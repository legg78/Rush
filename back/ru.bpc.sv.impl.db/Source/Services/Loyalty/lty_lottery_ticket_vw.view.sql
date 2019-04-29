create or replace force view lty_lottery_ticket_vw as
select id
     , seqnum
     , split_hash
     , customer_id
     , card_id
     , service_id
     , ticket_number
     , registration_date
     , status
     , inst_id
  from lty_lottery_ticket
/
