create table vis_vss6 (
    id              number(16)
  , file_id         number(16)
  , record_number   number(8)
  , status          varchar2(8)
  , dst_bin         varchar2(6)
  , src_bin         varchar2(6)
  , sre_id          varchar2(10)
  , proc_id         varchar2(10)
  , clear_bin       varchar2(10)
  , clear_currency  varchar2(3)
  , sttl_service    varchar2(8)
  , bus_mode        varchar2(8)
  , no_data         varchar2(1)
  , report_group    varchar2(1)
  , report_subgroup varchar2(1)
  , rep_id_num      varchar2(3)
  , rep_id_sfx      varchar2(2)
  , sttl_date       date
  , report_date     date
  , fin_ind         varchar2(1) 
  , clear_only      varchar2(1)
  , bus_tr_type     varchar2(8)
  , bus_tr_cycle    varchar2(8)
  , reversal        varchar2(1)
  , trans_dispos    varchar2(8)
  , trans_count     number(15)
  , amount          number(16)
  , summary_level   varchar2(8)
  , reimb_attr      varchar2(1)
  , inst_id         number(4)
)
/

comment on table vis_vss6 is 'VISA VSS Type 6 Reports Table. This Table contains VISA VSS - 900 reports. The content of this table is updated as new VISA incoming file comes.'
/

comment on column vis_vss6.id is 'Unique internal message number'
/

comment on column vis_vss6.file_id is 'Unique internal file number'
/

comment on column vis_vss6.record_number is 'Record Number'
/

comment on column vis_vss6.status is 'Message status'
/

comment on column vis_vss6.dst_bin is 'Report destination BIN'
/

comment on column vis_vss6.src_bin is 'Source BIN'
/

comment on column vis_vss6.sre_id is 'Reporting For SRE Identifier. This is the identifier for the SRE being reported upon'
/

comment on column vis_vss6.proc_id is 'Processor Identifier for which this report was requested.'
/

comment on column vis_vss6.clear_bin is 'Clearing BIN.'
/

comment on column vis_vss6.clear_currency is 'Clearing Currency Code'
/

comment on column vis_vss6.sttl_service is 'Settlement service identifier.'
/

comment on column vis_vss6.bus_mode is 'Business Mode.'
/

comment on column vis_vss6.no_data is 'No Data Indicator. Y or Space.'
/

comment on column vis_vss6.report_group is 'Report group'
/

comment on column vis_vss6.report_subgroup is 'Report subgroup'
/

comment on column vis_vss6.rep_id_num is 'Report identification number'
/

comment on column vis_vss6.rep_id_sfx is 'Report identification suffix'
/

comment on column vis_vss6.sttl_date is 'Settlement date YYYY - MM - DD. Initially comes in YYYYDDD format'
/

comment on column vis_vss6.report_date is 'Report creation date YYYY - MM - DD. Initially comes in YYYYDDD format'
/

comment on column vis_vss6.fin_ind is 'Financial Indicator, Y or N.'
/

comment on column vis_vss6.clear_only is 'Clearing Only Indicator, Y or N.'
/

comment on column vis_vss6.bus_tr_type is 'Business Transaction Type'
/

comment on column vis_vss6.bus_tr_cycle is 'Business Transaction Cycle. '
/

comment on column vis_vss6.reversal is 'Reversal Indicator. Y or N.'
/

comment on column vis_vss6.trans_dispos is 'Transaction Disposition'
/

comment on column vis_vss6.trans_count is 'Transaction Count.'
/

comment on column vis_vss6.amount is 'Amount in minor currency units. May be positive or negative depending on Amount Sign in original record.'
/

comment on column vis_vss6.summary_level is 'Summary Level.'
/

comment on column vis_vss6.reimb_attr is 'Reimbursement Attribute.'
/

comment on column vis_vss6.inst_id is 'ID of the financial institution the record belongs to. '
/

alter table vis_vss6 add (crs_date date)
/
comment on column vis_vss6.crs_date is 'The date on which the transaction was sent to CRS. Initially comes in DDMMMYY format.'
/
alter table vis_vss6 modify record_number number(8)
/
