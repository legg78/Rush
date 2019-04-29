create or replace force view pmo_ui_service_template_vw as
select a.service_id
     , a.provider_id
     , b.purpose_id
     , b.id as template_id
     , get_text(
         i_table_name  => 'pmo_order'
       , i_column_name => 'label'
       , i_object_id   => b.id
       , i_lang        =>  c.lang
       ) as label
     , get_text(
         i_table_name  => 'pmo_order'
       , i_column_name => 'description'
       , i_object_id   => b.id
       , i_lang        =>  c.lang
       ) as description
     , c.lang
  from pmo_purpose a
     , pmo_order b
     , com_language_vw c
 where a.id          = b.purpose_id
   and b.customer_id = iss_api_card_pkg.get_customer_id(iss_api_card_pkg.get_card_number)
   and b.is_template = 1
/
