create or replace package body cst_api_application_pkg is
/*********************************************************
*  Custom API for application <br />
*  Created by Kopachev D.(kopachev@bpcbt.com) at 13.12.2011 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: cst_api_application_pkg <br />
*  @headcom
**********************************************************/

function get_appl_description(
    i_appl_id              in            com_api_type_pkg.t_long_id
  , i_flow_id              in            com_api_type_pkg.t_tiny_id
  , i_lang                 in            com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_full_desc is
begin
    trc_log_pkg.debug (
        i_text       => 'cst_api_application_pkg.get_appl_description [#1] [#2] [#3]'
      , i_env_param1 => i_appl_id
      , i_env_param2 => i_flow_id
      , i_env_param3 => i_lang
    );
    return null;
end;

procedure process_customer_before (
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_inst_id              in            com_api_type_pkg.t_inst_id
  , o_customer_id             out nocopy com_api_type_pkg.t_medium_id
) is
begin
    trc_log_pkg.debug (
        i_text => 'cst_api_application_pkg.process_customer_before'
    );
end;

procedure process_contract_before (
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_inst_id              in            com_api_type_pkg.t_inst_id
  , i_agent_id             in            com_api_type_pkg.t_short_id
  , i_customer_id          in            com_api_type_pkg.t_medium_id
  , o_contract_id             out nocopy com_api_type_pkg.t_medium_id
) is
begin
    trc_log_pkg.debug (
        i_text => 'cst_api_application_pkg.process_contract_before'
    );
end;

procedure process_account_before (
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_inst_id              in            com_api_type_pkg.t_inst_id
  , i_agent_id             in            com_api_type_pkg.t_short_id
  , i_customer_id          in            com_api_type_pkg.t_medium_id
  , io_contract_id         in out nocopy com_api_type_pkg.t_medium_id
) is
begin
    trc_log_pkg.debug (
        i_text => 'cst_api_application_pkg.process_account_before'
    );
end;

procedure process_card_before (
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_customer_id          in            com_api_type_pkg.t_medium_id
  , io_contract_id         in out nocopy com_api_type_pkg.t_long_id
  , i_inst_id              in            com_api_type_pkg.t_inst_id
) is
begin
    trc_log_pkg.debug (
        i_text => 'cst_api_application_pkg.process_card_before'
    );
end;

procedure process_person_before (
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , io_person_id           in out nocopy com_api_type_pkg.t_person_id
) is
begin
    trc_log_pkg.debug (
        i_text => 'cst_api_application_pkg.process_person_before'
    );
end;

procedure process_company_before (
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_inst_id              in            com_api_type_pkg.t_inst_id
  , io_company_id          in out nocopy com_api_type_pkg.t_long_id
) is
begin
    trc_log_pkg.debug (
        i_text => 'cst_api_application_pkg.process_company_before'
    );
end;

procedure process_contact_before (
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_parent_appl_data_id  in            com_api_type_pkg.t_long_id
  , i_object_id            in            com_api_type_pkg.t_long_id
  , i_entity_type          in            com_api_type_pkg.t_dict_value
  , i_person_id            in            com_api_type_pkg.t_long_id
  , i_appl_id              in            com_api_type_pkg.t_long_id
) is
begin
    trc_log_pkg.debug (
        i_text => 'cst_api_application_pkg.process_contact_before'
    );
end;

procedure process_address_before (
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_parent_appl_data_id  in            com_api_type_pkg.t_long_id
  , i_entity_type          in            com_api_type_pkg.t_dict_value
  , i_object_id            in            com_api_type_pkg.t_long_id
  , o_address_id              out nocopy com_api_type_pkg.t_medium_id
) is
begin
    trc_log_pkg.debug (
        i_text => 'cst_api_application_pkg.process_address_before'
    );
end;

procedure process_merchant_before (
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_parent_appl_data_id  in            com_api_type_pkg.t_long_id
  , i_contract_id          in            com_api_type_pkg.t_medium_id
  , i_customer_id          in            com_api_type_pkg.t_medium_id
) is
begin
    trc_log_pkg.debug (
        i_text => 'cst_api_application_pkg.process_merchant_before'
    );
end;

procedure process_terminal_before (
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_parent_appl_data_id  in            com_api_type_pkg.t_long_id
  , i_merchant_id          in            com_api_type_pkg.t_short_id
  , i_inst_id              in            com_api_type_pkg.t_tiny_id
  , i_contract_id          in            com_api_type_pkg.t_medium_id
  , i_customer_id          in            com_api_type_pkg.t_medium_id
) is
begin
    trc_log_pkg.debug (
        i_text => 'cst_api_application_pkg.process_terminal_before'
    );
end;


procedure process_customer_after (
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_inst_id              in            com_api_type_pkg.t_inst_id
  , io_customer_id         in out nocopy com_api_type_pkg.t_medium_id
) is
begin
    trc_log_pkg.debug (
        i_text => 'cst_api_application_pkg.process_customer_after, io_customer_id='||io_customer_id
    );
end;

procedure process_contract_after (
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_inst_id              in            com_api_type_pkg.t_inst_id
  , i_agent_id             in            com_api_type_pkg.t_short_id
  , i_customer_id          in            com_api_type_pkg.t_medium_id
  , io_contract_id         in out nocopy com_api_type_pkg.t_medium_id
) is
begin
    trc_log_pkg.debug (
        i_text => 'cst_api_application_pkg.process_contract_after, io_contract_id='||io_contract_id
    );
end;

procedure process_account_after (
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_inst_id              in            com_api_type_pkg.t_inst_id
  , i_agent_id             in            com_api_type_pkg.t_short_id
  , i_customer_id          in            com_api_type_pkg.t_medium_id
  , i_contract_id          in            com_api_type_pkg.t_medium_id
) is
begin
    trc_log_pkg.debug (
        i_text => 'cst_api_application_pkg.process_account_after'
    );
end;

procedure process_card_after (
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_customer_id          in            com_api_type_pkg.t_medium_id
  , i_contract_id          in            com_api_type_pkg.t_long_id
  , i_inst_id              in            com_api_type_pkg.t_inst_id
) is
begin
    trc_log_pkg.debug (
        i_text => 'cst_api_application_pkg.process_card_after'
    );
end;

procedure process_person_after (
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , io_person_id           in out nocopy com_api_type_pkg.t_person_id
) is
begin
    trc_log_pkg.debug (
        i_text => 'cst_api_application_pkg.process_person_after'
    );
end;

procedure process_company_after (
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_inst_id              in            com_api_type_pkg.t_inst_id
  , io_company_id          in out nocopy com_api_type_pkg.t_long_id
) is
begin
    trc_log_pkg.debug (
        i_text => 'cst_api_application_pkg.process_company_after'
    );
end;

procedure process_contact_after (
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_parent_appl_data_id  in            com_api_type_pkg.t_long_id
  , i_object_id            in            com_api_type_pkg.t_long_id
  , i_entity_type          in            com_api_type_pkg.t_dict_value
  , i_person_id            in            com_api_type_pkg.t_long_id
  , i_appl_id              in            com_api_type_pkg.t_long_id
) is
begin
    trc_log_pkg.debug (
        i_text => 'cst_api_application_pkg.process_contact_after'
    );
end;

procedure process_address_after (
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_parent_appl_data_id  in            com_api_type_pkg.t_long_id
  , i_entity_type          in            com_api_type_pkg.t_dict_value
  , i_object_id            in            com_api_type_pkg.t_long_id
  , io_address_id          in out nocopy com_api_type_pkg.t_medium_id
) is
begin
    trc_log_pkg.debug (
        i_text => 'cst_api_application_pkg.process_address_after, io_address_id='||io_address_id
    );
end;

procedure process_merchant_after (
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_parent_appl_data_id  in            com_api_type_pkg.t_long_id
  , i_contract_id          in            com_api_type_pkg.t_medium_id
  , i_customer_id          in            com_api_type_pkg.t_medium_id
) is
begin
    trc_log_pkg.debug (
        i_text => 'cst_api_application_pkg.process_merchant_after'
    );
end;

procedure process_terminal_after (
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_parent_appl_data_id  in            com_api_type_pkg.t_long_id
  , i_merchant_id          in            com_api_type_pkg.t_short_id
  , i_inst_id              in            com_api_type_pkg.t_tiny_id
  , i_contract_id          in            com_api_type_pkg.t_medium_id
  , i_customer_id          in            com_api_type_pkg.t_medium_id
) is
begin
    trc_log_pkg.debug (
        i_text => 'cst_api_application_pkg.process_terminal_after'
    );
end;

procedure process_lnk_card_account_after (
   i_appl_data_id          in            com_api_type_pkg.t_long_id
 , i_account_id            in            com_api_type_pkg.t_long_id
 , i_entity_type           in            com_api_type_pkg.t_dict_value
 , i_object_id             in            com_api_type_pkg.t_long_id
) is
begin
    trc_log_pkg.debug (
        i_text => 'cst_api_application_pkg.process_lnk_card_account_after'
    );
end;

procedure process_provider_host_after (
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_host_member_id       in            com_api_type_pkg.t_tiny_id
  , i_provider_id          in            com_api_type_pkg.t_short_id
  , i_object_id            in            com_api_type_pkg.t_long_id
) is
begin
    trc_log_pkg.debug (
        i_text => 'cst_api_application_pkg.process_provider_host_after'
    );
end;

procedure change_card_before(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_contract_id          in            com_api_type_pkg.t_medium_id
  , i_inst_id              in            com_api_type_pkg.t_tiny_id
  , i_cardholder_id        in            com_api_type_pkg.t_medium_id
  , io_card_old            in out nocopy iss_api_type_pkg.t_card
  , io_card_new            in out nocopy iss_api_type_pkg.t_card
) is
begin
    null;
end change_card_before;

end;
/
