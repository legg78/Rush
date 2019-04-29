create or replace package body trc_table_pkg as
/*********************************************************
 *  API for trc_log table <br />
 *  Created by Filimonov A.(filimonov@bpcbt.com)  at 02.07.2009 <br />
 *  Module: trc_table_pkg <br />
 *  @headcom
 **********************************************************/

g_log_tab                       com_api_type_pkg.t_trc_log_tab;
g_tab_pointer                   com_api_type_pkg.t_tiny_id;
g_log_buffer_size               com_api_type_pkg.t_byte_id      := trc_config_pkg.LOG_BUFFER_SIZE;

procedure log(
    i_trace_conf        in      trc_config_pkg.trace_conf
  , i_timestamp         in      timestamp
  , i_level             in      com_api_type_pkg.t_dict_value
  , i_section           in      com_api_type_pkg.t_full_desc
  , i_user              in      com_api_type_pkg.t_oracle_name
  , i_text              in      com_api_type_pkg.t_text
  , i_entity_type       in      com_api_type_pkg.t_dict_value       default null
  , i_object_id         in      com_api_type_pkg.t_long_id          default null
  , i_event_id          in      com_api_type_pkg.t_tiny_id          default null
  , i_label_id          in      com_api_type_pkg.t_short_id         default null
  , i_inst_id           in      com_api_type_pkg.t_tiny_id          default null
  , i_session_id        in      com_api_type_pkg.t_long_id          default null
  , i_thread_number     in      com_api_type_pkg.t_tiny_id          default null
  , i_who_called        in      com_api_type_pkg.t_name
  , i_trace_count       in      com_api_type_pkg.t_long_id          default null
  , i_level_code        in      com_api_type_pkg.t_tiny_id          default null
  , i_text_mode         in      com_api_type_pkg.t_boolean          default null
  , i_env_param1        in      com_api_type_pkg.t_full_desc        default null
  , i_env_param2        in      com_api_type_pkg.t_name             default null
  , i_env_param3        in      com_api_type_pkg.t_name             default null
  , i_env_param4        in      com_api_type_pkg.t_name             default null
  , i_env_param5        in      com_api_type_pkg.t_name             default null
  , i_env_param6        in      com_api_type_pkg.t_name             default null
) is

    procedure put_rec_in_buffer is
        l_temp_log_tab          com_api_type_pkg.t_trc_log_tab;
        l_save_tab_pointer      com_api_type_pkg.t_tiny_id;
    begin
        -- Change log buffer size when it is required
        if g_log_buffer_size != i_trace_conf.error_trace_size then
            if g_log_tab.count > 0 then
                l_save_tab_pointer := g_tab_pointer;
                g_tab_pointer      := 0;
                for i in reverse 1 .. l_save_tab_pointer loop
                    exit when g_tab_pointer       >= i_trace_conf.error_trace_size;
                    g_tab_pointer                 := g_tab_pointer + 1;
                    l_temp_log_tab(g_tab_pointer) := g_log_tab(i);
                end loop;
                if g_log_tab.count > l_save_tab_pointer then
                    for i in reverse (g_log_buffer_size - l_save_tab_pointer + 1) .. g_log_buffer_size loop
                        exit when g_tab_pointer       >= i_trace_conf.error_trace_size;
                        g_tab_pointer                 := g_tab_pointer + 1;
                        l_temp_log_tab(g_tab_pointer) := g_log_tab(i);
                    end loop;
                end if;
                g_log_tab     := l_temp_log_tab;
            end if;
            g_log_buffer_size := i_trace_conf.error_trace_size;
        end if;

        -- Move pointer of log buffer
        if g_log_tab.count = 0 or g_tab_pointer >= g_log_buffer_size then
            g_tab_pointer := 1;
        else
            g_tab_pointer := g_tab_pointer + 1;
        end if;

        g_log_tab(g_tab_pointer).i_timestamp   := i_timestamp;
        g_log_tab(g_tab_pointer).level         := i_level;
        g_log_tab(g_tab_pointer).section       := i_section;
        g_log_tab(g_tab_pointer).text          := i_text;
        g_log_tab(g_tab_pointer).user          := i_user;
        g_log_tab(g_tab_pointer).entity_type   := i_entity_type;
        g_log_tab(g_tab_pointer).object_id     := i_object_id;
        g_log_tab(g_tab_pointer).event_id      := i_event_id;
        g_log_tab(g_tab_pointer).label_id      := i_label_id;
        g_log_tab(g_tab_pointer).inst_id       := i_inst_id;
        g_log_tab(g_tab_pointer).session_id    := i_session_id;
        g_log_tab(g_tab_pointer).thread_number := i_thread_number;
        g_log_tab(g_tab_pointer).who_called    := lower(i_who_called);
        g_log_tab(g_tab_pointer).level_code    := i_level_code;
        g_log_tab(g_tab_pointer).text_mode     := i_text_mode;
        g_log_tab(g_tab_pointer).env_param1    := i_env_param1;
        g_log_tab(g_tab_pointer).env_param2    := i_env_param2;
        g_log_tab(g_tab_pointer).env_param3    := i_env_param3;
        g_log_tab(g_tab_pointer).env_param4    := i_env_param4;
        g_log_tab(g_tab_pointer).env_param5    := i_env_param5;
        g_log_tab(g_tab_pointer).env_param6    := i_env_param6;
    end;
    --
    procedure save_buffer is
        pragma autonomous_transaction;

        l_text    com_api_type_pkg.t_text;
    begin
        if i_trace_conf.use_table = com_api_type_pkg.TRUE
           and g_log_tab.count > 0
        then
            if i_trace_conf.log_mode = trc_config_pkg.LOG_MODE_ON_ERROR then
                for i in g_log_tab.first .. g_log_tab.last loop
                    l_text := g_log_tab(i).text;

                    trc_text_pkg.get_text(
                        i_level       =>  g_log_tab(i).level_code
                      , io_text       =>  l_text
                      , i_env_param1  =>  g_log_tab(i).env_param1
                      , i_env_param2  =>  g_log_tab(i).env_param2
                      , i_env_param3  =>  g_log_tab(i).env_param3
                      , i_env_param4  =>  g_log_tab(i).env_param4
                      , i_env_param5  =>  g_log_tab(i).env_param5
                      , i_env_param6  =>  g_log_tab(i).env_param6
                      , i_get_text    =>  g_log_tab(i).text_mode
                      , o_label_id    =>  g_log_tab(i).label_id
                      , o_param_text  =>  g_log_tab(i).text
                    );
                end loop;
            end if;

            forall i in g_log_tab.first .. g_log_tab.last
                insert into trc_log (
                    trace_timestamp
                  , trace_level
                  , trace_section
                  , trace_text
                  , user_id
                  , entity_type
                  , object_id
                  , event_id
                  , label_id
                  , inst_id
                  , session_id
                  , thread_number
                  , who_called
                ) values (
                    g_log_tab(i).i_timestamp
                  , g_log_tab(i).level
                  , g_log_tab(i).section
                  , g_log_tab(i).text
                  , g_log_tab(i).user
                  , g_log_tab(i).entity_type
                  , g_log_tab(i).object_id
                  , g_log_tab(i).event_id
                  , g_log_tab(i).label_id
                  , g_log_tab(i).inst_id
                  , g_log_tab(i).session_id
                  , g_log_tab(i).thread_number
                  , g_log_tab(i).who_called
                );
            commit write nowait;
        end if;
        -- clear buffer
        g_log_tab.delete;
        g_tab_pointer := 1;
    exception
        when others then
            rollback;
            dbms_output.put_line(sqlerrm);
            dbms_output.put_line(trc_log_pkg.get_error_stack());
            raise;
    end save_buffer;
    --
    procedure save_record
    is
        pragma autonomous_transaction;
    begin
        if i_trace_conf.use_table = com_api_type_pkg.TRUE then
            insert into trc_log (
                trace_timestamp
              , trace_level
              , trace_section
              , trace_text
              , user_id
              , entity_type
              , object_id
              , event_id
              , label_id
              , inst_id
              , session_id
              , thread_number
              , who_called
            ) values (
                i_timestamp
              , i_level
              , i_section
              , i_text
              , i_user
              , i_entity_type
              , i_object_id
              , i_event_id
              , i_label_id
              , i_inst_id
              , i_session_id
              , i_thread_number
              , lower(i_who_called)
            );
            commit write nowait;
        end if;
    exception
        when others then
            rollback;
            dbms_output.put_line(sqlerrm);
            dbms_output.put_line(trc_log_pkg.get_error_stack());
            raise;
    end save_record;
    --
begin
    -- LOG_MODE = 'On error'
    if i_trace_conf.log_mode = trc_config_pkg.LOG_MODE_ON_ERROR then
        -- if not error
        if i_level in (trc_api_const_pkg.TRACE_LEVEL_DEBUG
                     , trc_api_const_pkg.TRACE_LEVEL_INFO)
        then
            if i_trace_count > nvl(i_trace_conf.start_trace_size, -1) then
                -- if buffer overflow - shift buffer on 1 record up
                put_rec_in_buffer;
            else
                save_record;
            end if;
        elsif i_level in (trc_api_const_pkg.TRACE_LEVEL_WARNING)
        then
            save_record;
        elsif i_level in (trc_api_const_pkg.TRACE_LEVEL_ERROR
                        , trc_api_const_pkg.TRACE_LEVEL_FATAL)
        then
            save_buffer;
            save_record;
        end if;
    -- LOG_MODE = 'Suspended recording'
    elsif i_trace_conf.log_mode = trc_config_pkg.LOG_MODE_SUSPENDED then
        -- if error
        if i_level in (trc_api_const_pkg.TRACE_LEVEL_ERROR
                     , trc_api_const_pkg.TRACE_LEVEL_FATAL)
        then
            save_buffer;
            save_record;
        else
            put_rec_in_buffer;
            -- if buffer overflows
            if g_log_tab.count >= g_log_buffer_size then
                save_buffer;
            end if;
        end if;
    else
        save_record;
    end if;
exception
    when others then
        dbms_output.put_line(sqlerrm);
        dbms_output.put_line(trc_log_pkg.get_error_stack());
        dbms_output.put_line('sizeof(i_text) = ' || lengthb(i_text) || ', i_text:' || chr(13) || chr(10) || i_text);
        raise;
end log;

end;
/
