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
    out->write( |Total value : { lv_total } INR| ).

  ENDMETHOD.


  METHOD get_orders.

    " A host variable cannot be tested with IS INITIAL inside Open SQL,
    " so the empty-customer case is handled with a plain IF instead.
    IF iv_customer IS INITIAL.

      SELECT *
        FROM zi_salesorderitem
        ORDER BY SalesOrder, SalesOrderItem
        INTO TABLE @rt_orders.

    ELSE.

      SELECT *
        FROM zi_salesorderitem
        WHERE Customer = @iv_customer
        ORDER BY SalesOrder, SalesOrderItem
        INTO TABLE @rt_orders.

    ENDIF.

    IF iv_only_open = abap_true.
      DELETE rt_orders WHERE OrderStatus <> c_status_open.
    ENDIF.

  ENDMETHOD.


  METHOD calculate_total.

    DATA ls_order TYPE zi_salesorderitem.   " work area

    LOOP AT it_orders INTO ls_order.
      rv_total = rv_total + ls_order-NetValue.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
