-- Create table
create table way_additional_data
(
  oper_id          NUMBER(16) not null,
  ptid             VARCHAR2(3),
  trans_location   VARCHAR2(83),
  postal_code      VARCHAR2(10),
  src              NUMBER(3),
  tcashback_curr   NUMBER(3),
  tcashback_amount NUMBER(12),
  surcharge_curr   NUMBER(3),
  surcharge_amount NUMBER(12),
  mbr_reconc_ind   VARCHAR2(50),
  cpna             VARCHAR2(25),
  cpad             VARCHAR2(30),
  cpcy             VARCHAR2(25),
  cpst             VARCHAR2(3),
  cpcn             VARCHAR2(3),
  cppc             VARCHAR2(10),
  cpdb             VARCHAR2(8),
  utrn             NUMBER(16),
  rpph             VARCHAR2(20),
  rpna             VARCHAR2(75),
  dev_tag          VARCHAR2(18),
  trn              VARCHAR2(16),
  emv_84           VARCHAR2(32),
  emv_5f2a         NUMBER(3),
  emv_9f02         NUMBER(12),
  msg_code         VARCHAR2(32),
  trans_condition  VARCHAR2(4000),
  orig_trans_date  DATE,
  orig_drn         NUMBER(12),
  prev_drn         NUMBER(12),
  emv_9f1a         NUMBER(3),
  emv_9a           VARCHAR2(10),
  cps              VARCHAR2(55)
)
/
-- Add comments to the table 
comment on table way_additional_data                    is 'Openway Additional Data'
/
-- Add comments to the columns 
comment on column way_additional_data.oper_id           is 'Reference to vis_fin_message'
/
comment on column way_additional_data.ptid              is 'Program Registration ID'
/
comment on column way_additional_data.trans_location    is 'Merchant (Card Acceptor) Address MC (IPM DE43_1, 2, 3)'
/
comment on column way_additional_data.postal_code       is 'Merchant (Card Acceptor) Postal Code MC (IPM DE43_4)'
/
comment on column way_additional_data.src               is 'Service Code MC (IPM DE40)'
/
comment on column way_additional_data.tcashback_curr    is 'CashBack Numeric ISO 4217 currency code MC (IPM DE54_3) for type DE54_2=40 Amount, Cash Back'
/
comment on column way_additional_data.tcashback_amount  is 'CashBack Numeric ISO 4217 currency code MC (IPM DE54_5) for type DE54_2=40 Amount, Cash Back'
/
comment on column way_additional_data.surcharge_curr    is 'CashBack Numeric ISO 4217 currency code MC (IPM DE54_3) for type DE54_2=42 Amount, Surcharge'
/
comment on column way_additional_data.surcharge_amount  is 'CashBack Numeric ISO 4217 currency code MC (IPM DE54_5)for type DE54_2=42 Amount, Surcharge'
/
comment on column way_additional_data.mbr_reconc_ind    is 'Member Reconciliation Indicator MC (IPM PDS0375)'
/
comment on column way_additional_data.cpna              is 'Sender Name MC (IPM PDS0670.SF1)'
/
comment on column way_additional_data.cpad              is 'Sender Address MC (IPM PDS0670.SF2)'
/
comment on column way_additional_data.cpcy              is 'Sender City MC (IPM PDS0670.SF3)'
/
comment on column way_additional_data.cpst              is 'Sender State MC (IPM PDS0670.SF4)'
/
comment on column way_additional_data.cpcn              is 'Sender Country MC (IPM PDS0670.SF5)'
/
comment on column way_additional_data.cppc              is 'Payer Postal Code MC (IPM PDS0670.SF6)'
/
comment on column way_additional_data.cpdb              is 'Payer Date of Birth MMDDYYYY MC (IPM PDS0670.SF7)'
/
comment on column way_additional_data.utrn              is 'Unique Transaction Reference Number MC (IPM PDS0674)'
/
comment on column way_additional_data.rpph              is 'Payee Telephone Number (Optional) MC (IPM PDS0765.SF9)'
/
comment on column way_additional_data.rpna              is 'Payee first name Payee last name MC (IPM  PDS0765.SF1, PDS0765.SF2)'
/
comment on column way_additional_data.dev_tag           is 'Is used to set additional parameters of a device'
/
comment on column way_additional_data.trn               is 'TRN - netrefnum'
/
comment on column way_additional_data.emv_84            is 'EMV 84 DF Name'
/
comment on column way_additional_data.emv_5f2a          is 'Transaction Currency Code'
/
comment on column way_additional_data.emv_9f02          is 'Amount Transaction'
/
comment on column way_additional_data.msg_code          is 'Transaction type code (message code)'
/
comment on column way_additional_data.trans_condition   is 'Comma-separated list (with leading and trailing commas) of transaction attributes which describes current transaction condition.'
/
comment on column way_additional_data.orig_trans_date   is 'Transaction date of the original transaction'
/
comment on column way_additional_data.orig_drn          is 'Identifier of the original document in a chain of documents (created by the sender''s system)'
/
comment on column way_additional_data.prev_drn          is 'Identifier of the previous document in a chain of documents (created by the sender''s system)'
/
comment on column way_additional_data.emv_9f1a          is 'Terminal country code'
/
comment on column way_additional_data.emv_9a            is 'Terminal transaction data'
/
comment on column way_additional_data.cps               is 'Custom Payment Service'
/
 
-- Add/modify columns 
alter table WAY_ADDITIONAL_DATA modify trans_location VARCHAR2(240)
/
alter table WAY_ADDITIONAL_DATA modify trn VARCHAR2(36)
/
alter table WAY_ADDITIONAL_DATA modify orig_drn NUMBER(16)
/
alter table WAY_ADDITIONAL_DATA modify prev_drn NUMBER(16)
/
