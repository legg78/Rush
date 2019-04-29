create or replace package body cst_woo_prc_incoming_pkg as
pragma serially_reusable;
/************************************************************
 * Import batch files from Woori bank CBS <br />
 * Created by:
    Chau Huynh (huynh@bpcbt.com)
    Man Do     (m.do@bpcbt.com)  at 2017-03-03     <br />
 * Last changed by $Author: Man Do               $ <br />
 * $LastChangedDate:        2017-08-26 16:00     $ <br />
 * Revision: $LastChangedRevision:  428          $ <br />
 * Module: CST_WOO_PRC_INCOMING_PKG                <br />
 * @headcom
 *************************************************************/

function get_id(
    i_host_date             in      date    default null
) return com_api_type_pkg.t_long_id is
begin
    return com_api_id_pkg.get_id(opr_operation_seq.nextval, coalesce(i_host_date, com_api_sttl_day_pkg.get_sysdate));
end;

procedure process_file_header(
    i_header_data           in  com_api_type_pkg.t_text
  , i_inst_id               in  com_api_type_pkg.t_inst_id
  , i_file_name             in  com_api_type_pkg.t_name
  , i_expected_row_count    in  com_api_type_pkg.t_tiny_id default null
  , o_woo_file              out cst_woo_api_type_pkg.t_file_rec
) is
begin
    trc_log_pkg.debug(
        i_text  => 'cst_woo_prc_incoming_pkg.process_file_header > Start'
    );

    o_woo_file.header       := cst_woo_com_pkg.get_substr(i_header_data, 1);
    o_woo_file.job_id       := cst_woo_com_pkg.get_substr(i_header_data, 2);
    o_woo_file.process_date := cst_woo_com_pkg.get_substr(i_header_data, 3);
    o_woo_file.sequence_id  := cst_woo_com_pkg.get_substr(i_header_data, 4);
    o_woo_file.total_amount := cst_woo_com_pkg.get_substr(i_header_data, 5);
    o_woo_file.total_record := cst_woo_com_pkg.get_substr(i_header_data, 6);

    if i_expected_row_count is not null and o_woo_file.total_record != i_expected_row_count then
        trc_log_pkg.error(
            i_text  => 'Files records count is ' || i_expected_row_count
                    || ', but header''s record count is ' || o_woo_file.total_record
                    || '. File processing aborted'
        );

        com_api_error_pkg.raise_error(
            i_error        => 'RECORD_COUNT_NOT_MATCHES_WITH_HEADER'
          , i_env_param1   => i_expected_row_count
          , i_env_param2   => o_woo_file.total_record
        );
    end if;

    insert into cst_woo_import_header(
        header
      , job_id
      , process_date
      , sequence_id
      , total_amount
      , total_record
      , import_date
      , file_name
    ) values (
        o_woo_file.header
      , o_woo_file.job_id
      , o_woo_file.process_date
      , o_woo_file.sequence_id
      , o_woo_file.total_amount
      , o_woo_file.total_record
      , get_sysdate
      , i_file_name
    );

    trc_log_pkg.debug(
        i_text  => 'cst_woo_prc_incoming_pkg.process_file_header > End'
    );
end;

procedure process_operations(
    i_oper_list in  cst_woo_api_type_pkg.t_oper_list
) is
begin
    for i in i_oper_list.first..i_oper_list.last loop
        update opr_operation
           set status = opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY -- OPST0100
         where id = i_oper_list(i).oper_id
           and status = cst_woo_const_pkg.OPERATION_STATUS_WAITING_BATCH; -- OPST5004

        -- process operation
        if sql%rowcount > 0 then
            opr_api_process_pkg.process_operation(
                i_operation_id => i_oper_list(i).oper_id
            );
        end if;
    end loop;
end process_operations;

procedure cancel_operations(
    i_oper_list in  cst_woo_api_type_pkg.t_oper_list
) is
begin
    for i in i_oper_list.first..i_oper_list.last loop
        update opr_operation
           set status = opr_api_const_pkg.OPERATION_STATUS_DONT_PROCESS -- OPST0101
         where id = i_oper_list(i).oper_id
           and status = cst_woo_const_pkg.OPERATION_STATUS_WAITING_BATCH; -- OPST5004
    end loop;
end cancel_operations;

procedure process_data_f59(
    i_tc_buffer             in com_api_type_pkg.t_text
  , i_file_name             in com_api_type_pkg.t_name
) is
    l_processed_count       com_api_type_pkg.t_long_id    := 0;
    l_excepted_count        com_api_type_pkg.t_long_id    := 0;
    l_rejected_count        com_api_type_pkg.t_long_id    := 0;

    l_event_params          com_api_type_pkg.t_param_tab;

    l_woo_fin_rec           cst_woo_api_type_pkg.t_mes_rec_59;
    l_oper                  opr_prc_import_pkg.t_oper_clearing_rec;
    l_resp_code             com_api_type_pkg.t_dict_value;
    l_sttl_date             date;
    l_fraud_control         com_api_type_pkg.t_boolean;
    l_multi_institution     com_api_type_pkg.t_boolean;
    l_common_sttl_day       com_api_type_pkg.t_boolean;

    l_split_hash_tab        com_api_type_pkg.t_tiny_tab;
    l_inst_id_tab           com_api_type_pkg.t_inst_id_tab;
    l_auth_data_rec         aut_api_type_pkg.t_auth_rec;
    l_auth_tag_tab          aut_api_type_pkg.t_auth_tag_tab;
begin
    trc_log_pkg.debug(
        i_text  => 'cst_woo_prc_incoming_pkg.process_data_f59 > Start'
    );
    -- parse data from buffer
    l_woo_fin_rec.seq_id            := cst_woo_com_pkg.get_substr(i_tc_buffer, 1);
    l_woo_fin_rec.recov_date        := cst_woo_com_pkg.get_substr(i_tc_buffer, 2);
    l_woo_fin_rec.recov_branch_code := cst_woo_com_pkg.get_substr(i_tc_buffer, 3);
    l_woo_fin_rec.cus_branch_code   := cst_woo_com_pkg.get_substr(i_tc_buffer, 4);
    l_woo_fin_rec.global_id         := cst_woo_com_pkg.get_substr(i_tc_buffer, 5);
    l_woo_fin_rec.cif_no            := cst_woo_com_pkg.get_substr(i_tc_buffer, 6);
    l_woo_fin_rec.crd_acc_num       := cst_woo_com_pkg.get_substr(i_tc_buffer, 7);
    l_woo_fin_rec.card_num          := cst_woo_com_pkg.get_substr(i_tc_buffer, 8);
    l_woo_fin_rec.acc_num           := cst_woo_com_pkg.get_substr(i_tc_buffer, 9);
    l_woo_fin_rec.request_amount    := cst_woo_com_pkg.get_substr(i_tc_buffer, 10);
    l_woo_fin_rec.total_amount      := cst_woo_com_pkg.get_substr(i_tc_buffer, 11);
    l_woo_fin_rec.err_code          := cst_woo_com_pkg.get_substr(i_tc_buffer, 12);
    l_woo_fin_rec.err_content       := cst_woo_com_pkg.get_substr(i_tc_buffer, 13);

    --Check if the record was already processed before
    begin
        select count(*)
          into l_processed_count
          from opr_operation
         where originator_refnum = l_woo_fin_rec.global_id
           and status = opr_api_const_pkg.OPERATION_STATUS_PROCESSED -- 'OPST0400'
           ;
    exception
        when no_data_found then
            l_processed_count := 0;
    end;

    if l_processed_count = 0 then
     -- intital operation data
        l_oper.oper_date                := to_date(cst_woo_com_pkg.get_substr(i_tc_buffer, 2), 'yyyymmdd');
        l_oper.originator_refnum        := cst_woo_com_pkg.get_substr(i_tc_buffer, 5);
        l_oper.issuer_account_number    := cst_woo_com_pkg.get_substr(i_tc_buffer, 7);
        l_oper.oper_amount_value        := to_number(cst_woo_com_pkg.get_substr(i_tc_buffer, 11));
        l_oper.issuer_card_number       := cst_woo_com_pkg.get_substr(i_tc_buffer, 8);
        l_oper.oper_amount_currency     := cst_woo_const_pkg.VNDONG;
        l_oper.oper_type                := cst_woo_const_pkg.OPERATION_PAYMENT_DD; --OPTP7030
        l_oper.msg_type                 := opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT; --MSGTPRES
        l_oper.sttl_type                := opr_api_const_pkg.SETTLEMENT_INTERNAL; --STTT0000
        l_oper.status                   := opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY; --OPST0100
        l_oper.status_reason            := aup_api_const_pkg.RESP_CODE_OK;
        l_oper.oper_reason              := cst_woo_const_pkg.ADJUSTMENT_MISC_CR; --'ACAR0006'
        l_oper.issuer_client_id_type    := opr_api_const_pkg.CLIENT_ID_TYPE_CARD;  --CITPCARD
        l_oper.issuer_client_id_value   := cst_woo_com_pkg.get_substr(i_tc_buffer, 8);
        l_oper.issuer_inst_id           := cst_woo_const_pkg.W_INST; --1001
        l_oper.issuer_network_id        := 1001;
        l_oper.issuer_exists            := com_api_type_pkg.TRUE;

        l_oper.acquirer_inst_id         := 2001;
        l_oper.acquirer_network_id      := 1001;
        l_oper.acquirer_exists          := com_api_type_pkg.TRUE;

        l_oper.destination_exists       := com_api_type_pkg.FALSE;
        l_oper.aggregator_exists        := com_api_type_pkg.FALSE;
        l_oper.service_provider_exists  := com_api_type_pkg.FALSE;
        l_oper.is_reversal              := com_api_type_pkg.FALSE;

        -- get sttl_date for operations
        l_multi_institution := set_ui_value_pkg.get_system_param_n('MULTI_INSTITUTION');
        l_common_sttl_day   := set_ui_value_pkg.get_system_param_n('COMMON_SETTLEMENT_DAY');

        if l_multi_institution   = com_api_type_pkg.FALSE
           and l_common_sttl_day = com_api_type_pkg.TRUE
        then
            l_sttl_date := com_api_sttl_day_pkg.get_open_sttl_date(ost_api_const_pkg.DEFAULT_INST);
        else
            l_sttl_date := null;
        end if;

        trc_log_pkg.debug(
            i_text  => 'l_sttl_date = ' || l_sttl_date
        );

        -- check if needed fraud control
        select case when count(1) > 0 then 1 else 0 end
          into l_fraud_control
          from opr_proc_stage
         where command is not null;

        trc_log_pkg.debug(
            i_text      => 'l_fraud_control = [' || l_fraud_control || ']'
        );

        l_resp_code :=
            opr_prc_import_pkg.register_operation(
                io_oper             => l_oper
              , io_auth_data_rec    => l_auth_data_rec
              , io_auth_tag_tab     => l_auth_tag_tab
              , i_import_clear_pan  => com_api_type_pkg.TRUE
              , i_oper_status       => l_oper.status
              , i_sttl_date         => l_sttl_date
              , i_fraud_control     => l_fraud_control
              , io_split_hash_tab   => l_split_hash_tab
              , io_inst_id_tab      => l_inst_id_tab
              , i_use_auth_data_rec => com_api_const_pkg.FALSE
              , io_event_params     => l_event_params
            );

        if l_resp_code != aup_api_const_pkg.RESP_CODE_OK then
            if l_resp_code = aup_api_const_pkg.RESP_CODE_OPERATION_DUPLICATED then
                l_rejected_count := l_rejected_count + 1;
            else
                l_excepted_count := l_excepted_count + 1;
            end if;
        end if;

        opr_prc_import_pkg.register_events(
            io_oper           => l_oper
          , i_resp_code       => l_resp_code
          , io_split_hash_tab => l_split_hash_tab
          , io_inst_id_tab    => l_inst_id_tab
          , io_event_params   => l_event_params
        );

        --process operation
        opr_api_process_pkg.process_operation(
            i_operation_id => l_oper.oper_id
        );

    end if;

--insert data into this table after parsed for logging
    insert into cst_woo_import_f59(
        seq_id
      , recov_date
      , recov_branch_code
      , cus_branch_code
      , global_id
      , cif_no
      , crd_acc_num
      , card_num
      , acc_num
      , request_amount
      , total_amount
      , err_code
      , err_content
      , import_date
      , file_name
    ) values (
        l_woo_fin_rec.seq_id
      , l_woo_fin_rec.recov_date
      , l_woo_fin_rec.recov_branch_code
      , l_woo_fin_rec.cus_branch_code
      , l_woo_fin_rec.global_id
      , l_woo_fin_rec.cif_no
      , l_woo_fin_rec.crd_acc_num
      , l_woo_fin_rec.card_num
      , l_woo_fin_rec.acc_num
      , l_woo_fin_rec.request_amount
      , l_woo_fin_rec.total_amount
      , l_woo_fin_rec.err_code
      , l_woo_fin_rec.err_content
      , get_sysdate
      , i_file_name
    );

    trc_log_pkg.debug(
        i_text  => 'cst_woo_prc_incoming_pkg.process_data_f59 > End'
    );
end process_data_f59;

procedure process_f59(
    i_inst_id               in com_api_type_pkg.t_inst_id default null
)is
    l_tc_buffer             cst_woo_api_type_pkg.t_tc_buffer;
    l_woo_file              cst_woo_api_type_pkg.t_file_rec;
    l_inst_id               com_api_type_pkg.t_inst_id;
    l_record_number         com_api_type_pkg.t_long_id := 0;
    l_record_count          com_api_type_pkg.t_count    := 0;
    l_errors_count          com_api_type_pkg.t_count    := 0;
    l_file_count            com_api_type_pkg.t_count    := 0;      
    l_header_load           com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE;
    l_file_name             com_api_type_pkg.t_name    := null;
begin
    trc_log_pkg.debug(
        i_text => 'cst_woo_prc_incoming_pkg.process_f59 > Start'
    );
    
    prc_api_stat_pkg.log_start;
    
    l_inst_id  := nvl(i_inst_id, cst_woo_const_pkg.W_INST);

    select count(1)
      into l_record_count
      from prc_file_raw_data a
         , prc_session_file b
     where b.id = (select max(id) keep (dense_rank first order by file_name desc)
                     from prc_session_file
                    where session_id = prc_api_session_pkg.get_session_id)
       and a.record_number > 1
       and a.session_file_id = b.id;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count   => l_record_count
    );

    l_record_count := 0;

    for p in (
        select id as session_file_id
             , record_count
             , file_name
          from prc_session_file
         where id = (select max(id) keep (dense_rank first order by file_name desc)
                       from prc_session_file
                      where session_id = prc_api_session_pkg.get_session_id)
    ) loop
        l_errors_count := 0;
        l_header_load  := com_api_type_pkg.FALSE;
        l_file_count   := l_file_count + 1;
        l_file_name    := p.file_name;

        begin
            savepoint sp_woo_incoming_file;
            trc_log_pkg.debug(
                i_text      => 'Session file_id =' || p.session_file_id
                            || ', file name = ' || l_file_name
            );

            for r in (
                select record_number
                     , raw_data
                     , substr(raw_data, 1, 6) ident
                  from prc_file_raw_data
                 where session_file_id = p.session_file_id
                 order by record_number
            -- processing current file
            ) loop
                l_record_number     := r.record_number;
                l_tc_buffer(1)      := r.raw_data;
                --check header
                if l_header_load = com_api_type_pkg.FALSE then
                    if r.ident = cst_woo_const_pkg.F_HEADER then
                        process_file_header(
                            i_header_data  =>  l_tc_buffer(1)
                          , i_inst_id      =>  l_inst_id
                          , i_file_name    =>  l_file_name
                          , o_woo_file     =>  l_woo_file
                        );
                        l_header_load := com_api_type_pkg.TRUE;
                    else
                        com_api_error_pkg.raise_error(
                            i_error        => 'HEADER_NOT_FOUND'
                          , i_env_param1   => p.session_file_id
                        );
                    end if;
                else
                    -- get data and process data
                    process_data_f59(
                        i_tc_buffer => l_tc_buffer(1)
                      , i_file_name => l_file_name
                    );
                    l_record_count := l_record_count + 1;
                end if;
                -- cleanup buffer before loading next record(s)
                l_tc_buffer.delete;
            end loop;

        exception
            when com_api_error_pkg.e_application_error then
                rollback to sp_woo_incoming_file;

                l_errors_count := l_errors_count + 1;
                trc_log_pkg.debug(
                    i_text          => 'Error at line='||l_record_number
                                    || ', File_name=' || l_file_name
                );

                prc_api_file_pkg.close_file(
                    i_sess_file_id  => p.session_file_id
                  , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
                );

                raise;
        end;
    end loop;

    if l_file_count = 0 then
        com_api_error_pkg.raise_error (
            i_error        => 'SEC_FILE_NOT_FOUND'
    );
    end if;

    prc_api_stat_pkg.log_end(
        i_processed_total   => l_record_count
      , i_excepted_total    => l_errors_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug(
        i_text  => 'cst_woo_prc_incoming_pkg.process_f59 > End.'
    );
exception
    when others then
        prc_api_stat_pkg.log_end(
            i_result_code   => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );
        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end process_f59;

procedure process_data_f65(
    i_tc_buffer             in com_api_type_pkg.t_text
  , i_file_name             in com_api_type_pkg.t_name
) is
    l_woo_fin_rec           cst_woo_api_type_pkg.t_mes_rec_65;
    l_map_status            com_api_type_pkg.t_sign;
    l_oper                  opr_api_type_pkg.t_oper_rec;
    l_iss_part              opr_api_type_pkg.t_oper_part_rec;
    l_original_id           com_api_type_pkg.t_long_id;
    l_count_reversal        com_api_type_pkg.t_tiny_id;
begin
    trc_log_pkg.debug(
        i_text  => 'cst_woo_prc_incoming_pkg.process_data_f65 > Start'
    );

    l_map_status := 1;

--Step 1: parse data from buffer
    l_woo_fin_rec.seq_id        := cst_woo_com_pkg.get_substr(i_tc_buffer, 1);
    l_woo_fin_rec.job_date      := cst_woo_com_pkg.get_substr(i_tc_buffer, 2);
    l_woo_fin_rec.cif_num       := cst_woo_com_pkg.get_substr(i_tc_buffer, 3);
    l_woo_fin_rec.branch_code   := cst_woo_com_pkg.get_substr(i_tc_buffer, 4);
    l_woo_fin_rec.w_bank_code   := cst_woo_com_pkg.get_substr(i_tc_buffer, 5);
    l_woo_fin_rec.w_acct_num    := cst_woo_com_pkg.get_substr(i_tc_buffer, 6);
    l_woo_fin_rec.d_bank_code   := cst_woo_com_pkg.get_substr(i_tc_buffer, 7);
    l_woo_fin_rec.d_acct_num    := cst_woo_com_pkg.get_substr(i_tc_buffer, 8);
    l_woo_fin_rec.d_currency    := cst_woo_com_pkg.get_substr(i_tc_buffer, 9);
    l_woo_fin_rec.d_amount      := cst_woo_com_pkg.get_substr(i_tc_buffer, 10);
    l_woo_fin_rec.b_content     := cst_woo_com_pkg.get_substr(i_tc_buffer, 11);
    l_woo_fin_rec.work_type     := cst_woo_com_pkg.get_substr(i_tc_buffer, 12);
    l_woo_fin_rec.err_code      := cst_woo_com_pkg.get_substr(i_tc_buffer, 13);
    l_woo_fin_rec.sv_acct_num   := cst_woo_com_pkg.get_substr(i_tc_buffer, 14);

--Step 2: insert data into this table after parsed
    insert into cst_woo_import_f65(
        seq_id
      , job_date
      , cif_num
      , branch_code
      , w_bank_code
      , w_acct_num
      , d_bank_code
      , d_acct_num
      , d_currency
      , d_amount
      , b_content
      , work_type
      , err_code
      , sv_acct_num
      , import_date
      , file_name
    ) values (
        l_woo_fin_rec.seq_id
      , l_woo_fin_rec.job_date
      , l_woo_fin_rec.cif_num
      , l_woo_fin_rec.branch_code
      , l_woo_fin_rec.w_bank_code
      , l_woo_fin_rec.w_acct_num
      , l_woo_fin_rec.d_bank_code
      , l_woo_fin_rec.d_acct_num
      , l_woo_fin_rec.d_currency
      , l_woo_fin_rec.d_amount
      , l_woo_fin_rec.b_content
      , l_woo_fin_rec.work_type
      , l_woo_fin_rec.err_code
      , l_woo_fin_rec.sv_acct_num
      , get_sysdate
      , i_file_name
    );

--Step 3: process unsuccessful transactions
    if l_woo_fin_rec.err_code <> '00000000' then

        l_original_id := substr(l_woo_fin_rec.b_content, instr(l_woo_fin_rec.b_content, ':') + 1, 16);

        select count(*)
          into l_count_reversal
          from opr_operation
         where original_id = l_original_id
           and status = opr_api_const_pkg.OPERATION_STATUS_PROCESSED
           and is_reversal = com_api_const_pkg.TRUE;

        if l_count_reversal > 0 then
            com_api_error_pkg.raise_error(
                i_error         => 'DISPUTE_DOUBLE_REVERSAL'
              , i_env_param1    => l_original_id
            );
        end if;

        opr_api_operation_pkg.get_operation(
            i_oper_id   => l_original_id
          , o_operation => l_oper
        );

        case
            when l_oper.id is null then
                com_api_error_pkg.raise_error(
                    i_error         => 'ORIGINAL_OPERATION_IS_NOT_FOUND'
                  , i_env_param1    => l_original_id
                );
            when l_oper.status != opr_api_const_pkg.OPERATION_STATUS_PROCESSED then
                com_api_error_pkg.raise_error(
                    i_error         => 'OPR_STAGE_NOT_FOUND'
                  , i_env_param1    => l_original_id
                  , i_env_param2    => l_oper.status
                );
            when l_oper.is_reversal != com_api_const_pkg.FALSE then
                com_api_error_pkg.raise_error(
                    i_error         => 'DISPUTE_DOUBLE_REVERSAL'
                  , i_env_param1    => l_original_id
                );
            else

            opr_api_operation_pkg.get_participant(
                i_oper_id           => l_original_id
              , i_participaint_type => com_api_const_pkg.PARTICIPANT_ISSUER --'PRTYISS'
              , o_participant       => l_iss_part
            );

            l_oper.host_date    := get_sysdate;
            l_oper.id           := get_id;

            --Create reversal operation for unsuccessful transaction:
            opr_api_create_pkg.create_operation (
                io_oper_id             => l_oper.id
                , i_session_id         => get_session_id
                , i_status             => opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY
                , i_status_reason      => l_oper.status_reason
                , i_sttl_type          => l_oper.sttl_type
                , i_msg_type           => l_oper.msg_type
                , i_oper_type          => l_oper.oper_type
                , i_oper_reason        => l_oper.oper_reason
                , i_is_reversal        => com_api_const_pkg.TRUE
                , i_oper_amount        => l_oper.oper_amount
                , i_oper_currency      => l_oper.oper_currency
                , i_oper_date          => l_oper.oper_date
                , i_host_date          => l_oper.host_date
                , i_original_id        => l_original_id
                , i_proc_mode          => l_oper.proc_mode
            );

            opr_api_create_pkg.add_participant (
                i_oper_id             => l_oper.id
                , i_msg_type          => l_oper.msg_type
                , i_oper_type         => l_oper.oper_type
                , i_participant_type  => com_api_const_pkg.PARTICIPANT_ISSUER
                , i_host_date         => l_oper.host_date
                , i_inst_id           => l_iss_part.inst_id
                , i_network_id        => l_iss_part.network_id
                , i_customer_id       => l_iss_part.customer_id
                , i_client_id_type    => l_iss_part.client_id_type
                , i_client_id_value   => l_iss_part.client_id_value
                , i_account_id        => l_iss_part.account_id
                , i_account_number    => l_iss_part.account_number
                , i_account_amount    => l_iss_part.account_amount
                , i_account_currency  => l_iss_part.account_currency
                , i_split_hash        => l_iss_part.split_hash
                , i_is_reversal       => com_api_const_pkg.TRUE
                , i_without_checks    => com_api_const_pkg.TRUE
            );

            opr_api_process_pkg.process_operation(
                i_operation_id => l_oper.id
            );

        end case;

        --Unsuccessful transactions from CBS will be inserted into this table
        insert into cst_woo_mapping_f64f65(
            id
          , seq_id
          , file_date
          , cif_num
          , agent_id
          , wdr_bank_code
          , wdr_acct_num
          , dep_bank_code
          , dep_acct_num
          , dep_curr_code
          , dep_amount
          , brief_content
          , work_type
          , err_code
          , sv_acct_num
          , map_status
        ) values (
            cst_woo_mapping_f64f65_seq.nextval
          , l_woo_fin_rec.seq_id
          , to_date(l_woo_fin_rec.job_date, 'yyyymmdd')
          , l_woo_fin_rec.cif_num
          , l_woo_fin_rec.branch_code
          , l_woo_fin_rec.w_bank_code
          , l_woo_fin_rec.w_acct_num
          , l_woo_fin_rec.d_bank_code
          , l_woo_fin_rec.d_acct_num
          , l_woo_fin_rec.d_currency
          , l_woo_fin_rec.d_amount
          , l_woo_fin_rec.b_content
          , l_woo_fin_rec.work_type
          , l_woo_fin_rec.err_code
          , l_woo_fin_rec.sv_acct_num
          , l_map_status
        );

    end if;

    trc_log_pkg.debug(
        i_text  => 'cst_woo_prc_incoming_pkg.process_data_f65 > End'
    );

end process_data_f65;

procedure process_f65(
    i_inst_id               in com_api_type_pkg.t_inst_id default null
) is
    l_tc_buffer             cst_woo_api_type_pkg.t_tc_buffer;
    l_woo_file              cst_woo_api_type_pkg.t_file_rec;
    l_inst_id               com_api_type_pkg.t_inst_id;
    l_record_number         com_api_type_pkg.t_long_id  := 0;
    l_record_count          com_api_type_pkg.t_count    := 0;
    l_errors_count          com_api_type_pkg.t_count    := 0;
    l_file_count            com_api_type_pkg.t_count    := 0;    
    l_header_load           com_api_type_pkg.t_boolean  := com_api_type_pkg.FALSE;
    l_file_name             com_api_type_pkg.t_name     := null;
begin
    trc_log_pkg.debug(
        i_text => 'cst_woo_prc_incoming_pkg.process_f65 > Start'
    );
    
    prc_api_stat_pkg.log_start;

    l_inst_id := nvl(i_inst_id, cst_woo_const_pkg.W_INST);

    select count(1)
      into l_record_count
      from prc_file_raw_data a
         , prc_session_file b
     where b.id = (select max(id) keep (dense_rank first order by file_name desc)
                     from prc_session_file
                    where session_id = prc_api_session_pkg.get_session_id)
       and a.record_number > 1
       and a.session_file_id = b.id;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count   => l_record_count
    );

    l_record_count := 0;

    for p in (
        select id as session_file_id
             , record_count
             , file_name
          from prc_session_file
         where id = (select max(id) keep (dense_rank first order by file_name desc)
                       from prc_session_file
                      where session_id = prc_api_session_pkg.get_session_id)
    ) loop
        l_errors_count := 0;
        l_header_load  := com_api_type_pkg.FALSE;
        l_file_count   := l_file_count + 1;
        l_file_name    := p.file_name;

        begin
            savepoint sp_woo_incoming_file;
            trc_log_pkg.debug(
                i_text => 'Session file_id =' || p.session_file_id
                            || ', file name = ' || l_file_name
            );
            
            for r in (
                select record_number
                     , raw_data
                     , substr(raw_data, 1, 6) ident
                  from prc_file_raw_data
                 where session_file_id = p.session_file_id
                 order by record_number
            -- processing current file
            ) loop
                l_record_number     := r.record_number;
                l_tc_buffer(1)      := r.raw_data;
                --check header
                if l_header_load = com_api_type_pkg.FALSE then
                    if r.ident = cst_woo_const_pkg.F_HEADER then
                        process_file_header(
                            i_header_data  =>  l_tc_buffer(1)
                          , i_inst_id      =>  l_inst_id
                          , i_file_name    =>  l_file_name
                          , o_woo_file     =>  l_woo_file
                        );
                        l_header_load := com_api_type_pkg.TRUE;
                    else
                        com_api_error_pkg.raise_error(
                            i_error        => 'HEADER_NOT_FOUND'
                          , i_env_param1   => p.session_file_id
                        );
                    end if;
                else
                    -- get data and process data
                    process_data_f65(
                        i_tc_buffer        => l_tc_buffer(1)
                      , i_file_name        => l_file_name
                    );
                    l_record_count := l_record_count + 1;
                end if;

                -- cleanup buffer before loading next record(s)
                l_tc_buffer.delete;
            end loop;

        exception
            when com_api_error_pkg.e_application_error then
                rollback to sp_woo_incoming_file;

                l_errors_count := l_errors_count + 1;

                trc_log_pkg.debug(
                    i_text  => 'Error at line='||l_record_number
                                || ', File_name=' || l_file_name
                );

                prc_api_file_pkg.close_file(
                    i_sess_file_id  => p.session_file_id
                  , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
                );
                raise;
        end;
    end loop;

    if l_file_count = 0 then
        com_api_error_pkg.raise_error (
            i_error        => 'SEC_FILE_NOT_FOUND'
    );
    end if;

    prc_api_stat_pkg.log_end(
        i_processed_total   => l_record_count
      , i_excepted_total    => l_errors_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug(
        i_text  => 'cst_woo_prc_incoming_pkg.process_f65 > End.'
    );
exception
    when others then
        prc_api_stat_pkg.log_end(
            i_result_code   => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );
        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;

end process_f65;

procedure process_data_f67(
    i_tc_buffer             in com_api_type_pkg.t_text
  , i_file_name             in com_api_type_pkg.t_name
) is
    l_woo_fin_rec           cst_woo_api_type_pkg.t_mes_rec_67;
    l_id                    com_api_type_pkg.t_short_id;
    l_seqnum                com_api_type_pkg.t_tiny_id;
    l_count                 com_api_type_pkg.t_short_id;
begin
    trc_log_pkg.debug(
        i_text  => 'cst_woo_prc_incoming_pkg.process_data_f67 > Start'
    );

-- parse data from buffer
    l_woo_fin_rec.seq_id            := cst_woo_com_pkg.get_substr(i_tc_buffer, 1);
    l_woo_fin_rec.bank_code         := cst_woo_com_pkg.get_substr(i_tc_buffer, 2);
    l_woo_fin_rec.notice_date       := cst_woo_com_pkg.get_substr(i_tc_buffer, 3);
    l_woo_fin_rec.notice_seq        := cst_woo_com_pkg.get_substr(i_tc_buffer, 4);
    l_woo_fin_rec.from_curr         := cst_woo_com_pkg.get_substr(i_tc_buffer, 5);
    l_woo_fin_rec.to_curr           := cst_woo_com_pkg.get_substr(i_tc_buffer, 6);
    l_woo_fin_rec.class_code        := cst_woo_com_pkg.get_substr(i_tc_buffer, 7);
    l_woo_fin_rec.branch_code       := cst_woo_com_pkg.get_substr(i_tc_buffer, 8);
    l_woo_fin_rec.exchange_rate     := cst_woo_com_pkg.get_substr(i_tc_buffer, 9);
    l_woo_fin_rec.f_exchange_rate   := cst_woo_com_pkg.get_substr(i_tc_buffer, 10);
    l_woo_fin_rec.notice_time       := cst_woo_com_pkg.get_substr(i_tc_buffer, 11);
    l_woo_fin_rec.status_code       := cst_woo_com_pkg.get_substr(i_tc_buffer, 12);

--insert data into this table after parsed for logging
    insert into cst_woo_import_f67(
        seq_id
      , bank_code
      , notice_date
      , notice_seq
      , from_curr
      , to_curr
      , class_code
      , branch_code
      , exchange_rate
      , f_exchange_rate
      , notice_time
      , status_code
      , import_date
      , file_name
    ) values (
        l_woo_fin_rec.seq_id
      , l_woo_fin_rec.bank_code
      , l_woo_fin_rec.notice_date
      , l_woo_fin_rec.notice_seq
      , l_woo_fin_rec.from_curr
      , l_woo_fin_rec.to_curr
      , l_woo_fin_rec.class_code
      , l_woo_fin_rec.branch_code
      , l_woo_fin_rec.exchange_rate
      , l_woo_fin_rec.f_exchange_rate
      , l_woo_fin_rec.notice_time
      , l_woo_fin_rec.status_code
      , get_sysdate
      , i_file_name
    );

--com_api_currency_pkg.get_currency_code
    com_api_rate_pkg.set_rate(
        o_id                => l_id
        , o_seqnum          => l_seqnum
        , o_count           => l_count
        , i_src_currency    => com_api_currency_pkg.get_currency_code(
                                    i_curr_name => l_woo_fin_rec.from_curr)
        , i_dst_currency    => com_api_currency_pkg.get_currency_code(
                                    i_curr_name => l_woo_fin_rec.to_curr)
        , i_rate_type       => cst_woo_const_pkg.RATE_TYPE_BANK_CUSTOMER  --'RTTPCUST'
        , i_inst_id         => cst_woo_const_pkg.W_INST
        , i_eff_date        => get_sysdate
        , i_rate            => l_woo_fin_rec.exchange_rate
        , i_inverted        => 0    --> default = 0
        , i_src_scale       => 1    --> default = 1
        , i_dst_scale       => 1    --> default = 1
        , i_exp_date        => null --> default = null
    );

    trc_log_pkg.debug(
        i_text  => 'cst_woo_prc_incoming_pkg.process_data_f67 > End'
    );
end process_data_f67;

procedure process_f67(
    i_inst_id               in com_api_type_pkg.t_inst_id default null
)is
    l_tc_buffer             cst_woo_api_type_pkg.t_tc_buffer;
    l_woo_file              cst_woo_api_type_pkg.t_file_rec;
    l_inst_id               com_api_type_pkg.t_inst_id;
    l_record_number         com_api_type_pkg.t_long_id := 0;
    l_record_count          com_api_type_pkg.t_count    := 0;
    l_errors_count          com_api_type_pkg.t_count    := 0;
    l_file_count            com_api_type_pkg.t_count    := 0; 
    l_header_load           com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE;
    l_file_name             com_api_type_pkg.t_name    := null;
begin
    trc_log_pkg.debug(
        i_text => 'cst_woo_prc_incoming_pkg.process_f67 > Start'
    );

    prc_api_stat_pkg.log_start;

    l_inst_id := nvl(i_inst_id, cst_woo_const_pkg.W_INST);

    select count(1)
      into l_record_count
      from prc_file_raw_data a
         , prc_session_file b
     where b.id = (select max(id) keep (dense_rank first order by file_name desc)
                     from prc_session_file
                    where session_id = prc_api_session_pkg.get_session_id)
       and a.record_number > 1
       and a.session_file_id = b.id;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count   => l_record_count
    );

    l_record_count := 0;

    for p in (
        select id as session_file_id
             , record_count
             , file_name
          from prc_session_file
         where id = (select max(id) keep (dense_rank first order by file_name desc)
                       from prc_session_file
                      where session_id = prc_api_session_pkg.get_session_id)
    ) loop
        l_errors_count := 0;
        l_header_load  := com_api_type_pkg.FALSE;
        l_file_count   := l_file_count + 1;
        l_file_name    := p.file_name;

        begin
            savepoint sp_woo_incoming_file;
            trc_log_pkg.debug(
                i_text      => 'Session file_id =' || p.session_file_id
                            || ', file name = ' || l_file_name
            );

            for r in (
                select record_number
                     , raw_data
                     , substr(raw_data, 1, 6) ident
                  from prc_file_raw_data
                 where session_file_id = p.session_file_id
                 order by record_number
            -- processing current file
            ) loop
                l_record_number     := r.record_number;
                l_tc_buffer(1)      := r.raw_data;
                --check header
                if l_header_load = com_api_type_pkg.FALSE then
                    if r.ident = cst_woo_const_pkg.F_HEADER then
                        process_file_header(
                            i_header_data   => l_tc_buffer(1)
                          , i_inst_id       => l_inst_id
                          , i_file_name     => l_file_name
                          , o_woo_file      => l_woo_file
                        );
                        l_header_load := com_api_type_pkg.TRUE;
                    else
                        com_api_error_pkg.raise_error(
                            i_error         => 'HEADER_NOT_FOUND'
                          , i_env_param1    => p.session_file_id
                        );
                    end if;
                else
                    -- get data and process data
                    process_data_f67(
                        i_tc_buffer         => l_tc_buffer(1)
                      , i_file_name         => l_file_name
                    );
                    l_record_count := l_record_count + 1;
                end if;
                -- cleanup buffer before loading next record(s)
                l_tc_buffer.delete;
            end loop;

        exception
            when com_api_error_pkg.e_application_error then
                rollback to sp_woo_incoming_file;

                l_errors_count := l_errors_count + 1;

                trc_log_pkg.debug(
                    i_text  => 'Error at line='||l_record_number
                               || ', File_name=' || l_file_name
                );

                prc_api_file_pkg.close_file(
                    i_sess_file_id  => p.session_file_id
                  , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
                );
                raise;
        end;
    end loop;

    if l_file_count = 0 then
        com_api_error_pkg.raise_error (
            i_error        => 'SEC_FILE_NOT_FOUND'
    );
    end if;

    prc_api_stat_pkg.log_end(
        i_processed_total   => l_record_count
      , i_excepted_total    => l_errors_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
    
    trc_log_pkg.debug(
        i_text  => 'cst_woo_prc_incoming_pkg.process_f67 > End.'
    );    
exception
    when others then
        prc_api_stat_pkg.log_end(
            i_result_code   => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );
        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;
end process_f67;

procedure process_data_f68(
    i_tc_buffer             in  com_api_type_pkg.t_text
  , i_file_name             in  com_api_type_pkg.t_name
  , o_successful_oper_id    out com_api_type_pkg.t_long_id -- in case of success oper_id will be returned
) is
    l_woo_rec               cst_woo_import_f68%rowtype;
begin
    trc_log_pkg.debug(
        i_text              => 'cst_woo_prc_incoming_pkg.process_data_f68 > Start'
    );

    -- parse data from buffer
    l_woo_rec.seq_id            := cst_woo_com_pkg.get_substr(i_tc_buffer, 1);
    l_woo_rec.file_date         := cst_woo_com_pkg.get_substr(i_tc_buffer, 2);
    l_woo_rec.cif_num           := cst_woo_com_pkg.get_substr(i_tc_buffer, 3);
    l_woo_rec.branch_code       := cst_woo_com_pkg.get_substr(i_tc_buffer, 4);
    l_woo_rec.wdr_bank_code     := cst_woo_com_pkg.get_substr(i_tc_buffer, 5);
    l_woo_rec.wdr_acct_num      := cst_woo_com_pkg.get_substr(i_tc_buffer, 6);
    l_woo_rec.dep_bank_code     := cst_woo_com_pkg.get_substr(i_tc_buffer, 7);
    l_woo_rec.dep_acct_num      := cst_woo_com_pkg.get_substr(i_tc_buffer, 8);
    l_woo_rec.dep_curr_code     := cst_woo_com_pkg.get_substr(i_tc_buffer, 9);
    l_woo_rec.dep_amount        := cst_woo_com_pkg.get_substr(i_tc_buffer, 10);    
    l_woo_rec.brief_content     := cst_woo_com_pkg.get_substr(i_tc_buffer, 11);
    l_woo_rec.work_type         := cst_woo_com_pkg.get_substr(i_tc_buffer, 12);    
    l_woo_rec.err_code          := cst_woo_com_pkg.get_substr(i_tc_buffer, 13);
    l_woo_rec.sv_crd_acct       := cst_woo_com_pkg.get_substr(i_tc_buffer, 14);    
    l_woo_rec.oper_id           := to_number(substr(l_woo_rec.brief_content, instr(l_woo_rec.brief_content, ':') + 1, 16));

    -- in case of successful response from CBS no need to resend record
    if l_woo_rec.err_code = cst_woo_const_pkg.CBS_CODE_SUCCESS then
        o_successful_oper_id := l_woo_rec.oper_id;
    else
        -- otherwise save a record to be resent
        merge
         into cst_woo_import_f68 t1
        using (select l_woo_rec.oper_id as oper_id from dual) t2
           on (t1.oper_id = t2.oper_id)
         when matched then update
              set t1.import_date = get_sysdate
                , t1.err_code = l_woo_rec.err_code
                , t1.seq_id = l_woo_rec.seq_id
                , t1.brief_content = l_woo_rec.brief_content
                , t1.file_name = i_file_name
         when not matched then insert (
              t1.seq_id
            , t1.oper_id
            , t1.brief_content
            , t1.err_code
            , t1.import_date
            , t1.file_name
            , t1.file_date
            , t1.cif_num
            , t1.branch_code
            , t1.wdr_bank_code
            , t1.wdr_acct_num
            , t1.dep_bank_code
            , t1.dep_acct_num
            , t1.dep_curr_code
            , t1.dep_amount
            , t1.work_type
            , t1.sv_crd_acct
        ) values (
              l_woo_rec.seq_id
            , l_woo_rec.oper_id
            , l_woo_rec.brief_content
            , l_woo_rec.err_code
            , get_sysdate
            , i_file_name
            , l_woo_rec.file_date
            , l_woo_rec.cif_num
            , l_woo_rec.branch_code
            , l_woo_rec.wdr_bank_code
            , l_woo_rec.wdr_acct_num
            , l_woo_rec.dep_bank_code
            , l_woo_rec.dep_acct_num
            , l_woo_rec.dep_curr_code
            , l_woo_rec.dep_amount
            , l_woo_rec.work_type
            , l_woo_rec.sv_crd_acct
        );
        o_successful_oper_id := null;
    end if;

    trc_log_pkg.debug(
        i_text  => 'cst_woo_prc_incoming_pkg.process_data_f68 > End'
    );
end process_data_f68;

procedure process_f68(
    i_inst_id         in com_api_type_pkg.t_inst_id default null
) is
    l_tc_buffer             cst_woo_api_type_pkg.t_tc_buffer;
    l_woo_file              cst_woo_api_type_pkg.t_file_rec;
    l_inst_id               com_api_type_pkg.t_inst_id;
    l_record_number         com_api_type_pkg.t_long_id  := 0;
    l_record_count          com_api_type_pkg.t_count    := 0;
    l_errors_count          com_api_type_pkg.t_count    := 0;
    l_file_count            com_api_type_pkg.t_count    := 0; 
    l_header_load           com_api_type_pkg.t_boolean  := com_api_type_pkg.FALSE;
    l_file_name             com_api_type_pkg.t_name     := null;
    l_successful_oper_id    com_api_type_pkg.t_long_id;
    l_oper_list             cst_woo_api_type_pkg.t_oper_list := cst_woo_api_type_pkg.t_oper_list();
begin
    trc_log_pkg.debug(
        i_text => 'cst_woo_prc_incoming_pkg.process_f68 > Start'
    );
    
    prc_api_stat_pkg.log_start;

    l_inst_id := nvl(i_inst_id, cst_woo_const_pkg.W_INST);

    select count(1)
      into l_record_count
      from prc_file_raw_data a
         , prc_session_file b
     where b.id = (select max(id) keep (dense_rank first order by file_name desc)
                     from prc_session_file
                    where session_id = prc_api_session_pkg.get_session_id)
       and a.record_number > 1
       and a.session_file_id = b.id;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count   => l_record_count
    );

    l_record_count := 0;

    for p in (
        select id as session_file_id
             , record_count
             , file_name
          from prc_session_file
         where id = (select max(id) keep (dense_rank first order by file_name desc)
                       from prc_session_file
                      where session_id = prc_api_session_pkg.get_session_id)
    ) loop
        l_errors_count := 0;
        l_header_load  := com_api_type_pkg.FALSE;
        l_file_count   := l_file_count + 1; 
        l_file_name    := p.file_name;

        begin
            savepoint sp_woo_incoming_file;
            trc_log_pkg.debug(
                i_text      => 'Session file_id = ' || p.session_file_id
                            || ', file name = ' || l_file_name
            );

            for r in (
                select record_number
                     , raw_data
                     , substr(raw_data, 1, 6) ident
                  from prc_file_raw_data
                 where session_file_id = p.session_file_id
                 order by record_number
            -- processing of current file
            ) loop
                l_record_number     := r.record_number;
                l_tc_buffer(1)      := r.raw_data;
                -- check header
                if l_header_load = com_api_type_pkg.FALSE then
                    if r.ident = cst_woo_const_pkg.F_HEADER then
                        process_file_header(
                            i_header_data   => l_tc_buffer(1)
                          , i_inst_id       => l_inst_id
                          , i_file_name     => l_file_name
                          , o_woo_file      => l_woo_file
                        );
                        l_header_load := com_api_type_pkg.TRUE;
                    else
                        com_api_error_pkg.raise_error(
                            i_error         => 'HEADER_NOT_FOUND'
                          , i_env_param1    => p.session_file_id
                        );
                    end if;
                else
                    -- get data and process data
                    process_data_f68(
                        i_tc_buffer          => l_tc_buffer(1)
                      , i_file_name          => l_file_name
                      , o_successful_oper_id => l_successful_oper_id
                    );
                    l_record_count := l_record_count + 1;

                    -- save successful operation ID to delete it from import table:
                    if l_successful_oper_id is not null then
                        l_oper_list.extend;
                        l_oper_list(l_oper_list.last).oper_id := l_successful_oper_id;
                    end if;
                end if;
                -- cleanup buffer before loading next record(s)
                l_tc_buffer.delete;
            end loop;
        exception
            when com_api_error_pkg.e_application_error then
                rollback to sp_woo_incoming_file;

                l_errors_count  := l_errors_count + 1;

                trc_log_pkg.debug(
                    i_text  => 'Error at line = ' || l_record_number
                            || ', File name = ' || l_file_name
                );

                prc_api_file_pkg.close_file(
                    i_sess_file_id  => p.session_file_id
                  , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
                );
                raise;
        end;
    end loop;

    if l_file_count = 0 then
        com_api_error_pkg.raise_error (
            i_error        => 'SEC_FILE_NOT_FOUND'
        );
    end if;
    
    -- Delete successful operations from table;
    forall i in l_oper_list.first..l_oper_list.last
    delete
      from cst_woo_import_f68
     where oper_id = l_oper_list(i).oper_id;

    prc_api_stat_pkg.log_end(
        i_processed_total   => l_record_count
      , i_excepted_total    => l_errors_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug(
        i_text  => 'cst_woo_prc_incoming_pkg.process_f68 > End.'
    );
exception
    when others then

        prc_api_stat_pkg.log_end(
            i_result_code   => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end process_f68;

procedure process_data_f70(
    i_tc_buffer             in com_api_type_pkg.t_text
    , i_file_name           in com_api_type_pkg.t_name
) is
    l_woo_fin_rec           cst_woo_api_type_pkg.t_mes_rec_70;
begin
    trc_log_pkg.debug(
        i_text  => 'cst_woo_prc_incoming_pkg.process_data_f70 > Start'
    );

-- parse data from buffer
    l_woo_fin_rec.seq_id                := cst_woo_com_pkg.get_substr(i_tc_buffer, 1);
    l_woo_fin_rec.bank_code             := cst_woo_com_pkg.get_substr(i_tc_buffer, 2);
    l_woo_fin_rec.staff_num             := cst_woo_com_pkg.get_substr(i_tc_buffer, 3);
    l_woo_fin_rec.staff_name            := cst_woo_com_pkg.get_substr(i_tc_buffer, 4);
    l_woo_fin_rec.branch_code           := cst_woo_com_pkg.get_substr(i_tc_buffer, 5);
    l_woo_fin_rec.r_branch_code         := cst_woo_com_pkg.get_substr(i_tc_buffer, 6);
    l_woo_fin_rec.gender                := cst_woo_com_pkg.get_substr(i_tc_buffer, 7);
    l_woo_fin_rec.eng_name              := cst_woo_com_pkg.get_substr(i_tc_buffer, 8);
    l_woo_fin_rec.chn_name              := cst_woo_com_pkg.get_substr(i_tc_buffer, 9);
    l_woo_fin_rec.cus_number            := cst_woo_com_pkg.get_substr(i_tc_buffer, 10);
    l_woo_fin_rec.cus_iden_code         := cst_woo_com_pkg.get_substr(i_tc_buffer, 11);
    l_woo_fin_rec.cus_iden_num          := cst_woo_com_pkg.get_substr(i_tc_buffer, 12);
    l_woo_fin_rec.item_value_1          := cst_woo_com_pkg.get_substr(i_tc_buffer, 13);
    l_woo_fin_rec.rank_level            := cst_woo_com_pkg.get_substr(i_tc_buffer, 14);
    l_woo_fin_rec.salary_level          := cst_woo_com_pkg.get_substr(i_tc_buffer, 15);
    l_woo_fin_rec.first_bank_date       := cst_woo_com_pkg.get_substr(i_tc_buffer, 16);
    l_woo_fin_rec.move_depart_date      := cst_woo_com_pkg.get_substr(i_tc_buffer, 17);
    l_woo_fin_rec.attend_depart_date    := cst_woo_com_pkg.get_substr(i_tc_buffer, 18);
    l_woo_fin_rec.promote_date          := cst_woo_com_pkg.get_substr(i_tc_buffer, 19);
    l_woo_fin_rec.nexn_promote_date     := cst_woo_com_pkg.get_substr(i_tc_buffer, 20);
    l_woo_fin_rec.position_code         := cst_woo_com_pkg.get_substr(i_tc_buffer, 21);
    l_woo_fin_rec.devision_code         := cst_woo_com_pkg.get_substr(i_tc_buffer, 22);
    l_woo_fin_rec.birth_date            := cst_woo_com_pkg.get_substr(i_tc_buffer, 23);
    l_woo_fin_rec.sal_acc_num           := cst_woo_com_pkg.get_substr(i_tc_buffer, 24);
    l_woo_fin_rec.is_married            := cst_woo_com_pkg.get_substr(i_tc_buffer, 25);
    l_woo_fin_rec.wed_anniver_date      := cst_woo_com_pkg.get_substr(i_tc_buffer, 26);
    l_woo_fin_rec.phone_num             := cst_woo_com_pkg.get_substr(i_tc_buffer, 27);
    l_woo_fin_rec.address               := cst_woo_com_pkg.get_substr(i_tc_buffer, 28);
    l_woo_fin_rec.cell_phone_num        := cst_woo_com_pkg.get_substr(i_tc_buffer, 29);
    l_woo_fin_rec.emer_contact_num      := cst_woo_com_pkg.get_substr(i_tc_buffer, 30);
    l_woo_fin_rec.security_num          := cst_woo_com_pkg.get_substr(i_tc_buffer, 31);
    l_woo_fin_rec.email                 := cst_woo_com_pkg.get_substr(i_tc_buffer, 32);
    l_woo_fin_rec.internal_phone_num    := cst_woo_com_pkg.get_substr(i_tc_buffer, 33);
    l_woo_fin_rec.is_retired            := cst_woo_com_pkg.get_substr(i_tc_buffer, 34);
    l_woo_fin_rec.retire_code           := cst_woo_com_pkg.get_substr(i_tc_buffer, 35);
    l_woo_fin_rec.retire_date           := cst_woo_com_pkg.get_substr(i_tc_buffer, 36);
    l_woo_fin_rec.retire_reason         := cst_woo_com_pkg.get_substr(i_tc_buffer, 37);
    l_woo_fin_rec.before_branch         := cst_woo_com_pkg.get_substr(i_tc_buffer, 38);
    l_woo_fin_rec.item_value_2          := cst_woo_com_pkg.get_substr(i_tc_buffer, 39);
    l_woo_fin_rec.item_value_3          := cst_woo_com_pkg.get_substr(i_tc_buffer, 40);
    l_woo_fin_rec.item_value_4          := cst_woo_com_pkg.get_substr(i_tc_buffer, 41);

--insert data into this table after parsed for logging
    insert into cst_woo_import_f70(
        seq_id
      , bank_code
      , staff_num
      , staff_name
      , branch_code
      , r_branch_code
      , gender
      , eng_name
      , chn_name
      , cus_number
      , cus_iden_code
      , cus_iden_num
      , item_value_1
      , rank_level
      , salary_level
      , first_bank_date
      , move_depart_date
      , attend_depart_date
      , promote_date
      , nexn_promote_date
      , position_code
      , devision_code
      , birth_date
      , sal_acc_num
      , is_married
      , wed_anniver_date
      , phone_num
      , address
      , cell_phone_num
      , emer_contact_num
      , security_num
      , email
      , internal_phone_num
      , is_retired
      , retire_code
      , retire_date
      , retire_reason
      , before_branch
      , item_value_2
      , item_value_3
      , item_value_4
      , import_date
      , file_name
    ) values (
        l_woo_fin_rec.seq_id
      , l_woo_fin_rec.bank_code
      , l_woo_fin_rec.staff_num
      , l_woo_fin_rec.staff_name
      , l_woo_fin_rec.branch_code
      , l_woo_fin_rec.r_branch_code
      , l_woo_fin_rec.gender
      , l_woo_fin_rec.eng_name
      , l_woo_fin_rec.chn_name
      , l_woo_fin_rec.cus_number
      , l_woo_fin_rec.cus_iden_code
      , l_woo_fin_rec.cus_iden_num
      , l_woo_fin_rec.item_value_1
      , l_woo_fin_rec.rank_level
      , l_woo_fin_rec.salary_level
      , l_woo_fin_rec.first_bank_date
      , l_woo_fin_rec.move_depart_date
      , l_woo_fin_rec.attend_depart_date
      , l_woo_fin_rec.promote_date
      , l_woo_fin_rec.nexn_promote_date
      , l_woo_fin_rec.position_code
      , l_woo_fin_rec.devision_code
      , l_woo_fin_rec.birth_date
      , l_woo_fin_rec.sal_acc_num
      , l_woo_fin_rec.is_married
      , l_woo_fin_rec.wed_anniver_date
      , l_woo_fin_rec.phone_num
      , l_woo_fin_rec.address
      , l_woo_fin_rec.cell_phone_num
      , l_woo_fin_rec.emer_contact_num
      , l_woo_fin_rec.security_num
      , l_woo_fin_rec.email
      , l_woo_fin_rec.internal_phone_num
      , l_woo_fin_rec.is_retired
      , l_woo_fin_rec.retire_code
      , l_woo_fin_rec.retire_date
      , l_woo_fin_rec.retire_reason
      , l_woo_fin_rec.before_branch
      , l_woo_fin_rec.item_value_2
      , l_woo_fin_rec.item_value_3
      , l_woo_fin_rec.item_value_4
      , get_sysdate
      , i_file_name
    );

    trc_log_pkg.debug(
        i_text  => 'cst_woo_prc_incoming_pkg.process_data_f70 > End'
    );
end process_data_f70;

procedure process_f70(
    i_inst_id               in com_api_type_pkg.t_inst_id default null
)is
    l_tc_buffer             cst_woo_api_type_pkg.t_tc_buffer;
    l_woo_file              cst_woo_api_type_pkg.t_file_rec;
    l_inst_id               com_api_type_pkg.t_inst_id;
    l_record_number         com_api_type_pkg.t_long_id  := 0;
    l_record_count          com_api_type_pkg.t_count    := 0;
    l_errors_count          com_api_type_pkg.t_count    := 0;
    l_file_count            com_api_type_pkg.t_count    := 0;     
    l_header_load           com_api_type_pkg.t_boolean  := com_api_type_pkg.FALSE;
    l_file_name             com_api_type_pkg.t_name     := null;

begin
    trc_log_pkg.debug(
        i_text => 'cst_woo_prc_incoming_pkg.process_f70 > Start'
    );
    
    prc_api_stat_pkg.log_start;
    
    l_inst_id := nvl(i_inst_id, cst_woo_const_pkg.W_INST);

    select count(1)
      into l_record_count
      from prc_file_raw_data a
         , prc_session_file b
     where b.id = (select max(id) keep (dense_rank first order by file_name desc)
                     from prc_session_file
                    where session_id = prc_api_session_pkg.get_session_id)
       and a.record_number > 1
       and a.session_file_id = b.id;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count   => l_record_count
    );

    l_record_count := 0;

    for p in (
        select id as session_file_id
             , record_count
             , file_name
          from prc_session_file
         where id = (select max(id) keep (dense_rank first order by file_name desc)
                       from prc_session_file
                      where session_id = prc_api_session_pkg.get_session_id)
    ) loop
        l_errors_count := 0;
        l_header_load  := com_api_type_pkg.FALSE;
        l_file_count   := l_file_count + 1;
        l_file_name    := p.file_name;

        begin
            savepoint sp_woo_incoming_file;
            trc_log_pkg.debug(
                i_text  => 'Session file_id =' || p.session_file_id
                            || ', file name = ' || l_file_name
            );

            for r in (
                select record_number
                     , raw_data
                     , substr(raw_data, 1, 6) ident
                  from prc_file_raw_data
                 where session_file_id = p.session_file_id
                 order by record_number
            -- processing current file
            ) loop
                l_record_number     := r.record_number;
                l_tc_buffer(1)      := r.raw_data;
                --check header
                if l_header_load = com_api_type_pkg.FALSE then
                    if r.ident = cst_woo_const_pkg.F_HEADER then
                        process_file_header(
                            i_header_data   => l_tc_buffer(1)
                          , i_inst_id       => l_inst_id
                          , i_file_name     => l_file_name
                          , o_woo_file      => l_woo_file
                        );
                        l_header_load := com_api_type_pkg.TRUE;
                    else
                        com_api_error_pkg.raise_error(
                            i_error         => 'HEADER_NOT_FOUND'
                            , i_env_param1  => p.session_file_id
                        );
                    end if;
                else
                    -- get data and process data
                    process_data_f70(
                        i_tc_buffer     => l_tc_buffer(1)
                      , i_file_name     => l_file_name
                    );
                    l_record_count  := l_record_count + 1;
                end if;
                -- cleanup buffer before loading next record(s)
                l_tc_buffer.delete;
            end loop;

        exception
            when com_api_error_pkg.e_application_error then
                rollback to sp_woo_incoming_file;

                l_errors_count := l_errors_count + 1;

                trc_log_pkg.debug(
                    i_text  => 'Error at line='     || l_record_number
                                || ', File_name='   || l_file_name
                );

                prc_api_file_pkg.close_file(
                    i_sess_file_id  => p.session_file_id
                  , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
                );
                raise;
        end;
    end loop;

    if l_file_count = 0 then
        com_api_error_pkg.raise_error (
            i_error        => 'SEC_FILE_NOT_FOUND'
    );
    end if;

    prc_api_stat_pkg.log_end(
        i_processed_total   => l_record_count
      , i_excepted_total    => l_errors_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug(
        i_text  => 'cst_woo_prc_incoming_pkg.process_f70 > End.'
    );
exception
    when others then
        prc_api_stat_pkg.log_end(
            i_result_code   => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );
        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end process_f70;

procedure process_data_f73(
    i_tc_buffer             in com_api_type_pkg.t_text
    , i_file_name           in com_api_type_pkg.t_name
) is
    l_woo_fin_rec           cst_woo_api_type_pkg.t_mes_rec_73;
    l_map_status            com_api_type_pkg.t_sign;
begin
    trc_log_pkg.debug(
        i_text  => 'cst_woo_prc_incoming_pkg.process_data_f73 > Start'
    );

    l_map_status := 1;

-- parse data from buffer
    l_woo_fin_rec.seq_id            := cst_woo_com_pkg.get_substr(i_tc_buffer, 1);
    l_woo_fin_rec.file_date         := cst_woo_com_pkg.get_substr(i_tc_buffer, 2);
    l_woo_fin_rec.cif_no            := cst_woo_com_pkg.get_substr(i_tc_buffer, 3);
    l_woo_fin_rec.branch_code       := cst_woo_com_pkg.get_substr(i_tc_buffer, 4);
    l_woo_fin_rec.w_acc_bank_code   := cst_woo_com_pkg.get_substr(i_tc_buffer, 5);
    l_woo_fin_rec.w_acc_num         := cst_woo_com_pkg.get_substr(i_tc_buffer, 6);
    l_woo_fin_rec.d_acc_bank_code   := cst_woo_com_pkg.get_substr(i_tc_buffer, 7);
    l_woo_fin_rec.d_acc_num         := cst_woo_com_pkg.get_substr(i_tc_buffer, 8);
    l_woo_fin_rec.d_currency        := cst_woo_com_pkg.get_substr(i_tc_buffer, 9);
    l_woo_fin_rec.d_amount          := cst_woo_com_pkg.get_substr(i_tc_buffer, 10);
    l_woo_fin_rec.brief_content     := cst_woo_com_pkg.get_substr(i_tc_buffer, 11);
    l_woo_fin_rec.work_type         := cst_woo_com_pkg.get_substr(i_tc_buffer, 12);
    l_woo_fin_rec.err_code          := cst_woo_com_pkg.get_substr(i_tc_buffer, 13);
    l_woo_fin_rec.sv_acct_num       := cst_woo_com_pkg.get_substr(i_tc_buffer, 14);

--insert data into this table after parsed for logging
    insert into cst_woo_import_f73(
        seq_id
      , file_date
      , cif_no
      , branch_code
      , w_acc_bank_code
      , w_acc_num
      , d_acc_bank_code
      , d_acc_num
      , d_currency
      , d_amount
      , brief_content
      , work_type
      , err_code
      , sv_acct_num
      , import_date
      , file_name
    ) values (
        l_woo_fin_rec.seq_id
      , l_woo_fin_rec.file_date
      , l_woo_fin_rec.cif_no
      , l_woo_fin_rec.branch_code
      , l_woo_fin_rec.w_acc_bank_code
      , l_woo_fin_rec.w_acc_num
      , l_woo_fin_rec.d_acc_bank_code
      , l_woo_fin_rec.d_acc_num
      , l_woo_fin_rec.d_currency
      , l_woo_fin_rec.d_amount
      , l_woo_fin_rec.brief_content
      , l_woo_fin_rec.work_type
      , l_woo_fin_rec.err_code
      , l_woo_fin_rec.sv_acct_num
      , get_sysdate
      , i_file_name
    );

    --Failed transactions from CBS will be inserted to this table
    if l_woo_fin_rec.err_code <> '00000000' then
        insert into cst_woo_mapping_f72f73(
            id
          , seq_id
          , file_date
          , cif_num
          , agent_id
          , wdr_bank_code
          , wdr_acct_num
          , dep_bank_code
          , dep_acct_num
          , dep_curr_code
          , dep_amount
          , brief_content
          , work_type
          , err_code
          , sv_acct_num
          , map_status
        ) values (
            cst_woo_mapping_f72f73_seq.nextval
          , l_woo_fin_rec.seq_id
          , to_date(l_woo_fin_rec.file_date, 'yyyymmdd')
          , l_woo_fin_rec.cif_no
          , l_woo_fin_rec.branch_code
          , l_woo_fin_rec.w_acc_bank_code
          , l_woo_fin_rec.w_acc_num
          , l_woo_fin_rec.d_acc_bank_code
          , l_woo_fin_rec.d_acc_num
          , l_woo_fin_rec.d_currency
          , l_woo_fin_rec.d_amount
          , l_woo_fin_rec.brief_content
          , l_woo_fin_rec.work_type
          , l_woo_fin_rec.err_code
          , l_woo_fin_rec.sv_acct_num
          , l_map_status
        );
    end if;

    trc_log_pkg.debug(
        i_text  => 'cst_woo_prc_incoming_pkg.process_data_f73 > End'
    );
end process_data_f73;

procedure process_f73(
    i_inst_id               in com_api_type_pkg.t_inst_id default null
)is
    l_tc_buffer             cst_woo_api_type_pkg.t_tc_buffer;
    l_woo_file              cst_woo_api_type_pkg.t_file_rec;
    l_inst_id               com_api_type_pkg.t_inst_id;
    l_record_number         com_api_type_pkg.t_long_id  := 0;
    l_record_count          com_api_type_pkg.t_count    := 0;
    l_errors_count          com_api_type_pkg.t_count    := 0;
    l_file_count            com_api_type_pkg.t_count    := 0;    
    l_header_load           com_api_type_pkg.t_boolean  := com_api_type_pkg.FALSE;
    l_file_name             com_api_type_pkg.t_name     := null;

begin
    trc_log_pkg.debug(
        i_text => 'cst_woo_prc_incoming_pkg.process_f73 > Start'
    );
    
    prc_api_stat_pkg.log_start;

    l_inst_id := nvl(i_inst_id, cst_woo_const_pkg.W_INST);

    select count(1)
      into l_record_count
      from prc_file_raw_data a
         , prc_session_file b
     where b.id = (select max(id) keep (dense_rank first order by file_name desc)
                     from prc_session_file
                    where session_id = prc_api_session_pkg.get_session_id)
       and a.record_number > 1
       and a.session_file_id = b.id;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count   => l_record_count
    );

    l_record_count := 0;

    for p in (
        select id as session_file_id
             , record_count
             , file_name
          from prc_session_file
         where id = (select max(id) keep (dense_rank first order by file_name desc)
                       from prc_session_file
                      where session_id = prc_api_session_pkg.get_session_id)
    ) loop
        l_errors_count := 0;
        l_header_load  := com_api_type_pkg.FALSE;
        l_file_count   := l_file_count + 1;
        l_file_name    := p.file_name;

        begin
            savepoint sp_woo_incoming_file;
            trc_log_pkg.debug(
                i_text      => 'Session file_id =' || p.session_file_id
                            || ', file name = ' || l_file_name
            );

            for r in (
                select record_number
                     , raw_data
                     , substr(raw_data, 1, 6) ident
                  from prc_file_raw_data
                 where session_file_id = p.session_file_id
                 order by record_number
            -- processing current file
            ) loop
                l_record_number     := r.record_number;
                l_tc_buffer(1)      := r.raw_data;
                --check header
                if l_header_load = com_api_type_pkg.FALSE then
                    if r.ident = cst_woo_const_pkg.F_HEADER then
                        process_file_header(
                            i_header_data   => l_tc_buffer(1)
                          , i_inst_id       => l_inst_id
                          , i_file_name     => l_file_name
                          , o_woo_file      => l_woo_file
                        );
                        l_header_load := com_api_type_pkg.TRUE;
                    else
                        com_api_error_pkg.raise_error(
                            i_error         => 'HEADER_NOT_FOUND'
                          , i_env_param1    => p.session_file_id
                        );
                    end if;
                else
                    -- get data and process data
                    process_data_f73(
                        i_tc_buffer         => l_tc_buffer(1)
                      , i_file_name         => l_file_name
                    );
                    l_record_count := l_record_count + 1;
                end if;
                -- cleanup buffer before loading next record(s)
                l_tc_buffer.delete;
            end loop;
        exception
            when com_api_error_pkg.e_application_error then
                rollback to sp_woo_incoming_file;

                l_errors_count  := l_errors_count + 1;

                trc_log_pkg.debug(
                    i_text  => 'Error at line=' || l_record_number
                                || ', File_name=' || l_file_name
                );

                prc_api_file_pkg.close_file(
                    i_sess_file_id  => p.session_file_id
                  , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
                );
                raise;
        end;
    end loop;

    if l_file_count = 0 then
        com_api_error_pkg.raise_error (
            i_error        => 'SEC_FILE_NOT_FOUND'
    );
    end if;

    prc_api_stat_pkg.log_end(
        i_processed_total   => l_record_count
      , i_excepted_total    => l_errors_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug(
        i_text  => 'cst_woo_prc_incoming_pkg.process_f73 > End.'
    );
exception
    when others then
        prc_api_stat_pkg.log_end(
            i_result_code   => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );
        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end process_f73;

function get_parent_id(
    i_appl_id               in com_api_type_pkg.t_long_id
  , i_element_name          in com_api_type_pkg.t_name
) return com_api_type_pkg.t_long_id
is
    l_parent_id             com_api_type_pkg.t_long_id;
begin
    select max(id)
      into l_parent_id
      from app_data
     where appl_id    = i_appl_id
       and element_id = app_api_element_pkg.get_element_id(i_element_name);

    return l_parent_id;
exception
    when no_data_found then
        return null;
        /*
        com_api_error_pkg.raise_error(
            i_error         => 'PARENT_ELEMENT_NOT_FOUND'
          , i_env_param1    => i_element_name
          , i_env_param2    => l_application.id
        );
        */
end;

procedure process_data_f77(
    i_tc_buffer             in com_api_type_pkg.t_text
  , i_file_name             in com_api_type_pkg.t_name
) is
    l_woo_fin_rec           cst_woo_api_type_pkg.t_mes_rec_77;
    l_application           app_api_type_pkg.t_application_rec;
    l_appl_data             app_data_tpt;
    l_seqnum                com_api_type_pkg.t_tiny_id;
    l_parent_id             com_api_type_pkg.t_long_id;
    l_customer_type         com_api_type_pkg.t_dict_value;
    l_customer_id           com_api_type_pkg.t_medium_id;
    l_serial_number         com_api_type_pkg.t_tiny_id;
    l_lang                  com_api_type_pkg.t_dict_value;

    e_nonexist_cust         exception;

    procedure add_element(
        io_appl_data        in out nocopy app_data_tpt
      , i_element_name      in            com_api_type_pkg.t_name
      , i_element_value_v   in            com_api_type_pkg.t_full_desc
    ) is
    begin
        io_appl_data.extend(1);
        io_appl_data(io_appl_data.count()) :=
            app_data_tpr(
                null
              , app_api_element_pkg.get_element_id(i_element_name)
              , null
              , 1 -- seqnum
              , i_element_value_v
              , null
              , null
              , null
            );
    end;

begin
    trc_log_pkg.debug(
        i_text  => 'cst_woo_prc_incoming_pkg.process_data_f77 > Start'
    );

-- parse data from buffer
    l_woo_fin_rec.seq_id                := cst_woo_com_pkg.get_substr(i_tc_buffer, 1);
    l_woo_fin_rec.bank_code             := cst_woo_com_pkg.get_substr(i_tc_buffer, 2);
    l_woo_fin_rec.cif_no                := cst_woo_com_pkg.get_substr(i_tc_buffer, 3);
    l_woo_fin_rec.cus_eng_name          := cst_woo_com_pkg.get_substr(i_tc_buffer, 4);
    l_woo_fin_rec.first_name            := cst_woo_com_pkg.get_substr(i_tc_buffer, 5);
    l_woo_fin_rec.second_name           := cst_woo_com_pkg.get_substr(i_tc_buffer, 6);
    l_woo_fin_rec.surname               := cst_woo_com_pkg.get_substr(i_tc_buffer, 7);
    l_woo_fin_rec.cus_local_name        := cst_woo_com_pkg.get_substr(i_tc_buffer, 8);
    l_woo_fin_rec.nationality           := cst_woo_com_pkg.get_substr(i_tc_buffer, 9);
    l_woo_fin_rec.id_type               := cst_woo_com_pkg.get_substr(i_tc_buffer, 10);
    l_woo_fin_rec.id_num                := cst_woo_com_pkg.get_substr(i_tc_buffer, 11);
    l_woo_fin_rec.birth_date            := cst_woo_com_pkg.get_substr(i_tc_buffer, 12);
    l_woo_fin_rec.gender                := cst_woo_com_pkg.get_substr(i_tc_buffer, 13);
    l_woo_fin_rec.residence_type        := cst_woo_com_pkg.get_substr(i_tc_buffer, 14);
    l_woo_fin_rec.job_code              := cst_woo_com_pkg.get_substr(i_tc_buffer, 15);
    l_woo_fin_rec.country_code          := cst_woo_com_pkg.get_substr(i_tc_buffer, 16);
    l_woo_fin_rec.region                := cst_woo_com_pkg.get_substr(i_tc_buffer, 17);
    l_woo_fin_rec.city                  := cst_woo_com_pkg.get_substr(i_tc_buffer, 18);
    l_woo_fin_rec.street                := cst_woo_com_pkg.get_substr(i_tc_buffer, 19);
    l_woo_fin_rec.home_phone            := cst_woo_com_pkg.get_substr(i_tc_buffer, 20);
    l_woo_fin_rec.mobile_phone          := cst_woo_com_pkg.get_substr(i_tc_buffer, 21);
    l_woo_fin_rec.email                 := cst_woo_com_pkg.get_substr(i_tc_buffer, 22);
    l_woo_fin_rec.fax_num               := cst_woo_com_pkg.get_substr(i_tc_buffer, 23);
    l_woo_fin_rec.company_name          := cst_woo_com_pkg.get_substr(i_tc_buffer, 24);
    l_woo_fin_rec.job_class_code        := cst_woo_com_pkg.get_substr(i_tc_buffer, 25);
    l_woo_fin_rec.pos_class_code        := cst_woo_com_pkg.get_substr(i_tc_buffer, 26);
    l_woo_fin_rec.company_phone         := cst_woo_com_pkg.get_substr(i_tc_buffer, 27);
    l_woo_fin_rec.company_addr_country  := cst_woo_com_pkg.get_substr(i_tc_buffer, 28);
    l_woo_fin_rec.company_addr_region   := cst_woo_com_pkg.get_substr(i_tc_buffer, 29);
    l_woo_fin_rec.company_addr_city     := cst_woo_com_pkg.get_substr(i_tc_buffer, 30);
    l_woo_fin_rec.company_addr_street   := cst_woo_com_pkg.get_substr(i_tc_buffer, 31);
    l_woo_fin_rec.cus_rate_code         := cst_woo_com_pkg.get_substr(i_tc_buffer, 32);
    l_woo_fin_rec.employee_num          := cst_woo_com_pkg.get_substr(i_tc_buffer, 33);
    l_woo_fin_rec.retirement_code       := cst_woo_com_pkg.get_substr(i_tc_buffer, 34);
    l_woo_fin_rec.retirement_date       := cst_woo_com_pkg.get_substr(i_tc_buffer, 35);

    l_lang        := nvl(get_user_lang(), com_api_const_pkg.LANGUAGE_ENGLISH);
    -- verify input data
    -- 1. Customer ID
    l_customer_id := prd_api_customer_pkg.get_customer_id(
                        i_customer_number => l_woo_fin_rec.cif_no
                      , i_mask_error      => 0
                     );
    if l_customer_id is null then
        raise e_nonexist_cust;
    end if;

    -- 2. Customer Type
    l_customer_type := cst_woo_com_pkg.get_customer_type( l_woo_fin_rec.cif_no);

    -- 3. Gender
    if trim(l_woo_fin_rec.gender) = 'M' then
        l_woo_fin_rec.gender := cst_woo_const_pkg.MALE_CODE;

    elsif trim(l_woo_fin_rec.gender) = 'F' then
        l_woo_fin_rec.gender := cst_woo_const_pkg.FEMALE_CODE;

    else
        l_woo_fin_rec.gender := NULL;

    end if;

    -- Create application
    l_application.flow_id       := 1004; -- Update customer --will add app_api_const_pkg
    l_application.appl_status   := app_api_const_pkg.APPL_STATUS_PROC_READY; --'APST0006'

    app_ui_application_pkg.add_application(
        io_appl_id          => l_application.id
      , o_seqnum            => l_seqnum
      , i_appl_type         => app_api_const_pkg.APPL_TYPE_ISSUING  --APTPISSA
      , i_appl_number       => null
      , i_flow_id           => l_application.flow_id -- 1004
      , i_inst_id           => cst_woo_const_pkg.W_INST  -- 1001
      , i_agent_id          => null
      , i_appl_status       => l_application.appl_status  --APST0006
      , i_session_file_id   => null
      , i_file_rec_num      => null
      , i_customer_type     => l_customer_type --ENTTPERS
      , i_split_hash        => null
      , i_reject_code       => null
      , i_user_id           => com_ui_user_env_pkg.get_user_id()
    );
-- add application data
    -- Set APPLICATION as a parent element for all new elements that are being added to the application
    begin
        select id
          into l_parent_id
          from app_data
         where appl_id      = l_application.id
           and element_id   = app_api_element_pkg.get_element_id('APPLICATION');
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error         => 'PARENT_ELEMENT_NOT_FOUND'
              , i_env_param1    => 'APPLICATION'
              , i_env_param2    => l_application.id
            );
    end;
    --<customer>--COMPLEX
    l_appl_data :=
        app_data_tpt(
            app_data_tpr(
                app_ui_application_pkg.get_next_appl_data_id(i_appl_id => l_application.id)
              , app_api_element_pkg.get_element_id('CUSTOMER')
              , get_parent_id(
                  i_appl_id         => l_application.id
                , i_element_name    => 'APPLICATION')
              , 1, null, null, null, l_lang)
        );

    app_ui_application_pkg.modify_application_data(
        i_appl_id           => l_application.id
      , i_appl_data         => l_appl_data
    );

    --<customer>--ATTRIBUTE
    l_appl_data.delete;
    l_appl_data :=
        app_data_tpt(
            app_data_tpr(
                null, app_api_element_pkg.get_element_id('COMMAND')
              , null, 1, 'CMMDEXUP', null, null, l_lang
            )
          , app_data_tpr(
                null, app_api_element_pkg.get_element_id('CUSTOMER_NUMBER')
              , null, 1, l_woo_fin_rec.cif_no, null, null, l_lang
            )
          , app_data_tpr(
                null, app_api_element_pkg.get_element_id('CUSTOMER_RELATION')
              , null, 1, 'RSCBEXTR', null, null,l_lang
            )
          , app_data_tpr(
                null, app_api_element_pkg.get_element_id('NATIONALITY')
              , null, 1
              , com_api_country_pkg.get_country_code(
                    i_visa_country_code => trim(l_woo_fin_rec.nationality)
                  , i_raise_error       => com_api_const_pkg.FALSE
                )
              , null, null, l_lang
            )
          , app_data_tpr(
                null, app_api_element_pkg.get_element_id('MONEY_LAUNDRY_REASON')
              , null, 1, 'MLRS0001', null, null, l_lang
            )
          , app_data_tpr(
                null, app_api_element_pkg.get_element_id('PERSON')
              , null, 1, null, null, null, l_lang
            )
        );

    for i in 1 .. l_appl_data.count() loop
        l_appl_data(i).appl_data_id     := app_ui_application_pkg.get_next_appl_data_id(
                                            i_appl_id       => l_application.id
                                           );
        l_appl_data(i).parent_id        := get_parent_id(
                                            i_appl_id       => l_application.id
                                           , i_element_name => 'CUSTOMER'
                                           );
    end loop;

    app_ui_application_pkg.modify_application_data(
        i_appl_id           => l_application.id
      , i_appl_data         => l_appl_data
    );

--<customer> <person> --ATTRIBUTE  --1
    l_appl_data.delete;
        l_appl_data :=
        app_data_tpt(
            app_data_tpr(
                null, app_api_element_pkg.get_element_id('COMMAND') -- <command>
              , null, 1, 'CMMDCRUP', null, null, l_lang
            )
          , app_data_tpr(
                null, app_api_element_pkg.get_element_id('PERSON_NAME')--<person_name> --COMPLEX
              , null, 1, null, null, null, l_lang
            )
        );
    for i in 1 .. l_appl_data.count() loop
        l_appl_data(i).appl_data_id := app_ui_application_pkg.get_next_appl_data_id(
                                            i_appl_id       => l_application.id
                                       );
        l_appl_data(i).parent_id    := get_parent_id(
                                            i_appl_id       => l_application.id
                                          , i_element_name  => 'PERSON'
                                       );
    end loop;

    app_ui_application_pkg.modify_application_data(
        i_appl_id           => l_application.id
      , i_appl_data         => l_appl_data
    );
--<customer> <person> <person_name> --ATTRIBUTE
    l_appl_data.delete;
        l_appl_data :=
            app_data_tpt(
                app_data_tpr(
                    null, app_api_element_pkg.get_element_id('FIRST_NAME') -- dont have
                  , null, 1, l_woo_fin_rec.first_name, null, null, l_lang
                )
              , app_data_tpr(
                    null, app_api_element_pkg.get_element_id('SURNAME')
                  , null, 1, l_woo_fin_rec.surname, null, null, l_lang
                )
            );
        for i in 1 .. l_appl_data.count() loop
            l_appl_data(i).appl_data_id := app_ui_application_pkg.get_next_appl_data_id(
                                                i_appl_id       => l_application.id
                                           );
            l_appl_data(i).parent_id    := get_parent_id(
                                                i_appl_id       => l_application.id
                                              , i_element_name  => 'PERSON_NAME'
                                           );
        end loop;

        app_ui_application_pkg.modify_application_data(
            i_appl_id       => l_application.id
          , i_appl_data     => l_appl_data
        );

--<customer> <person> --ATTRIBUTE  --2
        l_appl_data.delete;
            l_appl_data :=
            app_data_tpt(
                app_data_tpr(
                    null, app_api_element_pkg.get_element_id('BIRTHDAY') --<birthday>
                  , null, 1, null, cst_woo_com_pkg.date_yymmdd(l_woo_fin_rec.birth_date), null, l_lang
                )
              , app_data_tpr(
                    null, app_api_element_pkg.get_element_id('GENDER') --<gender>
                  , null, 1, l_woo_fin_rec.gender, null, null, l_lang
                )
              , app_data_tpr(
                    null, app_api_element_pkg.get_element_id('IDENTITY_CARD') --<identity_card> --COMPLEX
                  , null, 1, null, null, null, l_lang
                )
            );
        for i in 1 .. l_appl_data.count() loop
            l_appl_data(i).appl_data_id := app_ui_application_pkg.get_next_appl_data_id(
                                                i_appl_id       => l_application.id
                                           );
            l_appl_data(i).parent_id    := get_parent_id(
                                                i_appl_id       => l_application.id
                                              , i_element_name  => 'PERSON'
                                           );
        end loop;

        app_ui_application_pkg.modify_application_data(
            i_appl_id       => l_application.id
          , i_appl_data     => l_appl_data
        );

--<customer> <person> <identity_card> --ATTRIBUTE
    l_appl_data.delete;
        l_appl_data :=
            app_data_tpt(
                 app_data_tpr(
                    null, app_api_element_pkg.get_element_id('COMMAND')
                  , null, 1, 'CMMDCRUP', null, null, l_lang
                )
               , app_data_tpr(
                    null, app_api_element_pkg.get_element_id('ID_TYPE')
                  , null, 1, cst_woo_com_pkg.get_mapping_code(
                                i_code        => l_woo_fin_rec.id_type
                              , i_array_id   => cst_woo_const_pkg.WOORI_ID_TYPE
                              , i_in_out     => 1 -- 1: in -- 0 out
                              , i_language   => l_lang
                              )
                  , null, null, l_lang
                )
             -- , app_data_tpr(
             --       null, app_api_element_pkg.get_element_id('ID_SERIES')
             --     , null, 1, l_woo_fin_rec.id_num, null, null, l_lang
             --   )
             , app_data_tpr(
                    null, app_api_element_pkg.get_element_id('ID_NUMBER')
                  , null, 1, l_woo_fin_rec.id_num, null, null, l_lang
                )
            );
        for i in 1 .. l_appl_data.count() loop
            l_appl_data(i).appl_data_id := app_ui_application_pkg.get_next_appl_data_id(
                                                i_appl_id       => l_application.id
                                           );
            l_appl_data(i).parent_id    := get_parent_id(
                                                i_appl_id       => l_application.id
                                              , i_element_name  => 'IDENTITY_CARD'
                                           );
        end loop;

        app_ui_application_pkg.modify_application_data(
            i_appl_id       => l_application.id
          , i_appl_data     => l_appl_data
        );
--<person> <cst_company_name>--ATTRIBUTE  --3
    l_appl_data.delete;
        l_appl_data :=
        app_data_tpt(
             app_data_tpr(
                null, app_api_element_pkg.get_element_id('CST_COMPANY_NAME')--<cst_company_name>
              , null, 1, l_woo_fin_rec.company_name, null, null, l_lang
            )
         );
     for i in 1 .. l_appl_data.count() loop
        l_appl_data(i).appl_data_id := app_ui_application_pkg.get_next_appl_data_id(
                                            i_appl_id       => l_application.id
                                       );
        l_appl_data(i).parent_id    := get_parent_id(
                                            i_appl_id       =>l_application.id
                                          , i_element_name  =>'PERSON'
                                       );
    end loop;

    app_ui_application_pkg.modify_application_data(
        i_appl_id           => l_application.id
      , i_appl_data         => l_appl_data
    );
--</person>

    ---------------------------CONTACT--HOME/LANDLINE PHONE-------------------------
    -- Reset serial number = 0
    l_serial_number := 0;
    if l_woo_fin_rec.home_phone is not null then
        l_serial_number := l_serial_number + 1;
    --<customer> <contact>
        l_appl_data.delete;
            l_appl_data :=
            app_data_tpt(
                 app_data_tpr(
                    null, app_api_element_pkg.get_element_id('CONTACT')-- <contact> --COMPLEX
                  , null, l_serial_number, null, null, null, l_lang
                )
             );
         for i in 1 .. l_appl_data.count() loop
            l_appl_data(i).appl_data_id := app_ui_application_pkg.get_next_appl_data_id(
                                                i_appl_id       => l_application.id
                                           );
            l_appl_data(i).parent_id    := get_parent_id(
                                                i_appl_id       => l_application.id
                                              , i_element_name  => 'CUSTOMER'
                                           );
        end loop;

        app_ui_application_pkg.modify_application_data(
            i_appl_id       => l_application.id
          , i_appl_data     => l_appl_data
        );
        --Skip Email

    --<customer> <contact> --ATTRIBUTE
        l_appl_data.delete;
            l_appl_data :=
            app_data_tpt(
                 app_data_tpr(
                    null, app_api_element_pkg.get_element_id('COMMAND') --<command> --primary
                  , null, 1, 'CMMDCRUP', null, null, l_lang
                )
                ,app_data_tpr(
                    null, app_api_element_pkg.get_element_id('CONTACT_TYPE') --<contact_type>
                  , null, 1, nvl(cst_woo_com_pkg.get_contact_type(l_customer_id, 'CMNM0012'), 'CNTTSCNC'), null, null, l_lang
                )
                ,app_data_tpr(
                    null, app_api_element_pkg.get_element_id('CONTACT_DATA') --<contact_data> -- COMPLEX
                  , null, 1, null, null, null, l_lang
                )
             );
         for i in 1 .. l_appl_data.count() loop
            l_appl_data(i).appl_data_id := app_ui_application_pkg.get_next_appl_data_id(
                                                i_appl_id       => l_application.id
                                           );
            l_appl_data(i).parent_id    := get_parent_id(
                                                i_appl_id       => l_application.id
                                              , i_element_name  => 'CONTACT'
                                           );
        end loop;

        app_ui_application_pkg.modify_application_data(
            i_appl_id       => l_application.id
          , i_appl_data     => l_appl_data
        );
    --<customer> <contact> <contact_data>--ATTRIBUTE -- Mobile
        l_appl_data.delete;
            l_appl_data :=
            app_data_tpt(
                 app_data_tpr(
                    null, app_api_element_pkg.get_element_id('COMMUN_METHOD') --<commun_method>
                  , null, 1, 'CMNM0012', null, null, l_lang --landline fone
                )
                ,app_data_tpr(
                    null, app_api_element_pkg.get_element_id('COMMUN_ADDRESS') --<commun_address>
                  , null, 1, l_woo_fin_rec.home_phone, null, null, l_lang
                )
             );
         for i in 1 .. l_appl_data.count() loop
            l_appl_data(i).appl_data_id := app_ui_application_pkg.get_next_appl_data_id(
                                                i_appl_id       => l_application.id
                                           );
            l_appl_data(i).parent_id    := get_parent_id(
                                                i_appl_id       => l_application.id
                                              , i_element_name  => 'CONTACT_DATA'
                                           );
        end loop;

        app_ui_application_pkg.modify_application_data(
            i_appl_id       => l_application.id
          , i_appl_data     => l_appl_data
        );
    end if;
    ---------------------------CONTACT--MOBILE--------------------------------------
    if l_woo_fin_rec.mobile_phone is not null then
        l_serial_number := l_serial_number + 1;
--<customer> <contact>
        l_appl_data.delete;
            l_appl_data :=
            app_data_tpt(
                 app_data_tpr(
                    null, app_api_element_pkg.get_element_id('CONTACT')-- <contact> --COMPLEX
                  , null, l_serial_number, null, null, null, l_lang
                )
             );
         for i in 1 .. l_appl_data.count() loop
            l_appl_data(i).appl_data_id := app_ui_application_pkg.get_next_appl_data_id(
                                                i_appl_id       => l_application.id
                                           );
            l_appl_data(i).parent_id    := get_parent_id(
                                                i_appl_id       => l_application.id
                                              , i_element_name  => 'CUSTOMER'
                                           );
        end loop;

        app_ui_application_pkg.modify_application_data(
            i_appl_id       => l_application.id
          , i_appl_data     => l_appl_data
        );
        --Skip Email

    --<customer> <contact> --ATTRIBUTE
        l_appl_data.delete;
            l_appl_data :=
            app_data_tpt(
                 app_data_tpr(
                    null, app_api_element_pkg.get_element_id('COMMAND') --<command> --primary
                  , null, 1, 'CMMDCRUP', null, null, l_lang
                )
                ,app_data_tpr(
                    null, app_api_element_pkg.get_element_id('CONTACT_TYPE') --<contact_type>
                  , null, 1, nvl(cst_woo_com_pkg.get_contact_type(l_customer_id, 'CMNM0001'), 'CNTTSCNC'), null, null, l_lang                      -- not have
                )
                ,app_data_tpr(
                    null, app_api_element_pkg.get_element_id('CONTACT_DATA') --<contact_data> -- COMPLEX
                  , null, 1, null, null, null, l_lang
                )
             );
         for i in 1 .. l_appl_data.count() loop
            l_appl_data(i).appl_data_id := app_ui_application_pkg.get_next_appl_data_id(
                                                i_appl_id => l_application.id
                                           );
            l_appl_data(i).parent_id    := get_parent_id(
                                                i_appl_id       => l_application.id
                                              , i_element_name  => 'CONTACT'
                                           );
        end loop;

        app_ui_application_pkg.modify_application_data(
            i_appl_id       => l_application.id
          , i_appl_data     => l_appl_data
        );
    --<customer> <contact> <contact_data>--ATTRIBUTE -- Mobile
        l_appl_data.delete;
            l_appl_data :=
            app_data_tpt(
                 app_data_tpr(
                    null, app_api_element_pkg.get_element_id('COMMUN_METHOD') --<commun_method>
                  , null, 1, 'CMNM0001', null, null, l_lang
                )
                ,app_data_tpr(
                    null, app_api_element_pkg.get_element_id('COMMUN_ADDRESS') --<commun_address>
                  , null, 1, l_woo_fin_rec.mobile_phone, null, null, l_lang
                )
             );
         for i in 1 .. l_appl_data.count() loop
            l_appl_data(i).appl_data_id := app_ui_application_pkg.get_next_appl_data_id(
                                                i_appl_id       => l_application.id
                                           );
            l_appl_data(i).parent_id    := get_parent_id(
                                                i_appl_id       => l_application.id
                                              , i_element_name  => 'CONTACT_DATA'
                                           );
        end loop;

        app_ui_application_pkg.modify_application_data(
            i_appl_id       => l_application.id
          , i_appl_data     => l_appl_data
        );
    end if;
    ---------------------------CONTACT--EMAIL---------------------------------------
    if l_woo_fin_rec.email is not null then
        l_serial_number := l_serial_number + 1;
    --<customer> <contact>
        l_appl_data.delete;
            l_appl_data :=
            app_data_tpt(
                 app_data_tpr(
                    null, app_api_element_pkg.get_element_id('CONTACT')-- <contact> --COMPLEX
                  , null, l_serial_number, null, null, null, l_lang
                )
             );
         for i in 1 .. l_appl_data.count() loop
            l_appl_data(i).appl_data_id := app_ui_application_pkg.get_next_appl_data_id(
                                                i_appl_id       => l_application.id
                                           );
            l_appl_data(i).parent_id    := get_parent_id(
                                                i_appl_id       => l_application.id
                                              , i_element_name  => 'CUSTOMER'
                                           );
        end loop;

        app_ui_application_pkg.modify_application_data(
            i_appl_id       => l_application.id
          , i_appl_data     => l_appl_data
        );
        --Skip Email

    --<customer> <contact> --ATTRIBUTE
        l_appl_data.delete;
            l_appl_data :=
            app_data_tpt(
                 app_data_tpr(
                    null, app_api_element_pkg.get_element_id('COMMAND') --<command> --primary
                  , null, 1, 'CMMDCRUP', null, null, l_lang
                )
                ,app_data_tpr(
                    null, app_api_element_pkg.get_element_id('CONTACT_TYPE') --<contact_type>
                  , null, 1, nvl(cst_woo_com_pkg.get_contact_type(l_customer_id, 'CMNM0002'), 'CNTTSCNC'), null, null, l_lang                      -- not have
                )
                ,app_data_tpr(
                    null, app_api_element_pkg.get_element_id('CONTACT_DATA') --<contact_data> -- COMPLEX
                  , null, 1, null, null, null, l_lang
                )
             );
         for i in 1 .. l_appl_data.count() loop
            l_appl_data(i).appl_data_id := app_ui_application_pkg.get_next_appl_data_id(
                                               i_appl_id        => l_application.id
                                           );
            l_appl_data(i).parent_id    := get_parent_id(
                                                i_appl_id       => l_application.id
                                              , i_element_name  => 'CONTACT'
                                            );
        end loop;

        app_ui_application_pkg.modify_application_data(
            i_appl_id       => l_application.id
          , i_appl_data     => l_appl_data
        );
    --<customer> <contact> <contact_data>--ATTRIBUTE -- Mobile
        l_appl_data.delete;
            l_appl_data :=
            app_data_tpt(
                 app_data_tpr(
                    null, app_api_element_pkg.get_element_id('COMMUN_METHOD') --<commun_method>
                  , null, 1, 'CMNM0002', null, null, l_lang
                )
                ,app_data_tpr(
                    null, app_api_element_pkg.get_element_id('COMMUN_ADDRESS') --<commun_address>
                  , null, 1, l_woo_fin_rec.email, null, null, l_lang
                )
             );
         for i in 1 .. l_appl_data.count() loop
            l_appl_data(i).appl_data_id := app_ui_application_pkg.get_next_appl_data_id(
                                               i_appl_id        => l_application.id
                                           );
            l_appl_data(i).parent_id    := get_parent_id(
                                                i_appl_id       => l_application.id
                                              , i_element_name  => 'CONTACT_DATA'
                                           );
        end loop;

        app_ui_application_pkg.modify_application_data(
            i_appl_id       => l_application.id
          , i_appl_data     => l_appl_data
        );
    end if;
    ---------------------------CONTACT--FAX-----------------------------------------
    if l_woo_fin_rec.fax_num is not null then
        l_serial_number := l_serial_number + 1;
    --<customer> <contact>
        l_appl_data.delete;
            l_appl_data :=
            app_data_tpt(
                 app_data_tpr(
                    null, app_api_element_pkg.get_element_id('CONTACT')-- <contact> --COMPLEX
                  , null, l_serial_number, null, null, null, null
                )
             );
         for i in 1 .. l_appl_data.count() loop
            l_appl_data(i).appl_data_id := app_ui_application_pkg.get_next_appl_data_id(
                                                i_appl_id => l_application.id
                                           );
            l_appl_data(i).parent_id    := get_parent_id(
                                                i_appl_id       => l_application.id
                                              , i_element_name  => 'CUSTOMER'
                                           );
        end loop;

        app_ui_application_pkg.modify_application_data(
            i_appl_id       => l_application.id
          , i_appl_data     => l_appl_data
        );
        --Skip Email

    --<customer> <contact> --ATTRIBUTE
        l_appl_data.delete;
            l_appl_data :=
            app_data_tpt(
                 app_data_tpr(
                    null, app_api_element_pkg.get_element_id('COMMAND') --<command> --primary
                  , null, 1, 'CMMDCRUP', null, null, l_lang
                )
                ,app_data_tpr(
                    null, app_api_element_pkg.get_element_id('CONTACT_TYPE') --<contact_type>
                  , null, 1, nvl(cst_woo_com_pkg.get_contact_type(l_customer_id, 'CMNM0004'), 'CNTTSCNC')
                  , null, null, l_lang
                )
                ,app_data_tpr(
                    null, app_api_element_pkg.get_element_id('CONTACT_DATA') --<contact_data> -- COMPLEX
                  , null, 1, null, null, null, l_lang
                )
             );
         for i in 1 .. l_appl_data.count() loop
            l_appl_data(i).appl_data_id := app_ui_application_pkg.get_next_appl_data_id(
                                               i_appl_id        => l_application.id
                                           );
            l_appl_data(i).parent_id    := get_parent_id(
                                                i_appl_id       => l_application.id
                                              , i_element_name  => 'CONTACT'
                                           );
        end loop;

        app_ui_application_pkg.modify_application_data(
            i_appl_id       => l_application.id
          , i_appl_data     => l_appl_data
        );
    --<customer> <contact> <contact_data>--ATTRIBUTE -- Mobile
        l_appl_data.delete;
            l_appl_data :=
            app_data_tpt(
                 app_data_tpr(
                    null, app_api_element_pkg.get_element_id('COMMUN_METHOD') --<commun_method>
                  , null, 1, 'CMNM0004', null, null, l_lang
                )
                ,app_data_tpr(
                    null, app_api_element_pkg.get_element_id('COMMUN_ADDRESS') --<commun_address>
                  , null, 1, l_woo_fin_rec.fax_num, null, null, l_lang
                )
             );
         for i in 1 .. l_appl_data.count() loop
            l_appl_data(i).appl_data_id := app_ui_application_pkg.get_next_appl_data_id(
                                                i_appl_id       => l_application.id
                                           );
            l_appl_data(i).parent_id    := get_parent_id(
                                                i_appl_id       => l_application.id
                                              , i_element_name  => 'CONTACT_DATA'
                                           );
        end loop;

        app_ui_application_pkg.modify_application_data(
            i_appl_id       => l_application.id
          , i_appl_data     => l_appl_data
        );
    end if;
    ---------------------------CONTACT--FINISH--------------------------------------
    ---------------------------ADDRESS--HOME----------------------------------------
    l_serial_number := 0;
    if not( l_woo_fin_rec.country_code is null and l_woo_fin_rec.region is null
        and l_woo_fin_rec.city is null and l_woo_fin_rec.street is null ) then

        l_serial_number := l_serial_number + 1;
    --<customer> <address>
        l_appl_data.delete;
            l_appl_data :=
            app_data_tpt(
                 app_data_tpr(
                    null, app_api_element_pkg.get_element_id('ADDRESS')-- <contact> --COMPLEX
                  , null, l_serial_number, null, null, null, l_lang
                )
             );
         for i in 1 .. l_appl_data.count() loop
            l_appl_data(i).appl_data_id := app_ui_application_pkg.get_next_appl_data_id(
                                                i_appl_id       => l_application.id
                                           );
            l_appl_data(i).parent_id    := get_parent_id(
                                                i_appl_id       => l_application.id
                                              , i_element_name  => 'CUSTOMER'
                                           );
        end loop;

        app_ui_application_pkg.modify_application_data(
            i_appl_id       => l_application.id
          , i_appl_data     => l_appl_data
        );
    --<customer> <address>--ATTRIBUTE
       l_appl_data.delete;
            l_appl_data :=
            app_data_tpt(
                 app_data_tpr(
                    null, app_api_element_pkg.get_element_id('COMMAND')
                  , null, 1, 'CMMDCRUP', null, null, l_lang
                )
              , app_data_tpr(
                    null, app_api_element_pkg.get_element_id('ADDRESS_TYPE')
                  , null, 1, 'ADTPHOME', null, null, l_lang
                )
              , app_data_tpr(
                    null, app_api_element_pkg.get_element_id('COUNTRY')
                  , null, 1
                  , com_api_country_pkg.get_country_code(
                        i_visa_country_code => trim(l_woo_fin_rec.country_code)
                      , i_raise_error       => com_api_const_pkg.FALSE
                    )
                  , null, null, l_lang
                )
              , app_data_tpr(
                    null, app_api_element_pkg.get_element_id('ADDRESS_NAME')
                  , null, 1, null, null, null, l_lang
                )
            );
        for i in 1 .. l_appl_data.count() loop
            l_appl_data(i).appl_data_id := app_ui_application_pkg.get_next_appl_data_id(
                                                i_appl_id       => l_application.id
                                           );
            l_appl_data(i).parent_id    := get_parent_id(
                                                i_appl_id       => l_application.id
                                              , i_element_name  => 'ADDRESS'
                                           );
        end loop;

        app_ui_application_pkg.modify_application_data(
            i_appl_id       => l_application.id
          , i_appl_data     => l_appl_data
        );

    --<customer> <address> <address_name>
        l_appl_data.delete;
            l_appl_data :=
            app_data_tpt(
                 app_data_tpr(
                    null, app_api_element_pkg.get_element_id('REGION') --<region>
                  , null, 1, l_woo_fin_rec.region, null, null, l_lang
                )
                ,app_data_tpr(
                    null, app_api_element_pkg.get_element_id('CITY') --<city>
                  , null, 1, l_woo_fin_rec.city, null, null, l_lang
                )
                ,app_data_tpr(
                    null, app_api_element_pkg.get_element_id('STREET') --<street>
                  , null, 1, l_woo_fin_rec.street, null, null, l_lang
                )
             );
        for i in 1 .. l_appl_data.count() loop
            l_appl_data(i).appl_data_id := app_ui_application_pkg.get_next_appl_data_id(
                                                i_appl_id       => l_application.id
                                           );
            l_appl_data(i).parent_id    := get_parent_id(
                                                i_appl_id       => l_application.id
                                              , i_element_name  => 'ADDRESS_NAME'
                                           );
        end loop;

        app_ui_application_pkg.modify_application_data(
            i_appl_id       => l_application.id
          , i_appl_data     => l_appl_data
        );
    end if;
    ---------------------------ADDRESS--COMPANY-------------------------------------
    if not( l_woo_fin_rec.company_addr_country is null and l_woo_fin_rec.company_addr_region is null
        and l_woo_fin_rec.company_addr_city is null and l_woo_fin_rec.company_addr_street is null ) then

        l_serial_number := l_serial_number + 1;
    --<customer> <address>
        l_appl_data.delete;
            l_appl_data :=
            app_data_tpt(
                 app_data_tpr(
                    null, app_api_element_pkg.get_element_id('ADDRESS')-- <contact> --COMPLEX
                  , null, l_serial_number, null, null, null, l_lang
                )
             );
        for i in 1 .. l_appl_data.count() loop
            l_appl_data(i).appl_data_id := app_ui_application_pkg.get_next_appl_data_id(
                                                i_appl_id       => l_application.id
                                           );
            l_appl_data(i).parent_id    := get_parent_id(
                                                i_appl_id       => l_application.id
                                              , i_element_name  => 'CUSTOMER'
                                           );
        end loop;

        app_ui_application_pkg.modify_application_data(
            i_appl_id       => l_application.id
          , i_appl_data     => l_appl_data
        );
    --<customer> <address>--ATTRIBUTE
       l_appl_data.delete;
            l_appl_data :=
            app_data_tpt(
                 app_data_tpr(
                    null, app_api_element_pkg.get_element_id('COMMAND')
                  , null, 1, 'CMMDCRUP', null, null, l_lang
                )
                ,app_data_tpr(
                    null, app_api_element_pkg.get_element_id('ADDRESS_TYPE')
                  , null, 1, com_api_const_pkg.ADDRESS_TYPE_BUSINESS, null, null, l_lang
                )
                ,app_data_tpr(
                    null, app_api_element_pkg.get_element_id('COUNTRY')
                  , null, 1
                  , com_api_country_pkg.get_country_code(
                        i_visa_country_code => trim(l_woo_fin_rec.company_addr_country)
                      , i_raise_error       => com_api_const_pkg.FALSE
                    )
                  , null, null, null
                )
                ,app_data_tpr(
                    null, app_api_element_pkg.get_element_id('ADDRESS_NAME')
                  , null, 1, null, null, null, l_lang
                )
             );
         for i in 1 .. l_appl_data.count() loop
            l_appl_data(i).appl_data_id := app_ui_application_pkg.get_next_appl_data_id(
                                                i_appl_id       => l_application.id
                                           );
            l_appl_data(i).parent_id    := get_parent_id(
                                                i_appl_id       => l_application.id
                                              , i_element_name  => 'ADDRESS');
        end loop;

        app_ui_application_pkg.modify_application_data(
            i_appl_id       => l_application.id
          , i_appl_data     => l_appl_data
        );

        --<customer> <address> <address_name>
        l_appl_data.delete;
            l_appl_data :=
            app_data_tpt(
                app_data_tpr(
                    null, app_api_element_pkg.get_element_id('REGION') --<region>
                  , null, 1, cst_woo_com_pkg.get_mapping_code(
                                i_code        => l_woo_fin_rec.company_addr_region
                              , i_array_id    => cst_woo_const_pkg.WOORI_REGION_CODE
                              , i_in_out      => 1 -- 1: in -- 0 out
                              , i_language    => l_lang)
                  , null, null, l_lang
                )
              , app_data_tpr(
                    null, app_api_element_pkg.get_element_id('CITY') --<city>
                  , null, 1, cst_woo_com_pkg.get_mapping_code(
                                i_code        => l_woo_fin_rec.company_addr_city
                              , i_array_id    => cst_woo_const_pkg.WOORI_CITY_CODE
                              , i_in_out      => 1 -- 1: in -- 0 out
                              , i_language    => l_lang)
                 , null, null, l_lang
                )
              , app_data_tpr(
                    null, app_api_element_pkg.get_element_id('STREET') --<street>
                  , null, 1, l_woo_fin_rec.company_addr_street, null, null, l_lang
                )
            );
        for i in 1 .. l_appl_data.count() loop
            l_appl_data(i).appl_data_id := app_ui_application_pkg.get_next_appl_data_id(
                                                i_appl_id       => l_application.id
                                           );
            l_appl_data(i).parent_id    := get_parent_id(
                                                i_appl_id       => l_application.id
                                              , i_element_name  => 'ADDRESS_NAME');
        end loop;

        app_ui_application_pkg.modify_application_data(
            i_appl_id       => l_application.id
          , i_appl_data     => l_appl_data
        );
    end if;
    ---------------------------ADDRESS--END-----------------------------------------
--<customer>
    l_appl_data.delete;
        l_appl_data :=
        app_data_tpt(
            app_data_tpr(
                null, app_api_element_pkg.get_element_id('RESIDENCE_TYPE') --<residence_type>
              , null, 1, l_woo_fin_rec.pos_class_code, null, null, l_lang
            )
            ,app_data_tpr(
                null, app_api_element_pkg.get_element_id('CST_EMPLOYEE_NUMBER')
              , null, 1, l_woo_fin_rec.employee_num, null, null, l_lang
            )
            ,app_data_tpr(
                null, app_api_element_pkg.get_element_id('CST_RETIREMENT_CODE')
              , null, 1, l_woo_fin_rec.retirement_code, null, null, l_lang
            )
            ,app_data_tpr(
                null, app_api_element_pkg.get_element_id('CST_RETIREMENT_DATE')
              , null, 1, null, cst_woo_com_pkg.date_yymmdd(l_woo_fin_rec.retirement_date), null, l_lang
            )
            ,app_data_tpr(
                null, app_api_element_pkg.get_element_id('CST_PAYMENT_CAPABILITY') --<cst_payment_capability>
              , null, 1, l_woo_fin_rec.job_class_code, null, null, l_lang
            )
            ,app_data_tpr(
                null, app_api_element_pkg.get_element_id('CST_COMPANY_POSITION') --<cst_company_position>
              , null, 1, l_woo_fin_rec.pos_class_code, null, null, l_lang
            )
        );

        for i in 1 .. l_appl_data.count() loop
            l_appl_data(i).appl_data_id := app_ui_application_pkg.get_next_appl_data_id(
                                                i_appl_id       => l_application.id
                                           );
            l_appl_data(i).parent_id    := get_parent_id(
                                                i_appl_id       => l_application.id
                                              , i_element_name  => 'CUSTOMER');
        end loop;

        app_ui_application_pkg.modify_application_data(
            i_appl_id       => l_application.id
          , i_appl_data     => l_appl_data
        );
--</customer>
--Process application
        app_ui_application_pkg.process_application(i_appl_id    => l_application.id);
--Process application
    insert into cst_woo_import_f77(
        seq_id
      , bank_code
      , cif_no
      , cus_eng_name
      , first_name
      , second_name
      , surname
      , cus_local_name
      , nationality
      , id_type
      , id_num
      , birth_date
      , gender
      , residence_type
      , job_code
      , country_code
      , region
      , city
      , street
      , home_phone
      , mobile_phone
      , email
      , fax_num
      , company_name
      , job_class_code
      , pos_class_code
      , company_phone
      , company_addr_country
      , company_addr_region
      , company_addr_city
      , company_addr_street
      , cus_rate_code
      , employee_num
      , retirement_code
      , retirement_date
      , import_date
      , file_name
    ) values (
        l_woo_fin_rec.seq_id
      , l_woo_fin_rec.bank_code
      , l_woo_fin_rec.cif_no
      , l_woo_fin_rec.cus_eng_name
      , l_woo_fin_rec.first_name
      , l_woo_fin_rec.second_name
      , l_woo_fin_rec.surname
      , l_woo_fin_rec.cus_local_name
      , l_woo_fin_rec.nationality
      , l_woo_fin_rec.id_type
      , l_woo_fin_rec.id_num
      , l_woo_fin_rec.birth_date
      , decode(l_woo_fin_rec.gender, 'GNDRMALE', 'M', 'GNDRFEML', 'F', null)
      , l_woo_fin_rec.residence_type
      , l_woo_fin_rec.job_code
      , l_woo_fin_rec.country_code
      , l_woo_fin_rec.region
      , l_woo_fin_rec.city
      , l_woo_fin_rec.street
      , l_woo_fin_rec.home_phone
      , l_woo_fin_rec.mobile_phone
      , l_woo_fin_rec.email
      , l_woo_fin_rec.fax_num
      , l_woo_fin_rec.company_name
      , l_woo_fin_rec.job_class_code
      , l_woo_fin_rec.pos_class_code
      , l_woo_fin_rec.company_phone
      , l_woo_fin_rec.company_addr_country
      , l_woo_fin_rec.company_addr_region
      , l_woo_fin_rec.company_addr_city
      , l_woo_fin_rec.company_addr_street
      , l_woo_fin_rec.cus_rate_code
      , l_woo_fin_rec.employee_num
      , l_woo_fin_rec.retirement_code
      , l_woo_fin_rec.retirement_date
      , get_sysdate
      , i_file_name
    );

    trc_log_pkg.debug(
        i_text  => 'cst_woo_prc_incoming_pkg.process_data_f77 > End'
    );
exception
    when e_nonexist_cust then
        com_api_error_pkg.raise_error(
            i_error         => 'CUSTOMER_NOT_FOUND'
          , i_env_param1    => l_woo_fin_rec.cif_no
        );
end process_data_f77;

procedure process_f77(
    i_inst_id               in com_api_type_pkg.t_inst_id default null
)is
    l_tc_buffer             cst_woo_api_type_pkg.t_tc_buffer;
    l_woo_file              cst_woo_api_type_pkg.t_file_rec;
    l_inst_id               com_api_type_pkg.t_inst_id;
    l_record_number         com_api_type_pkg.t_long_id  := 0;
    l_record_count          com_api_type_pkg.t_count    := 0;
    l_errors_count          com_api_type_pkg.t_count    := 0;
    l_file_count            com_api_type_pkg.t_count    := 0;       
    l_header_load           com_api_type_pkg.t_boolean  := com_api_type_pkg.FALSE;
    l_file_name             com_api_type_pkg.t_name     := null; 

begin
    trc_log_pkg.debug(
        i_text => 'cst_woo_prc_incoming_pkg.process_f77 > Start'
    );
    prc_api_stat_pkg.log_start;

    l_inst_id := nvl(i_inst_id, cst_woo_const_pkg.W_INST);

    select count(1)
      into l_record_count
      from prc_file_raw_data a
         , prc_session_file b
     where b.id = (select max(id) keep (dense_rank first order by file_name desc)
                     from prc_session_file
                    where session_id = prc_api_session_pkg.get_session_id)
       and a.record_number > 1
       and a.session_file_id = b.id;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count   => l_record_count
    );

    l_record_count := 0;

    for p in (
        select id as session_file_id
             , record_count
             , file_name
          from prc_session_file
         where id = (select max(id) keep (dense_rank first order by file_name desc)
                       from prc_session_file
                      where session_id = prc_api_session_pkg.get_session_id)
    ) loop
        l_errors_count := 0;
        l_header_load  := com_api_type_pkg.FALSE;
        l_file_count   := l_file_count + 1;
        l_file_name    := p.file_name;

        begin
            savepoint sp_woo_incoming_file;
            trc_log_pkg.debug(
                i_text      => 'Session file_id =' || p.session_file_id
                            || ', file name = ' || l_file_name
            );

            for r in (
                select record_number
                     , raw_data
                     , substr(raw_data, 1, 6) ident
                  from prc_file_raw_data
                 where session_file_id = p.session_file_id
                 order by record_number
            -- processing current file
            ) loop
                l_record_number     := r.record_number;
                l_tc_buffer(1)      := r.raw_data;
                --check header
                if l_header_load = com_api_type_pkg.FALSE then
                    if r.ident = cst_woo_const_pkg.F_HEADER then
                        process_file_header(
                            i_header_data   =>  l_tc_buffer(1)
                            , i_inst_id     =>  l_inst_id
                            , i_file_name   =>  l_file_name
                            , o_woo_file    =>  l_woo_file
                        );
                        l_header_load := com_api_type_pkg.TRUE;
                    else
                        com_api_error_pkg.raise_error(
                            i_error         => 'HEADER_NOT_FOUND'
                            , i_env_param1  => p.session_file_id
                        );
                    end if;
                else
                    -- get data and process data
                    process_data_f77(
                        i_tc_buffer         => l_tc_buffer(1)
                        , i_file_name       => l_file_name
                    );
                    l_record_count := l_record_count + 1;
                end if;

                -- cleanup buffer before loading next record(s)
                l_tc_buffer.delete;

            end loop;

        exception
            when com_api_error_pkg.e_application_error then
                rollback to sp_woo_incoming_file;

                l_errors_count := l_errors_count + 1;

                trc_log_pkg.debug(
                    i_text  => 'Error at line=' || l_record_number
                                || ', File_name=' || l_file_name
                );

                prc_api_file_pkg.close_file(
                    i_sess_file_id  => p.session_file_id
                  , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
                );
                raise;
        end;

    end loop;

    if l_file_count = 0 then
        com_api_error_pkg.raise_error (
            i_error        => 'SEC_FILE_NOT_FOUND'
    );
    end if;

    prc_api_stat_pkg.log_end(
        i_processed_total   => l_record_count
      , i_excepted_total    => l_errors_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug(
        i_text  => 'cst_woo_prc_incoming_pkg.process_f77 > End.'
    );
exception
    when others then
        prc_api_stat_pkg.log_end(
            i_result_code   => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );
        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end process_f77;

procedure process_data_f78(
    i_tc_buffer             in com_api_type_pkg.t_text
  , i_file_name             in com_api_type_pkg.t_name
) is
    l_woo_fin_rec           cst_woo_api_type_pkg.t_mes_rec_78;
begin
    trc_log_pkg.debug(
        i_text  => 'cst_woo_prc_incoming_pkg.process_data_f78 > Start'
    );

-- parse data from buffer
    l_woo_fin_rec.seq_id                := cst_woo_com_pkg.get_substr(i_tc_buffer, 1);
    l_woo_fin_rec.approved_date         := cst_woo_com_pkg.get_substr(i_tc_buffer, 2);
    l_woo_fin_rec.tele_mess_num         := cst_woo_com_pkg.get_substr(i_tc_buffer, 3);
    l_woo_fin_rec.trans_num             := cst_woo_com_pkg.get_substr(i_tc_buffer, 4);
    l_woo_fin_rec.card_num              := cst_woo_com_pkg.get_substr(i_tc_buffer, 5);
    l_woo_fin_rec.card_revenue_type     := cst_woo_com_pkg.get_substr(i_tc_buffer, 6);
    l_woo_fin_rec.approved_amt          := cst_woo_com_pkg.get_substr(i_tc_buffer, 7);
    l_woo_fin_rec.cash_id_code          := cst_woo_com_pkg.get_substr(i_tc_buffer, 8);
    l_woo_fin_rec.card_approved_code    := cst_woo_com_pkg.get_substr(i_tc_buffer, 9);
    l_woo_fin_rec.approved_time         := cst_woo_com_pkg.get_substr(i_tc_buffer, 10);
    l_woo_fin_rec.terminal_id           := cst_woo_com_pkg.get_substr(i_tc_buffer, 11);
    l_woo_fin_rec.terminal_agent_id     := cst_woo_com_pkg.get_substr(i_tc_buffer, 12);
    l_woo_fin_rec.response_code         := cst_woo_com_pkg.get_substr(i_tc_buffer, 13);

--insert data into this table after parsed for logging
    insert into cst_woo_import_f78(
        seq_id
      , approved_date
      , tele_mess_num
      , trans_num
      , card_num
      , card_revenue_type
      , approved_amt
      , cash_id_code
      , card_approved_code
      , approved_time
      , terminal_id
      , terminal_agent_id
      , response_code
      , import_date
      , file_name
    ) values (
        l_woo_fin_rec.seq_id
      , l_woo_fin_rec.approved_date
      , l_woo_fin_rec.tele_mess_num
      , l_woo_fin_rec.trans_num
      , l_woo_fin_rec.card_num
      , l_woo_fin_rec.card_revenue_type
      , l_woo_fin_rec.approved_amt
      , l_woo_fin_rec.cash_id_code
      , l_woo_fin_rec.card_approved_code
      , l_woo_fin_rec.approved_time
      , l_woo_fin_rec.terminal_id
      , l_woo_fin_rec.terminal_agent_id
      , l_woo_fin_rec.response_code
      , get_sysdate
      , i_file_name
    );

    trc_log_pkg.debug(
        i_text  => 'cst_woo_prc_incoming_pkg.process_data_f78 > End'
    );
end process_data_f78;

procedure process_f78(
    i_inst_id               in com_api_type_pkg.t_inst_id default null
)is
    l_tc_buffer             cst_woo_api_type_pkg.t_tc_buffer;
    l_woo_file              cst_woo_api_type_pkg.t_file_rec;
    l_inst_id               com_api_type_pkg.t_inst_id;
    l_record_number         com_api_type_pkg.t_long_id  := 0;
    l_record_count          com_api_type_pkg.t_count    := 0;
    l_errors_count          com_api_type_pkg.t_count    := 0;
    l_file_count            com_api_type_pkg.t_count    := 0;    
    l_header_load           com_api_type_pkg.t_boolean  := com_api_type_pkg.FALSE;
    l_file_name             com_api_type_pkg.t_name     := null;      
    l_start_date            date;
    l_end_date              date;

begin
    trc_log_pkg.debug(
        i_text => 'cst_woo_prc_incoming_pkg.process_f78 > Start'
    );

    prc_api_stat_pkg.log_start;

    l_inst_id := nvl(i_inst_id, cst_woo_const_pkg.W_INST);

    --Time period for ATM transactions reconciliation
    l_start_date := to_date(to_char(get_sysdate - 1, 'dd/mm/yyyy')|| ' 18:00:00', 'dd/mm/yyyy HH24:MI:SS');
    l_end_date := to_date(to_char(get_sysdate, 'dd/mm/yyyy')|| ' 17:59:59', 'dd/mm/yyyy HH24:MI:SS');    

    select count(1)
      into l_record_count
      from prc_file_raw_data a
         , prc_session_file b
     where b.id = (select max(id) keep (dense_rank first order by file_name desc)
                     from prc_session_file
                    where session_id = prc_api_session_pkg.get_session_id)
       and a.record_number > 1
       and a.session_file_id = b.id;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count   => l_record_count
    );

    l_record_count := 0;

    for p in (
        select id as session_file_id
             , record_count
             , file_name
          from prc_session_file
         where id = (select max(id) keep (dense_rank first order by file_name desc)
                       from prc_session_file
                      where session_id = prc_api_session_pkg.get_session_id)
    ) loop
        l_errors_count := 0;
        l_header_load  := com_api_type_pkg.FALSE;
        l_file_count   := l_file_count + 1;
        l_file_name    := p.file_name;

        begin
            savepoint sp_woo_incoming_file;
            trc_log_pkg.debug(
                i_text      => 'Session file_id =' || p.session_file_id
                            || ', file name = ' || l_file_name
            );

            for r in (
                select record_number
                     , raw_data
                     , substr(raw_data, 1, 6) ident
                  from prc_file_raw_data
                 where session_file_id = p.session_file_id
                 order by record_number
            -- processing current file
            ) loop
                l_record_number     := r.record_number;
                l_tc_buffer(1)      := r.raw_data;
                --check header
                if l_header_load = com_api_type_pkg.FALSE then
                    if r.ident = cst_woo_const_pkg.F_HEADER then
                        process_file_header(
                            i_header_data   =>  l_tc_buffer(1)
                            , i_inst_id     =>  l_inst_id
                            , i_file_name   =>  l_file_name
                            , o_woo_file    =>  l_woo_file
                        );
                        l_header_load := com_api_type_pkg.TRUE;
                    else
                        com_api_error_pkg.raise_error(
                            i_error         => 'HEADER_NOT_FOUND'
                            , i_env_param1  => p.session_file_id
                        );
                    end if;
                else
                    -- get data and process data
                    process_data_f78(
                        i_tc_buffer         => l_tc_buffer(1)
                        , i_file_name       => l_file_name
                    );
                    l_record_count := l_record_count + 1;
                end if;

                -- cleanup buffer before loading next record(s)
                l_tc_buffer.delete;

            end loop;
        exception
            when com_api_error_pkg.e_application_error then
                rollback to sp_woo_incoming_file;

                l_errors_count := l_errors_count + 1;

                trc_log_pkg.debug(
                    i_text  => 'Error at line=' || l_record_number
                                || ', File_name=' || l_file_name
                );

                prc_api_file_pkg.close_file(
                    i_sess_file_id  => p.session_file_id
                  , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
                );
                raise;
        end;

    end loop;

    if l_file_count = 0 then
        com_api_error_pkg.raise_error (
            i_error        => 'SEC_FILE_NOT_FOUND'
        );
    end if;
    
    cst_woo_com_pkg.reconcile_atm_trans(
        i_start_date => l_start_date
      , i_end_date   => l_end_date
    );

    prc_api_stat_pkg.log_end(
        i_processed_total   => l_record_count
      , i_excepted_total    => l_errors_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug(
        i_text  => 'cst_woo_prc_incoming_pkg.process_f78 > End.'
    );

exception
    when others then
        prc_api_stat_pkg.log_end(
            i_result_code   => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );
        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end process_f78;

procedure process_data_f79(
    i_tc_buffer             in com_api_type_pkg.t_text
    , i_file_name           in com_api_type_pkg.t_name
) is
    l_woo_fin_rec           cst_woo_api_type_pkg.t_mes_rec_79;
    l_params                com_api_type_pkg.t_param_tab;
begin
    trc_log_pkg.debug(
        i_text  => 'cst_woo_prc_incoming_pkg.process_data_f79 > Start'
    );

-- parse data from buffer
    l_woo_fin_rec.seq_id                := cst_woo_com_pkg.get_substr(i_tc_buffer, 1);
    l_woo_fin_rec.bank_code             := cst_woo_com_pkg.get_substr(i_tc_buffer, 2);
    l_woo_fin_rec.cif_no                := cst_woo_com_pkg.get_substr(i_tc_buffer, 3);
    l_woo_fin_rec.accident_code         := cst_woo_com_pkg.get_substr(i_tc_buffer, 4);
    l_woo_fin_rec.cus_accident_num      := cst_woo_com_pkg.get_substr(i_tc_buffer, 5);
    l_woo_fin_rec.start_date            := cst_woo_com_pkg.get_substr(i_tc_buffer, 6);
    l_woo_fin_rec.end_date              := cst_woo_com_pkg.get_substr(i_tc_buffer, 7);
    l_woo_fin_rec.free_date             := cst_woo_com_pkg.get_substr(i_tc_buffer, 8);
    l_woo_fin_rec.employee_num          := cst_woo_com_pkg.get_substr(i_tc_buffer, 9);
    l_woo_fin_rec.release_branch_code   := cst_woo_com_pkg.get_substr(i_tc_buffer, 10);
    l_woo_fin_rec.restrict_branch_code  := cst_woo_com_pkg.get_substr(i_tc_buffer, 11);
    l_woo_fin_rec.reg_branch_code       := cst_woo_com_pkg.get_substr(i_tc_buffer, 12);
    l_woo_fin_rec.reg_employee_num      := cst_woo_com_pkg.get_substr(i_tc_buffer, 13);
    l_woo_fin_rec.reg_content           := cst_woo_com_pkg.get_substr(i_tc_buffer, 14);
    l_woo_fin_rec.is_valid              := cst_woo_com_pkg.get_substr(i_tc_buffer, 15);
    l_woo_fin_rec.status_code           := cst_woo_com_pkg.get_substr(i_tc_buffer, 16);

--insert data into this table after parsed for logging
    insert into cst_woo_import_f79(
        seq_id
      , bank_code
      , cif_no
      , accident_code
      , cus_accident_num
      , start_date
      , end_date
      , free_date
      , employee_num
      , release_branch_code
      , restrict_branch_code
      , reg_branch_code
      , reg_employee_num
      , reg_content
      , is_valid
      , status_code
      , import_date
      , file_name
    ) values (
        l_woo_fin_rec.seq_id
      , l_woo_fin_rec.bank_code
      , l_woo_fin_rec.cif_no
      , l_woo_fin_rec.accident_code
      , l_woo_fin_rec.cus_accident_num
      , l_woo_fin_rec.start_date
      , l_woo_fin_rec.end_date
      , l_woo_fin_rec.free_date
      , l_woo_fin_rec.employee_num
      , l_woo_fin_rec.release_branch_code
      , l_woo_fin_rec.restrict_branch_code
      , l_woo_fin_rec.reg_branch_code
      , l_woo_fin_rec.reg_employee_num
      , l_woo_fin_rec.reg_content
      , l_woo_fin_rec.is_valid
      , l_woo_fin_rec.status_code
      , get_sysdate
      , i_file_name
    );

    --Temporary blocking all cards of customer
    for p in (
        select distinct ici.id as card_instance_id
          from iss_card ica
             , iss_card_instance ici
             , prd_customer pct
         where 1 = 1
           and ica.id               = ici.card_id
           and ica.customer_id      = pct.id
           and ici.state            = iss_api_const_pkg.CARD_STATE_ACTIVE       --'CSTE0200'
           and ici.status           in (iss_api_const_pkg.CARD_STATUS_VALID_CARD  --'CSTS0000'
                                      , iss_api_const_pkg.CARD_STATUS_NOT_ACTIVATED) --'CSTS0012'
           and pct.customer_number  = l_woo_fin_rec.cif_no
    )
    loop
        evt_api_status_pkg.change_status(
            i_event_type   => 'EVNT0168'  --Temporary card blocking by bank on client request
          , i_initiator    => evt_api_const_pkg.INITIATOR_OPERATOR  -- 'ENSIOPER'
          , i_entity_type  => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
          , i_object_id    => p.card_instance_id
          , i_reason       => iss_api_const_pkg.CARD_STATUS_REASON_PC_REGUL
          , i_params       => l_params
        );
    end loop;

    trc_log_pkg.debug(
        i_text              => 'cst_woo_prc_incoming_pkg.process_data_f79 > End'
    );

exception
    when no_data_found then
        trc_log_pkg.debug (
            i_text  =>  'Not found card_instance_id for customer number = '
                        || l_woo_fin_rec.cif_no || ' In procedure process_data_f79'
        );
end process_data_f79;

procedure process_f79(
    i_inst_id               in com_api_type_pkg.t_inst_id default null
)is
    l_tc_buffer             cst_woo_api_type_pkg.t_tc_buffer;
    l_woo_file              cst_woo_api_type_pkg.t_file_rec;
    l_inst_id               com_api_type_pkg.t_inst_id;
    l_record_number         com_api_type_pkg.t_long_id  := 0;
    l_record_count          com_api_type_pkg.t_count    := 0;
    l_errors_count          com_api_type_pkg.t_count    := 0;
    l_file_count            com_api_type_pkg.t_count    := 0;     
    l_header_load           com_api_type_pkg.t_boolean  := com_api_type_pkg.FALSE;
    l_file_name             com_api_type_pkg.t_name     := null;   

begin
    trc_log_pkg.debug(
        i_text => 'cst_woo_prc_incoming_pkg.process_f79 > Start'
    );
    
    prc_api_stat_pkg.log_start;

    l_inst_id := nvl(i_inst_id, cst_woo_const_pkg.W_INST);

    select count(1)
      into l_record_count
      from prc_file_raw_data a
         , prc_session_file b
     where b.id = (select max(id) keep (dense_rank first order by file_name desc)
                     from prc_session_file
                    where session_id = prc_api_session_pkg.get_session_id)
       and a.record_number > 1
       and a.session_file_id = b.id;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count   => l_record_count
    );

    l_record_count := 0;

    for p in (
        select id as session_file_id
             , record_count
             , file_name
          from prc_session_file
         where id = (select max(id) keep (dense_rank first order by file_name desc)
                       from prc_session_file
                      where session_id = prc_api_session_pkg.get_session_id)
    ) loop
        l_errors_count := 0;
        l_header_load  := com_api_type_pkg.FALSE;
        l_file_count   := l_file_count + 1;
        l_file_name    := p.file_name;

        begin
            savepoint sp_woo_incoming_file;
            trc_log_pkg.debug(
                i_text      => 'Session file_id =' || p.session_file_id
                            || ', file name = ' || l_file_name
            );

            for r in (
                select record_number
                     , raw_data
                     , substr(raw_data, 1, 6) ident
                  from prc_file_raw_data
                 where session_file_id = p.session_file_id
                 order by record_number
            -- processing current file
            ) loop
                l_record_number                     := r.record_number;
                l_tc_buffer(1)      := r.raw_data;
                --check header
                if l_header_load = com_api_type_pkg.FALSE then
                    if r.ident = cst_woo_const_pkg.F_HEADER then
                        process_file_header(
                            i_header_data   => l_tc_buffer(1)
                          , i_inst_id       => l_inst_id
                          , i_file_name     => l_file_name
                          , o_woo_file      => l_woo_file
                        );
                        l_header_load := com_api_type_pkg.TRUE;
                    else
                        com_api_error_pkg.raise_error(
                            i_error         => 'HEADER_NOT_FOUND'
                            , i_env_param1  => p.session_file_id
                        );
                    end if;
                else
                    -- get data and process data
                    process_data_f79(
                        i_tc_buffer         => l_tc_buffer(1)
                        , i_file_name       => l_file_name
                    );
                    l_record_count := l_record_count + 1;
                end if;

                -- cleanup buffer before loading next record(s)
                l_tc_buffer.delete;
            end loop;
        exception
            when com_api_error_pkg.e_application_error then
                rollback to sp_woo_incoming_file;

                l_errors_count := l_errors_count + 1;

                trc_log_pkg.debug(
                    i_text  => 'Error at line=' || l_record_number
                                || ', File_name=' || l_file_name
                );

                prc_api_file_pkg.close_file(
                    i_sess_file_id  => p.session_file_id
                  , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
                );
                raise;
        end;
    end loop;

    if l_file_count = 0 then
        com_api_error_pkg.raise_error (
            i_error        => 'SEC_FILE_NOT_FOUND'
    );
    end if;
    
    prc_api_stat_pkg.log_end(
        i_processed_total   => l_record_count
      , i_excepted_total    => l_errors_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug(
        i_text              => 'cst_woo_prc_incoming_pkg.process_f79 > End.'
    );    
exception
    when others then
        prc_api_stat_pkg.log_end(
            i_result_code   => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );
        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end process_f79;

procedure process_data_f127(
    i_tc_buffer             in com_api_type_pkg.t_text
    , i_file_name           in com_api_type_pkg.t_name
) is
    l_woo_fin_rec           cst_woo_api_type_pkg.t_mes_rec_127;

begin
    trc_log_pkg.debug(
        i_text  => 'cst_woo_prc_incoming_pkg.process_data_f127 > Start'
    );

-- parse data from buffer
    l_woo_fin_rec.seq_id            := cst_woo_com_pkg.get_substr(i_tc_buffer, 1);
    l_woo_fin_rec.job_date          := cst_woo_com_pkg.get_substr(i_tc_buffer, 2);
    l_woo_fin_rec.card_num          := cst_woo_com_pkg.get_substr(i_tc_buffer, 3);
    l_woo_fin_rec.delivery_status   := cst_woo_com_pkg.get_substr(i_tc_buffer, 4);

--insert data into this table after parsed for logging
    insert into cst_woo_import_f127(
        seq_id
      , job_date
      , card_num
      , delivery_status
      , import_date
      , file_name
    ) values (
        l_woo_fin_rec.seq_id
      , l_woo_fin_rec.job_date
      , l_woo_fin_rec.card_num
      , l_woo_fin_rec.delivery_status
      , get_sysdate
      , i_file_name
    );

    update iss_card_instance
       set delivery_status = decode( l_woo_fin_rec.delivery_status
                                   , '1', cst_woo_const_pkg.DELIVERY_STATUS_ISSUED       --'CRDS5001'
                                   , '2', cst_woo_const_pkg.DELIVERY_STATUS_DELIVERING   --'CRDS5002'
                                   , '3', cst_woo_const_pkg.DELIVERY_STATUS_DELIVERD     --'CRDS5003'
                                   , '4', cst_woo_const_pkg.DELIVERY_STATUS_RETURN       --'CRDS5004'
                                   , '5', cst_woo_const_pkg.DELIVERY_STATUS_DISCARD      --'CRDS5005'
                                   )
    where card_id in (select card_id
                        from iss_card_number
                       where card_number = l_woo_fin_rec.card_num );

    trc_log_pkg.debug(
        i_text  => 'cst_woo_prc_incoming_pkg.process_data_f127 > End'
    );
end process_data_f127;

procedure process_f127(
    i_inst_id               in com_api_type_pkg.t_inst_id default null
)is
    l_tc_buffer             cst_woo_api_type_pkg.t_tc_buffer;
    l_woo_file              cst_woo_api_type_pkg.t_file_rec;
    l_inst_id               com_api_type_pkg.t_inst_id;
    l_record_number         com_api_type_pkg.t_long_id  := 0;
    l_record_count          com_api_type_pkg.t_count    := 0;
    l_errors_count          com_api_type_pkg.t_count    := 0;
    l_file_count            com_api_type_pkg.t_count    := 0;      
    l_header_load           com_api_type_pkg.t_boolean  := com_api_type_pkg.FALSE;
    l_file_name             com_api_type_pkg.t_name     := null; 

begin
    trc_log_pkg.debug(
        i_text => 'cst_woo_prc_incoming_pkg.process_f127 > Start'
    );

    prc_api_stat_pkg.log_start;

    l_inst_id := nvl(i_inst_id, cst_woo_const_pkg.W_INST);

    select count(1)
      into l_record_count
      from prc_file_raw_data a
         , prc_session_file b
     where b.id = (select max(id) keep (dense_rank first order by file_name desc)
                     from prc_session_file
                    where session_id = prc_api_session_pkg.get_session_id)
       and a.record_number > 1
       and a.session_file_id = b.id;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count     => l_record_count
    );

    l_record_count := 0;

    for p in (
        select id as session_file_id
             , record_count
             , file_name
          from prc_session_file
         where id = (select max(id) keep (dense_rank first order by file_name desc)
                       from prc_session_file
                      where session_id = prc_api_session_pkg.get_session_id)
    ) loop
        l_errors_count := 0;
        l_header_load  := com_api_type_pkg.FALSE;
        l_file_count   := l_file_count + 1;
        l_file_name    := p.file_name;

        begin
            savepoint sp_woo_incoming_file;
            trc_log_pkg.debug(
                i_text      => 'Session file_id =' || p.session_file_id
                            || ', file name = ' || l_file_name
            );

            for r in (
                select record_number
                     , raw_data
                     , substr(raw_data, 1, 6) ident
                  from prc_file_raw_data
                 where session_file_id = p.session_file_id
                 order by record_number
            -- processing current file
            ) loop
                l_record_number     := r.record_number;
                l_tc_buffer(1)      := r.raw_data;
                --check header
                if l_header_load = com_api_type_pkg.FALSE then
                    if r.ident = cst_woo_const_pkg.F_HEADER then
                        process_file_header(
                            i_header_data   => l_tc_buffer(1)
                          , i_inst_id       => l_inst_id
                          , i_file_name     => l_file_name
                          , o_woo_file      => l_woo_file
                        );
                        l_header_load := com_api_type_pkg.TRUE;
                    else
                        com_api_error_pkg.raise_error(
                            i_error         => 'HEADER_NOT_FOUND'
                          , i_env_param1    => p.session_file_id
                        );
                    end if;
                else
                    -- get data and process data
                    process_data_f127(
                        i_tc_buffer         => l_tc_buffer(1)
                      , i_file_name         => l_file_name
                    );
                    l_record_count := l_record_count + 1;
                end if;

                -- cleanup buffer before loading next record(s)
                l_tc_buffer.delete;
            end loop;

        exception
            when com_api_error_pkg.e_application_error then
                rollback to sp_woo_incoming_file;

                l_errors_count := l_errors_count + 1;

                trc_log_pkg.debug(
                    i_text  => 'Error at line=' || l_record_number
                                || ', File_name=' || l_file_name
                );
                prc_api_file_pkg.close_file(
                    i_sess_file_id  => p.session_file_id
                  , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
                );
                raise;
        end;
    end loop;

    if l_file_count = 0 then
        com_api_error_pkg.raise_error (
            i_error        => 'SEC_FILE_NOT_FOUND'
    );
    end if;

    prc_api_stat_pkg.log_end(
        i_processed_total   => l_record_count
      , i_excepted_total    => l_errors_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug(
        i_text  => 'cst_woo_prc_incoming_pkg.process_f127 > End.'
    );
exception
    when others then
        prc_api_stat_pkg.log_end(
            i_result_code   => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );
        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end process_f127;

procedure process_data_f128(
    i_tc_buffer             in com_api_type_pkg.t_text
    , i_file_name           in com_api_type_pkg.t_name
) is
    l_woo_fin_rec           cst_woo_api_type_pkg.t_mes_rec_128;

begin
    trc_log_pkg.debug(
        i_text  => 'cst_woo_prc_incoming_pkg.process_data_f128 > Start'
    );

-- parse data from buffer
    l_woo_fin_rec.seq_id            := cst_woo_com_pkg.get_substr(i_tc_buffer, 1);
    l_woo_fin_rec.job_date          := cst_woo_com_pkg.get_substr(i_tc_buffer, 2);
    l_woo_fin_rec.card_num          := cst_woo_com_pkg.get_substr(i_tc_buffer, 3);
    l_woo_fin_rec.delivery_status   := cst_woo_com_pkg.get_substr(i_tc_buffer, 4);
    l_woo_fin_rec.delivery_type     := cst_woo_com_pkg.get_substr(i_tc_buffer, 5);

--insert data into this table after parsed for logging
   insert into cst_woo_import_f128(
        seq_id
      , job_date
      , card_num
      , delivery_status
      , delivery_type
      , import_date
      , file_name
    ) values (
        l_woo_fin_rec.seq_id
      , l_woo_fin_rec.job_date
      , l_woo_fin_rec.card_num
      , l_woo_fin_rec.delivery_status
      , l_woo_fin_rec.delivery_type
      , get_sysdate
      , i_file_name
    );

    update iss_card_instance
       set delivery_status = decode( l_woo_fin_rec.delivery_status
                                   , '1', cst_woo_const_pkg.DELIVERY_STATUS_ISSUED       --'CRDS5001'
                                   , '2', cst_woo_const_pkg.DELIVERY_STATUS_DELIVERING   --'CRDS5002'
                                   , '3', cst_woo_const_pkg.DELIVERY_STATUS_DELIVERD     --'CRDS5003'
                                   , '4', cst_woo_const_pkg.DELIVERY_STATUS_RETURN       --'CRDS5004'
                                   , '5', cst_woo_const_pkg.DELIVERY_STATUS_DISCARD      --'CRDS5005'
                                    )
        , delivery_channel = decode( l_woo_fin_rec.delivery_type
                                   , '1', cst_woo_const_pkg.DELIVERY_CHANNEL_BRANCH      --'CRDC5003'
                                   , '2', cst_woo_const_pkg.DELIVERY_CHANNEL_PARTY       --'CRDC5001'
                                   , '3', cst_woo_const_pkg.DELIVERY_CHANNEL_STAFF       --'CRDC5002'
                                   )
    where card_id in(select card_id
                       from iss_card_number
                      where card_number = l_woo_fin_rec.card_num);

    trc_log_pkg.debug(
        i_text  => 'cst_woo_prc_incoming_pkg.process_data_f128 > End'
    );
end process_data_f128;

procedure process_f128(
    i_inst_id               in com_api_type_pkg.t_inst_id default null
)is
    l_tc_buffer             cst_woo_api_type_pkg.t_tc_buffer;
    l_woo_file              cst_woo_api_type_pkg.t_file_rec;
    l_inst_id               com_api_type_pkg.t_inst_id;
    l_record_number         com_api_type_pkg.t_long_id  := 0;
    l_record_count          com_api_type_pkg.t_count    := 0;
    l_errors_count          com_api_type_pkg.t_count    := 0;
    l_file_count            com_api_type_pkg.t_count    := 0;    
    l_header_load           com_api_type_pkg.t_boolean  := com_api_type_pkg.FALSE;
    l_file_name             com_api_type_pkg.t_name     := null;  

begin
    trc_log_pkg.debug(
        i_text => 'cst_woo_prc_incoming_pkg.process_f128 > Start'
    );

    prc_api_stat_pkg.log_start;

    l_inst_id := nvl(i_inst_id, cst_woo_const_pkg.W_INST);

    select count(1)
      into l_record_count
      from prc_file_raw_data a
         , prc_session_file b
     where b.id = (select max(id) keep (dense_rank first order by file_name desc)
                     from prc_session_file
                    where session_id = prc_api_session_pkg.get_session_id)
       and a.record_number > 1
       and a.session_file_id = b.id;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count   => l_record_count
    );

    l_record_count := 0;

    for p in (
        select id as session_file_id
             , record_count
             , file_name
          from prc_session_file
         where id = (select max(id) keep (dense_rank first order by file_name desc)
                       from prc_session_file
                      where session_id = prc_api_session_pkg.get_session_id)
    ) loop
        l_errors_count := 0;
        l_header_load  := com_api_type_pkg.FALSE;
        l_file_count   := l_file_count + 1;
        l_file_name    := p.file_name;

        begin
            savepoint sp_woo_incoming_file;
            trc_log_pkg.debug(
                i_text      => 'Session file_id =' || p.session_file_id
                            || ', file name = ' || l_file_name
            );

            for r in (
                select record_number
                     , raw_data
                     , substr(raw_data, 1, 6) ident
                  from prc_file_raw_data
                 where session_file_id = p.session_file_id
                 order by record_number
            -- processing current file
            ) loop
                l_record_number     := r.record_number;
                l_tc_buffer(1)      := r.raw_data;
                --check header
                if l_header_load = com_api_type_pkg.FALSE then
                    if r.ident = cst_woo_const_pkg.F_HEADER then
                        process_file_header(
                            i_header_data   => l_tc_buffer(1)
                          , i_inst_id       => l_inst_id
                          , i_file_name     => l_file_name
                          , o_woo_file      => l_woo_file
                        );
                        l_header_load := com_api_type_pkg.TRUE;
                    else
                        com_api_error_pkg.raise_error(
                            i_error         => 'HEADER_NOT_FOUND'
                          , i_env_param1    => p.session_file_id
                        );
                    end if;
                else
                    -- get data and process data
                    process_data_f128(
                        i_tc_buffer         => l_tc_buffer(1)
                        , i_file_name       => l_file_name
                    );
                    l_record_count := l_record_count + 1;
                end if;

                -- cleanup buffer before loading next record(s)
                l_tc_buffer.delete;
            end loop;

        exception
            when com_api_error_pkg.e_application_error then
                rollback to sp_woo_incoming_file;

                l_errors_count := l_errors_count + 1;

                trc_log_pkg.debug(
                    i_text  => 'Error at line='||l_record_number
                             || ', File_name=' || l_file_name
                );

                prc_api_file_pkg.close_file(
                    i_sess_file_id      => p.session_file_id
                  , i_status            => prc_api_const_pkg.FILE_STATUS_REJECTED
                );
                raise;
        end;

    end loop;

    if l_file_count = 0 then
        com_api_error_pkg.raise_error (
            i_error        => 'SEC_FILE_NOT_FOUND'
    );
    end if;

    prc_api_stat_pkg.log_end(
        i_processed_total   => l_record_count
      , i_excepted_total    => l_errors_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug(
        i_text  => 'cst_woo_prc_incoming_pkg.process_f128 > End.'
    );
exception
    when others then
        prc_api_stat_pkg.log_end(
            i_result_code   => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );
        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end process_f128;

procedure process_data_f129(
    i_tc_buffer             in com_api_type_pkg.t_text
    , i_file_name           in com_api_type_pkg.t_name
) is
    l_woo_fin_rec           cst_woo_api_type_pkg.t_mes_rec_129;
    l_params                com_api_type_pkg.t_param_tab;
begin
    trc_log_pkg.debug(
        i_text  => 'cst_woo_prc_incoming_pkg.process_data_f129 > Start'
    );

-- parse data from buffer
    l_woo_fin_rec.seq_id                := cst_woo_com_pkg.get_substr(i_tc_buffer, 1);
    l_woo_fin_rec.overdue_type          := cst_woo_com_pkg.get_substr(i_tc_buffer, 2);
    l_woo_fin_rec.file_date             := cst_woo_com_pkg.get_substr(i_tc_buffer, 3);
    l_woo_fin_rec.bank_code             := cst_woo_com_pkg.get_substr(i_tc_buffer, 4);
    l_woo_fin_rec.crd_run_num           := cst_woo_com_pkg.get_substr(i_tc_buffer, 5);
    l_woo_fin_rec.branch_code           := cst_woo_com_pkg.get_substr(i_tc_buffer, 6);
    l_woo_fin_rec.cif_num               := cst_woo_com_pkg.get_substr(i_tc_buffer, 7);
    l_woo_fin_rec.crd_deli_code         := cst_woo_com_pkg.get_substr(i_tc_buffer, 8);
    l_woo_fin_rec.item_1                := cst_woo_com_pkg.get_substr(i_tc_buffer, 9);
    l_woo_fin_rec.first_deli_date       := cst_woo_com_pkg.get_substr(i_tc_buffer, 10);
    l_woo_fin_rec.deli_start_date       := cst_woo_com_pkg.get_substr(i_tc_buffer, 11);
    l_woo_fin_rec.num_of_deli           := cst_woo_com_pkg.get_substr(i_tc_buffer, 12);
    l_woo_fin_rec.currency_code         := cst_woo_com_pkg.get_substr(i_tc_buffer, 13);
    l_woo_fin_rec.amt_due_princ         := cst_woo_com_pkg.get_substr(i_tc_buffer, 14);
    l_woo_fin_rec.interest_accrued_amt  := cst_woo_com_pkg.get_substr(i_tc_buffer, 15);
    l_woo_fin_rec.amort_amt             := cst_woo_com_pkg.get_substr(i_tc_buffer, 16);
    l_woo_fin_rec.item_2                := cst_woo_com_pkg.get_substr(i_tc_buffer, 17);
    l_woo_fin_rec.deli_month            := cst_woo_com_pkg.get_substr(i_tc_buffer, 18);
    l_woo_fin_rec.days_to_deli          := cst_woo_com_pkg.get_substr(i_tc_buffer, 19);
    l_woo_fin_rec.overdue_interest_rate := cst_woo_com_pkg.get_substr(i_tc_buffer, 20);

--insert data into this table after parsed for logging
    insert into cst_woo_import_f129(
        seq_id
      , overdue_type
      , file_date
      , bank_code
      , crd_run_num
      , branch_code
      , cif_num
      , crd_deli_code
      , item_1
      , first_deli_date
      , deli_start_date
      , num_of_deli
      , currency_code
      , amt_due_princ
      , interest_accrued_amt
      , amort_amt
      , item_2
      , deli_month
      , days_to_deli
      , overdue_interest_rate
      , import_date
      , file_name
    ) values (
        l_woo_fin_rec.seq_id
      , l_woo_fin_rec.overdue_type
      , l_woo_fin_rec.file_date
      , l_woo_fin_rec.bank_code
      , l_woo_fin_rec.crd_run_num
      , l_woo_fin_rec.branch_code
      , l_woo_fin_rec.cif_num
      , l_woo_fin_rec.crd_deli_code
      , l_woo_fin_rec.item_1
      , l_woo_fin_rec.first_deli_date
      , l_woo_fin_rec.deli_start_date
      , l_woo_fin_rec.num_of_deli
      , l_woo_fin_rec.currency_code
      , l_woo_fin_rec.amt_due_princ
      , l_woo_fin_rec.interest_accrued_amt
      , l_woo_fin_rec.amort_amt
      , l_woo_fin_rec.item_2
      , l_woo_fin_rec.deli_month
      , l_woo_fin_rec.days_to_deli
      , l_woo_fin_rec.overdue_interest_rate
      , get_sysdate
      , i_file_name
    );

    if l_woo_fin_rec.amt_due_princ = 0 and l_woo_fin_rec.interest_accrued_amt = 0 then
    --Unblock all Credit accounts that were temporary changed to bank overdue status
        for p in (
                    select aac.id               as account_id
                      from acc_account          aac
                         , prd_customer         pct
                     where aac.customer_id      = pct.id
                       and aac.split_hash       = pct.split_hash
                       and aac.account_type     = acc_api_const_pkg.ACCOUNT_TYPE_CREDIT     --'ACTP0130'
                       and aac.status           = cst_woo_const_pkg.ACCOUNT_STATUS_OVERDUE  --'ACSTBOVD'
                       and pct.customer_number  = l_woo_fin_rec.cif_num
        ) loop
            --Change account status to ACSTACTV
            evt_api_status_pkg.change_status(
                i_event_type   => cst_woo_const_pkg.EVT_TYPE_ACC_OVERDUE_TO_ACTIVE  --'EVNT5012'
              , i_initiator    => evt_api_const_pkg.INITIATOR_SYSTEM                --'ENSISSTM'
              , i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT             --'ENTTACCT'
              , i_object_id    => p.account_id
              , i_reason       => null
              , i_params       => l_params
            );
        end loop;

    else
    --Temporary blocking all Credit accounts in active status
        for p in (
                    select aac.id               as account_id
                      from acc_account          aac
                         , prd_customer         pct
                     where aac.customer_id      = pct.id
                       and aac.split_hash       = pct.split_hash
                       and aac.account_type     = acc_api_const_pkg.ACCOUNT_TYPE_CREDIT     --'ACTP0130'
                       and aac.status           = acc_api_const_pkg.ACCOUNT_STATUS_ACTIVE   --'ACSTACTV'
                       and pct.customer_number  = l_woo_fin_rec.cif_num
        ) loop
            --Change account status to ACSTBOVD (Bank overdue)
            evt_api_status_pkg.change_status(
                i_event_type   => cst_woo_const_pkg.EVT_TYPE_ACC_ACTIVE_TO_OVERDUE  --'EVNT5011'
              , i_initiator    => evt_api_const_pkg.INITIATOR_SYSTEM                --'ENSISSTM'
              , i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT             --'ENTTACCT'
              , i_object_id    => p.account_id
              , i_reason       => null
              , i_params       => l_params
            );
        end loop;
    end if;

    trc_log_pkg.debug(
        i_text              => 'cst_woo_prc_incoming_pkg.process_data_f129 > End'
    );
exception
    when no_data_found then
        trc_log_pkg.debug (
            i_text  =>  'Not found card_instance_id for customer number = '
                        || l_woo_fin_rec.cif_num || ' In procedure process_data_f129'
        );
end process_data_f129;

procedure process_f129(
    i_inst_id               in com_api_type_pkg.t_inst_id default null
)is
    l_tc_buffer             cst_woo_api_type_pkg.t_tc_buffer;
    l_woo_file              cst_woo_api_type_pkg.t_file_rec;
    l_inst_id               com_api_type_pkg.t_inst_id;
    l_record_number         com_api_type_pkg.t_long_id  := 0;
    l_record_count          com_api_type_pkg.t_count    := 0;
    l_errors_count          com_api_type_pkg.t_count    := 0;
    l_file_count            com_api_type_pkg.t_count    := 0;    
    l_header_load           com_api_type_pkg.t_boolean  := com_api_type_pkg.FALSE;
    l_file_name             com_api_type_pkg.t_name     := null;    

begin
    trc_log_pkg.debug(
        i_text => 'cst_woo_prc_incoming_pkg.process_f129 > Start'
    );
    
    prc_api_stat_pkg.log_start;

    l_inst_id := nvl(i_inst_id, cst_woo_const_pkg.W_INST);

    select count(1)
      into l_record_count
      from prc_file_raw_data a
         , prc_session_file b
     where b.id = (select max(id) keep (dense_rank first order by file_name desc)
                     from prc_session_file
                    where session_id = prc_api_session_pkg.get_session_id)
       and a.record_number > 1
       and a.session_file_id = b.id;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count   => l_record_count
    );

    l_record_count := 0;

    for p in (
        select id as session_file_id
             , record_count
             , file_name
          from prc_session_file
         where id = (select max(id) keep (dense_rank first order by file_name desc)
                       from prc_session_file
                      where session_id = prc_api_session_pkg.get_session_id)
    ) loop
        l_errors_count := 0;
        l_header_load  := com_api_type_pkg.FALSE;
        l_file_count   := l_file_count + 1;
        l_file_name    := p.file_name;

        begin
            savepoint sp_woo_incoming_file;
            trc_log_pkg.debug(
                i_text      => 'Session file_id =' || p.session_file_id
                            || ', file name = ' || l_file_name
            );

            for r in (
                select record_number
                     , raw_data
                     , substr(raw_data, 1, 6) ident
                  from prc_file_raw_data
                 where session_file_id = p.session_file_id
                 order by record_number
            -- processing current file
            ) loop
                l_record_number     := r.record_number;
                l_tc_buffer(1)      := r.raw_data;
                --check header
                if l_header_load = com_api_type_pkg.FALSE then
                    if r.ident = cst_woo_const_pkg.F_HEADER then
                        process_file_header(
                            i_header_data   => l_tc_buffer(1)
                          , i_inst_id       => l_inst_id
                          , i_file_name     => l_file_name
                          , o_woo_file      => l_woo_file
                        );
                        l_header_load := com_api_type_pkg.TRUE;
                    else
                        com_api_error_pkg.raise_error(
                            i_error         => 'HEADER_NOT_FOUND'
                            , i_env_param1  => p.session_file_id
                        );
                    end if;
                else
                    -- get data and process data
                    process_data_f129(
                        i_tc_buffer         => l_tc_buffer(1)
                        , i_file_name       => l_file_name
                    );
                    l_record_count := l_record_count + 1;
                end if;

                -- cleanup buffer before loading next record(s)
                l_tc_buffer.delete;
            end loop;

        exception
            when com_api_error_pkg.e_application_error then
                rollback to sp_woo_incoming_file;

                l_errors_count := l_errors_count + 1;

                trc_log_pkg.debug(
                    i_text  => 'Error at line='||l_record_number
                            || ', File_name=' || l_file_name
                );

                prc_api_file_pkg.close_file(
                    i_sess_file_id  => p.session_file_id
                  , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
                );
                raise;
        end;
    end loop;

    if l_file_count = 0 then
        com_api_error_pkg.raise_error (
            i_error        => 'SEC_FILE_NOT_FOUND'
    );
    end if;

    prc_api_stat_pkg.log_end(
        i_processed_total   => l_record_count
      , i_excepted_total    => l_errors_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug(
        i_text  => 'cst_woo_prc_incoming_pkg.process_f129 > End.'
    );
exception
    when others then
        prc_api_stat_pkg.log_end(
            i_result_code   => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );
        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end process_f129;

procedure process_data_f130(
    i_tc_buffer             in com_api_type_pkg.t_text
    , i_file_name           in com_api_type_pkg.t_name
) is
    l_woo_fin_rec           cst_woo_api_type_pkg.t_mes_rec_130;
    l_pool_id               com_api_type_pkg.t_long_id;
    l_index_range_id        com_api_type_pkg.t_short_id;
    l_value                 com_api_type_pkg.t_long_id;
    l_acc_exist_count       com_api_type_pkg.t_short_id;
begin
    trc_log_pkg.debug(
        i_text  => 'cst_woo_prc_incoming_pkg.process_data_f130 start'
    );

-- parse data from buffer
    l_woo_fin_rec.seq_id            := cst_woo_com_pkg.get_substr(i_tc_buffer, 1);
    l_woo_fin_rec.agent_code        := cst_woo_com_pkg.get_substr(i_tc_buffer, 2);
    l_woo_fin_rec.virtual_acc       := cst_woo_com_pkg.get_substr(i_tc_buffer, 3);
    l_woo_fin_rec.created_date      := cst_woo_com_pkg.get_substr(i_tc_buffer, 4);
    l_woo_fin_rec.parent_acc        := cst_woo_com_pkg.get_substr(i_tc_buffer, 5);
    l_woo_fin_rec.virtual_acc_type  := cst_woo_com_pkg.get_substr(i_tc_buffer, 6);

--Check if virtual account already exists
    select count(1)
      into l_acc_exist_count
      from rul_name_index_pool rp
     where rp.value = l_woo_fin_rec.virtual_acc;

    if l_acc_exist_count > 0 then
        trc_log_pkg.debug(
            i_text          => 'Virtual account [#1] already exists >> skipped'
          , i_env_param1    => l_woo_fin_rec.virtual_acc
        );
    else
--insert data into this table after parsed for logging
   insert into cst_woo_import_f130(
        seq_id
      , agent_code
      , virtual_acc
      , created_date
      , parent_acc
      , virtual_acc_type
      , import_date
      , file_name
    ) values (
        l_woo_fin_rec.seq_id
      , l_woo_fin_rec.agent_code
      , l_woo_fin_rec.virtual_acc
      , l_woo_fin_rec.created_date
      , l_woo_fin_rec.parent_acc
      , l_woo_fin_rec.virtual_acc_type
      , get_sysdate
      , i_file_name
    );

    case l_woo_fin_rec.virtual_acc_type
        when '701' then l_index_range_id := cst_woo_const_pkg.VIRT_ACC_RANGE_ID_CREDIT;  -- -50000019
        when '702' then l_index_range_id := cst_woo_const_pkg.VIRT_ACC_RANGE_ID_PREPAID; -- -50000020
        else l_index_range_id := null;
    end case;

    if l_index_range_id is null then
        trc_log_pkg.debug(
            i_text          => 'Missing account type for Virtual account [#1]'
          , i_env_param1    => l_woo_fin_rec.virtual_acc
        );
        com_api_error_pkg.raise_error(
            i_error         => 'ACCOUNT_TYPE_NOT_FOUND'
        );
    end if;

    itf_api_naming_pkg.import_pool_value(
        i_index_range_id   =>  l_index_range_id
      , i_value            =>  l_woo_fin_rec.virtual_acc
    );

    trc_log_pkg.debug(
        i_text              => 'Virtual_acc [#1] is imported'
      , i_env_param1        => l_woo_fin_rec.virtual_acc
    );

    end if;
    
    trc_log_pkg.debug(
        i_text              => 'cst_woo_prc_incoming_pkg.process_data_f130 end'
    );
end process_data_f130;

procedure process_f130(
    i_inst_id               in com_api_type_pkg.t_inst_id default null
)is
    l_tc_buffer             cst_woo_api_type_pkg.t_tc_buffer;
    l_woo_file              cst_woo_api_type_pkg.t_file_rec;
    l_inst_id               com_api_type_pkg.t_inst_id;
    l_record_number         com_api_type_pkg.t_long_id  := 0;
    l_record_count          com_api_type_pkg.t_count    := 0;
    l_errors_count          com_api_type_pkg.t_count    := 0;
    l_file_count            com_api_type_pkg.t_count    := 0;       
    l_header_load           com_api_type_pkg.t_boolean  := com_api_type_pkg.FALSE;
    l_file_name             com_api_type_pkg.t_name     := null; 

begin
    trc_log_pkg.debug(
        i_text => 'cst_woo_prc_incoming_pkg.process_f130 > Start'
    );

    prc_api_stat_pkg.log_start;

    l_inst_id := nvl(i_inst_id, cst_woo_const_pkg.W_INST);

    select count(1)
      into l_record_count
      from prc_file_raw_data a
         , prc_session_file b
     where b.id = (select max(id) keep (dense_rank first order by file_name desc)
                     from prc_session_file
                    where session_id = prc_api_session_pkg.get_session_id)
       and a.record_number > 1
       and a.session_file_id = b.id;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count     => l_record_count
    );

    l_record_count := 0;

    for p in (
        select id as session_file_id
             , record_count
             , file_name
          from prc_session_file
         where id = (select max(id) keep (dense_rank first order by file_name desc)
                       from prc_session_file
                      where session_id = prc_api_session_pkg.get_session_id)
    ) loop
        l_errors_count := 0;
        l_header_load  := com_api_type_pkg.FALSE;
        l_file_count   := l_file_count + 1;
        l_file_name    := p.file_name;

        begin
            savepoint sp_woo_incoming_file;
            trc_log_pkg.debug(
                i_text      => 'Session file_id =' || p.session_file_id
                            || ', file name = ' || l_file_name
            );

            for r in (
                select record_number
                     , raw_data
                     , substr(raw_data, 1, 6) ident
                  from prc_file_raw_data
                 where session_file_id = p.session_file_id
                 order by record_number
            -- processing current file
            ) loop
                l_record_number     := r.record_number;
                l_tc_buffer(1)      := r.raw_data;
                --check header
                if l_header_load = com_api_type_pkg.FALSE then
                    if r.ident = cst_woo_const_pkg.F_HEADER then
                        process_file_header(
                            i_header_data   => l_tc_buffer(1)
                          , i_inst_id       => l_inst_id
                          , i_file_name     => l_file_name
                          , o_woo_file      => l_woo_file
                        );
                        l_header_load       := com_api_type_pkg.TRUE;
                    else
                        com_api_error_pkg.raise_error(
                            i_error         => 'HEADER_NOT_FOUND'
                          , i_env_param1    => p.session_file_id
                        );
                    end if;
                else
                    -- get data and process data
                    process_data_f130(
                        i_tc_buffer         => l_tc_buffer(1)
                      , i_file_name         => l_file_name
                    );
                    l_record_count := l_record_count + 1;
                end if;
                -- cleanup buffer before loading next record(s)
                l_tc_buffer.delete;

            end loop;
        exception
            when com_api_error_pkg.e_application_error then
                rollback to sp_woo_incoming_file;

                l_errors_count := l_errors_count + 1;

                trc_log_pkg.debug(
                    i_text  => 'Error at line='||l_record_number
                            || ', File_name=' || l_file_name
                );

                prc_api_file_pkg.close_file(
                    i_sess_file_id  => p.session_file_id
                  , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
                );
                raise;
        end;

    end loop;

    if l_file_count = 0 then
        com_api_error_pkg.raise_error (
            i_error        => 'SEC_FILE_NOT_FOUND'
    );
    end if;

    prc_api_stat_pkg.log_end(
        i_processed_total   => l_record_count
      , i_excepted_total    => l_errors_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug(
        i_text              => 'cst_woo_prc_incoming_pkg.process_f130 > End.'
    );
exception
    when others then
        prc_api_stat_pkg.log_end(
            i_result_code   => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );
        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end process_f130;

procedure process_data_f136(
    i_tc_buffer             in com_api_type_pkg.t_text
    , i_file_name           in com_api_type_pkg.t_name
    , i_inst_id             in com_api_type_pkg.t_inst_id
) is
    l_woo_fin_rec           cst_woo_api_type_pkg.t_mes_rec_136;
    l_account_id            com_api_type_pkg.t_long_id;
    l_card_id               com_api_type_pkg.t_long_id;
    l_card_instance_id      com_api_type_pkg.t_long_id;
    l_order_id              com_api_type_pkg.t_long_id;
    l_params                com_api_type_pkg.t_param_tab;
begin
    trc_log_pkg.debug(
        i_text              => 'cst_woo_prc_incoming_pkg.process_data_f136 > Start'
    );

-- parse data from buffer
    l_woo_fin_rec.seq_id            := cst_woo_com_pkg.get_substr(i_tc_buffer, 1);
    l_woo_fin_rec.file_date         := cst_woo_com_pkg.get_substr(i_tc_buffer, 2);
    l_woo_fin_rec.cif_num           := cst_woo_com_pkg.get_substr(i_tc_buffer, 3);
    l_woo_fin_rec.branch_code       := cst_woo_com_pkg.get_substr(i_tc_buffer, 4);
    l_woo_fin_rec.wdr_bank_code     := cst_woo_com_pkg.get_substr(i_tc_buffer, 5);
    l_woo_fin_rec.wdr_acct_num      := cst_woo_com_pkg.get_substr(i_tc_buffer, 6);
    l_woo_fin_rec.dep_bank_code     := cst_woo_com_pkg.get_substr(i_tc_buffer, 7);
    l_woo_fin_rec.dep_acct_num      := cst_woo_com_pkg.get_substr(i_tc_buffer, 8);
    l_woo_fin_rec.dep_curr_code     := cst_woo_com_pkg.get_substr(i_tc_buffer, 9);
    l_woo_fin_rec.dep_amount        := cst_woo_com_pkg.get_substr(i_tc_buffer, 10);
    l_woo_fin_rec.brief_content     := cst_woo_com_pkg.get_substr(i_tc_buffer, 11);
    l_woo_fin_rec.work_type         := cst_woo_com_pkg.get_substr(i_tc_buffer, 12);
    l_woo_fin_rec.err_code          := cst_woo_com_pkg.get_substr(i_tc_buffer, 13);
    l_woo_fin_rec.sv_crd_acct       := cst_woo_com_pkg.get_substr(i_tc_buffer, 14);

--insert data into this table after parsed for logging
    insert into cst_woo_import_f136(
        seq_id
      , file_date
      , cif_num
      , branch_code
      , wdr_bank_code
      , wdr_acct_num
      , dep_bank_code
      , dep_acct_num
      , dep_curr_code
      , dep_amount
      , brief_content
      , work_type
      , err_code
      , sv_crd_acct
      , import_date
      , file_name
    ) values (
        l_woo_fin_rec.seq_id
      , l_woo_fin_rec.file_date
      , l_woo_fin_rec.cif_num
      , l_woo_fin_rec.branch_code
      , l_woo_fin_rec.wdr_bank_code
      , l_woo_fin_rec.wdr_acct_num
      , l_woo_fin_rec.dep_bank_code
      , l_woo_fin_rec.dep_acct_num
      , l_woo_fin_rec.dep_curr_code
      , l_woo_fin_rec.dep_amount
      , l_woo_fin_rec.brief_content
      , l_woo_fin_rec.work_type
      , l_woo_fin_rec.err_code
      , l_woo_fin_rec.sv_crd_acct
      , get_sysdate
      , i_file_name
    );

    select a.id
         , c.id
         , i.id
      into l_account_id
         , l_card_id
         , l_card_instance_id
      from acc_account        a
         , acc_account_object o
         , iss_card           c
         , iss_card_instance  i
     where 1                = 1
       and a.id             = o.account_id
       and c.id             = o.object_id
       and c.id             = i.card_id
       and o.entity_type    = 'ENTTCARD'
       and a.account_number = l_woo_fin_rec.sv_crd_acct --Prepaid account number
       ;

    if l_woo_fin_rec.err_code = '00000000' then  -- Mean no error

    --For successful cases debit prepaid account and permanently close prepaid account

        --Close card:
        app_api_service_pkg.close_service(
            i_entity_type   => iss_api_const_pkg.ENTITY_TYPE_CARD
          , i_object_id     => l_card_id
          , i_inst_id       => i_inst_id
        );

        trc_log_pkg.debug(
            i_text  => 'l_card_id = ' || l_card_id || ' close_service successful'
        );

        evt_api_status_pkg.change_status (
            i_event_type    => cst_woo_const_pkg.EVENT_TYPE_CARD_PERM_BLOCK
          , i_initiator     => evt_api_const_pkg.INITIATOR_SYSTEM
          , i_entity_type   => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
          , i_object_id     => l_card_instance_id
          , i_reason        => iss_api_const_pkg.CARD_STATUS_REASON_PC_REGUL
          , i_params        => l_params
        );

        trc_log_pkg.debug(
            i_text  => 'l_card_instance_id = ' || l_card_instance_id || ' is closed successfully'
        );

       for balance in (
            select b.id
                 , b.balance
                 , b.balance_type
                 , b.currency
              from acc_balance b
             where b.account_id = l_account_id
               and b.status = acc_api_const_pkg.BALANCE_STATUS_ACTIVE
            ) loop
                if balance.balance <> 0 then
                    update acc_balance
                       set balance = 0
                     where id = balance.id
                       and balance_type = balance.balance_type
                       and currency = balance.currency
                       ;
                    trc_log_pkg.debug(
                        i_text  => 'updated balance to 0 in acc_balance, id = ' || balance.id
                                || ' balance=' || balance.balance
                                || ' balance_type=' || balance.balance_type
                                || ' currency=' || balance.currency
                    );
                end if;
            end loop;

        --Close account:
        app_api_service_pkg.close_service(
            i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id     => l_account_id
          , i_inst_id       => i_inst_id
        );

        trc_log_pkg.debug(
            i_text  => 'account_id = ' || l_account_id || ' close_service successful'
        );

        acc_api_account_pkg.close_account(
            i_account_id    => l_account_id
        );

        trc_log_pkg.debug(
            i_text  => 'account_id = ' || l_account_id || ' is closed successfully'
        );

    else -- When CBS response error, change card and account to active status
        trc_log_pkg.debug(
            i_text  => 'Error code from CBS = ' || l_woo_fin_rec.err_code || ' > Card and account will be activated again!'
        );

        --For card:
        iss_api_card_pkg.activate_card(
            i_card_instance_id  => l_card_instance_id
            , i_initial_status  => null
            , i_status          => null
        );
        trc_log_pkg.debug(
            i_text  => 'l_card_instance_id = ' || l_card_instance_id || ' is activated successfully'
        );

        --For account:
        acc_api_account_pkg.set_account_status(
            i_account_id   => l_account_id
          , i_status       => acc_api_const_pkg.ACCOUNT_STATUS_ACTIVE  -- 'ACSTACTV'
        );
        trc_log_pkg.debug(
            i_text  => 'l_account_id = ' || l_account_id || ' is changed to status active.'
        );

    end if;

    l_order_id := substr(l_woo_fin_rec.brief_content, instr(l_woo_fin_rec.brief_content, ':') + 1, 16);

    --update payment order response date param value
    update pmo_order_data
       set param_value  = to_char(sysdate, 'yyyy-mm-dd hh24:mi:ss')
     where param_id     = (select id from pmo_parameter where param_name = 'CBS_RESPONSE_DATE')
       and order_id     = l_order_id
       ;

    trc_log_pkg.debug(
        i_text  => 'cst_woo_prc_incoming_pkg.process_data_f136 > End'
    );
end process_data_f136;

procedure process_f136(
    i_inst_id               in com_api_type_pkg.t_inst_id default null
)is
    l_tc_buffer             cst_woo_api_type_pkg.t_tc_buffer;
    l_woo_file              cst_woo_api_type_pkg.t_file_rec;
    l_inst_id               com_api_type_pkg.t_inst_id;
    l_record_number         com_api_type_pkg.t_long_id  := 0;
    l_record_count          com_api_type_pkg.t_count    := 0;
    l_errors_count          com_api_type_pkg.t_count    := 0;
    l_file_count            com_api_type_pkg.t_count    := 0;    
    l_header_load           com_api_type_pkg.t_boolean  := com_api_type_pkg.FALSE;
    l_file_name             com_api_type_pkg.t_name     := null; 

begin
    trc_log_pkg.debug(
        i_text => 'cst_woo_prc_incoming_pkg.process_f136 > Start'
    );
    
    prc_api_stat_pkg.log_start;

    l_inst_id := nvl(i_inst_id, cst_woo_const_pkg.W_INST);
    
    select count(1)
      into l_record_count
      from prc_file_raw_data a
         , prc_session_file b
     where b.id = (select max(id) keep (dense_rank first order by file_name desc)
                     from prc_session_file
                    where session_id = prc_api_session_pkg.get_session_id)
       and a.record_number > 1
       and a.session_file_id = b.id;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count   => l_record_count
    );

    l_record_count := 0;

    for p in (
        select id as session_file_id
             , record_count
             , file_name
          from prc_session_file
         where id = (select max(id) keep (dense_rank first order by file_name desc)
                       from prc_session_file
                      where session_id = prc_api_session_pkg.get_session_id)
    ) loop
        l_errors_count := 0;
        l_header_load  := com_api_type_pkg.FALSE;
        l_file_count   := l_file_count + 1;
        l_file_name    := p.file_name;

        begin
            savepoint sp_woo_incoming_file;
            trc_log_pkg.debug(
                i_text      => 'Session file_id =' || p.session_file_id
                            || ', file name = ' || l_file_name
            );

            for r in (
                select record_number
                     , raw_data
                     , substr(raw_data, 1, 6) ident
                  from prc_file_raw_data
                 where session_file_id = p.session_file_id
                 order by record_number
            -- processing current file
            ) loop
                l_record_number     := r.record_number;
                l_tc_buffer(1)      := r.raw_data;
                --check header
                if l_header_load = com_api_type_pkg.FALSE then
                    if r.ident = cst_woo_const_pkg.F_HEADER then
                        process_file_header(
                            i_header_data   => l_tc_buffer(1)
                          , i_inst_id       => l_inst_id
                          , i_file_name     => l_file_name
                          , o_woo_file      => l_woo_file
                        );
                        l_header_load := com_api_type_pkg.TRUE;
                    else
                        com_api_error_pkg.raise_error(
                            i_error         => 'HEADER_NOT_FOUND'
                          , i_env_param1    => p.session_file_id
                        );
                    end if;
                else
                    -- get data and process data
                    process_data_f136(
                        i_tc_buffer         => l_tc_buffer(1)
                      , i_file_name         => l_file_name
                      , i_inst_id           => l_inst_id
                    );
                    l_record_count := l_record_count + 1;
                end if;
                -- cleanup buffer before loading next record(s)
                l_tc_buffer.delete;
            end loop;
        exception
            when com_api_error_pkg.e_application_error then
                rollback to sp_woo_incoming_file;

                l_errors_count  := l_errors_count + 1;

                trc_log_pkg.debug(
                    i_text      => 'Error at line='||l_record_number
                                   || ', File_name=' || l_file_name
                );

                prc_api_file_pkg.close_file(
                    i_sess_file_id  => p.session_file_id
                  , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
                );
                raise;
        end;
    end loop;

    if l_file_count = 0 then
        com_api_error_pkg.raise_error (
            i_error        => 'SEC_FILE_NOT_FOUND'
    );
    end if;

    prc_api_stat_pkg.log_end(
        i_processed_total   => l_record_count
      , i_excepted_total    => l_errors_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug(
        i_text  => 'cst_woo_prc_incoming_pkg.process_f136 > End.'
    );
exception
    when others then
        prc_api_stat_pkg.log_end(
            i_result_code   => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );
        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end process_f136;

procedure process_data_f138(
    i_tc_buffer             in com_api_type_pkg.t_text
    , i_file_name           in com_api_type_pkg.t_name
) is
    l_woo_fin_rec           cst_woo_api_type_pkg.t_mes_rec_138;
    l_oper_id               com_api_type_pkg.t_long_id;
    l_oper_status           com_api_type_pkg.t_dict_value;
begin
    trc_log_pkg.debug(
        i_text              => 'cst_woo_prc_incoming_pkg.process_data_f138 > Start'
    );

-- parse data from buffer
    l_woo_fin_rec.seq_id            := cst_woo_com_pkg.get_substr(i_tc_buffer, 1);
    l_woo_fin_rec.file_date         := cst_woo_com_pkg.get_substr(i_tc_buffer, 2);
    l_woo_fin_rec.cif_num           := cst_woo_com_pkg.get_substr(i_tc_buffer, 3);
    l_woo_fin_rec.branch_code       := cst_woo_com_pkg.get_substr(i_tc_buffer, 4);
    l_woo_fin_rec.wdr_bank_code     := cst_woo_com_pkg.get_substr(i_tc_buffer, 5);
    l_woo_fin_rec.wdr_acct_num      := cst_woo_com_pkg.get_substr(i_tc_buffer, 6);
    l_woo_fin_rec.dep_bank_code     := cst_woo_com_pkg.get_substr(i_tc_buffer, 7);
    l_woo_fin_rec.dep_acct_num      := cst_woo_com_pkg.get_substr(i_tc_buffer, 8);
    l_woo_fin_rec.dep_curr_code     := cst_woo_com_pkg.get_substr(i_tc_buffer, 9);
    l_woo_fin_rec.dep_amount        := cst_woo_com_pkg.get_substr(i_tc_buffer, 10);
    l_woo_fin_rec.brief_content     := cst_woo_com_pkg.get_substr(i_tc_buffer, 11);
    l_woo_fin_rec.work_type         := cst_woo_com_pkg.get_substr(i_tc_buffer, 12);
    l_woo_fin_rec.err_code          := cst_woo_com_pkg.get_substr(i_tc_buffer, 13);
    l_woo_fin_rec.sv_crd_acct       := cst_woo_com_pkg.get_substr(i_tc_buffer, 14);

--insert data into this table after parsed for logging
    insert into cst_woo_import_f138(
        seq_id
      , file_date
      , cif_num
      , branch_code
      , wdr_bank_code
      , wdr_acct_num
      , dep_bank_code
      , dep_acct_num
      , dep_curr_code
      , dep_amount
      , brief_content
      , work_type
      , err_code
      , sv_crd_acct
      , import_date
      , file_name
    ) values (
        l_woo_fin_rec.seq_id
      , l_woo_fin_rec.file_date
      , l_woo_fin_rec.cif_num
      , l_woo_fin_rec.branch_code
      , l_woo_fin_rec.wdr_bank_code
      , l_woo_fin_rec.wdr_acct_num
      , l_woo_fin_rec.dep_bank_code
      , l_woo_fin_rec.dep_acct_num
      , l_woo_fin_rec.dep_curr_code
      , l_woo_fin_rec.dep_amount
      , l_woo_fin_rec.brief_content
      , l_woo_fin_rec.work_type
      , l_woo_fin_rec.err_code
      , l_woo_fin_rec.sv_crd_acct
      , get_sysdate
      , i_file_name
    );

    --Only process the operation that received successful response from CBS
    if l_woo_fin_rec.err_code = '00000000' then

        l_oper_id := to_number(substr(l_woo_fin_rec.brief_content, instr(l_woo_fin_rec.brief_content, ':') + 1, 16));

        update opr_operation
           set status    = opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY --'OPST0100'
             , host_date = sysdate
         where id = l_oper_id;

        opr_api_process_pkg.process_operation(
            i_operation_id => l_oper_id
        );

        select status
          into l_oper_status
          from opr_operation
         where id = l_oper_id;

        trc_log_pkg.debug(
            i_text       => 'Operation ID [#1], status after processed: [#2]'
          , i_env_param1 => l_oper_id
          , i_env_param2 => l_oper_status
        );

    end if;

    trc_log_pkg.debug(
        i_text  => 'cst_woo_prc_incoming_pkg.process_data_f138 > End'
    );
end process_data_f138;

procedure process_f138(
    i_inst_id               in com_api_type_pkg.t_inst_id default null
)is
    l_tc_buffer             cst_woo_api_type_pkg.t_tc_buffer;
    l_woo_file              cst_woo_api_type_pkg.t_file_rec;
    l_inst_id               com_api_type_pkg.t_inst_id;
    l_record_number         com_api_type_pkg.t_long_id := 0;
    l_record_count          com_api_type_pkg.t_count    := 0;
    l_errors_count          com_api_type_pkg.t_count    := 0;
    l_file_count            com_api_type_pkg.t_count    := 0;        
    l_header_load           com_api_type_pkg.t_boolean  := com_api_type_pkg.FALSE;
    l_file_name             com_api_type_pkg.t_name     := null;

begin
    trc_log_pkg.debug(
        i_text => 'cst_woo_prc_incoming_pkg.process_f79 > Start'
    );
    
    prc_api_stat_pkg.log_start;

    l_inst_id := nvl(i_inst_id, cst_woo_const_pkg.W_INST);

    select count(1)
      into l_record_count
      from prc_file_raw_data a
         , prc_session_file b
     where b.id = (select max(id) keep (dense_rank first order by file_name desc)
                     from prc_session_file
                    where session_id = prc_api_session_pkg.get_session_id)
       and a.record_number > 1
       and a.session_file_id = b.id;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count   => l_record_count
    );

    l_record_count := 0;

    for p in (
        select id as session_file_id
             , record_count
             , file_name
          from prc_session_file
         where id = (select max(id) keep (dense_rank first order by file_name desc)
                       from prc_session_file
                      where session_id = prc_api_session_pkg.get_session_id)
    ) loop
        l_errors_count := 0;
        l_header_load  := com_api_type_pkg.FALSE;
        l_file_count   := l_file_count + 1;
        l_file_name    := p.file_name;

        begin
            savepoint sp_woo_incoming_file;
            trc_log_pkg.debug(
                i_text      => 'Session file_id =' || p.session_file_id
                            || ', file name = ' || l_file_name
            );

            for r in (
                select record_number
                     , raw_data
                     , substr(raw_data, 1, 6) ident
                  from prc_file_raw_data
                 where session_file_id = p.session_file_id
                 order by record_number
            -- processing current file
            ) loop
                l_record_number     := r.record_number;
                l_tc_buffer(1)      := r.raw_data;
                --check header
                if l_header_load = com_api_type_pkg.FALSE then
                    if r.ident = cst_woo_const_pkg.F_HEADER then
                        process_file_header(
                            i_header_data   => l_tc_buffer(1)
                          , i_inst_id       => l_inst_id
                          , i_file_name     => l_file_name
                          , o_woo_file      => l_woo_file
                        );
                        l_header_load := com_api_type_pkg.TRUE;
                    else
                        com_api_error_pkg.raise_error(
                            i_error         => 'HEADER_NOT_FOUND'
                          , i_env_param1    => p.session_file_id
                        );
                    end if;
                else
                    -- get data and process data
                    process_data_f138(
                        i_tc_buffer         => l_tc_buffer(1)
                      , i_file_name         => l_file_name
                    );
                    l_record_count := l_record_count + 1;
                end if;
                -- cleanup buffer before loading next record(s)
                l_tc_buffer.delete;
            end loop;
        exception
            when com_api_error_pkg.e_application_error then
                rollback to sp_woo_incoming_file;

                l_errors_count  := l_errors_count + 1;

                trc_log_pkg.debug(
                    i_text      => 'Error at line='||l_record_number
                                   || ', File_name=' || l_file_name
                );

                prc_api_file_pkg.close_file(
                    i_sess_file_id  => p.session_file_id
                  , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
                );
                raise;
        end;
    end loop;

    if l_file_count = 0 then
        com_api_error_pkg.raise_error (
            i_error        => 'SEC_FILE_NOT_FOUND'
        );
    end if;
    
    if l_file_name is not null then
    --Reconcile offline fees transaction
    cst_woo_com_pkg.reconcile_offline_fees(l_file_name);
    end if;

    prc_api_stat_pkg.log_end(
        i_processed_total   => l_record_count
      , i_excepted_total    => l_errors_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug(
        i_text  => 'cst_woo_prc_incoming_pkg.process_f138 > End.'
    );
exception
    when others then
        prc_api_stat_pkg.log_end(
            i_result_code   => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );
        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end process_f138;

procedure process_data_f140(
    i_tc_buffer             in  com_api_type_pkg.t_text
  , i_file_name             in  com_api_type_pkg.t_name
  , i_inst_id               in  com_api_type_pkg.t_inst_id
  , i_sttl_date             in  date
  , i_fraud_control         in  com_api_type_pkg.t_boolean
  , io_oper_list            in out cst_woo_api_type_pkg.t_oper_list
  , o_successful_count      out com_api_type_pkg.t_long_id
  , o_rejected_count        out com_api_type_pkg.t_long_id
  , o_error_count           out com_api_type_pkg.t_long_id
) is
    l_woo_rec               cst_woo_import_f140%rowtype;
    l_oper                  opr_prc_import_pkg.t_oper_clearing_rec;
    l_resp_code             com_api_type_pkg.t_dict_value;
    l_event_params          com_api_type_pkg.t_param_tab;
    l_split_hash_tab        com_api_type_pkg.t_tiny_tab;
    l_inst_id_tab           com_api_type_pkg.t_inst_id_tab;
    l_auth_data_rec         aut_api_type_pkg.t_auth_rec;
    l_auth_tag_tab          aut_api_type_pkg.t_auth_tag_tab;
begin
    o_successful_count := 0;
    o_rejected_count   := 0;
    o_error_count      := 0;

    -- parse data from buffer
    l_woo_rec.seq_id            := cst_woo_com_pkg.get_substr(i_tc_buffer, 1);
    l_woo_rec.debit_oper_id     := null;
    l_woo_rec.credit_oper_id    := null;
    l_woo_rec.bank_code         := cst_woo_com_pkg.get_substr(i_tc_buffer, 2);
    l_woo_rec.branch_code       := cst_woo_com_pkg.get_substr(i_tc_buffer, 3);
    l_woo_rec.transaction_date  := cst_woo_com_pkg.get_substr(i_tc_buffer, 4);
    l_woo_rec.debit_gl_account  := l_woo_rec.branch_code || cst_woo_com_pkg.get_substr(i_tc_buffer, 5);
    l_woo_rec.debit_amount      := to_number(cst_woo_com_pkg.get_substr(i_tc_buffer, 6));
    l_woo_rec.credit_gl_account := l_woo_rec.branch_code || cst_woo_com_pkg.get_substr(i_tc_buffer, 7);
    l_woo_rec.credit_amount     := to_number(cst_woo_com_pkg.get_substr(i_tc_buffer, 8));
    l_woo_rec.import_date       := get_sysdate;
    l_woo_rec.file_name         := i_file_name;

    -- Debit operation:
    if  l_woo_rec.debit_gl_account is not null
    and l_woo_rec.debit_amount > 0
    then
        l_oper.oper_date                := to_date(l_woo_rec.transaction_date, cst_woo_const_pkg.WOORI_DATE_FORMAT);
        l_oper.originator_refnum        := null;
        l_oper.issuer_account_number    := l_woo_rec.debit_gl_account;
        l_oper.oper_amount_value        := l_woo_rec.debit_amount;
        l_oper.issuer_card_number       := null;
        l_oper.oper_amount_currency     := cst_woo_const_pkg.VNDONG;
        l_oper.oper_type                := cst_woo_const_pkg.OPERATION_GL_DEBIT_ADJUSTMENT; -- OPTP7033
        l_oper.msg_type                 := opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT; -- MSGTPRES
        l_oper.sttl_type                := opr_api_const_pkg.SETTLEMENT_INTERNAL; -- STTT0000
        l_oper.status                   := cst_woo_const_pkg.OPERATION_STATUS_WAITING_BATCH; -- OPST5004
        l_oper.status_reason            := null;
        l_oper.oper_reason              := cst_woo_const_pkg.ADJUSTMENT_MISC_DR; -- ACAR0005
        l_oper.issuer_client_id_type    := opr_api_const_pkg.CLIENT_ID_TYPE_ACCOUNT;  -- CITPACCT
        l_oper.issuer_client_id_value   := l_woo_rec.debit_gl_account;
        l_oper.issuer_inst_id           := i_inst_id;
        l_oper.issuer_network_id        := null;
        l_oper.issuer_exists            := com_api_type_pkg.TRUE;
        l_oper.acquirer_inst_id         := null;
        l_oper.acquirer_network_id      := null;
        l_oper.acquirer_exists          := com_api_type_pkg.FALSE;
        l_oper.destination_exists       := com_api_type_pkg.FALSE;
        l_oper.aggregator_exists        := com_api_type_pkg.FALSE;
        l_oper.service_provider_exists  := com_api_type_pkg.FALSE;
        l_oper.is_reversal              := com_api_type_pkg.FALSE;

        l_resp_code :=
            opr_prc_import_pkg.register_operation(
                io_oper             => l_oper
              , io_auth_data_rec    => l_auth_data_rec
              , io_auth_tag_tab     => l_auth_tag_tab
              , i_import_clear_pan  => com_api_type_pkg.TRUE
              , i_oper_status       => l_oper.status
              , i_sttl_date         => i_sttl_date
              , i_fraud_control     => i_fraud_control
              , io_split_hash_tab   => l_split_hash_tab
              , io_inst_id_tab      => l_inst_id_tab
              , i_use_auth_data_rec => com_api_const_pkg.FALSE
              , io_event_params     => l_event_params
            );

        if l_resp_code = aup_api_const_pkg.RESP_CODE_OK then
            o_successful_count := o_successful_count + 1;
        else
            if l_resp_code = aup_api_const_pkg.RESP_CODE_OPERATION_DUPLICATED then
                o_rejected_count := o_rejected_count + 1;
            else
                o_error_count := o_error_count + 1;
            end if;
        end if;

        opr_prc_import_pkg.register_events(
            io_oper            => l_oper
          , i_resp_code        => l_resp_code
          , io_split_hash_tab  => l_split_hash_tab
          , io_inst_id_tab     => l_inst_id_tab
          , io_event_params   => l_event_params
        );

        l_woo_rec.debit_oper_id := l_oper.oper_id;

        -- save operation ID for processing
        io_oper_list.extend;
        io_oper_list(io_oper_list.last).oper_id := l_oper.oper_id;
    end if;

    -- Credit operation:
    if  l_woo_rec.credit_gl_account is not null
    and l_woo_rec.credit_amount > 0
    then
        l_oper                          := null;
        l_oper.oper_date                := to_date(l_woo_rec.transaction_date, cst_woo_const_pkg.WOORI_DATE_FORMAT);
        l_oper.originator_refnum        := null;
        l_oper.issuer_account_number    := l_woo_rec.credit_gl_account;
        l_oper.oper_amount_value        := l_woo_rec.credit_amount;
        l_oper.issuer_card_number       := null;
        l_oper.oper_amount_currency     := cst_woo_const_pkg.VNDONG;
        l_oper.oper_type                := cst_woo_const_pkg.OPERATION_GL_CREDIT_ADJUSTMENT; -- OPTP7033
        l_oper.msg_type                 := opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT; -- MSGTPRES
        l_oper.sttl_type                := opr_api_const_pkg.SETTLEMENT_INTERNAL; -- STTT0000
        l_oper.status                   := cst_woo_const_pkg.OPERATION_STATUS_WAITING_BATCH; -- OPST5004
        l_oper.status_reason            := null;
        l_oper.oper_reason              := cst_woo_const_pkg.ADJUSTMENT_MISC_CR; -- ACAR0006
        l_oper.issuer_client_id_type    := opr_api_const_pkg.CLIENT_ID_TYPE_ACCOUNT;  -- CITPACCT
        l_oper.issuer_client_id_value   := l_woo_rec.debit_gl_account;
        l_oper.issuer_inst_id           := i_inst_id;
        l_oper.issuer_network_id        := null;
        l_oper.issuer_exists            := com_api_type_pkg.TRUE;
        l_oper.acquirer_inst_id         := null;
        l_oper.acquirer_network_id      := null;
        l_oper.acquirer_exists          := com_api_type_pkg.FALSE;
        l_oper.destination_exists       := com_api_type_pkg.FALSE;
        l_oper.aggregator_exists        := com_api_type_pkg.FALSE;
        l_oper.service_provider_exists  := com_api_type_pkg.FALSE;
        l_oper.is_reversal              := com_api_type_pkg.FALSE;

        l_resp_code :=
            opr_prc_import_pkg.register_operation(
                io_oper             => l_oper
              , io_auth_data_rec    => l_auth_data_rec
              , io_auth_tag_tab     => l_auth_tag_tab
              , i_import_clear_pan  => com_api_type_pkg.TRUE
              , i_oper_status       => l_oper.status
              , i_sttl_date         => i_sttl_date
              , i_fraud_control     => i_fraud_control
              , io_split_hash_tab   => l_split_hash_tab
              , io_inst_id_tab      => l_inst_id_tab
              , i_use_auth_data_rec => com_api_const_pkg.FALSE
              , io_event_params     => l_event_params
            );

        if l_resp_code = aup_api_const_pkg.RESP_CODE_OK then
            o_successful_count := o_successful_count + 1;
        else
            if l_resp_code = aup_api_const_pkg.RESP_CODE_OPERATION_DUPLICATED then
                o_rejected_count := o_rejected_count + 1;
            else
                o_error_count := o_error_count + 1;
            end if;
        end if;

        opr_prc_import_pkg.register_events(
            io_oper           => l_oper
          , i_resp_code       => l_resp_code
          , io_split_hash_tab => l_split_hash_tab
          , io_inst_id_tab    => l_inst_id_tab
          , io_event_params   => l_event_params
        );

        l_woo_rec.credit_oper_id := l_oper.oper_id;

        -- save operation ID for processing
        io_oper_list.extend;
        io_oper_list(io_oper_list.last).oper_id := l_oper.oper_id;
    end if;

    -- Insert data after processing for logging
    insert into cst_woo_import_f140
    values l_woo_rec;

end process_data_f140;

procedure process_f140(
    i_inst_id         in com_api_type_pkg.t_inst_id default null
) is
    PROC_STAGE_HEADER       constant com_api_type_pkg.t_tiny_id := 0;
    PROC_STAGE_PREPARE_OPER constant com_api_type_pkg.t_tiny_id := 1;
    PROC_STAGE_PROCESS_OPER constant com_api_type_pkg.t_tiny_id := 2;
    l_tc_buffer             cst_woo_api_type_pkg.t_tc_buffer;
    l_woo_file              cst_woo_api_type_pkg.t_file_rec;
    l_inst_id               com_api_type_pkg.t_inst_id;
    l_record_number         com_api_type_pkg.t_count := 0;
    l_record_count          com_api_type_pkg.t_count := 0;
    l_record_count_expected com_api_type_pkg.t_count := 0;
    l_errors_count          com_api_type_pkg.t_count := 0;
    l_file_count            com_api_type_pkg.t_count := 0;      
    l_successful_oper_count com_api_type_pkg.t_long_id;
    l_rejected_oper_count   com_api_type_pkg.t_long_id;
    l_error_oper_count      com_api_type_pkg.t_long_id;
    l_header_load           com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE;
    l_file_name             com_api_type_pkg.t_name := null;
    l_sttl_date             date;
    l_fraud_control         com_api_type_pkg.t_boolean;
    l_multi_institution     com_api_type_pkg.t_boolean;
    l_common_sttl_day       com_api_type_pkg.t_boolean;
    l_processing_stage      com_api_type_pkg.t_tiny_id := PROC_STAGE_HEADER;
    l_oper_list             cst_woo_api_type_pkg.t_oper_list := cst_woo_api_type_pkg.t_oper_list();
  
begin
    trc_log_pkg.debug(
        i_text => 'cst_woo_prc_incoming_pkg.process_f140 > Start'
    );
    
    prc_api_stat_pkg.log_start;

    l_inst_id := nvl(i_inst_id, cst_woo_const_pkg.W_INST);

    select count(1)
      into l_record_count
      from prc_file_raw_data a
         , prc_session_file b
     where b.id = (select max(id) keep (dense_rank first order by file_name desc)
                     from prc_session_file
                    where session_id = prc_api_session_pkg.get_session_id)
       and a.record_number > 1
       and a.session_file_id = b.id;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count   => l_record_count
    );

    l_record_count := 0;

    for p in (
        select id as session_file_id
             , record_count
             , file_name
          from prc_session_file
         where id = (select max(id) keep (dense_rank first order by file_name desc)
                       from prc_session_file
                      where session_id = prc_api_session_pkg.get_session_id)
    ) loop
        l_errors_count := 0;
        l_header_load  := com_api_type_pkg.FALSE;
        l_file_count   := l_file_count + 1;
        l_file_name    := p.file_name;

        begin
            savepoint sp_woo_incoming_file;
            trc_log_pkg.debug(
                i_text      => 'Session file_id = ' || p.session_file_id
                            || ', file name = ' || l_file_name
            );

            -- get sttl_date for operations
            l_multi_institution := set_ui_value_pkg.get_system_param_n('MULTI_INSTITUTION');
            l_common_sttl_day   := set_ui_value_pkg.get_system_param_n('COMMON_SETTLEMENT_DAY');

            if  l_multi_institution = com_api_type_pkg.FALSE
            and l_common_sttl_day = com_api_type_pkg.TRUE
            then
                l_sttl_date := com_api_sttl_day_pkg.get_open_sttl_date(ost_api_const_pkg.DEFAULT_INST);
            else
                l_sttl_date := com_api_sttl_day_pkg.get_open_sttl_date(i_inst_id);
            end if;

            trc_log_pkg.debug(
                i_text  => 'l_sttl_date = ' || to_char(l_sttl_date, cst_woo_const_pkg.WOORI_DATE_FORMAT)
            );

            -- check if needed fraud control
            select decode(count(1), 0, 1)
              into l_fraud_control
              from opr_proc_stage
             where command is not null;

            trc_log_pkg.debug(
                i_text      => 'l_fraud_control = [' || l_fraud_control || ']'
            );

            select count(*) - 1
              into l_record_count_expected
              from prc_file_raw_data
             where session_file_id = p.session_file_id;

            for r in (
                select record_number
                     , raw_data
                     , substr(raw_data, 1, 6) ident
                  from prc_file_raw_data
                 where session_file_id = p.session_file_id
                 order by record_number
            -- processing of current file
            ) loop
                l_record_number                    := r.record_number;
                l_tc_buffer(1)    := r.raw_data;
                -- check header
                if l_header_load = com_api_type_pkg.FALSE then
                    if r.ident = cst_woo_const_pkg.F_HEADER then
                        process_file_header(
                            i_header_data   => l_tc_buffer(1)
                          , i_inst_id       => l_inst_id
                          , i_file_name     => l_file_name
                          , i_expected_row_count => l_record_count_expected
                          , o_woo_file      => l_woo_file
                        );
                        l_header_load := com_api_type_pkg.TRUE;

                        -- clean the previous data in the import table:
                        delete from cst_woo_import_f140;
                        trc_log_pkg.debug(
                            i_text      => 'Header is loaded, previous data is purged'
                        );
                        l_processing_stage := PROC_STAGE_PREPARE_OPER;
                    else
                        com_api_error_pkg.raise_error(
                            i_error         => 'HEADER_NOT_FOUND'
                          , i_env_param1    => p.session_file_id
                        );
                    end if;
                else
                    -- get data and process data
                    process_data_f140(
                        i_tc_buffer          => l_tc_buffer(1)
                      , i_file_name          => l_file_name
                      , i_inst_id            => i_inst_id
                      , i_sttl_date          => l_sttl_date
                      , i_fraud_control      => l_fraud_control
                      , io_oper_list         => l_oper_list
                      , o_successful_count   => l_successful_oper_count
                      , o_rejected_count     => l_rejected_oper_count
                      , o_error_count        => l_error_oper_count
                    );

                    l_record_count := l_record_count + 1;

                    if l_rejected_oper_count > 0 or l_error_oper_count > 0 then
                        trc_log_pkg.warn(
                            i_text  => 'Record [' || l_record_count
                                    || ']: rejected operations = ' || l_rejected_oper_count
                                    || ', error operations = ' || l_error_oper_count
                        );
                    end if;
                end if;
                -- cleanup buffer before loading next record(s)
                l_tc_buffer.delete;
            end loop;
        exception
            when com_api_error_pkg.e_application_error then
                rollback to sp_woo_incoming_file;

                l_errors_count  := l_errors_count + 1;

                trc_log_pkg.debug(
                    i_text  => 'Error at line = ' || l_record_number
                            || ', file name = ' || l_file_name
                );

                prc_api_file_pkg.close_file(
                    i_sess_file_id  => p.session_file_id
                  , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
                );
                raise;
        end;
    end loop;

    if l_file_count = 0 then
        com_api_error_pkg.raise_error (
            i_error        => 'SEC_FILE_NOT_FOUND'
        );
    end if;
    
    trc_log_pkg.info(
        i_text  => 'All file records are parsed, start operations processing'
    );
    l_processing_stage := PROC_STAGE_PROCESS_OPER;

    if l_oper_list.count > 0 then
    process_operations(
        i_oper_list => l_oper_list
    );
    end if;

    prc_api_stat_pkg.log_end(
        i_processed_total   => l_record_count
      , i_excepted_total    => l_errors_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug(
        i_text  => 'cst_woo_prc_incoming_pkg.process_f140 > End'
    );
exception
    when others then

        if l_processing_stage = PROC_STAGE_PREPARE_OPER then
            if l_oper_list.count > 0 then
                cancel_operations(
                    i_oper_list => l_oper_list
                );
                trc_log_pkg.info(
                    i_text  => 'Created but not processed operations are cancelled'
                );
            end if;
        end if;

        prc_api_stat_pkg.log_end(
            i_result_code   => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end process_f140;

end cst_woo_prc_incoming_pkg;
/
