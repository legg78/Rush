create or replace package body mup_prc_bin_pkg is

    BULK_LIMIT                   constant integer := 1000;
    MINIMUM_FILLED_BIN_LENGTH    constant com_api_type_pkg.t_tiny_id    := 16;
    FILLED_BIN_LENGTH            constant com_api_type_pkg.t_tiny_id    := 19;

    cursor cur_iss_bins (
        p_priority      in com_api_type_pkg.t_tiny_id
    ) is
        select to_date(x.eff_date, 'yyyymmdd') as eff_date
             , x.member_id
             , (case
                    when length(x.pan_low) < MINIMUM_FILLED_BIN_LENGTH
                    then rpad(x.pan_low, FILLED_BIN_LENGTH, '0')
                    else x.pan_low
                    end
               )  as pan_low
             , (case
                    when length(x.pan_high) < MINIMUM_FILLED_BIN_LENGTH
                    then rpad(x.pan_high, FILLED_BIN_LENGTH, '9')
                    else x.pan_high
                    end
               ) as pan_high
             , x.member_name
             , x.product_id
             , x.country
             , x.crdh_curr_code
             , p_priority as priority
          from prc_session_file s
             , prc_file_attribute a
             , prc_file f
             , xmltable(
               --  xmlnamespaces(default 'http://bpc.ru/sv/SVXP/bin'),
                '/dataset/record'
                 passing s.file_xml_contents
                 columns
                     eff_date        varchar2(8)     path 'EFFECTIVE_DATE'
                   , member_id       varchar2(11)    path 'MEMBER_ID'
                   , pan_low         varchar2(19)    path 'LO_RANGE'
                   , pan_high        varchar2(19)    path 'HI_RANGE'
                   , member_name     varchar2(50)    path 'BANK_NAME'
                   , product_id      varchar2(3)     path 'PRODUCT_CODE'
                   , country         varchar2(3)     path 'COUNTRY_CODE'
                   , crdh_curr_code  varchar2(3)     path 'BILCURRENCY_CODE' -- Cardholder Billing Currency Code . 
             ) x
         where s.session_id   = get_session_id
           and s.file_attr_id = a.id
           and f.id           = a.file_id
           and f.file_type    = mup_api_const_pkg.FILE_TYPE_ISSUER_BIN;

    cursor cur_acq_bins is
        select to_date(x.eff_date, 'yyyymmdd') as eff_date
             , x.member_id
             , x.acq_bin
             , x.country
             , x.member_name
          from prc_session_file s
             , prc_file_attribute a
             , prc_file f
             , xmltable(
               --  xmlnamespaces(default 'http://bpc.ru/sv/SVXP/bin'),
                '/dataset/record'
                 passing s.file_xml_contents
                 columns
                     eff_date        varchar2(8)     path 'EFFECTIVE_DATE'
                   , member_id       varchar2(11)    path 'MEMBER_ID'
                   , acq_bin         varchar(6)      path 'BIN'
                   , country         varchar2(3)     path 'COUNTRY_CODE'
                   , member_name     varchar2(50)    path 'BANK_NAME'
              ) x
          where s.session_id   = get_session_id
            and s.file_attr_id = a.id
            and f.id           = a.file_id
            and f.file_type    = mup_api_const_pkg.FILE_TYPE_ACQUIRER_BIN;

    cursor cur_bin_count is
        select nvl(sum(bin_count), 0) bin_count
           from prc_session_file s
              , prc_file_attribute a
              , prc_file f
              , xmltable(--  xmlnamespaces(default 'http://bpc.ru/sv/SVXP/bin'),
                      '/dataset/record' passing s.file_xml_contents
                       columns
                            bin_count          number     path 'fn:count(MEMBER_ID)'
              ) x
          where s.session_id = get_session_id
            and s.file_attr_id = a.id
            and f.id = a.file_id;

    type t_iss_bin_rec is record (
        eff_date        date
      , member_id       com_api_type_pkg.t_medium_id
      , pan_low         com_api_type_pkg.t_card_number
      , pan_high        com_api_type_pkg.t_card_number
      , member_name     com_api_type_pkg.t_name
      , product_id      com_api_type_pkg.t_mcc
      , country         com_api_type_pkg.t_country_code
      , crdh_curr_code  com_api_type_pkg.t_curr_code
      , priority        com_api_type_pkg.t_tiny_id
    );

    type t_acq_bin_rec is record (
        eff_date        date
      , member_id       com_api_type_pkg.t_medium_id
      , acq_bin         com_api_type_pkg.t_bin
      , country         com_api_type_pkg.t_country_code
      , member_name     com_api_type_pkg.t_name
    );

    type t_iss_bin_tab     is varray(1000) of t_iss_bin_rec;
    l_iss_bin_tab          t_iss_bin_tab;

    type t_acq_bin_tab     is varray(1000) of t_acq_bin_rec;
    l_acq_bin_tab          t_acq_bin_tab;

procedure update_net_bin_range(
    i_iss_network_id          in com_api_type_pkg.t_tiny_id
  , i_iss_inst_id             in com_api_type_pkg.t_inst_id
  , i_card_network_id         in com_api_type_pkg.t_tiny_id
  , i_card_inst_id            in com_api_type_pkg.t_inst_id
  , i_standard_id             in com_api_type_pkg.t_tiny_id
) is
    l_net_bin_range_tab         net_api_type_pkg.t_net_bin_range_tab;
begin
    -- Fetch all new records with net BIN range into collection and check them
    select pan_low
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
      bulk collect
      into l_net_bin_range_tab
      from (
        select rpad(r.acq_bin, MINIMUM_FILLED_BIN_LENGTH, '0')  pan_low
             , rpad(r.acq_bin, MINIMUM_FILLED_BIN_LENGTH, '9')  pan_high
             , MINIMUM_FILLED_BIN_LENGTH                        pan_length
             , null                                             priority
             , null                                             card_type_id
             , min(r.country)                                   country
             , i_iss_network_id                                 iss_network_id
             , i_iss_inst_id                                    iss_inst_id
             , i_card_network_id                                card_network_id
             , i_card_inst_id                                   card_inst_id
             , null                                             activation_date
             , mup_api_const_pkg.MODULE_CODE_MUP                module_code
             , null                                             account_currency
          from mup_acq_bin r
         group by r.acq_bin
        union all
        select r.pan_low
             , r.pan_high
             , length(r.pan_low)                    pan_length
             , min(nvl(r.priority, m.priority))     priority
             , min(m.card_type_id) keep (dense_rank first order by m.priority)  card_type_id
             , min(r.country)                       country
             , i_iss_network_id                     iss_network_id
             , i_iss_inst_id                        iss_inst_id
             , i_card_network_id                    card_network_id
             , i_card_inst_id                       card_inst_id
             , null                                 activation_date
             , mup_api_const_pkg.MODULE_CODE_MUP    module_code
             , null                                 account_currency
          from mup_bin_range r
             , net_card_type_map m
         where m.standard_id = i_standard_id
           and r.product_id like m.network_card_type
           and r.country like nvl(m.country, '%')
         group by r.pan_low
             , r.pan_high
           );

    -- If check is not passed then appropriate error exception will be raised
    net_api_bin_pkg.check_bin_range(
        i_bin_range_tab => l_net_bin_range_tab
    );

    -- Otherwise, net BIN ranges is updated normally
    delete from net_bin_range
    where iss_network_id = i_card_network_id
      and iss_inst_id    = i_card_inst_id
      and module_code    = mup_api_const_pkg.MODULE_CODE_MUP;

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
        );

    for r in (select r.product_id
                   , r.pan_low
                   , r.pan_high
                from mup_bin_range r
               where not exists (select null
                                   from net_card_type_map m
                                  where r.product_id like m.network_card_type
                                    and m.standard_id = i_standard_id
                                )
    ) loop
        trc_log_pkg.error(
            i_text          => 'IMPOSSIBLE_DEFINE_CARD_TYPE'
          , i_env_param1    => i_card_network_id
          , i_env_param2    => r.product_id
          , i_env_param3    => r.pan_low
        );
    end loop;

    net_api_bin_pkg.rebuild_bin_index;

end update_net_bin_range;

procedure add_mup_bin(
    i_bin_rec         in    t_iss_bin_rec
) is
begin

    merge into mup_bin_range dst
    using (
            select i_bin_rec.eff_date       eff_date
                 , i_bin_rec.member_id      member_id
                 , i_bin_rec.pan_low        pan_low
                 , i_bin_rec.pan_high       pan_high
                 , i_bin_rec.member_name    member_name
                 , i_bin_rec.product_id     product_id
                 , i_bin_rec.country        country
                 , i_bin_rec.crdh_curr_code crdh_curr_code
                 , i_bin_rec.priority       priority
              from dual
          ) src
       on (
            src.pan_low    = dst.pan_low
        and src.pan_high   = dst.pan_high
        and src.product_id = dst.product_id
          )
    when matched then
        update
           set dst.eff_date       = src.eff_date
             , dst.member_id      = src.member_id
             , dst.member_name    = src.member_name
             , dst.country        = src.country
             , dst.crdh_curr_code = src.crdh_curr_code
             , dst.priority       = src.priority
    when not matched then
        insert (
            dst.eff_date
          , dst.member_id
          , dst.pan_low
          , dst.pan_high
          , dst.member_name
          , dst.product_id
          , dst.country
          , dst.crdh_curr_code
          , dst.priority
        ) values (
            src.eff_date
          , src.member_id
          , src.pan_low
          , src.pan_high
          , src.member_name
          , src.product_id
          , src.country
          , src.crdh_curr_code
          , src.priority
        );
end;

procedure add_acq_bin(
    i_bin_rec         in    t_acq_bin_rec
) is
begin
    merge into mup_acq_bin dst
    using (
            select i_bin_rec.eff_date       eff_date
                 , i_bin_rec.member_id      member_id
                 , i_bin_rec.acq_bin        acq_bin
                 , i_bin_rec.country        country
                 , i_bin_rec.member_name    member_name
              from dual
          ) src
       on (
            src.acq_bin    = dst.acq_bin
          )
    when matched then
        update
           set dst.eff_date       = src.eff_date
             , dst.member_id      = src.member_id
             , dst.country        = src.country
             , dst.member_name    = src.member_name
    when not matched then
        insert (
            dst.eff_date
          , dst.member_id
          , dst.acq_bin
          , dst.country
          , dst.member_name
        ) values (
            src.eff_date
          , src.member_id
          , src.acq_bin
          , src.country
          , src.member_name
        );
end add_acq_bin;

procedure load_bin(
    i_inst_id         in    com_api_type_pkg.t_inst_id
  , i_network_id      in    com_api_type_pkg.t_tiny_id
  , i_priority        in    com_api_type_pkg.t_tiny_id
  , i_cleanup_bins    in    com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
) is
    l_estimated_count       com_api_type_pkg.t_long_id := 0;
    l_processed_count       com_api_type_pkg.t_long_id := 0;
    l_excepted_count        com_api_type_pkg.t_long_id := 0;
begin
    savepoint read_bin_start;

    trc_log_pkg.info(
        i_text          => 'Read bins start'
    );

    prc_api_stat_pkg.log_start;

    open cur_bin_count;
    fetch cur_bin_count into l_estimated_count;
    close cur_bin_count;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count       => l_estimated_count
    );

    if l_estimated_count > 0 then

        if nvl(i_cleanup_bins, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE then
            net_api_bin_pkg.cleanup_network_bins(
                i_network_id        => i_network_id
            );
        end if;

        -- Issuer BINs loading
        open cur_iss_bins(i_priority);

        trc_log_pkg.debug(
            i_text          => 'cursor opened ('||l_estimated_count||')'
        );

        loop
            fetch cur_iss_bins bulk collect
             into l_iss_bin_tab
            limit BULK_LIMIT;

            trc_log_pkg.info(
                i_text          => '#1 records fetched'
              , i_env_param1    => l_iss_bin_tab.count
            );

            for i in 1 .. l_iss_bin_tab.count loop
                savepoint process_iss_bin_start;

                begin
                    if l_iss_bin_tab(i).pan_low is not null then
                        add_mup_bin(
                            i_bin_rec         => l_iss_bin_tab(i)
                        );
                    end if;

                    l_processed_count := l_processed_count + 1;

                exception
                    when others then
                        rollback to savepoint process_iss_bin_start;
                        if com_api_error_pkg.is_application_error(sqlcode) = com_api_type_pkg.TRUE then
                            l_excepted_count := l_excepted_count + 1;
                        else
                            close cur_iss_bins;
                            raise;
                        end if;
                end;

                if mod(l_processed_count, 100) = 0 then
                    prc_api_stat_pkg.log_current(
                        i_current_count     => l_processed_count
                      , i_excepted_count    => l_excepted_count
                    );

                end if;

            end loop;

            exit when cur_iss_bins%notfound;

        end loop;

        close cur_iss_bins;

        --Acquirer BINs loading
        open cur_acq_bins;

        trc_log_pkg.debug(
            i_text          => 'cursor opened ('||l_estimated_count||')'
        );

        loop
            fetch cur_acq_bins bulk collect
             into l_acq_bin_tab
            limit BULK_LIMIT;

            trc_log_pkg.info(
                i_text          => '#1 records fetched'
              , i_env_param1    => l_acq_bin_tab.count
            );

            for i in 1 .. l_acq_bin_tab.count loop
                savepoint process_acq_bin_start;

                begin
                    if l_acq_bin_tab(i).acq_bin is not null then
                        add_acq_bin(
                            i_bin_rec         => l_acq_bin_tab(i)
                        );
                    end if;

                    l_processed_count := l_processed_count + 1;

                exception
                    when others then
                        rollback to savepoint process_acq_bin_start;
                        if com_api_error_pkg.is_application_error(sqlcode) = com_api_type_pkg.TRUE then
                            l_excepted_count := l_excepted_count + 1;
                        else
                            close cur_acq_bins;
                            raise;
                        end if;
                end;

                if mod(l_processed_count, 100) = 0 then
                    prc_api_stat_pkg.log_current(
                        i_current_count     => l_processed_count
                      , i_excepted_count    => l_excepted_count
                    );

                end if;

            end loop;

            exit when cur_acq_bins%notfound;

        end loop;

        close cur_acq_bins;

        update_net_bin_range(
            i_iss_network_id    => nvl(i_network_id, mup_api_const_pkg.MUP_NETWORK_ID)
          , i_iss_inst_id       => nvl(i_inst_id, mup_api_const_pkg.NATIONAL_PROC_CENTER_INST)
          , i_card_network_id   => mup_api_const_pkg.MUP_NETWORK_ID
          , i_card_inst_id      => mup_api_const_pkg.NATIONAL_PROC_CENTER_INST
          , i_standard_id       => net_api_network_pkg.get_offline_standard(i_network_id => mup_api_const_pkg.MUP_NETWORK_ID)
        );

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
        rollback to savepoint read_bin_start;

        if cur_iss_bins%isopen then
            close cur_iss_bins;
        end if;

        if cur_acq_bins%isopen then
            close cur_acq_bins;
        end if;

        prc_api_stat_pkg.log_end(
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


end mup_prc_bin_pkg;
/
