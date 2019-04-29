create or replace force view com_ui_id_type_vw as 
select a.id
     , a.seqnum
     , a.entity_type
     , get_article_text(a.entity_type, b.lang) as entity_type_desc
     , a.inst_id
     , a.id_type
     , get_article_text(a.id_type, b.lang) id_type_desc
     , b.lang
from com_id_type a
   , com_language_vw b
where a.inst_id in (select inst_id from acm_cu_inst_vw)
/

