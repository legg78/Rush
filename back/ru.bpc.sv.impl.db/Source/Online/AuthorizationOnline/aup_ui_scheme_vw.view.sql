create or replace force view aup_ui_scheme_vw as
select a.id
     , a.seqnum
     , a.scheme_type
     , a.inst_id
     , a.scale_id
     , a.resp_code
     , get_text('aup_scheme', 'label', a.id, b.lang) label
     , get_text('aup_scheme', 'description', a.id, b.lang) description
     , b.lang
     , a.system_name
  from aup_scheme a
     , com_language_vw b
 where a.inst_id in (select inst_id from acm_cu_inst_vw)
/