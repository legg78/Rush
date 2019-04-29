create or replace force view com_i18n_vw
as
select 
    id
  , lang
  , entity_type
  , table_name
  , column_name
  , object_id
  , text
from com_i18n
/