create or replace type rcn_atm_recon_msg_tpr as object (
    id               number(16)
  , oper_type        varchar2(8)
  , oper_date        date
  , oper_amount      number(22, 4)
  , oper_currency    varchar2(3)
  , trace_number     number(8)
  , acq_inst_id      number(4)
  , card_number      varchar2(24)
  , auth_code        varchar2(6)
  , is_reversal      number(1)
  , terminal_type    varchar2(8)
  , terminal_number  varchar2(16)
  , iss_fee          number(22, 4)
  , acc_from         varchar2(32)
  , acc_to           varchar2(32)
)
/
  
