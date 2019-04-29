create or replace package body aup_api_online_pkg is
/************************************************************
* Authorization Online API <br />
* Created by Khougaev A.(khougaev@bpc.ru)  at 08.10.2010  <br />
* Module: AUP_API_ONLINE_PKG <br />
* @headcom
************************************************************/

procedure get_member_info(
    i_originator_inst_id      in     com_api_type_pkg.t_inst_id
  , i_destination_network_id  in     com_api_type_pkg.t_tiny_id
  , i_destination_inst_id     in     com_api_type_pkg.t_inst_id
  , i_participant_type        in     com_api_type_pkg.t_dict_value default null
  , o_originator_member_id       out com_api_type_pkg.t_tiny_id
  , o_destination_member_id      out com_api_type_pkg.t_tiny_id
) is
begin
    begin
        o_originator_member_id :=
            net_api_network_pkg.get_member_id(
                i_inst_id          => i_originator_inst_id
              , i_network_id       => i_destination_network_id
              , i_participant_type => i_participant_type
            );
    exception
        when com_api_error_pkg.e_application_error then
            com_api_error_pkg.raise_error(
                i_error      => 'ORIGINATOR_MEMBER_NOT_FOUND'
              , i_env_param1 => i_destination_inst_id
              , i_env_param2 => i_destination_network_id
            );
        when others then
            com_api_error_pkg.raise_error(
                i_error => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
    end;
        
    begin
        o_destination_member_id :=
            net_api_network_pkg.get_member_id(
                i_inst_id          => i_destination_inst_id
              , i_network_id       => i_destination_network_id
              , i_participant_type => i_participant_type
            );
    exception
        when com_api_error_pkg.e_application_error then
            com_api_error_pkg.raise_error(
                i_error      => 'DESTINATION_MEMBER_NOT_FOUND'
              , i_env_param1 => i_destination_inst_id
              , i_env_param2 => i_destination_network_id
            );
        when others then
            com_api_error_pkg.raise_error(
                i_error => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
    end;
end get_member_info;

procedure get_card_keys (
    i_card_instance_id in com_api_type_pkg.t_medium_id
    , o_des_keys       out com_api_type_pkg.t_des_key_tab
    , o_hmac_keys      out com_api_type_pkg.t_hmac_key_tab
) is
begin
    trc_log_pkg.debug (
        i_text         => 'Request for keys for instance [#1]'
        , i_env_param1 => i_card_instance_id
    );

    select
        ky.lmk_id
        , ky.key_type
        , ky.key_index
        , ky.key_length
        , ky.key_value
        , ky.key_prefix
        , ky.check_value
    bulk collect into
        o_des_keys
    from
        (   select distinct
                e.entity_type
                , e.key_type
                , case e.entity_type
                    when iss_api_const_pkg.ENTITY_TYPE_ISS_BIN then i.bin_id
                    when ost_api_const_pkg.ENTITY_TYPE_INSTITUTION then i.inst_id
                    when ost_api_const_pkg.ENTITY_TYPE_AGENT then i.agent_id
                end object_id
            from
                iss_card_instance i
                , prs_method m
                , prs_key_schema_entity e
            where
                i.id = i_card_instance_id
                and i.perso_method_id = m.id
                and m.key_schema_id = e.key_schema_id
        ) schm
        , sec_des_key ky
    where
        schm.key_type = ky.key_type
        and schm.entity_type = ky.entity_type
        and schm.object_id = ky.object_id
    order by
        ky.key_type
        , ky.key_index;

    select
        ky.lmk_id
        , ky.key_index
        , ky.key_length
        , ky.key_value
    bulk collect into
        o_hmac_keys
    from (
       select distinct
            e.entity_type
            , case e.entity_type
                when iss_api_const_pkg.ENTITY_TYPE_ISS_BIN then i.bin_id
                when ost_api_const_pkg.ENTITY_TYPE_INSTITUTION then i.inst_id
                when ost_api_const_pkg.ENTITY_TYPE_AGENT then i.agent_id
            end object_id
        from
            iss_card_instance i
            , prs_method m
            , prs_key_schema_entity e
        where
            i.id = i_card_instance_id
            and i.perso_method_id = m.id
            and m.key_schema_id = e.key_schema_id
        ) schm
        , sec_hmac_key ky
    where
        schm.entity_type = ky.entity_type
        and schm.object_id = ky.object_id
    order by
        ky.key_index;

    trc_log_pkg.debug (
        i_text         => 'Returning card keys [#1]'
        , i_env_param1 => o_des_keys.count
    );
end get_card_keys;

procedure get_card_resp_code (
    i_host_date                 in date
    , i_pin_presence            in com_api_type_pkg.t_dict_value
    , i_oper_type               in com_api_type_pkg.t_dict_value
    , i_card_instance_id        in com_api_type_pkg.t_medium_id
    , i_card_service_code       in com_api_type_pkg.t_curr_code
    , i_discr_data              in com_api_type_pkg.t_name
    , i_card_data_input_mode    in com_api_type_pkg.t_dict_value
    , i_msg_type                in com_api_type_pkg.t_dict_value
    , i_participant_type        in com_api_type_pkg.t_dict_value
    , o_resp_code               out com_api_type_pkg.t_dict_value
    , o_pvv_tab                 out com_api_type_pkg.t_number_tab
    , o_pin_verify_method       out com_api_type_pkg.t_dict_value
    , o_pvk_index_tab           out com_api_type_pkg.t_number_tab
    , o_pan_length              out com_api_type_pkg.t_tiny_id
    , o_cvv                     out com_api_type_pkg.t_module_code
    , o_cvv2_date_format        out com_api_type_pkg.t_dict_value
    , io_atc                    in out com_api_type_pkg.t_dict_value
    , i_discr_type              in com_api_type_pkg.t_short_id := null
    , o_un_placeholder             out com_api_type_pkg.t_cmid
) is
    l_expir_date            date;
    l_start_date            date;
    l_service_code          com_api_type_pkg.t_curr_code;
    l_perso_method_id       com_api_type_pkg.t_short_id;
    l_atc                   com_api_type_pkg.t_name;
    l_pvv_store_method      com_api_type_pkg.t_dict_value;
    
begin
    trc_log_pkg.debug (
        i_text         => 'get_card_resp_code: i_card_instance_id [#1], i_host_date [#2], '
                       || 'i_pin_presence [#3], i_oper_type [#4], i_card_service_code [#5], i_msg_type [#6]'
        , i_env_param1 => i_card_instance_id
        , i_env_param2 => i_host_date
        , i_env_param3 => i_pin_presence
        , i_env_param4 => i_oper_type
        , i_env_param5 => i_card_service_code
        , i_env_param6 => i_msg_type
    );
    
    o_pvv_tab.delete;
    o_pvk_index_tab.delete;

    begin
        select start_date
             , expir_date
             , service_code
             , pvv
             , pin_verify_method
             , pvk_index
             , resp_code
             , pan_length
             , perso_method_id
             , exp_date_format
             , pvv_store_method
          into l_start_date
             , l_expir_date
             , l_service_code
             , o_pvv_tab(1)
             , o_pin_verify_method
             , o_pvk_index_tab(1)
             , o_resp_code
             , o_pan_length
             , l_perso_method_id
             , o_cvv2_date_format
             , l_pvv_store_method
          from (
                select i.start_date
                     , i.expir_date
                     , m.service_code
                     , d.pvv
                     , m.pin_verify_method
                     , d.pvk_index
                     , min(r.resp_code) keep (dense_rank first order by r.priority nulls last) resp_code
                     , b.pan_length
                     , i.perso_method_id
                     , m.exp_date_format
                     , m.pvv_store_method
                  from iss_card_instance i
                     , iss_card_instance_data d
                     , iss_bin b
                     , prs_method m
                     , aup_card_status_resp r
                 where i.id = i_card_instance_id
                   and d.card_instance_id(+) = i.id
                   and i.perso_method_id = m.id
                   and i.bin_id = b.id
                   and i.inst_id like r.inst_id(+)
                   and i.state like r.card_state(+)
                   and i.status like r.card_status(+)
                   and i_oper_type like r.oper_type(+)
                   and i_pin_presence like r.pin_presence(+)
                   and i_msg_type like r.msg_type(+)
                   and i_participant_type like r.participant_type(+)
                 group by i.start_date
                        , i.expir_date
                        , m.service_code
                        , d.pvv
                        , m.pin_verify_method
                        , d.pvk_index
                        , b.pan_length
                        , i.perso_method_id
                        , m.exp_date_format
                        , m.pvv_store_method
                 order by decode(resp_code, aup_api_const_pkg.RESP_CODE_OK, 0, null, 2, 1)
               )
         where rownum = 1;

        trc_log_pkg.debug('resp_code [' || o_resp_code || '] has been found');

        o_resp_code := cst_api_online_pkg.check_card_expire_date(
            i_oper_type            => i_oper_type
            , i_host_date          => i_host_date
            , i_start_date         => l_start_date
            , i_expir_date         => l_expir_date
            , i_resp_code          => o_resp_code
        );

        if o_resp_code is null then
            o_resp_code := aup_api_const_pkg.RESP_CODE_UNKNOWN_CARD_STATUS;
        elsif nvl(i_card_service_code, l_service_code) != l_service_code then
            o_resp_code := aup_api_const_pkg.RESP_CODE_WRONG_SERVICE_CODE;
        end if;

    exception
        when no_data_found then
            o_resp_code := aup_api_const_pkg.RESP_CODE_UNKNOWN_CARD_STATUS;
    end;

    trc_log_pkg.debug('resp_code has been set to [' || o_resp_code || '] after checks');

    begin
        if i_discr_data is not null then
            if i_card_data_input_mode in ('F227000A', 'F227000M', 'F227000N', 'F227000P') then
                prs_api_template_pkg.parse_discr_contactless_data (
                    i_perso_method_id  => l_perso_method_id
                    , i_discr_data     => i_discr_data
                    , o_atc            => l_atc
                    , o_un_placeholder => o_un_placeholder
                    , o_cvc3           => o_cvv
                    , o_pvv            => o_pvv_tab(2)
                    , o_pvk_index      => o_pvk_index_tab(2)
                );
                io_atc := l_atc;
            else
                prs_api_template_pkg.parse_discr_data (
                    i_perso_method_id  => l_perso_method_id
                    , i_discr_data     => i_discr_data
                    , o_pvv            => o_pvv_tab(2)
                    , o_pvk_index      => o_pvk_index_tab(2)
                    , o_cvv            => o_cvv
                    , o_atc            => l_atc
                    , i_discr_type     => i_discr_type
                );
            end if;
        end if;
    exception
        when com_api_error_pkg.e_application_error then
            if com_api_error_pkg.get_last_error in (
                'ILLEGAL_PERSO_METHOD'
            ) then
                o_resp_code := aup_api_const_pkg.RESP_CODE_INVALID_TRACK;
            else
                raise;
            end if;
        when com_api_error_pkg.e_value_error then
            o_resp_code := aup_api_const_pkg.RESP_CODE_INVALID_TRACK;
    end;

    if i_discr_data is not null then
        case l_pvv_store_method
        when prs_api_const_pkg.PVV_STORING_METHOD_TRACK then
            o_pvv_tab(1) := o_pvv_tab(2);
            o_pvk_index_tab(1) := o_pvk_index_tab(2);
        when prs_api_const_pkg.PVV_STORING_METHOD_COMBINED then
            o_pvk_index_tab(1) := case when o_pvv_tab(1) is null then o_pvk_index_tab(2) else o_pvk_index_tab(1) end;
            o_pvv_tab(1) := case when o_pvv_tab(1) is null then o_pvv_tab(2) else o_pvv_tab(1) end;
        else
            null;
        end case;
    end if;
        
    trc_log_pkg.debug ('get_card_resp_code: done with o_resp_code [' || o_resp_code || ']');
end get_card_resp_code;

function get_resp_code(
    i_error in com_api_type_pkg.t_name
) return com_api_type_pkg.t_dict_value is
begin
    trc_log_pkg.debug('get_resp_code: i_error[' || i_error || ']');
    return
        case i_error
            when 'UNKNOWN_INSTITUTION_NETWORK'          then aup_api_const_pkg.RESP_CODE_ERROR
            when 'UNKNOWN_MERCHANT'                     then aup_api_const_pkg.RESP_CODE_ERROR
            when 'UNKNOWN_TERMINAL'                     then aup_api_const_pkg.RESP_CODE_ERROR
            when 'UNKNOWN_ISSUING_NETWORK'              then aup_api_const_pkg.RESP_CODE_CANT_GET_ISSUER
            when 'UNKNOWN_CUSTOMER'                     then aup_api_const_pkg.RESP_CODE_CANT_GET_CUSTOMER
            when 'ACCOUNT_RESTRICTED'                   then aup_api_const_pkg.RESP_CODE_ACCOUNT_RESTRICTED
            when 'UNKNOWN_DESTINATION_NETWORK'          then aup_api_const_pkg.RESP_CODE_CANT_FIND_DEST
            when 'INSTITUTION_NOT_REGISTRED_IN_NETWORK' then aup_api_const_pkg.RESP_CODE_CANT_GET_ACQ_BIN
            when 'UNKNOWN_ACCOUNT'                      then aup_api_const_pkg.RESP_CODE_ACCT_NOT_FOUND
            when 'UNKNOWN_CARD'                         then aup_api_const_pkg.RESP_CODE_CARD_NOT_FOUND
            else                                             aup_api_const_pkg.RESP_CODE_ERROR
        end;
end get_resp_code;

function put_auth(
    i_id                       in com_api_type_pkg.t_long_id
  , o_scenario_id             out com_api_type_pkg.t_tiny_id
  , o_split_hash              out com_api_type_pkg.t_tiny_id
  , i_is_reversal              in com_api_type_pkg.t_boolean
  , i_original_id              in com_api_type_pkg.t_long_id
  , i_parent_id                in com_api_type_pkg.t_long_id
  , i_msg_type                 in com_api_type_pkg.t_dict_value
  , i_oper_type                in com_api_type_pkg.t_dict_value
  , o_sttl_type               out com_api_type_pkg.t_dict_value
  , i_is_advice                in com_api_type_pkg.t_boolean
  , i_is_repeat                in com_api_type_pkg.t_boolean
  , i_host_date                in date
  , i_oper_date                in date
  , i_oper_count               in com_api_type_pkg.t_short_id
  , i_oper_request_amount      in com_api_type_pkg.t_money
  , i_oper_amount_algorithm    in com_api_type_pkg.t_dict_value
  , i_oper_amount              in com_api_type_pkg.t_money
  , i_oper_currency            in com_api_type_pkg.t_curr_code
  , i_oper_cashback_amount     in com_api_type_pkg.t_money
  , i_oper_replacement_amount  in com_api_type_pkg.t_money
  , i_oper_surcharge_amount    in com_api_type_pkg.t_money
  , i_client_id_type           in com_api_type_pkg.t_dict_value
  , i_client_id_value          in com_api_type_pkg.t_name
  , o_iss_inst_id             out com_api_type_pkg.t_inst_id
  , o_iss_network_id          out com_api_type_pkg.t_network_id
  , o_iss_host_id             out com_api_type_pkg.t_tiny_id
  , i_iss_network_device_id    in com_api_type_pkg.t_short_id
  , o_split_hash_iss          out com_api_type_pkg.t_tiny_id
  , o_card_inst_id            out com_api_type_pkg.t_inst_id
  , o_card_network_id         out com_api_type_pkg.t_network_id
  , i_card_number              in com_api_type_pkg.t_card_number
  , o_card_id                 out com_api_type_pkg.t_medium_id
  , o_card_instance_id        out com_api_type_pkg.t_medium_id
  , o_card_type_id            out com_api_type_pkg.t_tiny_id
  , o_card_mask               out com_api_type_pkg.t_card_number
  , o_card_hash               out com_api_type_pkg.t_medium_id
  , io_card_seq_number         in out com_api_type_pkg.t_tiny_id
  , io_card_expir_date         in out date
  , io_card_service_code       in out com_api_type_pkg.t_curr_code
  , o_card_country            out com_api_type_pkg.t_country_code
  , o_pan_length              out com_api_type_pkg.t_tiny_id
  , o_pvv_tab                 out com_api_type_pkg.t_number_tab
  , o_pin_verify_method       out com_api_type_pkg.t_dict_value
  , o_pvk_index_tab           out com_api_type_pkg.t_number_tab
  , o_customer_id             out com_api_type_pkg.t_medium_id
  , o_account_id              out com_api_type_pkg.t_medium_id
  , i_account_type             in com_api_type_pkg.t_dict_value
  , i_account_number           in com_api_type_pkg.t_account_number
  , i_account_amount           in com_api_type_pkg.t_money
  , i_account_currency         in com_api_type_pkg.t_curr_code
  , i_account_cnvt_rate        in com_api_type_pkg.t_money
  , i_bin_amount               in com_api_type_pkg.t_money
  , i_bin_currency             in com_api_type_pkg.t_curr_code
  , i_bin_cnvt_rate            in com_api_type_pkg.t_money
  , i_network_amount           in com_api_type_pkg.t_money
  , i_network_currency         in com_api_type_pkg.t_curr_code
  , i_network_cnvt_date        in date
  , i_network_cnvt_rate        in com_api_type_pkg.t_money
  , i_addr_verif_result        in com_api_type_pkg.t_dict_value
  , o_address_verify_algo     out com_api_type_pkg.t_dict_value
  , o_address_verify_string   out com_api_type_pkg.t_name
  , o_address_verify_zip      out com_api_type_pkg.t_postal_code
  , i_auth_code                in com_api_type_pkg.t_auth_code
  , i_dst_client_id_type       in com_api_type_pkg.t_dict_value
  , i_dst_client_id_value      in com_api_type_pkg.t_name
  , o_dst_inst_id             out com_api_type_pkg.t_inst_id
  , o_dst_network_id          out com_api_type_pkg.t_network_id
  , o_dst_card_inst_id        out com_api_type_pkg.t_inst_id
  , o_dst_card_network_id     out com_api_type_pkg.t_network_id
  , i_dst_card_number          in com_api_type_pkg.t_card_number
  , o_dst_card_id             out com_api_type_pkg.t_medium_id
  , o_dst_card_instance_id    out com_api_type_pkg.t_medium_id
  , o_dst_card_type_id        out com_api_type_pkg.t_tiny_id
  , o_dst_card_mask           out com_api_type_pkg.t_card_number
  , o_dst_card_hash           out com_api_type_pkg.t_medium_id
  , io_dst_card_seq_number     in out com_api_type_pkg.t_tiny_id
  , io_dst_card_expir_date     in out date
  , io_dst_card_service_code   in out com_api_type_pkg.t_curr_code
  , o_dst_card_country        out com_api_type_pkg.t_country_code
  , o_dst_customer_id         out com_api_type_pkg.t_medium_id
  , o_dst_account_id          out com_api_type_pkg.t_medium_id
  , i_dst_account_type         in com_api_type_pkg.t_dict_value
  , i_dst_account_number       in com_api_type_pkg.t_account_number
  , i_dst_account_amount       in com_api_type_pkg.t_money
  , i_dst_account_currency     in com_api_type_pkg.t_curr_code
  , i_dst_auth_code            in com_api_type_pkg.t_auth_code
  , i_acq_device_id            in com_api_type_pkg.t_short_id
  , i_acq_resp_code            in com_api_type_pkg.t_dict_value
  , i_acq_device_proc_result   in com_api_type_pkg.t_dict_value
  , i_acq_inst_bin             in com_api_type_pkg.t_cmid
  , i_forw_inst_bin            in com_api_type_pkg.t_cmid
  , i_acq_inst_id              in com_api_type_pkg.t_inst_id
  , io_acq_network_id          in out com_api_type_pkg.t_network_id
  , o_split_hash_acq          out com_api_type_pkg.t_tiny_id
  , o_acq_member_id           out com_api_type_pkg.t_short_id
  , io_merchant_id             in out com_api_type_pkg.t_short_id
  , i_merchant_number          in com_api_type_pkg.t_merchant_number
  , i_terminal_type            in com_api_type_pkg.t_dict_value
  , i_terminal_number          in com_api_type_pkg.t_terminal_number
  , io_terminal_id             in out com_api_type_pkg.t_short_id
  , i_merchant_name            in com_api_type_pkg.t_name
  , i_merchant_street          in com_api_type_pkg.t_name
  , i_merchant_city            in com_api_type_pkg.t_name
  , i_merchant_region          in com_api_type_pkg.t_module_code
  , i_merchant_country         in com_api_type_pkg.t_country_code
  , i_merchant_postcode        in com_api_type_pkg.t_postal_code
  , i_cat_level                in com_api_type_pkg.t_dict_value
  , i_mcc                      in com_api_type_pkg.t_mcc
  , i_originator_refnum        in com_api_type_pkg.t_rrn
  , i_network_refnum           in com_api_type_pkg.t_rrn
  , i_card_data_input_cap      in com_api_type_pkg.t_dict_value
  , i_crdh_auth_cap            in com_api_type_pkg.t_dict_value
  , i_card_capture_cap         in com_api_type_pkg.t_dict_value
  , i_terminal_operating_env   in com_api_type_pkg.t_dict_value
  , i_crdh_presence            in com_api_type_pkg.t_dict_value
  , i_card_presence            in com_api_type_pkg.t_dict_value
  , i_card_data_input_mode     in com_api_type_pkg.t_dict_value
  , i_crdh_auth_method         in com_api_type_pkg.t_dict_value
  , i_crdh_auth_entity         in com_api_type_pkg.t_dict_value
  , i_card_data_output_cap     in com_api_type_pkg.t_dict_value
  , i_terminal_output_cap      in com_api_type_pkg.t_dict_value
  , i_pin_capture_cap          in com_api_type_pkg.t_dict_value
  , i_pin_presence             in com_api_type_pkg.t_dict_value
  , i_cvv2_presence            in com_api_type_pkg.t_dict_value
  , i_cvc_indicator            in com_api_type_pkg.t_dict_value
  , i_pos_entry_mode           in com_api_type_pkg.t_module_code
  , i_pos_cond_code            in com_api_type_pkg.t_module_code
  , i_emv_data                 in com_api_type_pkg.t_param_value
  , io_atc                     in out com_api_type_pkg.t_dict_value
  , i_tvr                      in com_api_type_pkg.t_param_value
  , i_cvr                      in com_api_type_pkg.t_param_value
  , i_addl_data                in com_api_type_pkg.t_param_value
  , i_service_code             in com_api_type_pkg.t_dict_value
  , i_device_date              in date
  , i_certificate_method       in com_api_type_pkg.t_dict_value
  , i_certificate_type         in com_api_type_pkg.t_dict_value
  , i_merchant_certif          in com_api_type_pkg.t_name
  , i_cardholder_certif        in com_api_type_pkg.t_name
  , i_ucaf_indicator           in com_api_type_pkg.t_dict_value
  , i_is_early_emv             in com_api_type_pkg.t_boolean
  , i_payment_order_id         in com_api_type_pkg.t_long_id := null
  , i_payment_host_id          in com_api_type_pkg.t_tiny_id := null
  , i_payment_purpose_id       in com_api_type_pkg.t_short_id := null
  , i_discr_data               in com_api_type_pkg.t_name := null
  , o_cvv                     out com_api_type_pkg.t_module_code
  , o_emv_scheme_id           out com_api_type_pkg.t_dict_value
  , i_oper_reason              in com_api_type_pkg.t_dict_value := null
  , i_tags                     in aup_api_type_pkg.t_aup_tag_tab
  , o_cvv2_date_format        out com_api_type_pkg.t_dict_value
  , i_amounts                  in com_api_type_pkg.t_raw_data := null
  , i_cavv_presence            in com_api_type_pkg.t_dict_value
  , i_aav_presence             in com_api_type_pkg.t_dict_value
  , i_transaction_id           in com_api_type_pkg.t_auth_long_id default null
  , i_discr_type               in com_api_type_pkg.t_short_id := null
  , o_un_placeholder          out com_api_type_pkg.t_name
) return com_api_type_pkg.t_dict_value is

    l_resp_code                 com_api_type_pkg.t_dict_value;
    l_match_status              com_api_type_pkg.t_dict_value;
    l_param_tab                 com_api_type_pkg.t_param_tab;
    l_atc                       com_api_type_pkg.t_long_id;
    l_last_atc                  com_api_type_pkg.t_long_id;
    l_last_atc_hex              com_api_type_pkg.t_dict_value;
    l_split_hash                com_api_type_pkg.t_tiny_id;
    l_oper_id                   com_api_type_pkg.t_long_id;
    l_acq_inst_id               com_api_type_pkg.t_inst_id := i_acq_inst_id;
    l_host_id                   com_api_type_pkg.t_tiny_id;
    l_payment_host_id           com_api_type_pkg.t_tiny_id;
    l_payment_purpose_id        com_api_type_pkg.t_short_id;
    l_oper_status               com_api_type_pkg.t_dict_value;

    procedure save_auth(
        i_resp_code in com_api_type_pkg.t_dict_value
    ) is
    begin
        insert into aut_auth (
            id
          , parent_id
          , resp_code
          , proc_type
          , proc_mode
          , is_advice
          , is_repeat
          , is_completed
          , account_cnvt_rate
          , bin_amount
          , bin_currency
          , bin_cnvt_rate
          , network_amount
          , network_currency
          , network_cnvt_date
          , network_cnvt_rate
          , addr_verif_result
          , acq_device_id
          , acq_resp_code
          , acq_device_proc_result
          , cat_level
          , card_data_input_cap
          , crdh_auth_cap
          , card_capture_cap
          , terminal_operating_env
          , crdh_presence
          , card_presence
          , card_data_input_mode
          , crdh_auth_method
          , crdh_auth_entity
          , card_data_output_cap
          , terminal_output_cap
          , pin_capture_cap
          , pin_presence
          , cvv2_presence
          , cvc_indicator
          , pos_entry_mode
          , pos_cond_code
          , emv_data
          , atc
          , tvr
          , cvr
          , addl_data
          , service_code
          , device_date
          , certificate_method
          , certificate_type
          , merchant_certif
          , cardholder_certif
          , ucaf_indicator
          , is_early_emv
          , amounts
          , cavv_presence
          , aav_presence
          , transaction_id              
        ) values (
            i_id
          , i_parent_id
          , save_auth.i_resp_code
          , null              -- proc_type
          , null              -- proc_mode
          , i_is_advice
          , i_is_repeat
          , aut_api_const_pkg.AUTH_DURING_EXECUTION    -- is_completed
          , i_account_cnvt_rate
          , i_bin_amount
          , i_bin_currency
          , i_bin_cnvt_rate
          , i_network_amount
          , i_network_currency
          , i_network_cnvt_date
          , i_network_cnvt_rate
          , i_addr_verif_result
          , i_acq_device_id
          , i_acq_resp_code
          , i_acq_device_proc_result
          , i_cat_level
          , i_card_data_input_cap
          , i_crdh_auth_cap
          , i_card_capture_cap
          , i_terminal_operating_env
          , i_crdh_presence
          , i_card_presence
          , i_card_data_input_mode
          , i_crdh_auth_method
          , i_crdh_auth_entity
          , i_card_data_output_cap
          , i_terminal_output_cap
          , i_pin_capture_cap
          , i_pin_presence
          , i_cvv2_presence
          , i_cvc_indicator
          , i_pos_entry_mode
          , i_pos_cond_code
          , i_emv_data
          , io_atc
          , i_tvr
          , i_cvr
          , i_addl_data
          , i_service_code
          , i_device_date
          , i_certificate_method
          , i_certificate_type
          , i_merchant_certif
          , i_cardholder_certif
          , i_ucaf_indicator
          , i_is_early_emv
          , i_amounts
          , i_cavv_presence
          , i_aav_presence
          , i_transaction_id
        );
    end save_auth;
    
    procedure save_auth_card(
        i_split_hash in com_api_type_pkg.t_tiny_id
    ) is
    begin
        insert into aut_card (
            auth_id
          , split_hash
          , card_number
          , dst_card_number
        ) values (
            i_id
          , i_split_hash
          , iss_api_token_pkg.encode_card_number(i_card_number => i_card_number)
          , iss_api_token_pkg.encode_card_number(i_card_number => i_dst_card_number)
        );
    end;

begin
    trc_log_pkg.set_object (
        i_entity_type => opr_api_const_pkg.ENTITY_TYPE_OPERATION
      , i_object_id   => i_id
    );

    trc_log_pkg.debug(
        i_text       => 'Starting auth initialization procedure: '
                     || 'oper_type [#1], msg_type [#2], oper_reason [#3], i_client_id_type [#4]'
      , i_env_param1 => i_oper_type
      , i_env_param2 => i_msg_type
      , i_env_param3 => i_oper_reason
      , i_env_param4 => i_client_id_type 
    );

    begin
        o_card_type_id := null;
        o_card_mask    := null;
        o_card_hash    := null;
        o_card_country := null;

        opr_api_create_pkg.add_participant(
            i_oper_id               => i_id
          , i_msg_type              => i_msg_type
          , i_oper_type             => i_oper_type
          , i_oper_reason           => i_oper_reason
          , i_participant_type      => com_api_const_pkg.PARTICIPANT_ACQUIRER
          , io_inst_id              => l_acq_inst_id
          , io_network_id           => io_acq_network_id
          , o_host_id               => l_host_id
          , io_card_inst_id         => o_card_inst_id
          , io_card_network_id      => o_card_network_id
          , io_card_id              => o_card_id
          , o_card_instance_id      => o_card_instance_id
          , io_card_type_id         => o_card_type_id
          , io_card_mask            => o_card_mask
          , io_card_hash            => o_card_hash
          , io_card_seq_number      => io_card_seq_number
          , io_card_expir_date      => io_card_expir_date
          , io_card_service_code    => io_card_service_code
          , io_card_country         => o_card_country
          , io_customer_id          => o_customer_id
          , io_account_id           => o_account_id
          , i_merchant_number       => i_merchant_number
          , io_merchant_id          => io_merchant_id
          , i_terminal_number       => i_terminal_number
          , io_terminal_id          => io_terminal_id
          , o_split_hash            => o_split_hash_acq
          , io_payment_host_id      => l_payment_host_id
          , i_payment_order_id      => i_payment_order_id
        );
    exception
        when com_api_error_pkg.e_application_error then
            if l_resp_code is null then
                l_resp_code := cst_api_online_pkg.get_resp_code(
                                   i_error                   => com_api_error_pkg.get_last_error
                                 , i_msg_type                => i_msg_type
                                 , i_oper_type               => i_oper_type
                                 , i_oper_reason             => i_oper_reason
                                 , i_participant_type        => com_api_const_pkg.PARTICIPANT_ACQUIRER
                                 , i_client_id_type          => null
                                 , i_client_id_value         => null
                               );
            end if;

            if l_resp_code is null then
                l_resp_code := get_resp_code(i_error => com_api_error_pkg.get_last_error);
            end if;
    end;
    trc_log_pkg.debug('l_resp_code [' || l_resp_code || '] (ACQ)');

    begin
        if i_client_id_type in (
            aup_api_const_pkg.CLIENT_ID_TYPE_EMAIL
          , aup_api_const_pkg.CLIENT_ID_TYPE_MOBILE
          , aup_api_const_pkg.CLIENT_ID_TYPE_CUSTOMER
          , aup_api_const_pkg.CLIENT_ID_TYPE_CONTRACT
          , aup_api_const_pkg.CLIENT_ID_TYPE_ACCOUNT
        )
        then
            o_iss_inst_id := l_acq_inst_id;
        end if;

        o_card_type_id := null;
        o_card_mask    := null;
        o_card_hash    := null;
        o_card_country := null;

        opr_api_create_pkg.add_participant(
            i_oper_id               => i_id
          , i_msg_type              => i_msg_type
          , i_oper_type             => i_oper_type
          , i_oper_reason           => i_oper_reason
          , i_participant_type      => com_api_const_pkg.PARTICIPANT_ISSUER
          , i_host_date             => i_host_date
          , i_client_id_type        => i_client_id_type
          , i_client_id_value       => i_client_id_value
          , io_inst_id              => o_iss_inst_id
          , io_network_id           => o_iss_network_id
          , o_host_id               => o_iss_host_id
          , io_card_inst_id         => o_card_inst_id
          , io_card_network_id      => o_card_network_id
          , io_card_id              => o_card_id
          , o_card_instance_id      => o_card_instance_id
          , io_card_type_id         => o_card_type_id
          , i_card_number           => i_card_number
          , io_card_mask            => o_card_mask
          , io_card_hash            => o_card_hash
          , io_card_seq_number      => io_card_seq_number
          , io_card_expir_date      => io_card_expir_date
          , io_card_service_code    => io_card_service_code
          , io_card_country         => o_card_country
          , io_customer_id          => o_customer_id
          , io_account_id           => o_account_id
          , i_account_type          => i_account_type
          , i_account_number        => i_account_number
          , i_account_amount        => i_account_amount
          , i_account_currency      => i_account_currency
          , i_auth_code             => i_auth_code
          , io_merchant_id          => io_merchant_id
          , io_terminal_id          => io_terminal_id
          , o_split_hash            => o_split_hash_iss
          , i_without_checks        => case when l_resp_code is not null then com_api_const_pkg.TRUE else com_api_const_pkg.FALSE end
          , io_payment_host_id      => l_payment_host_id
          , i_payment_order_id      => i_payment_order_id
          , i_acq_inst_id           => l_acq_inst_id          
          , i_acq_network_id        => io_acq_network_id       
          , i_oper_currency         => i_oper_currency            
          , i_terminal_type         => i_terminal_type                     
        );

        if o_card_instance_id is not null then
            get_card_resp_code(
                i_oper_type             => i_oper_type
              , i_host_date             => i_host_date
              , i_pin_presence          => i_pin_presence
              , i_card_instance_id      => o_card_instance_id
              , i_card_service_code     => io_card_service_code
              , i_discr_data            => i_discr_data
              , i_card_data_input_mode  => i_card_data_input_mode
              , i_msg_type              => i_msg_type
              , i_participant_type      => com_api_const_pkg.PARTICIPANT_ISSUER
              , o_resp_code             => l_resp_code
              , o_pvv_tab               => o_pvv_tab
              , o_pin_verify_method     => o_pin_verify_method
              , o_pvk_index_tab         => o_pvk_index_tab
              , o_pan_length            => o_pan_length
              , o_cvv                   => o_cvv
              , o_cvv2_date_format      => o_cvv2_date_format
              , io_atc                  => io_atc
              , i_discr_type            => i_discr_type
              , o_un_placeholder        => o_un_placeholder
            );
        end if;

    exception
        when com_api_error_pkg.e_application_error then
            if l_resp_code is null then
                l_resp_code := cst_api_online_pkg.get_resp_code(
                                   i_error                   => com_api_error_pkg.get_last_error
                                 , i_msg_type                => i_msg_type
                                 , i_oper_type               => i_oper_type
                                 , i_oper_reason             => i_oper_reason
                                 , i_participant_type        => com_api_const_pkg.PARTICIPANT_ISSUER
                                 , i_client_id_type          => i_client_id_type
                                 , i_client_id_value         => i_client_id_value
                               );
            end if;

            if l_resp_code is null then
                l_resp_code := get_resp_code(i_error => com_api_error_pkg.get_last_error);
            end if;
    end;
    trc_log_pkg.debug('l_resp_code [' || l_resp_code || '] (ISS)');

    begin
        if i_dst_client_id_type in (
            aup_api_const_pkg.CLIENT_ID_TYPE_EMAIL
          , aup_api_const_pkg.CLIENT_ID_TYPE_MOBILE
          , aup_api_const_pkg.CLIENT_ID_TYPE_CUSTOMER
          , aup_api_const_pkg.CLIENT_ID_TYPE_CONTRACT
          , aup_api_const_pkg.CLIENT_ID_TYPE_ACCOUNT
        )
            or i_dst_client_id_type is null
            or substr(i_dst_client_id_type, 1, 4) = com_api_const_pkg.COMMUNICATION_METHOD_KEY
        then
            o_dst_inst_id :=  l_acq_inst_id;
        end if;

        opr_api_create_pkg.add_participant(
            i_oper_id               => i_id
          , i_msg_type              => i_msg_type
          , i_oper_type             => i_oper_type
          , i_oper_reason           => i_oper_reason
          , i_participant_type      => com_api_const_pkg.PARTICIPANT_DEST
          , i_host_date             => i_host_date
          , i_client_id_type        => i_dst_client_id_type
          , i_client_id_value       => i_dst_client_id_value
          , io_inst_id              => o_dst_inst_id
          , io_network_id           => o_dst_network_id
          , o_host_id               => l_host_id
          , io_card_inst_id         => o_dst_card_inst_id
          , io_card_network_id      => o_dst_card_network_id
          , io_card_id              => o_dst_card_id
          , o_card_instance_id      => o_dst_card_instance_id
          , io_card_type_id         => o_dst_card_type_id
          , i_card_number           => i_dst_card_number
          , io_card_mask            => o_dst_card_mask
          , io_card_hash            => o_dst_card_hash
          , io_card_seq_number      => io_dst_card_seq_number
          , io_card_expir_date      => io_dst_card_expir_date
          , io_card_service_code    => io_dst_card_service_code
          , io_card_country         => o_dst_card_country
          , io_customer_id          => o_dst_customer_id
          , io_account_id           => o_dst_account_id
          , i_account_type          => i_dst_account_type
          , i_account_number        => i_dst_account_number
          , i_account_amount        => i_dst_account_amount
          , i_account_currency      => i_dst_account_currency
          , i_auth_code             => i_dst_auth_code
          , io_merchant_id          => io_merchant_id
          , io_terminal_id          => io_terminal_id
          , o_split_hash            => l_split_hash
          , i_without_checks        => case when nvl(l_resp_code, aup_api_const_pkg.RESP_CODE_OK) != aup_api_const_pkg.RESP_CODE_OK then com_api_const_pkg.TRUE else com_api_const_pkg.FALSE end
          , io_payment_host_id      => l_payment_host_id
          , i_payment_order_id      => i_payment_order_id
        );
            -- set dst customer for payment order
        if o_dst_customer_id is not null and i_payment_order_id is not null then
            update pmo_order b
               set b.dst_customer_id = o_dst_customer_id
             where b.id = i_payment_order_id;
        end if;

    exception
        when com_api_error_pkg.e_application_error then
            if l_resp_code is null then
                l_resp_code := cst_api_online_pkg.get_resp_code(
                                   i_error                   => com_api_error_pkg.get_last_error
                                 , i_msg_type                => i_msg_type
                                 , i_oper_type               => i_oper_type
                                 , i_oper_reason             => i_oper_reason
                                 , i_participant_type        => com_api_const_pkg.PARTICIPANT_DEST
                                 , i_client_id_type          => i_dst_client_id_type
                                 , i_client_id_value         => i_dst_client_id_value
                               );
            end if;

            if l_resp_code is null then
                l_resp_code := get_resp_code(i_error => com_api_error_pkg.get_last_error);
            end if;
    end;

    trc_log_pkg.debug(
        i_text            => 'Find out settlement type [#1][#2][#3][#4][#5][#6]'
      , i_env_param1      => o_iss_inst_id
      , i_env_param2      => l_acq_inst_id
      , i_env_param3      => o_card_inst_id
      , i_env_param4      => o_iss_network_id
      , i_env_param5      => io_acq_network_id
      , i_env_param6      => o_card_network_id
    );

    net_api_sttl_pkg.get_sttl_type(
        i_iss_inst_id             => o_iss_inst_id
      , i_acq_inst_id             => l_acq_inst_id
      , i_card_inst_id            => o_card_inst_id
      , i_iss_network_id          => o_iss_network_id
      , i_acq_network_id          => io_acq_network_id
      , i_card_network_id         => o_card_network_id
      , i_acq_inst_bin            => i_acq_inst_bin
      , o_sttl_type               => o_sttl_type
      , o_match_status            => l_match_status
      , i_mask_error              => com_api_const_pkg.TRUE
      , i_oper_type               => i_oper_type
    );

    trc_log_pkg.debug(
        i_text            => 'Settlement type results [#1][#2]'
      , i_env_param1      => o_sttl_type
      , i_env_param2      => l_match_status
    );

    if o_sttl_type is null then
        trc_log_pkg.error(
            i_text          => 'UNKNOWN_SETTLEMENT_TYPE'
          , i_env_param1    => o_iss_network_id
          , i_env_param2    => o_iss_inst_id
          , i_env_param3    => io_acq_network_id
          , i_env_param4    => l_acq_inst_id
          , i_env_param5    => o_card_network_id
          , i_env_param6    => o_card_inst_id
          , i_entity_type   => aut_api_const_pkg.ENTITY_TYPE_AUTHORIZATION
          , i_object_id     => i_id
        );

        l_resp_code := aup_api_const_pkg.RESP_CODE_CANT_GET_STTL_TYPE;

        trc_log_pkg.debug('Settlement type hasn''t been found, l_resp_code [' || l_resp_code || ']');
    end if;

    trc_log_pkg.debug('l_resp_code [' || l_resp_code || '] (DST)');

    l_resp_code := nvl(l_resp_code, aup_api_const_pkg.RESP_CODE_OK);

    if l_resp_code = aup_api_const_pkg.RESP_CODE_OK
        and o_card_id is null
    then
        -- only for them-on-us or them-on-them need search member id
        begin
            o_acq_member_id :=
                net_api_network_pkg.get_member_id(
                    i_inst_id           => l_acq_inst_id
                  , i_network_id        => o_iss_network_id
                  , i_participant_type  => com_api_const_pkg.PARTICIPANT_ACQUIRER
                );
        exception
            when com_api_error_pkg.e_application_error then
                l_resp_code := cst_api_online_pkg.get_resp_code(
                                   i_error                   => com_api_error_pkg.get_last_error
                                 , i_msg_type                => i_msg_type
                                 , i_oper_type               => i_oper_type
                                 , i_oper_reason             => i_oper_reason
                                 , i_participant_type        => com_api_const_pkg.PARTICIPANT_ACQUIRER
                                 , i_client_id_type          => i_client_id_type
                                 , i_client_id_value         => i_client_id_value
                               );

                if l_resp_code is null then
                    l_resp_code := get_resp_code(i_error => com_api_error_pkg.get_last_error);
                end if;
        end;
    end if;

    l_oper_id := i_id;

    -- Rejected by SVFE (unsuccessful) authorizations come to SVBO as advices with empty authorization codes,
    -- to have possibility to differ them from successful ones it is needed to override operations' statuses
    l_oper_status := 
        case
            when trim(i_auth_code) is null and i_is_advice = com_api_const_pkg.TRUE then
                opr_api_const_pkg.OPERATION_STATUS_UNSUCCESSFUL 
            else    
                opr_api_const_pkg.OPERATION_STATUS_PROCESSING
        end;

    trc_log_pkg.debug(
        i_text       => 'i_auth_code [#1] and i_is_advice [#2] get a value l_oper_status [#3]'
      , i_env_param1 => i_auth_code
      , i_env_param2 => i_is_advice
      , i_env_param3 => l_oper_status
    );

    opr_api_create_pkg.create_operation(
        io_oper_id                  => l_oper_id
      , i_session_id                => null
      , i_is_reversal               => i_is_reversal
      , i_original_id               => i_original_id
      , i_oper_type                 => i_oper_type
      , i_oper_reason               => i_oper_reason
      , i_msg_type                  => i_msg_type
      , i_status                    => l_oper_status
      , i_status_reason             => null
      , i_sttl_type                 => o_sttl_type
      , i_terminal_type             => i_terminal_type
      , i_acq_inst_bin              => i_acq_inst_bin
      , i_forw_inst_bin             => i_forw_inst_bin
      , i_merchant_number           => i_merchant_number
      , i_terminal_number           => i_terminal_number
      , i_merchant_name             => i_merchant_name
      , i_merchant_street           => i_merchant_street
      , i_merchant_city             => i_merchant_city
      , i_merchant_region           => i_merchant_region
      , i_merchant_country          => i_merchant_country
      , i_merchant_postcode         => i_merchant_postcode
      , i_mcc                       => i_mcc
      , i_originator_refnum         => i_originator_refnum
      , i_network_refnum            => i_network_refnum
      , i_oper_count                => i_oper_count
      , i_oper_request_amount       => i_oper_request_amount
      , i_oper_amount_algorithm     => i_oper_amount_algorithm
      , i_oper_amount               => i_oper_amount
      , i_oper_currency             => i_oper_currency
      , i_oper_cashback_amount      => i_oper_cashback_amount
      , i_oper_replacement_amount   => i_oper_replacement_amount
      , i_oper_surcharge_amount     => i_oper_surcharge_amount
      , i_oper_date                 => i_oper_date
      , i_host_date                 => i_host_date
      , i_match_status              => l_match_status
      , i_sttl_amount               => null
      , i_sttl_currency             => null
      , i_dispute_id                => null
      , i_payment_order_id          => i_payment_order_id
      , i_payment_host_id           => null
      , i_forced_processing         => com_api_type_pkg.FALSE
    );

    if l_resp_code = aup_api_const_pkg.RESP_CODE_OK 
        and (i_emv_data is not null or i_card_data_input_mode in ('F227000A', 'F227000M', 'F227000P', 'F227000N')) then
        -- last online ATC
        begin
            select atc
              into l_last_atc_hex
              from (
                    select a.atc
                      from aut_auth a
                         , opr_operation o
                         , opr_participant p
                     where p.card_id = o_card_id
                       and p.split_hash = o_split_hash_iss
                       and p.oper_id = o.id
                       and o.id = a.id
                       and a.atc is not null
                     order by o.host_date desc
                            , o.oper_date desc
                   )
             where rownum <= 1;
        exception
            when no_data_found then
                l_last_atc_hex := '0000';
        end;

        l_atc      := prs_api_util_pkg.hex2dec(io_atc);
        l_last_atc := prs_api_util_pkg.hex2dec(l_last_atc_hex);

        if l_atc < 0 or l_last_atc > l_atc then
            trc_log_pkg.error(
                i_text            => 'EXCEED_ATC'
              , i_env_param1      => io_atc
              , i_env_param2      => l_last_atc
              , i_entity_type     => aut_api_const_pkg.ENTITY_TYPE_AUTHORIZATION
              , i_object_id       => i_id
            );

            l_resp_code := aup_api_const_pkg.RESP_CODE_ERROR;

            trc_log_pkg.debug('ATC has been exceeded, l_resp_code [' || l_resp_code || ']');
        end if;

        for emv_scheme in (
            select a.type as appl_type
              from iss_card_instance_vw ci
                 , iss_card oc
                 , prd_contract ct
                 , iss_product_card_type pd
                 , emv_appl_scheme_vw a
             where ci.id           = o_card_instance_id
               and oc.id           = ci.card_id
               and ct.id           = oc.contract_id
               and pd.product_id   = ct.product_id
               and pd.bin_id       = ci.bin_id
               and pd.card_type_id = oc.card_type_id
               and ci.seq_number between pd.seq_number_low and pd.seq_number_high
               and a.id            = pd.emv_appl_scheme_id
        ) loop
            o_emv_scheme_id := emv_scheme.appl_type;
            exit;
        end loop;
    end if;

    if l_resp_code = aup_api_const_pkg.RESP_CODE_OK then
        rul_api_param_pkg.set_param(
            io_params         => l_param_tab
          , i_name            => 'OPER_TYPE'
          , i_value           => i_oper_type
        );
        rul_api_param_pkg.set_param(
            io_params         => l_param_tab
          , i_name            => 'MSG_TYPE'
          , i_value           => i_msg_type
        );
        rul_api_param_pkg.set_param(
            io_params         => l_param_tab
          , i_name            => 'IS_REVERSAL'
          , i_value           => i_is_reversal
        );
        rul_api_param_pkg.set_param(
            io_params         => l_param_tab
          , i_name            => 'IS_REPEAT'
          , i_value           => i_is_repeat
        );
        rul_api_param_pkg.set_param(
            io_params         => l_param_tab
          , i_name            => 'IS_ADVICE'
          , i_value           => i_is_advice
        );
        rul_api_param_pkg.set_param(
            io_params         => l_param_tab
          , i_name            => 'CLIENT_ID_TYPE'
          , i_value           => i_client_id_type
        );
        rul_api_param_pkg.set_param(
            io_params         => l_param_tab
          , i_name            => 'ACQ_INST_ID'
          , i_value           => l_acq_inst_id
        );
        rul_api_param_pkg.set_param(
            io_params         => l_param_tab
          , i_name            => 'ACQ_NETWORK_ID'
          , i_value           => io_acq_network_id
        );
        rul_api_param_pkg.set_param(
            io_params         => l_param_tab
          , i_name            => 'ISS_INST_ID'
          , i_value           => o_iss_inst_id
        );
        rul_api_param_pkg.set_param(
            io_params         => l_param_tab
          , i_name            => 'ISS_NETWORK_ID'
          , i_value           => o_iss_network_id
        );
        rul_api_param_pkg.set_param(
            io_params         => l_param_tab
          , i_name            => 'DST_INST_ID'
          , i_value           => o_dst_inst_id
        );
        rul_api_param_pkg.set_param(
            io_params         => l_param_tab
          , i_name            => 'DST_NETWORK_ID'
          , i_value           => o_dst_network_id
        );
        rul_api_param_pkg.set_param(
            io_params         => l_param_tab
          , i_name            => 'STTL_TYPE'
          , i_value           => o_sttl_type
        );
        rul_api_param_pkg.set_param(
            io_params         => l_param_tab
          , i_name            => 'TERMINAL_TYPE'
          , i_value           => i_terminal_type
        );
        rul_api_param_pkg.set_param(
            io_params         => l_param_tab
          , i_name            => 'TERMINAL_NUMBER'
          , i_value           => i_terminal_number
        );
        rul_api_param_pkg.set_param(
            io_params         => l_param_tab
          , i_name            => 'CARD_NUMBER'
          , i_value           => i_card_number
        );
        rul_api_param_pkg.set_param(
            io_params         => l_param_tab
          , i_name            => 'OPER_REASON'
          , i_value           => i_oper_reason
        );
        rul_api_param_pkg.set_param(
            io_params         => l_param_tab
          , i_name            => 'CAT_LEVEL'
          , i_value           => i_cat_level
        );
        rul_api_param_pkg.set_param(
            io_params         => l_param_tab
          , i_name            => 'CARD_DATA_INPUT_CAP'
          , i_value           => i_card_data_input_cap
        );
        rul_api_param_pkg.set_param(
            io_params         => l_param_tab
          , i_name            => 'CRDH_AUTH_CAP'
          , i_value           => i_crdh_auth_cap
        );
        rul_api_param_pkg.set_param(
            io_params         => l_param_tab
          , i_name            => 'CARD_CAPTURE_CAP'
          , i_value           => i_card_capture_cap
        );
        rul_api_param_pkg.set_param(
            io_params         => l_param_tab
          , i_name            => 'TERMINAL_OPERATING_ENV'
          , i_value           => i_terminal_operating_env
        );
        rul_api_param_pkg.set_param(
            io_params         => l_param_tab
          , i_name            => 'CRDH_PRESENCE'
          , i_value           => i_crdh_presence
        );
        rul_api_param_pkg.set_param(
            io_params         => l_param_tab
          , i_name            => 'CARD_PRESENCE'
          , i_value           => i_card_presence
        );
        rul_api_param_pkg.set_param(
            io_params         => l_param_tab
          , i_name            => 'CARD_DATA_INPUT_MODE'
          , i_value           => i_card_data_input_mode
        );
        rul_api_param_pkg.set_param(
            io_params         => l_param_tab
          , i_name            => 'CRDH_AUTH_METHOD'
          , i_value           => i_crdh_auth_method
        );
        rul_api_param_pkg.set_param(
            io_params         => l_param_tab
          , i_name            => 'CRDH_AUTH_ENTITY'
          , i_value           => i_crdh_auth_entity
        );
        rul_api_param_pkg.set_param(
            io_params         => l_param_tab
          , i_name            => 'CARD_DATA_OUTPUT_CAP'
          , i_value           => i_card_data_output_cap
        );
        rul_api_param_pkg.set_param(
            io_params         => l_param_tab
          , i_name            => 'TERMINAL_OUTPUT_CAP'
          , i_value           => i_terminal_output_cap
        );
        rul_api_param_pkg.set_param(
            io_params         => l_param_tab
          , i_name            => 'PIN_CAPTURE_CAP'
          , i_value           => i_pin_capture_cap
        );
        rul_api_param_pkg.set_param(
            io_params         => l_param_tab
          , i_name            => 'PIN_PRESENCE'
          , i_value           => i_pin_presence
        );
        rul_api_param_pkg.set_param(
            io_params         => l_param_tab
          , i_name            => 'CVV2_PRESENCE'
          , i_value           => i_cvv2_presence
        );
        rul_api_param_pkg.set_param(
            io_params         => l_param_tab
          , i_name            => 'CVC_INDICATOR'
          , i_value           => i_cvc_indicator
        );
        rul_api_param_pkg.set_param(
            io_params         => l_param_tab
          , i_name            => 'POS_ENTRY_MODE'
          , i_value           => i_pos_entry_mode
        );
        rul_api_param_pkg.set_param(
            io_params         => l_param_tab
          , i_name            => 'POS_COND_CODE'
          , i_value           => i_pos_cond_code
        );
        rul_api_param_pkg.set_param(
            io_params         => l_param_tab
          , i_name            => 'DST_CLIENT_ID_TYPE'
          , i_value           => i_dst_client_id_type
        );
        rul_api_param_pkg.set_param(
            io_params         => l_param_tab
          , i_name            => 'CARD_NUMBER'
          , i_value           => i_card_number
        );
        rul_api_param_pkg.set_param(
            io_params         => l_param_tab
          , i_name            => 'EXPIR_DATE'
          , i_value           => io_card_expir_date
        );
        rul_api_param_pkg.set_param(
            io_params         => l_param_tab
          , i_name            => 'CAVV_PRESENCE'
          , i_value           => i_cavv_presence
        );
        rul_api_param_pkg.set_param(
            io_params         => l_param_tab
          , i_name            => 'AAV_PRESENCE'
          , i_value           => i_aav_presence
        );
        rul_api_param_pkg.set_param(
            io_params         => l_param_tab
          , i_name            => 'MERCHANT_NUMBER'
          , i_value           => i_merchant_number
        );
        rul_api_param_pkg.set_param(
            io_params         => l_param_tab
          , i_name            => 'OPER_CURRENCY'
          , i_value           => i_oper_currency
        );
        rul_api_param_pkg.set_param(
            io_params         => l_param_tab
          , i_name            => 'MCC'
          , i_value           => i_mcc
        );
        rul_api_param_pkg.set_param(
            io_params         => l_param_tab
          , i_name            => 'SERVICE_CODE'
          , i_value           => io_card_service_code
        );
        rul_api_param_pkg.set_param(
            io_params         => l_param_tab
          , i_name            => 'ACQ_RESP_CODE'
          , i_value           => i_acq_resp_code
        );

        -- purpose_id
        l_payment_purpose_id := i_payment_purpose_id;

        if l_payment_purpose_id is null and i_payment_order_id is not null then
            select a.purpose_id
              into l_payment_purpose_id
              from pmo_order a
             where a.id = i_payment_order_id;
        end if;

        rul_api_param_pkg.set_param(
            io_params         => l_param_tab
          , i_name            => 'PAYMENT_PURPOSE'
          , i_value           => l_payment_purpose_id
        );

        asc_api_scenario_pkg.get_scenario_id(
            i_param_tab         => l_param_tab
          , o_scenario_id       => o_scenario_id
        );

        if o_scenario_id is null then
            trc_log_pkg.error(
                i_text              => 'CANT_GET_SCENARIO'
              , i_env_param1        => rul_api_param_pkg.serialize_params(l_param_tab)
            );

            l_resp_code := aup_api_const_pkg.RESP_CODE_CANT_GET_SCENARIO;
        else
            trc_log_pkg.debug(
                i_text            => 'Scenario selected [#1]'
              , i_env_param1      => o_scenario_id
              , i_entity_type     => AUT_API_CONST_PKG.ENTITY_TYPE_AUTHORIZATION
              , i_object_id       => i_id
            );
        end if;

        if l_resp_code = aup_api_const_pkg.RESP_CODE_OK then
            if o_card_id is not null then
                aup_api_scheme_pkg.check_issuing_scheme(
                    i_card_id     => o_card_id
                  , i_oper_date   => i_oper_date
                  , i_auth_param  => l_param_tab
                  , o_resp_code   => l_resp_code
                );
                trc_log_pkg.debug('Checking of issuing scheme completed, l_resp_code [' || l_resp_code || ']');

            elsif io_terminal_id is not null or io_merchant_id is not null then
                aup_api_scheme_pkg.check_acquiring_scheme(
                    i_terminal_id  => io_terminal_id
                  , i_merchant_id  => io_merchant_id
                  , i_acq_inst_id  => l_acq_inst_id
                  , i_oper_date    => i_oper_date
                  , i_auth_param   => l_param_tab
                  , o_resp_code    => l_resp_code
                );
                trc_log_pkg.debug('Checking of acquiring scheme completed, l_resp_code [' || l_resp_code || ']');
            end if;
        end if;
    end if;

    if  l_oper_status != opr_api_const_pkg.OPERATION_STATUS_PROCESSING
        and
        l_resp_code = aup_api_const_pkg.RESP_CODE_OK
    then
        l_resp_code := aup_api_const_pkg.RESP_CODE_ERROR;
    end if;

    save_auth(
        i_resp_code         => l_resp_code
    );

    if o_split_hash_iss is not null then
        save_auth_card(
            i_split_hash        => o_split_hash_iss
        );
    end if;

    aup_api_tag_pkg.save_tag(
        i_auth_id  => i_id
      , i_tags     => i_tags
    );

    trc_log_pkg.clear_object;

    trc_log_pkg.debug(
        i_text            => 'Authorization saved. Returning with [#1]'
      , i_env_param1      => l_resp_code
      , i_entity_type     => AUT_API_CONST_PKG.ENTITY_TYPE_AUTHORIZATION
      , i_object_id       => i_id
    );

    return l_resp_code;
exception
    when others then
        trc_log_pkg.debug(
            i_text            => 'UNHANDLED_EXCEPTION'
          , i_env_param1      => sqlerrm
          , i_entity_type     => AUT_API_CONST_PKG.ENTITY_TYPE_AUTHORIZATION
          , i_object_id       => i_id
        );

        save_auth(
            i_resp_code         => aup_api_const_pkg.RESP_CODE_ERROR
        );

        trc_log_pkg.clear_object;

        return aup_api_const_pkg.RESP_CODE_ERROR;
end put_auth;

function update_auth (
    i_id                      in     com_api_type_pkg.t_long_id
  , i_network_refnum          in     com_api_type_pkg.t_rrn := null
  , i_payment_order_id        in     com_api_type_pkg.t_long_id := null
  , i_payment_host_id         in     com_api_type_pkg.t_tiny_id := null
  , i_auth_code               in     com_api_type_pkg.t_auth_code := null
  , i_oper_request_amount     in     com_api_type_pkg.t_money := null
  , i_oper_amount             in     com_api_type_pkg.t_money := null
  , i_oper_currency           in     com_api_type_pkg.t_curr_code := null
  , i_account_number          in     com_api_type_pkg.t_account_number := null
  , i_account_amount          in     com_api_type_pkg.t_money := null
  , i_account_currency        in     com_api_type_pkg.t_curr_code := null
  , i_network_amount          in     com_api_type_pkg.t_money := null
  , i_network_currency        in     com_api_type_pkg.t_curr_code := null
  , i_network_cnvt_date       in     date := null
  , i_addr_verif_result       in     com_api_type_pkg.t_dict_value := null
  , i_acq_device_proc_result  in     com_api_type_pkg.t_dict_value := null
  , i_acq_resp_code           in     com_api_type_pkg.t_dict_value := null
  , i_dst_card_number         in     com_api_type_pkg.t_card_number := null
  , i_dst_card_expir_date     in     date := null
  , i_dst_account_type        in     com_api_type_pkg.t_dict_value := null
  , i_dst_account_number      in     com_api_type_pkg.t_account_number := null
  , i_dst_client_id_type      in     com_api_type_pkg.t_dict_value := null
  , i_dst_client_id_value     in     com_api_type_pkg.t_name := null
  , i_dst_auth_code           in     com_api_type_pkg.t_auth_code := null
  , i_emv_script_status       in     com_api_type_pkg.t_dict_value := null
  , i_tags                    in     aup_api_type_pkg.t_aup_tag_tab
  , i_mcc                     in     com_api_type_pkg.t_mcc := null
  , i_merchant_name           in     com_api_type_pkg.t_name := null
  , i_amounts                 in     com_api_type_pkg.t_raw_data := null
  , i_cvr                     in     com_api_type_pkg.t_param_value := null
  , i_resp_code               in     com_api_type_pkg.t_dict_value := null
  , i_transaction_id          in     com_api_type_pkg.t_auth_long_id default null
) return com_api_type_pkg.t_dict_value is
    l_card_instance_id          com_api_type_pkg.t_medium_id;
begin
    trc_log_pkg.debug(
        i_text       => lower($$PLSQL_UNIT) || '.update_auth: i_id [' || i_id
                     || '], i_amounts [' || substr(i_amounts, 1, 3800)
                     || '], i_resp_code [#1]'
      , i_env_param1 => i_resp_code
    );

    update aut_auth
       set network_amount         = i_network_amount
         , network_currency       = i_network_currency
         , network_cnvt_date      = i_network_cnvt_date
         , addr_verif_result      = i_addr_verif_result
         , acq_device_proc_result = i_acq_device_proc_result
         , acq_resp_code          = i_acq_resp_code
         , amounts                = nvl(i_amounts, amounts)
         , cvr                    = i_cvr
         , resp_code              = nvl(i_resp_code,resp_code)
         , transaction_id         = nvl(i_transaction_id,transaction_id)
     where id                     = i_id;

    update opr_operation
       set network_refnum      = i_network_refnum
         , payment_order_id    = nvl(i_payment_order_id, payment_order_id)
         , payment_host_id     = i_payment_host_id
         , oper_request_amount = i_oper_request_amount
         , oper_amount         = i_oper_amount
         , oper_currency       = i_oper_currency
         , mcc                 = i_mcc
         , merchant_name       = i_merchant_name
     where id                  = i_id;

    if i_account_number is not null or
       i_account_amount is not null or
       i_account_currency is not null or
       i_auth_code is not null or
       i_emv_script_status is not null
    then

        update opr_participant
           set account_number   = i_account_number
             , account_amount   = i_account_amount
             , account_currency = i_account_currency
             , auth_code        = i_auth_code
         where oper_id          = i_id
           and participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
        returning card_instance_id
        into l_card_instance_id;

        emv_api_script_pkg.change_script_status (
            i_object_id     => l_card_instance_id
          , i_entity_type   => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
          , i_status        => i_emv_script_status
        );
    end if;

    if i_dst_card_expir_date is not null or
       i_dst_account_type is not null or
       i_dst_account_number is not null or
       i_dst_auth_code is not null
    then
        update opr_participant
           set card_expir_date  = i_dst_card_expir_date
             , account_type     = i_dst_account_type
             , account_number   = i_dst_account_number
             , auth_code        = i_dst_auth_code
         where oper_id          = i_id
           and participant_type = com_api_const_pkg.PARTICIPANT_DEST;
    end if;

    if i_dst_card_number is not null then
        update opr_card
           set card_number      = iss_api_token_pkg.encode_card_number(i_card_number => i_dst_card_number)
         where oper_id          = i_id
           and participant_type = com_api_const_pkg.PARTICIPANT_DEST;
    end if;

    aup_api_tag_pkg.save_tag (
        i_auth_id  => i_id
      , i_tags     => i_tags
    );

    return aup_api_const_pkg.RESP_CODE_OK;
exception
    when others then
        trc_log_pkg.debug (
            i_text              => 'UNHANDLED_EXCEPTION'
            , i_env_param1      => sqlerrm
            , i_entity_type     => AUT_API_CONST_PKG.ENTITY_TYPE_AUTHORIZATION
            , i_object_id       => i_id
        );

        return aup_api_const_pkg.RESP_CODE_ERROR;
end update_auth;

function finalize (
    i_id                 in     com_api_type_pkg.t_long_id
  , i_oper_type          in     com_api_type_pkg.t_dict_value
  , i_msg_type           in     com_api_type_pkg.t_dict_value
  , i_is_reversal        in     com_api_type_pkg.t_boolean
  , i_resp_code          in     com_api_type_pkg.t_dict_value
  , i_is_completed       in     com_api_type_pkg.t_dict_value
  , i_auth_code          in     com_api_type_pkg.t_auth_code
  , i_payment_order_id   in     com_api_type_pkg.t_long_id    default null
  , i_payment_host_id    in     com_api_type_pkg.t_tiny_id    default null
  , i_cvv2_result        in     com_api_type_pkg.t_dict_value default null
  , i_sttl_type          in     com_api_type_pkg.t_dict_value default null
  , i_oper_reason        in     com_api_type_pkg.t_dict_value default null
) return com_api_type_pkg.t_dict_value is
    l_status                    com_api_type_pkg.t_dict_value;
    l_status_reason             com_api_type_pkg.t_dict_value;
    l_proc_mode                 com_api_type_pkg.t_dict_value;
    l_proc_type                 com_api_type_pkg.t_dict_value;
    l_rowcount                  com_api_type_pkg.t_count := 0;
begin
    trc_log_pkg.debug (
        i_text                  => 'finalizing auth [#2] with resp [#1]'
        , i_env_param1          => i_resp_code
        , i_env_param2          => i_id
    );

    aut_api_load_pkg.get_status_by_resp (
        i_resp_code             => i_resp_code
        , i_oper_type           => i_oper_type
        , i_msg_type            => i_msg_type
        , i_is_reversal         => i_is_reversal
        , i_is_completed        => i_is_completed
        , i_sttl_type           => i_sttl_type
        , i_oper_reason         => i_oper_reason
        , o_status              => l_status
        , o_status_reason       => l_status_reason
        , o_proc_mode           => l_proc_mode
        , o_proc_type           => l_proc_type
    );

    trc_log_pkg.debug (
        i_text                  => 'status according to resp code: [#1][#2][#3][#4][#5][#6]'
        , i_env_param1          => i_resp_code
        , i_env_param2          => i_is_reversal
        , i_env_param3          => l_status
        , i_env_param4          => l_status_reason
        , i_env_param5          => l_proc_mode
        , i_env_param6          => l_proc_type
    );

    update opr_operation
       set status = case
                    when l_status in (opr_api_const_pkg.OPERATION_STATUS_PROCESSED, 
                                      opr_api_const_pkg.OPERATION_STATUS_AUTHORIZED) 
                     and unhold_date is not null 
                    then opr_api_const_pkg.OPERATION_STATUS_AWAITS_UNHOLD
                    else l_status
                 end
         , status_reason    = l_status_reason
         , payment_order_id = nvl(i_payment_order_id, payment_order_id)
         , payment_host_id  = i_payment_host_id
     where id               = i_id
       and status           = opr_api_const_pkg.OPERATION_STATUS_PROCESSING;

    l_rowcount := sql%rowcount;

    if l_rowcount > 0 then

        update aut_auth
           set proc_mode        = l_proc_mode
             , proc_type        = l_proc_type
             , is_completed     = i_is_completed
             , resp_code        = i_resp_code
             , cvv2_result      = i_cvv2_result
         where id               = i_id;

        update opr_operation
           set proc_mode        = l_proc_mode
         where id               = i_id;

        update opr_participant
           set auth_code        = i_auth_code
         where oper_id          = i_id
           and participant_type = com_api_const_pkg.PARTICIPANT_ISSUER;

    end if;

    trc_log_pkg.debug (
        i_text                  => '[#1] auth updated'
        , i_env_param1          => l_rowcount
    );

    if l_rowcount = 0 then
        raise no_data_found;
    end if;

    return aup_api_const_pkg.RESP_CODE_OK;
exception
    when others then
        trc_log_pkg.debug (
            i_text              => 'UNHANDLED_EXCEPTION'
            , i_env_param1      => sqlerrm
            , i_entity_type     => AUT_API_CONST_PKG.ENTITY_TYPE_AUTHORIZATION
            , i_object_id       => i_id
        );

        return aup_api_const_pkg.RESP_CODE_ERROR;
end finalize;

procedure get_card_auths (
    i_id            in com_api_type_pkg.t_long_id default null
  , i_card_id       in  com_api_type_pkg.t_medium_id
  , i_limit         in  com_api_type_pkg.t_tiny_id
  , i_null_amounts  in  com_api_type_pkg.t_boolean   default com_api_const_pkg.FALSE
  , o_auth_tab      out aup_api_type_pkg.t_auth_stmt_tab
) is
begin
    if i_id is not null then
        trc_log_pkg.set_object (
            i_entity_type  => opr_api_const_pkg.ENTITY_TYPE_OPERATION
            , i_object_id  => i_id
        );
    end if;

    trc_log_pkg.debug (
        i_text                  => 'Ministatement request [#1][#2]'
        , i_env_param1          => i_card_id
        , i_env_param2          => i_limit
    );

    select auth_id
         , card_id
         , oper_date
         , host_date
         , oper_type
         , auth_code
         , oper_amount
         , oper_currency
         , account_amount
         , account_currency
         , terminal_number
         , merchant_number
         , merchant_name
         , merchant_street
         , merchant_city
         , merchant_region
         , merchant_country
         , merchant_postcode
         , is_reversal
      bulk collect into
           o_auth_tab
      from (
            select o.id auth_id
                 , p.card_id
                 , o.oper_date
                 , o.host_date
                 , o.oper_type
                 , p.auth_code
                 , o.oper_amount
                 , o.oper_currency
                 , p.account_amount
                 , p.account_currency
                 , o.terminal_number
                 , o.merchant_number
                 , o.merchant_name
                 , o.merchant_street
                 , o.merchant_city
                 , o.merchant_region
                 , o.merchant_country
                 , o.merchant_postcode
                 , o.is_reversal
              from opr_operation o
                 , opr_participant p
                 , ( select distinct a.inst_id
                       from com_array a, com_array_element ae
                      where a.array_type_id = 1003
                        and ae.array_id = a.id
                   ) ar
             where p.card_id = i_card_id
               and p.oper_id = o.id
               and o.id != i_id
               and p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
               and o.msg_type = opr_api_const_pkg.MESSAGE_TYPE_AUTHORIZATION
               and o.status in (select e.element_value 
                                  from com_array_element e
                                 where e.array_id = opr_api_const_pkg.OPER_STATUS_ARRAY_ID)
               and p.inst_id = ar.inst_id(+) 
               and ((ar.inst_id is null)
                     or
                    (ar.inst_id is not null and
                     o.oper_type in (
                                    select ae.element_value 
                                      from com_array a, com_array_element ae
                                     where a.array_type_id = 1003
                                       and ae.array_id = a.id
                                       and a.inst_id = p.inst_id
                                    )
                    )
                   )
               and (i_null_amounts = com_api_const_pkg.FALSE 
                    or 
                   (i_null_amounts = com_api_const_pkg.TRUE and nvl(o.oper_amount, 0) <> 0))    
             order by host_date desc
                    , oper_date desc
           )
     where rownum <= i_limit;

    trc_log_pkg.debug (
        i_text                  => '[#1] auth returned'
        , i_env_param1          => o_auth_tab.count
    );

    if i_id is not null then
        trc_log_pkg.clear_object;
    end if;
end get_card_auths;

procedure get_account_auths (
  i_id                        in com_api_type_pkg.t_long_id default null
  , i_account_id            in      com_api_type_pkg.t_account_id
  , i_limit                 in      com_api_type_pkg.t_tiny_id
  , i_null_amounts          in      com_api_type_pkg.t_boolean   default com_api_const_pkg.FALSE
  , o_auth_tab              out     aup_api_type_pkg.t_auth_stmt_tab
) is
begin
    if i_id is not null then
        trc_log_pkg.set_object (
            i_entity_type  => opr_api_const_pkg.ENTITY_TYPE_OPERATION
            , i_object_id  => i_id
        );
    end if;

    trc_log_pkg.debug (
        i_text                  => 'Ministatement request [#1][#2]'
        , i_env_param1          => i_account_id
        , i_env_param2          => i_limit
    );

    select auth_id
         , card_id
         , oper_date
         , host_date
         , oper_type
         , auth_code
         , oper_amount
         , oper_currency
         , account_amount
         , account_currency
         , terminal_number
         , merchant_number
         , merchant_name
         , merchant_street
         , merchant_city
         , merchant_region
         , merchant_country
         , merchant_postcode
         , is_reversal
      bulk collect into
           o_auth_tab
      from (
            select o.id auth_id
                 , p.card_id
                 , o.oper_date
                 , o.host_date
                 , o.oper_type
                 , p.auth_code
                 , o.oper_amount
                 , o.oper_currency
                 , p.account_amount
                 , p.account_currency
                 , o.terminal_number
                 , o.merchant_number
                 , o.merchant_name
                 , o.merchant_street
                 , o.merchant_city
                 , o.merchant_region
                 , o.merchant_country
                 , o.merchant_postcode
                 , o.is_reversal
              from opr_operation o
                 , opr_participant p
             where p.account_id = i_account_id
               and p.oper_id = o.id
               and p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
               and o.msg_type = opr_api_const_pkg.MESSAGE_TYPE_AUTHORIZATION
               and o.status in (select e.element_value 
                                  from com_array_element e
                                 where e.array_id = opr_api_const_pkg.OPER_STATUS_ARRAY_ID)
               and (i_null_amounts = com_api_const_pkg.FALSE 
                    or 
                   (i_null_amounts = com_api_const_pkg.TRUE and nvl(o.oper_amount, 0) <> 0))
             order by host_date desc
                    , oper_date desc
           )
     where rownum <= i_limit;

    trc_log_pkg.debug (
        i_text                  => '[#1] auth returned'
        , i_env_param1          => o_auth_tab.count
    );

    if i_id is not null then
        trc_log_pkg.clear_object;
    end if;
end get_account_auths;

function find_auth (
    i_parent_id                 in com_api_type_pkg.t_long_id
    , i_oper_type               in com_api_type_pkg.t_dict_value
    , o_id                      out com_api_type_pkg.t_long_id
    , o_split_hash              out com_api_type_pkg.t_tiny_id
    , o_is_reversal             out com_api_type_pkg.t_boolean
    , o_original_id             out com_api_type_pkg.t_long_id
    , o_msg_type                out com_api_type_pkg.t_dict_value
    , o_sttl_type               out com_api_type_pkg.t_dict_value
    , o_is_advice               out com_api_type_pkg.t_boolean
    , o_is_repeat               out com_api_type_pkg.t_boolean
    , o_host_date               out date
    , o_oper_date               out date
    , o_oper_count              out com_api_type_pkg.t_short_id
    , o_oper_request_amount     out com_api_type_pkg.t_money
    , o_oper_amount_algorithm   out com_api_type_pkg.t_dict_value
    , o_oper_amount             out com_api_type_pkg.t_money
    , o_oper_currency           out com_api_type_pkg.t_curr_code
    , o_oper_cashback_amount    out com_api_type_pkg.t_money
    , o_oper_replacement_amount out com_api_type_pkg.t_money
    , o_oper_surcharge_amount   out com_api_type_pkg.t_money
    , o_client_id_type          out com_api_type_pkg.t_dict_value
    , o_client_id_value         out com_api_type_pkg.t_name
    , o_iss_inst_id             out com_api_type_pkg.t_inst_id
    , o_iss_network_id          out com_api_type_pkg.t_network_id
    , o_iss_host_id             out com_api_type_pkg.t_tiny_id
    , o_iss_network_device_id   out com_api_type_pkg.t_short_id
    , o_split_hash_iss          out com_api_type_pkg.t_tiny_id
    , o_card_inst_id            out com_api_type_pkg.t_inst_id
    , o_card_network_id         out com_api_type_pkg.t_network_id
    , o_card_number             out com_api_type_pkg.t_card_number
    , o_card_id                 out com_api_type_pkg.t_medium_id
    , o_card_instance_id        out com_api_type_pkg.t_medium_id
    , o_card_type_id            out com_api_type_pkg.t_tiny_id
    , o_card_mask               out com_api_type_pkg.t_card_number
    , o_card_hash               out com_api_type_pkg.t_medium_id
    , o_card_seq_number         out com_api_type_pkg.t_tiny_id
    , o_card_expir_date         out date
    , o_card_service_code       out com_api_type_pkg.t_curr_code
    , o_card_country            out com_api_type_pkg.t_country_code
    , o_customer_id             out com_api_type_pkg.t_medium_id
    , o_account_id              out com_api_type_pkg.t_medium_id
    , o_account_type            out com_api_type_pkg.t_dict_value
    , o_account_number          out com_api_type_pkg.t_account_number
    , o_account_amount          out com_api_type_pkg.t_money
    , o_account_currency        out com_api_type_pkg.t_curr_code
    , o_account_cnvt_rate       out com_api_type_pkg.t_money
    , o_bin_amount              out com_api_type_pkg.t_money
    , o_bin_currency            out com_api_type_pkg.t_curr_code
    , o_bin_cnvt_rate           out com_api_type_pkg.t_money
    , o_network_amount          out com_api_type_pkg.t_money
    , o_network_currency        out com_api_type_pkg.t_curr_code
    , o_network_cnvt_date       out date
    , o_network_cnvt_rate       out com_api_type_pkg.t_money
    , o_addr_verif_result       out com_api_type_pkg.t_dict_value
    , o_auth_code               out com_api_type_pkg.t_auth_code
    , o_dst_client_id_type      out com_api_type_pkg.t_dict_value
    , o_dst_client_id_value     out com_api_type_pkg.t_name
    , o_dst_inst_id             out com_api_type_pkg.t_inst_id
    , o_dst_network_id          out com_api_type_pkg.t_network_id
    , o_dst_card_inst_id        out com_api_type_pkg.t_inst_id
    , o_dst_card_network_id     out com_api_type_pkg.t_network_id
    , o_dst_card_number         out com_api_type_pkg.t_card_number
    , o_dst_card_id             out com_api_type_pkg.t_medium_id
    , o_dst_card_instance_id    out com_api_type_pkg.t_medium_id
    , o_dst_card_type_id        out com_api_type_pkg.t_tiny_id
    , o_dst_card_mask           out com_api_type_pkg.t_card_number
    , o_dst_card_hash           out com_api_type_pkg.t_medium_id
    , o_dst_card_seq_number     out com_api_type_pkg.t_tiny_id
    , o_dst_card_expir_date     out date
    , o_dst_card_service_code   out com_api_type_pkg.t_curr_code
    , o_dst_card_country        out com_api_type_pkg.t_country_code
    , o_dst_customer_id         out com_api_type_pkg.t_medium_id
    , o_dst_account_id          out com_api_type_pkg.t_medium_id
    , o_dst_account_type        out com_api_type_pkg.t_dict_value
    , o_dst_account_number      out com_api_type_pkg.t_account_number
    , o_dst_account_amount      out com_api_type_pkg.t_money
    , o_dst_account_currency    out com_api_type_pkg.t_curr_code
    , o_dst_auth_code           out com_api_type_pkg.t_auth_code
    , o_acq_device_id           out com_api_type_pkg.t_short_id
    , o_acq_resp_code           out com_api_type_pkg.t_dict_value
    , o_acq_device_proc_result  out com_api_type_pkg.t_dict_value
    , o_acq_inst_bin            out com_api_type_pkg.t_cmid
    , o_forw_inst_bin           out com_api_type_pkg.t_cmid
    , o_acq_inst_id             out com_api_type_pkg.t_inst_id
    , o_acq_network_id          out com_api_type_pkg.t_network_id
    , o_split_hash_acq          out com_api_type_pkg.t_tiny_id
    , o_merchant_id             out com_api_type_pkg.t_short_id
    , o_merchant_number         out com_api_type_pkg.t_merchant_number
    , o_terminal_type           out com_api_type_pkg.t_dict_value
    , o_terminal_number         out com_api_type_pkg.t_terminal_number
    , o_terminal_id             out com_api_type_pkg.t_short_id
    , o_merchant_name           out com_api_type_pkg.t_name
    , o_merchant_street         out com_api_type_pkg.t_name
    , o_merchant_city           out com_api_type_pkg.t_name
    , o_merchant_region         out com_api_type_pkg.t_module_code
    , o_merchant_country        out com_api_type_pkg.t_country_code
    , o_merchant_postcode       out com_api_type_pkg.t_postal_code
    , o_cat_level               out com_api_type_pkg.t_dict_value
    , o_mcc                     out com_api_type_pkg.t_mcc
    , o_originator_refnum       out com_api_type_pkg.t_rrn
    , o_network_refnum          out com_api_type_pkg.t_rrn
    , o_card_data_input_cap     out com_api_type_pkg.t_dict_value
    , o_crdh_auth_cap           out com_api_type_pkg.t_dict_value
    , o_card_capture_cap        out com_api_type_pkg.t_dict_value
    , o_terminal_operating_env  out com_api_type_pkg.t_dict_value
    , o_crdh_presence           out com_api_type_pkg.t_dict_value
    , o_card_presence           out com_api_type_pkg.t_dict_value
    , o_card_data_input_mode    out com_api_type_pkg.t_dict_value
    , o_crdh_auth_method        out com_api_type_pkg.t_dict_value
    , o_crdh_auth_entity        out com_api_type_pkg.t_dict_value
    , o_card_data_output_cap    out com_api_type_pkg.t_dict_value
    , o_terminal_output_cap     out com_api_type_pkg.t_dict_value
    , o_pin_capture_cap         out com_api_type_pkg.t_dict_value
    , o_pin_presence            out com_api_type_pkg.t_dict_value
    , o_cvv2_presence           out com_api_type_pkg.t_dict_value
    , o_cvc_indicator           out com_api_type_pkg.t_dict_value
    , o_pos_entry_mode          out com_api_type_pkg.t_module_code
    , o_pos_cond_code           out com_api_type_pkg.t_module_code
    , o_emv_data                out com_api_type_pkg.t_param_value
    , o_atc                     out com_api_type_pkg.t_dict_value
    , o_tvr                     out com_api_type_pkg.t_param_value
    , o_cvr                     out com_api_type_pkg.t_param_value
    , o_addl_data               out com_api_type_pkg.t_param_value
    , o_amounts                 out com_api_type_pkg.t_raw_data
    , o_resp_code               out com_api_type_pkg.t_dict_value
    , o_cavv_presence           out com_api_type_pkg.t_dict_value
    , o_aav_presence            out com_api_type_pkg.t_dict_value
    , o_transaction_id          out com_api_type_pkg.t_auth_long_id 
) return com_api_type_pkg.t_dict_value is
begin
    select
        min(a.id)
        , min(null)
        , min(o.is_reversal)
        , min(o.original_id)
        , min(o.msg_type)
        , min(o.sttl_type)
        , min(a.is_advice)
        , min(a.is_repeat)
        , min(o.host_date)
        , min(o.oper_date)
        , min(o.oper_count)
        , min(o.oper_request_amount)
        , min(o.oper_amount_algorithm)
        , min(o.oper_amount)
        , min(o.oper_currency)
        , min(o.oper_cashback_amount)
        , min(o.oper_replacement_amount)
        , min(o.oper_surcharge_amount)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER then p.client_id_type     else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER then p.client_id_value    else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER then p.inst_id            else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER then p.network_id         else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER then
                net_api_network_pkg.get_member_id(
                    i_inst_id       => p.inst_id
                    , i_network_id  => p.network_id
                    , i_participant_type => com_api_const_pkg.PARTICIPANT_ISSUER
                )
                else null 
            end)
        , min(a.iss_network_device_id)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER then p.split_hash         else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER then p.card_inst_id       else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER then p.card_network_id    else null end)
        , min(case when c.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
                   then iss_api_token_pkg.decode_card_number(i_card_number => c.card_number)        
                   else null
              end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER then p.card_id            else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER then p.card_instance_id   else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER then p.card_type_id       else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER then p.card_mask          else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER then p.card_hash          else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER then p.card_seq_number    else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER then p.card_expir_date    else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER then p.card_service_code  else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER then p.card_country       else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER then p.customer_id        else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER then p.account_id         else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER then p.account_type       else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER then p.account_number     else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER then p.account_amount     else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER then p.account_currency   else null end)
        , min(a.account_cnvt_rate)
        , min(a.bin_amount)
        , min(a.bin_currency)
        , min(a.bin_cnvt_rate)
        , min(a.network_amount)
        , min(a.network_currency)
        , min(a.network_cnvt_date)
        , min(a.network_cnvt_rate)
        , min(a.addr_verif_result)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER then p.auth_code      else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_DEST then p.client_id_type   else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_DEST then p.client_id_value  else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_DEST then p.inst_id          else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_DEST then p.network_id       else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_DEST then p.card_inst_id     else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_DEST then p.card_network_id  else null end)
        , min(case when c.participant_type = com_api_const_pkg.PARTICIPANT_DEST
                   then iss_api_token_pkg.decode_card_number(i_card_number => c.card_number)
                   else null
              end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_DEST then p.card_id          else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_DEST then p.card_instance_id else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_DEST then p.card_type_id     else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_DEST then p.card_mask        else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_DEST then p.card_hash        else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_DEST then p.card_seq_number  else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_DEST then p.card_expir_date  else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_DEST then p.card_service_code else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_DEST then p.card_country     else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_DEST then p.customer_id      else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_DEST then p.account_id       else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_DEST then p.account_type     else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_DEST then p.account_number   else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_DEST then p.account_amount   else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_DEST then p.account_currency else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_DEST then p.auth_code        else null end)
        , min(a.acq_device_id)
        , min(a.acq_resp_code)
        , min(a.acq_device_proc_result)
        , min(o.acq_inst_bin)
        , min(o.forw_inst_bin)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER then p.inst_id      else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER then p.network_id   else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER then p.split_hash   else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER then p.merchant_id  else null end)
        , min(o.merchant_number)
        , min(o.terminal_type)
        , min(o.terminal_number)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER then p.terminal_id  else null end)
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
        , min(a.emv_data)
        , min(a.atc)
        , min(a.tvr)
        , min(a.cvr)
        , min(a.addl_data)
        , min(a.amounts)
        , min(a.resp_code)
        , min(a.cavv_presence)
        , min(a.aav_presence)
        , min(a.transaction_id)
    into
        o_id
        , o_split_hash
        , o_is_reversal
        , o_original_id
        , o_msg_type
        , o_sttl_type
        , o_is_advice
        , o_is_repeat
        , o_host_date
        , o_oper_date
        , o_oper_count
        , o_oper_request_amount
        , o_oper_amount_algorithm
        , o_oper_amount
        , o_oper_currency
        , o_oper_cashback_amount
        , o_oper_replacement_amount
        , o_oper_surcharge_amount
        , o_client_id_type
        , o_client_id_value
        , o_iss_inst_id
        , o_iss_network_id
        , o_iss_host_id
        , o_iss_network_device_id
        , o_split_hash_iss
        , o_card_inst_id
        , o_card_network_id
        , o_card_number
        , o_card_id
        , o_card_instance_id
        , o_card_type_id
        , o_card_mask
        , o_card_hash
        , o_card_seq_number
        , o_card_expir_date
        , o_card_service_code
        , o_card_country
        , o_customer_id
        , o_account_id
        , o_account_type
        , o_account_number
        , o_account_amount
        , o_account_currency
        , o_account_cnvt_rate
        , o_bin_amount
        , o_bin_currency
        , o_bin_cnvt_rate
        , o_network_amount
        , o_network_currency
        , o_network_cnvt_date
        , o_network_cnvt_rate
        , o_addr_verif_result
        , o_auth_code
        , o_dst_client_id_type
        , o_dst_client_id_value
        , o_dst_inst_id
        , o_dst_network_id
        , o_dst_card_inst_id
        , o_dst_card_network_id
        , o_dst_card_number
        , o_dst_card_id
        , o_dst_card_instance_id
        , o_dst_card_type_id
        , o_dst_card_mask
        , o_dst_card_hash
        , o_dst_card_seq_number
        , o_dst_card_expir_date
        , o_dst_card_service_code
        , o_dst_card_country
        , o_dst_customer_id
        , o_dst_account_id
        , o_dst_account_type
        , o_dst_account_number
        , o_dst_account_amount
        , o_dst_account_currency
        , o_dst_auth_code
        , o_acq_device_id
        , o_acq_resp_code
        , o_acq_device_proc_result
        , o_acq_inst_bin
        , o_forw_inst_bin
        , o_acq_inst_id
        , o_acq_network_id
        , o_split_hash_acq
        , o_merchant_id
        , o_merchant_number
        , o_terminal_type
        , o_terminal_number
        , o_terminal_id
        , o_merchant_name
        , o_merchant_street
        , o_merchant_city
        , o_merchant_region
        , o_merchant_country
        , o_merchant_postcode
        , o_cat_level
        , o_mcc
        , o_originator_refnum
        , o_network_refnum
        , o_card_data_input_cap
        , o_crdh_auth_cap
        , o_card_capture_cap
        , o_terminal_operating_env
        , o_crdh_presence
        , o_card_presence
        , o_card_data_input_mode
        , o_crdh_auth_method
        , o_crdh_auth_entity
        , o_card_data_output_cap
        , o_terminal_output_cap
        , o_pin_capture_cap
        , o_pin_presence
        , o_cvv2_presence
        , o_cvc_indicator
        , o_pos_entry_mode
        , o_pos_cond_code
        , o_emv_data
        , o_atc
        , o_tvr
        , o_cvr
        , o_addl_data
        , o_amounts
        , o_resp_code
        , o_cavv_presence
        , o_aav_presence
        , o_transaction_id
    from aut_auth a
       , opr_operation o
       , opr_participant p
       , opr_card c
   where a.parent_id = i_parent_id
     and o.oper_type = i_oper_type
     and a.id = o.id
     and a.id = p.oper_id
     and p.oper_id = c.oper_id(+)
     and p.participant_type = c.participant_type(+);
    --
    return aup_api_const_pkg.RESP_CODE_OK;
exception
    when others then
        trc_log_pkg.debug (
            i_text              => 'UNHANDLED_EXCEPTION'
            , i_env_param1      => sqlerrm
            , i_entity_type     => AUT_API_CONST_PKG.ENTITY_TYPE_AUTHORIZATION
            , i_object_id       => i_parent_id
        );

        return aup_api_const_pkg.RESP_CODE_ERROR;
end find_auth;

function get_auth (
    i_id                        in com_api_type_pkg.t_long_id
    , o_split_hash              out com_api_type_pkg.t_tiny_id
    , o_is_reversal             out com_api_type_pkg.t_boolean
    , o_original_id             out com_api_type_pkg.t_long_id
    , o_parent_id               out com_api_type_pkg.t_long_id
    , o_msg_type                out com_api_type_pkg.t_dict_value
    , o_oper_type               out com_api_type_pkg.t_dict_value
    , o_sttl_type               out com_api_type_pkg.t_dict_value
    , o_is_advice               out com_api_type_pkg.t_boolean
    , o_is_repeat               out com_api_type_pkg.t_boolean
    , o_host_date               out date
    , o_oper_date               out date
    , o_oper_count              out com_api_type_pkg.t_short_id
    , o_oper_request_amount     out com_api_type_pkg.t_money
    , o_oper_amount_algorithm   out com_api_type_pkg.t_dict_value
    , o_oper_amount             out com_api_type_pkg.t_money
    , o_oper_currency           out com_api_type_pkg.t_curr_code
    , o_oper_cashback_amount    out com_api_type_pkg.t_money
    , o_oper_replacement_amount out com_api_type_pkg.t_money
    , o_oper_surcharge_amount   out com_api_type_pkg.t_money
    , o_client_id_type          out com_api_type_pkg.t_dict_value
    , o_client_id_value         out com_api_type_pkg.t_name
    , o_iss_inst_id             out com_api_type_pkg.t_inst_id
    , o_iss_network_id          out com_api_type_pkg.t_network_id
    , o_iss_host_id             out com_api_type_pkg.t_tiny_id
    , o_iss_network_device_id   out com_api_type_pkg.t_short_id
    , o_split_hash_iss          out com_api_type_pkg.t_tiny_id
    , o_card_inst_id            out com_api_type_pkg.t_inst_id
    , o_card_network_id         out com_api_type_pkg.t_network_id
    , o_card_number             out com_api_type_pkg.t_card_number
    , o_card_id                 out com_api_type_pkg.t_medium_id
    , o_card_instance_id        out com_api_type_pkg.t_medium_id
    , o_card_type_id            out com_api_type_pkg.t_tiny_id
    , o_card_mask               out com_api_type_pkg.t_card_number
    , o_card_hash               out com_api_type_pkg.t_medium_id
    , o_card_seq_number         out com_api_type_pkg.t_tiny_id
    , o_card_expir_date         out date
    , o_card_service_code       out com_api_type_pkg.t_curr_code
    , o_card_country            out com_api_type_pkg.t_country_code
    , o_customer_id             out com_api_type_pkg.t_medium_id
    , o_account_id              out com_api_type_pkg.t_medium_id
    , o_account_type            out com_api_type_pkg.t_dict_value
    , o_account_number          out com_api_type_pkg.t_account_number
    , o_account_amount          out com_api_type_pkg.t_money
    , o_account_currency        out com_api_type_pkg.t_curr_code
    , o_account_cnvt_rate       out com_api_type_pkg.t_money
    , o_bin_amount              out com_api_type_pkg.t_money
    , o_bin_currency            out com_api_type_pkg.t_curr_code
    , o_bin_cnvt_rate           out com_api_type_pkg.t_money
    , o_network_amount          out com_api_type_pkg.t_money
    , o_network_currency        out com_api_type_pkg.t_curr_code
    , o_network_cnvt_date       out date
    , o_network_cnvt_rate       out com_api_type_pkg.t_money
    , o_addr_verif_result       out com_api_type_pkg.t_dict_value
    , o_auth_code               out com_api_type_pkg.t_auth_code
    , o_dst_client_id_type      out com_api_type_pkg.t_dict_value
    , o_dst_client_id_value     out com_api_type_pkg.t_name
    , o_dst_inst_id             out com_api_type_pkg.t_inst_id
    , o_dst_network_id          out com_api_type_pkg.t_network_id
    , o_dst_card_inst_id        out com_api_type_pkg.t_inst_id
    , o_dst_card_network_id     out com_api_type_pkg.t_network_id
    , o_dst_card_number         out com_api_type_pkg.t_card_number
    , o_dst_card_id             out com_api_type_pkg.t_medium_id
    , o_dst_card_instance_id    out com_api_type_pkg.t_medium_id
    , o_dst_card_type_id        out com_api_type_pkg.t_tiny_id
    , o_dst_card_mask           out com_api_type_pkg.t_card_number
    , o_dst_card_hash           out com_api_type_pkg.t_medium_id
    , o_dst_card_seq_number     out com_api_type_pkg.t_tiny_id
    , o_dst_card_expir_date     out date
    , o_dst_card_service_code   out com_api_type_pkg.t_curr_code
    , o_dst_card_country        out com_api_type_pkg.t_country_code
    , o_dst_customer_id         out com_api_type_pkg.t_medium_id
    , o_dst_account_id          out com_api_type_pkg.t_medium_id
    , o_dst_account_type        out com_api_type_pkg.t_dict_value
    , o_dst_account_number      out com_api_type_pkg.t_account_number
    , o_dst_account_amount      out com_api_type_pkg.t_money
    , o_dst_account_currency    out com_api_type_pkg.t_curr_code
    , o_dst_auth_code           out com_api_type_pkg.t_auth_code
    , o_acq_device_id           out com_api_type_pkg.t_short_id
    , o_acq_resp_code           out com_api_type_pkg.t_dict_value
    , o_acq_device_proc_result  out com_api_type_pkg.t_dict_value
    , o_acq_inst_bin            out com_api_type_pkg.t_cmid
    , o_forw_inst_bin           out com_api_type_pkg.t_cmid
    , o_acq_inst_id             out com_api_type_pkg.t_inst_id
    , o_acq_network_id          out com_api_type_pkg.t_network_id
    , o_split_hash_acq          out com_api_type_pkg.t_tiny_id
    , o_merchant_id             out com_api_type_pkg.t_short_id
    , o_merchant_number         out com_api_type_pkg.t_merchant_number
    , o_terminal_type           out com_api_type_pkg.t_dict_value
    , o_terminal_number         out com_api_type_pkg.t_terminal_number
    , o_terminal_id             out com_api_type_pkg.t_short_id
    , o_merchant_name           out com_api_type_pkg.t_name
    , o_merchant_street         out com_api_type_pkg.t_name
    , o_merchant_city           out com_api_type_pkg.t_name
    , o_merchant_region         out com_api_type_pkg.t_module_code
    , o_merchant_country        out com_api_type_pkg.t_country_code
    , o_merchant_postcode       out com_api_type_pkg.t_postal_code
    , o_cat_level               out com_api_type_pkg.t_dict_value
    , o_mcc                     out com_api_type_pkg.t_mcc
    , o_originator_refnum       out com_api_type_pkg.t_rrn
    , o_network_refnum          out com_api_type_pkg.t_rrn
    , o_card_data_input_cap     out com_api_type_pkg.t_dict_value
    , o_crdh_auth_cap           out com_api_type_pkg.t_dict_value
    , o_card_capture_cap        out com_api_type_pkg.t_dict_value
    , o_terminal_operating_env  out com_api_type_pkg.t_dict_value
    , o_crdh_presence           out com_api_type_pkg.t_dict_value
    , o_card_presence           out com_api_type_pkg.t_dict_value
    , o_card_data_input_mode    out com_api_type_pkg.t_dict_value
    , o_crdh_auth_method        out com_api_type_pkg.t_dict_value
    , o_crdh_auth_entity        out com_api_type_pkg.t_dict_value
    , o_card_data_output_cap    out com_api_type_pkg.t_dict_value
    , o_terminal_output_cap     out com_api_type_pkg.t_dict_value
    , o_pin_capture_cap         out com_api_type_pkg.t_dict_value
    , o_pin_presence            out com_api_type_pkg.t_dict_value
    , o_cvv2_presence           out com_api_type_pkg.t_dict_value
    , o_cvc_indicator           out com_api_type_pkg.t_dict_value
    , o_pos_entry_mode          out com_api_type_pkg.t_module_code
    , o_pos_cond_code           out com_api_type_pkg.t_module_code
    , o_emv_data                out com_api_type_pkg.t_param_value
    , o_atc                     out com_api_type_pkg.t_dict_value
    , o_tvr                     out com_api_type_pkg.t_param_value
    , o_cvr                     out com_api_type_pkg.t_param_value
    , o_addl_data               out com_api_type_pkg.t_param_value
    , o_amounts                 out com_api_type_pkg.t_raw_data
    , o_purpose_id              out com_api_type_pkg.t_short_id
    , o_resp_code               out com_api_type_pkg.t_dict_value
    , o_cavv_presence           out com_api_type_pkg.t_dict_value
    , o_aav_presence            out com_api_type_pkg.t_dict_value
    , o_transaction_id          out com_api_type_pkg.t_auth_long_id 
) return com_api_type_pkg.t_dict_value is
begin
    select
          min(null)
        , min(o.is_reversal)
        , min(o.original_id)
        , min(a.parent_id)
        , min(o.msg_type)
        , min(o.oper_type)
        , min(o.sttl_type)
        , min(a.is_advice)
        , min(a.is_repeat)
        , min(o.host_date)
        , min(o.oper_date)
        , min(o.oper_count)
        , min(o.oper_request_amount)
        , min(o.oper_amount_algorithm)
        , min(o.oper_amount)
        , min(o.oper_currency)
        , min(o.oper_cashback_amount)
        , min(o.oper_replacement_amount)
        , min(o.oper_surcharge_amount)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER then p.client_id_type     else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER then p.client_id_value    else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER then p.inst_id            else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER then p.network_id         else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER then
                net_api_network_pkg.get_member_id(
                    i_inst_id       => p.inst_id
                    , i_network_id  => p.network_id
                    , i_participant_type => com_api_const_pkg.PARTICIPANT_ISSUER
                )
                else null 
            end) 
        , min(a.iss_network_device_id)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER then p.split_hash         else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER then p.card_inst_id       else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER then p.card_network_id    else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
                   then iss_api_token_pkg.decode_card_number(i_card_number => c.card_number)
                   else null
              end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER then p.card_id            else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER then p.card_instance_id   else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER then p.card_type_id       else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER then p.card_mask          else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER then p.card_hash          else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER then p.card_seq_number    else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER then p.card_expir_date    else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER then p.card_service_code  else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER then p.card_country       else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER then p.customer_id        else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER then p.account_id         else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER then p.account_type       else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER then p.account_number     else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER then p.account_amount     else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER then p.account_currency   else null end)
        , min(a.account_cnvt_rate)
        , min(a.bin_amount)
        , min(a.bin_currency)
        , min(a.bin_cnvt_rate)
        , min(a.network_amount)
        , min(a.network_currency)
        , min(a.network_cnvt_date)
        , min(a.network_cnvt_rate)
        , min(a.addr_verif_result)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER then p.auth_code      else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_DEST then p.client_id_type   else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_DEST then p.client_id_value  else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_DEST then p.inst_id          else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_DEST then p.network_id       else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_DEST then p.card_inst_id     else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_DEST then p.card_network_id  else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_DEST
                   then iss_api_token_pkg.decode_card_number(i_card_number => c.card_number)
                   else null
              end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_DEST then p.card_id          else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_DEST then p.card_instance_id else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_DEST then p.card_type_id     else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_DEST then p.card_mask        else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_DEST then p.card_hash        else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_DEST then p.card_seq_number  else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_DEST then p.card_expir_date  else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_DEST then p.card_service_code else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_DEST then p.card_country     else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_DEST then p.customer_id      else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_DEST then p.account_id       else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_DEST then p.account_type     else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_DEST then p.account_number   else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_DEST then p.account_amount   else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_DEST then p.account_currency else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_DEST then p.auth_code        else null end)
        , min(a.acq_device_id)
        , min(a.acq_resp_code)
        , min(a.acq_device_proc_result)
        , min(o.acq_inst_bin)
        , min(o.forw_inst_bin)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER then p.inst_id      else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER then p.network_id   else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER then p.split_hash   else null end)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER then p.merchant_id  else null end)
        , min(o.merchant_number)
        , min(o.terminal_type)
        , min(o.terminal_number)
        , min(case when p.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER then p.terminal_id  else null end)
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
        , min(a.emv_data)
        , min(a.atc)
        , min(a.tvr)
        , min(a.cvr)
        , min(a.addl_data)
        , min(a.amounts)
        , min(d.purpose_id)
        , min(a.resp_code)
        , min(a.cavv_presence)
        , min(a.aav_presence)
        , min(a.transaction_id)
    into
        o_split_hash
        , o_is_reversal
        , o_original_id
        , o_parent_id
        , o_msg_type
        , o_oper_type
        , o_sttl_type
        , o_is_advice
        , o_is_repeat
        , o_host_date
        , o_oper_date
        , o_oper_count
        , o_oper_request_amount
        , o_oper_amount_algorithm
        , o_oper_amount
        , o_oper_currency
        , o_oper_cashback_amount
        , o_oper_replacement_amount
        , o_oper_surcharge_amount
        , o_client_id_type
        , o_client_id_value
        , o_iss_inst_id
        , o_iss_network_id
        , o_iss_host_id
        , o_iss_network_device_id
        , o_split_hash_iss
        , o_card_inst_id
        , o_card_network_id
        , o_card_number
        , o_card_id
        , o_card_instance_id
        , o_card_type_id
        , o_card_mask
        , o_card_hash
        , o_card_seq_number
        , o_card_expir_date
        , o_card_service_code
        , o_card_country
        , o_customer_id
        , o_account_id
        , o_account_type
        , o_account_number
        , o_account_amount
        , o_account_currency
        , o_account_cnvt_rate
        , o_bin_amount
        , o_bin_currency
        , o_bin_cnvt_rate
        , o_network_amount
        , o_network_currency
        , o_network_cnvt_date
        , o_network_cnvt_rate
        , o_addr_verif_result
        , o_auth_code
        , o_dst_client_id_type
        , o_dst_client_id_value
        , o_dst_inst_id
        , o_dst_network_id
        , o_dst_card_inst_id
        , o_dst_card_network_id
        , o_dst_card_number
        , o_dst_card_id
        , o_dst_card_instance_id
        , o_dst_card_type_id
        , o_dst_card_mask
        , o_dst_card_hash
        , o_dst_card_seq_number
        , o_dst_card_expir_date
        , o_dst_card_service_code
        , o_dst_card_country
        , o_dst_customer_id
        , o_dst_account_id
        , o_dst_account_type
        , o_dst_account_number
        , o_dst_account_amount
        , o_dst_account_currency
        , o_dst_auth_code
        , o_acq_device_id
        , o_acq_resp_code
        , o_acq_device_proc_result
        , o_acq_inst_bin
        , o_forw_inst_bin
        , o_acq_inst_id
        , o_acq_network_id
        , o_split_hash_acq
        , o_merchant_id
        , o_merchant_number
        , o_terminal_type
        , o_terminal_number
        , o_terminal_id
        , o_merchant_name
        , o_merchant_street
        , o_merchant_city
        , o_merchant_region
        , o_merchant_country
        , o_merchant_postcode
        , o_cat_level
        , o_mcc
        , o_originator_refnum
        , o_network_refnum
        , o_card_data_input_cap
        , o_crdh_auth_cap
        , o_card_capture_cap
        , o_terminal_operating_env
        , o_crdh_presence
        , o_card_presence
        , o_card_data_input_mode
        , o_crdh_auth_method
        , o_crdh_auth_entity
        , o_card_data_output_cap
        , o_terminal_output_cap
        , o_pin_capture_cap
        , o_pin_presence
        , o_cvv2_presence
        , o_cvc_indicator
        , o_pos_entry_mode
        , o_pos_cond_code
        , o_emv_data
        , o_atc
        , o_tvr
        , o_cvr
        , o_addl_data
        , o_amounts
        , o_purpose_id
        , o_resp_code
        , o_cavv_presence
        , o_aav_presence
        , o_transaction_id
    from aut_auth a
       , opr_operation o
       , opr_participant p
       , opr_card c
       , pmo_order d
   where a.id = i_id
     and a.id = o.id
     and a.id = p.oper_id
     and p.oper_id = c.oper_id(+)
     and p.participant_type = c.participant_type(+)
     and o.payment_order_id = d.id(+);
    --
    return aup_api_const_pkg.RESP_CODE_OK;
exception
    when others then
        trc_log_pkg.debug (
            i_text              => 'UNHANDLED_EXCEPTION'
            , i_env_param1      => sqlerrm
            , i_entity_type     => AUT_API_CONST_PKG.ENTITY_TYPE_AUTHORIZATION
            , i_object_id       => i_id
        );
        --
        return aup_api_const_pkg.RESP_CODE_ERROR;
end get_auth;

procedure get_entry_info(
    i_oper_id             in     com_api_type_pkg.t_long_id
  , o_entry_tab              out acc_api_type_pkg.t_entry_tab
) is
begin

    select
        zz.oper_id
      , r.document_number
      , r.document_date
      , r.document_type
      , zz.transaction_id
      , zz.transaction_date
      , zz.transaction_type
      , zz.debit_account_number
      , zz.credit_account_number
      , zz.balance_type
      , zz.debit_amount
      , zz.debit_currency
      , zz.credit_amount
      , zz.credit_currency
    bulk collect into o_entry_tab
      from (
          select
              z.oper_id
            , z.transaction_id
            , z.transaction_date
            , z.transaction_type
            , sum(z.debit_account_number) as debit_account_number
            , sum(z.credit_account_number) as credit_account_number
            , z.balance_type
            , sum(z.debit_amount) as debit_amount
            , max(z.debit_currency) as debit_currency
            , sum(z.credit_amount) as credit_amount
            , max(z.credit_currency) as credit_currency
          from (
              select
                  i_oper_id as oper_id
                , e.transaction_id
                , m.posting_date as transaction_date
                , e.transaction_type
                , decode(e.balance_impact
                        , com_api_const_pkg.DEBIT
                        , a.account_number
                        , 0) as debit_account_number
                , decode(e.balance_impact
                        , com_api_const_pkg.CREDIT
                        , a.account_number
                        , 0) as credit_account_number
                , e.balance_type
                , decode(e.balance_impact
                        , com_api_const_pkg.DEBIT
                        , e.amount
                        , 0) as debit_amount
                , decode(e.balance_impact
                        , com_api_const_pkg.DEBIT
                        , e.currency
                        , null) as debit_currency

                , decode(e.balance_impact
                        , com_api_const_pkg.CREDIT
                        , e.amount
                        , 0) as credit_amount
                , decode(e.balance_impact
                        , com_api_const_pkg.CREDIT
                        , e.currency
                        , null) as credit_currency
              from
                  acc_entry   e
                , acc_macros  m
                , acc_account a
              where
                  e.account_id = a.id
              and
                  m.id = e.macros_id
              and
                  m.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
              and
                  m.object_id = i_oper_id) z
             group by
                 z.transaction_id
               , z.oper_id
               , z.transaction_date
               , z.transaction_type
               , z.balance_type) zz
          , rpt_document r
     where
         r.entity_type = acc_api_const_pkg.ENTITY_TYPE_TRANSACTION
     and
         r.object_id(+) = zz.transaction_id
     order by
         zz.transaction_id;

end get_entry_info;

end;
/
