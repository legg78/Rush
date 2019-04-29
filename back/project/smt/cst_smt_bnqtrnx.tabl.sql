create table cst_smt_bnqtrnx
( id                  number(16),
  record_type         varchar2(4),
  batch_id            number,
  remittance_seq      number,
  merchant_id         varchar2(10),
  batch_number        number,
  amount              number(22,4),
  currency            number(3),
  terminal_id         number,
  tran_count          number,
  batch_date          date,
  operation_code      varchar2(1),
  sttl_amount         number(22,4),
  operation_source    varchar2(1),
  merchant_name       varchar2(200),
  card_number         varchar2(24),
  card_exp_date       date,
  tran_date           date,
  appr_code           varchar2(6),
  issuer_inst         varchar2(4),
  acquirer_inst       varchar2(4),
  pos_batch_sequence  number,
  tran_originator     varchar2(1),
  status              varchar2(8),
  split_hash          number(4),
  session_file_id     number(16)                                 	
)
/

alter table cst_smt_bnqtrnx add (oper_id  number(16))
/
