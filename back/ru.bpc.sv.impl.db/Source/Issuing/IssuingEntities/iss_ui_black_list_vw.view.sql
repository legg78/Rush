create or replace force view iss_ui_black_list_vw as
select
    a.id
  , iss_api_token_pkg.decode_card_number(i_card_number => a.card_number) as card_number
from
    iss_black_list a
/
