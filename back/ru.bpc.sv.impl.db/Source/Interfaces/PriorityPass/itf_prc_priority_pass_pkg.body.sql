create or replace package body itf_prc_priority_pass_pkg is
/************************************************************
 * Priority Pass Card Processes <br />
 * Created by Alalykin A.(alalykin@bpcbt.com) at 29.01.2015 <br />
 * Last changed by $Author: alalykin $ <br />
 * $LastChangedDate:: 2015-01-29 17:00:00 +0400#$ <br />
 * Revision: $LastChangedRevision: 1 $ <br />
 * Module: itf_prc_priority_pass_pkg <br />
 * @headcom
 ************************************************************/

BULK_LIMIT          constant com_api_type_pkg.t_count       := 100;
CSV_DELIMITER       constant com_api_type_pkg.t_byte_char   := ',';
CRLF                constant com_api_type_pkg.t_oracle_name := chr(13) || chr(10);

/*
 * Processing of Priority Pass lounge visits.
 */
procedure process_lounge_visits
is
    LOG_PREFIX      constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_lounge_visits: ';

    cursor cur_raw_data(
        p_session_file_id    in com_api_type_pkg.t_long_id
    ) is
        select record_number
             , raw_data
             --, row_number() over (order by record_number) as rn 
             --, count(*) over () as cnt
          from prc_file_raw_data
         where session_file_id = p_session_file_id
      order by record_number;
    
    type t_raw_data_tab is table of cur_raw_data%rowtype index by pls_integer;

    l_records_tab            t_raw_data_tab;
    l_current_index          com_api_type_pkg.t_count := 0;
    -- Count of records in a current file
    l_current_count          com_api_type_pkg.t_count := 0;
    -- Failed records in all unsuccessfully processed files 
    l_failed_count           com_api_type_pkg.t_count := 0;
    -- Total records in all processed files
    l_total_count            com_api_type_pkg.t_count := 0;
    -- Associative array is used to storage values of a line that are delimited by CSV_DELIMITER 
    l_fields_tab             com_api_type_pkg.t_name_tab;
    
    -- Logging primary estimation of records count for in all files of a current session
    procedure log_estimation
    is
        l_count                  com_api_type_pkg.t_count := 0;
    begin
        select count(*) as cnt
          into l_count
          from prc_file_raw_data rd
          join prc_session_file sf  on sf.id = rd.session_file_id 
         where sf.session_id = prc_api_session_pkg.get_session_id();

        prc_api_stat_pkg.log_estimation(
            i_estimated_count => l_count
        );
    end;
    
    function split_values(
        i_line            in     com_api_type_pkg.t_text
    ) return com_api_type_pkg.t_name_tab
    is
        l_string_tab             com_api_type_pkg.t_name_tab;
    begin
        -- Usage of regular expression may be less efficient than trivial PL/SQL
        -- realization, so performance analysis is desired 
         select trim(regexp_substr(i_line, '[^' || CSV_DELIMITER || ']+', 1, level))
           bulk collect into l_string_tab
           from dual 
        connect by instr(i_line, CSV_DELIMITER, 1, level-1) > 0; 

        return l_string_tab;
    end;
    
    -- For debugging
    function list_splitted_values(
        i_string_tab      in     com_api_type_pkg.t_name_tab
    ) return com_api_type_pkg.t_text 
    is
        l_text                   com_api_type_pkg.t_text;
    begin
        for i in i_string_tab.first() .. i_string_tab.last() loop
            l_text := l_text || CRLF
                   || 'field(' || i || ') = [' || i_string_tab(i) || ']';
        end loop;

        return l_text;
    end;
    
    -- It return TRUE if i_string_tab is zero-size of contains only NULL values  
    function values_are_empty(
        i_string_tab      in     com_api_type_pkg.t_name_tab
    ) return com_api_type_pkg.t_boolean
    is
        l_result                 com_api_type_pkg.t_boolean;
        i                        pls_integer;
    begin
        i := i_string_tab.first();
        while i <= i_string_tab.last() and i_string_tab(i) is null loop
            i := i_string_tab.next(i);
        end loop;
        
        if i_string_tab.count() = 0 or i is null then
            trc_log_pkg.debug(LOG_PREFIX || ' values_are_empty() = TRUE');
            l_result := com_api_type_pkg.TRUE;
        else
            l_result := com_api_type_pkg.FALSE;
        end if;
        
        return l_result;
    end;

    procedure register_operation(
        i_fields_tab      in     com_api_type_pkg.t_name_tab
      , i_session_file_id in     com_api_type_pkg.t_long_id
    ) is
        l_operation_id           com_api_type_pkg.t_long_id;
    begin
        opr_api_create_pkg.create_operation(
            io_oper_id              => l_operation_id
          , i_session_id            => prc_api_session_pkg.get_session_id()
          , i_is_reversal           => com_api_type_pkg.FALSE
          , i_oper_type             => opr_api_const_pkg.OPERATION_TYPE_PRY_PASS_LOUNGE
          , i_msg_type              => opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
          , i_status                => opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY
          , i_sttl_type             => opr_api_const_pkg.SETTLEMENT_THEMONUS
          , i_merchant_number       => i_fields_tab(6)    -- Lounge Code
          , i_merchant_name         => i_fields_tab(5)    -- Lounge Name
          , i_merchant_country      => com_api_country_pkg.get_country_code_by_name(
                                           i_name        => i_fields_tab(7) -- Country Code
                                         , i_raise_error => com_api_type_pkg.FALSE
                                       )
          , i_originator_refnum     => i_fields_tab(13)   -- Voucher Number
          , i_oper_count            => i_fields_tab(8)+1  -- Guests + 1
          , i_oper_amount           => i_fields_tab(11)   -- Total Fee
          , i_oper_currency         => com_api_currency_pkg.USDOLLAR
          , i_oper_date             => to_date(i_fields_tab(4), com_api_const_pkg.XML_DATE_FORMAT) -- Visit
          , i_host_date             => com_api_sttl_day_pkg.get_sysdate()
          , i_match_status          => opr_api_const_pkg.OPERATION_MATCH_DONT_REQ_MATCH
          , i_incom_sess_file_id    => i_session_file_id
        );
        opr_api_create_pkg.add_participant(
            i_oper_id               => l_operation_id
          , i_msg_type              => opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
          , i_oper_type             => opr_api_const_pkg.OPERATION_TYPE_PRY_PASS_LOUNGE
          , i_participant_type      => com_api_const_pkg.PARTICIPANT_ISSUER
          , i_host_date             => com_api_sttl_day_pkg.get_sysdate()
          , i_client_id_type        => opr_api_const_pkg.CLIENT_ID_TYPE_CARD
          , i_client_id_value       => i_fields_tab(2)    -- Priority Pass ID
        );
    end;

begin
    trc_log_pkg.debug(LOG_PREFIX || 'START');
    prc_api_stat_pkg.log_start();
    log_estimation();

    -- Process all files of the current session one by one
    for f in (
        select id as session_file_id
          from prc_session_file
         where session_id = prc_api_session_pkg.get_session_id()
      order by id
    ) loop
        trc_log_pkg.debug(LOG_PREFIX || 'processing session_file_id [' || f.session_file_id || ']');
        -- If some record (string) in a current file leads to error raising,
        -- mark entire file as unprocessed (all its records are failed)
        savepoint sp_start_file_processing;
        begin
            l_current_count := 0;

            open cur_raw_data(p_session_file_id => f.session_file_id);
            loop
                fetch cur_raw_data bulk collect into l_records_tab limit BULK_LIMIT;
                
                for i in l_records_tab.first() .. l_records_tab.last() loop
                    l_current_index := i; -- for debug

                    -- Split a line of current CSV file into values and register operation with participant
                    l_fields_tab := split_values(i_line => l_records_tab(i).raw_data);
                    
                    -- Register an operation with a participant (skip empty line)   
                    if values_are_empty(i_string_tab => l_fields_tab) = com_api_type_pkg.FALSE then
                        register_operation(
                            i_fields_tab      => l_fields_tab
                          , i_session_file_id => f.session_file_id
                        );
                        l_current_count := l_current_count + 1;
                    end if;
                end loop;

                prc_api_stat_pkg.log_current(
                    i_current_count  => l_total_count + l_current_count
                  , i_excepted_count => l_failed_count
                );
                
                exit when cur_raw_data%notfound;
            end loop;
            close cur_raw_data;

            prc_api_file_pkg.close_file(
                i_sess_file_id => f.session_file_id
              , i_status       => prc_api_const_pkg.FILE_STATUS_ACCEPTED
            );

            l_total_count := l_total_count + l_current_count;
            
            prc_api_stat_pkg.log_current(
                i_current_count  => l_total_count
              , i_excepted_count => l_failed_count
            );
        exception
            when com_api_error_pkg.e_application_error then
                rollback to sp_start_file_processing;

                trc_log_pkg.debug(
                    LOG_PREFIX || 'FAILED on line [' || l_records_tab(l_current_index).record_number
                               || '], l_records_tab(' || l_current_index
                               || ') = [' || l_records_tab(l_current_index).raw_data || '];'
                               || CRLF || 'l_fields_tab:'
                               || list_splitted_values(l_fields_tab)
                );
                -- Mark all records of a current file as unsuccessfully processed  
                l_failed_count := l_failed_count + l_current_count;
                l_total_count  := l_total_count  + l_current_count;

                prc_api_stat_pkg.log_current(
                    i_current_count  => l_total_count
                  , i_excepted_count => l_failed_count
                );
                prc_api_file_pkg.close_file(
                    i_sess_file_id   => f.session_file_id
                  , i_status         => prc_api_const_pkg.FILE_STATUS_REJECTED
                );
                raise;
        end;
        trc_log_pkg.debug(LOG_PREFIX || 'session_file_id [' || f.session_file_id
                                     || '] was processed, records count [' || l_current_count || ']');
    end loop;

    prc_api_stat_pkg.log_end(
        i_result_code => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
    trc_log_pkg.debug(LOG_PREFIX || 'END');
exception
    when others then
        if cur_raw_data%isopen then
            close cur_raw_data;
        end if;

        prc_api_stat_pkg.log_end(
            i_result_code => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );
        if  com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE
            or
            com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE
        then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end process_lounge_visits;

end; 
/
