@EndUserText.label : 'Sales Order Item (training, modelled on VBAP)'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table zso_item {

  key client : abap.clnt not null;
  key vbeln  : abap.char(10) not null;
  key posnr  : abap.numc(6) not null;
  matnr      : abap.char(18);
  arktx      : abap.char(40);
  @Semantics.quantity.unitOfMeasure : 'zso_item.meins'
  kwmeng     : abap.quan(13,3);
  meins      : abap.unit(3);
  @Semantics.amount.currencyCode : 'zso_item.waerk'
  netwr      : abap.curr(15,2);
  waerk      : abap.cuky(5);

}
