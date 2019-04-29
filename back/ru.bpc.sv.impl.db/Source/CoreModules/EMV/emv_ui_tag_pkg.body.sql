create or replace package body emv_ui_tag_pkg is

    procedure add_tag (
        o_id                        out com_api_type_pkg.t_tiny_id
        , i_tag                     in com_api_type_pkg.t_tag
        , i_min_length              in com_api_type_pkg.t_tiny_id
        , i_max_length              in com_api_type_pkg.t_tiny_id
        , i_data_type               in com_api_type_pkg.t_dict_value
        , i_data_format             in com_api_type_pkg.t_name
        , i_default_value           in com_api_type_pkg.t_name
        , i_tag_type                in com_api_type_pkg.t_dict_value
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_description             in com_api_type_pkg.t_full_desc
    ) is
    begin
        o_id := emv_tag_seq.nextval;
        
        insert into emv_tag_vw (
            id
            , tag
            , min_length
            , max_length
            , data_type
            , data_format
            , default_value
            , tag_type
        ) values (
            o_id
            , i_tag
            , nvl(i_min_length, 0)
            , nvl(i_max_length, 0)
            , i_data_type
            , i_data_format
            , i_default_value
            , i_tag_type
        );

        com_api_i18n_pkg.add_text(
            i_table_name            => 'emv_tag'
          , i_column_name           => 'description'
          , i_object_id             => o_id
          , i_lang                  => i_lang
          , i_text                  => i_description
          , i_check_unique          => com_api_type_pkg.TRUE
        );
    exception
        when dup_val_on_index then
            com_api_error_pkg.raise_error (
                i_error         => 'EMV_TAG_ALREADY_EXIST'
                , i_env_param1  => i_tag
            );
    end;

    procedure modify_tag (
        i_id                        in com_api_type_pkg.t_tiny_id
        , i_min_length              in com_api_type_pkg.t_tiny_id
        , i_max_length              in com_api_type_pkg.t_tiny_id
        , i_data_type               in com_api_type_pkg.t_dict_value
        , i_data_format             in com_api_type_pkg.t_name
        , i_default_value           in com_api_type_pkg.t_name
        , i_tag_type                in com_api_type_pkg.t_dict_value
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_description             in com_api_type_pkg.t_full_desc
    ) is
    begin
        update
            emv_tag_vw
        set
            min_length = nvl(i_min_length, 0)
            , max_length = nvl(i_max_length, 0)
            , data_type = i_data_type
            , data_format = i_data_format
            , default_value = i_default_value
            , tag_type = i_tag_type
        where
            id = i_id;
            
        com_api_i18n_pkg.add_text(
            i_table_name            => 'emv_tag' 
          , i_column_name           => 'description' 
          , i_object_id             => i_id
          , i_lang                  => i_lang
          , i_text                  => i_description
          , i_check_unique          => com_api_type_pkg.TRUE
        );
    end;

    procedure remove_tag (
        i_id                        in com_api_type_pkg.t_tiny_id
    ) is
    begin
        com_api_i18n_pkg.remove_text(
            i_table_name            => 'emv_tag' 
          , i_object_id             => i_id
        );
      
        delete from
            emv_tag_vw
        where
            id = i_id;
    end;

    procedure set_tag_value (
        i_tag_id                    in com_api_type_pkg.t_tiny_id
        , i_object_id               in com_api_type_pkg.t_long_id
        , i_entity_type             in com_api_type_pkg.t_dict_value
        , i_value                   in com_api_type_pkg.t_name
        , i_profile                 in com_api_type_pkg.t_dict_value
    ) is
    begin
        update emv_tag_value_vw src
           set tag_value = i_value
         where src.tag_id      = i_tag_id
           and src.object_id   = i_object_id
           and src.entity_type = i_entity_type
           and src.profile     = i_profile;
        
        if sql%rowcount = 0 then
             insert into emv_tag_value_vw(
                 id
                 , object_id
                 , entity_type
                 , tag_id
                 , tag_value
                 , profile
             ) values (
                 emv_tag_value_seq.nextval
                 , i_object_id
                 , i_entity_type
                 , i_tag_id
                 , i_value
                 , i_profile
            );
        end if;
    end;
    
    procedure remove_tag_value (
        i_id                        in com_api_type_pkg.t_short_id
    ) is
    begin
        delete from
            emv_tag_value_vw
        where
            id = i_id;
    end;

end; 
/
