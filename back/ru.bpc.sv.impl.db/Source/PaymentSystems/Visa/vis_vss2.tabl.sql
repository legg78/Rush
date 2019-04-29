create table vis_vss2 (
   id              number(12)
 , file_id         number(16)
 , record_number   number(6) 
 , status          varchar2(8)
 , dst_bin         varchar2(6)
 , src_bin         varchar2(6)
 , sre_id          varchar2(10)
 , up_sre_id       varchar2(10)
 , funds_id        varchar2(10)
 , sttl_service    varchar2(8)
 , sttl_currency   varchar2(3)
 , no_data         varchar2(1)
 , report_group    varchar2(1)
 , report_subgroup varchar2(1)
 , rep_id_num      varchar2(3)
 , rep_id_sfx      varchar2(2)
 , sttl_date       date
 , report_date     date
 , date_from       date
 , date_to         date
 , amount_type     varchar2(1)
 , bus_mode        varchar2(8)
 , trans_count     number(15)
 , credit_amount   number(15)
 , debit_amount    number(15)
 , net_amount      number(16)
 , reimb_attr      varchar2(1)
 , inst_id         number(4)
)
/

comment on table vis_vss2 is 'VISA VSS Type 2 Reports Table. This Table contains VISA VSS - 110 - M and VSS - 110 reports. The content of this table is updated as new VISA incoming file.'
/

comment on column vis_vss2.id is 'Unique internal message number'
/

comment on column vis_vss2.file_id is 'Unique internal file number'
/

comment on column vis_vss2.record_number is 'Record Number'
/

comment on column vis_vss2.status is 'Message status'
/

comment on column vis_vss2.dst_bin is 'Report destination BIN'
/

comment on column vis_vss2.src_bin is 'Source BIN'
/

comment on column vis_vss2.sre_id is 'Reporting For SRE Identifier. This is the identifier for the SRE being reported upon'
/

comment on column vis_vss2.up_sre_id is 'Rollup To SRE Identifier. ID of the SRE which is directly superior to the Reporting For SRE in the settlement hierarchy.'
/

comment on column vis_vss2.funds_id is 'Funds transfer SRE Identifier.'
/

comment on column vis_vss2.sttl_service is 'Settlement service identifier'
/

comment on column vis_vss2.sttl_currency is 'Settlement Currency Code'
/

comment on column vis_vss2.no_data is 'No Data Indicator. Y or Space.'
/

comment on column vis_vss2.report_group is 'Report group'
/

comment on column vis_vss2.report_subgroup is 'Report subgroup'
/

comment on column vis_vss2.rep_id_num is 'Report identification number (110)'
/

comment on column vis_vss2.rep_id_sfx is 'Report identification suffix (M or Space)'
/

comment on column vis_vss2.sttl_date is 'Settlement date YYYY - MM - DD. Initially comes in YYYYDDD format'
/

comment on column vis_vss2.report_date is 'Report creation date YYYY - MM - DD. Initially comes in YYYYDDD format'
/

comment on column vis_vss2.date_from is 'From Date. Starting range for report'
/

comment on column vis_vss2.date_to is 'To Date. Ending range for report'
/

comment on column vis_vss2.amount_type is 'Amount type. I - Interchange, F - Reimbursement Fees, C - VISA Charges, T - Total.'
/

comment on column vis_vss2.bus_mode is 'Business Mode'
/

comment on column vis_vss2.trans_count is 'Count. Interchange transaction count corresponding to business mode.'
/

comment on column vis_vss2.credit_amount is 'Credit Amount in minor currency units'
/

comment on column vis_vss2.debit_amount is 'Debit Amount in minor currency units'
/

comment on column vis_vss2.net_amount is 'Net Amount in minor currency units. May be positive or negative depending Net Amount Sign in initial record.'
/

comment on column vis_vss2.reimb_attr is 'Reimbursement Attribute.'
/

comment on column vis_vss2.inst_id is 'ID of the financial institution the record belongs to.'
/

alter table vis_vss2 add operation_id number(16)
/
comment on column vis_vss2.operation_id is 'ID of the operation created for GL Routing.'
/
alter table vis_vss2 modify record_number number(8)
/
