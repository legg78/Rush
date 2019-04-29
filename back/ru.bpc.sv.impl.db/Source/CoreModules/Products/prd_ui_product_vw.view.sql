create or replace force view prd_ui_product_vw as
select n.id
     , n.product_type
     , n.contract_type
     , n.parent_id
     , n.seqnum
     , n.inst_id
     , n.status
     , n.product_number
     , get_text(
           i_table_name  => 'prd_product'
         , i_column_name => 'label'
         , i_object_id   => n.id
         , i_lang        => l.lang
       ) as label
     , get_text(
           i_table_name  => 'prd_product'
         , i_column_name => 'description'
         , i_object_id   => n.id
         , i_lang        => l.lang
       ) as description
     , l.lang
from prd_product n
   , com_language_vw l
/
