create or replace force view dsp_ui_scale_selection_vw as
select d.id
     , d.seqnum
     , d.scale_type
     , get_text(
           i_table_name  => 'dsp_scale_selection'
         , i_column_name => 'label'
         , i_object_id   => d.id
         , i_lang        => l.lang
       ) as label
     , get_text(
           i_table_name  => 'dsp_scale_selection'
         , i_column_name => 'description'
         , i_object_id   => d.id
         , i_lang        => l.lang
       ) as description
     , d.mod_id
     , com_api_i18n_pkg.get_text(
           i_table_name    => 'rul_mod'
         , i_column_name   => 'name'
         , i_object_id     => d.mod_id
         , i_lang          => l.lang
       ) as mod_name
     , l.lang
     , d.init_rule_id
     , com_api_i18n_pkg.get_text(
           i_table_name    => 'rul_proc'
         , i_column_name   => 'name'
         , i_object_id     => d.init_rule_id
         , i_lang          => l.lang
       ) as init_rule_name
  from dsp_scale_selection d
     , com_language_vw l
/
