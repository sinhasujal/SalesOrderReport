@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales orders with their items'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_SalesOrderItem
  as select from zso_header as Header
    inner join   zso_item   as Item
      on Header.vbeln = Item.vbeln
{
      key Header.vbeln  as SalesOrder,
      key Item.posnr    as SalesOrderItem,
          Header.kunnr  as Customer,
          Header.erdat  as CreatedOn,
          Header.status as OrderStatus,
          Item.matnr    as Material,
          Item.arktx    as MaterialDescription,

          @Semantics.quantity.unitOfMeasure: 'BaseUnit'
          Item.kwmeng   as Quantity,
          Item.meins    as BaseUnit,

          @Semantics.amount.currencyCode: 'Currency'
          Item.netwr    as NetValue,
          Item.waerk    as Currency
}
