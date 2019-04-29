create or replace package body opr_ui_check_pkg is

    procedure add_check (
        o_id                        out com_api_type_pkg.t_tiny_id
        , o_seqnum                  out com_api_type_pkg.t_seqnum
        , i_check_group_id          in com_api_type_pkg.t_tiny_id
        , i_check_type              in com_api_type_pkg.t_dict_value
        , i_exec_order              in com_api_type_pkg.t_tiny_id
    ) is
    begin
        begin
            select id
              into o_id
              from opr_check_vw
             where check_group_id = i_check_group_id
               and check_type = i_check_type
               and exec_order = i_exec_order;

            com_api_error_pkg.raise_error (
                i_error         => 'OPR_CHECK_ALREADY_EXIST'
                , i_env_param1  => i_check_group_id
                , i_env_param2  => i_check_type
                , i_env_param3  => i_exec_order
            );
        exception
            when no_data_found then
                o_id := opr_check_seq.nextval;
                o_seqnum := 1;
                
                insert into opr_check_vw (
                    id
                    , seqnum
                    , check_group_id
                    , check_type
                    , exec_order
                ) values (
                    o_id
                    , o_seqnum
                    , i_check_group_id
                    , i_check_type
                    , i_exec_order
                );
        end;
    end;

    procedure modify_check (
        i_id                        in com_api_type_pkg.t_tiny_id
        , io_seqnum                 in out com_api_type_pkg.t_seqnum
        , i_check_group_id          in com_api_type_pkg.t_tiny_id
        , i_check_type              in com_api_type_pkg.t_dict_value
        , i_exec_order              in com_api_type_pkg.t_tiny_id
    ) is
        l_id                        com_api_type_pkg.t_tiny_id;
    begin
        begin
            select id
              into l_id
              from opr_check_vw
             where check_group_id = i_check_group_id
               and check_type = i_check_type
               and exec_order = i_exec_order
               and id != i_id;

            com_api_error_pkg.raise_error (
                i_error         => 'OPR_CHECK_ALREADY_EXIST'
                , i_env_param1  => i_check_group_id
                , i_env_param2  => i_check_type
                , i_env_param3  => i_exec_order
            );
        exception
            when no_data_found then
                update
                    opr_check_vw
                set
                    seqnum = io_seqnum
                    , check_group_id = i_check_group_id
                    , check_type = i_check_type
                    , exec_order = i_exec_order
                where
                    id = i_id;
                    
                io_seqnum := io_seqnum + 1;
        end;
    end;

    procedure remove_check (
        i_id                        in com_api_type_pkg.t_tiny_id
        , i_seqnum                  in com_api_type_pkg.t_seqnum
    ) is
    begin
        update
            opr_check_vw
        set
            seqnum = i_seqnum
        where
            id = i_id;

        delete from
            opr_check_vw
        where
            id = i_id;
    end;

    procedure add_check_group (
        o_id                        out com_api_type_pkg.t_tiny_id
        , o_seqnum                  out com_api_type_pkg.t_seqnum
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_name                    in com_api_type_pkg.t_name
        , i_description             in com_api_type_pkg.t_full_desc
    ) is
    begin
        o_id := opr_check_group_seq.nextval;
        o_seqnum := 1;
        
        insert into opr_check_group_vw (
            id
            , seqnum
        ) values (
            o_id
            , o_seqnum
        );
        
        com_api_i18n_pkg.add_text (
            i_table_name      => 'opr_check_group' 
            , i_column_name   => 'name' 
            , i_object_id     => o_id
            , i_lang          => i_lang
            , i_text          => i_name
            , i_check_unique  => com_api_type_pkg.TRUE
        );
        
        com_api_i18n_pkg.add_text (
            i_table_name     => 'opr_check_group' 
            , i_column_name  => 'description' 
            , i_object_id    => o_id
            , i_lang         => i_lang
            , i_text         => i_description
        );
    end;

    procedure modify_check_group (
        i_id                        in com_api_type_pkg.t_tiny_id
        , io_seqnum                 in out com_api_type_pkg.t_seqnum
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_name                    in com_api_type_pkg.t_name
        , i_description             in com_api_type_pkg.t_full_desc
    ) is
    begin
        update
            opr_check_group_vw
        set
            seqnum = io_seqnum
        where
            id = i_id;
            
        io_seqnum := io_seqnum + 1;
        
        com_api_i18n_pkg.add_text (
            i_table_name      => 'opr_check_group' 
            , i_column_name   => 'name' 
            , i_object_id     => i_id
            , i_lang          => i_lang
            , i_text          => i_name
            , i_check_unique  => com_api_type_pkg.TRUE
        );
        
        com_api_i18n_pkg.add_text (
            i_table_name     => 'opr_check_group' 
            , i_column_name  => 'description' 
            , i_object_id    => i_id
            , i_lang         => i_lang
            , i_text         => i_description
        );
    end;

    procedure remove_check_group (
        i_id                        in com_api_type_pkg.t_tiny_id
        , i_seqnum                  in com_api_type_pkg.t_seqnum
    ) is
        l_check_cnt                 number;
    begin
        select
            count(*)
        into
            l_check_cnt
        from (        select check_group_id from opr_check_vw
            union all select check_group_id from opr_check_selection_vw
        )
        where
            check_group_id = i_id;

        if l_check_cnt > 0 then
            com_api_error_pkg.raise_error (
                i_error         => 'OPR_CHECK_GROUP_ALREADY_USED'
                , i_env_param1  => i_id
            );
        end if;
        
        update
            opr_check_group_vw
        set
            seqnum = i_seqnum
        where
            id = i_id;

        delete from
            opr_check_group_vw
        where
            id = i_id;
            
        com_api_i18n_pkg.remove_text (
            i_table_name   => 'opr_check_group' 
            , i_object_id  => i_id
        );
    end;
    
    procedure add_check_selection (
        o_id                        out com_api_type_pkg.t_tiny_id
        , o_seqnum                  out com_api_type_pkg.t_seqnum
        , i_oper_type               in com_api_type_pkg.t_dict_value
        , i_msg_type                in com_api_type_pkg.t_dict_value
        , i_party_type              in com_api_type_pkg.t_dict_value
        , i_inst_id                 in com_api_type_pkg.t_dict_value
        , i_network_id              in com_api_type_pkg.t_dict_value
        , i_check_group_id          in com_api_type_pkg.t_tiny_id
        , i_exec_order              in com_api_type_pkg.t_tiny_id
    ) is
    begin
        o_id := opr_check_selection_seq.nextval;
        o_seqnum := 1;
        
        insert into opr_check_selection_vw (
            id
            , seqnum
            , oper_type
            , msg_type
            , party_type
            , inst_id
            , network_id
            , check_group_id
            , exec_order
        ) values (
            o_id
            , o_seqnum
            , i_oper_type
            , i_msg_type
            , i_party_type
            , i_inst_id
            , i_network_id
            , i_check_group_id
            , i_exec_order
        );
    end;

    procedure modify_check_selection (
        i_id                        in com_api_type_pkg.t_tiny_id
        , io_seqnum                 in out com_api_type_pkg.t_seqnum
        , i_oper_type               in com_api_type_pkg.t_dict_value
        , i_msg_type                in com_api_type_pkg.t_dict_value
        , i_party_type              in com_api_type_pkg.t_dict_value
        , i_inst_id                 in com_api_type_pkg.t_dict_value
        , i_network_id              in com_api_type_pkg.t_dict_value
        , i_check_group_id          in com_api_type_pkg.t_tiny_id
        , i_exec_order              in com_api_type_pkg.t_tiny_id
    ) is
    begin
        update
            opr_check_selection_vw
        set
            seqnum = io_seqnum
            , oper_type = i_oper_type
            , msg_type = i_msg_type
            , party_type = i_party_type
            , inst_id = i_inst_id
            , network_id = i_network_id
            , check_group_id = i_check_group_id
            , exec_order = i_exec_order
        where
            id = i_id;
            
        io_seqnum := io_seqnum + 1;
    end;

    procedure remove_check_selection (
        i_id                        in com_api_type_pkg.t_tiny_id
        , i_seqnum                  in com_api_type_pkg.t_seqnum
    ) is
    begin
        update
            opr_check_selection_vw
        set
            seqnum = i_seqnum
        where
            id = i_id;

        delete from
            opr_check_selection_vw
        where
            id = i_id;
    end;

end;
/
