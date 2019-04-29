create or replace force view acq_account_scheme_vw as
select id
     , seqnum
     , inst_id
 from
     acq_account_scheme
/
