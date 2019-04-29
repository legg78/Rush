create or replace force view ost_institution_vw as
select id
     , seqnum
     , parent_id
     , network_id
     , inst_type
     , institution_number
     , status
  from ost_institution
/
