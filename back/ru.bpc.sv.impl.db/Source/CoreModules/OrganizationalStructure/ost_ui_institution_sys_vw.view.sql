create or replace force view ost_ui_institution_sys_vw as
select a.id
     , a.seqnum
     , a.parent_id
     , a.network_id
     , a.inst_type
     , institution_number
     , get_text('ost_institution', 'name', a.id, b.lang) name
     , get_text('ost_institution', 'description', a.id, b.lang) description
     , a.status
     , b.lang
  from ost_institution a
     , com_language_vw b
 where id in (select inst_id from acm_cu_inst_vw)
union all
select 9999 id
     , 1    seqnum
     , null parent_id
     , null network_id
     , null inst_type
     , null institution_number
     , com_api_label_pkg.get_label_text('SYS_INST_NAME', b.lang) name
     , null description
     , null status
     , b.lang
  from com_language_vw b
/
