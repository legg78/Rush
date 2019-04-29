create or replace force view vch_batch_vw as
select id
     , seqnum
     , status
     , total_amount
     , currency
     , total_count
     , reg_date
     , proc_date
     , merchant_id
     , terminal_id
     , status_reason
     , user_id
     , inst_id
     , card_network_id
  from vch_batch
/