create table vis_tcr4 (
    id                   number(16)
  , trans_comp_number    varchar2(1)
  , agent_unique_id      varchar2(5)
  , business_format_code varchar2(8)
  , contact_information  varchar2(15)
  , adjustment_indicator varchar2(1)
  , message_reason_code  varchar2(8)
  , dispute_condition    varchar2(3)
  , vrol_financial_id    varchar2(11)
  , vrol_case_number     varchar2(10)
  , vrol_bundle_number   varchar2(10)
  , client_case_number   varchar2(20)
  , dispute_status       varchar2(2)
  , surcharge_amount     number(22,4)
  , surcharge_sign       varchar2(2)
  , payment_acc_ref      varchar2(29)
  , token_requestor_id   varchar2(11)
)
/

comment on table vis_tcr4 is 'VISA TCR4 data table.'
/
comment on column vis_tcr4.id is 'Primary key. VISA financial message identifier.'
/
comment on column vis_tcr4.trans_comp_number is 'Transaction Component Sequence Number.'
/
comment on column vis_tcr4.agent_unique_id is 'Agent Unique ID.'
/
comment on column vis_tcr4.business_format_code is 'Code indicating the type of business that is applicable to this transaction.'
/
comment on column vis_tcr4.contact_information is 'Contact information for Plus transactions.'
/
comment on column vis_tcr4.adjustment_indicator is 'Adjustment Processing Indicator.'
/
comment on column vis_tcr4.message_reason_code is 'Message Reason Code.'
/
comment on column vis_tcr4.dispute_condition is 'Dispute condition assigned through the Visa Claims Resolution (VCR) process.'
/
comment on column vis_tcr4.vrol_financial_id is 'Visa Resolve Online (VROL) financial ID assigned through the VCR process.'
/
comment on column vis_tcr4.vrol_case_number is 'VROL case number assigned through the VCR process.'
/
comment on column vis_tcr4.vrol_bundle_number is 'VROL bundle case number when the dispute was submitted to VROL as part of a bundle of disputes.'
/
comment on column vis_tcr4.client_case_number is 'Case tracking number assigned by the endpoint in VROL when a VCR dispute is created.'
/
comment on column vis_tcr4.dispute_status is 'Dispute Status.'
/
comment on column vis_tcr4.surcharge_amount is 'Surcharge Amount.'
/
comment on column vis_tcr4.surcharge_sign is 'Surcharge Credit/Debit Indicator.'
/
comment on column vis_tcr4.payment_acc_ref is 'Payment Account Reference.'
/
comment on column vis_tcr4.token_requestor_id is 'Token Requestor ID.'
/
