create or replace package body cst_bmed_csc_incoming_pkg as 

g_error_flag        com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE;

procedure process_file_header(
    i_header_data           in varchar2
    , i_network_id          in com_api_type_pkg.t_mcc
    , i_dst_inst_id         in com_api_type_pkg.t_mcc    
    , o_csc_file            out cst_bmed_csc_type_pkg.t_csc_file_rec
) is
begin
    trc_log_pkg.debug (
        i_text          => 'cst_bmed_csc_incoming_pkg.process_file_header start'
    );
    
    o_csc_file.identifier_header := substr(i_header_data, 1, 2);
    o_csc_file.file_label   := substr(i_header_data, 3, 10);
    o_csc_file.file_id      := substr(i_header_data, 13, 8);
    
    trc_log_pkg.debug (
        i_text          => 'cst_bmed_csc_incoming_pkg.process_file_header end'
    );
end;

procedure process_file_trailer (
    i_trailer_data          in      varchar2
    , io_csc_file           in  out cst_bmed_csc_type_pkg.t_csc_file_rec
) is
begin
    trc_log_pkg.debug (
        i_text          => 'cst_bmed_csc_incoming_pkg.process_file_trailer start'
    );

    io_csc_file.identifier_trailer     := substr(i_trailer_data, 1, 2);   
    io_csc_file.trans_total            := substr(i_trailer_data, 3, 10);
    io_csc_file.amount_total           := substr(i_trailer_data, 13, 19);
    io_csc_file.reversal_amount_total  := substr(i_trailer_data, 32, 19);

    trc_log_pkg.debug (
        i_text          => 'cst_bmed_csc_incoming_pkg.process_file_trailer end'
    );
end;

function date_yymm (
    p_date                  in varchar2
) return date is
begin
    if p_date is null or p_date = '0000' then
        return null;
    end if;

    return to_date(p_date, 'YYMM');
end;

function date_yymmddhhmmss (
    p_date                  in varchar2
) return date is
begin
    if p_date is null or p_date = '000000000000' then
        return null;
    end if;

    return to_date(p_date, 'YYMMDDHH24MISS');
end;

procedure get_original_id(
    io_oper             in out nocopy opr_api_type_pkg.t_oper_rec
  , i_iss_part          in out nocopy opr_api_type_pkg.t_oper_part_rec
  , o_original_id       out           com_api_type_pkg.t_long_id
) is
    REVERSAL_SEARCH_TIME_WINDOW     constant number := 30;
    l_original_id                   com_api_type_pkg.t_long_id;     
begin
    select o.id
      into l_original_id
      from opr_operation o
         , opr_participant op
         , opr_card oc
     where op.oper_id = o.id
       and nvl(o.is_reversal, com_api_type_pkg.FALSE) = com_api_type_pkg.FALSE
       and o.originator_refnum = io_oper.originator_refnum
       and o.oper_type         = io_oper.oper_type
       and o.msg_type          = io_oper.msg_type
       and io_oper.oper_date - o.oper_date <= REVERSAL_SEARCH_TIME_WINDOW
       and not exists ( -- operation may be already linked with another reversal
           select r.id
             from opr_operation r
            where nvl(r.is_reversal, com_api_type_pkg.FALSE) = com_api_type_pkg.TRUE
              and r.original_id = o.id
       )
       and op.participant_type    = com_api_const_pkg.PARTICIPANT_ISSUER
       and oc.oper_id(+)          = op.oper_id
       and oc.participant_type(+) = op.participant_type
       and op.client_id_type      = i_iss_part.client_id_type
       and op.client_id_value     = i_iss_part.client_id_value
       ;

exception
    when no_data_found then
        
        io_oper.status := opr_api_const_pkg.OPERATION_STATUS_MANUAL;
         
        trc_log_pkg.error(
            i_text       => 'ORIGINAL_OPERATION_IS_NOT_FOUND'
          , i_env_param1 => io_oper.id
          , i_env_param2 => io_oper.originator_refnum
          , i_env_param3 => io_oper.oper_date
          , i_env_param4 => i_iss_part.client_id_type
          , i_env_param5 => i_iss_part.client_id_value
        );
end;

procedure create_operation(
    io_csc_fin_rec       in out nocopy  cst_bmed_csc_type_pkg.t_csc_fin_mes_rec
)is
    l_iss_inst_id           com_api_type_pkg.t_inst_id;
    l_iss_network_id        com_api_type_pkg.t_tiny_id;
    l_acq_network_id        com_api_type_pkg.t_tiny_id;
    l_acq_inst_id           com_api_type_pkg.t_inst_id;
    l_card_inst_id          com_api_type_pkg.t_inst_id;
    l_card_network_id       com_api_type_pkg.t_tiny_id;
    l_card_type_id          com_api_type_pkg.t_tiny_id;
    l_country_code          com_api_type_pkg.t_country_code;
    l_bin_currency          com_api_type_pkg.t_curr_code;
    l_sttl_currency         com_api_type_pkg.t_curr_code;
    l_sttl_type             com_api_type_pkg.t_dict_value;
    l_match_status          com_api_type_pkg.t_dict_value;

    l_oper                  opr_api_type_pkg.t_oper_rec;
    l_iss_part              opr_api_type_pkg.t_oper_part_rec;
    l_acq_part              opr_api_type_pkg.t_oper_part_rec;
    l_orig_id               com_api_type_pkg.t_long_id;
begin
    trc_log_pkg.debug (
        i_text          => 'cst_bmed_csc_incoming_pkg.create_operation start'
    );

    -- get card inst
    iss_api_bin_pkg.get_bin_info (
        i_card_number        => io_csc_fin_rec.pan
        , o_iss_inst_id      => l_iss_inst_id
        , o_iss_network_id   => l_iss_network_id
        , o_card_inst_id     => l_card_inst_id
        , o_card_network_id  => l_card_network_id
        , o_card_type        => l_card_type_id
        , o_card_country     => l_country_code
        , o_bin_currency     => l_bin_currency
        , o_sttl_currency    => l_sttl_currency
    );

    -- if card BIN not found, then mark record as invalid
    if l_card_inst_id is null then
        io_csc_fin_rec.is_invalid := com_api_type_pkg.TRUE;
        g_error_flag              := com_api_type_pkg.TRUE;
        l_iss_inst_id             := cst_bmed_csc_const_pkg.PROCESSING_CENTER_INST;
        l_iss_network_id          := ost_api_institution_pkg.get_inst_network(l_iss_inst_id);
    end if;

    if l_acq_inst_id is null then
        l_acq_network_id          := cst_bmed_csc_const_pkg.CSC_NETWORK;
        l_acq_inst_id             := net_api_network_pkg.get_inst_id(cst_bmed_csc_const_pkg.CSC_NETWORK);
    end if;
    
    -- mapping
    if io_csc_fin_rec.proc_code = cst_bmed_csc_const_pkg.PROC_CODE_ATM then

        l_oper.oper_type := opr_api_const_pkg.OPERATION_TYPE_ATM_CASH;
    end if;

    if l_oper.oper_type is null then

        com_api_error_pkg.raise_error(
            i_error         => 'UNABLE_DETERMINE_OPER_TYPE'
            , i_env_param1  => io_csc_fin_rec.proc_code
        );
    end if;

    net_api_sttl_pkg.get_sttl_type (
        i_iss_inst_id        => l_iss_inst_id
        , i_acq_inst_id      => l_acq_inst_id
        , i_card_inst_id     => l_card_inst_id
        , i_iss_network_id   => l_iss_network_id
        , i_acq_network_id   => l_acq_network_id
        , i_card_network_id  => l_card_network_id
        , i_acq_inst_bin     => null
        , o_sttl_type        => l_sttl_type
        , o_match_status     => l_match_status
        , i_oper_type        => l_oper.oper_type
    );

    l_oper.match_status         := l_match_status;

    l_oper.sttl_type := l_sttl_type;
    if l_oper.sttl_type is null then
    
        com_api_error_pkg.raise_error(
            i_error         => 'UNABLE_DETERMINE_STTL_TYPE'
            , i_env_param1  => iss_api_card_pkg.get_card_mask(i_card_number => io_csc_fin_rec.pan)
            , i_env_param2  => l_iss_inst_id
            , i_env_param3  => l_acq_inst_id
            , i_env_param4  => l_card_inst_id
            , i_env_param5  => l_iss_network_id || '/' || l_acq_network_id
        );
    end if;

    l_oper.msg_type := opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT;

    if io_csc_fin_rec.is_invalid = com_api_type_pkg.TRUE then

        l_oper.status := opr_api_const_pkg.OPERATION_STATUS_MANUAL;
    end if;
    
    l_oper.is_reversal             := case io_csc_fin_rec.rev_by when ' ' 
                                            then 0 
                                            else 1 
                                      end;
    l_oper.terminal_type           :=  acq_api_const_pkg.TERMINAL_TYPE_ATM;
    l_oper.oper_amount             := io_csc_fin_rec.amt_tran;
    l_oper.oper_currency           := io_csc_fin_rec.cur_tran;
    l_oper.sttl_amount             := io_csc_fin_rec.amt_card_bill;
    l_oper.sttl_currency           := io_csc_fin_rec.cur_card_bill;
    l_oper.oper_date               := date_yymmddhhmmss(io_csc_fin_rec.date_time_local_tran);
    l_oper.host_date               := null;
    l_oper.mcc                     := '6011';
    l_oper.originator_refnum       := io_csc_fin_rec.retrieval_ref_nbr;
    l_oper.acq_inst_bin            := io_csc_fin_rec.inst_id_acqr;
    
    l_oper.merchant_number         := io_csc_fin_rec.card_acpt_id;
    l_oper.terminal_number         := io_csc_fin_rec.card_acpt_term_id;
    l_oper.merchant_name           := io_csc_fin_rec.card_acpt_id;
    l_oper.merchant_city           := io_csc_fin_rec.card_acpt_city;
    l_oper.merchant_street         := io_csc_fin_rec.card_acpt_addr;
    l_oper.merchant_country        := io_csc_fin_rec.country_acqr_inst;
    l_oper.merchant_region         := io_csc_fin_rec.card_acpt_country;
    
    -- participants
    l_iss_part.inst_id             := l_iss_inst_id;
    l_iss_part.network_id          := l_iss_network_id;
    l_iss_part.card_id             := iss_api_card_pkg.get_card_id(io_csc_fin_rec.pan);
    
    case when l_card_type_id is not null then
        l_iss_part.card_type_id    := l_card_type_id;
    else
        l_iss_part.card_type_id    := iss_api_card_pkg.get_card (
            i_card_number   => io_csc_fin_rec.pan
            , i_mask_error  => com_api_type_pkg.TRUE
        ).card_type_id;
    end case;
    
    l_iss_part.card_expir_date     := date_yymm(io_csc_fin_rec.date_exp);
    l_iss_part.client_id_type      := opr_api_const_pkg.CLIENT_ID_TYPE_CARD;
    l_iss_part.client_id_value     := io_csc_fin_rec.pan;
    l_iss_part.customer_id         := iss_api_card_pkg.get_card (
        i_card_number   => io_csc_fin_rec.pan
        , i_mask_error  => com_api_type_pkg.TRUE
    ).customer_id;    
    l_iss_part.card_mask           := iss_api_card_pkg.get_card_mask(io_csc_fin_rec.pan);
    l_iss_part.card_number         := io_csc_fin_rec.pan;
    l_iss_part.card_hash           := com_api_hash_pkg.get_card_hash(io_csc_fin_rec.pan);
    
    case when l_country_code is not null then
        l_iss_part.card_country    := l_country_code;
    else
        l_iss_part.card_country    := iss_api_card_pkg.get_card(
            i_card_number   => io_csc_fin_rec.pan
            , i_mask_error  => com_api_type_pkg.TRUE
        ).country;
    end case;
    
    l_iss_part.card_inst_id        := l_card_inst_id;
    l_iss_part.card_network_id     := l_card_network_id;
    l_iss_part.split_hash          := com_api_hash_pkg.get_split_hash(io_csc_fin_rec.pan);
    l_iss_part.account_amount      := null;
    l_iss_part.account_currency    := null;
    l_iss_part.account_number      := null;
    l_iss_part.auth_code           := substr(io_csc_fin_rec.approval_code, 1, 6); 

    l_acq_part.inst_id             := l_acq_inst_id;
    l_acq_part.network_id          := l_acq_network_id;
    l_acq_part.merchant_id         := null;
    l_acq_part.terminal_id         := null;
    l_acq_part.split_hash          := null;

    -- create operation
    trc_log_pkg.debug (
        i_text         => 'create_operation start'
    );

    if l_oper.is_reversal = com_api_type_pkg.TRUE then
        
        get_original_id(
            io_oper             => l_oper
          , i_iss_part          => l_iss_part
          , o_original_id       => l_oper.original_id
        );
    end if;

    opr_api_create_pkg.create_operation (
        io_oper_id             => l_oper.id
        , i_session_id         => get_session_id
        , i_status             => nvl(l_oper.status, opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY)
        , i_status_reason      => l_oper.status_reason
        , i_sttl_type          => l_oper.sttl_type
        , i_msg_type           => l_oper.msg_type
        , i_oper_type          => l_oper.oper_type
        , i_oper_reason        => l_oper.oper_reason
        , i_is_reversal        => l_oper.is_reversal
        , i_oper_amount        => l_oper.oper_amount
        , i_oper_currency      => l_oper.oper_currency
        , i_sttl_amount        => l_oper.sttl_amount
        , i_sttl_currency      => l_oper.sttl_currency
        , i_oper_date          => l_oper.oper_date
        , i_host_date          => l_oper.host_date
        , i_terminal_type      => l_oper.terminal_type
        , i_mcc                => l_oper.mcc
        , i_originator_refnum  => l_oper.originator_refnum
        , i_acq_inst_bin       => l_oper.acq_inst_bin
        , i_merchant_number    => l_oper.merchant_number
        , i_terminal_number    => l_oper.terminal_number
        , i_merchant_name      => l_oper.merchant_name
        , i_merchant_street    => l_oper.merchant_street
        , i_merchant_city      => l_oper.merchant_city
        , i_merchant_region    => l_oper.merchant_region
        , i_merchant_country   => l_oper.merchant_country
        , i_merchant_postcode  => l_oper.merchant_postcode
        , i_dispute_id         => l_oper.dispute_id
        , i_match_status       => l_oper.match_status
        , i_original_id        => l_oper.original_id
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
        , i_client_id_type    => opr_api_const_pkg.CLIENT_ID_TYPE_CARD
        , i_client_id_value   => l_iss_part.card_number
        , i_card_id           => l_iss_part.card_id
        , i_card_type_id      => l_iss_part.card_type_id
        , i_card_expir_date   => l_iss_part.card_expir_date
        , i_card_seq_number   => l_iss_part.card_seq_number
        , i_card_number       => l_iss_part.card_number
        , i_card_mask         => l_iss_part.card_mask
        , i_card_hash         => l_iss_part.card_hash
        , i_card_country      => l_iss_part.card_country
        , i_card_inst_id      => l_iss_part.card_inst_id
        , i_card_network_id   => l_iss_part.card_network_id
        , i_account_id        => null
        , i_account_number    => null
        , i_account_amount    => null
        , i_account_currency  => null
        , i_auth_code         => l_iss_part.auth_code
        , i_split_hash        => l_iss_part.split_hash
        , i_without_checks    => com_api_const_pkg.TRUE
    );

    opr_api_create_pkg.add_participant (
        i_oper_id             => l_oper.id
        , i_msg_type          => l_oper.msg_type
        , i_oper_type         => l_oper.oper_type
        , i_participant_type  => com_api_const_pkg.PARTICIPANT_ACQUIRER
        , i_host_date         => l_oper.host_date
        , i_inst_id           => l_acq_part.inst_id
        , i_network_id        => l_acq_part.network_id
        , i_merchant_id       => null
        , i_terminal_id       => null
        , i_terminal_number   => l_oper.terminal_number
        , i_split_hash        => null
        , i_without_checks    => com_api_const_pkg.TRUE
    );
        
    trc_log_pkg.debug (
        i_text         => 'create_operation end'
    );
    
    trc_log_pkg.debug (
        i_text          => 'csc_prc_incoming_pkg.create_operation end'
    );

end;

procedure process_presentment(
    i_tc_buffer             in      varchar2
    , i_csc_file            in      cst_bmed_csc_type_pkg.t_csc_file_rec
) is
    l_csc_fin_rec           cst_bmed_csc_type_pkg.t_csc_fin_mes_rec;

begin
    trc_log_pkg.debug (
        i_text          => 'cst_bmed_csc_incoming_pkg.process_presentment start'
    );
    -- init_record
    --l_csc_fin_rec.id                         
    l_csc_fin_rec.file_id                 := substr(i_tc_buffer, 1, 8);  
    l_csc_fin_rec.rec_id                  := substr(i_tc_buffer, 9, 12);      
    l_csc_fin_rec.proc_code               := substr(i_tc_buffer, 21, 6);  
    l_csc_fin_rec.act_code                := substr(i_tc_buffer, 27, 3);  
    l_csc_fin_rec.date_time_local_tran    := substr(i_tc_buffer, 30, 12); 
    l_csc_fin_rec.retrieval_ref_nbr       := substr(i_tc_buffer, 42, 12); 
    l_csc_fin_rec.system_trace_audit_nbr  := substr(i_tc_buffer, 54, 6); 
    l_csc_fin_rec.card_acpt_term_id       := substr(i_tc_buffer, 60, 15);  
    l_csc_fin_rec.card_acpt_id            := substr(i_tc_buffer, 75, 15);  
    l_csc_fin_rec.card_acpt_addr          := substr(i_tc_buffer, 90, 29);  
    l_csc_fin_rec.card_acpt_city          := substr(i_tc_buffer, 119, 28);  
    l_csc_fin_rec.card_acpt_country       := substr(i_tc_buffer, 147, 3);  
    l_csc_fin_rec.country_acqr_inst       := substr(i_tc_buffer, 150, 3);  
    l_csc_fin_rec.inst_id_acqr            := substr(i_tc_buffer, 153, 11);  
    l_csc_fin_rec.network_id_acqr         := substr(i_tc_buffer, 164, 3);  
    l_csc_fin_rec.network_term_id         := substr(i_tc_buffer, 167, 8);  
    l_csc_fin_rec.pr_proc_id              := substr(i_tc_buffer, 175, 6);  
    l_csc_fin_rec.proc_id_acqr            := substr(i_tc_buffer, 181, 6);  
    l_csc_fin_rec.process_id_acqr         := substr(i_tc_buffer, 187, 6); 
    l_csc_fin_rec.date_recon_acqr         := substr(i_tc_buffer, 193, 6);      
    l_csc_fin_rec.pan                     := trim(substr(i_tc_buffer, 199, 28));  
    l_csc_fin_rec.inst_id_issr            := substr(i_tc_buffer, 227, 11);  
    l_csc_fin_rec.pr_rpt_inst_id_issr     := substr(i_tc_buffer, 238, 11);  
    l_csc_fin_rec.date_recon_issr         := substr(i_tc_buffer, 249, 6); 
    l_csc_fin_rec.auth_by                 := substr(i_tc_buffer, 255, 1); 
    l_csc_fin_rec.approval_code           := substr(i_tc_buffer, 256, 6);  
    l_csc_fin_rec.country_auth_agent_inst := substr(i_tc_buffer, 262, 3); 
    l_csc_fin_rec.rev_by                  := substr(i_tc_buffer, 265, 1);  
    l_csc_fin_rec.date_exp                := substr(i_tc_buffer, 266, 4);  
    l_csc_fin_rec.date_time_trans_rqst    := substr(i_tc_buffer, 270, 10);  
    l_csc_fin_rec.cur_tran                := substr(i_tc_buffer, 280, 3);  
    l_csc_fin_rec.cur_tran_exp            := substr(i_tc_buffer, 283, 1);  
    l_csc_fin_rec.amt_tran                := substr(i_tc_buffer, 284, 19);  
    l_csc_fin_rec.amt_rev                 := substr(i_tc_buffer, 303, 19);  
    l_csc_fin_rec.amt_tran_fee            := substr(i_tc_buffer, 322, 19);  
    l_csc_fin_rec.cur_card_bill           := substr(i_tc_buffer, 341, 3);  
    l_csc_fin_rec.cur_bill_exp            := substr(i_tc_buffer, 344, 1);  
    l_csc_fin_rec.amt_card_bill           := substr(i_tc_buffer, 345, 19);   
    l_csc_fin_rec.amt_rev_bill            := substr(i_tc_buffer, 364, 19);   
    l_csc_fin_rec.amt_card_bill_fee       := substr(i_tc_buffer, 383, 19);   
    
    create_operation(
        io_csc_fin_rec       => l_csc_fin_rec
    );
       
    trc_log_pkg.debug (
        i_text          => 'cst_bmed_csc_incoming_pkg.process_presentment end'
    );
end;    

procedure process (
    i_network_id            in com_api_type_pkg.t_tiny_id
    , i_dst_inst_id         in com_api_type_pkg.t_inst_id default null
)is
    l_tc_buffer             cst_bmed_csc_type_pkg.t_tc_buffer;
    l_csc_file              cst_bmed_csc_type_pkg.t_csc_file_rec;
    l_record_number         com_api_type_pkg.t_long_id := 0;
    l_record_count          com_api_type_pkg.t_long_id := 0;
    l_errors_count          com_api_type_pkg.t_long_id := 0;

    l_trailer_load          com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE;
    l_header_load           com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE;
    l_inst_name             com_api_type_pkg.t_name;

    cursor cu_records_count is
        select count(1)
          from prc_file_raw_data a
             , prc_session_file b
         where b.session_id      = prc_api_session_pkg.get_session_id
           and a.record_number   > 1
           and substr(a.raw_data, 1, 2) != cst_bmed_csc_const_pkg.IDENTIFIER_TRAILER
           and a.session_file_id = b.id;

begin
    prc_api_stat_pkg.log_start;

    open cu_records_count;
    fetch cu_records_count into l_record_count;
    close cu_records_count;

    prc_api_stat_pkg.log_estimation (
        i_estimated_count     => l_record_count
    );

    trc_log_pkg.debug (
        i_text          => 'estimation record = ' || l_record_count
    );

    l_record_count := 0;

    for p in (
        select id session_file_id
             , record_count
          from prc_session_file
         where session_id = prc_api_session_pkg.get_session_id
         order by id
    ) loop
        l_errors_count := 0;
        l_trailer_load := com_api_type_pkg.FALSE;
        l_header_load  := com_api_type_pkg.FALSE;
        
        begin
            savepoint sp_csc_incoming_file;
            trc_log_pkg.debug (
                i_text          => 'cst_bmed_csc_incoming_pkg.process start. Session file=' || p.session_file_id
            );
            
            for r in (
                select
                    record_number
                    , raw_data
                    , substr(raw_data, 1, 2) ident
                from
                    prc_file_raw_data
                where
                    session_file_id = p.session_file_id
                order by
                    record_number
            -- processing current file
            ) loop
                g_error_flag                        := com_api_type_pkg.FALSE;
                l_tc_buffer(l_tc_buffer.count + 1)  := r.raw_data;
                
                --check header
                if l_header_load = com_api_type_pkg.FALSE then
                   
                    if r.ident = cst_bmed_csc_const_pkg.IDENTIFIER_HEADER then  
                          
                        process_file_header(
                            i_header_data    =>  l_tc_buffer(1)
                            , i_network_id   =>  i_network_id
                            , i_dst_inst_id  =>  i_dst_inst_id
                            , o_csc_file     =>  l_csc_file
                        );
                        l_header_load := com_api_type_pkg.TRUE;
                    else
                        com_api_error_pkg.raise_error(
                            i_error          => 'HEADER_NOT_FOUND'
                            , i_env_param1   => p.session_file_id
                        );
                    end if;
                    
                elsif instr(l_tc_buffer(1), cst_bmed_csc_const_pkg.IDENTIFIER_TRAILER) <> 0 then
                
                    process_file_trailer (
                        i_trailer_data       =>  l_tc_buffer(1)
                        , io_csc_file        =>  l_csc_file
                    );
                    l_trailer_load := com_api_type_pkg.TRUE;
                else
                    --process_presentment
                    if l_trailer_load = com_api_type_pkg.TRUE then
                        com_api_error_pkg.raise_error(
                            i_error          => 'PRESENTMENT_AFTER_TRAILER'
                            , i_env_param1   => p.session_file_id
                        );
                    end if;    
                    
                    process_presentment(
                        i_tc_buffer          =>  l_tc_buffer(1)
                        , i_csc_file         =>  l_csc_file
                    );
                    l_record_count := l_record_count + 1;
                end if;                                

                -- cleanup buffer before loading next record(s)
                l_tc_buffer.delete;

                l_record_number := l_record_number + 1;

                if g_error_flag = com_api_type_pkg.TRUE then
                    l_errors_count := l_errors_count + 1;
                end if;

                if mod(l_record_count, 100) = 0 then
                    prc_api_stat_pkg.log_current(
                        i_current_count  => l_record_count
                      , i_excepted_count => l_errors_count
                    );
                end if;

            end loop;              

            -- check trailer exists
            if l_trailer_load = com_api_type_pkg.FALSE then
                com_api_error_pkg.raise_error(
                    i_error         => 'TRAILER_NOT_FOUND'
                    , i_env_param1  => p.session_file_id
                );
            end if;

            trc_log_pkg.debug (
                i_text          => 'cst_bmed_csc_incoming_pkg.process end.'
            );
            
        exception
            when com_api_error_pkg.e_application_error then
                rollback to sp_csc_incoming_file;

                l_errors_count := l_errors_count + p.record_count;
                l_record_count := l_record_count + p.record_count;

                prc_api_stat_pkg.log_current(
                    i_current_count  => l_record_count
                  , i_excepted_count => l_errors_count
                );

                prc_api_file_pkg.close_file(
                    i_sess_file_id          => p.session_file_id
                  , i_status                => prc_api_const_pkg.FILE_STATUS_REJECTED
                );   
                
                raise;                              
        end;
        
    end loop;

    prc_api_stat_pkg.log_end(
        i_processed_total   => l_record_count
      , i_excepted_total    => l_errors_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

exception
    when others then
        if cu_records_count%isopen then
            close cu_records_count;
        end if;

        prc_api_stat_pkg.log_end(
            i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
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
    
end;

end;
/
