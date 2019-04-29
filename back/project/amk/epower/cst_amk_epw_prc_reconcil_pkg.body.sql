create or replace package body cst_amk_epw_prc_reconcil_pkg is

function get_pos(
    i_str   com_api_type_pkg.t_text
  , i_nth   com_api_type_pkg.t_count
) return varchar2 is
    l_buf          varchar2(200);
    l_sep constant varchar2(1) := ';';
begin
    if i_nth = 1 then
        l_buf := substr(i_str, 1, instr(i_str, l_sep, 1, i_nth) - 1);
    else
        if instr(i_str, l_sep, 1, i_nth - 1) > 0 then
            l_buf := substr(i_str, instr(i_str, l_sep, 1, i_nth - 1) + 1);
            if instr(i_str, l_sep, 1, i_nth) > 0 then
                l_buf := substr(l_buf, 1 , instr(l_buf, l_sep) - 1);
            end if;
        end if;
    end if;
    return trim(l_buf);
end;

procedure save_msg(
    i_msg       cst_amk_epw_api_type_pkg.t_msg_rec
)
is
    l_msg       cst_amk_epw_api_type_pkg.t_msg_rec;
begin
    l_msg     := i_msg;
    l_msg.id  := nvl(l_msg.id, cst_amk_epw_fin_msg_seq.NEXTVAL);
    
    insert into cst_amk_epw_fin_msg (
        id
      , status
      , file_id
      , is_invalid
      , is_incoming
      , row_number
      , supplier_code
      , supplier_name
      , customer_code
      , customer_name
      , customer_id
      , trxn_datetime
      , amount
      , currency_name
      , currency_code
    )
    values (
        l_msg.id
      , l_msg.status
      , l_msg.file_id
      , l_msg.is_invalid
      , l_msg.is_incoming
      , l_msg.row_number
      , l_msg.supplier_code
      , l_msg.supplier_name
      , l_msg.customer_code
      , l_msg.customer_name
      , l_msg.customer_id
      , l_msg.trxn_datetime
      , l_msg.amount
      , l_msg.currency_name
      , l_msg.currency_code
    );
    
end;

procedure save_file(
    i_file             cst_amk_epw_api_type_pkg.t_file_rec
) 
is 
begin
    insert into cst_amk_epw_file (
        id
      , is_incoming
      , network_id
      , inst_id
      , session_file_id
      , total_records
      , date_beg
      , date_end
    )
    values (
        i_file.id
      , i_file.is_incoming
      , i_file.network_id
      , i_file.inst_id
      , i_file.session_file_id
      , i_file.total_records
      , i_file.date_beg
      , i_file.date_end
    );
end;

procedure process_new_file(
    i_file_name            in com_api_type_pkg.t_name
  , i_network_id           in com_api_type_pkg.t_tiny_id
  , i_session_file_id      in com_api_type_pkg.t_long_id
  , i_file_record_count    in com_api_type_pkg.t_count
  , o_file                out cst_amk_epw_api_type_pkg.t_file_rec
)
is
    l_regexp  constant  com_api_type_pkg.t_name := '_(\d+)\_(\d{8})\_(\d{8})\..{3}$';
begin
    o_file.id               := cst_amk_epw_file_seq.nextval;
    o_file.is_incoming      := com_api_const_pkg.TRUE;
    o_file.network_id       := i_network_id;
    o_file.inst_id          := net_api_network_pkg.get_inst_id(i_network_id => i_network_id);
    o_file.session_file_id  := i_session_file_id;
    o_file.total_records    := to_number(regexp_substr(i_file_name, l_regexp, 1, 1, 'i', 1));
    o_file.date_beg         := to_date(regexp_substr(i_file_name, l_regexp, 1, 1, 'i', 2),'YYYYMMDD');
    o_file.date_end         := to_date(regexp_substr(i_file_name, l_regexp, 1, 1, 'i', 3),'YYYYMMDD') + 1 - (interval '1' second);
    
    -- check record count
    if o_file.total_records <> i_file_record_count or o_file.total_records is null then
        com_api_error_pkg.raise_error(
            i_error       => 'EPW_FILE_CORRUPTED_INCORRECT_COUNT'
          , i_env_param1  => o_file.total_records
          , i_env_param2  => i_file_record_count
        );
    end if;
    
    save_file(o_file);
end;

procedure process_record(
    i_file                 in cst_amk_epw_api_type_pkg.t_file_rec
  , i_rec                  in com_api_type_pkg.t_text
  , i_row_number           in com_api_type_pkg.t_count
)
is
    l_msg                  cst_amk_epw_api_type_pkg.t_msg_rec;
    l_amount_str           com_api_type_pkg.t_original_data;
    l_currency_exponent    com_api_type_pkg.t_tiny_id;
    
    procedure invalidate 
    is
    begin
        l_msg.is_invalid := com_api_const_pkg.TRUE;
        l_msg.status     := net_api_const_pkg.CLEARING_MSG_STATUS_INVALID;
    end;
begin
    l_msg.status           := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;
    l_msg.file_id          := i_file.id;
    l_msg.is_invalid       := com_api_const_pkg.FALSE;
    l_msg.is_incoming      := com_api_const_pkg.TRUE;
    l_msg.row_number       := i_row_number;
    l_msg.supplier_code    := get_pos(i_rec, 1);
    l_msg.supplier_name    := get_pos(i_rec, 2);
    l_msg.customer_code    := get_pos(i_rec, 3);
    l_msg.customer_name    := get_pos(i_rec, 4);
    l_msg.trxn_datetime    := to_date(get_pos(i_rec, 5),'YYYYMMDDHH24MISS');
    l_amount_str           := get_pos(i_rec, 6);
    l_msg.currency_name    := get_pos(i_rec, 7);
    begin
        l_msg.currency_code := com_api_currency_pkg.get_currency_code(i_curr_name => l_msg.currency_name);
    exception 
        when com_api_error_pkg.e_application_error then
            invalidate; 
    end;
    
    l_currency_exponent :=
        com_api_currency_pkg.get_currency_exponent(
            i_curr_code => l_msg.currency_code
        );
    l_msg.amount := to_number(l_amount_str, 'FM999999999999999990.0000', 'NLS_NUMERIC_CHARACTERS=''. ''');
    l_msg.amount := l_msg.amount * power(10, l_currency_exponent);
    
    l_msg.customer_id := 
        prd_api_customer_pkg.get_customer_id(
            i_customer_number    => l_msg.customer_code
          , i_mask_error         => com_api_const_pkg.TRUE
        );
    
    if l_msg.customer_id is null then
        invalidate;
    end if;

    save_msg(i_msg => l_msg);

end;

procedure reconciliation(
    i_file      cst_amk_epw_api_type_pkg.t_file_rec
  , i_host_id   com_api_type_pkg.t_tiny_id
)
is
    l_start_id         com_api_type_pkg.t_long_id;
    l_end_id           com_api_type_pkg.t_long_id;
    l_msg              cst_amk_epw_api_type_pkg.t_msg_rec;
    l_status           com_api_type_pkg.t_dict_value;
    l_is_invalid       com_api_type_pkg.t_boolean;
begin
    l_start_id   := com_api_id_pkg.get_from_id(i_file.date_beg);
    l_end_id     := com_api_id_pkg.get_till_id(i_file.date_end);
    for r in (            
        with t as (
            select o.id as oper_id
                 , o.oper_date
                 , o.oper_amount
                 , o.oper_currency
                 , pp.purpose_number
                 , pdo.param_value      as customer_number
              from opr_operation o
                 , opr_participant p
                 , acc_account a
                 , prd_customer c
                 , pmo_order po
                 , pmo_purpose pp
                 , pmo_provider_host h
                 , pmo_order_data pdo
             where o.oper_date     between i_file.date_beg and i_file.date_end
               and o.id            between l_start_id      and l_end_id
               and o.status              =  opr_api_const_pkg.OPERATION_STATUS_PROCESSED
               and o.oper_type          in (opr_api_const_pkg.OPERATION_TYPE_SRV_PRV_PAYMENT
                                          , opr_api_const_pkg.OPERATION_TYPE_SRV_PRV_PAY_AGT)
               and p.oper_id             = o.id
               and p.participant_type    = decode(
                                               o.oper_type
                                             , opr_api_const_pkg.OPERATION_TYPE_SRV_PRV_PAYMENT
                                             , com_api_const_pkg.PARTICIPANT_ISSUER
                                             , com_api_const_pkg.PARTICIPANT_ACQUIRER
                                           )
               and a.id                  = p.account_id
               and c.id                  = a.customer_id
               and po.id                 = o.payment_order_id
               and pp.id                 = po.purpose_id
               and h.provider_id         = pp.provider_id
               and h.host_member_id      = i_host_id
               and pdo.order_id          = po.id
               and pdo.param_id          = pmo_api_const_pkg.PMO_PARAM_PMT_ACCOUNT
        )
        , f as (
            select f.id
                 , f.status
                 , f.file_id
                 , f.is_invalid
                 , f.row_number
                 , f.supplier_code
                 , f.supplier_name
                 , f.customer_code
                 , f.customer_name
                 , f.customer_id
                 , f.trxn_datetime
                 , f.amount
                 , f.currency_name
                 , f.currency_code
                 , f.oper_id
              from cst_amk_epw_fin_msg f
             where f.file_id = i_file.id
        )
        select f.id
             , f.trxn_datetime
             , f.amount
             , f.currency_code
             , f.supplier_code
             , f.customer_code
             , t.oper_id
             , t.oper_date
             , t.oper_amount
             , t.oper_currency
             , t.purpose_number
             , t.customer_number
          from t full join f on (
                f.supplier_code = t.purpose_number
            and f.customer_code = t.customer_number
            and f.amount        = t.oper_amount
            and f.currency_code = t.oper_currency
            and f.trxn_datetime = t.oper_date
        )
    )
    loop
        l_msg := null;
        if r.id is null then
            l_msg.status         := cst_amk_epw_api_const_pkg.MSG_STATUS_NOT_FOUND_IN_FILE;
            l_msg.file_id        := i_file.id;
            l_msg.is_invalid     := com_api_const_pkg.TRUE;
            l_msg.is_incoming    := com_api_const_pkg.FALSE;
            l_msg.supplier_code  := r.purpose_number;
            l_msg.customer_code  := r.customer_number;
            l_msg.trxn_datetime  := r.oper_date;
            l_msg.amount         := r.oper_amount;
            l_msg.currency_name  := com_api_currency_pkg.get_currency_name(i_curr_code => r.oper_currency);
            save_msg(i_msg => l_msg);
        else
            if r.id is not null and r.oper_id is not null then
                l_status := net_api_const_pkg.CLEARING_MSG_STATUS_MATCHED;
                l_is_invalid := com_api_const_pkg.FALSE;
            else
                l_status := cst_amk_epw_api_const_pkg.MSG_STATUS_NOT_FOUND_IN_SV;
                l_is_invalid := com_api_const_pkg.TRUE;
            end if;

            update cst_amk_epw_fin_msg f
               set f.status     = l_status
                 , f.oper_id    = r.oper_id
                 , f.is_invalid = l_is_invalid
             where f.id = r.id;
        end if;
    end loop;
end;

procedure save_output(
    i_file             cst_amk_epw_api_type_pkg.t_file_rec
  , i_file_name        com_api_type_pkg.t_name
)
is 
    l_params                  com_api_type_pkg.t_param_tab;
    l_session_file_id         com_api_type_pkg.t_long_id;
    l_report                  clob;
    l_container_id            com_api_type_pkg.t_short_id;
    l_source_type             com_api_type_pkg.t_dict_value;
    l_data_source             clob;
    l_report_id               com_api_type_pkg.t_short_id;
    l_template_id             com_api_type_pkg.t_short_id;
    l_cur                     sys_refcursor;
begin
    l_container_id    := prc_api_session_pkg.get_container_id;
    
    select a.report_id
         , a.report_template_id
         , r.source_type
         , r.data_source
      into l_report_id
         , l_template_id
         , l_source_type
         , l_data_source
      from prc_file f
         , prc_file_attribute a
         , rpt_report r
     where a.container_id = l_container_id
       and a.file_id    = f.id
       and a.report_id  = r.id;

    trc_log_pkg.debug('report_id='||l_report_id||'source_type='||l_source_type);
    
    rul_api_param_pkg.set_param (
        i_name     => 'SYS_DATE'
      , i_value    => com_api_sttl_day_pkg.get_sysdate
      , io_params  => l_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'ORIGINAL_FILE_NAME'
      , i_value   => i_file_name
      , io_params => l_params
    );

    prc_api_file_pkg.open_file(
        o_sess_file_id  => l_session_file_id
      , i_file_type     => cst_amk_epw_api_const_pkg.FILE_TYPE_EPW_RECONCIL_RESULT
      , io_params       => l_params
    );

    rul_api_param_pkg.set_param(
        i_name    => 'I_FILE_ID'
      , i_value   => i_file.id
      , io_params => l_params
    );
    
    rpt_api_run_pkg.process_report(
        i_report_id     => l_report_id
      , i_template_id   => l_template_id
      , i_parameters    => l_params 
      , i_source_type   => l_source_type
      , io_data_source  => l_data_source
      , o_resultset     => l_cur
      , o_xml           => l_report
    );
    
    prc_api_file_pkg.put_file(
        i_sess_file_id => l_session_file_id
      , i_clob_content => l_report
      , i_add_to       => com_api_const_pkg.FALSE
    );
    
    prc_api_file_pkg.close_file(
        i_sess_file_id  => l_session_file_id
      , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
    );
end;

-- Processing of Incoming reconciliation files
procedure process(
    i_network_id           in     com_api_type_pkg.t_tiny_id
)
is
    LOG_PREFIX           constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process: ';
    l_host_id                     com_api_type_pkg.t_tiny_id;
    l_record_number               com_api_type_pkg.t_long_id := 0;
    l_record_count_all_files      com_api_type_pkg.t_long_id := 0;
    l_record_count                com_api_type_pkg.t_long_id := 0;
    l_file                        cst_amk_epw_api_type_pkg.t_file_rec;
    l_rec                         com_api_type_pkg.t_text;

    cursor cu_records_count is
        select count(1)
          from prc_file_raw_data a
             , prc_session_file b
         where b.session_id      = prc_api_session_pkg.get_session_id
           and a.session_file_id = b.id;
begin
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'i_network_id [' || i_network_id || ']'
    );
    prc_api_stat_pkg.log_start;

    open cu_records_count;
    fetch cu_records_count into l_record_count_all_files;
    close cu_records_count;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count     => l_record_count_all_files
    );

    -- get network communication standard
    l_host_id :=
        net_api_network_pkg.get_default_host(
            i_network_id   => i_network_id
        );
    
    trc_log_pkg.debug(
        i_text => 'l_host_id [' || l_host_id || ']'
    );
    
    for p in (
        select id session_file_id
             , record_count
             , file_name
          from prc_session_file
         where session_id = prc_api_session_pkg.get_session_id
         order by id
    ) 
    loop
        trc_log_pkg.debug(
            i_text => 'Processing session_file_id [' || p.session_file_id 
                   || '], record_count [' || p.record_count 
                   || '], file_name [' || p.file_name || ']'
        );
        
        begin
            savepoint sp_epw_reconcil_file;
            l_record_number := 1;
            
            for r in (
                select record_number
                     , raw_data
                     , count(*) over() cnt
                     , row_number() over(order by record_number) rn
                     , row_number() over(order by record_number desc) rn_desc
                  from prc_file_raw_data
                 where session_file_id = p.session_file_id
                 order by record_number
            )
            loop
                l_rec := r.raw_data;
                if r.rn = 1 then
                    process_new_file(
                        i_file_name            => p.file_name
                      , i_network_id           => i_network_id
                      , i_session_file_id      => p.session_file_id
                      , i_file_record_count    => r.cnt
                      , o_file                 => l_file
                    );
                end if;
                
                process_record(
                    i_file              => l_file
                  , i_rec               => r.raw_data
                  , i_row_number        => r.rn
                );
                
                if mod(r.rn, 100) = 0 then
                    prc_api_stat_pkg.log_current(
                        i_current_count  => l_record_count + r.rn
                      , i_excepted_count => 0
                    );
                end if;
                
                if r.rn_desc = 1 then
                    l_record_count := l_record_count + r.cnt;
                    prc_api_stat_pkg.log_current(
                        i_current_count  => l_record_count
                      , i_excepted_count => 0
                    );
                end if;
            end loop;
            
            reconciliation(
                i_file              => l_file
              , i_host_id           => l_host_id
            );
            
            save_output(
                i_file      => l_file
              , i_file_name => p.file_name
            );
            
            prc_api_file_pkg.close_file(
                i_sess_file_id          => p.session_file_id
              , i_status                => prc_api_const_pkg.FILE_STATUS_ACCEPTED
            );
        exception
            when com_api_error_pkg.e_application_error then
                rollback to sp_epw_reconcil_file;

                l_record_count := l_record_count + p.record_count;

                prc_api_stat_pkg.log_current(
                        i_current_count  => l_record_count
                      , i_excepted_count => 0
                );
                prc_api_file_pkg.close_file(
                    i_sess_file_id          => p.session_file_id
                  , i_status                => prc_api_const_pkg.FILE_STATUS_REJECTED
                );
                raise;
        end;
    end loop;
    
    prc_api_stat_pkg.log_end(
        i_processed_total  => l_record_count
      , i_excepted_total   => 0
      , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug(LOG_PREFIX || 'END');
exception
    when others then
        if cu_records_count%isopen then
            close cu_records_count;
        end if;

        prc_api_stat_pkg.log_end(
            i_result_code      => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        else
            trc_log_pkg.debug(
                i_text       => LOG_PREFIX || 'FAILED with l_record_number [#1] l_rec [#2]' 
              , i_env_param1 => l_record_number
              , i_env_param2 => l_rec
            );
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end;

end ;
/
