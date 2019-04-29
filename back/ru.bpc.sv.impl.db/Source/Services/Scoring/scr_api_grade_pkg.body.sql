create or replace package body scr_api_grade_pkg 
is

procedure add_grade(
    i_eval        in      com_api_type_pkg.t_long_id
  , i_total_score in      com_api_type_pkg.t_tiny_id
  , i_grade       in      com_api_type_pkg.t_name
  , i_name        in      com_api_type_pkg.t_name
  , o_seqnum         out  com_api_type_pkg.t_seqnum
  , i_lang        in      com_api_type_pkg.t_dict_value   default null
  , o_id             out  com_api_type_pkg.t_long_id
) is
    l_id        com_api_type_pkg.t_long_id;
    l_lang      com_api_type_pkg.t_dict_value := nvl(i_lang, get_user_lang);
begin
    insert into scr_grade(id
                        , seqnum
                        , evaluation_id
                        , total_score
                        , grade)
    values(scr_grade_seq.nextval
         , 0
         , i_eval
         , i_total_score
         , i_grade)
    returning id into l_id;
                        
    com_api_i18n_pkg.add_text(
        i_table_name   => 'SCR_GRADE'
      , i_column_name  => 'NAME'
      , i_object_id    => l_id
      , i_text         => i_name
      , i_lang         => l_lang
      , i_check_unique => com_api_type_pkg.TRUE
    );
    
    o_seqnum := 0;
    o_id     := l_id;
    trc_log_pkg.debug(
        i_text       => 'add_grade: created grade [#1] ([#2]) for eval [#3] '
      , i_env_param1 => l_id
      , i_env_param2 => i_name
      , i_env_param3 => i_eval
    );
end add_grade;

procedure modify_grade(
    i_id        in      com_api_type_pkg.t_long_id
  , i_eval        in      com_api_type_pkg.t_long_id
  , i_total_score in      com_api_type_pkg.t_tiny_id
  , i_grade       in      com_api_type_pkg.t_name
  , i_name      in      com_api_type_pkg.t_name
  , i_lang      in      com_api_type_pkg.t_dict_value   default null
  , io_seqnum in   out  com_api_type_pkg.t_seqnum
) is
    l_lang      com_api_type_pkg.t_dict_value := nvl(i_lang, get_user_lang);
begin
    com_api_i18n_pkg.add_text(
        i_table_name   => 'SCR_GRADE'
      , i_column_name  => 'NAME'
      , i_object_id    => i_id
      , i_text         => i_name
      , i_lang         => l_lang
      , i_check_unique => com_api_type_pkg.TRUE
    );
    
    io_seqnum := io_seqnum + 1;
    
    update scr_grade
       set seqnum        = nvl(io_seqnum, seqnum)
         , evaluation_id = nvl(i_eval, evaluation_id)
         , total_score   = nvl(i_total_score, total_score)
         , grade         = nvl(i_grade, grade)
     where id = i_id;   

    if sql%rowcount = 0 then
        trc_log_pkg.debug(
            i_text       => 'modify_grade: 0 records were deleted by id [#1]'
          , i_env_param1 => i_id
        );
    end if;
end modify_grade;

procedure remove_grade(
    i_id        in      com_api_type_pkg.t_long_id
) is
begin
    com_api_i18n_pkg.remove_text(
        i_table_name => 'SCR_GRADE'
      , i_object_id  => i_id
    );
    
    delete from scr_grade
     where id = i_id;
     
    if sql%rowcount = 0 then
        trc_log_pkg.debug(
            i_text       => 'remove_grade: 0 records were deleted by id [#1]'
          , i_env_param1 => i_id
        );
    end if;
end;

end scr_api_grade_pkg;
/
