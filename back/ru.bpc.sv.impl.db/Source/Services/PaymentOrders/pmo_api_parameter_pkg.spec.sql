create or replace package pmo_api_parameter_pkg as
/************************************************************
 * UI for Payment Order parameters <br />
 * Created by Fomichev A.(fomichev@bpcbt.com)  at 31.10.2011  <br />
 * Last changed by $Author$  <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: pmo_api_parameter_pkg <br />
 * @headcom
 ************************************************************/
procedure get_purp_param_value(
    i_param_name in     com_api_type_pkg.t_name
  , i_purpose_id in     com_api_type_pkg.t_short_id
  , o_value         out varchar2
);

procedure get_purp_param_value(
    i_param_name in     com_api_type_pkg.t_name
  , i_purpose_id in     com_api_type_pkg.t_short_id
  , o_value         out number
);

procedure get_purp_param_value(
    i_param_name in     com_api_type_pkg.t_name
  , i_purpose_id in     com_api_type_pkg.t_short_id
  , o_value         out date
);

function get_purp_param_char(
    i_param_name in     com_api_type_pkg.t_name
  , i_purpose_id in     com_api_type_pkg.t_short_id
) return varchar2;

function get_purp_param_num(
    i_param_name in     com_api_type_pkg.t_name
  , i_purpose_id in     com_api_type_pkg.t_short_id
) return number;

function get_purp_param_date(
    i_param_name in     com_api_type_pkg.t_name
  , i_purpose_id in     com_api_type_pkg.t_short_id
) return  date;

function get_pmo_parameter_id(
    i_param_name        in     com_api_type_pkg.t_name
  , i_inst_id               in     com_api_type_pkg.t_inst_id    default null
  , i_mask_error            in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_short_id;

end;
/
