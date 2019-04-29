create or replace package body hsm_ui_selection_pkg is

    procedure check_max_connection (
        i_hsm_id                    in com_api_type_pkg.t_tiny_id
        , i_selection_id            in com_api_type_pkg.t_tiny_id
        , i_max_connection          in com_api_type_pkg.t_tiny_id
    ) is
        l_max_connection            com_api_type_pkg.t_tiny_id;
    begin
        select
            (nvl(t.max_connection, 0) - nvl(s.max_connection, 0))
        into
            l_max_connection
        from
            hsm_tcp_ip t
            , (select
                   hsm_device_id
                   , sum(max_connection) max_connection
               from
                   hsm_selection_vw l
               where
                   (l.id != i_selection_id or i_selection_id is null)
               group by
                   hsm_device_id
            ) s
        where
            t.id = i_hsm_id
            and s.hsm_device_id(+) = t.id;

        if l_max_connection < 1 then
            com_api_error_pkg.raise_error (
                i_error         => 'HSM_MAX_CONNECTIONS_EXHAUSTED'
                , i_env_param1  => l_max_connection
            );
        elsif (l_max_connection - i_max_connection) < 0 then
            com_api_error_pkg.raise_error (
                i_error         => 'HSM_MAX_CONNECTIONS_IS_NOT_VALID'
                , i_env_param1  => l_max_connection
            );
        end if;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error (
                i_error         => 'HSM_DEVICE_NOT_FOUND'
                , i_env_param1  => i_hsm_id
            );
    end;
    
      
    procedure add_hsm_selection (
        o_id                        out com_api_type_pkg.t_tiny_id
        , o_seqnum                  out com_api_type_pkg.t_seqnum
        , i_action                  in com_api_type_pkg.t_dict_value
        , i_inst_id                 in com_api_type_pkg.t_inst_id
        , i_mod_id                  in com_api_type_pkg.t_tiny_id
        , i_hsm_id                  in com_api_type_pkg.t_tiny_id
        , i_max_connection          in com_api_type_pkg.t_tiny_id
        , i_firmware                in com_api_type_pkg.t_dict_value
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_description             in com_api_type_pkg.t_full_desc
    ) is
    begin
        check_max_connection (
            i_hsm_id            => i_hsm_id
            , i_selection_id    => o_id
            , i_max_connection  => i_max_connection
        ); 
            
        o_id := hsm_selection_seq.nextval;
        o_seqnum := 1;
            
        insert into hsm_selection_vw (
            id
            , seqnum
            , action
            , inst_id
            , mod_id
            , hsm_device_id
            , max_connection
            , firmware
        ) values (
            o_id
            , o_seqnum
            , i_action
            , i_inst_id
            , i_mod_id
            , i_hsm_id
            , i_max_connection
            , i_firmware
        );
        
        com_api_i18n_pkg.add_text(
            i_table_name   => 'hsm_selection'
          , i_column_name  => 'description'
          , i_object_id    => o_id
          , i_lang         => i_lang
          , i_text         => i_description
        );
    end;

    procedure modify_hsm_selection (
        i_id                        in com_api_type_pkg.t_tiny_id
        , io_seqnum                 in out com_api_type_pkg.t_seqnum
        , i_action                  in com_api_type_pkg.t_dict_value
        , i_inst_id                 in com_api_type_pkg.t_inst_id
        , i_mod_id                  in com_api_type_pkg.t_tiny_id
        , i_hsm_id                  in com_api_type_pkg.t_tiny_id
        , i_max_connection          in com_api_type_pkg.t_tiny_id
        , i_firmware                in com_api_type_pkg.t_dict_value
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_description             in com_api_type_pkg.t_full_desc
    ) is
    begin
        check_max_connection (
            i_hsm_id            => i_hsm_id
            , i_selection_id    => i_id
            , i_max_connection  => i_max_connection
        ); 
      
        update
            hsm_selection_vw
        set
            seqnum = io_seqnum
            , action = i_action
            , inst_id = i_inst_id
            , mod_id = i_mod_id
            , hsm_device_id = i_hsm_id
            , max_connection = i_max_connection
            , firmware = i_firmware
        where
            id = i_id;
            
        io_seqnum := io_seqnum + 1;

        com_api_i18n_pkg.add_text(
            i_table_name            => 'hsm_selection'
          , i_column_name           => 'description'
          , i_object_id             => i_id
          , i_lang                  => i_lang
          , i_text                  => i_description
        );
    end;

    procedure remove_hsm_selection (
        i_id                        in com_api_type_pkg.t_tiny_id
        , i_seqnum                  in com_api_type_pkg.t_seqnum
    ) is
    begin
        com_api_i18n_pkg.remove_text(
            i_table_name  => 'hsm_selection'
          , i_object_id   => i_id
        );
          
        update
            hsm_selection_vw
        set
            seqnum = i_seqnum
        where
            id = i_id;
            
        delete from
            hsm_selection_vw
        where
            id = i_id;
    end;

    procedure get_hsm_lov (
        o_ref_cur                   out sys_refcursor
        , i_inst_id                 in com_api_type_pkg.t_inst_id
        , i_agent_id                in com_api_type_pkg.t_agent_id
        , i_action                  in com_api_type_pkg.t_dict_value
    ) is
        l_params                    com_api_type_pkg.t_param_tab;
        l_hsm_id                    com_api_type_pkg.t_number_tab;
        l_sql_source                com_api_type_pkg.t_full_desc;
        l_where_clause              com_api_type_pkg.t_full_desc;
        l_orderby                   com_api_type_pkg.t_full_desc := ' order by id';
        l_error                     com_api_type_pkg.t_full_desc;
    begin
        rul_api_param_pkg.set_param (
            i_name       => 'INST_ID'
            , i_value    => i_inst_id
            , io_params  => l_params
        );
        rul_api_param_pkg.set_param (
            i_name       => 'AGENT_ID'
            , i_value    => i_agent_id
            , io_params  => l_params
        );
        
        l_hsm_id := hsm_api_selection_pkg.select_all_hsm (
            i_inst_id   => i_inst_id
            , i_action  => i_action
            , i_params  => l_params
        );
        
        l_sql_source := 'select * from hsm_ui_device_vw';
        
        l_where_clause := ' where lang = com_ui_user_env_pkg.get_user_lang ';
        if l_hsm_id.count > 0 then
            l_where_clause := l_where_clause || 'and id in (';
            for i in 1 .. l_hsm_id.count loop
                l_where_clause := l_where_clause || l_hsm_id(i) || ', ';
            end loop;
            l_where_clause := rtrim(l_where_clause, ', ') || ')';
        else
            l_where_clause := l_where_clause || 'and 1=0';
        end if;
        l_where_clause := l_where_clause || ' and is_enabled = ' || com_api_type_pkg.TRUE;

        l_sql_source :=  l_sql_source || l_where_clause || l_orderby;

        trc_log_pkg.debug (
            i_text          => 'Going to execute query for HSM LOV: [#1]'
            , i_env_param1  => l_sql_source
        );

        begin
            open o_ref_cur for l_sql_source;
        exception
            when others then
                l_error := substr(sqlerrm, 1, 200);
                com_api_error_pkg.raise_error (
                    i_error         => 'EXEC_HSM_SELECT_QUERY_ERROR'
                    , i_env_param1  => substr(l_sql_source, 1, 2000)
                    , i_env_param2  => l_error
                );
        end;
    end;

end; 
/
