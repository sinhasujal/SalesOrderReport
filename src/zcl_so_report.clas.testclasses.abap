*&---------------------------------------------------------------------*
*& Local test class for ZCL_SO_REPORT
*&---------------------------------------------------------------------*
*& Run in ADT/SE80 with Ctrl+Shift+F10 (Run -> Unit Test).
*&
*& Only the calculation methods are tested here. They work purely on an
*& internal table passed in, so the tests need no data in the database.
*&---------------------------------------------------------------------*
CLASS ltcl_so_report DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    " CUT = "code under test", the usual name for the object being tested
    DATA mo_cut TYPE REF TO zcl_so_report.

    METHODS setup.

    " Helper that builds one output row
    METHODS build_row
      IMPORTING
        iv_vbeln      TYPE zso_header-vbeln
        iv_netwr      TYPE zso_item-netwr
      RETURNING
        VALUE(rs_row) TYPE zcl_so_report=>ty_output.

    METHODS total_of_three_rows   FOR TESTING.
    METHODS total_of_empty_table  FOR TESTING.
    METHODS count_distinct_orders FOR TESTING.
    METHODS count_of_empty_table  FOR TESTING.

ENDCLASS.


CLASS ltcl_so_report IMPLEMENTATION.

  METHOD setup.
    " Runs before every single test method
    CREATE OBJECT mo_cut.
  ENDMETHOD.


  METHOD build_row.
    rs_row-vbeln = iv_vbeln.
    rs_row-netwr = iv_netwr.
    rs_row-waerk = 'INR'.
  ENDMETHOD.


  METHOD total_of_three_rows.

    DATA lt_rows  TYPE zcl_so_report=>ty_output_tab.
    DATA lv_total TYPE zso_item-netwr.

    APPEND build_row( iv_vbeln = '0000000001' iv_netwr = '100.00' ) TO lt_rows.
    APPEND build_row( iv_vbeln = '0000000001' iv_netwr = '150.50' ) TO lt_rows.
    APPEND build_row( iv_vbeln = '0000000002' iv_netwr = '99.50'  ) TO lt_rows.

    lv_total = mo_cut->calculate_total( lt_rows ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_total
      exp = '350.00'
      msg = 'Total of 100.00 + 150.50 + 99.50 should be 350.00' ).

  ENDMETHOD.


  METHOD total_of_empty_table.

    DATA lt_rows  TYPE zcl_so_report=>ty_output_tab.
    DATA lv_total TYPE zso_item-netwr.

    lv_total = mo_cut->calculate_total( lt_rows ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_total
      exp = 0
      msg = 'Total of an empty table should be zero' ).

  ENDMETHOD.


  METHOD count_distinct_orders.

    DATA lt_rows  TYPE zcl_so_report=>ty_output_tab.
    DATA lv_count TYPE i.

    " Three rows, but only two different order numbers
    APPEND build_row( iv_vbeln = '0000000001' iv_netwr = '100.00' ) TO lt_rows.
    APPEND build_row( iv_vbeln = '0000000001' iv_netwr = '150.50' ) TO lt_rows.
    APPEND build_row( iv_vbeln = '0000000002' iv_netwr = '99.50'  ) TO lt_rows.

    lv_count = mo_cut->count_orders( lt_rows ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_count
      exp = 2
      msg = 'Three item rows across two orders should count as 2' ).

  ENDMETHOD.


  METHOD count_of_empty_table.

    DATA lt_rows  TYPE zcl_so_report=>ty_output_tab.
    DATA lv_count TYPE i.

    lv_count = mo_cut->count_orders( lt_rows ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_count
      exp = 0
      msg = 'An empty table contains no orders' ).

  ENDMETHOD.

ENDCLASS.
