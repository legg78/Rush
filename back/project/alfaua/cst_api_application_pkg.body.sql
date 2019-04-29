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
    l_account              acc_api_type_pkg.t_account_rec;
begin
    trc_log_pkg.debug (
        i_text => 'cst_api_application_pkg.process_account_before'
    );
    --reconnect account
    app_api_application_pkg.get_element_value(
        i_element_name   =>  'ACCOUNT_NUMBER'
      , i_parent_id      =>  i_appl_data_id
      , o_element_value  =>  l_account.account_number
    );

    begin
        select id, customer_id, contract_id
          into l_account.account_id, l_account.customer_id, l_account.contract_id
          from acc_account
         where account_number = l_account.account_number
           and inst_id        = i_inst_id;
    exception
        when no_data_found then
            l_account.account_id := null;
    end;
    if l_account.account_id is not null       and
       l_account.customer_id <> i_customer_id and
       l_account.contract_id <> io_contract_id
    then
        begin
            select split_hash
              into l_account.split_hash
              from prd_customer
             where id = i_customer_id;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error => 'CUSTOMER_NOT_FOUND'
                );
        end;

        update acc_account_vw a set
              a.customer_id = i_customer_id
            , a.contract_id = io_contract_id
            , a.split_hash = l_account.split_hash
         where a.id = l_account.account_id;
    end if;
end;

procedure process_card_before (
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_customer_id          in            com_api_type_pkg.t_medium_id
  , io_contract_id         in out nocopy com_api_type_pkg.t_long_id
  , i_inst_id              in            com_api_type_pkg.t_inst_id
) is
    l_card                 iss_api_type_pkg.t_card_rec;
    l_card_number          com_api_type_pkg.t_card_number;
    l_card_uid             com_api_type_pkg.t_name; 
    l_cardholder_id        com_api_type_pkg.t_long_id;
    l_cardholder_data_id   com_api_type_pkg.t_long_id;
begin
    trc_log_pkg.debug (
        i_text => 'cst_api_application_pkg.process_card_before'
    );
    --reconnect card + unlink from all accounts
    app_api_application_pkg.get_element_value(
        i_element_name   => 'CARD_NUMBER'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_card_number
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'CARD_ID'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_card_uid
    );

    if l_card_number is null and l_card_uid is not null then
        l_card_number := 
            iss_api_card_pkg.get_card_number(
                i_card_uid    => l_card_uid
                , o_card_id   => l_card.id
            );
    end if;

    if l_card_number is not null then
        l_card := iss_api_card_pkg.get_card(
                      i_card_number => l_card_number
                    , i_mask_error  => com_api_type_pkg.TRUE
                  );
    end if;

    app_api_application_pkg.get_appl_data_id(
        i_element_name   => 'CARDHOLDER'
      , i_parent_id      => i_appl_data_id
      , o_appl_data_id   => l_cardholder_data_id
    );

    if l_cardholder_data_id is not null then
        iap_cardholder_pkg.process_cardholder(
            i_appl_data_id        => l_cardholder_data_id
          , i_parent_appl_data_id => i_appl_data_id
          , i_card_id             => null
          , i_customer_id         => i_customer_id
          , i_inst_id             => i_inst_id
          , o_cardholder_id       => l_cardholder_id
        );
    end if;

    if l_card.id is not null then
        --reconnect
        iap_api_card_pkg.reconnect_card(
            i_card_id       => l_card.id
          , i_customer_id   => i_customer_id
          , i_contract_id   => io_contract_id
          , i_appl_data_id  => i_appl_data_id
          , i_cardholder_id => l_cardholder_id
        );
        --unlink card from all accounts
        for r in (
                  select aao.id
                    from acc_account_object aao
                   where entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                     and object_id   = l_card.id
                 )
        loop
            trc_log_pkg.debug(
                i_text => 'Dettaching account with link ID [' || r.id
                       || '] from card [' || l_card.id || ']'
            );
            acc_api_account_pkg.remove_account_object(
                i_account_object_id  => r.id
            );
        end loop;
    end if;
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
    /*
    --unlink card from other accounts
    for r in (
              select aao.id
                from acc_account_object aao
               where account_id  <> i_account_id
                 and entity_type = i_entity_type
                 and entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                 and object_id   = i_object_id
             )
    loop
        trc_log_pkg.debug(
            i_text => 'Dettaching account with link ID [' || r.id
                   || '] from [' || i_entity_type|| '] [' || i_object_id || ']'
        );
        acc_api_account_pkg.remove_account_object(
            i_account_object_id  => r.id
        );
    end loop;
    */
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
