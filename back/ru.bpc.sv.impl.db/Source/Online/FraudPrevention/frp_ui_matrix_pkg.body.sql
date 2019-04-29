create or replace package body frp_ui_matrix_pkg as

procedure add_matrix(
    o_id              out  com_api_type_pkg.t_short_id 
  , o_seqnum          out  com_api_type_pkg.t_seqnum
  , i_inst_id      in      com_api_type_pkg.t_inst_id
  , i_x_scale      in      com_api_type_pkg.t_name
  , i_y_scale      in      com_api_type_pkg.t_name
  , i_matrix_type  in      com_api_type_pkg.t_dict_value
  , i_lang         in      com_api_type_pkg.t_dict_value
  , i_label        in      com_api_type_pkg.t_name
  , i_description  in      com_api_type_pkg.t_full_desc
) is
begin
    select frp_matrix_seq.nextval into o_id from dual;
    
    o_seqnum := 1;
    
    insert into frp_matrix_vw(
        id
      , seqnum
      , inst_id
      , x_scale
      , y_scale
      , matrix_type
    ) values (
        o_id
      , o_seqnum
      , i_inst_id
      , i_x_scale
      , i_y_scale
      , i_matrix_type
    );
    
    if i_label is not null then
        com_api_i18n_pkg.add_text(
            i_table_name    => 'frp_matrix'
          , i_column_name   => 'label'
          , i_object_id     => o_id
          , i_lang          => i_lang
          , i_text          => i_label
          , i_check_unique  => com_api_type_pkg.TRUE
        );
    end if;

    if i_description is not null then
        com_api_i18n_pkg.add_text(
            i_table_name    => 'frp_matrix'
          , i_column_name   => 'description'
          , i_object_id     => o_id
          , i_lang          => i_lang
          , i_text          => i_description
        );
    end if;
end;

procedure modify_matrix(
    i_id           in      com_api_type_pkg.t_short_id 
  , io_seqnum      in out  com_api_type_pkg.t_seqnum
  , i_inst_id      in      com_api_type_pkg.t_inst_id
  , i_x_scale      in      com_api_type_pkg.t_name
  , i_y_scale      in      com_api_type_pkg.t_name
  , i_matrix_type  in      com_api_type_pkg.t_dict_value
  , i_lang         in      com_api_type_pkg.t_dict_value
  , i_label        in      com_api_type_pkg.t_name
  , i_description  in      com_api_type_pkg.t_full_desc
) is
begin
    update frp_matrix_vw
       set seqnum       = io_seqnum
         , inst_id      = i_inst_id
         , x_scale      = i_x_scale
         , y_scale      = i_y_scale
         , matrix_type  = i_matrix_type
     where id           = i_id;
     
    io_seqnum := io_seqnum + 1;
    
    if i_label is not null then
        com_api_i18n_pkg.add_text(
            i_table_name    => 'frp_matrix'
          , i_column_name   => 'label'
          , i_object_id     => i_id
          , i_lang          => i_lang
          , i_text          => i_label
          , i_check_unique  => com_api_type_pkg.TRUE
        );
    end if;

    if i_description is not null then
        com_api_i18n_pkg.add_text(
            i_table_name    => 'frp_matrix'
          , i_column_name   => 'description'
          , i_object_id     => i_id
          , i_lang          => i_lang
          , i_text          => i_description
        );
    end if;
end;

procedure remove_matrix(
    i_id           in      com_api_type_pkg.t_tiny_id  
  , i_seqnum       in      com_api_type_pkg.t_seqnum
) is
begin
    update frp_matrix_vw
       set seqnum  = i_seqnum
     where id      = i_id;
     
    delete frp_matrix_vw
     where id      = i_id;
     
    com_api_i18n_pkg.remove_text(
        i_table_name        => 'frp_matrix'
      , i_object_id         => i_id
    );
end;

end;
/
