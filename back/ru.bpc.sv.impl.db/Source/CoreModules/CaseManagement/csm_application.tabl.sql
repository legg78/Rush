create table csm_application(
    id                      number(16)
  , seqnum                  number(4)
  , case_source             varchar2(8)
)
/

comment on table csm_application is 'Dispute cases inserted into system.'
/
comment on column csm_application.id is 'Primary key. Reference to APP_APPLICATION.ID'
/
comment on column csm_application.seqnum is 'Sequence number. Describe data version.'
/
comment on column csm_application.case_source is 'Case source for dispute (dictionary DSCS)'
/
alter table csm_application add case_id number(16)
/
comment on column csm_application.case_id is 'Case identifier'
/
alter table csm_application add claim_id number(16)
/
comment on column csm_application.claim_id is 'Claim identifier'
/
alter table csm_application add original_id number(16)
/
comment on column csm_application.original_id is 'Reference to original operation in dispute case'
/
alter table csm_application add dispute_id number(16)
/
comment on column csm_application.dispute_id is 'Identifier of dispute which message involved in'
/
