create or replace package body opr_api_shared_data_pkg is
/*********************************************************
 *  Operation shared data <br />
 *  Created by Khougaev A.(khougaev@bpcbt.com)  at 21.08.2009 <br />
 *  Module:  OPR_API_SHARED_DATA_PKG  <br />
 *  @headcom
 **********************************************************/

-- Private variables that are only used in methods stash_shared_data/restore_shared_data
-- for temporary saving current values of public global variables g_* into their private replicas
g_private_amounts               com_api_type_pkg.t_amount_by_name_tab;
g_private_currencies            com_api_type_pkg.t_currency_by_name_tab;
g_private_accounts              acc_api_type_pkg.t_account_by_name_tab;
g_private_dates                 com_api_type_pkg.t_date_by_name_tab;
g_private_params                com_api_type_pkg.t_param_tab;
g_private_auth                  aut_api_type_pkg.t_auth_rec;
g_private_operation             opr_api_type_pkg.t_oper_rec;
g_private_iss_participant       opr_api_type_pkg.t_oper_part_rec;
g_private_acq_participant       opr_api_type_pkg.t_oper_part_rec;
g_private_dst_participant       opr_api_type_pkg.t_oper_part_rec;
g_private_agg_participant       opr_api_type_pkg.t_oper_part_rec;
g_private_spr_participant       opr_api_type_pkg.t_oper_part_rec;
g_private_lty_participant       opr_api_type_pkg.t_oper_part_rec;
g_private_inst_participant      opr_api_type_pkg.t_oper_part_rec;


procedure clear_shared_data is
begin
    trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.clear_shared_data()');
    g_operation := null;
    g_iss_participant := null;
    g_acq_participant := null;
    g_dst_participant := null;
    g_agg_participant := null;
    g_spr_participant := null;
    g_lty_participant := null;
    g_inst_participant := null;
    g_amounts.delete;
    g_currencies.delete;
    g_accounts.delete;
    g_dates.delete;
    g_params.delete;
    g_auth            := null;
end;

/*
 * Stash/save current values of some global variables into local variables for private storing.
 */
procedure stash_shared_data
is
begin
    trc_log_pkg.debug(
        i_text       => lower($$PLSQL_UNIT) || '.stash_shared_data() for operation [#1]'
      , i_env_param1 => g_operation.id
    );
    g_private_operation        := g_operation;
    g_private_amounts          := g_amounts;
    g_private_currencies       := g_currencies;
    g_private_accounts         := g_accounts;
    g_private_dates            := g_dates;
    g_private_params           := g_params;
    g_private_auth             := g_auth;
    g_private_iss_participant  := g_iss_participant;
    g_private_acq_participant  := g_acq_participant;
    g_private_dst_participant  := g_dst_participant;
    g_private_agg_participant  := g_agg_participant;
    g_private_spr_participant  := g_spr_participant;
    g_private_lty_participant  := g_lty_participant;
    g_private_inst_participant := g_inst_participant;
end;

/*
 * Replace current values of some global variables with saved earlier values of local variables.
 */
procedure restore_shared_data
is
    LOG_PREFIX    constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.restore_shared_data';
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' << g_operation.id [#1]'
      , i_env_param1 => g_operation.id
    );

    clear_shared_data();

    g_operation                := g_private_operation;
    g_amounts                  := g_private_amounts;
    g_currencies               := g_private_currencies;
    g_accounts                 := g_private_accounts;
    g_dates                    := g_private_dates;
    g_params                   := g_private_params;
    g_auth                     := g_private_auth;
    g_iss_participant          := g_private_iss_participant;
    g_acq_participant          := g_private_acq_participant;
    g_dst_participant          := g_private_dst_participant;
    g_agg_participant          := g_private_agg_participant;
    g_spr_participant          := g_private_spr_participant;
    g_lty_participant          := g_private_lty_participant;
    g_inst_participant         := g_private_inst_participant;

    g_private_operation        := null;
    g_private_auth             := null;
    g_private_iss_participant  := null;
    g_private_acq_participant  := null;
    g_private_dst_participant  := null;
    g_private_agg_participant  := null;
    g_private_spr_participant  := null;
    g_private_lty_participant  := null;
    g_private_inst_participant := null;
    g_private_amounts.delete();
    g_private_currencies.delete();
    g_private_accounts.delete();
    g_private_dates.delete();
    g_private_params.delete();

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' >> g_operation.id [#1]'
      , i_env_param1 => g_operation.id
    );
end restore_shared_data;

procedure clear_params is
begin
    rul_api_param_pkg.clear_params(
        io_params  => g_params
    );
end;

procedure collect_payment_order_params(
    io_params             in out nocopy com_api_type_pkg.t_param_tab
) is
    l_purpose_id        com_api_type_pkg.t_short_id;
begin
    if g_operation.payment_order_id is not null then
        for r in (
            select p.param_name
                 , d.param_value
              from pmo_order_data d
                 , pmo_parameter p
             where d.order_id = g_operation.payment_order_id
               and d.param_id = p.id
        ) loop
            rul_api_param_pkg.set_param(
                i_name    => r.param_name
              , i_value   => r.param_value
              , io_params => io_params
            );
        end loop;

        begin
            select purpose_id
              into l_purpose_id
              from pmo_order
             where id = g_operation.payment_order_id;

            rul_api_param_pkg.set_param(
                i_value   => l_purpose_id
              , i_name    => 'PURPOSE_ID'
              , io_params => io_params
            );
        exception
            when no_data_found then
                null;
        end;
    end if;
end collect_payment_order_params;

procedure collect_global_card_params(
    io_params             in out nocopy com_api_type_pkg.t_param_tab
) is
    l_card_status                         com_api_type_pkg.t_dict_value;
    l_card_state                          com_api_type_pkg.t_dict_value;
begin
    if g_iss_participant.card_id is not null then
        begin
            select ci.status
                 , ci.state
              into l_card_status
                 , l_card_state
              from iss_card_instance ci
             where ci.card_id            = g_iss_participant.card_id
               and ci.is_last_seq_number = com_api_type_pkg.TRUE;

        exception
            when no_data_found then
                null;
        end;

        -- If last card instance is not found then rule 'check_object_status' will raise error
        rul_api_param_pkg.set_param(
            i_value   => l_card_status
          , i_name    => 'LAST_CARD_STATUS'
          , io_params => io_params
        );

        rul_api_param_pkg.set_param(
            i_value   => l_card_state
          , i_name    => 'LAST_CARD_STATE'
          , io_params => io_params
        );
    end if;
end collect_global_card_params;

procedure collect_global_oper_params
is
    l_pos_batch_support                 com_api_type_pkg.t_boolean;
begin
    rul_api_param_pkg.set_param(
        i_value    => g_operation.msg_type
      , i_name     => 'MSG_TYPE'
      , io_params  => g_params
    );
    rul_api_param_pkg.set_param(
        i_value    => g_operation.oper_type
      , i_name     => 'OPER_TYPE'
      , io_params  => g_params
    );
    rul_api_param_pkg.set_param(
        i_value    => g_operation.oper_reason
      , i_name     => 'OPER_REASON'
      , io_params  => g_params
    );
    rul_api_param_pkg.set_param(
        i_value    => g_operation.sttl_type
      , i_name     => 'STTL_TYPE'
      , io_params  => g_params
    );

    rul_api_param_pkg.set_param(
        i_value    => g_iss_participant.inst_id
      , i_name     => 'ISS_INST_ID'
      , io_params  => g_params
    );
    rul_api_param_pkg.set_param(
        i_value    => g_iss_participant.card_network_id
      , i_name     => 'CARD_NETWORK_ID'
      , io_params  => g_params
    );
    rul_api_param_pkg.set_param(
        i_value    => g_iss_participant.card_type_id
      , i_name     => 'CARD_TYPE_ID'
      , io_params  => g_params
    );
    rul_api_param_pkg.set_param(
        i_value    => g_iss_participant.account_currency
      , i_name     => 'ACCOUNT_CURRENCY'
      , io_params  => g_params
    );
    rul_api_param_pkg.set_param(
        i_value    => prd_api_contract_pkg.get_contract(
                          i_contract_id => g_iss_participant.contract_id
                      ).contract_type
      , i_name     => 'ISS_CONTRACT_TYPE'
      , io_params  => g_params
    );
    rul_api_param_pkg.set_param(
        i_name     => 'ISS_COUNTRY'
      , i_value    => g_iss_participant.card_country
      , io_params  => g_params
    );
    rul_api_param_pkg.set_param(
        i_name     => 'SEQ_NUMBER'
      , i_value    => g_iss_participant.card_seq_number
      , io_params  => g_params
    );
    rul_api_param_pkg.set_param(
        i_name     => 'EXPIR_DATE'
      , i_value    => g_iss_participant.card_expir_date
      , io_params  => g_params
    );
    rul_api_param_pkg.set_param(
        i_name     => 'SERVICE_CODE'
      , i_value    => g_iss_participant.card_service_code
      , io_params  => g_params
    );
    rul_api_param_pkg.set_param(
        i_name     => 'CARD_INST_ID'
      , i_value    => g_iss_participant.card_inst_id
      , io_params  => g_params
    );

    rul_api_param_pkg.set_param(
        i_value    => g_acq_participant.inst_id
      , i_name     => 'ACQ_INST_ID'
      , io_params  => g_params
    );
    rul_api_param_pkg.set_param(
        i_value    => g_operation.acq_inst_bin
      , i_name     => 'ACQ_BIN'
      , io_params  => g_params
    );
    rul_api_param_pkg.set_param(
        i_value    => acq_api_merchant_pkg.get_merchant_contract(
                          i_merchant_id  => g_acq_participant.merchant_id
                      ).contract_type
      , i_name     => 'ACQ_CONTRACT_TYPE'
      , io_params  => g_params
    );
    rul_api_param_pkg.set_param(
        i_value    => g_operation.oper_currency
      , i_name     => 'OPER_CURRENCY'
      , io_params  => g_params
    );
    rul_api_param_pkg.set_param(
        i_value    => g_operation.sttl_currency
      , i_name     => 'STTL_CURRENCY'
      , io_params  => g_params
    );
    rul_api_param_pkg.set_param(
        i_value    => g_operation.host_date
      , i_name     => 'HOST_DATE'
      , io_params  => g_params
    );
    rul_api_param_pkg.set_param(
        i_value    => g_operation.oper_date
      , i_name     => 'OPER_DATE'
      , io_params  => g_params
    );
    rul_api_param_pkg.set_param(
        i_value    => g_operation.match_status
      , i_name     => 'MATCH_STATUS'
      , io_params  => g_params
    );
    rul_api_param_pkg.set_param(
        i_value    => g_operation.terminal_type
      , i_name     => 'TERMINAL_TYPE'
      , io_params  => g_params
    );

    rul_api_param_pkg.set_param(
        i_value    => g_operation.terminal_number
      , i_name     => 'TERMINAL_NUMBER'
      , io_params  => g_params
    );

    select nvl(min(pos_batch_support), com_api_const_pkg.FALSE)
      into l_pos_batch_support
      from acq_terminal t
     where t.terminal_number = g_operation.terminal_number
       and rownum = 1;

    rul_api_param_pkg.set_param(
        i_value    => l_pos_batch_support
      , i_name     => 'POS_BATCH_SUPPORT'
      , io_params  => g_params
    );
    rul_api_param_pkg.set_param(
        i_value    => g_operation.merchant_number
      , i_name     => 'MERCHANT_NUMBER'
      , io_params  => g_params
    );
    rul_api_param_pkg.set_param(
        i_value    => g_operation.merchant_country
      , i_name     => 'MERCHANT_COUNTRY'
      , io_params  => g_params
    );
    rul_api_param_pkg.set_param(
        i_value    => g_operation.merchant_region
      , i_name     => 'MERCHANT_REGION'
      , io_params  => g_params
    );
    rul_api_param_pkg.set_param(
        i_value    => g_operation.mcc
      , i_name     => 'MCC'
      , io_params  => g_params
    );
    rul_api_param_pkg.set_param(
        i_value    => acq_api_merchant_pkg.get_merchant_risk_indicator(
                          i_merchant_id  => g_acq_participant.merchant_id
                      )
      , i_name     => 'RISK_INDICATOR'
      , io_params  => g_params
    );

    opr_cst_shared_data_pkg.collect_global_oper_params(
        io_params  => g_params
    );
    collect_payment_order_params(
        io_params  => g_params
    );
    collect_global_card_params(
        io_params  => g_params
    );

    if g_operation.id is not null then
        if vis_api_fin_message_pkg.is_visa(i_id => g_operation.id) = com_api_const_pkg.TRUE then
            vis_api_shared_data_pkg.collect_fin_message_params(
                io_params     => g_params
            );
        elsif mcw_api_fin_pkg.is_mastercard(i_id => g_operation.id) = com_api_const_pkg.TRUE then
            mcw_api_shared_data_pkg.collect_fin_message_params(
                io_params     => g_params
            );
        elsif cup_api_fin_message_pkg.is_cup(i_id => g_operation.id) = com_api_const_pkg.TRUE then
            cup_api_shared_data_pkg.collect_fin_message_params(
                io_params     => g_params
            );
        elsif mup_api_fin_pkg.is_mup(i_id => g_operation.id) = com_api_const_pkg.TRUE then
            mup_api_shared_data_pkg.collect_fin_message_params(
                io_params     => g_params
              , i_is_incoming => com_api_const_pkg.TRUE
            );
        end if;
    end if;

    rul_api_param_pkg.set_param(
        i_value    => g_operation.merchant_name
      , i_name     => 'MERCHANT_NAME'
      , io_params  => g_params
    );
    rul_api_param_pkg.set_param(
        i_value    => g_operation.proc_mode
      , i_name     => 'PROC_MODE'
      , io_params  => g_params
    );
    rul_api_param_pkg.set_param(
        i_value    => g_auth.resp_code
      , i_name     => 'RESP_CODE'
      , io_params  => g_params
    );
end collect_global_oper_params;

function get_param_num(
    i_name                in            com_api_type_pkg.t_name
  , i_mask_error          in            com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
  , i_error_value         in            com_api_type_pkg.t_name           default null
) return number is
begin
    return rul_api_param_pkg.get_param_num(
               i_name         => i_name
             , io_params      => g_params
             , i_mask_error   => i_mask_error
             , i_error_value  => i_error_value
           );
end;

function get_param_date(
    i_name                in            com_api_type_pkg.t_name
  , i_mask_error          in            com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
  , i_error_value         in            com_api_type_pkg.t_name           default null
) return date is
begin
    return rul_api_param_pkg.get_param_date(
               i_name         => i_name
             , io_params      => g_params
             , i_mask_error   => i_mask_error
             , i_error_value  => i_error_value
           );
end;

function get_param_char(
    i_name                in            com_api_type_pkg.t_name
  , i_mask_error          in            com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
  , i_error_value         in            com_api_type_pkg.t_name           default null
) return com_api_type_pkg.t_name is
begin
    return rul_api_param_pkg.get_param_char(
               i_name         => i_name
             , io_params      => g_params
             , i_mask_error   => i_mask_error
             , i_error_value  => i_error_value
           );
end;

procedure set_param(
    i_name                in            com_api_type_pkg.t_name
  , i_value               in            com_api_type_pkg.t_name
) is
begin
    rul_api_param_pkg.set_param(
        i_name     => i_name
      , io_params  => g_params
      , i_value    => i_value
    );
end;

procedure set_param(
    i_name                in            com_api_type_pkg.t_name
  , i_value               in            number
) is
begin
    rul_api_param_pkg.set_param(
        i_name     => i_name
      , io_params  => g_params
      , i_value    => i_value
    );
end;

procedure set_param(
    i_name                in            com_api_type_pkg.t_name
  , i_value               in            date
) is
begin
    rul_api_param_pkg.set_param(
        i_name     => i_name
      , io_params  => g_params
      , i_value    => i_value
    );
end;

procedure set_amount(
    i_name                in            com_api_type_pkg.t_name
  , i_amount              in            com_api_type_pkg.t_money
  , i_currency            in            com_api_type_pkg.t_curr_code
  , i_conversion_rate     in            com_api_type_pkg.t_rate           default null
  , i_rate_type           in            com_api_type_pkg.t_dict_value     default null
) is
begin
    rul_api_param_pkg.set_amount(
        i_name             => i_name
      , i_amount           => i_amount
      , i_currency         => i_currency
      , i_conversion_rate  => i_conversion_rate
      , i_rate_type        => i_rate_type
      , io_amount_tab      => g_amounts
    );
end;

procedure get_amount(
    i_name                in            com_api_type_pkg.t_name
  , o_amount                 out        com_api_type_pkg.t_money
  , o_currency               out        com_api_type_pkg.t_curr_code
  , i_mask_error          in            com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
  , i_error_amount        in            com_api_type_pkg.t_money          default null
  , i_error_currency      in            com_api_type_pkg.t_curr_code      default null
) is
begin
    rul_api_param_pkg.get_amount(
        i_name            => i_name
      , o_amount          => o_amount
      , o_currency        => o_currency
      , io_amount_tab     => g_amounts
      , i_mask_error      => i_mask_error
      , i_error_amount    => i_error_amount
      , i_error_currency  => i_error_currency
    );
end;

procedure get_amount(
    i_name                in            com_api_type_pkg.t_name
  , o_amount                 out        com_api_type_pkg.t_money
  , o_currency               out        com_api_type_pkg.t_curr_code
  , o_conversion_rate        out        com_api_type_pkg.t_rate
  , o_rate_type              out        com_api_type_pkg.t_dict_value
  , i_mask_error          in            com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
  , i_error_amount        in            com_api_type_pkg.t_money          default null
  , i_error_currency      in            com_api_type_pkg.t_curr_code      default null
) is
begin
    rul_api_param_pkg.get_amount(
        i_name             => i_name
      , o_amount           => o_amount
      , o_currency         => o_currency
      , o_conversion_rate  => o_conversion_rate
      , o_rate_type        => o_rate_type
      , io_amount_tab      => g_amounts
      , i_mask_error       => i_mask_error
      , i_error_amount     => i_error_amount
      , i_error_currency   => i_error_currency
    );
end;

procedure set_account(
    i_name                in            com_api_type_pkg.t_name
  , i_account_rec         in            acc_api_type_pkg.t_account_rec
) is
begin
    rul_api_param_pkg.set_account(
        i_name              => i_name
      , i_account_rec       => i_account_rec
      , io_account_tab      => g_accounts
    );
end;

procedure get_account(
    i_name                in            com_api_type_pkg.t_name
  , o_account_rec            out        acc_api_type_pkg.t_account_rec
  , i_mask_error          in            com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
  , i_error_value         in            com_api_type_pkg.t_account_id     default null
) is
begin
    rul_api_param_pkg.get_account(
        i_name          => i_name
      , o_account_rec   => o_account_rec
      , io_account_tab  => g_accounts
      , i_mask_error    => i_mask_error
      , i_error_value   => i_error_value
    );
end;

procedure set_date(
    i_name                in            com_api_type_pkg.t_name
  , i_date                in            date
) is
begin
    rul_api_param_pkg.set_date(
        i_name       => i_name
      , i_date       => i_date
      , io_date_tab  => g_dates
    );
end;

procedure get_date(
    i_name                in            com_api_type_pkg.t_name
  , o_date                   out        date
  , i_mask_error          in            com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
  , i_error_value         in            date                              default null
) is
begin
    rul_api_param_pkg.get_date(
        i_name         => i_name
      , o_date         => o_date
      , io_date_tab    => g_dates
      , i_mask_error   => i_mask_error
      , i_error_value  => i_error_value
    );
end;

procedure set_currency(
    i_name                in            com_api_type_pkg.t_name
  , i_currency            in            com_api_type_pkg.t_curr_code
) is
begin
    rul_api_param_pkg.set_currency(
        i_name           => i_name
      , i_currency       => i_currency
      , io_currency_tab  => g_currencies
    );
end;

procedure get_currency(
    i_name                in            com_api_type_pkg.t_name
  , o_currency               out        com_api_type_pkg.t_curr_code
  , i_mask_error          in            com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
  , i_error_value         in            com_api_type_pkg.t_curr_code      default null
) is
begin
    rul_api_param_pkg.get_currency(
        i_name           => i_name
      , o_currency       => o_currency
      , io_currency_tab  => g_currencies
      , i_mask_error     => i_mask_error
      , i_error_value    => i_error_value
    );
end;

procedure collect_oper_params
is
    l_additonal_amount_tab    com_api_type_pkg.t_amount_tab;
begin
    set_date(
        i_name      => com_api_const_pkg.DATE_PURPOSE_PROCESSING
      , i_date      => com_api_sttl_day_pkg.get_sysdate
    );
    set_date(
        i_name      => com_api_const_pkg.DATE_PURPOSE_OPERATION
      , i_date      => g_operation.oper_date
    );
    set_date(
        i_name      => com_api_const_pkg.DATE_PURPOSE_HOST
      , i_date      => g_operation.host_date
    );

    set_amount(
        i_name      => com_api_const_pkg.AMOUNT_PURPOSE_OPER_ACTUAL
      , i_amount    => g_operation.oper_amount
      , i_currency  => g_operation.oper_currency
    );
    set_amount(
        i_name      => com_api_const_pkg.AMOUNT_PURPOSE_NETWORK
      , i_amount    => g_auth.network_amount
      , i_currency  => g_auth.network_currency
    );
    set_amount(
        i_name      => com_api_const_pkg.AMOUNT_PURPOSE_OPER_REQUEST
      , i_amount    => g_operation.oper_request_amount
      , i_currency  => g_operation.oper_currency
    );
    set_amount(
        i_name      => com_api_const_pkg.AMOUNT_PURPOSE_OPER_SURCHARGE
      , i_amount    => g_operation.oper_surcharge_amount
      , i_currency  => g_operation.oper_currency
    );
    set_amount(
        i_name      => com_api_const_pkg.AMOUNT_PURPOSE_OPER_CASHBACK
      , i_amount    => g_operation.oper_cashback_amount
      , i_currency  => g_operation.oper_currency
    );
    set_amount(
        i_name      => com_api_const_pkg.AMOUNT_PURPOSE_OPER_REPLACE
      , i_amount    => g_operation.oper_replacement_amount
      , i_currency  => g_operation.oper_currency
    );
    set_amount(
        i_name      => com_api_const_pkg.AMOUNT_PURPOSE_SETTLEMENT
      , i_amount    => g_operation.sttl_amount
      , i_currency  => g_operation.sttl_currency
    );
    set_amount(
        i_name      => com_api_const_pkg.AMOUNT_PURPOSE_ACCOUNT
      , i_amount    => g_iss_participant.account_amount
      , i_currency  => g_iss_participant.account_currency
    );
    set_amount(
        i_name      => com_api_const_pkg.AMOUNT_PURPOSE_SOURCE
      , i_amount    => g_iss_participant.account_amount
      , i_currency  => g_iss_participant.account_currency
    );

    collect_payment_order_params(
        io_params   => g_params
    );

    -- Collect additional amounts,
    -- first of all we read all amounts per once into temporary collection
    opr_api_additional_amount_pkg.get_amounts(
        i_oper_id    => g_operation.id
      , o_amount_tab => l_additonal_amount_tab
    );
    for i in 1 .. l_additonal_amount_tab.count() loop
        set_amount(
            i_name     => l_additonal_amount_tab(i).amount_type
          , i_amount   => l_additonal_amount_tab(i).amount
          , i_currency => l_additonal_amount_tab(i).currency
        );
    end loop;
end collect_oper_params;

procedure put_oper_params
is
    l_account               acc_api_type_pkg.t_account_rec;
    l_amount_type           com_api_type_pkg.t_oracle_name; -- index for g_amounts
begin
    get_date(
        i_name            => com_api_const_pkg.DATE_PURPOSE_UNHOLD
      , o_date            => g_operation.unhold_date
      , i_mask_error      => com_api_const_pkg.TRUE
      , i_error_value     => g_operation.unhold_date
    );
    get_amount(
        i_name            => com_api_const_pkg.AMOUNT_PURPOSE_ACCOUNT
      , o_amount          => g_iss_participant.account_amount
      , o_currency        => g_iss_participant.account_currency
      , i_mask_error      => com_api_const_pkg.TRUE
      , i_error_amount    => g_iss_participant.account_amount
      , i_error_currency  => g_iss_participant.account_currency
    );

    if g_dst_participant.account_amount is null then
        get_amount(
            i_name            => com_api_const_pkg.AMOUNT_PURPOSE_DESTINATION
          , o_amount          => g_dst_participant.account_amount
          , o_currency        => g_dst_participant.account_currency
          , i_mask_error      => com_api_const_pkg.TRUE
          , i_error_amount    => g_dst_participant.account_amount
          , i_error_currency  => g_dst_participant.account_currency
        );
    end if;

    get_account(
        i_name         => com_api_const_pkg.ACCOUNT_PURPOSE_CARD
      , o_account_rec  => l_account
      , i_mask_error   => com_api_const_pkg.TRUE
      , i_error_value  => null
    );
    g_iss_participant.account_id     := l_account.account_id;
    g_iss_participant.account_number := l_account.account_number;

    if g_iss_participant.account_number is null then
        get_account(
            i_name         => com_api_const_pkg.ACCOUNT_PURPOSE_SOURCE
          , o_account_rec  => l_account
          , i_mask_error   => com_api_const_pkg.TRUE
          , i_error_value  => null
        );

        g_iss_participant.account_id     := l_account.account_id;
        g_iss_participant.account_number := l_account.account_number;
    end if;

    if g_dst_participant.account_number is null then
        get_account(
            i_name          => com_api_const_pkg.ACCOUNT_PURPOSE_DESTINATION
          , o_account_rec   => l_account
          , i_mask_error    => com_api_const_pkg.TRUE
          , i_error_value   => null
        );

        g_dst_participant.account_id     := l_account.account_id;
        g_dst_participant.account_number := l_account.account_number;
    end if;

    if g_dst_participant.account_number is not null and g_dst_participant.account_amount is null then
        get_amount(
            i_name            => com_api_const_pkg.AMOUNT_PURPOSE_SOURCE
          , o_amount          => g_dst_participant.account_amount
          , o_currency        => g_dst_participant.account_currency
          , i_mask_error      => com_api_const_pkg.TRUE
          , i_error_amount    => g_dst_participant.account_amount
          , i_error_currency  => g_dst_participant.account_currency
        );
    end if;

    -- All amounts of dictionary AMPR that are NOT saved into tables
    -- OPR_OPERATION or OPR_PARTICIPANT should be treated as additional ones
    l_amount_type := g_amounts.first();
    while l_amount_type is not null loop
        if l_amount_type like com_api_const_pkg.AMOUNT_PURPOSE_DICTIONARY || '%'
           and l_amount_type not in (com_api_const_pkg.AMOUNT_PURPOSE_DESTINATION
                                   , com_api_const_pkg.AMOUNT_PURPOSE_SOURCE)
           and g_amounts(l_amount_type).amount is not null
        then
            opr_api_additional_amount_pkg.save_amount(
                i_oper_id      => g_operation.id
              , i_amount_type  => l_amount_type
              , i_amount_value => g_amounts(l_amount_type).amount
              , i_currency     => g_amounts(l_amount_type).currency
            );
        end if;
        l_amount_type := g_amounts.next(l_amount_type);
    end loop;
end put_oper_params;

function get_object_id(
    io_entity_type        in out        com_api_type_pkg.t_dict_value
  , i_account_name        in            com_api_type_pkg.t_name
  , i_party_type          in            com_api_type_pkg.t_dict_value
  , o_inst_id                out        com_api_type_pkg.t_inst_id
  , o_account_number         out        com_api_type_pkg.t_account_number
) return com_api_type_pkg.t_long_id
is
    l_account_rec                       acc_api_type_pkg.t_account_rec;
    l_participant                       opr_api_type_pkg.t_oper_part_rec;
begin
    if io_entity_type is null then
        if i_party_type is not null then
            io_entity_type :=
                case get_participant(i_party_type).client_id_type
                    when opr_api_const_pkg.CLIENT_ID_TYPE_CARD then
                        iss_api_const_pkg.ENTITY_TYPE_CARD
                    when opr_api_const_pkg.CLIENT_ID_TYPE_CARD_ID then
                        iss_api_const_pkg.ENTITY_TYPE_CARD
                    when opr_api_const_pkg.CLIENT_ID_TYPE_ACCOUNT then
                        acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                    else
                        com_api_const_pkg.ENTITY_TYPE_CUSTOMER
                end;
        end if;
    end if;

    l_participant := get_participant(i_participant_type  => i_party_type);

    if io_entity_type in (iss_api_const_pkg.ENTITY_TYPE_CUSTOMER
                        , acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                        , ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
                        , prd_api_const_pkg.ENTITY_TYPE_CONTRACT)
    then
        o_inst_id        := l_participant.inst_id;
        o_account_number := l_participant.account_number;
    end if;

    case io_entity_type
        when acq_api_const_pkg.ENTITY_TYPE_MERCHANT then
            if i_party_type = com_api_const_pkg.PARTICIPANT_DEST and g_dst_participant.merchant_id is not null then
                o_inst_id := g_dst_participant.inst_id;
                o_account_number := g_dst_participant.account_number;
                return g_dst_participant.merchant_id;

            else
                if g_acq_participant.merchant_id is not null then
                    o_inst_id := g_acq_participant.inst_id;
                    o_account_number := g_acq_participant.account_number;
                    return g_acq_participant.merchant_id;
                end if;

            end if;

        when acq_api_const_pkg.ENTITY_TYPE_TERMINAL then
            if i_party_type = com_api_const_pkg.PARTICIPANT_DEST and g_dst_participant.terminal_id is not null then
                o_inst_id := g_dst_participant.inst_id;
                o_account_number := g_dst_participant.account_number;
                return g_dst_participant.terminal_id;

            else
                if g_acq_participant.terminal_id is not null then
                    o_inst_id := g_acq_participant.inst_id;
                    o_account_number := g_acq_participant.account_number;
                    return g_acq_participant.terminal_id;
                end if;

            end if;

        when iss_api_const_pkg.ENTITY_TYPE_CARD then
            if i_party_type = com_api_const_pkg.PARTICIPANT_ISSUER and g_iss_participant.card_id is not null then
                o_inst_id := g_iss_participant.card_inst_id;
                o_account_number := g_iss_participant.account_number;
                return g_iss_participant.card_id;
            elsif i_party_type = com_api_const_pkg.PARTICIPANT_DEST and g_dst_participant.card_id is not null then
                o_inst_id := g_dst_participant.card_inst_id;
                o_account_number := g_dst_participant.account_number;
                return g_dst_participant.card_id;
            end if;

        when iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE then
            if g_iss_participant.card_instance_id is not null then
                o_inst_id := g_iss_participant.card_inst_id;
                o_account_number := g_iss_participant.account_number;
                return g_iss_participant.card_instance_id;
            end if;

        when iss_api_const_pkg.ENTITY_TYPE_CUSTOMER then
            return l_participant.customer_id;

        when acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
            if i_account_name is not null then
                get_account(
                    i_name         => i_account_name
                  , o_account_rec  => l_account_rec
                  , i_mask_error   => com_api_const_pkg.TRUE
                  , i_error_value  => null
                );
            end if;

            if l_account_rec.account_id is null
                and l_participant.inst_id is not null
                and l_participant.account_id is not null
            then
                return l_participant.account_id;

            elsif i_account_name is not null
                  and l_account_rec.account_id is not null
            then
                o_inst_id        := l_account_rec.inst_id;
                o_account_number := l_account_rec.account_number;

                return l_account_rec.account_id;
            end if;

        when ost_api_const_pkg.ENTITY_TYPE_AGENT then

            get_account(
                i_name              => i_account_name
              , o_account_rec       => l_account_rec
            );

            o_inst_id        := l_account_rec.inst_id;
            o_account_number := l_account_rec.account_number;

            return l_account_rec.agent_id;

        when ost_api_const_pkg.ENTITY_TYPE_INSTITUTION then
            return l_participant.inst_id;

        when prd_api_const_pkg.ENTITY_TYPE_CONTRACT then
            return l_participant.contract_id;

    else
        null;
    end case;

    com_api_error_pkg.raise_error(
        i_error       => 'OPERATION_ENTITY_NOT_AVAILABLE'
      , i_env_param1  => io_entity_type
      , i_env_param2  => i_account_name
      , i_env_param3  => i_party_type
    );
end get_object_id;

function get_object_id (
     io_entity_type       in out        com_api_type_pkg.t_dict_value
   , i_account_name       in            com_api_type_pkg.t_name
   , i_party_type         in            com_api_type_pkg.t_dict_value
   , o_inst_id               out        com_api_type_pkg.t_inst_id
) return com_api_type_pkg.t_long_id
is
    l_account_number                    com_api_type_pkg.t_account_number;
begin
    return get_object_id(
               io_entity_type    => io_entity_type
             , i_account_name    => i_account_name
             , i_party_type      => i_party_type
             , o_inst_id         => o_inst_id
             , o_account_number  => l_account_number
           );
end;

function get_object_id (
    i_entity_type         in            com_api_type_pkg.t_dict_value
  , i_account_name        in            com_api_type_pkg.t_name
  , i_party_type          in            com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_long_id
is
    l_entity_type                       com_api_type_pkg.t_dict_value := i_entity_type;
    l_inst_id                           com_api_type_pkg.t_inst_id;
    l_account_number                    com_api_type_pkg.t_account_number;
begin
    return get_object_id(
               io_entity_type    => l_entity_type
             , i_account_name    => i_account_name
             , i_party_type      => i_party_type
             , o_inst_id         => l_inst_id
             , o_account_number  => l_account_number
           );
end;

function get_object_id(
    i_entity_type         in            com_api_type_pkg.t_dict_value
  , i_account_name        in            com_api_type_pkg.t_name
  , i_party_type          in            com_api_type_pkg.t_dict_value
  , o_inst_id                out        com_api_type_pkg.t_inst_id
) return com_api_type_pkg.t_long_id
is
    l_entity_type                       com_api_type_pkg.t_dict_value := i_entity_type;
    l_account_number                    com_api_type_pkg.t_account_number;
begin
    return get_object_id(
               io_entity_type    => l_entity_type
             , i_account_name    => i_account_name
             , i_party_type      => i_party_type
             , o_inst_id         => o_inst_id
             , o_account_number  => l_account_number
           );
end;

function get_object_id(
    i_entity_type         in            com_api_type_pkg.t_dict_value
  , i_account_name        in            com_api_type_pkg.t_name
  , i_party_type          in            com_api_type_pkg.t_dict_value
  , o_account_number         out        com_api_type_pkg.t_account_number
) return com_api_type_pkg.t_long_id
is
    l_entity_type                       com_api_type_pkg.t_dict_value := i_entity_type;
    l_inst_id                           com_api_type_pkg.t_inst_id;
begin
    return get_object_id(
               io_entity_type    => l_entity_type
             , i_account_name    => i_account_name
             , i_party_type      => i_party_type
             , o_inst_id         => l_inst_id
             , o_account_number  => o_account_number
           );
end;

function get_operation return opr_api_type_pkg.t_oper_rec is
begin
    return g_operation;
end;

procedure set_participant(
    i_oper_participant    in            opr_api_type_pkg.t_oper_part_rec
) is
begin
    case i_oper_participant.participant_type
    when com_api_const_pkg.PARTICIPANT_ISSUER then
        g_iss_participant := i_oper_participant;
    when com_api_const_pkg.PARTICIPANT_ACQUIRER then
        g_acq_participant := i_oper_participant;
    when com_api_const_pkg.PARTICIPANT_DEST then
        g_dst_participant := i_oper_participant;
    when com_api_const_pkg.PARTICIPANT_AGGREGATOR then
        g_agg_participant := i_oper_participant;
    when com_api_const_pkg.PARTICIPANT_SERVICE_PROVIDER then
        g_spr_participant := i_oper_participant;
    when com_api_const_pkg.PARTICIPANT_LOYALTY then
        g_lty_participant := i_oper_participant;
    when com_api_const_pkg.PARTICIPANT_INSTITUTION then
        g_inst_participant := i_oper_participant;
    else
        null;
    end case;
end;

function get_participant(
    i_participant_type    in            com_api_type_pkg.t_dict_value
) return opr_api_type_pkg.t_oper_part_rec is
begin
    return case i_participant_type
               when com_api_const_pkg.PARTICIPANT_ISSUER           then g_iss_participant
               when com_api_const_pkg.PARTICIPANT_ACQUIRER         then g_acq_participant
               when com_api_const_pkg.PARTICIPANT_DEST             then g_dst_participant
               when com_api_const_pkg.PARTICIPANT_AGGREGATOR       then g_agg_participant
               when com_api_const_pkg.PARTICIPANT_SERVICE_PROVIDER then g_spr_participant
               when com_api_const_pkg.PARTICIPANT_LOYALTY          then g_lty_participant
               when com_api_const_pkg.PARTICIPANT_INSTITUTION      then g_inst_participant
           end;
end;

procedure assert_operation(
    i_id                  in            com_api_type_pkg.t_long_id
) is
begin
    if g_operation.id is null or (i_id is null or i_id = g_operation.id) then
        null;
    else
        com_api_error_pkg.raise_error(
            i_error       => 'SET_OPERATION_NOT_AVAILABLE'
          , i_env_param1  => g_operation.id
          , i_env_param2  => i_id
        );
    end if;
end;

procedure set_operation(
    i_operation           in            opr_api_type_pkg.t_oper_rec
) is
begin
    assert_operation(
        i_id  => i_operation.id
    );
    g_operation := i_operation;
end;

procedure set_operation_proc_stage(
    i_id                  in            com_api_type_pkg.t_long_id
  , i_proc_stage          in            com_api_type_pkg.t_dict_value
) is
begin
    assert_operation(
        i_id  => i_id
    );
    g_operation.proc_stage := i_proc_stage;
end;

procedure set_operation_status(
    i_id                  in            com_api_type_pkg.t_long_id
  , i_status              in            com_api_type_pkg.t_dict_value
) is
begin
    assert_operation(
        i_id  => i_id
    );
    g_operation.status := i_status;
end;

procedure set_operation_reason(
    i_id                  in            com_api_type_pkg.t_long_id
  , i_reason              in            com_api_type_pkg.t_dict_value
) is
begin
    assert_operation(
        i_id  => i_id
    );
    g_operation.status_reason := i_reason;
end;

procedure load_card_params is
begin
    rul_api_shared_data_pkg.load_card_params(
        i_card_id           => g_iss_participant.card_id
      , i_card_instance_id  => g_iss_participant.card_instance_id
      , io_params           => g_params
    );
end;

procedure load_account_params is
begin
    rul_api_shared_data_pkg.load_account_params(
        i_account_id  => g_dst_participant.account_id
      , io_params     => g_params
    );
end;

procedure load_terminal_params is
begin
    rul_api_shared_data_pkg.load_terminal_params(
        i_terminal_id  => g_acq_participant.terminal_id
      , io_params      => g_params
    );
end;

procedure load_merchant_params is
begin
    rul_api_shared_data_pkg.load_merchant_params(
        i_merchant_id  => g_acq_participant.merchant_id
      , io_params      => g_params
    );
end;

procedure load_customer_params(
    i_party_type          in            com_api_type_pkg.t_dict_value
) is
    l_object_id                         com_api_type_pkg.t_medium_id;
begin
    if i_party_type = com_api_const_pkg.PARTICIPANT_ACQUIRER then
        select c.customer_id
          into l_object_id
          from acq_merchant m
             , prd_contract c
         where m.id = g_acq_participant.merchant_id
           and c.id = m.contract_id;
    elsif i_party_type = com_api_const_pkg.PARTICIPANT_ISSUER then
        l_object_id := g_iss_participant.customer_id;
    elsif i_party_type = com_api_const_pkg.PARTICIPANT_DEST then
        l_object_id := g_dst_participant.customer_id;
    end if;

    rul_api_shared_data_pkg.load_customer_params(
        i_customer_id  => l_object_id
      , io_params      => g_params
      , i_usage        => com_api_const_pkg.FLEXIBLE_FIELD_PROC_OPER
    );
end;

procedure stop_process(
    i_id                  in            com_api_type_pkg.t_long_id
  , i_status              in            com_api_type_pkg.t_dict_value
  , i_reason              in            com_api_type_pkg.t_dict_value     default null
) is
begin
    set_operation_status(
        i_id      => i_id
      , i_status  => i_status
    );
    if i_reason is not null then
        set_operation_reason(
            i_id      => i_id
          , i_reason  => i_reason
        );
    end if;
    raise com_api_error_pkg.e_stop_process_operation;
end;

procedure rollback_process(
    i_id                  in            com_api_type_pkg.t_long_id
  , i_status              in            com_api_type_pkg.t_dict_value
  , i_reason              in            com_api_type_pkg.t_dict_value
) is
begin
    set_operation_status(
        i_id      => i_id
      , i_status  => i_status
    );
    set_operation_reason(
        i_id      => i_id
      , i_reason  => i_reason
    );
    trc_log_pkg.error(
        i_text        => 'ERROR_ROLLBACK_PROCESSING_OPERATION'
      , i_env_param1  => i_id
      , i_env_param2  => i_status
      , i_env_param3  => i_reason
      , i_entity_type => opr_api_const_pkg.ENTITY_TYPE_OPERATION
      , i_object_id   => i_id
    );
    raise com_api_error_pkg.e_rollback_process_operation;
end;

procedure collect_auth_params(
    i_auth                in            aut_api_type_pkg.t_auth_rec
  , io_params             in out nocopy com_api_type_pkg.t_param_tab
) is
begin
    io_params.delete;

    rul_api_param_pkg.set_param(
        i_value    => i_auth.iss_network_id
      , i_name     => 'ISS_NETWORK_ID'
      , io_params  => io_params
    );
    rul_api_param_pkg.set_param(
        i_value    => i_auth.acq_network_id
      , i_name     => 'ACQ_NETWORK_ID'
      , io_params  => io_params
    );
    rul_api_param_pkg.set_param(
        i_value    => i_auth.dst_network_id
      , i_name     => 'DST_NETWORK_ID'
      , io_params  => io_params
    );
    rul_api_param_pkg.set_param(
        i_value    => i_auth.dst_inst_id
      , i_name     => 'DST_INST_ID'
      , io_params  => io_params
    );
    rul_api_param_pkg.set_param(
        i_value    => i_auth.card_network_id
      , i_name     => 'CARD_NETWORK_ID'
      , io_params  => io_params
    );
    rul_api_param_pkg.set_param(
        i_value    => i_auth.card_inst_id
      , i_name     => 'CARD_INST_ID'
      , io_params  => io_params
    );
    rul_api_param_pkg.set_param(
        i_value    => i_auth.host_date
      , i_name     => 'HOST_DATE'
      , io_params  => io_params
    );
    rul_api_param_pkg.set_param(
        i_value    => i_auth.unhold_date
      , i_name     => 'UNHOLD_DATE'
      , io_params  => io_params
    );
    rul_api_param_pkg.set_param(
        i_value    => i_auth.customer_id
      , i_name     => 'CUSTOMER_ID'
      , io_params  => io_params
    );
    rul_api_param_pkg.set_param(
        i_value    => i_auth.client_id_type
      , i_name     => 'CLIENT_ID_TYPE'
      , io_params  => io_params
    );
    rul_api_param_pkg.set_param(
        i_value    => i_auth.dst_client_id_type
      , i_name     => 'DST_CLIENT_ID_TYPE'
      , io_params  => io_params
    );
    rul_api_param_pkg.set_param(
        i_value    => i_auth.oper_amount_algorithm
      , i_name     => 'OPER_AMOUNT_ALGORITHM'
      , io_params  => io_params
    );
    rul_api_param_pkg.set_param(
        i_value    => i_auth.terminal_number
      , i_name     => 'TERMINAL_NUMBER'
      , io_params  => io_params
    );
    rul_api_param_pkg.set_param(
        i_value    => i_auth.is_advice
      , i_name     => 'IS_ADVICE'
      , io_params  => io_params
    );

    rul_api_param_pkg.set_param(
        i_value    => i_auth.card_presence
      , i_name     => 'CARD_PRESENCE'
      , io_params  => io_params
    );
    rul_api_param_pkg.set_param(
        i_value    => i_auth.crdh_presence
      , i_name     => 'CRDH_PRESENCE'
      , io_params  => io_params
    );
    rul_api_param_pkg.set_param(
        i_value    => i_auth.pin_presence
      , i_name     => 'PIN_PRESENCE'
      , io_params  => io_params
    );
    rul_api_param_pkg.set_param(
        i_value    => i_auth.cvv2_presence
      , i_name     => 'CVV2_PRESENCE'
      , io_params  => io_params
    );
    rul_api_param_pkg.set_param(
        i_value    => i_auth.auth_purpose_id
      , i_name     => 'AUTH_PURPOSE_ID'
      , io_params  => io_params
    );
    rul_api_param_pkg.set_param(
        i_value    => i_auth.card_data_input_cap
      , i_name     => 'CARD_DATA_INPUT_CAP'
      , io_params  => io_params
    );
    rul_api_param_pkg.set_param(
        i_value    => i_auth.crdh_auth_cap
      , i_name     => 'CRDH_AUTH_CAP'
      , io_params  => io_params
    );
    rul_api_param_pkg.set_param(
        i_value    => i_auth.card_capture_cap
      , i_name     => 'CARD_CAPTURE_CAP'
      , io_params  => io_params
    );
    rul_api_param_pkg.set_param(
        i_value    => i_auth.terminal_operating_env
      , i_name     => 'TERMINAL_OPERATING_ENV'
      , io_params  => io_params
    );
    rul_api_param_pkg.set_param(
        i_value    => i_auth.card_data_input_mode
      , i_name     => 'CARD_DATA_INPUT_MODE'
      , io_params  => io_params
    );
    rul_api_param_pkg.set_param(
        i_value    => i_auth.crdh_auth_method
      , i_name     => 'CRDH_AUTH_METHOD'
      , io_params  => io_params
    );                                                                         
    rul_api_param_pkg.set_param(
        i_value    => i_auth.crdh_auth_entity
      , i_name     => 'CRDH_AUTH_ENTITY'
      , io_params  => io_params
    );
end collect_auth_params;

procedure collect_auth_params(
    i_id                  in            com_api_type_pkg.t_long_id
  , io_params             in out nocopy com_api_type_pkg.t_param_tab
) is
    l_auth                              aut_api_type_pkg.t_auth_rec;
begin
    load_auth(
        i_id         => i_id
      , io_auth      => l_auth
    );
    collect_auth_params(
        i_auth       => l_auth
      , io_params    => io_params
    );
end;

procedure collect_auth_params is
begin
    -- collecting data from auth to param arrays
    collect_auth_params (
        i_auth      => g_auth
      , io_params   => g_params
    );

    set_date(
        i_name      => com_api_const_pkg.DATE_PURPOSE_PROCESSING
      , i_date      => com_api_sttl_day_pkg.get_sysdate
    );
    set_date(
        i_name      => com_api_const_pkg.DATE_PURPOSE_OPERATION
      , i_date      => g_auth.oper_date
    );
    set_date(
        i_name      => com_api_const_pkg.DATE_PURPOSE_UNHOLD
      , i_date      => g_auth.unhold_date
    );

    set_amount(
        i_name      => com_api_const_pkg.AMOUNT_PURPOSE_NETWORK
      , i_amount    => g_auth.network_amount
      , i_currency  => g_auth.network_currency
    );
    set_amount(
        i_name      => com_api_const_pkg.AMOUNT_PURPOSE_BIN
      , i_amount    => g_auth.bin_amount
      , i_currency  => g_auth.bin_currency
    );
    set_amount(
        i_name      => com_api_const_pkg.AMOUNT_PURPOSE_ACCOUNT
      , i_amount    => g_auth.account_amount
      , i_currency  => g_auth.account_currency
    );

    if g_auth.amounts is not null then
        for r in (
            select substr(amounts, 1, 8) amount_type
                 , substr(amounts, 9, 3) currency
                 , decode(substr(amounts, 12, 1), 'N', -1, 1) * to_number(substr(amounts, 13), com_api_const_pkg.XML_FLOAT_FORMAT) amount
              from (select substr(g_auth.amounts, (level - 1) * 35 + 1, 35) amounts
                      from dual
                   connect by level < length(nvl(g_auth.amounts, 0)) / 35 + 1
              )
        ) loop
            set_amount(
                i_name            => r.amount_type
              , i_amount          => r.amount
              , i_currency        => r.currency
            );
        end loop;
    end if;
end collect_auth_params;

procedure load_auth(
    i_id                  in            com_api_type_pkg.t_long_id
  , io_auth               in out nocopy aut_api_type_pkg.t_auth_rec
) is
begin
    select min(null) proc_stage
         , min(a.rowid)
         , min(a.id)
         , min(null) split_hash
         , min(o.session_id)
         , min(o.is_reversal)
         , min(o.original_id)
         , min(a.parent_id)
         , min(o.id) oper_id
         , min(o.msg_type)
         , min(o.oper_type)
         , min(o.oper_reason)
         , min(a.resp_code)
         , min(o.status)
         , min(o.status_reason)
         , min(a.proc_type)
         , min(a.proc_mode)
         , min(o.sttl_type)
         , min(o.match_status)
         , min(o.forced_processing)
         , min(a.is_advice)
         , min(a.is_repeat)
         , min(a.is_completed)
         , min(o.host_date)
         , min(o.sttl_date)
         , min(o.acq_sttl_date)
         , min(o.unhold_date)
         , min(o.oper_date)
         , min(o.oper_count)
         , min(o.oper_request_amount)
         , min(o.oper_amount_algorithm)
         , min(o.oper_amount)
         , min(o.oper_currency)
         , min(o.oper_cashback_amount)
         , min(o.oper_replacement_amount)
         , min(o.oper_surcharge_amount)
         , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER, p.client_id_type,    null))
         , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER, p.client_id_value,   null))
         , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER, p.inst_id,           null))
         , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER, p.network_id,        null))
         , min(a.iss_network_device_id)
         , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER, p.split_hash,        null))
         , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER, p.card_inst_id,      null))
         , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER, p.card_network_id,   null))
         , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER
                    , iss_api_token_pkg.decode_card_number(i_card_number => c.card_number),          null))
         , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER, p.card_id,           null))
         , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER, p.card_instance_id,  null))
         , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER, p.card_type_id,      null))
         , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER, p.card_mask,         null))
         , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER, p.card_hash,         null))
         , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER, p.card_seq_number,   null))
         , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER, p.card_expir_date,   null))
         , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER, p.card_service_code, null))
         , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER, p.card_country,      null))
         , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER, p.customer_id,       null))
         , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER, p.account_id,        null))
         , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER, p.account_type,      null))
         , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER, p.account_number,    null))
         , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER, p.account_amount,    null))
         , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER, p.account_currency,  null))
         , min(a.account_cnvt_rate)
         , min(a.bin_amount)
         , min(a.bin_currency)
         , min(a.bin_cnvt_rate)
         , min(a.network_amount)
         , min(a.network_currency)
         , min(a.network_cnvt_date)
         , min(a.network_cnvt_rate)
         , min(a.addr_verif_result)
         , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER, p.auth_code,         null))
         , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_DEST, p.client_id_type,      null))
         , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_DEST, p.client_id_value,     null))
         , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_DEST, p.inst_id,             null))
         , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_DEST, p.network_id,          null))
         , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_DEST, p.card_inst_id,        null))
         , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_DEST, p.card_network_id,     null))
         , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_DEST
                    , iss_api_token_pkg.decode_card_number(i_card_number => c.card_number),          null))
         , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_DEST, p.card_id,             null))
         , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_DEST, p.card_instance_id,    null))
         , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_DEST, p.card_type_id,        null))
         , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_DEST, p.card_mask,           null))
         , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_DEST, p.card_hash,           null))
         , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_DEST, p.card_seq_number,     null))
         , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_DEST, p.card_expir_date,     null))
         , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_DEST, p.card_service_code,   null))
         , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_DEST, p.card_country,        null))
         , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_DEST, p.customer_id,         null))
         , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_DEST, p.account_id,          null))
         , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_DEST, p.account_type,        null))
         , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_DEST, p.account_number,      null))
         , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_DEST, p.account_amount,      null))
         , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_DEST, p.account_currency,    null))
         , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_DEST, p.auth_code,           null))
         , min(a.acq_device_id)
         , min(a.acq_resp_code)
         , min(a.acq_device_proc_result)
         , min(o.acq_inst_bin)
         , min(o.forw_inst_bin)
         , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ACQUIRER, p.inst_id,         null))
         , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ACQUIRER, p.network_id,      null))
         , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ACQUIRER, p.split_hash,      null))
         , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ACQUIRER, p.merchant_id,     null))
         , min(o.merchant_number)
         , min(o.terminal_type)
         , min(o.terminal_number)
         , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ACQUIRER, p.terminal_id,     null))
         , min(o.merchant_name)
         , min(o.merchant_street)
         , min(o.merchant_city)
         , min(o.merchant_region)
         , min(o.merchant_country)
         , min(o.merchant_postcode)
         , min(a.cat_level)
         , min(o.mcc)
         , min(o.originator_refnum)
         , min(o.network_refnum)
         , min(a.card_data_input_cap)
         , min(a.crdh_auth_cap)
         , min(a.card_capture_cap)
         , min(a.terminal_operating_env)
         , min(a.crdh_presence)
         , min(a.card_presence)
         , min(a.card_data_input_mode)
         , min(a.crdh_auth_method)
         , min(a.crdh_auth_entity)
         , min(a.card_data_output_cap)
         , min(a.terminal_output_cap)
         , min(a.pin_capture_cap)
         , min(a.pin_presence)
         , min(a.cvv2_presence)
         , min(a.cvc_indicator)
         , min(a.pos_entry_mode)
         , min(a.pos_cond_code)
         , min(o.payment_order_id)
         , min(o.payment_host_id)
         , min(a.emv_data)
         , min(a.atc)
         , min(a.tvr)
         , min(a.cvr)
         , min(a.addl_data)
         , min(a.service_code)
         , min(a.device_date)
         , min(a.cvv2_result)
         , min(a.certificate_method)
         , min(a.certificate_type)
         , min(a.merchant_certif)
         , min(a.cardholder_certif)
         , min(a.ucaf_indicator)
         , min(a.is_early_emv)
         , min(a.amounts)
         , min(a.cavv_presence)
         , min(a.aav_presence)
         , min(a.transaction_id)
         , min(a.system_trace_audit_number)
         , min(a.external_auth_id)
         , min(a.external_orig_id)
         , min(a.agent_unique_id)
         , min(a.native_resp_code)
         , min(a.trace_number)
         , min(a.auth_purpose_id)
         , min(a.is_incremental)
      into io_auth
      from aut_auth a
         , opr_card c
         , opr_operation o
         , opr_participant p
     where a.id = i_id
       and a.id = o.id
       and o.id = p.oper_id
       and p.oper_id = c.oper_id(+)
       and p.participant_type = c.participant_type(+);
end load_auth;

function get_auth(
    i_id                  in            com_api_type_pkg.t_long_id
) return aut_api_type_pkg.t_auth_rec
is
    l_auth_rec                          aut_api_type_pkg.t_auth_rec;
begin
    load_auth(
        i_id    => i_id
      , io_auth => l_auth_rec
    );
    return l_auth_rec;
end get_auth;

procedure put_auth_params is
    l_account               acc_api_type_pkg.t_account_rec;
    l_amount                com_api_type_pkg.t_money;
    l_currency              com_api_type_pkg.t_curr_code;
begin
    trc_log_pkg.debug(
        i_text       => 'Going to put data from param arrays back to auth'
    );

    get_amount(
        i_name        => com_api_const_pkg.AMOUNT_PURPOSE_OPER_REQUEST
      , o_amount      => l_amount
      , o_currency    => l_currency
      , i_mask_error  => com_api_const_pkg.TRUE
    );
    if nvl(l_currency, com_api_const_pkg.UNDEFINED_CURRENCY) not in (com_api_const_pkg.ZERO_CURRENCY
                                                                   , com_api_const_pkg.UNDEFINED_CURRENCY)
    then
        get_amount(
            i_name            => com_api_const_pkg.AMOUNT_PURPOSE_OPER_REQUEST
          , o_amount          => g_auth.oper_request_amount
          , o_currency        => g_auth.oper_currency
          , i_mask_error      => com_api_const_pkg.TRUE
          , i_error_amount    => g_auth.oper_request_amount
          , i_error_currency  => g_auth.oper_currency
        );
    end if;
    get_amount(
        i_name            => com_api_const_pkg.AMOUNT_PURPOSE_OPER_ACTUAL
      , o_amount          => l_amount
      , o_currency        => l_currency
      , i_mask_error      => com_api_const_pkg.TRUE
    );
    if nvl(l_currency, com_api_const_pkg.UNDEFINED_CURRENCY) not in (com_api_const_pkg.ZERO_CURRENCY
                                                                   , com_api_const_pkg.UNDEFINED_CURRENCY)
    then
        get_amount(
            i_name            => com_api_const_pkg.AMOUNT_PURPOSE_OPER_ACTUAL
          , o_amount          => g_auth.oper_amount
          , o_currency        => g_auth.oper_currency
          , i_mask_error      => com_api_const_pkg.TRUE
          , i_error_amount    => g_auth.oper_amount
          , i_error_currency  => g_auth.oper_currency
        );
    end if;
    get_amount(
        i_name        => com_api_const_pkg.AMOUNT_PURPOSE_OPER_SURCHARGE
      , o_amount      => l_amount
      , o_currency    => l_currency
      , i_mask_error  => com_api_const_pkg.TRUE
    );
    if nvl(l_currency, com_api_const_pkg.UNDEFINED_CURRENCY) not in (com_api_const_pkg.ZERO_CURRENCY
                                                                   , com_api_const_pkg.UNDEFINED_CURRENCY)
    then
        get_amount(
            i_name            => com_api_const_pkg.AMOUNT_PURPOSE_OPER_SURCHARGE
          , o_amount          => g_auth.oper_surcharge_amount
          , o_currency        => g_auth.oper_currency
          , i_mask_error      => com_api_const_pkg.TRUE
          , i_error_amount    => g_auth.oper_surcharge_amount
          , i_error_currency  => g_auth.oper_currency
        );
    end if;
    get_amount(
        i_name        => com_api_const_pkg.AMOUNT_PURPOSE_OPER_CASHBACK
      , o_amount      => l_amount
      , o_currency    => l_currency
      , i_mask_error  => com_api_const_pkg.TRUE
    );
    if nvl(l_currency, com_api_const_pkg.UNDEFINED_CURRENCY) not in (com_api_const_pkg.ZERO_CURRENCY
                                                                   , com_api_const_pkg.UNDEFINED_CURRENCY)
    then
        get_amount(
            i_name            => com_api_const_pkg.AMOUNT_PURPOSE_OPER_CASHBACK
          , o_amount          => g_auth.oper_cashback_amount
          , o_currency        => g_auth.oper_currency
          , i_mask_error      => com_api_const_pkg.TRUE
          , i_error_amount    => g_auth.oper_cashback_amount
          , i_error_currency  => g_auth.oper_currency
        );
    end if;
    get_amount(
        i_name        => com_api_const_pkg.AMOUNT_PURPOSE_OPER_REPLACE
      , o_amount      => l_amount
      , o_currency    => l_currency
      , i_mask_error  => com_api_const_pkg.TRUE
    );
    if nvl(l_currency, com_api_const_pkg.UNDEFINED_CURRENCY) not in (com_api_const_pkg.ZERO_CURRENCY
                                                                   , com_api_const_pkg.UNDEFINED_CURRENCY)
    then
        get_amount(
            i_name            => com_api_const_pkg.AMOUNT_PURPOSE_OPER_REPLACE
          , o_amount          => g_auth.oper_replacement_amount
          , o_currency        => g_auth.oper_currency
          , i_mask_error      => com_api_const_pkg.TRUE
          , i_error_amount    => g_auth.oper_replacement_amount
          , i_error_currency  => g_auth.oper_currency
        );
    end if;
    get_amount(
        i_name            => com_api_const_pkg.AMOUNT_PURPOSE_NETWORK
      , o_amount          => g_auth.network_amount
      , o_currency        => g_auth.network_currency
      , i_mask_error      => com_api_const_pkg.TRUE
      , i_error_amount    => g_auth.network_amount
      , i_error_currency  => g_auth.network_currency
    );
    get_amount(
        i_name            => com_api_const_pkg.AMOUNT_PURPOSE_BIN
      , o_amount          => g_auth.bin_amount
      , o_currency        => g_auth.bin_currency
      , i_mask_error      => com_api_const_pkg.TRUE
      , i_error_amount    => g_auth.bin_amount
      , i_error_currency  => g_auth.bin_currency
    );
    get_amount(
        i_name            => com_api_const_pkg.AMOUNT_PURPOSE_ACCOUNT
      , o_amount          => g_auth.account_amount
      , o_currency        => g_auth.account_currency
      , i_mask_error      => com_api_const_pkg.TRUE
      , i_error_amount    => g_auth.account_amount
      , i_error_currency  => g_auth.account_currency
    );
    if g_auth.account_amount is null then
        get_amount(
            i_name            => com_api_const_pkg.AMOUNT_PURPOSE_SOURCE
          , o_amount          => g_auth.account_amount
          , o_currency        => g_auth.account_currency
          , i_mask_error      => com_api_const_pkg.TRUE
          , i_error_amount    => g_auth.account_amount
          , i_error_currency  => g_auth.account_currency
        );
    end if;

    if g_auth.dst_account_amount is null then
        get_amount(
            i_name            => com_api_const_pkg.AMOUNT_PURPOSE_DESTINATION
          , o_amount          => g_auth.dst_account_amount
          , o_currency        => g_auth.dst_account_currency
          , i_mask_error      => com_api_const_pkg.TRUE
          , i_error_amount    => g_auth.dst_account_amount
          , i_error_currency  => g_auth.dst_account_currency
        );
    end if;

    get_date (
        i_name         => com_api_const_pkg.DATE_PURPOSE_UNHOLD
      , o_date         => g_auth.unhold_date
      , i_mask_error   => com_api_const_pkg.TRUE
      , i_error_value  => g_auth.unhold_date
    );

    get_account(
        i_name         => com_api_const_pkg.ACCOUNT_PURPOSE_CARD
      , o_account_rec  => l_account
      , i_mask_error   => com_api_const_pkg.TRUE
      , i_error_value  => null
    );

    g_auth.account_id     := l_account.account_id;
    g_auth.account_number := l_account.account_number;

    if g_auth.account_number is null then
        get_account(
            i_name         => com_api_const_pkg.ACCOUNT_PURPOSE_SOURCE
          , o_account_rec  => l_account
          , i_mask_error   => com_api_const_pkg.TRUE
          , i_error_value  => null
        );

        g_auth.account_id     := l_account.account_id;
        g_auth.account_number := l_account.account_number;
    end if;

    if g_auth.dst_account_number is null then
        get_account(
            i_name         => com_api_const_pkg.ACCOUNT_PURPOSE_DESTINATION
          , o_account_rec  => l_account
          , i_mask_error   => com_api_const_pkg.TRUE
          , i_error_value  => null
        );

        g_auth.dst_account_id     := l_account.account_id;
        g_auth.dst_account_number := l_account.account_number;
    end if;

    if g_auth.dst_account_number is not null and g_auth.dst_account_amount is null then
        get_amount(
            i_name            => com_api_const_pkg.AMOUNT_PURPOSE_SOURCE
          , o_amount          => g_auth.dst_account_amount
          , o_currency        => g_auth.dst_account_currency
          , i_mask_error      => com_api_const_pkg.TRUE
          , i_error_amount    => g_auth.dst_account_amount
          , i_error_currency  => g_auth.dst_account_currency
        );
    end if;

    g_auth.oper_id :=
        get_param_num(
            i_name          => 'OPERATION_ID'
          , i_mask_error  => com_api_const_pkg.TRUE
          , i_error_value => g_auth.oper_id
        );
end put_auth_params;

function get_returning_resp_code return com_api_type_pkg.t_dict_value is
begin
    return
        nvl(g_operation.status_reason, aup_api_const_pkg.RESP_CODE_OK);
end;

function get_operation_id(
    i_selector            in            com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_long_id
is
    l_operation_id                      com_api_type_pkg.t_long_id;
begin
    l_operation_id :=
        case i_selector
            when opr_api_const_pkg.OPER_SELECTOR_CURRENT then
                get_operation().id

            when opr_api_const_pkg.OPER_SELECTOR_ORIGINAL then
                get_operation().original_id

            when opr_api_const_pkg.OPER_SELECTOR_MATCHING then
                get_operation().match_id

            when opr_api_const_pkg.OPER_SELECTOR_PARENT_AUTH then
                -- We consider that opr_operation.id = aut_auth.id
                get_auth(i_id => get_operation().id).parent_id
            else
                get_operation().id -- Use current operation by default
        end;

    trc_log_pkg.debug(
        i_text        => 'Going to get operation/authorization [#1] by selector [#2]'
      , i_env_param1  => l_operation_id
      , i_env_param2  => i_selector
    );

    return l_operation_id;
end;

procedure stop_stage is
begin
    raise com_api_error_pkg.e_stop_process_stage;
end;

procedure rollback_stage is
begin
    raise com_api_error_pkg.e_rollback_process_stage;
end;

procedure load_card_bin_info(
    i_party_type          in            com_api_type_pkg.t_dict_value
) is
    l_operation_id                      com_api_type_pkg.t_long_id;
begin
    trc_log_pkg.debug(
        i_text        => 'load_card_bin_info: start i_party_type [#1]'
      , i_env_param1  => i_party_type
    );
    
    l_operation_id := get_operation().id;

    for tab in (select product_id
                     , brand
                     , region
                     , product_type
                     , account_funding_source
                  from opr_bin_info
                 where oper_id = l_operation_id
                   and participant_type = i_party_type)
    loop
        set_param(
            i_name   => 'BIN_PRODUCT_ID'
          , i_value  => tab.product_id
        );
        set_param(
            i_name   => 'MCW_BRAND'
          , i_value  => tab.brand
        );
        set_param(
            i_name   => 'MCW_PRODUCT_TYPE'
          , i_value  => tab.product_type
        );
        set_param(
            i_name   => 'VIS_ACCOUNT_FUNDING_SOURCE'
          , i_value  => tab.account_funding_source
        );
        set_param(
            i_name   => 'BIN_REGION'
          , i_value  => tab.region
        );
    end loop;
end load_card_bin_info;

function get_amounts return com_api_type_pkg.t_amount_by_name_tab
is
begin
    return g_amounts;
end get_amounts;

end opr_api_shared_data_pkg;
/
