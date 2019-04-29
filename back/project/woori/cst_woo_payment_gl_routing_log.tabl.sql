create table cst_woo_payment_gl_routing_log (
    payment_id         number(16)
  , oper_id            number(16)
  , balance_type       varchar2(8 char)
  , contract_type      varchar2(8 char)
  , merchant_country   varchar2(3 char)
  , oper_type          varchar2(8 char)
  , sttl_type          varchar2(8 char)
  , macros_type_id     number(4)
  , fee_type           varchar2(8 char)
  , oper_reason        varchar2(8 char)
  , msg_type           varchar2(8 char)
  , is_reversal        number(1)
  , pay_amount         number(22,4)
  , eff_date           date
)
/
comment on table   cst_woo_payment_gl_routing_log is 'Log payments fail to route.'
/
comment on column  cst_woo_payment_gl_routing_log.payment_id is 'Payment id.'
/
comment on column  cst_woo_payment_gl_routing_log.oper_id is 'Original operation id.'
/
comment on column  cst_woo_payment_gl_routing_log.balance_type is 'Balance type.'
/
comment on column  cst_woo_payment_gl_routing_log.contract_type is 'Countract type.'
/
comment on column  cst_woo_payment_gl_routing_log.merchant_country is 'Original operation merchant country.'
/
comment on column  cst_woo_payment_gl_routing_log.oper_type is 'Operation type.'
/
comment on column  cst_woo_payment_gl_routing_log.sttl_type is 'Settlement type.'
/
comment on column  cst_woo_payment_gl_routing_log.macros_type_id is 'Macros type.'
/
comment on column  cst_woo_payment_gl_routing_log.fee_type is 'Fee type.'
/
comment on column  cst_woo_payment_gl_routing_log.oper_reason is 'Original operation reason.'
/
comment on column  cst_woo_payment_gl_routing_log.msg_type is 'Original message type.'
/
comment on column  cst_woo_payment_gl_routing_log.is_reversal is 'Is reversal operation.'
/
comment on column  cst_woo_payment_gl_routing_log.pay_amount is 'Payment amount.'
/
comment on column  cst_woo_payment_gl_routing_log.eff_date is 'Payment effect date.'
/
