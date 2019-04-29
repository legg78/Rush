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
l_reserved_acc_name     com_api_type_pkg.t_name;
l_param_tab             com_api_type_pkg.t_param_tab;
l_account_id            com_api_type_pkg.t_name;
l_naming_format         com_api_type_pkg.t_medium_id;
l_product_id            com_api_type_pkg.t_short_id;
l_eff_date              date;

begin
    trc_log_pkg.debug (
        i_text => 'cst_api_application_pkg.process_card_after - i_appl_data_id : ' || i_appl_data_id
    );

    l_eff_date := com_api_sttl_day_pkg.get_sysdate;

    l_product_id := prd_api_contract_pkg.get_contract(i_contract_id => i_contract_id).product_id;

    l_naming_format := coalesce(l_naming_format,
        prd_api_product_pkg.get_attr_value_number(
            i_entity_type        => prd_api_const_pkg.ENTITY_TYPE_PRODUCT
          , i_object_id          => l_product_id
          , i_attr_name          => cst_cfc_api_const_pkg.CST_CFC_POOL_ACC_NUM_FORMAT
          , i_service_id         => cst_cfc_api_const_pkg.CARD_MAINTENANCE_SERVICE_ID
          , i_eff_date           => l_eff_date
          , i_inst_id            => i_inst_id
          , i_mask_error         => com_api_type_pkg.TRUE
          , i_use_default_value  => com_api_const_pkg.TRUE
          , i_default_value      => null
        ));

    if nvl(l_naming_format, 0) <= 0 then
        trc_log_pkg.info(
            i_text       => 'ENTITY_NAME_FORMAT_NOT_DEFINED'
          , i_env_param1 => iss_api_const_pkg.ENTITY_TYPE_CARD
        );
        return;
    else
        for i in (
            select c.id, c.split_hash, c.inst_id
              from iss_card   c
                 , app_object o
                 , app_application a
             where c.contract_id  = i_contract_id
               and c.customer_id  = i_customer_id
               and o.entity_type  = iss_api_const_pkg.ENTITY_TYPE_CARD
               and o.appl_id      = a.id
               and o.object_id    = c.id
               and a.flow_id      = app_api_const_pkg.FLOW_ID_ISS_POOL_CARD
        )
        loop
            -- get next account id
            l_account_id := acc_account_seq.nextval;

            rul_api_param_pkg.set_param (
                i_name      => 'ACCOUNT_ID'
              , i_value     => l_account_id
              , io_params   => l_param_tab
            );

            l_reserved_acc_name :=
                rul_api_name_pkg.get_name(
                    i_format_id => l_naming_format
                  , i_param_tab => l_param_tab
                );

            trc_log_pkg.debug (
                i_text          => 'Generate account number [#1] for car_id [#2] with naming format [#3]'
              , i_env_param1    => l_reserved_acc_name
              , i_env_param2    => i.id
              , i_env_param3    => l_naming_format
            );

            if l_reserved_acc_name is not null then
                com_api_flexible_data_pkg.set_flexible_value(
                    i_field_name  => cst_cfc_api_const_pkg.CST_CFC_RESERVED_ACC_NUMBER
                  , i_entity_type => iss_api_const_pkg.ENTITY_TYPE_CARD
                  , i_object_id   => i.id
                  , i_field_value => l_reserved_acc_name
                );
            end if;
        end loop;
    end if;
exception
    when others then
        null;
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
