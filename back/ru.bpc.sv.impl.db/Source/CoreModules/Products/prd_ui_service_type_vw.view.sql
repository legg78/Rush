create or replace force view prd_ui_service_type_vw as
select
    n.id
  , n.seqnum
  , n.product_type
  , n.entity_type
  , n.is_initial
  , n.enable_event_type
  , n.disable_event_type
  , get_text (
        i_table_name  => 'prd_service_type'
      , i_column_name => 'label'
      , i_object_id   => n.id
      , i_lang        => l.lang
    ) label
  , get_text (
        i_table_name  => 'prd_service_type'
      , i_column_name => 'description'
      , i_object_id   => n.id
      , i_lang        => l.lang
    ) description
  , l.lang
  , n.service_fee
  , n.external_code
from prd_service_type n
   , com_language_vw l
/

