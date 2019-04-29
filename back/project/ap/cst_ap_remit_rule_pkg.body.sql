create or replace package body cst_ap_remit_rule_pkg is
/*********************************************************
*  Remittance card status change  <br />
*  Created by Vasilyeva Y.(vasilieva@bpcsv.com)  at 21.02.2019 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: cst_sat_recon_upload <br />
*  @headcom
**********************************************************/

gc_addl_virt_card_Number      VARCHAR2(3) := '017'; -- virtual card number

procedure change_virtual_card_status is 


    l_result_status                 com_api_type_pkg.t_name;
    l_addl_data                     com_api_type_pkg.t_full_desc;
    l_new_card_id                   com_api_type_pkg.t_medium_id;
    l_new_card_num                  com_api_type_pkg.t_card_number;
    l_new_card_instance_id          com_api_type_pkg.t_medium_id;
    
begin

    l_result_status   := opr_api_shared_data_pkg.get_param_char('CARD_STATUS');                     
    l_addl_data       := opr_api_shared_data_pkg.g_auth.addl_data;  
    l_new_card_num    := cst_ap_rule_util_pkg.get_auth_addl_data(
                             i_addl_data_str  => l_addl_data
                           , i_addl_data_tag  => gc_addl_virt_card_Number
                         );   --Virtual            
                         
    begin
        select card_id 
          into l_new_card_id
          from iss_card_number icn
         where card_number = l_new_card_num;
    exception when no_data_found then 
        trc_log_pkg.error(
            i_text       => 'Virtial card number [#1] is not found'
          , i_env_param1 => l_new_card_num
        );
        opr_api_shared_data_pkg.rollback_process(
            i_id     => opr_api_shared_data_pkg.get_operation().id
          , i_status => opr_api_const_pkg.OPERATION_STATUS_EXCEPTION
          , i_reason => aup_api_const_pkg.RESP_CODE_CARD_NOT_FOUND
        );
    end;
    
    begin
        select max(id) 
          into l_new_card_instance_id
          from iss_card_instance
         where card_id = l_new_card_id;
    exception when no_data_found then 
        trc_log_pkg.error(
            i_text       => 'Instance for virtial card number [#1] and card id [#2] is not found'
          , i_env_param1 => l_new_card_num
          , i_env_param2 => l_new_card_id
        );
    end;
    
    iss_api_card_instance_pkg.change_card_state(
        i_id          => l_new_card_instance_id
      , i_card_state  => l_result_status
      , i_raise_error => com_api_const_pkg.TRUE
    );
end;

end cst_ap_remit_rule_pkg;
/

