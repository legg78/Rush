create or replace force view cmn_standard_version_vw as
select id
     , seqnum
     , standard_id
     , version_number
     , version_order
  from cmn_standard_version
/
