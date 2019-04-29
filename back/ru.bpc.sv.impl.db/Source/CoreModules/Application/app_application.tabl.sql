create table app_application(
    id                      number(16)
  , part_key                as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual -- [@skip patch]
  , split_hash              number(4)                                                 -- [@skip patch]
  , seqnum                  number(4)
  , appl_type               varchar2(8)
  , appl_number             varchar2(200)
  , flow_id                 number(4)
  , appl_status             varchar2(8)
  , reject_code             varchar2(8)
  , agent_id                number(8)
  , inst_id                 number(4)
  , session_file_id         number(16)
  , file_rec_num            number(8)
  , resp_session_file_id    number(16)
  , is_template             number(1)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH')) -- [@skip patch]
subpartition by list (split_hash)                                   -- [@skip patch]
subpartition template                                               -- [@skip patch]
(                                                                   -- [@skip patch]
    <subpartition_list>                                             -- [@skip patch]
)                                                                   -- [@skip patch]
(                                                                   -- [@skip patch]
    partition app_application_p01 values less than (to_date('01-01-2017','DD-MM-YYYY')) -- [@skip patch]
)                                                                   -- [@skip patch]
******************** partition end ********************/
/

comment on table app_application is 'Applications inserted into system.'
/
comment on column app_application.id is 'Primary key.'
/
comment on column app_application.seqnum is 'Sequence number. Describe data version.'
/
comment on column app_application.appl_type is 'Reference to application type.'
/
comment on column app_application.appl_number is 'External application number. Unique in institution.'
/
comment on column app_application.appl_status is 'Application status. Describing application processing state.'
/
comment on column app_application.reject_code is 'Reject code. The reason why application was rejected.'
/
comment on column app_application.agent_id is 'Agent contained objects defined in application.'
/
comment on column app_application.inst_id is 'Institution contained objects defined in application.'
/
comment on column app_application.session_file_id is 'Incoming file identifier.'
/
comment on column app_application.file_rec_num is 'Number of record in incoming file.'
/
comment on column app_application.resp_session_file_id is 'Response file identifier.'
/
comment on column app_application.is_template is 'Template flag.'
/
alter table app_application add (product_id number(8))
/
comment on column app_application.product_id is 'Customer product identifier. Using only for application templates.'
/
comment on column app_application.flow_id is 'Flow identifier'
/
comment on column app_application.split_hash is 'Hash value to split further processing' -- [@skip patch]
/
alter table app_application add (user_id number(8))
/
comment on column app_application.user_id is 'Foreign key to table ACM_USER'
/
alter table app_application add (is_visible number(1))
/
comment on column app_application.is_visible is 'Visibility flag, initially for dispute applications'
/
alter table app_application add (case_source varchar2(8))
/
comment on column app_application.case_source is 'Case source for dispute (dictionary DSCS)'
/
alter table app_application add (case_owner number(8))
/
comment on column app_application.case_owner is 'Case owner for dispute (table ACM_USER)'
/
alter table app_application drop column case_source
/
alter table app_application drop column case_owner
/
alter table app_application add (appl_prioritized number(1))
/
comment on column app_application.appl_prioritized is 'Application processing is prioritized'
/
alter table app_application add (execution_mode varchar2(8))
/
comment on column app_application.execution_mode is 'Execution mode of process (dictionary EXEM)'
/
