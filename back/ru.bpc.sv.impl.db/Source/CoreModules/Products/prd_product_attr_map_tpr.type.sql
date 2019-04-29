create or replace type prd_product_attr_map_tpr as object (
    product_id            number(8)
  , attr_value            varchar2(200)
  , level_priority        number(8)
  , object_type           varchar2(8)
  , register_timestamp    timestamp(6)
  , start_date            date
  , end_date              date
)
/
