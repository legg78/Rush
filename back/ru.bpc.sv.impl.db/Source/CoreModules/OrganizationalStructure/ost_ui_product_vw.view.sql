create or replace force view ost_ui_product_vw as
select
    a.id
    , a.product_type
    , a.contract_type
    , a.parent_id
    , a.seqnum
    , a.inst_id
    , a.status
    , a.lang
    , a.label
    , a.description
from
    prd_ui_product_vw a
where
    a.product_type = 'PRDT0300'
/
