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

REISSUE_APPL_FLOW_ID            constant    com_api_type_pkg.t_tiny_id      := 5;

-- Minimal limit of days before card expiration date when reissuing is available (flow REISSUE_APPL_FLOW_ID)
LIMIT_OF_DAYS_FOR_REISSUE       constant    com_api_type_pkg.t_count        := 90;

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
    l_flow_id              com_api_type_pkg.t_tiny_id;
    l_days_left            com_api_type_pkg.t_count := 0;
begin
    -- Check if card can be reissued by the flow APPL_FLOW_ID
    -- or it can not since it is nearly expired
    l_flow_id   := app_api_application_pkg.get_appl_flow;
    l_days_left := trunc(last_day(io_card_old.expir_date))
                 - trunc(com_api_sttl_day_pkg.get_sysdate());

    trc_log_pkg.debug(
        i_text       => lower($$PLSQL_UNTI) || '.change_card_before: l_flow_id [#1], l_days_left [#2]'
      , i_env_param1 => l_flow_id
      , i_env_param2 => l_days_left
    );

    if  l_flow_id = REISSUE_APPL_FLOW_ID and l_days_left < LIMIT_OF_DAYS_FOR_REISSUE then
        com_api_error_pkg.raise_error(
            i_error      => 'IMPOSSIBLE_TO_REISSUE_NEARLY_EXPIRED_CARD'
          , i_env_param1 => iss_api_card_pkg.get_card_mask(i_card_number => io_card_new.card_number)
          , i_env_param2 => l_flow_id
          , i_env_param3 => case when l_days_left > 0 then l_days_left else 0 end
          , i_env_param4 => LIMIT_OF_DAYS_FOR_REISSUE
        );
    end if;
end change_card_before;

end;
/
