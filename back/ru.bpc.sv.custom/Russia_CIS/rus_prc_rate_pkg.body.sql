create or replace package body rus_prc_rate_pkg is

    CBRF_RATE  constant    com_api_type_pkg.t_dict_value := 'RTTPCBRF';

    type t_rate_rec is record (
        src_currency          com_api_type_pkg.t_curr_code
        , dst_currency        com_api_type_pkg.t_curr_code
        , rate_type           com_api_type_pkg.t_dict_value
        , inst_id             com_api_type_pkg.t_inst_id
        , eff_date            date
        , rate                com_api_type_pkg.t_money
        , inverted            com_api_type_pkg.t_boolean
        , src_scale           com_api_type_pkg.t_short_id
        , dst_scale           com_api_type_pkg.t_tiny_id
        , exp_date            date
    );

    type t_rate_tab    is varray(1000) of t_rate_rec;
    l_rate_tab         t_rate_tab;

procedure load_rates(
    i_inst_id           in    com_api_type_pkg.t_inst_id
    , i_eff_date        in    date
)is
    l_estimated_count       com_api_type_pkg.t_long_id := 0;
    l_processed_count       com_api_type_pkg.t_long_id := 0;
    l_excepted_count        com_api_type_pkg.t_long_id := 0;
    l_inverted              com_api_type_pkg.t_boolean := 0;
    l_dst_scale             com_api_type_pkg.t_tiny_id := 1;
    l_dst_currency          com_api_type_pkg.t_curr_code := '643';
    l_id                    com_api_type_pkg.t_short_id;
    l_seqnum                com_api_type_pkg.t_tiny_id;
    l_count                 number;
    l_test                  com_api_type_pkg.t_money;
    
    cursor cur_rates is
       select x.src_currency
            , l_dst_currency dst_currency
            , rus_prc_rate_pkg.CBRF_RATE rate_type
            , i_inst_id inst_id
            , i_eff_date eff_date  
            , to_number(x.rate, 'FM999999999999999990D0000', 'NLS_NUMERIC_CHARACTERS='',.''')
            , l_inverted inverted
            , x.src_scale
            , l_dst_scale dst_scale
            , null exp_date
         from prc_session_file s
            , prc_file_attribute a
            , prc_file f
            , xmltable(
               '/ValCurs/Valute'
                passing s.file_xml_contents
                columns
                    src_currency        varchar2(3)   path 'NumCode' 
                    , rate              varchar2(100) path 'Value'
                    , src_scale         number        path 'Nominal'
             ) x                                    
         where s.session_id = get_session_id
           and s.file_attr_id = a.id
           and f.id = a.file_id;
           
    cursor cur_rate_count is
        select nvl(sum(rate_count), 0) rate_count
           from prc_session_file s
              , prc_file_attribute a
              , prc_file f
              , xmltable( 
                      '/ValCurs/Valute' passing s.file_xml_contents
                       columns
                            rate_count      number   path 'fn:count(CharCode)'
              ) x          
          where s.session_id = get_session_id
            and s.file_attr_id = a.id
            and f.id = a.file_id;                                       
        
begin
    savepoint read_rates_start;

    trc_log_pkg.info(
        i_text          => 'Read rates start'
    );
                  
    prc_api_stat_pkg.log_start;
    
    open cur_rate_count; 
    fetch cur_rate_count into l_estimated_count;
    close cur_rate_count;
    
    prc_api_stat_pkg.log_estimation(
        i_estimated_count       => l_estimated_count
    );
    
    open cur_rates;
       
    trc_log_pkg.debug(
        i_text          => 'cursor opened ('||l_estimated_count||')'
    );
        
    loop
        fetch cur_rates bulk collect into l_rate_tab limit 1000;
        
        trc_log_pkg.info(
            i_text          => '#1 records fetched'
          , i_env_param1    => l_rate_tab.count
        );
    
        for i in 1 .. l_rate_tab.count loop
            savepoint process_rate_start;

            begin               
                com_api_rate_pkg.set_rate (
                    o_id              => l_id
                    , o_seqnum        => l_seqnum
                    , o_count         => l_count
                    , i_src_currency  => l_rate_tab(i).src_currency
                    , i_dst_currency  => l_rate_tab(i).dst_currency
                    , i_rate_type     => l_rate_tab(i).rate_type
                    , i_inst_id       => l_rate_tab(i).inst_id
                    , i_eff_date      => l_rate_tab(i).eff_date
                    , i_rate          => l_rate_tab(i).rate
                    , i_inverted      => l_rate_tab(i).inverted
                    , i_src_scale     => l_rate_tab(i).src_scale
                    , i_dst_scale     => l_rate_tab(i).dst_scale
                    , i_exp_date      => l_rate_tab(i).exp_date
                );
                        
                l_processed_count := l_processed_count + 1;
                
            exception
                when others then
                    rollback to savepoint process_rate_start;
                    if com_api_error_pkg.is_application_error(sqlcode) = com_api_type_pkg.TRUE then
                        l_excepted_count := l_excepted_count + 1;
                    else
                        close   cur_rates;
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

        exit when cur_rates%notfound;
        
    end loop;
    
    close cur_rates;
    
    prc_api_stat_pkg.log_end(
        i_processed_total   => l_processed_count
      , i_excepted_total    => l_excepted_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
    
    trc_log_pkg.info(
        i_text          => 'Read reates end'
    );

exception
     when others then
        rollback to savepoint read_rates_start;
        if cur_rates%isopen then
            close   cur_rates;

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

end;
/
