create or replace force view aup_scheme_vw as
select a.id
     , a.seqnum
     , a.scheme_type
     , a.inst_id
     , a.scale_id
     , a.resp_code
     , a.system_name
  from aup_scheme a
/