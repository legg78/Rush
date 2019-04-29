create or replace package body frp_ui_matrix_value_pkg as

procedure add_matrix_value(
    o_id              out  com_api_type_pkg.t_short_id 
  , o_seqnum          out  com_api_type_pkg.t_seqnum
  , i_matrix_id    in      com_api_type_pkg.t_tiny_id
  , i_x_value      in      com_api_type_pkg.t_name
  , i_y_value      in      com_api_type_pkg.t_name
  , i_matrix_value in      com_api_type_pkg.t_name
) is
  l_count                  com_api_type_pkg.t_tiny_id;  
begin
    select count(1)
      into l_count
      from frp_matrix_value_vw
     where x_value   = i_x_value
       and y_value   = i_y_value
       and matrix_id = i_matrix_id;
    
    if l_count > 0 then
        com_api_error_pkg.raise_error(
            i_error             => 'MATRIX_VALUE_FOR_X_Y_ALREADY_EXISTS'
          , i_env_param1        => i_x_value
          , i_env_param2        => i_y_value
        );        
    end if;

    select frp_matrix_value_seq.nextval into o_id from dual;
    
    o_seqnum := 1;
    
    insert into frp_matrix_value_vw(
        id
      , seqnum
      , matrix_id
      , x_value
      , y_value
      , matrix_value
    ) values (
        o_id
      , o_seqnum
      , i_matrix_id
      , i_x_value
      , i_y_value
      , i_matrix_value
    );    
end;

procedure modify_matrix_value(
    i_id           in      com_api_type_pkg.t_short_id 
  , io_seqnum      in out  com_api_type_pkg.t_seqnum
  , i_matrix_id    in      com_api_type_pkg.t_tiny_id
  , i_x_value      in      com_api_type_pkg.t_name
  , i_y_value      in      com_api_type_pkg.t_name
  , i_matrix_value in      com_api_type_pkg.t_name
) is
begin
    update frp_matrix_value_vw
       set seqnum       = io_seqnum
         , matrix_id    = i_matrix_id
         , x_value      = i_x_value
         , y_value      = i_y_value
         , matrix_value = i_matrix_value
     where id           = i_id;
     
    io_seqnum := io_seqnum + 1;
    
end;

procedure remove_matrix_value(
    i_id           in      com_api_type_pkg.t_tiny_id  
  , i_seqnum       in      com_api_type_pkg.t_seqnum
) is
begin
    update frp_matrix_value_vw
       set seqnum  = i_seqnum
     where id      = i_id;
     
    delete frp_matrix_value_vw
     where id      = i_id;
     
    com_api_i18n_pkg.remove_text(
        i_table_name        => 'frp_matrix_value'
      , i_object_id         => i_id
    );
end;

end;
/
