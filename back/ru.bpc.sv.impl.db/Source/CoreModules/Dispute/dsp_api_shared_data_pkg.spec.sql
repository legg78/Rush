create or replace package dsp_api_shared_data_pkg is
/************************************************************
 * API for Dispute shared data <br />
 * Created by Maslov I.(maslov@bpcbt.com)  at 27.05.2013 <br />
 * Module: DSP_API_SHARED_DATA_PKG <br />
 * @headcom
 ***********************************************************/

function get_id return com_api_type_pkg.t_long_id;

function get_global_params return com_api_type_pkg.t_param_tab;

procedure clear_params;

procedure set_param (
    i_name                 in     com_api_type_pkg.t_name
  , i_value                in     com_api_type_pkg.t_name
);

procedure set_param (
    i_name                 in     com_api_type_pkg.t_name
  , i_value                in     number
);

procedure set_param (
    i_name                 in     com_api_type_pkg.t_name
  , i_value                in     date
);

function select_condition (
    i_mod                  in     com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_boolean;

procedure set_cur_statement (
    i_cur_stat             in     clob
);

function get_cur_statement return clob;

function get_param_num (
    i_name                 in     com_api_type_pkg.t_name
  , i_mask_error           in     com_api_type_pkg.t_boolean    default com_api_type_pkg.FALSE
  , i_error_value          in     com_api_type_pkg.t_name       default null
) return number;

function get_param_date (
    i_name                 in     com_api_type_pkg.t_name
  , i_mask_error           in     com_api_type_pkg.t_boolean    default com_api_type_pkg.FALSE
  , i_error_value          in     com_api_type_pkg.t_name       default null
) return date;

function get_param_char (
    i_name                 in     com_api_type_pkg.t_name
  , i_mask_error           in     com_api_type_pkg.t_boolean    default com_api_type_pkg.FALSE
  , i_error_value          in     com_api_type_pkg.t_name       default null
) return com_api_type_pkg.t_name;

function get_masked_param_num (
    i_name                 in     com_api_type_pkg.t_name
) return number;

function get_masked_param_date (
    i_name                 in     com_api_type_pkg.t_name
) return date;

function get_masked_param_char(
    i_name                 in     com_api_type_pkg.t_name
) return com_api_type_pkg.t_name;

end dsp_api_shared_data_pkg;
/
