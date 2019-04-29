create or replace package body trc_file_pkg as
/*********************************************************
 *  API for logging into file  <br />
 *  Created by Alalykin A.(alalykin@bpcbt.com)  at 03.03.2015 <br />
 *  Last changed by $Author: alalykin $ <br />
 *  $LastChangedDate:: 2015-03-03 19:00:00 +0300#$ <br />
 *  Revision: $LastChangedRevision: 1 $ <br />
 *  Module: trc_file_pkg <br />
 *  @headcom
 **********************************************************/

FIELD_DELIMETER       constant com_api_type_pkg.t_byte_char   := ',';
LINE_TERMINATOR       constant com_api_type_pkg.t_byte_char   := '\n';
LOG_DIRECTORY         constant com_api_type_pkg.t_oracle_name := 'DATA_PUMP_DIR';
MAX_BUFFER_SIZE       constant com_api_type_pkg.t_short_id    := 32767;
FILENAME_TEMPLATE     constant com_api_type_pkg.t_name        := 'trc_%SID%.log';

g_file_handle                  utl_file.file_type;
g_session_id                   com_api_type_pkg.t_long_id;
g_buffer_tab                   com_api_type_pkg.t_desc_tab; -- TO-DO: add t_text_tab
g_pointer                      com_api_type_pkg.t_tiny_id;

/*
 * Logging into a file.
 * TO-DO list, restrictions:
 * a) logging into file wasn't tested in multi-thread mode, so creating
 *    a separate file for every thread of a session may be required;
 * b) handling exceptions is required;
 * c) need some checks for string variable overflow in
 *    format_message() and flush_buffer() [for edition 1]
 * d) logging file doesn't close normally, fclose() call should be used.
 */
procedure log(
    i_trace_conf        in     trc_config_pkg.trace_conf
  , i_timestamp         in     timestamp
  , i_level             in     com_api_type_pkg.t_dict_value
  , i_user              in     com_api_type_pkg.t_oracle_name
  , i_text              in     com_api_type_pkg.t_text
  , i_entity_type       in     com_api_type_pkg.t_dict_value
  , i_object_id         in     com_api_type_pkg.t_long_id
  , i_session_id        in     com_api_type_pkg.t_long_id
  , i_thread_number     in     com_api_type_pkg.t_tiny_id
) is

    function get_filename(
        i_session_id        in     com_api_type_pkg.t_long_id
    ) return com_api_type_pkg.t_oracle_name
    is
    begin
        return replace(FILENAME_TEMPLATE, '%SID%', i_session_id);
    end;

    function format_message return com_api_type_pkg.t_text
    is
    begin
        -- TO-DO: check for result string's length
        return
            to_char(i_timestamp, com_api_const_pkg.TIMESTAMP_FORMAT) || FIELD_DELIMETER ||
            i_level         || FIELD_DELIMETER ||
            i_text          || FIELD_DELIMETER ||
            i_entity_type   || FIELD_DELIMETER ||
            i_object_id     || FIELD_DELIMETER ||
            i_thread_number || FIELD_DELIMETER ||
            i_user;
    end;

    procedure put_rec_in_buffer is
    begin
        if g_buffer_tab.count() = 0 or g_pointer >= trc_config_pkg.LOG_BUFFER_SIZE then
            g_pointer := 1;
        else
            g_pointer := g_pointer + 1;
        end if;
        g_buffer_tab(g_pointer) := format_message();
    end;

    procedure flush_buffer
    is
        --l_buffer               com_api_type_pkg.t_lob_data;
    begin
        if g_buffer_tab.count > 0 then
            -- We wish to write some logging messages with buffer flushing on end of this action
            /*
            -- Edition 1, it is a little faster but it requires additional
            -- check for overflow of <l_buffer>
            for i in g_buffer_tab.first .. g_buffer_tab.last loop
                l_buffer := l_buffer || g_buffer_tab(i) || LINE_TERMINATOR;
            end loop;
            utl_file.putf(
                file   => g_file_handle
              , format => l_buffer
            );
            --*/
            --/*
            -- Edition 2, it is a little slower then edition 1 but it doesn't
            -- require check for overflow of <l_buffer>
            for i in g_buffer_tab.first .. g_buffer_tab.last loop
                utl_file.put_line(
                    file      => g_file_handle
                  , buffer    => g_buffer_tab(i)
                  , autoflush => false
                );
            end loop;
            --*/
            utl_file.fflush(
                file   => g_file_handle
            );
            -- Clear buffer array
            g_buffer_tab.delete;
            g_pointer := 1;
        end if;
    end;

    procedure write_record
    is
    begin
        utl_file.put_line(
            file      => g_file_handle
          , buffer    => format_message()
          , autoflush => true
        );
    end write_record;

begin
/*
    if i_trace_conf.use_file = com_api_type_pkg.TRUE then
        -- Check that opened file corresponds to current user session
        if  g_session_id is null
            or
            g_session_id != i_session_id
        then
            if utl_file.is_open(file => g_file_handle) then
                --dbms_output.put_line('->fclose(' || get_filename(i_session_id => g_session_id) || ')');
                utl_file.fclose(file => g_file_handle);
            end if;

            g_session_id := i_session_id;

            --dbms_output.put_line('->fopen(' || get_filename(i_session_id => g_session_id) || ')');
            g_file_handle :=
                utl_file.fopen(
                    location     => LOG_DIRECTORY
                  , filename     => get_filename(i_session_id => g_session_id)
                  , open_mode    => 'a' -- Append
                  , max_linesize => MAX_BUFFER_SIZE
                );
        end if;

        -- LOG_MODE = 'On error'
        if i_trace_conf.log_mode = trc_config_pkg.LOG_MODE_ON_ERROR then
            -- if not error
            if i_level in (trc_api_const_pkg.TRACE_LEVEL_DEBUG) then
                -- buffer filling cycle, <g_pointer> is the index
                put_rec_in_buffer();
            elsif i_level in (trc_api_const_pkg.TRACE_LEVEL_INFO
                            , trc_api_const_pkg.TRACE_LEVEL_WARNING)
            then
                write_record();
            elsif i_level in (trc_api_const_pkg.TRACE_LEVEL_ERROR
                            , trc_api_const_pkg.TRACE_LEVEL_FATAL)
            then
                flush_buffer();
                write_record();
            end if;

        -- LOG_MODE = 'Suspended recording'
        elsif i_trace_conf.log_mode = trc_config_pkg.LOG_MODE_SUSPENDED then
            -- Buffered logging
            put_rec_in_buffer();
            -- Buffer is flushed on error or when it is full
            if  i_level in (trc_api_const_pkg.TRACE_LEVEL_ERROR
                          , trc_api_const_pkg.TRACE_LEVEL_FATAL)
                or
                g_buffer_tab.count() >= trc_config_pkg.LOG_BUFFER_SIZE
            then
                flush_buffer();
            end if;

        -- LOG_MODE = 'Immediate saving'
        else
            write_record();
        end if;
    end if;
*/
    null;
end log;

end;
/
