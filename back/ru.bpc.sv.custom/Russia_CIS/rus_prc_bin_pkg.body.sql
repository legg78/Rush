create or replace package body rus_prc_bin_pkg is
/************************************************************
 * API for process files with BINs of domestic networks <br />
 * Created by Maslov I.(maslov@bpcbt.com)  at 11.12.2014 <br />
 * Last changed by $Author: truschelev $ <br />
 * $LastChangedDate:: 2015-11-18 09:47:00 +0300#$ <br />
 * Revision: $LastChangedRevision: 6280 $ <br />
 * Module: RUS_PRC_BIN_PKG <br />
 * @headcom
 ***********************************************************/

MINIMUM_FILLED_BIN_LENGTH    constant com_api_type_pkg.t_tiny_id    := 16;
FILLED_BIN_LENGTH            constant com_api_type_pkg.t_tiny_id    := 19;
RUS_MODULE_CODE              constant com_api_type_pkg.t_curr_code  := 'RUS';

MC_NETWORK_ID                constant com_api_type_pkg.t_network_id := 1002;
VISA_NETWORK_ID              constant com_api_type_pkg.t_network_id := 1003;

cursor cur_bins is
    select to_date(x.activation_date, 'yyyy-mm-dd') as activation_date
         , x.member_id
         , (case
                when length(x.lo_range) < MINIMUM_FILLED_BIN_LENGTH
                then rpad(x.lo_range, FILLED_BIN_LENGTH, '0')
                else x.lo_range
                end
           )  as lo_range
         , (case
                when length(x.hi_range) < MINIMUM_FILLED_BIN_LENGTH
                then rpad(x.hi_range, FILLED_BIN_LENGTH, '9')
                else x.hi_range
                end
           ) as hi_range
      from prc_session_file s
         , prc_file_attribute a
         , prc_file f
         , xmltable(
           --  xmlnamespaces(default 'http://bpc.ru/sv/SVXP/bin'), 
            '/dataset/record'
             passing s.file_xml_contents
             columns
                 activation_date          varchar2(8)     path 'EFFECTIVE_DATE'
                 , member_id              varchar2(11)    path 'MEMBER_ID'
                 , lo_range               varchar2(19)    path 'LO_RANGE'
                 , hi_range               varchar2(19)    path 'HI_RANGE'
          ) x                                    
      where s.session_id   = get_session_id
        and s.file_attr_id = a.id
        and f.id           = a.file_id;
           
cursor cur_bin_count is
    select nvl(sum(bin_count), 0) bin_count
       from prc_session_file s
          , prc_file_attribute a
          , prc_file f
          , xmltable(--  xmlnamespaces(default 'http://bpc.ru/sv/SVXP/bin'), 
                  '/dataset/record' passing s.file_xml_contents
                   columns
                        bin_count          number     path 'fn:count(LO_RANGE)'
          ) x          
      where s.session_id   = get_session_id
        and s.file_attr_id = a.id
        and f.id           = a.file_id;                                       

type t_bin_rec is record (
    activation_date     date
  , member_id           com_api_type_pkg.t_cmid 
  , lo_range            com_api_type_pkg.t_card_number
  , hi_range            com_api_type_pkg.t_card_number
);

type t_bin_tab          is varray(1000) of t_bin_rec;
l_bin_tab               t_bin_tab;
    
procedure add_bin(
    i_bin_rec           in    t_bin_rec
  , i_inst_id           in    com_api_type_pkg.t_inst_id
  , i_network_id        in    com_api_type_pkg.t_tiny_id
  , i_priority          in    com_api_type_pkg.t_tiny_id
  , i_card_network_id   in    com_api_type_pkg.t_tiny_id
) is
    l_iss_inst_id       com_api_type_pkg.t_inst_id;
    l_iss_host_id       com_api_type_pkg.t_tiny_id;
    l_card_type_id      com_api_type_pkg.t_tiny_id;
    l_card_country      com_api_type_pkg.t_curr_code;
    l_card_inst_id      com_api_type_pkg.t_inst_id;
    l_card_network_id   com_api_type_pkg.t_tiny_id;
    l_pan_length        com_api_type_pkg.t_tiny_id;
begin
    trc_log_pkg.debug(
        i_text          => 'rus_prc_bin_pkg.add_bin [#1]'
      , i_env_param1    => i_bin_rec.lo_range  
    );
    
    net_api_bin_pkg.get_bin_info (
        i_card_number       => i_bin_rec.lo_range
      , i_network_id        => i_network_id
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
        trc_log_pkg.debug(
            i_text          => 'Bin range [#1] already exists for network [#2] and institution [#3]'
          , i_env_param1    => i_bin_rec.lo_range  
          , i_env_param2    => i_network_id
          , i_env_param3    => l_iss_inst_id 
        );
        return;
    end if;

    if l_iss_inst_id is null then
        net_api_bin_pkg.get_bin_info (
            i_card_number       => i_bin_rec.lo_range
          , i_network_id        => i_card_network_id
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
            i_pan_low           => substr(i_bin_rec.lo_range, 1, l_pan_length)
          , i_pan_high          => substr(i_bin_rec.hi_range, 1, l_pan_length)
          , i_country           => l_card_country
          , i_network_id        => i_network_id
          , i_inst_id           => i_inst_id
          , i_pan_length        => l_pan_length
          , i_network_card_type => l_card_type_id
          , i_card_network_id   => l_card_network_id
          , i_card_inst_id      => l_card_inst_id
          , i_module_code       => RUS_MODULE_CODE 
          , i_priority          => i_priority
          , i_activation_date   => i_bin_rec.activation_date
          , i_card_type_id      => l_card_type_id
        );
            
    else
        begin
            select case substr(i_bin_rec.lo_range, 1, 1) 
                        when '4' then 1010 
                        when '5' then 1006
                        when '6' then 1005
                        else null
                   end
                 , case substr(i_bin_rec.lo_range, 1, 1) 
                        when '4' then 1003 
                        when '5' then 1002
                        when '6' then 1002
                        else null
                   end
                 , case substr(i_bin_rec.lo_range, 1, 1) 
                        when '4' then 9002 
                        when '5' then 9001
                        when '6' then 9001
                        else null
                   end
              into l_card_type_id 
                 , l_card_network_id
                 , l_card_inst_id
              from dual
             where substr(i_bin_rec.lo_range, 1, 1) in ('4', '5', '6');
             
            net_api_bin_pkg.add_bin_range(
                i_pan_low           => i_bin_rec.lo_range  
              , i_pan_high          => i_bin_rec.hi_range 
              , i_country           => '643'
              , i_network_id        => i_network_id
              , i_inst_id           => i_inst_id
              , i_pan_length        => length(i_bin_rec.lo_range)
              , i_network_card_type => null
              , i_card_network_id   => l_card_network_id
              , i_card_inst_id      => l_card_inst_id
              , i_module_code       => RUS_MODULE_CODE 
              , i_priority          => i_priority
              , i_activation_date   => i_bin_rec.activation_date
              , i_card_type_id      => l_card_type_id
            );
            
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error         => 'RUS_BIN_RANGE_NOT_FOUND'
                  , i_env_param1    => i_bin_rec.lo_range
                  , i_env_param2    => i_bin_rec.hi_range
                );
        end;
    end if;
    
end add_bin;
    
procedure load_bin(
    i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_network_id          in     com_api_type_pkg.t_tiny_id
  , i_priority            in     com_api_type_pkg.t_tiny_id
  , i_card_network_id     in     com_api_type_pkg.t_tiny_id
  , i_found_bin_priority  in     com_api_type_pkg.t_tiny_id
)is
    l_estimated_count            com_api_type_pkg.t_long_id := 0;
    l_processed_count            com_api_type_pkg.t_long_id := 0;
    l_excepted_count             com_api_type_pkg.t_long_id := 0;
begin
    savepoint sp_read_bin_start;
    
    trc_log_pkg.info(
        i_text          => 'Read bins start'
    );
    
    prc_api_stat_pkg.log_start;
    
    open cur_bin_count; 
    fetch cur_bin_count into l_estimated_count;
    close cur_bin_count;
    
    prc_api_stat_pkg.log_estimation(
        i_estimated_count    => l_estimated_count
    );
    
    if l_estimated_count > 0 then
    
        net_api_bin_pkg.cleanup_network_bins(
            i_network_id => i_network_id
        );
        
        open cur_bins;
        
        trc_log_pkg.debug(
            i_text           => 'Cursor opened. estimated_count ['||l_estimated_count||']'
        );

        if i_card_network_id not in (VISA_NETWORK_ID, MC_NETWORK_ID)
           or i_card_network_id is null
        then
            com_api_error_pkg.raise_error(
                i_error       => 'UNSUPPORTED_NETWORK'
              , i_env_param1  => i_card_network_id
            );
        end if;
        
        loop
            fetch cur_bins bulk collect into l_bin_tab limit 1000;
            
            trc_log_pkg.info(
                i_text          => '#1 records fetched'
              , i_env_param1    => l_bin_tab.count
            );
        
            for i in 1 .. l_bin_tab.count loop
                savepoint sp_process_bin_start;

                begin
                    if l_bin_tab(i).lo_range is not null then
                        add_bin(
                            i_bin_rec           => l_bin_tab(i)
                          , i_inst_id           => i_inst_id
                          , i_network_id        => i_network_id
                          , i_priority          => i_priority
                          , i_card_network_id   => i_card_network_id
                        );                
                    end if;
                    
                    l_processed_count := l_processed_count + 1;
                    
                exception
                    when others then
                        rollback to savepoint sp_process_bin_start;

                        if com_api_error_pkg.is_application_error(sqlcode) = com_api_type_pkg.TRUE then
                            l_excepted_count := l_excepted_count + 1;
                        else
                            close   cur_bins;
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

            exit when cur_bins%notfound;
            
        end loop;
        
        close cur_bins;
        
        for r in (
            select distinct
                   f.pan_low
                 , f.pan_high
                 , f.card_type_id
                 , f.country
                 , f.pan_length
                 , f.card_network_id
                 , f.card_inst_id
                 , f.activation_date
              from net_bin_range d
                 , net_bin_range f
             where d.iss_network_id  = i_network_id
               and d.pan_low        <= f.pan_high
               and d.pan_high       >= f.pan_low
               and f.iss_network_id  = i_card_network_id
        )
        loop
            net_api_bin_pkg.add_bin_range(
                i_pan_low           => r.pan_low
              , i_pan_high          => r.pan_high
              , i_country           => r.country
              , i_network_id        => i_network_id
              , i_inst_id           => i_inst_id
              , i_pan_length        => r.pan_length
              , i_network_card_type => r.card_type_id
              , i_card_network_id   => r.card_network_id
              , i_card_inst_id      => r.card_inst_id
              , i_module_code       => RUS_MODULE_CODE 
              , i_priority          => i_found_bin_priority
              , i_activation_date   => r.activation_date
              , i_card_type_id      => r.card_type_id
            );
        end loop;

        net_api_bin_pkg.rebuild_bin_index;

    end if;
    
    prc_api_stat_pkg.log_end(
        i_processed_total   => l_processed_count
      , i_excepted_total    => l_excepted_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
    
    trc_log_pkg.info(
        i_text          => 'Read bins end'
    );

exception
     when others then
        rollback to savepoint sp_read_bin_start;

        if cur_bins%isopen then
            close cur_bins;
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
    
end load_bin;

end rus_prc_bin_pkg;
/
