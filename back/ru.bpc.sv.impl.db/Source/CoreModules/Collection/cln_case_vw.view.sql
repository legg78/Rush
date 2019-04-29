create or replace force view cln_case_vw as
select c.id
     , c.seqnum
     , c.inst_id
     , c.split_hash
     , c.case_number 
     , c.creation_date
     , c.customer_id
     , c.user_id
     , c.status
     , c.resolution
  from cln_case c
/
