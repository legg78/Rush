create or replace package body dsp_ui_list_condition_pkg is

procedure add_condition(
    o_id              out    com_api_type_pkg.t_tiny_id
  , i_init_rule       in     com_api_type_pkg.t_agent_id
  , i_gen_rule        in     com_api_type_pkg.t_agent_id
  , i_func_order      in     com_api_type_pkg.t_agent_id
  , i_mod_id          in     com_api_type_pkg.t_tiny_id
  , i_is_online       in     com_api_type_pkg.t_boolean
  , i_name            in     com_api_type_pkg.t_name
  , i_lang            in     com_api_type_pkg.t_dict_value
)is
begin

    o_id := dsp_list_condition_seq.nextval;

    insert into dsp_list_condition(
        id          
        , init_rule   
        , gen_rule    
        , func_order  
        , mod_id      
        , is_online       
    ) values (
        o_id
        , i_init_rule       
        , i_gen_rule        
        , i_func_order      
        , i_mod_id          
        , i_is_online       
    );

    com_api_i18n_pkg.add_text(
        i_table_name   => 'dsp_list_condition'
      , i_column_name  => 'name'
      , i_object_id    => o_id
      , i_text         => i_name
      , i_lang         => i_lang
      , i_check_unique => com_api_type_pkg.TRUE
    );    

end;
  
procedure modify_condition(
    i_id              in     com_api_type_pkg.t_tiny_id
  , i_init_rule       in     com_api_type_pkg.t_agent_id
  , i_gen_rule        in     com_api_type_pkg.t_agent_id
  , i_func_order      in     com_api_type_pkg.t_agent_id
  , i_mod_id          in     com_api_type_pkg.t_tiny_id
  , i_is_online       in     com_api_type_pkg.t_boolean
  , i_name            in     com_api_type_pkg.t_name
  , i_lang            in     com_api_type_pkg.t_dict_value
)is
begin
    update dsp_list_condition a
       set a.init_rule  = i_init_rule
         , a.gen_rule   = i_gen_rule
         , a.func_order = i_func_order
         , a.mod_id     = i_mod_id
         , a.is_online  = i_is_online         
     where a.id      = i_id;

    com_api_i18n_pkg.add_text(
        i_table_name   => 'dsp_list_condition'
      , i_column_name  => 'name'
      , i_object_id    => i_id
      , i_text         => i_name
      , i_lang         => i_lang
      , i_check_unique => com_api_type_pkg.TRUE
    );
        
end;
  
procedure remove_condition(
    i_id      in     com_api_type_pkg.t_tiny_id
)is
begin
    delete dsp_list_condition a
     where a.id = i_id;

    com_api_i18n_pkg.remove_text(
        i_table_name => 'dsp_list_condition'
      , i_object_id  => i_id
    );
end;

end dsp_ui_list_condition_pkg;
/
