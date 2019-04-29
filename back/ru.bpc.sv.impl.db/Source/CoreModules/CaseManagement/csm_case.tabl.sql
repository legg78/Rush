create table csm_case(
    id                      number(16)
  , part_key                as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual -- [@skip patch]
  , seqnum                  number(4)
  , inst_id                 number(4)
  , merchant_name           varchar2(200)
  , customer_number         varchar2(200)
  , dispute_reason          varchar2(8)
  , oper_date               date
  , oper_amount             number(22,4)
  , oper_currency           varchar2(3)
  , dispute_id              number(16)
  , dispute_progress        varchar2(8)
  , write_off_amount        number(22,4)
  , write_off_currency      varchar2(3)
  , due_date                date
  , reason_code             varchar2(8)
  , disputed_amount         number(22,4)
  , disputed_currency       varchar2(3)
  , created_date            date
  , created_by_user_id      number(8)
  , arn                     varchar2(23)
  , claim_id                number(16)
  , auth_code               varchar2(6)
  , case_progress           varchar2(8)
  , acquirer_inst_bin       varchar2(12)
  , transaction_code        varchar2(12)
  , case_source             varchar2(8)
  , sttl_amount             number(22,4)
  , sttl_currency           varchar2(3)
  , base_amount             number(22,4)
  , base_currency           varchar2(3)
  , hide_date               date
  , unhide_date             date
  , team_id                 number(4)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                      -- [@skip patch]
(                                                                                        -- [@skip patch]
    partition csm_case_p01 values less than (to_date('01-01-2017','DD-MM-YYYY'))         -- [@skip patch]
)                                                                                        -- [@skip patch]
******************** partition end ********************/
/

comment on table csm_case is 'Dispute cases inserted into system.'
/
comment on column csm_case.id is 'Primary key. Reference to APP_APPLICATION.ID'
/
comment on column csm_case.seqnum is 'Sequence number. Describe data version.'
/
comment on column csm_case.inst_id is 'Institution contained objects defined in case.'
/
comment on column csm_case.merchant_name is 'Merchant name sending into payment network.'
/
comment on column csm_case.customer_number is 'External customer number.'
/
comment on column csm_case.dispute_reason is 'Dispute reason.'
/
comment on column csm_case.oper_date is 'Operation date.'
/
comment on column csm_case.oper_date is 'Operation date.'
/
comment on column csm_case.oper_amount is 'Operation amount in operation currency.'
/
comment on column csm_case.oper_currency is 'Operation currency.'
/
comment on column csm_case.dispute_id is 'Identifier of dispute which message involved in.'
/
comment on column csm_case.dispute_progress is 'Dispute progress.'
/
comment on column csm_case.write_off_amount is 'Write-off amount.'
/
comment on column csm_case.write_off_currency is 'Write-off currency.'
/
comment on column csm_case.due_date is 'Due date.'
/
comment on column csm_case.reason_code is 'Reason code (dictionary value)'
/
comment on column csm_case.disputed_amount is 'Disputed amount.'
/
comment on column csm_case.disputed_currency is 'Disputed currency.'
/
comment on column csm_case.created_date is 'Created date.'
/
comment on column csm_case.created_by_user_id is 'Created by user.'
/
comment on column csm_case.arn is 'Acquirer Reference Number (ARN)'
/
comment on column csm_case.claim_id is 'Claim identifier'
/
comment on column csm_case.auth_code is 'Authorization code.'
/
comment on column csm_case.case_progress is 'Case progress.'
/
comment on column csm_case.acquirer_inst_bin is 'Acquirer institution BIN'
/
comment on column csm_case.transaction_code is 'Transaction code'
/
comment on column csm_case.case_source is 'Source of case'
/
comment on column csm_case.sttl_amount is 'Settlement amount'
/
comment on column csm_case.sttl_currency is 'Settlement currency'
/
comment on column csm_case.base_amount is 'Base amount'
/
comment on column csm_case.base_currency is 'Base currency'
/
comment on column csm_case.hide_date is 'Hide date'
/
comment on column csm_case.unhide_date is 'Unhide date'
/
comment on column csm_case.team_id is 'Team identifier'
/
alter table csm_case add original_id number(16)
/
comment on column csm_case.original_id is 'Reference to original operation in dispute case'
/
comment on column csm_case.dispute_reason is 'Dispute reason (reason of case initiation, dictionary DSPR).'
/
comment on column csm_case.reason_code is 'Reason code (from network)'
/
alter table csm_case drop column seqnum
/
alter table csm_case add network_id number(4)
/
alter table csm_case add ext_claim_id varchar2(20)
/
alter table csm_case add ext_clearing_trans_id varchar2(200)
/
alter table csm_case add ext_auth_trans_id varchar2(200)
/
comment on column csm_case.network_id is 'Card network identifier'
/
comment on column csm_case.ext_claim_id is 'Identifier assigned to the Claim in MasterCom'
/
comment on column csm_case.ext_clearing_trans_id is 'MasterCom clearing Transaction Id'
/
comment on column csm_case.ext_auth_trans_id is 'MasterCom authorization Transaction Id'
/
