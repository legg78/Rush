create or replace type dpp_instalment_tpr as object (
    id                   number(16)
  , instalment_date      date
  , amount               number(22,4)
  , interest             number(22,4)
  , repayment            number(22,4)
  , is_posted            number(1)
  , macros_id            number(16)
  , need_acceleration    number(1)
  , acceleration_type    varchar2(8)
  , split_hash           number(4)
  , period_days_count    number(4)
  , fee_id               number(8)
  , acceleration_reason  varchar2(8)
)
/
