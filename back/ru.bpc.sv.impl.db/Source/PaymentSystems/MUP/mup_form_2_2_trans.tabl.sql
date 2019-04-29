create table mup_form_2_2_trans (
    inst_id                 number(4)
  , agent_id                number(8)
  , date_start              date
  , date_end                date
  , oper_id                 number(16)
  , checked_successfully    number(1)
  , oper_sign               number(1)
  , oper_amount             number(22,4)
  , part                    number(1)
  , c0_region_code          varchar2(2 byte)
  , c6_c7_pay_pos           number(16)
  , c8_c9_pay_atm           number(16)
  , c10_c11_pay_internet    number(16)
  , c12_c13_cashout_atm     number(16)
  , c14_c15_cashout_pos     number(16)
  , c16_c17_cashin          number(16)
  , c18_c19_transfer_credit number(16)
  , c20_c21_transfer_debit  number(16)
)
/

comment on table mup_form_2_2_trans is 'MUP form 2.2 - acquiring'
/

comment on column mup_form_2_2_trans.inst_id is 'Institution ID'
/
comment on column mup_form_2_2_trans.agent_id is 'Agent ID'
/
comment on column mup_form_2_2_trans.date_start is 'Date start'
/
comment on column mup_form_2_2_trans.date_end is 'Date end'
/
comment on column mup_form_2_2_trans.oper_id is 'Operation ID'
/
comment on column mup_form_2_2_trans.checked_successfully is 'Successfully checked flag'
/
comment on column mup_form_2_2_trans.oper_sign is 'Sign of operation'
/
comment on column mup_form_2_2_trans.oper_amount is 'Operation amount'
/
comment on column mup_form_2_2_trans.part is 'Part'
/
comment on column mup_form_2_2_trans.c0_region_code is 'C0 region code'
/
comment on column mup_form_2_2_trans.c6_c7_pay_pos is 'cc6 c7 pay pos'
/
comment on column mup_form_2_2_trans.c8_c9_pay_atm is 'c8 c9 pay ATM'
/
comment on column mup_form_2_2_trans.c10_c11_pay_internet is 'C10 c11 pay internet'
/
comment on column mup_form_2_2_trans.c12_c13_cashout_atm is 'c12 c13 cashout ATM'
/
comment on column mup_form_2_2_trans.c14_c15_cashout_pos is 'c14 c15 cashout pos'
/
comment on column mup_form_2_2_trans.c16_c17_cashin is 'c16 c17 cash in'
/
comment on column mup_form_2_2_trans.c18_c19_transfer_credit is 'c18 c19 transfer credit'
/
comment on column mup_form_2_2_trans.c20_c21_transfer_debit is 'c20 c21 transfer debit'
/
