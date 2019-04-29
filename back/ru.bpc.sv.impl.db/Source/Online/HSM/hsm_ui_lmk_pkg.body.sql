create or replace package body hsm_ui_lmk_pkg is

    procedure check_unique (
        i_id                        in com_api_type_pkg.t_tiny_id
        , i_name                    in com_api_type_pkg.t_full_desc
    ) is
        l_count                     pls_integer;
    begin
        if i_name is not null then
            select
                count(1)
            into
                l_count
            from
                hsm_ui_lmk_vw
            where
                id != i_id
                and description = i_name;

            if l_count > 0 then
                com_api_error_pkg.raise_error (
                    i_error         =>  'DESCRIPTION_IS_NOT_UNIQUE'
                    , i_env_param1  => upper('hsm_lmk')
                    , i_env_param2  => upper('name')
                    , i_env_param3  => i_name
                );
            end if;
        end if;
    end;

    procedure add_hsm_lmk (
        o_id                        out com_api_type_pkg.t_tiny_id
        , o_seqnum                  out com_api_type_pkg.t_seqnum
        , i_check_value             in com_api_type_pkg.t_name
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_name                    in com_api_type_pkg.t_full_desc
    ) is
    begin
        o_id := hsm_lmk_seq.nextval;
        o_seqnum := 1;
            
        insert into hsm_lmk_vw (
            id
            , seqnum
            , check_value
        ) values (
            o_id
            , o_seqnum
            , i_check_value
        );
        
        check_unique (
            i_id         => o_id
            , i_name     => i_name
        );

        com_api_i18n_pkg.add_text(
            i_table_name   => 'hsm_lmk' 
          , i_column_name  => 'name' 
          , i_object_id    => o_id
          , i_lang         => i_lang
          , i_text         => i_name
        );
    end;

    procedure modify_hsm_lmk (
        i_id                        in com_api_type_pkg.t_tiny_id
        , io_seqnum                 in out com_api_type_pkg.t_seqnum
        , i_check_value             in com_api_type_pkg.t_name
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_name                    in com_api_type_pkg.t_full_desc
    ) is
    begin
        update
            hsm_lmk_vw
        set
            seqnum = io_seqnum
            , check_value = i_check_value
        where
            id = i_id;
            
        io_seqnum := io_seqnum + 1;

        check_unique (
            i_id         => i_id
            , i_name     => i_name
        );

        com_api_i18n_pkg.add_text(
            i_table_name            => 'hsm_lmk' 
          , i_column_name           => 'name' 
          , i_object_id             => i_id
          , i_lang                  => i_lang
          , i_text                  => i_name
        );
    end;

    procedure remove_hsm_lmk (
        i_id                        in com_api_type_pkg.t_tiny_id
        , i_seqnum                  in com_api_type_pkg.t_seqnum
    ) is
        l_check_cnt                 pls_integer;
    begin
        select
            count(*)
        into
            l_check_cnt
        from
            hsm_device_vw
        where
            lmk_id = i_id;
        
        if l_check_cnt > 0 then
            com_api_error_pkg.raise_error (
                i_error        => 'LMK_IS_ALREADY_IN_USE'
                , i_env_param1 => i_id 
            );
        end if;
 
        com_api_i18n_pkg.remove_text (
            i_table_name   => 'hsm_lmk'
            , i_object_id  => i_id
        );
          
        update
            hsm_lmk_vw
        set
            seqnum = i_seqnum
        where
            id = i_id;
            
        delete from
            hsm_lmk_vw
        where
            id = i_id;
            
        for rec in (
             select id, seqnum from sec_rsa_key where lmk_id = i_id
        ) loop
            sec_api_rsa_key_pkg.remove_rsa_key (
                i_key_id    => rec.id
                , i_seqnum  => rec.seqnum
            );
        end loop;
                    
    end;

end; 
/
