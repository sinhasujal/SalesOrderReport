*&---------------------------------------------------------------------*
*& Report  ZSO_REPORT
*&---------------------------------------------------------------------*
*& Purpose : Display sales orders and their line items, with an
*&           optional filter for open orders only.
*&
*& Author  : Sujal Sinha
*& Concepts: Selection screen, Open SQL (INNER JOIN), Internal Table,
*&           Work Area, Modularization (FORM/PERFORM), ALV output.
*&
*& Note    : The tables ZSO_HEADER / ZSO_ITEM are custom (Z) tables
*&           modelled on the standard SAP tables VBAK / VBAP so that
*&           the report can run on any system, including a trial.
*&---------------------------------------------------------------------*
REPORT zso_report.

" TABLES is declared only so the SELECT-OPTIONS below can reference
" the field types of ZSO_HEADER. We do not use the table work area itself.
TABLES zso_header.

*&---------------------------------------------------------------------*
*& Global data
*&---------------------------------------------------------------------*
" The output structure is defined once, in the class, and reused here.
" Internal table = a table held in memory for the runtime of the program.
DATA gt_output TYPE zcl_so_report=>ty_output_tab.

*&---------------------------------------------------------------------*
*& Selection screen
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS: s_vbeln FOR zso_header-vbeln,   " Order number range
                s_kunnr FOR zso_header-kunnr,   " Customer range
                s_erdat FOR zso_header-erdat.   " Created-on date range
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-002.
PARAMETERS p_open AS CHECKBOX DEFAULT 'X'.      " Only open orders
SELECTION-SCREEN END OF BLOCK b2.

*&---------------------------------------------------------------------*
*& Main processing block
*&---------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM get_data.
  PERFORM display_data.

*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& Reads the data from the database into the internal table GT_OUTPUT.
*& The actual SELECT is delegated to the class ZCL_SO_REPORT so the
*& same logic can be reused and unit-tested.
*&---------------------------------------------------------------------*
FORM get_data.

  DATA lo_report TYPE REF TO zcl_so_report.

  " Create an instance of our report class (basic OO ABAP)
  CREATE OBJECT lo_report.

  gt_output = lo_report->get_orders(
                it_vbeln     = s_vbeln[]
                it_kunnr     = s_kunnr[]
                it_erdat     = s_erdat[]
                iv_only_open = p_open ).

  IF gt_output IS INITIAL.
    MESSAGE 'No sales orders found for the given selection' TYPE 'S'
                                                        DISPLAY LIKE 'W'.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form DISPLAY_DATA
*&---------------------------------------------------------------------*
*& Shows the internal table in a simple ALV grid.
*&---------------------------------------------------------------------*
FORM display_data.

  DATA lo_alv TYPE REF TO cl_salv_table.
  DATA lo_msg TYPE REF TO cx_salv_msg.

  IF gt_output IS INITIAL.
    RETURN.
  ENDIF.

  TRY.
      " Build the ALV object from our internal table
      cl_salv_table=>factory(
        IMPORTING
          r_salv_table = lo_alv
        CHANGING
          t_table      = gt_output ).

      " Switch on the standard toolbar (sort, filter, export to Excel)
      lo_alv->get_functions( )->set_all( abap_true ).

      " Stripe the rows so the list is easier to read
      lo_alv->get_display_settings( )->set_striped_pattern( abap_true ).
      lo_alv->get_display_settings( )->set_list_header(
                                         'Sales Order Report' ).

      lo_alv->display( ).

    CATCH cx_salv_msg INTO lo_msg.
      MESSAGE lo_msg->get_text( ) TYPE 'E'.
  ENDTRY.

ENDFORM.
