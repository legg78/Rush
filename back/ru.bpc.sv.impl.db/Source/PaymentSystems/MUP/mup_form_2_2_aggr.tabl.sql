create table mup_form_2_2_aggr (
    inst_id                   number(4)
  , agent_id                  number(8)
  , part                      number(1)
  , checked_successfully      number(1)
  , c0_region_code            varchar2(2 byte)
  , c1_member_code            varchar2(8 byte)
  , c2_bank_code              varchar2(8 byte)
  , c3_bank_name              varchar2(1000 byte)
  , c4_count_pay              number(16)
  , c5_sum_pay                number(22,4)
  , c6_count_pay_pos          number(16)
  , c7_sum_pay_pos            number(22,4)
  , c8_count_pay_atm          number(16)
  , c9_sum_pay_atm            number(22,4)
  , c10_count_pay_internet    number(16)
  , c11_sum_pay_internet      number(22,4)
  , c12_count_cashout_atm     number(16)
  , c13_sum_cashout_atm       number(22,4)
  , c14_count_cashout_pos     number(16)
  , c15_sum_cashout_pos       number(22,4)
  , c16_count_cashin          number(16)
  , c17_sum_cashin            number(22,4)
  , c18_count_transfer_credit number(16)
  , c19_sum_transfer_credit   number(22,4)
  , c20_count_transfer_debit  number(16)
  , c21_sum_transfer_debit    number(22,4)
)
/

comment on table mup_form_2_2_aggr is 'Table for MUP report of form 2.2'
/

comment on column mup_form_2_2_aggr.inst_id is 'Institution ID'
/
comment on column mup_form_2_2_aggr.agent_id is 'Agent ID'
/
comment on column mup_form_2_2_aggr.part is 'Part'
/
comment on column mup_form_2_2_aggr.checked_successfully is 'Successfully checked flag'
/
comment on column mup_form_2_2_aggr.c0_region_code is 'Region code'
/
comment on column mup_form_2_2_aggr.c1_member_code is 'Member code'
/
comment on column mup_form_2_2_aggr.c2_bank_code is 'Bank code'
/
comment on column mup_form_2_2_aggr.c3_bank_name is 'Bank name'
/
comment on column mup_form_2_2_aggr.c4_count_pay is 'Count of pay'
/
comment on column mup_form_2_2_aggr.c5_sum_pay is 'Sum of pay'
/
comment on column mup_form_2_2_aggr.c6_count_pay_pos is 'Count of pos pay'
/
comment on column mup_form_2_2_aggr.c7_sum_pay_pos is 'Sum of pos pay'
/
comment on column mup_form_2_2_aggr.c8_count_pay_atm is 'Count of ATM pay'
/
comment on column mup_form_2_2_aggr.c9_sum_pay_atm is 'Sum of ATM pay'
/
comment on column mup_form_2_2_aggr.c10_count_pay_internet is 'Count of internet pay'
/
comment on column mup_form_2_2_aggr.c11_sum_pay_internet is 'Sum of internet pay'
/
comment on column mup_form_2_2_aggr.c12_count_cashout_atm is 'Count of ATM Cashout'
/
comment on column mup_form_2_2_aggr.c13_sum_cashout_atm is 'Sum of ATM cashout'
/
comment on column mup_form_2_2_aggr.c14_count_cashout_pos is 'Count of POS cashout'
/
comment on column mup_form_2_2_aggr.c15_sum_cashout_pos is 'Sum of POS cashout'
/
comment on column mup_form_2_2_aggr.c16_count_cashin is 'Count of cashin'
/
comment on column mup_form_2_2_aggr.c17_sum_cashin is 'Sum of cashin'
/
comment on column mup_form_2_2_aggr.c18_count_transfer_credit is 'Count of transfer credit'
/
comment on column mup_form_2_2_aggr.c19_sum_transfer_credit is 'Sum of transfer credit'
/
comment on column mup_form_2_2_aggr.c20_count_transfer_debit is 'Count of transfer debit'
/
comment on column mup_form_2_2_aggr.c21_sum_transfer_debit is 'Sum of transfer debit'
/
