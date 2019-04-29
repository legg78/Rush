create or replace force view iss_card_number_vw as
select
    cn.card_id
  , iss_api_token_pkg.decode_card_number(i_card_number => cn.card_number) as card_number
from
    iss_card_number cn
/
