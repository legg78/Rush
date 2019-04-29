create or replace force view set_ui_user_parameters_vw as
select id
     , name
     , caption
     , value_v
     , value_n
     , value_d
     , description
     , default_value
     , data_type
     , lov_id
     , parent_id
     , display_order
     , case when lov_id is not null and data_type = 'DTTPNMBR' 
            then com_api_type_pkg.get_lov_value(i_data_type => data_type, i_value => value_n, i_lov_id => lov_id)
            when lov_id is not null and data_type = 'DTTPCHAR' 
            then com_api_type_pkg.get_lov_value(i_data_type => data_type, i_value => value_v, i_lov_id => lov_id)
            when lov_id is not null and data_type = 'DTTPDATE' 
            then com_api_type_pkg.get_lov_value(i_data_type => data_type, i_value => value_d, i_lov_id => lov_id)
            else to_char(null)
       end as lov_value
     , user_id
     , user_name
  from (     
        select p.id
             , p.name
             , p.caption
             , set_ui_value_pkg.get_user_param_v(i_param_name=>p.name, i_user_id=>u.name, i_data_type=>p.data_type) value_v
             , set_ui_value_pkg.get_user_param_n(i_param_name=>p.name, i_user_id=>u.name, i_data_type=>p.data_type) value_n
             , set_ui_value_pkg.get_user_param_d(i_param_name=>p.name, i_user_id=>u.name, i_data_type=>p.data_type) value_d
             , p.description
             , p.default_value
             , p.data_type
             , p.lov_id
             , p.parent_id
             , p.display_order
             , u.id user_id
             , u.name  as user_name
          from set_ui_parameter_vw p
             , acm_user            u
         where p.lang           = com_ui_user_env_pkg.get_user_lang() 
           and p.lowest_level   = 'PLVLUSER'
       )
/
