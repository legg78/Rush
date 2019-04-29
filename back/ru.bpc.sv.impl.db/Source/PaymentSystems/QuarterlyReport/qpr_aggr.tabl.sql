create table qpr_aggr
(
  cnt                   number,
  amount                number,
  currency              varchar2(3),
  oper_date             date,
  oper_type             varchar2(8),
  sttl_type             varchar2(8),
  msg_type              varchar2(8),
  status                varchar2(8),
  oper_reason           varchar2(8),
  is_reversal           number(1),
  mcc                   varchar2(4),
  merchant_country      varchar2(3),
  acq_inst_bin          varchar2(12),
  card_type_id          number(4),
  card_inst_id          number(4),
  card_network_id       number(4),
  card_country          varchar2(3),
  card_product_id       number(8),
  card_perso_method_id  number,
  card_bin              varchar2(6),
  acq_inst_id           number(4),
  card_data_input_mode  varchar2(8),
  terminal_number       number,
  is_iss                number,
  is_acq                number
)
/
alter table qpr_aggr add (id number(12))
/
alter table qpr_aggr modify (terminal_number varchar2(8))
/
alter table qpr_aggr add (account_funding_source varchar2(100))
/
alter table qpr_aggr add (crdh_presence varchar2(8))
/
alter table qpr_aggr modify (terminal_number varchar2(16))
/
alter table qpr_aggr add (trans_code_qualifier varchar2(1))
/
comment on column qpr_aggr.trans_code_qualifier is 'Transaction code qualifier.'
/
alter table qpr_aggr add (pos_environment varchar2(1))
/
comment on column qpr_aggr.pos_environment is 'POS environment.'
/
alter table qpr_aggr add (product_id varchar2(2))
/
comment on column qpr_aggr.product_id is 'Visa Product ID'
/
alter table qpr_aggr add (business_application_id varchar2(2))
/
comment on column qpr_aggr.business_application_id is 'Business Application IDs'
/