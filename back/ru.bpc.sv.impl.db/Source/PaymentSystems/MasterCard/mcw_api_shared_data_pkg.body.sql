create or replace package body mcw_api_shared_data_pkg is

/*********************************************************
*  API for shared data of Master Card messages
**********************************************************/

procedure collect_fin_message_params(
    io_params                   in out nocopy com_api_type_pkg.t_param_tab
) is
begin
    null;
end collect_fin_message_params;

procedure set_fin(
    i_flash_fin_if_no_operation in            com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
)  is
    l_operation_id                            com_api_type_pkg.t_long_id;
begin
    l_operation_id := dsp_api_shared_data_pkg.get_param_num(i_name => 'OPERATION_ID');

    if l_operation_id is not null then
        mcw_api_fin_pkg.get_fin(
            i_id      => l_operation_id
          , o_fin_rec => g_fin_rec
        );

    else
        trc_log_pkg.debug('OPERATION_ID cannot be retrieved from (dsp)cache');
        if i_flash_fin_if_no_operation = com_api_const_pkg.TRUE then
            g_fin_rec := null;
            trc_log_pkg.debug('Variable g_fin_rec flashed');
        end if;
    end if;
end set_fin;

function get_country_code
    return mcw_api_type_pkg.t_de043_6
    is
begin
    if g_fin_rec.id is null then
        trc_log_pkg.debug('Variable g_fin_rec is empty');
        return null;

    elsif g_fin_rec.de043_6 is null then
        trc_log_pkg.debug('Digital code of a country is empty(g_fin_rec[' || g_fin_rec.id || '])');
        return null;

    else
        return com_api_country_pkg.get_country_code_by_name(
                   i_name => g_fin_rec.de043_6
               );
    end if;
end get_country_code;

function get_fin
    return mcw_api_type_pkg.t_fin_rec
is
    l_fin_msg                 mcw_api_type_pkg.t_fin_rec;
    l_operation_id            com_api_type_pkg.t_long_id;
begin
    l_operation_id := dsp_api_shared_data_pkg.get_param_num(i_name => 'OPERATION_ID');

    if l_operation_id is not null then
        mcw_api_fin_pkg.get_fin(
            i_id      => l_operation_id
          , o_fin_rec => l_fin_msg
        );
    else
        trc_log_pkg.debug('OPERATION_ID cannot be retrieved from (dsp)cache');
        return null;
    end if;

    return l_fin_msg;
end get_fin;

end mcw_api_shared_data_pkg;
/
