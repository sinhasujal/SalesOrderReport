*&---------------------------------------------------------------------*
*& Class  ZCL_SO_REPORT_CLOUD
*&---------------------------------------------------------------------*
*& The ABAP Cloud version of ZSO_REPORT.
*&
*& There is no SAP GUI on BTP, so there is no selection screen and no
*& ALV grid. A console application (IF_OO_ADT_CLASSRUN) prints to the
*& ADT console instead - run it with F9 in Eclipse.
*&
*& The data is read through the CDS view ZI_SalesOrderItem rather than
*& by joining the tables directly, which is the ABAP Cloud way.
*&---------------------------------------------------------------------*
CLASS zcl_so_report_cloud DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun.

    TYPES ty_orders TYPE STANDARD TABLE OF zi_salesorderitem
                         WITH DEFAULT KEY.

    "! Reads sales order items, optionally only the open ones.
    METHODS get_orders
      IMPORTING
        iv_customer      TYPE zso_header-kunnr OPTIONAL
        iv_only_open     TYPE abap_bool        DEFAULT abap_false
      RETURNING
        VALUE(rt_orders) TYPE ty_orders.

    "! Adds up the net value of all rows passed in.
    METHODS calculate_total
      IMPORTING
        it_orders       TYPE ty_orders
      RETURNING
        VALUE(rv_total) TYPE zso_item-netwr.

    "! Counts how many distinct sales orders appear in the result.
    METHODS count_orders
      IMPORTING
        it_orders       TYPE ty_orders
      RETURNING
        VALUE(rv_count) TYPE i.

  PRIVATE SECTION.

    CONSTANTS c_status_open TYPE zso_header-status VALUE 'O'.

ENDCLASS.


CLASS zcl_so_report_cloud IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    DATA lt_orders TYPE ty_orders.
    DATA lv_total  TYPE zso_item-netwr.

    lt_orders = get_orders( iv_only_open = abap_true ).

    out->write( 'Sales Order Report - open orders' ).
    out->write( '================================' ).

    IF lt_orders IS INITIAL.
      out->write( 'No sales orders found. Run ZCL_SO_DATA_GEN_CLOUD first.' ).
      RETURN.
    ENDIF.

    out->write( lt_orders ).

    lv_total = calculate_total( lt_orders ).

    out->write( |Rows        : { lines( lt_orders ) }| ).
    out->write( |Orders      : { count_orders( lt_orders ) }| ).
    out->write( |Total value : { lv_total } INR| ).

  ENDMETHOD.


  METHOD get_orders.

    " A host variable cannot be tested with IS INITIAL inside Open SQL,
    " but a range can: a range with no rows imposes no restriction. Turning
    " both optional filters into ranges collapses what used to be two
    " SELECTs into one, and lets the database apply the status filter
    " instead of deleting rows from the internal table afterwards.
    DATA lt_customer TYPE RANGE OF zso_header-kunnr.
    DATA lt_status   TYPE RANGE OF zso_header-status.

    IF iv_customer IS NOT INITIAL.
      lt_customer = VALUE #( ( sign   = 'I'
                               option = 'EQ'
                               low    = iv_customer ) ).
    ENDIF.

    IF iv_only_open = abap_true.
      lt_status = VALUE #( ( sign   = 'I'
                             option = 'EQ'
                             low    = c_status_open ) ).
    ENDIF.

    " SELECT * is deliberate here: RT_ORDERS is typed as the CDS view
    " itself, so every column is used by the caller.
    SELECT *
      FROM zi_salesorderitem
      WHERE Customer    IN @lt_customer
        AND OrderStatus IN @lt_status
      ORDER BY SalesOrder, SalesOrderItem
      INTO TABLE @rt_orders.

  ENDMETHOD.


  METHOD calculate_total.

    DATA ls_order TYPE zi_salesorderitem.   " work area

    LOOP AT it_orders INTO ls_order.
      rv_total = rv_total + ls_order-NetValue.
    ENDLOOP.

  ENDMETHOD.


  METHOD count_orders.

    DATA lt_orders TYPE STANDARD TABLE OF zso_header-vbeln WITH DEFAULT KEY.
    DATA ls_order  TYPE zi_salesorderitem.

    LOOP AT it_orders INTO ls_order.
      APPEND ls_order-SalesOrder TO lt_orders.
    ENDLOOP.

    " Remove duplicates so each order is counted once.
    SORT lt_orders.
    DELETE ADJACENT DUPLICATES FROM lt_orders.

    rv_count = lines( lt_orders ).

  ENDMETHOD.

ENDCLASS.
