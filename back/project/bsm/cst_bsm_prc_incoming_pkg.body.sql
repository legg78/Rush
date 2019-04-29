create or replace package body cst_bsm_prc_incoming_pkg is

-- Import information of priority product details in CSV format
procedure process_priority_prod_details is
    LOG_PREFIX       constant com_api_type_pkg.t_name    := lower($$PLSQL_UNIT) || '.process_priority_prod_details: ';
    DELIM            constant com_api_type_pkg.t_name    := '|';
    DATE_FORMAT      constant com_api_type_pkg.t_name    := 'yyyy-mm-dd hh24:mi:ss';
    l_record_count            com_api_type_pkg.t_long_id;
    l_estimated_count         com_api_type_pkg.t_long_id;
    l_errors_count            com_api_type_pkg.t_long_id := 0;
begin
    trc_log_pkg.debug( i_text => LOG_PREFIX || ' started' );
    prc_api_stat_pkg.log_start;

    for f in (
        select id              session_file_id
             , count(1)        record_count
             , sum(count(1)) over() total_cnt
             , row_number() over(order by f.id) rn
          from prc_session_file f
             , prc_file_raw_data d
         where f.session_id = prc_api_session_pkg.get_session_id
           and f.id         = d.session_file_id
      group by f.id
      order by f.id
    ) loop
        if f.rn = 1 then
            l_estimated_count := f.total_cnt;
            prc_api_stat_pkg.log_estimation (
                i_estimated_count  => l_estimated_count
            );

            l_record_count := 0;
        end if;

        trc_log_pkg.debug(i_text => LOG_PREFIX || 'processing session_file_id [' || f.session_file_id || ']' );

        begin
            savepoint sp_priority_prod_details;

            merge into cst_bsm_priority_prod_details dst
            using (select substr(r.raw_data,         1,        r.d1 - 1)                       IDFundProduct
                        , substr(r.raw_data,         r.d1 + 1, r.d2  - r.d1 - 1)               IDFundProductGroup
                        , substr(r.raw_data,         r.d2 + 1, r.d3  - r.d2 - 1)               FundProductCode
                        , substr(r.raw_data,         r.d3 + 1, r.d4  - r.d3 - 1)               FundProductDesc
                        , substr(r.raw_data,         r.d4 + 1, r.d5  - r.d4 - 1)               FundProductCategory
                        , substr(r.raw_data,         r.d5 + 1, r.d6  - r.d5 - 1)               FundProductSubCategory
                        , substr(r.raw_data,         r.d6 + 1, r.d7  - r.d6 - 1)               FundProduct_Level3
                        , to_date(substr(r.raw_data, r.d7 + 1, r.d8  - r.d7 - 5), DATE_FORMAT) EntryDate
                        , substr(r.raw_data,         r.d8 + 1, r.d9  - r.d8 - 1)               FundProduct_Level4
                        , substr(r.raw_data,         r.d9 + 1, r.d10 - r.d9)                   Akad
                     from (select raw_data
                                , instr(raw_data, DELIM, 1, 1) d1
                                , instr(raw_data, DELIM, 1, 2) d2
                                , instr(raw_data, DELIM, 1, 3) d3
                                , instr(raw_data, DELIM, 1, 4) d4
                                , instr(raw_data, DELIM, 1, 5) d5
                                , instr(raw_data, DELIM, 1, 6) d6
                                , instr(raw_data, DELIM, 1, 7) d7
                                , instr(raw_data, DELIM, 1, 8) d8
                                , instr(raw_data, DELIM, 1, 9) d9
                                , length(raw_data)             d10
                             from prc_file_raw_data d
                            where d.session_file_id = f.session_file_id
                              and d.record_number > 1
                          ) r
                  ) src
            on (dst.product_id        = src.IDFundProduct
            and dst.parent_product_id = src.IDFundProductGroup
            and dst.product_number    = FundProductCode)
            when matched then
                update set dst.product_description = src.FundProductDesc
                         , dst.product_category    = src.FundProductCategory
                         , dst.product_subcategory = src.FundProductSubCategory
                         , dst.product_level3      = src.FundProduct_Level3
                         , dst.creation_date       = src.EntryDate
                         , dst.product_level4      = src.FundProduct_Level4
                         , dst.product_lag         = src.akad
            when not matched then
                insert (id
                      , product_id
                      , parent_product_id
                      , product_number
                      , product_description
                      , product_category
                      , product_subcategory
                      , product_level3
                      , creation_date
                      , product_level4
                      , product_lag 
                  ) values (
                        cst_bsm_priority_prod_det_seq.nextval
                      , src.IDFundProduct
                      , src.IDFundProductGroup
                      , src.FundProductCode
                      , src.FundProductDesc
                      , src.FundProductCategory
                      , src.FundProductSubCategory
                      , src.FundProduct_Level3
                      , src.EntryDate
                      , src.FundProduct_Level4
                      , src.akad
                  );
            l_record_count := l_record_count + f.record_count;

            prc_api_stat_pkg.log_current(
                i_current_count  => l_record_count
              , i_excepted_count => l_errors_count
            );
               
            prc_api_file_pkg.close_file(
                i_sess_file_id  => f.session_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
            );
        exception
            when com_api_error_pkg.e_application_error then
                rollback to sp_priority_prod_details;

                l_errors_count := l_errors_count + f.record_count;
                l_record_count := l_record_count + f.record_count;

                prc_api_stat_pkg.log_current(
                    i_current_count  => l_record_count
                  , i_excepted_count => l_errors_count
                );

                prc_api_file_pkg.close_file(
                    i_sess_file_id  => f.session_file_id
                  , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
                );
        end;
    end loop;

    if l_estimated_count is null then
          prc_api_stat_pkg.log_estimation (
            i_estimated_count => 0
        );
    end if;
    
    prc_api_stat_pkg.log_end(
        i_processed_total   => nvl(l_record_count, 0)
      , i_excepted_total    => l_errors_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug(LOG_PREFIX || 'END');
exception
    when others then
        prc_api_stat_pkg.log_end(
            i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        else
            trc_log_pkg.debug(
                i_text       => LOG_PREFIX || 'FAILED: [#1]'
              , i_env_param1 => sqlerrm
            );
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end process_priority_prod_details;

-- Import information of priority account details in CSV format
procedure process_priority_acc_details is
    LOG_PREFIX        constant com_api_type_pkg.t_name    := lower($$PLSQL_UNIT) || '.process_priority_acc_details: ';
    DELIM             constant com_api_type_pkg.t_name    := '|';
    DATE_FORMAT       constant com_api_type_pkg.t_name    := 'yyyymmdd';
    NUMBER_FORMAT     constant com_api_type_pkg.t_name    := 'FM999999999999999999.9999';
    l_estimated_count          com_api_type_pkg.t_long_id;
    l_errors_count             com_api_type_pkg.t_long_id := 0;
begin
    trc_log_pkg.debug( i_text => LOG_PREFIX || ' started' );
    prc_api_stat_pkg.log_start;
  
    for f in (
        select id session_file_id
             , count(1) record_count
             , sum(count(1)) over() total_cnt
             , row_number() over(order by f.id) rn
          from prc_session_file f
             , prc_file_raw_data d
         where f.session_id = prc_api_session_pkg.get_session_id
           and f.id         = d.session_file_id
      group by f.id
      order by f.id
    ) loop
        if f.rn = 1 then
            l_estimated_count := f.total_cnt;
            prc_api_stat_pkg.log_estimation (
                i_estimated_count  => l_estimated_count
            );
        end if;

        trc_log_pkg.debug(i_text => LOG_PREFIX || 'Processing session_file_id [' || f.session_file_id || ']' );

        begin
            savepoint sp_priority_acc_details;
            
            merge into cst_bsm_priority_acc_details dst
            using (
                select to_date(substr(r.raw_data,   1,        r.d1 - 1),         DATE_FORMAT)   fic_mis_date
                     , substr(r.raw_data,           r.d1 + 1, r.d2  - r.d1 - 1)                 CIF
                     , substr(r.raw_data,           r.d2 + 1, r.d3  - r.d2 - 1)                 nomor_rekening
                     , to_number(substr(r.raw_data, r.d3 + 1, r.d4  - r.d3 - 1), NUMBER_FORMAT) acct_balance_lcy
                     , to_number(substr(r.raw_data, r.d4 + 1, r.d5  - r.d4 - 1), NUMBER_FORMAT) SummarySaldoCIF_Lcy
                     , substr(r.raw_data,           r.d5 + 1, r.d6  - r.d5 - 1)                 BranchCode
                     , substr(r.raw_data,           r.d6 + 1, r.d7  - r.d6 - 1)                 product_code
                     , substr(r.raw_data,           r.d7 + 1, r.d8  - r.d7)                     priority_flag
                 from (select raw_data
                            , instr(raw_data, DELIM, 1, 1) d1
                            , instr(raw_data, DELIM, 1, 2) d2
                            , instr(raw_data, DELIM, 1, 3) d3
                            , instr(raw_data, DELIM, 1, 4) d4
                            , instr(raw_data, DELIM, 1, 5) d5
                            , instr(raw_data, DELIM, 1, 6) d6
                            , instr(raw_data, DELIM, 1, 7) d7
                            , length(raw_data)             d8
                         from prc_file_raw_data
                        where session_file_id = f.session_file_id
                          and record_number > 1
                        ) r
                  ) src
            on (dst.customer_number = src.CIF
            and dst.account_number = src.nomor_rekening)
            when matched then
                update set dst.account_balance  = src.acct_balance_lcy
                         , dst.customer_balance = src.SummarySaldoCIF_Lcy
                         , dst.agent_number     = src.BranchCode
                         , dst.product_number   = src.product_code
                         , dst.priority_flag    = src.priority_flag
                         , dst.file_date        = src.fic_mis_date
            when not matched then
                insert(id
                     , file_date
                     , customer_number
                     , account_number
                     , account_balance
                     , customer_balance
                     , agent_number
                     , product_number
                     , priority_flag
                  ) values (
                       cst_bsm_priority_acc_det_seq.nextval
                     , src.fic_mis_date
                     , src.CIF
                     , src.nomor_rekening
                     , src.acct_balance_lcy
                     , src.SummarySaldoCIF_Lcy
                     , src.BranchCode
                     , src.product_code
                     , src.priority_flag
                  );

            prc_api_stat_pkg.increase_current(
                i_current_count  => f.record_count
              , i_excepted_count => 0
            );

            prc_api_file_pkg.close_file(
                i_sess_file_id  => f.session_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
            );
        exception
            when com_api_error_pkg.e_application_error then
                rollback to sp_priority_acc_details;

                l_errors_count := l_errors_count + f.record_count;

                prc_api_stat_pkg.increase_current(
                    i_current_count  => f.record_count
                  , i_excepted_count => l_errors_count
                );

                prc_api_file_pkg.close_file(
                    i_sess_file_id  => f.session_file_id
                  , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
                );
        end;
    end loop;

    if l_estimated_count is null then
        prc_api_stat_pkg.log_estimation (
            i_estimated_count => 0
        );
    end if;
    
    prc_api_stat_pkg.log_end(
        i_processed_total  => nvl(l_estimated_count, 0)
      , i_excepted_total   => l_errors_count
      , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug(LOG_PREFIX || 'END');
exception
    when others then
        prc_api_stat_pkg.log_end(
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        else
            trc_log_pkg.debug(
                i_text       => LOG_PREFIX || 'FAILED: [#1]'
              , i_env_param1 => substr(sqlerrm, 1, 3900)
            );
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => substr(sqlerrm, 1, 3900)
            );
        end if;
end process_priority_acc_details;

end cst_bsm_prc_incoming_pkg;
/
