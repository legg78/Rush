create or replace package body aup_ui_tag_pkg is

    procedure add_tag (
        o_id                        out com_api_type_pkg.t_short_id
        , o_seqnum                  out com_api_type_pkg.t_seqnum
        , i_tag                     in com_api_type_pkg.t_short_id
        , i_tag_type                in com_api_type_pkg.t_dict_value
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_name                    in com_api_type_pkg.t_name
        , i_description             in com_api_type_pkg.t_full_desc
        , i_reference               in com_api_type_pkg.t_name
        , i_db_stored               in com_api_type_pkg.t_boolean
    ) is
    begin
        o_id := aup_tag_seq.nextval;
        o_seqnum := 1;
        
        insert into aup_tag_vw (
            id
            , seqnum
            , tag
            , tag_type
            , reference
            , db_stored
        ) values (
            o_id
            , o_seqnum
            , i_tag
            , i_tag_type
            , i_reference
            , i_db_stored
        );
        
        com_api_i18n_pkg.add_text (
            i_table_name     => 'aup_tag'
            , i_column_name  => 'name'
            , i_object_id    => o_id
            , i_lang         => i_lang
            , i_text         => i_name
        );
        com_api_i18n_pkg.add_text (
            i_table_name     => 'aup_tag'
            , i_column_name  => 'description'
            , i_object_id    => o_id
            , i_lang         => i_lang
            , i_text         => i_description
        );
    exception
        when dup_val_on_index then
            com_api_error_pkg.raise_error(
                i_error      => 'TAG_IS_NOT_UNIQUE'
              , i_env_param1 => i_tag
            );
    end;

    procedure modify_tag (
        i_id                        in com_api_type_pkg.t_short_id
        , io_seqnum                 in out com_api_type_pkg.t_seqnum
        , i_tag                     in com_api_type_pkg.t_short_id
        , i_tag_type                in com_api_type_pkg.t_dict_value
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_name                    in com_api_type_pkg.t_name
        , i_description             in com_api_type_pkg.t_full_desc
        , i_reference               in com_api_type_pkg.t_name
        , i_db_stored               in com_api_type_pkg.t_boolean
    ) is
    begin
        update
            aup_tag_vw
        set
            seqnum = io_seqnum
            , tag = i_tag
            , tag_type = i_tag_type
            , reference = i_reference
            , db_stored = i_db_stored
        where
            id = i_id;
            
        io_seqnum := io_seqnum + 1;

        com_api_i18n_pkg.add_text (
            i_table_name     => 'aup_tag'
            , i_column_name  => 'name'
            , i_object_id    => i_id
            , i_lang         => i_lang
            , i_text         => i_name
        );
        com_api_i18n_pkg.add_text (
            i_table_name     => 'aup_tag'
            , i_column_name  => 'description'
            , i_object_id    => i_id
            , i_lang         => i_lang
            , i_text         => i_description
        );
    exception
        when dup_val_on_index then
            com_api_error_pkg.raise_error(
                i_error      => 'TAG_IS_NOT_UNIQUE'
              , i_env_param1 => i_tag
            );
    end;

    procedure remove_tag (
        i_id                        in com_api_type_pkg.t_short_id
        , i_seqnum                  in com_api_type_pkg.t_seqnum
    ) is
    begin
        com_api_i18n_pkg.remove_text (
            i_table_name   => 'aup_tag'
            , i_object_id  => i_id
        );
          
        update
            aup_tag_vw
        set
            seqnum = i_seqnum
        where
            id = i_id;
            
        delete from
            aup_tag_vw
        where
            id = i_id;
    end;

end; 
/
