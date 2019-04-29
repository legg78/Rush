create table vis_vss4 (
    id                  number(16)
  , file_id             number(16)
  , record_number       number(8)
  , status              varchar2(8) 
  , dst_bin             varchar2(6)
  , src_bin             varchar2(6)
  , sre_id              varchar2(10)
  , up_sre_id           varchar2(10)
  , funds_id            varchar2(10)
  , sttl_service        varchar2(8)
  , sttl_currency       varchar2(3)
  , clear_currency      varchar2(3)
  , bus_mode            varchar2(8)
  , no_data             varchar2(1)
  , report_group        varchar2(1)
  , report_subgroup     varchar2(1)
  , rep_id_num          varchar2(3)
  , rep_id_sfx          varchar2(2)
  , sttl_date           date
  , report_date         date
  , date_from           date
  , date_to             date
  , charge_type         varchar2(8)
  , bus_tr_type         varchar2(8)
  , bus_tr_cycle        varchar2(8)
  , revers_ind          varchar2(1)
  , return_ind          varchar2(1)
  , jurisdict           varchar2(8)
  , routing             varchar2(1)
  , src_country         varchar2(3)
  , dst_country         varchar2(3)
  , src_region          varchar2(2)
  , dst_region          varchar2(2)
  , fee_level           varchar2(16)
  , cr_db_net           varchar2(1)
  , summary_level       varchar2(8)
  , reimb_attr          varchar2(1)
  , currency_table_date date
  , first_count         number(15)
  , second_count        number(15)
  , first_amount        number(16)
  , second_amount       number(16)
  , third_amount        number(16)
  , fourth_amount       number(16)
  , fifth_amount        number(16)
  , inst_id             number(4)
)
/

comment on table vis_vss4 is 'VISA VSS Type 4 Reports Table. This Table contains VISA VSS - 120, 130, 135, 140, 210 and 230 reports. The content of this table is updated as new VISA incoming file coming. One record contains both TCR0 and TCR1 of TC46.'
/

comment on column vis_vss4.id is 'Unique internal message number'
/

comment on column vis_vss4.file_id is 'Unique internal file number'
/

comment on column vis_vss4.record_number is 'Record Number'
/

comment on column vis_vss4.status is 'Message status'
/

comment on column vis_vss4.dst_bin is 'Report destination BIN'
/

comment on column vis_vss4.src_bin is 'Source BIN'
/

comment on column vis_vss4.sre_id is 'Reporting For SRE Identifier. This is the identifier for the SRE being reported upon'
/

comment on column vis_vss4.up_sre_id is 'Rollup To SRE Identifier. ID of the SRE which is directly superior to the Reporting For SRE in the settlement hierarchy.'
/

comment on column vis_vss4.funds_id is 'Funds transfer SRE Identifier.'
/

comment on column vis_vss4.sttl_service is 'Settlement service identifier'
/

comment on column vis_vss4.sttl_currency is 'Settlement Currency Code'
/

comment on column vis_vss4.clear_currency is 'Clearing Currency Code'
/

comment on column vis_vss4.bus_mode is 'Business Mode.'
/

comment on column vis_vss4.no_data is 'No Data Indicator. Y or Space.'
/

comment on column vis_vss4.report_group is 'Report group'
/

comment on column vis_vss4.report_subgroup is 'Report subgroup'
/

comment on column vis_vss4.rep_id_num is 'Report identification number'
/

comment on column vis_vss4.rep_id_sfx is 'Report identification suffix'
/

comment on column vis_vss4.sttl_date is 'Settlement date YYYY - MM - DD. Initially comes in YYYYDDD format'
/

comment on column vis_vss4.report_date is 'Report creation date YYYY - MM - DD. Initially comes in YYYYDDD format'
/

comment on column vis_vss4.date_from is 'From Date. Starting range for report'
/

comment on column vis_vss4.date_to is 'To Date. Ending range for report'
/

comment on column vis_vss4.charge_type is 'Charge Type Code.'
/

comment on column vis_vss4.bus_tr_type is 'Business Transaction Type. '
/

comment on column vis_vss4.bus_tr_cycle is 'Business Transaction Cycle. '
/

comment on column vis_vss4.revers_ind is 'Reversal Indicator. Y or N.'
/

comment on column vis_vss4.return_ind is 'Return Indicator. Y or N.'
/

comment on column vis_vss4.jurisdict is 'Jurisdiction Code'
/

comment on column vis_vss4.routing is 'Inter - regional Routing Indicator. Y or N.'
/

comment on column vis_vss4.src_country is 'Source Country Code'
/

comment on column vis_vss4.dst_country is 'Destination Country Code'
/

comment on column vis_vss4.src_region is 'Source Region Code'
/

comment on column vis_vss4.dst_region is 'Destination Region Code'
/

comment on column vis_vss4.fee_level is 'Fee Level Descriptor.'
/

comment on column vis_vss4.cr_db_net is 'CR/DB/NET Indicator. C - Credit Line, D - Debit Line, N - Net Line.'
/

comment on column vis_vss4.summary_level is 'Summary Level'
/

comment on column vis_vss4.reimb_attr is 'Reimbursement Attribute.'
/

comment on column vis_vss4.currency_table_date is 'Currency Table Date. YYYY - MM - DD. Initially comes in YYYYDDD format'
/

comment on column vis_vss4.first_count is 'First Count.'
/

comment on column vis_vss4.second_count is 'Second Count.'
/

comment on column vis_vss4.first_amount is 'First Amount in minor currency units. May be positive or negative depending on First Amount Sign in initial record.'
/

comment on column vis_vss4.second_amount is 'Second Amount in minor currency units. May be positive or negative depending on Second Amount Sign in initial record.'
/

comment on column vis_vss4.third_amount is 'Third Amount in minor currency units. May be positive or negative depending on Third Amount Sign in initial record.'
/

comment on column vis_vss4.fourth_amount is 'Fourth Amount in minor currency units. May be positive or negative depending on Fourth Amount Sign in initial record.'
/

comment on column vis_vss4.fifth_amount is 'Firth Amount in minor currency units. May be positive or negative depending on Fifth Amount Sign in initial record.'
/

comment on column vis_vss4.inst_id is 'ID of the financial institution the record belongs to. '
/
alter table vis_vss4 modify record_number number(8)
/
