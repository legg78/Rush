create or replace force view acq_reimb_channel_vw as
select id
     , channel_number
     , payment_mode
     , currency
     , inst_id
     , seqnum
  from acq_reimb_channel
/
