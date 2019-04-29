create table vis_vss1 (
   id              number(16)
 , file_id         number(16)
 , record_number   number(6)
 , status          varchar2(8)
 , dst_bin         varchar2(6)
 , src_bin         varchar2(6)
 , sre_id          varchar2(10)
 , sttl_service    varchar2(8)
 , report_date     date
 , sre_level       number(1)
 , report_group    varchar2(1)
 , report_subgroup varchar2(1)
 , rep_id_num      varchar2(3)
 , rep_id_sfx      varchar2(2)
 , sub_sre_id      varchar2(10)
 , sub_sre_name    varchar2(15)
 , funds_ind       varchar2(1)
 , entity_type     varchar2(1)
 , entity_id1      varchar2(18)
 , entity_id2      varchar2(18)
 , proc_sind       varchar2(1)
 , proc_id         varchar2(10)
 , network_sind    varchar2(1)
 , network_id      varchar2(4)
 , reimb_attr      varchar2(1)
 , inst_id         number(4)
)
/

comment on table vis_vss1 is 'VISA VSS Type 1 Reports Table. This Table contains VISA VSS - 100 - W reports. The content of this table is updated as new VISA incoming file.'
/

comment on column vis_vss1.id is 'Unique internal message number'
/

comment on column vis_vss1.file_id is 'Unique internal file number'
/

comment on column vis_vss1.record_number is 'Record number'
/

comment on column vis_vss1.status is 'Message status'
/

comment on column vis_vss1.dst_bin is 'Report destination BIN'
/

comment on column vis_vss1.src_bin is 'Source BIN'
/

comment on column vis_vss1.sre_id is 'This is the identifier for the SRE being reported upon'
/

comment on column vis_vss1.sttl_service is 'Settlement service identifier'
/

comment on column vis_vss1.report_date is 'Report creation date YYYY - MM - DD. Initially comes in YYYYDDD format'
/

comment on column vis_vss1.sre_level is 'SRE level number'
/

comment on column vis_vss1.report_group is 'Report group'
/

comment on column vis_vss1.report_subgroup is 'Report subgroup'
/

comment on column vis_vss1.rep_id_num is 'Report identification number (100)'
/

comment on column vis_vss1.rep_id_sfx is 'Report identification suffix (W)'
/

comment on column vis_vss1.sub_sre_id is 'Subordinate SRE ID. This contains the identifier of the SRE represented by this record.'
/

comment on column vis_vss1.sub_sre_name is 'Subordinate SRE name'
/

comment on column vis_vss1.funds_ind is 'Funds transfer indicator. Y for Funds Transfer SRE, N for not Funds Transfer SRE.'
/

comment on column vis_vss1.entity_type is 'Clearing entity identifier type. A - card account range, B - BIN, P - processor charges SRE.'
/

comment on column vis_vss1.entity_id1 is 'Clearing entity identifier 1. May contain starting value for card account range, BIN number (last 6 digits), spaces depending ENTITY_TYPE field.'
/

comment on column vis_vss1.entity_id2 is 'Clearing entity identifier 2. May contain ending value for card account range or spaces depending ENTITY_TYPE field.'
/

comment on column vis_vss1.proc_sind is 'Processor specified indicator. Y if the processor identifier is specified, N - otherwise.'
/

comment on column vis_vss1.proc_id is 'Processor Identifier. Filled with the processor identifier used to match transactions to this subordinate SRE if Y in PROC_SIND field, otherwise spaces.'
/

comment on column vis_vss1.network_sind is 'Network Specified Indicator. Y if the network identifier is specified, N - otherwise.'
/

comment on column vis_vss1.network_id is 'Network Identifier. Filled if NET_SIND = Y.'
/

comment on column vis_vss1.reimb_attr is 'Reimbursement Attribute.'
/

comment on column vis_vss1.inst_id is 'ID of the financial institution the record belongs to.'
/
alter table vis_vss1 modify record_number number(8)
/
