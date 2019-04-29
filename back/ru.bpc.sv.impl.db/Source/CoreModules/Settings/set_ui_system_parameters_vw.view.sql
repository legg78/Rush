create or replace force view set_ui_system_parameters_vw as
select
    x.id
    , x.name
    , x.caption
    , x.value_v
    , x.value_n
    , x.value_d
    , x.module_code
    , x.description
    , x.lang
    , x.lowest_level
    , x.default_value
    , x.data_type
    , x.lov_id
    , x.parent_id
    , x.display_order
    , x.is_encrypted
    , case when x.lov_id is not null
      then com_api_type_pkg.get_lov_value(i_data_type => x.data_type, i_value => nvl(x.value_v, x.value_n), i_lov_id => x.lov_id)
      else to_char(null)
      end lov_value
from (  select
            p.id
            , p.name
            , p.caption
            , set_ui_value_pkg.get_system_param_v(i_param_name=>p.name, i_data_type=>p.data_type) value_v
            , set_ui_value_pkg.get_system_param_n(i_param_name=>p.name, i_data_type=>p.data_type) value_n
            , set_ui_value_pkg.get_system_param_d(i_param_name=>p.name, i_data_type=>p.data_type) value_d
            , p.module_code
            , p.description
            , p.lang
            , p.lowest_level
            , p.default_value
            , p.data_type
            , p.lov_id
            , p.parent_id
            , p.display_order
            , p.is_encrypted
        from
            set_ui_parameter_vw p
        where
            p.lang = get_user_lang 
    ) x
/
