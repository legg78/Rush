create or replace package body hsm_ui_device_pkg is

    procedure add_hsm_device (
        o_id                        out com_api_type_pkg.t_tiny_id
        , o_seqnum                  out com_api_type_pkg.t_seqnum
        , i_is_enabled              in com_api_type_pkg.t_boolean
        , i_comm_protocol           in com_api_type_pkg.t_dict_value
        , i_plugin                  in com_api_type_pkg.t_dict_value
        , i_manufacturer            in com_api_type_pkg.t_dict_value
        , i_serial_number           in com_api_type_pkg.t_name
        , i_lang                    in com_api_type_pkg.t_dict_value default null
        , i_description             in com_api_type_pkg.t_full_desc default null
        , i_lmk_id                  in com_api_type_pkg.t_tiny_id
        , i_model_number            in com_api_type_pkg.t_dict_value
    ) is
    begin
        o_id := hsm_device_seq.nextval;
        o_seqnum := 1;
        
        insert into hsm_device_vw (
            id
            , is_enabled
            , comm_protocol
            , plugin
            , manufacturer
            , serial_number
            , seqnum
            , lmk_id
            , model_number
        ) values (
            o_id
            , i_is_enabled
            , i_comm_protocol
            , i_plugin
            , i_manufacturer
            , i_serial_number
            , o_seqnum
            , i_lmk_id
            , i_model_number
        );

        com_api_i18n_pkg.add_text (
            i_table_name     => 'hsm_device'
            , i_column_name  => 'description'
            , i_object_id    => o_id
            , i_lang         => i_lang
            , i_text         => i_description
            , i_check_unique => com_api_type_pkg.TRUE
        );
    end;

    procedure modify_hsm_device (
        i_id                        in com_api_type_pkg.t_tiny_id
        , io_seqnum                 in out com_api_type_pkg.t_seqnum
        , i_is_enabled              in com_api_type_pkg.t_boolean
        , i_comm_protocol           in com_api_type_pkg.t_dict_value
        , i_plugin                  in com_api_type_pkg.t_dict_value
        , i_manufacturer            in com_api_type_pkg.t_dict_value
        , i_serial_number           in com_api_type_pkg.t_name
        , i_lang                    in com_api_type_pkg.t_dict_value default null
        , i_description             in com_api_type_pkg.t_full_desc default null
        , i_lmk_id                  in com_api_type_pkg.t_tiny_id
        , i_model_number            in com_api_type_pkg.t_dict_value
    ) is
        l_count_selection           com_api_type_pkg.t_tiny_id;
        l_connect_status            com_api_type_pkg.t_name := hsm_api_const_pkg.HSM_CONN_STATUS_ACTIVE;
    begin
        for device in (
            select
                is_enabled
            from
                hsm_device_vw
            where
                id = i_id
                and is_enabled != i_is_enabled
        ) loop
            -- init hsm
            if i_is_enabled = com_api_const_pkg.TRUE then
                select
                    count(id)
                into
                    l_count_selection
                from
                    hsm_selection
                where
                    hsm_device_id = i_id;
                
                if l_count_selection > 0 then
                    hsm_api_device_pkg.init_hsm_devices (
                        i_hsm_device_id    => i_id
                        , o_connect_status => l_connect_status
                    );
                else
                    com_api_error_pkg.raise_error (
                        i_error         => 'HSM_SELECTION_NOT_DEFINED'
                        , i_env_param1  => i_id
                    );
                end if;
            else
                -- deinit hsm
                hsm_api_device_pkg.deinit_hsm_devices (
                    i_hsm_device_id  => i_id
                );
            end if;
        end loop;
        
        if i_is_enabled = com_api_const_pkg.TRUE and l_connect_status != hsm_api_const_pkg.HSM_CONN_STATUS_ACTIVE then
            update
                hsm_device_vw
            set
                is_enabled = is_enabled
                , comm_protocol = i_comm_protocol
                , plugin = i_plugin
                , seqnum = io_seqnum
                , manufacturer = i_manufacturer
                , serial_number = i_serial_number
                , lmk_id = i_lmk_id
                , model_number = i_model_number
            where
                id = i_id;
        else
            update
                hsm_device_vw
            set
                is_enabled = i_is_enabled
                , comm_protocol = i_comm_protocol
                , plugin = i_plugin
                , seqnum = io_seqnum
                , manufacturer = i_manufacturer
                , serial_number = i_serial_number
                , lmk_id = i_lmk_id
                , model_number = i_model_number
            where
                id = i_id;
        end if;
            
        io_seqnum := io_seqnum + 1;

        -- TODO: check here other types( UDP )

        com_api_i18n_pkg.add_text (
            i_table_name     => 'hsm_device'
            , i_column_name  => 'description'
            , i_object_id    => i_id
            , i_lang         => i_lang
            , i_text         => i_description
            , i_check_unique => com_api_type_pkg.TRUE
        );
    end;

    procedure remove_hsm_device (
        i_id                        in com_api_type_pkg.t_tiny_id
        , i_seqnum                  in com_api_type_pkg.t_seqnum
    ) is
        l_is_enabled                com_api_type_pkg.t_boolean;
    begin
        select
            is_enabled
        into
            l_is_enabled
        from
            hsm_device_vw
        where
            id = i_id;
        
        if l_is_enabled = com_api_const_pkg.TRUE then
            com_api_error_pkg.raise_error (
                i_error         => 'CANNOT_REMOVE_ENABLED_HSM'
                , i_env_param1  => i_id
            );
        end if;

        -- clear device dynamic status
        hsm_api_connection_pkg.remove_connection (
           i_hsm_device_id  => i_id
        );

        update
            hsm_device_vw
        set
            seqnum = i_seqnum
        where
            id = i_id;

        delete from
            hsm_device_vw
        where
            id = i_id;

        delete from
            hsm_tcp_ip_vw
        where
            id = i_id;

        for rec in (
             select id, seqnum from hsm_selection_vw where hsm_device_id = i_id
        ) loop
            hsm_ui_selection_pkg.remove_hsm_selection(rec.id, rec.seqnum);
        end loop;

        -- TODO: delete here other types( UDP )

        com_api_i18n_pkg.remove_text (
            i_table_name   => 'hsm_device'
            , i_object_id  => i_id
        );
    end;

    procedure add_hsm_tcp_ip (
        i_hsm_device_id             in com_api_type_pkg.t_tiny_id
        , i_address                 in com_api_type_pkg.t_name
        , i_port                    in com_api_type_pkg.t_name
        , i_max_connection          in com_api_type_pkg.t_tiny_id
    ) is
    begin
        insert into hsm_tcp_ip_vw (
            id
            , address
            , port
            , max_connection
        )
        values (
            i_hsm_device_id
            , i_address
            , i_port
            , i_max_connection
        );
    end;

    procedure modify_hsm_tcp_ip (
        i_hsm_device_id             in com_api_type_pkg.t_tiny_id
        , i_address                 in com_api_type_pkg.t_name
        , i_port                    in com_api_type_pkg.t_name
        , i_max_connection          in com_api_type_pkg.t_tiny_id
    ) is
        l_is_enabled                com_api_type_pkg.t_boolean;
        l_max_connection            com_api_type_pkg.t_tiny_id;
    begin
        select
            is_enabled
        into
            l_is_enabled
        from
            hsm_device_vw
        where
            id = i_hsm_device_id;
    
        if l_is_enabled = com_api_const_pkg.TRUE then
            com_api_error_pkg.raise_error (
                i_error         => 'CANNOT_MODIFY_ENABLED_HSM'
                , i_env_param1  => i_hsm_device_id
            );
        end if;

        select
            nvl(sum(max_connection), 0)
        into
            l_max_connection
        from
            hsm_selection_vw
        where
            hsm_device_id = i_hsm_device_id;

        if i_max_connection < l_max_connection then
            com_api_error_pkg.raise_error (
                i_error         => 'CANNOT_MODIFY_HSM_WITH_SELECTION'
                , i_env_param1  => i_hsm_device_id
            );
        end if;
         
        delete from
            hsm_connection_vw
        where
            hsm_device_id = i_hsm_device_id;

        update
            hsm_tcp_ip_vw
        set
            address = i_address
            , port = i_port
            , max_connection = i_max_connection
        where
            id = i_hsm_device_id;
    end;

    procedure remove_hsm_tcp_ip (
        i_hsm_device_id             in com_api_type_pkg.t_tiny_id
    ) is
    begin
        delete from
            hsm_connection_vw
        where
            hsm_device_id = i_hsm_device_id;

        delete from
            hsm_tcp_ip_vw
        where
            id = i_hsm_device_id;

        update
            hsm_device_vw
        set
            is_enabled = com_api_type_pkg.FALSE
        where
            id = i_hsm_device_id;
    end;

    procedure check_lmk (
        i_hsm_device_id             in com_api_type_pkg.t_tiny_id
        , o_responce_msg            out com_api_type_pkg.t_text
    ) is
        l_result                    com_api_type_pkg.t_tiny_id;
        l_resp_message              com_api_type_pkg.t_name;
        l_hsm_device                hsm_api_type_pkg.t_hsm_device_rec;
        l_responce_check            com_api_type_pkg.t_dict_value;
    begin
        -- get hsm
        l_hsm_device := hsm_api_device_pkg.get_hsm_device (
            i_hsm_device_id  => i_hsm_device_id
        );
            
        if hsm_api_device_pkg.g_use_hsm = com_api_type_pkg.TRUE then
            l_result := hsm_api_hsm_pkg.perform_diagnostics (
                i_hsm_ip        => l_hsm_device.address
                , i_hsm_port    => l_hsm_device.port
                , i_lmk_id      => l_hsm_device.lmk_id
                , i_lmk_value   => l_hsm_device.lmk_value
                , o_resp_check  => l_responce_check
                , o_resp_mess   => l_resp_message
            );
            if l_result < hsm_api_const_pkg.RESULT_CODE_OK then
                com_api_error_pkg.raise_error (
                    i_error         => 'ERROR_HSM_PERFORM_DIAGNOSTICS'
                    , i_env_param1  => l_resp_message
                );
            end if;
            
            o_responce_msg := com_api_dictionary_pkg.get_article_desc (
                i_article  => l_responce_check
            );
        else
            o_responce_msg := com_api_dictionary_pkg.get_article_desc (
                i_article  => 'HSMR0010'
            );
        end if;
    end;

end;
/
