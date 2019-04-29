create or replace force view asc_ui_state_parameter_vw as 
select x.state_id
     , x.scenario_id
     , x.param_id
     , x.param_name
     , nvl(v.param_value, x.default_value) param_value
     , x.display_order
     , x.data_type
     , x.lov_id
     , x.description
     , x.lang
     , get_number_value(x.data_type, nvl(v.param_value, x.default_value)) param_number_value
     , get_char_value  (x.data_type, nvl(v.param_value, x.default_value)) param_char_value
     , get_date_value  (x.data_type, nvl(v.param_value, x.default_value)) param_date_value
     , get_lov_value   (x.data_type, nvl(v.param_value, x.default_value), x.lov_id) param_lov_value
  from asc_state_param_value v,
       (
        select a.id state_id
             , a.scenario_id
             , c.id param_id
             , c.param_name
             , d.default_value
             , d.display_order
             , c.data_type
             , c.lov_id
             , get_text('asc_state_parameter', 'description', d.id, b.lang) description
             , b.lang
          from asc_state a,
               asc_parameter c,
               asc_state_parameter d,
               com_language_vw b
         where d.param_id = c.id 
           and d.state_type = a.state_type
       ) x
 where v.param_id(+) = x.param_id 
   and v.state_id(+) = x.state_id
/