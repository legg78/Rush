create or replace package body opr_api_process_pkg is
/************************************************************
 * API for process operations <br />
 * Created by Khougaev (khougaev@bpcbt.com)  at 21.08.2009 <br />
 * Module: opr_api_process_pkg <br />
 * @headcom
 ***********************************************************/

procedure process_rules(
    i_msg_type            in            com_api_type_pkg.t_dict_value
  , i_proc_stage          in            com_api_type_pkg.t_dict_value default opr_api_const_pkg.PROCESSING_STAGE_COMMON
  , i_sttl_type           in            com_api_type_pkg.t_dict_value
  , i_oper_type           in            com_api_type_pkg.t_dict_value
  , i_oper_reason         in            com_api_type_pkg.t_dict_value default null
  , i_is_reversal         in            com_api_type_pkg.t_boolean    default null
  , i_iss_inst_id         in            com_api_type_pkg.t_inst_id    default null
  , i_acq_inst_id         in            com_api_type_pkg.t_inst_id    default null
  , i_terminal_type       in            com_api_type_pkg.t_dict_value default null
  , i_oper_currency       in            com_api_type_pkg.t_curr_code  default null
  , i_account_currency    in            com_api_type_pkg.t_curr_code  default null
  , i_sttl_currency       in            com_api_type_pkg.t_curr_code  default null
  , i_proc_mode           in            com_api_type_pkg.t_dict_value default null
  , o_rules_count            out        number
  , io_params             in out nocopy com_api_type_pkg.t_param_tab
) is
    l_rules_count                       number;

    cursor l_rules is
        select r.rule_set_id
             , r.mod_id
          from opr_rule_selection r
         where nvl(i_msg_type, '%') like r.msg_type
           and i_proc_stage = r.proc_stage
           and nvl(i_sttl_type, '%') like r.sttl_type
           and nvl(i_oper_type, '%') like r.oper_type
           and nvl(i_oper_reason, '%') like r.oper_reason
           and i_is_reversal = r.is_reversal
           and nvl(to_char(i_iss_inst_id), '%') like r.iss_inst_id
           and nvl(to_char(i_acq_inst_id), '%') like r.acq_inst_id
           and nvl(i_terminal_type, '%') like r.terminal_type
           and nvl(i_oper_currency, '%') like r.oper_currency
           and nvl(i_account_currency, '%') like r.account_currency
           and nvl(i_sttl_currency, '%') like r.sttl_currency
      order by r.exec_order;

begin
    savepoint processing_rules;

    trc_log_pkg.debug(
        i_text       => 'Fetching rule sets for [' || i_msg_type
                     || '][' || i_proc_stage || '][' || i_sttl_type
                     || '][' || i_oper_type || '][' || i_oper_reason
                     || '][' || i_is_reversal || '][' || i_iss_inst_id
                     || '][' || i_acq_inst_id || '][' || i_terminal_type
                     || '][' || i_oper_currency || '][' || i_account_currency
                     || '][' || i_sttl_currency || ']'
    );

    o_rules_count := 0;

    for rule_rec in l_rules loop
        trc_log_pkg.debug(
            i_text       => 'Fetched rule set [#1] modifier [#2]'
          , i_env_param1 => rule_rec.rule_set_id
          , i_env_param2 => rule_rec.mod_id
        );

        l_rules_count := 0;

        if rul_api_mod_pkg.check_condition(
               i_mod_id  => rule_rec.mod_id
             , i_params  => opr_api_shared_data_pkg.g_params
           ) = com_api_const_pkg.TRUE
        then
            rul_api_process_pkg.execute_rule_set(
                i_rule_set_id  => rule_rec.rule_set_id
              , o_rules_count  => l_rules_count
              , io_params      => io_params
            );
        end if;

        o_rules_count := o_rules_count + l_rules_count;
    end loop;

exception
    when others then
        if l_rules%isopen then
            close l_rules;
        end if;

        raise;
end process_rules;

function get_result_status(
    i_proc_stage      com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_dict_value
result_cache relies_on (opr_proc_stage)
is
    l_result_status   com_api_type_pkg.t_dict_value;
begin
    select t.result_status
      into l_result_status
      from opr_proc_stage t
     where t.proc_stage = i_proc_stage
       and t.parent_stage = i_proc_stage;

    return l_result_status;
exception when no_data_found then
    return null;
end;

-- You can run this method and see the result query for dynamic SQL.
function get_query_statement(
    i_count_query_only    in            com_api_type_pkg.t_boolean
  , i_stage               in            com_api_type_pkg.t_dict_value
  , i_operation_id        in            com_api_type_pkg.t_long_id
  , i_thread_number       in            com_api_type_pkg.t_tiny_id
  , i_process_container   in            com_api_type_pkg.t_boolean
  , i_session_id          in            com_api_type_pkg.t_long_id
  , i_statement           in            com_api_type_pkg.t_text
) return com_api_type_pkg.t_text
is
    l_query_statement     com_api_type_pkg.t_text;
    l_count_records       com_api_type_pkg.t_tiny_id;
begin
    trc_log_pkg.debug(
        i_text       => 'get_query_statement: START; i_count_query_only [#1], i_stage [#2], i_operation_id [#3]'
                     || ', i_thread_number [#4] i_process_container [#5] i_session_id [#6]'
      , i_env_param1 => i_count_query_only
      , i_env_param2 => i_stage
      , i_env_param3 => i_operation_id
      , i_env_param4 => i_thread_number
      , i_env_param5 => i_process_container
      , i_env_param6 => i_session_id
    );

    if i_count_query_only = com_api_type_pkg.TRUE then
        l_query_statement := '
select count(1)';
    else
        l_query_statement := '
select o.id
, s.proc_stage
, s.exec_order stage_number
, o.session_id
, o.is_reversal
, o.original_id
, o.oper_type
, o.oper_reason
, o.msg_type
, o.status
, o.status_reason
, o.sttl_type
, o.terminal_type
, o.acq_inst_bin
, o.forw_inst_bin
, o.merchant_number
, o.terminal_number
, o.merchant_name
, o.merchant_street
, o.merchant_city
, o.merchant_region
, o.merchant_country
, o.merchant_postcode
, o.mcc
, o.originator_refnum
, o.network_refnum
, o.oper_count
, o.oper_request_amount
, o.oper_amount_algorithm
, o.oper_amount
, o.oper_currency
, o.oper_cashback_amount
, o.oper_replacement_amount
, o.oper_surcharge_amount
, o.oper_date
, o.host_date
, o.unhold_date
, o.match_status
, o.sttl_amount
, o.sttl_currency
, o.dispute_id
, o.payment_order_id
, o.payment_host_id
, o.forced_processing
, o.match_id
, o.proc_mode
, o.clearing_sequence_num
, o.clearing_sequence_count
, o.incom_sess_file_id
, o.sttl_date
, o.acq_sttl_date
';
    end if;

    select count(1)
      into l_count_records
      from opr_proc_stage
     where parent_stage = i_stage
       and rownum < 2;

    case
        when l_count_records = 0
        then
            com_api_error_pkg.raise_error (
                i_error         => 'OPR_STAGE_NOT_FOUND'
                , i_env_param1  => i_stage
                , i_entity_type => opr_api_const_pkg.ENTITY_TYPE_OPERATION
            );
        when i_stage = opr_api_const_pkg.PROCESSING_STAGE_COMMON
        then
             l_query_statement := l_query_statement || '
                 from
                      opr_operation o
                    , opr_proc_stage s
                    , opr_oper_stage os
                    , aut_auth a
                    , (
                       select :stage p_stage
                            , :operation_id p_operation_id
                            , :thread_number p_thread_number
                            , :session_id p_session_id
                            , :proc_session_id p_proc_session_id
                         from dual
                      ) x
                where decode(o.status, ''' || opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY
                               || ''', ''' || opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY || ''', null) = '''
                      || opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY || '''
                  and o.id = os.oper_id(+)
                  and o.id = a.id(+)
                  and x.p_stage = coalesce(os.proc_stage, x.p_stage)
                  and (o.sttl_type = s.sttl_type or s.sttl_type = ''%'')
                  and (o.oper_type = s.oper_type or s.oper_type = ''%'')
                  and (o.msg_type = s.msg_type or s.msg_type = ''%'')
                  and s.parent_stage = x.p_stage
                ';
        else
             l_query_statement := l_query_statement || '
                 from
                      opr_operation o
                    , opr_oper_stage os
                    , opr_proc_stage s
                    , aut_auth a
                    , (
                       select :stage p_stage
                            , :operation_id p_operation_id
                            , :thread_number p_thread_number
                            , :session_id p_session_id
                            , :proc_session_id p_proc_session_id
                         from dual
                      ) x
                where decode(os.status, ''' || opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY
                                || ''', ''' || opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY || ''', null) = '''
                      || opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY || '''
                  and os.proc_stage = x.p_stage
                  and os.oper_id = o.id
                  and o.id = a.id(+)
                  and (o.sttl_type = s.sttl_type or s.sttl_type = ''%'')
                  and (o.oper_type = s.oper_type or s.oper_type = ''%'')
                  and (o.msg_type = s.msg_type or s.msg_type = ''%'')
                  and s.parent_stage = x.p_stage
                ';
    end case;

    if i_operation_id is not null then
        l_query_statement := l_query_statement || '
            and o.id = x.p_operation_id';
    end if;

    if i_thread_number > 0 then
        l_query_statement := l_query_statement || '
            and exists (select 1
                          from opr_participant op
                         where op.oper_id = o.id
                           and op.participant_type = ''' || com_api_const_pkg.PARTICIPANT_ISSUER || '''
                           and nvl(op.split_hash, 1) in (select m.split_hash from com_split_map m where m.thread_number = x.p_thread_number)
                )';
    end if;

    if i_session_id is not null then
        l_query_statement := l_query_statement || '
            and o.session_id in (select id from prc_session connect by parent_id = prior id start with id = x.p_session_id)';
    end if;

    if i_statement is not null then
        l_query_statement := l_query_statement || ' ' || i_statement;
    end if;

    if nvl(i_process_container, com_api_type_pkg.FALSE) = com_api_type_pkg.TRUE then
        l_query_statement := l_query_statement || '
            and o.session_id in (
                select id from prc_session
                  start with id = ( select max(id) keep (dense_rank last order by level)
                                      from prc_session
                                     start with id = x.p_proc_session_id
                                   connect by id = prior parent_id)
                  connect by prior id = parent_id) ';
    end if;

    if i_count_query_only = com_api_type_pkg.FALSE then
        l_query_statement := l_query_statement || '
            order by decode(o.oper_type, ''OPTP1001'', 0, 1)
                   , a.external_auth_id
                   , o.is_reversal
                   , o.id
                   , s.exec_order';

    end if;

    trc_log_pkg.debug (
        i_text  => l_query_statement
    );
    trc_log_pkg.debug (
        i_text  => 'get_query_statement: FINISH'
    );

    return l_query_statement;
end;

procedure process(
    i_stage               in            com_api_type_pkg.t_dict_value
  , i_operation_id        in            com_api_type_pkg.t_long_id
  , i_stat_log            in            com_api_type_pkg.t_boolean
  , i_mask_error          in            com_api_type_pkg.t_boolean
  , i_process_container   in            com_api_type_pkg.t_boolean
  , i_session_id          in            com_api_type_pkg.t_long_id
  , i_oper_filter         in            com_api_type_pkg.t_dict_value default null
  , i_commit_work         in            com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
  , i_param_tab           in            com_param_map_tpt             default null
) is
    BULK_LIMIT                 constant pls_integer := 100;
    LOG_PREFIX                 constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process';
    l_oper_cur                          sys_refcursor;
    l_oper_cur_stmt                     com_api_type_pkg.t_text;
    l_statement                         com_api_type_pkg.t_text;

    l_oper_tab                          opr_api_type_pkg.t_oper_tab;
    l_oper_participant                  opr_api_type_pkg.t_oper_part_rec;
    cu_oper_participants                sys_refcursor;
    l_rules_count                       pls_integer;

    l_skip_further_proc                 boolean;
    l_skip_further_stage                boolean;
    l_total_rules_count                 pls_integer;

    l_id                                com_api_type_pkg.t_number_tab;
    l_proc_stage                        com_api_type_pkg.t_dict_tab;
    l_status                            com_api_type_pkg.t_dict_tab;
    l_reason                            com_api_type_pkg.t_dict_tab;
    l_account_id                        com_api_type_pkg.t_number_tab;
    l_dst_account_id                    com_api_type_pkg.t_number_tab;
    l_account_number                    com_api_type_pkg.t_account_number_tab;
    l_dst_account_number                com_api_type_pkg.t_account_number_tab;
    l_split_hash                        com_api_type_pkg.t_number_tab;
    l_dst_split_hash                    com_api_type_pkg.t_number_tab;
    l_next_stage                        com_api_type_pkg.t_number_tab;
    l_part_issuer_inst_id               com_api_type_pkg.t_inst_id_tab;
    l_part_dest_inst_id                 com_api_type_pkg.t_inst_id_tab;
    l_host_date                         com_api_type_pkg.t_date_tab;
    l_curr_status                       com_api_type_pkg.t_dict_value;
    l_unhold_date                       com_api_type_pkg.t_date_tab;

    l_thread_number                     com_api_type_pkg.t_tiny_id;

    l_estimated_count                   com_api_type_pkg.t_count := 0;
    l_excepted_count                    com_api_type_pkg.t_count := 0;
    l_processed_count                   com_api_type_pkg.t_count := 0;

    procedure save_opr_statuses
    is
        l_event_type            com_api_type_pkg.t_dict_value;
        l_event_type_log        com_api_type_pkg.t_dict_tab;
        l_initiator_log         com_api_type_pkg.t_dict_tab;
        l_entity_type_log       com_api_type_pkg.t_dict_tab;
        l_id_log                com_api_type_pkg.t_number_tab;
        l_status_log            com_api_type_pkg.t_dict_tab;
        l_reason_log            com_api_type_pkg.t_dict_tab;
        l_host_date_log         com_api_type_pkg.t_date_tab;
        l_count                 com_api_type_pkg.t_count      := 1;
        l_event_date_log        com_api_type_pkg.t_date_tab;
    begin
        trc_log_pkg.debug (
            i_text      => 'Saving ' || l_id.count || ' operations statuses'
        );

        if l_id.count > 0 then

            trc_log_pkg.debug (
                i_text      => 'Saving id=' || l_id(1) || ' status=' || l_status(1) || ' reason=' || l_reason(1)
            );

            forall i in 1 .. l_id.count
                update opr_operation
                   set status             = l_status(i)
                     , status_reason      = l_reason(i)
                     , unhold_date        = l_unhold_date(i)
                 where id                 = l_id(i)
                   and l_status(i) is not null;

            forall i in 1 .. l_id.count
                update opr_participant
                   set account_number     = decode(
                                                participant_type
                                              , com_api_const_pkg.PARTICIPANT_ISSUER, l_account_number(i)
                                              , l_dst_account_number(i)
                                            )
                     , account_id         = decode(
                                                participant_type
                                              , com_api_const_pkg.PARTICIPANT_ISSUER, l_account_id(i)
                                              , l_dst_account_id(i)
                                            )
                 where oper_id            = l_id(i)
                   and participant_type in (com_api_const_pkg.PARTICIPANT_ISSUER
                                          , com_api_const_pkg.PARTICIPANT_DEST)
                   and split_hash = decode(
                                        participant_type
                                      , com_api_const_pkg.PARTICIPANT_DEST, l_dst_split_hash(i)
                                      , l_split_hash(i)
                                    )
                   and account_id  is     null
                   and l_status(i) is not null;

            -- Registering events for successfully and unsuccessfully processed operations
            for i in l_id.first .. l_id.last loop
                if l_status(i) is not null then
                    trc_log_pkg.debug(
                        i_text        => 'Registering events (i = #1): l_id [#2], l_status [#3], l_host_date [#4], '
                                      || 'l_part_issuer_inst_id [#5], l_part_dest_inst_id [#6]'
                      , i_env_param1  => i
                      , i_env_param2  => l_id(i)
                      , i_env_param3  => l_status(i)
                      , i_env_param4  => to_char(l_host_date(i), com_api_const_pkg.DATE_FORMAT)
                      , i_env_param5  => l_part_issuer_inst_id(i)
                      , i_env_param6  => l_part_dest_inst_id(i)
                      , i_entity_type => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                      , i_object_id   => opr_api_shared_data_pkg.get_operation().id
                    );

                    l_event_type := case
                                        when l_status(i) in (
                                                 opr_api_const_pkg.OPERATION_STATUS_PROCESSED
                                               , opr_api_const_pkg.OPERATION_STATUS_DONE_WO_PROC
                                               , opr_api_const_pkg.OPERATION_STATUS_UNHOLDED
                                               , opr_api_const_pkg.OPERATION_STATUS_AUTHORIZED
                                               , opr_api_const_pkg.OPERATION_STATUS_NO_ENTRIES
                                               , opr_api_const_pkg.OPERATION_STATUS_AWAITS_UNHOLD
                                             )
                                        then opr_api_const_pkg.EVENT_PROCESSED_SUCCESSFULLY
                                        else opr_api_const_pkg.EVENT_PROCESSED_WITH_ERRORS
                                    end;
                    -- Registering events for both participants
                    evt_api_event_pkg.register_event(
                        i_event_type  => l_event_type
                      , i_eff_date    => l_host_date(i)
                      , i_entity_type => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                      , i_object_id   => l_id(i)
                      , i_inst_id     => l_part_issuer_inst_id(i)
                      , i_split_hash  => l_split_hash(i)
                      , i_param_tab   => opr_api_shared_data_pkg.g_params
                    );
                    -- Fill arrays when l_status(i) is not null
                    l_event_type_log(l_count)  := l_event_type;
                    l_initiator_log(l_count)   := evt_api_const_pkg.INITIATOR_SYSTEM;
                    l_entity_type_log(l_count) := opr_api_const_pkg.ENTITY_TYPE_OPERATION;
                    l_id_log(l_count)          := l_id(i);
                    l_status_log(l_count)      := l_status(i);
                    l_reason_log(l_count)      := l_reason(i);
                    l_host_date_log(l_count)   := l_host_date(i);
                    l_event_date_log(l_count)  := null;
                    l_count                    := l_count + 1;
                end if;
            end loop;

            evt_api_status_pkg.add_status_log(
                i_event_type      => l_event_type_log
              , i_initiator       => l_initiator_log
              , i_entity_type     => l_entity_type_log
              , i_object_id       => l_id_log
              , i_reason          => l_reason_log
              , i_status          => l_status_log
              , i_eff_date        => l_host_date_log
              , i_event_date      => l_event_date_log
            );

            if i_stage not in (opr_api_const_pkg.PROCESSING_STAGE_UDEFINED)
            then
                forall i in 1 .. l_id.count
                    update opr_oper_stage
                       set status = l_status(i)
                     where oper_id = l_id(i)
                       and proc_stage = l_proc_stage(i)
                       and l_status(i) is not null;
            end if;

            evt_api_event_pkg.flush_events;
        end if;

        l_id.delete;
        l_proc_stage.delete;
        l_status.delete;
        l_reason.delete;
        l_account_number.delete;
        l_account_id.delete;
        l_dst_account_id.delete;
        l_dst_account_number.delete;
        l_next_stage.delete;
        l_part_issuer_inst_id.delete;
        l_part_dest_inst_id.delete;
        l_host_date.delete;
        l_unhold_date.delete;
    end;

    procedure finalize_job is
    begin
        acc_api_entry_pkg.flush_job;
        save_opr_statuses;
    end;

    procedure flush_job is
    begin
        acc_api_entry_pkg.flush_job;
    end;

    procedure cancel_job is
    begin
        acc_api_entry_pkg.cancel_job;
        evt_api_event_pkg.cancel_events;
    end;

    procedure finalize_prev_oper is
        i                       binary_integer := l_id.count + 1;
        l_result_status         com_api_type_pkg.t_dict_value;
    begin
        if opr_api_shared_data_pkg.get_operation().id is not null then
            l_id(i)         := opr_api_shared_data_pkg.get_operation().id;
            l_proc_stage(i) := opr_api_shared_data_pkg.get_operation().proc_stage;
            l_status(i)     := opr_api_shared_data_pkg.get_operation().status;
            l_reason(i)     := opr_api_shared_data_pkg.get_operation().status_reason;
            l_account_number(i) := opr_api_shared_data_pkg.get_participant(com_api_const_pkg.PARTICIPANT_ISSUER).account_number;
            l_account_id(i)     := opr_api_shared_data_pkg.get_participant(com_api_const_pkg.PARTICIPANT_ISSUER).account_id;

            select max(split_hash) keep (dense_rank first
                                           order by decode(participant_type, com_api_const_pkg.PARTICIPANT_ISSUER,   0,
                                                                             com_api_const_pkg.PARTICIPANT_ACQUIRER, 1,
                                                                             com_api_const_pkg.PARTICIPANT_DEST,     2,
                                                                                                                     3))
              into l_split_hash(i)
              from opr_participant
             where oper_id = l_id(i);

            l_dst_account_number(i)  := opr_api_shared_data_pkg.get_participant(com_api_const_pkg.PARTICIPANT_DEST).account_number;
            l_dst_account_id(i)      := opr_api_shared_data_pkg.get_participant(com_api_const_pkg.PARTICIPANT_DEST).account_id;
            l_part_issuer_inst_id(i) := opr_api_shared_data_pkg.get_participant(com_api_const_pkg.PARTICIPANT_ISSUER).inst_id;
            l_part_dest_inst_id(i)   := opr_api_shared_data_pkg.get_participant(com_api_const_pkg.PARTICIPANT_DEST).inst_id;
            l_dst_split_hash(i)      := opr_api_shared_data_pkg.get_participant(com_api_const_pkg.PARTICIPANT_DEST).split_hash;
            l_host_date(i)           := opr_api_shared_data_pkg.get_operation().host_date;
            l_unhold_date(i)         := opr_api_shared_data_pkg.get_operation().unhold_date;

            flush_job;

            if l_status(i) = opr_api_const_pkg.OPERATION_STATUS_EXCEPTION then
                l_excepted_count := l_excepted_count + 1;
            else
                l_result_status := get_result_status(i_proc_stage => l_proc_stage(i));

                if l_result_status is not null then
                    l_status(i) := l_result_status;
                elsif l_status(i) = opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY then
                    if l_total_rules_count = 0 then
                        l_status(i) := opr_api_const_pkg.OPERATION_STATUS_NO_RULES;
                    else
                        if opr_api_shared_data_pkg.get_operation().unhold_date is not null then
                            l_status(i) := opr_api_const_pkg.OPERATION_STATUS_AWAITS_UNHOLD;
                        else
                            select case
                                       when exists (select 1
                                                      from acc_macros
                                                     where object_id = l_id(i)
                                                       and entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION)
                                       then opr_api_const_pkg.OPERATION_STATUS_PROCESSED
                                       else opr_api_const_pkg.OPERATION_STATUS_NO_ENTRIES
                                   end
                                   into l_status(i)
                              from dual;
                        end if;
                    end if;
                end if;
            end if;

            trc_log_pkg.debug(
                i_text        => 'Operation processing [' || opr_api_shared_data_pkg.get_operation().id
                              || '] FINISHED with status [#1]'
              , i_env_param1  => l_status(i)
              , i_entity_type => opr_api_const_pkg.ENTITY_TYPE_OPERATION
              , i_object_id   => opr_api_shared_data_pkg.get_operation().id
            );

            save_opr_statuses;

            if  mod(l_processed_count, BULK_LIMIT) = 0
                -- Disable committing (optionally) only for single operation processing
                and (i_commit_work = com_api_const_pkg.TRUE or i_operation_id is null)
            then
                opr_cst_process_pkg.before_commit(l_id);
                commit;
            end if;

            opr_api_shared_data_pkg.set_operation(null);
            l_processed_count := l_processed_count + 1;
        end if;
    end finalize_prev_oper;

begin
    trc_log_pkg.debug(
        i_text        => LOG_PREFIX || ' START: i_stage [#1], i_oper_filter [#2]'
      , i_env_param1  => i_stage
      , i_env_param2  => i_oper_filter
      , i_entity_type => case when i_operation_id is not null then opr_api_const_pkg.ENTITY_TYPE_OPERATION end
      , i_object_id   => i_operation_id
    );

    com_api_sttl_day_pkg.cache_sttl_days;
    opr_api_shared_data_pkg.clear_shared_data;

    l_thread_number := get_thread_number;

    opr_cst_process_pkg.get_statement(
        i_oper_filter  => i_oper_filter
      , o_statement    => l_statement
    );

    l_oper_cur_stmt := get_query_statement(
                           i_count_query_only   => com_api_type_pkg.FALSE
                         , i_stage              => i_stage
                         , i_operation_id       => i_operation_id
                         , i_thread_number      => l_thread_number
                         , i_process_container  => i_process_container
                         , i_session_id         => i_session_id
                         , i_statement          => l_statement
                       );

    if i_stat_log = com_api_type_pkg.TRUE then
        prc_api_stat_pkg.log_start;
    end if;

    open l_oper_cur for l_oper_cur_stmt
    using i_stage, i_operation_id, l_thread_number, i_session_id, get_session_id;

    -- Different savepoints are used to rollback changes on the following 2 types of processing:
    -- 1) a set of operations (<processing_new_operation>);
    -- 2) a single operation (<before_processing>).
    -- Overwise, if one savepoint is used and there is some processing rule that calls processing of
    -- another single operation recursively, then the savepoint is rewritten in this recursive call.
    -- Error exception may be raised during processing that single operation. All changes are rollbacked
    -- to the savepoint. When returning from the recursive call to parent operation processing,
    -- the procedure tries to rollback its changes but the savepoint either is invalidated (ORA-01086)
    -- or points to the beginning of child operation processing in the recursive call.
    if i_operation_id is not null then
        trc_log_pkg.debug(
            i_text        => LOG_PREFIX || ': set savepoint <before_processing>'
          , i_entity_type => opr_api_const_pkg.ENTITY_TYPE_OPERATION
          , i_object_id   => i_operation_id
        );
        savepoint before_processing;
    end if;

    opr_cst_process_pkg.before_process;

    loop
        fetch l_oper_cur bulk collect into l_oper_tab limit BULK_LIMIT;

        l_estimated_count := l_estimated_count + l_oper_tab.count;

        trc_log_pkg.debug('Estimated count of operations is [' || l_estimated_count || ']');

        if i_stat_log = com_api_type_pkg.TRUE then
            prc_api_stat_pkg.log_estimation(
                i_estimated_count  => l_estimated_count
            );
        end if;

        for i in 1 .. l_oper_tab.count loop

            if  i_stage = opr_api_const_pkg.PROCESSING_STAGE_UDEFINED
                and
                l_oper_tab(i).proc_stage is null
            then
                l_oper_tab(i).proc_stage := opr_api_const_pkg.PROCESSING_STAGE_COMMON;
            end if;

            if opr_api_shared_data_pkg.get_operation().id = l_oper_tab(i).id then
                -- Same operation, next stage
                savepoint stage_process_start;

                opr_api_shared_data_pkg.set_operation_proc_stage(
                    i_id          => l_oper_tab(i).id
                  , i_proc_stage  => l_oper_tab(i).proc_stage
                );

                l_skip_further_stage := false;

            else
                opr_api_shared_data_pkg.put_oper_params;
                finalize_prev_oper;
                flush_job;
                opr_api_shared_data_pkg.clear_shared_data;

                -- The following savepoint shouldn't be set for single operation processing
                if i_operation_id is null then
                    trc_log_pkg.debug(
                        i_text        => LOG_PREFIX || ': set savepoint <processing_new_operation>'
                      , i_entity_type => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                      , i_object_id   => l_oper_tab(i).id
                    );
                    savepoint processing_new_operation;
                end if;

                savepoint stage_process_start;

                trc_log_pkg.set_object(
                    i_entity_type  => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                  , i_object_id    => l_oper_tab(i).id
                );

                opr_api_shared_data_pkg.set_operation(l_oper_tab(i));

                begin
                    select status
                      into l_curr_status
                      from opr_operation
                     where id = l_oper_tab(i).id
                       and status = l_oper_tab(i).status
                    for update of status nowait;
                exception
                    when com_api_error_pkg.e_resource_busy
                      or com_api_error_pkg.e_deadlock_detected
                      or no_data_found
                    then
                        l_skip_further_proc  := true;
                        l_total_rules_count  := l_total_rules_count + 1;
                        l_oper_tab(i).status := null;
                        continue;
                end;

                -- An operation with uncommon processing stage can be processed having "Ready for process" status only,
                -- therefore it is needed to redefine current operation status for correct defining of resulting status
                if i_stage != opr_api_const_pkg.PROCESSING_STAGE_COMMON then
                    opr_api_shared_data_pkg.set_operation_status(
                        i_id      => l_oper_tab(i).id
                      , i_status  => opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY
                    );
                    opr_api_shared_data_pkg.set_operation_reason(
                        i_id      => l_oper_tab(i).id
                      , i_reason  => aup_api_const_pkg.RESP_CODE_OK
                    );
                end if;

                opr_api_shared_data_pkg.load_auth(
                    i_id     => l_oper_tab(i).id
                  , io_auth  => opr_api_shared_data_pkg.g_auth
                );

                open cu_oper_participants for
                    select p.oper_id
                         , p.participant_type
                         , p.client_id_type
                         , p.client_id_value
                         , p.inst_id
                         , p.network_id
                         , p.card_inst_id
                         , p.card_network_id
                         , p.card_id
                         , p.card_instance_id
                         , p.card_type_id
                         , iss_api_token_pkg.decode_card_number(i_card_number => c.card_number) as card_number
                         , p.card_mask
                         , p.card_hash
                         , p.card_seq_number
                         , p.card_expir_date
                         , p.card_service_code
                         , p.card_country
                         , p.customer_id
                         , to_number(null) contract_id
                         , p.account_id
                         , p.account_type
                         , p.account_number
                         , p.account_amount
                         , p.account_currency
                         , p.auth_code
                         , p.merchant_id
                         , p.terminal_id
                         , p.split_hash
                         , to_number(null) acq_inst_id
                         , to_number(null) acq_network_id
                         , to_number(null) iss_inst_id
                         , to_number(null) iss_network_id
                      from opr_participant p
                         , opr_card c
                     where p.oper_id = l_oper_tab(i).id
                       and p.oper_id = c.oper_id(+)
                       and p.participant_type = c.participant_type(+);
                loop
                    fetch cu_oper_participants into l_oper_participant;
                    exit when cu_oper_participants%notfound;

                    opr_api_shared_data_pkg.set_participant(
                        i_oper_participant      => l_oper_participant
                    );
                end loop;

                close cu_oper_participants;

                opr_api_shared_data_pkg.collect_auth_params;
                opr_api_shared_data_pkg.collect_oper_params;
                opr_api_shared_data_pkg.collect_global_oper_params;

                trc_log_pkg.debug(
                    i_text        => 'operation processing [' || opr_api_shared_data_pkg.get_operation().id || '] starting'
                  , i_entity_type => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                  , i_object_id   => opr_api_shared_data_pkg.get_operation().id
                );

                l_total_rules_count     := 0;
                l_skip_further_proc     := false;
                l_skip_further_stage    := false;
            end if;

            trc_log_pkg.debug(
                i_text        => 'processing stage [' || opr_api_shared_data_pkg.get_operation().proc_stage || ']'
              , i_entity_type => opr_api_const_pkg.ENTITY_TYPE_OPERATION
              , i_object_id   => opr_api_shared_data_pkg.get_operation().id
            );

            if l_skip_further_proc or l_skip_further_stage then
                null;
            else
                begin
                    if i_param_tab.exists(1) then

                        trc_log_pkg.debug(
                            i_text        => 'Set transmissioned global parameters ... i_param_tab.count(' || i_param_tab.count || ')'
                          , i_entity_type => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                          , i_object_id   => opr_api_shared_data_pkg.get_operation().id
                        );

                        for i in i_param_tab.first .. i_param_tab.last
                        loop
                            if not opr_api_shared_data_pkg.g_params.exists(i_param_tab(i).name)
                                or opr_api_shared_data_pkg.g_params(i_param_tab(i).name) is null
                            then
                                if i_param_tab(i).char_value is not null then
                                    opr_api_shared_data_pkg.set_param(
                                        i_name  => i_param_tab(i).name
                                      , i_value => i_param_tab(i).char_value
                                    );
                                elsif i_param_tab(i).number_value is not null then
                                    opr_api_shared_data_pkg.set_param(
                                        i_name  => i_param_tab(i).name
                                      , i_value => i_param_tab(i).number_value
                                    );
                                elsif i_param_tab(i).date_value is not null then
                                    opr_api_shared_data_pkg.set_param(
                                        i_name  => i_param_tab(i).name
                                      , i_value => i_param_tab(i).date_value
                                    );
                                end if;
                            end if;
                        end loop;

                    end if;

                    trc_log_pkg.debug(
                        i_text        => 'processing rules ...'
                      , i_entity_type => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                      , i_object_id   => opr_api_shared_data_pkg.get_operation().id
                    );

                    process_rules(
                        i_msg_type       => l_oper_tab(i).msg_type
                      , i_proc_stage     => l_oper_tab(i).proc_stage
                      , i_sttl_type      => l_oper_tab(i).sttl_type
                      , i_oper_type      => l_oper_tab(i).oper_type
                      , i_oper_reason    => l_oper_tab(i).oper_reason
                      , i_is_reversal    => l_oper_tab(i).is_reversal
                      , i_iss_inst_id    => opr_api_shared_data_pkg.get_participant(com_api_const_pkg.PARTICIPANT_ISSUER).inst_id
                      , i_acq_inst_id    => opr_api_shared_data_pkg.get_participant(com_api_const_pkg.PARTICIPANT_ACQUIRER).inst_id
                      , i_terminal_type  => l_oper_tab(i).terminal_type
                      , i_oper_currency  => l_oper_tab(i).oper_currency
                      , i_sttl_currency  => l_oper_tab(i).sttl_currency
                      , i_proc_mode      => l_oper_tab(i).proc_mode
                      , o_rules_count    => l_rules_count
                      , io_params        => opr_api_shared_data_pkg.g_params
                    );

                    trc_log_pkg.debug(
                        i_text        => 'processed ' || nvl(l_rules_count, 0) || ' rules'
                      , i_entity_type => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                      , i_object_id   => opr_api_shared_data_pkg.get_operation().id
                    );

                    l_total_rules_count := l_total_rules_count + nvl(l_rules_count, 0);
                exception
                    when com_api_error_pkg.e_stop_process_operation then
                        l_total_rules_count := l_total_rules_count + 1;
                        l_skip_further_proc := true;
                        trc_log_pkg.clear_object;

                    when com_api_error_pkg.e_rollback_process_operation then
                        l_total_rules_count := l_total_rules_count + 1;
                        l_skip_further_proc := true;
                        cancel_job;

                        trc_log_pkg.debug(
                            i_text        => LOG_PREFIX || ': rollback to savepoint <#1>'
                          , i_env_param1  => case
                                                 when i_operation_id is null
                                                 then 'processing_new_operation'
                                                 else 'before_processing'
                                             end
                        );

                        if i_operation_id is null then
                            rollback to savepoint processing_new_operation;
                        else
                            rollback to savepoint before_processing;
                        end if;

                        trc_log_pkg.clear_object;

                    when com_api_error_pkg.e_stop_process_stage then
                        l_total_rules_count  := l_total_rules_count + 1;
                        l_skip_further_stage := true;

                    when com_api_error_pkg.e_rollback_process_stage then
                        l_total_rules_count  := l_total_rules_count + 1;
                        l_skip_further_stage := true;
                        cancel_job;
                        rollback to savepoint stage_process_start;

                    when others then
                        l_total_rules_count := l_total_rules_count + 1;
                        l_skip_further_proc := true;
                        cancel_job;

                        trc_log_pkg.debug(
                            i_text        => LOG_PREFIX || ': rollback to savepoint <#1>'
                          , i_env_param1  => case
                                                 when i_operation_id is null
                                                 then 'processing_new_operation'
                                                 else 'before_processing'
                                             end
                        );

                        if i_operation_id is null then
                            rollback to savepoint processing_new_operation;
                        else
                            rollback to savepoint before_processing;
                        end if;

                        trc_log_pkg.clear_object;

                        if com_api_error_pkg.is_application_error(sqlcode) = com_api_type_pkg.TRUE then

                            if i_mask_error = com_api_type_pkg.TRUE then
                                trc_log_pkg.error(
                                    i_text        => 'ERROR_PROCESSING_OPERATION'
                                  , i_env_param1  => opr_api_shared_data_pkg.get_operation().id
                                  , i_env_param2  => com_api_error_pkg.get_last_error_id
                                  , i_env_param3  => sqlerrm
                                  , i_entity_type => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                                  , i_object_id   => opr_api_shared_data_pkg.get_operation().id
                                );
                                opr_api_shared_data_pkg.set_operation_status(
                                    i_id          => l_oper_tab(i).id
                                  , i_status      => opr_api_const_pkg.OPERATION_STATUS_EXCEPTION
                                );
                            else
                                com_api_error_pkg.raise_error(
                                    i_error       => 'ERROR_PROCESSING_OPERATION'
                                  , i_env_param1  => opr_api_shared_data_pkg.get_operation().id
                                  , i_env_param2  => com_api_error_pkg.get_last_error_id
                                  , i_env_param3  => sqlerrm
                                  , i_entity_type => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                                  , i_object_id   => opr_api_shared_data_pkg.get_operation().id
                                );
                            end if;

                        else
                            com_api_error_pkg.raise_error(
                                i_error       => 'ERROR_PROCESSING_OPERATION_FATAL'
                              , i_env_param1  => opr_api_shared_data_pkg.get_operation().id
                              , i_env_param2  => sqlerrm
                              , i_entity_type => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                              , i_object_id   => opr_api_shared_data_pkg.get_operation().id
                            );
                        end if;
                end;
            end if;
        end loop;

        if i_stat_log = com_api_type_pkg.TRUE then
            prc_api_stat_pkg.log_current(
                i_excepted_count => l_excepted_count
              , i_current_count  => l_processed_count
            );
        end if;

        exit when l_oper_cur%notfound;
    end loop;
    close l_oper_cur;

    trc_log_pkg.debug (
        i_text      => 'finalizing job ...'
    );

    opr_api_shared_data_pkg.put_oper_params;
    finalize_prev_oper;
    finalize_job;
    trc_log_pkg.clear_object;

    com_api_sttl_day_pkg.free_cache_sttl_days;

    if i_stat_log = com_api_type_pkg.TRUE then
        prc_api_stat_pkg.log_end(
            i_excepted_total   => l_excepted_count
          , i_processed_total  => l_processed_count
          , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        );
    end if;

    trc_log_pkg.debug(
        i_text        => LOG_PREFIX || ' END'
      , i_entity_type => case when i_operation_id is not null then opr_api_const_pkg.ENTITY_TYPE_OPERATION end
      , i_object_id   => i_operation_id
    );

exception
    when others then
        trc_log_pkg.debug(
            i_text        => LOG_PREFIX || ' FAILED: rollback'
                          || case
                                 when i_operation_id is not null
                                 then ' to savepoint <before_processing>'
                             end
          , i_entity_type => opr_api_const_pkg.ENTITY_TYPE_OPERATION
          , i_object_id   => opr_api_shared_data_pkg.get_operation().id
        );
        -- Impossible to rollback entire transaction in the case of single operation processing
        -- because that operation may be processed within some operational rule, so that all savepoints
        -- would be invalidated and there would be exception ORA-01086 (savepoint never established)
        -- when attempting to rollback changes in parent operation processing (which initiates processing rules)
        if i_operation_id is not null then
            rollback to savepoint before_processing;
        else
            rollback;
        end if;

        trc_log_pkg.clear_object;

        trc_log_pkg.error(
            i_text        => 'ERROR_PROCESSING_OPERATION'
          , i_env_param1  => -1
          , i_env_param2  => sqlerrm
        );

        cancel_job;
        com_api_sttl_day_pkg.free_cache_sttl_days;

        if l_oper_cur%isopen then
            close l_oper_cur;
        end if;

        if cu_oper_participants%isopen then
            close cu_oper_participants;
        end if;

        if i_stat_log = com_api_type_pkg.TRUE then
            prc_api_stat_pkg.log_end(
                i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
            );
        end if;

        raise;
end process;

procedure process_operations(
    i_stage               in            com_api_type_pkg.t_dict_value default opr_api_const_pkg.PROCESSING_STAGE_COMMON
  , i_process_container   in            com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
  , i_session_id          in            com_api_type_pkg.t_long_id    default null
  , i_oper_filter         in            com_api_type_pkg.t_dict_value default null
) is
begin
    process(
        i_stage              => i_stage
      , i_operation_id       => null
      , i_stat_log           => com_api_const_pkg.TRUE
      , i_mask_error         => com_api_const_pkg.TRUE
      , i_process_container  => i_process_container
      , i_session_id         => i_session_id
      , i_oper_filter        => i_oper_filter
    );
end;

/*
 * Single operation processing.
 */
procedure process_operation(
    i_operation_id        in            com_api_type_pkg.t_long_id
  , i_stage               in            com_api_type_pkg.t_dict_value default opr_api_const_pkg.PROCESSING_STAGE_COMMON
  , i_mask_error          in            com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
  , i_commit_work         in            com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
  , i_param_tab           in            com_param_map_tpt             default null
) is
    l_oper_id                           com_api_type_pkg.t_long_id;
begin
    -- This procedure may be triggered within one of operation processing rules implicitly during
    -- creating and processing another associated operation (e.g. see rule credit_dpp_payment with
    -- DPP registering procedure call).
    -- Therefore during processing this child operation in the entry point of procedure process() all
    -- global variables-cashes in package opr_api_shared_data_pkg are cleared by method clear_shared_data()
    -- and in the exit point they contain some data about child operation.
    -- When returning to processing parent operation, its source values of variables-cashes are erased,
    -- and it may lead to an unexpected exception followed by a fatal error.
    -- To prevent this situation all necessary cache data is saved before processing and is restored after it.

    opr_api_shared_data_pkg.stash_shared_data();

    l_oper_id := opr_api_shared_data_pkg.get_operation().id;

    trc_log_pkg.set_object(
        i_entity_type => opr_api_const_pkg.ENTITY_TYPE_OPERATION
      , i_object_id   => i_operation_id
    );

    process(
        i_stage              => i_stage
      , i_operation_id       => i_operation_id
      , i_stat_log           => com_api_const_pkg.FALSE
      , i_mask_error         => i_mask_error
      , i_process_container  => com_api_const_pkg.FALSE
      , i_session_id         => null
      , i_oper_filter        => null
      , i_commit_work        => nvl(i_commit_work, com_api_const_pkg.TRUE)
      , i_param_tab          => i_param_tab
    );

    trc_log_pkg.set_object(
        i_entity_type => opr_api_const_pkg.ENTITY_TYPE_OPERATION
      , i_object_id   => l_oper_id
    );

    opr_api_shared_data_pkg.restore_shared_data();

exception
    when others then
        if l_oper_id is not null then
            trc_log_pkg.set_object(
                i_entity_type => opr_api_const_pkg.ENTITY_TYPE_OPERATION
              , i_object_id   => l_oper_id
            );
        end if;

        opr_api_shared_data_pkg.restore_shared_data();

        raise;
end;

end opr_api_process_pkg;
/
