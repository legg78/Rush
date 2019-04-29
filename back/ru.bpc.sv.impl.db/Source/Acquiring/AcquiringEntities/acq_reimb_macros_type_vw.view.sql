create or replace force view acq_reimb_macros_type_vw as
select id
     , macros_type_id
     , amount_type
     , is_reversal
     , inst_id
     , seqnum
  from acq_reimb_macros_type
/
