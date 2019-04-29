create table aci_atm_setl_hopr (
    id                          number(16)
    , hopr_num                  varchar2(4)
    , term_setl_hopr_contents   varchar2(2)
    , term_setl_hopr_beg_cash   varchar2(19)
    , term_setl_hopr_cash_incr  varchar2(19)
    , term_setl_hopr_cash_decr  varchar2(19)
    , term_setl_hopr_cash_out   varchar2(19)
    , term_setl_hopr_end_cash   varchar2(19)
    , term_setl_hopr_crncy_cde  varchar2(3)
    , term_setl_hopr_user_fld5  varchar2(1)
)
/
comment on table aci_atm_setl_hopr is 'Hopper values from the TDF just prior to the terminal being balanced'
/
comment on column aci_atm_setl_hopr.hopr_num is 'The hopper number.'
/
comment on column aci_atm_setl_hopr.term_setl_hopr_contents is 'A code used to identify the contents of the hopper.'
/
comment on column aci_atm_setl_hopr.term_setl_hopr_beg_cash is 'The amount of currency in the hopper at the start of the current balancing period.'
/
comment on column aci_atm_setl_hopr.term_setl_hopr_cash_incr is 'The amount of currency added to the hopper during the current balancing period.'
/
comment on column aci_atm_setl_hopr.term_setl_hopr_cash_decr is 'The amount of currency removed from the hopper during the current balancing period.'
/
comment on column aci_atm_setl_hopr.term_setl_hopr_cash_out is 'The amount of currency dispensed from the hopper through customer withdrawals between terminal balancing periods.'
/
comment on column aci_atm_setl_hopr.term_setl_hopr_end_cash is 'The amount of currency remaining in the hopper at the end of the balancing period.'
/
comment on column aci_atm_setl_hopr.term_setl_hopr_crncy_cde is 'A code identifying the currency in the hopper.'
/
comment on column aci_atm_setl_hopr.term_setl_hopr_user_fld5 is 'This field is not used.'
/
