create or replace package body utl_prc_clear_pkg as
/**********************************************************
 * Deploy utilites<br/>
 * Created by Mashonkin V.(mashonkin@bpcbt.com)  at 11.06.2014<br/>
 * Last changed by $Author:  $<br/>
 * $LastChangedDate:: 2014-06-11 15:58:30 +0400 $<br/>
 * Revision: $LastChangedRevision: 40134 $<br/>
 * Module: UTL_PRC_CLEAR_PKG
 * @headcom
 **********************************************************/

-- Clear all data from non-config user tables
procedure clear_user_tables(
    i_test_option    in  com_api_type_pkg.t_dict_value default 'CLRM000T'
  , i_approvement    in  com_api_type_pkg.t_text
)
as
    irresponsible_action exception;

    l_count              pls_integer := 0;
    l_error_cnt          pls_integer := 0;
    l_sql                com_api_type_pkg.t_text;
    l_msg                com_api_type_pkg.t_text;
    l_default_max_value  pls_integer := 0;
begin
    -- Approvement is STRICTLY necessary
    if lower(trim(i_approvement)) != C_CONFIRMATION_TEXT then
        raise irresponsible_action;
    end if;

    -- clear all log
    if i_test_option = 'P' then  -- CLRM000P = work mode, CLRM000T - test mode

        execute immediate 'truncate table trc_log drop storage';

        delete from prc_session s
         where s.start_time < trunc(sysdate);  -- old sessions

        delete from prc_session_file
         where session_id not in (select id from prc_session);

    end if;

    prc_api_stat_pkg.log_start;

    trc_log_pkg.debug(i_text => '*** i_test_option = ' || i_test_option);

    select max_value
      into l_default_max_value
      from user_sequences us
     where lower(us.sequence_name) = 'com_dictionary_seq';

    for i in (
        select u.table_name
             , ut.table_name   as sv_table_name
             , ut.is_split_seq
             , case
                   when nvl(lower(ut.config_condition), '~') like 'id%'
                        and nvl(s.max_value, l_default_max_value) is not null
                   then 'ID >= ' || to_char(power(10, length(nvl(s.max_value, l_default_max_value))-1) * utl_deploy_pkg.instance_type_production)
                   else ut.config_condition
               end as config_condition
          from user_tables u
          left join utl_table ut     on (ut.table_name   = u.table_name)
          left join user_sequences s on (s.sequence_name = u.table_name||'_SEQ')
         where lower(u.table_name) not like '%_mvw'
           and lower(u.table_name) not in ('utl_table', 'trc_log', 'prc_session')  -- GUI uses this tables when running this process
           and ut.is_cleanup_table  = 1                                            -- clear only this tables
         order by 1
    )
    loop
        begin
            l_sql := '';
            l_msg := '';

            if i.sv_table_name is null then

                -- Table does not described in the tables dictionary
                l_msg :=  'WARNING: table ' || i.table_name || ' not exists in UTL_TABLE';

            elsif nvl(i.is_split_seq, -1) in (0, 1) then

                if trim(i.config_condition) is not null then
                    -- Need delete user data from table according "config_condition"
                    l_sql := 'delete from ' || i.table_name || ' where ' || i.config_condition || '';
                else
                    -- "config_condition" does not used for this table
                    l_sql := 'truncate table ' || i.table_name || ' drop storage';
                end if;

            end if;

            -- execute action or log message
            if l_msg    is not null
               or l_sql is not null
            then
                if l_sql is not null then
                    trc_log_pkg.debug(i_text => 'execute immediate ' || l_sql);
                    if i_test_option = 'P' then
                        execute immediate l_sql;
                    end if;
                else
                    trc_log_pkg.debug(i_text => l_msg);
                end if;
            end if;

            l_count := l_count + 1;

        exception
            when others then
                l_error_cnt := l_error_cnt + 1;

                trc_log_pkg.error(
                    i_text       => 'UNHANDLED_EXCEPTION'
                  , i_env_param1 => dbms_utility.format_error_backtrace || dbms_utility.format_error_stack  -- SQLERRM
                );
        end;
    end loop;

    if i_test_option = 'P' then
        -- reset sequences
        utl_deploy_pkg.sync_sequences(utl_deploy_pkg.INSTANCE_TYPE_PRODUCTION);
        -- recompile_invalid_packages;
    end if;

    trc_log_pkg.debug(
        i_text => 'Clear tables finished. Total '||l_count||' tables processed, '||l_error_cnt||' errors.'
    );

    prc_api_stat_pkg.log_end(
        i_result_code => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

exception
    when irresponsible_action then
        com_api_error_pkg.raise_error(
            i_error       => 'INCORRECT_APPROVEMENT_TEXT'
          , i_env_param1  => C_CONFIRMATION_TEXT
        );

    when others then
        trc_log_pkg.error(
            i_text        => 'UNHANDLED_EXCEPTION'
          , i_env_param1  => dbms_utility.format_error_backtrace || dbms_utility.format_error_stack  -- SQLERRM
        );
        prc_api_stat_pkg.log_end (
            i_result_code => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

end clear_user_tables;

end utl_prc_clear_pkg;
/
