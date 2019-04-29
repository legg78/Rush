create or replace package com_ui_rate_type_pkg is
/************************************************************
 * UI for rate type <br />
 * Created by Khougaev A.(khougaev@bpc.ru)  at 23.04.2010  <br />
 * Last changed by $Author$  <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: COM_UI_RATE_TYPE_PKG <br />
 * @headcom
 ************************************************************/
procedure add (
    o_id                     out  com_api_type_pkg.t_tiny_id
  , o_seqnum                 out  com_api_type_pkg.t_tiny_id
  , i_rate_type           in      com_api_type_pkg.t_dict_value
  , i_inst_id             in      com_api_type_pkg.t_inst_id
  , i_use_cross_rate      in      com_api_type_pkg.t_boolean
  , i_use_base_rate       in      com_api_type_pkg.t_boolean
  , i_base_currency       in      com_api_type_pkg.t_curr_code
  , i_is_reversible       in      com_api_type_pkg.t_boolean
  , i_warning_level       in      number
  , i_use_double_typing   in      com_api_type_pkg.t_boolean
  , i_use_verification    in      com_api_type_pkg.t_boolean
  , i_adjust_exponent     in      com_api_type_pkg.t_boolean
  , i_exp_period          in      com_api_type_pkg.t_tiny_id
  , i_rounding_accuracy   in      com_api_type_pkg.t_tiny_id
);

procedure modify (
    i_id                  in     com_api_type_pkg.t_tiny_id
  , io_seqnum             in out com_api_type_pkg.t_tiny_id
  , i_use_cross_rate      in     com_api_type_pkg.t_boolean
  , i_use_base_rate       in     com_api_type_pkg.t_boolean
  , i_base_currency       in     com_api_type_pkg.t_curr_code
  , i_is_reversible       in     com_api_type_pkg.t_boolean
  , i_warning_level       in     number
  , i_use_double_typing   in     com_api_type_pkg.t_boolean
  , i_use_verification    in     com_api_type_pkg.t_boolean
  , i_adjust_exponent     in     com_api_type_pkg.t_boolean
  , i_exp_period          in     com_api_type_pkg.t_tiny_id
  , i_rounding_accuracy   in     com_api_type_pkg.t_tiny_id
);

procedure remove (
    i_id                  in     com_api_type_pkg.t_tiny_id
  , i_seqnum              in     com_api_type_pkg.t_tiny_id
) ;

end;
/
