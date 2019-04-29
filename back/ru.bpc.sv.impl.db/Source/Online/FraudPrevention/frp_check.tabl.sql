create table frp_check (
    id             number(8)
  , seqnum         number(4)
  , case_id        number(4)
  , check_type     varchar2(8)
  , alert_type     varchar2(8)
  , expression     varchar2(2000)
  , risk_score     number(4)
  , risk_matrix_id number(4))
/

comment on table frp_check is 'Fraud checks. Boolean expressions determine fraud characteristics.'
/

comment on column frp_check.seqnum is 'Sequential number of data record version.'
/

comment on column frp_check.case_id is 'Reference to fraud case.'
/

comment on column frp_check.check_type is 'Check type (boolean exspresion, risk matrix, boolean exspression with risk matrix)'
/

comment on column frp_check.alert_type is 'Alert type. Define rule to store alerts (Always, If used, Never).'
/

comment on column frp_check.expression is 'Boolean exspression stored as plain text.'
/

comment on column frp_check.risk_score is 'Risk score add to total case score if check is TRUE.'
/

comment on column frp_check.risk_matrix_id is 'Reference to matrix defining risk score instead of plain value.'
/