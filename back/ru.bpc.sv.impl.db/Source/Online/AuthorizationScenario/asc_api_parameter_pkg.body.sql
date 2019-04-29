create or replace package body asc_api_parameter_pkg is

procedure add_parameter(  
    io_param_id             in out com_api_type_pkg.t_short_id 
  , i_param_name            in     com_api_type_pkg.t_oracle_name
  , i_description           in     com_api_type_pkg.t_full_desc
  , i_lang                  in     com_api_type_pkg.t_dict_value
  , i_data_type             in     com_api_type_pkg.t_dict_value
  , i_lov_id                in     com_api_type_pkg.t_tiny_id
) is
begin
    -- check parameter type
    if upper(i_data_type) not in (  
        com_api_const_pkg.DATA_TYPE_NUMBER
      , com_api_const_pkg.DATA_TYPE_CHAR
      , com_api_const_pkg.DATA_TYPE_DATE
    ) then
        com_api_error_pkg.raise_error(  
            i_error      => 'UNKNOWN_DATA_TYPE'
          , i_env_param1 => i_data_type 
        );
    end if; 
                         
    if io_param_id is null then 
        io_param_id := com_parameter_seq.nextval;    
    
        insert into asc_parameter_vw(
            id
          , param_name
          , data_type
          , lov_id
        ) values ( 
            io_param_id
          , upper(i_param_name)
          , upper(i_data_type)
          , i_lov_id
       );
    else
        update asc_parameter_vw 
        set param_name  = upper(i_param_name)
          , data_type   = upper(i_data_type)
          , lov_id      = i_lov_id
        where id = io_param_id;
    end if; 
    
    -- add/modify description  
    com_api_i18n_pkg.add_text ( 
        i_table_name  => 'ASC_PARAMETER'
      , i_column_name => 'DESCRIPTION'
      , i_object_id   => io_param_id
      , i_text        => i_description
      , i_lang        => i_lang
    );                           
end;

procedure remove_parameter( 
    i_param_id              in      com_api_type_pkg.t_short_id 
) is
begin
    delete from asc_parameter_vw a where a.id = i_param_id;
 
    com_api_i18n_pkg.remove_text(
        i_table_name => 'ASC_PARAMETER'
      , i_object_id  => i_param_id
    );  
end;

procedure add_state_parameter (
    o_state_parameter_id       out  com_api_type_pkg.t_short_id
  , o_seqnum                   out  com_api_type_pkg.t_seqnum
  , i_param_id              in      com_api_type_pkg.t_short_id
  , i_state_type            in      com_api_type_pkg.t_dict_value
  , i_default_value         in      com_api_type_pkg.t_full_desc
  , i_display_order         in      com_api_type_pkg.t_tiny_id
  , i_description           in      com_api_type_pkg.t_full_desc
  , i_lang                  in      com_api_type_pkg.t_dict_value
) is
begin
    
    o_state_parameter_id := asc_state_parameter_seq.nextval;
    o_seqnum             := 1;
                
    insert into asc_state_parameter_vw (    
        id
      , seqnum
      , state_type
      , param_id
      , default_value
      , display_order
    ) values ( 
        o_state_parameter_id
      , o_seqnum
      , i_state_type
      , i_param_id
      , i_default_value
      , i_display_order          
    );
    
    com_api_i18n_pkg.add_text( 
        i_table_name  => 'ASC_STATE_PARAMETER'
      , i_column_name => 'DESCRIPTION'
      , i_object_id   => o_state_parameter_id
      , i_text        => i_description
      , i_lang        => i_lang
    );    
  
end;

procedure modify_state_parameter (
    i_state_parameter_id    in      com_api_type_pkg.t_short_id
  , io_seqnum               in out  com_api_type_pkg.t_seqnum
  , i_default_value         in      com_api_type_pkg.t_full_desc
  , i_display_order         in      com_api_type_pkg.t_tiny_id
  , i_description           in      com_api_type_pkg.t_full_desc
  , i_lang                  in      com_api_type_pkg.t_dict_value
) is
begin
    
    update asc_state_parameter_vw 
       set default_value = i_default_value
         , display_order = i_display_order
         , seqnum        = io_seqnum                 
     where id            = i_state_parameter_id;
    
    com_api_i18n_pkg.add_text( 
        i_table_name  => 'ASC_STATE_PARAMETER'
      , i_column_name => 'DESCRIPTION'
      , i_object_id   => i_state_parameter_id
      , i_text        => i_description
      , i_lang        => i_lang
    );    
  
    io_seqnum := io_seqnum + 1;
end;

procedure remove_state_parameter ( 
    i_state_parameter_id    in      com_api_type_pkg.t_short_id
  , i_seqnum                in      com_api_type_pkg.t_seqnum
) is
begin

    update asc_state_parameter_vw 
       set seqnum = i_seqnum                 
     where id     = i_state_parameter_id;

    delete from asc_state_parameter_vw a 
     where a.id = i_state_parameter_id;
        
    com_api_i18n_pkg.remove_text(
        i_table_name  => 'ASC_STATE_PARAMETER'
      , i_object_id   => i_state_parameter_id
    );
   
end;

end;
/
