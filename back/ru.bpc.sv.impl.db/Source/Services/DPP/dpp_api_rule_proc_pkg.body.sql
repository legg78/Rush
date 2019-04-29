create or replace package body dpp_api_rule_proc_pkg is
/*********************************************************
*  DPP rules processing <br />
*  Created by Alalykin A.(alalykin@bpcbt.com) at 11.05.2017 <br />
*  Module: DPP_API_RULE_PROC_PKG <br />
*  @headcom
**********************************************************/

/*
 * Get the DPP parameters from current operation (i_oper_id is null)
 * or from the current(oper_id)/matched authorization.
*/
procedure get_auth_parameters(
    i_oper_id               in      com_api_type_pkg.t_long_id          default null
  , o_calc_algorithm            out com_api_type_pkg.t_dict_value
  , o_instalment_count          out com_api_type_pkg.t_tiny_id
  , o_instalment_amount         out com_api_type_pkg.t_money
  , o_first_payment_date        out date
  , o_percent_rate              out com_api_type_pkg.t_money
  , o_fee_id                    out com_api_type_pkg.t_short_id
) is
    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_auth_parameters';
    l_operation                     opr_api_type_pkg.t_oper_rec;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' << i_oper_id [#1]'
      , i_env_param1 => i_oper_id
    );

    if i_oper_id is null then
        l_operation := opr_api_shared_data_pkg.get_operation();
    else
        opr_api_operation_pkg.get_operation(
            i_oper_id     => i_oper_id
          , o_operation   => l_operation
        );
    end if;

    -- A presenment doesn't have its own authorization so find the original operation
    if l_operation.msg_type = opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT then
        l_operation.id := nvl(l_operation.match_id, l_operation.id);
    end if;

    o_calc_algorithm :=
        aup_api_tag_pkg.get_tag_value(
            i_auth_id   => l_operation.id
          , i_tag_id    => aup_api_tag_pkg.find_tag_by_reference('DF8C25')
        );

    o_percent_rate :=
        to_number(
            aup_api_tag_pkg.get_tag_value(
                i_auth_id  => l_operation.id
              , i_tag_id   => aup_api_tag_pkg.find_tag_by_reference('DF8C21')
            )
        );

    o_instalment_count :=
        to_number(
            aup_api_tag_pkg.get_tag_value(
                i_auth_id  => l_operation.id
              , i_tag_id   => aup_api_tag_pkg.find_tag_by_reference('DF8C23')
            )
        );

    o_instalment_amount :=
        to_number(
            aup_api_tag_pkg.get_tag_value(
                i_auth_id  => l_operation.id
              , i_tag_id   => aup_api_tag_pkg.find_tag_by_reference('DF8C24')
            )
        );

    o_first_payment_date :=
        to_date(
            aup_api_tag_pkg.get_tag_value(
                i_auth_id  => l_operation.id
              , i_tag_id   => aup_api_tag_pkg.find_tag_by_reference('DF8C22')
            )
          , 'DDMMYYYY'
        );

    o_fee_id :=
        to_number(
            aup_api_tag_pkg.get_tag_value(
                i_auth_id  => l_operation.id
              , i_tag_id   => aup_api_tag_pkg.find_tag_by_reference('DF835D')
            )
        );

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' >> o_calc_algorithm [#1], o_percent_rate [#5], o_fee_id [#6]'
                     || ', o_instalment_count [#2], o_instalment_amount [#3], o_first_payment_date [#4]'
      , i_env_param1 => o_calc_algorithm
      , i_env_param2 => o_instalment_count
      , i_env_param3 => o_instalment_amount
      , i_env_param4 => o_first_payment_date
      , i_env_param5 => o_percent_rate
      , i_env_param6 => o_fee_id
    );
end get_auth_parameters;

procedure register_dpp is
    l_macros_type                   com_api_type_pkg.t_tiny_id;
    l_macros_id                     com_api_type_pkg.t_long_id;
    l_amount_name                   com_api_type_pkg.t_name;
    l_amount                        com_api_type_pkg.t_amount_rec;
    l_amount_value                  com_api_type_pkg.t_money;
    l_account                       acc_api_type_pkg.t_account_rec;
    l_oper_id                       com_api_type_pkg.t_long_id;
    l_iss_participant               opr_api_type_pkg.t_oper_part_rec;
    l_credit_service_id             com_api_type_pkg.t_short_id;
    l_eff_date                      date;
    l_use_autocreation              com_api_type_pkg.t_boolean;
    l_autocreation_threshold        com_api_type_pkg.t_money;
    l_create_operation              com_api_type_pkg.t_boolean;

    l_calc_algorithm                com_api_type_pkg.t_dict_value;
    l_instalment_count              com_api_type_pkg.t_tiny_id;
    l_instalment_amount             com_api_type_pkg.t_money;
    l_first_payment_date            date;
    l_percent_rate                  com_api_type_pkg.t_money;
    l_fee_id                        com_api_type_pkg.t_short_id;

    procedure get_dpp_autocreation_params(
        io_account           in out acc_api_type_pkg.t_account_rec
      , i_eff_date           in     date
      , o_use_autocreation      out com_api_type_pkg.t_boolean
      , o_threshold             out com_api_type_pkg.t_money
    ) is
        l_dpp_service_id            com_api_type_pkg.t_short_id;
        l_product_id                com_api_type_pkg.t_short_id;
    begin
        trc_log_pkg.debug(
            i_text => 'Getting DPP auto-creation attributes'
        );

        l_dpp_service_id :=
            prd_api_service_pkg.get_active_service_id(
                i_entity_type      => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id        => io_account.account_id
              , i_attr_name        => null
              , i_service_type_id  => dpp_api_const_pkg.DPP_SERVICE_TYPE_ID
              , i_split_hash       => io_account.split_hash
              , i_eff_date         => i_eff_date
              , i_mask_error       => com_api_const_pkg.TRUE
            );

        if l_dpp_service_id is null then
            com_api_error_pkg.raise_error(
                i_error       => 'DPP_SERVICE_NOT_FOUND'
              , i_env_param1  => io_account.account_id
              , i_env_param2  => io_account.account_number
              , i_mask_error  => com_api_const_pkg.TRUE -- Consider this as a warning and exit the rule
            );
        end if;

        if opr_api_shared_data_pkg.get_operation().oper_type = dpp_api_const_pkg.OPERATION_TYPE_DPP_REGISTER then
            -- It is the case when an instalment plan is registered by processing of operation "DPP registration",
            -- so that Auto-creation settings should be ignored and the plan should always be created
            o_threshold        := 0;
            o_use_autocreation := com_api_const_pkg.TRUE;
        else
            -- Therefore, Auto-creation settings should be used only for the case of registering an instalment plan
            -- is performed on processing some purchase operation (non "DPP registration"!)
            l_product_id :=
                prd_api_product_pkg.get_product_id(
                    i_entity_type      => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                  , i_object_id        => io_account.account_id
                  , i_eff_date         => i_eff_date
                  , i_inst_id          => io_account.inst_id
                );

            trc_log_pkg.debug(
                i_text => 'l_dpp_service_id [' || l_dpp_service_id || '], l_product_id [' || l_product_id || ']'
            );

            begin
                o_use_autocreation :=
                    prd_api_product_pkg.get_attr_value_number(
                        i_product_id   => l_product_id
                      , i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                      , i_object_id    => io_account.account_id
                      , i_attr_name    => dpp_api_const_pkg.ATTR_USE_AUTOCREATION
                      , i_service_id   => l_dpp_service_id
                      , i_eff_date     => i_eff_date
                      , i_split_hash   => io_account.split_hash
                      , i_inst_id      => io_account.inst_id
                      , i_params       => opr_api_shared_data_pkg.g_params
                      , i_mask_error   => com_api_const_pkg.TRUE
                    );
                if o_use_autocreation = com_api_const_pkg.TRUE then
                    prd_api_product_pkg.get_fee_amount(
                        i_product_id      => l_product_id
                      , i_entity_type     => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                      , i_object_id       => io_account.account_id
                      , i_fee_type        => dpp_api_const_pkg.FEE_TYPE_AUTOCREATION_THRSHLD
                      , i_params          => opr_api_shared_data_pkg.g_params
                      , i_service_id      => l_dpp_service_id
                      , i_eff_date        => i_eff_date
                      , i_split_hash      => io_account.split_hash
                      , i_inst_id         => io_account.inst_id
                      , i_base_amount     => 0
                      , i_base_currency   => io_account.currency
                      , io_fee_currency   => io_account.currency
                      , o_fee_amount      => o_threshold
                      , i_mask_error      => com_api_const_pkg.TRUE
                    );
                end if;
            exception
                when com_api_error_pkg.e_application_error then
                    trc_log_pkg.debug(
                        i_text => 'DPP auto-creation is not used/defined for the account: '
                               ||    'account_id [' || io_account.account_id
                               || '], inst_id ['    || io_account.inst_id
                               || '], split_hash [' || io_account.split_hash
                               || ']; i_eff_date [' || to_char(i_eff_date, com_api_const_pkg.LOG_DATE_FORMAT)
                               || '], o_use_autocreation [' || o_use_autocreation
                               || '], o_threshold ['        || o_threshold || ']'
                    );
            end;
        end if;

        trc_log_pkg.debug(
            i_text       => 'DPP auto-creation attributes: use auto-creation [#1], threshold [#2]'
          , i_env_param1 => case o_use_autocreation
                                when com_api_const_pkg.TRUE  then 'true'
                                when com_api_const_pkg.FALSE then 'false'
                                                             else 'NULL'
                            end
          , i_env_param2 => o_threshold
        );
    end get_dpp_autocreation_params;

begin
    l_eff_date := com_api_sttl_day_pkg.get_sysdate();

    opr_api_shared_data_pkg.get_account(
        i_name         => opr_api_shared_data_pkg.get_param_char('ACCOUNT_NAME')
      , o_account_rec  => l_account
    );

    l_credit_service_id :=
        crd_api_service_pkg.get_active_service(
            i_account_id  => l_account.account_id
          , i_eff_date    => l_eff_date
          , i_split_hash  => l_account.split_hash
          , i_mask_error  => com_api_const_pkg.TRUE
        );

    if l_credit_service_id is null then
        trc_log_pkg.debug(
            i_text        => 'Credit service is not found on account with ID [#1], EXIT the rule'
          , i_env_param1  => l_account.account_id
        );
    else
        acc_api_entry_pkg.flush_job;

        l_create_operation := nvl(
                                  opr_api_shared_data_pkg.get_param_num(
                                      i_name       => 'CREATE_OPERATION'
                                    , i_mask_error => com_api_const_pkg.TRUE
                                  )
                                , com_api_const_pkg.TRUE
                              );
        l_oper_id          := opr_api_shared_data_pkg.get_operation_id(
                                  i_selector => opr_api_shared_data_pkg.get_param_char(
                                                    i_name         => 'OPERATION_SELECTOR'
                                                  , i_mask_error   => com_api_const_pkg.TRUE
                                                  , i_error_value  => opr_api_const_pkg.OPER_SELECTOR_CURRENT
                                                )
                              );
        l_iss_participant  := opr_api_shared_data_pkg.get_participant(
                                  i_participant_type => com_api_const_pkg.PARTICIPANT_ISSUER
                              );
        l_macros_type      := opr_api_shared_data_pkg.get_param_num(
                                  i_name         => 'MACROS_TYPE'
                              );
        l_amount_name      := opr_api_shared_data_pkg.get_param_char(
                                  i_name         => 'AMOUNT_NAME'
                                , i_mask_error   => com_api_type_pkg.TRUE
                                , i_error_value  => null
                              );
        if l_amount_name is not null then
            opr_api_shared_data_pkg.get_amount(
                i_name      => l_amount_name
              , o_amount    => l_amount.amount
              , o_currency  => l_amount.currency
            );
        end if;

        select min(m.id)     keep (dense_rank first order by e.posting_order desc) as macros_id
             , min(m.amount) keep (dense_rank first order by e.posting_order desc) as macros_amount
          into l_macros_id
             , l_amount_value
          from acc_macros m
             , acc_entry e
             , acc_account a
             , prd_contract c
         where m.macros_type_id = l_macros_type
           and m.entity_type    = opr_api_const_pkg.ENTITY_TYPE_OPERATION
           and m.object_id      = l_oper_id
           and e.macros_id      = m.id
           and m.account_id     = a.id
           and a.contract_id    = c.id;

        trc_log_pkg.debug(
            i_text        => 'Incoming amount [#1], macros amount [#2], macros ID [#3]'
          , i_env_param1  => l_amount.amount
          , i_env_param2  => l_amount_value
          , i_env_param3  => l_macros_id
        );

        l_amount_value := nvl(l_amount.amount, l_amount_value);

        get_dpp_autocreation_params(
            io_account         => l_account
          , i_eff_date         => l_eff_date
          , o_use_autocreation => l_use_autocreation
          , o_threshold        => l_autocreation_threshold
        );

        if l_create_operation = com_api_const_pkg.FALSE and l_macros_id is null then
            l_macros_id := com_api_id_pkg.get_id(i_seq => acc_macros_seq.nextval);
        end if;

        if l_use_autocreation = com_api_const_pkg.FALSE then
            trc_log_pkg.info(
                i_text        => 'DPP_AUTO_CREATION_IS_DISABLED'
              , i_env_param1  => l_account.account_id
              , i_env_param2  => l_account.account_number
            );
        elsif l_amount_value is null or l_macros_id is null then
            com_api_error_pkg.raise_error(
                i_error       => 'IMPOSSIBLE_TO_REGISTER_DPP'
              , i_env_param1  => l_amount_value
              , i_env_param2  => l_macros_id
            );
        elsif l_use_autocreation = com_api_const_pkg.TRUE
              and
              l_amount_value < l_autocreation_threshold
        then
            trc_log_pkg.info(
                i_text        => 'AMOUNT_IS_NOT_SUFFICIENT_FOR_DPP_AUTO_CREATION'
              , i_env_param1  => l_amount_value
              , i_env_param2  => l_autocreation_threshold
            );
        else
            get_auth_parameters(
                i_oper_id            => opr_api_shared_data_pkg.get_operation().id
              , o_calc_algorithm     => l_calc_algorithm
              , o_instalment_count   => l_instalment_count
              , o_instalment_amount  => l_instalment_amount
              , o_first_payment_date => l_first_payment_date
              , o_percent_rate       => l_percent_rate
              , o_fee_id             => l_fee_id
            );

            dpp_api_payment_plan_pkg.register_dpp(
                i_account_id         => l_account.account_id
              , i_dpp_algorithm      => l_calc_algorithm
              , i_instalment_count   => l_instalment_count
              , i_instalment_amount  => l_instalment_amount
              , i_fee_id             => l_fee_id
              , i_percent_rate       => l_percent_rate
              , i_first_payment_date => l_first_payment_date
              , i_dpp_amount         => l_amount_value
              , i_dpp_currency       => l_account.currency
              , i_macros_id          => l_macros_id
              , i_oper_id            => l_oper_id
              , i_param_tab          => opr_api_shared_data_pkg.g_params
              , i_create_reg_oper    => l_create_operation
            );

            if l_amount_name is not null and l_amount.amount is null then
                opr_api_shared_data_pkg.set_amount(
                    i_name      => l_amount_name
                  , i_amount    => l_amount_value
                  , i_currency  => l_account.currency
                );
            end if;
        end if;
    end if;

exception
    when com_api_error_pkg.e_application_error then
        if com_api_error_pkg.get_last_error() = 'DPP_SERVICE_NOT_FOUND' then
            trc_log_pkg.debug(
                i_text        => 'DPP service is missing, EXIT the rule'
            );
        else
            raise;
        end if;
end register_dpp;

procedure accelerate_dpps as
    l_account_name                  com_api_type_pkg.t_name;
    l_account                       acc_api_type_pkg.t_account_rec;
    l_acceleration_type             com_api_type_pkg.t_dict_value;
    l_balance                       com_api_type_pkg.t_amount_rec;
begin
    l_acceleration_type :=
        nvl(
            opr_api_shared_data_pkg.get_param_char(
                i_name       => 'DPP_ACCELERATION_TYPE'
              , i_mask_error => com_api_type_pkg.TRUE
            )
          , dpp_api_const_pkg.DPP_ACCELERT_KEEP_INSTLMT_AMT
        );
    l_account_name := opr_api_shared_data_pkg.get_param_char(i_name => 'ACCOUNT_NAME');

    opr_api_shared_data_pkg.get_account(
        i_name              => l_account_name
      , o_account_rec       => l_account
      , i_mask_error        => com_api_const_pkg.FALSE
      , i_error_value       => null
    );

    l_balance :=
        acc_api_balance_pkg.get_balance_amount(
            i_account_id     => l_account.account_id
          , i_balance_type   => acc_api_const_pkg.BALANCE_TYPE_LEDGER
          , i_date           => opr_api_shared_data_pkg.get_operation().oper_date
          , i_date_type      => com_api_const_pkg.DATE_PURPOSE_PROCESSING
          , i_mask_error     => com_api_type_pkg.FALSE
        );

    trc_log_pkg.debug(
        i_text        => 'account [#1] balance [#2]'
      , i_env_param1  => l_account.account_id
      , i_env_param2  => l_balance.amount
    );

    if l_balance.amount > 0 then
        dpp_api_payment_plan_pkg.accelerate_dpps(
            i_account_id        => l_account.account_id
          , i_payment_amount    => l_balance.amount
          , i_acceleration_type => l_acceleration_type
        );
    end if;
end accelerate_dpps;

procedure register_instalment_event
is
    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.register_instalment_event: ';
    l_object_id                     com_api_type_pkg.t_long_id;
    l_event_date                    date;
    l_entity_type                   com_api_type_pkg.t_dict_value;
    l_event_type                    com_api_type_pkg.t_dict_value;
    l_entity_object_type            com_api_type_pkg.t_dict_value;
    l_event_object_type             com_api_type_pkg.t_dict_value;
    l_params                        com_api_type_pkg.t_param_tab;
    l_rec_count                     com_api_type_pkg.t_tiny_id := 0;
begin
    l_object_id          := evt_api_shared_data_pkg.get_param_num('OBJECT_ID');
    l_entity_type        := evt_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_event_type         := evt_api_shared_data_pkg.get_param_char('EVENT_TYPE');
    l_event_date         := evt_api_shared_data_pkg.get_param_date('EVENT_DATE');
    l_entity_object_type := evt_api_shared_data_pkg.get_param_char('ENTITY_OBJECT_TYPE');
    l_event_object_type  := evt_api_shared_data_pkg.get_param_char('EVENT_OBJECT_TYPE');

    if l_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
        if l_entity_object_type = dpp_api_const_pkg.ENTITY_TYPE_INSTALMENT then
            for r in (select a.customer_id
                           , a.inst_id
                           , a.split_hash
                           , dpi.id as instalment_id
                        from acc_account a
                           , dpp_payment_plan dpp
                           , dpp_instalment dpi
                       where a.id = l_object_id
                         and decode(dpp.status, 'DOST0100', dpp.account_id, null) = a.id
                         and decode(dpi.macros_id,null,dpi.dpp_id,null) = dpp.id
                         and trunc(dpi.instalment_date) = trunc(l_event_date)
                     )
            loop
                rul_api_param_pkg.set_param(
                    i_name    => 'SRC_ENTITY_TYPE'
                  , i_value   => prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
                  , io_params => l_params
                );
                rul_api_param_pkg.set_param(
                    i_name    => 'SRC_OBJECT_ID'
                  , i_value   => prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
                  , io_params => l_params
                );

                evt_api_event_pkg.register_event(
                    i_event_type  => l_event_object_type
                  , i_eff_date    => l_event_date
                  , i_entity_type => l_entity_object_type
                  , i_object_id   => r.instalment_id
                  , i_inst_id     => r.inst_id
                  , i_split_hash  => r.split_hash
                  , i_param_tab   => l_params
                );
                l_rec_count := l_rec_count + 1;
            end loop;
        else
            com_api_error_pkg.raise_error(
                i_error      => 'ENTITY_TYPE_NOT_SUPPORTED'
              , i_env_param1 => l_entity_object_type
            );
        end if;

    else
        com_api_error_pkg.raise_error(
            i_error      => 'ENTITY_TYPE_NOT_SUPPORTED'
          , i_env_param1 => l_entity_type
        );
    end if;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'finished success with count record processed [#1]'
      , i_env_param1 => l_rec_count
    );
end register_instalment_event;

procedure check_dpp_account
is
    l_object_id                     com_api_type_pkg.t_long_id;
    l_entity_type                   com_api_type_pkg.t_dict_value;
    l_credit_service_id             com_api_type_pkg.t_short_id;
    l_account                       acc_api_type_pkg.t_account_rec;
    l_balances_exists               com_api_type_pkg.t_boolean;
begin
    l_object_id          := evt_api_shared_data_pkg.get_param_num('OBJECT_ID');
    l_entity_type        := evt_api_shared_data_pkg.get_param_char('ENTITY_TYPE');

    if l_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
        l_account :=
            acc_api_account_pkg.get_account(
                i_account_id    => l_object_id
              , i_mask_error    => com_api_const_pkg.TRUE
            );

        l_credit_service_id :=
            crd_api_service_pkg.get_active_service(
                i_account_id  => l_account.account_id
              , i_eff_date    => com_api_sttl_day_pkg.get_calc_date(i_inst_id => l_account.inst_id)
              , i_split_hash  => l_account.split_hash
              , i_mask_error  => com_api_const_pkg.FALSE
            );
        if l_credit_service_id is not null then
            com_api_error_pkg.raise_error(
                i_error      => 'DPP_INSTALMENT_ACCOUNT_CONTAINS_CREDIT_SERVICE'
              , i_env_param1 => l_object_id
            );
        end if;

        l_balances_exists :=
            dpp_api_payment_plan_pkg.check_balances_exist(
                i_account_id => l_account.account_id
              , i_mask_error => com_api_type_pkg.FALSE
            );
    else
        com_api_error_pkg.raise_error(
            i_error      => 'ENTITY_TYPE_NOT_SUPPORTED'
          , i_env_param1 => l_entity_type
        );
    end if;
end check_dpp_account;

procedure cancel_dpp
is
begin
    dpp_api_payment_plan_pkg.cancel_dpp(
        i_dpp_id  => dpp_api_payment_plan_pkg.get_dpp(
                         i_reg_oper_id  => opr_api_shared_data_pkg.get_operation().original_id
                       , i_mask_error   => com_api_const_pkg.FALSE
                     ).id
    );
end;

procedure load_dpp_data
is
begin
    rul_api_shared_data_pkg.load_dpp_params(
        i_dpp_id  => dpp_api_payment_plan_pkg.get_dpp(
                         i_oper_id    => opr_api_shared_data_pkg.get_operation_id(
                                             i_selector => opr_api_shared_data_pkg.get_param_char(
                                                               i_name         => 'OPERATION_SELECTOR'
                                                             , i_mask_error   => com_api_const_pkg.TRUE
                                                             , i_error_value  => opr_api_const_pkg.OPER_SELECTOR_CURRENT
                                                           )
                                         )
                       , i_mask_error => com_api_const_pkg.FALSE
                     ).id
      , io_params => opr_api_shared_data_pkg.g_params
    );
end load_dpp_data;

procedure restructure_dpp
is
    l_dpp                           dpp_api_type_pkg.t_dpp;
    l_operation                     opr_api_type_pkg.t_oper_rec;
    l_acceleration_type             com_api_type_pkg.t_dict_value;
    l_instalment_count              com_api_type_pkg.t_tiny_id;
    l_instalment_amount             com_api_type_pkg.t_money;
    l_first_payment_date            date;
    l_percent_rate                  com_api_type_pkg.t_money;
    l_fee_id                        com_api_type_pkg.t_short_id;
begin
    l_operation := opr_api_shared_data_pkg.get_operation();

    l_dpp :=
        dpp_api_payment_plan_pkg.get_dpp(
            i_reg_oper_id   => l_operation.original_id
          , i_mask_error    => com_api_const_pkg.FALSE
        );

    get_auth_parameters(
        i_oper_id            => l_operation.id
      , o_calc_algorithm     => l_acceleration_type
      , o_instalment_count   => l_instalment_count
      , o_instalment_amount  => l_instalment_amount
      , o_first_payment_date => l_first_payment_date
      , o_percent_rate       => l_percent_rate
      , o_fee_id             => l_fee_id
    );

    l_acceleration_type :=
        nvl(
            opr_api_shared_data_pkg.get_param_char(
                i_name       => 'DPP_ACCELERATION_TYPE'
              , i_mask_error => com_api_type_pkg.TRUE
            )
          , l_acceleration_type
        );

    dpp_api_payment_plan_pkg.accelerate_dpp(
        i_dpp_id            => l_dpp.id
      , i_new_count         => l_instalment_count
      , i_payment_amount    => l_operation.oper_amount
      , i_acceleration_type => l_acceleration_type
    );
end restructure_dpp;

end;
/
