create or replace force view rcn_ui_srvp_data_vw as
    select
        dt.id
      , dt.part_key
      , dt.msg_id                   as recon_msg_id
      , dt.purpose_id
      , p.label                     as purpose_name
      , dt.param_id
      , get_text(
            i_table_name  => 'pmo_parameter'
          , i_column_name => 'label'
          , i_object_id   => dt.param_id
          , i_lang        => l.lang
        )                           as param_name
      , dt.param_value
      , l.lang
    from rcn_srvp_data              dt
       , pmo_ui_purpose_vw          p
       , com_language_vw            l
   where dt.purpose_id = p.id(+)
     and l.lang = p.lang
/
