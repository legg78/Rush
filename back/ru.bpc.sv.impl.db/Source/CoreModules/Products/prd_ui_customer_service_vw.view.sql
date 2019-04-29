create or replace force view prd_ui_customer_service_vw as
select
    ps.id
    , ps.parent_id
    , sv.id service_id
    , sv.label service_label
    , sv.lang
    , st.id service_type_id
    , st.label service_type
    , st.is_initial
    , m.id customer_id
    , m.customer_number
    , cn.contract_number
    , m.contract_id
    , cn.product_id
    , decode(
        (select
            count(*) 
        from
            prd_service_object o 
        where ((st.is_initial = 0 and o.entity_type = 'ENTTCUST' and o.object_id = m.id)
            or (st.is_initial = 1 and o.contract_id = cn.id)) 
            and o.service_id = sv.id),0,0,1) is_service_exist
    , sum(
        (select
            count(*) 
        from
            prd_service_object o 
        where ((st.is_initial = 0 and o.entity_type = 'ENTTCUST' and o.object_id = m.id)
            or (st.is_initial = 1 and o.contract_id = cn.id)) 
            and o.service_id = sv.id)
    ) over(partition by sv.lang, m.id) total_count      
    , nvl(ps.min_count, 0) min_count    
    , nvl(ps.max_count, 0) max_count
from (  
    select
        connect_by_root service_id root_service_id
        , id
        , parent_id
        , product_id
        , service_id
        , min_count
        , max_count
    from
        prd_product_service_vw
    connect by
        parent_id = prior id
    start with 
        parent_id is null
    ) ps
    , prd_service_vw s
    , prd_service_type_vw t
    , prd_customer m
    , prd_contract cn
    , prd_ui_service_vw sv
    , prd_ui_service_type_vw st
where
    t.entity_type = 'ENTTCUST'
    and s.service_type_id = t.id
    and m.contract_id = cn.id
    and m.inst_id = s.inst_id
    and ps.root_service_id = s.id
    and ps.product_id = cn.product_id
    and sv.id = ps.service_id
    and st.id = sv.service_type_id
    and st.lang = sv.lang
/