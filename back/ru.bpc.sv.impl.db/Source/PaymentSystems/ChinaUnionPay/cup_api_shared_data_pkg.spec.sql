create or replace package cup_api_shared_data_pkg is

/*********************************************************
*  API for shared data of CUP messages
**********************************************************/

procedure collect_fin_message_params (
    io_params       in out nocopy   com_api_type_pkg.t_param_tab
);

end cup_api_shared_data_pkg;
/
