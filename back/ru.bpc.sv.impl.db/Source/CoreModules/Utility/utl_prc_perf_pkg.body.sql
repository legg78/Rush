create or replace package body utl_prc_perf_pkg is
/**********************************************************
 * List of objects for setting up the system performance
 * 
 * Created by Gogolev I.(i.gogolev@bpcbt.com) at 29.08.2016
 * Last changed by Gogolev I.(i.gogolev@bpcbt.com) at 
 * 30.08.2016 15:20:00
 *
 * Module: UTL_PRC_PERF_PKG
 * @headcom
 **********************************************************/

SORTING_CPU_TIME           constant  com_api_type_pkg.t_dict_value := 'TSQLCPU';
SORTING_ELAPSED_TIME       constant  com_api_type_pkg.t_dict_value := 'TSQLELA';
SORTING_DISK_READS         constant  com_api_type_pkg.t_dict_value := 'TSQLDSKR';
SORTING_BUFFER_GETS        constant  com_api_type_pkg.t_dict_value := 'TSQLBUFG';
SORTING_DIRECT_WRITES      constant  com_api_type_pkg.t_dict_value := 'TSQLDWRT';
SORTING_CONCURRENCY_WAIT   constant  com_api_type_pkg.t_dict_value := 'TSQLCONW';
SORTING_PLSQL_EXEC_TIME    constant  com_api_type_pkg.t_dict_value := 'TSQLPLS';

procedure run_gather_stats(
    i_is_stat_mode_def in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
) is
    l_estimated_count       com_api_type_pkg.t_long_id    := 0;
    l_processed_count       com_api_type_pkg.t_long_id    := 0;
    l_excepted_count        com_api_type_pkg.t_long_id    := 0;
    l_rejected_count        com_api_type_pkg.t_long_id    := 0;
begin
    prc_api_stat_pkg.log_start;
        
    trc_log_pkg.debug(
        i_text        => 'Process [#1] is started in MODE: [#2] '
      , i_env_param1  => 'RUN_GATHER_STATS'
      , i_env_param2  => case 
                             when i_is_stat_mode_def = com_api_const_pkg.TRUE
                                 then utl_prc_perf_pkg.GATHER_DEF
                             when i_is_stat_mode_def = com_api_const_pkg.FALSE
                                 then utl_prc_perf_pkg.GATHER_AUTO
                             else 'NULL'
                         end
    );
    
    if i_is_stat_mode_def is null
        or i_is_stat_mode_def not in (com_api_const_pkg.TRUE, com_api_const_pkg.FALSE)
    then
        com_api_error_pkg.raise_error(
            i_error         => 'WRONG_PARAM_VALUE_FORMAT'
          , i_env_param1    => 'I_IS_STAT_MODE_DEF'
          , i_env_param2    => 'BOOLEAN: TRUE/FALSE (NUMBER(1) 0/1))'
          , i_env_param3    => i_is_stat_mode_def
        );
    else
        l_estimated_count := 1;
    end if;
    
    prc_api_stat_pkg.log_estimation(
        i_estimated_count   => l_estimated_count
    );
    
    dbms_stats.gather_schema_stats(
        ownname             => user
      , cascade             => true
      , options             => case 
                                   when i_is_stat_mode_def = com_api_const_pkg.FALSE
                                   then utl_prc_perf_pkg.GATHER_AUTO 
                                   else utl_prc_perf_pkg.GATHER_DEF
                               end
      , estimate_percent    => dbms_stats.AUTO_SAMPLE_SIZE
      , degree              => dbms_stats.AUTO_DEGREE
    );

    l_processed_count := 1;

    trc_log_pkg.debug(
        i_text        => 'Process [#1] is finished success'
      , i_env_param1  => 'RUN_GATHER_STATS'
    );

    prc_api_stat_pkg.log_end(
        i_excepted_total   => l_excepted_count
      , i_processed_total  => l_processed_count
      , i_rejected_total   => l_rejected_count
      , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
    
exception
    when others then
       trc_log_pkg.debug(
            i_text        => 'Process [#1] is finished with error: [#2]'
          , i_env_param1  => 'RUN_GATHER_STATS'
          , i_env_param2  => sqlerrm
        );
        
        l_excepted_count := 1;
        
        prc_api_stat_pkg.log_end(
            i_excepted_total   => l_excepted_count
          , i_processed_total  => l_processed_count
          , i_rejected_total   => l_rejected_count
          , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE
        then
            com_api_error_pkg.raise_fatal_error(
                i_error       => 'UNHANDLED_EXCEPTION'
              , i_env_param1  => sqlerrm
            );
        end if;
         
        raise;
end run_gather_stats;

procedure insert_top_sql(
    i_session_id        in     com_api_type_pkg.t_long_id
  , i_min_snap_id       in     com_api_type_pkg.t_long_id
  , i_max_snap_id       in     com_api_type_pkg.t_long_id
  , i_count             in     com_api_type_pkg.t_count
  , i_sorting_type      in     com_api_type_pkg.t_dict_value
  , i_is_aggregation    in     com_api_type_pkg.t_boolean
) is
begin
    insert into utl_top_sql(
        session_id
      , top_sql_order
      , dbid
      , parsing_schema_id
      , parsing_schema_name
      , min_snap_id
      , snap_min_time
      , max_snap_id
      , snap_max_time
      , sql_id
      , plan_hash_value
      , command_type
      , sql_text

      , parse_calls
      , parse_calls_all

      , executions
      , executions_all

      , fetches
      , fetches_all

      , disk_reads
      , disk_reads_all

      , buffer_gets
      , buffer_gets_all

      , rows_processed

      , cpu_time
      , cpu_time_all

      , plsexec_time
      , plsexec_time_all

      , elapsed_time
      , elapsed_time_all

      , iowait
      , iowait_all

      , apwait
      , apwait_all

      , ccwait
      , ccwait_all

      , direct_writes
      , direct_writes_all

      , sorting_type
      , is_aggregation
    )
    select i_session_id as session_id
         , rownum       as top_sql_order
         , dbid
         , parsing_schema_id
         , parsing_schema_name
         , min_snap_id
         , (
               select sn.begin_interval_time
                 from dba_hist_snapshot sn
                where sn.snap_id = m.min_snap_id
                  and sn.dbid = m.dbid
           ) as snap_min_time
         , max_snap_id
         , (
               select sn.end_interval_time
                 from dba_hist_snapshot sn
                where sn.snap_id = m.max_snap_id
                  and sn.dbid = m.dbid
           ) as snap_max_time
         , sql_id
         , plan_hash_value
         , (
               select t.command_type
                 from dba_hist_sqltext t
                where t.dbid = m.dbid
                  and t.sql_id = m.sql_id

           ) as command_type
         , (
               select t.sql_text
                 from dba_hist_sqltext t
                where t.dbid = m.dbid
                  and t.sql_id = m.sql_id
           ) as sql_text

         , parse_calls
         , parse_calls_all

         , executions
         , executions_all

         , fetches
         , fetches_all

         , disk_reads
         , disk_reads_all

         , buffer_gets
         , buffer_gets_all

         , rows_processed

         , cpu_time / 1000000 as cpu_time
         , cpu_time_all / 1000000 as cpu_time_all

         , plsexec_time / 1000000 as plsexec_time
         , plsexec_time_all / 1000000 as plsexec_time_all

         , elapsed_time / 1000000 as elapsed_time
         , elapsed_time_all / 1000000 as elapsed_time_all

         , iowait / 1000000 as iowait
         , iowait_all / 1000000 as iowait_all

         , apwait / 1000000 as apwait
         , apwait_all / 1000000 as apwait_all

         , ccwait / 1000000 as ccwait
         , ccwait_all / 1000000 as ccwait_all

         , direct_writes / 1000000 as direct_writes
         , direct_writes_all / 1000000 as direct_writes_all

         , i_sorting_type
         , i_is_aggregation
      from (
               select /*+ first_rows */
                      s.dbid
                    , s.parsing_schema_id
                    , s.parsing_schema_name
                    , min(s.snap_id) as min_snap_id
                    , max(s.snap_id) as max_snap_id
                    , s.sql_id
                    , s.plan_hash_value

                    , sum(parse_calls_delta) as parse_calls
                    , sum(sum(parse_calls_delta)) over() as parse_calls_all

                    , sum(executions_delta) as executions
                    , sum(sum(executions_delta)) over() as executions_all

                    , sum(fetches_delta) as fetches
                    , sum(sum(fetches_delta)) over() as fetches_all

                    , sum(disk_reads_delta) as disk_reads
                    , sum(sum(disk_reads_delta)) over() as disk_reads_all

                    , sum(buffer_gets_delta) as buffer_gets
                    , sum(sum(buffer_gets_delta)) over() as buffer_gets_all

                    , sum(rows_processed_delta) as rows_processed

                    , sum(cpu_time_delta) as cpu_time
                    , sum(sum(cpu_time_delta)) over() as cpu_time_all

                    , sum(plsexec_time_delta) as plsexec_time
                    , sum(sum(plsexec_time_delta)) over() as plsexec_time_all

                    , sum(elapsed_time_delta) as elapsed_time
                    , sum(sum(elapsed_time_delta)) over() as elapsed_time_all

                    , sum(iowait_delta) as iowait
                    , sum(sum(iowait_delta)) over() as iowait_all

                    , sum(apwait_delta) as apwait
                    , sum(sum(apwait_delta)) over() as apwait_all

                    , sum(ccwait_delta) as ccwait
                    , sum(sum(ccwait_delta)) over() as ccwait_all

                    , sum(direct_writes_delta) as direct_writes
                    , sum(sum(direct_writes_delta)) over() as direct_writes_all
                 from dba_hist_sqlstat s
                where s.snap_id between i_min_snap_id and i_max_snap_id
                group by s.dbid
                       , s.sql_id
                       , s.plan_hash_value
                       , s.parsing_schema_id
                       , s.parsing_schema_name
                order by decode(
                             i_sorting_type
                           , SORTING_CPU_TIME,         cpu_time
                           , SORTING_ELAPSED_TIME,     elapsed_time
                           , SORTING_DISK_READS,       disk_reads
                           , SORTING_BUFFER_GETS,      buffer_gets
                           , SORTING_DIRECT_WRITES,    direct_writes
                           , SORTING_CONCURRENCY_WAIT, ccwait
                           , SORTING_PLSQL_EXEC_TIME,  plsexec_time
                         ) desc
           ) m
     where rownum <= i_count;

end insert_top_sql;

procedure save_top_sql(
    i_start_date             in     date                           default null
  , i_end_date               in     date                           default null
  , i_count                  in     com_api_type_pkg.t_long_id     default null
  , i_top_sql_sorting_type   in     com_api_type_pkg.t_dict_value  default null
  , i_need_aggregate         in     com_api_type_pkg.t_boolean     default null
) is
    DEFAULT_TOP_SQL_COUNT  constant com_api_type_pkg.t_count      := 50;
    l_count                         com_api_type_pkg.t_count      := nvl(i_count,                DEFAULT_TOP_SQL_COUNT);
    l_sorting_type                  com_api_type_pkg.t_dict_value := nvl(i_top_sql_sorting_type, SORTING_CPU_TIME);
    l_need_aggregate                com_api_type_pkg.t_boolean    := nvl(i_need_aggregate,       com_api_const_pkg.FALSE);

    l_found                         com_api_type_pkg.t_boolean;
    l_session_id                    com_api_type_pkg.t_long_id;
    l_min_snap_id                   com_api_type_pkg.t_long_id;
    l_max_snap_id                   com_api_type_pkg.t_long_id;
    l_start_date                    date;
    l_end_date                      date;

    l_estimated_count               com_api_type_pkg.t_count    := 0;
    l_processed_count               com_api_type_pkg.t_count    := 0;
    l_excepted_count                com_api_type_pkg.t_count    := 0;
    l_rejected_count                com_api_type_pkg.t_count    := 0;
begin
    prc_api_stat_pkg.log_start;

    trc_log_pkg.debug(
        i_text        => 'Process [#1] is started'
      , i_env_param1  => 'SAVE_TOP_SQL'
    );

    l_start_date := coalesce(i_start_date, trunc(get_sysdate - 1));
    l_end_date   := coalesce(i_end_date,   l_start_date + 1 - com_api_const_pkg.ONE_SECOND);
    l_session_id := get_session_id;

    select min(sn.snap_id) as snap_min
         , max(sn.snap_id) as snap_max
      into l_min_snap_id
         , l_max_snap_id
      from dba_hist_snapshot sn
     where sn.begin_interval_time <= l_end_date
       and sn.end_interval_time   >= l_start_date;

    l_estimated_count := nvl(l_max_snap_id - l_min_snap_id + 1, 0);
    
    prc_api_stat_pkg.log_estimation(
        i_estimated_count   => l_estimated_count
    );

    if l_estimated_count > 0 then
        if l_need_aggregate = com_api_const_pkg.TRUE then
            insert_top_sql(
                i_session_id      => l_session_id
              , i_min_snap_id     => l_min_snap_id
              , i_max_snap_id     => l_max_snap_id
              , i_count           => l_count
              , i_sorting_type    => l_sorting_type
              , i_is_aggregation  => l_need_aggregate
            );

            l_processed_count := l_processed_count + 1;
        else
            for i in l_min_snap_id .. l_max_snap_id loop

                select nvl(max(com_api_const_pkg.TRUE), com_api_const_pkg.FALSE)
                  into l_found
                  from utl_top_sql t
                 where t.min_snap_id    = i
                   and t.max_snap_id    = i
                   and t.sorting_type   = l_sorting_type
                   and t.is_aggregation = l_need_aggregate
                   and rownum = 1;

                if l_found = com_api_const_pkg.FALSE then
                    insert_top_sql(
                        i_session_id      => l_session_id
                      , i_min_snap_id     => i
                      , i_max_snap_id     => i
                      , i_count           => l_count
                      , i_sorting_type    => l_sorting_type
                      , i_is_aggregation  => l_need_aggregate
                    );

                    l_processed_count := l_processed_count + 1;
                end if;
            end loop;
        end if;
    end if;

    trc_log_pkg.debug(
        i_text        => 'Process [#1] is finished successfully'
      , i_env_param1  => 'SAVE_TOP_SQL'
    );

    prc_api_stat_pkg.log_end(
        i_excepted_total   => l_excepted_count
      , i_processed_total  => l_processed_count
      , i_rejected_total   => l_rejected_count
      , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

exception
    when others then
       trc_log_pkg.debug(
            i_text        => 'Process [#1] is finished with error: [#2]'
          , i_env_param1  => 'SAVE_TOP_SQL'
          , i_env_param2  => sqlerrm
        );

        l_excepted_count := 1;

        prc_api_stat_pkg.log_end(
            i_excepted_total   => l_excepted_count
          , i_processed_total  => l_processed_count
          , i_rejected_total   => l_rejected_count
          , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE
        then
            com_api_error_pkg.raise_fatal_error(
                i_error       => 'UNHANDLED_EXCEPTION'
              , i_env_param1  => sqlerrm
            );
        end if;

        raise;
end save_top_sql;

end utl_prc_perf_pkg;
/
