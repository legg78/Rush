create or replace force view set_ui_agent_parameters_vw as
select
    x.*
    , case when x.lov_id is not null
      then com_api_type_pkg.get_lov_value(i_data_type => x.data_type, i_value => nvl(x.value_v, x.value_n), i_lov_id => x.lov_id)
      else to_char(null)
      end lov_value
from (  select
            p.id
            , p.name
            , p.caption
            , set_ui_value_pkg.get_agent_param_v(i_param_name=>p.name, i_agent_id=>a.id, i_data_type=>p.data_type) value_v
            , set_ui_value_pkg.get_agent_param_n(i_param_name=>p.name, i_agent_id=>a.id, i_data_type=>p.data_type) value_n
            , set_ui_value_pkg.get_agent_param_d(i_param_name=>p.name, i_agent_id=>a.id, i_data_type=>p.data_type) value_d
            , p.module_code
            , p.description
            , p.lang
            , p.lowest_level
            , p.default_value
            , p.data_type
            , p.lov_id
            , p.parent_id
            , p.display_order
            , a.id agent_id
        from
            set_ui_parameter_vw p
            , ost_agent a
        where
            p.lang = get_user_lang 
            and p.lowest_level IN ('PLVLAGNT', 'PLVLUSER')
    ) x
/
