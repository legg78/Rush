create unique index prd_product_service_uk on prd_product_service (service_id, product_id)
/
create index prd_product_service_prod_ndx on prd_product_service (product_id)
/
