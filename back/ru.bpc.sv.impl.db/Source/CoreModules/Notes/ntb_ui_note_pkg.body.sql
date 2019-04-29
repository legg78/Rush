create or replace package body ntb_ui_note_pkg is

procedure add(
    o_id                  out com_api_type_pkg.t_long_id
  , i_entity_type         in com_api_type_pkg.t_dict_value
  , i_object_id           in com_api_type_pkg.t_long_id
  , i_note_type           in com_api_type_pkg.t_dict_value
  , i_lang                in com_api_type_pkg.t_dict_value
  , i_header              in com_api_type_pkg.t_text
  , i_text                in com_api_type_pkg.t_text
  , i_start_date          in date default null
  , i_end_date            in date default null
) is

    l_params              com_api_type_pkg.t_param_tab;
    l_split_hash          com_api_type_pkg.t_tiny_id;
    l_inst_id             com_api_type_pkg.t_inst_id;
    l_event_type          com_api_type_pkg.t_dict_value := ntb_api_const_pkg.NOTE_REGISTRATION_EVENT_TYPE;

    procedure check_if_case
    is
        l_case_rec             csm_api_type_pkg.t_csm_case_rec;
    begin
        if i_entity_type = app_api_const_pkg.ENTITY_TYPE_APPLICATION then
            csm_api_case_pkg.get_case(
                i_case_id    => i_object_id
              , o_case_rec   => l_case_rec
              , i_mask_error => com_api_const_pkg.TRUE);

            if l_case_rec.case_id is not null then
                l_event_type := dsp_api_const_pkg.EVENT_ADD_DISPUTE_COMMENT;
                l_inst_id    := l_case_rec.inst_id;
            end if;
            trc_log_pkg.debug(
                i_text => 'l_event_type=' || l_event_type || ' l_inst_id=' || l_inst_id
            );
        end if;
    end;
    
begin
    o_id := ntb_note_seq.nextval;
    l_inst_id := ost_api_const_pkg.DEFAULT_INST;

    trc_log_pkg.debug(
        i_text => 'ntb_ui_note_pkg.add: i_entity_type=' || i_entity_type || ', i_object_id=' || i_object_id
    );
    check_if_case;
        
    insert into ntb_note_vw
    (
        id
      , entity_type
      , object_id
      , note_type
      , reg_date
      , user_id
      , start_date
      , end_date
    ) 
    values
    (
        o_id
      , i_entity_type
      , i_object_id
      , i_note_type
      , systimestamp
      , get_user_id
      , i_start_date
      , i_end_date
    );
        
    com_api_i18n_pkg.add_text(
        i_table_name        => 'ntb_note'
      , i_column_name       => 'header'
      , i_object_id         => o_id
      , i_text              => i_header
      , i_lang              => i_lang
    );
        
    com_api_i18n_pkg.add_text(
        i_table_name        => 'ntb_note'
      , i_column_name       => 'text'
      , i_object_id         => o_id
      , i_text              => i_text
      , i_lang              => i_lang
    );
    
    l_params        := evt_api_shared_data_pkg.g_params;

    evt_api_event_pkg.register_event(
        i_event_type        => l_event_type
      , i_eff_date          => nvl(i_start_date, get_sysdate)
      , i_entity_type       => i_entity_type
      , i_object_id         => i_object_id
      , i_inst_id           => l_inst_id
      , i_split_hash        => l_split_hash
      , i_param_tab         => l_params
    );
    
end add;

procedure move(
    i_entity_type         in com_api_type_pkg.t_dict_value
  , i_object_id_old       in com_api_type_pkg.t_long_id
  , i_object_id_new       in com_api_type_pkg.t_long_id
) is

    l_params              com_api_type_pkg.t_param_tab;
    l_split_hash          com_api_type_pkg.t_tiny_id;
    l_inst_id             com_api_type_pkg.t_inst_id;
    
    l_start_date          date;
    l_count_update        com_api_type_pkg.t_short_id;
    
    l_current_date        date := get_sysdate;
begin
    
    update ntb_note
       set object_id = i_object_id_new
     where object_id = i_object_id_old
       and entity_type = i_entity_type
       and ((start_date is null
             and l_current_date <= nvl(end_date, l_current_date)
            )
            or
            (end_date is null
             and l_current_date >= nvl(start_date, l_current_date)
            )
            or
            (l_current_date between start_date and end_date)
           )
    returning
           max(nvl(start_date, l_current_date))
         , count(1)
      into l_start_date
         , l_count_update;
         
    if l_count_update > 0 then

        l_params        := evt_api_shared_data_pkg.g_params;
        
        evt_api_event_pkg.register_event(
            i_event_type        => ntb_api_const_pkg.NOTE_REGISTRATION_EVENT_TYPE
          , i_eff_date          => greatest(l_start_date, get_sysdate)
          , i_entity_type       => i_entity_type
          , i_object_id         => i_object_id_new
          , i_inst_id           => l_inst_id
          , i_split_hash        => l_split_hash
          , i_param_tab         => l_params
        );
        
    end if;
    
end move;

end ntb_ui_note_pkg;
/
