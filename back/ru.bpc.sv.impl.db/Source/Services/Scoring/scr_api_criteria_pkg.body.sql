create or replace package body scr_api_criteria_pkg 
is

procedure add_criteria(
    i_eval      in      com_api_type_pkg.t_long_id
  , i_order_num in      com_api_type_pkg.t_tiny_id
  , i_name      in      com_api_type_pkg.t_name
  , o_seqnum       out  com_api_type_pkg.t_seqnum
  , i_lang      in      com_api_type_pkg.t_dict_value   default null
  , o_id         out  com_api_type_pkg.t_long_id
) is
    l_id        com_api_type_pkg.t_long_id;
    l_lang      com_api_type_pkg.t_dict_value := nvl(i_lang, get_user_lang);
begin
    insert into scr_criteria(id
                           , seqnum
                           , evaluation_id
                           , order_num)
    values(scr_criteria_seq.nextval
         , 0
         , i_eval
         , i_order_num)
    returning id into l_id;
                        
    com_api_i18n_pkg.add_text(
        i_table_name   => 'SCR_CRITERIA'
      , i_column_name  => 'NAME'
      , i_object_id    => l_id
      , i_text         => i_name
      , i_lang         => l_lang
      , i_check_unique => com_api_type_pkg.TRUE
    );
    
    o_seqnum := 0;
    o_id     := l_id;
    trc_log_pkg.debug(
        i_text       => 'add_criteria: created criteria [#1] ([#2]) for evaluation [#3] '
      , i_env_param1 => l_id
      , i_env_param2 => i_name
      , i_env_param3 => i_eval
    );
end add_criteria;

procedure modify_criteria(
    i_id        in      com_api_type_pkg.t_long_id
  , i_eval      in      com_api_type_pkg.t_long_id
  , i_order_num in      com_api_type_pkg.t_tiny_id
  , i_name      in      com_api_type_pkg.t_name
  , i_lang      in      com_api_type_pkg.t_dict_value   default null
  , io_seqnum in out  com_api_type_pkg.t_seqnum
) is
    l_lang      com_api_type_pkg.t_dict_value := nvl(i_lang, get_user_lang);
begin
    com_api_i18n_pkg.add_text(
        i_table_name   => 'SCR_CRITERIA'
      , i_column_name  => 'NAME'
      , i_object_id    => i_id
      , i_text         => i_name
      , i_lang         => l_lang
      , i_check_unique => com_api_type_pkg.TRUE
    );
    
    io_seqnum := io_seqnum + 1;
    
    update scr_criteria
       set seqnum        = nvl(io_seqnum, seqnum)
         , evaluation_id = nvl(i_eval, evaluation_id)
         , order_num     = nvl(i_order_num, order_num)
     where id = i_id;   

    if sql%rowcount = 0 then
        trc_log_pkg.debug(
            i_text       => 'modify_criteria: 0 records were deleted by id [#1]'
          , i_env_param1 => i_id
        );
    end if;
end modify_criteria;

procedure remove_criteria(
    i_id        in      com_api_type_pkg.t_long_id
  , i_force     in      com_api_type_pkg.t_boolean      default null
) is
    l_force   com_api_type_pkg.t_boolean := nvl(i_force, com_api_const_pkg.FALSE);
begin
    for tab in (select id
                  from scr_value
                 where criteria_id = i_id)
    loop
        if l_force = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_error(
                i_error      => 'CRIT_HAS_VALUE'
              , i_env_param1 => i_id
            );
        else
            scr_api_value_pkg.remove_value(
                i_id => tab.id
            );
        end if;
    end loop;                 
    
    com_api_i18n_pkg.remove_text(
        i_table_name => 'SCR_CRITERIA'
      , i_object_id  => i_id
    );
    
    delete from scr_criteria
     where id = i_id;
     
    if sql%rowcount = 0 then
        trc_log_pkg.debug(
            i_text       => 'remove_criteria: 0 records were deleted by id [#1]'
          , i_env_param1 => i_id
        );
    end if;
end remove_criteria;

end scr_api_criteria_pkg;
/
