create or replace package body asc_ui_scenario_pkg is
/**********************************************************
 * UI for scenaries<br/>
 * Created by Rashin G.(rashin@bpcbt.com)  at 03.02.2010<br/>
 * Last changed by $Author$<br/>
 * $LastChangedDate::                           $<br/>
 * Revision: $LastChangedRevision$<br/>
 * Module: ASC_UI_SCENARIO_PKG
 * @headcom
 **********************************************************/
procedure add_scenario (
    o_scenario_id          out com_api_type_pkg.t_tiny_id
    , o_seqnum             out com_api_type_pkg.t_seqnum
    , i_scenario_name      in com_api_type_pkg.t_name
    , i_lang               in com_api_type_pkg.t_dict_value default null
    , i_description        in com_api_type_pkg.t_full_desc default null
) is
begin
    o_scenario_id := asc_scenario_seq.nextval;
    o_seqnum := 1;

    begin
        insert into asc_scenario_vw (
            id
            , seqnum
        ) values (
            o_scenario_id
            , o_seqnum
        );
    exception
        when dup_val_on_index then
            com_api_error_pkg.raise_error (
                i_error             => 'ASC_SCENARIO_ALREADY_EXISTS'
                , i_env_param1      => o_scenario_id
            );
    end;

    com_api_i18n_pkg.add_text (
        i_table_name     => 'asc_scenario'
        , i_column_name  => 'name'
        , i_object_id    => o_scenario_id
        , i_lang         => i_lang
        , i_text         => i_scenario_name
    );

    com_api_i18n_pkg.add_text (
        i_table_name     => 'asc_scenario'
        , i_column_name  => 'description'
        , i_object_id    => o_scenario_id
        , i_lang         => i_lang
        , i_text         => i_description
    );
end;

procedure modify_scenario (
    i_scenario_id          in com_api_type_pkg.t_tiny_id
    , io_seqnum            in out com_api_type_pkg.t_seqnum
    , i_scenario_name      in com_api_type_pkg.t_name
    , i_lang               in com_api_type_pkg.t_dict_value default null
    , i_description        in com_api_type_pkg.t_full_desc default null
) is
begin

    begin
        update
            asc_scenario_vw
        set
              seqnum = io_seqnum
        where
            id = i_scenario_id;
    exception
        when dup_val_on_index then
            com_api_error_pkg.raise_error (
                i_error             => 'ASC_SCENARIO_ALREADY_EXISTS'
                , i_env_param1      => i_scenario_id
            );
    end;
        
    io_seqnum := io_seqnum + 1;

    com_api_i18n_pkg.add_text (
        i_table_name     => 'asc_scenario'
        , i_column_name  => 'name'
        , i_object_id    => i_scenario_id
        , i_lang         => i_lang
        , i_text         => i_scenario_name
    );

    com_api_i18n_pkg.add_text (
        i_table_name     => 'asc_scenario'
        , i_column_name  => 'description'
        , i_object_id    => i_scenario_id
        , i_lang         => i_lang
        , i_text         => i_description
    );
end;

procedure remove_scenario (
    i_scenario_id          in com_api_type_pkg.t_tiny_id
    , i_seqnum             in com_api_type_pkg.t_seqnum
) is
begin
    update
        asc_scenario_vw
    set
        seqnum = i_seqnum
    where
        id = i_scenario_id;

    for rec in (
        select
            a.id
            , a.seqnum
        from
            asc_state a
        where
            a.scenario_id = i_scenario_id
    ) loop
        remove_state (
            i_state_id => rec.id
            , i_seqnum => rec.seqnum
        );
    end loop;
    
    for sel in (
        select
            id
        from
            asc_scenario_selection
        where
            scenario_id = i_scenario_id
    ) loop
        remove_selection (
            i_id  => sel.id
        );
    end loop;

    delete from
        asc_scenario_vw
    where
        id = i_scenario_id;

    com_api_i18n_pkg.remove_text (
        i_table_name   => 'asc_scenario'
        , i_object_id  => i_scenario_id
    );
end remove_scenario;

procedure add_state (
    o_state_id             out com_api_type_pkg.t_short_id
    , o_seqnum             out com_api_type_pkg.t_seqnum
    , i_scenario_id        in com_api_type_pkg.t_tiny_id
    , i_state_code         in com_api_type_pkg.t_tiny_id
    , i_state_type         in com_api_type_pkg.t_dict_value
    , i_lang               in com_api_type_pkg.t_dict_value default null
    , i_description        in com_api_type_pkg.t_full_desc default null
) is
begin
    o_state_id := asc_state_seq.nextval;
    o_seqnum := 1;
        
    begin
        insert into asc_state_vw (
            id
            , code
            , state_type
            , scenario_id
            , seqnum
        ) values (
            o_state_id
            , i_state_code
            , i_state_type
            , i_scenario_id
            , o_seqnum
        );
    exception
        when dup_val_on_index then
            com_api_error_pkg.raise_error (
                i_error         => 'ASC_STATE_ALREADY_EXISTS'
                , i_env_param1  => i_scenario_id
                , i_env_param2  => i_state_code
            );
    end;
        
    com_api_i18n_pkg.add_text (
        i_table_name     => 'asc_state'
        , i_column_name  => 'description'
        , i_object_id    => o_state_id
        , i_lang         => i_lang
        , i_text         => i_description
    );
end;

procedure modify_state (
    i_state_id             in com_api_type_pkg.t_short_id
    , io_seqnum            in out com_api_type_pkg.t_seqnum
    , i_state_code         in com_api_type_pkg.t_tiny_id
    , i_lang               in com_api_type_pkg.t_dict_value default null
    , i_description        in com_api_type_pkg.t_full_desc default null
) is
begin
    update
        asc_state_vw
    set
        code = i_state_code
        , seqnum = io_seqnum
    where
        id = i_state_id;
        
    io_seqnum := io_seqnum + 1;

    com_api_i18n_pkg.add_text (
        i_table_name     => 'asc_state'
        , i_column_name  => 'description'
        , i_object_id    => i_state_id
        , i_lang         => i_lang
        , i_text         => i_description
    );

end;

procedure remove_state (
    i_state_id             in com_api_type_pkg.t_short_id
    , i_seqnum             in com_api_type_pkg.t_seqnum
) is
begin
    update
        asc_state_vw
    set
        seqnum = i_seqnum
    where
        id = i_state_id;

    delete from
        asc_state_param_value_vw a
    where
        a.state_id = i_state_id;

    delete from
        asc_state_vw
    where
        id = i_state_id;

    com_api_i18n_pkg.remove_text (
        i_table_name   => 'asc_state'
        , i_object_id  => i_state_id
    );

end;
    
procedure assert_param_type (
    i_parameter_id      in com_api_type_pkg.t_tiny_id
    , i_type            in com_api_type_pkg.t_dict_value
) is
    l_type              com_api_type_pkg.t_dict_value;
begin
    select
        data_type
    into
        l_type
    from
        asc_parameter
    where
        id = i_parameter_id;

    if l_type = i_type then
        null;
    else
        com_api_error_pkg.raise_error (
            i_error             => 'WRONG_PARAMETER_DATA_TYPE'
            , i_env_param1      => i_parameter_id
            , i_env_param2      => l_type
            , i_env_param3      => i_type
        );
    end if;
exception
    when no_data_found then
        com_api_error_pkg.raise_error (
            i_error             => 'UNDEFINED_PARAMETER'
            , i_env_param1      => i_parameter_id
        );
end;


procedure set_state_param_value (
    i_state_id             in com_api_type_pkg.t_short_id
    , i_parameter_id       in com_api_type_pkg.t_tiny_id
    , i_value              in com_api_type_pkg.t_full_desc
    , i_seqnum             in com_api_type_pkg.t_seqnum
) is
begin
    update
        asc_state_vw
    set
        seqnum = i_seqnum
    where
        id = i_state_id;
            
    merge into
        asc_state_param_value_vw dst
    using (
        select
            i_state_id          state_id
            , p.id              param_id
            , i_value           param_value
        from
            asc_parameter p
        where
            p.id = i_parameter_id
    ) src
    on (
        src.state_id = dst.state_id
        and src.param_id = dst.param_id
    )
    when matched then
        update
        set
            dst.param_value = src.param_value
    when not matched then
        insert (
            dst.state_id
            , dst.param_id
            , dst.param_value
        ) values (
            src.state_id
            , src.param_id
            , src.param_value
        );
end;
    
procedure add_state_param_value (
    i_state_id             in com_api_type_pkg.t_short_id
    , i_parameter_id       in com_api_type_pkg.t_tiny_id
    , i_value_char         in com_api_type_pkg.t_full_desc
    , i_seqnum             in com_api_type_pkg.t_seqnum
) is
begin
    assert_param_type (
        i_parameter_id      => i_parameter_id
        , i_type            => com_api_const_pkg.DATA_TYPE_CHAR
    );
    
    set_state_param_value (
        i_state_id          => i_state_id
        , i_parameter_id    => i_parameter_id
        , i_value           => i_value_char
        , i_seqnum          => i_seqnum
    );
end;

procedure add_state_param_value (
    i_state_id             in com_api_type_pkg.t_short_id
    , i_parameter_id       in com_api_type_pkg.t_tiny_id
    , i_value_num          in number
    , i_seqnum             in com_api_type_pkg.t_seqnum
) is
begin
    assert_param_type (
        i_parameter_id      => i_parameter_id
        , i_type            => com_api_const_pkg.DATA_TYPE_NUMBER
    );
    
    set_state_param_value (
        i_state_id          => i_state_id
        , i_parameter_id    => i_parameter_id
        , i_value           => to_char(i_value_num, get_number_format)
        , i_seqnum          => i_seqnum
    );
end;

procedure add_state_param_value (
    i_state_id             in com_api_type_pkg.t_short_id
    , i_parameter_id       in com_api_type_pkg.t_tiny_id
    , i_value_date         in date
    , i_seqnum             in com_api_type_pkg.t_seqnum
) is
begin
    assert_param_type (
        i_parameter_id      => i_parameter_id
        , i_type            => com_api_const_pkg.DATA_TYPE_DATE
    );
    
    set_state_param_value (
        i_state_id          => i_state_id
        , i_parameter_id    => i_parameter_id
        , i_value           => to_char(i_value_date, get_date_format)
        , i_seqnum          => i_seqnum
    );
end;

procedure add_selection(
    o_id                      out com_api_type_pkg.t_short_id
  , i_scenario_id          in     com_api_type_pkg.t_tiny_id
  , i_mod_id               in     com_api_type_pkg.t_tiny_id
  , i_oper_type            in     com_api_type_pkg.t_dict_value
  , i_is_reversal          in     com_api_type_pkg.t_boolean
  , i_sttl_type            in     com_api_type_pkg.t_dict_value
  , i_priority             in     com_api_type_pkg.t_tiny_id
  , i_msg_type             in     com_api_type_pkg.t_dict_value
  , i_terminal_type        in     com_api_type_pkg.t_dict_value
  , i_oper_reason          in     com_api_type_pkg.t_dict_value
) is
begin
    o_id := asc_scenario_selection_seq.nextval;

    insert into asc_scenario_selection_vw(
        id
      , scenario_id
      , mod_id
      , oper_type
      , is_reversal
      , sttl_type
      , priority
      , msg_type
      , terminal_type
      , oper_reason
    ) values (
        o_id
      , i_scenario_id
      , i_mod_id
      , i_oper_type
      , i_is_reversal
      , i_sttl_type
      , i_priority
      , i_msg_type
      , nvl(i_terminal_type, '%')
      , nvl(i_oper_reason, '%')
    );
end;

procedure remove_selection(
    i_id                   in     com_api_type_pkg.t_short_id
) is
begin
    delete
        asc_scenario_selection_vw
    where
        id = i_id;
end;

end;
/
