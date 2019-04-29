create table csm_stop_list(
    id                  number(16)
  , stop_list_type      varchar2(8)
  , reason_code         varchar2(8)
  , purge_date          date
  , region_list         varchar2(200)
)
/

comment on table csm_stop_list is 'IPS stop lists'
/
comment on column csm_stop_list.id is 'Primary key'
/
comment on column csm_stop_list.stop_list_type is 'Type of a stop list (dictionary ISLT)'
/
comment on column csm_stop_list.reason_code is 'Reason code (dictionary value)'
/
comment on column csm_stop_list.purge_date is 'Purge date'
/
comment on column csm_stop_list.region_list is 'List of regions'
/
alter table csm_stop_list add (product varchar2(8))
/
comment on column csm_stop_list.product is 'MasterCard Product Identifier.'
/
