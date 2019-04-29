create or replace force view dpp_instalment_vw as
select
    id
  , dpp_id
  , instalment_number
  , instalment_date
  , instalment_amount
  , payment_amount
  , interest_amount
  , macros_id
  , acceleration_type
  , split_hash
  , fee_id
  , acceleration_reason
from
    dpp_instalment
/
