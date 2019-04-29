create or replace package body cst_bof_gim_prc_dictionary_pkg as
/*********************************************************
 *  Interface for loading dictionary files from GIM  <br />
 *  Created by Truschelev O.(truschelev@bpcbt.com)  at 01.09.2017 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: cst_bof_gim_prc_dictionary_pkg <br />
 *  @headcom
 **********************************************************/

    GIM_BIN_LENGTH         constant com_api_type_pkg.t_tiny_id := 16;

    procedure update_net_bin_range(
        i_iss_network_id         in com_api_type_pkg.t_tiny_id
      , i_iss_inst_id            in com_api_type_pkg.t_inst_id
      , i_card_network_id        in com_api_type_pkg.t_tiny_id
      , i_card_inst_id           in com_api_type_pkg.t_inst_id
      , i_standard_id            in com_api_type_pkg.t_tiny_id
    ) is
        l_net_bin_range_tab         net_api_type_pkg.t_net_bin_range_tab;
    begin
        -- Fetch all new records with net BIN range into collection and check them
        select rpad(r.pan_low,  greatest(length(r.pan_low), GIM_BIN_LENGTH), '0')
             , rpad(r.pan_high, greatest(length(r.pan_low), GIM_BIN_LENGTH), '9')
             , greatest(length(r.pan_low), GIM_BIN_LENGTH)
             , min(m.priority)
             , min(m.card_type_id) keep (dense_rank first order by m.priority)
             , min(r.country)
             , i_iss_network_id
             , i_iss_inst_id
             , i_card_network_id
             , i_card_inst_id
             , cst_bof_gim_api_const_pkg.MODULE_CODE_GIM
             , null -- activation_date
             , null
          bulk collect into l_net_bin_range_tab
          from cst_bof_gim_bin_range r
             , net_card_type_map m
         where m.standard_id    = i_standard_id
           and r.bin_type    like m.network_card_type
           and r.country     like nvl(m.country, '%')
         group by rpad(r.pan_low,  greatest(length(r.pan_low), GIM_BIN_LENGTH), '0')
                , rpad(r.pan_high, greatest(length(r.pan_low), GIM_BIN_LENGTH), '9')
                , greatest(length(r.pan_low), GIM_BIN_LENGTH)
                , r.bin_type;

        -- If check is not passed then appropriate error exception will be raised
        net_api_bin_pkg.check_bin_range(
            i_bin_range_tab => l_net_bin_range_tab
        );

        -- Otherwise, net BIN ranges is updated normally 
        delete from net_bin_range
         where iss_network_id = i_iss_network_id
           and iss_inst_id    = i_iss_inst_id
           and module_code    = cst_bof_gim_api_const_pkg.MODULE_CODE_GIM;

        forall i in l_net_bin_range_tab.first .. l_net_bin_range_tab.last
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
              , module_code
              , activation_date
              , account_currency
            ) values (
                l_net_bin_range_tab(i).pan_low
              , l_net_bin_range_tab(i).pan_high
              , l_net_bin_range_tab(i).pan_length
              , l_net_bin_range_tab(i).priority
              , l_net_bin_range_tab(i).card_type_id
              , l_net_bin_range_tab(i).country
              , l_net_bin_range_tab(i).iss_network_id
              , l_net_bin_range_tab(i).iss_inst_id
              , l_net_bin_range_tab(i).card_network_id
              , l_net_bin_range_tab(i).card_inst_id
              , l_net_bin_range_tab(i).module_code
              , l_net_bin_range_tab(i).activation_date
              , l_net_bin_range_tab(i).account_currency
            );

        for r in (
            select r.bin_type
                 , r.pan_low
              from cst_bof_gim_bin_range r
             where not exists (
                           select null from net_card_type_map m
                                where r.bin_type    like m.network_card_type
                                  and m.standard_id    = i_standard_id
                       )
        ) loop
            trc_log_pkg.warn(
                i_text          => 'CARD_TYPE_MAPING_NOT_FOUND'
              , i_env_param1    => i_card_network_id
              , i_env_param2    => r.bin_type
              , i_env_param3    => r.pan_low
            );
        end loop;

    end update_net_bin_range;

    procedure load_bin(
        i_network_id             in com_api_type_pkg.t_tiny_id  := null
      , i_inst_id                in com_api_type_pkg.t_inst_id  := null
      , i_card_network_id        in com_api_type_pkg.t_tiny_id
      , i_card_inst_id           in com_api_type_pkg.t_inst_id  := null
    ) is
        l_session_id                com_api_type_pkg.t_long_id;
        l_estimated_count           com_api_type_pkg.t_long_id  := 0;
        
        l_iss_inst_id               com_api_type_pkg.t_inst_id  := i_inst_id;
        l_card_inst_id              com_api_type_pkg.t_inst_id  := i_card_inst_id;
        l_card_network_id           com_api_type_pkg.t_inst_id  := i_card_network_id;
        l_iss_network_id            com_api_type_pkg.t_tiny_id  := i_network_id;
        l_standard_id               com_api_type_pkg.t_tiny_id;

        l_pan_low_tab               com_api_type_pkg.t_name_tab;
        l_pan_high_tab              com_api_type_pkg.t_name_tab;
    begin
        savepoint start_load_bin;

        prc_api_stat_pkg.log_start;

        l_session_id := get_session_id;

        -- estimate records
        select count(*)
          into l_estimated_count
          from prc_session_file s
             , prc_file_raw_data d
         where s.session_id      = l_session_id
           and d.session_file_id = s.id;

        prc_api_stat_pkg.log_estimation (
            i_estimated_count => l_estimated_count
        );

        if l_card_inst_id is null then
            l_card_inst_id   := net_api_network_pkg.get_inst_id(
                                    i_network_id => l_card_network_id
                                );
        end if;

        if l_iss_network_id is null then
            l_iss_network_id := l_card_network_id;
        end if;

        if l_iss_inst_id is null then
            l_iss_inst_id    := net_api_network_pkg.get_inst_id(
                                    i_network_id => l_iss_network_id
                                );
        end if;

        l_standard_id        := net_api_network_pkg.get_offline_standard(
                                    i_network_id => l_card_network_id
                                );

        select pan_low
             , pan_high
          bulk collect into l_pan_low_tab
                          , l_pan_high_tab
          from (
              select substr(d.raw_data, instr(d.raw_data, ';', 1, 1) + 1, instr(d.raw_data, ';', 1, 2) - instr(d.raw_data, ';', 1, 1) - 1) as pan_low
                   , substr(d.raw_data, instr(d.raw_data, ';', 1, 2) + 1, instr(d.raw_data, ';', 1, 3) - instr(d.raw_data, ';', 1, 2) - 1) as pan_high
                from prc_session_file s
                   , prc_file_raw_data d
               where s.session_id      = l_session_id
                 and d.session_file_id = s.id
           )
           where (pan_low, pan_high) not in (select pan_low, pan_high from cst_bof_gim_bin_range);

        if l_pan_low_tab.count > 0 then
            for i in 1 .. l_pan_low_tab.count loop
                delete from cst_bof_gim_bin_range dst
                 where not (
                           dst.pan_low      = l_pan_low_tab(i)
                           and dst.pan_high = l_pan_high_tab(i)
                       )
                       and (
                           l_pan_low_tab(i)     between dst.pan_low and dst.pan_high
                           or l_pan_high_tab(i) between dst.pan_low and dst.pan_high
                       );
            end loop;
        end if;

        merge into cst_bof_gim_bin_range dst
        using (
            select substr(d.raw_data, 1, instr(d.raw_data, ';', 1, 1) - 1)                                                               as issuer_bin
                 , substr(d.raw_data, instr(d.raw_data, ';', 1, 1) + 1, instr(d.raw_data, ';', 1, 2) - instr(d.raw_data, ';', 1, 1) - 1) as pan_low
                 , substr(d.raw_data, instr(d.raw_data, ';', 1, 2) + 1, instr(d.raw_data, ';', 1, 3) - instr(d.raw_data, ';', 1, 2) - 1) as pan_high
                 , substr(d.raw_data, instr(d.raw_data, ';', 1, 3) + 1, instr(d.raw_data, ';', 1, 4) - instr(d.raw_data, ';', 1, 3) - 1) as country
                 , substr(d.raw_data, instr(d.raw_data, ';', 1, 4) + 1, instr(d.raw_data, ';', 1, 5) - instr(d.raw_data, ';', 1, 4) - 1) as region
                 , substr(d.raw_data, instr(d.raw_data, ';', 1, 5) + 1, instr(d.raw_data, ';', 1, 6) - instr(d.raw_data, ';', 1, 5) - 1) as bin_type
            from prc_session_file s
               , prc_file_raw_data d
           where s.session_id      = l_session_id
             and d.session_file_id = s.id
        ) src
        on (
            dst.pan_low = src.pan_low
            and dst.pan_high = src.pan_high
            and dst.bin_type = src.bin_type
            and dst.country  = src.country
        )
        when matched then
            update
            set
                dst.issuer_bin = src.issuer_bin
              , dst.region     = src.region
        when not matched then
            insert (
                dst.id
              , dst.issuer_bin
              , dst.pan_low
              , dst.pan_high
              , dst.country
              , dst.region
              , dst.bin_type
            )
            values (
                cst_bof_gim_bin_range_seq.nextval
              , src.issuer_bin
              , src.pan_low
              , src.pan_high
              , src.country
              , src.region
              , src.bin_type
            );
        
        prc_api_stat_pkg.increase_current (
            i_current_count      => l_estimated_count
          , i_excepted_count     => 0
        );

        for r in (
            select id
                 , pan_low
                 , pan_high
              from cst_bof_gim_bin_range
             where length(pan_low) != length(pan_high)
        ) loop
            trc_log_pkg.error(
                i_text        => 'GIF_BIN_LOW_HIGH_HAS_DIFFERENT_LENGTH'
              , i_env_param1  => r.pan_low
              , i_env_param2  => r.pan_high
            );

            delete from cst_bof_gim_bin_range
             where id = r.id;
        end loop;

        update_net_bin_range (
            i_iss_network_id     => l_iss_network_id
          , i_iss_inst_id        => l_iss_inst_id
          , i_card_network_id    => l_card_network_id
          , i_card_inst_id       => l_card_inst_id
          , i_standard_id        => l_standard_id
        );

        net_api_bin_pkg.rebuild_bin_index;

        prc_api_stat_pkg.log_end (
            i_processed_total    => l_estimated_count
            , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        );
    exception
        when others then
            rollback to savepoint start_load_bin;

            prc_api_stat_pkg.log_end (
                i_result_code    => prc_api_const_pkg.PROCESS_RESULT_FAILED
            );
            if com_api_error_pkg.is_fatal_error(SQLCODE) = com_api_const_pkg.TRUE then
                raise;
            elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
                com_api_error_pkg.raise_fatal_error(
                    i_error      => 'UNHANDLED_EXCEPTION'
                  , i_env_param1 => sqlerrm
                );
            end if;
            raise;
    end load_bin;

end cst_bof_gim_prc_dictionary_pkg;
/
