create or replace package body emv_ui_appl_scheme_pkg is
/************************************************************
 * User interface for scheme of EMV card applications <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 04.10.2011 <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: emv_ui_appl_scheme_pkg <br />
 * @headcom
 ************************************************************/

    procedure check_unique (
        i_id                        in com_api_type_pkg.t_tiny_id
        , i_inst_id                 in com_api_type_pkg.t_inst_id
        , i_name                    in com_api_type_pkg.t_name
    ) is
        l_count                     pls_integer;
    begin
        if i_name is not null then
            select
                count(1)
            into
                l_count
            from
                emv_ui_appl_scheme_vw
            where
                id != i_id
                and inst_id = i_inst_id
                and name = i_name;

            if l_count > 0 then
                com_api_error_pkg.raise_error (
                    i_error         =>  'DESCRIPTION_IS_NOT_UNIQUE'
                    , i_env_param1  => upper('emv_appl_scheme')
                    , i_env_param2  => upper('name')
                    , i_env_param3  => i_name
                );
            end if;
        end if;
    end;
    
    procedure add_appl_scheme (
        o_id                        out com_api_type_pkg.t_tiny_id
        , o_seqnum                  out com_api_type_pkg.t_seqnum
        , i_inst_id                 in com_api_type_pkg.t_inst_id
        , i_type                    in com_api_type_pkg.t_dict_value
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_name                    in com_api_type_pkg.t_name
        , i_description             in com_api_type_pkg.t_full_desc
    ) is
    begin
        o_id := emv_appl_scheme_seq.nextval;
        o_seqnum := 1;

        insert into emv_appl_scheme_vw (
            id
            , seqnum
            , inst_id
            , type
        ) values (
            o_id
            , o_seqnum
            , i_inst_id
            , i_type
        );

        check_unique (
            i_id         => o_id
            , i_inst_id  => i_inst_id
            , i_name     => i_name
        );

        com_api_i18n_pkg.add_text (
            i_table_name     => 'emv_appl_scheme'
            , i_column_name  => 'name'
            , i_object_id    => o_id
            , i_lang         => i_lang
            , i_text         => i_name
        );

        com_api_i18n_pkg.add_text (
            i_table_name     => 'emv_appl_scheme'
            , i_column_name  => 'description'
            , i_object_id    => o_id
            , i_lang         => i_lang
            , i_text         => i_description
        );

    end;

    procedure modify_appl_scheme (
        i_id                        in com_api_type_pkg.t_tiny_id
        , io_seqnum                 in out com_api_type_pkg.t_seqnum
        , i_inst_id                 in com_api_type_pkg.t_inst_id
        , i_type                    in com_api_type_pkg.t_dict_value
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_name                    in com_api_type_pkg.t_name
        , i_description             in com_api_type_pkg.t_full_desc
    ) is
    begin
        update
            emv_appl_scheme_vw
        set
            seqnum = io_seqnum
            , type = i_type
        where
            id = i_id;

        io_seqnum := io_seqnum + 1;

        check_unique (
            i_id         => i_id
            , i_inst_id  => i_inst_id
            , i_name     => i_name
        );

        com_api_i18n_pkg.add_text (
            i_table_name     => 'emv_appl_scheme'
            , i_column_name  => 'name'
            , i_object_id    => i_id
            , i_lang         => i_lang
            , i_text         => i_name
        );

        com_api_i18n_pkg.add_text (
            i_table_name     => 'emv_appl_scheme'
            , i_column_name  => 'description'
            , i_object_id    => i_id
            , i_lang         => i_lang
            , i_text         => i_description
        );

    end;

    procedure remove_appl_scheme (
        i_id                        in com_api_type_pkg.t_tiny_id
        , i_seqnum                  in com_api_type_pkg.t_seqnum
    ) is
        l_check_cnt                 number;
    begin
        select
            count(*)
        into
            l_check_cnt
        from
            iss_product_card_type_vw
        where
            emv_appl_scheme_id = i_id;

        if l_check_cnt > 0 then
            com_api_error_pkg.raise_error (
                i_error  => 'EMV_APPL_SCHEME_ALREADY_USED'
            );
        end if;
        
        -- delete tag value
        delete from
            emv_tag_value_vw
        where
            entity_type = emv_api_const_pkg.ENTITY_TYPE_EMV_SCHEME
            and object_id = i_id;
        
        -- delete depend record, etc. appl, block, var, element
        for r in (
            select
                id
            from
                emv_application_vw
            where
                appl_scheme_id = i_id
        ) loop
            -- delete depend variable elements
            delete from
                emv_element_vw
            where
                entity_type = emv_api_const_pkg.ENTITY_TYPE_EMV_VAR
                and object_id in (
                    select
                        id
                    from
                        emv_variable_vw
                    where
                        application_id = r.id
                );
            
            -- delete depend variable
            for r2 in (
                select
                    id
                from
                    emv_variable
                where
                    application_id = r.id
            ) loop
                -- remove text
                com_api_i18n_pkg.remove_text (
                    i_table_name   => 'emv_variable'
                    , i_object_id  => r2.id
                );
                
                delete from
                    emv_variable_vw
                where
                    id = r2.id;
            end loop;
                
            -- delete depend block elements
            delete from
                emv_element_vw
            where
                entity_type = emv_api_const_pkg.ENTITY_TYPE_EMV_BLOCK
                and object_id in (
                    select
                        id
                    from
                        emv_block_vw
                    where
                        application_id = r.id
                );
            
            -- delete depend block
            delete from
                emv_block_vw
            where
                application_id = r.id;
                
            -- remove text
            com_api_i18n_pkg.remove_text (
                i_table_name   => 'emv_application'
                , i_object_id  => r.id
            );

            -- delete element
            delete from
                emv_application_vw
            where
                id = r.id;
        end loop;
        
        -- remove text
        com_api_i18n_pkg.remove_text (
            i_table_name   => 'emv_appl_scheme'
            , i_object_id  => i_id
        );

        update
            emv_appl_scheme_vw
        set
            seqnum = i_seqnum
        where
            id = i_id;

        -- delete scheme
        delete from
            emv_appl_scheme_vw
        where
            id = i_id;

    end;

end;
/
