*&---------------------------------------------------------------------*
*& Class  ZCL_SO_DATA_GEN_CLOUD
*&---------------------------------------------------------------------*
*& ABAP Cloud version of ZSO_DATA_GEN.
*&
*& Fills ZSO_HEADER and ZSO_ITEM with demo rows. Run once with F9 in
*& Eclipse before running ZCL_SO_REPORT_CLOUD.
*&
*& Uses the VALUE #( ) constructor to build the internal tables - the
*& modern equivalent of repeated work-area assignment plus APPEND.
*&---------------------------------------------------------------------*
CLASS zcl_so_data_gen_cloud DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

ENDCLASS.


CLASS zcl_so_data_gen_cloud IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    DATA lt_header TYPE STANDARD TABLE OF zso_header WITH DEFAULT KEY.
    DATA lt_item   TYPE STANDARD TABLE OF zso_item   WITH DEFAULT KEY.

    lt_header = VALUE #(
      ( vbeln = '0000000001' kunnr = 'CUST001' erdat = '20260901'
        status = 'O' netwr = '45000.00' waerk = 'INR' )
      ( vbeln = '0000000002' kunnr = 'CUST002' erdat = '20260903'
        status = 'C' netwr = '12500.00' waerk = 'INR' )
      ( vbeln = '0000000003' kunnr = 'CUST001' erdat = '20260910'
        status = 'O' netwr = '78000.00' waerk = 'INR' ) ).

    lt_item = VALUE #(
      ( vbeln = '0000000001' posnr = '000010' matnr = 'MAT-1001'
        arktx = 'Laptop Stand - Aluminium'
        kwmeng = '10.000' meins = 'EA' netwr = '25000.00' waerk = 'INR' )
      ( vbeln = '0000000001' posnr = '000020' matnr = 'MAT-1002'
        arktx = 'USB-C Docking Station'
        kwmeng = '5.000'  meins = 'EA' netwr = '20000.00' waerk = 'INR' )
      ( vbeln = '0000000002' posnr = '000010' matnr = 'MAT-2001'
        arktx = 'Wireless Keyboard'
        kwmeng = '25.000' meins = 'EA' netwr = '12500.00' waerk = 'INR' )
      ( vbeln = '0000000003' posnr = '000010' matnr = 'MAT-3001'
        arktx = '27 inch Monitor'
        kwmeng = '6.000'  meins = 'EA' netwr = '78000.00' waerk = 'INR' ) ).

    " Start from a clean slate so the class can be re-run safely
    DELETE FROM zso_item.
    DELETE FROM zso_header.

    INSERT zso_header FROM TABLE @lt_header.
    INSERT zso_item   FROM TABLE @lt_item.

    COMMIT WORK.

    out->write( 'Demo data created.' ).
    out->write( |Header rows: { lines( lt_header ) }| ).
    out->write( |Item rows  : { lines( lt_item ) }| ).

  ENDMETHOD.

ENDCLASS.
