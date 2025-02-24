@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_RAP_T_GATE
  as select from zrap_t_gate
{
  key purchase_order as PurchaseOrder,
  key gate_entry_no as GateEntryNo,
  vehicle_num as VehicleNum,
  driver_name as DriverName,
  plant as Plant,
  location as Location,
  travel_date as TravelDate,
  gate_status as GateStatus,
   
  @Semantics.user.createdBy: true
  local_created_by as LocalCreatedBy,
  @Semantics.systemDateTime.createdAt: true
  local_created_at as LocalCreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  local_last_changed_by as LocalLastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed_at as LastChangedAt
  
}
