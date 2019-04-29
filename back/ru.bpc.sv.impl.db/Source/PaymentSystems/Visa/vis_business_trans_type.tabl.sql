create table vis_business_trans_type 
(
 trans_code               varchar2(2),
 reason_code              varchar2(4),
 business_trans_type      varchar2(8)
)
/
comment on table vis_business_trans_type
  is 'Mapping of visa clearing trxns with VSS Business transacition types, additional info in VisaNet Settlement Service docs '
/
comment on column vis_business_trans_type.trans_code
  is 'VISA transaction code'
/
comment on column vis_business_trans_type.reason_code
  is 'VISA reason code'
/
comment on column vis_business_trans_type.business_trans_type
  is 'Business Transaction Type from vss4 reports'
/  
