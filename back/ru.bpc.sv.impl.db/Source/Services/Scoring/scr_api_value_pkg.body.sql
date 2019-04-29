create or replace package body scr_api_value_pkg 
is

procedure add_value(
    i_crit      in      com_api_type_pkg.t_long_id
  , i_score     in      com_api_type_pkg.t_tiny_id
  , i_name      in      com_api_type_pkg.t_name
  , o_seqnum       out  com_api_type_pkg.t_seqnum
  , i_lang      in      com_api_type_pkg.t_dict_value   default null
  , o_id           out  com_api_type_pkg.t_long_id
) is
    l_id        com_api_type_pkg.t_long_id;
    l_lang      com_api_type_pkg.t_dict_value := nvl(i_lang, get_user_lang);
begin
    insert into scr_value(id
                        , seqnum
                        , criteria_id
                        , score)
    values(scr_value_seq.nextval
         , 0
         , i_crit
         , i_score)
    returning id into l_id;
                        
    com_api_i18n_pkg.add_text(
        i_table_name   => 'SCR_VALUE'
      , i_column_name  => 'NAME'
      , i_object_id    => l_id
      , i_text         => i_name
      , i_lang         => l_lang
      , i_check_unique => com_api_type_pkg.TRUE
    );
    
    o_seqnum := 0;
    o_id     := l_id;
    trc_log_pkg.debug(
        i_text       => 'add_value: created value [#1] ([#2]) for criteria [#3] '
      , i_env_param1 => l_id
      , i_env_param2 => i_name
      , i_env_param3 => i_crit
    );
end add_value;

procedure modify_value(
    i_id        in      com_api_type_pkg.t_long_id
  , i_crit      in      com_api_type_pkg.t_long_id
  , i_score     in      com_api_type_pkg.t_tiny_id
  , i_name      in      com_api_type_pkg.t_name
  , i_lang      in      com_api_type_pkg.t_dict_value   default null
  , io_seqnum in   out  com_api_type_pkg.t_seqnum
) is
    l_lang      com_api_type_pkg.t_dict_value := nvl(i_lang, get_user_lang);
begin
    com_api_i18n_pkg.add_text(
        i_table_name   => 'SCR_VALUE'
      , i_column_name  => 'NAME'
      , i_object_id    => i_id
      , i_text         => i_name
      , i_lang         => l_lang
      , i_check_unique => com_api_type_pkg.TRUE
    );
    
    io_seqnum := io_seqnum + 1;
    
    update scr_value
       set seqnum      = nvl(io_seqnum, seqnum)
         , criteria_id = nvl(i_crit, criteria_id)
         , score       = nvl(i_score, score)
     where id = i_id;   

    if sql%rowcount = 0 then
        trc_log_pkg.debug(
            i_text       => 'modify_value: 0 records were deleted by id [#1]'
          , i_env_param1 => i_id
        );
    end if;
end modify_value;

procedure remove_value(
    i_id        in      com_api_type_pkg.t_long_id
) is
begin              
    
    com_api_i18n_pkg.remove_text(
        i_table_name => 'SCR_CRITERIA'
      , i_object_id  => i_id
    );
    
    delete from scr_value
     where id = i_id;
     
    if sql%rowcount = 0 then
        trc_log_pkg.debug(
            i_text       => 'remove_value: 0 records were deleted by id [#1]'
          , i_env_param1 => i_id
        );
    end if;
end remove_value;

end scr_api_value_pkg;
/
