create table dpp_instalment (
    id                number(16)
  , part_key          as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual -- [@skip patch]
  , dpp_id           number(16)
  , instalment_number number(4)
  , instalment_date   date
  , instalment_amount number(22 , 4)
  , payment_amount    number(22 , 4)
  , interest_amount   number(22 , 4)
  , macros_id         number(16)
  , acceleration_type varchar2(8)
  , split_hash        number(4)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                       -- [@skip patch]
subpartition by list (split_hash)                                                         -- [@skip patch]
subpartition template                                                                     -- [@skip patch]
(                                                                                         -- [@skip patch]
    <subpartition_list>                                                                   -- [@skip patch]
)                                                                                         -- [@skip patch]
(                                                                                         -- [@skip patch]
    partition dpp_instalment_p01 values less than (to_date('01-01-2017','DD-MM-YYYY'))    -- [@skip patch]
)                                                                                         -- [@skip patch]
******************** partition end ********************/
/

comment on table dpp_instalment is 'Payment plan.'
/

comment on column dpp_instalment.id is 'Primary key.'
/
comment on column dpp_instalment.dpp_id is 'Reference to payment plan.'
/
comment on column dpp_instalment.instalment_number is 'Instalment sequential number.'
/
comment on column dpp_instalment.instalment_date is 'Date of instalment posting.'
/
comment on column dpp_instalment.instalment_amount is 'Instalment amount (not including interest amount).'
/
comment on column dpp_instalment.payment_amount is 'Actual payment amount. Filled when actual amount not equal (greater than)  instalment amount.'
/
comment on column dpp_instalment.interest_amount is 'Interest amount.'
/
comment on column dpp_instalment.macros_id is 'Identifier of macros was created as a result of instalment implementation.'
/
comment on column dpp_instalment.acceleration_type is 'Type of plan acceleration (by instalment count, by instalment amount).'
/
comment on column dpp_instalment.split_hash is 'Value to split further processing.'
/
comment on column dpp_instalment.instalment_amount is 'Instalment payment amount (including interest)'
/
comment on column dpp_instalment.payment_amount is 'Repayment amount. It is presented in the case of early repayment, it is a part of instalment_amount (they are equal in the case of full eraly repayment)'
/
comment on column dpp_instalment.acceleration_type is 'Type of DPP acceleration (repayment with preserving instalments count, with preserving instalment amount, or restructing with new instalments count)'
/
alter table dpp_instalment add (macros_intr_id number(16))
/
comment on column dpp_instalment.macros_intr_id is 'Id of macros for interest amount.'
/
alter table dpp_instalment add (fee_id number(8))
/
comment on column dpp_instalment.fee_id is 'Fee used to calculate interest rate.'
/
alter table dpp_instalment add (acceleration_reason varchar2(8))
/
comment on column dpp_instalment.acceleration_reason is 'Acceleration reason.'
/

