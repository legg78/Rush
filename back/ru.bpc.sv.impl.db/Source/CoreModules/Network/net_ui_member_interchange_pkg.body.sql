create or replace package body net_ui_member_interchange_pkg is
/************************************************************
 * User interface for NET member interchange <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 06.03.2013 <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: net_ui_member_interchange_pkg <br />
 * @headcom
 ************************************************************/

    procedure add_member_interchange (
        o_id                        out com_api_type_pkg.t_tiny_id
        , o_seqnum                  out com_api_type_pkg.t_seqnum
        , i_mod_id                  in com_api_type_pkg.t_tiny_id
        , i_value                   in com_api_type_pkg.t_byte_char
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_name                    in com_api_type_pkg.t_name
    ) is
    begin
        o_id := net_member_interchange_seq.nextval;
        o_seqnum := 1;
        
        insert into net_member_interchange_vw (
            id
            , seqnum
            , mod_id
            , value
       ) values (
            o_id
            , o_seqnum
            , i_mod_id
            , i_value
        );
        
        com_api_i18n_pkg.add_text (
            i_table_name      => 'net_member_interchange'
            , i_column_name   => 'name'
            , i_object_id     => o_id
            , i_lang          => i_lang
            , i_text          => i_name
        );
        
    exception
        when dup_val_on_index then
            com_api_error_pkg.raise_error (
                i_error  => 'DUPLICATE_MEMBER_INTERCHANGE'
            );
    end;

    procedure modify_member_interchange (
        i_id                        in com_api_type_pkg.t_tiny_id
        , io_seqnum                 in out com_api_type_pkg.t_seqnum
        , i_mod_id                  in com_api_type_pkg.t_tiny_id
        , i_value                   in com_api_type_pkg.t_byte_char
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_name                    in com_api_type_pkg.t_name
    ) is
    begin
        update
            net_member_interchange_vw
        set
            seqnum = io_seqnum
            , mod_id = i_mod_id
            , value = i_value
        where
            id = i_id;
        
        io_seqnum := io_seqnum + 1;
        
        com_api_i18n_pkg.add_text (
            i_table_name      => 'net_member_interchange'
            , i_column_name   => 'name'
            , i_object_id     => i_id
            , i_lang          => i_lang
            , i_text          => i_name
        );
    exception
        when dup_val_on_index then
            com_api_error_pkg.raise_error (
                i_error  => 'DUPLICATE_MEMBER_INTERCHANGE'
            );
    end;

    procedure remove_member_interchange (
        i_id                        in com_api_type_pkg.t_tiny_id
        , i_seqnum                  in com_api_type_pkg.t_seqnum
    ) is
    begin
        update
            net_member_interchange_vw
        set
            seqnum = i_seqnum
        where
            id = i_id;
        
        -- remove text
        com_api_i18n_pkg.remove_text (
            i_table_name   => 'net_member_interchange'
            , i_object_id  => i_id
        );
        
        -- delete
        delete from
            net_member_interchange_vw
        where
            id = i_id;
    
    end;

end;
/
