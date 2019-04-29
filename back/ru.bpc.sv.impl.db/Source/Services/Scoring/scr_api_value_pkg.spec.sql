create or replace package scr_api_value_pkg 
is
/************************************************************
 * Scroing module common package <br />
 * Created by Nick (shalnov@bpcbt.com)  at 19.03.2018 <br />
 * Module: SCR_API_VALUE_PKG <br />
 * @headcom
 ***********************************************************/

procedure add_value(
    i_crit      in      com_api_type_pkg.t_long_id
  , i_score     in      com_api_type_pkg.t_tiny_id
  , i_name      in      com_api_type_pkg.t_name
  , o_seqnum       out  com_api_type_pkg.t_seqnum
  , i_lang      in      com_api_type_pkg.t_dict_value   default null
  , o_id           out  com_api_type_pkg.t_long_id
);

procedure modify_value(
    i_id        in      com_api_type_pkg.t_long_id
  , i_crit      in      com_api_type_pkg.t_long_id
  , i_score     in      com_api_type_pkg.t_tiny_id
  , i_name      in      com_api_type_pkg.t_name
  , i_lang      in      com_api_type_pkg.t_dict_value   default null
  , io_seqnum in   out  com_api_type_pkg.t_seqnum
);

procedure remove_value(
    i_id        in      com_api_type_pkg.t_long_id
);

end scr_api_value_pkg;
/
