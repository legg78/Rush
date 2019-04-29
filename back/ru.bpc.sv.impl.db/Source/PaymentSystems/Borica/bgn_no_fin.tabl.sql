create table bgn_no_fin (
    id              number(16)
  , file_id         number(16)  
  , code            varchar2(8)
  , card_marker     varchar2(8)                     
  , product_name    varchar2(200)  
  , oper_name       varchar2(200)
  , seq_number      number(4)
  , ird             varchar2(200)   
  , debit_count     number(12)
  , debit_trans     number(22,4)  
  , debit_tax       number(22,4)
  , debit_total     number(22,4)
  , credit_count    number(12)
  , credit_trans    number(22,4)  
  , credit_tax      number(22,4)
  , credit_total    number(22,4)  
)
/

comment on table bgn_no_fin is 'NO messages'
/

comment on column bgn_no_fin.id           is 'Primary key. Same as opr_operation.id'
/

comment on column bgn_no_fin.file_id      is 'NO file id'
/

comment on column bgn_no_fin.code         is 'Code of string'
/

comment on column bgn_no_fin.card_marker  is 'Card type code: I - VISA, II - domestic card, III - Mastercard'
/

comment on column bgn_no_fin.product_name is 'Mastercard product name'
/

comment on column bgn_no_fin.oper_name    is 'Operation name'
/

comment on column bgn_no_fin.seq_number   is 'Additional number fo code'
/

comment on column bgn_no_fin.ird          is 'Mastercard IRD'
/

comment on column bgn_no_fin.debit_count  is 'Count of debit operations'
/

comment on column bgn_no_fin.debit_trans  is 'Amount of debit transactions'
/

comment on column bgn_no_fin.debit_tax    is 'Interbank fees debit amount'
/

comment on column bgn_no_fin.debit_total  is 'Total debit amount'
/

comment on column bgn_no_fin.credit_count is 'Count of credit operations'
/

comment on column bgn_no_fin.credit_trans is 'Amount of credit transactions'
/

comment on column bgn_no_fin.credit_tax   is 'Interbank fees credit amount'
/

comment on column bgn_no_fin.credit_total is 'Total credit amount'
/

alter table bgn_no_fin add is_incoming number(1)
/

comment on column bgn_no_fin.is_incoming is 'Incoming message - 1, outgoing message - 0'
/

alter table bgn_no_fin add status varchar2(8)
/

comment on column bgn_no_fin.status is 'Clearing message status (CLMS)'
/

alter table bgn_no_fin add match_id number(16)
/

comment on column bgn_no_fin.match_id is 'Incoming clearing message id'
/
