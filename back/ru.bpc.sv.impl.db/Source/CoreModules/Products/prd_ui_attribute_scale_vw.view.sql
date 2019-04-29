create or replace force view prd_ui_attribute_scale_vw as
select 
    id
  , attr_id
  , inst_id
  , scale_id
  , get_text('rul_mod_scale','name',scale_id, l.lang) scale_name
  , l.lang
  , seqnum
from prd_attribute_scale s
   , com_language_vw l
/
