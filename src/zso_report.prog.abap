*&---------------------------------------------------------------------*
*& Report  ZSO_REPORT
*&---------------------------------------------------------------------*
*& Purpose : Display sales orders and their line items, with an
*&           optional filter for open orders only.
*&
*& Author  : Sujal Sinha
*& Concepts: Selection screen and its validation, authorization check,
*&           Open SQL (INNER JOIN), Internal Table, Work Area,
*&           Modularization (FORM/PERFORM), ALV output.
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
*& Selection screen validation
*&---------------------------------------------------------------------*
*& AT SELECTION-SCREEN runs after the user presses F8, but before
*& START-OF-SELECTION. A type 'E' message raised here returns the user
*& to the screen with the offending field ready for correction, instead
*& of running the report and showing an empty list.
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.

  PERFORM validate_selection.

*&---------------------------------------------------------------------*
*& Main processing block
*&---------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM check_authority.
  PERFORM get_data.
  PERFORM display_data.

*&---------------------------------------------------------------------*
*& Form VALIDATE_SELECTION
*&---------------------------------------------------------------------*
*& Checks the created-on range the user typed in.
*&
*& SELECT-OPTIONS does not enforce that the "to" value is later than the
*& "from" value. A reversed range is accepted and simply returns no
*& rows, which reads as a broken report rather than a typo in the input.
*&---------------------------------------------------------------------*
FORM validate_selection.

  DATA ls_erdat LIKE LINE OF s_erdat.

  LOOP AT s_erdat INTO ls_erdat.

    IF ls_erdat-high IS NOT INITIAL AND ls_erdat-high < ls_erdat-low.
      MESSAGE 'Created on: the to-date is earlier than the from-date'
              TYPE 'E'.
    ENDIF.

    IF ls_erdat-low > sy-datum.
      MESSAGE 'Created on: the from-date is in the future' TYPE 'E'.
    ENDIF.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form CHECK_AUTHORITY
*&---------------------------------------------------------------------*
*& A report that reads business data should check that the user is
*& allowed to see it, before it reads anything.
*&
*& S_TABU_DIS is the standard authorization object for table display.
*& '&NC&' is the authorization group used for tables that have not been
*& assigned one, which is the case for ZSO_HEADER and ZSO_ITEM. Activity
*& '03' is display.
*&---------------------------------------------------------------------*
FORM check_authority.

  AUTHORITY-CHECK OBJECT 'S_TABU_DIS'
    ID 'DICBERCLS' FIELD '&NC&'
    ID 'ACTVT'     FIELD '03'.

  IF sy-subrc <> 0.
    MESSAGE 'You are not authorised to display sales order data'
            TYPE 'E'.
  ENDIF.

ENDFORM.

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
