create or replace force view prd_api_service_vw as
select n.id
     , get_text (
         i_table_name    => 'prd_service'
         , i_column_name => 'name'
         , i_object_id   => n.id
         , i_lang        => l.lang
     ) as name
     , l.lang
  from prd_service n
     , com_language_vw l
 where
     l.lang = 'LANGENG'
/
