create or replace force view pmo_ui_template_vw as
select a.id
     , get_text (
           i_table_name  => 'pmo_order'
         , i_column_name => 'label'
         , i_object_id   => a.id
         , i_lang        => b.lang
       ) as label
     , get_text(
           i_table_name  => 'pmo_order'
         , i_column_name => 'description'
         , i_object_id   => a.id
         , i_lang        => b.lang
       ) as description
     , a.customer_id
     , a.purpose_id
     , a.is_prepared_order
     , a.templ_status status
     , a.inst_id
     , b.lang
     , a.amount
     , a.currency
     , a.payment_order_number
     , a.entity_type
     , a.object_id
     , case when a.entity_type = 'ENTTCARD' then iss_api_card_pkg.get_card_mask(n.card_number)
            when a.entity_type = 'ENTTACCT' then t.account_number
            when a.entity_type = 'ENTTCUST' then c.customer_number
            when a.entity_type = 'ENTTMRCH' then m.merchant_number
            when a.entity_type = 'ENTTTRMN' then tl.terminal_number
            else null
       end object_number
  from pmo_order_vw a
     , com_language_vw b
     , iss_card_number n
     , prd_customer c
     , acc_account t
     , acq_merchant m
     , acq_terminal tl
 where a.inst_id in (select d.inst_id from acm_cu_inst_vw d)
   and a.is_template = 1
   and a.object_id = n.card_id(+)
   and a.object_id = c.id(+)
   and a.object_id = t.id(+)
   and a.object_id = m.id(+)
   and a.object_id = tl.id(+)
/
