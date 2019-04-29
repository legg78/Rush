create or replace force view pmo_api_provider_vw as
select
    a.id
  , a.seqnum
  , a.provider_number
  , get_text(
        i_table_name  => 'pmo_provider'
      , i_column_name => 'name'
      , i_object_id   => a.id
      , i_lang        => 'LANGENG'
    ) as name
  , get_text(
        i_table_name  => 'pmo_provider'
      , i_column_name => 'short_name'
      , i_object_id   => a.id
      , i_lang        => 'LANGENG'
    ) as short_name
from
    pmo_provider a
/
