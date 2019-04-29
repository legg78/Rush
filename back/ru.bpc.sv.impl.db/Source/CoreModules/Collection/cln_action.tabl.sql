create table cln_action ( 
    id                   number(16)
  , part_key             as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd'))
  , case_id              number(16) 
  , seqnum               number(4)
  , split_hash           number(4)
  , activity_category    varchar2(8)
  , activity_type        varchar2(8)
  , user_id              number(8)
  , action_date          date
  , eff_date             date
  , status               varchar2(8)
  , resolution           varchar2(8)
  , commentary           varchar2(2000)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))
subpartition by list (split_hash)
subpartition template
(
    <subpartition_list>
)
(
  partition cln_action_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))
)
******************** partition end ********************/
/
comment on table cln_action is 'Case activity.'
/
comment on column cln_action.id is 'Primary key.'
/
comment on column cln_action.case_id is 'Reference to case identifier (cln_case.id)'
/
comment on column cln_action.seqnum is 'Sequence number. Describe data version.'
/
comment on column cln_action.split_hash is 'Hash value to split processing'
/
comment on column cln_action.activity_category is 'Activity category: Collector activity, Customer response, Planned activity, System activity. Dictionary CNAC.'
/
comment on column cln_action.activity_type is 'Activity type. Dictionary CRAT, CSRS. There is may be event (EVNT)'
/
comment on column cln_action.user_id is 'User identifier (acm_user.id)'
/
comment on column cln_action.action_date is 'Date when action was done user.'
/
comment on column cln_action.eff_date is 'Date when action was registered in system.'
/
comment on column cln_action.status is 'Case status. Dictionary CNST'
/
comment on column cln_action.resolution is 'Status resolution. Dictionary CNRN'
/
comment on column cln_action.commentary is 'Comments of changing.'
/
begin
    for rec in (select count(1) cnt from user_tab_columns where table_name = 'CLN_ACTION' and column_name = 'PART_KEY')
    loop
        if rec.cnt = 0 then
            execute immediate 'alter table cln_action add (part_key as (to_date(substr(lpad(to_char(id), 16, ''0''), 1, 6), ''yymmdd'')) virtual)';
            execute immediate 'comment on column cln_action.part_key is ''Partition key''';
        end if;
    end loop;
end;
/
