create or replace package body mup_api_shared_data_pkg is

/*********************************************************
*  API for shared data of MUP Card messages
**********************************************************/

procedure collect_fin_message_params (
    io_params       in out nocopy com_api_type_pkg.t_param_tab
  , i_is_incoming   in            com_api_type_pkg.t_boolean
) is
    l_oper_id                     com_api_type_pkg.t_long_id;
    l_tag_id                      com_api_type_pkg.t_short_id;
    l_is_mup_sms_message          com_api_type_pkg.t_boolean  := com_api_const_pkg.FALSE;
begin
    l_oper_id := opr_api_shared_data_pkg.get_operation().id;

    if i_is_incoming = com_api_const_pkg.FALSE then
        l_tag_id  := aup_api_tag_pkg.find_tag_by_reference('DF8A75');
        if aup_api_tag_pkg.get_tag_value(
               i_auth_id => l_oper_id
             , i_tag_id  => l_tag_id
           ) = '1'  -- for MUP SMS message
        then
            l_is_mup_sms_message := com_api_const_pkg.TRUE;
        end if;
    end if;

    rul_api_param_pkg.set_param(
        i_value    => l_is_mup_sms_message
      , i_name     => 'IS_MUP_SMS_MESSAGE'
      , io_params  => io_params
    );

end collect_fin_message_params;

end mup_api_shared_data_pkg;
/
