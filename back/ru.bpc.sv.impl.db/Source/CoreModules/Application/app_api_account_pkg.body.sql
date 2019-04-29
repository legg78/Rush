create or replace package body app_api_account_pkg as
/*********************************************************
*  Application - account <br />
*  Created by Fomichev A.(fomichev@bpc.ru)  at 01.02.2011 <br />
*  Module: APP_API_ACCOUNT_PKG <br />
*  @headcom
**********************************************************/

procedure get_account_appl_data(
    i_appl_data_id  in            com_api_type_pkg.t_long_id
  , o_account          out nocopy acc_api_type_pkg.t_account_rec
  , o_value_tab        out nocopy com_api_type_pkg.t_param_tab
) is
    l_id                          com_api_type_pkg.t_long_id;
begin
    o_account.agent_id := app_api_application_pkg.get_app_agent_id;

    app_api_application_pkg.get_element_value(
        i_element_name   =>  'ACCOUNT_NUMBER'
      , i_parent_id      =>  i_appl_data_id
      , o_element_value  =>  o_account.account_number
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'ACCOUNT_TYPE'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_account.account_type
    );

    rul_api_param_pkg.set_param (
        i_value          => o_account.account_type
      , i_name           => 'ACCOUNT_TYPE'
      , io_params        => app_api_application_pkg.g_params
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'CURRENCY'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_account.currency
    );
    rul_api_param_pkg.set_param (
        i_value          => o_account.currency
      , i_name           => 'ACCOUNT_CURRENCY'
      , io_params        => app_api_application_pkg.g_params
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'ACCOUNT_STATUS'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_account.status
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'STATUS_REASON'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_value_tab('STATUS_REASON') --o_account.status_reason
    );

    rul_api_param_pkg.set_param(
        i_value          => o_account.status
      , i_name           => 'ACCOUNT_STATUS'
      , io_params        => app_api_application_pkg.g_params
    );

    app_api_application_pkg.get_appl_data_id(
        i_element_name   => 'APPLICATION'
      , i_parent_id      => null
      , o_appl_data_id   => l_id
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'INSTITUTION_ID'
      , i_parent_id      => l_id
      , o_element_value  => o_account.inst_id
    );
end get_account_appl_data;

procedure attach_account_to_application(
    i_account_id    in            com_api_type_pkg.t_long_id
) is
    l_count                       com_api_type_pkg.t_count    := 0;
    l_appl_id                     com_api_type_pkg.t_long_id;
begin
    if i_account_id is null then
        return;
    end if;

    l_appl_id := app_api_application_pkg.get_appl_id;

    select count(appl_id)
      into l_count
      from app_object
     where object_id   = i_account_id
       and appl_id     = l_appl_id
       and entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT;

    trc_log_pkg.debug(
        i_text         => 'Attach account to the application: number of accounts [#1], account_id [#2], application_id [#3]'
      , i_env_param1   => l_count
      , i_env_param2   => i_account_id
      , i_env_param3   => app_api_application_pkg.get_appl_id
    );

    if l_count = 0 then
        app_api_appl_object_pkg.add_object(
            i_appl_id     => app_api_application_pkg.get_appl_id
          , i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id   => i_account_id
          , i_seqnum      => 1
        );
    end if;
end attach_account_to_application;

procedure change_objects(
    i_appl_data_id  in            com_api_type_pkg.t_long_id
  , i_account_id    in            com_api_type_pkg.t_long_id
  , i_contract_id   in            com_api_type_pkg.t_long_id
  , i_inst_id       in            com_api_type_pkg.t_inst_id
  , i_agent_id      in            com_api_type_pkg.t_short_id
  , i_customer_id   in            com_api_type_pkg.t_medium_id
) is
    LOG_PREFIX           constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.change_objects: ';
    l_id_tab                      com_api_type_pkg.t_number_tab;
begin
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'START with i_account_id [' || i_account_id
                             || '], i_customer_id [' || i_customer_id || '], i_contract_id [' || i_contract_id
                             || '], i_agent_id [' || i_agent_id || '], i_inst_id [' || i_inst_id || ']'
    );

    app_api_flexible_field_pkg.process_flexible_fields(
        i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
      , i_object_type   => null
      , i_object_id     => i_account_id
      , i_inst_id       => i_inst_id
      , i_appl_data_id  => i_appl_data_id
    );

    app_api_service_pkg.process_entity_service(
        i_appl_data_id  => i_appl_data_id
      , i_element_name  => 'ACCOUNT'
      , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
      , i_object_id     => i_account_id
      , i_contract_id   => i_contract_id
      , io_params       => app_api_application_pkg.g_params
    );

    app_api_application_pkg.get_appl_data_id(
        i_element_name  => 'PAYMENT_ORDER'
      , i_parent_id     => i_appl_data_id
      , o_appl_data_id  => l_id_tab
    );

    for i in 1..nvl(l_id_tab.count, 0) loop
        app_api_payment_order_pkg.process_order(
            i_appl_data_id => l_id_tab(i)
          , i_inst_id      => i_inst_id
          , i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id    => i_account_id
          , i_agent_id     => i_agent_id
          , i_customer_id  => i_customer_id
          , i_contract_id  => i_contract_id
        );
    end loop;

    -- update document link
    app_api_report_pkg.process_report(
        i_appl_data_id        => i_appl_data_id
      , i_entity_type         => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
      , i_object_id           => i_account_id
    );

    trc_log_pkg.debug(LOG_PREFIX || 'END');
end change_objects;

procedure check_default_pos_account(
    i_account_id            in         com_api_type_pkg.t_long_id
  , i_card_id               in         com_api_type_pkg.t_medium_id
  , i_currency              in         com_api_type_pkg.t_curr_code     default null
) is
    l_account_id                       com_api_type_pkg.t_account_id;
begin
    select max(o.account_id)
      into l_account_id
      from acc_account_object o
         , acc_account        a
     where o.account_id     != i_account_id
       and o.object_id       = i_card_id
       and o.entity_type     = iss_api_const_pkg.ENTITY_TYPE_CARD
       and o.is_pos_default  = com_api_const_pkg.TRUE
       and a.id              = o.account_id
       and a.status         != acc_api_const_pkg.ACCOUNT_STATUS_CLOSED
       and (i_currency is null or a.currency = i_currency);

    if l_account_id is not null then
        -- Raise error Default account for POS already set
        com_api_error_pkg.raise_error(
            i_error        => 'DEFAULT_POS_ACCOUNT_EXISTS'
          , i_env_param1   => l_account_id
          , i_env_param2   => i_card_id
        );
    end if;
end;

procedure check_default_atm_account(
    i_account_id            in         com_api_type_pkg.t_long_id
  , i_card_id               in         com_api_type_pkg.t_medium_id
  , i_currency              in         com_api_type_pkg.t_curr_code     default null
)is
    l_account_id                       com_api_type_pkg.t_account_id;
begin
    select max(o.account_id)
      into l_account_id
      from acc_account_object o
         , acc_account        a
     where o.account_id    != i_account_id
       and o.object_id      = i_card_id
       and o.entity_type    = iss_api_const_pkg.ENTITY_TYPE_CARD
       and o.is_atm_default = com_api_const_pkg.TRUE
       and a.id             = o.account_id
       and a.status        != acc_api_const_pkg.ACCOUNT_STATUS_CLOSED
       and (i_currency is null or a.currency = i_currency);

    if l_account_id is not null then
        -- Raise error Default account for ATM already set
        com_api_error_pkg.raise_error(
            i_error        => 'DEFAULT_ATM_ACCOUNT_EXISTS'
          , i_env_param1   => l_account_id
          , i_env_param2   => i_card_id
        );
    end if;
end;

procedure check_default_pos_currency(
    i_account_id            in         com_api_type_pkg.t_long_id
  , i_card_id               in         com_api_type_pkg.t_medium_id
  , i_currency              in         com_api_type_pkg.t_curr_code
) is
    l_cnt                              com_api_type_pkg.t_tiny_id;
begin
    select count(*)
      into l_cnt
      from acc_account_object o
      join acc_account        a
        on a.id              = o.account_id
       and a.currency        = i_currency
       and a.status         != acc_api_const_pkg.ACCOUNT_STATUS_CLOSED
     where o.is_pos_currency = com_api_const_pkg.TRUE
       and o.entity_type     = iss_api_const_pkg.ENTITY_TYPE_CARD
       and o.account_id     != i_account_id
       and o.object_id       = i_card_id;

    if l_cnt > 0 then
        com_api_error_pkg.raise_error(
            i_error        => 'DEFAULT_POS_ACCOUNT_CURRENCY_EXISTS'
          , i_env_param1   => i_account_id
          , i_env_param2   => i_currency
          , i_env_param3   => i_card_id
        );
    end if;
end;

procedure check_default_atm_currency(
    i_account_id            in         com_api_type_pkg.t_long_id
  , i_card_id               in         com_api_type_pkg.t_medium_id
  , i_currency              in         com_api_type_pkg.t_curr_code
) is
    l_cnt                              com_api_type_pkg.t_tiny_id;
begin
    select count(*)
      into l_cnt
      from acc_account_object o
      join acc_account        a
        on a.id              = o.account_id
       and a.currency        = i_currency
       and a.status         != acc_api_const_pkg.ACCOUNT_STATUS_CLOSED
     where o.is_atm_currency = com_api_const_pkg.TRUE
       and o.entity_type     = iss_api_const_pkg.ENTITY_TYPE_CARD
       and o.account_id     != i_account_id
       and o.object_id       = i_card_id;

    if l_cnt > 0 then
        com_api_error_pkg.raise_error(
            i_error        => 'DEFAULT_ATM_ACCOUNT_CURRENCY_EXISTS'
          , i_env_param1   => i_account_id
          , i_env_param2   => i_currency
          , i_env_param3   => i_card_id
        );
    end if;
end;

procedure check_default_values(
    i_account_id            in         com_api_type_pkg.t_long_id
) is
begin
    for r_account_object in (
            select ao.account_id
                 , ao.object_id as card_id
                 , a.currency
                 , ao.is_pos_default
                 , ao.is_atm_default
                 , ao.is_pos_currency
                 , ao.is_atm_currency
              from acc_account_object ao
                 , acc_account a
             where a.id           = i_account_id
               and ao.account_id  = a.id
               and ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
               and ao.split_hash  = a.split_hash
               and (
                       nvl(ao.is_pos_default,     com_api_type_pkg.FALSE) = com_api_type_pkg.TRUE
                       or nvl(ao.is_atm_default,  com_api_type_pkg.FALSE) = com_api_type_pkg.TRUE
                       or nvl(ao.is_pos_currency, com_api_type_pkg.FALSE) = com_api_type_pkg.TRUE
                       or nvl(ao.is_atm_currency, com_api_type_pkg.FALSE) = com_api_type_pkg.TRUE
                   )
        )
    loop
        if nvl(r_account_object.is_pos_default,     com_api_type_pkg.FALSE) = com_api_type_pkg.TRUE then
            check_default_pos_account(
                i_account_id  => r_account_object.account_id
              , i_card_id     => r_account_object.card_id
              , i_currency    => r_account_object.currency
            );
        end if;

        if nvl(r_account_object.is_atm_default,     com_api_type_pkg.FALSE) = com_api_type_pkg.TRUE then
            check_default_atm_account(
                i_account_id  => r_account_object.account_id
              , i_card_id     => r_account_object.card_id
              , i_currency    => r_account_object.currency
            );
        end if;

        if nvl(r_account_object.is_pos_currency, com_api_type_pkg.FALSE) = com_api_type_pkg.TRUE then
            check_default_pos_currency(
                i_account_id  => r_account_object.account_id
              , i_card_id     => r_account_object.card_id
              , i_currency    => r_account_object.currency
            );
        end if;

        if nvl(r_account_object.is_atm_currency, com_api_type_pkg.FALSE) = com_api_type_pkg.TRUE then
            check_default_atm_currency(
                i_account_id  => r_account_object.account_id
              , i_card_id     => r_account_object.card_id
              , i_currency    => r_account_object.currency
            );
        end if;
    end loop;
end check_default_values;

procedure attach_facilitator(
    i_account_id        in            com_api_type_pkg.t_long_id
  , i_appl_data_id      in            com_api_type_pkg.t_long_id
  , i_inst_id           in            com_api_type_pkg.t_inst_id
) is
    LOG_PREFIX               constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.attach_facilitator: ';
    l_facilitator_data_id             com_api_type_pkg.t_long_id;
    l_account_number                  com_api_type_pkg.t_account_number;
    l_description                     com_api_type_pkg.t_name;
    l_account_rec                     acc_api_type_pkg.t_account_rec;
    l_account_link_id                 com_api_type_pkg.t_medium_id;
begin
    trc_log_pkg.debug(LOG_PREFIX || 'START with account_id [' || i_account_id || '], i_inst_id [' || i_inst_id || ']');

    app_api_application_pkg.get_appl_data_id(
        i_element_name   => 'FACILITATOR'
      , i_parent_id      => i_appl_data_id
      , o_appl_data_id   => l_facilitator_data_id
    );
    if l_facilitator_data_id is not null then
        app_api_application_pkg.get_element_value(
            i_element_name   => 'ACCOUNT_NUMBER'
          , i_parent_id      => l_facilitator_data_id
          , o_element_value  => l_account_number
        );
        if l_account_number is not null then
            app_api_application_pkg.get_element_value(
                i_element_name   => 'DESCRIPTION'
              , i_parent_id      => l_facilitator_data_id
              , o_element_value  => l_description
            );
            l_account_rec := acc_api_account_pkg.get_account(
                                 i_account_id     => null
                               , i_account_number => l_account_number
                               , i_inst_id        => null
                               , i_mask_error     => com_api_const_pkg.FALSE
                             );
            acc_api_account_pkg.add_account_link(
                i_account_id          => i_account_id
              , i_object_id           => l_account_rec.account_id
              , i_entity_type         => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_description         => l_description
              , i_is_active           => com_api_const_pkg.TRUE
              , o_account_link_id     => l_account_link_id
            );
        end if;
    end if;
end attach_facilitator;

/*
 * Procedure attaches or detaches account with some entity (card, merchant, terminal, etc.).
 * i_detaching_only    - if it is true then only detaching is available,
 *                       value ACCOUNT_LINK_FLAG = 1 will be ignored.
 */
procedure attach_account(
    i_account_id        in            com_api_type_pkg.t_long_id
  , i_appl_data_id      in            com_api_type_pkg.t_long_id
  , i_inst_id           in            com_api_type_pkg.t_inst_id
  , i_detach_only       in            com_api_type_pkg.t_boolean    default com_api_type_pkg.FALSE
  , i_mask_error        in            com_api_type_pkg.t_boolean    default com_api_type_pkg.FALSE
) is
    LOG_PREFIX               constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.attach_account: ';
    l_object_id                       com_api_type_pkg.t_long_id;
    l_card_rec                        iss_api_type_pkg.t_card_rec;
    l_account_object_id               com_api_type_pkg.t_long_id;
    l_account_number                  com_api_type_pkg.t_account_number;
    l_appl_data_id                    com_api_type_pkg.t_long_id;
    l_entity_type                     com_api_type_pkg.t_dict_value;
    l_str                             com_api_type_pkg.t_full_desc;
    l_desc_tab                        com_api_type_pkg.t_desc_tab;
    l_account_object_tab              com_api_type_pkg.t_number_tab;
    l_appl_data_id_tab                com_api_type_pkg.t_number_tab;
    l_link_flag                       com_api_type_pkg.t_boolean;
    l_acc_obj_id                      com_api_type_pkg.t_long_id;
    l_contact_data_id_tab             com_api_type_pkg.t_number_tab;
    l_commun_method                   com_api_type_pkg.t_dict_value;
    l_commun_address                  com_api_type_pkg.t_full_desc;
    l_is_pos_default                  com_api_type_pkg.t_boolean;
    l_is_atm_default                  com_api_type_pkg.t_boolean;
    l_card_uid                        com_api_type_pkg.t_name;
    l_sysdate                         date;
    l_split_hash                      com_api_type_pkg.t_tiny_id;
    l_count                           com_api_type_pkg.t_short_id;
    l_unlink_account_id               com_api_type_pkg.t_long_id;
    l_usage_order                     com_api_type_pkg.t_tiny_id;
    l_link_property_flag              com_api_type_pkg.t_boolean;
    l_link_property_type              com_api_type_pkg.t_dict_value;
    l_link_property                   com_api_type_pkg.t_dict_value;
    l_is_atm_currency                 com_api_type_pkg.t_boolean;
    l_is_pos_currency                 com_api_type_pkg.t_boolean;
    l_account_seq_number              acc_api_type_pkg.t_account_seq_number;
    l_account_object_property_tab     com_api_type_pkg.t_number_tab;
    l_appl_data_property_id_tab       com_api_type_pkg.t_number_tab;
begin
    trc_log_pkg.debug(LOG_PREFIX || 'START with account_id [' || i_account_id || '], i_inst_id [' || i_inst_id || ']');

    l_sysdate        := com_api_sttl_day_pkg.get_sysdate;

    l_account_number := acc_api_account_pkg.get_account(
                            i_account_id => i_account_id
                          , i_mask_error => com_api_const_pkg.FALSE
                        ).account_number;
    trc_log_pkg.debug('l_account_number [' || l_account_number || ']');

    -- This is APPL_DATA_ID of block TERMINAL, MERCHANT, ACCOUNT or CARD block
    app_api_application_pkg.get_appl_id_value(
        i_element_name   => 'ACCOUNT_OBJECT'
      , i_parent_id      => i_appl_data_id
      , o_appl_data_id   => l_appl_data_id_tab
      , o_element_value  => l_account_object_tab
    );
    trc_log_pkg.debug(nvl(l_account_object_tab.count, 0) || ' account objects are found');

    for i in 1 .. nvl(l_account_object_tab.count, 0) loop
        trc_log_pkg.debug('l_account_object_tab('||i||') = '||l_account_object_tab(i));

        app_api_application_pkg.get_element_value(
            i_element_name   => 'ACCOUNT_LINK_FLAG'
          , i_parent_id      => l_appl_data_id_tab(i)
          , o_element_value  => l_link_flag
        );

        select e.entity_type
          into l_entity_type
          from app_data d
             , app_element e
         where d.element_id = e.id
           and d.id         = l_account_object_tab(i);

        case l_entity_type

        when acq_api_const_pkg.ENTITY_TYPE_MERCHANT then
            app_api_application_pkg.get_element_value(
                i_element_name   => 'MERCHANT_NUMBER'
              , i_parent_id      => l_account_object_tab(i)
              , o_element_value  => l_str
            );
            begin
                select id
                  into l_object_id
                  from acq_merchant
                 where inst_id         = i_inst_id
                   and merchant_number = l_str;
            exception
                when no_data_found then
                    com_api_error_pkg.raise_error(
                        i_error        => 'CAN_NOT_FIND_MERCHANT'
                      , i_env_param1   => l_object_id
                      , i_env_param2   => l_str
                      , i_env_param3   => i_inst_id
                      , i_env_param4   => l_appl_data_id
                    );
            end;

        when acq_api_const_pkg.ENTITY_TYPE_TERMINAL then
            app_api_application_pkg.get_element_value(
               i_element_name   => 'TERMINAL_NUMBER'
             , i_parent_id      => l_account_object_tab(i)
             , o_element_value  => l_desc_tab
            );
            for j in 1 ..  nvl(l_desc_tab.last, 0) loop
                begin
                    select id
                      into l_object_id
                      from acq_terminal
                     where terminal_number = l_desc_tab(j)
                       and inst_id         = i_inst_id
                       and status         != acq_api_const_pkg.TERMINAL_STATUS_CLOSED;
                exception
                    when no_data_found then
                        com_api_error_pkg.raise_error(
                            i_error        => 'TERMINAL_NOT_FOUND'
                          , i_env_param1   => l_desc_tab(j)||', inst='||i_inst_id
                        );
                end;

                if  l_link_flag = com_api_const_pkg.TRUE
                    and
                    i_detach_only = com_api_const_pkg.FALSE
                then
                    trc_log_pkg.debug(
                        i_text => 'Attaching account to [' || l_entity_type || '] [' || l_object_id || ']'
                    );
                    acc_api_account_pkg.add_account_object(
                        i_account_id        => i_account_id
                      , i_entity_type       => l_entity_type
                      , i_object_id         => l_object_id
                      , o_account_object_id => l_account_object_id
                    );
                elsif l_link_flag = com_api_const_pkg.TRUE then -- detaching only
                    trc_log_pkg.debug(
                        i_text => 'Impossible to attach account to [' || l_entity_type|| '] ['
                               || l_object_id || '] because flag <i_detach_only> is set'
                    );
                else
                    select min(id)
                      into l_acc_obj_id
                      from acc_account_object
                     where account_id  = i_account_id
                       and entity_type = l_entity_type
                       and object_id   = l_object_id;

                    trc_log_pkg.debug(
                        i_text => 'Dettaching account with link ID [' || l_acc_obj_id
                               || '] from [' || l_entity_type|| '] [' || l_object_id || ']'
                    );
                    acc_api_account_pkg.remove_account_object(
                        i_account_object_id  => l_acc_obj_id
                    );
                end if;
            end loop;
            continue;

        when iss_api_const_pkg.ENTITY_TYPE_CARD then
            app_api_application_pkg.get_element_value(
                i_element_name   => 'CARD_NUMBER'
              , i_parent_id      => l_account_object_tab(i)
              , o_element_value  => l_str
            );
            app_api_application_pkg.get_element_value(
                i_element_name   => 'CARD_ID'
              , i_parent_id      => l_account_object_tab(i)
              , o_element_value  => l_card_uid --l_card_id
            );

            trc_log_pkg.debug('l_card_uid [' || l_card_uid || ']');

            if l_card_uid is not null then
                l_card_rec := iss_api_card_pkg.get_card(
                                  i_card_uid     => l_card_uid
                                , i_mask_error   => com_api_const_pkg.FALSE
                              );
            else
                l_card_rec := iss_api_card_pkg.get_card(
                                  i_card_number  => l_str
                                , i_mask_error   => com_api_const_pkg.FALSE
                              );
            end if;

            select count(1)
              into l_count
              from iss_card_instance
             where id     = iss_api_card_instance_pkg.get_card_instance_id(i_card_id => l_card_rec.id)
               and state != iss_api_const_pkg.CARD_STATE_CLOSED;

            if l_count = 0 then
                com_api_error_pkg.raise_error(
                    i_error        => 'CARD_NOT_FOUND'
                  , i_env_param1   => l_card_rec.id
                );
            end if;

            if l_card_rec.inst_id = i_inst_id then
                l_object_id := l_card_rec.id;
            else
                com_api_error_pkg.raise_error(
                    i_error        => 'UNKNOWN_CARD'
                  , i_env_param1   => l_str
                  , i_env_param2   => i_inst_id
                );
            end if;

            -- Get default account for POS and ATM
            app_api_application_pkg.get_element_value(
                i_element_name   => 'IS_POS_DEFAULT'
              , i_parent_id      => l_appl_data_id_tab(i)
              , o_element_value  => l_is_pos_default
            );
            app_api_application_pkg.get_element_value(
                i_element_name   => 'IS_ATM_DEFAULT'
              , i_parent_id      => l_appl_data_id_tab(i)
              , o_element_value  => l_is_atm_default
            );

          -- Use account sequential number from the application or generate it.
            -- This field is used only for entity ENTTCARD.
            app_api_application_pkg.get_element_value(
                i_element_name   => 'ACCOUNT_SEQ_NUMBER'
              , i_parent_id      => l_appl_data_id_tab(i)
              , o_element_value  => l_account_seq_number
            );
            -- Check account sequential number if it is defined in the application;
            -- otherwise, get next free account sequential number for the card
            acc_api_account_pkg.get_seq_number(
                i_entity_type         => iss_api_const_pkg.ENTITY_TYPE_CARD
              , i_object_id           => l_card_rec.id
              , i_account_seq_number  => l_account_seq_number
              , i_mask_error          => com_api_const_pkg.FALSE
              , o_account_seq_number  => l_account_seq_number
            );

            app_api_application_pkg.get_appl_id_value(
                i_element_name   => 'ACCOUNT_OBJECT_PROPERTY'
              , i_parent_id      => l_appl_data_id_tab(i)
              , o_appl_data_id   => l_appl_data_property_id_tab
              , o_element_value  => l_account_object_property_tab
            );

            trc_log_pkg.debug(
                i_text       =>   'l_appl_data_property_id_tab.count = '   || l_appl_data_property_id_tab.count
                             || ', l_account_object_property_tab.count = ' || l_account_object_property_tab.count
            );
            for i in 1 .. nvl(l_account_object_property_tab.count, 0)
            loop
                app_api_application_pkg.get_element_value(
                    i_element_name   => 'LINK_PROPERTY_FLAG'
                  , i_parent_id      => l_appl_data_property_id_tab(i)
                  , o_element_value  => l_link_property_flag
                );
                trc_log_pkg.debug('l_link_property_flag [' || l_link_property_flag || ']');

                if l_link_property_flag = com_api_const_pkg.TRUE then
                    app_api_application_pkg.get_element_value(
                        i_element_name   => 'LINK_PROPERTY_TYPE'
                      , i_parent_id      => l_appl_data_property_id_tab(i)
                      , o_element_value  => l_link_property_type
                    );
                    trc_log_pkg.debug(' link_property_type [' || l_link_property_type || ']');

                    if l_link_property_type = app_api_const_pkg.ACCOUNT_DEFAULT_IN_CURRENCY then
                        app_api_application_pkg.get_element_value(
                            i_element_name   => 'LINK_PROPERTY'
                          , i_parent_id      => l_appl_data_property_id_tab(i)
                          , o_element_value  => l_link_property
                        );
                        trc_log_pkg.debug('link_property [' || l_link_property || ']');

                        case l_link_property
                            when app_api_const_pkg.DEFAULT_POS_IN_CURRENCY then
                                l_is_pos_currency := com_api_const_pkg.TRUE;
                            when app_api_const_pkg.DEFAULT_ATM_IN_CURRENCY then
                                l_is_atm_currency := com_api_const_pkg.TRUE;
                            else
                                null;
                        end case;
                    end if;
                end if;
            end loop;

        when com_api_const_pkg.ENTITY_TYPE_CONTACT then
            app_api_application_pkg.get_appl_data_id(
                i_element_name   => 'CONTACT_DATA'
              , i_parent_id      => l_account_object_tab(i)
              , o_appl_data_id   => l_contact_data_id_tab
            );

            for q in 1 .. nvl(l_contact_data_id_tab.count, 0) loop
                app_api_application_pkg.get_element_value (
                    i_element_name   => 'COMMUN_METHOD'
                  , i_parent_id      => l_contact_data_id_tab(q)
                  , o_element_value  => l_commun_method
                );

                app_api_application_pkg.get_element_value(
                    i_element_name   => 'COMMUN_ADDRESS'
                  , i_parent_id      => l_contact_data_id_tab(q)
                  , o_element_value  => l_commun_address
                );
                begin
                    select contact_id
                      into l_object_id
                      from com_contact_data_vw
                     where commun_method  = l_commun_method
                       and commun_address = l_commun_address
                       and (end_date is null or end_date > l_sysdate);
                exception
                    when no_data_found then
                        com_api_error_pkg.raise_error(
                            i_error        => 'UNKNOWN_CONTACT_DATA'
                          , i_env_param1   => l_commun_method||' '|| l_commun_address
                        );
                end;
                exit;
            end loop;

        else
            com_api_error_pkg.raise_error(
                i_error         => 'INCORRECT_ENTITY_TO_ATTACH_ACCOUNT'
              , i_env_param1    => l_entity_type
            );
        end case;

        if  l_link_flag = com_api_const_pkg.TRUE
            and
            i_detach_only = com_api_const_pkg.FALSE
        then
            trc_log_pkg.debug(
                i_text       => 'Attaching account to [#1] [' || l_object_id || ']'
              , i_env_param1 => l_entity_type
            );
            acc_api_account_pkg.add_account_object(
                i_account_id         => i_account_id
              , i_entity_type        => l_entity_type
              , i_object_id          => l_object_id
              , i_is_pos_default     => nvl(l_is_pos_default, com_api_const_pkg.FALSE)
              , i_is_atm_default     => nvl(l_is_atm_default, com_api_const_pkg.FALSE)
              , i_is_atm_currency    => nvl(l_is_atm_currency, com_api_const_pkg.FALSE)
              , i_is_pos_currency    => nvl(l_is_pos_currency, com_api_const_pkg.FALSE)
              , i_account_seq_number => l_account_seq_number
              , o_account_object_id  => l_account_object_id
            );

            cst_api_application_pkg.process_lnk_card_account_after (
                i_appl_data_id  => i_appl_data_id
              , i_account_id    => i_account_id
              , i_entity_type   => l_entity_type
              , i_object_id     => l_object_id
            );
        elsif l_link_flag = com_api_const_pkg.TRUE then -- detaching only
            trc_log_pkg.debug(
                i_text => 'Impossible to attach account to [' || l_entity_type|| '] ['
                       || l_object_id || '] because flag <i_detach_only> is set'
            );
        else
            -- Find one row by unique index
            select min(id)
                 , min(usage_order)
                 , min(account_seq_number)
                 , min(split_hash)
              into l_acc_obj_id
                 , l_usage_order
                 , l_account_seq_number
                 , l_split_hash
              from acc_account_object
             where account_id   = i_account_id
               and entity_type  = l_entity_type
               and object_id    = l_object_id;

            trc_log_pkg.debug(
                i_text => 'Dettaching account with link ID [' || l_acc_obj_id
                       || '] from [' || l_entity_type|| '] [' || l_object_id || ']'
            );

            acc_api_account_pkg.remove_account_object(
                i_account_object_id  => l_acc_obj_id
            );

            if l_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD and l_acc_obj_id is not null then
                -- Need to unload unlinked account into FE via CREF.
                -- If some account_id was linked and unlinked several times
                -- then unload only unlinked accounts with unlink_date >= min(eff_date) of the card events.
                acc_api_account_pkg.add_unlink_account(
                    i_account_id          => i_account_id
                  , i_object_id           => l_object_id
                  , i_entity_type         => l_entity_type
                  , i_usage_order         => l_usage_order
                  , i_inst_id             => i_inst_id
                  , i_split_hash          => l_split_hash
                  , i_is_pos_default      => nvl(l_is_pos_default,  com_api_const_pkg.FALSE)
                  , i_is_atm_default      => nvl(l_is_atm_default,  com_api_const_pkg.FALSE)
                  , i_is_atm_currency     => nvl(l_is_atm_currency, com_api_const_pkg.FALSE)
                  , i_is_pos_currency     => nvl(l_is_pos_currency, com_api_const_pkg.FALSE)
                  , i_account_seq_number  => l_account_seq_number
                  , o_unlink_account_id   => l_unlink_account_id
                );
            end if;
        end if;
    end loop;

    attach_facilitator(
        i_account_id    => i_account_id
      , i_appl_data_id  => i_appl_data_id
      , i_inst_id       => i_inst_id
    );
    trc_log_pkg.debug(LOG_PREFIX || 'END');

exception
    when com_api_error_pkg.e_fatal_error then
        raise;
    when com_api_error_pkg.e_application_error then
        if nvl(i_mask_error, com_api_const_pkg.FALSE) = com_api_const_pkg.FALSE then
            raise;
        end if;
    when others then
        trc_log_pkg.debug(LOG_PREFIX || sqlerrm); -- for saving call stack
        com_api_error_pkg.raise_fatal_error(
            i_error      => 'UNHANDLED_EXCEPTION'
          , i_env_param1 => sqlerrm
        );
end attach_account;

/*
 * Function looks for existing account by <io_account.account_id> and updates it with values from <io_account>.
 */
procedure change_account(
    i_appl_data_id  in            com_api_type_pkg.t_long_id
  , i_customer_id   in            com_api_type_pkg.t_medium_id
  , io_account      in out nocopy acc_api_type_pkg.t_account_rec
  , i_contract_id   in            com_api_type_pkg.t_long_id
  , i_status_reason in            com_api_type_pkg.t_dict_value     default null
) is
    LOG_PREFIX      constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.change_account: ';
    l_old           acc_api_type_pkg.t_account_rec;
begin
    trc_log_pkg.debug(LOG_PREFIX || 'START');

    l_old :=
        acc_api_account_pkg.get_account(
            i_account_id     => io_account.account_id
          , i_mask_error     => com_api_const_pkg.FALSE
        );

    if io_account.status is not null and (l_old.status is null or l_old.status != io_account.status) then
        evt_api_status_pkg.change_status(
            i_initiator      => evt_api_const_pkg.INITIATOR_CLIENT
          , i_entity_type    => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id      => io_account.account_id
          , i_new_status     => io_account.status
          , i_eff_date       => com_api_sttl_day_pkg.get_sysdate()
          , i_reason         => i_status_reason
          , o_status         => io_account.status
          , i_raise_error    => com_api_const_pkg.TRUE
          , i_register_event => com_api_const_pkg.TRUE
          , i_params         => app_api_application_pkg.g_params
        );
    end if;

    change_objects(
        i_appl_data_id   => i_appl_data_id
      , i_account_id     => io_account.account_id
      , i_contract_id    => i_contract_id
      , i_inst_id        => l_old.inst_id
      , i_agent_id       => l_old.agent_id
      , i_customer_id    => l_old.customer_id
    );
    trc_log_pkg.debug(LOG_PREFIX || 'END');
end change_account;

procedure attach_account_to_card(
    i_account_id        in            com_api_type_pkg.t_long_id
  , i_card_id           in            com_api_type_pkg.t_long_id
) is
    l_account_object_id               com_api_type_pkg.t_long_id;
begin
    trc_log_pkg.debug('Attach account [' || i_account_id || '] from pool to card [' || i_card_id || '] from pool');

    acc_api_account_pkg.add_account_object(
        i_account_id        => i_account_id
      , i_entity_type       => iss_api_const_pkg.ENTITY_TYPE_CARD
      , i_object_id         => i_card_id
      , i_is_pos_default    => com_api_const_pkg.FALSE
      , i_is_atm_default    => com_api_const_pkg.FALSE
      , i_is_atm_currency   => com_api_const_pkg.FALSE
      , i_is_pos_currency   => com_api_const_pkg.FALSE
      , o_account_object_id => l_account_object_id
    );

    trc_log_pkg.debug('Account attached');
end;

function check_link_flag(
    i_appl_data_id      in            com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_boolean
is
    l_account_object_tab              com_api_type_pkg.t_number_tab;
    l_appl_data_id_tab                com_api_type_pkg.t_number_tab;
    l_link_flag                       com_api_type_pkg.t_boolean;
    LOG_PREFIX               constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.check_link_flag: ';
begin
    app_api_application_pkg.get_appl_id_value(
        i_element_name   => 'ACCOUNT_OBJECT'
      , i_parent_id      => i_appl_data_id
      , o_appl_data_id   => l_appl_data_id_tab
      , o_element_value  => l_account_object_tab
    );

    for i in 1 .. nvl(l_account_object_tab.count, 0) loop
        trc_log_pkg.debug(LOG_PREFIX || 'l_account_object_tab('||i||') = '||l_account_object_tab(i));

        app_api_application_pkg.get_element_value(
            i_element_name   => 'ACCOUNT_LINK_FLAG'
          , i_parent_id      => l_appl_data_id_tab(i)
          , o_element_value  => l_link_flag
        );
        trc_log_pkg.debug(LOG_PREFIX || 'l_link_flag=' || l_link_flag);
        return l_link_flag;
    end loop;    
    
    return com_api_const_pkg.FALSE;
end;

procedure create_account(
    i_appl_data_id  in            com_api_type_pkg.t_long_id
  , i_contract_id   in            com_api_type_pkg.t_medium_id
  , i_customer_id   in            com_api_type_pkg.t_medium_id
  , io_account      in out nocopy acc_api_type_pkg.t_account_rec
) is
    LOG_PREFIX           constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.create_account: ';
    l_appl_data_id                com_api_type_pkg.t_long_id;
    l_split_hash                  com_api_type_pkg.t_tiny_id;
    l_appl_service_id             com_api_type_pkg.t_short_id;
    l_service_tab                 com_api_type_pkg.t_short_tab;
    l_is_initial                  com_api_type_pkg.t_boolean;
    l_account_count               com_api_type_pkg.t_tiny_id;
    l_card_count                  com_api_type_pkg.t_tiny_id;
    l_card_id_tab                 com_api_type_pkg.t_number_tab;
    l_card_appl_data_tab          com_api_type_pkg.t_number_tab;
    l_account_block_id            com_api_type_pkg.t_long_id;
    l_skipped_elements            com_api_type_pkg.t_param_tab;
    l_account_block_rec           app_api_type_pkg.t_appl_data_rec;
    l_contract_type               com_api_type_pkg.t_dict_value;    
begin

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'START with io_account {account_id [' || io_account.account_id
                             || '], account_number [' || io_account.account_number
                             || '], account_type [' || io_account.account_type
                             || '], currency [' || io_account.currency
                             || '], inst_id [' || io_account.inst_id
                             || '], agent_id [' || io_account.agent_id
                             || '], status [' || io_account.status || ']}'
    );
    -- Checking for existance of initial service
    select com_api_type_pkg.convert_to_number(c.element_value) as service_id
      bulk collect into l_service_tab
      from app_ui_data_vw a
         , app_ui_data_vw b
         , app_data c
     where a.id = i_appl_data_id
       and b.appl_id = a.appl_id
       and a.name = 'ACCOUNT'
       and b.name = 'SERVICE_OBJECT'
       and c.id = b.parent_id
       and com_api_type_pkg.convert_to_char(a.id) = b.element_value;

    l_is_initial := com_api_const_pkg.FALSE;

    for i in 1 .. l_service_tab.count loop
        begin
            select st.is_initial
                 , s.id
              into l_is_initial
                 , l_appl_service_id
              from prd_service s
                 , prd_service_type st
             where s.id = l_service_tab(i)
               and s.service_type_id = st.id;
        exception
            when no_data_found then
                l_is_initial := com_api_const_pkg.FALSE;
        end;
        exit when l_is_initial = com_api_const_pkg.TRUE;
    end loop;

    if l_is_initial = com_api_const_pkg.FALSE then
        com_api_error_pkg.raise_error(
            i_error      => 'INITIAL_SERVICE_NOT_FOUND'
          , i_env_param1 => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_env_param2 => i_appl_data_id
        );
    end if;

    trc_log_pkg.debug(
        i_text       => 'Checking found initial service [#1] with service contract''s product; '
                     || 'io_account.account_type [#2], io_account.currency [#3]'
      , i_env_param1 => l_appl_service_id
      , i_env_param2 => io_account.account_type
      , i_env_param3 => io_account.currency
    );

    declare
        l_service_id       com_api_type_pkg.t_short_id;
    begin
        select
            a.service_id
        into
            l_service_id
        from
            acc_product_account_type a
            , prd_contract b
        where
            a.product_id = b.product_id
            and b.id = i_contract_id
            and a.account_type = io_account.account_type
            and (a.currency = io_account.currency or a.currency is null)
            and a.service_id = l_appl_service_id;

        trc_log_pkg.debug('l_service_id [' || l_service_id || ']');
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error       => 'SERVICE_PARAM_NOT_EQUAL'
              , i_env_param1  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_env_param2  => l_appl_service_id
              , i_env_param3  => l_service_id
              , i_env_param4  => i_contract_id
            );
    end;

    app_api_application_pkg.get_element_value(
        i_element_name   =>  'ACCOUNT_COUNT'
      , i_parent_id      =>  i_appl_data_id
      , o_element_value  =>  l_account_count
    );
    trc_log_pkg.debug('l_account_count [' || l_account_count || ']');

    select object_id
      bulk collect into l_card_id_tab
      from app_object
     where appl_id     = app_api_application_pkg.get_appl_id
       and entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD;

    trc_log_pkg.debug(LOG_PREFIX || 'Get list of card ids. Count [' || l_card_id_tab.count || ']');

    l_contract_type := prd_api_contract_pkg.get_contract(
                           i_contract_id  => i_contract_id
                         , i_raise_error  => com_api_const_pkg.TRUE
                       ).contract_type;

    -- pool of accounts
    if nvl(l_account_count, 0) > 1 then

        if l_contract_type = prd_api_const_pkg.CONTRACT_TYPE_ACCOUNT_POOL then
            if l_card_id_tab.count > 0 then
                com_api_error_pkg.raise_error(
                    i_error       => 'INCORRECT_TAG_CARD_FOR_CONTRACT_TYPE'
                  , i_env_param1  => l_contract_type
                );
            end if;

        else
            if l_contract_type != prd_api_const_pkg.CONTRACT_TYPE_PREPAID_CARD then
                com_api_error_pkg.raise_error(
                    i_error       => 'INCORRECT_CONTRACT_TYPE_FOR_POOL_OF_ACCOUNTS'
                  , i_env_param1  => l_contract_type
                  , i_env_param2  => prd_api_const_pkg.CONTRACT_TYPE_PREPAID_CARD
                  , i_env_param3  => l_account_count
                );
            end if;

            if l_card_count != l_account_count then
                com_api_error_pkg.raise_error(
                    i_error       => 'CARD_COUNT_NOT_EQUAL_ACCOUNT_COUNT'
                  , i_env_param1  => l_card_count
                  , i_env_param2  => l_account_count
                );
            end if;

            select nvl(max(to_number(d.element_value, com_api_const_pkg.NUMBER_FORMAT)), 0)
              into l_card_count
              from app_data d
                 , app_element e
             where d.appl_id = app_api_application_pkg.get_appl_id
               and e.id      = d.element_id
               and e.name    = 'CARD_COUNT';

            trc_log_pkg.debug('l_card_count [' || l_card_count || ']');

            select d.id
              bulk collect into l_card_appl_data_tab
              from app_data d
                 , app_element e
             where e.id = d.element_id
               and e.name = 'CARD'
               and d.appl_id = app_api_application_pkg.get_appl_id;

        end if;

    else
         -- check only if count set explicitly
        if l_account_count is not null and l_contract_type = prd_api_const_pkg.CONTRACT_TYPE_PREPAID_CARD then
            select nvl(max(to_number(d.element_value, com_api_const_pkg.NUMBER_FORMAT)), 0)
              into l_card_count
              from app_data d
                 , app_element e
             where d.appl_id = app_api_application_pkg.get_appl_id
               and e.id      = d.element_id
               and e.name    = 'CARD_COUNT';

            trc_log_pkg.debug('l_card_count [' || l_card_count || ']');

            -- if not equal, then raise error
            if l_card_count != l_account_count then
                com_api_error_pkg.raise_error(
                    i_error       => 'CARD_COUNT_NOT_EQUAL_ACCOUNT_COUNT'
                  , i_env_param1  => l_card_count
                  , i_env_param2  => l_account_count
                );
            end if;
        end if;
        -- one account
        l_account_count := 1;
        trc_log_pkg.debug(LOG_PREFIX || 'set up account count to 1');
    end if;
    
    for i in 1..l_account_count loop
        trc_log_pkg.debug('Start creating accounts, i=' || i || ' (of ' || l_account_count || ')');

        -- Clear account number on a new iteration
        if l_account_count > 1 then
            io_account.account_number := null;
        end if;

        trc_log_pkg.debug('Current account application type is ' || app_api_application_pkg.get_appl_type || '.');

        if app_api_application_pkg.get_appl_type = app_api_const_pkg.APPL_TYPE_INSTITUTION then 

            acc_api_account_pkg.create_gl_account(
                o_id                  => io_account.account_id
              , io_account_number     => io_account.account_number
              , i_entity_type         => ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
              , i_account_type        => io_account.account_type
              , i_currency            => io_account.currency
              , i_inst_id             => io_account.inst_id
              , i_agent_id            => coalesce(
                                             io_account.agent_id
                                           , ost_ui_institution_pkg.get_default_agent(i_inst_id => io_account.inst_id)
                                         )
            );

            trc_log_pkg.debug('GL-account with id=' || io_account.account_id || ' created, i=' || i || ' (of ' || l_account_count || ')');

        else

            acc_api_account_pkg.create_account(
                o_id               => io_account.account_id
              , io_split_hash      => l_split_hash
              , i_account_type     => io_account.account_type
              , io_account_number  => io_account.account_number
              , i_currency         => io_account.currency
              , i_inst_id          => io_account.inst_id
              , i_agent_id         => coalesce(
                                          io_account.agent_id
                                        , ost_ui_institution_pkg.get_default_agent(i_inst_id => io_account.inst_id)
                                      )
              , i_status           => nvl(io_account.status, acc_api_const_pkg.ACCOUNT_STATUS_ACTIVE)
              , i_contract_id      => i_contract_id
              , i_customer_id      => i_customer_id
              , i_customer_number  => prd_api_customer_pkg.get_customer_number(i_customer_id => i_customer_id)
            );

        end if;

        change_objects(
            i_appl_data_id     => i_appl_data_id
          , i_account_id       => io_account.account_id
          , i_contract_id      => i_contract_id
          , i_inst_id          => io_account.inst_id
          , i_agent_id         => nvl(io_account.agent_id, ost_ui_institution_pkg.get_default_agent(io_account.inst_id))
          , i_customer_id      => i_customer_id
        );

        -- This code needed for copy block of account and for link account_object with card
        if i = 1 then
            l_account_block_id  := i_appl_data_id;
            l_account_block_rec := app_api_application_pkg.get_appl_data_rec(
                                       i_appl_data_id => i_appl_data_id
                                   );
        else
            -- Create an associative array with elements that should be skipped
            -- during copying (cloning) an entire block with root i_appl_data_id
            l_skipped_elements('ACCOUNT_COUNT') := null;
            l_skipped_elements('COMMAND')       := null;
            -- Add a new block ACCOUNT to block CONTRACT
            app_api_application_pkg.clone_block(
                i_root_appl_id     => i_appl_data_id
              , i_dest_appl_id     => l_account_block_rec.parent_id
              , i_skipped_elements => l_skipped_elements
              , i_serial_number    => l_account_block_rec.serial_number + i - 1
              , o_new_appl_id      => l_account_block_id
            );

            --modify reference to card
            app_api_application_pkg.get_appl_data_id(
                i_element_name      => 'ACCOUNT_OBJECT'
              , i_parent_id         => l_account_block_id--i_appl_data_id
              , o_appl_data_id      => l_appl_data_id
            );

            if l_card_appl_data_tab.exists(i) then
                if l_appl_data_id is null then
                    app_api_application_pkg.add_element(
                        i_element_name      => 'ACCOUNT_OBJECT'
                      , i_parent_id         => l_account_block_id--i_appl_data_id
                      , i_element_value     => l_card_appl_data_tab(i)
                    );
                else
                    app_api_application_pkg.modify_element(
                        i_appl_data_id      => l_appl_data_id
                      , i_element_value     => l_card_appl_data_tab(i)
                    );
                end if;
            end if;

            trc_log_pkg.debug('Added block l_account_block_id [' || l_account_block_id || ']');
        end if;

        app_api_application_pkg.get_appl_data_id(
            i_element_name      => 'ACCOUNT_NUMBER'
          , i_parent_id         => l_account_block_id--i_appl_data_id
          , o_appl_data_id      => l_appl_data_id
        );

        trc_log_pkg.debug(
            i_text => 'Searching element ACCOUNT_NUMBER in application structure: l_appl_data_id [' || l_appl_data_id
                   || '], io_account.account_id [' || io_account.account_id
                   || '], io_account.account_number [' || io_account.account_number || ']'
        );

        if l_appl_data_id is null then
            app_api_application_pkg.add_element(
                i_element_name      => 'ACCOUNT_NUMBER'
              , i_parent_id         => l_account_block_id--i_appl_data_id
              , i_element_value     => io_account.account_number
            );
            app_api_application_pkg.get_appl_data_id(
                i_element_name      => 'ACCOUNT_NUMBER'
              , i_parent_id         => l_account_block_id--i_appl_data_id
              , o_appl_data_id      => l_appl_data_id
            );
            trc_log_pkg.debug('Element ACCOUNT_NUMBER is added: l_appl_data_id [' || l_appl_data_id || ']');

        else
            app_api_application_pkg.modify_element(
                i_appl_data_id      => l_appl_data_id
              , i_element_value     => io_account.account_number
            );
        end if;
                                    
        if l_account_count = 1 then
            trc_log_pkg.debug(LOG_PREFIX || 'exec attach_account ' || i_appl_data_id);
            attach_account(
                i_appl_data_id  => i_appl_data_id
              , i_account_id    => io_account.account_id
              , i_inst_id       => io_account.inst_id
            );
        else
            if l_card_id_tab.count > 0 then
                attach_account_to_card(
                    i_account_id    => io_account.account_id
                  , i_card_id       => l_card_id_tab(i)
                );
            end if;

            attach_account_to_application(
                i_account_id  => io_account.account_id
            );
        end if;
    end loop;

    trc_log_pkg.debug(LOG_PREFIX || 'END');
end create_account;

procedure process_account(
    i_appl_data_id   in            com_api_type_pkg.t_long_id
  , i_inst_id        in            com_api_type_pkg.t_inst_id
  , i_agent_id       in            com_api_type_pkg.t_short_id
  , i_customer_id    in            com_api_type_pkg.t_medium_id
  , i_contract_id    in            com_api_type_pkg.t_medium_id
  , o_account_id    out            com_api_type_pkg.t_medium_id
) is
    LOG_PREFIX  constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_account: ';
    l_command            com_api_type_pkg.t_dict_value;
    l_account            acc_api_type_pkg.t_account_rec;
    l_detached_account   acc_api_type_pkg.t_account_rec;
    l_contract_id        com_api_type_pkg.t_medium_id;
    l_value_tab          com_api_type_pkg.t_param_tab;
    l_status_reason      com_api_type_pkg.t_dict_value;
begin
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'START with i_appl_data_id [' || i_appl_data_id
                             || '], i_customer_id [' || i_customer_id || '], i_contract_id [' || i_contract_id
                             || '], i_agent_id [' || i_agent_id || '], i_inst_id [' || i_inst_id || ']'
    );

    l_contract_id := i_contract_id;

    cst_api_application_pkg.process_account_before(
        i_appl_data_id  => i_appl_data_id
      , i_inst_id       => i_inst_id
      , i_agent_id      => i_agent_id
      , i_customer_id   => i_customer_id
      , io_contract_id  => l_contract_id
    );
    trc_log_pkg.debug('l_contract_id [' || l_contract_id || ']');

    app_api_application_pkg.get_element_value(
        i_element_name   => 'COMMAND'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_command
    );

    get_account_appl_data(
        i_appl_data_id  => i_appl_data_id
      , o_account       => l_account
      , o_value_tab     => l_value_tab
    );

    l_status_reason := l_value_tab('STATUS_REASON');

    l_account.customer_id := prd_api_contract_pkg.get_contract(
                                 i_contract_id => i_contract_id
                               , i_raise_error => com_api_const_pkg.TRUE
                             ).customer_id;
    trc_log_pkg.debug('Customer by l_contract_id is found: l_account.customer_id [' || l_account.customer_id || ']');

    begin
        select id
          into l_account.account_id
          from acc_account
         where account_number = l_account.account_number
           and inst_id        = i_inst_id
           and customer_id    = i_customer_id;

        trc_log_pkg.debug('Account is found with account_id [' || l_account.account_id ||
                                       '] by account_number [' || l_account.account_number || ']');

        if l_command = app_api_const_pkg.COMMAND_CREATE_OR_PROCEED then
            change_objects(
                i_appl_data_id  => i_appl_data_id
              , i_account_id    => l_account.account_id
              , i_contract_id   => l_contract_id
              , i_inst_id       => i_inst_id
              , i_agent_id      => i_agent_id
              , i_customer_id   => i_customer_id
            );
            attach_account(
                i_appl_data_id  => i_appl_data_id
              , i_account_id    => l_account.account_id
              , i_inst_id       => i_inst_id
            );
        elsif l_command = app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT then
            com_api_error_pkg.raise_error(
                i_error         => 'ACCOUNT_ALREADY_EXIST'
              , i_env_param1    => l_account.account_number
              , i_env_param2    => i_inst_id
              , i_env_param3    => i_customer_id
            );
        elsif l_command in (
            app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
          , app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
        ) then
            change_account(
                i_appl_data_id  => i_appl_data_id
              , i_customer_id   => i_customer_id
              , i_contract_id   => l_contract_id
              , io_account      => l_account
              , i_status_reason => l_status_reason
            );
            attach_account(
                i_appl_data_id  => i_appl_data_id
              , i_account_id    => l_account.account_id
              , i_inst_id       => i_inst_id
            );
        elsif l_command = app_api_const_pkg.COMMAND_EXCEPT_OR_PROCEED then
            change_objects(
                i_appl_data_id  => i_appl_data_id
              , i_account_id    => l_account.account_id
              , i_contract_id   => l_contract_id
              , i_inst_id       => i_inst_id
              , i_agent_id      => i_agent_id
              , i_customer_id   => i_customer_id
            );
            attach_account(
                i_appl_data_id  => i_appl_data_id
              , i_account_id    => l_account.account_id
              , i_inst_id       => i_inst_id
            );
        elsif l_command = app_api_const_pkg.COMMAND_EXCEPT_OR_REMOVE then
            -- close service
            app_api_service_pkg.close_service(
                i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id     => l_account.account_id
              , i_inst_id       => i_inst_id
            );
            acc_api_account_pkg.close_account(
                i_account_id    => l_account.account_id
            );
        else
            attach_account(
                i_appl_data_id  => i_appl_data_id
              , i_account_id    => l_account.account_id
              , i_inst_id       => i_inst_id
            );
        end if;

    exception
        when no_data_found then
            trc_log_pkg.debug('Account is NOT found by account number ' || l_account.account_number);

            if l_command = app_api_const_pkg.COMMAND_PROCEED_OR_REMOVE then
                -- This command may be used for unlinking (detaching) account from another customer.
                -- Example: flow #1009, linking issuied card with real customer
                --          and detaching it from source agent customer.

                -- Search account that doesn't belong to <i_customer_id>
                l_detached_account := acc_api_account_pkg.get_account(
                                          i_account_id     => null
                                        , i_account_number => l_account.account_number
                                        , i_inst_id        => i_inst_id
                                        , i_mask_error     => com_api_const_pkg.TRUE
                                      );
                if l_detached_account.account_id is not null then
                    attach_account(
                        i_appl_data_id  => i_appl_data_id
                      , i_account_id    => l_detached_account.account_id
                      , i_inst_id       => i_inst_id
                      , i_detach_only   => com_api_const_pkg.TRUE -- forbid attaching account
                      , i_mask_error    => com_api_const_pkg.TRUE
                    );
                end if;
            elsif l_command in (
                app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
              , app_api_const_pkg.COMMAND_EXCEPT_OR_REMOVE
              , app_api_const_pkg.COMMAND_EXCEPT_OR_PROCEED
            ) then
                com_api_error_pkg.raise_error(
                    i_error         => 'ACCOUNT_NOT_FOUND'
                  , i_env_param1    => l_account.account_number
                  , i_env_param2    => i_inst_id
                  , i_env_param3    => nvl(prd_api_customer_pkg.get_customer_number(i_customer_id => i_customer_id), i_customer_id)
                );
            --elsif l_command in (
            --    app_api_const_pkg.COMMAND_CREATE_OR_PROCEED
            --  , app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
            --  , app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT
            --) then
            else
                create_account(
                    i_appl_data_id  => i_appl_data_id
                  , i_contract_id   => l_contract_id
                  , i_customer_id   => i_customer_id
                  , io_account      => l_account
                );
            end if;
    end;
    
    app_api_note_pkg.process_note(
        i_appl_data_id => i_appl_data_id
      , i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
      , i_object_id    => l_account.account_id
    );
    
    attach_account_to_application (
        i_account_id    => l_account.account_id
    );

    cst_api_application_pkg.process_account_after (
        i_appl_data_id  => i_appl_data_id
      , i_inst_id       => i_inst_id
      , i_agent_id      => i_agent_id
      , i_customer_id   => i_customer_id
      , i_contract_id   => l_contract_id
    );

    o_account_id := l_account.account_id;

    trc_log_pkg.debug(LOG_PREFIX || 'END');

exception
    when com_api_error_pkg.e_application_error then
        app_api_error_pkg.intercept_error(
            i_appl_data_id  => i_appl_data_id
          , i_element_name  => 'ACCOUNT'
        );
end process_account;

end app_api_account_pkg;
/
