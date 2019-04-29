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

/**********************************************************
 *
 * Add virtual account number into customer account
 * and application if required attribute and flexible
 * fields are present (only WOORI)
 *
 *********************************************************/
procedure process_account_after (
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_inst_id              in            com_api_type_pkg.t_inst_id
  , i_agent_id             in            com_api_type_pkg.t_short_id
  , i_customer_id          in            com_api_type_pkg.t_medium_id
  , i_contract_id          in            com_api_type_pkg.t_medium_id
) is
    l_name_format_id       com_api_type_pkg.t_short_id;
    l_virtual_acc_name     com_api_type_pkg.t_name;
    l_appl_id              com_api_type_pkg.t_long_id;
    l_product_id           com_api_type_pkg.t_short_id;
    l_account_id           com_api_type_pkg.t_account_id;
    l_flexible_field_id    com_api_type_pkg.t_long_id;
begin
    trc_log_pkg.debug (
        i_text => 'cst_api_application_pkg.process_account_after'
    );

    l_appl_id := app_api_application_pkg.get_appl_id;

    for c in (
                select d.element_value  as account_number
                     , d.parent_id      as parent_id
                  from app_data         d
                     , app_element      e
                     , acc_account      a
                 where e.id             = d.element_id
                   and e.name           = 'ACCOUNT_NUMBER'
                   and d.element_value  = a.account_number
                   and a.account_type in (
                                            acc_api_const_pkg.ACCOUNT_TYPE_CREDIT   --'ACTP0130'
                                          , cst_woo_const_pkg.ACCT_TYPE_PREPAID_VND --'ACTP0140'
                                         )
                   and d.appl_id        = l_appl_id
    ) loop
        trc_log_pkg.debug (
            i_text          => 'Begin adding Virtual account for account number [#1]'
          , i_env_param1    => c.account_number
        );

        l_account_id := acc_api_account_pkg.get_account_id(
                            i_account_number => c.account_number
                        );

        l_product_id := prd_api_product_pkg.get_product_id(
                            i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                          , i_object_id    => l_account_id
                          , i_inst_id      => i_inst_id
                        );

        l_virtual_acc_name := com_api_flexible_data_pkg.get_flexible_value(
                                  i_field_name  => cst_woo_const_pkg.FLEX_VIRTUAL_ACCOUNT_NUMBER
                                , i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                , i_object_id   => l_account_id
                              );

        -- If FLEX_VIRTUAL_ACCOUNT_NUMBER already set then will not update this
        if l_virtual_acc_name is null then

            begin

                l_name_format_id := prd_api_product_pkg.get_attr_value_number(
                                        i_product_id  => l_product_id
                                      , i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                      , i_object_id   => l_account_id
                                      , i_attr_name   => cst_woo_const_pkg.ATTR_ACC_VIRTUAL_NUMBER_FORMAT
                                      , i_params      => app_api_application_pkg.g_params
                                      , i_inst_id     => i_inst_id
                                    );

                l_virtual_acc_name := rul_api_name_pkg.get_name(
                                          i_format_id => l_name_format_id
                                        , i_param_tab => app_api_application_pkg.g_params
                                      );

            exception
                when com_api_error_pkg.e_application_error then

                    trc_log_pkg.debug (
                        i_text           => 'Error [#1] when get attribute [#2] for appl_data_id [#3]'
                        , i_env_param1   => com_api_error_pkg.get_last_error
                        , i_env_param2   => cst_woo_const_pkg.ATTR_ACC_VIRTUAL_NUMBER_FORMAT
                        , i_env_param3   => i_appl_data_id
                        , i_entity_type  => app_api_const_pkg.ENTITY_TYPE_APPLICATION
                        , i_object_id    => l_appl_id
                    );

            end;

            if l_virtual_acc_name is not null then

                -- For account
                com_api_flexible_data_pkg.set_flexible_value(
                    i_field_name  => cst_woo_const_pkg.FLEX_VIRTUAL_ACCOUNT_NUMBER
                  , i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                  , i_object_id   => l_account_id
                  , i_field_value => l_virtual_acc_name
                );

                -- For application
                app_api_application_pkg.add_element(
                    i_element_name           => 'FLEXIBLE_FIELD'
                  , i_parent_id              => c.parent_id
                  , i_element_value          => null
                  , o_appl_data_id           => l_flexible_field_id
                );

                app_api_application_pkg.add_element(
                    i_element_name           => 'FLEXIBLE_FIELD_NAME'
                  , i_parent_id              => l_flexible_field_id
                  , i_element_value          => com_api_flexible_data_pkg.get_flexible_field_label(
                                                    i_field_name  => cst_woo_const_pkg.FLEX_VIRTUAL_ACCOUNT_NUMBER
                                                  , i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                                )
                );

                app_api_application_pkg.add_element(
                    i_element_name           => 'FLEXIBLE_FIELD_VALUE'
                  , i_parent_id              => l_flexible_field_id
                  , i_element_value          => l_virtual_acc_name
                );

            end if;

        else

            trc_log_pkg.debug (
                i_text           => 'Flexible field [#1] already set for account number [#2]: [#3]'
                , i_env_param1   => com_api_flexible_data_pkg.get_flexible_field_label(
                                        i_field_name  => cst_woo_const_pkg.FLEX_VIRTUAL_ACCOUNT_NUMBER
                                      , i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                    )
                , i_env_param2   => c.account_number
                , i_env_param3   => l_virtual_acc_name
                , i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                , i_object_id    => l_account_id
            );

        end if;
    end loop;
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
