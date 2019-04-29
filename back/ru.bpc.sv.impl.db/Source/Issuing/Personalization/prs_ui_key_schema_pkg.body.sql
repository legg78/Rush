create or replace package body prs_ui_key_schema_pkg is
/************************************************************
 * User interface for personalization schema of keys <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 03.08.2010 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: prs_ui_key_schema_pkg <br />
 * @headcom
 ************************************************************/

    procedure add (
        o_id                        out com_api_type_pkg.t_tiny_id
        , o_seqnum                  out com_api_type_pkg.t_seqnum
        , i_inst_id                 in com_api_type_pkg.t_inst_id
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_name                    in com_api_type_pkg.t_name
        , i_description             in com_api_type_pkg.t_full_desc
    ) is
        l_count                     pls_integer;
    begin
        o_id := prs_key_schema_seq.nextval;
        o_seqnum := 1;
            
        insert into prs_key_schema_vw (
            id
            , inst_id
            , seqnum
        ) values (
            o_id
            , i_inst_id
            , o_seqnum
        );

        if i_name is not null then
            select
                count(1)
            into
                l_count 
            from
                prs_ui_key_schema_vw
            where
                id != o_id
                and inst_id = i_inst_id
                and name = i_name;

            if l_count > 0 then 
                com_api_error_pkg.raise_error (
                    i_error         =>  'DESCRIPTION_IS_NOT_UNIQUE'
                    , i_env_param1  => upper('prs_key_schema')
                    , i_env_param2  => upper('name')
                    , i_env_param3  => i_name
                );
            end if;
        
            com_api_i18n_pkg.add_text (
                i_table_name      => 'prs_key_schema'
                , i_column_name   => 'name'
                , i_object_id     => o_id
                , i_lang          => i_lang
                , i_text          => i_name
            );
        end if;
        
        com_api_i18n_pkg.add_text (
            i_table_name     => 'prs_key_schema'
            , i_column_name  => 'description'
            , i_object_id    => o_id
            , i_lang         => i_lang
            , i_text         => i_description
        );
    end;

    procedure modify (
        i_id                        in com_api_type_pkg.t_tiny_id
        , io_seqnum                 in out com_api_type_pkg.t_seqnum
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_name                    in com_api_type_pkg.t_name
        , i_description             in com_api_type_pkg.t_full_desc
    ) is
    begin
        update
            prs_key_schema_vw
        set
            seqnum = io_seqnum
        where
            id = i_id;
            
        io_seqnum := io_seqnum + 1;

        com_api_i18n_pkg.add_text (
            i_table_name      => 'prs_key_schema'
            , i_column_name   => 'name'
            , i_object_id     => i_id
            , i_lang          => i_lang
            , i_text          => i_name
            , i_check_unique  => com_api_type_pkg.TRUE
        );

        com_api_i18n_pkg.add_text (
            i_table_name     => 'prs_key_schema'
            , i_column_name  => 'description'
            , i_object_id    => i_id
            , i_lang         => i_lang
            , i_text         => i_description
        );
    end;

    procedure remove (
        i_id                        in com_api_type_pkg.t_tiny_id
        , i_seqnum                  in com_api_type_pkg.t_seqnum
    ) is
        l_check_cnt                number;
    begin
        select
            count(*)
        into
            l_check_cnt
        from
            prs_method_vw
        where
            key_schema_id = i_id;

        if l_check_cnt > 0 then
            com_api_error_pkg.raise_error (
                i_error        => 'SCHEMA_OF_KEYS_ALREADY_USED'
                , i_env_param1 => i_id
            );
        else
            -- delete key schema entity
            delete from
                prs_key_schema_entity_vw
            where
                key_schema_id = i_id;
            
            -- delete key schema
            com_api_i18n_pkg.remove_text (
                i_table_name  => 'prs_key_schema'
               , i_object_id  => i_id
            );
          
            update
                prs_key_schema_vw
            set
                seqnum = i_seqnum
            where
                id = i_id;
                
            delete from
                prs_key_schema_vw
            where
                id = i_id;
        end if;
    end;

end; 
/
