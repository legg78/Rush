create or replace force view cst_ui_bsm_prior_prd_detail_vw as
  select a.id
    , a.product_id
    , a.parent_product_id
    , a.product_number
    , a.product_description
    , a.product_category
    , a.product_subcategory
    , a.product_level3
    , a.creation_date
    , a.product_level4
    , a.product_lag
  from cst_bsm_prior_prd_detail_vw a
/
