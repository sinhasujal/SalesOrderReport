@EndUserText.label : 'Sales Order Header (training, modelled on VBAK)'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table zso_header {

  key client : abap.clnt not null;
  key vbeln  : abap.char(10) not null;
  kunnr      : abap.char(10);
  erdat      : abap.dats;
  status     : abap.char(1);
  @Semantics.amount.currencyCode : 'zso_header.waerk'
  netwr      : abap.curr(15,2);
  waerk      : abap.cuky(5);

}
