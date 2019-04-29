create or replace package vis_api_shared_data_pkg is

/*********************************************************
*  API for shared data of VISA messages
**********************************************************/

procedure collect_fin_message_params (
    io_params       in out nocopy   com_api_type_pkg.t_param_tab
);

end vis_api_shared_data_pkg;
/
