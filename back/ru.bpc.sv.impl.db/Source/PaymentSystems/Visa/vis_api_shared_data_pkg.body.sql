create or replace package body vis_api_shared_data_pkg is

/*********************************************************
*  API for shared data of VISA messages
**********************************************************/

procedure collect_fin_message_params (
    io_params       in out nocopy com_api_type_pkg.t_param_tab
) is
    l_oper_id                     com_api_type_pkg.t_long_id;
    l_dispute_status              com_api_type_pkg.t_byte_char;
begin
    l_oper_id := opr_api_shared_data_pkg.get_operation().id;

    begin
        select dispute_status
          into l_dispute_status
          from vis_vcr_advice
         where id = l_oper_id;

    exception when no_data_found then
        null;
    end;

    rul_api_param_pkg.set_param(
        i_value    => l_dispute_status
      , i_name     => 'DISPUTE_STATUS'
      , io_params  => io_params
    );

end collect_fin_message_params;

end vis_api_shared_data_pkg;
/
