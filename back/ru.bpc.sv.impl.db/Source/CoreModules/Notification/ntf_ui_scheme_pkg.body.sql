create or replace package body ntf_ui_scheme_pkg is

    procedure add_scheme (
        o_id                        out com_api_type_pkg.t_tiny_id
        , o_seqnum                  out com_api_type_pkg.t_seqnum
        , i_scheme_type             in com_api_type_pkg.t_dict_value
        , i_inst_id                 in com_api_type_pkg.t_inst_id
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_name                    in com_api_type_pkg.t_name
        , i_description             in com_api_type_pkg.t_full_desc
    ) is
    begin
        if i_inst_id = ost_api_const_pkg.DEFAULT_INST then
            com_api_error_pkg.raise_error(
                i_error      => 'CANNOT_CREATE_NOTIFICATION_SCHEME_FOR_DEFAULT_INSTITUTION'
              , i_env_param1 => i_inst_id
            );
        end if;

        o_id := ntf_scheme_seq.nextval;
        o_seqnum := 1;

        insert into ntf_scheme_vw (
            id
          , seqnum
          , scheme_type
          , inst_id
        ) values (
            o_id
          , o_seqnum
          , i_scheme_type
          , i_inst_id
        );
        
        com_api_i18n_pkg.add_text(
            i_table_name            => 'ntf_scheme' 
          , i_column_name           => 'name' 
          , i_object_id             => o_id
          , i_lang                  => i_lang
          , i_text                  => i_name
          , i_check_unique          => com_api_type_pkg.TRUE
        );
        
        com_api_i18n_pkg.add_text(
            i_table_name            => 'ntf_scheme' 
          , i_column_name           => 'description' 
          , i_object_id             => o_id
          , i_lang                  => i_lang
          , i_text                  => i_description
        );
    end;

    procedure modify_scheme (
        i_id                        in com_api_type_pkg.t_tiny_id
        , io_seqnum                 in out com_api_type_pkg.t_seqnum
        , i_scheme_type             in com_api_type_pkg.t_dict_value
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_name                    in com_api_type_pkg.t_name
        , i_description             in com_api_type_pkg.t_full_desc
    ) is
    begin
        update ntf_scheme_vw
           set seqnum = io_seqnum
             , scheme_type = i_scheme_type
         where id = i_id;
            
        io_seqnum := io_seqnum + 1;
        
        com_api_i18n_pkg.add_text(
            i_table_name            => 'ntf_scheme' 
          , i_column_name           => 'name' 
          , i_object_id             => i_id
          , i_lang                  => i_lang
          , i_text                  => i_name
          , i_check_unique          => com_api_type_pkg.TRUE
        );
        
        com_api_i18n_pkg.add_text(
            i_table_name            => 'ntf_scheme' 
          , i_column_name           => 'description' 
          , i_object_id             => i_id
          , i_lang                  => i_lang
          , i_text                  => i_description
        );
    end;

    procedure remove_scheme (
        i_id                     in com_api_type_pkg.t_tiny_id
      , i_seqnum                 in com_api_type_pkg.t_seqnum
    ) is
        l_check_cnt                 number;
    begin
        select count(1) 
          into l_check_cnt 
          from prd_attribute a
             , prd_attribute_value v
         where a.attr_name   = 'NOTIFICATION_SCHEME'   
           and a.id          = v.attr_id      
           and a.data_type   = com_api_const_pkg.DATA_TYPE_NUMBER
           and v.attr_value  = to_char(i_id, com_api_const_pkg.NUMBER_FORMAT);
        
        if l_check_cnt > 0 then
            com_api_error_pkg.raise_error (
                i_error      => 'NOTIFICATION_SCHEME_INCLUDED_IN_PRODUCT'
              , i_env_param1 => i_id 
            );
        else
            delete from ntf_scheme_event_vw
             where scheme_id = i_id;

            com_api_i18n_pkg.remove_text(
                i_table_name => 'ntf_scheme' 
              , i_object_id  => i_id
            );
        
            update ntf_scheme_vw
               set seqnum = i_seqnum
             where id = i_id;
            
            delete from ntf_scheme_vw
             where id = i_id;
        end if;
    end;

end; 
/
