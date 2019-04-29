create or replace force view iss_black_list_vw as
select
    a.id
  , a.card_number
from
    iss_black_list a
/
