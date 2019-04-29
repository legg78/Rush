create or replace force view rul_ui_rule_param_value_vw as
select v.id
     , v.seqnum
     , x.rule_id
     , x.param_id
     , x.lov_id
     , get_number_value (x.data_type, v.param_value) param_number_value
     , get_char_value   (x.data_type, v.param_value) param_char_value
     , get_date_value   (x.data_type, v.param_value) param_date_value
     , get_lov_value    (x.data_type, v.param_value, x.lov_id) param_lov_value
     , data_type
  from (select r.id rule_id
             , p.id param_id
             , nvl(p.lov_id, m.lov_id) as lov_id
             , m.data_type
          from rul_rule r
             , rul_proc_param p
             , rul_mod_param m
         where r.proc_id = p.proc_id
           and m.id      = p.param_id
       ) x
     , rul_rule_param_value v
 where x.rule_id  = v.rule_id(+)
   and x.param_id = v.proc_param_id(+)
/
