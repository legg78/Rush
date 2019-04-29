create or replace package body din_api_rule_proc_pkg is
/*********************************************************
*  Diners Club operation rules processing <br />
*  Created by Alalykin A.(alalykin@bpcbt.com) at 06.07.2016 <br />
*  Last changed by $Author: alalykin $ <br />
*  $LastChangedDate:: 2016-06-07 18:00:00 +0300#$ <br />
*  Revision: $LastChangedRevision: 1 $ <br />
*  Module: DIN_API_RULE_PROC_PKG <br />
*  @headcom
**********************************************************/

/*
 * Creation of Diners Club financial message during operation processing.
 */
procedure create_fin_message
is
    l_fin_id                        com_api_type_pkg.t_long_id;
    l_inst_id                       com_api_type_pkg.t_inst_id;
    l_network_id                    com_api_type_pkg.t_network_id;
    l_message_status                com_api_type_pkg.t_dict_value;
begin
    if opr_api_shared_data_pkg.g_auth.id is not null then
        begin
            select id
              into l_fin_id
              from din_fin_message
             where id = opr_api_shared_data_pkg.g_auth.id;
        exception
            when no_data_found then
                null;
        end;

        if l_fin_id is not null then
            trc_log_pkg.debug(
                i_text       => 'Outgoing Diners Club message with ID [#2] is already presented for operation [#1]'
              , i_env_param1 => opr_api_shared_data_pkg.g_auth.id
              , i_env_param2 => l_fin_id
            );
        else
            l_inst_id :=
                opr_api_shared_data_pkg.get_param_num(
                    i_name        => 'INST_ID'
                  , i_mask_error  => com_api_type_pkg.TRUE
                  , i_error_value => null
                );
            l_network_id :=
                opr_api_shared_data_pkg.get_param_num(
                    i_name        => 'NETWORK_ID'
                  , i_mask_error  => com_api_type_pkg.TRUE
                  , i_error_value => null
                );
            l_message_status :=
                opr_api_shared_data_pkg.get_param_char(
                    i_name        => 'MESSAGE_STATUS'
                  , i_mask_error  => com_api_type_pkg.TRUE
                  , i_error_value => null
                );

            din_api_fin_message_pkg.create_from_auth(
                i_auth_rec        => opr_api_shared_data_pkg.g_auth
              , i_inst_id         => l_inst_id
              , i_network_id      => l_network_id
              , i_message_status  => l_message_status
              , io_fin_message_id => opr_api_shared_data_pkg.g_auth.id
            );
        end if;
    end if;
end create_fin_message;

end;
/
