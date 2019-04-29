create or replace package body csm_api_dispute_pkg as
/*********************************************************
 *  Case management API  <br />
 *  Created by Kondratyev A.(kondratyev@bpcbt.com)  at 29.11.2016 <br />
 *  Module: csm_api_dispute_pkg <br />
 *  @headcom
 **********************************************************/

procedure add_case(
    i_case_id                 in     com_api_type_pkg.t_long_id
  , i_seqnum                  in     com_api_type_pkg.t_seqnum
  , i_inst_id                 in     com_api_type_pkg.t_inst_id
  , i_merchant_name           in     com_api_type_pkg.t_name
  , i_customer_number         in     com_api_type_pkg.t_name
  , i_dispute_reason          in     com_api_type_pkg.t_dict_value
  , i_oper_date               in     date
  , i_oper_amount             in     com_api_type_pkg.t_money
  , i_oper_currency           in     com_api_type_pkg.t_curr_code
  , i_dispute_id              in     com_api_type_pkg.t_long_id
  , i_dispute_progress        in     com_api_type_pkg.t_dict_value
  , i_write_off_amount        in     com_api_type_pkg.t_money
  , i_write_off_currency      in     com_api_type_pkg.t_curr_code
  , i_due_date                in     date
  , i_reason_code             in     com_api_type_pkg.t_dict_value
  , i_disputed_amount         in     com_api_type_pkg.t_money
  , i_disputed_currency       in     com_api_type_pkg.t_curr_code
  , i_created_date            in     date
  , i_created_by_user_id      in     com_api_type_pkg.t_short_id
  , i_arn                     in     com_api_type_pkg.t_card_number
  , i_claim_id                in     com_api_type_pkg.t_long_id       default null
  , i_auth_code               in     com_api_type_pkg.t_auth_code
  , i_case_progress           in     com_api_type_pkg.t_dict_value
  , i_acquirer_inst_bin       in     com_api_type_pkg.t_cmid
  , i_transaction_code        in     com_api_type_pkg.t_cmid
  , i_case_source             in     com_api_type_pkg.t_dict_value
  , i_sttl_amount             in     com_api_type_pkg.t_money
  , i_sttl_currency           in     com_api_type_pkg.t_curr_code
  , i_base_amount             in     com_api_type_pkg.t_money
  , i_base_currency           in     com_api_type_pkg.t_curr_code
  , i_hide_date               in     date
  , i_unhide_date             in     date
  , i_team_id                 in     com_api_type_pkg.t_tiny_id
  , i_card_number             in     com_api_type_pkg.t_card_number
  , i_original_id             in     com_api_type_pkg.t_long_id
)
is
    l_case_id          com_api_type_pkg.t_long_id;
    l_team_id          com_api_type_pkg.t_tiny_id  := nvl(i_team_id, csm_api_const_pkg.CASE_CHARGEBACK_TEAM);

    l_sysdate          date;
    l_base_currency    com_api_type_pkg.t_curr_code;
    l_base_amount      com_api_type_pkg.t_money;
    l_base_rate_type   com_api_type_pkg.t_dict_value;
begin
    l_sysdate  := com_api_sttl_day_pkg.get_sysdate;

    -- Need that appl_id, case_id and claim_id is different numbers.
    if i_case_id is null then
        l_case_id  := com_api_id_pkg.get_id(app_application_seq.nextval, l_sysdate);
    else
        l_case_id := i_case_id;
    end if;

    -- Calculate base_amount
    if i_base_amount is null or i_base_currency is null then
        l_base_currency  := set_ui_value_pkg.get_inst_param_v(
                                i_param_name => 'NATIONAL_CURRENCY'
                              , i_inst_id    => i_inst_id
                              , i_data_type  => com_api_const_pkg.DATA_TYPE_CHAR
                            );
        l_base_rate_type := set_ui_value_pkg.get_inst_param_v(
                                i_param_name => dsp_api_const_pkg.DISPUTE_RATE_TYPE_BASE_PARAM
                              , i_inst_id    => i_inst_id
                              , i_data_type  => com_api_const_pkg.DATA_TYPE_CHAR
                            );
        if l_base_currency is not null and l_base_rate_type is not null then
            l_base_amount := com_api_rate_pkg.convert_amount(
                                 i_src_amount     => i_oper_amount
                               , i_src_currency   => i_oper_currency
                               , i_dst_currency   => l_base_currency
                               , i_rate_type      => l_base_rate_type
                               , i_inst_id        => i_inst_id
                               , i_eff_date       => i_created_date
                               , i_mask_exception => com_api_const_pkg.FALSE
                             );


        else
            l_base_currency := i_base_currency;
            l_base_amount   := i_base_amount;
        end if;
    else
        l_base_currency := i_base_currency;
        l_base_amount   := i_base_amount;
    end if;

    insert into csm_case_vw(
        id
      , inst_id
      , merchant_name
      , customer_number
      , dispute_reason
      , oper_date
      , oper_amount
      , oper_currency
      , dispute_id
      , dispute_progress
      , write_off_amount
      , write_off_currency
      , due_date
      , reason_code
      , disputed_amount
      , disputed_currency
      , created_date
      , created_by_user_id
      , arn
      , claim_id
      , auth_code
      , case_progress
      , acquirer_inst_bin
      , transaction_code
      , case_source
      , sttl_amount
      , sttl_currency
      , base_amount
      , base_currency
      , hide_date
      , unhide_date
      , team_id
      , original_id
    ) values (
        l_case_id
      , i_inst_id
      , i_merchant_name
      , i_customer_number
      , i_dispute_reason
      , i_oper_date
      , i_oper_amount
      , i_oper_currency
      , i_dispute_id
      , i_dispute_progress
      , i_write_off_amount
      , i_write_off_currency
      , i_due_date
      , i_reason_code
      , i_disputed_amount
      , i_disputed_currency
      , i_created_date
      , i_created_by_user_id
      , i_arn
      , i_claim_id
      , i_auth_code
      , i_case_progress
      , i_acquirer_inst_bin
      , i_transaction_code
      , i_case_source
      , i_sttl_amount
      , i_sttl_currency
      , l_base_amount
      , l_base_currency
      , i_hide_date
      , i_unhide_date
      , l_team_id
      , i_original_id
    );

    if i_card_number is not null then
        insert into csm_card(
            id
          , card_number
        ) values (
            l_case_id
          , iss_api_token_pkg.encode_card_number(i_card_number => i_card_number)
        );
    end if;
end add_case;

-- Add case
procedure add (
    i_inst_id                 in     com_api_type_pkg.t_inst_id
  , i_card_number             in     com_api_type_pkg.t_card_number
  , i_merchant_number         in     com_api_type_pkg.t_merchant_number
  , i_msg_type                in     com_api_type_pkg.t_dict_value
  , i_oper_id                 in     com_api_type_pkg.t_long_id
  , i_original_id             in     com_api_type_pkg.t_long_id
  , i_dispute_id              in     com_api_type_pkg.t_long_id
  , i_dispute_amount          in     com_api_type_pkg.t_money         default null
  , i_dispute_currency        in     com_api_type_pkg.t_curr_code     default null
)
is
    l_sysdate                       date;
    l_user_id                       com_api_type_pkg.t_short_id;
    l_count                         com_api_type_pkg.t_medium_id;
    l_case_id                       com_api_type_pkg.t_long_id;
    l_seqnum                        com_api_type_pkg.t_tiny_id;
    l_flow_id                       com_api_type_pkg.t_tiny_id;
    l_agent_id                      com_api_type_pkg.t_agent_id;
    l_customer_type                 com_api_type_pkg.t_dict_value;
    l_split_hash                    com_api_type_pkg.t_tiny_id;
    l_customer_number               com_api_type_pkg.t_name;
    l_oper_date                     date;
    l_oper_amount                   com_api_type_pkg.t_money;
    l_oper_currency                 com_api_type_pkg.t_curr_code;
    l_inst_id                       com_api_type_pkg.t_inst_id;
    l_merchant_name                 com_api_type_pkg.t_name;
    l_arn                           com_api_type_pkg.t_card_number;
    l_auth_code                     com_api_type_pkg.t_auth_code;
    l_acquirer_inst_bin             com_api_type_pkg.t_cmid;
    l_card_network_id               com_api_type_pkg.t_network_id;
    l_oper_id                       com_api_type_pkg.t_long_id;
    l_transaction_code              com_api_type_pkg.t_cmid;

    l_old_appl_status               com_api_type_pkg.t_dict_value;
    l_new_appl_status               com_api_type_pkg.t_dict_value;
    l_old_reject_code               com_api_type_pkg.t_dict_value;
    l_new_reject_code               com_api_type_pkg.t_dict_value;
    l_operation                     opr_api_type_pkg.t_oper_rec;
begin
    l_sysdate := com_api_sttl_day_pkg.get_sysdate;
    l_user_id := com_ui_user_env_pkg.get_user_id;

    select count(*)
      into l_count
      from app_application_vw a
         , csm_case_vw c
     where c.dispute_id = i_dispute_id
       and c.id         = a.id;

    if l_count = 0
       and i_dispute_id is null
       and i_msg_type in (opr_api_const_pkg.MESSAGE_TYPE_CHARGEBACK
                        , opr_api_const_pkg.MESSAGE_TYPE_RETRIEVAL_REQUEST)
    then

        insert into csm_unpaired_item (
            id
          , is_unpaired_item
        ) values (
            i_oper_id
          , com_api_type_pkg.TRUE
        );

    elsif l_count = 0
          and i_dispute_id is not null
    then
        begin
            select case
                       when com_api_array_pkg.is_element_in_array(
                                i_array_id     => opr_api_const_pkg.STTL_TYPE_ISS_ARRAY_ID
                              , i_elem_value   => o.sttl_type
                            ) = com_api_const_pkg.TRUE
                       then app_api_const_pkg.FLOW_ID_ISS_DISPUTE_INTERNTNL

                       when com_api_array_pkg.is_element_in_array(
                                i_array_id     => opr_api_const_pkg.STTL_TYPE_ACQ_ARRAY_ID
                              , i_elem_value   => o.sttl_type
                            ) = com_api_const_pkg.TRUE
                       then app_api_const_pkg.FLOW_ID_ACQ_DISPUTE_INTERNTNL
                   end as flow_id
                 , o.oper_date
                 , o.oper_amount
                 , o.oper_currency
                 , case when com_api_array_pkg.is_element_in_array(
                                 i_array_id     => opr_api_const_pkg.STTL_TYPE_ISS_ARRAY_ID
                               , i_elem_value   => o.sttl_type
                             ) = com_api_const_pkg.TRUE
                        then p.card_inst_id
                        when com_api_array_pkg.is_element_in_array(
                                 i_array_id     => opr_api_const_pkg.STTL_TYPE_ACQ_ARRAY_ID
                               , i_elem_value   => o.sttl_type
                             ) = com_api_const_pkg.TRUE
                        then a.inst_id
                   end as inst_id
                 , p.auth_code
                 , o.acq_inst_bin
                 , p.card_network_id
                 , o.id
                 , coalesce(mf.de031, vf.arn, af.arn) as arn
                 , coalesce(mf.de024, vf.trans_code, af.func_code) as transaction_code
              into l_flow_id
                 , l_oper_date
                 , l_oper_amount
                 , l_oper_currency
                 , l_inst_id
                 , l_auth_code
                 , l_acquirer_inst_bin
                 , l_card_network_id
                 , l_oper_id
                 , l_arn
                 , l_transaction_code
              from opr_operation_vw o
                 , opr_participant_vw p
                 , opr_participant_vw a
                 , mcw_fin mf
                 , vis_fin_message vf
                 , amx_fin_message af
             where o.id               = i_original_id
               and o.dispute_id+0     = i_dispute_id
               and p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
               and p.oper_id          = o.id
               and a.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
               and a.oper_id          = o.id
               and mf.id(+)           = o.id
               and vf.id(+)           = o.id
               and af.id(+)           = o.id;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error        => 'OPERATION_NOT_FOUND'
                  , i_env_param1   => i_dispute_id
                  , i_env_param2   => i_inst_id
                );
        end;

        opr_api_operation_pkg.get_operation(
            i_oper_id   => i_oper_id
          , o_operation => l_operation
        );

        begin
            select a.agent_id
                 , c.entity_type
                 , a.split_hash
                 , c.customer_number
              into l_agent_id
                 , l_customer_type
                 , l_split_hash
                 , l_customer_number
              from prd_customer c
                 , acc_account a
                 , iss_card card
                 , acc_account_object ao
             where card.id          = iss_api_card_pkg.get_card_id(i_card_number => i_card_number)
               and card.id          = ao.object_id
               and ao.entity_type   = iss_api_const_pkg.ENTITY_TYPE_CARD
               and c.id             = card.customer_id
               and a.id             = ao.account_id;
        exception
            when no_data_found then
                begin
                    select c.entity_type
                         , m.split_hash
                         , c.customer_number
                         , m.merchant_name
                         , cn.agent_id
                      into l_customer_type
                         , l_split_hash
                         , l_customer_number
                         , l_merchant_name
                         , l_agent_id
                      from prd_customer c
                         , acq_merchant m
                         , prd_contract cn
                     where m.merchant_number = trim(i_merchant_number)
                       and m.inst_id         = nvl(i_inst_id, l_inst_id)
                       and m.contract_id     = cn.id
                       and c.id              = cn.customer_id;
                exception
                    when no_data_found then
                        if i_merchant_number is null then
                            com_api_error_pkg.raise_error(
                                i_error        => 'CARD_IS_NOT_FOUND'
                              , i_env_param1   => i_card_number
                              , i_env_param2   => nvl(i_inst_id, l_inst_id)
                            );
                        else
                            com_api_error_pkg.raise_error(
                                i_error        => 'MERCHANT_NOT_FOUND'
                              , i_env_param2   => i_merchant_number
                              , i_env_param3   => nvl(i_inst_id, l_inst_id)
                            );
                        end if;
                end;
        end;

        app_ui_application_pkg.add_application(
            io_appl_id             => l_case_id
          , o_seqnum               => l_seqnum
          , i_appl_type            => app_api_const_pkg.APPL_TYPE_DISPUTE
          , i_appl_number          => null
          , i_flow_id              => l_flow_id
          , i_inst_id              => nvl(i_inst_id, l_inst_id)
          , i_agent_id             => l_agent_id
          , i_appl_status          => app_api_const_pkg.APPL_STATUS_PENDING
          , i_session_file_id      => null
          , i_file_rec_num         => null
          , i_customer_type        => l_customer_type
          , i_split_hash           => l_split_hash
        );

        csm_api_dispute_pkg.add_case(
            i_case_id              => l_case_id
          , i_seqnum               => l_seqnum
          , i_inst_id              => nvl(i_inst_id, l_inst_id)
          , i_merchant_name        => l_merchant_name
          , i_customer_number      => l_customer_number
          , i_dispute_reason       => csm_api_const_pkg.DISPUTE_REASON_DISCLAIMED
          , i_oper_date            => l_oper_date
          , i_oper_amount          => l_oper_amount
          , i_oper_currency        => l_oper_currency
          , i_dispute_id           => i_dispute_id
          , i_dispute_progress     => null
          , i_write_off_amount     => null
          , i_write_off_currency   => null
          , i_due_date             => null
          , i_reason_code          => l_operation.oper_reason
          , i_disputed_amount      => case
                                          when l_flow_id in (app_api_const_pkg.FLOW_ID_ACQ_DISPUTE_DOMESTIC, app_api_const_pkg.FLOW_ID_ACQ_DISPUTE_INTERNTNL)
                                              then l_operation.oper_amount
                                          when l_flow_id in (app_api_const_pkg.FLOW_ID_ISS_DISPUTE_DOMESTIC, app_api_const_pkg.FLOW_ID_ISS_DISPUTE_INTERNTNL)
                                              then i_dispute_amount
                                          else
                                              l_oper_amount
                                      end
          , i_disputed_currency    => case
                                          when l_flow_id in (app_api_const_pkg.FLOW_ID_ACQ_DISPUTE_DOMESTIC, app_api_const_pkg.FLOW_ID_ACQ_DISPUTE_INTERNTNL)
                                              then l_operation.oper_currency
                                          when l_flow_id in (app_api_const_pkg.FLOW_ID_ISS_DISPUTE_DOMESTIC, app_api_const_pkg.FLOW_ID_ISS_DISPUTE_INTERNTNL)
                                              then i_dispute_currency
                                          else
                                              l_oper_currency
                                      end
          , i_created_date         => l_sysdate
          , i_created_by_user_id   => l_user_id
          , i_arn                  => l_arn
          , i_claim_id             => null
          , i_auth_code            => l_auth_code
          , i_case_progress        => null
          , i_acquirer_inst_bin    => l_acquirer_inst_bin
          , i_transaction_code     => l_transaction_code
          , i_case_source          => csm_api_const_pkg.CASE_SOURCE_INCOMING_FILE
          , i_sttl_amount          => case
                                          when l_flow_id in (app_api_const_pkg.FLOW_ID_ACQ_DISPUTE_DOMESTIC, app_api_const_pkg.FLOW_ID_ACQ_DISPUTE_INTERNTNL)
                                              then l_operation.sttl_amount
                                          when l_flow_id in (app_api_const_pkg.FLOW_ID_ISS_DISPUTE_DOMESTIC, app_api_const_pkg.FLOW_ID_ISS_DISPUTE_INTERNTNL)
                                              then null
                                          else
                                              l_operation.sttl_amount
                                      end
          , i_sttl_currency        => case
                                          when l_flow_id in (app_api_const_pkg.FLOW_ID_ACQ_DISPUTE_DOMESTIC, app_api_const_pkg.FLOW_ID_ACQ_DISPUTE_INTERNTNL)
                                              then l_operation.sttl_currency
                                          when l_flow_id in (app_api_const_pkg.FLOW_ID_ISS_DISPUTE_DOMESTIC, app_api_const_pkg.FLOW_ID_ISS_DISPUTE_INTERNTNL)
                                              then null
                                          else
                                              l_operation.sttl_currency
                                      end
          , i_base_amount          => null
          , i_base_currency        => null
          , i_hide_date            => null
          , i_unhide_date          => null
          , i_team_id              => null
          , i_card_number          => i_card_number
          , i_original_id          => i_original_id
        );

        select a.appl_status
             , a.reject_code
          into l_old_appl_status
             , l_old_reject_code
          from app_application a
         where a.id = l_case_id;

        l_new_appl_status := app_api_const_pkg.APPL_STATUS_PENDING;
        l_new_reject_code := app_api_const_pkg.CASE_RESOLUTION_UNRESOLVED;

        app_ui_application_pkg.modify_application(
            i_appl_id              => l_case_id
          , io_seqnum              => l_seqnum
          , i_appl_status          => l_new_appl_status
          , i_resp_sess_file_id    => null
          , i_comments             => null
          , i_reject_code          => l_new_reject_code
        );

        -- Add history
        add_history(
            i_case_id         => l_case_id
          , i_action          => csm_api_const_pkg.CASE_ACTION_CREATE_LABEL
          , i_event_type      => dsp_api_const_pkg.EVENT_AUTOM_DISPUTE_CASE_REG
          , i_new_appl_status => l_new_appl_status
          , i_old_appl_status => l_old_appl_status
          , i_new_reject_code => l_new_reject_code
          , i_old_reject_code => l_old_reject_code
          , i_env_param1      => l_case_id
        );
    end if;
end add;

function get_card_category(
    i_case_id                 in     com_api_type_pkg.t_long_id
  , i_mask_error              in     com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_tiny_id  -- Return 1 - Visa, 2 - MasterCard, 3 - Maestro, else return null.
is
    l_result             com_api_type_pkg.t_tiny_id := csm_api_const_pkg.CARD_CATEGORY_UNSUPPORTED;
    l_card_number        com_api_type_pkg.t_card_number;
    l_card_inst_id       com_api_type_pkg.t_tiny_id;
    l_card_network_id    com_api_type_pkg.t_tiny_id;
    l_card_type          com_api_type_pkg.t_tiny_id;
    l_card_country       com_api_type_pkg.t_curr_code;
    l_dummy              com_api_type_pkg.t_long_id;
begin
    begin
        select card_number
          into l_card_number
          from csm_card
         where id = i_case_id;
    exception
        when no_data_found then
            if i_mask_error = com_api_const_pkg.FALSE then
                com_api_error_pkg.raise_error(
                    i_error        => 'CASE_CARD_NOT_FOUND'
                  , i_env_param1   => i_case_id
                );
            else
                trc_log_pkg.debug(
                    i_text => 'Case [#1] not found '
                  , i_env_param1   => i_case_id
                );
            end if;
    end;

    if l_card_number is not null then
        iss_api_bin_pkg.get_bin_info(
            i_card_number      => l_card_number
          , o_card_inst_id     => l_card_inst_id
          , o_card_network_id  => l_card_network_id
          , o_card_type        => l_card_type
          , o_card_country     => l_card_country
          , i_raise_error      => com_api_type_pkg.boolean_not(i_mask_error)
        );

        if l_card_network_id is null then
            net_api_bin_pkg.get_bin_info(
                i_card_number     => l_card_number
              , io_iss_inst_id    => l_dummy
              , o_iss_network_id  => l_dummy
              , o_iss_host_id     => l_dummy
              , o_card_type_id    => l_card_type
              , o_card_country    => l_card_country
              , o_card_inst_id    => l_card_inst_id
              , o_card_network_id => l_card_network_id
              , o_pan_length      => l_dummy
              , i_raise_error      => com_api_type_pkg.boolean_not(i_mask_error)
            );
        end if;

        case l_card_network_id
            when mcw_api_const_pkg.MCW_NETWORK_ID then
                if l_card_type = mcw_api_const_pkg.QR_MAESTRO_CARD_TYPE then
                    l_result := csm_api_const_pkg.CARD_CATEGORY_MAESTRO;
                else
                    l_result := csm_api_const_pkg.CARD_CATEGORY_MASTERCARD;
                end if;

            when cmp_api_const_pkg.VISA_NETWORK   then
                l_result := csm_api_const_pkg.CARD_CATEGORY_VISA;

            else
                if i_mask_error = com_api_const_pkg.TRUE then
                    trc_log_pkg.debug(
                        i_text       => 'Card network is not found'
                      , i_env_param1 => iss_api_card_pkg.get_card_mask(l_card_number)
                    );
                else
                    com_api_error_pkg.raise_error (
                        i_error             => 'UNKNOWN_ISSUING_NETWORK'
                      , i_env_param1        => iss_api_card_pkg.get_card_mask(l_card_number)
                    );
                end if;
        end case;
    end if;

    trc_log_pkg.debug(
        i_text => 'Card category ' || l_result
    );
    return l_result;
end get_card_category;

function check_due_date(
    i_case_id                 in     com_api_type_pkg.t_long_id
  , i_msg_type                in     com_api_type_pkg.t_dict_value
  , i_reason_code             in     com_api_type_pkg.t_dict_value    default null
  , i_is_manual               in     com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
) return date
is
    l_card_category      com_api_type_pkg.t_tiny_id;
    l_standard_id        com_api_type_pkg.t_tiny_id;
    l_due_date           date;
    l_init_date          date default com_api_sttl_day_pkg.get_sysdate;
    l_oper_id            com_api_type_pkg.t_long_id;
    l_usage_code         com_api_type_pkg.t_byte_char;
    l_old_appl_status    com_api_type_pkg.t_dict_value;
    l_old_reject_code    com_api_type_pkg.t_dict_value;
begin
    trc_log_pkg.debug('csm_api_dispute_pkg.check_due_date: i_case_id=' || i_case_id
                     || ' i_msg_type=' || i_msg_type || ' i_reason_code=' || i_reason_code);

    select a.appl_status
         , a.reject_code
      into l_old_appl_status
         , l_old_reject_code
      from app_application a
     where a.id = i_case_id;

    begin
        l_card_category := csm_api_dispute_pkg.get_card_category(
                               i_case_id => i_case_id
                           );
    exception
        when com_api_error_pkg.e_application_error then
            if com_api_error_pkg.get_last_error not in ('CASE_CARD_NOT_FOUND') then
                raise;
            else
                l_card_category := null;
            end if;
    end;

    -- search operation id
    select min(op.id)
      into l_oper_id
      from csm_case c
         , opr_operation op
     where c.id  = i_case_id
       and op.id = c.original_id;

    if l_oper_id is null then
        com_api_error_pkg.raise_error(
            i_error         => 'OPERATION_NOT_FOUND'
          , i_env_param1    => i_case_id
        );
    end if;

    trc_log_pkg.debug('csm_api_dispute_pkg.check_due_date: l_oper_id=' || l_oper_id
                    || ' l_card_category=' || l_card_category);

    begin
        if l_card_category in (csm_api_const_pkg.CARD_CATEGORY_MASTERCARD
                             , csm_api_const_pkg.CARD_CATEGORY_MAESTRO) then
            l_standard_id := mcw_api_const_pkg.MCW_STANDARD_ID;
            -- process l_init_date, if not found, then exception
            if i_msg_type = opr_api_const_pkg.MESSAGE_TYPE_CHARGEBACK then
                select trunc(p0158_5)
                  into l_init_date
                  from mcw_fin
                 where id = l_oper_id;
            elsif i_msg_type = opr_api_const_pkg.MESSAGE_TYPE_FRAUD_REPORT then
                select trunc(de012)
                  into l_init_date
                  from mcw_fin
                 where id = l_oper_id;
            end if;
        elsif l_card_category = csm_api_const_pkg.CARD_CATEGORY_VISA   then
            l_standard_id := vis_api_const_pkg.VISA_BASEII_STANDARD;
            if i_msg_type = opr_api_const_pkg.MESSAGE_TYPE_CHARGEBACK then
                select to_date(central_proc_date, 'YDDD')
                     , usage_code
                  into l_init_date
                     , l_usage_code
                  from vis_fin_message
                 where id = l_oper_id;
            elsif i_msg_type = opr_api_const_pkg.MESSAGE_TYPE_FRAUD_REPORT then
                select trunc(oper_date)
                     , usage_code
                  into l_init_date
                     , l_usage_code
                  from vis_fin_message
                 where id = l_oper_id;
            end if;
        end if;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error         => 'ORIG_DATE_NOT_FOUND'
              , i_env_param1    => l_oper_id
            );
    end;

    if l_init_date is null then
        com_api_error_pkg.raise_error(
            i_error         => 'ORIG_DATE_NOT_FOUND'
          , i_env_param1    => l_oper_id
        );
    end if;

    if l_standard_id is not null then
        l_due_date := dsp_ui_due_date_limit_pkg.get_due_date(
                          i_message_type => i_msg_type
                        , i_oper_date    => l_init_date
                        , i_reason_code  => i_reason_code
                        , i_standard_id  => l_standard_id
                        , i_is_manual    => i_is_manual
                        , i_usage_code   => case when l_usage_code = '9' then l_usage_code end
                      );
    end if;

    trc_log_pkg.debug('csm_api_dispute_pkg.check_due_date: l_due_date=' || l_due_date);

    add_history(
        i_case_id          => i_case_id
      , i_action           => case i_msg_type
                                  when opr_api_const_pkg.MESSAGE_TYPE_CHARGEBACK
                                      then csm_api_const_pkg.CASE_ACTION_CH_DD_CHBCK_LABEL
                                  when opr_api_const_pkg.MESSAGE_TYPE_FRAUD_REPORT
                                      then csm_api_const_pkg.CASE_ACTION_CH_DD_FRAUD_LABEL
                              end
      , i_new_appl_status  => l_old_appl_status
      , i_old_appl_status  => l_old_appl_status
      , i_new_reject_code  => l_old_reject_code
      , i_old_reject_code  => l_old_reject_code
      , i_env_param1       => l_due_date
    );

    return l_due_date;
end check_due_date;

function get_reason_lov_id(
    i_case_id                 in     com_api_type_pkg.t_long_id
  , i_case_progress           in     com_api_type_pkg.t_dict_value    default null
) return com_api_type_pkg.t_tiny_id
is
    l_card_category         com_api_type_pkg.t_tiny_id;
    l_lov_id                com_api_type_pkg.t_tiny_id;
begin
    begin
        l_card_category := csm_api_dispute_pkg.get_card_category(
                               i_case_id => i_case_id
                           );
    exception
        when com_api_error_pkg.e_application_error then
            if com_api_error_pkg.get_last_error not in ('CASE_CARD_NOT_FOUND') then
                raise;
            else
                l_card_category := null;
            end if;
    end;

    if nvl(i_case_progress,csm_api_const_pkg.CASE_PROGRESS_CHARGEBACK) = csm_api_const_pkg.CASE_PROGRESS_CHARGEBACK then
        l_lov_id :=
        case l_card_category
            when csm_api_const_pkg.CARD_CATEGORY_MASTERCARD then mcw_api_const_pkg.LOV_ID_MC_FIRST_CHARGEBACK
            when csm_api_const_pkg.CARD_CATEGORY_MAESTRO    then mcw_api_const_pkg.LOV_ID_MC_FIRST_CHARGEBACK
            when csm_api_const_pkg.CARD_CATEGORY_VISA       then vis_api_const_pkg.LOV_ID_VIS_DISPUTE_CONDITIONS
            else null
        end;
    elsif i_case_progress = csm_api_const_pkg.CASE_PROGRESS_REPRESENTMENT then
        l_lov_id :=
        case l_card_category
            when csm_api_const_pkg.CARD_CATEGORY_MAESTRO    then mcw_api_const_pkg.LOV_ID_MAE_SECOND_PRESENT
            else null
        end;
    end if;

    return l_lov_id;
end get_reason_lov_id;

procedure get_case_by_operation(
    i_oper_id                 in     com_api_type_pkg.t_long_id
  , i_case_source             in     com_api_type_pkg.t_dict_value    default null
  , i_mask_error              in     com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
  , o_case_id                    out com_api_type_pkg.t_long_id
  , o_seqnum                     out com_api_type_pkg.t_tiny_id
) is
    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_case_by_operation: ';
begin

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'Started with params - i_oper_id [' || i_oper_id
               || '], i_case_source [' || i_case_source
               || '], i_mask_error [' || i_mask_error
               || ']'
    );

    select ca.id
         , a.seqnum
      into o_case_id
         , o_seqnum
      from opr_operation o
         , csm_case ca
         , app_application a
     where o.id           = i_oper_id
       and ca.dispute_id  = o.dispute_id
       and ca.case_source = nvl(i_case_source, ca.case_source)
       and a.id           = ca.id
    ;

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'Finish success'
    );
exception
    when no_data_found then
        if i_mask_error = com_api_const_pkg.TRUE then
            trc_log_pkg.debug(
                    i_text => LOG_PREFIX || 'Dispute application not found'
                );
        else
            com_api_error_pkg.raise_error(
                i_error => 'NO_DISPUTE_FOUND'
            );
        end if;
    when others then
        if com_api_error_pkg.is_application_error(code => sqlcode) = com_api_const_pkg.TRUE then
            if i_mask_error = com_api_const_pkg.TRUE then
                null;
            else
                raise;
            end if;
        elsif com_api_error_pkg.is_fatal_error(code => sqlcode) = com_api_const_pkg.TRUE then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;

end get_case_by_operation;

procedure change_case_status(
    i_dispute_id              in     com_api_type_pkg.t_long_id
  , i_reason_code             in     com_api_type_pkg.t_dict_value
) is
    LOG_PREFIX      constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.change_case_status: ';
    l_appl_id       com_api_type_pkg.t_long_id;
    l_seqnum        com_api_type_pkg.t_tiny_id;
    l_reason_code   com_api_type_pkg.t_dict_value;
    l_application   app_api_type_pkg.t_application_rec;

    l_comment           com_api_type_pkg.t_text;
    l_new_appl_status   com_api_type_pkg.t_dict_value;
    l_new_reject_code   com_api_type_pkg.t_dict_value;
    l_event_type        com_api_type_pkg.t_dict_value;
begin
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || ' Started with params - i_dispute_id [' || i_dispute_id || ']' || ' - i_reason_code [' || i_reason_code || ']'
    );

    l_reason_code := i_reason_code;

    if i_dispute_id is not null then
        begin
            select c.id
                 , a.seqnum
              into l_appl_id
                 , l_seqnum
              from csm_case c
                 , app_application a
             where c.dispute_id = i_dispute_id
               and c.id         = a.id
               and rownum       = 1;
            exception
                when no_data_found then
                    l_appl_id := null;
                    l_seqnum := null;
                    trc_log_pkg.debug(
                        i_text          => LOG_PREFIX || ' Not found application by dispute_id'
                      , i_env_param1    => i_dispute_id
                    );
        end;
    end if;

    if l_appl_id is not null then
        l_application :=
            app_api_application_pkg.get_application(
                i_appl_id     => l_appl_id
              , i_raise_error => com_api_const_pkg.TRUE
            );
        app_api_flow_transition_pkg.get_new_transition_data(
            i_flow_id          => l_application.flow_id
          , i_old_appl_status  => l_application.appl_status
          , i_old_reject_code  => l_application.reject_code
          , i_reason_code      => l_reason_code
          , io_new_appl_status => l_new_appl_status
          , io_new_reject_code => l_new_reject_code
          , io_event_type      => l_event_type
        );
        l_comment :=
            csm_api_utl_pkg.get_case_comment(
                i_action      => csm_api_const_pkg.CASE_ACTION_STATUS_CHNG_LABEL
              , i_description => '"' || l_new_appl_status || '";"' || l_new_reject_code || '";'
            );

        app_ui_application_pkg.modify_application(
            i_appl_id                => l_appl_id
          , io_seqnum                => l_seqnum
          , i_reason_code            => l_reason_code
          , i_comments               => l_comment
          , i_change_action          => csm_api_const_pkg.CASE_ACTION_STATUS_CHNG_LABEL
          , i_event_type             => null
        );

        trc_log_pkg.debug(
            i_text    => LOG_PREFIX || ' Modify application status is completed'
        );
    else
        trc_log_pkg.debug(
            i_text    => LOG_PREFIX || ' Application is null'
        );
    end if;

end change_case_status;

procedure set_due_date(
    i_case_id                 in     com_api_type_pkg.t_long_id
  , i_due_date                in     date
  , io_seqnum                 in out com_api_type_pkg.t_seqnum
) is
    l_old_appl_status    com_api_type_pkg.t_dict_value;
    l_old_reject_code    com_api_type_pkg.t_dict_value;
begin
    select a.appl_status
         , a.reject_code
      into l_old_appl_status
         , l_old_reject_code
      from app_application a
     where a.id = i_case_id;

    update csm_case_vw
       set due_date = i_due_date
     where id       = i_case_id;

    update app_application_vw
       set seqnum   = nvl(io_seqnum, seqnum)
     where id       = i_case_id;

    io_seqnum := io_seqnum + 1;

    add_history(
        i_case_id          => i_case_id
      , i_action           => csm_api_const_pkg.CASE_ACTION_SET_DUE_DT_LABEL
      , i_new_appl_status  => l_old_appl_status
      , i_old_appl_status  => l_old_appl_status
      , i_new_reject_code  => l_old_reject_code
      , i_old_reject_code  => l_old_reject_code
      , i_env_param1       => i_due_date
    );
end set_due_date;

procedure get_case(
    i_case_id                 in     com_api_type_pkg.t_long_id
  , o_case_rec                   out csm_api_type_pkg.t_csm_case_rec
  , i_mask_error              in     com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
) is
    LOG_PREFIX      constant com_api_type_pkg.t_name    := lower($$PLSQL_UNIT) || '.get_case: ';
begin
    select c.id
         , a.seqnum
         , c.inst_id
         , c.merchant_name
         , c.customer_number
         , c.dispute_reason
         , c.oper_date
         , c.oper_amount
         , c.oper_currency
         , c.dispute_id
         , c.dispute_progress
         , c.write_off_amount
         , c.write_off_currency
         , c.due_date
         , c.reason_code
         , c.disputed_amount
         , c.disputed_currency
         , c.created_date
         , c.created_by_user_id
         , c.arn
         , c.claim_id
         , c.auth_code
         , c.case_progress
         , c.acquirer_inst_bin
         , c.transaction_code
         , c.case_source
         , c.sttl_amount
         , c.sttl_currency
         , c.base_amount
         , c.base_currency
         , c.hide_date
         , c.unhide_date
         , c.team_id
         , iss_api_card_pkg.get_card_id (
               i_card_number => iss_api_token_pkg.decode_card_number(i_card_number => card.card_number)
           ) as card_id
         , case
               when p.merchant_id is not null
               then p.merchant_id
               else (select max(m.id)
                       from acq_merchant m
                      where m.merchant_number = o.merchant_number
                        and m.inst_id         = c.inst_id
                    )
           end as merchant_id
         , a.is_visible
         , a.appl_status as case_status
         , a.reject_code as case_resolution
         , a.flow_id
         , o.is_reversal
         , a.split_hash
         , c.original_id
      into o_case_rec
      from csm_case c
         , app_application a
         , csm_card card
         , opr_operation o
         , opr_participant p
     where c.id                  = i_case_id
       and a.id                  = c.id
       and card.id(+)            = c.id
       and o.id(+)               = c.original_id
       and p.oper_id(+)          = o.id
       and p.participant_type(+) = com_api_const_pkg.PARTICIPANT_ACQUIRER;
exception
    when no_data_found then
       if i_mask_error = com_api_const_pkg.TRUE then
            trc_log_pkg.debug(
                i_text       => LOG_PREFIX || 'Dispute not found case id [#1]'
              , i_env_param1 => i_case_id
            );
       else
            com_api_error_pkg.raise_error(
                i_error => 'NO_DISPUTE_FOUND'
            );
       end if;
end get_case;

procedure get_case(
    i_dispute_id              in     com_api_type_pkg.t_long_id
  , o_case_rec                   out csm_api_type_pkg.t_csm_case_rec
  , i_mask_error              in     com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
) is
    LOG_PREFIX      constant com_api_type_pkg.t_name    := lower($$PLSQL_UNIT) || '.get_case: ';
    l_case_id       com_api_type_pkg.t_long_id;
begin
    trc_log_pkg.debug(
        i_text          => LOG_PREFIX || 'Start with param dispute_id [#1] mask_error [#2]'
      , i_env_param1    => i_dispute_id
      , i_env_param2    => i_mask_error
    );

    -- one case - one dispute
    select c.id
      into l_case_id
      from csm_case c
     where c.dispute_id = i_dispute_id;

    get_case(
        i_case_id    => l_case_id
      , o_case_rec   => o_case_rec
      , i_mask_error => i_mask_error
    );
exception
    when no_data_found then
       if i_mask_error = com_api_const_pkg.TRUE then
            trc_log_pkg.debug(
                i_text       => LOG_PREFIX || 'Dispute not found dispute id [#1]'
              , i_env_param1 => i_dispute_id
            );
       else
            com_api_error_pkg.raise_error(
                i_error => 'NO_DISPUTE_FOUND'
            );
       end if;
end get_case;

procedure change_case_progress(
    i_case_id                 in     com_api_type_pkg.t_long_id
  , io_seqnum                 in out com_api_type_pkg.t_seqnum
  , i_case_progress           in     com_api_type_pkg.t_dict_value
  , i_reason_code             in     com_api_type_pkg.t_dict_value
  , i_mask_error              in     com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
)
is
    LOG_PREFIX      constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.change_case_progress: ';
    l_case_id                com_api_type_pkg.t_long_id;
    l_old_appl_status        com_api_type_pkg.t_dict_value;
    l_old_reject_code        com_api_type_pkg.t_dict_value;
begin
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'start, i_case_id=' || i_case_id || ' i_case_progress=' || i_case_progress || ' i_reason_code=' || i_reason_code
    );

    select id
      into l_case_id
      from csm_case
     where id = i_case_id;

    select a.appl_status
         , a.reject_code
      into l_old_appl_status
         , l_old_reject_code
      from app_application a
     where a.id = l_case_id;

    update csm_case_vw
       set case_progress = i_case_progress
         , reason_code   = i_reason_code
     where id            = l_case_id;

    update app_application_vw
       set seqnum        = nvl(io_seqnum, seqnum)
     where id            = l_case_id;

    io_seqnum := io_seqnum + 1;

    add_history(
        i_case_id          => i_case_id
      , i_action           => csm_api_const_pkg.CASE_ACTION_SET_PROGR_LABEL
      , i_new_appl_status  => l_old_appl_status
      , i_old_appl_status  => l_old_appl_status
      , i_new_reject_code  => l_old_reject_code
      , i_old_reject_code  => l_old_reject_code
      , i_env_param1       => i_case_progress
      , i_env_param2       => i_reason_code
      , i_mask_error       => i_mask_error
    );

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'end'
    );
exception
    when no_data_found then
        if i_mask_error = com_api_const_pkg.TRUE then
            trc_log_pkg.debug(
                    i_text => LOG_PREFIX || 'Case not found'
                );
        else
            com_api_error_pkg.raise_error(
                i_error      => 'APPLICATION_NOT_FOUND'
              , i_env_param1 => i_case_id
            );
        end if;
    when others then
        if com_api_error_pkg.is_application_error(code => sqlcode) = com_api_const_pkg.TRUE then
            if i_mask_error = com_api_const_pkg.TRUE then
                null;
            else
                raise;
            end if;
        elsif com_api_error_pkg.is_fatal_error(code => sqlcode) = com_api_const_pkg.TRUE then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;
end change_case_progress;

procedure change_case_progress(
    i_dispute_id              in     com_api_type_pkg.t_long_id
  , io_seqnum                 in out com_api_type_pkg.t_seqnum
  , i_case_progress           in     com_api_type_pkg.t_dict_value
  , i_reason_code             in     com_api_type_pkg.t_dict_value
  , i_mask_error              in     com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
) is
    LOG_PREFIX      constant com_api_type_pkg.t_name    := lower($$PLSQL_UNIT) || '.change_case_progress(dispute): ';
    l_cnt                    com_api_type_pkg.t_long_id := 0;
    l_seqnum                 com_api_type_pkg.t_seqnum;
begin
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'start, i_dispute_id=' || i_dispute_id || ' i_case_progress=' || i_case_progress || ' i_reason_code=' || i_reason_code
    );

    for tab in (
        select id
          from csm_case
         where dispute_id = i_dispute_id
    )
    loop
        l_seqnum := io_seqnum;
        change_case_progress(
            i_case_id       => tab.id
          , io_seqnum       => l_seqnum
          , i_case_progress => i_case_progress
          , i_reason_code   => i_reason_code
          , i_mask_error    => i_mask_error
        );
        l_cnt := l_cnt + 1;
    end loop;

    io_seqnum := l_seqnum;

    if l_cnt = 0 then
        if i_mask_error = com_api_const_pkg.TRUE then
            trc_log_pkg.debug(
                i_text => LOG_PREFIX || 'Dispute not found'
            );
        else
            com_api_error_pkg.raise_error(
                i_error => 'NO_DISPUTE_FOUND'
            );
        end if;
    end if;

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'end ' || l_cnt
    );
exception
    when others then
        if com_api_error_pkg.is_application_error(code => sqlcode) = com_api_const_pkg.TRUE then
            if i_mask_error = com_api_const_pkg.TRUE then
                null;
            else
                raise;
            end if;
        elsif com_api_error_pkg.is_fatal_error(code => sqlcode) = com_api_const_pkg.TRUE then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;
end change_case_progress;

function get_progress_lov_id(
    i_case_id                 in     com_api_type_pkg.t_long_id
  , i_flow_id                 in     com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_tiny_id
is
    l_flow_id       com_api_type_pkg.t_tiny_id;
    l_lov_id        com_api_type_pkg.t_tiny_id := null;
    l_case_rec      csm_api_type_pkg.t_csm_case_rec;
begin
    if i_case_id is null and i_flow_id is null then
        return null;
    end if;

    if i_flow_id is not null then
        l_flow_id := i_flow_id;
    else
        get_case(
            i_case_id    => i_case_id
          , o_case_rec   => l_case_rec
          , i_mask_error => com_api_const_pkg.TRUE
        );
        l_flow_id := l_case_rec.flow_id;
    end if;

    if l_flow_id in (app_api_const_pkg.FLOW_ID_ISS_DISPUTE_DOMESTIC, app_api_const_pkg.FLOW_ID_ACQ_DISPUTE_DOMESTIC) then
        l_lov_id := 619;
    elsif l_flow_id in (app_api_const_pkg.FLOW_ID_ISS_DISPUTE_INTERNTNL, app_api_const_pkg.FLOW_ID_ACQ_DISPUTE_INTERNTNL) then
        l_lov_id := 618;
    end if;

    return l_lov_id;
end get_progress_lov_id;

procedure add_history(
    i_case_id                 in     com_api_type_pkg.t_long_id
  , i_action                  in     com_api_type_pkg.t_name
  , i_event_type              in     com_api_type_pkg.t_dict_value   default null
  , i_new_appl_status         in     com_api_type_pkg.t_dict_value
  , i_old_appl_status         in     com_api_type_pkg.t_dict_value
  , i_new_reject_code         in     com_api_type_pkg.t_dict_value
  , i_old_reject_code         in     com_api_type_pkg.t_dict_value
  , i_env_param1              in     com_api_type_pkg.t_name         default null
  , i_env_param2              in     com_api_type_pkg.t_name         default null
  , i_env_param3              in     com_api_type_pkg.t_name         default null
  , i_env_param4              in     com_api_type_pkg.t_name         default null
  , i_mask_error              in     com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
)
is
    LOG_PREFIX      constant com_api_type_pkg.t_name    := lower($$PLSQL_UNIT) || '.add_history: ';
    l_comments      com_api_type_pkg.t_text;
begin
    trc_log_pkg.debug(
        i_text          => LOG_PREFIX
                        || 'Start with params: case_id [#1] action [#2] event_type [#3] appl_status [#4] reject_code [#5'
                        || '] env_param1 [' || i_env_param1
                        || '] env_param2 [' || i_env_param2
                        || '] env_param3 [' || i_env_param3
                        || '] env_param4 [' || i_env_param4
                        || '] mask_error [' || i_mask_error
                        || ']'
      , i_env_param1    => i_case_id
      , i_env_param2    => i_action
      , i_env_param3    => i_event_type
      , i_env_param4    => i_new_appl_status
      , i_env_param5    => i_new_reject_code
    );

    l_comments :=
        csm_api_utl_pkg.get_case_comment(
            i_action      => i_action
          , i_description => '"' || i_env_param1 || '";"' || i_env_param2 || '";"' || i_env_param3 || '";"' || i_env_param4 || '";'
        );

    app_api_history_pkg.add_history (
        i_appl_id         => i_case_id
      , i_action          => nvl(i_event_type, i_action)
      , i_comments        => l_comments
      , i_new_appl_status => i_new_appl_status
      , i_old_appl_status => i_old_appl_status
      , i_new_reject_code => i_new_reject_code
      , i_old_reject_code => i_old_reject_code
    );

exception
    when others then
        if com_api_error_pkg.is_application_error(sqlcode) = com_api_type_pkg.TRUE then
            if nvl(i_mask_error, com_api_type_pkg.FALSE) = com_api_type_pkg.FALSE then
                raise;
            else
                trc_log_pkg.debug(
                    i_text => LOG_PREFIX || ' >> error was masked: '
                                         || com_api_error_pkg.get_last_message()
                );
            end if;
        elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_type_pkg.TRUE then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;

end add_history;

end csm_api_dispute_pkg;
/
drop package csm_api_dispute_pkg
/
