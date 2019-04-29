create or replace force view com_api_currency_vw as
select
    a.id
  , a.seqnum
  , a.code
  , a.name
  , a.exponent
from
    com_currency_vw a
/
