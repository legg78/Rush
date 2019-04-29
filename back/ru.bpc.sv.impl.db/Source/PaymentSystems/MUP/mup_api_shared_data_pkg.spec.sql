create or replace package mup_api_shared_data_pkg is

/*********************************************************
*  API for shared data of MUP Card messages
**********************************************************/

procedure collect_fin_message_params (
    io_params       in out nocopy com_api_type_pkg.t_param_tab
  , i_is_incoming   in            com_api_type_pkg.t_boolean
);

end mup_api_shared_data_pkg;
/
