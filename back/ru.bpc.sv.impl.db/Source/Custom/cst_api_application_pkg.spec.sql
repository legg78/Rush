create or replace package cst_api_application_pkg is

function get_appl_description(
    i_appl_id              in            com_api_type_pkg.t_long_id
  , i_flow_id              in            com_api_type_pkg.t_tiny_id
  , i_lang                 in            com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_full_desc;


procedure process_customer_before (
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_inst_id              in            com_api_type_pkg.t_inst_id
  , o_customer_id             out nocopy com_api_type_pkg.t_medium_id
);

procedure process_contract_before (
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_inst_id              in            com_api_type_pkg.t_inst_id
  , i_agent_id             in            com_api_type_pkg.t_short_id
  , i_customer_id          in            com_api_type_pkg.t_medium_id
  , o_contract_id             out nocopy com_api_type_pkg.t_medium_id
);

procedure process_account_before (
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_inst_id              in            com_api_type_pkg.t_inst_id
  , i_agent_id             in            com_api_type_pkg.t_short_id
  , i_customer_id          in            com_api_type_pkg.t_medium_id
  , io_contract_id         in out nocopy com_api_type_pkg.t_medium_id
);

procedure process_card_before (
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_customer_id          in            com_api_type_pkg.t_medium_id
  , io_contract_id         in out nocopy com_api_type_pkg.t_long_id
  , i_inst_id              in            com_api_type_pkg.t_inst_id
);

procedure process_person_before (
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , io_person_id           in out nocopy com_api_type_pkg.t_person_id
);

procedure process_company_before (
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_inst_id              in            com_api_type_pkg.t_inst_id
  , io_company_id          in out nocopy com_api_type_pkg.t_long_id
);

procedure process_contact_before (
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_parent_appl_data_id  in            com_api_type_pkg.t_long_id
  , i_object_id            in            com_api_type_pkg.t_long_id
  , i_entity_type          in            com_api_type_pkg.t_dict_value
  , i_person_id            in            com_api_type_pkg.t_long_id
  , i_appl_id              in            com_api_type_pkg.t_long_id
);

procedure process_address_before (
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_parent_appl_data_id  in            com_api_type_pkg.t_long_id
  , i_entity_type          in            com_api_type_pkg.t_dict_value
  , i_object_id            in            com_api_type_pkg.t_long_id
  , o_address_id              out nocopy com_api_type_pkg.t_medium_id
);

procedure process_merchant_before (
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_parent_appl_data_id  in            com_api_type_pkg.t_long_id
  , i_contract_id          in            com_api_type_pkg.t_medium_id
  , i_customer_id          in            com_api_type_pkg.t_medium_id
);

procedure process_terminal_before (
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_parent_appl_data_id  in            com_api_type_pkg.t_long_id
  , i_merchant_id          in            com_api_type_pkg.t_short_id
  , i_inst_id              in            com_api_type_pkg.t_tiny_id
  , i_contract_id          in            com_api_type_pkg.t_medium_id
  , i_customer_id          in            com_api_type_pkg.t_medium_id
);

-------------
procedure process_customer_after (
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_inst_id              in            com_api_type_pkg.t_inst_id
  , io_customer_id         in out nocopy com_api_type_pkg.t_medium_id
);

procedure process_contract_after (
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_inst_id              in            com_api_type_pkg.t_inst_id
  , i_agent_id             in            com_api_type_pkg.t_short_id
  , i_customer_id          in            com_api_type_pkg.t_medium_id
  , io_contract_id         in out nocopy com_api_type_pkg.t_medium_id
);

procedure process_account_after(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_inst_id              in            com_api_type_pkg.t_inst_id
  , i_agent_id             in            com_api_type_pkg.t_short_id
  , i_customer_id          in            com_api_type_pkg.t_medium_id
  , i_contract_id          in            com_api_type_pkg.t_medium_id
);

procedure process_card_after (
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_customer_id          in            com_api_type_pkg.t_medium_id
  , i_contract_id          in            com_api_type_pkg.t_long_id
  , i_inst_id              in            com_api_type_pkg.t_inst_id
);

procedure process_person_after (
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , io_person_id           in out nocopy com_api_type_pkg.t_person_id
);

procedure process_company_after (
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_inst_id              in            com_api_type_pkg.t_inst_id
  , io_company_id          in out nocopy com_api_type_pkg.t_long_id
);

procedure process_contact_after (
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_parent_appl_data_id  in            com_api_type_pkg.t_long_id
  , i_object_id            in            com_api_type_pkg.t_long_id
  , i_entity_type          in            com_api_type_pkg.t_dict_value
  , i_person_id            in            com_api_type_pkg.t_long_id
  , i_appl_id              in            com_api_type_pkg.t_long_id
);

procedure process_address_after (
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_parent_appl_data_id  in            com_api_type_pkg.t_long_id
  , i_entity_type          in            com_api_type_pkg.t_dict_value
  , i_object_id            in            com_api_type_pkg.t_long_id
  , io_address_id          in out nocopy com_api_type_pkg.t_medium_id
);

procedure process_merchant_after (
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_parent_appl_data_id  in            com_api_type_pkg.t_long_id
  , i_contract_id          in            com_api_type_pkg.t_medium_id
  , i_customer_id          in            com_api_type_pkg.t_medium_id
);

procedure process_terminal_after (
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_parent_appl_data_id  in            com_api_type_pkg.t_long_id
  , i_merchant_id          in            com_api_type_pkg.t_short_id
  , i_inst_id              in            com_api_type_pkg.t_tiny_id
  , i_contract_id          in            com_api_type_pkg.t_medium_id
  , i_customer_id          in            com_api_type_pkg.t_medium_id
);

procedure process_lnk_card_account_after (
   i_appl_data_id          in            com_api_type_pkg.t_long_id
 , i_account_id            in            com_api_type_pkg.t_long_id
 , i_entity_type           in            com_api_type_pkg.t_dict_value
 , i_object_id             in            com_api_type_pkg.t_long_id
);

procedure process_provider_host_after (
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_host_member_id       in            com_api_type_pkg.t_tiny_id
  , i_provider_id          in            com_api_type_pkg.t_short_id
  , i_object_id            in            com_api_type_pkg.t_long_id
);

procedure change_card_before(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_contract_id          in            com_api_type_pkg.t_medium_id
  , i_inst_id              in            com_api_type_pkg.t_tiny_id
  , i_cardholder_id        in            com_api_type_pkg.t_medium_id
  , io_card_old            in out nocopy iss_api_type_pkg.t_card
  , io_card_new            in out nocopy iss_api_type_pkg.t_card
);

end;
/
