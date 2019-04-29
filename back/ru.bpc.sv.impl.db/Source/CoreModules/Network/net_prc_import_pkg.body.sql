CREATE OR REPLACE package body net_prc_import_pkg as

   cursor cur_bins is
       select x.pan_low
            , x.pan_high
            , x.pan_length
            , x.priority
            , x.card_type_id
            , x.country
            , x.iss_network_id
            , x.iss_inst_id
            , x.card_network_id
            , x.card_inst_id
            , s.id
         from prc_session_file s
            , prc_file_attribute a
            , prc_file f
             , xmltable(
                xmlnamespaces(default 'http://bpc.ru/sv/SVXP/bin')
              , '/bins/bin'
                passing s.file_xml_contents
                columns
                    pan_low             varchar2(24)  path 'pan_low'
                    , pan_high          varchar2(24)  path 'pan_high'
                    , pan_length        number        path 'pan_length'
                    , priority          number        path 'priority'
                    , card_type_id      number        path 'card_type_id'
                    , country           varchar2(3)   path 'country'
                    , iss_network_id    number        path 'iss_network_id'
                    , iss_inst_id       number        path 'iss_inst_id'
                    , card_network_id   number        path 'card_network_id'
                    , card_inst_id      number        path 'card_inst_id'
              ) x                                    
         where s.session_id = get_session_id
           and s.file_attr_id = a.id
           and f.id = a.file_id;
           
    cursor cur_bin_count is
        select nvl(sum(bin_count), 0) bin_count
           from prc_session_file s
              , prc_file_attribute a
              , prc_file f
              , xmltable(
                    xmlnamespaces(default 'http://bpc.ru/sv/SVXP/bin')
              , '/bins/bin'
                passing s.file_xml_contents
                columns 
                      bin_count                        number        path 'fn:count(pan_low)'
                ) x
          where s.session_id = get_session_id
            and s.file_attr_id = a.id
            and f.id = a.file_id;                                       

    type t_bin_rec is record (
        pan_low             varchar2(24)
        , pan_high          varchar2(24)
        , pan_length        number      
        , priority          number      
        , card_type_id      number      
        , country           varchar2(3) 
        , iss_network_id    number      
        , iss_inst_id       number      
        , card_network_id   number      
        , card_inst_id      number
        , session_file_id   number

    );

    type t_bin_tab     is varray(1000) of t_bin_rec;
    l_bin_tab          t_bin_tab;

procedure load_bin
is
    l_estimated_count       com_api_type_pkg.t_long_id := 0;
    l_processed_count       com_api_type_pkg.t_long_id := 0;
    l_excepted_count        com_api_type_pkg.t_long_id := 0;
    l_rejected_count        com_api_type_pkg.t_long_id := 0;

begin
    savepoint read_operations_start;
    
    trc_log_pkg.info(
        i_text          => 'Read bins'
    );
    
    prc_api_stat_pkg.log_start;

    
    open cur_bin_count; 
    fetch cur_bin_count into l_estimated_count;
    close cur_bin_count;
    
    prc_api_stat_pkg.log_estimation(
        i_estimated_count       => l_estimated_count
    );
    
    open cur_bins;
       
    trc_log_pkg.debug(
        i_text          => 'cursor opened ('||l_estimated_count||')'
    );
        
    loop
        fetch cur_bins bulk collect into l_bin_tab limit 1000;

        
        forall i in 1 .. l_bin_tab.count
        insert into net_bin_range (
            pan_low
            , pan_high
            , pan_length
            , priority
            , card_type_id
            , country
            , iss_network_id
            , iss_inst_id
            , card_network_id
            , card_inst_id
        ) values(
              l_bin_tab(i).pan_low
            , l_bin_tab(i).pan_high
            , l_bin_tab(i).pan_length
            , l_bin_tab(i).priority
            , l_bin_tab(i).card_type_id
            , l_bin_tab(i).country
            , l_bin_tab(i).iss_network_id
            , l_bin_tab(i).iss_inst_id
            , l_bin_tab(i).card_network_id
            , l_bin_tab(i).card_inst_id
        
        );

        l_processed_count := l_processed_count + l_bin_tab.count;

        prc_api_stat_pkg.log_current (
            i_current_count     => l_processed_count
          , i_excepted_count    => l_excepted_count
        );
        
        exit when cur_bins%notfound;
        
    end loop;
    
    close cur_bins;

    net_api_bin_pkg.rebuild_bin_index;
    
    prc_api_stat_pkg.log_end (
        i_excepted_total     => l_excepted_count
        , i_processed_total  => l_processed_count
        , i_rejected_total   => l_rejected_count
        , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
    
    trc_log_pkg.info (
        i_text  => 'Read bins finished'
    );
    
    com_api_sttl_day_pkg.unset_sysdate;            

exception
    when others then
        rollback to savepoint read_operations_start;
        com_api_sttl_day_pkg.unset_sysdate;
        trc_log_pkg.clear_object;
        
        if cur_bins%isopen then 
            close   cur_bins;
            
        end if;

        prc_api_stat_pkg.log_end (
            i_excepted_total     => l_excepted_count
            , i_processed_total  => l_processed_count
            , i_rejected_total   => l_rejected_count
            , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );
        
        raise;
            
end load_bin;

end net_prc_import_pkg;
/
