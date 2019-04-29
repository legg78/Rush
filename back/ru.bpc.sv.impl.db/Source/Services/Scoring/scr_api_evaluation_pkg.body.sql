create or replace package body scr_api_evaluation_pkg 
is

procedure add_evaluation(
    i_name    in      com_api_type_pkg.t_name
  , i_inst_id in      com_api_type_pkg.t_inst_id      default null
  , o_seqnum     out  com_api_type_pkg.t_seqnum
  , i_lang    in      com_api_type_pkg.t_dict_value   default null
  , o_id         out  com_api_type_pkg.t_long_id
) is
    l_id        com_api_type_pkg.t_long_id;
    l_lang      com_api_type_pkg.t_dict_value := nvl(i_lang, get_user_lang);
begin
    insert into scr_evaluation(id
                             , seqnum
                             , inst_id)
    values(scr_evaluation_seq.nextval
         , 0
         , nvl(i_inst_id, ost_api_const_pkg.DEFAULT_INST))
    returning id into l_id;
                        
    com_api_i18n_pkg.add_text(
        i_table_name   => 'SCR_EVALUATION'
      , i_column_name  => 'NAME'
      , i_object_id    => l_id
      , i_text         => i_name
      , i_lang         => l_lang
      , i_check_unique => com_api_type_pkg.TRUE
    );
    
    o_seqnum := 0;
    o_id     := l_id;
    trc_log_pkg.debug(
        i_text       => 'add_evaluation: created evaluation [#1] for [#2]'
      , i_env_param1 => l_id
      , i_env_param2 => i_name
    );
      
end add_evaluation;


procedure modify_evaluation(
    i_id      in      com_api_type_pkg.t_long_id
  , i_inst_id in      com_api_type_pkg.t_inst_id      default null
  , i_name    in      com_api_type_pkg.t_name
  , i_lang    in      com_api_type_pkg.t_dict_value   default null
  , io_seqnum in out  com_api_type_pkg.t_seqnum
) is
    l_lang      com_api_type_pkg.t_dict_value := nvl(i_lang, get_user_lang);
begin
    
    com_api_i18n_pkg.add_text(
        i_table_name   => 'SCR_EVALUATION'
      , i_column_name  => 'NAME'
      , i_object_id    => i_id
      , i_text         => i_name
      , i_lang         => l_lang
      , i_check_unique => com_api_type_pkg.TRUE
    );
    
    io_seqnum := io_seqnum + 1;
    
    update scr_evaluation
       set seqnum  = nvl(io_seqnum, seqnum)
         , inst_id = nvl(i_inst_id, inst_id)
     where id = i_id;   

    if sql%rowcount = 0 then
        trc_log_pkg.debug(
            i_text       => 'modify_evaluation: 0 records were deleted by id [#1]'
          , i_env_param1 => i_id
        );
    end if;
    
end modify_evaluation;

procedure remove_evaluation(
    i_id     in      com_api_type_pkg.t_long_id
  , i_force  in      com_api_type_pkg.t_boolean    default null
) is
    l_force   com_api_type_pkg.t_boolean := nvl(i_force, com_api_const_pkg.FALSE);
begin

    for tab in (select id
                  from scr_criteria
                 where evaluation_id = i_id)
    loop
        if l_force = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_error(
                i_error      => 'EVAL_HAS_CRITERIA'
              , i_env_param1 => i_id
            );
        else
            scr_api_criteria_pkg.remove_criteria(
                i_id    => tab.id
              , i_force => l_force
            );
        end if;
    end loop;           
    
    for tab in (select id
                  from scr_grade
                 where evaluation_id = i_id)
    loop
        if l_force = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_error(
                i_error      => 'EVAL_HAS_GRADE'
              , i_env_param1 => i_id
            );
        else
            scr_api_grade_pkg.remove_grade(
                i_id        => tab.id
            );
        end if;
    end loop;              
    
    com_api_i18n_pkg.remove_text(
        i_table_name => 'SCR_EVALUATION'
      , i_object_id  => i_id
    );
    
    delete from scr_evaluation
     where id = i_id;
     
    if sql%rowcount = 0 then
        trc_log_pkg.debug(
            i_text       => 'remove_evaluation: 0 records were deleted by id [#1]'
          , i_env_param1 => i_id
        );
    end if;
    
end remove_evaluation;

end scr_api_evaluation_pkg;
/
