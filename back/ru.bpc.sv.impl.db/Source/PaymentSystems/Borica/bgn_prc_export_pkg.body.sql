create or replace package body bgn_prc_export_pkg as

procedure register_session_file (
    i_inst_id           in  com_api_type_pkg.t_inst_id
  , i_network_id        in  com_api_type_pkg.t_tiny_id
  , i_host_inst_id      in  com_api_type_pkg.t_inst_id
  , i_file_type         in  com_api_type_pkg.t_dict_value
  , o_session_file_id   out com_api_type_pkg.t_long_id
) is
    l_params                com_api_type_pkg.t_param_tab;
    l_file_number           com_api_type_pkg.t_tiny_id;
begin
    trc_log_pkg.debug (
        i_text          => 'bgn_prc_export_pkg.register_session_file inst_id [#1], network_id [#2], host_inst_id [#3], i_file_type [#4]'
      , i_env_param1    => i_inst_id
      , i_env_param2    => i_network_id
      , i_env_param3    => i_host_inst_id
      , i_env_param4    => i_file_type 
    );
    
    select count(1)
      into l_file_number
      from bgn_file
     where is_incoming = g_file_rec.is_incoming
       and trunc(creation_date) = trunc(g_file_rec.creation_date)
       and file_type = g_file_rec.file_type; 
    
    l_params.delete;
    rul_api_param_pkg.set_param (
        i_name       => 'FILE_NUMBER'
        , i_value    => to_char(g_file_rec.creation_date, 'ymmdd') || to_char(l_file_number)
        , io_params  => l_params
    );

    prc_api_file_pkg.open_file (
        o_sess_file_id  => o_session_file_id
        , i_file_type   => i_file_type
        , io_params     => l_params
    );
    
end;

procedure process (
    i_network_id            in com_api_type_pkg.t_network_id
  , i_inst_id               in com_api_type_pkg.t_inst_id
  , i_host_inst_id          in com_api_type_pkg.t_inst_id  
  , i_date_type             in com_api_type_pkg.t_dict_value
) is
    l_estimated_count           com_api_type_pkg.t_long_id := 0;
    l_processed_count           com_api_type_pkg.t_long_id := 0;

    l_inst_tab                  com_api_type_pkg.t_inst_id_tab;
    l_host_inst_tab             com_api_type_pkg.t_inst_id_tab;
    l_network_tab               com_api_type_pkg.t_network_tab;
    l_host_tab                  com_api_type_pkg.t_number_tab;
    l_standard_tab              com_api_type_pkg.t_number_tab;
    
    l_record_number             com_api_type_pkg.t_short_id;
    
    l_fin_cur                   bgn_api_type_pkg.t_bgn_fin_cur;
    l_fin_tab                   bgn_api_type_pkg.t_bgn_fin_tab;
    l_line                      com_api_type_pkg.t_raw_data;
    
    l_ok_mess_tab               com_api_type_pkg.t_number_tab;
    l_file_tab                  com_api_type_pkg.t_number_tab;
    l_rec_num_tab               com_api_type_pkg.t_number_tab;
    
    l_file_number               number(3);
    
    BULK_LIMIT                  constant binary_integer := 1000;
    
    l_sql_line_stmt             com_api_type_pkg.t_full_desc;
    l_sql_final_stmt            com_api_type_pkg.t_full_desc;
    l_procedure_parameters      com_api_type_pkg.t_full_desc; 
    
    l_date                      date;
    
    procedure register_ok_message (
        i_mess_id               com_api_type_pkg.t_long_id
        , i_file_id             com_api_type_pkg.t_long_id
    ) is
        i                       binary_integer;
    begin
        i := l_ok_mess_tab.count + 1;
        l_ok_mess_tab(i)    := i_mess_id;
        l_file_tab(i)       := i_file_id;
        l_rec_num_tab(i)    := prc_api_file_pkg.get_record_number(i_sess_file_id => g_file_rec.id);
    end;

    procedure mark_ok_message is
    begin
        forall i in 1..l_ok_mess_tab.count
            update bgn_fin
               set file_id = l_file_tab(i)
                 , file_record_number = l_rec_num_tab(i)
                 , status = net_api_const_pkg.CLEARING_MSG_STATUS_UPLOADED
             where id = l_ok_mess_tab(i);
            
        opr_api_clearing_pkg.mark_uploaded (
            i_id_tab  => l_ok_mess_tab
        );

        l_ok_mess_tab.delete;
        l_file_tab.delete;
        l_rec_num_tab.delete;
    end;    
    
begin
    trc_log_pkg.debug (
        i_text          => 'BORICA outgoing clearing inst_id [#2], host_inst_id [#3], network_id [#4], date_type [#5]'
      , i_env_param2    => i_inst_id
      , i_env_param3    => i_host_inst_id
      , i_env_param4    => i_network_id 
      , i_env_param5    => i_date_type
    );
    
    if i_date_type = com_api_const_pkg.DATE_PURPOSE_PROCESSING then
        l_date  := get_sysdate();
        
    elsif i_date_type = com_api_const_pkg.DATE_PURPOSE_BANK then
        l_date  := com_api_sttl_day_pkg.get_open_sttl_date(i_inst_id => i_inst_id);
        
    end if;

    trc_log_pkg.info(
        i_text          => 'settlment date [#1]'
      , i_env_param1    => l_date
    );
    
    l_sql_line_stmt             := 'bgn_qo_pkg.export_line';
    l_sql_final_stmt            := 'bgn_qo_pkg.export_line';
    l_procedure_parameters      := 
        '  (io_line             => :line'
     || ' , i_record_number     => :record_number'
     || ' , i_session_file_id   => :session_file_id'
     || ' , i_network_id        => :network_id'
     || ' , i_inst_id           => :inst_id'
     || ' , i_host_inst_id      => :host_inst_id'
     || ' , i_is_file_trail     => :is_trail)'
    ;
    
    prc_api_stat_pkg.log_start;
    
    select max(file_number)
      into l_file_number
      from bgn_file
     where file_type = bgn_api_const_pkg.FILE_TYPE_BORICA_QO
       and trunc(sttl_date) = trunc(l_date)
       and is_incoming = com_api_const_pkg.FALSE;
    
    l_sql_line_stmt     := 'begin ' || l_sql_line_stmt || l_procedure_parameters || '; end;';
    l_sql_final_stmt    := 'begin ' || l_sql_final_stmt || l_procedure_parameters || '; end;';

    select m.id host_id
         , m.inst_id host_inst_id
         , n.id network_id
         , r.inst_id
         , s.standard_id
    bulk collect into
           l_host_tab
         , l_host_inst_tab
         , l_network_tab
         , l_inst_tab
         , l_standard_tab
      from net_network n
         , net_member m
         , net_interface i
         , net_member r
         , cmn_standard_object s
    where
        (n.id = i_network_id or i_network_id is null)
        and n.id = m.network_id
        and n.inst_id = m.inst_id
        and (m.inst_id = i_host_inst_id or i_host_inst_id is null)
        and s.object_id = m.id
        and s.entity_type = net_api_const_pkg.ENTITY_TYPE_HOST
        and s.standard_type = cmn_api_const_pkg.STANDART_TYPE_NETW_CLEARING
        and (r.inst_id = i_inst_id or i_inst_id is null)
        and r.id = i.consumer_member_id
        and i.host_member_id = m.id;

    for i in 1..l_host_tab.count loop
        l_estimated_count := l_estimated_count +
                             bgn_api_fin_pkg.estimate_messages_for_upload (
                                 i_network_id       => l_network_tab(i)
                               , i_inst_id          => l_inst_tab(i)
                               , i_host_inst_id     => l_host_inst_tab(i)
                             );
    end loop;

    prc_api_stat_pkg.log_estimation (
        i_estimated_count  => l_estimated_count
    );

    if l_estimated_count > 0 then
        for i in 1..l_host_tab.count loop
            l_record_number    := 0;
  
            g_file_rec  := null;
            
            g_file_rec.file_type        := bgn_api_const_pkg.FILE_TYPE_BORICA_QO;
            g_file_rec.is_incoming      := com_api_const_pkg.FALSE;
            l_file_number               := nvl(l_file_number + 1, 0);
            g_file_rec.file_number      := l_file_number;
            g_file_rec.creation_date    := get_sysdate();
            g_file_rec.sttl_date        := l_date;
            
            register_session_file (
                i_inst_id           => l_inst_tab(i)
              , i_network_id        => l_network_tab(i)
              , i_host_inst_id      => l_host_inst_tab(i)
              , i_file_type         => g_file_rec.file_type
              , o_session_file_id   => g_file_rec.id
            );
 
            bgn_api_fin_pkg.enum_messages_for_upload (
                o_fin_cur       => l_fin_cur
              , i_network_id    => l_network_tab(i)
              , i_inst_id       => l_inst_tab(i)
              , i_host_inst_id  => l_host_inst_tab(i)
            );
            
            loop
                fetch l_fin_cur bulk collect into l_fin_tab limit BULK_LIMIT;
                for j in 1..l_fin_tab.count loop
                    g_fin_rec   := l_fin_tab(j);

                    if l_record_number = 0 then
                        execute immediate l_sql_line_stmt 
                          using in out l_line
                                     , l_record_number
                                     , g_file_rec.id
                                     , l_network_tab(i)
                                     , l_inst_tab(i)
                                     , l_host_inst_tab(i)
                                     , com_api_const_pkg.FALSE
                                     ;
                                     
                        if l_line is not null then
                            prc_api_file_pkg.put_line(
                                i_raw_data      => l_line
                              , i_sess_file_id  => g_file_rec.id
                            );
                            
                        end if;             
                                     
                        l_record_number := l_record_number + 1;
                    end if;
                    
                    execute immediate l_sql_line_stmt 
                      using in out l_line
                                 , l_record_number
                                 , g_file_rec.id
                                 , l_network_tab(i)
                                 , l_inst_tab(i)
                                 , l_host_inst_tab(i)
                                 , com_api_const_pkg.FALSE
                                 ;
                                 
                    if l_line is not null then
                        prc_api_file_pkg.put_line(
                            i_raw_data      => l_line
                          , i_sess_file_id  => g_file_rec.id
                        );
                        
                    end if;             
                                 
                    l_record_number := l_record_number + 1;

                    register_ok_message (
                        i_mess_id   => l_fin_tab(j).id
                      , i_file_id   => g_file_rec.id
                    );
                    
                end loop;
                
                mark_ok_message;

                l_processed_count := l_processed_count + l_fin_tab.count;

                prc_api_stat_pkg.log_current (
                    i_current_count     => l_processed_count
                  , i_excepted_count    => 0
                );

                exit when l_fin_cur%notfound;
                
            end loop;
            
            close l_fin_cur;

            if l_record_number > 0 then
                l_record_number := l_record_number + 1;

                execute immediate l_sql_final_stmt 
                      using in out l_line
                                 , l_record_number
                                 , g_file_rec.id
                                 , l_network_tab(i)
                                 , l_inst_tab(i)
                                 , l_host_inst_tab(i)
                                 , com_api_const_pkg.TRUE
                                 ;
                
                if l_line is not null then
                    prc_api_file_pkg.put_line(
                        i_raw_data      => l_line
                      , i_sess_file_id  => g_file_rec.id
                    );
                        
                end if;
                
                prc_api_file_pkg.close_file (
                    i_sess_file_id  => g_file_rec.id
                  , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
                );

            end if;
            
        end loop;
        
    end if;

    prc_api_stat_pkg.log_end(
        i_result_code        => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        , i_processed_total  => l_processed_count
    );

    trc_log_pkg.debug (
        i_text  => 'BORICA outgoing clearing end'
    );

exception
    when others then
        if l_fin_cur%isopen then
            close l_fin_cur;
        end if;

        prc_api_stat_pkg.log_end (
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        prc_api_file_pkg.close_file (
            i_sess_file_id  => g_file_rec.id
          , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
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

end bgn_prc_export_pkg;
/ 
