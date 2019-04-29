create or replace package body crd_ui_account_info_pkg as
/************************************************************
* UI-procedures for credit service <br />
* Created by Kolodkina Y.(kolodkina@bpcbt.com) at 30.03.2015 <br />
* Module: CRD_UI_ACCOUNT_INFO_PKG <br />
* @headcom
************************************************************/

/***********************************************************************
 * Returns cursor for credit's state info.
 * @param o_ref_cur       Opened cursor with data
 * @param i_account_id    Account ID
 ***********************************************************************/
procedure get_credit_info(
    o_ref_cur               out com_api_type_pkg.t_ref_cur
  , i_account_id         in     com_api_type_pkg.t_account_id
) is
    l_interests_num             com_api_type_pkg.t_money := 0;
    l_interests                 com_api_type_pkg.t_name;
    l_aging_period              com_api_type_pkg.t_tiny_id;
    l_currency                  com_api_type_pkg.t_curr_code;
    l_exponent                  com_api_type_pkg.t_tiny_id;
    l_account_number            com_api_type_pkg.t_account_number;
    l_product_id                com_api_type_pkg.t_short_id;
    l_service_id                com_api_type_pkg.t_short_id;
    l_split_hash                com_api_type_pkg.t_tiny_id;
    l_param_tab                 com_api_type_pkg.t_param_tab;
    l_fee_id                    com_api_type_pkg.t_short_id;
    l_add_fee_id                com_api_type_pkg.t_short_id;
    l_not_paid_mad              com_api_type_pkg.t_money;
    l_overdue_sum               com_api_type_pkg.t_money;
    l_overall_tad               com_api_type_pkg.t_money;
    l_not_paid_tad              com_api_type_pkg.t_money;

    l_purch_int_rate            com_api_type_pkg.t_short_desc;
    l_purch_add_int_rate        com_api_type_pkg.t_short_desc;
    l_cash_int_rate             com_api_type_pkg.t_short_desc;
    l_cash_add_int_rate         com_api_type_pkg.t_short_desc;
    l_contract_history          com_api_type_pkg.t_full_desc;
    l_alg_calc_intr             com_api_type_pkg.t_dict_value;
    l_inst_id                   com_api_type_pkg.t_inst_id;
    l_contract_id               com_api_type_pkg.t_medium_id;

    l_last_inv_id               com_api_type_pkg.t_medium_id;
    l_last_inv_date             date;
    l_grace_date                date;
    l_penalty_date              date;
    l_last_inv_mad              com_api_type_pkg.t_money;
    l_last_inv_tad              com_api_type_pkg.t_money;

    l_is_grace_enable           com_api_type_pkg.t_boolean;
    l_total_payment             com_api_type_pkg.t_money;
    l_eff_date                  date;
    l_cur_sql                   com_api_type_pkg.t_lob_data   := '';
    l_add_sql                   com_api_type_pkg.t_lob_data;
    l_lang                      com_api_type_pkg.t_dict_value := com_ui_user_env_pkg.get_user_lang();
    l_attr_alg_id               com_api_type_pkg.t_medium_id  := 10002378;

    l_not_paid_mad_text         com_api_type_pkg.t_full_desc;
    l_not_paid_tad_text         com_api_type_pkg.t_full_desc;
    l_purch_int_rate_text       com_api_type_pkg.t_full_desc;
    l_purch_add_int_rate_text   com_api_type_pkg.t_full_desc;
    l_cash_int_rate_text        com_api_type_pkg.t_full_desc;
    l_cash_add_int_rate_text    com_api_type_pkg.t_full_desc;
    l_interests_text            com_api_type_pkg.t_full_desc;
    l_alg_calc_intr_text        com_api_type_pkg.t_full_desc;
    l_debt_restruct_info_text   com_api_type_pkg.t_full_desc;
    l_text                      com_api_type_pkg.t_full_desc;

    l_penalty_from_id           com_api_type_pkg.t_long_id;
    l_grace_from_id             com_api_type_pkg.t_long_id;

    l_portfolio_code            com_api_type_pkg.t_dict_value;
    l_cumulative_intr_indue     com_api_type_pkg.t_amount_rec;
    l_cumulative_intr_overdue   com_api_type_pkg.t_amount_rec;
    l_last_inv_waive_int_sum    com_api_type_pkg.t_money;

    l_dpp_operation_id          com_api_type_pkg.t_long_id;
    l_label_id                  com_api_type_pkg.t_short_id;
    l_dpp_reg_date              date;
    l_instalment_amount         com_api_type_pkg.t_amount_rec;
    l_total_instalments         com_api_type_pkg.t_tiny_id;
    l_billed_instalments        com_api_type_pkg.t_tiny_id;
    l_total_debt                com_api_type_pkg.t_amount_rec;
    l_aging_algorithm           com_api_type_pkg.t_dict_value;
    l_number_i_format           com_api_type_pkg.t_name;
    l_number_f_format           com_api_type_pkg.t_name;
    l_nls_numeric_characters    com_api_type_pkg.t_name;
begin
    trc_log_pkg.debug (
        i_text       => 'crd_ui_credit_pkg.get_credit_info started for account_id [#1]'
      , i_env_param1 => i_account_id
    );

    l_nls_numeric_characters := com_ui_user_env_pkg.get_nls_numeric_characters;
    l_number_i_format        := com_api_const_pkg.get_number_i_format_with_sep;
    l_number_f_format        := com_api_const_pkg.get_number_f_format_with_sep;
    
    -- Get base parameters of the account
    select a.currency
         , a.split_hash
         , c.exponent
         , a.inst_id
         , a.account_number
         , a.contract_id
      into l_currency
         , l_split_hash
         , l_exponent
         , l_inst_id
         , l_account_number
         , l_contract_id
      from acc_account a
         , com_currency c
     where a.id   = i_account_id
       and c.code = a.currency;

    -- Get settlement date
    l_eff_date := com_api_sttl_day_pkg.get_calc_date(i_inst_id => l_inst_id);

    l_product_id :=
        prd_api_product_pkg.get_product_id(
            i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id     => i_account_id
          , i_eff_date      => l_eff_date
        );

    -- Get credit service ID
    l_service_id :=
        prd_api_service_pkg.get_active_service_id (
            i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => i_account_id
          , i_attr_name         => null
          , i_service_type_id   => crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID
          , i_split_hash        => l_split_hash
          , i_eff_date          => null
          , i_mask_error        => com_api_const_pkg.TRUE
        );

    l_aging_algorithm :=
        prd_api_product_pkg.get_attr_value_char(
            i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => i_account_id
          , i_attr_name         => crd_api_const_pkg.AGING_ALGORITHM
          , i_service_id        => l_service_id
          , i_eff_date          => l_eff_date
          , i_split_hash        => l_split_hash
          , i_inst_id           => l_inst_id
          , i_mask_error        => com_api_type_pkg.FALSE
          , i_use_default_value => com_api_type_pkg.TRUE
          , i_default_value     => crd_api_const_pkg.ALGORITHM_AGING_DEFAULT
        );
    if l_service_id is not null then
        -- Get invoice parameters
        begin
            select i.id
                 , i.invoice_date
                 , i.grace_date
                 , i.penalty_date
                 , i.min_amount_due
                 , i.total_amount_due
                 , case
                       when l_aging_algorithm = crd_api_const_pkg.ALGORITHM_AGING_INDEPENDENT
                           then i.aging_period
                       when i.penalty_date >= l_eff_date
                           then i.aging_period
                           else i.aging_period + 1
                   end
                 , i.waive_interest_amount
              into l_last_inv_id
                 , l_last_inv_date
                 , l_grace_date
                 , l_penalty_date
                 , l_last_inv_mad
                 , l_last_inv_tad
                 , l_aging_period
                 , l_last_inv_waive_int_sum
              from (select max(i.id) keep (dense_rank last order by i.serial_number) as id
                      from crd_invoice i
                     where i.account_id = i_account_id
                       and i.split_hash = l_split_hash
                   ) li
                 , crd_invoice i
             where i.id      = li.id;

        exception
            when no_data_found then
                null;
        end;

        begin
            select crd_api_const_pkg.QUALIFICATION_K
              into l_portfolio_code
              from dual
             where exists (select 1
                             from evt_status_log sl
                                , acc_account_object o
                            where (sl.entity_type     = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                   and sl.object_id   = i_account_id
                                or sl.entity_type     = iss_api_const_pkg.ENTITY_TYPE_CARD
                                   and sl.object_id   = o.object_id
                                   and sl.entity_type = o.entity_type
                                   and o.account_id   = i_account_id
                                  )
                              and sl.reason           = crd_api_const_pkg.PUNISHED_EVENT
                          );
        exception
            when no_data_found then
                case
                    when l_aging_period = 1
                    then l_portfolio_code := crd_api_const_pkg.QUALIFICATION_A;
                    when l_aging_period = 2
                    then l_portfolio_code := crd_api_const_pkg.QUALIFICATION_B;
                    when l_aging_period = 3
                    then l_portfolio_code := crd_api_const_pkg.QUALIFICATION_C;
                    when l_aging_period between 4 and 6
                    then l_portfolio_code := crd_api_const_pkg.QUALIFICATION_D;
                    when l_aging_period > 6
                    then l_portfolio_code := crd_api_const_pkg.QUALIFICATION_E;
                    else l_portfolio_code := 'N/A';
                end case;
        end;

        -- Load debt params
        begin
            crd_cst_debt_pkg.load_debt_param (
                i_account_id => i_account_id
              , i_product_id => l_product_id
              , i_split_hash => l_split_hash
              , io_param_tab => l_param_tab
            );
        exception
            when others then
                null;
        end;

        --Get l_not_paid_mad and l_not_paid_tad
        begin
            l_is_grace_enable :=
                prd_api_product_pkg.get_attr_value_number(
                    i_product_id    => l_product_id
                  , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                  , i_object_id     => i_account_id
                  , i_attr_name     => crd_api_const_pkg.GRACE_PERIOD_ENABLE
                  , i_service_id    => l_service_id
                  , i_split_hash    => l_split_hash
                  , i_params        => l_param_tab
                  , i_eff_date      => l_eff_date
                );

            l_penalty_from_id      := com_api_id_pkg.get_from_id(l_penalty_date);
            l_grace_from_id        := com_api_id_pkg.get_from_id(l_grace_date);

            select sum (amount)
              into l_total_payment
              from crd_payment
             where account_id = i_account_id
               and split_hash = l_split_hash
               and id < l_penalty_from_id
               and (
                       (
                        l_is_grace_enable = com_api_const_pkg.TRUE
                        and id < l_grace_from_id
                       )
                       or
                       l_is_grace_enable = com_api_const_pkg.FALSE
                   )
            ;
            l_not_paid_mad := l_last_inv_mad - l_total_payment;
            l_not_paid_tad := l_last_inv_tad - l_total_payment;

            if l_not_paid_mad < 0 then
                l_not_paid_mad := 0;
            end if;

            if l_not_paid_tad < 0 then
                l_not_paid_tad := 0;
            end if;

        exception
            when com_api_error_pkg.e_application_error then
                if com_api_error_pkg.get_last_error = 'ATTRIBUTE_VALUE_NOT_DEFINED' then

                    trc_log_pkg.debug('Attribute value [CRD_GRACE_PERIOD_ENABLE] not defined.');

                    l_not_paid_mad := 0;
                    l_not_paid_tad := 0;
                else
                    l_not_paid_mad_text := com_api_error_pkg.get_last_message;
                    l_not_paid_tad_text := com_api_error_pkg.get_last_message;
                end if;
            when others then
                trc_log_pkg.debug('Get attribute value error. '||sqlerrm);
                l_not_paid_mad_text := com_api_error_pkg.get_last_message;
                l_not_paid_tad_text := com_api_error_pkg.get_last_message;
        end;

        if l_not_paid_mad_text is null then
            l_not_paid_mad_text := nvl(to_char(round(l_not_paid_mad) / power(10, l_exponent), l_number_f_format, l_nls_numeric_characters), 'N/A');
        end if;

        if l_not_paid_tad_text is null then
            l_not_paid_tad_text := nvl(to_char(round(l_not_paid_tad) / power(10, l_exponent), l_number_f_format, l_nls_numeric_characters), 'N/A');
        end if;

        -- Get algorithm ACIL
        begin
            l_alg_calc_intr := nvl(prd_api_product_pkg.get_attr_value_char (
                i_product_id    => l_product_id
              , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id     => i_account_id
              , i_attr_name     => crd_api_const_pkg.ALGORITHM_CALC_INTEREST
              , i_split_hash    => l_split_hash
              , i_service_id    => l_service_id
              , i_params        => l_param_tab
              , i_eff_date      => l_eff_date
            ), crd_api_const_pkg.ALGORITHM_CALC_INTR_STANDARD);

        exception
            when com_api_error_pkg.e_application_error then
                if com_api_error_pkg.get_last_error = 'ATTRIBUTE_VALUE_NOT_DEFINED' then
                    trc_log_pkg.debug('Attribute value [CRD_ALGORITHM_CALC_INTEREST] not defined. Set algorithm = ACIL0001');
                    l_alg_calc_intr := crd_api_const_pkg.ALGORITHM_CALC_INTR_STANDARD;
                else
                    l_alg_calc_intr_text := com_api_error_pkg.get_last_message;
                end if;
            when others then
                trc_log_pkg.debug('Get attribute value error. '||sqlerrm);
                l_alg_calc_intr_text := com_api_error_pkg.get_last_message;
        end;
        trc_log_pkg.debug('Algorithm for calc interests = ' || l_alg_calc_intr);

        if l_alg_calc_intr_text is null then
            l_alg_calc_intr_text := nvl(l_alg_calc_intr || ' - ' || com_api_dictionary_pkg.get_article_text(i_article => l_alg_calc_intr), 'N/A');
        end if;

        -- Get sum of not charged interests
        begin
            l_interests_num := crd_api_report_pkg.calculate_interest (
                i_account_id    => i_account_id
              , i_eff_date      => l_eff_date
              , i_split_hash    => l_split_hash
              , i_service_id    => l_service_id
              , i_product_id    => l_product_id
              , i_alg_calc_intr => l_alg_calc_intr
            );
            l_interests := to_char(round(l_interests_num) / power(10, l_exponent), l_number_f_format, l_nls_numeric_characters);
        exception
            when com_api_error_pkg.e_application_error then
                if com_api_error_pkg.get_last_error in ('PRD_NO_ACTIVE_SERVICE', 'ATTRIBUTE_VALUE_NOT_DEFINED')  then
                    trc_log_pkg.debug('No active service found when calculating sum of not charged interests. Use "N/A" value instead.');
                    l_interests := 'N/A';
                else
                    l_interests_text := com_api_error_pkg.get_last_message;
                end if;
            when others then
                trc_log_pkg.debug('Calculate sum of not charged interests error. '||sqlerrm);
                l_interests_text := com_api_error_pkg.get_last_message;
        end;

        if l_interests_text is null then
            l_interests_text := nvl(l_interests, 'N/A');
        end if;

        -- Calculate purchase interest rate
        rul_api_param_pkg.set_param (
            io_params => l_param_tab
          , i_name    => 'OPER_TYPE'
          , i_value   => opr_api_const_pkg.OPERATION_TYPE_PURCHASE
        );

        begin
            trC_log_pkg.debug(
                i_text          => 'l_product_id [#1], i_account_id [#2], l_sttl_date [#3]'
              , i_env_param1    => l_product_id
              , i_env_param2    => i_account_id
              , i_env_param3    => l_eff_date
            );

            l_fee_id :=
                prd_api_product_pkg.get_fee_id (
                    i_product_id    => l_product_id
                  , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                  , i_object_id     => i_account_id
                  , i_fee_type      => crd_api_const_pkg.INTEREST_RATE_FEE_TYPE
                  , i_split_hash    => l_split_hash
                  , i_params        => l_param_tab
                  , i_eff_date      => l_eff_date
                );
            l_purch_int_rate :=
                crd_cst_interest_pkg.get_fee_desc(
                    i_product_id        => l_product_id
                  , i_alg_calc_intr     => l_alg_calc_intr
                  , i_service_id        => l_service_id
                  , i_object_id         => i_account_id
                  , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                  , i_params            => l_param_tab
                  , i_fee_id            => l_fee_id
                  , i_split_hash        => l_split_hash
                  , i_inst_id           => l_inst_id
                  , i_eff_date          => l_eff_date
                );
        exception
            when com_api_error_pkg.e_application_error then
                if com_api_error_pkg.get_last_error = 'FEE_NOT_DEFINED' then
                    trc_log_pkg.debug('Attribute value for Purchase interest rate is not defined. Use "N/A" value instead.');
                    l_purch_int_rate := 'N/A';
                elsif com_api_error_pkg.get_last_error = 'PRD_NO_ACTIVE_SERVICE' then
                    trc_log_pkg.debug('No active service found when calculating Purchase interest rate. Use "N/A" value instead.');
                    l_purch_int_rate := 'N/A';
                else
                    l_purch_int_rate_text := com_api_error_pkg.get_last_message;
                end if;
            when others then
                trc_log_pkg.debug('Get purchase interest rate error. ' || sqlerrm);
                l_purch_int_rate_text := com_api_error_pkg.get_last_message;
        end;

        if l_purch_int_rate_text is null then
            l_purch_int_rate_text := nvl(l_purch_int_rate, 'N/A');
        end if;

        -- Calculate cash interest rate
        rul_api_param_pkg.set_param (
            io_params => l_param_tab
          , i_name    => 'OPER_TYPE'
          , i_value   => opr_api_const_pkg.OPERATION_TYPE_ATM_CASH
        );

        begin
            l_fee_id :=
                prd_api_product_pkg.get_fee_id(
                    i_product_id    => l_product_id
                  , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                  , i_object_id     => i_account_id
                  , i_fee_type      => crd_api_const_pkg.INTEREST_RATE_FEE_TYPE
                  , i_split_hash    => l_split_hash
                  , i_params        => l_param_tab
                  , i_eff_date      => l_eff_date
                );
            l_cash_int_rate :=
                crd_cst_interest_pkg.get_fee_desc(
                    i_product_id        => l_product_id
                  , i_alg_calc_intr     => l_alg_calc_intr
                  , i_service_id        => l_service_id
                  , i_object_id         => i_account_id
                  , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                  , i_params            => l_param_tab
                  , i_fee_id            => l_fee_id
                  , i_split_hash        => l_split_hash
                  , i_inst_id           => l_inst_id
                  , i_eff_date          => l_eff_date
                );
        exception
            when com_api_error_pkg.e_application_error then
                if com_api_error_pkg.get_last_error = 'FEE_NOT_DEFINED' then
                    trc_log_pkg.debug('Attribute value for Cash interest rate is not defined. Use "N/A" value instead.');
                    l_cash_int_rate := 'N/A';
                elsif com_api_error_pkg.get_last_error = 'PRD_NO_ACTIVE_SERVICE' then
                    trc_log_pkg.debug('No active service found when calculating Cash interest rate. Use "N/A" value instead.');
                    l_cash_int_rate := 'N/A';
                else
                    l_cash_int_rate_text := com_api_error_pkg.get_last_message;
                end if;
            when others then
                trc_log_pkg.debug('Get cash interest rate error. ' || sqlerrm);
                l_cash_int_rate_text := com_api_error_pkg.get_last_message;
        end;

        if l_cash_int_rate_text is null then
            l_cash_int_rate_text := nvl(l_cash_int_rate, 'N/A');
        end if;

        -- Calculate purchase overdue interest rate
        rul_api_param_pkg.set_param (
            io_params => l_param_tab
          , i_name    => 'OPER_TYPE'
          , i_value   => opr_api_const_pkg.OPERATION_TYPE_PURCHASE
        );

        rul_api_param_pkg.set_param (
            io_params => l_param_tab
          , i_name    => 'BALANCE_TYPE'
          , i_value   => crd_api_const_pkg.BALANCE_TYPE_OVERDUE
        );

        rul_api_param_pkg.set_param (
            io_params => l_param_tab
          , i_name    => 'MACROS_TYPE'
          , i_value   => 1004          -- Cardholder debit on operation
        );

        begin
            l_add_fee_id :=
                prd_api_product_pkg.get_fee_id (
                    i_product_id    => l_product_id
                  , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                  , i_object_id     => i_account_id
                  , i_fee_type      => crd_api_const_pkg.ADDIT_INTEREST_RATE_FEE_TYPE
                  , i_split_hash    => l_split_hash
                  , i_params        => l_param_tab
                  , i_eff_date      => l_eff_date
                );
            if l_add_fee_id is not null then
                l_purch_add_int_rate := fcl_ui_fee_pkg.get_fee_desc(l_add_fee_id);
            else
                l_purch_add_int_rate := '';
            end if;
        exception
            when com_api_error_pkg.e_application_error then
                if com_api_error_pkg.get_last_error = 'FEE_NOT_DEFINED' then
                    trc_log_pkg.debug('Attribute value for Purchase overdue interest rate is not defined. Use "N/A" value instead.');
                    l_purch_add_int_rate := 'N/A';
                elsif com_api_error_pkg.get_last_error = 'PRD_NO_ACTIVE_SERVICE' then
                    trc_log_pkg.debug('No active service found when calculating Purchase overdue interest rate. Use "N/A" value instead.');
                    l_purch_add_int_rate := 'N/A';
                else
                    l_purch_add_int_rate_text := com_api_error_pkg.get_last_message;
                end if;
            when others then
                trc_log_pkg.debug('Get purchase overdue interest rate error. '||sqlerrm);
                l_purch_add_int_rate_text := com_api_error_pkg.get_last_message;
        end;

        if l_purch_add_int_rate_text is null then
            l_purch_add_int_rate_text := nvl(l_purch_add_int_rate, 'N/A');
        end if;

        -- Calculate cash overdue interest rate
        rul_api_param_pkg.set_param (
            io_params => l_param_tab
          , i_name    => 'OPER_TYPE'
          , i_value   => opr_api_const_pkg.OPERATION_TYPE_ATM_CASH
        );

        begin
            l_add_fee_id :=
                prd_api_product_pkg.get_fee_id (
                    i_product_id    => l_product_id
                  , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                  , i_object_id     => i_account_id
                  , i_fee_type      => crd_api_const_pkg.ADDIT_INTEREST_RATE_FEE_TYPE
                  , i_split_hash    => l_split_hash
                  , i_params        => l_param_tab
                  , i_eff_date      => l_eff_date
                );
            if l_add_fee_id is not null then
                l_cash_add_int_rate := fcl_ui_fee_pkg.get_fee_desc(l_add_fee_id);
            else
                l_cash_add_int_rate := '';
            end if;
        exception
            when com_api_error_pkg.e_application_error then
                if com_api_error_pkg.get_last_error = 'FEE_NOT_DEFINED' then
                    trc_log_pkg.debug('Attribute value for Cash overdue interest rate is not defined. Use "N/A" value instead.');
                    l_cash_add_int_rate := 'N/A';
                elsif com_api_error_pkg.get_last_error = 'PRD_NO_ACTIVE_SERVICE' then
                    trc_log_pkg.debug('No active service found when calculating Cash overdue interest rate. Use "N/A" value instead.');
                    l_cash_add_int_rate := 'N/A';
                else
                    l_cash_add_int_rate_text := com_api_error_pkg.get_last_message;
                end if;
            when others then
                trc_log_pkg.debug('Get cash overdue interest rate error. ' || sqlerrm);
                l_cash_add_int_rate_text := com_api_error_pkg.get_last_message;
        end;

        if l_cash_add_int_rate_text is null then
            l_cash_add_int_rate_text := nvl(l_cash_add_int_rate, 'N/A');
        end if;

        -- Calculate overall sum of TAD and MAD
        select nvl(sum(b.amount), 0)
          into l_overall_tad
          from crd_debt d
             , crd_debt_balance b
         where d.account_id = i_account_id
           and d.split_hash = l_split_hash
           and b.debt_id    = d.id
           and b.split_hash = l_split_hash;

        l_overall_tad := l_overall_tad + nvl(l_interests_num, 0);

        -- Calculate overdue sum
        select abs(round(nvl(sum(b.balance), 0)) / power(10, max(c.exponent)))
          into l_overdue_sum
          from acc_balance b
             , com_currency c
         where b.account_id   = i_account_id
           and c.code         = b.currency
           and b.balance_type in (crd_api_const_pkg.BALANCE_TYPE_OVERDUE, crd_api_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST);

        begin
            --Selecting contract history
            with x as (
                select ch.end_date, p.product_number || ' (till ' || to_char(end_date, crd_api_const_pkg.DATE_FORMAT) || ')' txt
                  from prd_contract_history ch
                     , prd_product p
                 where ch.contract_id = l_contract_id
                   and ch.product_id = p.id
                union all
                select null, p.product_number || ' (actual)'
                  from prd_contract ch
                     , prd_product p
                 where ch.id = l_contract_id
                   and ch.product_id = p.id
            )
            select listagg(txt, ' -> ') within group (order by end_date) txt
              into l_contract_history
              from x;
        exception
            when others then
                l_contract_history := com_api_error_pkg.get_last_message;
        end;

    end if;

    -- Getting cumulative indue/overdue interests (BLTP1003, BLTP1005)
    l_cumulative_intr_indue    := acc_api_balance_pkg.get_balance_amount(
                                      i_account_id   => i_account_id
                                    , i_balance_type => crd_api_const_pkg.BALANCE_TYPE_INTEREST
                                    , i_mask_error   => com_api_const_pkg.TRUE
                                  );
    l_cumulative_intr_overdue  := acc_api_balance_pkg.get_balance_amount(
                                      i_account_id   => i_account_id
                                    , i_balance_type => crd_api_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST
                                    , i_mask_error   => com_api_const_pkg.TRUE
                                  );
    begin

        select max(o.id) oper_id
             , max(pp.oper_date)         keep (dense_rank last order by o.id) oper_date
             , max(pp.instalment_amount) keep (dense_rank last order by o.id) instalment_amount
             , max(com_api_currency_pkg.get_currency_name(i_curr_code => pp.dpp_currency)) keep (dense_rank last order by o.id) dpp_currency
             , max(pp.instalment_total)  keep (dense_rank last order by o.id) instalment_total
             , max(pp.instalment_billed) keep (dense_rank last order by o.id) instalment_billed
             , max(pp.debt_balance)      keep (dense_rank last order by o.id) total_debt
          into l_dpp_operation_id
             , l_dpp_reg_date
             , l_instalment_amount.amount
             , l_instalment_amount.currency
             , l_total_instalments
             , l_billed_instalments
             , l_total_debt.amount
          from opr_operation o
             , opr_participant op
             , dpp_payment_plan pp
         where o.oper_type         = dpp_api_const_pkg.OPERATION_TYPE_DPP_RESTRUCT
           and o.id                = op.oper_id
           and pp.account_id       = op.account_id
           and op.account_id       = i_account_id
           and pp.oper_id          = o.id
           and pp.split_hash       = op.split_hash
           and op.split_hash       = l_split_hash
           and op.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
        ;
        if      l_dpp_operation_id           is null
            and l_dpp_reg_date               is null
            and l_instalment_amount.amount   is null
            and l_instalment_amount.currency is null
            and l_total_instalments          is null
            and l_billed_instalments         is null
            and l_total_debt.amount          is null
        then
            l_debt_restruct_info_text := null;
        else
            l_debt_restruct_info_text := dpp_api_const_pkg.DPP_RESTRUCT_INFO;

            trc_text_pkg.get_text(
                i_level      => trc_config_pkg.INFO
              , io_text      => l_debt_restruct_info_text
              , i_env_param1 => to_char(l_dpp_operation_id,         l_number_i_format, l_nls_numeric_characters)
              , i_env_param2 => to_char(l_total_debt.amount,        l_number_f_format, l_nls_numeric_characters)
                             || ' ' || l_instalment_amount.currency
              , i_env_param3 => to_char(l_dpp_reg_date, CRD_API_CONST_PKG.DATE_FORMAT)
              , i_env_param4 => to_char(l_instalment_amount.amount, l_number_f_format, l_nls_numeric_characters)
                             || ' ' || l_instalment_amount.currency
              , i_env_param5 => to_char(l_billed_instalments,       l_number_i_format, l_nls_numeric_characters)
                             || '/' || to_char(l_total_instalments, l_number_i_format, l_nls_numeric_characters)
              , i_get_text   => com_api_const_pkg.TRUE
              , o_label_id   => l_label_id
              , o_param_text => l_text
            );
        end if;
    exception
        when others then
            l_debt_restruct_info_text := sqlerrm;
    end;

    --generate sql
    l_cur_sql := 'select ''' || crd_api_const_pkg.CONTRACT_HISTORY || ''' as system_name, '
              || '''Product''' ||' as name, ''' || l_contract_history || ''' as value from dual union all ';
    l_cur_sql := l_cur_sql || 'select ''' || crd_api_const_pkg.SETTLEMENT_DATE || ''', '''
              || com_api_label_pkg.get_label_text(crd_api_const_pkg.SETTLEMENT_DATE, l_lang) || ''', '''
              || nvl(to_char(l_eff_date, crd_api_const_pkg.DATE_FORMAT), 'N/A') || ''' from dual union all ';
    l_cur_sql := l_cur_sql || 'select ''' || crd_api_const_pkg.LAST_INVOICE_DATE || ''', '''
              || com_api_label_pkg.get_label_text(crd_api_const_pkg.LAST_INVOICE_DATE, l_lang) || ''', '''
              || nvl(to_char(l_last_inv_date, crd_api_const_pkg.DATE_FORMAT), 'N/A') || ''' from dual union all ';
    l_cur_sql := l_cur_sql || 'select ''' || crd_api_const_pkg.GRACE_DATE || ''', '''
              || com_api_label_pkg.get_label_text(crd_api_const_pkg.GRACE_DATE, l_lang) || ''', '''
              || nvl(to_char(l_grace_date, crd_api_const_pkg.DATE_FORMAT), 'N/A') || ''' from dual union all ';
    l_cur_sql := l_cur_sql || 'select ''' || crd_api_const_pkg.PENALTY_DATE || ''', '''
              || com_api_label_pkg.get_label_text(crd_api_const_pkg.PENALTY_DATE, l_lang) || ''', '''
              || nvl(to_char(l_penalty_date, crd_api_const_pkg.DATE_FORMAT), 'N/A') || ''' from dual union all ';
    l_cur_sql := l_cur_sql || 'select ''' || crd_api_const_pkg.TAD_IN_INVOICE || ''', '''
              || com_api_label_pkg.get_label_text(crd_api_const_pkg.TAD_IN_INVOICE, l_lang) || ' '
              || to_char(l_last_inv_date, crd_api_const_pkg.DATE_FORMAT) || ''', '''
              || nvl(to_char(round(l_last_inv_tad) / power(10, l_exponent), l_number_i_format, l_nls_numeric_characters), 'N/A') ||''' from dual union all ';
    l_cur_sql := l_cur_sql || 'select ''' || crd_api_const_pkg.TAD_NOT_PAID || ''', '''
              || com_api_label_pkg.get_label_text(crd_api_const_pkg.TAD_NOT_PAID, l_lang) || ''', '''
              || l_not_paid_tad_text || ''' from dual union all ';
    l_cur_sql := l_cur_sql || 'select ''' || crd_api_const_pkg.MAD_IN_INVOICE || ''', '''
              || com_api_label_pkg.get_label_text(crd_api_const_pkg.MAD_IN_INVOICE, l_lang) || ' '
              || to_char(l_last_inv_date, crd_api_const_pkg.DATE_FORMAT) || ''', '''
              || nvl(to_char(round(l_last_inv_mad) / power(10, l_exponent), l_number_i_format, l_nls_numeric_characters), 'N/A') ||''' from dual union all ';
    l_cur_sql := l_cur_sql || 'select ''' || crd_api_const_pkg.MAD_NOT_PAID || ''', '''
              || com_api_label_pkg.get_label_text(crd_api_const_pkg.MAD_NOT_PAID, l_lang) || ''', '''
              || l_not_paid_mad_text || ''' from dual union all ';
    l_cur_sql := l_cur_sql || 'select ''' || crd_api_const_pkg.TAD || ''', '''
              || com_api_label_pkg.get_label_text(crd_api_const_pkg.TAD, l_lang) || ''', '''
              || nvl(to_char(round(l_overall_tad) / power(10, l_exponent), l_number_i_format, l_nls_numeric_characters), 'N/A') || ''' from dual union all ';
    l_cur_sql := l_cur_sql || 'select ''' || crd_api_const_pkg.OVERDUE_SUM || ''', '''
              || com_api_label_pkg.get_label_text(crd_api_const_pkg.OVERDUE_SUM, l_lang) || ''', '''
              || nvl(to_char(l_overdue_sum, l_number_i_format, l_nls_numeric_characters), 'N/A') || ''' from dual union all ';
    l_cur_sql := l_cur_sql || 'select ''' || crd_api_const_pkg.PURCH_INTR_RATE || ''', '''
              || com_api_label_pkg.get_label_text(crd_api_const_pkg.PURCH_INTR_RATE, l_lang) || ''', '''
              || l_purch_int_rate_text || ''' from dual union all ';
    l_cur_sql := l_cur_sql || 'select ''' || crd_api_const_pkg.PURCH_OVRD_INTR_RATE || ''', '''
              || com_api_label_pkg.get_label_text(crd_api_const_pkg.PURCH_OVRD_INTR_RATE, l_lang) || ''', '''
              || l_purch_add_int_rate_text || ''' from dual union all ';
    l_cur_sql := l_cur_sql || 'select ''' || crd_api_const_pkg.CASH_INTR_RATE || ''', '''
              || com_api_label_pkg.get_label_text(crd_api_const_pkg.CASH_INTR_RATE, l_lang) || ''', '''
              || l_cash_int_rate_text || ''' from dual union all ';
    l_cur_sql := l_cur_sql || 'select ''' || crd_api_const_pkg.CASH_OVRD_INTR_RATE || ''', '''
              || com_api_label_pkg.get_label_text(crd_api_const_pkg.CASH_OVRD_INTR_RATE, l_lang) || ''', '''
              || l_cash_add_int_rate_text || ''' from dual union all ';
    l_cur_sql := l_cur_sql || 'select ''' || crd_api_const_pkg.NOT_CHRG_INTERESTS || ''', '''
              || com_api_label_pkg.get_label_text(crd_api_const_pkg.NOT_CHRG_INTERESTS, l_lang) || ''', '''
              || l_interests_text || ''' from dual union all ';
    l_cur_sql := l_cur_sql || 'select ''' || crd_api_const_pkg.AGING_PERIOD || ''', '''
              || com_api_label_pkg.get_label_text(crd_api_const_pkg.AGING_PERIOD, l_lang) || ''', '''
              || nvl(to_char(l_aging_period), 'N/A') || ''' from dual union all ';
    l_cur_sql := l_cur_sql || 'select ''' || crd_api_const_pkg.AGING_PERIOD_NAME || ''', '''
              || com_api_label_pkg.get_label_text(crd_api_const_pkg.AGING_PERIOD_NAME, l_lang) || ''', '''
              || coalesce(crd_ui_account_info_pkg.get_aging_period_name(i_aging_period => l_aging_period), 'N/A')
              || ''' from dual union all ';
    l_cur_sql := l_cur_sql || 'select ''' || crd_api_const_pkg.CARD_PORTFOLIO_RATE || ''', '''
              || com_api_dictionary_pkg.get_article_text(crd_api_const_pkg.CARD_PORTFOLIO_RATING, l_lang) || ''', '''
              || nvl(com_ui_lov_pkg.get_name(crd_api_const_pkg.CARD_PORDFOLIO_LOV_ID, l_portfolio_code), 'N/A') || ''' from dual union all ';
    l_cur_sql := l_cur_sql || 'select ''' || crd_api_const_pkg.ALGORITHM_CALC_INTEREST || ''', '''
              || get_text ('prd_attribute', 'label', l_attr_alg_id, l_lang)||''', ''' || l_alg_calc_intr_text || ''' from dual union all ';
    l_cur_sql := l_cur_sql || 'select ''' || crd_api_const_pkg.CUMULATIVE_INTR_INDUE || ''', '''
              || com_api_label_pkg.get_label_text(crd_api_const_pkg.CUMULATIVE_INTR_INDUE, l_lang) || ''', '''
              || nvl(to_char(round(l_cumulative_intr_indue.amount) / power(10, l_exponent), l_number_i_format, l_nls_numeric_characters), 'N/A') || ''' from dual union all ';
    l_cur_sql := l_cur_sql || 'select ''' || crd_api_const_pkg.CUMULATIVE_INTR_OVERDUE || ''', '''
              || com_api_label_pkg.get_label_text(crd_api_const_pkg.CUMULATIVE_INTR_OVERDUE, l_lang) || ''', '''
              || nvl(to_char(round(l_cumulative_intr_overdue.amount) / power(10, l_exponent), l_number_i_format, l_nls_numeric_characters), 'N/A') || ''' from dual union all ';
    l_cur_sql := l_cur_sql || 'select ''' || crd_api_const_pkg.WAIVE_INTEREST_AMOUNT || ''', '''
              || com_api_label_pkg.get_label_text(crd_api_const_pkg.WAIVE_INTEREST_AMOUNT, l_lang) || ' '
              || to_char(l_last_inv_date, crd_api_const_pkg.DATE_FORMAT) || ''', '''
              || nvl(to_char(round(l_last_inv_waive_int_sum) / power(10, l_exponent), l_number_i_format, l_nls_numeric_characters), 'N/A') ||''' from dual union all ';
    l_cur_sql := l_cur_sql || 'select ''' || dpp_api_const_pkg.DPP_RESTRUCT_INSTALMENTS || ''', '''
              || com_api_label_pkg.get_label_text(dpp_api_const_pkg.DPP_RESTRUCT_INSTALMENTS, l_lang) || ''', '''
              || nvl(l_debt_restruct_info_text, 'N/A') || ''' from dual ';

    l_cur_sql := l_cur_sql
              || crd_api_algo_proc_pkg.get_additional_ui_info(
                     i_account_id  => i_account_id
                   , i_eff_date    => l_eff_date
                   , i_product_id  => l_product_id
                   , i_service_id  => l_service_id
                 );

    -- User-exit
    l_add_sql := crd_cst_account_info_pkg.get_add_parameters (
                     i_account_id     => i_account_id
                   , i_product_id     => l_product_id
                   , i_service_id     => l_service_id
                   , i_split_hash     => l_split_hash
                   , i_inst_id        => l_inst_id
                   , i_param_tab      => l_param_tab
                 );

    if l_add_sql is not null then
        l_cur_sql := l_cur_sql || ' union all ' || l_add_sql;
    end if;

    open o_ref_cur for l_cur_sql;

exception
    when com_api_error_pkg.e_application_error or com_api_error_pkg.e_fatal_error then
        raise;
    when others then
        trc_log_pkg.debug(
            i_text        => lower($$PLSQL_UNIT) || '.get_credit_info(i_account_id => #1) FAILED: ' || sqlerrm
          , i_env_param1  => i_account_id
        );
        trc_log_pkg.debug(
            i_text        => 'l_cur_sql: ' || l_cur_sql
        );
        com_api_error_pkg.raise_fatal_error(
            i_error         => 'UNHANDLED_EXCEPTION'
          , i_env_param1    => sqlerrm
        );
end get_credit_info;

function calculate_uncharged_fee(
    i_account_id        in      com_api_type_pkg.t_long_id
  , i_eff_date          in      date
  , i_contract_id       in      com_api_type_pkg.t_medium_id
  , i_product_id        in      com_api_type_pkg.t_long_id
  , i_service_id        in      com_api_type_pkg.t_short_id
  , i_currency          in      com_api_type_pkg.t_curr_code
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
  , i_create_oper       in      com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_money
is
    l_account_rec       acc_api_type_pkg.t_account_rec;
    l_fee_amount        com_api_type_pkg.t_money        := 0;
    l_total_amount      com_api_type_pkg.t_money        := 0;
    l_currency          com_api_type_pkg.t_curr_code;
    l_fee_id            com_api_type_pkg.t_short_id;
    l_params            com_api_type_pkg.t_param_tab;
    l_start_date        date;
    l_end_date          date;
    l_oper_id           com_api_type_pkg.t_long_id;
    l_participants      opr_api_type_pkg.t_oper_part_by_type_tab;
    l_is_need_fee       com_api_type_pkg.t_boolean;
begin
    trc_log_pkg.debug(
        i_text         => 'Calculate uncharged fee: i_account_id [#1] i_eff_date [#2] i_service_id [#3] i_currency [#4] i_split_hash [#5]'
      , i_env_param1   => i_account_id
      , i_env_param2   => to_char(i_eff_date, com_api_const_pkg.LOG_DATE_FORMAT)
      , i_env_param3   => i_service_id
      , i_env_param4   => i_currency
      , i_env_param5   => i_split_hash
    );

    l_currency := i_currency;

    acc_api_account_pkg.get_account_info(
        i_account_id   => i_account_id
      , o_account_rec  => l_account_rec
    );

    for r in (
        select distinct
               ft.object_id
             , ft.entity_type
             , ft.service_id
             , ft.fee_type
          from (
               select o.object_id
                    , o.entity_type
                    , v.service_id
                    , t.object_type fee_type
                 from prd_attribute_value v
                    , prd_attribute       t
                    , prd_service_object  o
                    , fcl_fee_type        ff
                    , (select i_service_id service_id
                         from dual
                        union all
                       select s.service_id
                         from acc_account_object a
                            , prd_service_object s
                            , prd_service        p
                        where a.account_id  = i_account_id
                          and s.entity_type = a.entity_type
                          and s.object_id   = a.object_id
                          and s.service_id  = p.id
                          and s.split_hash  = i_split_hash
                          and s.contract_id = i_contract_id
                          and s.service_id = prd_api_service_pkg.get_active_service_id(
                                                 i_entity_type       => a.entity_type
                                               , i_object_id         => a.object_id
                                               , i_attr_name         => null
                                               , i_service_type_id   => p.service_type_id
                                               , i_split_hash        => s.split_hash
                                               , i_eff_date          => null
                                               , i_mask_error        => com_api_const_pkg.TRUE
                                             )
                      ) s
                where v.entity_type = prd_api_const_pkg.ENTITY_TYPE_PRODUCT
                  and v.object_id   = i_product_id
                  and v.service_id  = s.service_id
                  and v.attr_id     = t.id
                  and t.entity_type = fcl_api_const_pkg.ENTITY_TYPE_FEE
                  and ff.fee_type   = t.object_type
                  and ff.cycle_type is not null
                  and o.contract_id = i_contract_id
                  and o.split_hash  = i_split_hash
                  and o.service_id  = v.service_id
                union all
               select v.object_id
                    , v.entity_type
                    , v.service_id
                    , t.object_type fee_type
                 from prd_attribute_value v
                    , prd_attribute       t
                    , fcl_fee_type        ff
                where v.entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                  and v.object_id   = i_account_id
                  and v.service_id  = i_service_id
                  and v.attr_id     = t.id
                  and t.entity_type = fcl_api_const_pkg.ENTITY_TYPE_FEE
                  and ff.fee_type   = t.object_type
                  and ff.cycle_type is not null
                union all
               select a.object_id
                    , a.entity_type
                    , s.service_id
                    , t.object_type fee_type
                 from acc_account_object  a
                    , prd_service_object  s
                    , prd_service         p
                    , prd_attribute_value v
                    , prd_attribute       t
                    , fcl_fee_type        ff
                where a.account_id  = i_account_id
                  and s.entity_type = a.entity_type
                  and s.object_id   = a.object_id
                  and s.service_id  = p.id
                  and s.split_hash  = i_split_hash
                  and s.contract_id = i_contract_id
                  and v.entity_type = a.entity_type
                  and v.object_id   = a.object_id
                  and v.service_id  = s.service_id
                  and v.attr_id     = t.id
                  and t.entity_type = fcl_api_const_pkg.ENTITY_TYPE_FEE
                  and ff.fee_type   = t.object_type
                  and ff.cycle_type is not null
                  and s.service_id = prd_api_service_pkg.get_active_service_id(
                                         i_entity_type       => a.entity_type
                                       , i_object_id         => a.object_id
                                       , i_attr_name         => null
                                       , i_service_type_id   => p.service_type_id
                                       , i_split_hash        => s.split_hash
                                       , i_eff_date          => null
                                       , i_mask_error        => com_api_const_pkg.TRUE
                                     )
          ) ft
    ) loop
        trc_log_pkg.debug(
            i_text         => 'Calulating fee amount base entity_type [#1] object_id [#2] service_id [#3] fee_type [#4]'
          , i_env_param1   => r.entity_type
          , i_env_param2   => r.object_id
          , i_env_param3   => r.service_id
          , i_env_param4   => r.fee_type
        );

        l_is_need_fee := com_api_const_pkg.TRUE;

        begin
            select trunc(coalesce(c.prev_date, o.start_date, i_eff_date))
                 , trunc(least(i_eff_date, nvl(o.end_date,   i_eff_date))) + 1 - com_api_const_pkg.ONE_SECOND
              into l_start_date
                 , l_end_date
              from prd_service_object o
                 , fcl_fee_type t
                 , fcl_cycle_counter c
             where o.service_id      = r.service_id
               and o.entity_type     = r.entity_type
               and o.object_id       = r.object_id
               and o.split_hash      = i_split_hash
               and o.end_date       is not null
               and t.fee_type        = r.fee_type
               and c.entity_type     = o.entity_type
               and c.object_id       = o.object_id
               and c.cycle_type      = t.cycle_type
               and c.split_hash      = o.split_hash
               and (c.prev_date is null or c.next_date <= i_eff_date)
               and i_eff_date between trunc(coalesce(c.prev_date, o.start_date, i_eff_date))                                      -- equal to expression of "l_start_date"
                                  and trunc(least(i_eff_date, nvl(o.end_date,   i_eff_date))) + 1 - com_api_const_pkg.ONE_SECOND; -- equal to expression of "l_end_date"

            trc_log_pkg.debug('Did not charge fee in last period');

        exception
            when no_data_found then
                trc_log_pkg.debug('Not fee period');
                l_is_need_fee := com_api_const_pkg.FALSE;
        end;

        if l_is_need_fee = com_api_const_pkg.TRUE then

            l_fee_id := prd_api_product_pkg.get_fee_id(
                            i_product_id    => i_product_id
                          , i_entity_type   => r.entity_type
                          , i_object_id     => r.object_id
                          , i_fee_type      => r.fee_type
                          , i_split_hash    => i_split_hash
                          , i_service_id    => r.service_id
                          , i_params        => l_params
                          , i_eff_date      => i_eff_date
                          , i_inst_id       => null
                        );

            trc_log_pkg.debug(
                i_text         => 'Calulating fee amount base Fee Id [#1] start_date [#2] end_date [#3]'
              , i_env_param1   => l_fee_id
              , i_env_param2   => to_char(l_start_date, com_api_const_pkg.LOG_DATE_FORMAT)
              , i_env_param3   => to_char(l_end_date,   com_api_const_pkg.LOG_DATE_FORMAT)
            );

            l_fee_amount := fcl_api_fee_pkg.get_fee_amount(
                                i_fee_id          => l_fee_id
                              , i_base_amount     => 0
                              , io_base_currency  => l_currency
                              , i_entity_type     => r.entity_type
                              , i_object_id       => r.object_id
                              , i_split_hash      => i_split_hash
                              , i_start_date      => l_start_date
                              , i_end_date        => l_end_date
                            );

            if nvl(i_create_oper, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE then

                l_oper_id := null;

                l_participants(com_api_const_pkg.PARTICIPANT_ISSUER).participant_type    := com_api_const_pkg.PARTICIPANT_ISSUER;
                if r.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD then
                    l_participants(com_api_const_pkg.PARTICIPANT_ISSUER).client_id_type  := opr_api_const_pkg.CLIENT_ID_TYPE_CARD_ID;
                    l_participants(com_api_const_pkg.PARTICIPANT_ISSUER).client_id_value := r.object_id;
                    l_participants(com_api_const_pkg.PARTICIPANT_ISSUER).card_id         := r.object_id;
                else
                    l_participants(com_api_const_pkg.PARTICIPANT_ISSUER).client_id_type  := opr_api_const_pkg.CLIENT_ID_TYPE_ACCOUNT;
                    l_participants(com_api_const_pkg.PARTICIPANT_ISSUER).client_id_value := i_account_id;
                end if;
                l_participants(com_api_const_pkg.PARTICIPANT_ISSUER).inst_id             := l_account_rec.inst_id;
                l_participants(com_api_const_pkg.PARTICIPANT_ISSUER).network_id          := ost_api_institution_pkg.get_inst_network(i_inst_id => l_account_rec.inst_id);
                l_participants(com_api_const_pkg.PARTICIPANT_ISSUER).customer_id         := l_account_rec.customer_id;
                l_participants(com_api_const_pkg.PARTICIPANT_ISSUER).contract_id         := l_account_rec.contract_id;
                l_participants(com_api_const_pkg.PARTICIPANT_ISSUER).account_id          := l_account_rec.account_id;
                l_participants(com_api_const_pkg.PARTICIPANT_ISSUER).account_type        := l_account_rec.account_type;
                l_participants(com_api_const_pkg.PARTICIPANT_ISSUER).account_number      := l_account_rec.account_number;
                l_participants(com_api_const_pkg.PARTICIPANT_ISSUER).account_amount      := round(l_fee_amount);
                l_participants(com_api_const_pkg.PARTICIPANT_ISSUER).account_currency    := l_account_rec.currency;
                l_participants(com_api_const_pkg.PARTICIPANT_ISSUER).split_hash          := l_account_rec.split_hash;

                opr_api_create_pkg.create_operation(
                    io_oper_id                  => l_oper_id
                  , i_session_id                => get_session_id
                  , i_is_reversal               => com_api_const_pkg.FALSE
                  , i_oper_type                 => opr_api_const_pkg.OPERATION_TYPE_ISSUER_FEE
                  , i_oper_reason               => r.fee_type
                  , i_msg_type                  => opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
                  , i_status                    => opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY
                  , i_sttl_type                 => opr_api_const_pkg.SETTLEMENT_INTERNAL
                  , i_oper_count                => 1
                  , i_oper_request_amount       => round(l_fee_amount)
                  , i_oper_amount               => round(l_fee_amount)
                  , i_oper_currency             => l_currency
                  , i_oper_date                 => i_eff_date
                  , i_host_date                 => com_api_sttl_day_pkg.get_sysdate
                  , i_proc_mode                 => aut_api_const_pkg.AUTH_PROC_MODE_NORMAL
                  , io_participants             => l_participants
                );
            end if;

            l_total_amount := l_total_amount + l_fee_amount;

        end if;
    end loop;

    return l_total_amount;
end calculate_uncharged_fee;

function calculate_accrued_interest(
    i_account_id        in      com_api_type_pkg.t_long_id
  , i_eff_date          in      date
  , i_split_hash        in      com_api_type_pkg.t_tiny_id          default null
  , i_service_id        in      com_api_type_pkg.t_short_id
  , i_product_id        in      com_api_type_pkg.t_short_id
  , i_alg_calc_intr     in      com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_money
is
    l_split_hash                com_api_type_pkg.t_tiny_id;
    l_interest_amount           com_api_type_pkg.t_money;
    l_interest_sum              com_api_type_pkg.t_money            := 0;
    l_currency                  com_api_type_pkg.t_curr_code;
    l_param_tab                 com_api_type_pkg.t_param_tab;
    l_account_number            com_api_type_pkg.t_account_number;
    l_from_id                   com_api_type_pkg.t_long_id;
    l_till_id                   com_api_type_pkg.t_long_id;

    l_inst_id                   com_api_type_pkg.t_inst_id;
    l_last_invoice_id           com_api_type_pkg.t_medium_id;
    l_eff_date                  date;
    l_invoice_date              date                                := null;
    l_grace_date                date                                := null;
    l_due_date                  date                                := null;

    l_calc_interest_end_attr    com_api_type_pkg.t_dict_value;
    l_calc_interest_date_end    date;
    
    l_calc_due_date            date;
begin
    trc_log_pkg.debug('charge_interest: i_account_id ['||i_account_id||'] i_eff_date ['||to_char(i_eff_date, 'dd.mm.yyyy hh24:mi:ss')||']');
 
    if i_split_hash is null then
        l_split_hash := com_api_hash_pkg.get_split_hash(
                            i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                          , i_object_id     => i_account_id
                        );
    else
        l_split_hash := i_split_hash;
    end if;

    begin
        select inst_id
          into l_inst_id
          from acc_account
         where id = i_account_id;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error         => 'ACCOUNT_NOT_FOUND'
              , i_env_param1    => i_account_id
            );
    end;
    
    l_calc_interest_end_attr :=
        crd_interest_pkg.get_interest_calc_end_date(
            i_account_id  => i_account_id
          , i_eff_date    => i_eff_date
          , i_split_hash  => l_split_hash
          , i_inst_id     => l_inst_id
        );

    l_eff_date := i_eff_date;

    l_eff_date := crd_interest_pkg.get_interest_start_date(
                      i_product_id   => i_product_id
                    , i_account_id   => i_account_id
                    , i_split_hash   => l_split_hash
                    , i_service_id   => i_service_id
                    , i_param_tab    => l_param_tab
                    , i_posting_date => null
                    , i_eff_date     => l_eff_date
                    , i_inst_id      => l_inst_id
                  );

    l_last_invoice_id := crd_invoice_pkg.get_last_invoice_id(
                             i_account_id        => i_account_id
                           , i_split_hash        => i_split_hash
                           , i_mask_error        => com_api_const_pkg.TRUE
                         );

    if l_last_invoice_id is not null then
        select invoice_date
             , grace_date
             , due_date
          into l_invoice_date
             , l_grace_date
             , l_due_date
          from crd_invoice
         where id = l_last_invoice_id;
    end if;

    -- Get Due Date
    l_calc_due_date := 
        crd_invoice_pkg.calc_next_invoice_due_date(
            i_service_id => i_service_id
          , i_account_id => i_account_id
          , i_split_hash => l_split_hash
          , i_inst_id    => l_inst_id
          , i_eff_date   => i_eff_date
          , i_mask_error => case l_calc_interest_end_attr
                                when crd_api_const_pkg.INTER_CALC_END_DATE_BLNC
                                    then com_api_const_pkg.FALSE
                                when crd_api_const_pkg.INTER_CALC_END_DATE_DDUE
                                    then com_api_const_pkg.TRUE
                                else com_api_const_pkg.FALSE
                            end
        );
    
    for p in (
        select d.id debt_id
             , c.account_type
             , c.currency
             , c.account_number
             , c.inst_id
          from crd_debt d
             , acc_account c
         where decode(d.status, 'DBTSACTV', d.account_id, null) = i_account_id
           and d.account_id = c.id
           and d.split_hash = l_split_hash
           and crd_cst_interest_pkg.charge_interest_needed(i_debt_id => d.id) = com_api_const_pkg.TRUE
    ) loop

        l_currency       := p.currency;
        l_account_number := p.account_number;
        l_from_id        := com_api_id_pkg.get_from_id_num(i_object_id => p.debt_id);
        l_till_id        := com_api_id_pkg.get_till_id_num(i_object_id => p.debt_id);

        for r in (
            select x.balance_type
                 , x.fee_id
                 , x.add_fee_id
                 , x.amount
                 , x.start_date
                 , x.end_date
                 , b.bunch_type_id
                 , x.id
                 , x.macros_type_id
                 , x.interest_amount
                 , x.debt_intr_id
                 , x.due_date
              from (
                    select a.id debt_intr_id
                         , a.balance_type
                         , a.fee_id
                         , a.add_fee_id
                         , a.amount
                         , a.balance_date start_date
                         , nvl(lead(a.balance_date) over (partition by a.balance_type order by a.id), l_eff_date) end_date
                         , a.debt_id
                         , a.id
                         , d.inst_id
                         , d.macros_type_id
                         , a.interest_amount
                         , a.is_charged
                         , i.due_date
                      from crd_debt_interest a
                         , crd_debt d
                         , crd_invoice i
                     where a.debt_id         = p.debt_id
                       and (d.is_grace_enable = com_api_const_pkg.FALSE
                            or (l_grace_date is not null
                                and l_grace_date < l_eff_date
                                and d.oper_date  < l_invoice_date)
                           )
                       and d.id              = a.debt_id
                       and a.split_hash      = l_split_hash
                       and a.id between l_from_id and l_till_id
                       and a.invoice_id      = i.id(+)
                   ) x
                 , crd_event_bunch_type b
             where x.end_date        <= l_eff_date
               and b.event_type(+)    = crd_api_const_pkg.INTEREST_CHARGE_CYCLE_TYPE
               and x.is_charged       = com_api_const_pkg.FALSE
               and b.balance_type(+)  = x.balance_type
               and b.inst_id(+)       = x.inst_id
             order by bunch_type_id nulls first
        ) loop
        
            l_calc_interest_date_end := 
                case l_calc_interest_end_attr
                    when crd_api_const_pkg.INTER_CALC_END_DATE_BLNC
                        then r.end_date
                    when crd_api_const_pkg.INTER_CALC_END_DATE_DDUE
                        then nvl(r.due_date, l_calc_due_date)
                    else r.end_date
                end;
            if nvl(r.interest_amount, 0) = 0 then

                -- Calculate interest amount. Base algorithm
                if i_alg_calc_intr = crd_api_const_pkg.ALGORITHM_CALC_INTR_STANDARD then

                    l_interest_amount :=  round(
                        fcl_api_fee_pkg.get_fee_amount(
                            i_fee_id            => r.fee_id
                          , i_base_amount       => r.amount
                          , io_base_currency    => p.currency
                          , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                          , i_object_id         => i_account_id
                          , i_split_hash        => l_split_hash
                          , i_eff_date          => r.start_date
                          , i_start_date        => r.start_date
                          , i_end_date          => l_calc_interest_date_end
                        )
                      , 4
                    );

                    if r.add_fee_id is not null then
                        -- Calculate additional interest amount
                        l_interest_amount := l_interest_amount + round(
                            fcl_api_fee_pkg.get_fee_amount(
                                i_fee_id            => r.add_fee_id
                              , i_base_amount       => r.amount
                              , io_base_currency    => p.currency
                              , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                              , i_object_id         => i_account_id
                              , i_split_hash        => l_split_hash
                              , i_eff_date          => r.start_date
                              , i_start_date        => r.start_date
                              , i_end_date          => l_calc_interest_date_end
                            )
                          , 4
                        );
                    end if;
                -- Custom algorithm
                else
                    l_interest_amount :=  round(
                        crd_cst_interest_pkg.get_fee_amount(
                            i_fee_id            => r.fee_id
                          , i_base_amount       => r.amount
                          , io_base_currency    => p.currency
                          , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                          , i_object_id         => i_account_id
                          , i_split_hash        => l_split_hash
                          , i_eff_date          => l_eff_date   --r.start_date
                          , i_start_date        => r.start_date
                          , i_end_date          => l_calc_interest_date_end
                          , i_alg_calc_intr     => i_alg_calc_intr
                          , i_debt_id           => p.debt_id
                          , i_balance_type      => r.balance_type
                          , i_debt_intr_id      => r.debt_intr_id
                          , i_service_id        => i_service_id
                          , i_product_id        => i_product_id
                        )
                      , 4
                    );

                    if r.add_fee_id is not null then
                        -- Calculate additional interest amount
                        l_interest_amount := l_interest_amount + round(
                            crd_cst_interest_pkg.get_fee_amount(
                                i_fee_id            => r.add_fee_id
                              , i_base_amount       => r.amount
                              , io_base_currency    => p.currency
                              , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                              , i_object_id         => i_account_id
                              , i_split_hash        => l_split_hash
                              , i_eff_date          => l_eff_date   --r.start_date
                              , i_start_date        => r.start_date
                              , i_end_date          => l_calc_interest_date_end
                              , i_alg_calc_intr     => i_alg_calc_intr
                              , i_debt_id           => p.debt_id
                              , i_balance_type      => r.balance_type
                              , i_debt_intr_id      => r.debt_intr_id
                              , i_service_id        => i_service_id
                              , i_product_id        => i_product_id
                            )
                          , 4
                        );
                    end if;
                end if;
            else
                l_interest_amount := r.interest_amount;
            end if;

            l_interest_sum := l_interest_sum + l_interest_amount;

            trc_log_pkg.debug('Calulating interest amount base amount ['||r.amount||'] Fee Id ['||r.fee_id||'] Additional fee Id ['||r.add_fee_id||'] Interest amount ['||l_interest_amount||']');
        end loop;
        l_interest_sum := round(l_interest_sum); -- Rounding result, because in entries values will rouding every debt_id.
        trc_log_pkg.debug('Rounding interest amount ['||l_interest_sum||'] Debt Id ['||p.debt_id||']');
    end loop;

    return round(l_interest_sum);

end calculate_accrued_interest;

procedure total_debt_calculation(
    i_account_id         in     com_api_type_pkg.t_account_id
  , i_payoff_date        in     date
  , o_ref_cur               out com_api_type_pkg.t_ref_cur
) is
    l_own_funds_balance                  com_api_type_pkg.t_money;
    l_due_balance                        com_api_type_pkg.t_money;
    l_accrued_interest                   com_api_type_pkg.t_money;
    l_closing_balance                    com_api_type_pkg.t_money;
    l_unsettled_amount                   com_api_type_pkg.t_money;
    l_cur_sql                            com_api_type_pkg.t_lob_data;
    l_lang                               com_api_type_pkg.t_dict_value := get_user_lang;
    l_interest_tab                       crd_api_type_pkg.t_interest_tab;
    l_index                              binary_integer;
    l_cumulative_intr_indue              com_api_type_pkg.t_amount_rec;
    l_cumulative_intr_overdue            com_api_type_pkg.t_amount_rec;
    l_intr_indue_amount                  com_api_type_pkg.t_money;
    l_intr_overdue_amount                com_api_type_pkg.t_money;
    l_exponent                           com_api_type_pkg.t_tiny_id;
    l_digit_gr_separator                 com_api_type_pkg.t_dict_value;
    l_number_format                      com_api_type_pkg.t_name;
begin
    crd_invoice_pkg.calculate_total_outstanding(
        i_account_id        => i_account_id
      , i_payoff_date       => i_payoff_date
      , o_due_balance       => l_due_balance
      , o_accrued_interest  => l_accrued_interest
      , o_closing_balance   => l_closing_balance
      , o_own_funds_balance => l_own_funds_balance
      , o_unsettled_amount  => l_unsettled_amount
      , o_interest_tab      => l_interest_tab
    );

    -- Getting cumulative indue/overdue interests (BLTP1003, BLTP1005)
    l_cumulative_intr_indue    := acc_api_balance_pkg.get_balance_amount(
                                      i_account_id   => i_account_id
                                    , i_balance_type => crd_api_const_pkg.BALANCE_TYPE_INTEREST
                                    , i_mask_error   => com_api_const_pkg.TRUE
                                  );

    l_cumulative_intr_overdue  := acc_api_balance_pkg.get_balance_amount(
                                      i_account_id   => i_account_id
                                    , i_balance_type => crd_api_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST
                                    , i_mask_error   => com_api_const_pkg.TRUE
                                  );

    select c.exponent
      into l_exponent
      from acc_account a
         , com_currency c
     where a.id   = i_account_id
       and c.code = a.currency;

    l_intr_indue_amount     := round(l_cumulative_intr_indue.amount) / power(10, l_exponent);
    l_intr_overdue_amount   := round(l_cumulative_intr_overdue.amount) / power(10, l_exponent);

    l_number_format         := com_api_const_pkg.get_number_f_format_with_sep;

    l_cur_sql :=              'select ''' || crd_api_const_pkg.DUE_BALANCE || ''' as system_name, null parent_name, '''
                                          || com_api_label_pkg.get_label_text(i_name => crd_api_const_pkg.DUE_BALANCE, i_lang => l_lang)
                                          || ''' as name, ''' || to_char(nvl(l_due_balance, 0), l_number_format)
                                          || ''' as value from dual union all ';
    l_cur_sql := l_cur_sql || 'select ''' || crd_api_const_pkg.NOT_CHARGED_INTERESTS || ''' as system_name, null parent_name, '''
                                          || com_api_label_pkg.get_label_text(i_name => crd_api_const_pkg.NOT_CHARGED_INTERESTS, i_lang => l_lang)
                                          || ''' as name, ''' || to_char(nvl(l_accrued_interest, 0), l_number_format)
                                          || ''' as value from dual union all ';
    l_cur_sql := l_cur_sql || 'select ''' || crd_api_const_pkg.CLOSING_BALANCE || ''' as system_name, null parent_name, '''
                                          || com_api_label_pkg.get_label_text(i_name => crd_api_const_pkg.CLOSING_BALANCE, i_lang => l_lang)
                                          || ''', ''' || to_char(nvl(l_closing_balance, 0), l_number_format)
                                          || ''' as value from dual union all ';
    l_cur_sql := l_cur_sql || 'select ''' || crd_api_const_pkg.OWN_FUNDS_BALANCE || ''' as system_name, null parent_name, '''
                                          || com_api_label_pkg.get_label_text(i_name => crd_api_const_pkg.OWN_FUNDS_BALANCE, i_lang => l_lang)
                                          || ''' as name, ''' || to_char(nvl(l_own_funds_balance, 0), l_number_format)
                                          || ''' as value from dual union all ';
    l_cur_sql := l_cur_sql || 'select ''' || crd_api_const_pkg.UNSETTLED_AMOUNT || ''' as system_name, null parent_name, '''
                                          || com_api_label_pkg.get_label_text(i_name => crd_api_const_pkg.UNSETTLED_AMOUNT, i_lang => l_lang)
                                          || ''', ''' || to_char(nvl(l_unsettled_amount, 0), l_number_format)
                                          || ''' as value from dual union all ';
    l_cur_sql := l_cur_sql || 'select ''' || crd_api_const_pkg.CUMULATIVE_INTR_INDUE || ''' as system_name, null parent_name, '''
                                          || com_api_label_pkg.get_label_text(i_name => crd_api_const_pkg.CUMULATIVE_INTR_INDUE, i_lang => l_lang)
                                          || ''' as name, ''' || to_char(nvl(l_intr_indue_amount, 0), l_number_format)
                                          || ''' as value from dual union all ';
    l_cur_sql := l_cur_sql || 'select ''' || crd_api_const_pkg.CUMULATIVE_INTR_OVERDUE || ''' as system_name, null parent_name, '''
                                          || com_api_label_pkg.get_label_text(i_name => crd_api_const_pkg.CUMULATIVE_INTR_OVERDUE, i_lang => l_lang)
                                          || ''' as name, ''' || to_char(nvl(l_intr_overdue_amount, 0), l_number_format)
                                          || ''' as value from dual';

    if nvl(l_interest_tab.count, 0) > 1 then
        l_index := l_interest_tab.first;
        loop
            l_cur_sql := l_cur_sql || ' union all select ''BUNCH_TYPE_' ||to_char(l_index, com_api_const_pkg.XML_NUMBER_FORMAT)||''' as system_name '
                             || ', ''' || crd_api_const_pkg.NOT_CHARGED_INTERESTS || ''' as parent_name '
                             || ', ''' || com_api_i18n_pkg.get_text ('acc_bunch_type', 'name', l_index, 'LANGENG')||''' as name '
                             || ', '''||to_char(l_interest_tab(l_index), l_number_format) ||''' as value '
                             || ' from dual ';

            l_index := l_interest_tab.next(l_index);
            exit when l_index is null;
        end loop;
    end if;

    trc_log_pkg.debug('crd_ui_account_info_pkg.total_debt_calculation: l_cur_sql [ ' || l_cur_sql || ']');

    open o_ref_cur for l_cur_sql;
end; --total_debt_calculation;

procedure close_credit(
    i_account_id    in  com_api_type_pkg.t_account_id
  , i_eff_date      in  date
) is
    l_currency                          com_api_type_pkg.t_curr_code;
    l_exponent                          com_api_type_pkg.t_tiny_id;
    l_account_number                    com_api_type_pkg.t_account_number;
    l_split_hash                        com_api_type_pkg.t_tiny_id;
    l_contract_id                       com_api_type_pkg.t_medium_id;
    l_inst_id                           com_api_type_pkg.t_inst_id;
    l_product_id                        com_api_type_pkg.t_short_id;
    l_service_id                        com_api_type_pkg.t_short_id;
    l_param_tab                         com_api_type_pkg.t_param_tab;
    l_params                            com_api_type_pkg.t_param_tab;
    l_fee_id                            com_api_type_pkg.t_short_id;
    l_seqnum                            com_api_type_pkg.t_seqnum;
    l_fee_tier_id                       com_api_type_pkg.t_short_id;
    l_attribute_value_id                com_api_type_pkg.t_medium_id;
    l_attr_name                         com_api_type_pkg.t_name;
    l_eff_date                          date;
begin
    trc_log_pkg.debug(
        i_text       => 'crd_ui_credit_pkg.close_credit started for account_id [#1] and eff_date[#2]'
      , i_env_param1 => i_account_id
      , i_env_param2 => i_eff_date
    );

    if i_account_id is null then
        com_api_error_pkg.raise_error(
            i_error         => 'REQUIRED_PARAMETER_IS_NOT_SPECIFIED'
          , i_env_param1    => 'i_account_id'
        );
    end if;

    if i_eff_date is null then
        com_api_error_pkg.raise_error(
            i_error         => 'REQUIRED_PARAMETER_IS_NOT_SPECIFIED'
          , i_env_param1    => 'i_eff_date'
        );
    end if;

    -- Get base parameters of the account
    begin
    select a.currency
         , a.split_hash
         , c.exponent
         , a.inst_id
         , a.account_number
         , a.contract_id
      into l_currency
         , l_split_hash
         , l_exponent
         , l_inst_id
         , l_account_number
         , l_contract_id
      from acc_account a
         , com_currency c
     where a.id     = i_account_id
       and a.status != acc_api_const_pkg.ACCOUNT_STATUS_CLOSED
       and c.code   = a.currency;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error         => 'ACCOUNT_ALREADY_CLOSED'
              , i_env_param1    => i_account_id
            );
    end;

    l_product_id := prd_api_product_pkg.get_product_id(
                        i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                      , i_object_id     => i_account_id
                      , i_eff_date      => i_eff_date
                    );
    l_service_id := prd_api_service_pkg.get_active_service_id(
                        i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                      , i_object_id         => i_account_id
                      , i_attr_name         => null
                      , i_service_type_id   => crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID
                      , i_split_hash        => l_split_hash
                      , i_eff_date          => i_eff_date
                      , i_mask_error        => com_api_const_pkg.TRUE
                    );

    l_eff_date := crd_interest_pkg.get_interest_start_date(
                      i_product_id   => l_product_id
                    , i_account_id   => i_account_id
                    , i_split_hash   => l_split_hash
                    , i_service_id   => l_service_id
                    , i_param_tab    => l_param_tab
                    , i_posting_date => i_eff_date
                    , i_eff_date     => i_eff_date
                    , i_inst_id      => l_inst_id
                  );

    -- Calculate and charge interest on closure date
    crd_interest_pkg.charge_interest(
        i_account_id        => i_account_id
      , i_eff_date          => l_eff_date
      , i_split_hash        => l_split_hash
    );

    -- Apply payment after charge interest
    crd_payment_pkg.apply_payments(
        i_account_id        => i_account_id
      , i_eff_date          => l_eff_date
      , i_split_hash        => l_split_hash
    );

    begin
        select attr_name
          into l_attr_name
          from prd_attribute_vw a
             , prd_service_vw   s
         where a.entity_type     = fcl_api_const_pkg.ENTITY_TYPE_FEE
           and s.id              = l_service_id
           and s.service_type_id = a.service_type_id
           and a.object_type     = crd_api_const_pkg.INTEREST_RATE_FEE_TYPE;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error     => 'ATTRIBUTE_NOT_FOUND'
            );
    end;

    fcl_ui_fee_pkg.add_fee(
        i_fee_type      => crd_api_const_pkg.INTEREST_RATE_FEE_TYPE
      , i_currency      => l_currency
      , i_fee_rate_calc => fcl_api_const_pkg.FEE_RATE_FLAT_PERCENTAGE
      , i_fee_base_calc => fcl_api_const_pkg.FEE_BASE_INCOMING_AMOUNT
      , i_limit_id      => null
      , i_cycle_id      => null
      , i_inst_id       => l_inst_id
      , o_fee_id        => l_fee_id
      , o_seqnum        => l_seqnum
    );

    if l_fee_id is not null then
        fcl_ui_fee_pkg.add_fee_tier(
            i_fee_id                => l_fee_id
          , i_fixed_rate            => 0
          , i_percent_rate          => 0
          , i_min_value             => 0
          , i_max_value             => 0
          , i_length_type           => fcl_api_const_pkg.CYCLE_LENGTH_YEAR
          , i_length_type_algorithm => null
          , i_sum_threshold         => 0
          , i_count_threshold       => 0
          , o_fee_tier_id           => l_fee_tier_id
          , o_seqnum                => l_seqnum
        );

        prd_ui_attribute_value_pkg.set_attr_value_num(
            io_id               => l_attribute_value_id
          , i_service_id        => l_service_id
          , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => i_account_id
          , i_attr_name         => l_attr_name
          , i_mod_id            => null
          , i_start_date        => i_eff_date
          , i_end_date          => null
          , i_value             => l_fee_id
          , i_check_start_date  => com_api_const_pkg.FALSE
        );
    else
        com_api_error_pkg.raise_error(
            i_error             => 'FEE_NOT_FOUND'
          , i_env_param1        => l_fee_id
        );
    end if;

    -- Set credit limit on account to 0
    update acc_balance_vw b
       set b.balance = 0
     where b.id in (select id
                    from acc_balance_vw
                   where account_id   = i_account_id
                     and balance_type = crd_api_const_pkg.BALANCE_TYPE_ASSIGNED_EXCEED);

    -- Close all attached cards
    for cur in (select o.entity_type
                     , o.object_id
                     , i.inst_id
                     , i.split_hash
                     , i.id card_instance_id
                  from acc_account_object o
                     , iss_card_instance  i
                 where o.account_id  = i_account_id
                   and o.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                   and i.card_id     = o.object_id
                   and i.state      != iss_api_const_pkg.CARD_STATE_CLOSED
               )
    loop
        iss_api_card_pkg.deactivate_card(
            i_card_instance_id  => cur.card_instance_id
          , i_status            => null
        );

        prd_api_service_pkg.close_service(
            i_entity_type => cur.entity_type
          , i_object_id   => cur.object_id
          , i_inst_id     => cur.inst_id
          , i_split_hash  => cur.split_hash
          , i_params      => l_params
        );
    end loop;

    -- Change account status on Credits only
    acc_api_account_pkg.set_account_status(
        i_account_id      => i_account_id
      , i_status          => acc_api_const_pkg.ACCOUNT_STATUS_CREDITS
      , i_reason          => crd_api_const_pkg.PAY_OFF_CREDIT
    );

    trc_log_pkg.debug(
        i_text       => 'crd_ui_credit_pkg.close_credit finished'
    );
end close_credit;

procedure restructure_to_dpp(
    i_account_id         in     com_api_type_pkg.t_medium_id
  , i_fee_id             in     com_api_type_pkg.t_short_id
  , i_eff_date           in     date
  , i_dpp_algorithm      in     com_api_type_pkg.t_dict_value
  , i_instalments_count  in     com_api_type_pkg.t_tiny_id
) is
    l_oper_id            com_api_type_pkg.t_long_id;
    l_eff_date           date;
    l_account            acc_api_type_pkg.t_account_rec;
    l_tad                com_api_type_pkg.t_money;
    l_own_funds_balance  com_api_type_pkg.t_money            := 0;
    l_due_balance        com_api_type_pkg.t_money            := 0;
    l_accrued_interest   com_api_type_pkg.t_money            := 0;
    l_unsettled_amount   com_api_type_pkg.t_money            := 0;
    l_interest_tab       crd_api_type_pkg.t_interest_tab;
    l_macros_id          com_api_type_pkg.t_long_id;
    l_params             com_api_type_pkg.t_param_tab;
    l_card               iss_api_type_pkg.t_card;
begin
    trc_log_pkg.debug(
        i_text       => 'crd_ui_credit_pkg.restructure_to_dpp started'
    );

    l_account := acc_api_account_pkg.get_account(
                     i_account_id     => i_account_id
                   , i_mask_error     => com_api_const_pkg.FALSE
                 );

    savepoint sp_restruct_dpp;

    select max(c.id)
     into l_card.id
     from iss_card c
        , iss_card_instance i
    where c.customer_id = l_account.customer_id
      and i.card_id     = c.id
      and i.status      = iss_api_const_pkg.CARD_STATUS_VALID_CARD;

    l_eff_date := coalesce(i_eff_date, com_api_sttl_day_pkg.get_calc_date(
                                           i_inst_id    => l_account.inst_id
                                       )
                  );

    crd_interest_pkg.charge_interest(
        i_account_id  => i_account_id
      , i_eff_date    => l_eff_date
      , i_period_date => l_eff_date
      , i_split_hash  => l_account.split_hash
    );

    -- Get TAD
    crd_invoice_pkg.calculate_total_outstanding(
        i_account_id        => i_account_id
      , i_payoff_date       => l_eff_date
      , i_apply_exponent    => com_api_type_pkg.FALSE
      , o_due_balance       => l_due_balance
      , o_accrued_interest  => l_accrued_interest
      , o_closing_balance   => l_tad
      , o_own_funds_balance => l_own_funds_balance
      , o_unsettled_amount  => l_unsettled_amount
      , o_interest_tab      => l_interest_tab
    );

    opr_api_create_pkg.create_operation(
        io_oper_id                => l_oper_id
      , i_session_id              => get_session_id
      , i_is_reversal             => com_api_const_pkg.FALSE
      , i_original_id             => null
      , i_oper_type               => dpp_api_const_pkg.OPERATION_TYPE_DPP_RESTRUCT
      , i_msg_type                => opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
      , i_status                  => opr_api_const_pkg.OPERATION_STATUS_DONT_PROCESS
      , i_sttl_type               => opr_api_const_pkg.SETTLEMENT_USONUS
      , i_oper_count              => 1
      , i_oper_amount             => l_tad
      , i_oper_currency           => l_account.currency
      , i_oper_date               => l_eff_date
      , i_host_date               => l_eff_date
      , i_forced_processing       => com_api_const_pkg.TRUE
    );

    opr_api_create_pkg.add_participant(
        i_oper_id           => l_oper_id
      , i_msg_type          => opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
      , i_oper_type         => dpp_api_const_pkg.OPERATION_TYPE_DPP_RESTRUCT
      , i_participant_type  => com_api_const_pkg.PARTICIPANT_ISSUER
      , i_host_date         => l_eff_date
      , i_inst_id           => l_account.inst_id
      , i_customer_id       => l_account.customer_id
      , i_account_id        => i_account_id
      , i_account_type      => l_account.account_type
      , i_account_number    => l_account.account_number
      , i_account_amount    => l_tad
      , i_account_currency  => l_account.currency
      , i_card_id           => l_card.id
      , i_split_hash        => l_account.split_hash
      , i_without_checks    => com_api_const_pkg.TRUE
      , i_oper_currency     => l_account.currency
      , i_external_auth_id  => null
      , i_mask_error        => com_api_const_pkg.FALSE
      , i_is_reversal       => com_api_const_pkg.FALSE
    );

    l_macros_id := com_api_id_pkg.get_id(i_seq => acc_macros_seq.nextval, i_date => l_eff_date);

    rul_api_param_pkg.set_param(
        i_name          => 'OPER_TYPE'
      , i_value         => dpp_api_const_pkg.OPERATION_TYPE_DPP_RESTRUCT
      , io_params       => l_params
    );

    dpp_api_payment_plan_pkg.register_dpp(
        i_account_id        => l_account.account_id
      , i_dpp_algorithm     => i_dpp_algorithm
      , i_instalment_count  => i_instalments_count
      , i_instalment_amount => null
      , i_fee_id            => i_fee_id
      , i_dpp_amount        => l_tad
      , i_dpp_currency      => l_account.currency
      , i_macros_id         => l_macros_id
      , i_oper_id           => l_oper_id
      , i_param_tab         => l_params
    );

    acc_api_account_pkg.set_account_status(
        i_account_id => l_account.account_id
      , i_status     => acc_api_const_pkg.ACCOUNT_STATUS_DEBT_RESTRUCT
      , i_reason     => null
    );
    trc_log_pkg.debug(
        i_text       => 'crd_ui_credit_pkg.restructure_to_dpp finished'
    );
exception
    when others then
        rollback to sp_restruct_dpp;
        if com_api_error_pkg.is_application_error(code => sqlcode) = com_api_const_pkg.TRUE then
            trc_log_pkg.debug(i_text => 'crd_ui_credit_pkg.restructure_to_dpp error: ' || sqlerrm);
            raise;
        elsif com_api_error_pkg.is_fatal_error(code => sqlcode) = com_api_const_pkg.TRUE then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end restructure_to_dpp;

procedure interest_calculation(
    i_account_id         in     com_api_type_pkg.t_account_id
  , i_start_date         in     date
  , i_end_date           in     date
  , o_ref_cur               out com_api_type_pkg.t_ref_cur
) is
    l_own_funds_balance                  com_api_type_pkg.t_money            := 0;
    l_due_balance                        com_api_type_pkg.t_money            := 0;
    l_accrued_interest                   com_api_type_pkg.t_money            := 0;
    l_closing_balance                    com_api_type_pkg.t_money            := 0;
    l_unsettled_amount                   com_api_type_pkg.t_money            := 0;
    l_cur_sql                            com_api_type_pkg.t_lob_data;
    l_lang                               com_api_type_pkg.t_dict_value       := get_user_lang;
    l_interest_tab                       crd_api_type_pkg.t_interest_tab;
    l_index                              binary_integer;
    l_count                              binary_integer;
    l_cumulative_intr_indue              com_api_type_pkg.t_money            := 0;
    l_cumulative_intr_overdue            com_api_type_pkg.t_money            := 0;
    l_cumulative_intr_indue_st           com_api_type_pkg.t_money            := 0;
    l_cumulative_intr_overdue_st         com_api_type_pkg.t_money            := 0;
    l_cumulative_intr_indue_end          com_api_type_pkg.t_money            := 0;
    l_cumulative_intr_overdue_end        com_api_type_pkg.t_money            := 0;
    l_intr_indue_amount                  com_api_type_pkg.t_money            := 0;
    l_intr_overdue_amount                com_api_type_pkg.t_money            := 0;
    l_exponent                           com_api_type_pkg.t_tiny_id;
    l_start_date                         date;
    l_end_date                           date;
    l_sysdate                            date;
    l_account                            acc_api_type_pkg.t_account_rec;
    l_date_from                          date;
    l_date_to                            date;
begin
    l_sysdate    := trunc(get_sysdate) + 1 - com_api_const_pkg.ONE_SECOND;
    l_start_date := trunc(i_start_date);
    l_end_date   := trunc(i_end_date) + 1 - com_api_const_pkg.ONE_SECOND;

    l_account := acc_api_account_pkg.get_account(
                     i_account_id   => i_account_id
                   , i_mask_error   => com_api_const_pkg.FALSE
                 );

    if l_sysdate < l_start_date then
        l_date_from := l_start_date;
        l_date_to   := l_end_date;
    elsif l_sysdate between l_start_date and l_end_date then
        l_date_from := l_sysdate;
        l_date_to   := l_end_date;
    else
        l_date_from := l_start_date;
        l_date_to   := l_end_date;
    end if;

    crd_invoice_pkg.calculate_total_outstanding(
        i_account_id        => i_account_id
      , i_payoff_date       => l_date_from
      , o_due_balance       => l_due_balance
      , o_accrued_interest  => l_accrued_interest
      , o_closing_balance   => l_closing_balance
      , o_own_funds_balance => l_own_funds_balance
      , o_unsettled_amount  => l_unsettled_amount
      , o_interest_tab      => l_interest_tab
    );
    -- Getting cumulative indue/overdue interests (BLTP1003, BLTP1005) on start date
    if nvl(l_interest_tab.count, 0) > 0 then
        l_index := l_interest_tab.first;
        loop
            select count(1)
              into l_count
              from crd_event_bunch_type b
             where b.bunch_type_id = l_index
               and b.inst_id = l_account.inst_id
               and b.balance_type = crd_api_const_pkg.BALANCE_TYPE_INTEREST;

            if l_count > 0 then
                l_cumulative_intr_indue_st    := l_cumulative_intr_indue_st + l_interest_tab(l_index);
            end if;

            select count(1)
              into l_count
              from crd_event_bunch_type b
             where b.bunch_type_id = l_index
               and b.inst_id = l_account.inst_id
               and b.balance_type = crd_api_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST;

            if l_count > 0 then
                l_cumulative_intr_overdue_st  := l_cumulative_intr_overdue_st + l_interest_tab(l_index);
            end if;

            l_index := l_interest_tab.next(l_index);
            exit when l_index is null;
        end loop;
        if (l_cumulative_intr_indue_st = 0 or l_cumulative_intr_overdue_st = 0) and l_accrued_interest != 0 then
            l_cumulative_intr_indue_st := l_accrued_interest;
        end if;
    end if;

    crd_invoice_pkg.calculate_total_outstanding(
        i_account_id        => i_account_id
      , i_payoff_date       => l_date_to
      , o_due_balance       => l_due_balance
      , o_accrued_interest  => l_accrued_interest
      , o_closing_balance   => l_closing_balance
      , o_own_funds_balance => l_own_funds_balance
      , o_unsettled_amount  => l_unsettled_amount
      , o_interest_tab      => l_interest_tab
    );
    -- Getting cumulative indue/overdue interests (BLTP1003, BLTP1005) on end date
    if nvl(l_interest_tab.count, 0) > 0 then
        l_index := l_interest_tab.first;
        loop
            select count(1)
              into l_count
              from crd_event_bunch_type b
             where b.bunch_type_id = l_index
               and b.inst_id = l_account.inst_id
               and b.balance_type = crd_api_const_pkg.BALANCE_TYPE_INTEREST;

            if l_count > 0 then
                l_cumulative_intr_indue_end   := l_cumulative_intr_indue_end + l_interest_tab(l_index);
            end if;

            select count(1)
              into l_count
              from crd_event_bunch_type b
             where b.bunch_type_id = l_index
               and b.inst_id = l_account.inst_id
               and b.balance_type = crd_api_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST;

            if l_count > 0 then
                l_cumulative_intr_overdue_end := l_cumulative_intr_overdue_end + l_interest_tab(l_index);
            end if;

            l_index := l_interest_tab.next(l_index);
            exit when l_index is null;
        end loop;
        if (l_cumulative_intr_indue_end = 0 or l_cumulative_intr_overdue_end = 0) and l_accrued_interest != 0 then
            l_cumulative_intr_indue_end := l_accrued_interest;
        end if;
    end if;

    if l_sysdate > l_start_date then
        -- Getting cumulative indue/overdue interests (BLTP1003, BLTP1005)
        select nvl(sum(e.balance_impact * e.amount), 0)
          into l_cumulative_intr_indue
          from acc_entry e
         where e.balance_type = crd_api_const_pkg.BALANCE_TYPE_INTEREST
           and e.account_id   = i_account_id
           and e.posting_date between l_start_date and least(l_sysdate, l_end_date) ;

        select nvl(sum(e.balance_impact * e.amount), 0)
          into l_cumulative_intr_overdue
          from acc_entry e
         where e.balance_type = crd_api_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST
           and e.account_id   = i_account_id
           and e.posting_date between l_start_date and least(l_sysdate, l_end_date);
    end if;
    if l_sysdate > l_end_date then
        l_cumulative_intr_indue_st   := 0;
        l_cumulative_intr_overdue_st := 0;
    end if;

    select c.exponent
      into l_exponent
      from acc_account a
         , com_currency c
     where a.id   = i_account_id
       and c.code = a.currency;

    l_intr_indue_amount     := round(-1 * (l_cumulative_intr_indue_end - l_cumulative_intr_indue_st) + l_cumulative_intr_indue) / power(10, l_exponent);
    l_intr_overdue_amount   := round(-1 * (l_cumulative_intr_overdue_end - l_cumulative_intr_overdue_st) + l_cumulative_intr_overdue) / power(10, l_exponent);
    if nvl(l_interest_tab.count, 0) > 1 then
        l_index := l_interest_tab.first;
        loop
            l_closing_balance := l_closing_balance - l_interest_tab(l_index);

            l_index := l_interest_tab.next(l_index);
            exit when l_index is null;
        end loop;
    end if;

    l_cur_sql := 'select ''' || crd_api_const_pkg.CUMULATIVE_INTR_INDUE || ''' as system_name, null parent_name, '''
                             || com_api_label_pkg.get_label_text(
                                    i_name => crd_api_const_pkg.CUMULATIVE_INTR_INDUE
                                  , i_lang => l_lang
                                ) || ''' as name, '''
                             || to_char(nvl(l_intr_indue_amount, 0), com_api_const_pkg.XML_FLOAT_FORMAT)
                             || ''' as value from dual union all '
              || 'select ''' || crd_api_const_pkg.CUMULATIVE_INTR_OVERDUE || ''' as system_name, null parent_name, '''
                             || com_api_label_pkg.get_label_text(
                                    i_name => crd_api_const_pkg.CUMULATIVE_INTR_OVERDUE
                                  , i_lang => l_lang
                                ) || ''' as name, '''
                             || to_char(nvl(l_intr_overdue_amount, 0), com_api_const_pkg.XML_FLOAT_FORMAT)
                             || ''' as value from dual union all '
              || 'select ''' || crd_api_const_pkg.CLOSING_BALANCE || ''' as system_name, null parent_name, '''
                             || com_api_label_pkg.get_label_text(
                                    i_name => crd_api_const_pkg.CLOSING_BALANCE
                                  , i_lang => l_lang
                                ) || ''' as name, '''
                             || to_char(nvl(l_closing_balance, 0), com_api_const_pkg.XML_FLOAT_FORMAT)
                             || ''' as value from dual';

    trc_log_pkg.debug('crd_ui_account_info_pkg.interest_calculation: l_cur_sql [ ' || l_cur_sql || ']');

    open o_ref_cur for l_cur_sql;
end interest_calculation;

function get_aging_period_name(
    i_aging_period      in      com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_name
is
    l_aging_period_name         com_api_type_pkg.t_name;
begin
    if i_aging_period is not null then
        l_aging_period_name := coalesce(
                                   crd_invoice_pkg.get_converted_aging_period(
                                       i_aging_period => i_aging_period
                                   )
                                 , to_char(30 * i_aging_period)
                                   || ' '
                                   || lower(com_api_label_pkg.get_label_text(
                                                i_name => 'common.days'
                                            )
                                      )
                               );
    end if;

    return l_aging_period_name;
end get_aging_period_name;

procedure get_operation_debt(
    i_oper_id            in     com_api_type_pkg.t_long_id
  , o_debt_amount           out com_api_type_pkg.t_money
  , o_debt_currency         out com_api_type_pkg.t_curr_code
) is
    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_operation_debt ';
    l_debt_cnt                  com_api_type_pkg.t_tiny_id;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || '<< i_oper_id [#1]'
      , i_env_param1 => i_oper_id
    );

    begin
        select d.currency
             , nvl(sum(db.amount), 0)
          into o_debt_currency
             , o_debt_amount
          from (
              select d.*
                   , row_number() over (order by d.fee_type nulls first, d.id) as rn
                from crd_debt d
               where d.oper_id    = i_oper_id
                 and d.status     = crd_api_const_pkg.DEBT_STATUS_ACTIVE
          ) d
          join crd_debt_balance db   on db.debt_id      = d.id
                                    and db.id          >= trunc(d.id, -10)
                                    and db.split_hash   = d.split_hash
         group by
               d.currency;
    exception
        when no_data_found then
            null;
    end;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || '>> o_debt_amount [#1]'
      , i_env_param1 => o_debt_amount
    );
end get_operation_debt;

end;
/
