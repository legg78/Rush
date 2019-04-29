create or replace package scr_api_grade_pkg 
is
/************************************************************
 * Scroing module common package <br />
 * Created by Nick (shalnov@bpcbt.com)  at 19.03.2018 <br />
 * Module: SCR_API_GRADE_PKG <br />
 * @headcom
 ***********************************************************/
 
procedure add_grade(
    i_eval        in      com_api_type_pkg.t_long_id
  , i_total_score in      com_api_type_pkg.t_tiny_id
  , i_grade       in      com_api_type_pkg.t_name
  , i_name        in      com_api_type_pkg.t_name
  , o_seqnum         out  com_api_type_pkg.t_seqnum
  , i_lang        in      com_api_type_pkg.t_dict_value   default null
  , o_id             out  com_api_type_pkg.t_long_id
);

procedure modify_grade(
    i_id        in      com_api_type_pkg.t_long_id
  , i_eval        in      com_api_type_pkg.t_long_id
  , i_total_score in      com_api_type_pkg.t_tiny_id
  , i_grade       in      com_api_type_pkg.t_name
  , i_name      in      com_api_type_pkg.t_name
  , i_lang      in      com_api_type_pkg.t_dict_value   default null
  , io_seqnum in   out  com_api_type_pkg.t_seqnum
);

procedure remove_grade(
    i_id        in      com_api_type_pkg.t_long_id
);

end scr_api_grade_pkg;
/
