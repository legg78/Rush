create or replace package body emv_ui_application_pkg is
/************************************************************
 * User interface for EMV card application <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 02.09.2011 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: emv_ui_application_pkg <br />
 * @headcom
 ************************************************************/

    procedure check_unique (
        i_id                        in com_api_type_pkg.t_tiny_id
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
                emv_ui_application_vw
            where
                id != i_id
                and name = i_name;

            if l_count > 0 then
                com_api_error_pkg.raise_error (
                    i_error         =>  'DESCRIPTION_IS_NOT_UNIQUE'
                    , i_env_param1  => upper('emv_application')
                    , i_env_param2  => upper('name')
                    , i_env_param3  => i_name
                );
            end if;
        end if;
    end;

    procedure add_application (
        o_id                        out com_api_type_pkg.t_short_id
        , o_seqnum                  out com_api_type_pkg.t_seqnum
        , i_aid                     in com_api_type_pkg.t_name
        , i_id_owner                in sec_api_type_pkg.t_subject_id
        , i_pix                     in com_api_type_pkg.t_name
        , i_appl_scheme_id          in com_api_type_pkg.t_tiny_id
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_name                    in com_api_type_pkg.t_name
        , i_mod_id                  in com_api_type_pkg.t_tiny_id
    ) is
    begin
        check_unique (
            i_id         => o_id
            , i_name     => i_name
        );

        o_id := emv_application_seq.nextval;
        o_seqnum := 1;
        
        insert into emv_application_vw (
            id
            , seqnum
            , aid
            , id_owner
            , appl_scheme_id
            , pix
            , mod_id
       ) values (
            o_id
            , o_seqnum
            , i_aid
            , i_id_owner
            , i_appl_scheme_id
            , i_pix
            , i_mod_id
        );
        
        com_api_i18n_pkg.add_text(
            i_table_name            => 'emv_application'
          , i_column_name           => 'name'
          , i_object_id             => o_id
          , i_lang                  => i_lang
          , i_text                  => i_name
        );
        
    end;

    procedure modify_application (
        i_id                        in com_api_type_pkg.t_short_id
        , io_seqnum                 in out com_api_type_pkg.t_seqnum
        , i_aid                     in com_api_type_pkg.t_name
        , i_id_owner                in sec_api_type_pkg.t_subject_id
        , i_pix                     in com_api_type_pkg.t_name
        , i_appl_scheme_id          in com_api_type_pkg.t_tiny_id
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_name                    in com_api_type_pkg.t_name
        , i_mod_id                  in com_api_type_pkg.t_tiny_id
    ) is
    begin
        check_unique (
            i_id         => i_id
            , i_name     => i_name
        );
      
        update
            emv_application_vw
        set
            seqnum = io_seqnum
            , aid = i_aid
            , id_owner = i_id_owner
            , appl_scheme_id = i_appl_scheme_id
            , pix = i_pix
            , mod_id = i_mod_id
        where
            id = i_id;
        
        io_seqnum := io_seqnum + 1;
        
        com_api_i18n_pkg.add_text(
            i_table_name            => 'emv_application'
          , i_column_name           => 'name'
          , i_object_id             => i_id
          , i_lang                  => i_lang
          , i_text                  => i_name
        );
    end;

    procedure remove_application (
        i_id                        in com_api_type_pkg.t_short_id
        , i_seqnum                  in com_api_type_pkg.t_seqnum
    ) is
    begin
        -- delete depend record, etc. block, var, element
        
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
                    application_id = i_id
            );
            
        -- delete depend variable
        for r in (
            select
                id
            from
                emv_variable
            where
                application_id = i_id
        ) loop
            -- remove text
            com_api_i18n_pkg.remove_text (
                i_table_name   => 'emv_variable'
                , i_object_id  => r.id
            );
                
            delete from
                emv_variable_vw
            where
                id = r.id;
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
                    application_id = i_id
            );
        
        -- delete depend block
        delete from
            emv_block_vw
        where
            application_id = i_id;
            
        -- remove text
        com_api_i18n_pkg.remove_text (
            i_table_name   => 'emv_application'
            , i_object_id  => i_id
        );
        
        update
            emv_application_vw
        set
            seqnum = i_seqnum
        where
            id = i_id;
            
        -- delete element
        delete from
            emv_application_vw
        where
            id = i_id;
    
    end;

end;
/
