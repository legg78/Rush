create or replace force view aup_auth_template_vw as
select id
     , seqnum
     , templ_type
     , mod_id
     , resp_code
  from aup_auth_template
/