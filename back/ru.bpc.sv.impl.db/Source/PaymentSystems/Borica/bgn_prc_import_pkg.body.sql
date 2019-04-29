create or replace package body bgn_prc_import_pkg as

procedure process(
    i_file_type         com_api_type_pkg.t_dict_value
  , i_inst_id       in  com_api_type_pkg.t_inst_id
  , i_network_id    in  com_api_type_pkg.t_inst_id  
) is
    l_estimated_count       com_api_type_pkg.t_long_id := 0;
    l_processed_count       com_api_type_pkg.t_long_id := 0;
    l_excepted_count        com_api_type_pkg.t_long_id := 0;
    l_rejected_count        com_api_type_pkg.t_long_id := 0;
    
    l_session_file_id       com_api_type_pkg.t_long_id;
    
    cursor cur_records is
        select raw_data
             , record_number
          from prc_file_raw_data rd
         where rd.session_file_id = l_session_file_id
         order by record_number;
         
    l_string_tab            com_api_type_pkg.t_desc_tab;
    l_record_number_tab     com_api_type_pkg.t_short_tab;
    l_string_limit          com_api_type_pkg.t_short_id := 1000;
    
    l_is_invalid            com_api_type_pkg.t_boolean;
    
    l_sql_stmt              com_api_type_pkg.t_full_desc;
    l_procedure_parameters  com_api_type_pkg.t_full_desc := '(io_data => :data_string, i_session_file_id => :session_file_id, i_record_number => :record_number, i_inst_id => :inst_id, i_network_id => :i_network_id, o_is_invalid => :is_invalid)';
    
    l_amount_tab            com_api_type_pkg.t_money_tab;
    l_curr_tab              com_api_type_pkg.t_curr_code_tab;
    
begin
    savepoint read_clearing_start;
    
    trc_log_pkg.info(
        i_text          => 'Read clearing [#1] [#2] [#3]'
      , i_env_param1    => i_file_type  
      , i_env_param2    => i_inst_id
      , i_env_param3    => i_network_id
    );
    
    case i_file_type
    when bgn_api_const_pkg.FILE_TYPE_BORICA_EO then
        l_sql_stmt  := 'bgn_eo_pkg.process_string';
        
    when bgn_api_const_pkg.FILE_TYPE_BORICA_FO then
        l_sql_stmt  := 'bgn_fo_pkg.process_string';
        
    when bgn_api_const_pkg.FILE_TYPE_BORICA_QO then
        l_sql_stmt  := 'bgn_qo_pkg.process_string';
        
    when bgn_api_const_pkg.FILE_TYPE_BORICA_SO then
        l_sql_stmt  := 'bgn_so_pkg.process_string';                 
    
    else
        com_api_error_pkg.raise_error(
            i_error         => 'BGN_UNSUPPORTED_FILE_TYPE'
          , i_env_param1    => i_file_type  
        );                                
                                    
    end case; --i_file_type    
    
    l_sql_stmt := 'begin ' || l_sql_stmt || l_procedure_parameters || '; end;'; 
    
    select count(1)
      into l_estimated_count
      from prc_file_raw_data rd
         , prc_session_file sf
         , prc_file_attribute a
         , prc_file f
     where sf.session_id = get_session_id
       and rd.session_file_id = sf.id
       and sf.file_attr_id = a.id
       and f.id = a.file_id
       and f.file_type = i_file_type;  
  
    prc_api_stat_pkg.log_start;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count       => l_estimated_count
    );
    
    for cur_file in (
        select s.id
             , s.file_name 
          from prc_session_file s
             , prc_file_attribute a
             , prc_file f
         where s.session_id = get_session_id
           and s.file_attr_id = a.id
           and f.id = a.file_id
           and f.file_type = i_file_type   
         order by s.file_name
    ) loop
        trc_log_pkg.info(
            i_text          => 'Start process file [#1]; inst_id [#2]; network_id [#3]; sttl_date [#4]'
          , i_env_param1    => cur_file.file_name  
          , i_env_param2    => g_file_rec.inst_id
          , i_env_param3    => g_file_rec.network_id
          , i_env_param4    => g_file_rec.sttl_date
          , i_entity_type   => prc_api_const_pkg.ENTITY_TYPE_SESSION_FILE
          , i_object_id     => cur_file.id
        );
        
        l_session_file_id       := cur_file.id;
        g_file_rec              := null;
        g_file_rec.id           := l_session_file_id;
        g_file_rec.is_incoming  := com_api_type_pkg.TRUE;
        g_file_rec.inst_id      := i_inst_id;
        g_file_rec.network_id   := i_network_id;
        g_file_rec.file_type    := i_file_type;
        g_file_rec.sttl_date    := 
            com_api_sttl_day_pkg.get_open_sttl_date(
                i_inst_id   => i_inst_id
            );

        begin
            savepoint start_clearing_file;
            
            open cur_records;
            loop
                fetch cur_records bulk collect into l_string_tab, l_record_number_tab limit l_string_limit;
                trc_log_pkg.debug(
                    i_text          => '#1 records fetched'
                  , i_env_param1    => l_string_tab.count
                );
                
                for i in 1 .. l_string_tab.count loop
                    l_processed_count := l_processed_count + 1;
                    
                    execute immediate l_sql_stmt 
                    using in out  l_string_tab(i)
                            , in  l_session_file_id
                            , in  l_record_number_tab(i)
                            , in  i_inst_id
                            , in  i_network_id
                            , out l_is_invalid;
                        
                    if l_is_invalid = com_api_const_pkg.TRUE then
                        l_excepted_count    := l_excepted_count + 1;

                    end if;    
                              
                    if mod(l_processed_count, 100) = 0 then
                        prc_api_stat_pkg.log_current (
                            i_current_count     => l_processed_count
                          , i_excepted_count    => l_excepted_count
                        );
                    end if;      
                    
                end loop;
                
                exit when cur_records%notfound;
                
            end loop;
            
            close cur_records;
            
            l_amount_tab.delete;
            l_curr_tab.delete;
            
            begin
                select sum(oper_amount)
                     , oper_currency
                  bulk collect into
                       l_amount_tab
                     , l_curr_tab     
                  from opr_operation
                 where session_id = l_session_file_id
                 group by oper_currency; 
                 
                for i in 1 .. l_amount_tab.count loop
                    trc_log_pkg.info(
                        i_text          => 'Currency [#1], amount [#2]'
                      , i_env_param1    => l_curr_tab(i)
                      , i_env_param2    => l_amount_tab(i)
                    );
                end loop;     
                 
            exception
                when no_data_found then
                    null;     
            end;     
                  
        
        exception
            when others then
                rollback to savepoint start_clearing_file;
                               
                if com_api_error_pkg.is_application_error(sqlcode) = com_api_type_pkg.TRUE then
                    trc_log_pkg.error(
                        i_text          => 'Error during import file [#1]; file has NOT been imported'
                      , i_env_param1    => cur_file.file_name
                    );  
                end if; 
                
                raise;      
        end;
  
    end loop;
    
    prc_api_stat_pkg.log_end(
        i_processed_total   => l_processed_count
      , i_excepted_total    => l_excepted_count
      , i_rejected_total    => l_rejected_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS  
    );
    
exception
     when others then
        rollback to savepoint read_clearing_start;
        if cur_records%isopen then
            close   cur_records;

        end if;
        
        prc_api_stat_pkg.log_end (
            i_processed_total   => l_processed_count
          , i_excepted_total    => l_excepted_count
          , i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );
        
        update prc_session_file
           set status = prc_api_const_pkg.FILE_STATUS_REJECTED
         where session_id = get_session_id; 

--        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
--            raise;
--
--        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
--            com_api_error_pkg.raise_fatal_error(
--                i_error         => 'UNHANDLED_EXCEPTION'
--              , i_env_param1    => sqlerrm
--            );
--
--        end if;

        com_api_error_pkg.raise_fatal_error(
            i_error         => 'BGN_IMPORT_FAILED'
          , i_entity_type   => prc_api_const_pkg.entity_type_session
          , i_object_id     => get_session_id
          , i_env_param1    => get_session_id
        );  
    
end process;

procedure process_eo(
    i_inst_id       in  com_api_type_pkg.t_inst_id
  , i_network_id    in  com_api_type_pkg.t_inst_id  
)
is
begin
    process(
        i_file_type     => bgn_api_const_pkg.FILE_TYPE_BORICA_EO 
      , i_inst_id       => i_inst_id
      , i_network_id    => i_network_id  
    );
    
end;

procedure process_qo(
    i_inst_id       in  com_api_type_pkg.t_inst_id
  , i_network_id    in  com_api_type_pkg.t_inst_id  
)
is
begin
    process(
        i_file_type     => bgn_api_const_pkg.FILE_TYPE_BORICA_QO
      , i_inst_id       => i_inst_id
      , i_network_id    => i_network_id  
    );
    
end;

procedure process_fo(
    i_inst_id       in  com_api_type_pkg.t_inst_id
  , i_network_id    in  com_api_type_pkg.t_inst_id  
) 
is
begin
    process(
        i_file_type     => bgn_api_const_pkg.FILE_TYPE_BORICA_FO 
      , i_inst_id       => i_inst_id
      , i_network_id    => i_network_id  
    );
    
end;

procedure process_so(
    i_inst_id       in  com_api_type_pkg.t_inst_id
  , i_network_id    in  com_api_type_pkg.t_inst_id  
) 
is
begin
    process(
        i_file_type     => bgn_api_const_pkg.FILE_TYPE_BORICA_SO 
      , i_inst_id       => i_inst_id
      , i_network_id    => i_network_id  
    );
    
end;

procedure add_bin(
    i_bin_string        in      com_api_type_pkg.t_name
) is
    l_visa_network      com_api_type_pkg.t_network_id   := 1003;
    l_mc_network        com_api_type_pkg.t_network_id   := 1002;
    
    l_iss_inst_id       com_api_type_pkg.t_inst_id;
    l_iss_host_id       com_api_type_pkg.t_tiny_id;
    l_card_type_id      com_api_type_pkg.t_tiny_id;
    l_card_country      com_api_type_pkg.t_curr_code;
    l_card_inst_id      com_api_type_pkg.t_inst_id;
    l_card_network_id   com_api_type_pkg.t_tiny_id;
    l_pan_length        com_api_type_pkg.t_tiny_id;
    
    l_iss_network_id    com_api_type_pkg.t_network_id;
begin
    trc_log_pkg.debug(
        i_text          => 'bgn_prc_import_pkg.add_bin [#1]'
      , i_env_param1    => i_bin_string  
    );
    
    for r in (
        select
            bin || lpad(level-1, decode(length(bin), 1, 5, 2, 4, 3, 3, 4, 2, 5, 1), '0') bin_string
        from
            (select i_bin_string bin from dual)
        connect by
            level <= power(10, decode(length(bin),   1, 5, 2, 4, 3, 3, 4, 2, 5, 1, 6, 0))
    ) loop
        net_api_bin_pkg.get_bin_info (
            i_card_number       => r.bin_string 
          , i_network_id        => bgn_api_const_pkg.BORICA_NETWORK_ID
          , o_iss_inst_id       => l_iss_inst_id
          , o_iss_host_id       => l_iss_host_id
          , o_card_type_id      => l_card_type_id
          , o_card_country      => l_card_country
          , o_card_inst_id      => l_card_inst_id
          , o_card_network_id   => l_card_network_id
          , o_pan_length        => l_pan_length
          , i_raise_error       => com_api_type_pkg.FALSE
        );
            
        if l_iss_inst_id is not null then
            continue;
        end if;
            
        if l_iss_inst_id is null then
            net_api_bin_pkg.get_bin_info (
                i_card_number       => r.bin_string
              , i_network_id        => l_mc_network
              , o_iss_inst_id       => l_iss_inst_id
              , o_iss_host_id       => l_iss_host_id
              , o_card_type_id      => l_card_type_id
              , o_card_country      => l_card_country
              , o_card_inst_id      => l_card_inst_id
              , o_card_network_id   => l_card_network_id
              , o_pan_length        => l_pan_length
              , i_raise_error       => com_api_type_pkg.FALSE
            );   
        end if;
                
        if l_iss_inst_id is null then
            net_api_bin_pkg.get_bin_info (
                i_card_number       => r.bin_string 
              , i_network_id        => l_visa_network
              , o_iss_inst_id       => l_iss_inst_id
              , o_iss_host_id       => l_iss_host_id
              , o_card_type_id      => l_card_type_id
              , o_card_country      => l_card_country
              , o_card_inst_id      => l_card_inst_id
              , o_card_network_id   => l_card_network_id
              , o_pan_length        => l_pan_length
              , i_raise_error       => com_api_type_pkg.FALSE
            );   
        end if;
            
        if l_iss_inst_id is not null then
            net_api_bin_pkg.add_bin_range(
                i_pan_low           => rpad(r.bin_string, l_pan_length, '0') 
              , i_pan_high          => rpad(r.bin_string, l_pan_length, '9')
              , i_country           => l_card_country
              , i_network_id        => bgn_api_const_pkg.BORICA_NETWORK_ID
              , i_inst_id           => bgn_api_const_pkg.BORICA_INST_ID
              , i_pan_length        => l_pan_length
              , i_network_card_type => l_card_type_id
              , i_card_network_id   => l_card_network_id
              , i_card_inst_id      => l_card_inst_id
              , i_module_code       => bgn_api_const_pkg.MODULE_CODE_BORICA
            );
            
        else
            if length(i_bin_string) < 6 then
                trc_log_pkg.info(
                    i_text          => 'BGN_BIN_NOT_FOUND'
                  , i_env_param1    => r.bin_string
                  , i_env_param2    => i_bin_string
                );
            else
                com_api_error_pkg.raise_error(
                    i_error         => 'BGN_BIN_NOT_FOUND'
                  , i_env_param1    => r.bin_string
                );
            end if;    
        end if;
    end loop;
    
end;

procedure delete_borica_bins
is
begin
    trc_log_pkg.debug(
        i_text          => 'bgn_prc_import_pkg.delete_borica_bins'
    );
    
    delete from net_bin_range
     where iss_network_id = bgn_api_const_pkg.BORICA_NETWORK_ID
       and iss_inst_id = bgn_api_const_pkg.BORICA_INST_ID
       and module_code = bgn_api_const_pkg.MODULE_CODE_BORICA;
end;

procedure import_bin_table
is
    l_estimated_count       com_api_type_pkg.t_long_id := 0;
    l_processed_count       com_api_type_pkg.t_long_id := 0;
    l_excepted_count        com_api_type_pkg.t_long_id := 0;

    l_session_file_id       com_api_type_pkg.t_long_id;
        
    cursor cur_bin_records is
        select trim(raw_data)
             , record_number
          from prc_file_raw_data rd
         where rd.session_file_id = l_session_file_id
         order by record_number;
         
    l_string_tab            com_api_type_pkg.t_desc_tab;
    l_record_number_tab     com_api_type_pkg.t_short_tab;
    l_string_limit          com_api_type_pkg.t_short_id := 1000;      
         
begin
    savepoint read_bin_start;
    
    trc_log_pkg.info(
        i_text          => 'Read BORICA BIN table'
    );
    
    select count(1)
      into l_estimated_count
      from prc_file_raw_data rd
         , prc_session_file sf
         , prc_file_attribute a
         , prc_file f
     where sf.session_id = get_session_id
       and rd.session_file_id = sf.id
       and sf.file_attr_id = a.id
       and f.id = a.file_id
       and f.file_type = bgn_api_const_pkg.FILE_TYPE_BORICA_BIN_TABLE;  
  
    prc_api_stat_pkg.log_start;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count       => l_estimated_count
    );
    
    delete_borica_bins;
    
    for bin_file in (
        select s.id
             , s.file_name 
          from prc_session_file s
             , prc_file_attribute a
             , prc_file f
         where s.session_id = get_session_id
           and s.file_attr_id = a.id
           and f.id = a.file_id
           and f.file_type = bgn_api_const_pkg.FILE_TYPE_BORICA_BIN_TABLE    
    ) loop
        trc_log_pkg.info(
            i_text          => 'Start process file [#1]'
          , i_env_param1    => bin_file.file_name  
        );
        
        l_session_file_id   := bin_file.id;
        
        open cur_bin_records;
        loop
            fetch cur_bin_records bulk collect into l_string_tab, l_record_number_tab limit l_string_limit;
            trc_log_pkg.info(
                i_text          => '#1 records fetched'
              , i_env_param1    => l_string_tab.count
            );
            
            for i in 1 .. l_string_tab.count loop
                savepoint process_string_start;
                
                begin
                    --g_record_number := l_record_number_tab(i);
                    if l_string_tab(i) is null then
                        null;
                        
                    elsif l_string_tab(i) = 'BORICA BIN TABLE' then
                        null;
                        
                    else
                        add_bin(
                            i_bin_string   => l_string_tab(i)
                        );
                        
                    end if;        
                    
                    l_processed_count := l_processed_count + 1;
                    
                exception
                    when others then
                        rollback to savepoint process_string_start;
                        if com_api_error_pkg.is_application_error(sqlcode) = com_api_type_pkg.TRUE then
                            l_excepted_count := l_excepted_count + 1;

                        else
                            close   cur_bin_records;
                            raise;

                        end if;    
                end;
                
                if mod(l_processed_count, 100) = 0 then
                    prc_api_stat_pkg.log_current (
                        i_current_count     => l_processed_count
                      , i_excepted_count    => l_excepted_count
                    );
                    
                end if;
                
            end loop;
            
            exit when cur_bin_records%notfound;
        end loop;

        close cur_bin_records;
    end loop;
    
    net_api_bin_pkg.rebuild_bin_index;
    
    prc_api_stat_pkg.log_end(
        i_processed_total   => l_processed_count
      , i_excepted_total    => l_excepted_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS  
    );
    
exception
     when others then
        rollback to savepoint read_bin_start;
        if cur_bin_records%isopen then
            close   cur_bin_records;

        end if;

        prc_api_stat_pkg.log_end (
            i_processed_total   => l_processed_count
          , i_excepted_total    => l_excepted_count
          , i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;

        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );

        end if;

        raise;  
    
end;

end bgn_prc_import_pkg;
/
 