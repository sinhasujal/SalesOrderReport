*&---------------------------------------------------------------------*
*& Report  ZSO_DATA_GEN
*&---------------------------------------------------------------------*
*& Fills ZSO_HEADER and ZSO_ITEM with a small set of demo sales orders
*& so that ZSO_REPORT has something to display.
*&
*& Run this ONCE after the tables have been activated.
*&
*& Concepts: Internal tables, work areas, APPEND, INSERT ... FROM TABLE.
*&---------------------------------------------------------------------*
REPORT zso_data_gen.

PARAMETERS p_clear AS CHECKBOX DEFAULT 'X'.   " Delete existing rows first

START-OF-SELECTION.

  PERFORM fill_demo_data.

*&---------------------------------------------------------------------*
*& Form FILL_DEMO_DATA
*&---------------------------------------------------------------------*
FORM fill_demo_data.

  " Internal tables that will be written to the database in one go
  DATA lt_header TYPE STANDARD TABLE OF zso_header WITH DEFAULT KEY.
  DATA lt_item   TYPE STANDARD TABLE OF zso_item   WITH DEFAULT KEY.

  " Work areas - one row at a time is built here, then APPENDed
  DATA ls_header TYPE zso_header.
  DATA ls_item   TYPE zso_item.

  IF p_clear = 'X'.
    DELETE FROM zso_item.
    DELETE FROM zso_header.
  ENDIF.

  "--- Order 1 -------------------------------------------------------
  CLEAR ls_header.
  ls_header-vbeln  = '0000000001'.
  ls_header-kunnr  = 'CUST001'.
  ls_header-erdat  = '20260901'.
  ls_header-status = 'O'.
  ls_header-netwr  = '45000.00'.
  ls_header-waerk  = 'INR'.
  APPEND ls_header TO lt_header.

  CLEAR ls_item.
  ls_item-vbeln  = '0000000001'.
  ls_item-posnr  = '000010'.
  ls_item-matnr  = 'MAT-1001'.
  ls_item-arktx  = 'Laptop Stand - Aluminium'.
  ls_item-kwmeng = '10.000'.
  ls_item-meins  = 'EA'.
  ls_item-netwr  = '25000.00'.
  ls_item-waerk  = 'INR'.
  APPEND ls_item TO lt_item.

  CLEAR ls_item.
  ls_item-vbeln  = '0000000001'.
  ls_item-posnr  = '000020'.
  ls_item-matnr  = 'MAT-1002'.
  ls_item-arktx  = 'USB-C Docking Station'.
  ls_item-kwmeng = '5.000'.
  ls_item-meins  = 'EA'.
  ls_item-netwr  = '20000.00'.
  ls_item-waerk  = 'INR'.
  APPEND ls_item TO lt_item.

  "--- Order 2 -------------------------------------------------------
  CLEAR ls_header.
  ls_header-vbeln  = '0000000002'.
  ls_header-kunnr  = 'CUST002'.
  ls_header-erdat  = '20260903'.
  ls_header-status = 'C'.
  ls_header-netwr  = '12500.00'.
  ls_header-waerk  = 'INR'.
  APPEND ls_header TO lt_header.

  CLEAR ls_item.
  ls_item-vbeln  = '0000000002'.
  ls_item-posnr  = '000010'.
  ls_item-matnr  = 'MAT-2001'.
  ls_item-arktx  = 'Wireless Keyboard'.
  ls_item-kwmeng = '25.000'.
  ls_item-meins  = 'EA'.
  ls_item-netwr  = '12500.00'.
  ls_item-waerk  = 'INR'.
  APPEND ls_item TO lt_item.

  "--- Order 3 -------------------------------------------------------
  CLEAR ls_header.
  ls_header-vbeln  = '0000000003'.
  ls_header-kunnr  = 'CUST001'.
  ls_header-erdat  = '20260910'.
  ls_header-status = 'O'.
  ls_header-netwr  = '78000.00'.
  ls_header-waerk  = 'INR'.
  APPEND ls_header TO lt_header.

  CLEAR ls_item.
  ls_item-vbeln  = '0000000003'.
  ls_item-posnr  = '000010'.
  ls_item-matnr  = 'MAT-3001'.
  ls_item-arktx  = '27 inch Monitor'.
  ls_item-kwmeng = '6.000'.
  ls_item-meins  = 'EA'.
  ls_item-netwr  = '78000.00'.
  ls_item-waerk  = 'INR'.
  APPEND ls_item TO lt_item.

  "--- Write both internal tables to the database ---------------------
  INSERT zso_header FROM TABLE lt_header.
  INSERT zso_item   FROM TABLE lt_item.

  COMMIT WORK.

  WRITE: / 'Demo data created.'.
  WRITE: / 'Header rows:', lines( lt_header ).
  WRITE: / 'Item rows  :', lines( lt_item ).

ENDFORM.
