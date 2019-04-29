create or replace force view rcn_ui_srvp_parameter_vw as
    select
        par.id
      , par.inst_id
      , ins.name                    as inst_name
      , par.seqnum
      , par.provider_id
      , get_text(
            i_table_name  => 'pmo_provider'
          , i_column_name => 'label'
          , i_object_id   => par.provider_id
          , i_lang        => l.lang
        )                           as provider_name
      , par.purpose_id
      , p.label                     as purpose_name
      , par.param_id
      , get_text(
            i_table_name  => 'pmo_parameter'
          , i_column_name => 'label'
          , i_object_id   => par.param_id
          , i_lang        => l.lang
        )                           as param_name
      , l.lang
    from rcn_srvp_parameter         par
       , ost_ui_institution_sys_vw  ins
       , pmo_ui_purpose_vw          p
       , com_language_vw            l
   where par.inst_id = ins.id(+)
     and par.purpose_id = p.id(+)
     and l.lang = ins.lang
/
