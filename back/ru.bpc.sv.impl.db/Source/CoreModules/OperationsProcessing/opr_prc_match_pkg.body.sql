create or replace package body opr_prc_match_pkg is

    procedure incremental_matching(
        i_oper_id       in  com_api_type_pkg.t_long_id
      , i_auth_id       in  com_api_type_pkg.t_long_id
      , i_is_matched    in  com_api_type_pkg.t_boolean
    )
    is
        l_total_amount      com_api_type_pkg.t_money;
        l_match_status      com_api_type_pkg.t_dict_value;
        l_match_id          com_api_type_pkg.t_long_id;
        l_external_auth_id  com_api_type_pkg.t_attr_name;
    begin

        trc_log_pkg.debug(
            i_text          => 'opr_prc_match_pkg.incremental_matching [#1] [#2] [#3]'
          , i_env_param1    => i_oper_id
          , i_env_param2    => i_auth_id
          , i_env_param3    => i_is_matched
        );

        if i_is_matched = com_api_type_pkg.TRUE then

            select o.total_amount
                 , o.match_status
                 , o.match_id
                 , a.external_auth_id
              into l_total_amount
                 , l_match_status
                 , l_match_id
                 , l_external_auth_id
              from opr_operation o
                 , aut_auth a
             where o.id    = i_auth_id
               and a.id(+) = o.id;

            if l_total_amount is not null then

                update opr_operation o
                   set o.match_id     = l_match_id
                     , o.match_status = l_match_status
                 where o.id in (
                                   select a.id
                                     from aut_auth a
                                    where a.trace_number   = l_external_auth_id
                                      and a.is_incremental = com_api_type_pkg.TRUE
                                      and a.id not in (i_auth_id, i_oper_id)
                               );

            end if;
        end if;

    end incremental_matching;

    procedure insert_match_data (
        i_inst_id                in com_api_type_pkg.t_inst_id
      , i_depth_presentment      in com_api_type_pkg.t_tiny_id default null
      , i_depth_authorization    in com_api_type_pkg.t_tiny_id default null
    ) is
        DEFAULT_DEPTH      constant pls_integer := 40;

        l_estimated_count           com_api_type_pkg.t_long_id := 0;
        l_auth_count                com_api_type_pkg.t_long_id := 0;

        l_depth_presentment         com_api_type_pkg.t_tiny_id := nvl(i_depth_presentment,   DEFAULT_DEPTH);
        l_depth_authorization       com_api_type_pkg.t_tiny_id := nvl(i_depth_authorization, DEFAULT_DEPTH);

        l_min_presentment_id        com_api_type_pkg.t_long_id;
        l_min_authorization_id      com_api_type_pkg.t_long_id;
    begin
        prc_api_stat_pkg.log_start;

        trc_log_pkg.info(
            i_text       => 'Step 1: init variables'
        );

        l_min_presentment_id   := com_api_id_pkg.get_from_id(sysdate - l_depth_presentment);
        l_min_authorization_id := com_api_id_pkg.get_from_id(sysdate - l_depth_authorization);

        trc_log_pkg.info(
            i_text       => 'Step 2: truncate table opr_match_oper'
        );

        execute immediate 'truncate table opr_match_oper';

        trc_log_pkg.info(
            i_text       => 'Step 3: truncate table opr_match_auth'
        );

        execute immediate 'truncate table opr_match_auth';

        trc_log_pkg.info(
            i_text       => 'Step 4: insert into opr_match_oper'
        );

        -- Table "opr_match_oper" can not contain any indexes for best performance
        insert into opr_match_oper (
            id
          , row_id
          , is_reversal
          , oper_type
          , msg_type
          , status
          , acq_inst_bin
          , forw_inst_bin
          , merchant_number
          , terminal_number
          , mcc
          , originator_refnum
          , oper_amount
          , oper_currency
          , oper_date
          , clearing_sequence_num
          , clearing_sequence_count
          , sttl_date
          , total_amount
          , split_hash
          , auth_code
          , card_id
          , is_credit_operation
        )
        select/*+ ordered use_nl(op, p) index(op opr_operation_match_ndx) index(p opr_participant_pk) */
               op.id
             , op.rowid as row_id
             , op.is_reversal
             , op.oper_type
             , op.msg_type
             , op.status
             , op.acq_inst_bin
             , op.forw_inst_bin
             , op.merchant_number
             , op.terminal_number
             , op.mcc
             , op.originator_refnum
             , op.oper_amount
             , op.oper_currency
             , op.oper_date
             , op.clearing_sequence_count
             , op.clearing_sequence_num
             , op.sttl_date
             , op.total_amount
             , p.split_hash
             , p.auth_code
             , p.card_id
             , opr_api_operation_pkg.is_credit_operation(op.oper_type)
          from opr_operation op
             , opr_participant p
         where decode(op.match_status, 'MTST0200', op.match_status, 'MTST0600', op.match_status, null) in ('MTST0200', 'MTST0600')
           and p.oper_id            = op.id
           and p.participant_type   = com_api_const_pkg.PARTICIPANT_ISSUER
           and p.inst_id            = i_inst_id
           and op.id+0             >= l_min_presentment_id  -- do not use index by ID
           and op.msg_type         in (opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
                                     , opr_api_const_pkg.MESSAGE_TYPE_PARTIAL_AMOUNT
                                     , opr_api_const_pkg.MESSAGE_TYPE_PART_AMOUNT_COMPL)
           and p.client_id_type     = opr_api_const_pkg.CLIENT_ID_TYPE_CARD;

        -- determining the approximate number of presentments for matching
        l_estimated_count := sql%rowcount;

        prc_api_stat_pkg.log_estimation (
            i_estimated_count => l_estimated_count
        );

        trc_log_pkg.info(
            i_text       => 'Step 5: presentment estimated count [#1]'
          , i_env_param1 => l_estimated_count
        );

        -- Save "opr_match_oper" records
        commit;

        trc_log_pkg.info(
            i_text       => 'Step 6: insert into opr_match_auth'
        );

        -- Table "opr_match_auth" can not contain any indexes for best performance
        insert into opr_match_auth (
            id
          , row_id
          , is_reversal
          , oper_type
          , msg_type
          , status
          , acq_inst_bin
          , forw_inst_bin
          , merchant_number
          , terminal_number
          , mcc
          , originator_refnum
          , oper_amount
          , oper_currency
          , oper_date
          , clearing_sequence_num
          , clearing_sequence_count
          , sttl_date
          , total_amount
          , split_hash
          , auth_code
          , card_id
          , is_credit_operation
        )
        select/*+ ordered use_nl(op, p) index(op opr_operation_match_ndx) index(p opr_participant_pk) */
               op.id
             , op.rowid as row_id
             , op.is_reversal
             , op.oper_type
             , op.msg_type
             , op.status
             , op.acq_inst_bin
             , op.forw_inst_bin
             , op.merchant_number
             , op.terminal_number
             , op.mcc
             , op.originator_refnum
             , op.oper_amount
             , op.oper_currency
             , op.oper_date
             , op.clearing_sequence_count
             , op.clearing_sequence_num
             , op.sttl_date
             , op.total_amount
             , p.split_hash
             , p.auth_code
             , p.card_id
             , opr_api_operation_pkg.is_credit_operation(op.oper_type)
          from opr_operation op
             , opr_participant p
         where decode(op.match_status, 'MTST0200', op.match_status, 'MTST0600', op.match_status, null) in ('MTST0200', 'MTST0600')
           and p.oper_id            = op.id
           and p.participant_type   = com_api_const_pkg.PARTICIPANT_ISSUER
           and p.inst_id            = i_inst_id
           and op.id+0             >= l_min_authorization_id  -- do not use index by ID
           and op.msg_type         in (opr_api_const_pkg.MESSAGE_TYPE_AUTHORIZATION
                                     , opr_api_const_pkg.MESSAGE_TYPE_PREAUTHORIZATION
                                     , opr_api_const_pkg.MESSAGE_TYPE_COMPLETION)
           and p.client_id_type     = opr_api_const_pkg.CLIENT_ID_TYPE_CARD;

        -- determining the approximate number of authorizations for matching
        l_auth_count := sql%rowcount;

        trc_log_pkg.info(
            i_text       => 'Step 7: authorization count [#1]'
          , i_env_param1 => l_auth_count
        );

        -- Save "opr_match_auth" records
        commit;

        prc_api_stat_pkg.log_end (
            i_processed_total  => l_estimated_count
          , i_rejected_total   => null
          , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        );

    exception
        when others then

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
            end if;

    end insert_match_data;

    procedure process_match (
        i_inst_id                in com_api_type_pkg.t_inst_id
    ) is
        BULK_LIMIT         constant pls_integer := 400;
        l_match_cur                 sys_refcursor;

        l_oper_id                   com_api_type_pkg.t_number_tab;
        l_auth_id                   com_api_type_pkg.t_number_tab;
        l_oper_rowid                com_api_type_pkg.t_rowid_tab;
        l_auth_rowid                com_api_type_pkg.t_rowid_tab;
        l_oper_num                  com_api_type_pkg.t_number_tab;
        l_oper_count                com_api_type_pkg.t_number_tab;
        l_total_amount              com_api_type_pkg.t_number_tab;
        l_msg_type                  com_api_type_pkg.t_dict_tab;

        l_last_matched_oper         com_api_type_pkg.t_long_id;

        l_estimated_count           com_api_type_pkg.t_long_id := 0;
        l_rejected_count            com_api_type_pkg.t_long_id := 0;
        l_processed_count           com_api_type_pkg.t_long_id := 0;
        l_rowcount                  com_api_type_pkg.t_long_id;

        l_is_matched                com_api_type_pkg.t_boolean;

        l_match_restriction         com_api_type_pkg.t_dict_value;
        l_oper_auth_condition       com_api_type_pkg.t_text;

        l_thread_number             com_api_type_pkg.t_tiny_id;
        l_ref_source                com_api_type_pkg.t_sql_statement;

        cursor l_match_conditions (
            i_inst_id              com_api_type_pkg.t_inst_id
        ) is
            select level_id
                 , priority
                 , max(condition) condition
              from (
                  select t.rn
                       , t.level_id
                       , t.priority
                       , replace(sys_connect_by_path('(' || t.condition || ')', '__and_'), '__and_', ' and ') as condition
                    from (
                        select row_number() over (partition by level_id order by priority) rn
                             , level_id
                             , condition
                             , priority
                          from (
                              select l.id as level_id
                                   , c.condition
                                   , l.priority
                                from opr_match_level l
                                   , opr_match_level_condition lc
                                   , opr_match_condition c
                               where lc.level_id = l.id
                                 and c.id = lc.condition_id
                                 and (
                                     l.inst_id = i_inst_id
                                     or l.inst_id = ost_api_const_pkg.DEFAULT_INST
                                 )
                          )
                    ) t
                    start with t.rn = 1
                    connect by prior t.level_id = t.level_id
                           and prior t.rn + 1   = t.rn
              )
              group by priority
                     , level_id
              order by priority
                     , level_id;

        procedure open_match_cur is
            l_condition_part            com_api_type_pkg.t_sql_statement;
        begin
            for i in 1 .. 10 loop
                l_condition_part := substr(l_ref_source, 3900 * (i - 1) + 1, 3900);

                if l_condition_part is not null then
                    trc_log_pkg.debug(
                        i_text => 'Matching cursor (part ' || i || '): ' || l_condition_part
                    );
                end if;
            end loop;

            trc_log_pkg.debug(
                i_text        => 'Matching cursor length: [#1]'
              , i_env_param1  => length(l_ref_source)
            );

            if l_thread_number != prc_api_const_pkg.DEFAULT_THREAD then
                open l_match_cur for l_ref_source using l_thread_number;
            else
                open l_match_cur for l_ref_source;
            end if;

        end open_match_cur;
    begin
        trc_log_pkg.debug(
            i_text       => 'PROCESS_MATCH start: i_inst_id [#1]'
          , i_env_param1 => i_inst_id
        );

        prc_api_stat_pkg.log_start;

        l_match_restriction := set_ui_value_pkg.get_inst_param_v(
                                   i_param_name => 'MATCH_RESTRICTION'
                                 , i_inst_id    => i_inst_id
                               );

        trc_log_pkg.debug(
            i_text       => 'PROCESS_MATCH: l_match_restriction [#1]'
          , i_env_param1 => l_match_restriction
        );

        if l_match_restriction = opr_api_const_pkg.OPER_MATCHING_AFTER then
            l_oper_auth_condition := ' and (oper.id + 0) > (auth.id + 0) ';   -- no index
        else
            l_oper_auth_condition := ' and trunc(oper.id / 10000000000) >= trunc(auth.id / 10000000000) ';
        end if;

        trc_log_pkg.info(
            i_text       => 'Step 1: init variables'
        );

        l_thread_number := prc_api_session_pkg.get_thread_number;

        if l_thread_number = prc_api_const_pkg.DEFAULT_THREAD then
            select count(*)
              into l_estimated_count
              from opr_match_oper;
        else
            select count(*)
              into l_estimated_count
              from opr_match_oper
             where split_hash in (select split_hash from com_split_map where thread_number = l_thread_number);
        end if;

        prc_api_stat_pkg.log_estimation (
            i_estimated_count => l_estimated_count
        );

        trc_log_pkg.info(
            i_text       => 'Step 2: presentment estimated count [#1]'
          , i_env_param1 => l_estimated_count
        );

        l_ref_source :=
           'select oper_id'
        ||      ', auth_id'
        ||      ', oper_rowid'
        ||      ', auth_rowid'
        ||      ', seq_count'
        ||      ', seq_num'
        ||      ', total_amount'
        ||      ', msg_type'
        ||  ' from ('
        || 'select/*+ ordered use_hash(oper, auth) full(oper) full(auth) */'
        ||       ' oper.id as oper_id'
        ||      ', auth.id as auth_id'
        ||      ', auth.status as auth_status'
        ||      ', oper.row_id as oper_rowid'
        ||      ', auth.row_id as auth_rowid'
        ||      ', oper.clearing_sequence_count as seq_count'
        ||      ', oper.clearing_sequence_num as seq_num'
        ||      ', auth.total_amount'
        ||      ', oper.msg_type';

        trc_log_pkg.info(
            i_text       => 'Step 3: get match conditions'
        );

        l_ref_source := l_ref_source      || ' , (case ';

        for condition_rec in l_match_conditions(i_inst_id) loop

            trc_log_pkg.info (
                i_text => 'Match level [' || condition_rec.level_id || '] ' ||
                          'priority ['    || condition_rec.priority || '] ' ||
                          'condition ['   || substr(condition_rec.condition, 1, 1900) || ']'
            );

            l_ref_source := l_ref_source  || ' when ' || trim(substr(trim(condition_rec.condition), 4)) || ' then ' || condition_rec.priority;

        end loop;

        l_ref_source := l_ref_source      || ' else 0 end) as match_level ';

        l_ref_source := l_ref_source
        ||  ' from opr_match_oper oper'
        ||      ', opr_match_auth auth'
        || ' where auth.card_id = oper.card_id'
        ||   ' and auth.split_hash = oper.split_hash'
        ||   ' and auth.is_reversal = oper.is_reversal'
        ||   l_oper_auth_condition;

        if l_thread_number != prc_api_const_pkg.DEFAULT_THREAD then
            l_ref_source := l_ref_source
                         || ' and split_hash in (select split_hash from com_split_map where thread_number = :thread_number)';
        end if;

        l_ref_source := l_ref_source
        || ' ) where match_level > 0'
        || ' order by oper_id'
        ||        ' , match_level'
        ||        ' , case auth_status when ''' || opr_api_const_pkg.OPERATION_STATUS_AWAITS_UNHOLD || ''' then 0 else 1 end'
        ||        ' , auth_id';

        begin
            savepoint processing_matching_start;

            l_last_matched_oper := null;

            trc_log_pkg.info(
                i_text      => 'Step 4: open matching cursor'
            );

            open_match_cur;

            trc_log_pkg.info(
                i_text      => 'Step 5: matching cycle'
            );

            loop
                fetch l_match_cur
                  bulk collect into l_oper_id, l_auth_id, l_oper_rowid, l_auth_rowid, l_oper_count, l_oper_num, l_total_amount, l_msg_type
                  limit BULK_LIMIT;

                for i in 1..l_oper_rowid.count loop

                    if l_last_matched_oper is null or l_last_matched_oper != l_oper_id(i) then

                        trc_log_pkg.set_object(
                            i_entity_type  => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                          , i_object_id    => l_oper_id(i)
                        );

                        update opr_operation oper
                           set oper.match_status = case when (nvl(l_oper_count(i), 0) > nvl(l_oper_num(i), 0)
                                                              and rowid   != l_oper_rowid(i))
                                                          or l_msg_type(i) = opr_api_const_pkg.MESSAGE_TYPE_PARTIAL_AMOUNT
                                                        then opr_api_const_pkg.OPERATION_MATCH_PARTIAL_MATCHE
                                                        else opr_api_const_pkg.OPERATION_MATCH_MATCHED
                                                   end
                             , oper.match_id     = case when nvl(l_oper_count(i), 0) > nvl(l_oper_num(i), 0)
                                                             and rowid != l_oper_rowid(i)
                                                        then oper.match_id
                                                        when rowid      = l_oper_rowid(i)
                                                        then l_auth_id(i)
                                                        else l_oper_id(i)
                                                   end
                         where rowid in (
                                   select rowid
                                     from (
                                         select rowid
                                              , count(*) over() cnt
                                           from opr_operation
                                          where rowid in (l_auth_rowid(i), l_oper_rowid(i))
                                            and (
                                                    (match_status = opr_api_const_pkg.OPERATION_MATCH_REQ_MATCH and match_id is null)
                                                     or
                                                     match_status = opr_api_const_pkg.OPERATION_MATCH_PARTIAL_MATCHE
                                            )
                                     )
                                    where cnt = 2
                         );

                        l_rowcount := sql%rowcount;

                        if l_rowcount > 0 then
                            l_is_matched        := com_api_type_pkg.TRUE;
                            l_last_matched_oper := l_oper_id(i);
                            l_processed_count   := l_processed_count + 1;

                            trc_log_pkg.debug (
                                i_text          => 'Matched: oper_id[#1] auth_id[#2]'
                              , i_env_param1    => l_oper_id(i)
                              , i_env_param2    => l_auth_id(i)
                            );

                        else
                            l_is_matched        := com_api_type_pkg.FALSE;

                            trc_log_pkg.warn(
                                i_text          => 'OPERATION_IS_NOT_MATCHED'
                              , i_env_param1    => l_oper_id(i)
                            ); 

                        end if;

                        if l_total_amount(i) is not null then
                            incremental_matching(
                                i_oper_id           => l_oper_id(i)
                              , i_auth_id           => l_auth_id(i)
                              , i_is_matched        => l_is_matched
                            );
                        end if;

                        -- User exit opr_cst_match_pkg
                        opr_cst_match_pkg.after_matching(
                            i_oper_id           => l_oper_id(i)
                          , i_auth_id           => l_auth_id(i)
                          , i_is_matched        => l_is_matched
                        );

                        trc_log_pkg.clear_object;
                    end if;

                end loop;

                prc_api_stat_pkg.log_current (
                    i_current_count    => l_processed_count
                  , i_excepted_count   => 0
                );

                exit when l_match_cur%notfound;
            end loop;
            close l_match_cur;

            trc_log_pkg.info(
                i_text       => 'Step 6: Matched operations [#1]'
              , i_env_param1 => l_processed_count
            );

            commit;
        exception
            when others then
                rollback to savepoint processing_matching_start;

                trc_log_pkg.clear_object;

                if l_match_cur%isopen then
                    close l_match_cur;
                end if;

                if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
                    raise;
                elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
                    com_api_error_pkg.raise_fatal_error (
                        i_error       => 'UNHANDLED_EXCEPTION'
                      , i_env_param1  => sqlerrm
                    );
                end if;
        end;

        l_rejected_count := greatest(l_estimated_count - l_processed_count, 0);

        prc_api_stat_pkg.log_end (
            i_processed_total  => l_processed_count
          , i_rejected_total   => l_rejected_count
          , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        );

        trc_log_pkg.info (
            i_text             => 'Match processing finished. Matched operations [#1], Mismatched operations [#2]'
          , i_env_param1       => l_processed_count
          , i_env_param2       => l_rejected_count
        );

    exception
        when others then

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
            end if;

    end process_match;

    procedure process_match_obsolete (
        i_inst_id               in com_api_type_pkg.t_inst_id
      , i_depth_presentment     in com_api_type_pkg.t_tiny_id default null
      , i_depth_authorization   in com_api_type_pkg.t_tiny_id default null
    ) is
        BULK_LIMIT         constant pls_integer := 400;
        l_match_cur                 sys_refcursor;

        l_oper_id                   com_api_type_pkg.t_number_tab;
        l_auth_id                   com_api_type_pkg.t_number_tab;
        l_oper_rowid                com_api_type_pkg.t_rowid_tab;
        l_auth_rowid                com_api_type_pkg.t_rowid_tab;
        l_oper_num                  com_api_type_pkg.t_number_tab;
        l_oper_count                com_api_type_pkg.t_number_tab;
        l_total_amount              com_api_type_pkg.t_number_tab;
        l_msg_type                  com_api_type_pkg.t_dict_tab;

        l_last_matched_oper         com_api_type_pkg.t_long_id;

        l_estimated_count           com_api_type_pkg.t_long_id := 0;
        l_rejected_count            com_api_type_pkg.t_long_id := 0;
        l_processed_count           com_api_type_pkg.t_long_id := 0;
        l_rowcount                  com_api_type_pkg.t_long_id;

        l_is_matched                com_api_type_pkg.t_boolean;
        l_depth_presentment_id      com_api_type_pkg.t_long_id;
        l_depth_authorization_id    com_api_type_pkg.t_long_id;

        l_param_source              com_api_type_pkg.t_text :=
            ', ('||
                'select :p_inst_id p_inst_id '||
                  'from dual '||
               ') x ';

        l_column_list               com_api_type_pkg.t_text :=
            'select '||
                --'/*+ INDEX ( oper OPR_OPERATION_MTST0200_NDX ) INDEX( auth OPR_OPERATION_MTST0200_NDX )*/ '||
                '/*+ ORDERED(oper, auth, p_oper, p_auth)*/ '||
                'oper.id'||
                ', auth.id'||
                ', oper.row_id oper_rowid'||
                ', auth.row_id auth_rowid'||
                ', oper.seq_count'||
                ', oper.seq_num' ||
                ', auth.total_amount'||
                ', oper.msg_type ' ;

        l_ref_source                com_api_type_pkg.t_text;

        l_estimated_source          com_api_type_pkg.t_text;

        cursor l_match_conditions (
            i_inst_id              com_api_type_pkg.t_inst_id
        ) is
            select level_id
                 , priority
                 , max(condition) condition
              from (
                  select t.rn
                       , t.level_id
                       , t.priority
                       , replace(sys_connect_by_path('(' || t.condition || ')', '__and_'), '__and_', ' and ') as condition
                    from (
                        select row_number() over (partition by level_id order by priority) rn
                             , level_id
                             , condition
                             , priority
                          from (
                              select l.id as level_id
                                   , c.condition
                                   , l.priority
                                from opr_match_level l
                                   , opr_match_level_condition lc
                                   , opr_match_condition c
                               where lc.level_id = l.id
                                 and c.id = lc.condition_id
                                 and (
                                     l.inst_id = i_inst_id
                                     or l.inst_id = ost_api_const_pkg.DEFAULT_INST
                                 )
                          )
                    ) t
                    start with t.rn = 1
                    connect by prior t.level_id = t.level_id
                           and prior t.rn + 1   = t.rn
              )
              group by priority
                     , level_id
              order by priority
                     , level_id;

        procedure open_match_cur (
            i_condition     in com_api_type_pkg.t_text
        ) is
            l_match_cur_stmt   com_api_type_pkg.t_lob_data;
        begin
            l_match_cur_stmt :=
                l_column_list || l_ref_source
                || i_condition
                || ' order by oper.id,'
                || ' case auth.status when '''||opr_api_const_pkg.OPERATION_STATUS_AWAITS_UNHOLD||''' then 0 else 1 end,'
                || ' auth.id';

            open l_match_cur for l_match_cur_stmt using i_inst_id, i_inst_id;
        exception
            when others then
                trc_log_pkg.debug(
                    i_text => 'Exception on opening a matching cursor l_match_cur_stmt: '
                           || chr(13) || chr(10) || substr(l_match_cur_stmt, 1, 3900)
                );
                raise;
        end;
    begin
        prc_api_stat_pkg.log_start;

        l_depth_presentment_id   := com_api_id_pkg.get_from_id(sysdate - i_depth_presentment);
        l_depth_authorization_id := com_api_id_pkg.get_from_id(sysdate - i_depth_authorization);

        l_ref_source :=
            'from '||
                '( '||
                  'select /*+ index(ioper, opr_operation_match_ndx) index(ip_oper, opr_participant_pk) */ '||
                         'ioper.rowid row_id'||
                       ', ioper.id'||
                       ', ip_oper.card_id'||
                       ', ip_oper.account_id'||
                       ', ip_oper.client_id_type'||
                       ', ip_oper.split_hash'||
                       ', ioper.oper_date'||
                       ', ioper.sttl_date'||
                       ', ip_oper.auth_code'||
                       ', ioper.is_reversal'||
                       ', ioper.originator_refnum'||
                       ', ioper.acq_inst_bin'||
                       ', ioper.forw_inst_bin'||
                       ', ioper.merchant_number'||
                       ', ioper.terminal_number'||
                       ', ioper.oper_type'||
                       ', ioper.oper_amount'||
                       ', ioper.oper_currency'||
                       ', ioper.mcc'||
                       ', ioper.clearing_sequence_count seq_count'||
                       ', ioper.clearing_sequence_num seq_num'||
                       ', ioper.total_amount'||
                       ', rownum  rnm'|| -- needed to make predefined view (do not remove!)
                       ', opr_api_operation_pkg.is_credit_operation(ioper.oper_type) is_credit_operation' ||
                       ', ioper.msg_type ' ||
                    'from opr_operation ioper'||
                       ', opr_participant ip_oper'||
                       ', (select :p_inst_id p_inst_id from dual) x '||
                   'where ioper.id = ip_oper.oper_id ';

        if i_depth_presentment is not null then
            l_ref_source := l_ref_source ||
                     'and ioper.id > ' || to_char(l_depth_presentment_id) || ' ';
        end if;

        l_ref_source := l_ref_source ||
                     'and ip_oper.participant_type = ''' || com_api_const_pkg.PARTICIPANT_ISSUER || ''' '||
                     'and ip_oper.inst_id = x.p_inst_id '||
                     'and ip_oper.split_hash in (select split_hash from com_api_split_map_vw) '||
                     'and ioper.msg_type in (''' || opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT       || ''', '''
                                                 || opr_api_const_pkg.MESSAGE_TYPE_PARTIAL_AMOUNT    || ''', '''
                                                 || opr_api_const_pkg.MESSAGE_TYPE_PART_AMOUNT_COMPL || ''') '||
                     'and decode(ioper.match_status, ''' || opr_api_const_pkg.OPERATION_MATCH_REQ_MATCH
                         || ''', ioper.match_status, ''' || opr_api_const_pkg.OPERATION_MATCH_PARTIAL_MATCHE
                         || ''', ioper.match_status, null) in (''' || opr_api_const_pkg.OPERATION_MATCH_REQ_MATCH
                                                        || ''',''' || opr_api_const_pkg.OPERATION_MATCH_PARTIAL_MATCHE || ''') '||
                ') oper '||
              ', ( '||
                  'select /*+ index(iauth, opr_operation_match_ndx)  index(ip_auth, opr_participant_pk) */ '||
                         'iauth.rowid row_id'||
                       ', iauth.id'||
                       ', ip_auth.card_id'||
                       ', ip_auth.account_id'||
                       ', ip_auth.client_id_type'||
                       ', ip_auth.split_hash'||
                       ', iauth.oper_date'||
                       ', ip_auth.auth_code'||
                       ', iauth.is_reversal'||
                       ', iauth.originator_refnum'||
                       ', iauth.acq_inst_bin'||
                       ', iauth.forw_inst_bin'||
                       ', iauth.merchant_number'||
                       ', iauth.terminal_number'||
                       ', iauth.oper_type'||
                       ', iauth.oper_amount'||
                       ', iauth.oper_currency'||
                       ', iauth.mcc'||
                       ', iauth.status'||
                       ', iauth.total_amount'||
                       ', opr_api_operation_pkg.is_credit_operation(iauth.oper_type) is_credit_operation' ||
                       ', rownum rnm '|| -- needed to make predefined view (do not remove!)
                    'from opr_operation iauth '||
                       ', opr_participant ip_auth '||
                       ', (select :p_inst_id p_inst_id from dual) x '||
                   'where iauth.id = ip_auth.oper_id ';

        if i_depth_authorization is not null then
            l_ref_source := l_ref_source ||
                     'and iauth.id > ' || to_char(l_depth_authorization_id) || ' ';
        end if;

        l_ref_source := l_ref_source ||
                     'and ip_auth.participant_type = ''' || com_api_const_pkg.PARTICIPANT_ISSUER || ''' '||
                     'and ip_auth.inst_id = x.p_inst_id '||
                     'and ip_auth.split_hash in (select split_hash from com_api_split_map_vw) '||
                     'and iauth.msg_type in (''' || opr_api_const_pkg.MESSAGE_TYPE_AUTHORIZATION    || ''', '''
                                                 || opr_api_const_pkg.MESSAGE_TYPE_PREAUTHORIZATION || ''', '''
                                                 || opr_api_const_pkg.MESSAGE_TYPE_COMPLETION       || ''') '||
                     'and decode(iauth.match_status, ''' || opr_api_const_pkg.OPERATION_MATCH_REQ_MATCH
                         || ''', iauth.match_status, ''' || opr_api_const_pkg.OPERATION_MATCH_PARTIAL_MATCHE
                         || ''', iauth.match_status, null) in (''' || opr_api_const_pkg.OPERATION_MATCH_REQ_MATCH
                                                        || ''',''' || opr_api_const_pkg.OPERATION_MATCH_PARTIAL_MATCHE || ''') '||
                ') auth '||
            'where ((oper.client_id_type = ''' || opr_api_const_pkg.CLIENT_ID_TYPE_CARD || ''' and auth.client_id_type = ''' || opr_api_const_pkg.CLIENT_ID_TYPE_CARD
                     || ''' and oper.card_id = auth.card_id)   '||
                'or (oper.client_id_type = ''' || opr_api_const_pkg.CLIENT_ID_TYPE_ACCOUNT || ''' and auth.client_id_type = ''' || opr_api_const_pkg.CLIENT_ID_TYPE_ACCOUNT
                     || ''' and oper.account_id = auth.account_id))'||
              'and oper.split_hash = auth.split_hash '||
              'and (oper.id + 0) > (auth.id + 0) '||  -- no index
              'and oper.is_reversal = auth.is_reversal ';

        l_estimated_source :=
            'select /*+ index(oper, opr_operation_match_ndx) index(p_oper, opr_participant_pk) */ '||
                 'count(1) ' ||
            'from' ||
                 ' opr_operation oper' ||
                 ', opr_participant p_oper ' ||
                 l_param_source ||
            'where '||
                 'oper.id = p_oper.oper_id ';

        if i_depth_presentment is not null then
            l_estimated_source := l_estimated_source ||
                     'and oper.id > com_api_id_pkg.get_from_id(sysdate - ' || to_char(i_depth_presentment) || ') ';
        end if;

        l_estimated_source := l_estimated_source ||
                 'and p_oper.participant_type = ''' || com_api_const_pkg.PARTICIPANT_ISSUER || ''' '||
                 'and p_oper.inst_id = x.p_inst_id '||
                 'and p_oper.split_hash in (select split_hash from com_api_split_map_vw) '||
                 'and oper.msg_type in (''' || opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT       || ''', '''
                                            || opr_api_const_pkg.MESSAGE_TYPE_PARTIAL_AMOUNT    || ''', '''
                                            || opr_api_const_pkg.MESSAGE_TYPE_PART_AMOUNT_COMPL || ''') '||
                 'and decode(oper.match_status, ''' || opr_api_const_pkg.OPERATION_MATCH_REQ_MATCH
                     || ''', oper.match_status, ''' || opr_api_const_pkg.OPERATION_MATCH_PARTIAL_MATCHE
                     || ''', oper.match_status, null) in (''' || opr_api_const_pkg.OPERATION_MATCH_REQ_MATCH
                                                   || ''',''' || opr_api_const_pkg.OPERATION_MATCH_PARTIAL_MATCHE || ''') ';
        
        -- determining the approximate number of operations for matching
        execute immediate l_estimated_source into l_estimated_count using i_inst_id;

        prc_api_stat_pkg.log_estimation (
            i_estimated_count => l_estimated_count
        );

        trc_log_pkg.info (
            i_text      => 'Match processing starting for inst_id ' || i_inst_id
        );
        
        for condition_rec in l_match_conditions(i_inst_id) loop

            begin
                savepoint processing_matching_start;

                l_last_matched_oper := null;

                trc_log_pkg.info (
                    i_text => 'Match level [' || condition_rec.level_id || '] ' ||
                              'priority [' || condition_rec.priority || '] ' ||
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
                     bulk collect into l_oper_id, l_auth_id, l_oper_rowid, l_auth_rowid, l_oper_count, l_oper_num, l_total_amount, l_msg_type
                    limit BULK_LIMIT;

                    for i in 1..l_oper_rowid.count loop

                        if l_last_matched_oper is null or l_last_matched_oper != l_oper_id(i) then

                            update opr_operation oper
                               set oper.match_status = case when (nvl(l_oper_count(i), 0) > nvl(l_oper_num(i), 0)
                                                                  and rowid   != l_oper_rowid(i))
                                                              or l_msg_type(i) = opr_api_const_pkg.MESSAGE_TYPE_PARTIAL_AMOUNT
                                                            then opr_api_const_pkg.OPERATION_MATCH_PARTIAL_MATCHE
                                                            else opr_api_const_pkg.OPERATION_MATCH_MATCHED
                                                       end
                                 , oper.match_id     = case when nvl(l_oper_count(i), 0) > nvl(l_oper_num(i), 0)
                                                                 and rowid != l_oper_rowid(i)
                                                            then oper.match_id
                                                            when rowid      = l_oper_rowid(i)
                                                            then l_auth_id(i)
                                                            else l_oper_id(i)
                                                       end
                             where rowid in (
                                       select rowid
                                         from (
                                             select rowid
                                                  , count(*) over() cnt
                                               from opr_operation
                                              where rowid in (l_auth_rowid(i), l_oper_rowid(i))
                                                and (
                                                        (match_status = opr_api_const_pkg.OPERATION_MATCH_REQ_MATCH and match_id is null)
                                                         or
                                                         match_status = opr_api_const_pkg.OPERATION_MATCH_PARTIAL_MATCHE
                                                )
                                         )
                                        where cnt = 2
                             );

                            l_rowcount := sql%rowcount;

                            if l_rowcount > 0 then
                                l_is_matched        := com_api_type_pkg.TRUE;
                                l_last_matched_oper := l_oper_id(i);
                                l_processed_count   := l_processed_count + 1;

                                trc_log_pkg.debug (
                                    i_text          => 'Matched: oper_id[#1] auth_id[#2]'
                                  , i_env_param1    => l_oper_id(i)
                                  , i_env_param2    => l_auth_id(i)
                                );

                            else
                                l_is_matched        := com_api_type_pkg.FALSE;

                                trc_log_pkg.warn(
                                    i_text          => 'OPERATION_IS_NOT_MATCHED'
                                  , i_env_param1    => l_oper_id(i)
                                ); 

                            end if;

                            if l_total_amount(i) is not null then
                                incremental_matching(
                                    i_oper_id           => l_oper_id(i)
                                  , i_auth_id           => l_auth_id(i)
                                  , i_is_matched        => l_is_matched
                                );
                            end if;

                            -- User exit opr_cst_match_pkg
                            opr_cst_match_pkg.after_matching(
                                i_oper_id           => l_oper_id(i)
                              , i_auth_id           => l_auth_id(i)
                              , i_is_matched        => l_is_matched
                            );
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
                    i_text         => 'Match level [#1], Matched operations [#2]'
                  , i_env_param1   => condition_rec.level_id
                  , i_env_param2   => l_processed_count
                );
                commit;
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
            end;
        end loop;

        l_rejected_count := greatest(l_estimated_count - l_processed_count, 0);

        prc_api_stat_pkg.log_end (
            i_processed_total  => l_processed_count
          , i_rejected_total   => l_rejected_count
          , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        );

        trc_log_pkg.info (
            i_text             => 'Match processing finished. Matched operations [#1], Mismatched operations [#2]'
          , i_env_param1       => l_processed_count
          , i_env_param2       => l_rejected_count
        );

    exception
        when others then
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
    end process_match_obsolete;

    procedure process_mark_expired (
        i_inst_id               in com_api_type_pkg.t_inst_id
    ) is
        l_match_depth               com_api_type_pkg.t_long_id;
        l_match_depth_date          date;
        l_processed_count           com_api_type_pkg.t_long_id := 0;
    begin
        savepoint processing_mark_expired;
        
        prc_api_stat_pkg.log_start;

        trc_log_pkg.debug (
            i_text      => 'Processing mark expired messages started ...'
        );

        -- get match depth value
        l_match_depth := nvl( set_ui_value_pkg.get_inst_param_n ( i_param_name => 'MATCH_DEPTH', i_inst_id  => i_inst_id ), opr_api_const_pkg.DEFAULT_MATCH_DEPTH );

        -- calculate date
        l_match_depth_date := com_api_sttl_day_pkg.get_sysdate() - l_match_depth;

        trc_log_pkg.debug (
            i_text      => 'Match depth [' || l_match_depth || ']'
        );

        -- update operations
        update opr_operation oper
           set oper.match_status = opr_api_const_pkg.OPERATION_MATCH_EXPIRED
         where decode(oper.match_status, 'MTST0200'
                    , oper.match_status, 'MTST0600'
                    , oper.match_status, NULL)      in (opr_api_const_pkg.OPERATION_MATCH_REQ_MATCH
                                                      , opr_api_const_pkg.OPERATION_MATCH_PARTIAL_MATCHE)
           and oper.oper_date <= l_match_depth_date
           and exists (
                   select null
                     from opr_participant p
                    where p.oper_id          = oper.id
                      and p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
                      and p.inst_id          = i_inst_id
                      and p.split_hash      in (select split_hash from com_api_split_map_vw)
               );
        
        l_processed_count := sql%rowcount;
        
        trc_log_pkg.debug (
            i_text            => 'Saving #1 operations matching statuses'
          , i_env_param1      => l_processed_count
        );
        
        prc_api_stat_pkg.log_estimation (
            i_estimated_count => l_processed_count
        );
        
        prc_api_stat_pkg.log_end (
            i_excepted_total  => 0
          , i_processed_total => l_processed_count
          , i_result_code     => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        );

        trc_log_pkg.debug (
            i_text            => 'Processing mark expired messages finished ...'
        );
    exception
        when others then
            rollback to savepoint processing_mark_expired;
            
            prc_api_stat_pkg.log_end (
                i_result_code => prc_api_const_pkg.PROCESS_RESULT_FAILED
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

end opr_prc_match_pkg;
/
