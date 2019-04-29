create or replace force view aup_ui_scheme_template_vw as
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
     , c.scheme_id
  from aup_auth_template a
     , rul_ui_mod_vw b
     , aup_scheme_template c
 where a.mod_id = b.id
   and a.id = c.templ_id
/