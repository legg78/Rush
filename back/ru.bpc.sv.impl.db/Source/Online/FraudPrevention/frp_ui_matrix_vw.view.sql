create or replace force view frp_ui_matrix_vw as
select l.lang
     , id
     , seqnum
     , inst_id
     , x_scale
     , com_api_i18n_pkg.get_text(
           i_table_name  => 'rul_mod_param'
         , i_column_name => 'short_description'
         , i_object_id   => (select m.id 
                               from rul_mod_param m 
                              where upper(m.name) = upper(substr(a.x_scale, 1, instr(a.x_scale, '(') - 1)))
         , i_lang        => l.lang
       ) as x_scale_desc
     , y_scale
     , com_api_i18n_pkg.get_text(
           i_table_name  => 'rul_mod_param'
         , i_column_name => 'short_description'
         , i_object_id   => (select m.id
                               from rul_mod_param m 
                              where upper(m.name) = upper(substr(a.y_scale, 1, instr(a.y_scale, '(') - 1)))
         , i_lang        => l.lang
       ) as y_scale_desc
     , matrix_type
     , com_api_i18n_pkg.get_text(
           i_table_name  => 'frp_matrix'
         , i_column_name => 'label'
         , i_object_id   => a.id
         , i_lang        => l.lang
       ) as label
     , com_api_i18n_pkg.get_text(
           i_table_name  => 'frp_matrix'
         , i_column_name => 'description'
         , i_object_id   => a.id
         , i_lang        => l.lang
       ) as description
  from frp_matrix a
     , com_language_vw l
/
