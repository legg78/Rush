create or replace package body prc_ui_task_pkg as
/************************************************************
 * User interface for process tasks <br />
 * Created by Kryukov E.(krukov@bpc.ru)  at 04.12.2009 <br />
 * Last changed by $Author: krukov $ <br />
 * $LastChangedDate:: 2009-12-04 09:58:36 +0300#$ <br />
 * Revision: $LastChangedRevision: 1367 $ <br />
 * Module: prc_ui_task_pkg <br />
 * @headcom
 ************************************************************/
procedure add_task (
    o_id                         out com_api_type_pkg.t_short_id
    , i_process_id            in     com_api_type_pkg.t_short_id
    , i_crontab_value         in     com_api_type_pkg.t_name
    , i_is_active             in     com_api_type_pkg.t_boolean       default com_api_type_pkg.TRUE
    , i_repeat_period         in     com_api_type_pkg.t_tiny_id
    , i_repeat_interval       in     com_api_type_pkg.t_tiny_id
    , i_short_desc            in     com_api_type_pkg.t_short_desc
    , i_full_desc             in     com_api_type_pkg.t_full_desc
    , i_lang                  in     com_api_type_pkg.t_dict_value
    , i_is_holiday_skipped    in     com_api_type_pkg.t_boolean       default com_api_type_pkg.FALSE
    , i_stop_on_fatal         in     com_api_type_pkg.t_boolean       default com_api_type_pkg.FALSE
)
is
begin
    o_id := prc_task_seq.nextval;

    insert into prc_task_vw (
        id
      , process_id
      , crontab_value
      , is_active
      , repeat_period
      , repeat_interval
      , is_holiday_skipped
      , stop_on_fatal
    ) values (
        o_id
      , i_process_id
      , i_crontab_value
      , i_is_active
      , i_repeat_period
      , i_repeat_interval
      , i_is_holiday_skipped
      , i_stop_on_fatal
    );

    -- add/modify descriptions
    com_api_i18n_pkg.add_text (
        i_table_name   => 'prc_task'
      , i_column_name  => 'name'
      , i_object_id    => o_id
      , i_text         => i_short_desc
      , i_lang         => i_lang
    );

    com_api_i18n_pkg.add_text (
        i_table_name   => 'prc_task'
      , i_column_name  => 'description'
      , i_object_id    => o_id
      , i_text         => i_full_desc
      , i_lang         => i_lang
    );
end add_task;

procedure modify_task (
    i_id                      in     com_api_type_pkg.t_short_id
    , i_process_id            in     com_api_type_pkg.t_short_id
    , i_crontab_value         in     com_api_type_pkg.t_name
    , i_is_active             in     com_api_type_pkg.t_boolean       default com_api_type_pkg.TRUE
    , i_repeat_period         in     com_api_type_pkg.t_tiny_id
    , i_repeat_interval       in     com_api_type_pkg.t_tiny_id
    , i_short_desc            in     com_api_type_pkg.t_short_desc
    , i_full_desc             in     com_api_type_pkg.t_full_desc
    , i_lang                  in     com_api_type_pkg.t_dict_value
    , i_is_holiday_skipped    in     com_api_type_pkg.t_boolean       default com_api_type_pkg.FALSE
    , i_stop_on_fatal         in     com_api_type_pkg.t_boolean       default com_api_type_pkg.FALSE
)
is
begin
    update prc_task_vw
       set process_id         = nvl(i_process_id, process_id)
         , crontab_value      = nvl(i_crontab_value, crontab_value)
         , is_active          = nvl(i_is_active, is_active)
         , repeat_period      = i_repeat_period
         , repeat_interval    = i_repeat_interval
         , is_holiday_skipped = nvl(i_is_holiday_skipped, is_holiday_skipped)
         , stop_on_fatal      = nvl(i_stop_on_fatal, stop_on_fatal)
     where id = i_id;

    -- add/modify descriptions
    com_api_i18n_pkg.add_text (
        i_table_name     => 'prc_task'
        , i_column_name  => 'name'
        , i_object_id    => i_id
        , i_text         => i_short_desc
        , i_lang         => i_lang
    );

    com_api_i18n_pkg.add_text (
        i_table_name     => 'prc_task'
        , i_column_name  => 'description'
        , i_object_id    => i_id
        , i_text         => i_full_desc
        , i_lang         => i_lang
    );
end modify_task;

procedure remove_task (
    i_id                      in     com_api_type_pkg.t_short_id
)
is
begin
    delete from prc_task_vw a
     where a.id = i_id;

    -- delete descriptions
    com_api_i18n_pkg.remove_text (
        i_table_name   => 'PRC_TASK'
        , i_object_id  => i_id
    );
end remove_task;

function get_inc(
    i_str   in com_api_type_pkg.t_attr_name
  , i_max   in com_api_type_pkg.t_attr_name
) return binary_integer is
    l_inc   binary_integer := 0;
begin
    if i_str in ('*', '?') then
        l_inc := 1;     -- every time (min, hours or month)
    else
        if instr(i_str, '/') > 0 then     -- if divider exists
            l_inc := substr(i_str, instr(i_str, '/') + 1, 2);
        else
            l_inc := i_max;
        end if;
    end if;
    return l_inc;
end get_inc;

-- generator
function gen_times(
    i_hour  in  com_api_type_pkg.t_attr_name
  , i_min   in  com_api_type_pkg.t_attr_name
  , i_date  in date
) return date_tab_tpt pipelined is
    l_h_first   binary_integer := 0;
    l_h_inc     binary_integer := 0;
    l_h         binary_integer := 0;
    l_m_first   binary_integer := 0;
    l_m_inc     binary_integer := 0;
    l_m         binary_integer := 0;
    l_out_date  date;

    function get_first(
        i_str   in com_api_type_pkg.t_attr_name
    ) return binary_integer is
        l_first     com_api_type_pkg.t_attr_name;
    begin
        if i_str in ('*', '?') then
            l_first := '0';   -- from the beginning
        else
            if instr(i_str, '/') > 0 then     -- if divider exists
                l_first := substr(i_str, 1, instr(i_str, '/') - 1);
            else
                l_first := i_str;   -- no divider, then return as is
            end if;
        end if;
        return to_number(l_first);
    end get_first;

begin
    l_h_inc   := get_inc(i_hour, 24);   -- hour increment, if not found then 24 (no cycle)
    l_h_first := get_first(i_hour);
    l_m_inc   := get_inc(i_min, 60);      -- minute increment, if not found then 60 (no cycle)
    l_m_first := get_first(i_min);

    l_h := l_h_first;
    loop
        -- create minutes...
        l_m := l_m_first;
        loop
            l_out_date := trunc(i_date) + l_h/24 + l_m/24/60;
            pipe row(l_out_date);
            l_m := l_m + l_m_inc;
            exit when l_m >= 60;
        end loop;
        l_h := l_h + l_h_inc;
        exit when l_h >= 24;
    end loop;
exception
    when others then
        trc_log_pkg.debug(      -- numberic or conversion error
            i_text => 'Error while gen times(' || sqlerrm ||
                    '): l_h_inc[' || l_h_inc || '] l_h_first [' || l_h_first || '] l_h [' || l_h ||
                    ' l_m_inc [' || l_m_inc || '] l_m_first [' || l_m_first || '] l_m [' || l_m ||
                    ' l_out_date [' || to_char(l_out_date, 'DD.MM.YYYY HH24:MI:SS') || ']'
        );
        raise;
end gen_times;

-- Utility for gather days execution schedule for crontab
function get_exec_time(
    i_cron               in varchar2
  , i_date               in date                          default trunc(get_sysdate)
  , i_is_holiday_skipped in com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
  , i_inst_id            in com_api_type_pkg.t_inst_id    default ost_api_const_pkg.DEFAULT_INST
  , i_mask_error         in com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
) return date_tab_tpt pipelined
is
    l_min           com_api_type_pkg.t_attr_name;   -- only int optional with divide are allowed (for ex. 7/11 )
    l_hour          com_api_type_pkg.t_attr_name;   -- only int optional with divide are allowed (for ex. 7/11 )
    l_day_of_mounth com_api_type_pkg.t_attr_name;   -- only comma divided list of days are allowed (for ex. 3,4,5,11)
    l_month         com_api_type_pkg.t_attr_name;   -- only mnemonic of month with optional divide are allowed (for ex. ARP/3)
    l_day_of_week   com_api_type_pkg.t_attr_name;   -- only mnenonic names are allowed (THE, SUN, etc)

    l_date          date := nvl(i_date, get_sysdate());

    function find_subsrt(
        i_str   in com_api_type_pkg.t_attr_name
      , i_patt  in com_api_type_pkg.t_attr_name
    ) return com_api_type_pkg.t_boolean is
        l_res com_api_type_pkg.t_boolean;
    begin
        if instr(i_str, i_patt) > 0 then
            l_res := com_api_const_pkg.TRUE;
        else
            l_res := com_api_const_pkg.FALSE;
        end if;
        return l_res;
    end find_subsrt;

    -- check if i_date is comply to i_day_of_week pattern
    function check_day_of_week(
        i_day_of_week  in com_api_type_pkg.t_attr_name
      , i_date         in date
    ) return com_api_type_pkg.t_boolean is
        l_filter_pass   com_api_type_pkg.t_boolean := com_api_const_pkg.TRUE;
    begin
        if i_day_of_week not in ('*', '?') then
            -- check if currect day of mouth is from the list i_day_of_week
            case to_char(i_date, 'D')
                when 1 then
                    l_filter_pass := find_subsrt(i_day_of_week, 'MON');
                when 2 then
                    l_filter_pass := find_subsrt(i_day_of_week, 'TUE');
                when 3 then
                    l_filter_pass := find_subsrt(i_day_of_week, 'WED');
                when 4 then
                    l_filter_pass := find_subsrt(i_day_of_week, 'THU');
                when 5 then
                    l_filter_pass := find_subsrt(i_day_of_week, 'FRI');
                when 6 then
                    l_filter_pass := find_subsrt(i_day_of_week, 'SAT');
                when 7 then
                    l_filter_pass := find_subsrt(i_day_of_week, 'SUN');
            end case;
        end if;
        return l_filter_pass;
    end check_day_of_week;

    -- check if i_date is comply to i_day_of_mounth pattern
    function check_day_of_month(
        i_day_of_mounth  in com_api_type_pkg.t_attr_name
      , i_date           in date
    ) return com_api_type_pkg.t_boolean is
        l_filter_pass   com_api_type_pkg.t_boolean := com_api_const_pkg.TRUE;
    begin
        if i_day_of_mounth not in ('*', '?') then
            l_filter_pass := find_subsrt(i_day_of_mounth || ',', ltrim(to_char(i_date, 'DD'), '0') || ',');
        end if;
        return l_filter_pass;
    end check_day_of_month;

    -- check if i_date is comply to i_month pattern
    function check_month(
        i_month  in com_api_type_pkg.t_attr_name
      , i_date   in date
    ) return com_api_type_pkg.t_boolean is
        l_filter_pass   com_api_type_pkg.t_boolean := com_api_const_pkg.TRUE;
        l_month_inc     binary_integer;
    begin
        if i_month not in ('*', '?') then

            l_filter_pass := find_subsrt(i_month, to_char(i_date, 'MON'));
            if l_filter_pass = com_api_const_pkg.FALSE then -- if month already in cron - then true otherwise check divider
                l_month_inc := get_inc(i_month, 12);
                trc_log_pkg.debug('l_month_inc=' || l_month_inc);
                if l_month_inc != 12 then     -- if divider exists
                    declare
                        l_m     com_api_type_pkg.t_tiny_id := to_number(to_char(to_date(
                                                                  substr(i_month, 1, instr(i_month, '/') - 1), 'MON'), 'MM'
                                                              ));
                        l_currm com_api_type_pkg.t_tiny_id := to_number(to_char(i_date, 'MM'));
                    begin
                        trc_log_pkg.debug('l_currm=' || l_currm || ' l_m=' || l_m);
                        if l_currm >= l_m and mod(l_currm - l_m, l_month_inc) = 0 then
                                trc_log_pkg.debug('month OK');
                                l_filter_pass := com_api_const_pkg.TRUE;
                        end if;
                        trc_log_pkg.debug('....');
                    end;
                end if;
            end if;
        end if;
        return l_filter_pass;
    end check_month;

begin
    trc_log_pkg.debug(
        i_text => 'i_date [' || i_date || '] i_cron [' || i_cron ||
                  '] i_is_holiday_skipped [' || i_is_holiday_skipped || ']'
    );

    if (i_is_holiday_skipped = com_api_const_pkg.TRUE and
        com_api_holiday_pkg.is_holiday(
            i_day     => l_date
          , i_inst_id => i_inst_id
        ) = com_api_const_pkg.TRUE) or i_cron is null
    then
        return;
    end if;

    -- parse quartz cron
    for tab in (
        select regexp_substr (i_cron, '[^ ]+', 1, level) dt, rownum rn
          from dual
       connect by regexp_substr (i_cron, '[^ ]+', 1, level) is not null
    )
    loop
        case tab.rn - 1         -- skip seconds
            when 1 then l_min           := tab.dt;
            when 2 then l_hour          := tab.dt;
            when 3 then l_day_of_mounth := tab.dt;
            when 4 then l_month         := tab.dt;
            when 5 then l_day_of_week   := tab.dt;
            else null;
        end case;
    end loop;
    trc_log_pkg.debug('l_min [' || l_min || '] l_hour [' || l_hour || '] l_day_of_mounth [' || l_day_of_mounth
                || '] l_month [' || l_month || '] l_day_of_week [' || l_day_of_week || ']');

    -- filter stage:
    -- 1 - check day of week
    if check_day_of_week(
           i_day_of_week => l_day_of_week
         , i_date        => l_date
       ) = com_api_const_pkg.FALSE or
       -- 2 - check day of month
       check_day_of_month(
           i_day_of_mounth => l_day_of_mounth
         , i_date          => l_date
       ) = com_api_const_pkg.FALSE or
       -- 3 - check month
       check_month(
           i_month => l_month
         , i_date  => l_date
       ) = com_api_const_pkg.FALSE
    then
        return;
    end if;

    -- Generation stage:
    -- filter is passed => find out dates for exec in l_date
    for tab in (
        select column_value
          from table(gen_times(
                         i_hour => l_hour
                       , i_min  => l_min
                       , i_date => l_date
                     ))
    )
    loop
        pipe row(tab.column_value);
    end loop;

exception
    when others then
        trc_log_pkg.debug(
            i_text => 'Unable to parse quartz cron string ' || sqlerrm
        );
        if i_mask_error = com_api_const_pkg.FALSE then
            raise;
        end if;
end get_exec_time;



function get_sorting_clause(
    i_sorting_tab       in     com_param_map_tpt
) return com_api_type_pkg.t_name
is
    LOG_PREFIX    constant     com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_sorting_clause: ';
    l_result                   com_api_type_pkg.t_name := null;
begin
    if i_sorting_tab is not null then
        begin
            select nvl2(list, 'order by ' || list, '')
              into l_result
              from (select rtrim(xmlagg(xmlelement(e, name || ' ' || char_value, ',').extract('//text()')), ',') as list
                      from table(cast(i_sorting_tab as com_param_map_tpt))
                   );
        exception
            when no_data_found then
                l_result := null;
        end;
    end if;

    trc_log_pkg.debug(LOG_PREFIX || ' sort by [' || l_result || ']');
    return l_result;
end;



procedure get_schedule_info_base (
    o_ref_cur                   out  com_api_type_pkg.t_ref_cur
  , o_row_count                 out  com_api_type_pkg.t_long_id
  , i_date                   in      date                          default null
  , i_first_row              in      com_api_type_pkg.t_long_id    default null
  , i_last_row               in      com_api_type_pkg.t_long_id    default null
  , i_param_tab              in      com_param_map_tpt             default null
  , i_sorting_tab            in      com_param_map_tpt             default null
  , i_is_count_mode          in      com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
) is
    l_date                           date                          := null;
    l_lang                           com_api_type_pkg.t_dict_value := get_user_lang;
    l_query                          com_api_type_pkg.t_text       := null;
    LOG_PREFIX         constant      com_api_type_pkg.t_name       := lower($$PLSQL_UNIT) || '.get_schedule_info ';
    DEFAULT_SORTING    constant      com_api_type_pkg.t_name     := '
        order by v.container_process_id asc
               , s.start_time asc
               , v.planned_launch_date asc';
    START_LIMITATION   constant      com_api_type_pkg.t_text       := '
        select * from (
            select a.*, rownum r from (';
    END_LIMITATION     constant      com_api_type_pkg.t_text       := '
            ) a
        ) where r >= (:i_first_row) and r <= (:i_last_row)' ;
    DATA_QUERY         constant      com_api_type_pkg.t_text       := '
        select v.container_process_id as container_id
             , v.container_name       as container_name
             , v.inst_id              as inst_id
             , s.id                   as session_id
             , v.inst_name            as inst_name
             , v.planned_launch_date  as planned_launch_date
             , v.is_holiday_skipped   as is_holiday_skipped
             , v.is_container         as is_container
             , v.is_active            as is_active
             , s.start_time           as start_time
             , s.end_time             as end_time
             , s.result_code          as status
             , get_article_text(
                   i_article => s.result_code
                 , i_lang    => :l_lang
               )                      as status_desc
             , v.description
          from (with p as (
                select distinct c.container_process_id
                              , get_text(
                                    i_table_name  => ''PRC_PROCESS''
                                  , i_column_name => ''NAME''
                                  , i_object_id   => c.container_process_id
                                  , i_lang        => :l_lang
                                ) as container_name
                              , t.is_active
                              , t.is_holiday_skipped
                              , t.crontab_value
                              , p.inst_id
                              , p.is_container
                              , ost_ui_institution_pkg.get_inst_name(
                                    i_inst_id => p.inst_id
                                  , i_lang    => :l_lang
                                ) as inst_name
                              , get_text(
                                    i_table_name  => ''PRC_TASK''
                                  , i_column_name => ''NAME''
                                  , i_object_id   => t.id
                                  , i_lang        => :l_lang
                                ) as description
                           from prc_container c
                              , prc_task t
                              , prc_process p
                          where c.container_process_id = t.process_id
                            and c.container_process_id = p.id)
                   select p.*
                        , t.column_value as planned_launch_date
                     from p
                        , table(prc_ui_task_pkg.get_exec_time(
                                    i_date               => :l_date
                                  , i_cron               => p.crontab_value
                                  , i_inst_id            => p.inst_id
                                  , i_is_holiday_skipped => p.is_holiday_skipped)
                               ) t
               ) v
     left join prc_session s
            on s.process_id = v.container_process_id
           and trunc(v.planned_launch_date, ''MI'') = trunc(s.start_time, ''MI'')
           and s.start_time >= trunc(:l_date) 
           and s.start_time < trunc(:l_date) + 1';
begin
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || ': i_date [' || i_date || '] i_first_row [' || i_first_row || '] i_last_row [' || i_last_row || ']'
    );

    l_date := trunc(nvl(i_date, get_sysdate()));

    if i_is_count_mode = com_api_const_pkg.TRUE then
        trc_log_pkg.debug(LOG_PREFIX || ': execute count query');
        select count(v.container_process_id)
          into o_row_count
          from (with p as (
                select distinct c.container_process_id
                              , t.is_holiday_skipped
                              , t.crontab_value
                              , p.inst_id
                           from prc_container c
                              , prc_task t
                              , prc_process p
                          where c.container_process_id = t.process_id
                            and c.container_process_id = p.id)
                 select p.*
                      , t.column_value as planned_launch_date
                   from p
                      , table(prc_ui_task_pkg.get_exec_time(
                                  i_date               => l_date
                                , i_cron               => p.crontab_value
                                , i_inst_id            => p.inst_id
                                , i_is_holiday_skipped => p.is_holiday_skipped)
                             ) t
               ) v
     left join prc_session s
            on s.process_id = v.container_process_id
           and trunc(v.planned_launch_date, 'MI') = trunc(s.start_time, 'MI')
           and s.start_time >= trunc(l_date) 
           and s.start_time < trunc(l_date) + 1;
    else
        if i_first_row is not null and i_last_row is not null then
            l_query := START_LIMITATION 
                    || DATA_QUERY 
                    || nvl(get_sorting_clause(i_sorting_tab), DEFAULT_SORTING) 
                    || END_LIMITATION;
        else 
            l_query := DATA_QUERY 
                    || nvl(get_sorting_clause(i_sorting_tab), DEFAULT_SORTING);
        end if;

        trc_log_pkg.debug(LOG_PREFIX || ': oper cursor for [' || l_query || ']');
        open o_ref_cur for l_query
       using l_lang
           , l_lang
           , l_lang
           , l_lang
           , l_date
           , l_date
           , l_date
           , i_first_row
           , i_last_row;
    end if;

end get_schedule_info_base;

procedure get_schedule_info (
    o_ref_cur                   out  com_api_type_pkg.t_ref_cur
  , i_date                   in      date                          default null
  , i_first_row              in      com_api_type_pkg.t_long_id
  , i_last_row               in      com_api_type_pkg.t_long_id
  , i_param_tab              in      com_param_map_tpt             default null
  , i_sorting_tab            in      com_param_map_tpt             default null
) is
    l_row_count                      com_api_type_pkg.t_long_id    := null;
begin
    get_schedule_info_base (
        o_ref_cur       => o_ref_cur
      , o_row_count     => l_row_count
      , i_date          => i_date
      , i_first_row     => i_first_row
      , i_last_row      => i_last_row
      , i_param_tab     => i_param_tab
      , i_sorting_tab   => i_sorting_tab
      , i_is_count_mode => com_api_const_pkg.FALSE
    );
end get_schedule_info;

procedure get_schedule_info_count (
    o_row_count                 out  com_api_type_pkg.t_long_id
  , i_date                   in      date                          default null
  , i_param_tab              in      com_param_map_tpt             default null
) is
    l_ref_cur                        com_api_type_pkg.t_ref_cur    := null;
begin
    get_schedule_info_base (
        o_ref_cur       => l_ref_cur
      , o_row_count     => o_row_count
      , i_date          => i_date
      , i_param_tab     => i_param_tab
      , i_is_count_mode => com_api_const_pkg.TRUE
    );
end get_schedule_info_count;

end;
/
