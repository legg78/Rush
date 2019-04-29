create or replace force view dpp_ui_attribute_value_vw as
select
    g.attr_id
  , g.parent_id
  , g.attr_name
  , g.label
  , g.description
  , g.data_type
  , g.lov_id
  , g.entity_type
  , g.object_type
  , g.dpp_id
  , g.lang
  , g.display_order
  , g.value
  , case g.entity_type
        when 'ENTTFEES' then fcl_ui_fee_pkg.get_fee_desc(to_number(g.value, 'FM000000000000000000.0000'))
        when 'ENTTCYCL' then fcl_ui_cycle_pkg.get_cycle_desc(to_number(g.value, 'FM000000000000000000.0000'))
        when 'ENTTLIMT' then fcl_ui_limit_pkg.get_limit_desc(to_number(g.value, 'FM000000000000000000.0000'))
        else g.value
    end value_description
  , get_number_value(g.data_type, g.value) number_value
  , get_char_value  (g.data_type, g.value) char_value
  , get_date_value  (g.data_type, g.value) date_value
  , get_lov_value   (g.data_type, g.value, g.lov_id) lov_value
  , dpp_attr_val_id
from
    (select
        i.attr_id
      , i.parent_id
      , i.attr_name
      , i.label
      , i.description
      , i.data_type
      , i.lov_id
      , i.entity_type
      , i.object_type
      , i.dpp_id
      , i.lang
      , i.display_order
      , o.value
      , o.dpp_id as dpp_attr_val_id
    from
        (select
            a.id as attr_id
          , a.parent_id
          , a.attr_name
          , a.label
          , a.description
          , a.data_type
          , a.lov_id
          , a.entity_type
          , a.object_type
          , b.id as dpp_id
          , a.lang
          , a.display_order
        from
            prd_ui_attribute_vw a
          , dpp_payment_plan_vw b
        where
            a.service_type_id = dpp_api_const_pkg.get_dpp_service_type
        ) i
      , dpp_attribute_value_vw o
    where o.dpp_id (+) = i.dpp_id
      and o.attr_id (+) = i.attr_id
    ) g
/
