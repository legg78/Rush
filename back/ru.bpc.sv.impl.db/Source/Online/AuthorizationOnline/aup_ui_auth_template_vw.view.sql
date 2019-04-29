create or replace force view aup_ui_auth_template_vw as
select a.id
     , a.seqnum
     , a.templ_type
     , a.resp_code
     , b.id mod_id
     , b.scale_id
     , b.condition
     , b.name
     , b.description
     , b.lang
  from aup_auth_template a
     , rul_ui_mod_vw b
     , rul_mod_scale c
 where a.mod_id = b.id
   and b.scale_id = c.id
   and c.inst_id in (select inst_id from acm_cu_inst_vw)
/