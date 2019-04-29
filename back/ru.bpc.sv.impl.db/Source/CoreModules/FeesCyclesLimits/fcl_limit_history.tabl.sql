create table fcl_limit_history (
    id                  number(16)
  , entity_type         varchar2(8)
  , object_id           number(16)
  , limit_type          varchar2(8)
  , count_value         number(16)
  , sum_value           number(22,4)
  , source_entity_type  varchar2(8)
  , source_object_id    number(16)
  , split_hash          number(4)
  , part_key            as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual  -- [@skip patch]
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH')) -- [@skip patch]
subpartition by list (split_hash)                                   -- [@skip patch]
subpartition template                                               -- [@skip patch]
(
    <subpartition_list>                                             -- [@skip patch]
)                                                                   -- [@skip patch]
(                                                                   -- [@skip patch]
    partition fcl_limit_history_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))   -- [@skip patch]
)
******************** partition end ********************/
/

comment on table fcl_limit_history is 'Limits changes history.'
/

comment on column fcl_limit_history.id is 'Primary key.'
/
comment on column fcl_limit_history.entity_type is 'Limit owner entity type.'
/
comment on column fcl_limit_history.object_id is 'Limit owner identifier.'
/
comment on column fcl_limit_history.limit_type is 'Limit type.'
/
comment on column fcl_limit_history.count_value is 'Count value changed limit counter.'
/
comment on column fcl_limit_history.sum_value is 'Sum value changed limit counter.'
/
comment on column fcl_limit_history.source_entity_type is 'Reason of limit change. Financial operation entity type (Operation, Authorization etc.).'
/
comment on column fcl_limit_history.source_object_id is 'Financial operation identifier.'
/
comment on column fcl_limit_history.split_hash is 'Hash value to split further processing.'
/
begin
    for rec in (select count(1) cnt from user_tab_columns where table_name = 'FCL_LIMIT_HISTORY' and column_name = 'PART_KEY')
    loop
        if rec.cnt = 0 then
            execute immediate 'alter table fcl_limit_history add (part_key as (to_date(substr(lpad(to_char(id), 16, ''0''), 1, 6), ''yymmdd'')) virtual)';
            execute immediate 'comment on column fcl_limit_history.part_key is ''Partition key''';
        end if;
    end loop;
end;
/
