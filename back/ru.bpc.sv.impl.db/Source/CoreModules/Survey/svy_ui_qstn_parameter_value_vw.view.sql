create or replace force view svy_ui_qstn_parameter_value_vw as
select pv.id
     , pv.seqnum
     , pv.questionary_id
     , pv.param_id
     , p.param_name
     , get_text(
           i_table_name   => 'svy_parameter'
         , i_column_name  => 'name'
         , i_object_id    => p.id
         , i_lang         => l.lang
       ) as param_name_text
     , p.data_type
     , pv.param_value
     , case p.data_type
           when 'DTTPDATE' then to_char(to_date(pv.param_value, 'yyyymmddhh24miss'), 'dd.mm.yyyy')
           when 'DTTPNMBR' then to_char(to_number(pv.param_value, 'FM000000000000000000.0000'))
           else pv.param_value
       end param_value_format
     , pv.seq_number
     , l.lang
  from svy_qstn_parameter_value pv
     , svy_parameter p
     , com_language_vw l
 where pv.param_id = p.id
/
