create or replace package body vis_prc_dictionary_pkg as
/************************************************************
 * Interface for loading dictionary files from Visa <br />
 * Created by Fomichev A.(fomichev@bpc.ru)  at 21.04.2010 <br />
 * Last changed by $Author: Fomichev A. $ <br />
 * $LastChangedDate:: 2010-04-29 10:32:00 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: vis_prc_dictionary_pkg <br />
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
        -- Fetch all new records with net BIN range into collection and check them
        select
            rpad(r.pan_low, r.pan_length, '0')
            , rpad(r.pan_high, r.pan_length, '9')
            , r.pan_length
            , min(m.priority)
            , min(m.card_type_id) keep (dense_rank first order by m.priority)
            , min(r.country)
            , i_iss_network_id
            , i_iss_inst_id
            , i_card_network_id
            , i_card_inst_id
            , vis_api_const_pkg.MODULE_CODE_VISA
            , null -- activation_date
            , null
        bulk collect into
            l_net_bin_range_tab
        from
            vis_bin_range r
            , net_card_type_map m
        where
            m.standard_id = i_standard_id
            and r.product_id like m.network_card_type
            and r.pan_length > 0
            and r.country like nvl(m.country, '%')
        group by
            rpad(r.pan_low, r.pan_length, '0')
            , rpad(r.pan_high, r.pan_length, '9')
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
            and module_code = vis_api_const_pkg.MODULE_CODE_VISA;

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
            select r.product_id                 , r.pan_low
              from vis_bin_range r
             where not exists (select null from net_card_type_map m
                                where r.product_id like m.network_card_type
                                  and m.standard_id = i_standard_id)
               and trim(r.product_id) not in ('DI', 'DN', 'M', 'JC', 'AX')
        ) loop
            trc_log_pkg.warn(
                i_text          => 'CARD_TYPE_MAPING_NOT_FOUND'
              , i_env_param1    => i_card_network_id
              , i_env_param2    => r.product_id
              , i_env_param3    => r.pan_low
            );
        end loop;

    end update_net_bin_range;

    procedure load_ardef (
        i_network_id                in com_api_type_pkg.t_tiny_id
        , i_inst_id                 in com_api_type_pkg.t_inst_id
        , i_card_network_id         in com_api_type_pkg.t_tiny_id
        , i_card_inst_id            in com_api_type_pkg.t_inst_id
    ) is
        l_estimated_count       com_api_type_pkg.t_long_id := 0;
        
        l_iss_inst_id               com_api_type_pkg.t_inst_id := i_inst_id;
        l_card_inst_id              com_api_type_pkg.t_inst_id := i_card_inst_id;
        l_card_network_id           com_api_type_pkg.t_inst_id := i_card_network_id;
        l_iss_network_id            com_api_type_pkg.t_tiny_id := i_network_id;
        l_standard_id               com_api_type_pkg.t_tiny_id;

        l_pan_low_tab               com_api_type_pkg.t_name_tab;
        l_pan_high_tab              com_api_type_pkg.t_name_tab;
    begin
        savepoint ardef_start_load;

        prc_api_stat_pkg.log_start;

        -- estimate records
        select
            count(*)
        into
            l_estimated_count
        from
            prc_session_file s
            , prc_file_raw_data d
        where
            s.session_id = get_session_id
            and d.session_file_id = s.id;

        prc_api_stat_pkg.log_estimation (
            i_estimated_count  => l_estimated_count
        );

        if l_card_inst_id is null then
            l_card_inst_id := net_api_network_pkg.get_inst_id(l_card_network_id);
        end if;
        if l_iss_network_id is null then
            l_iss_network_id := l_card_network_id;
        end if;
        if l_iss_inst_id is null then
            l_iss_inst_id := net_api_network_pkg.get_inst_id(l_iss_network_id);
        end if;
        l_standard_id := net_api_network_pkg.get_offline_standard(i_network_id => l_card_network_id);

        select trim(substr(raw_data, 13, 9))   pan_low
             , trim(substr(raw_data, 1, 9))    pan_high
          bulk collect into l_pan_low_tab
                          , l_pan_high_tab
          from prc_session_file s
             , prc_file_raw_data d
         where s.session_id = get_session_id
           and d.session_file_id = s.id
           and nvl(trim(substr(raw_data,34, 1)),'N') != 'Y'
           and (trim(substr(raw_data, 13, 9)), trim(substr(raw_data, 1, 9)))
               not in (select pan_low, pan_high from vis_bin_range);

        if l_pan_low_tab.count > 0 then
            for i in 1..l_pan_low_tab.count loop
                delete from vis_bin_range dst
                 where not (dst.pan_low = l_pan_low_tab(i) and dst.pan_high = l_pan_high_tab(i))
                          and (l_pan_low_tab(i) between dst.pan_low and dst.pan_high
                               or l_pan_high_tab(i) between dst.pan_low and dst.pan_high);
            end loop;
        end if;

        merge into vis_bin_range dst
        using (
            select
                b.pan_low
                , b.pan_high
                , b.pan_length
                , b.issuer_bin
                , b.processor_bin
                , b.check_digit
                , b.token_indicator
                , b.technology_indicator
                , b.region
                , c.code country
                , b.product_id
                , b.fast_funds
                , b.account_funding_source
            from (
                select
                    trim(substr(raw_data, 13, 9))   pan_low
                    , trim(substr(raw_data, 1, 9))  pan_high
                    , case when trim(substr(raw_data, 32, 2)) = '00' then '16' else trim(substr(raw_data, 32, 2)) end pan_length
                    , trim(substr(raw_data, 25, 6)) issuer_bin
                    , trim(substr(raw_data, 36, 6)) processor_bin
                    , trim(substr(raw_data, 31, 1)) check_digit
                    , trim(substr(raw_data, 34, 1)) token_indicator
                    , trim(substr(raw_data, 47, 1)) technology_indicator
                    , trim(substr(raw_data, 48, 1)) region
                    , trim(substr(raw_data, 49, 2)) country
                    , substr(raw_data, 59, 2)       product_id
                    , trim(substr(raw_data, 62, 1)) fast_funds
                    , trim(substr(raw_data, 70, 1)) account_funding_source
                from
                    prc_session_file s
                    , prc_file_raw_data d
                where
                    s.session_id = get_session_id
                    and d.session_file_id = s.id
                union all
                select trim(substr(raw_data, 13, 9)) pan_low
                     , trim(substr(raw_data, 1, 9))  pan_high
                     , '13'                          pan_length
                     , trim(substr(raw_data, 25, 6)) issuer_bin
                     , trim(substr(raw_data, 36, 6)) processor_bin
                     , trim(substr(raw_data, 31, 1)) check_digit
                     , trim(substr(raw_data, 34, 1)) token_indicator
                     , trim(substr(raw_data, 47, 1)) technology_indicator
                     , trim(substr(raw_data, 48, 1)) region
                     , trim(substr(raw_data, 49, 2)) country
                     , substr(raw_data, 59, 2)       product_id
                     , trim(substr(raw_data, 62, 1)) fast_funds
                     , trim(substr(raw_data, 70, 1)) account_funding_source
                from prc_session_file s
                   , prc_file_raw_data d
                where s.session_id                           = get_session_id
                  and d.session_file_id                      = s.id
                  and trim(substr(raw_data, 32, 2))          = '00'
                ) b
                , com_country c
            where
                c.visa_country_code(+) = b.country
                and (b.pan_low, b.pan_high) not in (select '000000000', '999999999' from dual)
        ) src
        on (
            dst.pan_low = src.pan_low
            and dst.pan_high = src.pan_high
            and dst.pan_length = src.pan_length
        )
        when matched then
            update
            set
                dst.issuer_bin       = src.issuer_bin
                , dst.processor_bin  = src.processor_bin
                , dst.check_digit    = src.check_digit
                , dst.token_indicator= src.token_indicator
                , dst.technology_indicator= src.technology_indicator
                , dst.region         = src.region
                , dst.country        = src.country
                , dst.valid          = 1
                , dst.network_id     = l_card_network_id
                , dst.inst_id        = l_card_inst_id
                , dst.product_id     = src.product_id
                , dst.fast_funds     = src.fast_funds
                , dst.account_funding_source = src.account_funding_source
                --  , DOMAIN, SERVICE_IND, TECH_IND -- not enough data for this fields
        when not matched then
            insert (
                dst.pan_low
                , dst.pan_high
                , dst.pan_length
                , dst.issuer_bin
                , dst.processor_bin
                , dst.check_digit
                , dst.token_indicator
                , dst.technology_indicator
                , dst.region,country
                , dst.valid
                , dst.network_id
                , dst.inst_id
                , dst.product_id
                , dst.fast_funds
                , dst.account_funding_source
            )
              --  , DOMAIN, SERVICE_IND, TECH_IND -- not enough data for this fields
            values (
                src.pan_low
                , src.pan_high
                , src.pan_length
                , src.issuer_bin
                , src.processor_bin
                , src.check_digit
                , src.token_indicator
                , src.technology_indicator
                , src.region
                , src.country
                , 1
                , i_card_network_id
                , l_card_inst_id
                , src.product_id
                , src.fast_funds
                , src.account_funding_source
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

        prc_api_stat_pkg.log_end (
            i_processed_total  => l_estimated_count
            , i_result_code    => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        );
    exception
        when others then
            rollback to savepoint ardef_start_load;

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

    procedure load_country is
        l_count                     com_api_type_pkg.t_long_id;
        l_correct_lines_count       com_api_type_pkg.t_long_id;
    begin
        savepoint start_load_country;

        prc_api_stat_pkg.log_start;

        select
            count(*) c1
            , sum(case when substr(raw_data, 1, 7)='CNTRYCD' then 1 else 0 end) c2
        into
            l_count
            , l_correct_lines_count
        from
            prc_session_file s
            , prc_file_raw_data d
        where
            s.session_id = get_session_id
            and d.session_file_id = s.id;

        if l_count != l_correct_lines_count then
            com_api_error_pkg.raise_error (
                i_error         => 'VISA_FILE_WRONG_FORMAT'
                , i_env_param1  => 'CNTRYCD'
                , i_env_param2  => l_count - l_correct_lines_count
            );
        end if;

        prc_api_stat_pkg.log_estimation (
            i_estimated_count => l_count * 3
        );

       -- Deleting records, that is not valid and exists in new file
        delete from
            vis_country
        where
            is_valid = com_api_const_pkg.FALSE
            and visa_country_code in (
                select
                    trim(substr(raw_data, 9, 2))
                from
                    prc_session_file s
                    , prc_file_raw_data d
                where
                    s.session_id = get_session_id
                    and d.session_file_id = s.id
            );
            
        -- inserting new records, except already existing in the VIS_COUNTRY table
        insert into vis_country(
            visa_country_code
            , curr_code
            , session_file_id
            , is_valid
        )
        select
            trim(substrb(raw_data, 9, 2)) country_code
            , trim(substr(raw_data,34, 3)) curr_code
            , d.session_file_id
            , com_api_const_pkg.true
        from
            prc_session_file s
            , prc_file_raw_data d
        where
            s.session_id = get_session_id
            and d.session_file_id = s.id
            and not exists (
                select
                    1
                from
                    vis_country c
                where
                    c.visa_country_code = trim(substr(d.raw_data, 9, 2))
            );

        prc_api_stat_pkg.increase_current (
            i_current_count     => l_count
            , i_excepted_count  => 0
        );

        insert into com_country (
            id
            , seqnum
            , code
            , name
            , curr_code
            , visa_country_code
            , mastercard_region
            , mastercard_eurozone
        )
        select
            com_country_seq.nextval
            , 1
            , 'V'||visa_country_code
            , 'V'||visa_country_code
            , curr_code
            , visa_country_code
            , null
            , null
        from
            vis_country v
        where
            not exists (
                select
                    1
                from
                    com_country c
                where
                    c.visa_country_code = v.visa_country_code
            );

        prc_api_stat_pkg.increase_current (
            i_current_count     => l_count
            , i_excepted_count  => 0
        );

        update
            com_country c
        set
            visa_country_code = null
        where not exists (
            select
                1
            from
                vis_country v
            where
                v.visa_country_code = v.visa_country_code
        );

        prc_api_stat_pkg.increase_current (
            i_current_count     => l_count
            , i_excepted_count  => 0
        );

        prc_api_stat_pkg.log_end (
            i_processed_total  => l_count
            , i_result_code    => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        );
    exception
        when others then
            rollback to savepoint start_load_country;

            prc_api_stat_pkg.log_end(
                i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
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

    procedure load_mcc is
        l_count                     com_api_type_pkg.t_long_id;
    begin
        savepoint start_load_mcc;
        
        prc_api_stat_pkg.log_start;

        select
            count(*)
        into
            l_count
        from
            prc_session_file s
            , prc_file_raw_data d
        where
            s.session_id = get_session_id
            and d.session_file_id = s.id;

        prc_api_stat_pkg.log_estimation (
            i_estimated_count  => l_count
        );

        insert into com_mcc (
            id
            , seqnum
            , mcc
            , tcc
            , diners_code
            , mastercard_cab_type
        )
        select
            com_mcc_seq.nextval
            , 1
            , mcc
            , null
            , null
            , null
        from (
            select
                lpad(to_char(mcc_low + dummy - 1, 'tm9'), 4, '0') as mcc
            from (
                select
                    to_number(trim(substr(d.raw_data, 21, 4))) mcc_low
                    , to_number(trim(substr(d.raw_data,  9, 4))) - to_number(trim(substr(d.raw_data, 21, 4))) + 1 n
                from
                    prc_session_file s
                    , prc_file_raw_data d
                where
                    s.session_id = get_session_id
                    and d.session_file_id = s.id
            ) t
            model
            return updated rows
            partition by(mcc_low) -- the values in the dataset must be unique
            dimension by (0 dummy)
            measures (n)
            rules ( n[for dummy from 1 to n[0] increment 1] = n[0] )
            minus
            select mcc from com_mcc
        );

        prc_api_stat_pkg.increase_current (
            i_current_count     => sql%rowcount
            , i_excepted_count  => l_count - sql%rowcount
        );

        prc_api_stat_pkg.log_end (
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        );

    exception
        when others then
            rollback to savepoint start_load_mcc;

            prc_api_stat_pkg.log_end (
                i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
            );

            if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
                raise;
            elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
                com_api_error_pkg.raise_fatal_error (
                    i_error         => 'UNHANDLED_EXCEPTION'
                    , i_env_param1  => sqlerrm
                );
            end if;
            raise;
    end;

    procedure load_currency is
        l_count                     com_api_type_pkg.t_long_id;
        l_correct_lines_count       com_api_type_pkg.t_long_id;
    begin
        savepoint start_load_currency;

        select
            count(*) c1
            , sum(case when substr(raw_data,1,7)='CURRTBL' then 1 else 0 end) c2
        into
            l_count
            , l_correct_lines_count
        from
            prc_session_file s
            , prc_file_raw_data d
        where
            s.session_id = get_session_id
            and d.session_file_id = s.id;

        if l_count != l_correct_lines_count then
            com_api_error_pkg.raise_fatal_error (
                i_error         => 'VISA_FILE_WRONG_FORMAT'
                , i_env_param1  => 'CURRTBL'
                , i_env_param2  => l_count - l_correct_lines_count
            );
        end if;

        prc_api_stat_pkg.log_start;

        prc_api_stat_pkg.log_estimation (
            i_estimated_count  => l_count
        );

        merge into com_currency c
        using (
            select
                trim(SUBSTR(raw_data, 9, 3))  code
                , trim(substr(raw_data, 36, 1)) exponent
                , trim(substr(raw_data, 33, 3)) name
            from
                prc_session_file s
                , prc_file_raw_data d
            where
                s.session_id = get_session_id
                and d.session_file_id = s.id
        ) f
        on (
            f.code = c.code
        )
        when matched then
            update
            set
                c.exponent = f.exponent
                , c.name = f.name
        when not matched then
            insert (
                id
                , code
                , name
                , exponent
                , seqnum
            )
            values (
                com_currency_seq.nextval
                , f.code
                , f.name
                , f.exponent
                , 1
            );

        prc_api_stat_pkg.increase_current (
            i_current_count     => l_count
            , i_excepted_count  => 0
        );

        prc_api_stat_pkg.log_end (
            i_processed_total  => l_count
            , i_result_code    => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        );

    exception
        when others then
            rollback to savepoint start_load_currency;

            prc_api_stat_pkg.log_end (
                i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
            );

            if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
                raise;
            elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
                com_api_error_pkg.raise_fatal_error (
                    i_error         => 'UNHANDLED_EXCEPTION'
                    , i_env_param1  => sqlerrm
                );
            end if;
            raise;
    end;
end;
/
