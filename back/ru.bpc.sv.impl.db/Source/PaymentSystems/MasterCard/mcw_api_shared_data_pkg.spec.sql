create or replace package mcw_api_shared_data_pkg is

/*********************************************************
*  API for shared data of Master Card messages
**********************************************************/

    g_fin_rec          mcw_api_type_pkg.t_fin_rec;
    g_params           com_api_type_pkg.t_param_tab;

procedure collect_fin_message_params(
    io_params                   in out nocopy com_api_type_pkg.t_param_tab
);

procedure set_fin(
    i_flash_fin_if_no_operation in            com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
);

function get_country_code     return mcw_api_type_pkg.t_de043_6;

function get_fin              return mcw_api_type_pkg.t_fin_rec;

end mcw_api_shared_data_pkg;
/
