create or replace type prd_product_tpr as object (
    product_id      number(8)
  , level_priority  number(8)
  , parent_id       number(8)
  , top_flag        number(1)
)
/
