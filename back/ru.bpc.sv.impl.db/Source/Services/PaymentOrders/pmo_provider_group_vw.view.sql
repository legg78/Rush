create or replace force view pmo_provider_group_vw as
select p.id
     , p.seqnum
     , p.parent_id
     , p.region_code
     , p.provider_group_number
     , p.logo_path
     , p.inst_id
  from pmo_provider_group p
/
