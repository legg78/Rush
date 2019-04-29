create or replace package body cst_ap_env_unload_pkg is

procedure set_session_date(
    i_eff_date         in            date
  , io_params          in out nocopy com_api_type_pkg.t_param_tab
  , o_ap_session_id       out        com_api_type_pkg.t_short_id
) is
    l_start_date                     date;
    l_end_date                       date;
begin

    begin
    select distinct s.id
      into o_ap_session_id
      from opr_operation o
         , aup_tag_value tv
         , cst_ap_session s
     where o.id             = tv.auth_id
       and o.match_status   = cst_ap_api_const_pkg.STATUS_TP_FILE_LOADED
       and o.sttl_type      = cst_ap_api_const_pkg.STTT_SATIM_ON_US --'STTT5011'
       and tv.tag_id        = cst_ap_api_const_pkg.TAG_ID_SESSION_DAY -- 2005
       and s.status         = cst_ap_api_const_pkg.SESSION_ACTIVE
       and to_number(tv.tag_value) = s.id
       and i_eff_date between s.start_date and nvl(s.end_date, i_eff_date + 1);
    exception
        when too_many_rows then
            com_api_error_pkg.raise_error(
                i_error => 'AP_SESSION_TOO_MANY_ACTIVE_SESSIONS'
            );
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error => 'AP_SESSION_NO_ACTIVE_SESSIONS'
            );
    end;

    -- trc_log_pkg.debug('@@@ set_session_date(): o_ap_session_id['||o_ap_session_id||']');

    if o_ap_session_id is not null then

        cst_ap_api_process_pkg.get_ap_session_date(
            i_ap_session_id => o_ap_session_id
          , o_start_date    => l_start_date
          , o_end_date      => l_end_date
        );

        rul_api_param_pkg.set_param(
            i_name       => 'SESSION_DATE'
          , i_value      => l_end_date
          , io_params    => io_params
        );
    else
        com_api_error_pkg.raise_error(
            i_error => 'AP_SESSION_SESSION_DATE_IS_NOT_DEFINED'
        );
    end if;
end;

procedure prepare_env_operations(
    i_eff_date         in      date
  , i_ap_session_id    in      com_api_type_pkg.t_short_id     default null
  , o_oper_id_tab      out     num_tab_tpt
) is
    l_oper_id_tab              com_api_type_pkg.t_long_tab;
begin
    if i_ap_session_id is not null then

        select distinct o.id
          bulk collect into
               l_oper_id_tab
          from opr_operation o
             , aup_tag_value tv
             , cst_ap_session s
         where o.id             = tv.auth_id
           and o.match_status   = cst_ap_api_const_pkg.STATUS_TP_FILE_LOADED
           and o.sttl_type      = cst_ap_api_const_pkg.STTT_SATIM_ON_US --'STTT5011'
           and tv.tag_id        = cst_ap_api_const_pkg.TAG_ID_SESSION_DAY -- 2005
           --and s.status         = cst_ap_api_const_pkg.SESSION_ACTIVE
           and to_number(tv.tag_value) = s.id
           and s.id             = i_ap_session_id;
    else
        select distinct o.id
          bulk collect into
               l_oper_id_tab
          from opr_operation o
             , aup_tag_value tv
             , cst_ap_session s
         where o.id             = tv.auth_id
           and o.match_status   = cst_ap_api_const_pkg.STATUS_TP_FILE_LOADED
           and o.sttl_type      = cst_ap_api_const_pkg.STTT_SATIM_ON_US --'STTT5011'
           and tv.tag_id        = cst_ap_api_const_pkg.TAG_ID_SESSION_DAY -- 2005
           and s.status         = cst_ap_api_const_pkg.SESSION_ACTIVE
           and to_number(tv.tag_value) = s.id
           and i_eff_date   between s.start_date and nvl(s.end_date, i_eff_date + 1);
    end if;

    -- trc_log_pkg.debug('@@@ l_oper_id_tab.count['||l_oper_id_tab.count||']');

    o_oper_id_tab := num_tab_tpt();

    for i in 1 .. l_oper_id_tab.count loop
        o_oper_id_tab.extend;
        o_oper_id_tab(o_oper_id_tab.last) := l_oper_id_tab(i);
    end loop;

end prepare_env_operations;

function get_auth(
    i_id                 in      com_api_type_pkg.t_long_id
) return aut_api_type_pkg.t_auth_rec is
  l_auth                         aut_api_type_pkg.t_auth_rec;
begin
    select id
         , resp_code
         , proc_type
         , proc_mode
         , is_advice
         , is_repeat
         , bin_amount
         , bin_currency
         , bin_cnvt_rate
         , network_amount
         , network_currency
         , network_cnvt_date
         , network_cnvt_rate
         , account_cnvt_rate
         , parent_id
         , addr_verif_result
         , iss_network_device_id
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
         , cvv2_result
         , certificate_method
         , certificate_type
         , merchant_certif
         , cardholder_certif
         , ucaf_indicator
         , is_early_emv
         , is_completed
         , amounts
         , cavv_presence
         , aav_presence
         , transaction_id
         , system_trace_audit_number
         , external_auth_id
         , external_orig_id
         , agent_unique_id
         , native_resp_code
         , trace_number
         , auth_purpose_id
      into l_auth.id
         , l_auth.resp_code
         , l_auth.proc_type
         , l_auth.proc_mode
         , l_auth.is_advice
         , l_auth.is_repeat
         , l_auth.bin_amount
         , l_auth.bin_currency
         , l_auth.bin_cnvt_rate
         , l_auth.network_amount
         , l_auth.network_currency
         , l_auth.network_cnvt_date
         , l_auth.network_cnvt_rate
         , l_auth.account_cnvt_rate
         , l_auth.parent_id
         , l_auth.addr_verif_result
         , l_auth.iss_network_device_id
         , l_auth.acq_device_id
         , l_auth.acq_resp_code
         , l_auth.acq_device_proc_result
         , l_auth.cat_level
         , l_auth.card_data_input_cap
         , l_auth.crdh_auth_cap
         , l_auth.card_capture_cap
         , l_auth.terminal_operating_env
         , l_auth.crdh_presence
         , l_auth.card_presence
         , l_auth.card_data_input_mode
         , l_auth.crdh_auth_method
         , l_auth.crdh_auth_entity
         , l_auth.card_data_output_cap
         , l_auth.terminal_output_cap
         , l_auth.pin_capture_cap
         , l_auth.pin_presence
         , l_auth.cvv2_presence
         , l_auth.cvc_indicator
         , l_auth.pos_entry_mode
         , l_auth.pos_cond_code
         , l_auth.emv_data
         , l_auth.atc
         , l_auth.tvr
         , l_auth.cvr
         , l_auth.addl_data
         , l_auth.service_code
         , l_auth.device_date
         , l_auth.cvv2_result
         , l_auth.certificate_method
         , l_auth.certificate_type
         , l_auth.merchant_certif
         , l_auth.cardholder_certif
         , l_auth.ucaf_indicator
         , l_auth.is_early_emv
         , l_auth.is_completed
         , l_auth.amounts
         , l_auth.cavv_presence
         , l_auth.aav_presence
         , l_auth.transaction_id
         , l_auth.system_trace_audit_number
         , l_auth.external_auth_id
         , l_auth.external_orig_id
         , l_auth.agent_unique_id
         , l_auth.native_resp_code
         , l_auth.trace_number
         , l_auth.auth_purpose_id
      from aut_auth
     where id = i_id;

     return l_auth;

exception
    when no_data_found then
        trc_log_pkg.warn(
            i_text       => 'Authorization[#1] not found'
          , i_env_param1 => i_id
        );

        return null;
end get_auth;

function get_part_code(
    i_inst_id           in     com_api_type_pkg.t_inst_id
) return com_api_type_pkg.t_dict_value is
    l_part_code                com_api_type_pkg.t_short_desc;
begin
    l_part_code := substr(
                       com_api_flexible_data_pkg.get_flexible_value(
                           i_field_name  => 'CST_PARTICIPANT_CODE'
                         , i_entity_type => 'ENTTINST'
                         , i_object_id   => i_inst_id
                       )
                     , 1
                     , 200
                   );

    if length(l_part_code) > 3
        or l_part_code is null then

        com_api_error_pkg.raise_error(
            i_error      => 'INST_PARTICIPANT_CODE_HAS_WRONG_VALUE'
          , i_env_param1 => l_part_code
        );
    else
        trc_log_pkg.debug(
            i_text       => 'Flexible parameter of institution CST_PARTICIPANT_CODE is [#1]'
          , i_env_param1 => lpad(l_part_code, 3, '0')
        );

        return lpad(l_part_code, 3, '0');
    end if;

end get_part_code;

procedure unload_file(
    i_inst_id          in            com_api_type_pkg.t_inst_id
  , i_file_type        in            com_api_type_pkg.t_dict_value
  , io_params          in out nocopy com_api_type_pkg.t_param_tab
  , i_eff_date         in            date
  , i_env_file_oper_type in          com_api_type_pkg.t_dict_value
  , i_oper_id_tab      in            num_tab_tpt
  , io_estimated_count in out nocopy com_api_type_pkg.t_count
  , io_processed_count in out nocopy com_api_type_pkg.t_count
  , io_sess_env_file_seq in out nocopy com_api_type_pkg.t_count
) is
    l_session_file_id                com_api_type_pkg.t_long_id;
    l_part_code                      com_api_type_pkg.t_dict_value;

    l_emv_tags_tab                   com_api_type_pkg.t_tag_value_tab;
    l_auth                           aut_api_type_pkg.t_auth_rec;

    l_line                           com_api_type_pkg.t_raw_data;
    l_count                          com_api_type_pkg.t_count        := 0;

    l_total_amount                   com_api_type_pkg.t_money        := 0;
    l_operation_count                com_api_type_pkg.t_count        := 0;
    l_first_oper_id                  com_api_type_pkg.t_long_id;
    l_cst_ap_session_id              com_api_type_pkg.t_long_id;

    l_cst_ap_session_end_date        com_api_type_pkg.t_date_short;

    l_oper_id_tab                    com_api_type_pkg.t_long_tab;
    l_sql_rowcount                   com_api_type_pkg.t_count        := 0;
    l_oper_seq                       com_api_type_pkg.t_tiny_id;
    l_oper_amount_tab                com_api_type_pkg.t_money_tab;
    l_external_auth_id_tab           com_api_type_pkg.t_long_tab;
    l_auth_resp_code_tab             com_api_type_pkg.t_dict_tab;
    l_auth_code_tab                  com_api_type_pkg.t_auth_code_tab;
    l_card_number_tab                com_api_type_pkg.t_card_number_tab;
    l_terminal_number_tab            com_api_type_pkg.t_terminal_number_tab;
    l_amount_comission_tab           com_api_type_pkg.t_money_tab;
    l_host_date_tab                  com_api_type_pkg.t_date_tab;
    l_merchant_number_tab            com_api_type_pkg.t_merchant_number_tab;
    l_merchant_account_number_tab    com_api_type_pkg.t_account_number_tab;
    l_oper_type_tab                  com_api_type_pkg.t_dict_tab;
    l_oper_mcc_tab                   com_api_type_pkg.t_mcc_tab;
    l_terminal_type_tab              com_api_type_pkg.t_dict_tab;
    l_merchant_name_tab              com_api_type_pkg.t_name_tab;
    l_merchant_id_tab                com_api_type_pkg.t_short_tab;
    l_card_expir_date_tab            com_api_type_pkg.t_date_tab;
    l_participants_count_tab         com_api_type_pkg.t_tiny_tab;

    PROCESS_DATE           constant  com_api_type_pkg.t_date_short := to_char(com_api_sttl_day_pkg.get_sysdate, 'yyyymmdd');
    PROCESS_TIME           constant  com_api_type_pkg.t_date_short := to_char(com_api_sttl_day_pkg.get_sysdate, 'hh24miss');

    cursor cu_env_oper_sum(
        i_eff_date            in      date
      , i_oper_id_tab         in      num_tab_tpt
      , i_file_type           in      com_api_type_pkg.t_dict_value
      , i_env_file_oper_type  in      com_api_type_pkg.t_byte_char
    ) is
        select sum(op.oper_amount) + sum(aa.amount)
             , count(distinct op.id)
             , count(1)
             , min(op.id) first_oper_id
          from aut_auth              au
             , opr_operation         op
             , opr_card              ca
             , opr_participant       opa
             , opr_participant       opi
             , opr_additional_amount aa
             , acq_merchant          me
         where au.id = op.id
           and op.id = opa.oper_id
           and op.id = opi.oper_id
           and op.id = ca.oper_id
           and op.msg_type = opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
           and opi.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
           and opa.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
           and aa.oper_id(+)   = op.id
           and aa.amount_type = cst_ap_api_const_pkg.AMOUNT_INTERCHANGE
--           and op.sttl_type = cst_ap_api_const_pkg.STTT_SATIM_ON_US
           and ((i_file_type = cst_ap_api_const_pkg.FILETYPE_ENV_ATM and op.oper_type in (opr_api_const_pkg.OPERATION_TYPE_ATM_CASH, opr_api_const_pkg.OPERATION_TYPE_BALANCE_INQUIRY))
             or (i_file_type = cst_ap_api_const_pkg.FILETYPE_ENV_POS and op.oper_type in (opr_api_const_pkg.OPERATION_TYPE_PURCHASE, opr_api_const_pkg.OPERATION_TYPE_POS_CASH, opr_api_const_pkg.OPERATION_TYPE_PAYMENT, cst_ap_api_const_pkg.OPER_TYPE_DEBIT_NOTIF))
             or (i_file_type = cst_ap_api_const_pkg.FILETYPE_ENV_REFUND and op.oper_type in (opr_api_const_pkg.OPERATION_TYPE_REFUND))
               )
           and ((i_env_file_oper_type = cst_ap_api_const_pkg.ENV_FILE_OPERATION_TYPE_PRES   and au.resp_code is null)
             or (i_env_file_oper_type = cst_ap_api_const_pkg.ENV_FILE_OPERATION_TYPE_REJECT and au.resp_code is not null)
               )
--           and trunc(op.oper_date) >= trunc(i_eff_date - cst_ap_api_const_pkg.ENV_UPLOAD_DELAY)   -- Aks >= not =, i_eff_date     parametrizable, if null upload for the maximum last 5 days
           and opa.merchant_id = me.id(+)
--           and op.match_status = cst_ap_api_const_pkg.STATUS_TP_FILE_LOADED
           and op.id in (select column_value from table(cast(i_oper_id_tab as num_tab_tpt)));

    cursor cu_env_oper(
        i_eff_date            in      date
      , i_oper_id_tab         in      num_tab_tpt
      , i_file_type           in      com_api_type_pkg.t_dict_value
      , i_env_file_oper_type  in      com_api_type_pkg.t_byte_char
    ) is
        select op.id    oper_id
             , op.oper_amount                       --Amount of operation
             , au.external_auth_id                  --Transaction number
             , au.resp_code
             , opi.auth_code
             , opa.merchant_id
             , ca.card_number
             , op.terminal_number
             , aa.amount
             , op.host_date                         --Date of Withdrawal
             , me.merchant_number
             , xx_acc_obj.merchant_account_number
             , op.oper_type
             , op.mcc
             , op.terminal_type
             , op.merchant_name
             , opi.card_expir_date
             , row_number() over(partition by op.id order by op.id) participants_count
          from aut_auth              au
             , opr_operation         op
             , opr_card              ca
             , opr_participant       opi
             , opr_participant       opa
             , opr_additional_amount aa
             , acq_merchant          me
             , (select ao.object_id
                     , ac.account_number                                       merchant_account_number
                     , row_number() over(partition by object_id order by null) object_row_number
                  from acc_account_object ao
                     , acc_account        ac
                 where ao.account_id   = ac.id
                   and ao.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
               )                     xx_acc_obj
         where au.id = op.id
           and op.id = opa.oper_id
           and op.id = opi.oper_id
           and op.id = ca.oper_id
           and op.msg_type = opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
           and opi.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
           and opa.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
           and aa.oper_id(+)   = op.id
           and aa.amount_type = cst_ap_api_const_pkg.AMOUNT_INTERCHANGE
--           and op.sttl_type = cst_ap_api_const_pkg.STTT_SATIM_ON_US
           and ((i_file_type = cst_ap_api_const_pkg.FILETYPE_ENV_ATM and op.oper_type in (opr_api_const_pkg.OPERATION_TYPE_ATM_CASH, opr_api_const_pkg.OPERATION_TYPE_BALANCE_INQUIRY))
             or (i_file_type = cst_ap_api_const_pkg.FILETYPE_ENV_POS and op.oper_type in (opr_api_const_pkg.OPERATION_TYPE_PURCHASE, opr_api_const_pkg.OPERATION_TYPE_POS_CASH, opr_api_const_pkg.OPERATION_TYPE_PAYMENT, cst_ap_api_const_pkg.OPER_TYPE_DEBIT_NOTIF))
             or (i_file_type = cst_ap_api_const_pkg.FILETYPE_ENV_REFUND and op.oper_type in (opr_api_const_pkg.OPERATION_TYPE_REFUND))
               )
           and ((i_env_file_oper_type = cst_ap_api_const_pkg.ENV_FILE_OPERATION_TYPE_PRES   and au.resp_code is null)
             or (i_env_file_oper_type = cst_ap_api_const_pkg.ENV_FILE_OPERATION_TYPE_REJECT and au.resp_code is not null)
               )
--           and trunc(op.oper_date) >= trunc(i_eff_date - cst_ap_api_const_pkg.ENV_UPLOAD_DELAY)   -- Aks >= not =, i_eff_date     parametrizable, if null upload for the maximum last 5 days
           and opa.merchant_id = me.id(+)
           and xx_acc_obj.object_id(+) = me.id
           and xx_acc_obj.object_row_number(+) = 1
--           and op.match_status = cst_ap_api_const_pkg.STATUS_TP_FILE_LOADED
           and op.id in (select column_value from table(cast(i_oper_id_tab as num_tab_tpt)));

    procedure set_cst_ap_session_end_date
    is
    begin
        l_auth := get_auth(i_id => l_first_oper_id);

        if l_auth.id is not null then

            emv_api_tag_pkg.parse_emv_data(
                i_emv_data    => l_auth.emv_data
              , o_emv_tag_tab => l_emv_tags_tab
              , i_is_binary   => emv_api_tag_pkg.is_binary()
            );

            l_cst_ap_session_id :=
                aup_api_tag_pkg.get_tag_value(
                    i_auth_id => l_auth.id
                  , i_tag_id  => aup_api_tag_pkg.find_tag_by_reference(i_reference => 'CST_AP_SESSION')
                );

            if l_cst_ap_session_id is null then
                l_cst_ap_session_id :=
                    aup_api_tag_pkg.get_tag_value(
                        i_auth_id => l_auth.id
                      , i_tag_id  => aup_api_tag_pkg.find_tag_by_reference(i_reference => 'CST_SESSION_DAY')
                    );
                trc_log_pkg.debug(i_text => 'Aup tag CST_SESSION_DAY value['||l_cst_ap_session_id||']');
            end if;

            if l_cst_ap_session_id is null then
                l_cst_ap_session_id :=
                    aup_api_tag_pkg.get_tag_value(
                        i_auth_id => l_auth.id
                      , i_tag_id  => aup_api_tag_pkg.find_tag_by_reference(i_reference => '2005')
                    );
                trc_log_pkg.debug(i_text => 'Aup tag 2005 value['||l_cst_ap_session_id||']');
            end if;

            if l_cst_ap_session_id is not null then
                begin
                    select to_char(end_date, 'yyyymmdd')
                      into l_cst_ap_session_end_date
                      from cst_ap_session
                     where id = l_cst_ap_session_id;
                exception
                    when no_data_found then
                        com_api_error_pkg.raise_error(i_error => 'TABLE_CST_AP_SESSION_HAS_NO_ID');
                end;

                trc_log_pkg.debug(
                    i_text       => 'End date[#1] for session[#2]'
                  , i_env_param1 => l_cst_ap_session_end_date
                  , i_env_param2 => l_cst_ap_session_id
                );
            else
                com_api_error_pkg.raise_error(i_error => 'TAG_CST_AP_SESSION_NOT_DEFINED_FOR_OPERATION');
            end if;

        end if;
    end;

    function process_header(
        i_part_code         in     com_api_type_pkg.t_dict_value
      , i_total_amount      in     com_api_type_pkg.t_money
      , i_operation_count   in     com_api_type_pkg.t_count
    ) return com_api_type_pkg.t_raw_data is
        l_line                     com_api_type_pkg.t_raw_data;
    begin

        set_cst_ap_session_end_date;

        l_line := l_line || '1';                                                   --Sign                                                            --1
        l_line := l_line || '01';                                                  --Comensation code                                                --2
        l_line := l_line || 'DZ';                                                  --Currency code                                                   --4
        l_line := l_line || l_cst_ap_session_end_date;                             --Date of generation                                              --6
        l_line := l_line || lpad('0', 6, '0');                                     --Time of generation                                              --14

        l_line := l_line || case when i_file_type = cst_ap_api_const_pkg.FILETYPE_ENV_ATM    then cst_ap_api_const_pkg.FILE_OPERATION_TYPE_ATM
                                 when i_file_type = cst_ap_api_const_pkg.FILETYPE_ENV_POS    then cst_ap_api_const_pkg.FILE_OPERATION_TYPE_POS
                                 when i_file_type = cst_ap_api_const_pkg.FILETYPE_ENV_REFUND then cst_ap_api_const_pkg.FILE_OPERATION_TYPE_REFUND
                                 end;                                              --Operation code                                                  --20
        l_line := l_line || lpad(nvl(i_part_code, '0'), 3, '0');                   --Participant code                                                --22
        l_line := l_line || l_cst_ap_session_end_date;                             --Presentation date                                               --25
        l_line := l_line || l_cst_ap_session_end_date;                             --Presentation date                                               --33
        l_line := l_line || lpad(io_sess_env_file_seq, 4, '0');                    --Number of delivery                                              --41

        l_line := l_line || case when i_env_file_oper_type = cst_ap_api_const_pkg.ENV_FILE_OPERATION_TYPE_PRES   then '11'
                                 when i_env_file_oper_type = cst_ap_api_const_pkg.ENV_FILE_OPERATION_TYPE_REJECT then '12'
                                 end;                                              --Registration code                                               --45
        l_line := l_line || '012';                                                 --Currency code                                                   --47
        l_line := l_line || lpad(i_total_amount, 15, '0');                         --Total amount                                                    --50
        l_line := l_line || lpad(i_operation_count, 10, '0');                      --Number of operation                                             --65
        l_line := l_line || '000';                                                 --Source identification                                           --75
        l_line := l_line || lpad(' ', 573, ' ');                                   --Filler                                                          --78

        return l_line;

    end;

    function get_line(
        i_oper_id            in com_api_type_pkg.t_long_id
      , i_oper_amount        in com_api_type_pkg.t_money
      , i_external_auth_id   in com_api_type_pkg.t_long_id
      , i_auth_resp_code     in com_api_type_pkg.t_dict_value
      , i_auth_code          in com_api_type_pkg.t_auth_code
      , i_card_number        in com_api_type_pkg.t_card_number
      , i_terminal_number    in com_api_type_pkg.t_terminal_number
      , i_amount_comission   in com_api_type_pkg.t_money
      , i_host_date          in date
      , i_merchant_number    in com_api_type_pkg.t_merchant_number
      , i_merchant_account_number in com_api_type_pkg.t_account_number
      , i_oper_type          in com_api_type_pkg.t_dict_value
      , i_oper_mcc           in com_api_type_pkg.t_mcc
      , i_terminal_type      in com_api_type_pkg.t_dict_value
      , i_merchant_name      in com_api_type_pkg.t_name
      , i_merchant_id        in com_api_type_pkg.t_short_id
      , i_card_expir_date    in com_api_type_pkg.t_date_long
      , i_oper_seq           in com_api_type_pkg.t_tiny_id
    ) return com_api_type_pkg.t_raw_data
    is
        l_line                     com_api_type_pkg.t_raw_data;
        l_tag_cst_iss_part_code    com_api_type_pkg.t_short_desc;
        l_tag_cst_atm_connection   com_api_type_pkg.t_short_desc;
        l_tag_cst_agent_code       com_api_type_pkg.t_short_desc;
        l_tag_cst_ap_reference     com_api_type_pkg.t_short_desc;
        l_tag_cst_ap_rio           com_api_type_pkg.t_short_desc;

--        l_pos                      pls_integer;
--        l_emv_length               pls_integer;
--        l_tag_9f26                 com_api_type_pkg.t_short_desc;
        l_tag_9f27                 com_api_type_pkg.t_short_desc;
        l_tag_9f36                 com_api_type_pkg.t_short_desc;
        l_tag_95                   com_api_type_pkg.t_short_desc;

        l_address_id               com_api_type_pkg.t_long_id;
        l_merchant_address         com_api_type_pkg.t_short_desc;
    begin

        l_auth := get_auth(i_id => i_oper_id);

        if l_auth.id is not null then

            emv_api_tag_pkg.parse_emv_data(
                i_emv_data    => l_auth.emv_data
              , o_emv_tag_tab => l_emv_tags_tab
              , i_is_binary   => emv_api_tag_pkg.is_binary()
            );

            l_tag_cst_iss_part_code :=
                aup_api_tag_pkg.get_tag_value(
                    i_auth_id => l_auth.id
                  , i_tag_id  => aup_api_tag_pkg.find_tag_by_reference(i_reference => 'CST_ISS_PART_CODE')
                );

            l_tag_cst_atm_connection :=
                aup_api_tag_pkg.get_tag_value(
                    i_auth_id => l_auth.id
                  , i_tag_id  => aup_api_tag_pkg.find_tag_by_reference(i_reference => 'CST_ATM_CONNECTION')
                );

            l_tag_cst_agent_code :=
                aup_api_tag_pkg.get_tag_value(
                    i_auth_id => l_auth.id
                  , i_tag_id  => aup_api_tag_pkg.find_tag_by_reference(i_reference => 'CST_AGENT_CODE')
                );

            l_tag_cst_ap_reference :=
                aup_api_tag_pkg.get_tag_value(
                    i_auth_id => l_auth.id
                  , i_tag_id  => aup_api_tag_pkg.find_tag_by_reference(i_reference => 'CST_AP_REFERENCE')
                );

            l_tag_cst_ap_rio :=
                aup_api_tag_pkg.get_tag_value(
                    i_auth_id => l_auth.id
                  , i_tag_id  => aup_api_tag_pkg.find_tag_by_reference(i_reference => 'CST_AP_RIO')
                );

            if l_auth.emv_data is not null then

                begin
                    emv_api_tag_pkg.parse_emv_data(
                        i_emv_data    => l_auth.emv_data
                      , o_emv_tag_tab => l_emv_tags_tab
                      , i_is_binary   => com_api_const_pkg.TRUE
                    );

                    l_tag_9f27 :=
                        emv_api_tag_pkg.get_tag_value(
                            i_tag            => '9F27'
                          , i_emv_tag_tab    => l_emv_tags_tab
                        );

                    l_tag_9f36 :=
                        emv_api_tag_pkg.get_tag_value(
                            i_tag            => '9F36'
                          , i_emv_tag_tab    => l_emv_tags_tab
                        );

                    l_tag_95 :=
                        emv_api_tag_pkg.get_tag_value(
                            i_tag            => '95'
                          , i_emv_tag_tab    => l_emv_tags_tab
                        );
                exception
                    when others then
                        trc_log_pkg.debug(
                            i_text       => 'Exception on operation[#1]'
                          , i_env_param1 => i_oper_id
                        );
                        raise;
                end;
            end if;

        else
            trc_log_pkg.debug(
                i_text       => 'Auth[#1] is not exist'
              , i_env_param1 => i_oper_id
            );

            l_tag_cst_iss_part_code  := '0';
            l_tag_cst_atm_connection := ' ';
            l_tag_cst_agent_code     := '0';
            l_tag_9f27               := '0';
            l_tag_9f36               := '0';
            l_tag_95                 := '0';
        end if;

                                                                                                                                               -- OFFSET
        l_line := l_line || '1';                                                   --Sign                                                      -- 1
        l_line := l_line || '01';                                                  --Comensation code                                          -- 2
        l_line := l_line || 'DZ';                                                  --Currency code                                             -- 4
        l_line := l_line || l_cst_ap_session_end_date;                             --Date of generation                                        -- 6
        l_line := l_line || PROCESS_TIME;                                          --Time of generation Aks: sysdate                           -- 14
        l_line := l_line || case when i_file_type = cst_ap_api_const_pkg.FILETYPE_ENV_ATM    then cst_ap_api_const_pkg.FILE_OPERATION_TYPE_ATM -- 20
                                 when i_file_type = cst_ap_api_const_pkg.FILETYPE_ENV_POS    then cst_ap_api_const_pkg.FILE_OPERATION_TYPE_POS
                                 when i_file_type = cst_ap_api_const_pkg.FILETYPE_ENV_REFUND then cst_ap_api_const_pkg.FILE_OPERATION_TYPE_REFUND
                                 end;                                              --Operation code
        l_line := l_line || nvl(l_part_code, '000');                               --Participant code                                          -- 22
        l_line := l_line || l_cst_ap_session_end_date;                             --Presentation date                            -- 25
        l_line := l_line || l_cst_ap_session_end_date;                             --Presentation date                            -- 33
        l_line := l_line || lpad(io_sess_env_file_seq, 4, '0');                    --Number of delivery                                        -- 41

        l_line := l_line || case when i_env_file_oper_type = cst_ap_api_const_pkg.ENV_FILE_OPERATION_TYPE_PRES   then cst_ap_api_const_pkg.ENV_OPERATION_TYPE_CODE_PRES
                                 when i_env_file_oper_type = cst_ap_api_const_pkg.ENV_FILE_OPERATION_TYPE_REJECT then cst_ap_api_const_pkg.ENV_OPERATION_TYPE_CODE_REJECT
                                 end;                                              --Registration code                                         -- 45
        l_line := l_line || '012';                                                 --Currency code                                             -- 47

        l_line := l_line || case when i_file_type in (cst_ap_api_const_pkg.FILETYPE_ENV_ATM, cst_ap_api_const_pkg.FILETYPE_ENV_REFUND)    then lpad(nvl(i_oper_amount + i_amount_comission, '0'), 15, '0')
                                 when i_file_type = cst_ap_api_const_pkg.FILETYPE_ENV_POS then lpad(nvl(i_oper_amount - i_amount_comission, '0'), 15, '0')
                                 end;                                              --Amount of operation                                 -- 50


        l_line := l_line || lpad(nvl(i_external_auth_id, '0'), 12, '0');           --Transaction number                                        -- 65
        l_line := l_line || lpad(nvl(i_auth_code, '0'), 20, '0');                  --Authorization number                                      -- 77

        l_line := l_line || case when i_file_type = cst_ap_api_const_pkg.FILETYPE_ENV_ATM then 'DAB'                                           -- 97
                                 when i_file_type in (cst_ap_api_const_pkg.FILETYPE_ENV_POS, cst_ap_api_const_pkg.FILETYPE_ENV_REFUND) then 'TPE'
                                 end;                                              --Type of operation
        l_line := l_line || lpad(nvl(l_tag_cst_iss_part_code, '0'), 3, '0');       --Code of destination participant                           -- 100
        l_line := l_line || 'DZ';                                                  --Destination currency                                      -- 103

        if i_file_type = cst_ap_api_const_pkg.FILETYPE_ENV_ATM then
            l_line := l_line || lpad(' ', 20, ' ');                                --RIB of the creditor                                       -- 105
        elsif i_file_type in (cst_ap_api_const_pkg.FILETYPE_ENV_POS, cst_ap_api_const_pkg.FILETYPE_ENV_REFUND) then
            l_line := l_line || lpad(nvl(i_merchant_account_number, '0'), 20, '0');--RIB of the creditor                                       -- 105
        end if;

        l_line := l_line || lpad(nvl(i_card_number, ' '), 16, ' ');                --Card number                                               -- 125

        l_line := l_line || rpad(nvl(i_terminal_number, ' '), 10, ' '); -- Point number TAG21                                           -- 141
        if i_file_type = cst_ap_api_const_pkg.FILETYPE_ENV_ATM then
            l_line := l_line || rpad(nvl(l_tag_cst_atm_connection, ' '), 10, ' ');                                      --Terminal number TAG22                                            -- 151

        elsif i_file_type in (cst_ap_api_const_pkg.FILETYPE_ENV_POS, cst_ap_api_const_pkg.FILETYPE_ENV_REFUND) then

            l_line := l_line || case when i_terminal_type = acq_api_const_pkg.TERMINAL_TYPE_POS  then '00SATIMTPE'                             -- 151
                                     when i_terminal_type = acq_api_const_pkg.TERMINAL_TYPE_EPOS then '00SATIMTPE'
                                     else lpad(' ', 10, ' ')
                                     end;                                          --Terminal number TAG22
        end if;

        l_line := l_line || case when i_file_type = cst_ap_api_const_pkg.FILETYPE_ENV_ATM then lpad(' ', 11, ' ')                              -- 161
                                 when i_file_type in (cst_ap_api_const_pkg.FILETYPE_ENV_POS, cst_ap_api_const_pkg.FILETYPE_ENV_REFUND) then rpad(nvl(i_merchant_number, ' '), 11, ' ')
                                 end;                                              --Merchant number

        l_line := l_line || lpad(' ', 8, ' ');                                     --Date of regulation                                        -- 172
        l_line := l_line || case when i_env_file_oper_type = cst_ap_api_const_pkg.ENV_FILE_OPERATION_TYPE_PRES   then lpad('0', 8, '0')                            -- 180
                                 when i_env_file_oper_type = cst_ap_api_const_pkg.ENV_FILE_OPERATION_TYPE_REJECT then lpad(nvl(i_auth_resp_code, '0'), 8, '0')
                                 end;                                              --Reson for reject

        l_line := l_line || case when i_env_file_oper_type = cst_ap_api_const_pkg.ENV_FILE_OPERATION_TYPE_PRES   then lpad(PROCESS_DATE || 'SCM' || substr(i_oper_id, -7, 7), 18, ' ')
                                 when i_env_file_oper_type = cst_ap_api_const_pkg.ENV_FILE_OPERATION_TYPE_REJECT then lpad(nvl(l_tag_cst_ap_reference, ' '), 18, ' ')
                                 end;                                              --Reference of operation                                    -- 188

        l_line := l_line || case when i_env_file_oper_type = cst_ap_api_const_pkg.ENV_FILE_OPERATION_TYPE_PRES   then lpad(' ', 38, ' ')       -- 206
                                 when i_env_file_oper_type = cst_ap_api_const_pkg.ENV_FILE_OPERATION_TYPE_REJECT then lpad(nvl(l_tag_cst_ap_rio, ' '), 38, ' ')
                                 end;                                              --RIO of operation

        if i_file_type = cst_ap_api_const_pkg.FILETYPE_ENV_ATM then
            l_line := l_line || lpad(nvl(l_tag_cst_agent_code, '0'), 5, '0');      --Destination Agency code                                   -- 244
            l_line := l_line || lpad(nvl(i_oper_amount, '0'), 15, '0');            --Withdrawal Amount                                         -- 249
            l_line := l_line || 'C';                                               --Sign of commission                                        -- 264

            l_line := l_line || lpad(nvl(i_amount_comission, '0'), 7, '0');        --Amount of commision                                       -- 265
            l_line := l_line || nvl(to_char(i_host_date, 'yyyymmdd'), '00000000'); --Date of Withdrawal                                        -- 272
            l_line := l_line || nvl(to_char(i_host_date, 'hh24miss'), '000000');   --Time of Withdrawal                                        -- 280
            l_line := l_line || '2';                                               --Processing mode                                           -- 286
            l_line := l_line || '1';                                               --Authentication Mode                                       -- 287

            l_line := l_line || lpad('0', 8, '0');                                 --Start date of validation card                             -- 288
            l_line := l_line || lpad('0', 8, '0');                                 --End date of validation card                               -- 296
            l_line := l_line || lpad(nvl(l_tag_9f27, '0'), 1, '0');                --Criptogram information                                    -- 304
            l_line := l_line || lpad(nvl(l_tag_9f36, '0'), 2, '0');                --ATC                                                       -- 305
            l_line := l_line || lpad(nvl(l_tag_95, '0'), 5, '0');                  --TVR                                                       -- 307

            l_line := l_line || lpad(' ', 5, ' ');                                 --Remitting agency code                                     -- 312
            l_line := l_line || lpad(' ', 334, ' ');                               --Filler                                                    -- 317

        elsif i_file_type in (cst_ap_api_const_pkg.FILETYPE_ENV_POS, cst_ap_api_const_pkg.FILETYPE_ENV_REFUND) then

            l_line := l_line ||                                                                                                                -- 244
                nvl(
                    case when i_oper_type = opr_api_const_pkg.OPERATION_TYPE_PURCHASE
                             then cst_ap_api_const_pkg.PAYM_TYPE_PAYMENT

                         when i_oper_type = opr_api_const_pkg.OPERATION_TYPE_POS_CASH
                             then cst_ap_api_const_pkg.PAYM_TYPE_CASH_ADVANCE

                         when i_oper_type = opr_api_const_pkg.OPERATION_TYPE_PAYMENT   and i_terminal_type = acq_api_const_pkg.TERMINAL_TYPE_EPOS
                             then cst_ap_api_const_pkg.PAYM_TYPE_OTHER_PAYM_VIA_INT

                         when i_oper_type = cst_ap_api_const_pkg.OPER_TYPE_DEBIT_NOTIF and i_terminal_type = acq_api_const_pkg.TERMINAL_TYPE_EPOS
                             then cst_ap_api_const_pkg.PAYM_TYPE_OTHER_PAYM_VIA_INT

                         when i_oper_type = opr_api_const_pkg.OPERATION_TYPE_PAYMENT   and i_terminal_type = acq_api_const_pkg.TERMINAL_TYPE_POS
                             then cst_ap_api_const_pkg.PAYM_TYPE_BILL_PAYM_VIA_POS
                    end
                  , '00'
                );                                                                 --Payment type

            l_line := l_line || lpad(nvl(i_oper_amount, '0'), 15, '0');            --Amount                                                       -- 246
            l_line := l_line || case when i_file_type = cst_ap_api_const_pkg.FILETYPE_ENV_POS then 'C'                                            -- 261
                                     else 'D'
                                     end;                                          --Sign of operation
            l_line := l_line || 'C';                                               --Sign of comission

            l_line := l_line || lpad(nvl(i_amount_comission, '0'), 7, '0');        --Amount of commision                                          -- 263
            l_line := l_line || nvl(to_char(i_host_date, 'yyyymmdd'), '00000000'); --Date of payment                                              -- 270
            l_line := l_line || nvl(to_char(i_host_date, 'hh24miss'), '000000');   --Time of payment                                              -- 278
            l_line := l_line || '2';                                               --Processing mode                                              -- 284
            l_line := l_line || case when i_terminal_type = acq_api_const_pkg.TERMINAL_TYPE_EPOS then '3'                                         -- 285
                                     else '1'
                                     end;                                          --Authentication Mode

            l_line := l_line || lpad('0', 8, '0');                                 --End date of validation card                                  -- 286
            l_line := l_line || lpad(nvl(to_char(i_card_expir_date, 'yyyymmdd'), '0'), 8, '0');  --Start date of validation card                  -- 294

            l_line := l_line || lpad(nvl(l_tag_9f27, '0'), 1, '0');                --Criptogram information                                       -- 302
            l_line := l_line || lpad(nvl(l_tag_9f36, '0'), 2, '0');                --ATC                                                          -- 303
            l_line := l_line || lpad(nvl(l_tag_95, '0'), 5, '0');                  --TVR                                                          -- 305

            l_line := l_line || lpad(PROCESS_DATE, 8, '0');                        --Acceptor customer discount date                              -- 310
            l_line := l_line || '1';                                               --Presence indicator RIB/IBAN                                  -- 318
            l_line := l_line || lpad(' ', 4, ' ');                                 --Prefix IBAN                                                  -- 319
            l_line := l_line || rpad(nvl(i_merchant_name, ' '), 50, ' ');          --Name and surname or business name of the merchant            -- 323

            l_address_id := acq_api_merchant_pkg.get_merchant_address_id(i_merchant_id => i_merchant_id);

            if l_address_id is not null then
                l_merchant_address := com_api_address_pkg.get_address_string(
                                          i_address_id => l_address_id
                                        , i_lang       => get_user_lang
                                      );
                l_line := l_line || rpad(nvl(l_merchant_address, ' '), 70, ' ');   --Address of merchant                                          -- 373
            else
                l_line := l_line || lpad(' ', 70, ' ');                                                                                           -- 373
            end if;

            l_line := l_line || lpad('0', 10, '0');                                --Telephone of merchant                                        -- 443
            l_line := l_line || rpad(nvl(i_merchant_number, ' '), 15, ' ');        --Acceptor contract number                                     -- 453
            l_line := l_line || lpad(nvl(i_oper_mcc, '0'), 6, '0');                --Activity code of the acceptor                                -- 468
            l_line := l_line || lpad(' ', 5, ' ');                                 --Remitting agency code                                        -- 474
            l_line := l_line || lpad(' ', 172, ' ');                               --Filler                                                       -- 479

        end if;

        return l_line;

    exception
        when others then

            if cu_env_oper_sum%isopen then
                close cu_env_oper_sum;
            end if;

            if cu_env_oper%isopen then
                close cu_env_oper;
            end if;

            if l_session_file_id is not null then
                prc_api_file_pkg.close_file(
                    i_sess_file_id => l_session_file_id
                  , i_status       => prc_api_const_pkg.FILE_STATUS_REJECTED
                );
            end if;

            com_api_error_pkg.raise_fatal_error(
                i_error => 'UNHANDLED_EXCEPTION'
            );
    end;

begin

    trc_log_pkg.debug(
        i_text         => 'Creating file type[#1]'
      , i_env_param1   => i_file_type
    );

    rul_api_param_pkg.set_param(
        i_name         => 'CST_ENV_OPERATION_TYPE'
      , i_value        => to_char(i_env_file_oper_type)
      , io_params      => io_params
    );

    l_part_code := get_part_code(i_inst_id => i_inst_id);

    --header
     open cu_env_oper_sum(
        i_eff_date           => i_eff_date
      , i_oper_id_tab        => i_oper_id_tab
      , i_file_type          => i_file_type
      , i_env_file_oper_type => i_env_file_oper_type
     );

    fetch cu_env_oper_sum
     into l_total_amount
        , l_operation_count
        , l_count
        , l_first_oper_id;
    close cu_env_oper_sum;

    io_estimated_count := io_estimated_count + l_operation_count;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count => io_estimated_count
    );

    trc_log_pkg.debug(
        i_text       => 'Total amount[#1], number of operations[#2], number of lines[#3]'
      , i_env_param1 => l_total_amount
      , i_env_param2 => l_operation_count
      , i_env_param3 => l_count
    );

    l_sql_rowcount := 0;
    l_oper_seq     := 0;

    if l_operation_count > 0 then

        prc_api_file_pkg.open_file(
            o_sess_file_id => l_session_file_id
          , i_file_type    => i_file_type
          , io_params      => io_params
        );

        io_sess_env_file_seq := io_sess_env_file_seq + 1;
        trc_log_pkg.debug(i_text => 'Generating EMV file #' || io_sess_env_file_seq);

        --header
        l_line :=
            process_header(
                i_part_code       => l_part_code
              , i_total_amount    => l_total_amount
              , i_operation_count => l_operation_count
            );

        prc_api_file_pkg.put_line(
            i_raw_data     => l_line
          , i_sess_file_id => l_session_file_id
        );

        --lines
        open cu_env_oper(
            i_eff_date           => i_eff_date
          , i_oper_id_tab        => i_oper_id_tab
          , i_file_type          => i_file_type
          , i_env_file_oper_type => i_env_file_oper_type
        );
        loop
            fetch cu_env_oper
             bulk collect into l_oper_id_tab
                             , l_oper_amount_tab
                             , l_external_auth_id_tab
                             , l_auth_resp_code_tab
                             , l_auth_code_tab
                             , l_merchant_id_tab
                             , l_card_number_tab
                             , l_terminal_number_tab
                             , l_amount_comission_tab
                             , l_host_date_tab
                             , l_merchant_number_tab
                             , l_merchant_account_number_tab
                             , l_oper_type_tab
                             , l_oper_mcc_tab
                             , l_terminal_type_tab
                             , l_merchant_name_tab
                             , l_card_expir_date_tab
                             , l_participants_count_tab

            limit 1000;

            for i in 1 .. l_oper_id_tab.count loop
                l_oper_seq := l_oper_seq + 1;
                l_line := get_line(
                               i_oper_id          => l_oper_id_tab(i)
                             , i_oper_amount      => l_oper_amount_tab(i)
                             , i_external_auth_id => l_external_auth_id_tab(i)
                             , i_auth_resp_code   => l_auth_resp_code_tab(i)
                             , i_auth_code        => l_auth_code_tab(i)
                             , i_card_number      => l_card_number_tab(i)
                             , i_terminal_number  => l_terminal_number_tab(i)
                             , i_amount_comission => l_amount_comission_tab(i)
                             , i_host_date        => l_host_date_tab(i)
                             , i_merchant_number  => l_merchant_number_tab(i)
                             , i_merchant_account_number => l_merchant_account_number_tab(i)
                             , i_oper_type        => l_oper_type_tab(i)
                             , i_oper_mcc         => l_oper_mcc_tab(i)
                             , i_terminal_type    => l_terminal_type_tab(i)
                             , i_merchant_name    => l_merchant_name_tab(i)
                             , i_merchant_id      => l_merchant_id_tab(i)
                             , i_card_expir_date  => l_card_expir_date_tab(i)
                             , i_oper_seq         => l_oper_seq
                           );

                prc_api_file_pkg.put_line(
                    i_raw_data     => l_line
                  , i_sess_file_id => l_session_file_id
                );

                if l_participants_count_tab(i) = 1 then
                    io_processed_count := io_processed_count + 1;
                end if;

                trc_log_pkg.debug(
                    i_text       => 'Processed operation id: [#1]'
                  , i_env_param1 => l_oper_id_tab(i)
                );
            end loop;

            if l_oper_id_tab.count > 0 then
                forall i in 1 .. l_oper_id_tab.count
                    update opr_operation o
                       set o.match_status       = cst_ap_api_const_pkg.STATUS_ENV_FILE_UPL_NOT_CONF
                         , o.incom_sess_file_id = l_session_file_id
                     where o.id                 = l_oper_id_tab(i);

                for i in 1 .. l_oper_id_tab.count loop
                    l_sql_rowcount := l_sql_rowcount + sql%bulk_rowcount(i);
                end loop;
            end if;

            exit when cu_env_oper%notfound;

        end loop;
        close cu_env_oper;

        prc_api_file_pkg.close_file(
            i_sess_file_id => l_session_file_id
          , i_status       => prc_api_const_pkg.FILE_STATUS_ACCEPTED
        );

    end if;

    if l_sql_rowcount > 0 then
        trc_log_pkg.debug(
            i_text       => 'Updated [#1] operations: Status changed to[#2]. Unloaded file[#3][#4]'
          , i_env_param1 => l_sql_rowcount
          , i_env_param2 => cst_ap_api_const_pkg.STATUS_ENV_FILE_UPL_NOT_CONF
          , i_env_param3 => i_file_type
          , i_env_param4 => i_env_file_oper_type
        );
    else
        trc_log_pkg.debug(
            i_text       => 'No operations Status updated. File for[#1][#2] was not created'
          , i_env_param1 => i_file_type
          , i_env_param2 => i_env_file_oper_type
        );
    end if;

end unload_file;

procedure unload(
    i_inst_id                in      com_api_type_pkg.t_inst_id
  , i_eff_date               in      date                              default null
  , i_cst_env_operation_type in      com_api_type_pkg.t_dict_value     default null
) is
    l_estimated_count           com_api_type_pkg.t_count := 0;
    l_processed_count           com_api_type_pkg.t_count := 0;
    l_sess_env_file_seq         com_api_type_pkg.t_count := 0;

    l_eff_date                  date;
    l_params                    com_api_type_pkg.t_param_tab;

    l_oper_id_tab               num_tab_tpt;
    l_ap_session_id             com_api_type_pkg.t_short_id;
begin

    prc_api_stat_pkg.log_start;

    rul_api_param_pkg.set_param(
        i_name       => 'INST_ID'
      , i_value      => to_char(i_inst_id)
      , io_params    => l_params
    );

    l_eff_date := nvl(i_eff_date, com_api_sttl_day_pkg.get_sysdate);

    --com_api_sttl_day_pkg.set_sysdate(i_sysdate => l_eff_date);   -- for :SYS_DATE in naming format parts

    set_session_date(
        i_eff_date       => l_eff_date
      , io_params        => l_params
      , o_ap_session_id  => l_ap_session_id
    );

    prepare_env_operations(
        i_eff_date      => l_eff_date
      , i_ap_session_id => l_ap_session_id
      , o_oper_id_tab   => l_oper_id_tab
    );

	-- trc_log_pkg.debug('@@@ i_cst_env_operation_type['||i_cst_env_operation_type||']');

    for rec_env_operation_type in (
        select di.dict || di.code as env_operation_type
          from com_dictionary di
         where di.dict = 'ENVO'
           and (di.inst_id in (nvl(i_inst_id, ost_api_const_pkg.DEFAULT_INST), ost_api_const_pkg.DEFAULT_INST))
           and (i_cst_env_operation_type is null
               or (substr(i_cst_env_operation_type, 1, 4) = di.dict
               and substr(i_cst_env_operation_type, 5, 4) = di.code))
    ) loop
	-- trc_log_pkg.debug('@@@ rec_env_operation_type.env_operation_type['||rec_env_operation_type.env_operation_type||']');
	-- trc_log_pkg.debug('@@@ l_eff_date['||l_eff_date||'] i_inst_id['||i_inst_id||']');

        --ATM
        unload_file(
            i_inst_id               => i_inst_id
          , i_file_type             => cst_ap_api_const_pkg.FILETYPE_ENV_ATM
          , io_params               => l_params
          , i_eff_date              => l_eff_date
          , i_env_file_oper_type    => rec_env_operation_type.env_operation_type
          , i_oper_id_tab           => l_oper_id_tab
          , io_estimated_count      => l_estimated_count
          , io_processed_count      => l_processed_count
          , io_sess_env_file_seq    => l_sess_env_file_seq
        );

        --POS
        unload_file(
            i_inst_id               => i_inst_id
          , i_file_type             => cst_ap_api_const_pkg.FILETYPE_ENV_POS
          , io_params               => l_params
          , i_eff_date              => l_eff_date
          , i_env_file_oper_type    => rec_env_operation_type.env_operation_type
          , i_oper_id_tab           => l_oper_id_tab
          , io_estimated_count      => l_estimated_count
          , io_processed_count      => l_processed_count
          , io_sess_env_file_seq    => l_sess_env_file_seq
        );

        --REFUND
        unload_file(
            i_inst_id               => i_inst_id
          , i_file_type             => cst_ap_api_const_pkg.FILETYPE_ENV_REFUND
          , io_params               => l_params
          , i_eff_date              => l_eff_date
          , i_env_file_oper_type    => rec_env_operation_type.env_operation_type
          , i_oper_id_tab           => l_oper_id_tab
          , io_estimated_count      => l_estimated_count
          , io_processed_count      => l_processed_count
          , io_sess_env_file_seq    => l_sess_env_file_seq
        );

    end loop;

    prc_api_stat_pkg.log_end(
        i_result_code        => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
      , i_processed_total    => l_processed_count
    );

end unload;

procedure upload_rec_file
is
    l_oper_id_tab                     com_api_type_pkg.t_long_tab;
    l_rec_files_count                 com_api_type_pkg.t_count   := 0;
    l_processed_count                 com_api_type_pkg.t_long_id := 0;
    l_excepted_count                  com_api_type_pkg.t_long_id := 0;
    l_sql_rowcount                    com_api_type_pkg.t_long_id := 0;

    cursor cu_rec_file_operations(
        i_file_name_base        in com_api_type_pkg.t_name
    ) is
        select op.id
          from prc_session_file sf
             , opr_operation    op
         where op.incom_sess_file_id = sf.id
           and op.match_status       = cst_ap_api_const_pkg.STATUS_ENV_FILE_UPL_NOT_CONF
           and sf.file_name          = i_file_name_base;
begin
    prc_api_stat_pkg.log_start;

    select count(1)
      into l_rec_files_count
      from prc_session_file
     where session_id = prc_api_session_pkg.get_session_id
       and upper(regexp_replace(file_name, '(.*)(\.)(rec|REC|Rec)', '\3')) = cst_ap_api_const_pkg.FILE_REC_EXTENSION;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count => l_rec_files_count
    );

    for rec_file in (
        select file_name                                               file_name
             , regexp_replace(file_name, '(.*)(.rec|.REC|.Rec)', '\1') file_name_base
          from prc_session_file
         where session_id = prc_api_session_pkg.get_session_id
           and upper(regexp_replace(file_name, '(.*)(\.)(rec|REC|Rec)', '\3')) = cst_ap_api_const_pkg.FILE_REC_EXTENSION
         order by id
    ) loop

        trc_log_pkg.debug(
            i_text       => 'Found file [#1]'
          , i_env_param1 => rec_file.file_name
        );

        open cu_rec_file_operations(i_file_name_base => rec_file.file_name_base);
        loop
            fetch cu_rec_file_operations
             bulk collect into l_oper_id_tab
            limit 1000;

            if l_oper_id_tab.count > 0 then
                forall i in 1 .. l_oper_id_tab.count
                    update opr_operation
                       set match_status = cst_ap_api_const_pkg.ENV_LOADED
                     where id           = l_oper_id_tab(i);

                for i in 1 .. l_oper_id_tab.count loop
                    l_sql_rowcount := l_sql_rowcount + sql%bulk_rowcount(i);

                    trc_log_pkg.debug(
                        i_text       => 'Updated operation [#1]: Status changed to[#2]'
                      , i_env_param1 => l_oper_id_tab(i)
                      , i_env_param2 => cst_ap_api_const_pkg.ENV_LOADED
                    );
                end loop;
            else
                trc_log_pkg.debug(i_text => 'No operations found');

            end if;

            exit when cu_rec_file_operations%notfound;
        end loop;

        close cu_rec_file_operations;

        if l_sql_rowcount > 0 then
            trc_log_pkg.debug(
                i_text       => 'Updated [#1] operations: Status changed to[#2]'
              , i_env_param1 => l_sql_rowcount
              , i_env_param2 => cst_ap_api_const_pkg.ENV_LOADED
            );
        else
            trc_log_pkg.debug(i_text => 'No operations Status updated');

        end if;

        l_processed_count := l_processed_count + 1;

        prc_api_stat_pkg.log_current(
            i_current_count  => l_processed_count
          , i_excepted_count => l_excepted_count
        );
    end loop;

    prc_api_stat_pkg.log_end(
        i_processed_total    => l_processed_count
      , i_excepted_total     => l_excepted_count
      , i_result_code        => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

end;

end cst_ap_env_unload_pkg;
/
