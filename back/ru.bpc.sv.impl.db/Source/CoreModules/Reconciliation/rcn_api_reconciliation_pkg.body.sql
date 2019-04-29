create or replace package body rcn_api_reconciliation_pkg is

BULK_LIMIT         constant pls_integer := 400;

g_register_event   com_api_type_pkg.t_boolean;

procedure reg_event(
    i_event_type    in     com_api_type_pkg.t_dict_value
  , i_recon_msg_id  in     com_api_type_pkg.t_long_id
  , i_inst_id       in     com_api_type_pkg.t_inst_id
) is
    l_sysdate       date := com_api_sttl_day_pkg.get_sysdate();
    l_param_tab     com_api_type_pkg.t_param_tab;
begin
    if nvl(g_register_event, com_api_type_pkg.FALSE) = Com_api_const_pkg.TRUE
   and i_event_type is not null then
        evt_api_event_pkg.register_event(
            i_event_type  => i_event_type
          , i_eff_date    => l_sysdate
          , i_entity_type => rcn_api_const_pkg.ENTITY_TYPE_HOST_RECON
          , i_object_id   => i_recon_msg_id
          , i_inst_id     => i_inst_id
          , i_split_hash  => null
          , i_param_tab   => l_param_tab
          , i_status      => evt_api_const_pkg.EVENT_STATUS_READY
        );
    end if;
end reg_event;

procedure process(
    i_inst_id            in     com_api_type_pkg.t_inst_id
  , i_recon_type         in     com_api_type_pkg.t_dict_value    default rcn_api_const_pkg.RECON_TYPE_COMMON
) is
    l_match_cur                 sys_refcursor;
    l_last_matched_msg          com_api_type_pkg.t_long_id;
    l_recon_date                date;
    l_msg_cbs_id                com_api_type_pkg.t_number_tab;
    l_msg_sv_id                 com_api_type_pkg.t_number_tab;
    l_msg_cbs_rowid             com_api_type_pkg.t_rowid_tab;
    l_msg_sv_rowid              com_api_type_pkg.t_rowid_tab;

    l_estimated_count           com_api_type_pkg.t_long_id := 0;
    l_rejected_count            com_api_type_pkg.t_long_id := 0;
    l_processed_count           com_api_type_pkg.t_long_id := 0;
    l_rowcount                  com_api_type_pkg.t_long_id;

    l_param_source              com_api_type_pkg.t_text :=
        ', (' ||
            'select :p_inst_id p_inst_id ' ||
                 ', :p_recon_type p_recon_type ' ||
              'from dual ' ||
           ') x ';

    l_column_list               com_api_type_pkg.t_text :=
        'select ' ||
            '/*+ ORDERED(cbs, sv, p_cbs, p_sv)*/ ' ||
            'cbs.id' ||
            ', sv.id' ||
            ', cbs.row_id cbs_rowid' ||
            ', sv.row_id sv_rowid ';

    l_ref_source                com_api_type_pkg.t_lob_data;

    l_estimated_source          com_api_type_pkg.t_lob_data;

    l_add_amount_query          com_api_type_pkg.t_lob_data;
    l_add_amount_columns        com_api_type_pkg.t_lob_data;
    l_add_amount_where          com_api_type_pkg.t_lob_data;

    cursor l_match_conditions (
        i_inst_id              com_api_type_pkg.t_inst_id
      , i_recon_type           com_api_type_pkg.t_dict_value
    ) is
        select max(condition) condition
             , condition_type
          from (
              select t.rn
                   , replace(sys_connect_by_path('(' || t.condition || ')', '__and_'), '__and_', ' and ') as condition
                   , t.condition_type
                from (
                    select row_number() over (partition by priority order by condition) rn
                         , condition
                         , priority
                         , condition_type
                      from (
                          select c.condition
                               , rcn_api_const_pkg.RECON_CONDITION_COMPARATIVE as condition_type
                               , 1 as priority
                            from rcn_condition c
                           where (c.inst_id = i_inst_id or c.inst_id = ost_api_const_pkg.DEFAULT_INST)
                             and c.recon_type = i_recon_type
                             and c.condition_type in (rcn_api_const_pkg.RECON_CONDITION_CONNECTIVE
                                                    , rcn_api_const_pkg.RECON_CONDITION_COMPARATIVE
                                 )
                           union all
                          select c.condition
                               , c.condition_type
                               , 2 as priority
                            from rcn_condition c
                           where (c.inst_id = i_inst_id or c.inst_id = ost_api_const_pkg.DEFAULT_INST)
                             and c.recon_type = i_recon_type
                             and c.condition_type = rcn_api_const_pkg.RECON_CONDITION_CONNECTIVE
                      )
                ) t
                start with t.rn = 1
                connect by prior t.priority = t.priority
                       and prior t.rn + 1   = t.rn
          )
          group by condition_type
          order by decode(condition_type, rcn_api_const_pkg.RECON_CONDITION_CONNECTIVE, 2
                                        , rcn_api_const_pkg.RECON_CONDITION_COMPARATIVE, 1
                                        , 99
                          );

    procedure open_match_cur (
        i_condition     in com_api_type_pkg.t_text
    ) is
        l_match_cur_stmt   com_api_type_pkg.t_lob_data;
    begin
        l_match_cur_stmt :=
            l_column_list || l_ref_source
            || i_condition
            || ' order by cbs.id,'
            || ' sv.id';
        open l_match_cur for l_match_cur_stmt using i_inst_id, i_recon_type, i_inst_id, i_recon_type;
    exception
        when others then
            trc_log_pkg.debug(
                i_text => 'Exception on opening a matching cursor l_match_cur_stmt: '
                       || chr(13) || chr(10) || substr(l_match_cur_stmt, 1, 3900)
            );
            raise;
    end open_match_cur;

    procedure generate_sql_clause(i_prefix in com_api_type_pkg.t_text)
    is
        l_select          com_api_type_pkg.t_text;
        l_cols_list       com_api_type_pkg.t_lob_data := null;
        l_cols_list_query com_api_type_pkg.t_lob_data;
        l_from            com_api_type_pkg.t_text;
    begin
        l_select := ', (select a.rcn_id ';
        l_from := ' from rcn_additional_amount a ' ||
                  ' group by a.rcn_id) t ';
        for r in (
            select d.dict || d.code as dictcode
              from com_dictionary d
             where d.dict = com_api_const_pkg.AMOUNT_PURPOSE_DICTIONARY
        ) loop
            l_cols_list         := l_cols_list || ', ' || r.dictcode || '_amount, ' || r.dictcode || '_currency';
            l_cols_list_query   := l_cols_list_query || ', max(decode(a.amount_type, ''' || r.dictcode || ''', a.amount)) as ' || r.dictcode || '_amount'
                                                     || ', max(decode(a.amount_type, ''' || r.dictcode || ''', a.currency)) as ' || r.dictcode || '_currency';
        end loop;

        l_add_amount_columns   := l_cols_list;
        l_add_amount_query     := l_select || l_cols_list_query || l_from;
        l_add_amount_where     := 'and ' || i_prefix || 'id = t.rcn_id ';

    end generate_sql_clause;

begin
    savepoint processing_matching_start;

    prc_api_stat_pkg.log_start;

    trc_log_pkg.info(
        i_text          => 'CBS Reconciliation started.'
    );

    l_recon_date := com_api_sttl_day_pkg.get_sysdate();

    generate_sql_clause(i_prefix => 'cbs.');

    l_ref_source :=
        'from '||
            '( '||
              'select '||
                     'cbs.rowid row_id'||
                   ', cbs.id'||
                   ', cbs.recon_type' ||
                   ', cbs.msg_source' ||
                   ', cbs.msg_date' ||
                   ', cbs.oper_id' ||
                   ', cbs.recon_msg_id' ||
                   ', cbs.recon_status' ||
                   ', cbs.recon_date' ||
                   ', cbs.recon_inst_id' ||
                   ', cbs.oper_type' ||
                   ', cbs.msg_type' ||
                   ', cbs.sttl_type' ||
                   ', cbs.oper_date' ||
                   ', cbs.oper_amount' ||
                   ', cbs.oper_currency' ||
                   ', cbs.oper_request_amount' ||
                   ', cbs.oper_request_currency' ||
                   ', cbs.oper_surcharge_amount' ||
                   ', cbs.oper_surcharge_currency' ||
                   ', cbs.originator_refnum' ||
                   ', cbs.network_refnum' ||
                   ', cbs.acq_inst_bin' ||
                   ', cbs.status' ||
                   ', cbs.is_reversal' ||
                   ', cbs.merchant_number' ||
                   ', cbs.mcc' ||
                   ', cbs.merchant_name' ||
                   ', cbs.merchant_street' ||
                   ', cbs.merchant_city' ||
                   ', cbs.merchant_region' ||
                   ', cbs.merchant_country' ||
                   ', cbs.merchant_postcode' ||
                   ', cbs.terminal_type' ||
                   ', cbs.terminal_number' ||
                   ', cbs.acq_inst_id' ||
                   ', cbs.card_mask' ||
                   ', iss_api_token_pkg.decode_card_number(i_card_number => ccbs.card_number) as card_number' ||
                   ', cbs.card_seq_number' ||
                   ', cbs.card_expir_date' ||
                   ', cbs.card_country' ||
                   ', cbs.iss_inst_id' ||
                   ', cbs.auth_code' ||
                   ', rownum as rnm'|| -- needed to make predefined view (do not remove!)
                   l_add_amount_columns ||
               ' from rcn_cbs_msg cbs'||
                   ', rcn_card ccbs'||
                   ', (select :p_inst_id p_inst_id, :p_recon_type as p_recon_type from dual) x '||
                   l_add_amount_query ||
               'where cbs.id = ccbs.id '||
                 'and cbs.msg_source = ''' || rcn_api_const_pkg.RECON_MSG_SOURCE_CBS || ''' ' ||
                 'and cbs.recon_status = ''' || rcn_api_const_pkg.RECON_STATUS_REQ_RECON || ''' ' ||
                 'and cbs.recon_inst_id = x.p_inst_id '||
                 'and cbs.recon_type = x.p_recon_type '||
                 l_add_amount_where ||
            ') cbs ';

    generate_sql_clause(i_prefix => 'sv.');

    l_ref_source := l_ref_source ||
          ', ( '||
              'select '||
                     'sv.rowid row_id'||
                   ', sv.id'||
                   ', sv.recon_type' ||
                   ', sv.msg_source' ||
                   ', sv.msg_date' ||
                   ', sv.oper_id' ||
                   ', sv.recon_msg_id' ||
                   ', sv.recon_status' ||
                   ', sv.recon_date' ||
                   ', sv.recon_inst_id' ||
                   ', sv.oper_type' ||
                   ', sv.msg_type' ||
                   ', sv.sttl_type' ||
                   ', sv.oper_date' ||
                   ', sv.oper_amount' ||
                   ', sv.oper_currency' ||
                   ', sv.oper_request_amount' ||
                   ', sv.oper_request_currency' ||
                   ', sv.oper_surcharge_amount' ||
                   ', sv.oper_surcharge_currency' ||
                   ', sv.originator_refnum' ||
                   ', sv.network_refnum' ||
                   ', sv.acq_inst_bin' ||
                   ', sv.status' ||
                   ', sv.is_reversal' ||
                   ', sv.merchant_number' ||
                   ', sv.mcc' ||
                   ', sv.merchant_name' ||
                   ', sv.merchant_street' ||
                   ', sv.merchant_city' ||
                   ', sv.merchant_region' ||
                   ', sv.merchant_country' ||
                   ', sv.merchant_postcode' ||
                   ', sv.terminal_type' ||
                   ', sv.terminal_number' ||
                   ', sv.acq_inst_id' ||
                   ', sv.card_mask' ||
                   ', iss_api_token_pkg.decode_card_number(i_card_number => csv.card_number) as card_number' ||
                   ', sv.card_seq_number' ||
                   ', sv.card_expir_date' ||
                   ', sv.card_country' ||
                   ', sv.iss_inst_id' ||
                   ', sv.auth_code' ||
                   ', rownum as rnm'|| -- needed to make predefined view (do not remove!)
                   l_add_amount_columns ||
               ' from rcn_cbs_msg sv'||
                   ', rcn_card csv'||
                   ', (select :p_inst_id p_inst_id, :p_recon_type as p_recon_type from dual) x '||
                   l_add_amount_query ||
               'where sv.id = csv.id '||
                 'and sv.msg_source = ''' || rcn_api_const_pkg.RECON_MSG_SOURCE_INTERNAL || ''' ' ||
                 'and sv.recon_status = ''' || rcn_api_const_pkg.RECON_STATUS_REQ_RECON || ''' ' ||
                 'and sv.recon_inst_id = x.p_inst_id '||
                 'and sv.recon_type = x.p_recon_type '||
                 l_add_amount_where ||
            ') sv ' ||
        'where 1 = 1 ';

    l_estimated_source :=
        'select '||
             'count(1) ' ||
        'from' ||
             ' rcn_cbs_msg m' ||
             ', rcn_card c ' ||
             l_param_source ||
        'where m.id = c.id ' ||
          'and m.msg_source = ''' || rcn_api_const_pkg.RECON_MSG_SOURCE_CBS || ''' ' ||
          'and m.recon_status = ''' || rcn_api_const_pkg.RECON_STATUS_REQ_RECON || ''' ' ||
          'and m.recon_inst_id = x.p_inst_id '||
          'and m.recon_type = x.p_recon_type ';

    -- determining the approximate number of operations for matching
    execute immediate l_estimated_source into l_estimated_count using i_inst_id, i_recon_type;

    prc_api_stat_pkg.log_estimation (
        i_estimated_count => l_estimated_count
    );

    trc_log_pkg.info (
        i_text      => 'Reconciliate process starting for inst_id [' || i_inst_id || '], recon_type [' || i_recon_type || ']'
    );

    for condition_rec in l_match_conditions(i_inst_id, i_recon_type) loop

        l_last_matched_msg := null;

        trc_log_pkg.info (
            i_text => 'Condition type [' || condition_rec.condition_type || '] ' ||
                      'condition [' || substr(condition_rec.condition, 1, 1900) || ']'
        );

        open_match_cur (
            i_condition => condition_rec.condition
        );

        trc_log_pkg.debug (
            i_text      => 'Opening matching cursor finished'
        );

        loop
            fetch l_match_cur
             bulk collect into l_msg_cbs_id, l_msg_sv_id, l_msg_cbs_rowid, l_msg_sv_rowid
            limit BULK_LIMIT;

            for i in 1..l_msg_cbs_rowid.count loop

                if l_last_matched_msg is null or l_last_matched_msg != l_msg_cbs_id(i) then

                    update rcn_cbs_msg m
                       set m.recon_status = case when condition_rec.condition_type = rcn_api_const_pkg.RECON_CONDITION_COMPARATIVE
                                                 then rcn_api_const_pkg.RECON_STATUS_SUCCESSFULL
                                                 else rcn_api_const_pkg.RECON_STATUS_MATCHED_COMP
                                            end
                         , m.recon_msg_id = case when rowid = l_msg_cbs_rowid(i)
                                                 then l_msg_sv_id(i)
                                                 else l_msg_cbs_id(i)
                                            end
                         , m.recon_date   = l_recon_date
                     where rowid in (
                               select rowid
                                 from (
                                     select rowid
                                          , count(*) over() cnt
                                       from rcn_cbs_msg
                                      where rowid in (l_msg_cbs_rowid(i), l_msg_sv_rowid(i))
                                        and recon_status = rcn_api_const_pkg.RECON_STATUS_REQ_RECON
                                 )
                                where cnt = 2
                     );

                    l_rowcount := sql%rowcount;

                    if l_rowcount > 0 then
                        trc_log_pkg.debug (
                            i_text          => 'Matched: cbs_msg_id[#1] sv_msg_id[#2]'
                          , i_env_param1    => l_msg_cbs_id(i)
                          , i_env_param2    => l_msg_sv_id(i)
                        );
                        l_last_matched_msg  := l_msg_cbs_id(i);
                        l_processed_count   := l_processed_count + 1;
                    end if;

                end if;

            end loop;

            prc_api_stat_pkg.log_current (
                i_current_count    => l_processed_count
              , i_excepted_count   => 0
            );

            exit when l_match_cur%notfound;
        end loop;
        close l_match_cur;
        trc_log_pkg.info (
            i_text         => 'Match condition type [#1], Matched messages [#2]'
          , i_env_param1   => condition_rec.condition_type
          , i_env_param2   => l_processed_count
        );
        commit;
    end loop;

    update rcn_cbs_msg m
       set m.recon_status = rcn_api_const_pkg.RECON_STATUS_FAILED
         , m.recon_date   = l_recon_date
     where m.recon_status = rcn_api_const_pkg.RECON_STATUS_REQ_RECON;

    l_rejected_count := greatest(l_estimated_count - l_processed_count, 0);

    prc_api_stat_pkg.log_end (
        i_processed_total  => l_processed_count
      , i_rejected_total   => l_rejected_count
      , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.info (
        i_text             => 'Reconciliate process finished. Matched mesages [#1], Mismatched mesages [#2]'
      , i_env_param1       => l_processed_count
      , i_env_param2       => l_rejected_count
    );

exception
    when others then
        rollback to savepoint processing_matching_start;

        if l_match_cur%isopen then
            close l_match_cur;
        end if;
        if l_match_conditions%isopen then
            close l_match_conditions;
        end if;

        prc_api_stat_pkg.log_end (
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error (
                i_error         => 'UNHANDLED_EXCEPTION'
                , i_env_param1  => sqlerrm
            );
        end if;
end process;
------------------------------
procedure process_atm(
    i_inst_id  in      com_api_type_pkg.t_inst_id default ost_api_const_pkg.DEFAULT_INST
) is
    l_inst_tab         num_tab_tpt;
    l_estimated_tab    com_api_type_pkg.t_number_tab;
    l_inst_id          com_api_type_pkg.t_inst_id;
    l_estimated_count  com_api_type_pkg.t_count := 0;
    l_processed_count  com_api_type_pkg.t_count := 0;
    l_rejected_count   com_api_type_pkg.t_count := 0;
    l_query_text       com_api_type_pkg.t_text;
    l_from_source      com_api_type_pkg.t_text;
    l_cursor           sys_refcursor;
    l_atm_id           com_api_type_pkg.t_number_tab;
    l_sv_id            com_api_type_pkg.t_number_tab;
    l_last_atm_id      com_api_type_pkg.t_long_id;
    l_last_sv_id       com_api_type_pkg.t_long_id;
    l_recon_date       date := com_api_sttl_day_pkg.get_sysdate();
    l_rowcount         com_api_type_pkg.t_count := 0;

    l_column_list      com_api_type_pkg.t_text :=
       'select atm.id' ||
            ', sv.id ';

    procedure open_cursor(
        i_inst_id   in     com_api_type_pkg.t_inst_id
      , i_condition in     com_api_type_pkg.t_text
      , i_cond_type in     com_api_type_pkg.t_dict_value
    ) is
    begin
        l_query_text := l_column_list || l_from_source || ' and ' || i_condition || ' order by atm.id, sv.id';

        open l_cursor for l_query_text using i_inst_id, i_inst_id;
        trc_log_pkg.info (i_text => 'rec.inst_id='||i_inst_id||', cond_type='||i_cond_type||', sql='||l_query_text);
    exception
        when others then
            trc_log_pkg.debug(
                i_text => 'Error execute query(inst_id='||i_inst_id||', cond_type='||i_cond_type
                  ||': ' || chr(13) || chr(10) || substr(l_query_text, 1, 3900)
            );
            raise;
    end;
begin
    prc_api_stat_pkg.log_start;

    savepoint recon_start;

    l_inst_id := nvl(i_inst_id, ost_api_const_pkg.DEFAULT_INST);


    trc_log_pkg.info(i_text => 'ATM reconciliation started.');

    select recon_inst_id
         , sum(count(1)) over() total_cnt
      bulk collect into
           l_inst_tab
         , l_estimated_tab
      from rcn_atm_msg m
     where m.msg_source    = rcn_api_const_pkg.RECON_MSG_SOURCE_ATM_EJOURNAL  --'RMSC0002'
       and m.recon_status  = rcn_api_const_pkg.RECON_STATUS_REQ_RECON       -- 'RNST0200'
       and (m.recon_inst_id = l_inst_id or l_inst_id = ost_api_const_pkg.DEFAULT_INST)
     group by recon_inst_id;

    if l_estimated_tab.exists(1) then
        l_estimated_count := l_estimated_tab(1);
    end if;

    prc_api_stat_pkg.log_estimation (i_estimated_count => l_estimated_count );

    l_from_source :=
        'from (select sv.id' ||
                   ', sv.msg_source' ||
                   ', sv.msg_date' ||
                   ', sv.operation_id' ||
                   ', sv.recon_msg_ref' ||
                   ', sv.recon_status' ||
                   ', sv.recon_last_date' ||
                   ', sv.recon_inst_id' ||
                   ', sv.oper_type' ||
                   ', sv.oper_date' ||
                   ', sv.oper_amount' ||
                   ', sv.oper_currency' ||
                   ', sv.trace_number' ||
                   ', sv.acq_inst_id' ||
                   ', sv.card_mask' ||
                   ', sv.auth_code' ||
                   ', sv.is_reversal' ||
                   ', sv.terminal_type' ||
                   ', sv.terminal_number' ||
                   ', sv.iss_fee' ||
                   ', sv.acc_from' ||
                   ', sv.acc_to' ||
                   ', c.card_number' ||
               ' from rcn_atm_msg sv '||
                   ', rcn_card c '||
               'where sv.id = c.id '||
                 'and sv.msg_source = ''' || rcn_api_const_pkg.RECON_MSG_SOURCE_INTERNAL || ''' ' ||
                 'and sv.recon_status = ''' || rcn_api_const_pkg.RECON_STATUS_REQ_RECON || ''' ' ||
                 'and sv.recon_inst_id = :p_inst_id ) sv ';

    l_from_source := l_from_source ||
       ',(select atm.id' ||
              ', atm.msg_source' ||
              ', atm.msg_date' ||
              ', atm.operation_id' ||
              ', atm.recon_msg_ref' ||
              ', atm.recon_status' ||
              ', atm.recon_last_date' ||
              ', atm.recon_inst_id' ||
              ', atm.oper_type' ||
              ', atm.oper_date' ||
              ', atm.oper_amount' ||
              ', atm.oper_currency' ||
              ', atm.trace_number' ||
              ', atm.acq_inst_id' ||
              ', atm.card_mask' ||
              ', atm.auth_code' ||
              ', atm.is_reversal' ||
              ', atm.terminal_type' ||
              ', atm.terminal_number' ||
              ', atm.iss_fee' ||
              ', atm.acc_from' ||
              ', atm.acc_to' ||
              ', c.card_number' ||
          ' from rcn_atm_msg atm '||
              ', rcn_card c '||
          'where atm.id = c.id '||
            'and atm.msg_source = ''' || rcn_api_const_pkg.RECON_MSG_SOURCE_ATM_EJOURNAL || ''' ' ||
            'and atm.recon_status = ''' || rcn_api_const_pkg.RECON_STATUS_REQ_RECON || ''' ' ||
            'and atm.recon_inst_id = :p_inst_id) atm ' ||
          'where 1=1 ' ;


    for rec in (
        with inst as (select column_value as inst_id from table(cast(l_inst_tab as num_tab_tpt)))
      , cond as (select 1 ord
                      , rcn_api_const_pkg.RECON_CONDITION_CONNECTIVE cond_type
                      , rcn_api_const_pkg.RECON_CONDITION_COMPARATIVE second_cond_type
                   from dual
                  union all
                 select 2 ord
                      , rcn_api_const_pkg.RECON_CONDITION_CONNECTIVE cond_type
                      , 'EMPTY' second_cond_type
                   from dual)
        select inst_id
             , cond_type
             , second_cond_type
             , ord
             -- If conditions are set for the Reconciliation institution and the Reconciliation type they should be selected,
             , nvl((select listagg(c.condition, ' and ') within group(order by c.id)
                      from rcn_condition c
                     where c.inst_id    = inst.inst_id
                       and c.recon_type = rcn_api_const_pkg.RECON_TYPE_ATM_EJOURNAL
                       and c.condition_type in (cond.cond_type, cond.second_cond_type) )
                -- If no conditions, select conditions for 9999 institution and the Reconciliation type,
                 , (select listagg(c.condition, ' and ') within group(order by c.id)
                      from rcn_condition c
                    where c.inst_id    = ost_api_const_pkg.DEFAULT_INST
                      and c.recon_type = rcn_api_const_pkg.RECON_TYPE_ATM_EJOURNAL
                      and c.condition_type in (cond.cond_type, cond.second_cond_type))
            ) conditions
          from inst
             , cond
      order by inst_id
             , ord
    ) loop
         if rec.conditions is null then
            -- If no connective conditions are set on reconciliation or 9999 institution and the Reconciliation type,
            -- return a reconciliation conditions error.
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'RCN_CONDITIONS_NOT_FOUND'
              , i_env_param1 => rec.inst_id
            );
        end if;

        trc_log_pkg.info (
            i_text => 'Condition type =' || rec.cond_type ||','||rec.second_cond_type
                   || ', condition=' || substr(rec.conditions, 1, 1900)
        );

        open_cursor(
            i_inst_id => rec.inst_id
          , i_condition => rec.conditions
          , i_cond_type=>rec.cond_type||','||rec.second_cond_type
        );

        l_last_atm_id := null;

        loop
            fetch l_cursor
             bulk collect into l_atm_id, l_sv_id
            limit BULK_LIMIT;

            for i in 1..l_atm_id.count loop

                if l_last_atm_id is null or l_last_atm_id != l_atm_id(i) then

                    update rcn_atm_msg m
                       set m.recon_status    = case when rec.second_cond_type = rcn_api_const_pkg.RECON_CONDITION_COMPARATIVE
                                                    then rcn_api_const_pkg.RECON_STATUS_SUCCESSFULL
                                                    else rcn_api_const_pkg.RECON_STATUS_MATCHED_COMP
                                               end
                         , m.recon_msg_ref   = case when m.id = l_atm_id(i)
                                                    then l_sv_id(i)
                                                    else l_atm_id(i)
                                               end
                         , m.recon_last_date = l_recon_date
                     where m.id in (
                               select y.id
                                 from (select x.id
                                            , count(1) over() cnt
                                         from rcn_atm_msg x
                                        where x.id in (l_atm_id(i), l_sv_id(i))
                                          and x.recon_status = rcn_api_const_pkg.RECON_STATUS_REQ_RECON) y
                                where cnt = 2
                     ) and m.recon_status = rcn_api_const_pkg.RECON_STATUS_REQ_RECON;

                    l_rowcount := sql%rowcount;

                    if l_rowcount > 0 then
                        trc_log_pkg.debug (
                            i_text        => 'Matched: atm_id=#1, sv_id=#2'
                          , i_env_param1  => l_atm_id(i)
                          , i_env_param2  => l_sv_id(i)
                        );

                        l_last_atm_id         := l_atm_id(i);
                        l_last_sv_id          := l_sv_id(i);
                        l_processed_count := l_processed_count + 1;
                    end if;

                elsif l_last_atm_id = l_atm_id(i) and l_last_sv_id != l_sv_id(i) then
                  --4. If for 1 message from ATMJ matched more than 1 message in SV:
                  --b. Another SV messages should be set to recon_status RNST0700 (Matched, duplicates)
                    update rcn_atm_msg m
                       set m.recon_status    = rcn_api_const_pkg.RECON_STATUS_MATCHED_DUPL
                         , m.recon_last_date = l_recon_date
                         , m.recon_msg_ref   = l_atm_id(i)
                     where m.id              = l_sv_id(i)
                       and m.recon_status    = rcn_api_const_pkg.RECON_STATUS_REQ_RECON;
                end if;

            end loop;

            prc_api_stat_pkg.log_current (
                i_current_count    => l_processed_count
              , i_excepted_count   => 0
            );

            exit when l_cursor%notfound;
        end loop;

        close l_cursor;

        trc_log_pkg.info (
            i_text         => 'Match condition type=#1, Matched messages=#2'
          , i_env_param1   => rec.cond_type || ',' || rec.second_cond_type
          , i_env_param2   => l_processed_count
        );
        commit;
    end loop;

    update rcn_atm_msg m
       set m.recon_status    = rcn_api_const_pkg.RECON_STATUS_FAILED
         , m.recon_last_date = l_recon_date
     where m.recon_status    = rcn_api_const_pkg.RECON_STATUS_REQ_RECON;

    l_rejected_count := greatest(l_estimated_count - l_processed_count, 0);

    prc_api_stat_pkg.log_end (
        i_processed_total  => l_processed_count
      , i_rejected_total   => l_rejected_count
      , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.info (
        i_text        => 'Reconciliation process finished. Matched messages [#1], Mismatched messages [#2]'
      , i_env_param1  => l_processed_count
      , i_env_param2  => l_rejected_count
    );

exception
    when others then
        rollback to savepoint recon_start;

        if l_cursor%isopen then
            close l_cursor;
        end if;

        prc_api_stat_pkg.log_end (
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error (
                i_error       => 'UNHANDLED_EXCEPTION'
              , i_env_param1  => sqlerrm
            );
        else
            raise;
        end if;
end process_atm;

procedure process_host(
    i_inst_id         in     com_api_type_pkg.t_inst_id default ost_api_const_pkg.DEFAULT_INST
  , i_recon_type      in     com_api_type_pkg.t_dict_value
  , i_register_event  in     com_api_type_pkg.t_boolean
  , i_msg_source      in     com_api_type_pkg.t_dict_value default rcn_api_const_pkg.RECON_MSG_SOURCE_HOST
) is
    l_inst_id         com_api_type_pkg.t_inst_id;
    l_inst_tab        num_tab_tpt;
    l_estimated_tab   com_api_type_pkg.t_number_tab;
    l_estimated_count com_api_type_pkg.t_count := 0;
    l_processed_count com_api_type_pkg.t_count := 0;
    l_rejected_count  com_api_type_pkg.t_count := 0;
    l_query_text      com_api_type_pkg.t_text;
    l_from_source     com_api_type_pkg.t_text;
    l_cursor          sys_refcursor;
    l_host_id         com_api_type_pkg.t_number_tab;
    l_sv_id           com_api_type_pkg.t_number_tab;
    l_last_host_id    com_api_type_pkg.t_long_id;
    l_last_sv_id      com_api_type_pkg.t_long_id;
    l_recon_date      date := com_api_sttl_day_pkg.get_sysdate();
    l_rowcount        com_api_type_pkg.t_count := 0;
    l_event_type      com_api_type_pkg.t_dict_value;
    l_id_tab          com_api_type_pkg.t_long_tab;
    l_status_tab      com_api_type_pkg.t_dict_tab;
    l_msg_source_tab  com_api_type_pkg.t_dict_tab;
    
    l_column_list     com_api_type_pkg.t_text :=
       'select hst.id' ||
            ', sv.id ';

    procedure open_cursor(
        i_inst_id   in     com_api_type_pkg.t_inst_id
      , i_condition in     com_api_type_pkg.t_text
      , i_cond_type in     com_api_type_pkg.t_dict_value
    ) is
    begin
        l_query_text := l_column_list || l_from_source || ' and ' || i_condition || ' order by hst.id, sv.id';

        open l_cursor for l_query_text using i_inst_id, i_inst_id;
        trc_log_pkg.info (i_text => 'rec.inst_id=' || i_inst_id || ', cond_type=' || i_cond_type || ', sql=' || l_query_text);
    exception
        when others then
            trc_log_pkg.debug(
                i_text => 'Error execute query(inst_id=' || i_inst_id || ', cond_type=' || i_cond_type
                  ||': ' || chr(13) || chr(10) || substr(l_query_text, 1, 3900)
            );
            raise;
    end;
begin
    savepoint recon_start;
    
    prc_api_stat_pkg.log_start;

    l_inst_id := nvl(i_inst_id, ost_api_const_pkg.DEFAULT_INST);
    g_register_event := i_register_event;

    trc_log_pkg.info(
        i_text       => 'Host reconciliation started, inst_id [#1], recon_type [#2], register_event [#3].'
      , i_env_param1 => l_inst_id
      , i_env_param2 => i_recon_type
      , i_env_param3 => i_register_event
    );

    select recon_inst_id
         , sum(count(1)) over() total_cnt
      bulk collect into
           l_inst_tab
         , l_estimated_tab
      from rcn_host_msg m
     where m.msg_source     = i_msg_source
       and m.recon_status   = rcn_api_const_pkg.RECON_STATUS_REQ_RECON -- 'RNST0200'
       and (m.recon_inst_id = l_inst_id or l_inst_id = ost_api_const_pkg.DEFAULT_INST)
     group by recon_inst_id;

    if l_estimated_tab.exists(1) then
        l_estimated_count := l_estimated_tab(1);
    end if;

    prc_api_stat_pkg.log_estimation (i_estimated_count => l_estimated_count );

    l_from_source :=
        'from(select sv.id ' ||
                 ' , sv.part_key ' ||
                 ' , sv.recon_type ' ||
                 ' , sv.msg_source ' ||
                 ' , sv.msg_date ' ||
                 ' , sv.oper_id ' ||
                 ' , sv.recon_msg_id ' ||
                 ' , sv.recon_status ' ||
                 ' , sv.recon_date ' ||
                 ' , sv.recon_inst_id ' ||
                 ' , sv.oper_type ' ||
                 ' , sv.msg_type ' ||
                 ' , sv.host_date ' ||
                 ' , sv.oper_date ' ||
                 ' , sv.oper_amount ' ||
                 ' , sv.oper_currency ' ||
                 ' , sv.oper_surcharge_amount ' ||
                 ' , sv.oper_surcharge_currency ' ||
                 ' , sv.status ' ||
                 ' , sv.is_reversal ' ||
                 ' , sv.merchant_number ' ||
                 ' , sv.mcc' ||
                 ' , sv.merchant_name' ||
                 ' , sv.merchant_street' ||
                 ' , sv.merchant_city' ||
                 ' , sv.merchant_region' ||
                 ' , sv.merchant_country' ||
                 ' , sv.merchant_postcode' ||
                 ' , sv.terminal_type' ||
                 ' , sv.terminal_number' ||
                 ' , sv.acq_inst_id' ||
                 ' , sv.card_mask' ||
                 ' , sv.card_seq_number' ||
                 ' , sv.card_expir_date' ||
                 ' , c.card_number' ||
                 ' , sv.oper_cashback_amount' ||
                 ' , sv.oper_cashback_currency' ||
                 ' , sv.service_code' ||
                 ' , sv.approval_code' ||
                 ' , sv.rrn' ||
                 ' , sv.trn' ||
                 ' , sv.original_id' ||
                 ' , sv.emv_5f2a' ||
                 ' , sv.emv_5f34' ||
                 ' , sv.emv_71' ||
                 ' , sv.emv_72' ||
                 ' , sv.emv_82' ||
                 ' , sv.emv_84' ||
                 ' , sv.emv_8a' ||
                 ' , sv.emv_91' ||
                 ' , sv.emv_95' ||
                 ' , sv.emv_9a' ||
                 ' , sv.emv_9c' ||
                 ' , sv.emv_9f02' ||
                 ' , sv.emv_9f03' ||
                 ' , sv.emv_9f06' ||
                 ' , sv.emv_9f09' ||
                 ' , sv.emv_9f10' ||
                 ' , sv.emv_9f18' ||
                 ' , sv.emv_9f1a' ||
                 ' , sv.emv_9f1e' ||
                 ' , sv.emv_9f26' ||
                 ' , sv.emv_9f27' ||
                 ' , sv.emv_9f28' ||
                 ' , sv.emv_9f29' ||
                 ' , sv.emv_9f33' ||
                 ' , sv.emv_9f34' ||
                 ' , sv.emv_9f35' ||
                 ' , sv.emv_9f36' ||
                 ' , sv.emv_9f37' ||
                 ' , sv.emv_9f41' ||
                 ' , sv.emv_9f53' ||
                 ' , sv.pdc_1' ||
                 ' , sv.pdc_2' ||
                 ' , sv.pdc_3' ||
                 ' , sv.pdc_4' ||
                 ' , sv.pdc_5' ||
                 ' , sv.pdc_6' ||
                 ' , sv.pdc_7' ||
                 ' , sv.pdc_8' ||
                 ' , sv.pdc_9' ||
                 ' , sv.pdc_10' ||
                 ' , sv.pdc_11' ||
                 ' , sv.pdc_12' ||
                 ' , sv.forw_inst_code' ||
                 ' , sv.receiv_inst_code' ||
                 ' , sv.sttl_date' ||
                 ' , sv.oper_reason' ||
              ' from rcn_host_msg sv ' ||
                 ' , rcn_card c  ' ||
             ' where sv.id            = c.id ' ||
               ' and sv.msg_source    = ''' || rcn_api_const_pkg.RECON_MSG_SOURCE_INTERNAL || ''' ' ||
               ' and sv.recon_status  = ''' || rcn_api_const_pkg.RECON_STATUS_REQ_RECON || ''' ' ||
               ' and sv.recon_type  = ''' || i_recon_type || ''' ' ||
               ' and sv.recon_inst_id = :p_inst_id' ||
             ' ) sv ';

    l_from_source := l_from_source ||
        ', (select hst.id ' ||
               ' , hst.part_key ' ||
               ' , hst.recon_type ' ||
               ' , hst.msg_source ' ||
               ' , hst.msg_date ' ||
               ' , hst.oper_id ' ||
               ' , hst.recon_msg_id ' ||
               ' , hst.recon_status ' ||
               ' , hst.recon_date ' ||
               ' , hst.recon_inst_id ' ||
               ' , hst.oper_type ' ||
               ' , hst.msg_type ' ||
               ' , hst.host_date ' ||
               ' , hst.oper_date ' ||
               ' , hst.oper_amount ' ||
               ' , hst.oper_currency ' ||
               ' , hst.oper_surcharge_amount ' ||
               ' , hst.oper_surcharge_currency ' ||
               ' , hst.status ' ||
               ' , hst.is_reversal ' ||
               ' , hst.merchant_number ' ||
               ' , hst.mcc' ||
               ' , hst.merchant_name' ||
               ' , hst.merchant_street' ||
               ' , hst.merchant_city' ||
               ' , hst.merchant_region' ||
               ' , hst.merchant_country' ||
               ' , hst.merchant_postcode' ||
               ' , hst.terminal_type' ||
               ' , hst.terminal_number' ||
               ' , hst.acq_inst_id' ||
               ' , hst.card_mask' ||
               ' , hst.card_seq_number' ||
               ' , hst.card_expir_date' ||
               ' , c.card_number' ||
               ' , hst.oper_cashback_amount' ||
               ' , hst.oper_cashback_currency' ||
               ' , hst.service_code' ||
               ' , hst.approval_code' ||
               ' , hst.rrn' ||
               ' , hst.trn' ||
               ' , hst.original_id' ||
               ' , hst.emv_5f2a' ||
               ' , hst.emv_5f34' ||
               ' , hst.emv_71' ||
               ' , hst.emv_72' ||
               ' , hst.emv_82' ||
               ' , hst.emv_84' ||
               ' , hst.emv_8a' ||
               ' , hst.emv_91' ||
               ' , hst.emv_95' ||
               ' , hst.emv_9a' ||
               ' , hst.emv_9c' ||
               ' , hst.emv_9f02' ||
               ' , hst.emv_9f03' ||
               ' , hst.emv_9f06' ||
               ' , hst.emv_9f09' ||
               ' , hst.emv_9f10' ||
               ' , hst.emv_9f18' ||
               ' , hst.emv_9f1a' ||
               ' , hst.emv_9f1e' ||
               ' , hst.emv_9f26' ||
               ' , hst.emv_9f27' ||
               ' , hst.emv_9f28' ||
               ' , hst.emv_9f29' ||
               ' , hst.emv_9f33' ||
               ' , hst.emv_9f34' ||
               ' , hst.emv_9f35' ||
               ' , hst.emv_9f36' ||
               ' , hst.emv_9f37' ||
               ' , hst.emv_9f41' ||
               ' , hst.emv_9f53' ||
               ' , hst.pdc_1' ||
               ' , hst.pdc_2' ||
               ' , hst.pdc_3' ||
               ' , hst.pdc_4' ||
               ' , hst.pdc_5' ||
               ' , hst.pdc_6' ||
               ' , hst.pdc_7' ||
               ' , hst.pdc_8' ||
               ' , hst.pdc_9' ||
               ' , hst.pdc_10' ||
               ' , hst.pdc_11' ||
               ' , hst.pdc_12' ||
               ' , hst.forw_inst_code' ||
               ' , hst.receiv_inst_code' ||
               ' , hst.sttl_date' ||
               ' , hst.oper_reason' ||
            ' from rcn_host_msg hst ' ||
               ' , rcn_card c  ' ||
           ' where hst.id            = c.id ' ||
             ' and hst.msg_source    = ''' || i_msg_source || ''' ' ||
             ' and hst.recon_status  = ''' || rcn_api_const_pkg.RECON_STATUS_REQ_RECON || ''' ' ||
             ' and hst.recon_type  = ''' || i_recon_type || ''' ' ||
             ' and hst.recon_inst_id = :p_inst_id) hst ' ||
           ' where sv.recon_inst_id = hst.recon_inst_id ' ;

    for rec in (
        with inst as (select column_value as inst_id from table(cast(l_inst_tab as num_tab_tpt)))
      , cond as (select 1 ord
                      , rcn_api_const_pkg.RECON_CONDITION_CONNECTIVE cond_type
                      , rcn_api_const_pkg.RECON_CONDITION_COMPARATIVE second_cond_type
                   from dual
                  union all
                 select 2 ord
                      , rcn_api_const_pkg.RECON_CONDITION_CONNECTIVE cond_type
                      , 'EMPTY' second_cond_type
                   from dual)
        select inst_id
             , cond_type
             , second_cond_type
             , ord
             -- If conditions are set for the Reconciliation institution and the Reconciliation type they should be selected,
             , nvl((select listagg(c.condition, ' and ') within group(order by c.id)
                      from rcn_condition c
                     where c.inst_id    = inst.inst_id
                       and c.recon_type = i_recon_type
                       and c.condition_type in (cond.cond_type, cond.second_cond_type) )
                -- If no conditions, select conditions for 9999 institution and the Reconciliation type,
                 , (select listagg(c.condition, ' and ') within group(order by c.id)
                      from rcn_condition c
                    where c.inst_id    = ost_api_const_pkg.DEFAULT_INST
                      and c.recon_type = i_recon_type
                      and c.condition_type in (cond.cond_type, cond.second_cond_type))
               ) conditions
          from inst
             , cond
      order by inst_id
             , ord
    ) loop
         if rec.conditions is null then
            -- If no connective conditions are set on reconciliation or 9999 institution and the Reconciliation type,
            -- return a reconciliation conditions error.
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'RCN_CONDITIONS_NOT_FOUND'
              , i_env_param1 => rec.inst_id
            );
        end if;

        trc_log_pkg.info (
            i_text => 'Condition type =' || rec.cond_type ||','||rec.second_cond_type
                   || ', condition=' || substr(rec.conditions, 1, 1900)
        );

        open_cursor(
            i_inst_id   => rec.inst_id
          , i_condition => rec.conditions
          , i_cond_type => rec.cond_type || ',' || rec.second_cond_type
        );

        l_last_host_id := null;

        loop
            fetch l_cursor
             bulk collect into l_host_id, l_sv_id
            limit BULK_LIMIT;

            for i in 1..l_host_id.count loop

                if l_last_host_id is null or l_last_host_id != l_host_id(i) then

                    update rcn_host_msg m
                       set m.recon_status = case when rec.second_cond_type = rcn_api_const_pkg.RECON_CONDITION_COMPARATIVE -- 'RCTPCOMP'
                                                 then rcn_api_const_pkg.RECON_STATUS_SUCCESSFULL  -- 'RNST0500'
                                                 else rcn_api_const_pkg.RECON_STATUS_MATCHED_COMP -- 'RNST0600'
                                            end
                         , m.recon_msg_id = case when m.id = l_host_id(i)
                                                 then l_sv_id(i)
                                                 else l_host_id(i)
                                            end
                         , m.recon_date = l_recon_date
                     where m.id in (
                               select y.id
                                 from (select x.id
                                            , count(1) over() cnt
                                         from rcn_host_msg x
                                        where x.id in (l_host_id(i), l_sv_id(i))
                                          and x.recon_status = rcn_api_const_pkg.RECON_STATUS_REQ_RECON) y -- 'RNST0200'
                                where cnt = 2
                     ) and m.recon_status = rcn_api_const_pkg.RECON_STATUS_REQ_RECON  -- 'RNST0200'
                 returning m.id
                         , m.recon_status
                      bulk collect into
                           l_id_tab
                         , l_status_tab;
                  
                    l_rowcount := sql%rowcount;

                    if l_rowcount > 0 then
                        trc_log_pkg.debug (
                            i_text        => 'Matched: host_id=#1, sv_id=#2'
                          , i_env_param1  => l_host_id(i)
                          , i_env_param2  => l_sv_id(i)
                        );

                        l_last_host_id    := l_host_id(i);
                        l_last_sv_id      := l_sv_id(i);
                        l_processed_count := l_processed_count + 1;
                    end if;

                    if l_id_tab.count > 0 then

                        for q in l_id_tab.first .. l_id_tab.last loop

                            l_event_type := case l_status_tab(q)
                                            when rcn_api_const_pkg.RECON_STATUS_SUCCESSFULL  -- 'RNST0500'
                                            then rcn_api_const_pkg.EVENT_TYPE_RCN_SUCCESS    -- 'EVNT2100'
                                            when rcn_api_const_pkg.RECON_STATUS_MATCHED_COMP -- 'RNST0600'
                                            then rcn_api_const_pkg.EVENT_TYPE_RCN_COMP_ERR   -- 'EVNT2103'
                                            else null
                                            end;

                            reg_event(
                                i_event_type   => l_event_type
                              , i_recon_msg_id => l_id_tab(q)
                              , i_inst_id      => rec.inst_id
                            );

                        end loop;

                    end if;

                  
                elsif l_last_host_id = l_host_id(i) and l_last_sv_id != l_sv_id(i) then
                  --4. If for 1 message from HOST matched more than 1 message in SV:
                  --b. Another SV messages should be set to recon_status RNST0700 (Matched, duplicates)
                    update rcn_host_msg m
                       set m.recon_status  = rcn_api_const_pkg.RECON_STATUS_MATCHED_DUPL -- 'RNST0700'
                         , m.recon_date    = l_recon_date
                         , m.recon_msg_id  = l_host_id(i)
                     where m.id            = l_sv_id(i)
                       and m.recon_status  = rcn_api_const_pkg.RECON_STATUS_REQ_RECON; -- 'RNST0200'

                    reg_event(
                        i_event_type   => rcn_api_const_pkg.EVENT_TYPE_RCN_DUPLICATED  -- EVNT2104
                      , i_recon_msg_id => l_sv_id(i)
                      , i_inst_id      => rec.inst_id
                    );
                end if;

            end loop;

            prc_api_stat_pkg.log_current (
                i_current_count    => l_processed_count
              , i_excepted_count   => 0
            );

            exit when l_cursor%notfound;
        end loop;

        close l_cursor;

        trc_log_pkg.info (
            i_text         => 'Match condition type=#1, Matched messages=#2'
          , i_env_param1   => rec.cond_type || ',' || rec.second_cond_type
          , i_env_param2   => l_processed_count
        );
        commit;
    end loop;

    update rcn_host_msg m
       set m.recon_status  = rcn_api_const_pkg.RECON_STATUS_FAILED  -- 'RNST0100'
         , m.recon_date    = l_recon_date
     where m.recon_status  = rcn_api_const_pkg.RECON_STATUS_REQ_RECON -- 'RNST0200'
 returning m.id
         , m.recon_status
         , m.msg_source
      bulk collect into
           l_id_tab
         , l_status_tab
         , l_msg_source_tab;

    -- If a pair is not found, set to source message status RNST0100  Reconciliation failed and
    -- if the parameter Generate event set to Yes then provide the event EVNT2101  Hosts reconciliation message failed,
    if l_id_tab.count > 0 then
        for q in l_id_tab.first .. l_id_tab.last loop
            if l_status_tab(q) =  rcn_api_const_pkg.RECON_STATUS_FAILED
           and l_msg_source_tab(q) = i_msg_source
            then
                reg_event(
                    i_event_type   => rcn_api_const_pkg.EVENT_TYPE_RCN_FAILED -- 'EVNT2101'
                  , i_recon_msg_id => l_id_tab(q)
                  , i_inst_id      => i_inst_id
                );
            end if;
        end loop;
    end if;

    l_rejected_count := greatest(l_estimated_count - l_processed_count, 0);

    prc_api_stat_pkg.log_end (
        i_processed_total  => l_processed_count
      , i_rejected_total   => l_rejected_count
      , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.info (
        i_text        => 'Host reconciliation finished. Matched [#1], mismatched [#2] messages '
      , i_env_param1  => l_processed_count
      , i_env_param2  => l_rejected_count
    );

exception
    when others then
        rollback to savepoint recon_start;

        if l_cursor%isopen then
            close l_cursor;
        end if;

        prc_api_stat_pkg.log_end (
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error (
                i_error       => 'UNHANDLED_EXCEPTION'
              , i_env_param1  => sqlerrm
            );
        else
            raise;
        end if;
end process_host;

procedure process_mark_expired (
    i_inst_id            in     com_api_type_pkg.t_inst_id
) is
    l_match_depth               com_api_type_pkg.t_long_id;
    l_match_depth_date          date;
    l_processed_count           com_api_type_pkg.t_long_id := 0;
begin
    savepoint processing_mark_expired;

    prc_api_stat_pkg.log_start;

    trc_log_pkg.debug (
        i_text      => 'Processing mark expired CBS reconciliation messages started ...'
    );

    -- get match depth value
    l_match_depth := nvl( set_ui_value_pkg.get_inst_param_n ( i_param_name => 'RECONCILIATION_EXPIRED_PERIOD', i_inst_id  => i_inst_id ), rcn_api_const_pkg.DEFAULT_EXPIRED_PERIOD );
    -- calculate date
    l_match_depth_date := com_api_sttl_day_pkg.get_sysdate() - l_match_depth;

    trc_log_pkg.debug (
        i_text      => 'Match depth [' || l_match_depth || ']'
    );

    -- update operations
    update rcn_cbs_msg m
       set m.recon_status = rcn_api_const_pkg.RECON_STATUS_EXPIRED
         , m.recon_date   = l_match_depth_date
     where m.recon_status = rcn_api_const_pkg.RECON_STATUS_REQ_RECON
       and m.msg_date <= l_match_depth_date;

    l_processed_count := sql%rowcount;

    trc_log_pkg.debug (
        i_text          => 'Saving #1 messages matching statuses'
        , i_env_param1  => l_processed_count
    );

    prc_api_stat_pkg.log_estimation (
        i_estimated_count => l_processed_count
    );

    prc_api_stat_pkg.log_end (
        i_excepted_total     => 0
        , i_processed_total  => l_processed_count
        , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug (
        i_text      => 'Processing mark expired CBS reconciliation messages finished ...'
    );
exception
    when others then
        rollback to savepoint processing_mark_expired;

        prc_api_stat_pkg.log_end (
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;
end process_mark_expired;

procedure process_atm_mark_expired (
    i_inst_id  in     com_api_type_pkg.t_inst_id
) is
    l_exp_period      com_api_type_pkg.t_long_id;
    l_exp_date        date;
    l_processed_count com_api_type_pkg.t_count := 0;
begin
    savepoint proc_mark_expired;

    prc_api_stat_pkg.log_start;

    trc_log_pkg.debug (
        i_text      => 'Processing mark expired ATM reconciliation messages started ...'
    );

    -- get expired period
    l_exp_period := set_ui_value_pkg.get_inst_param_n(
                         i_param_name => 'ATM_RECONCILIATION_EXPIRED_PERIOD'
                       , i_inst_id    => i_inst_id
                     );

    if l_exp_period is null then
        trc_log_pkg.debug (i_text => 'expired period is not set (empty), nothing to do.');
    else
        -- calculate date
        l_exp_date := com_api_sttl_day_pkg.get_sysdate() - l_exp_period;
        trc_log_pkg.debug (i_text => 'Expiration date = ' || to_char(l_exp_date, com_api_const_pkg.XML_DATE_FORMAT));

        -- update operations
        update rcn_atm_msg m
           set m.recon_status = rcn_api_const_pkg.RECON_STATUS_EXPIRED
             , m.msg_date     = l_exp_date
         where m.recon_status = rcn_api_const_pkg.RECON_STATUS_REQ_RECON
           and m.msg_date    <= trunc(l_exp_date);

        l_processed_count := sql%rowcount;

        trc_log_pkg.debug (
            i_text        => 'Saving #1 messages matching statuses'
          , i_env_param1  => l_processed_count
        );
    end if;

    prc_api_stat_pkg.log_estimation (
        i_estimated_count => l_processed_count
    );

    prc_api_stat_pkg.log_end (
        i_excepted_total   => 0
      , i_processed_total  => l_processed_count
      , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug (
        i_text      => 'Processing mark expired ATM reconciliation messages finished ...'
    );
exception
    when others then
        rollback to savepoint proc_mark_expired;

        prc_api_stat_pkg.log_end (
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;
end process_atm_mark_expired;

procedure process_host_mark_expired(
    i_register_event  in      com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
  , i_inst_id         in      com_api_type_pkg.t_inst_id
) is
    l_exp_period      com_api_type_pkg.t_long_id;
    l_exp_date        date;
    l_processed_count com_api_type_pkg.t_count := 0;
    l_id_tab          com_api_type_pkg.t_long_tab;
    l_inst_tab        com_api_type_pkg.t_inst_id_tab;
begin
    savepoint proc_mark_expired;

    prc_api_stat_pkg.log_start;

    trc_log_pkg.debug (
        i_text      => 'Processing mark expired HOST reconciliation messages started ...'
    );
    g_register_event := i_register_event;

    -- get expired period
    l_exp_period := set_ui_value_pkg.get_inst_param_n(
                         i_param_name => 'HOST_RECONCILIATION_EXPIRED_PERIOD'
                       , i_inst_id    => i_inst_id
                     );

    if l_exp_period is null then
        trc_log_pkg.debug (i_text => 'HOST expired period is not set (empty), nothing to do.');
    else
        -- calculate date
        l_exp_date := com_api_sttl_day_pkg.get_sysdate() - l_exp_period;
        trc_log_pkg.debug (i_text => 'Expiration date = ' || to_char(l_exp_date, com_api_const_pkg.XML_DATE_FORMAT));

        update rcn_host_msg m
           set m.recon_status = rcn_api_const_pkg.RECON_STATUS_EXPIRED
             , m.msg_date     = l_exp_date
         where m.recon_status = rcn_api_const_pkg.RECON_STATUS_REQ_RECON
           and m.msg_date    <= trunc(l_exp_date)
     returning m.id
             , m.recon_inst_id
          bulk collect into
               l_id_tab
             , l_inst_tab;

         l_processed_count := sql%rowcount;

        if l_id_tab.count > 0
       and nvl(i_register_event, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE then
           trc_log_pkg.debug (
                i_text        => 'going to HOST expiration events generation'
              , i_env_param1  => l_processed_count
            );

            for i in l_id_tab.first .. l_id_tab.last loop
                reg_event(
                    i_event_type   => rcn_api_const_pkg.EVENT_TYPE_RCN_EXPIRED --'EVNT2102'
                  , i_recon_msg_id => l_id_tab(i)
                  , i_inst_id      => l_inst_tab(i)
                );
            end loop;
        end if;

        trc_log_pkg.debug (
            i_text        => 'Status of [#1] HOST messages has been set to Expired'
          , i_env_param1  => l_processed_count
        );
    end if;

    prc_api_stat_pkg.log_estimation (
        i_estimated_count => l_processed_count
    );

    prc_api_stat_pkg.log_end (
        i_excepted_total   => 0
      , i_processed_total  => l_processed_count
      , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug (
        i_text      => 'Processing mark expired HOST reconciliation messages finished ...'
    );
exception
    when others then
        rollback to savepoint proc_mark_expired;

        prc_api_stat_pkg.log_end (
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;
end process_host_mark_expired;

procedure process_srvp(
    i_inst_id                   in      com_api_type_pkg.t_inst_id
  , i_service_provider_id       in      com_api_type_pkg.t_short_id      default null
  , i_purpose_id                in      com_api_type_pkg.t_short_id      default null
  , i_recon_type                in      com_api_type_pkg.t_dict_value    default rcn_api_const_pkg.RECON_TYPE_SRVP
) is
    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_srvp: ';
    l_match_cur                 sys_refcursor;
    l_last_matched_msg          com_api_type_pkg.t_long_id;
    l_recon_date                date;
    l_msg_srvp_id               com_api_type_pkg.t_number_tab;
    l_msg_sv_id                 com_api_type_pkg.t_number_tab;
    l_msg_srvp_rowid            com_api_type_pkg.t_rowid_tab;
    l_msg_sv_rowid              com_api_type_pkg.t_rowid_tab;

    l_estimated_count           com_api_type_pkg.t_long_id      := 0;
    l_rejected_count            com_api_type_pkg.t_long_id      := 0;
    l_processed_count           com_api_type_pkg.t_long_id      := 0;
    l_rowcount                  com_api_type_pkg.t_long_id;

    l_param_source              com_api_type_pkg.t_text :=
        ', (' ||
            'select :p_inst_id      p_inst_id ' ||
                 ', :p_provider_id  p_provider_id ' ||
                 ', :p_purpose_id   p_purpose_id ' ||
                 ', :p_recon_type   p_recon_type ' ||
              'from dual ' ||
           ') x ';

    l_column_list               com_api_type_pkg.t_text :=
        'select ' ||
            '  srvp.id' ||
            ', sv.id' ||
            ', srvp.row_id srvp_rowid' ||
            ', sv.row_id sv_rowid ';

    l_ref_source                com_api_type_pkg.t_text;

    l_estimated_source          com_api_type_pkg.t_text;

    l_param_query       com_api_type_pkg.t_lob_data;
    l_param_columns     com_api_type_pkg.t_lob_data;
    l_param_where       com_api_type_pkg.t_lob_data;


    cursor l_match_conditions(
        i_inst_id               com_api_type_pkg.t_inst_id
      , i_provider_id           com_api_type_pkg.t_short_id
      , i_purpose_id            com_api_type_pkg.t_short_id
      , i_recon_type            com_api_type_pkg.t_dict_value
    ) is
        select max(condition) condition
             , condition_type
             , provider_id
             , purpose_id
          from (
              select t.rn
                   , replace(sys_connect_by_path('(' || t.condition || ')', '__and_'), '__and_', ' and ') as condition
                   , t.condition_type
                   , provider_id
                   , purpose_id
                from (
                    select row_number() over (partition by priority order by condition) rn
                         , condition
                         , priority
                         , condition_type
                         , provider_id
                         , purpose_id
                      from (
                          select c.condition
                               , rcn_api_const_pkg.RECON_CONDITION_COMPARATIVE as condition_type
                               , 1 as priority
                               , provider_id
                               , purpose_id
                            from rcn_condition c
                           where (c.inst_id = i_inst_id or c.inst_id = ost_api_const_pkg.DEFAULT_INST)
                             and c.recon_type = i_recon_type
                             and (c.provider_id = i_provider_id or i_provider_id is null)
                             and (c.purpose_id  = i_purpose_id or i_purpose_id is null)
                             and c.condition_type in (rcn_api_const_pkg.RECON_CONDITION_CONNECTIVE
                                                    , rcn_api_const_pkg.RECON_CONDITION_COMPARATIVE
                                 )
                           union all
                          select c.condition
                               , c.condition_type
                               , 2 as priority
                               , provider_id
                               , purpose_id
                            from rcn_condition c
                           where (c.inst_id = i_inst_id or c.inst_id = ost_api_const_pkg.DEFAULT_INST)
                             and c.recon_type = i_recon_type
                             and (c.provider_id = i_provider_id or i_provider_id is null)
                             and (c.purpose_id  = i_purpose_id or i_purpose_id is null)
                             and c.condition_type = rcn_api_const_pkg.RECON_CONDITION_CONNECTIVE
                      )
                ) t
                start with t.rn = 1
                connect by prior t.priority = t.priority
                       and prior t.rn + 1   = t.rn
          )
          group by provider_id, purpose_id, condition_type
          order by decode(condition_type, rcn_api_const_pkg.RECON_CONDITION_CONNECTIVE, 2
                                        , rcn_api_const_pkg.RECON_CONDITION_COMPARATIVE, 1
                                        , 99
                          );

    procedure open_match_cur(
        i_condition     in com_api_type_pkg.t_text
    ) is
        l_match_cur_stmt   com_api_type_pkg.t_lob_data;
    begin
        l_match_cur_stmt :=
            l_column_list || l_ref_source
            || i_condition
            || ' order by srvp.id,'
            || ' sv.id';

        open l_match_cur for l_match_cur_stmt using i_inst_id, i_recon_type, i_inst_id, i_recon_type;
    exception
        when others then
            trc_log_pkg.debug(
                i_text => 'Exception on opening a matching cursor l_match_cur_stmt: '
                       || chr(13) || chr(10) || substr(l_match_cur_stmt, 1, 3900)
            );
            raise;
    end;

    procedure generate_sql_clause(i_prefix in com_api_type_pkg.t_text)
    is
        l_select          com_api_type_pkg.t_text;
        l_cols_list       com_api_type_pkg.t_lob_data := null;
        l_cols_list_query com_api_type_pkg.t_lob_data;
        l_from            com_api_type_pkg.t_text;
    begin
        l_select := ', (select d.msg_id, pp.provider_id, d.purpose_id ';
        l_from := ' from rcn_srvp_data d ' ||
                  ' , pmo_parameter p ' ||
                  ' , rcn_srvp_parameter pp ' ||
                  ' where d.param_id = p.id ' ||
                  '   and d.param_id = pp.param_id ' ||
                  '   and d.purpose_id = pp.purpose_id ' ||
                  ' group by d.msg_id, pp.provider_id, d.purpose_id) par ';
        for i in (
            select p.param_name
              from rcn_srvp_parameter d
                 , pmo_parameter p
             where d.param_id = p.id
        ) loop
            if length(i.param_name) <= 32 then
                l_cols_list         := l_cols_list || ', ' || i.param_name || ' ';
                l_cols_list_query   := l_cols_list_query || ', ' || ' max(decode(p.param_name, ''' || i.param_name || ''', d.param_value)) as ' || i.param_name || ' ';
            else
                com_api_error_pkg.raise_error(
                    i_error         => 'UNHANDLED_EXCEPTION'
                    , i_env_param1  => i.param_name
                );
            end if;
        end loop;
        if l_cols_list is not null then 
            l_param_columns   := l_cols_list;
            l_param_query     := l_select || l_cols_list_query || l_from;
            l_param_where     :=
                'and ' || i_prefix || 'id = par.msg_id '||
                'and ' || i_prefix || 'provider_id = par.provider_id '||
                'and ' || i_prefix || 'purpose_id = par.purpose_id ';
        end if;
    exception
        when others then
            trc_log_pkg.debug(
                i_text => 'Exception on generate_params: '
            );
            raise;
    end generate_sql_clause;
begin
    savepoint srvp_processing_matching_start;

    prc_api_stat_pkg.log_start;

    trc_log_pkg.info(
        i_text          => LOG_PREFIX || 'STARTED'
    );

    l_recon_date := com_api_sttl_day_pkg.get_sysdate();

    generate_sql_clause(i_prefix => 'srvp.');

    l_ref_source :=
        'from '||
            '( '||
              'select ' ||
                   '  srvp.rowid as row_id ' ||
                   ', srvp.id ' ||
                   ', srvp.part_key ' ||
                   ', srvp.recon_type ' ||
                   ', srvp.msg_source ' ||
                   ', srvp.recon_status ' ||
                   ', srvp.msg_date ' ||
                   ', srvp.recon_date ' ||
                   ', srvp.inst_id ' ||
                   ', srvp.split_hash ' ||
                   ', srvp.order_id ' ||
                   ', srvp.recon_msg_id ' ||
                   ', srvp.payment_order_number ' ||
                   ', srvp.order_date ' ||
                   ', srvp.order_amount ' ||
                   ', srvp.order_currency ' ||
                   ', srvp.customer_id ' ||
                   ', srvp.customer_number ' ||
                   ', srvp.purpose_id ' ||
                   ', srvp.purpose_number ' ||
                   ', srvp.provider_id ' ||
                   ', srvp.provider_number ' ||
                   ', srvp.order_status ' ||
                   ', rownum as rnm '||
                   l_param_columns ||
                'from rcn_srvp_msg srvp'||
                   ', (select :p_inst_id p_inst_id, :p_recon_type as p_recon_type from dual) x '||
                   l_param_query ||
               'where 1 = 1 '||
                 'and srvp.msg_source = ''' || rcn_api_const_pkg.RECON_MSG_SOURCE_SRVP || ''' ' ||
                 'and srvp.recon_status = ''' || rcn_api_const_pkg.RECON_STATUS_REQ_RECON || ''' ' ||
                 'and srvp.inst_id = x.p_inst_id '||
                 'and srvp.recon_type = x.p_recon_type '||
                 case when i_service_provider_id is not null then 'and srvp.provider_id = x.p_provider_id ' end ||
                 case when i_purpose_id is not null then 'and srvp.purpose_id = x.p_purpose_id ' end ||
                 l_param_where ||
            ') srvp ';

    generate_sql_clause(i_prefix => 'sv.');

    l_ref_source := l_ref_source ||
          ', ( '||
              'select '||
                   '  sv.rowid as row_id ' ||
                   ', sv.id ' ||
                   ', sv.part_key ' ||
                   ', sv.recon_type ' ||
                   ', sv.msg_source ' ||
                   ', sv.recon_status ' ||
                   ', sv.msg_date ' ||
                   ', sv.recon_date ' ||
                   ', sv.inst_id ' ||
                   ', sv.split_hash ' ||
                   ', sv.order_id ' ||
                   ', sv.recon_msg_id ' ||
                   ', sv.payment_order_number ' ||
                   ', sv.order_date ' ||
                   ', sv.order_amount ' ||
                   ', sv.order_currency ' ||
                   ', sv.customer_id ' ||
                   ', sv.customer_number ' ||
                   ', sv.purpose_id ' ||
                   ', sv.purpose_number ' ||
                   ', sv.provider_id ' ||
                   ', sv.provider_number ' ||
                   ', sv.order_status ' ||
                   ', rownum as rnm '||
                   l_param_columns ||
                'from rcn_srvp_msg sv'||
                   ', (select :p_inst_id p_inst_id, :p_recon_type as p_recon_type from dual) x '||
                   l_param_query ||
               'where 1 = 1 '||
                 'and sv.msg_source = ''' || rcn_api_const_pkg.RECON_MSG_SOURCE_INTERNAL || ''' ' ||
                 'and sv.recon_status = ''' || rcn_api_const_pkg.RECON_STATUS_REQ_RECON || ''' ' ||
                 'and sv.inst_id = x.p_inst_id '||
                 'and sv.recon_type = x.p_recon_type '||
                 case when i_service_provider_id is not null then 'and m.provider_id = x.p_provider_id ' end ||
                 case when i_purpose_id is not null then 'and m.purpose_id = x.p_purpose_id ' end ||
                 l_param_where ||
            ') sv ' ||
        'where 1 = 1 ';

    trc_log_pkg.info(
        i_text => 
            replace(
                replace(
                    replace(
                        replace(
                            l_ref_source, ':p_inst_id', i_inst_id
                        )
                        , ':p_recon_type', ''''|| i_recon_type || ''''
                    )
                  , ':p_purpose_id', i_purpose_id
               )
             , ':p_provider_id', i_service_provider_id
         )
    );

    l_estimated_source :=
        'select '||
             'count(1) ' ||
        'from' ||
             ' rcn_srvp_msg m' ||
             l_param_source ||
        'where 1 = 1' ||
          'and m.msg_source = ''' || rcn_api_const_pkg.RECON_MSG_SOURCE_srvp || ''' ' ||
          'and m.recon_status = ''' || rcn_api_const_pkg.RECON_STATUS_REQ_RECON || ''' ' ||
          'and m.inst_id = x.p_inst_id ' ||
          'and m.recon_type = x.p_recon_type ' ||
          case when i_service_provider_id is not null then 'and m.provider_id = x.p_provider_id ' end ||
          case when i_purpose_id is not null then 'and m.purpose_id = x.p_purpose_id ' end;

    trc_log_pkg.info(
        i_text => 
            replace(
                replace(
                    replace(
                        replace(
                            l_estimated_source, ':p_inst_id', i_inst_id
                        )
                        , ':p_recon_type', ''''|| i_recon_type || ''''
                    )
                  , ':p_purpose_id', i_purpose_id
               )
             , ':p_provider_id', i_service_provider_id
         )
    );

    execute immediate l_estimated_source
        into l_estimated_count
        using i_inst_id
            , i_service_provider_id
            , i_purpose_id
            , i_recon_type;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count => l_estimated_count
    );

    trc_log_pkg.info(
        i_text =>
            'Reconciliation process started for inst_id [' || i_inst_id ||
            '], recon_type [' || i_recon_type || 
            '], estimated_count [' || l_estimated_count ||
            ']'
    );

    for condition_rec in l_match_conditions(i_inst_id, i_service_provider_id, i_purpose_id, i_recon_type) loop

        l_last_matched_msg := null;

        trc_log_pkg.info(
            i_text => 'Condition type [' || condition_rec.condition_type || '] ' ||
                      'condition [' || substr(condition_rec.condition, 1, 1900) || ']'
        );

        open_match_cur(
            i_condition => condition_rec.condition
        );

        trc_log_pkg.debug(
            i_text      => 'Opening matching cursor finished' 
        );

        loop
            fetch l_match_cur
             bulk collect into l_msg_srvp_id, l_msg_sv_id, l_msg_srvp_rowid, l_msg_sv_rowid
            limit BULK_LIMIT;

            for i in 1..l_msg_srvp_rowid.count loop

                if l_last_matched_msg is null or l_last_matched_msg != l_msg_srvp_id(i) then

                    update rcn_srvp_msg m
                       set m.recon_status = case when condition_rec.condition_type = rcn_api_const_pkg.RECON_CONDITION_COMPARATIVE
                                                 then rcn_api_const_pkg.RECON_STATUS_SUCCESSFULL
                                                 else rcn_api_const_pkg.RECON_STATUS_MATCHED_COMP
                                            end
                         , m.recon_msg_id = case when rowid = l_msg_srvp_rowid(i)
                                                 then l_msg_sv_id(i)
                                                 else l_msg_srvp_id(i)
                                            end
                         , m.recon_date   = l_recon_date
                     where rowid in (
                               select rowid
                                 from (
                                     select rowid
                                          , count(1) over() cnt
                                       from rcn_srvp_msg
                                      where rowid in (l_msg_srvp_rowid(i), l_msg_sv_rowid(i))
                                        and recon_status = rcn_api_const_pkg.RECON_STATUS_REQ_RECON
                                 )
                                where cnt = 2
                     );

                    l_rowcount := sql%rowcount;

                    if l_rowcount > 0 then
                        trc_log_pkg.debug(
                            i_text          => 'Matched: srvp_msg_id[#1] sv_msg_id[#2]'
                          , i_env_param1    => l_msg_srvp_id(i)
                          , i_env_param2    => l_msg_sv_id(i)
                        );
                        l_last_matched_msg  := l_msg_srvp_id(i);
                        l_processed_count   := l_processed_count + 1;
                    end if;

                end if;

            end loop;

            prc_api_stat_pkg.log_current(
                i_current_count    => l_processed_count
              , i_excepted_count   => 0
            );

            exit when l_match_cur%notfound;
        end loop;
        close l_match_cur;
        trc_log_pkg.info(
            i_text         => 'Match condition type [#1], Matched messages [#2]'
          , i_env_param1   => condition_rec.condition_type
          , i_env_param2   => l_processed_count
        );
        commit;
    end loop;

    l_rejected_count := greatest(l_estimated_count - l_processed_count, 0);

    prc_api_stat_pkg.log_end(
        i_processed_total  => l_processed_count
      , i_rejected_total   => l_rejected_count
      , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.info(
        i_text             => 'Service provider reconciliation process finished. Matched messages [#1], Mismatched messages [#2]'
      , i_env_param1       => l_processed_count
      , i_env_param2       => l_rejected_count
    );

exception
    when others then
        rollback to savepoint srvp_processing_matching_start;

        if l_match_cur%isopen then
            close l_match_cur;
        end if;
        if l_match_conditions%isopen then
            close l_match_conditions;
        end if;

        prc_api_stat_pkg.log_end (
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error (
                i_error         => 'UNHANDLED_EXCEPTION'
                , i_env_param1  => sqlerrm
            );
        end if;

end process_srvp;

procedure process_srvp_mark_expired(
    i_inst_id                   in      com_api_type_pkg.t_inst_id
) is
    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_srvp_mark_expired: ';
    l_match_depth               com_api_type_pkg.t_long_id;
    l_match_depth_date          date;
    l_processed_count           com_api_type_pkg.t_long_id := 0;
begin
    savepoint processing_srvp_mark_expired;

    prc_api_stat_pkg.log_start;

    trc_log_pkg.debug (
        i_text      => LOG_PREFIX || 'Processing mark expired Service provider reconciliation messages started ...'
    );

    l_match_depth := nvl(set_ui_value_pkg.get_inst_param_n(i_param_name => 'SRVP_RECONCILIATION_EXPIRED_PERIOD', i_inst_id  => i_inst_id ), rcn_api_const_pkg.DEFAULT_EXPIRED_PERIOD);
    l_match_depth_date := com_api_sttl_day_pkg.get_sysdate() - l_match_depth;

    trc_log_pkg.debug (
        i_text      => 'Match depth [' || l_match_depth || ']'
    );

    update rcn_srvp_msg m
       set m.recon_status = rcn_api_const_pkg.RECON_STATUS_EXPIRED
         , m.recon_date   = l_match_depth_date
     where m.recon_status = rcn_api_const_pkg.RECON_STATUS_REQ_RECON
       and m.msg_date    <= l_match_depth_date;

    l_processed_count := sql%rowcount;

    trc_log_pkg.debug (
        i_text          => 'Saving #1 messages matching statuses'
        , i_env_param1  => l_processed_count
    );

    prc_api_stat_pkg.log_estimation (
        i_estimated_count => l_processed_count
    );

    prc_api_stat_pkg.log_end(
        i_excepted_total     => 0
        , i_processed_total  => l_processed_count
        , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug(
        i_text      => LOG_PREFIX || 'Processing mark expired Service provider reconciliation messages finished ...'
    );
exception
    when others then
        rollback to savepoint processing_srvp_mark_expired;

        prc_api_stat_pkg.log_end (
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;
end process_srvp_mark_expired;

end rcn_api_reconciliation_pkg;
/
