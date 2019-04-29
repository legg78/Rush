create table mup_qpr_acq (
    inst_id               number(4)
  , agent_id              number(8)
  , part                  number(1)
  , checked_successfully  number(1)
  , region_code           varchar2(2)
  , count_pay             number(16)
  , sum_pay               number(22, 4)
  , count_pay_pos         number(16)
  , sum_pay_pos           number(22, 4)
  , count_pay_atm         number(16)
  , sum_pay_atm           number(22, 4)
  , count_pay_internet    number(16)
  , sum_pay_internet      number(22, 4)
  , count_cashout_atm     number(16)
  , sum_cashout_atm       number(22, 4)
  , count_cashout_pos     number(16)
  , sum_cashout_pos       number(22, 4)
  , count_cashin          number(16)
  , sum_cashin            number(22, 4)
  , count_transfer_credit number(16)
  , sum_transfer_credit   number(22, 4)
  , count_transfer_debit  number(16)
  , sum_transfer_debit    number(22, 4)
  , oper_date_quartal     number(1)
)
/
comment on table mup_qpr_acq is 'Report form MIR Acquiring'
/
comment on column mup_qpr_acq.inst_id               is 'Instution ID'
/
comment on column mup_qpr_acq.agent_id              is 'Agent ID'
/
comment on column mup_qpr_acq.part                  is 'Part'
/
comment on column mup_qpr_acq.checked_successfully  is 'Checked successfully'
/
comment on column mup_qpr_acq.region_code           is 'Region code'
/
comment on column mup_qpr_acq.count_pay             is 'Payment count all'
/
comment on column mup_qpr_acq.sum_pay               is 'Payment amount all'
/
comment on column mup_qpr_acq.count_pay_pos         is 'Payment count POS'
/
comment on column mup_qpr_acq.sum_pay_pos           is 'Payment amount POS'
/
comment on column mup_qpr_acq.count_pay_atm         is 'Payment count ATM'
/
comment on column mup_qpr_acq.sum_pay_atm           is 'Payment amount ATM'
/
comment on column mup_qpr_acq.count_pay_internet    is 'Payment count Internet'
/
comment on column mup_qpr_acq.sum_pay_internet      is 'Payment amount Internet'
/
comment on column mup_qpr_acq.count_cashout_atm     is 'Cash count ATM'
/
comment on column mup_qpr_acq.sum_cashout_atm       is 'Cash amount ATM'
/
comment on column mup_qpr_acq.count_cashout_pos     is 'Cash count POS'
/
comment on column mup_qpr_acq.sum_cashout_pos       is 'Cash amount POS'
/
comment on column mup_qpr_acq.count_cashin          is 'Cash in count POS'
/
comment on column mup_qpr_acq.sum_cashin            is 'Cash in amount POS'
/
comment on column mup_qpr_acq.count_transfer_credit is 'Transfer count Credit'
/
comment on column mup_qpr_acq.sum_transfer_credit   is 'Transfer amount Credit'
/
comment on column mup_qpr_acq.count_transfer_debit  is 'Transfer count Debit'
/
comment on column mup_qpr_acq.sum_transfer_debit    is 'Transfer amount Debit'
/
comment on column mup_qpr_acq.oper_date_quartal     is 'Operation date quartal'
/
