create or replace force view lty_ui_lottery_ticket_vw as
select t.id
     , t.seqnum
     , t.split_hash
     , t.customer_id
     , t.card_id
     , t.service_id
     , t.ticket_number
     , t.registration_date
     , t.status
     , t.inst_id
     , l.lang
     , coalesce(
           c.card_mask
         , iss_api_card_pkg.get_card_mask(i_card_number => c.card_number)
       ) as card_mask
     , cust.customer_number 
     , com_ui_object_pkg.get_object_desc('ENTTCUST', t.customer_id) as customer_name 
     , get_article_text (
           i_article  => t.status
         , i_lang   => l.lang
       ) as status_desc
     , ost_ui_institution_pkg.get_inst_name(t.inst_id) as inst_name 
  from lty_lottery_ticket t
     , iss_card_vw c
     , prd_customer cust 
     , com_language_vw l
 where t.card_id = c.id(+)
   and t.customer_id = cust.id 
   and t.inst_id in (select d.inst_id from acm_cu_inst_vw d)
/
