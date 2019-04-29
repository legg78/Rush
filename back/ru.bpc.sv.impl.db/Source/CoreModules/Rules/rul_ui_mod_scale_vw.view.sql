create or replace force view rul_ui_mod_scale_vw as
select 
      s.id
    , s.inst_id
    , s.seqnum
    , s.scale_type
    , l.lang
    , com_api_i18n_pkg.get_text('rul_mod_scale', 'name', s.id, l.lang) name
    , com_api_i18n_pkg.get_text('rul_mod_scale', 'description', s.id, l.lang) description
from 
    rul_mod_scale s
    , com_language_vw l
where s.inst_id in (select a.inst_id from acm_cu_inst_vw a)    
/
