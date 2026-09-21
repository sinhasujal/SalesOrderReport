*&---------------------------------------------------------------------*
*& Class  ZCL_SO_REPORT
*&---------------------------------------------------------------------*
*& Holds the data-retrieval logic for the sales order report.
*&
*& Keeping the SELECT inside a class (instead of directly in the
*& report) means the logic can be reused by other programs and can be
*& covered by ABAP Unit tests.
*&---------------------------------------------------------------------*
CLASS zcl_so_report DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    " Range types - these match what SELECT-OPTIONS produces on the
    " selection screen of ZSO_REPORT.
    TYPES ty_vbeln_range TYPE RANGE OF zso_header-vbeln.
    TYPES ty_kunnr_range TYPE RANGE OF zso_header-kunnr.
    TYPES ty_erdat_range TYPE RANGE OF zso_header-erdat.

    " Not filled from the selection screen - built inside GET_ORDERS( )
    " so the open-orders filter can be pushed into the WHERE clause.
    TYPES ty_status_range TYPE RANGE OF zso_header-status.

    " One row of the report output (header + item fields joined)
    TYPES: BEGIN OF ty_output,
             vbeln  TYPE zso_header-vbeln,
             kunnr  TYPE zso_header-kunnr,
             erdat  TYPE zso_header-erdat,
             status TYPE zso_header-status,
             posnr  TYPE zso_item-posnr,
             matnr  TYPE zso_item-matnr,
             arktx  TYPE zso_item-arktx,
             kwmeng TYPE zso_item-kwmeng,
             netwr  TYPE zso_item-netwr,
             waerk  TYPE zso_header-waerk,
           END OF ty_output.

    TYPES ty_output_tab TYPE STANDARD TABLE OF ty_output WITH DEFAULT KEY.

    "! Reads sales orders and their items from the database.
    "! @parameter it_vbeln     | Sales order number range
    "! @parameter it_kunnr     | Customer number range
    "! @parameter it_erdat     | Created-on date range
    "! @parameter iv_only_open | ABAP_TRUE = return open orders only
    "! @parameter rt_output    | Joined header/item rows, sorted
    METHODS get_orders
      IMPORTING
        it_vbeln         TYPE ty_vbeln_range OPTIONAL
        it_kunnr         TYPE ty_kunnr_range OPTIONAL
        it_erdat         TYPE ty_erdat_range OPTIONAL
        iv_only_open     TYPE abap_bool      DEFAULT abap_false
      RETURNING
        VALUE(rt_output) TYPE ty_output_tab.

    "! Adds up the net value of all rows passed in.
    "! @parameter it_output | Report rows
    "! @parameter rv_total  | Sum of the NETWR column
    METHODS calculate_total
      IMPORTING
        it_output       TYPE ty_output_tab
      RETURNING
        VALUE(rv_total) TYPE zso_item-netwr.

    "! Counts how many distinct sales orders appear in the result.
    "! @parameter it_output | Report rows
    "! @parameter rv_count  | Number of distinct order numbers
    METHODS count_orders
      IMPORTING
        it_output       TYPE ty_output_tab
      RETURNING
        VALUE(rv_count) TYPE i.

  PRIVATE SECTION.

    CONSTANTS c_status_open TYPE zso_header-status VALUE 'O'.

ENDCLASS.


CLASS zcl_so_report IMPLEMENTATION.

  METHOD get_orders.

    " The "open orders only" checkbox is expressed as a range rather than
    " as a separate condition. A range with no rows imposes no restriction,
    " so the unticked case needs no second SELECT.
    DATA lt_status TYPE ty_status_range.

    IF iv_only_open = abap_true.
      lt_status = VALUE #( ( sign   = 'I'
                             option = 'EQ'
                             low    = c_status_open ) ).
    ENDIF.

    " Open SQL: join the header table to the item table on the order
    " number, and apply every filter in the WHERE clause so the database
    " returns only the rows the report will actually display. Sorting is
    " pushed down with ORDER BY for the same reason.
    SELECT h~vbeln, h~kunnr, h~erdat, h~status,
           i~posnr, i~matnr, i~arktx, i~kwmeng, i~netwr,
           h~waerk
      FROM zso_header AS h
      INNER JOIN zso_item AS i
        ON i~vbeln = h~vbeln
      WHERE h~vbeln  IN @it_vbeln
        AND h~kunnr  IN @it_kunnr
        AND h~erdat  IN @it_erdat
        AND h~status IN @lt_status
      ORDER BY h~vbeln, i~posnr
      INTO TABLE @rt_output.

  ENDMETHOD.


  METHOD calculate_total.

    " LS_OUTPUT is the work area: one row of the internal table at a
    " time is copied into it by the LOOP.
    DATA ls_output TYPE ty_output.

    LOOP AT it_output INTO ls_output.
      rv_total = rv_total + ls_output-netwr.
    ENDLOOP.

  ENDMETHOD.


  METHOD count_orders.

    DATA lt_orders TYPE STANDARD TABLE OF zso_header-vbeln WITH DEFAULT KEY.
    DATA ls_output TYPE ty_output.

    LOOP AT it_output INTO ls_output.
      APPEND ls_output-vbeln TO lt_orders.
    ENDLOOP.

    " Remove duplicates so each order is counted once.
    SORT lt_orders.
    DELETE ADJACENT DUPLICATES FROM lt_orders.

    rv_count = lines( lt_orders ).

  ENDMETHOD.

ENDCLASS.
