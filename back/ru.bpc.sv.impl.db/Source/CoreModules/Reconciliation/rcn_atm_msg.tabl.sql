create table rcn_atm_msg(
    id              number(16)
  , part_key        as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd'))  -- [@skip patch]
  , msg_source      varchar2(8)
  , msg_date        date
  , operation_id    number(16)
  , recon_msg_ref   number(16) 
  , recon_status    varchar2(8)
  , recon_last_date date
  , recon_inst_id   number(4) 
  , oper_type       varchar2(8) 
  , oper_date       date
  , oper_amount     number(22,4)
  , oper_currency   varchar2(3)
  , trace_number    number(6)
  , acq_inst_id     number(4)
  , card_mask      varchar2(19)  
  , auth_code       varchar2(6)
  , is_reversal     number(1)
  , terminal_type   varchar2(8)
  , terminal_number varchar2(8)
  , iss_fee         number(12)
  , acc_from        varchar2(28)
  , acc_to          varchar2(28)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                   -- [@skip patch]
(                                                                                     -- [@skip patch]
    partition rcn_atm_msg_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))     -- [@skip patch]
)                                                                                     -- [@skip patch]
******************** partition end ********************/
/
comment on table rcn_atm_msg is 'ATM reconciliation financial messages'
/
comment on column rcn_atm_msg.id is 'A row identifier'
/
comment on column rcn_atm_msg.msg_source is 'Message source. Dictionary RMSC'
/
comment on column rcn_atm_msg.msg_date is 'Message date and time inserted into the table'
/
comment on column rcn_atm_msg.operation_id is 'Reference to an operation (opr_operation table). Not empty if a message loaded from SV operations'
/
comment on column rcn_atm_msg.recon_msg_ref is 'Reference to reconciled message in the table rcn_atm_msg.   If a reconciliation process will find a transactions pair, both of them should have links each other'
/
comment on column rcn_atm_msg.recon_status is 'Reconciliation status. Dictionary RNST'
/
comment on column rcn_atm_msg.recon_last_date is 'Date and time of last reconciliation process on the message'
/
comment on column rcn_atm_msg.recon_inst_id is 'Identifier of reconciliation institution. For multi institution reconciliation'
/
comment on column rcn_atm_msg.oper_type is 'Operation type. Dictionary OPTP'
/
comment on column rcn_atm_msg.oper_date is 'Local date and time when operation occurs'
/
comment on column rcn_atm_msg.oper_amount is 'Original operation amount value expressed in minimal currency units'
/
comment on column rcn_atm_msg.oper_currency is 'Original operation amount currency'
/
comment on column rcn_atm_msg.trace_number is 'Trace number'
/
comment on column rcn_atm_msg.acq_inst_id is 'Identifier of participant acquirer'
/
comment on column rcn_atm_msg.card_mask  is 'Card mask'
/
comment on column rcn_atm_msg.auth_code is 'Authorization code'
/
comment on column rcn_atm_msg.is_reversal is '0 - operation is not reversal, 1 - operation is reversal'
/
comment on column rcn_atm_msg.terminal_type is 'Terminal type. Dictionary TRMT. Const TRMT0002 - ATM'
/
comment on column rcn_atm_msg.terminal_number is 'Terminal number'
/
comment on column rcn_atm_msg.iss_fee is 'Issuer fee'
/
comment on column rcn_atm_msg.acc_from is 'Account from'
/
comment on column rcn_atm_msg.acc_to is 'Account to'
/
alter table rcn_atm_msg modify (terminal_number varchar2(16))
/

