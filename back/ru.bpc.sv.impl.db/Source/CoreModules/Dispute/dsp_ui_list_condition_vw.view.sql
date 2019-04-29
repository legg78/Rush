create or replace force view dsp_ui_list_condition_vw as
select n.id
     , n.init_rule
     , n.gen_rule
     , n.func_order
     , n.mod_id
     , get_text(
           i_table_name   => 'dsp_list_condition'
         , i_column_name  => 'name'
         , i_object_id    => n.id
         , i_lang         => l.lang
       ) as type
     , l.lang
     , n.is_online
     , s.scale_type
     , n.msg_type
  from dsp_list_condition n
     , com_language_vw l
     , rul_mod m
     , rul_mod_scale s
 where m.id = n.mod_id
   and s.id = m.scale_id    
/
