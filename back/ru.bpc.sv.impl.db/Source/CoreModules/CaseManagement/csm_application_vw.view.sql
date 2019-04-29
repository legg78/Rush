create or replace force view csm_application_vw as
select id
     , seqnum
     , case_source
     , case_id
     , claim_id
     , original_id
     , dispute_id
  from csm_application
/
