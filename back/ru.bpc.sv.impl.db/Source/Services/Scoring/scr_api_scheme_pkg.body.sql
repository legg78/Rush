create or replace package body scr_api_scheme_pkg
is

/*
 * scr_evaluation API 
 */

procedure add_evaluation(
    i_name    in      com_api_type_pkg.t_name
  , i_inst_id in      com_api_type_pkg.t_inst_id      default null
  , o_seqnum     out  com_api_type_pkg.t_seqnum
  , i_lang    in      com_api_type_pkg.t_dict_value   default null
  , o_id         out  com_api_type_pkg.t_long_id
) is    
begin
    scr_api_evaluation_pkg.add_evaluation(
        i_name   => i_name
      , i_inst_id => i_inst_id
      , o_seqnum => o_seqnum
      , i_lang   => i_lang
      , o_id     => o_id
    );
end add_evaluation;


procedure modify_evaluation(
    i_id      in      com_api_type_pkg.t_long_id
  , i_name    in      com_api_type_pkg.t_name
  , i_inst_id in      com_api_type_pkg.t_inst_id      default null
  , i_lang    in      com_api_type_pkg.t_dict_value   default null
  , io_seqnum in out  com_api_type_pkg.t_seqnum
) is    
begin
    scr_api_evaluation_pkg.modify_evaluation(
        i_id      => i_id
      , i_name    => i_name
      , i_inst_id => i_inst_id
      , i_lang    => i_lang
      , io_seqnum => io_seqnum
    );
end modify_evaluation;

procedure remove_evaluation(
    i_id      in      com_api_type_pkg.t_long_id
  , i_force   in      com_api_type_pkg.t_boolean    default null
) is
begin
    scr_api_evaluation_pkg.remove_evaluation(
        i_id    => i_id
      , i_force => i_force
    );
end remove_evaluation;

/*
 *_scr_criteria API 
 */
 
procedure add_criteria(
    i_eval      in      com_api_type_pkg.t_long_id
  , i_order_num in      com_api_type_pkg.t_tiny_id
  , i_name      in      com_api_type_pkg.t_name
  , o_seqnum       out  com_api_type_pkg.t_seqnum
  , i_lang      in      com_api_type_pkg.t_dict_value   default null
  , o_id         out  com_api_type_pkg.t_long_id
) is
begin
    scr_api_criteria_pkg.add_criteria(
        i_eval      => i_eval
      , i_order_num => i_order_num
      , i_name      => i_name
      , o_seqnum    => o_seqnum
      , i_lang      => i_lang
      , o_id        => o_id
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
begin
    scr_api_criteria_pkg.modify_criteria(
        i_id        => i_id
      , i_eval      => i_eval
      , i_order_num => i_order_num
      , i_name      => i_name
      , i_lang      => i_lang
      , io_seqnum   => io_seqnum
    );
end modify_criteria;

procedure remove_criteria(
    i_id        in      com_api_type_pkg.t_long_id
  , i_force     in      com_api_type_pkg.t_boolean    default null
) is
begin
    scr_api_criteria_pkg.remove_criteria(
        i_id    => i_id
      , i_force => i_force
    );
end remove_criteria;

/*
 *_scr_value API 
 */

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
    scr_api_value_pkg.add_value(
        i_crit   => i_crit
      , i_score  => i_score
      , i_name   => i_name
      , o_seqnum => o_seqnum
      , i_lang   => i_lang
      , o_id     => o_id
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
    scr_api_value_pkg.modify_value(
        i_id      => i_id
      , i_crit    => i_crit
      , i_score   => i_score
      , i_name    => i_name
      , i_lang    => i_lang
      , io_seqnum => io_seqnum
    );
end modify_value;

procedure remove_value(
    i_id        in      com_api_type_pkg.t_long_id
) is
begin              
    scr_api_value_pkg.remove_value(
        i_id => i_id
    );
end remove_value;

/*
 * scr_grade API 
 */

procedure add_grade(
    i_eval        in      com_api_type_pkg.t_long_id
  , i_total_score in      com_api_type_pkg.t_tiny_id
  , i_grade       in      com_api_type_pkg.t_name
  , i_name        in      com_api_type_pkg.t_name
  , o_seqnum         out  com_api_type_pkg.t_seqnum
  , i_lang        in      com_api_type_pkg.t_dict_value   default null
  , o_id             out  com_api_type_pkg.t_long_id
) is
begin
    scr_api_grade_pkg.add_grade(
        i_eval        => i_eval
      , i_total_score => i_total_score
      , i_grade       => i_grade
      , i_name        => i_name
      , o_seqnum      => o_seqnum
      , i_lang        => i_lang
      , o_id          => o_id
    );
end add_grade;

procedure modify_grade(
    i_id          in      com_api_type_pkg.t_long_id
  , i_eval        in      com_api_type_pkg.t_long_id
  , i_total_score in      com_api_type_pkg.t_tiny_id
  , i_grade       in      com_api_type_pkg.t_name
  , i_name        in      com_api_type_pkg.t_name
  , i_lang        in      com_api_type_pkg.t_dict_value   default null
  , io_seqnum     in   out  com_api_type_pkg.t_seqnum
) is
begin
    scr_api_grade_pkg.modify_grade(
        i_id          => i_id
      , i_eval        => i_eval      
      , i_total_score => i_total_score
      , i_grade       => i_grade
      , i_name        => i_name
      , i_lang        => i_lang
      , io_seqnum     => io_seqnum
    );
end modify_grade;

procedure remove_grade(
    i_id        in      com_api_type_pkg.t_long_id
) is
begin
    scr_api_grade_pkg.remove_grade(
        i_id => i_id
    );
end;

end scr_api_scheme_pkg;
/
