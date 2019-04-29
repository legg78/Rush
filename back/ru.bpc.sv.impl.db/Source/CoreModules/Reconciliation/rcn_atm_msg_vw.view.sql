create or replace force view rcn_atm_msg_vw as
select m.id
     , m.msg_source
     , m.msg_date
     , m.operation_id
     , m.recon_msg_ref
     , m.recon_status
     , m.recon_last_date
     , m.recon_inst_id
     , m.oper_type
     , m.oper_date
     , m.oper_amount
     , m.oper_currency
     , m.trace_number
     , m.acq_inst_id
     , m.card_mask
     , m.auth_code
     , m.is_reversal
     , m.terminal_type
     , m.terminal_number
     , m.iss_fee
     , m.acc_from
     , m.acc_to
  from rcn_atm_msg m
/
