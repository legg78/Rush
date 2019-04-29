create or replace force view adt_ui_entity_vw as
select
    a.entity_type
  , a.table_name
  , a.is_active
  , a.synch_needed
  , com_api_i18n_pkg.get_text('com_dictionary', 'name', b.id) name 
from
    adt_entity a
  , com_dictionary b
where
    a.entity_type = b.dict||b.code
and
    is_active != -1
/