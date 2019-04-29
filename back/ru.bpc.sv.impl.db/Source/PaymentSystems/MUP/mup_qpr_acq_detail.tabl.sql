create table mup_qpr_acq_detail(
    id	                  number(16) 
  , inst_id               number(4)
  , agent_id              number(8)
  , checked_successfully  number(1)
  , oper_sign             number(1)
  , oper_amount           number(22, 4)
  , part                  number(1)
  , region_code           varchar2(2)
  , pay_pos               number(16)
  , pay_atm               number(16)
  , pay_internet          number(16)
  , cashout_atm           number(16)
  , cashout_pos           number(16)
  , cashin                number(16)
  , transfer_credit       number(16)
  , transfer_debit        number(16)
  , oper_date             date
)
/
comment on table mup_qpr_acq_detail is 'Report form MIR Acquiring details'
/
comment on column mup_qpr_acq_detail.id                   is 'Operation ID'
/
comment on column mup_qpr_acq_detail.inst_id              is 'Instituion ID'
/
comment on column mup_qpr_acq_detail.agent_id             is 'Agent ID'
/
comment on column mup_qpr_acq_detail.checked_successfully is 'Checked successfully'
/
comment on column mup_qpr_acq_detail.oper_sign            is 'Operation sign'
/
comment on column mup_qpr_acq_detail.oper_amount          is 'Operation amount'
/
comment on column mup_qpr_acq_detail.part                 is 'Part'
/
comment on column mup_qpr_acq_detail.region_code          is 'Region code'
/
comment on column mup_qpr_acq_detail.pay_pos              is 'Payment by POS'
/
comment on column mup_qpr_acq_detail.pay_atm              is 'Payment by ATM'
/
comment on column mup_qpr_acq_detail.pay_internet         is 'Payment by Internet'
/
comment on column mup_qpr_acq_detail.cashout_atm          is 'Cash by ATM'
/
comment on column mup_qpr_acq_detail.cashout_pos          is 'Cash by POS'
/
comment on column mup_qpr_acq_detail.cashin               is 'Cash in'
/
comment on column mup_qpr_acq_detail.transfer_credit      is 'Transfer Credit'
/
comment on column mup_qpr_acq_detail.transfer_debit       is 'Transfer Debit'
/
comment on column mup_qpr_acq_detail.oper_date            is 'Processing date'
/
