@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity ZC_RAP_T_GATE
  provider contract transactional_query
  as projection on ZR_RAP_T_GATE
{
  key PurchaseOrder,
  key GateEntryNo,
  VehicleNum,
  DriverName,
  Plant,
  Location,
  TravelDate,
  GateStatus,
  
  LocalCreatedBy,
  LocalCreatedAt,
  LocalLastChangedBy,
  LocalLastChangedAt,
  LastChangedAt
  
}
