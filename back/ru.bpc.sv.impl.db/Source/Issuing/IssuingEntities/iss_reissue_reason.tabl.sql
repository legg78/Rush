create table iss_reissue_reason(
    id                        number(12) not null
  , seqnum                    number(4)
  , inst_id                   number(4)
  , reissue_reason            varchar2(8)
  , reissue_command           varchar2(8)
  , pin_request               varchar2(8)
  , pin_mailer_request        varchar2(8)
  , embossing_request         varchar2(8)
)
/
comment on table iss_reissue_reason is 'The table defines for every reason of reissuing appropriate reissuing command and flags'
/
comment on column iss_reissue_reason.inst_id is 'Institution identifier'
/
comment on column iss_reissue_reason.reissue_reason is 'Reason of reissuing (EVNT dictionary)'
/
comment on column iss_reissue_reason.reissue_command is 'Reissue command (RCMD dictionary)'
/
comment on column iss_reissue_reason.pin_request is 'Reissue flag (PNRQ dictionary)'
/
comment on column iss_reissue_reason.pin_mailer_request is 'Reissue flag (PMRQ dictionary)'
/
comment on column iss_reissue_reason.embossing_request is 'Reissue flag (EMRQ dictionary)'
/
alter table iss_reissue_reason add (reiss_start_date_rule varchar2(8), reiss_expir_date_rule varchar2(8), perso_priority varchar2(8))
/
comment on column iss_reissue_reason.reiss_expir_date_rule is 'Rule for reissuing expiration date generation (EDRL)'
/
comment on column iss_reissue_reason.reiss_start_date_rule is 'Rule for reissuing start date generation'
/
comment on column iss_reissue_reason.perso_priority is 'Personalization priority'
/
alter table iss_reissue_reason add clone_optional_services number(1)
/
comment on column iss_reissue_reason.clone_optional_services is 'Clone optional services (1 - Yes, 0 - No)'
/
