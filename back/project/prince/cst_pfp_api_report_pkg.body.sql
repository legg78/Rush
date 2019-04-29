create or replace package body cst_pfp_api_report_pkg as

-- Welcome letter. i_object_id - card instance id
procedure welcome_letter (
    o_xml             out clob
  , i_lang         in     com_api_type_pkg.t_dict_value
  , i_object_id    in     com_api_type_pkg.t_medium_id
) is
    l_header                  xmltype;
    l_result                  xmltype;

    l_customer_name           com_api_type_pkg.t_name;
    l_lang                    com_api_type_pkg.t_dict_value;
    l_account                 acc_api_type_pkg.t_account_rec;
    l_card                    iss_api_type_pkg.t_card_rec;
    l_card_instance           iss_api_type_pkg.t_card_instance;
    l_accounts_tab            acc_api_type_pkg.t_account_tab;
    l_exceed_limit            com_api_type_pkg.t_amount_rec;
    l_daily_cwd_limit         fcl_api_type_pkg.t_limit;
    l_single_cwd_limit        fcl_api_type_pkg.t_limit;
    l_header_logo             com_api_type_pkg.t_name;
    l_footer_logo             com_api_type_pkg.t_name;
    l_contract                prd_api_type_pkg.t_contract;
    l_service_type_id         com_api_type_pkg.t_short_id;
    l_service_id              com_api_type_pkg.t_short_id;
    l_limit_id                com_api_type_pkg.t_long_id;
    l_eff_date                date := com_api_sttl_day_pkg.get_sysdate;

begin
    trc_log_pkg.debug (
        i_text          => 'Run welcome letter [#1] [#2]'
      , i_env_param1    => i_lang
      , i_env_param2    => i_object_id
    );

    l_lang := nvl(i_lang, get_user_lang);

    l_card_instance :=
        iss_api_card_instance_pkg.get_instance(
            i_id             => i_object_id
          , i_raise_error    => com_api_const_pkg.TRUE
        );

    l_card :=
        iss_api_card_pkg.get_card(
            i_card_id        => l_card_instance.card_id
        );

    l_contract :=
        prd_api_contract_pkg.get_contract(
            i_contract_id    => l_card.contract_id
        );

    l_accounts_tab :=
        acc_api_account_pkg.get_accounts(
            i_contract_id  => l_card.contract_id
          , i_inst_id      => l_card.inst_id
          , i_split_hash   => l_card.split_hash
        );
    for i in 1..l_accounts_tab.count loop
        if l_accounts_tab(i).status != acc_api_const_pkg.ACCOUNT_STATUS_CLOSED then
            if l_accounts_tab(i).account_type = acc_api_const_pkg.ACCOUNT_TYPE_CREDIT then
                l_exceed_limit :=
                    acc_api_balance_pkg.get_balance_amount (
                        i_account_id     => l_accounts_tab(i).account_id
                      , i_balance_type   => crd_api_const_pkg.BALANCE_TYPE_ASSIGNED_EXCEED
                      , i_mask_error     => com_api_const_pkg.TRUE
                      , i_lock_balance   => com_api_const_pkg.FALSE
                    );
            end if;
            l_account := l_accounts_tab(i);
            exit;  -- we search for the first not closed account
        end if;
    end loop;

    -- Search value of the attribute DAILY_CASH_WITHDRAWL_TOTAL_AMOUNT_ON_ATM_AND_POS.
    -- For instant cards service of card maintenance is not assigned yet, so we have to get attribute value from product level.
    l_service_type_id :=
        prd_api_service_pkg.get_service_type_id(
            i_attr_name => cst_pfp_api_const_pkg.PRD_ATTR_DAILY_CWD_AMOUNT
        );

    l_service_id :=
        prd_api_service_pkg.get_active_service_id(
            i_entity_type      => iss_api_const_pkg.ENTITY_TYPE_CARD
          , i_object_id        => l_card_instance.card_id
          , i_attr_name        => cst_pfp_api_const_pkg.PRD_ATTR_DAILY_CWD_AMOUNT
          , i_service_type_id  => l_service_type_id
          , i_split_hash       => l_card.split_hash
          , i_eff_date         => l_eff_date
          , i_mask_error       => com_api_type_pkg.TRUE
          , i_inst_id          => l_card.inst_id
        );

    trc_log_pkg.debug (
        i_text          => 'Service term [#1]: l_service_type_id [#2], l_service_id [#3]'
      , i_env_param1    => cst_pfp_api_const_pkg.PRD_ATTR_DAILY_CWD_AMOUNT
      , i_env_param2    => l_service_type_id
      , i_env_param3    => l_service_id
    );

    if l_service_id is null then
        -- Try to find service for product:
        select pav.service_id
          into l_service_id
          from prd_attribute pa
             , prd_attribute_value pav
         where pa.id = pav.attr_id
           and pa.attr_name = cst_pfp_api_const_pkg.PRD_ATTR_DAILY_CWD_AMOUNT
           and pav.entity_type = prd_api_const_pkg.ENTITY_TYPE_PRODUCT
           and pav.object_id = l_contract.product_id
           and l_eff_date >= pav.start_date
           and l_eff_date < nvl(pav.end_date, l_eff_date + 1)
           and rownum <= 1;

        l_limit_id :=
            prd_api_product_pkg.get_attr_value_number(
                i_entity_type       => prd_api_const_pkg.ENTITY_TYPE_PRODUCT
              , i_object_id         => l_contract.product_id
              , i_service_id        => l_service_id
              , i_attr_name         => cst_pfp_api_const_pkg.PRD_ATTR_DAILY_CWD_AMOUNT
              , i_mask_error        => com_api_type_pkg.TRUE
            );
        trc_log_pkg.debug (
            i_text          => 'service id for product [#1], l_limit_id [#2]'
          , i_env_param1    => l_service_id
          , i_env_param2    => l_limit_id
        );
    else
        l_limit_id :=
            prd_api_product_pkg.get_attr_value_number(
                i_entity_type       => iss_api_const_pkg.ENTITY_TYPE_CARD
              , i_object_id         => l_card_instance.card_id
              , i_service_id        => l_service_id
              , i_attr_name         => cst_pfp_api_const_pkg.PRD_ATTR_DAILY_CWD_AMOUNT
              , i_mask_error        => com_api_type_pkg.TRUE
            );
        trc_log_pkg.debug (
            i_text          => 'l_limit_id [#1]'
          , i_env_param1    => l_limit_id
        );
    end if;

    if l_limit_id is not null then
        l_daily_cwd_limit :=
        fcl_api_limit_pkg.get_limit(
            i_limit_id  => l_limit_id
        );
    end if;

    -- Search value of the attribute ONE_TIME_CASH_WITHDRAWAL_ATM_POS.
    -- For instant cards service of card maintenance is not assigned yet, so we have to get attribute value from product level.
    l_service_type_id :=
        prd_api_service_pkg.get_service_type_id(
            i_attr_name => cst_pfp_api_const_pkg.PRD_ATTR_SINGLE_CWD_AMOUNT
        );

    l_service_id :=
        prd_api_service_pkg.get_active_service_id(
            i_entity_type      => iss_api_const_pkg.ENTITY_TYPE_CARD
          , i_object_id        => l_card_instance.card_id
          , i_attr_name        => cst_pfp_api_const_pkg.PRD_ATTR_SINGLE_CWD_AMOUNT
          , i_service_type_id  => l_service_type_id
          , i_split_hash       => l_card.split_hash
          , i_eff_date         => l_eff_date
          , i_mask_error       => com_api_type_pkg.TRUE
          , i_inst_id          => l_card.inst_id
        );

    trc_log_pkg.debug (
        i_text          => 'Service term [#1]: l_service_type_id [#2], l_service_id [#3]'
      , i_env_param1    => cst_pfp_api_const_pkg.PRD_ATTR_SINGLE_CWD_AMOUNT
      , i_env_param2    => l_service_type_id
      , i_env_param3    => l_service_id
    );

    if l_service_id is null then
        -- Try to find service for product:
        select pav.service_id
          into l_service_id
          from prd_attribute pa
             , prd_attribute_value pav
         where pa.id = pav.attr_id
           and pa.attr_name = cst_pfp_api_const_pkg.PRD_ATTR_SINGLE_CWD_AMOUNT
           and pav.entity_type = prd_api_const_pkg.ENTITY_TYPE_PRODUCT
           and pav.object_id = l_contract.product_id
           and l_eff_date >= pav.start_date
           and l_eff_date < nvl(pav.end_date, l_eff_date + 1)
           and rownum <= 1;

        l_limit_id := 
            prd_api_product_pkg.get_attr_value_number(
                i_entity_type       => prd_api_const_pkg.ENTITY_TYPE_PRODUCT
              , i_object_id         => l_contract.product_id
              , i_service_id        => l_service_id
              , i_attr_name         => cst_pfp_api_const_pkg.PRD_ATTR_SINGLE_CWD_AMOUNT
              , i_mask_error        => com_api_type_pkg.TRUE
            );
        trc_log_pkg.debug (
            i_text          => 'service id for product [#1], l_limit_id [#2]'
          , i_env_param1    => l_service_id
          , i_env_param2    => l_limit_id
        );
    else
        l_limit_id :=
            prd_api_product_pkg.get_attr_value_number(
                i_entity_type       => iss_api_const_pkg.ENTITY_TYPE_CARD
              , i_object_id         => l_card_instance.card_id
              , i_service_id        => l_service_id
              , i_attr_name         => cst_pfp_api_const_pkg.PRD_ATTR_SINGLE_CWD_AMOUNT
              , i_mask_error        => com_api_type_pkg.TRUE
            );
        trc_log_pkg.debug (
            i_text          => 'l_limit_id [#1]'
          , i_env_param1    => l_limit_id
        );
    end if;

    if l_limit_id is not null then
        l_single_cwd_limit :=
            fcl_api_limit_pkg.get_limit(
                i_limit_id  => l_limit_id
            );
    end if;

    l_header_logo :=
        cst_apc_com_pkg.get_banner_filename (
            i_banner_name   => cst_pfp_api_const_pkg.BANNER_WELCOME_HEADER_LOGO
          , i_lang          => l_lang
        );
    l_footer_logo :=
        cst_apc_com_pkg.get_banner_filename (
            i_banner_name   => cst_pfp_api_const_pkg.BANNER_WELCOME_FOOTER_LOGO
          , i_lang          => l_lang
        );

    -- header
    select xmlconcat(
               xmlelement("card_number",      l_card.card_mask)
             , xmlelement("card_id",          l_card_instance.card_id)
             , xmlelement("issuance_date",    to_char(l_card_instance.reg_date, cst_pfp_api_const_pkg.DATE_FORMAT_MASK_COMMON))
             , xmlelement("expire_date",      to_char(l_card_instance.expir_date, cst_pfp_api_const_pkg.DATE_FORMAT_MASK_EXPIRE_DATE))
             , xmlelement("customer_name",    iss_api_cardholder_pkg.get_cardholder_name(l_card.cardholder_id))
             , xmlelement("currency_name",    com_api_currency_pkg.get_currency_name(l_account.currency))
             , xmlelement("branch_name",      oa.agent_number || ' - ' || get_text('OST_AGENT', 'NAME', oa.id, l_lang))
             , xmlelement("header_logo",      l_header_logo)
             , xmlelement("footer_logo",      l_footer_logo)
             , xmlelement("credit_limit",     cst_apc_com_pkg.format_amount(
                                                  i_amount      => l_exceed_limit.amount
                                                , i_curr_code   => l_exceed_limit.currency
                                              )
                         )
             , xmlelement("card_type",        l_contract.product_id || ' - ' || get_text('PRD_PRODUCT', 'LABEL', l_contract.product_id, l_lang) || ' - ' || l_card.card_type_id)
             , xmlelement("daily_cwd_limit",  cst_apc_com_pkg.format_amount(
                                                  i_amount      => l_daily_cwd_limit.sum_limit
                                                , i_curr_code   => l_daily_cwd_limit.currency
                                              )
                         )
             , xmlelement("prepaid_limit",    null)
             , xmlelement("single_cwd_limit", cst_apc_com_pkg.format_amount(
                                                  i_amount      => l_single_cwd_limit.sum_limit
                                                , i_curr_code   => l_single_cwd_limit.currency
                                              )
                         )
             , xmlelement("cashadv_limit", null)
           )
      into l_header
      from ost_agent oa
     where oa.id = l_card_instance.agent_id;

    select xmlelement (
               "report"
             , l_header
           )
      into l_result
      from dual;

    o_xml := l_result.getclobval();

end welcome_letter;

end cst_pfp_api_report_pkg;
/
