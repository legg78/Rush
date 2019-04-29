create or replace package body cst_ap_cro_load_pkg is
/************************************************************
 * Processes for loading CRO files <br />
 * Created by Vasilyeva Y.(vasilieva@bpcbt.com)  at 25.02.2019 <br />
 * Last changed by $Author: Vasilyeva Y. $ <br />
 * $LastChangedDate:: #$ <br />
 * Revision: $LastChangedRevision:  $ <br />
 * Module: cst_smt_prc_incoming_pkg <br />
 * @headcom
 ***********************************************************/

procedure process_record(
    i_rec                   in com_api_type_pkg.t_text
  , i_incom_sess_file_id    in com_api_type_pkg.t_long_id
  , i_match_status          in com_api_type_pkg.t_dict_value
  , o_processed             out com_api_type_pkg.t_boolean
  , o_excepted              out com_api_type_pkg.t_boolean
  , o_not_found             out com_api_type_pkg.t_boolean
)
is
    LOG_PREFIX          constant com_api_type_pkg.t_name   := lower($$PLSQL_UNIT) || '.process_record: ';
    l_cro_rec                    cst_ap_api_type_pkg.t_cro_rec;
    l_oper_id                    com_api_type_pkg.t_long_id;
    cursor l_match_oper_cur(
                i_match_status    in com_api_type_pkg.t_dict_value
              , i_transaction_num in com_api_type_pkg.t_card_number
           ) is
        select o.id
          from opr_operation o
    inner join aut_auth a on o.id = a.id
         where a.external_auth_id = i_transaction_num
           and (i_match_status = cst_ap_api_const_pkg.ENV_LOADED
           and o.match_status = cst_ap_api_const_pkg.ENV_LOADED
            or i_match_status = cst_ap_api_const_pkg.CRO_ASP_PROCDESSED
           and o.match_status in (cst_ap_api_const_pkg.CRO_ASP_PROCDESSED));
                   
begin
    l_cro_rec.oper_code        := substr(i_rec, 20, 2); 
    l_cro_rec.transaction_num  := substr(i_rec, 65, 12); 
    
    open l_match_oper_cur(
             i_match_status    => process_record.i_match_status
           , i_transaction_num => to_number(l_cro_rec.transaction_num)
         );
    fetch  l_match_oper_cur into l_oper_id;
    if l_match_oper_cur%NOTFOUND then
        o_excepted  := 1;
        o_not_found := 1;
        prc_api_file_pkg.close_file(
            i_sess_file_id          => i_incom_sess_file_id
          , i_status                => prc_api_const_pkg.FILE_STATUS_REJECTED
        );
        com_api_error_pkg.raise_error(
            i_error      => LOG_PREFIX||' No transaction found for external id = '||to_number(l_cro_rec.transaction_num)||' matcjing status ='||process_record.i_match_status
        ); 
    else
        update opr_operation o
        set o.match_status = case i_match_status
                             when cst_ap_api_const_pkg.ENV_LOADED then cst_ap_api_const_pkg.CRO_ASP_PROCDESSED
                             when cst_ap_api_const_pkg.CRO_ASP_PROCDESSED then cst_ap_api_const_pkg.CRO_ADT_PROCDESSED
                             end
        where o.id = l_oper_id;
        o_processed := 1;
    end if;
    close l_match_oper_cur;
exception when others then
    o_excepted := 1;
    trc_log_pkg.error(
        i_text          => 'UNHANDLED_EXCEPTION'
      , i_env_param1    => sqlerrm
    );
end;
 
procedure process_cro
is 
    LOG_PREFIX           constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_msstrxn: ';
    
    l_record_count_all_files      com_api_type_pkg.t_long_id := 0;
    l_record_count                com_api_type_pkg.t_long_id := 0;
    l_processed_count             com_api_type_pkg.t_long_id := 0;
    l_excepted_count              com_api_type_pkg.t_long_id := 0;
    l_processed                   com_api_type_pkg.t_boolean;
    l_excepted                    com_api_type_pkg.t_boolean;
    l_not_found                   com_api_type_pkg.t_boolean := 0;
    
    l_match_status                com_api_type_pkg.t_dict_value;
    l_session_file_id             com_api_type_pkg.t_long_id;
    
    l_string_tab            com_api_type_pkg.t_desc_tab;
    l_record_number_tab     com_api_type_pkg.t_short_tab;
    l_string_limit          com_api_type_pkg.t_short_id := 1000;  
    
    cursor cu_records_count is
        select count(1)
          from prc_file_raw_data a
             , prc_session_file b
         where b.session_id      = prc_api_session_pkg.get_session_id
           and a.session_file_id = b.id;
           
    cursor cu_cro_records is
        select raw_data
             , record_number
          from prc_file_raw_data
         where session_file_id = l_session_file_id
         order by record_number;
        
begin
    prc_api_stat_pkg.log_start;

    open cu_records_count;
    fetch cu_records_count into l_record_count_all_files;
    close cu_records_count;          
    
    prc_api_stat_pkg.log_estimation(
        i_estimated_count     => l_record_count_all_files
    );
    for p in (
        select id session_file_id
             , record_count
             , file_name
          from prc_session_file
         where session_id = prc_api_session_pkg.get_session_id
         order by id
    )
    loop  
        trc_log_pkg.debug(
            i_text => LOG_PREFIX||'cst_ap_cro_load_pkg.process CRO matching'
        ); 
        l_session_file_id := p.session_file_id;
        
        if substr(p.file_name, 8, 9) = cst_ap_api_const_pkg.ADT then
            l_match_status := cst_ap_api_const_pkg.ENV_LOADED;
        elsif substr(p.file_name, 8, 21) = cst_ap_api_const_pkg.AST then
            l_match_status := cst_ap_api_const_pkg.CRO_ASP_PROCDESSED;
        else
            trc_log_pkg.fatal(
                i_text   => LOG_PREFIX||' Wrong file name is loaded'
            );   
            prc_api_file_pkg.close_file(
                i_sess_file_id  => p.session_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
            );
            com_api_error_pkg.raise_error(
                i_error      => 'UNSUPPORTED_FILENAME'
            );
        end if;    
        
        open cu_cro_records;
        loop
            fetch cu_cro_records bulk collect into l_string_tab, l_record_number_tab limit l_string_limit;
            trc_log_pkg.info(
                i_text          => '#1 records fetched'
              , i_env_param1    => l_string_tab.count
            );
                
            for i in 1 .. l_string_tab.count loop
                savepoint process_string_start;
                begin
                    if l_record_number_tab(i) = 1 then --header do nothing
                        l_processed_count := l_processed_count - 1;
                    else               
                        process_record(
                            i_rec                => l_string_tab(i)
                          , i_incom_sess_file_id => p.session_file_id
                          , i_match_status       => l_match_status
                          , o_processed          => l_processed
                          , o_excepted           => l_excepted
                          , o_not_found          => l_not_found
                        );
                    end if;
                        
                    l_processed_count := l_processed_count + l_processed;
                    l_excepted_count  := l_excepted_count + l_excepted;
                    l_not_found       := l_not_found + l_not_found;
                 exception
                     when others then
                         rollback to savepoint process_string_start;
                        l_record_count := l_record_count + p.record_count;

                        prc_api_stat_pkg.log_current(
                                i_current_count  => l_record_count
                              , i_excepted_count => 0
                        );
                        prc_api_file_pkg.close_file(
                            i_sess_file_id          => p.session_file_id
                          , i_status                => prc_api_const_pkg.FILE_STATUS_REJECTED
                        );
                        trc_log_pkg.fatal(
                            i_text          => 'UNHANDLED_EXCEPTION'
                          , i_env_param1    => sqlerrm
                        );   
                        raise;        
                end;
                if mod(l_processed_count, 100) = 0 then
                    prc_api_stat_pkg.log_current (
                       i_current_count     => l_processed_count
                     , i_excepted_count    => l_excepted_count
                    );
                end if;
                if l_not_found > 0 then
                    rollback to savepoint process_string_start;
                    exit;
                end if;
            end loop;
            exit when cu_cro_records%notfound or l_not_found > 0;
        end loop;
        close cu_cro_records;
        prc_api_file_pkg.close_file(
            i_sess_file_id          => p.session_file_id
          , i_status                => prc_api_const_pkg.FILE_STATUS_ACCEPTED
        );
    end loop;

end process_cro;

end cst_ap_cro_load_pkg;
/
