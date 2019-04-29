create or replace force view pmo_ui_schedule_vw as
select a.id
     , a.seqnum
     , a.order_id
     , a.event_type
     , a.entity_type
     , a.object_id
     , a.attempt_limit
     , a.amount_algorithm
     , a.cycle_id
     , case when a.entity_type = 'ENTTCARD' then iss_api_card_pkg.get_card_mask(n.card_number)
            when a.entity_type = 'ENTTACCT' then t.account_number
            when a.entity_type = 'ENTTCUST' then c.customer_number
            when a.entity_type = 'ENTTMRCH' then m.merchant_number
            when a.entity_type = 'ENTTTRMN' then tl.terminal_number
            else null
       end object_number         
  from pmo_schedule_vw a
     , iss_card_number n
     , prd_customer c
     , acc_account t
     , acq_merchant m
     , acq_terminal tl
 where a.object_id = n.card_id(+)   
   and a.object_id = c.id(+)
   and a.object_id = t.id(+)
   and a.object_id = m.id(+)
   and a.object_id = tl.id(+)
/

