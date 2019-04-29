create or replace force view dpp_attribute_value_vw as
select
    a.id
  , a.dpp_id
  , a.attr_id
  , a.mod_id
  , a.value
  , a.split_hash
from
    dpp_attribute_value a
/
