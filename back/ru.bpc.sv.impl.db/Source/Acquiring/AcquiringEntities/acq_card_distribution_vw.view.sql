create or replace force view acq_card_distribution_vw as
select
    iss_api_token_pkg.decode_card_number(i_card_number => card_number) as card_number
  , merchant_id
  , is_active
from acq_card_distribution
/
