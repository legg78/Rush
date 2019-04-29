create or replace package body dsp_ui_process_pkg is
/************************************************************
 * API for Dispute User Interface <br />
 * Created by Maslov I.(maslov@bpcbt.com)  at 27.05.2013 <br />
 * Module: DSP_UI_PROCESS_PKG <br />
 * @headcom
 ***********************************************************/

procedure remove_mup_message(
    i_id                      in     com_api_type_pkg.t_long_id
  , i_force                   in     com_api_type_pkg.t_boolean default com_api_type_pkg.TRUE
) is
    l_mup_count               com_api_type_pkg.t_count := 0;
begin
    select count(1)
      into l_mup_count
      from user_tables
     where table_name in ('MUP_FIN', 'MUP_CARD');
     
    if l_mup_count = 2 then
        execute immediate '
            delete from mup_fin
             where id = :i_id'
           using i_id;
           
        if sql%rowcount = 0 and i_force = com_api_type_pkg.FALSE then
            trc_log_pkg.debug(
                i_text       => 'Remove mup message: [#1] is not found'
              , i_env_param1 => i_id
            );
        else
            opr_api_operation_pkg.remove_operation(
                i_oper_id => i_id
            );
        end if;
    end if;
end remove_mup_message;

function is_jcb (
    i_id                      in     com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_boolean
is
    l_result                  com_api_type_pkg.t_boolean;
begin
    select count(1)
      into l_result
      from jcb_fin_message
     where id = i_id
       and rownum <= 1;

    return l_result;
end is_jcb;

procedure remove_jbc_message(
    i_id                      in     com_api_type_pkg.t_long_id
  , i_force                   in     com_api_type_pkg.t_boolean default com_api_type_pkg.TRUE
) is
begin
    delete 
      from jcb_fin_message
     where id = i_id;
    if sql%rowcount = 0 and i_force = com_api_type_pkg.FALSE then
        trc_log_pkg.debug(
            i_text       => 'Remove jbc message: [#1] is not found'
          , i_env_param1 => i_id
        );
    else
        opr_api_operation_pkg.remove_operation(
            i_oper_id => i_id
        );
    end if;
end remove_jbc_message;

/*
 * Procedure returns a scale type X that is got by associated modifier from the scale of type SCTPDCNS;
 * an associated rule is used for custom filling modifier parameters of found scale X.
 */
procedure select_scale_type(
    i_params                  in     com_api_type_pkg.t_param_tab
  , o_scale_type                 out com_api_type_pkg.t_dict_value
  , o_init_rule_id               out com_api_type_pkg.t_tiny_id
) is
    l_mods                           com_api_type_pkg.t_number_tab;
    l_scales_types                   com_api_type_pkg.t_varchar2_tab;
    l_init_rules                     com_api_type_pkg.t_tiny_tab;
    l_index                          pls_integer;
begin
    select scale_type
         , mod_id
         , init_rule_id
      bulk collect into
           l_scales_types
         , l_mods
         , l_init_rules
      from dsp_scale_selection;

    if l_mods.count() > 0 then
        l_index := rul_api_mod_pkg.select_condition(
                       i_mods       => l_mods
                     , i_params     => i_params
                     , i_mask_error => com_api_const_pkg.FALSE
                   );

        o_scale_type   := l_scales_types(l_index);
        o_init_rule_id := l_init_rules(l_index);
    end if;

exception
    when com_api_error_pkg.e_application_error then
        if com_api_error_pkg.get_last_error() != 'NO_APPLICABLE_CONDITION' then
            raise;
        end if;
end select_scale_type;

procedure get_common_dsp_list(
    i_id                      in     com_api_type_pkg.t_long_id
  , i_lang                    in     com_api_type_pkg.t_dict_value
  , o_dispute_list               out com_api_type_pkg.t_ref_cur
) is
    LOG_PREFIX                com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_common_dsp_list: ';
    l_scale_type              com_api_type_pkg.t_dict_value;
    l_init_rule_id            com_api_type_pkg.t_tiny_id;

    l_oper_list               com_api_type_pkg.t_ref_cur;

    type t_oper_rec is record(
        mti             com_api_type_pkg.t_tag
      , de024           com_api_type_pkg.t_tag
      , is_reversal     com_api_type_pkg.t_boolean
      , is_incoming     com_api_type_pkg.t_boolean
      , p0228           com_api_type_pkg.t_tiny_id
      , de025           com_api_type_pkg.t_tag
      , dispute_rn      com_api_type_pkg.t_long_id
      , de003_1         com_api_type_pkg.t_tag
      , card_number     com_api_type_pkg.t_card_number
      , de031           com_api_type_pkg.t_original_data
      , network_id      com_api_type_pkg.t_network_id
      , inst_id         com_api_type_pkg.t_inst_id
    );

    l_oper_rec              t_oper_rec;
    l_iss_inst_id           com_api_type_pkg.t_inst_id;
    l_iss_host_id           com_api_type_pkg.t_tiny_id;
    l_card_type_id          com_api_type_pkg.t_tiny_id;
    l_card_country          com_api_type_pkg.t_curr_code;
    l_card_inst_id          com_api_type_pkg.t_inst_id;
    l_card_network_id       com_api_type_pkg.t_tiny_id;
    l_pan_length            com_api_type_pkg.t_tiny_id;
    l_host_id               com_api_type_pkg.t_tiny_id;
    l_standard_id           com_api_type_pkg.t_tiny_id;
    l_vcr_dispute_enable    com_api_type_pkg.t_boolean;
    l_param_tab             com_api_type_pkg.t_param_tab;
    l_iss_network_id        com_api_type_pkg.t_tiny_id;
    l_bin_currency          com_api_type_pkg.t_curr_code;
    l_sttl_currency         com_api_type_pkg.t_curr_code;
    l_list_condition_tab    dsp_list_condition_tpt;
    l_lang                  com_api_type_pkg.t_dict_value;
begin
    trc_log_pkg.debug(LOG_PREFIX || 'START with i_id [' || i_id || ']');

    l_lang := coalesce(i_lang, com_ui_user_env_pkg.get_user_lang);

    if i_id is null then
        dsp_api_shared_data_pkg.set_param(
            i_name   => 'TRANSACTION_CODE'
          , i_value  => 'TRANS_CODE'
        );
        dsp_api_shared_data_pkg.set_param(
            i_name   => 'MESSAGE_TYPE'
          , i_value  => 'mti'
        );
    elsif vis_api_fin_message_pkg.is_visa_sms(i_id => i_id) = com_api_const_pkg.TRUE then
        for r in (
            select v.trans_code
                 , v.is_incoming
                 , v.usage_code
                 , v.mcc
                 , v.inst_id
                 , v.network_id
                 , p.card_network_id
                 , o.merchant_country as acq_country
                 , iss_api_token_pkg.decode_card_number(i_card_number => c.card_number) card_number
              from vis_fin_message v
                 , opr_participant p
                 , opr_operation o
                 , vis_card c
             where v.id      = i_id
               and c.id      = v.id
               and o.id      = v.id
               and p.oper_id = v.id
               and p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
               and rownum   <= 1
        ) loop
            dsp_api_shared_data_pkg.set_param(
                i_name   => 'TRANSACTION_CODE'
              , i_value  => r.trans_code
            );
            dsp_api_shared_data_pkg.set_param(
                i_name   => 'USAGE_CODE'
              , i_value  => r.usage_code
            );
            dsp_api_shared_data_pkg.set_param(
                i_name   => 'IS_INCOMING'
              , i_value  => r.is_incoming
            );
            dsp_api_shared_data_pkg.set_param(
                i_name   => 'MCC'
              , i_value  => r.mcc
            );
            dsp_api_shared_data_pkg.set_param(
                i_name   => 'INST_ID'
              , i_value  => r.inst_id
            );
            dsp_api_shared_data_pkg.set_param(
                i_name   => 'NETWORK_ID'
              , i_value  => r.network_id
            );
            dsp_api_shared_data_pkg.set_param(
                i_name   => 'CARD_NETWORK_ID'
              , i_value  => r.card_network_id
            );
            l_host_id     := net_api_network_pkg.get_default_host(
                                 i_network_id  => r.network_id
                             );
            l_standard_id := net_api_network_pkg.get_offline_standard(
                                 i_host_id     => l_host_id
                             );
            cmn_api_standard_pkg.get_param_value(
                i_inst_id      => r.inst_id
              , i_standard_id  => l_standard_id
              , i_object_id    => l_host_id
              , i_entity_type  => net_api_const_pkg.ENTITY_TYPE_HOST
              , i_param_name   => vis_api_const_pkg.VCR_DISPUTE_ENABLE
              , o_param_value  => l_vcr_dispute_enable
              , i_param_tab    => l_param_tab
            );
            dsp_api_shared_data_pkg.set_param(
                i_name   => 'VCR_DISPUTE_ENABLE'
              , i_value  => l_vcr_dispute_enable
            );
            dsp_api_shared_data_pkg.set_param(
                i_name   => 'ACQ_COUNTRY'
              , i_value  => r.acq_country
            );
            net_api_bin_pkg.get_bin_info(
                i_card_number      => r.card_number
              , i_network_id       => r.network_id
              , o_iss_inst_id      => l_iss_inst_id
              , o_iss_host_id      => l_iss_host_id
              , o_card_type_id     => l_card_type_id
              , o_card_country     => l_card_country
              , o_card_inst_id     => l_card_inst_id
              , o_card_network_id  => l_card_network_id
              , o_pan_length       => l_pan_length
              , i_raise_error      => com_api_const_pkg.FALSE
            );

            if l_card_country is null and r.card_number is not null then
                iss_api_bin_pkg.get_bin_info(
                    i_card_number      => r.card_number
                  , o_iss_inst_id      => l_iss_inst_id
                  , o_iss_network_id   => l_iss_network_id
                  , o_card_inst_id     => l_card_inst_id
                  , o_card_network_id  => l_card_network_id
                  , o_card_type        => l_card_type_id
                  , o_card_country     => l_card_country
                  , o_bin_currency     => l_bin_currency
                  , o_sttl_currency    => l_sttl_currency
                  , i_raise_error      => com_api_const_pkg.TRUE
                );
            end if;

            dsp_api_shared_data_pkg.set_param(
                i_name   => 'ISS_COUNTRY'
              , i_value  => l_card_country
            );
        end loop;

        l_scale_type := dsp_api_const_pkg.SCALE_TYPE_DSP_VISA;
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'VISA SMS operation is detected, l_scale_type [#1]'
          , i_env_param1 => l_scale_type
        ); 
        
    elsif vis_api_fin_message_pkg.is_visa(i_id => i_id) = com_api_const_pkg.TRUE then
        for r in (
            select v.trans_code
                 , v.is_incoming
                 , v.usage_code
                 , v.mcc
                 , v.inst_id
                 , v.network_id
                 , p.card_network_id
                 , o.merchant_country as acq_country
                 , iss_api_token_pkg.decode_card_number(i_card_number => c.card_number) card_number
              from vis_fin_message v
                 , opr_participant p
                 , opr_operation o
                 , vis_card c
             where v.id      = i_id
               and c.id      = v.id
               and o.id      = v.id
               and p.oper_id = v.id
               and p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
               and rownum   <= 1
        ) loop
            dsp_api_shared_data_pkg.set_param(
                i_name   => 'TRANSACTION_CODE'
              , i_value  => r.trans_code
            );
            dsp_api_shared_data_pkg.set_param(
                i_name   => 'USAGE_CODE'
              , i_value  => r.usage_code
            );
            dsp_api_shared_data_pkg.set_param(
                i_name   => 'IS_INCOMING'
              , i_value  => r.is_incoming
            );
            dsp_api_shared_data_pkg.set_param(
                i_name   => 'MCC'
              , i_value  => r.mcc
            );
            dsp_api_shared_data_pkg.set_param(
                i_name   => 'INST_ID'
              , i_value  => r.inst_id
            );
            dsp_api_shared_data_pkg.set_param(
                i_name   => 'NETWORK_ID'
              , i_value  => r.network_id
            );
            dsp_api_shared_data_pkg.set_param(
                i_name   => 'CARD_NETWORK_ID'
              , i_value  => r.card_network_id
            );
            l_host_id     := net_api_network_pkg.get_default_host(
                                 i_network_id  => r.network_id
                             );
            l_standard_id := net_api_network_pkg.get_offline_standard(
                                 i_host_id     => l_host_id
                             );

            if l_standard_id = way_api_const_pkg.WAY4_STANDARD then
                -- Do not open cursor for this standard because dispute cycle for Way4 is not supported
                -- and this method is called from package "dsp_ui_dispute_search_pkg".
                return;
            end if;

            cmn_api_standard_pkg.get_param_value(
                i_inst_id      => r.inst_id
              , i_standard_id  => l_standard_id
              , i_object_id    => l_host_id
              , i_entity_type  => net_api_const_pkg.ENTITY_TYPE_HOST
              , i_param_name   => vis_api_const_pkg.VCR_DISPUTE_ENABLE
              , o_param_value  => l_vcr_dispute_enable
              , i_param_tab    => l_param_tab
            );
            dsp_api_shared_data_pkg.set_param(
                i_name   => 'VCR_DISPUTE_ENABLE'
              , i_value  => l_vcr_dispute_enable
            );
            dsp_api_shared_data_pkg.set_param(
                i_name   => 'ACQ_COUNTRY'
              , i_value  => r.acq_country
            );
            net_api_bin_pkg.get_bin_info(
                i_card_number      => r.card_number
              , i_network_id       => r.network_id
              , o_iss_inst_id      => l_iss_inst_id
              , o_iss_host_id      => l_iss_host_id
              , o_card_type_id     => l_card_type_id
              , o_card_country     => l_card_country
              , o_card_inst_id     => l_card_inst_id
              , o_card_network_id  => l_card_network_id
              , o_pan_length       => l_pan_length
              , i_raise_error      => com_api_const_pkg.FALSE
            );

            if l_card_country is null and r.card_number is not null then
                iss_api_bin_pkg.get_bin_info(
                    i_card_number      => r.card_number
                  , o_iss_inst_id      => l_iss_inst_id
                  , o_iss_network_id   => l_iss_network_id
                  , o_card_inst_id     => l_card_inst_id
                  , o_card_network_id  => l_card_network_id
                  , o_card_type        => l_card_type_id
                  , o_card_country     => l_card_country
                  , o_bin_currency     => l_bin_currency
                  , o_sttl_currency    => l_sttl_currency
                  , i_raise_error      => com_api_const_pkg.TRUE
                );
            end if;

            dsp_api_shared_data_pkg.set_param(
                i_name   => 'ISS_COUNTRY'
              , i_value  => l_card_country
            );
        end loop;

        l_scale_type := dsp_api_const_pkg.SCALE_TYPE_DSP_VISA;
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'VISA operation is detected, l_scale_type [#1]'
          , i_env_param1 => l_scale_type
        ); 
        
    elsif mcw_api_fin_pkg.is_mastercard(i_id => i_id) = com_api_const_pkg.TRUE then
        for r in (
            select f.mti
                 , f.de024
                 , decode(f.p0025_1, 'R', 1, 0) is_reversal
                 , f.is_incoming
                 , f.p0228
                 , f.de025
                 , f.de026
                 , f.dispute_rn
                 , f.de003_1
                 , iss_api_token_pkg.decode_card_number(i_card_number => c.card_number) as card_number
                 , substr(f.de031, 2, 6) de031
                 , ( select max(substr(a.arrangement_code, 1, 2))
                       from mcw_acq_arrangement a
                      where a.acq_bin = to_number(substr(f.de031, 2, 6))
                        and a.arrangement_type = '2'
                        and rownum <= 1
                   ) acq_region
                 , ( select max(substr(a.arrangement_code, 1, 2))
                       from mcw_iss_arrangement a
                      -- We consider that a.pan_low and a.pan_high belongs to the same BIN,
                      -- and use <c.card_number like ...> to prevent full scan of table mcw_iss_arrangement
                      -- with API call of iss_api_token_pkg.decode_card_number for every(!) table's record
                      where c.card_number like substr(a.pan_low, 1, 6) || '%'
                        and iss_api_token_pkg.decode_card_number(i_card_number => c.card_number)
                            between a.pan_low and a.pan_high
                        and decode(a.arrangement_type, 2, 2, null) = '2'
                        and rownum <= 1
                   ) iss_region
              from mcw_fin f
                 , mcw_card c
             where f.id = i_id
               and f.id = c.id
               and rownum <= 1
        ) loop
            dsp_api_shared_data_pkg.set_param(
                i_name   => 'MESSAGE_TYPE'
              , i_value  => r.mti
            );
            dsp_api_shared_data_pkg.set_param(
                i_name   => 'DE_024'
              , i_value  => r.de024
            );
            dsp_api_shared_data_pkg.set_param(
                i_name   => 'IS_REVERSAL',
                i_value  => r.is_reversal
            );
            dsp_api_shared_data_pkg.set_param(
                i_name   => 'IS_INCOMING'
              , i_value  => r.is_incoming
            );
            dsp_api_shared_data_pkg.set_param(
                i_name   => 'DE_025'
              , i_value  => r.de025
            );
            dsp_api_shared_data_pkg.set_param(
                i_name   => 'DE_026'
              , i_value  => r.de026
            );
            dsp_api_shared_data_pkg.set_param(
                i_name   => 'DISPUTE_RN'
              , i_value  => r.dispute_rn
            );
            dsp_api_shared_data_pkg.set_param(
                i_name   => 'DE_003_1'
              , i_value  => r.de003_1
            );
            dsp_api_shared_data_pkg.set_param(
                i_name   => 'PDS_0228'
              , i_value  => r.p0228
            );

            dsp_api_shared_data_pkg.set_param(
                i_name   => 'ACQ_REGION'
              , i_value  => r.acq_region
            );

            dsp_api_shared_data_pkg.set_param(
                i_name    => 'CARD_REGION'
              , i_value   => r.iss_region
            );

            dsp_api_shared_data_pkg.set_param(
                i_name   => 'CARD_PRODUCT_TYPE'
              , i_value  => 'PAYNOW'
            );
            dsp_api_shared_data_pkg.set_param(
                i_name   => 'OPERATION_ID'
              , i_value  => i_id
            );
        end loop;

        l_scale_type := dsp_api_const_pkg.SCALE_TYPE_DSP_MASTERCARD;
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'MasterCard operation is detected, l_scale_type [#1]'
          , i_env_param1 => l_scale_type
        );

    elsif mup_api_fin_pkg.is_mup(i_id => i_id) = com_api_const_pkg.TRUE then
        begin
            open l_oper_list
             for 'select f.mti
                       , f.de024
                       , decode(f.p0025_1,''R'',1,0) is_reversal
                       , f.is_incoming
                       , f.p0228
                       , f.de025
                       , f.dispute_rn
                       , f.de003_1
                       , iss_api_token_pkg.decode_card_number(i_card_number => c.card_number) as card_number
                       , substr(f.de031, 2, 6) de031
                       , f.network_id
                       , f.inst_id 
                    from mup_fin f
                       , mup_card c
                   where f.id = :i_id
                     and f.id = c.id
                     and rownum <= 1'
            using i_id;

            loop
                fetch l_oper_list into l_oper_rec;

                exit when l_oper_list%notfound;

                dsp_api_shared_data_pkg.set_param(
                    i_name   => 'MESSAGE_TYPE'
                  , i_value  => l_oper_rec.mti
                );
                dsp_api_shared_data_pkg.set_param(
                    i_name   => 'DE_024'
                  , i_value  => l_oper_rec.de024
                );
                dsp_api_shared_data_pkg.set_param(
                    i_name   => 'IS_REVERSAL'
                  , i_value  => l_oper_rec.is_reversal
                );
                dsp_api_shared_data_pkg.set_param(
                    i_name   => 'IS_INCOMING'
                  , i_value  => l_oper_rec.is_incoming
                );
                dsp_api_shared_data_pkg.set_param(
                    i_name   => 'DE_025'
                  , i_value  => l_oper_rec.de025
                );
                dsp_api_shared_data_pkg.set_param(
                    i_name   => 'DISPUTE_RN'
                  , i_value  => l_oper_rec.dispute_rn
                );
                dsp_api_shared_data_pkg.set_param(
                    i_name   => 'DE_003_1'
                  , i_value  => l_oper_rec.de003_1
                );
                dsp_api_shared_data_pkg.set_param(
                    i_name   => 'PDS_0228'
                  , i_value  => l_oper_rec.p0228
                );
                dsp_api_shared_data_pkg.set_param(
                    i_name   => 'CARD_PRODUCT_TYPE'
                  , i_value  => 'PAYNOW'
                );
                dsp_api_shared_data_pkg.set_param(
                    i_name   => 'NETWORK_ID'
                  , i_value  => l_oper_rec.network_id
                );
                dsp_api_shared_data_pkg.set_param(
                    i_name   => 'INST_ID'
                  , i_value  => l_oper_rec.inst_id
                );

                exit;
            end loop;

            close l_oper_list;

            l_scale_type := dsp_api_const_pkg.SCALE_TYPE_DSP_MIR;
            trc_log_pkg.debug(
                i_text       => LOG_PREFIX || 'MUP operation is detected, l_scale_type [#1]'
              , i_env_param1 => l_scale_type
            );
        exception
            when others then
                if l_oper_list%isopen then
                    close l_oper_list;
                end if;

                raise;
        end;

    elsif is_jcb(i_id => i_id) = com_api_const_pkg.TRUE then
        for r in (
            select f.mti
                 , f.de024
                 , decode(f.p3007_1,'R',1,0) is_reversal
                 , f.is_incoming
                 , f.p3203
                 , f.p3250
                 , f.de025
                 , f.dispute_rn
                 , f.de003_1
                 , iss_api_token_pkg.decode_card_number(i_card_number => c.card_number) as card_number
                 , substr(f.de031, 2, 6) de031
              from jcb_fin_message f
                 , jcb_card c
             where f.id = i_id
               and f.id = c.id
               and rownum <= 1
        ) loop
            dsp_api_shared_data_pkg.set_param(
                i_name   => 'MESSAGE_TYPE'
              , i_value  => r.mti
            );
            dsp_api_shared_data_pkg.set_param(
                i_name   => 'DE_024'
              , i_value  => r.de024
            );
            dsp_api_shared_data_pkg.set_param(
                i_name   => 'IS_REVERSAL',
              i_value  => r.is_reversal
            );
            dsp_api_shared_data_pkg.set_param(
                i_name   => 'IS_INCOMING'
              , i_value  => r.is_incoming
            );
            dsp_api_shared_data_pkg.set_param(
                i_name   => 'DE_025'
              , i_value  => r.de025
            );
            dsp_api_shared_data_pkg.set_param(
                i_name   => 'DISPUTE_RN'
              , i_value  => r.dispute_rn
            );
            dsp_api_shared_data_pkg.set_param(
                i_name   => 'DE_003_1'
              , i_value  => r.de003_1
            );
            dsp_api_shared_data_pkg.set_param(
                i_name   => 'PDS_3203'
              , i_value  => r.p3203
            );
            dsp_api_shared_data_pkg.set_param(
                i_name   => 'PDS_3250'
              , i_value  => r.p3250
            );
        end loop;

        l_scale_type := dsp_api_const_pkg.SCALE_TYPE_DSP_JCB;
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'JCB operation is detected, l_scale_type [#1]'
          , i_env_param1 => l_scale_type
        );
        
    elsif amx_api_fin_message_pkg.is_amex(i_id => i_id) = com_api_const_pkg.TRUE then
        for r in (
            select f.mtid
                 , f.func_code
                 , f.is_reversal
                 , f.is_incoming
                 , f.reason_code
                 , f.mcc
                 , iss_api_token_pkg.decode_card_number(i_card_number => c.card_number) as card_number
              from amx_fin_message f
                 , amx_card c
             where f.id = i_id
               and f.id = c.id
               and rownum <= 1
        ) loop
            dsp_api_shared_data_pkg.set_param(
                i_name   => 'MESSAGE_TYPE'
              , i_value  => r.mtid
            );
            dsp_api_shared_data_pkg.set_param(
                i_name   => 'FUNC_CODE'
              , i_value  => r.func_code
            );
            dsp_api_shared_data_pkg.set_param(
                i_name   => 'IS_REVERSAL',
              i_value  => r.is_reversal
            );
            dsp_api_shared_data_pkg.set_param(
                i_name   => 'IS_INCOMING'
              , i_value  => r.is_incoming
            );
            dsp_api_shared_data_pkg.set_param(
                i_name   => 'REASON_CODE'
              , i_value  => r.reason_code
            );
            dsp_api_shared_data_pkg.set_param(
                i_name   => 'MCC'
              , i_value  => r.mcc
            );
        end loop;

        l_scale_type := dsp_api_const_pkg.SCALE_TYPE_DSP_AMX;
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'AMX operation is detected, l_scale_type [#1]'
          , i_env_param1 => l_scale_type
        );

    else
        -- Define a dispute scale type
        for r in (
            select o.id
                 , o.sttl_type
                 , o.is_reversal
                 , o.msg_type
                 , t.terminal_type
                 , iss.inst_id            as iss_inst_id
                 , iss.network_id         as iss_network_id
                 , iss.card_network_id
                 , iss.card_type_id
                 , acq.inst_id            as acq_inst_id
                 , acq.network_id         as acq_network_id
              from opr_operation o
                 , opr_participant iss
                 , opr_participant acq
                 , acq_terminal t
             where o.id                    = i_id
               and iss.oper_id(+)          = o.id
               and iss.participant_type(+) = com_api_const_pkg.PARTICIPANT_ISSUER
               and acq.oper_id(+)          = o.id
               and acq.participant_type(+) = com_api_const_pkg.PARTICIPANT_ACQUIRER
               and t.id(+)                 = acq.terminal_id
        ) loop
            dsp_api_shared_data_pkg.set_param(
                i_name   => 'STTL_TYPE'
              , i_value  => r.sttl_type
            );
            dsp_api_shared_data_pkg.set_param(
                i_name   => 'IS_REVERSAL'
              , i_value  => r.is_reversal
            );
            dsp_api_shared_data_pkg.set_param(
                i_name   => 'MSG_TYPE'
              , i_value  => r.msg_type
            );
            dsp_api_shared_data_pkg.set_param(
                i_name   => 'TERMINAL_TYPE'
              , i_value  => r.terminal_type
            );
            dsp_api_shared_data_pkg.set_param(
                i_name   => 'ACQ_NETWORK_ID'
              , i_value  => r.acq_network_id
            );
            dsp_api_shared_data_pkg.set_param(
                i_name   => 'ISS_NETWORK_ID'
              , i_value  => r.iss_network_id
            );
            dsp_api_shared_data_pkg.set_param(
                i_name   => 'CARD_NETWORK_ID'
              , i_value  => r.card_network_id
            );
            dsp_api_shared_data_pkg.set_param(
                i_name   => 'CARD_TYPE_ID'
              , i_value  => r.card_type_id
            );
            dsp_api_shared_data_pkg.set_param(
                i_name   => 'ACQ_INST_ID'
              , i_value  => r.acq_inst_id
            );
            dsp_api_shared_data_pkg.set_param(
                i_name   => 'ISS_INST_ID'
              , i_value  => r.iss_inst_id
            );
        end loop;

        select_scale_type(
            i_params       => dsp_api_shared_data_pkg.get_global_params()
          , o_scale_type   => l_scale_type
          , o_init_rule_id => l_init_rule_id
        );

        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'scale type selection result is l_scale_type [#1], l_init_rule_id [#2]'
          , i_env_param1 => l_scale_type
          , i_env_param2 => l_init_rule_id
        );

        -- Set values for scale parameters for dispute modifiers calculation
        if l_init_rule_id is not null then
            -- Passing ID of current fin. message to the rule of dispute parameters initialization
            dsp_api_shared_data_pkg.set_param(
                i_name   => 'ORIGINAL_ID'
              , i_value  => i_id
            );

            trc_log_pkg.debug(
                i_text       => 'Rule [' || l_init_rule_id || '] execution is STARTED'
            );

            rul_api_exec_pkg.execute_procedure(i_proc_id => l_init_rule_id);

            trc_log_pkg.debug(
                i_text       => 'Rule [' || l_init_rule_id || '] execution is FINISHED'
            );
        end if;

        if l_scale_type is null then
            l_scale_type := dsp_cst_process_pkg.check_other_networks(i_id);

            trc_log_pkg.debug(
                i_text       => LOG_PREFIX || 'custom selection of a scale type returned l_scale_type [#1]'
              , i_env_param1 => l_scale_type
            );
        end if;
    end if;

    l_list_condition_tab := new dsp_list_condition_tpt(); 

    for lc in (
        select lc.id
             , lc.func_order
             , lc.init_rule
             , lc.gen_rule
             , lc.is_online
             , lc.msg_type
             , lc.mod_id
          from dsp_list_condition lc
             , rul_mod m
             , rul_mod_scale ms
         where lc.mod_id       = m.id
           and ms.id           = m.scale_id
           and (ms.scale_type  = l_scale_type or l_scale_type is null)
           and lc.gen_rule    is not null
           and lc.init_rule   is not null
    ) loop
        if dsp_api_shared_data_pkg.select_condition(lc.mod_id) = com_api_type_pkg.TRUE then
            l_list_condition_tab.extend();
                
            l_list_condition_tab(l_list_condition_tab.last) := 
                new dsp_list_condition_tpr(
                    lc.id
                  , lc.func_order
                  , lc.init_rule
                  , lc.gen_rule
                  , lc.is_online
                  , lc.msg_type
                  , lc.mod_id
                  , com_api_type_pkg.TRUE
                );
        end if;
    end loop;

    open o_dispute_list for
        select get_text (
                   i_table_name    => 'dsp_list_condition'
                 , i_column_name   => 'name'
                 , i_object_id     => a.id
                 , i_lang          => l_lang
               ) as type
             , a.func_order
             , a.init_rule
             , a.gen_rule
             , a.is_online
             , l_lang as lang
             , a.msg_type
          from table(cast(l_list_condition_tab as dsp_list_condition_tpt)) a
      order by func_order;

end get_common_dsp_list;

procedure get_dispute_list (
    i_id                      in     com_api_type_pkg.t_long_id
  , i_lang                    in     com_api_type_pkg.t_dict_value    default null
  , o_dispute_list               out com_api_type_pkg.t_ref_cur
) is
begin
    dsp_api_shared_data_pkg.clear_params;

    get_common_dsp_list(
        i_id            => i_id
      , i_lang          => i_lang
      , o_dispute_list  => o_dispute_list
    );

end get_dispute_list;

function check_dispute_allow(
    i_id                      in     com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_boolean
is
    l_type                    com_api_type_pkg.t_text;
    l_func_order              com_api_type_pkg.t_tiny_id;
    l_init_rule               com_api_type_pkg.t_short_id;
    l_gen_rule                com_api_type_pkg.t_short_id;
    l_lang                    com_api_type_pkg.t_dict_value;
    l_is_online               com_api_type_pkg.t_boolean;
    l_msg_type                com_api_type_pkg.t_dict_value;

    l_dispute_cur             com_api_type_pkg.t_ref_cur;
    l_found                   com_api_type_pkg.t_boolean;
begin
    get_dispute_list(
        i_id            => i_id
      , o_dispute_list  => l_dispute_cur
    );

    if l_dispute_cur%isopen then
        fetch l_dispute_cur
         into l_type
            , l_func_order
            , l_init_rule
            , l_gen_rule
            , l_is_online
            , l_lang
            , l_msg_type;

        l_found := case
                       when l_dispute_cur%found
                       then com_api_const_pkg.TRUE
                       else com_api_const_pkg.FALSE
                   end;

        close l_dispute_cur;

        return l_found;
    end if;
    return com_api_const_pkg.FALSE;

exception
    when others then
        if l_dispute_cur%isopen then
            close l_dispute_cur;
        end if;
        raise;
end check_dispute_allow;

procedure prepare_dispute(
    i_oper_id                 in     com_api_type_pkg.t_long_id
  , i_proc_id                 in     com_api_type_pkg.t_short_id
  , i_lang                    in     com_api_type_pkg.t_dict_value    default null
  , i_is_editing              in     com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
  , o_dispute_cur                out com_api_type_pkg.t_ref_cur
) is
    l_statement               clob;
    l_is_editing              com_api_type_pkg.t_boolean  := nvl(i_is_editing, com_api_const_pkg.FALSE);
begin
    trc_log_pkg.debug(
        i_text        => 'prepare_dispute: Start i_oper_id [#1], i_proc_id [#2], i_lang [#3], i_is_editing [#4]' 
      , i_env_param1  => i_oper_id
      , i_env_param2  => i_proc_id
      , i_env_param3  => i_lang
      , i_env_param4  => i_is_editing
    );                    

    --dsp_api_shared_data_pkg.clear_params;

    dsp_api_shared_data_pkg.set_param(
        i_name   => 'OPERATION_ID'
      , i_value  => i_oper_id
    );

    dsp_api_shared_data_pkg.set_param(
        i_name   => 'EDITING'
      , i_value  => l_is_editing
    );

    rul_api_exec_pkg.execute_procedure (
        i_proc_id  => i_proc_id
    );

    l_statement := dsp_api_shared_data_pkg.get_cur_statement;

    open o_dispute_cur for l_statement using i_oper_id, nvl(i_lang, get_user_lang);

    trc_log_pkg.debug(
        i_text => 'Query part 1: ' || substr(l_statement, 1, 3900)
    );
    trc_log_pkg.debug(
        i_text => 'Query part 2: ' || substr(l_statement, 3901)
    );
    trc_log_pkg.debug(
        i_text => 'prepare_dispute: Finish'
    );                    

exception
    when others then
        trc_log_pkg.debug(
            i_text => lower($$PLSQL_UNIT) || '.prepare_dispute FAILED: sqlerrm [' || sqlerrm || '], l_statement: ...'
        );
        trc_log_pkg.debug(
            i_text => 'Query part 1: ' || substr(l_statement, 1, 3900)
        );
        trc_log_pkg.debug(
            i_text => 'Query part 2: ' || substr(l_statement, 3901)
        );
        raise;
end prepare_dispute;

procedure exec_dispute(
    i_oper_id                 in     com_api_type_pkg.t_long_id
  , i_init_rule               in     com_api_type_pkg.t_tiny_id
  , i_gen_rule                in     com_api_type_pkg.t_tiny_id
  , i_param_map               in     com_param_map_tpt
  , i_is_editing              in     com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
) is
    l_is_editing    com_api_type_pkg.t_boolean  := nvl(i_is_editing, com_api_const_pkg.FALSE);
    l_new_oper_id   com_api_type_pkg.t_long_id;
begin
    trc_log_pkg.debug(
        i_text        => 'exec_dispute: Start i_oper_id [#1], i_init_rule [#2], i_gen_rule [#3], i_is_editing [#4]' 
      , i_env_param1  => i_oper_id
      , i_env_param2  => i_init_rule
      , i_env_param3  => i_gen_rule
      , i_env_param4  => i_is_editing
    );                    

    dsp_api_shared_data_pkg.clear_params;

    if i_param_map is not null then
        for i in 1 .. i_param_map.count loop
            if i_param_map(i).char_value is not null then
                dsp_api_shared_data_pkg.set_param(upper(i_param_map(i).name), i_param_map(i).char_value);

            elsif i_param_map(i).number_value is not null then
                dsp_api_shared_data_pkg.set_param(upper(i_param_map(i).name), i_param_map(i).number_value);

            elsif i_param_map(i).date_value is not null then
                dsp_api_shared_data_pkg.set_param(upper(i_param_map(i).name), i_param_map(i).date_value);

            else
                null;
            end if;
        end loop;
    end if;

    dsp_api_shared_data_pkg.set_param(
        i_name   => 'OPERATION_ID'
      , i_value  => i_oper_id
    );

    dsp_api_shared_data_pkg.set_param(
        i_name   => 'EDITING'
      , i_value  => l_is_editing
    );

    rul_api_exec_pkg.execute_procedure (
        i_proc_id  => i_gen_rule
    );

    if l_is_editing = com_api_const_pkg.FALSE then
        l_new_oper_id := dsp_api_shared_data_pkg.get_param_num(
                             i_name       => 'OPERATION_ID'
                           , i_mask_error => com_api_const_pkg.TRUE
                         );

        put_message(
            i_id        => l_new_oper_id
          , i_init_rule => i_init_rule
          , i_gen_rule  => i_gen_rule
        );
    end if;

    trc_log_pkg.debug(
        i_text        => 'exec_dispute: Finish. New oper_id [#1]'
      , i_env_param1  => l_new_oper_id
    );                    

exception
    when others then
        trc_log_pkg.debug(
            i_text       => lower($$PLSQL_UNIT) || '.exec_dispute FAILED: i_init_rule [#1], i_gen_rule [#2], i_oper_id [#3], sqlerrm [#4]'
          , i_env_param1 => i_init_rule
          , i_env_param2 => i_gen_rule
          , i_env_param3 => i_oper_id
          , i_env_param4 => sqlerrm
        );
        raise;
end exec_dispute;

/*
 * Return true if such message type for duspute already exists.
 * @param i_oper_id       - Operation ID
 * @param i_msg_type      - Message type
 * @param i_param_map     - Value list of the Dispute parameters
 */
function check_duplicated_message(
    i_oper_id                 in     com_api_type_pkg.t_long_id
  , i_msg_type                in     com_api_type_pkg.t_dict_value
  , i_param_map               in     com_param_map_tpt
) return com_api_type_pkg.t_boolean
is
    l_result                         com_api_type_pkg.t_boolean    := com_api_const_pkg.FALSE;
    l_dispute_id                     com_api_type_pkg.t_long_id;
    l_old_oper_id                    com_api_type_pkg.t_long_id;
begin
    trc_log_pkg.debug(
        i_text       => 'check_duplicated_message start: i_oper_id [#1] i_msg_type [#2]'
      , i_env_param1 => i_oper_id
      , i_env_param2 => i_msg_type
    );

    if i_oper_id is null or i_msg_type is null then
        -- The user don't see the warning message in web form.
        return com_api_const_pkg.FALSE;
    end if;

    select dispute_id
      into l_dispute_id
      from opr_operation
     where id = i_oper_id;

    if l_dispute_id is not null then
        select max(id)
          into l_old_oper_id
          from opr_operation
         where dispute_id = l_dispute_id
           and msg_type   = i_msg_type
           and rownum     = 1;

        if l_old_oper_id is not null then
            l_result     := com_api_const_pkg.TRUE;
        end if;
    end if;

    trc_log_pkg.debug(
        i_text       => 'check_duplicated_message finish: old oper id [#1] result [#2]'
      , i_env_param1 => l_old_oper_id
      , i_env_param2 => l_result
    );
    return l_result;

end check_duplicated_message;

/*
 * Procedure generates and return a new dispute ID, incoming operation is marked with this ID.
 */
procedure initiate_dispute(
    i_oper_id                 in     com_api_type_pkg.t_long_id
  , o_dispute_id                 out com_api_type_pkg.t_long_id
) is
begin
    o_dispute_id := dsp_api_shared_data_pkg.get_id();

    update opr_operation
       set dispute_id = o_dispute_id
     where id         = i_oper_id;

end initiate_dispute;

/*
 * Save message into dsp_fin_message.
 */
procedure put_message(
    i_id                      in     com_api_type_pkg.t_long_id
  , i_init_rule               in     com_api_type_pkg.t_tiny_id
  , i_gen_rule                in     com_api_type_pkg.t_tiny_id
  , i_mask_error              in     com_api_type_pkg.t_boolean     default com_api_const_pkg.FALSE
) is 
begin
    insert into dsp_fin_message(
        id
      , init_rule
      , gen_rule
    )
    values(
        i_id
      , i_init_rule
      , i_gen_rule
    );

exception
    when dup_val_on_index then
        if nvl(i_mask_error, com_api_const_pkg.FALSE) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_error(
                i_error      => 'DSP_FIN_MSG_ALREADY_EXISTS'
              , i_env_param1 => i_id
            );
        else
            trc_log_pkg.debug(
                i_text       => 'Id [#1] is already exists'
              , i_env_param1 => i_id
            );
        end if;
end put_message;

/*
 * Getting dispute rules.
 */
procedure get_dispute_rule(
    i_id                      in     com_api_type_pkg.t_long_id
  , o_init_rule                  out com_api_type_pkg.t_tiny_id
  , o_gen_rule                   out com_api_type_pkg.t_tiny_id
  , i_mask_error              in     com_api_type_pkg.t_boolean     default com_api_const_pkg.FALSE
) is
begin
    select init_rule
         , gen_rule
      into o_init_rule
         , o_gen_rule
      from dsp_fin_message
     where id = i_id;

exception
    when no_data_found then
        if nvl(i_mask_error, com_api_const_pkg.FALSE) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_error(
                i_error      => 'DSP_FIN_MSG_NOT_FOUND'
              , i_env_param1 => i_id
            );
        else
            trc_log_pkg.debug(
                i_text       => 'Id [#1] is already exists'
              , i_env_param1 => i_id
            );
        end if; 
end get_dispute_rule;

/*
 * Remove dispute and related data
 */
procedure remove_dispute(
    i_id                      in     com_api_type_pkg.t_long_id
) is
begin
    if i_id is not null then
        if vis_api_fin_message_pkg.is_visa(i_id => i_id) = com_api_const_pkg.TRUE then
            vis_api_fin_message_pkg.remove_message(
                i_id => i_id
            );
        elsif mcw_api_fin_pkg.is_mastercard(i_id => i_id) = com_api_const_pkg.TRUE then
            mcw_api_fin_pkg.remove_message(
                i_id => i_id
            );
        elsif amx_api_fin_message_pkg.is_amex(i_id => i_id) = com_api_const_pkg.TRUE then
            amx_api_fin_message_pkg.remove_message(
                i_id => i_id
            );                 
            
        elsif mup_api_fin_pkg.is_mup(i_id => i_id) = com_api_const_pkg.TRUE then
            remove_mup_message(
                i_id => i_id
            );
        elsif is_jcb(i_id => i_id) = com_api_const_pkg.TRUE then
            remove_jbc_message(
                i_id => i_id
            );
        end if;
    end if;
end remove_dispute;

/*
 * Check if fin message is editable
 */  
function is_editable(
    i_id                      in     com_api_type_pkg.t_long_id
  , i_mask_error              in     com_api_type_pkg.t_boolean     default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_boolean
is
    l_res       com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE;
begin
    if vis_api_fin_message_pkg.is_visa(i_id => i_id) = com_api_const_pkg.TRUE then
        l_res := vis_api_fin_message_pkg.is_editable(
                     i_id    => i_id
                 );

    elsif mcw_api_fin_pkg.is_mastercard(i_id => i_id) = com_api_const_pkg.TRUE then
        l_res := mcw_api_fin_pkg.is_editable(
                     i_id    => i_id
                 );
    elsif amx_api_fin_message_pkg.is_amex(i_id => i_id) = com_api_const_pkg.TRUE then
        l_res := amx_api_fin_message_pkg.is_editable(
                     i_id => i_id
                 );                 
    else
        if nvl(i_mask_error, com_api_const_pkg.FALSE) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_error(
                i_error      => 'FIN_MESSAGE_FROM_UNSUPPORTED_IPS'
              , i_env_param1 => i_id
            );
        else
            trc_log_pkg.debug(
                i_text       => 'Financial message [#1] is from IPS unsupported by Case management module'
              , i_env_param1 => i_id
            );

            l_res := com_api_const_pkg.FALSE;
        end if;
    end if;

    return l_res;

end is_editable;

function is_doc_export_import_enabled(
    i_id                      in     com_api_type_pkg.t_long_id
  , i_mask_error              in     com_api_type_pkg.t_boolean     default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_boolean
is
    l_result       com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE;
begin
    if vis_api_fin_message_pkg.is_visa(i_id => i_id) = com_api_const_pkg.TRUE then
        l_result := vis_api_fin_message_pkg.is_doc_export_import_enabled(
                        i_id    => i_id
                    );

    elsif mcw_api_fin_pkg.is_mastercard(i_id => i_id) = com_api_const_pkg.TRUE then
        l_result := mcw_api_fin_pkg.is_doc_export_import_enabled(
                        i_id    => i_id
                    );
    else
        if nvl(i_mask_error, com_api_const_pkg.FALSE) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_error(
                i_error      => 'FIN_MESSAGE_FROM_UNSUPPORTED_IPS'
              , i_env_param1 => i_id
            );
        else
            trc_log_pkg.debug(
                i_text       => 'Financial message [#1] is from IPS unsupported by Case management module'
              , i_env_param1 => i_id
            );
        end if;
    end if;

    return l_result;
end is_doc_export_import_enabled;

/*
 * Check if current mode is editing
 */  
function is_editing return com_api_type_pkg.t_boolean
is
    l_is_editing    com_api_type_pkg.t_boolean;
begin
    l_is_editing := nvl(dsp_api_shared_data_pkg.get_param_num(
                            i_name          => 'EDITING'
                          , i_mask_error  => com_api_type_pkg.TRUE
                        )
                      , com_api_type_pkg.FALSE
                    );

    return l_is_editing;
end is_editing;

/*
 * Set operation id for new dispute message
 */  
procedure set_operation_id(
    i_oper_id    in     com_api_type_pkg.t_long_id
) is
begin
    dsp_api_shared_data_pkg.set_param(
        i_name   => 'OPERATION_ID'
      , i_value  => i_oper_id
    );        
end set_operation_id;

/*
 * Check if need "null" value when create dispute message
 */  
function is_null_value(
    i_value_null      in     com_api_type_pkg.t_boolean
) return com_api_type_pkg.t_boolean
is
    l_result    com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE;
begin
    if nvl(i_value_null, com_api_type_pkg.FALSE) = com_api_type_pkg.TRUE
       and is_editing = com_api_type_pkg.FALSE
    then
        l_result := com_api_type_pkg.TRUE;
    end if;

    return l_result;
end is_null_value;

end dsp_ui_process_pkg;
/
