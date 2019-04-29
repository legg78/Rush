create or replace package body cst_bmed_csc_outgoing_pkg as

BULK_LIMIT       constant integer  := 1000;

    cursor cur_csc_operations(
        i_network_id          in     com_api_type_pkg.t_network_id
      , i_full_export         in     com_api_type_pkg.t_boolean
      , i_date_type           in     com_api_type_pkg.t_dict_value
      , i_start_date          in     date
      , i_end_date            in     date
    ) is
    select e.id                                              id
         , com_api_const_pkg.FALSE                           is_invalid
         , to_char(o.sttl_date, 'yyyymmdd')                  file_id
         , rownum                                            rec_id
         , cst_bmed_csc_const_pkg.PROC_CODE_ATM              proc_code
         , 0                                                 act_code
         , to_char(o.oper_date, 'yymmddhhmmss')              date_time_local_tran
         , o.originator_refnum                               retrieval_ref_nbr
         , a.trace_number                                    system_trace_audit_nbr
         , o.terminal_number                                 card_acpt_term_id
         , o.merchant_number                                 card_acpt_id
         , o.merchant_street                                 card_acpt_addr
         , o.merchant_city                                   card_acpt_city
         , o.merchant_region                                 card_acpt_country
         , o.merchant_country                                country_acqr_inst
         , cst_bmed_csc_const_pkg.ACQUIRER_INST_ID           inst_id_acqr
         , cst_bmed_csc_const_pkg.NETWORK_ID_ACQUIRER        network_id_acqr
         , o.terminal_number                                 network_term_id
         , cst_bmed_csc_const_pkg.PR_PROC_ID                 pr_proc_id
         , cst_bmed_csc_const_pkg.PROC_ID_ACQUIRER           proc_id_acqr
         , cst_bmed_csc_const_pkg.PROCESS_ID_ACQUIRER        process_id_acqr
         , to_char(o.sttl_date, 'yymmdd')                    date_recon_acqr
         , c.card_number                                     pan
         , cst_bmed_csc_const_pkg.INST_ID_ISSUER             inst_id_issr
         , cst_bmed_csc_const_pkg.PR_RPT_INST_ID_ISSUER      pr_rpt_inst_id_issr
         , to_char(o.sttl_date, 'yymmdd')                    date_recon_issr
         , cst_bmed_csc_const_pkg.AUTH_BY                    auth_by
         , p.auth_code                                       approval_code
         , ' '                                               country_auth_agent_inst
         , o.is_reversal                                     rev_by
         , to_char(p.card_expir_date, 'yymm')                date_exp
         , to_char(o.oper_date, 'mmddhhmmss')                date_time_trans_rqst
         , o.oper_currency                                   cur_tran
         , co.exponent                                       cur_tran_exp
         , case
               when o.is_reversal = com_api_const_pkg.TRUE
               then (select nvl(sum(oper_amount), 0)
                       from opr_operation
                      where id = o.original_id
                    )
               else nvl(o.oper_amount, 0)
           end                                               amt_tran
         , case when o.is_reversal = com_api_const_pkg.TRUE then nvl(o.oper_amount, 0) else 0 end       amt_rev
         , 0                                                 amt_tran_fee
         , o.sttl_currency                                   cur_card_bill
         , cs.exponent                                       cur_bill_exp
         , case
               when o.is_reversal = com_api_const_pkg.TRUE
               then (select nvl(sum(sttl_amount), 0)
                       from opr_operation
                      where id = o.original_id
                    )
               else o.sttl_amount
           end                                               amt_card_bill
         , case when o.is_reversal = com_api_const_pkg.TRUE then o.sttl_amount else 0 end               amt_rev_bill
         , 0                                                 amt_card_bill_fee
      from opr_operation    o
         , opr_participant  p
         , opr_card         c
         , aut_auth         a
         , evt_event_object e
         , com_currency     co
         , com_currency     cs
     where i_full_export = com_api_const_pkg.FALSE
       and decode(e.status, 'EVST0001', e.procedure_name, null) = 'CST_BMED_CSC_OUTGOING_PKG.EXPORT_CSC_REPORT'
       and e.split_hash    in (select split_hash from com_api_split_map_vw)
       and e.entity_type      = opr_api_const_pkg.ENTITY_TYPE_OPERATION
       and e.object_id        = o.id
       and a.id(+)            = o.id
       and o.oper_type        = opr_api_const_pkg.OPERATION_TYPE_ATM_CASH
       and p.oper_id          = o.id
       and p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
       and o.id               = c.oper_id
       and co.code(+)         = o.oper_currency
       and cs.code(+)         = o.sttl_currency
       and p.network_id       = i_network_id

   union all

    select null                                              id
         , com_api_const_pkg.FALSE                           is_invalid
         , to_char(o.sttl_date, 'yyyymmdd')                  file_id
         , rownum                                            rec_id
         , cst_bmed_csc_const_pkg.PROC_CODE_ATM              proc_code
         , 0                                                 act_code
         , to_char(o.oper_date, 'yymmddhhmmss')              date_time_local_tran
         , o.originator_refnum                               retrieval_ref_nbr
         , a.trace_number                                    system_trace_audit_nbr
         , o.terminal_number                                 card_acpt_term_id
         , o.merchant_number                                 card_acpt_id
         , o.merchant_street                                 card_acpt_addr
         , o.merchant_city                                   card_acpt_city
         , o.merchant_region                                 card_acpt_country
         , o.merchant_country                                country_acqr_inst
         , cst_bmed_csc_const_pkg.ACQUIRER_INST_ID           inst_id_acqr
         , cst_bmed_csc_const_pkg.NETWORK_ID_ACQUIRER        network_id_acqr
         , o.terminal_number                                 network_term_id
         , cst_bmed_csc_const_pkg.PR_PROC_ID                 pr_proc_id
         , cst_bmed_csc_const_pkg.PROC_ID_ACQUIRER           proc_id_acqr
         , cst_bmed_csc_const_pkg.PROCESS_ID_ACQUIRER        process_id_acqr
         , to_char(o.sttl_date, 'yymmdd')                    date_recon_acqr
         , c.card_number                                     pan
         , cst_bmed_csc_const_pkg.INST_ID_ISSUER             inst_id_issr
         , cst_bmed_csc_const_pkg.PR_RPT_INST_ID_ISSUER      pr_rpt_inst_id_issr
         , to_char(o.sttl_date, 'yymmdd')                    date_recon_issr
         , cst_bmed_csc_const_pkg.AUTH_BY                    auth_by
         , p.auth_code                                       approval_code
         , ' '                                               country_auth_agent_inst
         , o.is_reversal                                     rev_by
         , to_char(p.card_expir_date, 'yymm')                date_exp
         , to_char(o.oper_date, 'mmddhhmmss')                date_time_trans_rqst
         , o.oper_currency                                   cur_tran
         , co.exponent                                       cur_tran_exp
         , case
               when o.is_reversal = com_api_const_pkg.TRUE
               then (select nvl(sum(oper_amount), 0)
                       from opr_operation
                      where id = o.original_id
                    )
               else nvl(o.oper_amount, 0)
           end                                               amt_tran
         , case when o.is_reversal = com_api_const_pkg.TRUE then nvl(o.oper_amount, 0) else 0 end       amt_rev
         , 0                                                 amt_tran_fee
         , o.sttl_currency                                   cur_card_bill
         , cs.exponent                                       cur_bill_exp
         , case
               when o.is_reversal = com_api_const_pkg.TRUE
               then (select nvl(sum(sttl_amount), 0)
                       from opr_operation
                      where id = o.original_id
                    )
               else o.sttl_amount
           end                                               amt_card_bill
         , case when o.is_reversal = com_api_const_pkg.TRUE then o.sttl_amount else 0 end               amt_rev_bill
         , 0                                                 amt_card_bill_fee
      from opr_operation    o
         , opr_participant  p
         , opr_card         c
         , aut_auth         a
         , com_currency     co
         , com_currency     cs
     where i_full_export = com_api_const_pkg.TRUE
       and (
         (i_date_type = com_api_const_pkg.DATE_PURPOSE_BANK and o.sttl_date between i_start_date and i_end_date
         )
        or
         (i_date_type = com_api_const_pkg.DATE_PURPOSE_PROCESSING and trunc(o.oper_date) between i_start_date and i_end_date
         ) )
       and a.id(+)            = o.id
       and o.oper_type        = opr_api_const_pkg.OPERATION_TYPE_ATM_CASH
       and p.oper_id          = o.id
       and p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
       and o.id               = c.oper_id
       and co.code(+)         = o.oper_currency
       and cs.code(+)         = o.sttl_currency
       and p.network_id       = i_network_id;

    cursor cur_csc_oper_count(
        i_network_id          in     com_api_type_pkg.t_network_id
      , i_full_export         in     com_api_type_pkg.t_boolean
      , i_date_type           in     com_api_type_pkg.t_dict_value
      , i_start_date          in     date
      , i_end_date            in     date
    ) is
    select sum("count")
      from (select count(1) "count"
              from opr_operation    o
                 , opr_participant  p
                 , opr_card         c
                 , aut_auth         a
                 , evt_event_object e
                 , com_currency     co
                 , com_currency     cs
             where i_full_export = com_api_const_pkg.FALSE
               and decode(e.status, 'EVST0001', e.procedure_name, null) = 'CST_BMED_CSC_OUTGOING_PKG.EXPORT_CSC_REPORT'
               and e.split_hash    in (select split_hash from com_api_split_map_vw)
               and e.entity_type      = opr_api_const_pkg.ENTITY_TYPE_OPERATION
               and e.object_id        = o.id
               and a.id(+)            = o.id
               and o.oper_type        = opr_api_const_pkg.OPERATION_TYPE_ATM_CASH
               and p.oper_id          = o.id
               and p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
               and o.id               = c.oper_id
               and co.code(+)         = o.oper_currency
               and cs.code(+)         = o.sttl_currency
               and p.network_id       = i_network_id

           union all

            select count(1) "count"
              from opr_operation    o
                 , opr_participant  p
                 , opr_card         c
                 , aut_auth         a
                 , com_currency     co
                 , com_currency     cs
             where i_full_export = com_api_const_pkg.TRUE
               and (
                 (i_date_type = com_api_const_pkg.DATE_PURPOSE_BANK and o.sttl_date between i_start_date and i_end_date
                 )
                or
                 (i_date_type = com_api_const_pkg.DATE_PURPOSE_PROCESSING and trunc(o.oper_date) between i_start_date and i_end_date
                 ) )
               and a.id(+)            = o.id
               and o.oper_type        = opr_api_const_pkg.OPERATION_TYPE_ATM_CASH
               and p.oper_id          = o.id
               and p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
               and o.id               = c.oper_id
               and co.code(+)         = o.oper_currency
               and cs.code(+)         = o.sttl_currency
               and p.network_id       = i_network_id);

procedure generate_header(
    i_csc_file              in cst_bmed_csc_type_pkg.t_csc_file_rec
  , i_session_file_id       in com_api_type_pkg.t_long_id
) is
    l_line                   com_api_type_pkg.t_text;
begin
    trc_log_pkg.debug (
        i_text => 'cst_bmed_csc_outgoing_pkg.csc_report_header start'
    );

    l_line := cst_bmed_csc_const_pkg.IDENTIFIER_HEADER;
    l_line := l_line || lpad(cst_bmed_csc_const_pkg.FILE_LABEL, 10);
    l_line := l_line || to_char(get_sysdate, 'yyyymmdd');

    if l_line is not null then
        prc_api_file_pkg.put_line(
            i_raw_data      => l_line
          , i_sess_file_id  => i_session_file_id
        );
    end if;

    trc_log_pkg.debug(
        i_text => 'cst_bmed_csc_outgoing_pkg.csc_report_header end'
    );
end;

procedure generate_trailer(
    i_csc_file          in cst_bmed_csc_type_pkg.t_csc_file_rec
  , i_session_file_id   in com_api_type_pkg.t_long_id
) is
    l_line                   com_api_type_pkg.t_text;
begin
    trc_log_pkg.debug(
        i_text => 'cst_bmed_csc_outgoing_pkg.csc_report_trailer start'
    );

    l_line := i_csc_file.identifier_trailer;
    l_line := l_line || lpad(i_csc_file.trans_total, 10, '0');
    l_line := l_line || lpad(i_csc_file.amount_total, 19, '0');
    l_line := l_line || lpad(i_csc_file.reversal_amount_total, 19, '0');

    if l_line is not null then
        prc_api_file_pkg.put_line(
            i_raw_data      => l_line
          , i_sess_file_id  => i_session_file_id
        );
    end if;

    trc_log_pkg.debug(
        i_text => 'cst_bmed_csc_outgoing_pkg.csc_report_trailer end'
    );
end;

procedure put_line(
    i_csc_fin_rec           in cst_bmed_csc_type_pkg.t_csc_fin_mes_rec
  , i_session_file_id       in com_api_type_pkg.t_long_id
) is
    l_line              com_api_type_pkg.t_text;
begin
    l_line := null;
    l_line := l_line || i_csc_fin_rec.file_id;
    l_line := l_line || lpad(i_csc_fin_rec.rec_id, 12, '0');
    l_line := l_line || rpad(i_csc_fin_rec.proc_code, 6, ' ');
    l_line := l_line || lpad(i_csc_fin_rec.act_code, 3, '0');
    l_line := l_line || lpad(nvl(i_csc_fin_rec.date_time_local_tran, 0), 12, '0');
    l_line := l_line || lpad(nvl(i_csc_fin_rec.retrieval_ref_nbr, 0), 12, '0');
    l_line := l_line || lpad(nvl(i_csc_fin_rec.system_trace_audit_nbr, 0), 6, '0');
    l_line := l_line || rpad(nvl(i_csc_fin_rec.card_acpt_term_id, ' '), 15, ' ');
    l_line := l_line || rpad(nvl(i_csc_fin_rec.card_acpt_id, ' '), 15, ' ');
    l_line := l_line || rpad(nvl(i_csc_fin_rec.card_acpt_addr, ' '), 29, ' ');
    l_line := l_line || rpad(nvl(i_csc_fin_rec.card_acpt_city, ' '), 28, ' ');
    l_line := l_line || lpad(nvl(i_csc_fin_rec.card_acpt_country, '0'), 3, '0');
    l_line := l_line || lpad(nvl(i_csc_fin_rec.country_acqr_inst, '0'), 3, '0');
    l_line := l_line || lpad(nvl(i_csc_fin_rec.inst_id_acqr, '0'), 11, '0');
    l_line := l_line || rpad(nvl(i_csc_fin_rec.network_id_acqr, ' '), 3, ' ');
    l_line := l_line || rpad(nvl(i_csc_fin_rec.network_term_id, ' '), 8, ' ');
    l_line := l_line || rpad(nvl(i_csc_fin_rec.pr_proc_id, ' '), 6, ' ');
    l_line := l_line || rpad(nvl(i_csc_fin_rec.proc_id_acqr, ' '), 6, ' ');
    l_line := l_line || rpad(nvl(i_csc_fin_rec.process_id_acqr, ' '), 6, ' ');
    l_line := l_line || lpad(nvl(i_csc_fin_rec.date_recon_acqr, '0'), 6, '0');
    l_line := l_line || lpad(nvl(i_csc_fin_rec.pan, '0'), 28, '0');
    l_line := l_line || lpad(nvl(i_csc_fin_rec.inst_id_issr, '0'), 11, '0');
    l_line := l_line || lpad(nvl(i_csc_fin_rec.pr_rpt_inst_id_issr, '0'), 11, '0');
    l_line := l_line || lpad(nvl(i_csc_fin_rec.date_recon_issr, '0'), 6, '0');
    l_line := l_line || rpad(nvl(i_csc_fin_rec.auth_by, ' '), 1, ' ');
    l_line := l_line || rpad(nvl(i_csc_fin_rec.approval_code, ' '), 6, ' ');
    l_line := l_line || rpad(nvl(i_csc_fin_rec.country_auth_agent_inst, ' '), 3, ' ');
    l_line := l_line || rpad(nvl(i_csc_fin_rec.rev_by, ' '), 1, ' ');
    l_line := l_line || lpad(nvl(i_csc_fin_rec.date_exp, '0'), 4, '0');
    l_line := l_line || lpad(nvl(i_csc_fin_rec.date_time_trans_rqst, '0'), 10, '0');
    l_line := l_line || lpad(nvl(i_csc_fin_rec.cur_tran, '0'), 3, '0');
    l_line := l_line || lpad(nvl(i_csc_fin_rec.cur_tran_exp, '0'), 1, '0');
    l_line := l_line || lpad(nvl(i_csc_fin_rec.amt_tran, '0'), 19, '0');
    l_line := l_line || lpad(nvl(i_csc_fin_rec.amt_rev, '0'), 19, '0');
    l_line := l_line || lpad(nvl(i_csc_fin_rec.amt_tran_fee, '0'), 19, '0');
    l_line := l_line || lpad(nvl(i_csc_fin_rec.cur_card_bill, '0'), 3, '0');
    l_line := l_line || lpad(nvl(i_csc_fin_rec.cur_bill_exp, '0'), 1, '0');
    l_line := l_line || lpad(nvl(i_csc_fin_rec.amt_card_bill, '0'), 19, '0');
    l_line := l_line || lpad(nvl(i_csc_fin_rec.amt_rev_bill, '0'), 19, '0');
    l_line := l_line || lpad(nvl(i_csc_fin_rec.amt_card_bill_fee, '0'), 19, '0');

    if l_line is not null then
        prc_api_file_pkg.put_line(
            i_raw_data      => l_line
          , i_sess_file_id  => i_session_file_id
        );
    end if;
end put_line;

procedure export_csc_report(
    i_network_id    in    com_api_type_pkg.t_network_id
  , i_date_type     in    com_api_type_pkg.t_dict_value
  , i_start_date    in    date                             default    null
  , i_end_date      in    date                             default    null
  , i_shift_from    in    com_api_type_pkg.t_tiny_id       default    0
  , i_shift_to      in    com_api_type_pkg.t_tiny_id       default    0
  , i_full_export   in    com_api_type_pkg.t_boolean       default    null
) is
    l_estimated_count       com_api_type_pkg.t_long_id    := 0;
    l_processed_count       com_api_type_pkg.t_long_id    := 0;
    l_excepted_count        com_api_type_pkg.t_long_id    := 0;
    l_rejected_count        com_api_type_pkg.t_long_id    := 0;

    l_network_id            com_api_type_pkg.t_network_id;
    l_csc_file              cst_bmed_csc_type_pkg.t_csc_file_rec;
    l_csc_fin_tab           cst_bmed_csc_type_pkg.t_csc_fin_mes_tab;
    l_event_tab             com_api_type_pkg.t_number_tab;

    l_session_file_id       com_api_type_pkg.t_long_id;

    l_full_export           com_api_type_pkg.t_boolean;
    l_sysdate               date;
    l_start_date            date;
    l_end_date              date;

begin
    savepoint export_csc_report_start;

    trc_log_pkg.info(
        i_text          => 'Export CSC report start'
    );

    prc_api_stat_pkg.log_start;

    l_network_id := nvl(i_network_id, cst_bmed_csc_const_pkg.CSC_NETWORK);

    l_csc_file.identifier_header        := cst_bmed_csc_const_pkg.IDENTIFIER_HEADER;
    l_csc_file.file_label               := cst_bmed_csc_const_pkg.FILE_LABEL;
    l_csc_file.file_id                  := to_char(get_sysdate, 'yyyymmdd');
    l_csc_file.identifier_trailer       := cst_bmed_csc_const_pkg.IDENTIFIER_TRAILER;
    l_csc_file.trans_total              := 0;
    l_csc_file.amount_total             := 0;
    l_csc_file.reversal_amount_total    := 0;

    l_full_export := nvl(i_full_export, com_api_type_pkg.FALSE);

    trc_log_pkg.debug(
        i_text        => 'Parameter [l_full_export] value set to [#1]'
      , i_env_param1  => l_full_export
    );

    l_sysdate    := com_api_sttl_day_pkg.get_sysdate;
    l_start_date := trunc(coalesce(i_start_date, l_sysdate), 'DD');
    l_end_date   := nvl(trunc(i_end_date, 'DD'), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND;

    l_start_date := l_start_date + nvl(i_shift_from, 0);
    l_end_date   := l_end_date + nvl(i_shift_to, 0);

    open cur_csc_oper_count(
        i_network_id       => l_network_id
      , i_full_export      => l_full_export
      , i_date_type        => i_date_type
      , i_start_date       => l_start_date
      , i_end_date         => l_end_date
    );

    fetch cur_csc_oper_count into l_estimated_count;
    close cur_csc_oper_count;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count       => l_estimated_count
    );

    if l_estimated_count > 0 then
        prc_api_file_pkg.open_file(
            o_sess_file_id  => l_session_file_id
          , i_file_type    => cst_bmed_csc_const_pkg.CSC_FILE_TYPE
        );

        generate_header(
            i_csc_file          => l_csc_file
          , i_session_file_id   => l_session_file_id
        );

        open cur_csc_operations(
            i_network_id     => l_network_id
          , i_full_export    => l_full_export
          , i_date_type      => i_date_type
          , i_start_date     => l_start_date
          , i_end_date       => l_end_date
        );

        trc_log_pkg.debug(
            i_text          => 'cursor cur_csc_operations opened'
        );

        loop
            fetch cur_csc_operations bulk collect into l_csc_fin_tab limit BULK_LIMIT;

            for i in 1 .. l_csc_fin_tab.count loop

                l_processed_count := l_processed_count + 1;
                l_event_tab(l_event_tab.count + 1) := l_csc_fin_tab(i).id;

                put_line(
                    i_csc_fin_rec       => l_csc_fin_tab(i)
                  , i_session_file_id   => l_session_file_id
                );

                l_csc_file.trans_total              := l_csc_file.trans_total + 1;
                l_csc_file.amount_total             := l_csc_file.amount_total + l_csc_fin_tab(i).amt_tran;
                l_csc_file.reversal_amount_total    := l_csc_file.reversal_amount_total + l_csc_fin_tab(i).amt_rev;

                if mod(l_processed_count, 100) = 0 then
                    prc_api_stat_pkg.log_current (
                        i_current_count     => l_processed_count
                      , i_excepted_count    => l_excepted_count
                    );
                end if;

            end loop;

            evt_api_event_pkg.process_event_object(
                i_event_object_id_tab    => l_event_tab
            );

            l_event_tab.delete;

            exit when cur_csc_operations%notfound;
        end loop;

        close cur_csc_operations;

        generate_trailer(
            i_csc_file          => l_csc_file
          , i_session_file_id   => l_session_file_id
        );

        prc_api_file_pkg.close_file(
            i_sess_file_id      => l_session_file_id
          , i_status            => prc_api_const_pkg.FILE_STATUS_ACCEPTED
        );

    end if;

    prc_api_stat_pkg.log_end(
        i_excepted_total    => l_excepted_count
      , i_processed_total   => l_processed_count
      , i_rejected_total    => l_rejected_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.info(
        i_text  => 'Export CSC report finished'
    );

exception
    when others then
        rollback to savepoint export_csc_report_start;

        if cur_csc_oper_count%isopen then
            close cur_csc_oper_count;
        end if; 

        if cur_csc_operations%isopen then
            close cur_csc_operations;
        end if;

        prc_api_stat_pkg.log_end(
            i_excepted_total    => l_excepted_count
          , i_processed_total   => l_processed_count
          , i_rejected_total    => l_rejected_count
          , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if l_session_file_id is not null then
            prc_api_file_pkg.close_file (
                i_sess_file_id  => l_session_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
            );
        end if;

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;

        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );

        end if;

        raise;
end export_csc_report;
end;
/
