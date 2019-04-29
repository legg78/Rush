create or replace package body prc_api_session_pkg is
/************************************************************
 * API for process sessions <br />
 * Created by Kryukov E.(krukov@bpc.ru)  at 06.10.2009 <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: PRC_API_SESSION_PKG <br />
 * @headcom
 *************************************************************/

g_process_id                com_api_type_pkg.t_short_id;
g_parent_session_id         com_api_type_pkg.t_long_id;
g_session_id                com_api_type_pkg.t_long_id;
g_inst_id                   com_api_type_pkg.t_inst_id          := ost_api_const_pkg.DEFAULT_INST;
g_thread_number             com_api_type_pkg.t_tiny_id;
g_parallel_degree           com_api_type_pkg.t_tiny_id;
g_container_id              com_api_type_pkg.t_short_id;

procedure set_client_info(
    i_session_id            in      com_api_type_pkg.t_long_id
  , i_thread_number         in      com_api_type_pkg.t_tiny_id
  , i_container_id          in      com_api_type_pkg.t_short_id
  , i_process_id            in      com_api_type_pkg.t_short_id
) is
begin
    dbms_application_info.set_client_info('sv:sid[' || to_char(i_session_id)
                                        || ']:tid[' || to_char(i_thread_number)
                                        || ']:cid[' || to_char(i_container_id)
                                        || ']:pid[' || to_char(i_process_id)
                                        || ']'
    );
end set_client_info;

procedure reset_client_info is
begin
    dbms_application_info.set_client_info(null);
end reset_client_info;

procedure add_session(
    o_session_id            in out  com_api_type_pkg.t_long_id
  , i_process_id            in      com_api_type_pkg.t_short_id
  , i_parent_session_id     in      com_api_type_pkg.t_long_id
  , i_user_id               in      com_api_type_pkg.t_short_id
  , i_ip_address            in      com_api_type_pkg.t_name         default null
  , i_inst_id               in      com_api_type_pkg.t_inst_id      default ost_api_const_pkg.DEFAULT_INST
  , i_container_id          in      com_api_type_pkg.t_short_id
) is
    pragma autonomous_transaction;
    l_open_sttl_day         com_api_type_pkg.t_tiny_id;
    l_open_sttl_date        date;
    l_inst_id               com_api_type_pkg.t_inst_id := nvl(i_inst_id, acm_api_user_pkg.get_user_inst);
begin
    o_session_id := com_api_id_pkg.get_id(prc_session_seq.nextval, com_api_sttl_day_pkg.get_sysdate);

    begin
        l_open_sttl_day := com_api_sttl_day_pkg.get_open_sttl_day(acm_api_user_pkg.get_user_inst);
    exception
        when com_api_error_pkg.e_fatal_error then
            l_open_sttl_day := null;
    end;
    begin
        l_open_sttl_date := com_api_sttl_day_pkg.get_open_sttl_date(acm_api_user_pkg.get_user_inst);
    exception
        when com_api_error_pkg.e_fatal_error then
            l_open_sttl_date := null;
    end;

    insert into prc_session (
        id
      , process_id
      , parent_id
      , start_time
      , user_id
      , inst_id
      , result_code
      , sttl_day
      , sttl_date
      , ip_address
      , container_id
    ) values (
        o_session_id
      , i_process_id
      , i_parent_session_id
      , systimestamp
      , i_user_id
      , l_inst_id
      , nvl2(i_process_id, prc_api_const_pkg.PROCESS_RESULT_IN_PROGRESS, null)
      , l_open_sttl_day
      , l_open_sttl_date
      , i_ip_address
      , i_container_id
    );

    commit;

exception
    when com_api_error_pkg.e_application_error then
        raise;
    when com_api_error_pkg.e_fatal_error then
        raise;
    when others then
        com_api_error_pkg.raise_fatal_error(
            i_error         => 'UNHANDLED_EXCEPTION'
          , i_env_param1    => sqlerrm
        );
end add_session;

procedure start_session (
    io_session_id           in out  com_api_type_pkg.t_long_id
  , i_process_id            in      com_api_type_pkg.t_short_id    default null
  , i_thread_number         in      com_api_type_pkg.t_tiny_id     default null
  , i_parent_session_id     in      com_api_type_pkg.t_long_id     default null
  , i_ip_address            in      com_api_type_pkg.t_name        default null
  , i_container_id          in      com_api_type_pkg.t_short_id    default null
  , i_inst_id               in      com_api_type_pkg.t_inst_id     default null
  , i_user_id               in      com_api_type_pkg.t_short_id    default null
) is
    l_process_id            com_api_type_pkg.t_short_id;
    l_parent_session_id     com_api_type_pkg.t_long_id;
begin
    if i_inst_id is not null then
        g_inst_id := i_inst_id;
    end if;

    if io_session_id is null then

        add_session(
            o_session_id        => io_session_id
          , i_process_id        => i_process_id
          , i_parent_session_id => i_parent_session_id
          , i_user_id           => nvl(i_user_id, get_user_id)
          , i_ip_address        => i_ip_address
          , i_inst_id           => g_inst_id
          , i_container_id      => i_container_id
        );

    else
        begin
            select process_id
                 , parent_id
              into l_process_id
                 , l_parent_session_id
              from prc_session
             where id = io_session_id;
        exception
            when no_data_found then
                null;
        end;
    end if;

    set_session_id(
        i_session_id        => io_session_id
    );

    set_thread_number(
        i_thread_number     => i_thread_number
    );

    set_process_id(
        i_process_id        => nvl(l_process_id, i_process_id)
    );

    set_parent_session_id(
        i_parent_session_id => nvl(l_parent_session_id, i_parent_session_id)
    );

    set_container_id(
        i_container_id      => i_container_id
    );

end start_session;

procedure stop_session(
    i_result_code           in      com_api_type_pkg.t_dict_value
) is
    pragma autonomous_transaction;
begin

    if g_session_id is not null then

        update prc_session_vw a
           set (
                  a.processed
                , a.rejected
                , a.excepted
                , a.thread_count
                , a.estimated_count
                , a.measure
               ) =
               (
                select nvl(sum(b.processed_total), 0)
                     , nvl(sum(b.rejected_total), 0)
                     , nvl(sum(b.excepted_total), 0)
                     , count(distinct b.thread_number)
                     , sum(b.estimated_count)
                     , max(b.measure)
                  from prc_stat b
                 where b.session_id = a.id
               )
             , a.end_time    = systimestamp
             , a.result_code = decode (a.result_code, prc_api_const_pkg.PROCESS_RESULT_FAILED, a.result_code, i_result_code)
         where a.id = g_session_id;

        if sql%rowcount > 0 then
            trc_log_pkg.debug(
                i_text => 'Stop session with id = ' || get_session_id
            );

            set_session_id(
                i_session_id        => null
            );

            set_thread_number(
                i_thread_number     => null
            );

            set_process_id(
                i_process_id        => null
            );

            set_parent_session_id(
                i_parent_session_id => null
            );
        end if;
    end if;

    reset_client_info;
    commit;
end stop_session;

function get_parallel_degree return com_api_type_pkg.t_tiny_id is
begin
    if g_parallel_degree is null then
         g_parallel_degree :=
            set_ui_value_pkg.get_system_param_n(
                i_param_name    => 'PARALLEL_DEGREE'
            );
    end if;

    return g_parallel_degree;
end get_parallel_degree;

procedure set_session_id(
    i_session_id            in      com_api_type_pkg.t_long_id
) is
begin
    g_session_id := i_session_id;
end set_session_id;

function get_session_id return com_api_type_pkg.t_long_id is
begin
    return g_session_id;
end get_session_id;

function get_inst_id return com_api_type_pkg.t_inst_id is
begin
    return g_inst_id;
end get_inst_id;

procedure set_thread_number(
    i_thread_number         in      com_api_type_pkg.t_tiny_id
) is
begin
    g_thread_number := i_thread_number;
end set_thread_number;

function get_thread_number return com_api_type_pkg.t_tiny_id is
begin
    return nvl(g_thread_number, prc_api_const_pkg.DEFAULT_THREAD);
end get_thread_number;

procedure set_process_id (
    i_process_id            in      com_api_type_pkg.t_short_id
) is
begin
    g_process_id := i_process_id;
end set_process_id;

function get_process_id return com_api_type_pkg.t_short_id is
begin
    return g_process_id;
end get_process_id;

procedure set_parent_session_id(
    i_parent_session_id     in      com_api_type_pkg.t_long_id
) is
begin
    g_parent_session_id := i_parent_session_id;
end set_parent_session_id;

procedure set_container_id(
    i_container_id          in      com_api_type_pkg.t_long_id
) is
begin
    g_container_id := i_container_id;
end set_container_id;

function get_container_id return com_api_type_pkg.t_short_id is
begin
    return g_container_id;
end get_container_id;

function get_parent_session_id return com_api_type_pkg.t_long_id is
begin
    return g_parent_session_id;
end get_parent_session_id;

function get_procedure_name(
    i_process_id            in      com_api_type_pkg.t_short_id     default null
) return com_api_type_pkg.t_name is
    l_result                com_api_type_pkg.t_name;
begin
    select a.procedure_name
      into l_result
      from prc_process a
     where a.id = nvl(i_process_id, get_process_id);

    return l_result;
exception
    when no_data_found then
        com_api_error_pkg.raise_error(
            i_error         => 'PROCEDURE_NOT_FOUND'
          , i_env_param1    => i_process_id
        );
end get_procedure_name;

function get_process_type(
    i_process_id            in      com_api_type_pkg.t_short_id     default null
) return com_api_type_pkg.t_boolean is
    l_result                com_api_type_pkg.t_boolean;
begin
    select a.is_external
      into l_result
      from prc_process a
     where a.id = nvl(i_process_id, get_process_id);

    return l_result;
exception
    when no_data_found then
        com_api_error_pkg.raise_error(
            i_error         => 'PROCEDURE_NOT_FOUND'
          , i_env_param1    => i_process_id
        );
end get_process_type;

procedure set_session_last_use is
begin
    if g_session_id is not null then
        update prc_session a
           set a.end_time    = systimestamp
         where a.id          = g_session_id;
    end if;
end set_session_last_use;

procedure set_session_context(
    i_session_id            in      com_api_type_pkg.t_long_id
) is
    l_container_id          com_api_type_pkg.t_short_id;
    l_process_id            com_api_type_pkg.t_short_id;
begin
    select s.container_id
         , s.process_id
      into l_container_id
         , l_process_id
      from prc_session s
     where s.id = i_session_id;

    prc_api_session_pkg.set_container_id(
        i_container_id => l_container_id
    );

    prc_api_session_pkg.set_process_id(
        i_process_id => l_process_id
    );

    prc_api_session_pkg.set_session_id(
        i_session_id => i_session_id
    );
exception
    when others then
        com_api_error_pkg.raise_error (
            i_error      => 'SESSION_NOT_FOUND'
          , i_env_param1 => i_session_id
        );
end set_session_context;

procedure check_process_in_progress(
    i_process_id            in      com_api_type_pkg.t_short_id
  , i_session_id            in      com_api_type_pkg.t_long_id
) is
    l_oracle_user       com_api_type_pkg.t_name;
begin
    l_oracle_user := user;

    trc_log_pkg.debug(
        i_text         => 'check_process_in_progress: oracle_user [#1], process_id [#2], session_id [#3]'
      , i_env_param1   => l_oracle_user
      , i_env_param2   => i_process_id
      , i_env_param3   => i_session_id
    );

    for r in (
        select ci.sid
             , ci.serial#
             , ci.session_id
             , ci.thread_number
             , ci.container_id
          from prc_session s
             , prc_api_client_info_vw ci
         where s.process_id   = i_process_id
           and s.id          != i_session_id
           and s.result_code  = prc_api_const_pkg.PROCESS_RESULT_IN_PROGRESS
           and ci.session_id  = s.id
           and ci.process_id  = s.process_id
           and ci.username    = l_oracle_user
           and ci.status      = 'ACTIVE'
           and rownum         = 1
    )
    loop
        com_api_error_pkg.raise_error(
            i_error         => 'PROCESS_IS_IN_PROGRESS'
          , i_env_param1    => i_process_id
          , i_env_param2    => r.sid
          , i_env_param3    => r.serial#
          , i_env_param4    => r.session_id
          , i_env_param5    => r.thread_number
          , i_env_param6    => r.container_id
        );
    end loop;

end check_process_in_progress;

end prc_api_session_pkg;
/
