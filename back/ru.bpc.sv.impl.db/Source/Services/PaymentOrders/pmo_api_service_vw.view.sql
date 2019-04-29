create or replace force view pmo_api_service_vw as
select
    a.id
  , a.seqnum
  , a.direction
  , get_text(
        i_table_name  => 'pmo_service'
      , i_column_name => 'label'
      , i_object_id   => a.id
      , i_lang        => 'LANGENG'
    ) as label
  , get_text(
        i_table_name  => 'pmo_service'
      , i_column_name => 'short_name'
      , i_object_id   => a.id
      , i_lang        => 'LANGENG'
    ) as short_name
  , get_text(
        i_table_name  => 'pmo_service'
      , i_column_name => 'description'
      , i_object_id   => a.id
      , i_lang        => 'LANGENG'
    ) as description
from
    pmo_service_vw a
/
