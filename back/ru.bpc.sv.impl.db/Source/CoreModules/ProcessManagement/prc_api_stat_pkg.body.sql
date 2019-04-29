create or replace package body prc_api_stat_pkg is
/****************************************************************
 * The API for statistics processes <br />
 * Created by Khougaev A.(khougaev@bpc.ru)  at 06.10.2009 <br />
 * Module: PRC_API_STAT_PKG <br />
 * @headcom
 ****************************************************************/

g_container_id         com_api_type_pkg.t_short_id;
g_error_limit          com_api_type_pkg.t_tiny_id;

procedure check_error_limit is
    l_flag             com_api_type_pkg.t_boolean;
    l_session_id       com_api_type_pkg.t_long_id;
    l_container_id     com_api_type_pkg.t_short_id;
    l_thread_number    com_api_type_pkg.t_tiny_id;
begin
    l_session_id    := prc_api_session_pkg.get_session_id;
    l_container_id  := prc_api_session_pkg.get_container_id;
    l_thread_number := prc_api_session_pkg.get_thread_number;

    if g_container_id != l_container_id
       or g_container_id is null
    then
        select a.error_limit
          into g_error_limit
          from prc_container a
         where a.id = l_container_id;

        g_container_id := l_container_id;
    end if;

    if nvl(g_error_limit, 0) < 100 then

        select 1
          into l_flag
          from prc_container a
             , prc_stat b
             , prc_session c
             , prc_session d
         where c.id                      = l_session_id
           and d.id                      = c.parent_id
           and a.id                      = l_container_id
           and b.session_id              = c.id
           and b.thread_number           = l_thread_number
           and nvl(a.error_limit,     0) > 0
           and nvl(a.track_threshold, 0) > 0
           and nvl(b.estimated_count, 0) > 0
           and nvl(b.excepted_count,  0) > 0
           and nvl(b.current_count,   0) >= a.track_threshold
           and b.excepted_count * 100 / b.current_count >= a.error_limit;

        com_api_error_pkg.raise_fatal_error(
            i_error         => 'PROCESS_ERROR_OVERLIMIT'
        );

    end if;

exception
    when no_data_found then
        null;
end check_error_limit;

procedure log_start is
    pragma autonomous_transaction;
begin
    if get_session_id is null then
        com_api_error_pkg.raise_error(
            i_error => 'SESSION_NOT_FOUND'
        );
    end if;

    merge into prc_stat dst
         using (select get_session_id as session_id
                     , get_thread_number as thread_number
                     , systimestamp as start_time
                from   dual) src
            on (    src.session_id = dst.session_id
                and src.thread_number = dst.thread_number)
      when matched then
        update
           set dst.start_time = src.start_time
             , dst.current_time = src.start_time
             , dst.end_time = null
             , dst.estimated_count = null
             , dst.current_count = null
             , dst.processed_total = null
             , dst.excepted_total = null
             , dst.result_code = null
      when not matched then
        insert (session_id, thread_number, start_time, current_time, end_time, estimated_count
              , current_count, processed_total, excepted_total, result_code)
        values (src.session_id, src.thread_number, src.start_time, src.start_time, null, null
              , null, null, null, null);
    commit;
end log_start;

procedure log_estimation (
    i_estimated_count           in       com_api_type_pkg.t_long_id
  , i_measure                   in       com_api_type_pkg.t_dict_value
) is
    pragma autonomous_transaction;
begin
    merge into prc_stat dst
         using (select get_session_id as session_id
                     , get_thread_number as thread_number
                     , i_estimated_count as estimated_count
                     , systimestamp as current_time
                     , i_measure as measure
                from   dual) src
            on (    src.session_id = dst.session_id
                and src.thread_number = dst.thread_number)
      when matched then
        update
           set dst.current_time = src.current_time
             , dst.end_time = null
             , dst.estimated_count = src.estimated_count
             , dst.current_count = null
             , dst.processed_total = null
             , dst.excepted_total = null
             , dst.result_code = null
             , dst.measure = src.measure
      when not matched then
        insert (session_id
              , thread_number
              , start_time
              , current_time
              , end_time
              , estimated_count
              , current_count
              , processed_total
              , excepted_total
              , result_code
              , measure)
        values (src.session_id
              , src.thread_number
              , src.current_time
              , src.current_time
              , null
              , src.estimated_count
              , 0
              , null
              , null
              , null
              , src.measure);
    commit;
end log_estimation;

procedure increase_current (
    i_current_count             in       com_api_type_pkg.t_long_id
  , i_excepted_count            in       com_api_type_pkg.t_long_id
) is
    pragma autonomous_transaction;
begin
    merge into prc_stat dst
         using (select get_session_id as session_id
                     , get_thread_number as thread_number
                     , i_current_count as current_count
                     , i_excepted_count as excepted_count
                     , systimestamp as current_time
                from   dual) src
            on (    src.session_id = dst.session_id
                and src.thread_number = dst.thread_number)
      when matched then
        update
           set dst.current_time = src.current_time
             , dst.end_time = null
             , dst.current_count = nvl (dst.current_count, 0) + src.current_count
             , dst.excepted_count = nvl (dst.excepted_count, 0) + src.excepted_count
             , dst.processed_total = null, dst.excepted_total = null
             , dst.result_code = null
      when not matched then
        insert (session_id
              , thread_number
              , start_time
              , current_time
              , end_time
              , estimated_count
              , current_count
              , excepted_count
              , processed_total
              , excepted_total
              , result_code)
        values (src.session_id
              , src.thread_number
              , src.current_time
              , src.current_time
              , null
              , null
              , src.current_count
              , src.excepted_count
              , null
              , null
              , null);

    commit;

    check_error_limit;
end increase_current;

procedure log_current (
    i_current_count             in       com_api_type_pkg.t_long_id
  , i_excepted_count            in       com_api_type_pkg.t_long_id
) is
    pragma autonomous_transaction;
begin
    merge into prc_stat dst
         using (select get_session_id as session_id
                     , get_thread_number as thread_number
                     , i_current_count as current_count
                     , i_excepted_count as excepted_count
                     , systimestamp as current_time
                from   dual) src
            on (    src.session_id = dst.session_id
                and src.thread_number = dst.thread_number)
      when matched then
        update
           set dst.current_time = src.current_time
             , dst.end_time = null
             , dst.current_count = src.current_count
             , dst.excepted_count = src.excepted_count
             , dst.processed_total = null
             , dst.excepted_total = null
             , dst.result_code = null
      when not matched then
        insert (session_id
              , thread_number
              , start_time
              , current_time
              , end_time
              , estimated_count
              , current_count
              , excepted_count
              , processed_total
              , excepted_total
              , result_code)
        values (src.session_id
              , src.thread_number
              , src.current_time
              , src.current_time
              , null
              , null
              , src.current_count
              , src.excepted_count
              , null
              , null
              , null);
    commit;

    check_error_limit;
end log_current;

procedure log_end (
    i_processed_total           in       com_api_type_pkg.t_long_id
  , i_excepted_total            in       com_api_type_pkg.t_long_id
  , i_rejected_total            in       com_api_type_pkg.t_long_id
  , i_result_code               in       com_api_type_pkg.t_dict_value
) is
    pragma autonomous_transaction;
begin
    if get_session_id is NULL then
        com_api_error_pkg.raise_error(
            i_error => 'SESSION_NOT_FOUND'
        );
    end if;

    merge into prc_stat dst
         using (select get_session_id as session_id
                     , get_thread_number as thread_number
                     , i_processed_total as processed_total
                     , i_excepted_total as excepted_total
                     , i_rejected_total as rejected_total
                     , i_result_code as result_code
                     , systimestamp as current_time
                from   dual) src
            on (    src.session_id = dst.session_id
                and src.thread_number = dst.thread_number)
      when matched then
        update
           set dst.current_time = src.current_time
             , dst.end_time = src.current_time
             , dst.processed_total = nvl (nvl (src.processed_total, dst.current_count), 0)
             , dst.excepted_total = nvl (nvl (src.excepted_total, dst.excepted_count), 0)
             , dst.rejected_total = nvl (nvl (src.rejected_total, 0), 0)
             , dst.current_count = nvl (src.processed_total, dst.current_count)
             , dst.result_code = decode (dst.result_code, prc_api_const_pkg.PROCESS_RESULT_FAILED, dst.result_code, src.result_code)
      when not matched then
        insert (session_id
              , thread_number
              , start_time
              , current_time
              , end_time
              , estimated_count
              , current_count
              , processed_total
              , excepted_total
              , rejected_total
              , result_code)
        values (src.session_id
              , src.thread_number
              , src.current_time
              , src.current_time
              , src.current_time
              , null
              , nvl (src.processed_total, 0)
              , nvl (src.processed_total, 0)
              , nvl (src.excepted_total, 0)
              , nvl (src.rejected_total, 0)
              , src.result_code
              );
    commit;

    check_error_limit;
end log_end;

procedure change_thread_status (
    i_session_id               in       com_api_type_pkg.t_long_id
  , i_thread_number            in       com_api_type_pkg.t_tiny_id
  , i_result_code              in       com_api_type_pkg.t_dict_value
) is
begin
    update prc_stat
       set result_code   = i_result_code
     where session_id    = i_session_id
       and thread_number = i_thread_number;
end change_thread_status;

procedure increase_rejected_total (
    i_session_id               in       com_api_type_pkg.t_long_id
  , i_thread_number            in       com_api_type_pkg.t_tiny_id
  , i_rejected_total           in       com_api_type_pkg.t_long_id
) is
begin
    update prc_stat
       set rejected_total = nvl(rejected_total, 0) + i_rejected_total
     where session_id     = i_session_id
       and thread_number  = i_thread_number;
end increase_rejected_total;

end prc_api_stat_pkg;
/
