create or replace package body cup_prc_dictionary_pkg as
/************************************************************
 * Interface for loading dictionary files from China UnionPay <br />
 * Created by Truschelev O.(truschelev@bpcbt.com)  at 14.05.2016 <br />
 * Last changed by $Author: Truschelev O. $ <br />
 * $LastChangedDate:: 2016-05-14 17:59:00 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: cup_prc_dictionary_pkg <br />
 * @headcom
 ************************************************************/

    procedure update_net_bin_range (
        i_iss_network_id            in com_api_type_pkg.t_tiny_id
        , i_iss_inst_id             in com_api_type_pkg.t_inst_id
        , i_card_network_id         in com_api_type_pkg.t_tiny_id
        , i_card_inst_id            in com_api_type_pkg.t_inst_id
        , i_standard_id             in com_api_type_pkg.t_tiny_id
    ) is
        l_net_bin_range_tab         net_api_type_pkg.t_net_bin_range_tab;
    begin
        trc_log_pkg.debug (
            i_text         => 'update_net_bin_range start. i_iss_network_id [#1] i_iss_inst_id [#2] i_card_network_id [#3] i_card_inst_id [#4] i_standard_id [#5]'
          , i_env_param1   => i_iss_network_id
          , i_env_param2   => i_iss_inst_id
          , i_env_param3   => i_card_network_id
          , i_env_param4   => i_card_inst_id
          , i_env_param5   => i_standard_id
        );

        -- Fetch all new records with net BIN range into collection and check them
        select rpad(r.pan_bin, r.pan_length, '0')
             , rpad(r.pan_bin, r.pan_length, '9')
             , r.pan_length
             , min(m.priority)
             , min(m.card_type_id) keep (dense_rank first order by m.priority)
             , min(r.issuing_region)
             , i_iss_network_id
             , i_iss_inst_id
             , i_card_network_id
             , i_card_inst_id
             , cup_api_const_pkg.MODULE_CODE_CUP
             , null  -- activation_date
             , null
        bulk collect into l_net_bin_range_tab
        from cup_bin_range r
           , net_card_type_map m
        where m.standard_id = i_standard_id
          and r.card_product like m.network_card_type
          and r.pan_length > 0
          and r.issuing_region like nvl(m.country, '%')
        group by rpad(r.pan_bin, r.pan_length, '0')
               , rpad(r.pan_bin, r.pan_length, '9')
               , r.pan_length;

        -- If check is not passed then appropriate error exception will be raised
        net_api_bin_pkg.check_bin_range(
            i_bin_range_tab => l_net_bin_range_tab
        );

        -- Otherwise, net BIN ranges is updated normally 
        delete from
            net_bin_range
        where
            iss_network_id = i_iss_network_id
            and iss_inst_id = i_iss_inst_id
            and module_code = cup_api_const_pkg.MODULE_CODE_CUP;

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
            select r.card_product
                 , r.pan_bin
              from cup_bin_range r
             where not exists (select 1
                                 from net_card_type_map m
                                where r.card_product like m.network_card_type
                                  and m.standard_id = i_standard_id
                       )
               and trim(r.card_product) not in ('DI', 'DN', 'M', 'JC', 'AX')
        ) loop
            trc_log_pkg.warn(
                i_text          => 'CARD_TYPE_MAPING_NOT_FOUND'
              , i_env_param1    => i_card_network_id
              , i_env_param2    => r.card_product
              , i_env_param3    => r.pan_bin
            );
        end loop;

        trc_log_pkg.debug (
            i_text         => 'update_net_bin_range finish'
        );

    end update_net_bin_range;

    procedure load_bin (
        i_network_id             in com_api_type_pkg.t_tiny_id := null
        , i_inst_id              in com_api_type_pkg.t_inst_id := null
        , i_card_network_id      in com_api_type_pkg.t_tiny_id
        , i_card_inst_id         in com_api_type_pkg.t_inst_id := null
    ) is
        l_estimated_count           com_api_type_pkg.t_long_id  := 0;
        l_session_id                com_api_type_pkg.t_long_id;
        
        l_iss_inst_id               com_api_type_pkg.t_inst_id  := i_inst_id;
        l_card_inst_id              com_api_type_pkg.t_inst_id  := i_card_inst_id;
        l_card_network_id           com_api_type_pkg.t_inst_id  := i_card_network_id;
        l_iss_network_id            com_api_type_pkg.t_tiny_id  := i_network_id;
        l_standard_id               com_api_type_pkg.t_tiny_id;
    begin
        savepoint start_load_bin;

        trc_log_pkg.debug (
            i_text         => 'CUP BIN loading start. i_network_id [#1] i_inst_id [#2] i_card_network_id [#3] i_card_inst_id [#4]'
          , i_env_param1   => i_network_id
          , i_env_param2   => i_inst_id
          , i_env_param3   => i_card_network_id
          , i_env_param4   => i_card_inst_id
        );

        prc_api_stat_pkg.log_start;

        l_session_id := get_session_id;

        -- estimate records
        select count(1)
          into l_estimated_count
          from prc_session_file s
             , prc_file_raw_data d
         where s.session_id      = l_session_id
           and d.session_file_id = s.id
           and substr(raw_data, 1, 4) not in ('HHHH', 'TTTT');

        prc_api_stat_pkg.log_estimation (
            i_estimated_count  => l_estimated_count
        );

        trc_log_pkg.debug (
            i_text         => 'CUP BIN loading start. l_estimated_count [#1]'
          , i_env_param1   => l_estimated_count
        );

        if l_estimated_count > 0 then

            for r in (
                -- Check BIN's duplicates.
                select pan_bin
                     , pan_length
                     , bin_count
                  from (
                        select trim(substr(d.raw_data, 114,  12)) as pan_bin
                             , trim(substr(d.raw_data, 126,   2)) as pan_length
                             , s.id                               as session_file_id
                             , count(1) over(partition by trim(substr(d.raw_data, 114,  12))
                                                        , trim(substr(d.raw_data, 126,   2))
                                                        , session_file_id
                               ) as bin_count
                          from prc_session_file s
                             , prc_file_raw_data d
                         where s.session_id      = l_session_id
                           and d.session_file_id = s.id
                           and substr(raw_data, 1, 4) not in ('HHHH', 'TTTT')
                  )
                  where bin_count > 1
                    and rownum = 1
            )
            loop
                com_api_error_pkg.raise_error(
                    i_error      => 'DUPLICATE_BIN'
                  , i_env_param1 => r.pan_bin
                  , i_env_param2 => r.pan_length
                  , i_env_param3 => r.bin_count
                );
            end loop;

            if l_card_inst_id is null then
                l_card_inst_id := net_api_network_pkg.get_inst_id(
                                      i_network_id => l_card_network_id
                                  );
            end if;

            if l_iss_network_id is null then
                l_iss_network_id := l_card_network_id;
            end if;

            if l_iss_inst_id is null then
                l_iss_inst_id := net_api_network_pkg.get_inst_id(
                                     i_network_id => l_iss_network_id
                                 );
            end if;

            l_standard_id := net_api_network_pkg.get_offline_standard(
                                 i_network_id => l_card_network_id
                             );

            -- The CUP specification contains the next requirement:
            -- CUPS informs the Members' system to update information of card BIN by sending the whole-library BIN file.
            delete from cup_bin_range;

            merge into cup_bin_range dst
            using (
                    select trim(substr(d.raw_data,   1,  11)) as issuer_iin
                         , trim(substr(d.raw_data,  12,  60)) as issuer_name
                         , trim(substr(d.raw_data,  72,   1)) as card_level
                         , trim(substr(d.raw_data,  74,   3)) as issuing_region
                         ,      substr(d.raw_data,  77,   2)  as card_product
                         , trim(substr(d.raw_data, 112,   2)) as bin_length
                         , trim(substr(d.raw_data, 114,  12)) as pan_bin
                         , trim(substr(d.raw_data, 126,   2)) as pan_length
                         , trim(substr(d.raw_data, 128,   1)) as card_type
                         , trim(substr(d.raw_data, 129,   1)) as message_type
                         , trim(substr(d.raw_data, 130,   3)) as billing_currency
                         , trim(substr(d.raw_data, 133,  13)) as transaction_type
                         , trim(substr(d.raw_data, 146,  13)) as transaction_channel
                         , trim(substr(d.raw_data, 160,   1)) as network_opened
                    from prc_session_file s
                       , prc_file_raw_data d
                   where s.session_id      = l_session_id
                     and d.session_file_id = s.id
                     and substr(raw_data, 1, 4) not in ('HHHH', 'TTTT')
            ) src
            on (
                dst.pan_bin = src.pan_bin
            )
            when matched then
                update
                set   dst.issuer_iin          = src.issuer_iin
                    , dst.issuer_name         = src.issuer_name
                    , dst.card_level          = src.card_level
                    , dst.issuing_region      = src.issuing_region
                    , dst.card_product        = src.card_product
                    , dst.bin_length          = src.bin_length
                    , dst.pan_length          = src.pan_length
                    , dst.card_type           = src.card_type
                    , dst.message_type        = src.message_type
                    , dst.billing_currency    = src.billing_currency
                    , dst.transaction_type    = src.transaction_type
                    , dst.transaction_channel = src.transaction_channel
                    , dst.network_opened      = src.network_opened
                    , dst.valid               = 1
                    , dst.inst_id             = l_card_inst_id
                    , dst.network_id          = l_card_network_id
            when not matched then
                insert (
                      dst.issuer_iin
                    , dst.issuer_name
                    , dst.card_level
                    , dst.issuing_region
                    , dst.card_product
                    , dst.bin_length
                    , dst.pan_bin
                    , dst.pan_length
                    , dst.card_type
                    , dst.message_type
                    , dst.billing_currency
                    , dst.transaction_type
                    , dst.transaction_channel
                    , dst.network_opened
                    , dst.valid
                    , dst.inst_id
                    , dst.network_id
                )
                values (
                      src.issuer_iin
                    , src.issuer_name
                    , src.card_level
                    , src.issuing_region
                    , src.card_product
                    , src.bin_length
                    , src.pan_bin
                    , src.pan_length
                    , src.card_type
                    , src.message_type
                    , src.billing_currency
                    , src.transaction_type
                    , src.transaction_channel
                    , src.network_opened
                    , 1
                    , l_card_inst_id
                    , l_card_network_id
                );
            
            prc_api_stat_pkg.increase_current (
                i_current_count     => l_estimated_count
                , i_excepted_count  => 0
            );

            update_net_bin_range (
                i_iss_network_id     => l_iss_network_id
                , i_iss_inst_id      => l_iss_inst_id
                , i_card_network_id  => l_card_network_id
                , i_card_inst_id     => l_card_inst_id
                , i_standard_id      => l_standard_id
            );

            net_api_bin_pkg.rebuild_bin_index;

        end if;  -- if l_estimated_count > 0

        prc_api_stat_pkg.log_end (
            i_processed_total  => l_estimated_count
            , i_result_code    => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        );

        trc_log_pkg.debug (
            i_text         => 'CUP BIN loading finish'
        );
    exception
        when others then
            rollback to savepoint start_load_bin;

            prc_api_stat_pkg.log_end (
                i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
            );
            if com_api_error_pkg.is_fatal_error(SQLCODE) = com_api_const_pkg.TRUE then
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
