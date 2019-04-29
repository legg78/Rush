create or replace package body cst_ap_prc_incoming_pkg is
/************************************************************
 * Processes for loading files <br />
 * Created by Gogolev I.(i.gogolev@bpcbt.com)  at 10.03.2019 <br />
 * Last changed by $Author: Gogolev I. $ <br />
 * $LastChangedDate:: #$ <br />
 * Revision: $LastChangedRevision:  $ <br />
 * Module: cst_ap_prc_incoming_pkg <br />
 * @headcom
 ***********************************************************/
procedure process_loading_synt(
    i_file_type     in  com_api_type_pkg.t_dict_value
) is
    LOG_PREFIX           constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_loading_synt: ';
    
    l_record_count_all_files      com_api_type_pkg.t_long_id := 0;
    l_record_number               com_api_type_pkg.t_long_id := 0;
    l_processed_count             com_api_type_pkg.t_long_id := 0;
    l_excepted_count              com_api_type_pkg.t_long_id := 0;
    l_rejected_count              com_api_type_pkg.t_long_id := 0;
    l_rec                         com_api_type_pkg.t_text;
    
    l_session_date                date;
    l_session_file_id             com_api_type_pkg.t_long_id;
    l_synt_file_tab               cst_ap_api_type_pkg.t_synt_file_tab;
    l_index                       com_api_type_pkg.t_long_id := 0;
    l_detail_count                com_api_type_pkg.t_long_id := 0;
    l_file_type                   com_api_type_pkg.t_dict_value;
begin
    prc_api_stat_pkg.log_start;
    
    select sum(decode(nvl(p.record_count, 0), 0, 0, p.record_count - 2))
      into l_record_count_all_files
      from prc_session_file p
     where session_id = prc_api_session_pkg.get_session_id
       and exists(select 1
                    from prc_file_raw_data r
                   where r.session_file_id = p.id
                     and case
                             when i_file_type = cst_ap_api_const_pkg.FILE_TYPE_SYNTI 
                                 and substr(r.raw_data, 25, 5) = cst_ap_api_const_pkg.SYNTI_IN_HEADER_SPEC
                                 then com_api_const_pkg.TRUE
                             when i_file_type = cst_ap_api_const_pkg.FILE_TYPE_SYNTO
                                 and substr(r.raw_data, 25, 5) = cst_ap_api_const_pkg.SYNTO_IN_HEADER_SPEC
                                 then com_api_const_pkg.TRUE
                             when i_file_type = cst_ap_api_const_pkg.FILE_TYPE_SYNTR
                                 and substr(r.raw_data, 25, 5) = cst_ap_api_const_pkg.SYNTR_IN_HEADER_SPEC
                                 then com_api_const_pkg.TRUE
                             when i_file_type is null
                                 and substr(r.raw_data, 25, 5) in (
                                         cst_ap_api_const_pkg.SYNTI_IN_HEADER_SPEC
                                       , cst_ap_api_const_pkg.SYNTO_IN_HEADER_SPEC
                                       , cst_ap_api_const_pkg.SYNTR_IN_HEADER_SPEC
                                     )
                                 then com_api_const_pkg.TRUE
                             else com_api_const_pkg.FALSE
                          end = com_api_const_pkg.TRUE
                 );
    
    prc_api_stat_pkg.log_estimation(
        i_estimated_count     => l_record_count_all_files
    );
    
    for p in (
        select id session_file_id
             , record_count
             , file_name
          from prc_session_file p
         where session_id = prc_api_session_pkg.get_session_id
         and exists(select 1
                      from prc_file_raw_data r
                     where r.session_file_id = p.id
                       and case
                               when i_file_type = cst_ap_api_const_pkg.FILE_TYPE_SYNTI 
                                   and substr(r.raw_data, 25, 5) = cst_ap_api_const_pkg.SYNTI_IN_HEADER_SPEC
                                   then com_api_const_pkg.TRUE
                               when i_file_type = cst_ap_api_const_pkg.FILE_TYPE_SYNTO
                                   and substr(r.raw_data, 25, 5) = cst_ap_api_const_pkg.SYNTO_IN_HEADER_SPEC
                                   then com_api_const_pkg.TRUE
                               when i_file_type = cst_ap_api_const_pkg.FILE_TYPE_SYNTR
                                   and substr(r.raw_data, 25, 5) = cst_ap_api_const_pkg.SYNTR_IN_HEADER_SPEC
                                   then com_api_const_pkg.TRUE
                               when i_file_type is null
                                   and substr(r.raw_data, 25, 5) in (
                                           cst_ap_api_const_pkg.SYNTI_IN_HEADER_SPEC
                                         , cst_ap_api_const_pkg.SYNTO_IN_HEADER_SPEC
                                         , cst_ap_api_const_pkg.SYNTR_IN_HEADER_SPEC
                                       )
                                   then com_api_const_pkg.TRUE
                               else com_api_const_pkg.FALSE
                            end = com_api_const_pkg.TRUE
                   )
         order by id
    ) 
    loop
        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'Processing session_file_id [' || p.session_file_id 
                   || '], record_count [' || p.record_count 
                   || '], file_name [' || p.file_name || ']'
        );
        
        l_session_file_id := p.session_file_id;
        l_index := null;
        if l_synt_file_tab.count > 0 then
            l_synt_file_tab.delete;
        end if;
        l_session_date := null;
        l_file_type    := null;
        l_detail_count := p.record_count;
        begin
            for r in (
                select record_number
                     , raw_data
                  from prc_file_raw_data
                 where session_file_id = p.session_file_id
                 order by record_number
            )
            loop
                l_record_number := r.record_number;
                l_rec := r.raw_data;
                if substr(l_rec, 1, 4) in ('ESYI', 'ESYR', 'ESYO') then
                    l_session_date := to_date(substr(l_rec, 11, 8), 'yyyymmdd');
                    l_file_type    := substr(l_rec, 25, 5); 
                elsif substr(l_rec, 1, 4) in ('ERGS', 'CREG') then
                    if l_index is null then
                        l_index := 1;
                    else
                        l_index := l_synt_file_tab.last + 1;
                    end if;
                    l_synt_file_tab(l_index).session_file_id  := l_session_file_id;
                    l_synt_file_tab(l_index).file_type        := l_file_type;
                    l_synt_file_tab(l_index).session_day      := l_session_date;
                    l_synt_file_tab(l_index).opr_type         := to_number(substr(l_rec, 5, 3));
                    l_synt_file_tab(l_index).bank_id          := substr(l_rec, 8, 3);
                    if l_file_type = cst_ap_api_const_pkg.SYNTR_IN_HEADER_SPEC then
                        l_synt_file_tab(l_index).oper_cnt       := null;
                        l_synt_file_tab(l_index).oper_amount    := to_number(substr(l_rec, 11, 16));
                        l_synt_file_tab(l_index).balance_impact := case substr(l_rec, 27, 1)
                                                                       when 'D'
                                                                           then com_api_const_pkg.DEBIT
                                                                       when 'C'
                                                                           then com_api_const_pkg.CREDIT
                                                                       else null
                                                                   end;
                    else
                        l_synt_file_tab(l_index).oper_cnt       := to_number(substr(l_rec, 11, 16));
                        l_synt_file_tab(l_index).oper_amount    := to_number(substr(l_rec, 27, 16));
                        l_synt_file_tab(l_index).balance_impact := null;
                    end if;
                else
                    null;
                end if;
            end loop;
                
            prc_api_file_pkg.close_file(
                i_sess_file_id          => p.session_file_id
              , i_status                => prc_api_const_pkg.FILE_STATUS_ACCEPTED
            );
        exception
            when others then
                prc_api_file_pkg.close_file(
                    i_sess_file_id          => p.session_file_id
                  , i_status                => prc_api_const_pkg.FILE_STATUS_REJECTED
                );
                com_api_error_pkg.raise_fatal_error(
                    i_error      => 'WRONG_STRUCTURE_FIN_MESSAGE'
                  , i_env_param1 => 'INVALID FILE - ' || l_session_file_id
                ); 
        end;
            
        if l_synt_file_tab.count > 0 then
            trc_log_pkg.debug(
                i_text       => LOG_PREFIX || 'All detail record in file [#1], put detail record in collection [#2]'
              , i_env_param1 => l_detail_count
              , i_env_param2 => l_synt_file_tab.count
            );
                
            cst_ap_api_process_pkg.insert_into_ap_synt_tab(
                i_ap_synt_tab        => l_synt_file_tab
            ); 
            l_processed_count := l_processed_count + l_synt_file_tab.count;
        end if;
    end loop;
    
    prc_api_stat_pkg.log_end(
        i_processed_total  => l_processed_count
      , i_excepted_total   => l_excepted_count
      , i_rejected_total   => l_rejected_count
      , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug(LOG_PREFIX || 'END');
exception
    when others then
        prc_api_stat_pkg.log_end(
            i_result_code      => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        else
            trc_log_pkg.debug(
                i_text       => LOG_PREFIX || 'FAILED with l_record_number [#1] l_rec [#2]' 
              , i_env_param1 => l_record_number
              , i_env_param2 => l_rec
            );
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end process_loading_synt;

procedure process_loading_dategen
is
    LOG_PREFIX           constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_loading_dategen: ';
    
    l_record_count_all_files      com_api_type_pkg.t_long_id := 0;
    l_record_number               com_api_type_pkg.t_long_id := 0;
    l_processed_count             com_api_type_pkg.t_long_id := 0;
    l_excepted_count              com_api_type_pkg.t_long_id := 0;
    l_rejected_count              com_api_type_pkg.t_long_id := 0;
    l_rec                         com_api_type_pkg.t_text;
    
    l_session_file_id             com_api_type_pkg.t_long_id;
begin
    prc_api_stat_pkg.log_start;
    
    select sum(nvl(p.record_count, 0))
      into l_record_count_all_files
      from prc_session_file p
     where session_id = prc_api_session_pkg.get_session_id
       and exists(select 1
                    from prc_file_raw_data r
                   where r.session_file_id = p.id
                     and trim(replace(replace(r.raw_data, chr(10), ''), chr(13), '')) is not null
                 );
    
    prc_api_stat_pkg.log_estimation(
        i_estimated_count     => l_record_count_all_files
    );
    
    for p in (
        select id session_file_id
             , record_count
             , file_name
          from prc_session_file p
         where session_id = prc_api_session_pkg.get_session_id
         and exists(select 1
                      from prc_file_raw_data r
                     where r.session_file_id = p.id
                       and trim(replace(replace(r.raw_data, chr(10), ''), chr(13), '')) is not null
                   )
         order by id
    ) 
    loop
        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'Processing session_file_id [' || p.session_file_id 
                   || '], record_count [' || p.record_count 
                   || '], file_name [' || p.file_name || ']'
        );
        
        l_session_file_id := p.session_file_id;
        begin
            for r in (
                select record_number
                     , trim(replace(replace(raw_data, chr(10), ''), chr(13), '')) raw_data
                  from prc_file_raw_data
                 where session_file_id = p.session_file_id
                 order by record_number
            )
            loop
                l_record_number := r.record_number;
                l_rec := r.raw_data;
                cst_ap_api_process_pkg.insert_into_ap_session_tab(
                    i_date_text         => l_rec
                  , i_session_file_id   => l_session_file_id
                ); 
                l_processed_count := l_processed_count + 1;
            end loop;
                
            prc_api_file_pkg.close_file(
                i_sess_file_id          => p.session_file_id
              , i_status                => prc_api_const_pkg.FILE_STATUS_ACCEPTED
            );
        exception
            when others then
                prc_api_file_pkg.close_file(
                    i_sess_file_id          => p.session_file_id
                  , i_status                => prc_api_const_pkg.FILE_STATUS_REJECTED
                );
                com_api_error_pkg.raise_fatal_error(
                    i_error      => 'WRONG_STRUCTURE_FIN_MESSAGE'
                  , i_env_param1 => 'INVALID FILE - ' || l_session_file_id
                ); 
        end;

    end loop;
    
    prc_api_stat_pkg.log_end(
        i_processed_total  => l_processed_count
      , i_excepted_total   => l_excepted_count
      , i_rejected_total   => l_rejected_count
      , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug(LOG_PREFIX || 'END');
exception
    when others then
        prc_api_stat_pkg.log_end(
            i_result_code      => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        else
            trc_log_pkg.debug(
                i_text       => LOG_PREFIX || 'FAILED with l_record_number [#1] l_rec [#2]' 
              , i_env_param1 => l_record_number
              , i_env_param2 => l_rec
            );
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end process_loading_dategen;

end cst_ap_prc_incoming_pkg;
/
