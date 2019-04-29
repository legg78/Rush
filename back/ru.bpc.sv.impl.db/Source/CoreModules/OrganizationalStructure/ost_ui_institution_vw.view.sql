create or replace force view ost_ui_institution_vw as
select a.id
     , a.seqnum
     , a.parent_id
     , a.network_id
     , a.inst_type
     , a.institution_number
     , get_text('ost_institution', 'name', a.id, b.lang) name
     , get_text('ost_institution', 'description', a.id, b.lang) description
     , a.status
     , b.lang
  from ost_institution a
     , com_language_vw b
 where id in (select inst_id from acm_cu_inst_vw)
/
