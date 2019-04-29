create or replace package body ntf_ui_notification_pkg is

    procedure add_notification (
        o_id                        out com_api_type_pkg.t_tiny_id
        , o_seqnum                  out com_api_type_pkg.t_seqnum
        , i_event_type              in com_api_type_pkg.t_dict_value
        , i_report_id               in com_api_type_pkg.t_short_id
        , i_inst_id                 in com_api_type_pkg.t_inst_id
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_name                    in com_api_type_pkg.t_name
        , i_description             in com_api_type_pkg.t_full_desc
    ) is
        l_count                     pls_integer;
    begin
        o_id := ntf_notification_seq.nextval;
        o_seqnum := 1;
        
        insert into ntf_notification_vw (
            id
            , seqnum
            , event_type
            , report_id
            , inst_id
        ) values (
            o_id
            , o_seqnum
            , i_event_type
            , i_report_id
            , i_inst_id
        );
        
        if i_name is not null then

            select count(1)
              into l_count
              from ntf_ui_notification_vw
             where id     != o_id
               and inst_id = i_inst_id
               and name    = i_name;

            if l_count > 0 then
                com_api_error_pkg.raise_error(
                   i_error       =>  'DESCRIPTION_IS_NOT_UNIQUE'
                 , i_env_param1  => upper('ntf_notification')
                 , i_env_param2  => upper('name')
                 , i_env_param3  => i_name
                );
            end if;

            com_api_i18n_pkg.add_text(
                i_table_name    => 'ntf_notification'
              , i_column_name   => 'name'
              , i_object_id     => o_id
              , i_lang          => i_lang
              , i_text          => i_name
            );
        end if;

        com_api_i18n_pkg.add_text(
            i_table_name            => 'ntf_notification' 
          , i_column_name           => 'description' 
          , i_object_id             => o_id
          , i_lang                  => i_lang
          , i_text                  => i_description
        );
    end;

    procedure modify_notification (
        i_id                        in com_api_type_pkg.t_tiny_id
        , io_seqnum                 in out com_api_type_pkg.t_seqnum
        , i_report_id               in com_api_type_pkg.t_short_id
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_name                    in com_api_type_pkg.t_name
        , i_description             in com_api_type_pkg.t_full_desc
    ) is
        l_count                     pls_integer;
    begin
        update
            ntf_notification_vw
        set
            seqnum = io_seqnum
            , report_id = i_report_id
        where
            id = i_id;
            
        io_seqnum := io_seqnum + 1;
        
        if i_name is not null then

            select count(1)
              into l_count
              from ntf_ui_notification_vw a
                 , ntf_notification_vw b
             where a.id     != i_id
               and b.id      = i_id
               and a.inst_id = b.inst_id
               and a.name    = i_name;

            if l_count > 0 then
                com_api_error_pkg.raise_error(
                   i_error       =>  'DESCRIPTION_IS_NOT_UNIQUE'
                 , i_env_param1  => upper('ntf_notification')
                 , i_env_param2  => upper('name')
                 , i_env_param3  => i_name
                );
            end if;

            com_api_i18n_pkg.add_text(
                i_table_name    => 'ntf_notification'
              , i_column_name   => 'name'
              , i_object_id     => i_id
              , i_lang          => i_lang
              , i_text          => i_name
            );
        end if;

        com_api_i18n_pkg.add_text(
            i_table_name            => 'ntf_notification' 
          , i_column_name           => 'description' 
          , i_object_id             => i_id
          , i_lang                  => i_lang
          , i_text                  => i_description
        );
    end;

    procedure remove_notification (
        i_id                        in com_api_type_pkg.t_tiny_id
        , i_seqnum                  in com_api_type_pkg.t_seqnum
    ) is
        l_check_cnt             number;
    begin
        select 
            count(*)
        into
            l_check_cnt 
        from
            ntf_scheme_event
        where 
            notif_id = i_id; 
            
        if l_check_cnt > 0 then
            com_api_error_pkg.raise_error(
                  i_error           => 'NOTIFICATION_INCLUDED_IN_SCHEME'
                , i_env_param1      => i_id 
            );
        else
            delete from
                ntf_template_vw
            where
                notif_id = i_id;

            com_api_i18n_pkg.remove_text(
                i_table_name            => 'ntf_notification' 
              , i_object_id             => i_id
            );
            
            update
                ntf_notification_vw
            set
                seqnum = i_seqnum
            where
                id = i_id;
            
            delete from
                ntf_notification_vw
            where
                id = i_id;
        end if;
    end;

end; 
/
