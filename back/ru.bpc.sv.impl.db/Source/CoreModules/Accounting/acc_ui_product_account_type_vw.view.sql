create or replace force view acc_ui_product_account_type_vw as
select
    id
    , product_id
    , account_type
    , scheme_id
    , currency
    , service_id
    , aval_algorithm
from
    acc_product_account_type c
/
