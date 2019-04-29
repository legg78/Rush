create or replace package scr_api_evaluation_pkg 
is
/************************************************************
 * Scroing module common package <br />
 * Created by Nick (shalnov@bpcbt.com)  at 19.03.2018 <br />
 * Module: SCR_API_EVALUATION_PKG <br />
 * @headcom
 ***********************************************************/

procedure add_evaluation(
    i_name    in      com_api_type_pkg.t_name  
  , i_inst_id in      com_api_type_pkg.t_inst_id      default null
  , o_seqnum     out  com_api_type_pkg.t_seqnum
  , i_lang    in      com_api_type_pkg.t_dict_value   default null
  , o_id         out  com_api_type_pkg.t_long_id
);

procedure modify_evaluation(
    i_id      in      com_api_type_pkg.t_long_id
  , i_inst_id in      com_api_type_pkg.t_inst_id      default null
  , i_name    in      com_api_type_pkg.t_name
  , i_lang    in      com_api_type_pkg.t_dict_value   default null
  , io_seqnum in out  com_api_type_pkg.t_seqnum
);

procedure remove_evaluation(
    i_id      in      com_api_type_pkg.t_long_id
  , i_force   in      com_api_type_pkg.t_boolean      default null
);

end scr_api_evaluation_pkg;
/
