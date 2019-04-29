create or replace force view asc_api_scenario_states_vw as 
select x.state_code
     , x.state_type 
     , x.scenario_id 
     , x.scenario_name 
     , x.param_name 
     , nvl(y.param_value, x.default_value) param_value 
     , x.seqnum 
  from (
        select a.code state_code
             , a.state_type
             , b.id scenario_id
             , get_text ('asc_scenario', 'name', b.id, 'LANGENG') scenario_name
             , d.param_name
             , b.seqnum
             , a.id state_id
             , d.id param_id
             , c.default_value default_value
          from asc_state a
             , asc_scenario b
             , asc_state_parameter c
             , asc_parameter d
         where a.scenario_id = b.id
           and a.state_type  = c.state_type(+)
           and c.param_id    = d.id(+)
       ) x
     , asc_state_param_value y
 where x.state_id = y.state_id(+)
   and x.param_id = y.param_id(+)
/