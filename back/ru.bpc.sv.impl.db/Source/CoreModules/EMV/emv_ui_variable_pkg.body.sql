create or replace package body emv_ui_variable_pkg is
/************************************************************
 * User interface for EMV data variables <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 20.09.2011 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: emv_ui_variable_pkg <br />
 * @headcom
 ************************************************************/

    procedure add_variable (
        o_id                        out com_api_type_pkg.t_short_id
        , o_seqnum                  out com_api_type_pkg.t_seqnum
        , i_application_id          in com_api_type_pkg.t_short_id
        , i_variable_type           in com_api_type_pkg.t_dict_value
        , i_profile                 in com_api_type_pkg.t_dict_value
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_name                    in com_api_type_pkg.t_name
    ) is
    begin
        o_id := emv_variable_seq.nextval;
        o_seqnum := 1;

        insert into emv_variable_vw (
            id
            , seqnum
            , application_id
            , variable_type
            , profile
        ) values (
            o_id
            , o_seqnum
            , i_application_id
            , i_variable_type
            , i_profile
        );
        
        com_api_i18n_pkg.add_text (
            i_table_name      => 'emv_variable'
            , i_column_name   => 'name'
            , i_object_id     => o_id
            , i_lang          => i_lang
            , i_text          => i_name
        );

    end;

    procedure modify_variable (
        i_id                        in com_api_type_pkg.t_short_id
        , io_seqnum                 in out com_api_type_pkg.t_seqnum
        , i_application_id          in com_api_type_pkg.t_short_id
        , i_variable_type           in com_api_type_pkg.t_dict_value
        , i_profile                 in com_api_type_pkg.t_dict_value
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_name                    in com_api_type_pkg.t_name
    ) is
    begin
        update
            emv_variable_vw
        set
            seqnum = io_seqnum
            , variable_type = i_variable_type
            , profile = i_profile
        where
            id = i_id;

        io_seqnum := io_seqnum + 1;
        
        com_api_i18n_pkg.add_text (
            i_table_name      => 'emv_variable'
            , i_column_name   => 'name'
            , i_object_id     => i_id
            , i_lang          => i_lang
            , i_text          => i_name
        );
        
    end;

    procedure remove_variable (
        i_id                        in com_api_type_pkg.t_short_id
        , i_seqnum                  in com_api_type_pkg.t_seqnum
    ) is
        l_count                     pls_integer;
    begin
        select 
            count(*)
        into
            l_count 
        from (
            select
                1
            from
                emv_block_vw t
            where
                t.transport_key_id = i_id
            union all
            select
                1
            from
                emv_block_vw t
            where
                t.encryption_id = i_id
        );

        if l_count > 0 then
            com_api_error_pkg.raise_error (
                i_error  =>  'EMV_VARIABLE_ALREADY_USED'
            );
        end if;
        
        -- delete depend elements
        delete from
            emv_element_vw
        where
            entity_type = emv_api_const_pkg.ENTITY_TYPE_EMV_VAR
            and object_id = i_id;

        -- remove text
        com_api_i18n_pkg.remove_text (
            i_table_name   => 'emv_variable'
            , i_object_id  => i_id
        );
        
        update
            emv_variable_vw
        set
            seqnum = i_seqnum
        where
            id = i_id;

        -- delete block
        delete from
            emv_variable_vw
        where
            id = i_id;

    end;

end;
/
