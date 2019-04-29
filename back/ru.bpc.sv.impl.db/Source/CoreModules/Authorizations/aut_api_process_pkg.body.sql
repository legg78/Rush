create or replace package body aut_api_process_pkg is
/************************************************************
 * Authorizations loads<br />
 * Created by Khougaev A.(khougaev@bpc.ru)  at 19.03.2010  <br />
 * Last changed by $Author$  <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: AUT_API_LOAD_PKG <br />
 * @headcom
 ************************************************************/

procedure process_auth is

    BULK_LIMIT         constant number := 400;

    l_auth_cur                  sys_refcursor;
    l_auth_cur_stmt             varchar2(4000);
    WHERE_PLACEHOLDER  constant varchar2(20) := '#####WHERE####';

    l_auth_tab                  aut_api_type_pkg.t_auth_tab;
    l_proc_stage                com_api_type_pkg.t_dict_value := opr_api_const_pkg.PROCESSING_STAGE_COMMON;
    l_skip_further_proc         boolean;
    l_skip_further_stage        boolean;
    l_rules_count               number;
    l_total_rules_count         number;

    l_rowid                     com_api_type_pkg.t_rowid_tab;
    l_operid                    com_api_type_pkg.t_number_tab;
    l_status                    com_api_type_pkg.t_dict_tab;
    l_reason                    com_api_type_pkg.t_dict_tab;

--        l_session_id                com_api_type_pkg.t_long_id := get_session_id;
    l_thread_number             com_api_type_pkg.t_tiny_id := get_thread_number;
    l_estimated_count           com_api_type_pkg.t_long_id := 0;
    l_excepted_count            com_api_type_pkg.t_long_id := 0;
    l_processed_count           com_api_type_pkg.t_long_id := 0;

    procedure save_auth_statuses is
    begin
--            forall i in 1 .. l_rowid.count
--                update
--                    aut_auth
--                set
--                    status = l_status(i)
--                    , status_reason = l_reason(i)
--                    , oper_id = l_operid(i)
--                where rowid = l_rowid(i);

        l_rowid.delete;
        l_status.delete;
        l_reason.delete;
    end;

    procedure finalize_prev_auth is

        i                       binary_integer := l_rowid.count + 1;

    begin
        if opr_api_shared_data_pkg.g_auth.row_id is not null then

            l_rowid(i) := opr_api_shared_data_pkg.g_auth.row_id;

            l_operid(i) := opr_api_shared_data_pkg.get_param_num (
                i_name              => 'OPERATION_ID'
                , i_mask_error      => com_api_type_pkg.TRUE
                , i_error_value     => opr_api_shared_data_pkg.get_operation().id
            );

            l_status(i) := opr_api_shared_data_pkg.get_operation().status;
            l_reason(i) := opr_api_shared_data_pkg.get_operation().status_reason;

            if l_status(i) = opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY then
                if l_total_rules_count = 0 then
                    l_status(i) := opr_api_const_pkg.OPERATION_STATUS_NO_RULES;
                else
                    l_status(i) := opr_api_const_pkg.OPERATION_STATUS_PROCESSED;
                end if;
            end if;

            if l_status(i) = opr_api_const_pkg.OPERATION_STATUS_EXCEPTION then
                l_excepted_count := l_excepted_count + 1;
            end if;

            if i > BULK_LIMIT then
                save_auth_statuses;
            end if;

            opr_api_shared_data_pkg.g_auth := null;

            l_processed_count := l_processed_count + 1;
        end if;
    end;

    procedure finalize_job is
    begin
        save_auth_statuses;
        mcw_api_fin_pkg.flush_job;
        acc_api_entry_pkg.flush_job;
    end;

    procedure flush_job is
    begin
        mcw_api_fin_pkg.flush_job;
        acc_api_entry_pkg.flush_job;
    end;

    procedure cancel_job is
    begin
        mcw_api_fin_pkg.cancel_job;
        acc_api_entry_pkg.cancel_job;
    end;

begin
    savepoint auth_process_start;

    prc_api_stat_pkg.log_start;

--    aut_api_shared_data_pkg.clear_shared_data;
    opr_api_shared_data_pkg.clear_shared_data;

    l_auth_cur_stmt :=
        'select count(*) from aut_auth where
         decode(status, ''' || opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY || ''', ''' || opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY || ''', null) = ''' || opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY || ''' ';

    if l_thread_number > 0 then
        l_auth_cur_stmt := l_auth_cur_stmt || ' and split_hash in (select m.split_hash from com_split_map m where m.thread_number = :thread_number)';

        trc_log_pkg.debug (
            i_text      => l_auth_cur_stmt
        );

        execute immediate l_auth_cur_stmt into l_estimated_count using l_thread_number;
    else
        trc_log_pkg.debug (
            i_text      => l_auth_cur_stmt
        );

        execute immediate l_auth_cur_stmt into l_estimated_count;
    end if;

    prc_api_stat_pkg.log_estimation (
        i_estimated_count => l_estimated_count
    );

    l_auth_cur_stmt :=
'select --+ USE_NL(a, c)
nvl(s.proc_stage, ''' || opr_api_const_pkg.PROCESSING_STAGE_COMMON || ''') proc_stage
, a.rowid row_id
, a.id
, a.split_hash
, a.session_id
, a.is_reversal
, a.original_id
, a.parent_id
, a.oper_id
, a.msg_type
, a.oper_type
, a.oper_reason
, a.resp_code
, a.status
, a.status_reason
, a.proc_type
, a.proc_mode
, a.sttl_type
, a.match_status
, a.forced_processing
, a.is_advice
, a.is_repeat
, a.is_completed
, a.host_date
, a.unhold_date
, a.oper_date
, a.oper_count
, a.oper_request_amount
, a.oper_amount_algorithm
, a.oper_amount
, a.oper_currency
, a.oper_cashback_amount
, a.oper_replacement_amount
, a.oper_surcharge_amount
, a.client_id_type
, a.client_id_value
, a.iss_inst_id
, a.iss_network_id
, a.iss_network_device_id
, a.split_hash_iss
, a.card_inst_id
, a.card_network_id
, iss_api_token_pkg.decode_card_number(i_card_number => c.card_number) as card_number
, a.card_id
, a.card_instance_id
, a.card_type_id
, a.card_mask
, a.card_hash
, a.card_seq_number
, a.card_expir_date
, a.card_service_code
, a.card_country
, a.customer_id
, a.account_id
, a.account_type
, a.account_number
, a.account_amount
, a.account_currency
, a.account_cnvt_rate
, a.bin_amount
, a.bin_currency
, a.bin_cnvt_rate
, a.network_amount
, a.network_currency
, a.network_cnvt_date
, a.network_cnvt_rate
, a.addr_verif_result
, a.auth_code
, a.dst_client_id_type
, a.dst_client_id_value
, a.dst_inst_id
, a.dst_network_id
, a.dst_card_inst_id
, a.dst_card_network_id
, iss_api_token_pkg.decode_card_number(i_card_number => c.dst_card_number) as dst_card_number
, a.dst_card_id
, a.dst_card_instance_id
, a.dst_card_type_id
, a.dst_card_mask
, a.dst_card_hash
, a.dst_card_seq_number
, a.dst_card_expir_date
, a.dst_card_service_code
, a.dst_card_country
, a.dst_customer_id
, a.dst_account_id
, a.dst_account_type
, a.dst_account_number
, a.dst_account_amount
, a.dst_account_currency
, a.dst_auth_code
, a.acq_device_id
, a.acq_resp_code
, a.acq_device_proc_result
, a.acq_inst_bin
, a.forw_inst_bin
, a.acq_inst_id
, a.acq_network_id
, a.split_hash_acq
, a.merchant_id
, a.merchant_number
, a.terminal_type
, a.terminal_number
, a.terminal_id
, a.merchant_name
, a.merchant_street
, a.merchant_city
, a.merchant_region
, a.merchant_country
, a.merchant_postcode
, a.cat_level
, a.mcc
, a.originator_refnum
, a.network_refnum
, a.card_data_input_cap
, a.crdh_auth_cap
, a.card_capture_cap
, a.terminal_operating_env
, a.crdh_presence
, a.card_presence
, a.card_data_input_mode
, a.crdh_auth_method
, a.crdh_auth_entity
, a.card_data_output_cap
, a.terminal_output_cap
, a.pin_capture_cap
, a.pin_presence
, a.cvv2_presence
, a.cvc_indicator
, a.pos_entry_mode
, a.pos_cond_code
, a.payment_order_id
, a.payment_host_id
, a.emv_data
, a.atc
, a.tvr
, a.cvr
, a.addl_data
, a.service_code
, a.device_date
, a.cvv2_result
, a.certificate_method
, a.certificate_type
, a.merchant_certif
, a.cardholder_certif
, a.ucaf_indicator
, a.is_early_emv
from
aut_auth a
, opr_proc_stage s
, aut_card c
where
decode(a.status, ''' || opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY || ''', ''' || opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY || ''', null) = ''' || opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY || '''
and c.auth_id = a.id
and a.sttl_type like s.sttl_type(+)
and a.oper_type like s.oper_type(+)
and a.msg_type like s.msg_type(+)
and s.parent_stage(+) = :parent_stage'
|| WHERE_PLACEHOLDER || '
order by
a.host_date
, a.original_id
, a.id
, s.exec_order
for update of
a.status
';

    if l_thread_number > 0 then
        l_auth_cur_stmt := replace(l_auth_cur_stmt, WHERE_PLACEHOLDER, ' and a.split_hash in (select m.split_hash from com_split_map m where m.thread_number = :thread_number) ');

        trc_log_pkg.debug (
            i_text      => l_auth_cur_stmt
        );

        open l_auth_cur
        for l_auth_cur_stmt
        using l_proc_stage, l_thread_number;
    else
        l_auth_cur_stmt := replace(l_auth_cur_stmt, WHERE_PLACEHOLDER, '');

        trc_log_pkg.debug (
            i_text      => l_auth_cur_stmt
        );

        open l_auth_cur
        for l_auth_cur_stmt
        using l_proc_stage;
    end if;

    loop
        fetch l_auth_cur bulk collect into l_auth_tab limit BULK_LIMIT;

        for i in 1 .. l_auth_tab.count loop

            trc_log_pkg.debug (
                i_text          => 'Going to process auth [#1] stage [#2]'
                , i_env_param1  => l_auth_tab(i).id
                , i_env_param2  => l_auth_tab(i).proc_stage
            );

            if opr_api_shared_data_pkg.g_auth.id = l_auth_tab(i).id then
                opr_api_shared_data_pkg.g_auth.proc_stage := l_auth_tab(i).proc_stage;
                opr_api_shared_data_pkg.put_auth_params;
                savepoint processing_new_stage;
                l_skip_further_stage := false;

            else
                finalize_prev_auth;
                flush_job;

                savepoint processing_new_authorization;
                savepoint processing_new_stage;

                trc_log_pkg.set_object (
                    i_entity_type  => aut_api_const_pkg.ENTITY_TYPE_AUTHORIZATION
                    , i_object_id  => l_auth_tab(i).id
                );

                opr_api_shared_data_pkg.clear_shared_data;
                opr_api_shared_data_pkg.g_auth := l_auth_tab(i);
                opr_api_shared_data_pkg.collect_auth_params;
                opr_api_shared_data_pkg.collect_oper_params;
                opr_api_shared_data_pkg.g_auth.status_reason := null;

                l_total_rules_count     := 0;
                l_skip_further_proc     := false;
                l_skip_further_stage    := false;

                trc_log_pkg.debug (
                    i_text      => 'Authorization processing [' || opr_api_shared_data_pkg.g_auth.id || '] STARTING'
                );
            end if;

            if l_skip_further_proc or l_skip_further_stage then
                null;
            else
                begin
                    opr_api_process_pkg.process_rules (
                        i_msg_type              => opr_api_const_pkg.MESSAGE_TYPE_AUTHORIZATION
                        , i_proc_stage          => l_auth_tab(i).proc_stage
                        , i_sttl_type           => l_auth_tab(i).sttl_type
                        , i_oper_type           => l_auth_tab(i).oper_type
                        , i_oper_reason         => null
                        , i_is_reversal         => l_auth_tab(i).is_reversal
                        , i_iss_inst_id         => l_auth_tab(i).iss_inst_id
                        , i_acq_inst_id         => l_auth_tab(i).acq_inst_id
                        , i_terminal_type       => l_auth_tab(i).terminal_type
                        , i_oper_currency       => l_auth_tab(i).oper_currency
                        , i_account_currency    => l_auth_tab(i).account_currency
                        , i_sttl_currency       => l_auth_tab(i).network_currency
                        , i_proc_mode           => l_auth_tab(i).proc_mode
                        , o_rules_count         => l_rules_count
                        , io_params             => opr_api_shared_data_pkg.g_params
                    );

                    l_total_rules_count := l_total_rules_count + l_rules_count;
                exception
                    when com_api_error_pkg.e_stop_process_operation then
                        l_total_rules_count := l_total_rules_count + 1;
                        l_skip_further_proc := true;
                        trc_log_pkg.clear_object;

                    when com_api_error_pkg.e_rollback_process_operation then
                        l_total_rules_count := l_total_rules_count + 1;
                        l_skip_further_proc := true;
                        cancel_job;
                        rollback to savepoint processing_new_authorization;
                        trc_log_pkg.clear_object;

                    when com_api_error_pkg.e_stop_process_stage then
                        l_total_rules_count := l_total_rules_count + 1;
                        l_skip_further_stage := true;
                        trc_log_pkg.clear_object;

                    when com_api_error_pkg.e_rollback_process_stage then
                        l_total_rules_count := l_total_rules_count + 1;
                        l_skip_further_stage := true;
                        cancel_job;
                        rollback to savepoint processing_new_stage;
                        trc_log_pkg.clear_object;

                    when others then
                        l_total_rules_count := l_total_rules_count + 1;
                        l_skip_further_proc := true;
                        cancel_job;
                        rollback to savepoint processing_new_authorization;
                        trc_log_pkg.clear_object;

                        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
                            raise;
                        else
                            opr_api_shared_data_pkg.g_auth.status := opr_api_const_pkg.OPERATION_STATUS_EXCEPTION;
                        end if;
                end;
            end if;
        end loop;

        prc_api_stat_pkg.log_current (
            i_current_count       => l_processed_count
            , i_excepted_count    => l_excepted_count
        );

        exit when l_auth_cur%notfound;
    end loop;

    close l_auth_cur;

    finalize_prev_auth;
    finalize_job;
    trc_log_pkg.clear_object;

    prc_api_stat_pkg.log_end (
        i_excepted_total    => l_excepted_count
      , i_processed_total   => l_processed_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
exception
    when others then
        rollback to savepoint auth_process_start;
        cancel_job;
        trc_log_pkg.clear_object;

        if l_auth_cur%isopen then
            close l_auth_cur;
        end if;

        prc_api_stat_pkg.log_end(
            i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        raise;
end process_auth;

procedure unhold_auth(
    i_id                 in com_api_type_pkg.t_long_id
  , i_reason             in com_api_type_pkg.t_dict_value
  , i_rollback_limits    in com_api_type_pkg.t_boolean     := null
  , i_original_oper_id   in com_api_type_pkg.t_long_id     := null
  , i_unhold_amount      in com_api_type_pkg.t_amount_rec  := null
  , i_final_unhold       in com_api_type_pkg.t_boolean     := null
  , i_status             in com_api_type_pkg.t_dict_value  := opr_api_const_pkg.OPERATION_STATUS_UNHOLDED
) is
    l_match_status          com_api_type_pkg.t_dict_value;
begin
    trc_log_pkg.debug (
        i_text              => 'Going to unhold auth [#1]'
      , i_env_param1        => i_id
      , i_entity_type       => aut_api_const_pkg.ENTITY_TYPE_AUTHORIZATION
      , i_object_id         => i_id
    );

    for r_auth in (select id, status, match_status, is_reversal from opr_operation where id = i_id for update nowait) loop
        trc_log_pkg.debug (
            i_text          => 'Auth status is [#1]'
          , i_env_param1    => r_auth.status
          , i_entity_type   => opr_api_const_pkg.ENTITY_TYPE_OPERATION
          , i_object_id     => i_id
        );

        if r_auth.status in (opr_api_const_pkg.OPERATION_STATUS_AWAITS_UNHOLD
                           , opr_api_const_pkg.OPERATION_STATUS_PART_UNHOLD)
        then
            if i_unhold_amount.amount is null then
                    acc_api_entry_pkg.cancel_processing (
                        i_entity_type       => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                      , i_object_id         => i_id
                      , i_macros_status     => acc_api_const_pkg.MACROS_STATUS_HOLDED
                    );
                else
                    acc_api_entry_pkg.partial_revert_entries (
                        i_entity_type       => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                      , i_object_id         => i_id
                      , i_macros_status     => acc_api_const_pkg.MACROS_STATUS_HOLDED
                      , i_amount            => i_unhold_amount
                      , i_final_unhold      => i_final_unhold
                    );


            end if;

            if nvl(i_rollback_limits, com_api_type_pkg.TRUE) = com_api_type_pkg.TRUE then
                fcl_api_limit_pkg.rollback_limit_counters(
                    i_source_entity_type  => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                  , i_source_object_id    => i_id
                );
            end if;

            if i_reason                = aut_api_const_pkg.AUTH_REASON_UNHOLD_AUTO
               and r_auth.match_status = opr_api_const_pkg.OPERATION_MATCH_REQ_MATCH
            then
                l_match_status      := opr_api_const_pkg.OPERATION_MATCH_NOT_MATCHED;
            else
                l_match_status      := null;
            end if;

            update opr_operation
               set status        = i_status
                 , status_reason = i_reason
                 , match_status  = nvl(l_match_status, match_status)
             where id            = r_auth.id;

            trc_log_pkg.debug (
                i_text              => 'Auth successfully unholded [#1]'
              , i_env_param1        => i_status
              , i_entity_type       => opr_api_const_pkg.ENTITY_TYPE_OPERATION
              , i_object_id         => i_id
            );

        elsif r_auth.status = opr_api_const_pkg.OPERATION_STATUS_UNHOLDED then
            trc_log_pkg.debug (
                i_text              => 'Auth already unholded'
              , i_entity_type       => opr_api_const_pkg.ENTITY_TYPE_OPERATION
              , i_object_id         => i_id
            );

            if r_auth.is_reversal = com_api_const_pkg.FALSE then
                com_api_error_pkg.raise_error(
                    i_error             => 'AUTH_ALREADY_UNHOLDED'
                    , i_entity_type     => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                    , i_object_id       => i_id
                    , i_mask_error      => com_api_type_pkg.TRUE
                );
            end if;

        else
            trc_log_pkg.debug (
                i_text              => 'Auth cant be unholded'
              , i_entity_type       => opr_api_const_pkg.ENTITY_TYPE_OPERATION
              , i_object_id         => i_id
            );

            com_api_error_pkg.raise_error(
                i_error             => 'AUTH_CANT_BE_UNHOLDED'
                , i_env_param1      => r_auth.status
                , i_entity_type     => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                , i_object_id       => i_id
                , i_mask_error      => com_api_type_pkg.TRUE
            );
        end if;

        return;
    end loop;

    com_api_error_pkg.raise_error(
        i_error             => 'AUTH_NOT_FOUND'
        , i_env_param1      => i_id
        , i_entity_type     => opr_api_const_pkg.ENTITY_TYPE_OPERATION
        , i_object_id       => i_id
        , i_mask_error      => com_api_type_pkg.TRUE
    );
end unhold_auth;

procedure unhold(
    i_id                 in com_api_type_pkg.t_long_id
  , i_reason             in com_api_type_pkg.t_dict_value
  , i_rollback_limits    in com_api_type_pkg.t_boolean
) is
begin
    unhold_auth (
        i_id                 => i_id
      , i_reason             => i_reason
      , i_rollback_limits    => i_rollback_limits
    );

    for r_reversal in (
        select r.id
          from opr_operation o
             , opr_operation r
         where o.id          = i_id
           and r.original_id = o.id
           and r.is_reversal = com_api_type_pkg.TRUE
           and r.msg_type    = o.msg_type
           and r.status      = opr_api_const_pkg.OPERATION_STATUS_AWAITS_UNHOLD
    ) loop
        begin
            unhold_auth (
                i_id                 => r_reversal.id
              , i_reason             => nvl(i_reason, aut_api_const_pkg.AUTH_REASON_UNHOLD_CUSTOMER)
              , i_rollback_limits    => i_rollback_limits
            );
        exception
            when others then
                if (
                    com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE
                    or com_api_error_pkg.is_fatal_error(sqlcode)    = com_api_const_pkg.TRUE
                ) then
                    null;
                else
                    trc_log_pkg.warn (
                        i_text           => 'UNHANDLED_EXCEPTION'
                      , i_env_param1     => sqlerrm
                      , i_env_param2     => sqlcode
                      , i_env_param3     => 'Unhold reversal failed'
                      , i_entity_type    => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                      , i_object_id      => r_reversal.id
                    );
                end if;
        end;
    end loop;
end unhold;

procedure unhold_partial(
    i_id                 in com_api_type_pkg.t_long_id
  , i_reason             in com_api_type_pkg.t_dict_value
  , i_rollback_limits    in com_api_type_pkg.t_boolean     := null
  , i_amount             in com_api_type_pkg.t_amount_rec  := null
  , i_original_oper_id   in com_api_type_pkg.t_long_id     := null
) is
    l_original_oper opr_api_type_pkg.t_oper_rec;
    l_status        com_api_type_pkg.t_dict_value :=opr_api_const_pkg.OPERATION_STATUS_UNHOLDED;
    l_unhold_amount com_api_type_pkg.t_amount_rec;
    l_hold_amount   com_api_type_pkg.t_amount_rec;
    l_amount        com_api_type_pkg.t_amount_rec;
    l_flag_final    com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE;
    l_status_marcos com_api_type_pkg.t_dict_value;
begin
    if i_amount.amount is not null then
            for auth in (select id, status from opr_operation where id = i_id for update nowait) loop
                l_status := auth.status;
                if auth.status in (opr_api_const_pkg.OPERATION_STATUS_AWAITS_UNHOLD
                                 , opr_api_const_pkg.OPERATION_STATUS_PART_UNHOLD) 
                then
                    if i_original_oper_id is not null then
                        for org_oper in (select * from opr_operation where id = i_original_oper_id and clearing_sequence_num is not null)
                        loop
                            l_original_oper.id := org_oper.id;
                            l_original_oper.oper_amount       := org_oper.oper_amount;
                            l_original_oper.oper_currency     := org_oper.oper_currency;
                            l_original_oper.sttl_amount       := org_oper.sttl_amount;
                            l_original_oper.sttl_currency     := org_oper.sttl_currency;
                            l_original_oper.clearing_sequence_num   := org_oper.clearing_sequence_num;
                            l_original_oper.clearing_sequence_count := org_oper.clearing_sequence_count;

                            exit;
                        end loop;

                        if l_original_oper.id is null then
                            select msg_type
                              into l_original_oper.msg_type
                              from opr_operation
                             where id = i_original_oper_id
                               and clearing_sequence_num is null;
                        end if;
                    end if;
                end if;
            end loop;
        else
            select status into l_status  from opr_operation where id = i_id for update nowait;
            l_original_oper.clearing_sequence_num   := 0;
            l_original_oper.clearing_sequence_count := 0;
    end if;


    if l_status in (opr_api_const_pkg.OPERATION_STATUS_AWAITS_UNHOLD, opr_api_const_pkg.OPERATION_STATUS_PART_UNHOLD)
       and  l_original_oper.clearing_sequence_num is not null
    then

            l_hold_amount := acc_api_entry_pkg.get_hold_amount(
                                 i_object_id   => i_id
                               , i_entity_type => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                             );

            l_unhold_amount := acc_api_entry_pkg.get_unhold_amount(
                                   i_object_id   => i_id
                                 , i_entity_type => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                               );

            if  l_hold_amount.currency = i_amount.currency or i_amount.currency is null then

                    if l_hold_amount.amount > (nvl(i_amount.amount,0)+nvl(l_unhold_amount.amount,0))
                       and i_amount.amount is not null then
                            l_amount     := i_amount;
                        else
                            l_amount.amount := l_hold_amount.amount-nvl(l_unhold_amount.amount,0);
                            l_flag_final := com_api_type_pkg.TRUE;
                    end if;

                    if l_original_oper.clearing_sequence_num = l_original_oper.clearing_sequence_count then
                        l_flag_final     := com_api_type_pkg.TRUE;
                        l_amount.amount  := l_hold_amount.amount - nvl(l_unhold_amount.amount,0);
                    end if;

                    l_amount.currency    := nvl(i_amount.currency, l_hold_amount.currency);

                    if l_flag_final = com_api_type_pkg.TRUE then
                        l_status_marcos  := opr_api_const_pkg.OPERATION_STATUS_UNHOLDED;
                    else
                        l_status_marcos  := opr_api_const_pkg.OPERATION_STATUS_PART_UNHOLD;
                    end if;

                else
                    trc_log_pkg.debug (
                        i_text              => 'Currency of amount for unhold not equal to hold currency'
                      , i_entity_type       => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                      , i_object_id         => i_id
                    );

                    com_api_error_pkg.raise_error(
                        i_error             => 'AUTH_CANT_BE_UNHOLDED'
                      , i_env_param1        => l_status
                      , i_entity_type       => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                      , i_object_id         => i_id
                    );
            end if;

      elsif ( l_original_oper.msg_type = opr_api_const_pkg.MESSAGE_TYPE_PARTIAL_AMOUNT) then
           l_amount := i_amount;
           l_status_marcos := opr_api_const_pkg.OPERATION_STATUS_PART_UNHOLD;

      elsif ( l_original_oper.msg_type = opr_api_const_pkg.MESSAGE_TYPE_PART_AMOUNT_COMPL) then

            l_hold_amount := acc_api_entry_pkg.get_hold_amount(i_object_id =>i_id,
                i_entity_type => opr_api_const_pkg.ENTITY_TYPE_OPERATION);

            l_unhold_amount := acc_api_entry_pkg.get_unhold_amount(i_object_id =>i_id,
                i_entity_type => opr_api_const_pkg.ENTITY_TYPE_OPERATION);

           l_amount.amount := l_hold_amount.amount-nvl(l_unhold_amount.amount,0);
           l_amount.currency := nvl(i_amount.currency, l_hold_amount.currency);

           l_status_marcos := opr_api_const_pkg.OPERATION_STATUS_UNHOLDED;
           l_flag_final := com_api_type_pkg.TRUE;

    end if;

    unhold_auth (
        i_id                 => i_id
      , i_reason             => i_reason
      , i_rollback_limits    => i_rollback_limits
      , i_unhold_amount      => l_amount
      , i_final_unhold       => l_flag_final
      , i_status             => l_status_marcos
    );
end unhold_partial;

end aut_api_process_pkg;
/
