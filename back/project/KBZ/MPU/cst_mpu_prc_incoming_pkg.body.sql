create or replace package body cst_mpu_prc_incoming_pkg as

g_error_flag        com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE;

function date_yymmdd(
    p_date in        varchar2
) return date is
begin
    if p_date = '000000' then
        return null;
    end if;
    return to_date(p_date, 'YYMMDD');
end;

function date_yymm(
    i_date  in     varchar2
) return date is
begin
    if i_date is null or i_date = '0000' then
        return null;
    end if;

    return to_date(i_date, 'YYMM');
end date_yymm;

-- This algorithm you can see in the "vis_prc_incoming_pkg.date_mmdd" method also.
function date_without_year(
    i_date      in     com_api_type_pkg.t_name
  , i_filedate  in     date
  , i_datemask  in com_api_type_pkg.t_name
) return date is
    YEAR_MASK      constant com_api_type_pkg.t_name := 'YYYY';
    l_datemask              com_api_type_pkg.t_name;
    l_year                  com_api_type_pkg.t_name;
    l_dt                    date;
begin
    if i_date is null or i_date = '0000' then
        return null;
    end if;

    l_datemask := YEAR_MASK || i_datemask;
    l_year     := to_char(i_filedate, YEAR_MASK);
    l_dt       := to_date(l_year || i_date, l_datemask);

    if l_dt > i_filedate then
        l_year := to_char(to_number(l_year) - 1);
        l_dt   := to_date(l_year || i_date, l_datemask);

        if abs(months_between(l_dt, i_filedate)) > 11 then
            l_year := to_char(i_filedate, YEAR_MASK);
            l_dt   := to_date(l_year || i_date, l_datemask);
        end if;
    end if;

    -- if operation date greater than file date then lessen date for a year
    if l_dt > i_filedate then
        l_dt := add_months(l_dt, -12);
    end if;

    return l_dt;
exception
    when others then
        trc_log_pkg.debug('l_year || i_date='||l_year || i_date||', l_datemask= l_datemask: '||sqlerrm);
        raise;
end date_without_year;

procedure assign_dispute_id(
    io_mpu_fin_rec  in out nocopy cst_mpu_api_type_pkg.t_mpu_fin_mes_rec
  , o_auth             out        aut_api_type_pkg.t_auth_rec
  , i_mask_error    in            com_api_type_pkg.t_boolean
) is
    l_reason_code           com_api_type_pkg.t_mcc;    
    l_original_fin_id       com_api_type_pkg.t_long_id;
    l_original_dispute_id   com_api_type_pkg.t_long_id;    
begin
    if io_mpu_fin_rec.reason_code in('0001', '0004', '0005') then -- chargeback, debit and credit adjasment. Replace on constant
        l_reason_code := '0000';
    elsif io_mpu_fin_rec.reason_code = '0002' then -- SP
        l_reason_code := '0001';
    elsif io_mpu_fin_rec.reason_code = '0003' then -- A chargeback
        l_reason_code := '0002';
    end if;

    select f.id
         , f.dispute_id
      into l_original_fin_id
         , l_original_dispute_id
      from cst_mpu_fin_msg f
         , cst_mpu_card c
     where f.id              = c.id
       and c.card_number     = io_mpu_fin_rec.card_number
       and f.reason_code     = l_reason_code
       and f.trans_amount    = io_mpu_fin_rec.trans_amount
       and f.trans_date      = io_mpu_fin_rec.trans_date
       and f.rrn             = io_mpu_fin_rec.rrn
       and f.sys_trace_num   = io_mpu_fin_rec.sys_trace_num
       and f.terminal_number = io_mpu_fin_rec.terminal_number;

    io_mpu_fin_rec.dispute_id  := l_original_dispute_id;
    io_mpu_fin_rec.original_id := l_original_fin_id;

    if l_original_dispute_id is null then
    
        io_mpu_fin_rec.dispute_id := l_original_fin_id;

        update cst_mpu_fin_msg
           set dispute_id = io_mpu_fin_rec.dispute_id
         where id         = io_mpu_fin_rec.dispute_id;

        update opr_operation
           set dispute_id = io_mpu_fin_rec.dispute_id
         where id         = io_mpu_fin_rec.dispute_id;
    end if;

    cst_mpu_api_fin_message_pkg.load_auth(
        i_id     => l_original_fin_id
      , io_auth  => o_auth
    );

exception
    when no_data_found then        
        if i_mask_error = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_error(
                i_error       => 'FINANCIAL_MESSAGE_NOT_FOUND'
              , i_env_param1  => l_reason_code
              , i_env_param2  => io_mpu_fin_rec.rrn
            );
        else
            trc_log_pkg.error(
                i_text        => 'FINANCIAL_MESSAGE_NOT_FOUND'
              , i_env_param1  => l_reason_code
              , i_env_param2  => io_mpu_fin_rec.rrn
            );
        end if;
end;

procedure process_file_header(
    i_file_name        in      com_api_type_pkg.t_name
  , i_header_data      in      varchar2
  , i_network_id       in      com_api_type_pkg.t_tiny_id
  , i_standard_id      in      com_api_type_pkg.t_tiny_id
  , i_host_id          in      com_api_type_pkg.t_tiny_id
  , o_mpu_file            out  cst_mpu_api_type_pkg.t_mpu_file_rec
  , i_session_file_id  in      com_api_type_pkg.t_long_id
) is
    LOG_PREFIX            constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_file_header';
begin
    trc_log_pkg.debug(
        i_text        => LOG_PREFIX || ': START with i_file_name [#1]'
      , i_env_param1  => i_file_name
    );
    if i_standard_id is null then
        com_api_error_pkg.raise_error(
            i_error       => 'UNKNOWN_NETWORK'
          , i_env_param1  => i_network_id
        );
    end if;
    o_mpu_file.is_incoming  := com_api_const_pkg.TRUE;
    o_mpu_file.network_id   := i_network_id;
    o_mpu_file.proc_date    := get_sysdate;

    o_mpu_file.iin          := trim(substr(i_header_data, 4, 11));

    o_mpu_file.inst_id := cmn_api_standard_pkg.find_value_owner(
        i_standard_id  => i_standard_id
      , i_entity_type  => net_api_const_pkg.ENTITY_TYPE_HOST
      , i_object_id    => i_host_id
      , i_param_name   => cst_mpu_api_const_pkg.MPU_BUSINESS_ID
      , i_value_char   => o_mpu_file.iin
      , i_mask_error   => com_api_const_pkg.TRUE
      , i_masked_level => trc_config_pkg.DEBUG
    );

    if o_mpu_file.inst_id is null then
        com_api_error_pkg.raise_error(
            i_error       => 'MPU_INSTITUTION_NOT_FOUND'
          , i_env_param1  => o_mpu_file.iin
          , i_env_param2  => i_network_id
        );
    end if;
    o_mpu_file.trans_date      := date_yymmdd(substr(i_header_data, 15, 6));
    o_mpu_file.file_date       := o_mpu_file.trans_date;

    o_mpu_file.session_file_id := i_session_file_id;

    o_mpu_file.id              := 
        com_api_id_pkg.get_id(
            i_seq => cst_mpu_file_seq.nextval
          , i_date =>  o_mpu_file.proc_date
        );

    trc_log_pkg.debug(
        i_text        => LOG_PREFIX || ': FINISH o_mpu_file.id [#1]'
      , i_env_param1  => o_mpu_file.id
    );
end process_file_header;

procedure process_file_trailer(
    i_trailer_data          in      varchar2
  , io_mpu_file             in out  cst_mpu_api_type_pkg.t_mpu_file_rec
) is
begin
    trc_log_pkg.debug(
        i_text          => 'process_file_trailer start'
    );

    io_mpu_file.trans_total := to_number(substr(i_trailer_data, 4, 9));
    io_mpu_file.generator   := trim(substr(i_trailer_data, 14, 20));

    trc_log_pkg.debug(
        i_text          => 'trans_total [#1]'
      , i_env_param1    => io_mpu_file.trans_total
    );

    insert into cst_mpu_file_vw(
        id            
      , inst_id       
      , network_id    
      , is_incoming   
      , iin           
      , trans_date    
      , trans_total   
      , generator     
      , file_date     
      , session_file_id
      , file_type     
      , file_number   
      , inst_role     
      , data_type     
      , proc_date     
    ) values(
        io_mpu_file.id            
      , io_mpu_file.inst_id       
      , io_mpu_file.network_id    
      , io_mpu_file.is_incoming   
      , io_mpu_file.iin           
      , io_mpu_file.trans_date    
      , io_mpu_file.trans_total   
      , io_mpu_file.generator     
      , io_mpu_file.file_date     
      , io_mpu_file.session_file_id
      , io_mpu_file.file_type     
      , io_mpu_file.file_number   
      , io_mpu_file.inst_role     
      , io_mpu_file.data_type     
      , io_mpu_file.proc_date     
    );
    trc_log_pkg.debug(
        i_text          => 'process_file_trailer end'
    );
end process_file_trailer;

procedure create_operation(
    io_mpu_fin_rec       in out nocopy  cst_mpu_api_type_pkg.t_mpu_fin_mes_rec
  , i_auth_rec           in             aut_api_type_pkg.t_auth_rec  
  , i_standard_id        in             com_api_type_pkg.t_tiny_id
  , i_incom_sess_file_id in             com_api_type_pkg.t_long_id
  , i_oper_type          in             com_api_type_pkg.t_dict_value default null
  , i_msg_type           in             com_api_type_pkg.t_dict_value default null
)is
    l_bin_currency       com_api_type_pkg.t_curr_code;
    l_sttl_currency      com_api_type_pkg.t_curr_code;
    l_sttl_type          com_api_type_pkg.t_dict_value;
    l_match_status       com_api_type_pkg.t_dict_value;

    l_oper               opr_api_type_pkg.t_oper_rec;
    l_iss_part           opr_api_type_pkg.t_oper_part_rec;
    l_acq_part           opr_api_type_pkg.t_oper_part_rec;
    l_card               iss_api_type_pkg.t_card_rec;
begin
    trc_log_pkg.debug(i_text => 'mpu_prc_incoming_pkg.create_operation start'
    );

    if i_auth_rec.id is null then  --case when we Issuer and we get Presentments
        iss_api_bin_pkg.get_bin_info(
            i_card_number      => io_mpu_fin_rec.card_number
          , o_iss_inst_id      => l_iss_part.iss_inst_id
          , o_iss_network_id   => l_iss_part.iss_network_id
          , o_card_inst_id     => l_iss_part.card_inst_id
          , o_card_network_id  => l_iss_part.card_network_id
          , o_card_type        => l_iss_part.card_type_id
          , o_card_country     => l_iss_part.card_country
          , o_bin_currency     => l_bin_currency
          , o_sttl_currency    => l_sttl_currency
          , i_raise_error      => com_api_const_pkg.FALSE
        );

        if l_iss_part.card_inst_id is null then
            l_iss_part.iss_inst_id    := io_mpu_fin_rec.inst_id;
            l_iss_part.iss_network_id := ost_api_institution_pkg.get_inst_network(io_mpu_fin_rec.inst_id);

            trc_log_pkg.error(
                i_text        => 'BIN_NOT_FOUND_BY_CARD_NUMBER'
              , i_env_param1  => iss_api_card_pkg.get_card_mask(io_mpu_fin_rec.card_number)
              , i_env_param2  => substr(io_mpu_fin_rec.card_number, 1, 6)
            );
        end if;

        if l_acq_part.acq_inst_id is null then
            l_acq_part.acq_network_id := io_mpu_fin_rec.network_id;
            l_acq_part.acq_inst_id    := net_api_network_pkg.get_inst_id(io_mpu_fin_rec.network_id);
        end if;

        net_api_sttl_pkg.get_sttl_type(
            i_iss_inst_id      => l_iss_part.iss_inst_id
          , i_acq_inst_id      => l_acq_part.acq_inst_id
          , i_card_inst_id     => l_iss_part.card_inst_id
          , i_iss_network_id   => l_iss_part.iss_network_id
          , i_acq_network_id   => l_acq_part.acq_network_id
          , i_card_network_id  => l_iss_part.card_inst_id
          , i_acq_inst_bin     => io_mpu_fin_rec.acq_inst_code
          , o_sttl_type        => l_sttl_type
          , o_match_status     => l_match_status
          , i_oper_type        => l_oper.oper_type
        );

        l_card := iss_api_card_pkg.get_card(
                      i_card_number => io_mpu_fin_rec.card_number
                    , i_mask_error  => com_api_const_pkg.TRUE
                  );

        l_oper.match_status := l_match_status;
        l_oper.sttl_type    := l_sttl_type;
        
        if l_oper.sttl_type is null then
            io_mpu_fin_rec.status     := net_api_const_pkg.CLEARING_MSG_STATUS_INVALID;
            g_error_flag              := com_api_const_pkg.TRUE;

            trc_log_pkg.error(
                i_text        => 'UNABLE_DETERMINE_STTL_TYPE'
              , i_env_param1  => io_mpu_fin_rec.record_type
              , i_env_param2  => iss_api_card_pkg.get_card_mask(io_mpu_fin_rec.card_number)
              , i_env_param3  => l_iss_part.iss_inst_id
              , i_env_param4  => l_acq_part.acq_inst_id
              , i_env_param5  => l_iss_part.card_inst_id
              , i_env_param6  => l_iss_part.iss_network_id || '/' || l_acq_part.acq_network_id
            );
        end if;
        
    else
        l_oper.sttl_type          := i_auth_rec.sttl_type;
        l_iss_part.inst_id        := i_auth_rec.iss_inst_id;
        l_iss_part.network_id     := i_auth_rec.iss_network_id;
        l_acq_part.acq_inst_id    := i_auth_rec.acq_inst_id;
        l_acq_part.acq_network_id := i_auth_rec.acq_network_id;
        -- We dont should match dispute message
        l_oper.match_status       := opr_api_const_pkg.OPERATION_MATCH_DONT_REQ_MATCH; -- 'MTST0300';

        l_iss_part.card_type_id   := i_auth_rec.card_type_id;
        l_iss_part.card_inst_id    := i_auth_rec.card_inst_id;
        l_iss_part.card_network_id := i_auth_rec.card_network_id;
    end if;
    
    -- mapping
    if i_oper_type is null then
    
        l_oper.oper_type :=
            net_api_map_pkg.get_oper_type(
                i_network_oper_type  => io_mpu_fin_rec.proc_code || io_mpu_fin_rec.mcc
              , i_standard_id        => i_standard_id
            );
        
        if l_oper.oper_type is null then
        
            io_mpu_fin_rec.status := net_api_const_pkg.CLEARING_MSG_STATUS_INVALID;
            g_error_flag := com_api_const_pkg.TRUE;
        
            trc_log_pkg.error(
                i_text        => 'UNABLE_DETERMINE_OPER_TYPE'
              , i_env_param1  => io_mpu_fin_rec.proc_code || io_mpu_fin_rec.mcc
            );
        end if;    
    
    else
        l_oper.oper_type := i_oper_type;
    end if;

    
    if i_msg_type is null then
    
        l_oper.msg_type := net_api_map_pkg.get_msg_type(
            i_network_msg_type  => io_mpu_fin_rec.record_type --501, 199, 100, 200
                                || io_mpu_fin_rec.reason_code --0001, 0002, 0003, 0004, 0005, 0006
          , i_standard_id       => i_standard_id
        );

        if l_oper.msg_type is null then
            io_mpu_fin_rec.status     := net_api_const_pkg.CLEARING_MSG_STATUS_INVALID;
            g_error_flag              := com_api_const_pkg.TRUE;

            trc_log_pkg.error(
                i_text        => 'UNABLE_DETERMINE_MSG_TYPE'
              , i_env_param1  => io_mpu_fin_rec.record_type
              , i_env_param2  => i_standard_id
            );
        end if;
    
    else
        l_oper.msg_type := i_msg_type;
    end if;

    if io_mpu_fin_rec.status = net_api_const_pkg.CLEARING_MSG_STATUS_INVALID then
        l_oper.status := opr_api_const_pkg.OPERATION_STATUS_MANUAL;
    end if;
    -- prepare l_oper and participants
    l_oper.id            := io_mpu_fin_rec.id;
    l_oper.is_reversal   := io_mpu_fin_rec.is_reversal;
    l_oper.terminal_type :=
        case io_mpu_fin_rec.mcc when '6011' then acq_api_const_pkg.TERMINAL_TYPE_ATM
            else acq_api_const_pkg.TERMINAL_TYPE_POS
        end;

    l_oper.sttl_amount := io_mpu_fin_rec.sttl_amount;

    l_oper.oper_amount         := io_mpu_fin_rec.trans_amount;
    l_oper.oper_currency       := io_mpu_fin_rec.trans_currency;
    l_oper.sttl_amount         := io_mpu_fin_rec.sttl_amount;
    l_oper.sttl_currency       := io_mpu_fin_rec.sttl_currency;
    l_oper.oper_date           := io_mpu_fin_rec.transmit_date;
    l_oper.host_date           := null;
    l_oper.mcc                 := io_mpu_fin_rec.mcc;
    l_oper.originator_refnum   := io_mpu_fin_rec.rrn;
    l_oper.merchant_number     := io_mpu_fin_rec.merchant_number;
    l_oper.terminal_number     := io_mpu_fin_rec.terminal_number;
    l_oper.merchant_name       := io_mpu_fin_rec.merchant_name;
    l_oper.merchant_country    := io_mpu_fin_rec.merchant_country;
    l_oper.incom_sess_file_id  := i_incom_sess_file_id;
    l_oper.original_id         := io_mpu_fin_rec.original_id;
    l_iss_part.card_id         := l_card.id;
    l_iss_part.card_type_id    := nvl(l_iss_part.card_type_id, l_card.card_type_id);
    l_iss_part.client_id_type      := opr_api_const_pkg.CLIENT_ID_TYPE_CARD;
    l_iss_part.client_id_value     := io_mpu_fin_rec.card_number;
    l_iss_part.customer_id         := l_card.customer_id;
    l_iss_part.card_mask           := l_card.card_mask;
    l_iss_part.card_number         := io_mpu_fin_rec.card_number;
    l_iss_part.card_hash           := l_card.card_hash;
    l_iss_part.card_country        := l_card.country;
    l_iss_part.split_hash          := l_card.split_hash;
    l_iss_part.account_amount      := null;
    l_iss_part.account_currency    := null;
    l_iss_part.account_number      := null;
    l_iss_part.auth_code           := io_mpu_fin_rec.auth_number;

    -- create operation
    cst_mpu_api_fin_message_pkg.create_operation(
        i_oper      => l_oper
      , i_iss_part  => l_iss_part
      , i_acq_part  => l_acq_part
    );

    trc_log_pkg.debug(i_text => 'mpu_prc_incoming_pkg.create_operation end');

end create_operation;

function get_original(
    i_mpu_fin_rec     in out nocopy   cst_mpu_api_type_pkg.t_mpu_fin_mes_rec
) return com_api_type_pkg.t_dict_value is
    l_oper_type     com_api_type_pkg.t_dict_value;
begin
    select min(o.id)
         , min(o.dispute_id)
         , min(o.oper_type)
      into i_mpu_fin_rec.original_id
         , i_mpu_fin_rec.dispute_id
         , l_oper_type
      from aut_auth a
         , opr_operation o
         , opr_participant pi
         , opr_participant pa
         , opr_card c
     where a.id                        = o.id
       and pi.oper_id                  = o.id
       and pi.participant_type         = com_api_const_pkg.PARTICIPANT_ISSUER
       and pa.oper_id                  = o.id
       and pa.participant_type         = com_api_const_pkg.PARTICIPANT_ACQUIRER
       and c.oper_id                   = o.id 
       and c.participant_type          = com_api_const_pkg.PARTICIPANT_ISSUER
       and a.system_trace_audit_number = i_mpu_fin_rec.sys_trace_num
       and o.oper_date                 = i_mpu_fin_rec.trans_date
       and o.originator_refnum         = i_mpu_fin_rec.rrn
       and o.terminal_number           = i_mpu_fin_rec.terminal_number 
       and c.card_number               = i_mpu_fin_rec.card_number;
       
    return l_oper_type; 
end;

/*
 * Record_type 500   
 * This record type is not requires create operation 
*/
procedure process_audit_trailer(
    i_tc_buffer             in      varchar2
  , i_mpu_file              in      cst_mpu_api_type_pkg.t_mpu_file_rec
) is
    l_mpu_fin_rec                   cst_mpu_api_type_pkg.t_mpu_fin_mes_rec;
    l_oper_type                     com_api_type_pkg.t_dict_value;
    function get_field_num(
        i_start  in    com_api_type_pkg.t_tiny_id
      , i_length in    com_api_type_pkg.t_tiny_id
    ) return number is
    begin
        return to_number(trim(substr(i_tc_buffer, i_start, i_length))
                       , com_api_const_pkg.NUMBER_INT_FORMAT_DEFAULT
               );
    end;
    
    function get_field_char(
        i_start  in    com_api_type_pkg.t_tiny_id
      , i_length in    com_api_type_pkg.t_tiny_id
    ) return varchar2 is
    begin
        return trim(substr(i_tc_buffer, i_start, i_length) );
    end;
    
begin
    trc_log_pkg.debug(i_text => 'process_audit_trailer start' );

    l_mpu_fin_rec.inst_id        := i_mpu_file.inst_id;
    l_mpu_fin_rec.network_id     := i_mpu_file.network_id;
    l_mpu_fin_rec.is_incoming    := com_api_const_pkg.TRUE;
    l_mpu_fin_rec.is_reversal    := com_api_const_pkg.FALSE;
    l_mpu_fin_rec.is_matched     := com_api_const_pkg.FALSE;
    l_mpu_fin_rec.status         := net_api_const_pkg.CLEARING_MSG_STATUS_READY;
    l_mpu_fin_rec.file_id        := i_mpu_file.id;
    l_mpu_fin_rec.dispute_id     := NULL;
    l_mpu_fin_rec.original_id    := NULL;
    l_mpu_fin_rec.message_number := NULL;
    l_mpu_fin_rec.record_type    := get_field_char(1, 3);
    l_mpu_fin_rec.card_number    := get_field_char(4, 19);
    l_mpu_fin_rec.proc_code      := get_field_char(23, 6);
    l_mpu_fin_rec.trans_amount   := get_field_num(29, 12);
    l_mpu_fin_rec.sttl_amount    := get_field_num(41, 12);
    l_mpu_fin_rec.sttl_rate      := get_field_num(53, 8);
    l_mpu_fin_rec.sys_trace_num  := trim(substr(i_tc_buffer, 62, 6));  
    l_mpu_fin_rec.trans_date     := to_date(trim(substr(i_tc_buffer, 75, 4))
                                         || trim(substr(i_tc_buffer, 69, 6)) 
                                          , 'MMddhh24miss'
                                           );
    l_mpu_fin_rec.sttl_date      := 
        date_without_year( 
            i_date      => trim(substr(i_tc_buffer, 79, 4))
          , i_filedate  => i_mpu_file.file_date
          , i_datemask  => 'mmdd'
        );
    l_mpu_fin_rec.mcc                  := get_field_char(83, 4);
    l_mpu_fin_rec.acq_inst_code        := get_field_char(87, 11);
    l_mpu_fin_rec.iss_bank_code        := get_field_char(98, 11);
    l_mpu_fin_rec.bnb_bank_code        := get_field_char(109, 11);
    l_mpu_fin_rec.forw_inst_code       := get_field_char(120, 11);
    l_mpu_fin_rec.receiv_inst_code     := null; -- !!! this field not exist
    l_mpu_fin_rec.auth_number          := get_field_char(131, 6);
    l_mpu_fin_rec.rrn                  := get_field_char(138, 12);
    l_mpu_fin_rec.terminal_number      := get_field_char(151, 8);
    l_mpu_fin_rec.trans_currency       := get_field_char(159, 3);
    l_mpu_fin_rec.sttl_currency        := get_field_char(162, 3);
    l_mpu_fin_rec.acct_from            := get_field_char(165, 28);
    l_mpu_fin_rec.acct_to              := get_field_char( 193, 28);
    l_mpu_fin_rec.mti                  := get_field_char(221, 4);
    l_mpu_fin_rec.trans_status         := get_field_char(225, 4);
    l_mpu_fin_rec.service_fee_receiv   := get_field_num(229, 12);
    l_mpu_fin_rec.service_fee_pay      := get_field_num(241, 12);
    l_mpu_fin_rec.service_fee_interchg := get_field_num(253,12);
    l_mpu_fin_rec.pos_entry_mode       := get_field_num(265, 3);
    l_mpu_fin_rec.sys_trace_num_orig   := get_field_char(268, 6);
    l_mpu_fin_rec.pos_cond_code        := get_field_char(274, 2);
    l_mpu_fin_rec.merchant_number      := get_field_char(276, 15);
    l_mpu_fin_rec.merchant_name        := null;
    l_mpu_fin_rec.accept_amount        := get_field_num(291, 12);
    l_mpu_fin_rec.cardholder_trans_fee := get_field_num(303, 12);
    l_mpu_fin_rec.transmit_date        := 
        date_without_year( 
            i_date     => trim(substr(i_tc_buffer, 315, 10))
          , i_filedate => i_mpu_file.file_date
          , i_datemask => 'MMddhh24miss'
        );
    l_mpu_fin_rec.orig_trans_info      := null;
    l_mpu_fin_rec.trans_features       := null;
    l_mpu_fin_rec.merchant_country     := null;
    l_mpu_fin_rec.auth_type            := null;
    l_mpu_fin_rec.reason_code          := null;

    -- match record with operation
    l_oper_type :=  get_original(i_mpu_fin_rec  => l_mpu_fin_rec);
       
    if l_mpu_fin_rec.original_id is not null then
        
        trc_log_pkg.debug(i_text => 'Original operation is found [' || l_mpu_fin_rec.original_id 
                        || ', l_oper_type='||l_oper_type||']' );
        l_mpu_fin_rec.is_matched := com_api_const_pkg.TRUE;
    else
        trc_log_pkg.debug(i_text => 'Original operation is not found ' );
        g_error_flag  := com_api_type_pkg.TRUE; 
        l_mpu_fin_rec.status := net_api_const_pkg.CLEARING_MSG_STATUS_INVALID;
    end if;

    -- put message
    l_mpu_fin_rec.id := 
        cst_mpu_api_fin_message_pkg.put_message(
            i_fin_rec => l_mpu_fin_rec
        );

    trc_log_pkg.debug(i_text => 'process_audit_trailer end');
exception
    when others then
        trc_log_pkg.debug( i_text  => sqlerrm );
        g_error_flag         := com_api_type_pkg.TRUE; 
        l_mpu_fin_rec.status := net_api_const_pkg.CLEARING_MSG_STATUS_INVALID;
end;

/*
 * Record_type 501   
 * This record type is required to create operation 
*/
procedure process_dispute_trailer(
    i_tc_buffer             in      varchar2
  , i_mpu_file              in      cst_mpu_api_type_pkg.t_mpu_file_rec
  , i_standard_id           in      com_api_type_pkg.t_tiny_id
  , i_session_file_id       in      com_api_type_pkg.t_long_id
) is
    l_mpu_fin_rec                   cst_mpu_api_type_pkg.t_mpu_fin_mes_rec;
    l_msg_type                      com_api_type_pkg.t_dict_value;
    l_oper_type                     com_api_type_pkg.t_dict_value;
    l_auth_rec                      aut_api_type_pkg.t_auth_rec;
    function get_field_num(
        i_start  in    com_api_type_pkg.t_tiny_id
      , i_length in    com_api_type_pkg.t_tiny_id
    ) return number is
    begin
        return to_number(trim(substr(i_tc_buffer, i_start, i_length))
                       , com_api_const_pkg.NUMBER_INT_FORMAT_DEFAULT
               );
    end;
    
    function get_field_char(
        i_start  in    com_api_type_pkg.t_tiny_id
      , i_length in    com_api_type_pkg.t_tiny_id
    ) return varchar2 is
    begin
        return trim(substr(i_tc_buffer, i_start, i_length) );
    end;
begin
    trc_log_pkg.debug(i_text => 'process_dispute_trailer start' );
    l_mpu_fin_rec.inst_id         := i_mpu_file.inst_id;
    l_mpu_fin_rec.network_id      := i_mpu_file.network_id;
    l_mpu_fin_rec.is_incoming     := com_api_const_pkg.TRUE;
    l_mpu_fin_rec.is_reversal     := com_api_const_pkg.FALSE;
    l_mpu_fin_rec.is_matched      := com_api_const_pkg.FALSE;
    l_mpu_fin_rec.status          := net_api_const_pkg.CLEARING_MSG_STATUS_READY;
    l_mpu_fin_rec.file_id         := i_mpu_file.id;
    l_mpu_fin_rec.dispute_id      := null;
    l_mpu_fin_rec.original_id     := null;
    l_mpu_fin_rec.message_number  := null;
    l_mpu_fin_rec.record_type     := get_field_char(1, 3);
    l_mpu_fin_rec.card_number     := get_field_char(4, 19);
    l_mpu_fin_rec.proc_code       := get_field_char(23, 6);
    l_mpu_fin_rec.trans_amount    := get_field_num(29, 12);
    l_mpu_fin_rec.sttl_amount     := get_field_num(41, 12);
    l_mpu_fin_rec.sttl_rate       := get_field_num(53, 8);
    l_mpu_fin_rec.sys_trace_num   := get_field_char(62, 6);
    l_mpu_fin_rec.trans_date      := to_date(trim(substr(i_tc_buffer, 75, 4))
                                          || trim(substr(i_tc_buffer, 69, 6))
                                      , 'MMddhh24miss'
                                     );
    l_mpu_fin_rec.sttl_date :=
        date_without_year( 
            i_date      => trim(substr(i_tc_buffer, 79, 4))
          , i_filedate  => i_mpu_file.file_date
          , i_datemask  => 'mmdd'
        );

    l_mpu_fin_rec.mcc                  := get_field_char(83, 4);
    l_mpu_fin_rec.acq_inst_code        := get_field_char(87, 11);
    l_mpu_fin_rec.iss_bank_code        := get_field_char(98, 11);
    l_mpu_fin_rec.bnb_bank_code        := get_field_char(109, 11);
    l_mpu_fin_rec.forw_inst_code       := get_field_char(120, 11);
    l_mpu_fin_rec.receiv_inst_code     := null;
    l_mpu_fin_rec.auth_number          := get_field_char(131, 6);
    l_mpu_fin_rec.rrn                  := get_field_char(138, 12);
    l_mpu_fin_rec.terminal_number      := get_field_char(151, 8);
    l_mpu_fin_rec.trans_currency       := get_field_char(159, 3);
    l_mpu_fin_rec.sttl_currency        := get_field_char(162, 3);
    l_mpu_fin_rec.acct_from            := get_field_char(165, 28);
    l_mpu_fin_rec.acct_to              := get_field_char(193, 28);
    l_mpu_fin_rec.mti                  := get_field_char(221, 4);
    l_mpu_fin_rec.trans_status         := net_api_const_pkg.CLEARING_MSG_STATUS_READY;
    l_mpu_fin_rec.service_fee_receiv   := get_field_num(229, 12);
    l_mpu_fin_rec.service_fee_pay      := get_field_num(241, 12);
    l_mpu_fin_rec.service_fee_interchg := get_field_num(253, 12);
    l_mpu_fin_rec.pos_entry_mode       := get_field_char(265, 3);
    l_mpu_fin_rec.sys_trace_num_orig   := get_field_char(268, 6);
    l_mpu_fin_rec.pos_cond_code        := get_field_char(274, 2);
    l_mpu_fin_rec.merchant_number      := get_field_char(276, 15);
    l_mpu_fin_rec.merchant_name        := null;
    l_mpu_fin_rec.accept_amount        := get_field_num(291, 12);
    l_mpu_fin_rec.cardholder_trans_fee := get_field_num(303, 12);
    l_mpu_fin_rec.transmit_date        := 
        date_without_year( 
            i_date     => trim(substr(i_tc_buffer, 315, 10))
          , i_filedate => i_mpu_file.file_date
          , i_datemask => 'MMddhh24miss'
        );

    l_mpu_fin_rec.orig_trans_info  := null;
    l_mpu_fin_rec.trans_features   := null;
    l_mpu_fin_rec.merchant_country := null;
    l_mpu_fin_rec.auth_type        := null;
    l_mpu_fin_rec.reason_code      := get_field_char(225, 4);
    -- get dispute_id 
    assign_dispute_id(
        io_mpu_fin_rec => l_mpu_fin_rec
      , o_auth         => l_auth_rec
      , i_mask_error   => com_api_const_pkg.FALSE
    );
    
    -- Check role. Create operation for ACQ and ISS only
--    if i_mpu_file.inst_role in('A', 'I') then
    create_operation(
        io_mpu_fin_rec       => l_mpu_fin_rec
      , i_auth_rec           => l_auth_rec  
      , i_standard_id        => i_standard_id
      , i_incom_sess_file_id => i_session_file_id
      , i_oper_type          => l_oper_type
      , i_msg_type           => l_msg_type
    );
    --end if;
    
    -- put message    
    l_mpu_fin_rec.id := cst_mpu_api_fin_message_pkg.put_message(
        i_fin_rec => l_mpu_fin_rec
    );

    trc_log_pkg.debug(i_text => 'process_dispute_trailer end' );
exception
    when others then
        trc_log_pkg.debug(i_text => sqlerrm);
        g_error_flag  := com_api_type_pkg.TRUE; 
        l_mpu_fin_rec.status := net_api_const_pkg.CLEARING_MSG_STATUS_INVALID;
end;

procedure process_settlement(
    i_tc_buffer        in     varchar2
  , i_mpu_file         in     cst_mpu_api_type_pkg.t_mpu_file_rec
  , i_standard_id      in     com_api_type_pkg.t_tiny_id
  , i_host_id          in     com_api_type_pkg.t_tiny_id
  , i_session_file_id  in     com_api_type_pkg.t_long_id
) is
    l_mpu_fin_rec             cst_mpu_api_type_pkg.t_mpu_fin_mes_rec;
    l_msg_type                com_api_type_pkg.t_dict_value;
    l_oper_type               com_api_type_pkg.t_dict_value;
    l_pre_auth_date           date;
    l_pre_auth_sys_trace      com_api_type_pkg.t_dict_value;
    l_inst_id                 com_api_type_pkg.t_inst_id;
    l_auth_rec                aut_api_type_pkg.t_auth_rec;
    function get_field_num(
        i_start  in    com_api_type_pkg.t_tiny_id
      , i_length in    com_api_type_pkg.t_tiny_id
    ) return number is
    begin
        return to_number(trim(substr(i_tc_buffer, i_start, i_length))
                       , com_api_const_pkg.NUMBER_INT_FORMAT_DEFAULT
               );
    end;
    
    function get_field_char(
        i_start  in    com_api_type_pkg.t_tiny_id
      , i_length in    com_api_type_pkg.t_tiny_id
    ) return varchar2 is
    begin
        return trim(substr(i_tc_buffer, i_start, i_length) );
    end; 
begin
    trc_log_pkg.debug(i_text => 'process_settlement start');

    l_mpu_fin_rec.id               := null;
    l_mpu_fin_rec.inst_id          := i_mpu_file.inst_id;
    l_mpu_fin_rec.network_id       := i_mpu_file.network_id;
    l_mpu_fin_rec.is_incoming      := com_api_const_pkg.TRUE;
    l_mpu_fin_rec.is_reversal      := com_api_const_pkg.FALSE;
    l_mpu_fin_rec.is_matched       := com_api_const_pkg.FALSE;
    l_mpu_fin_rec.status           := net_api_const_pkg.CLEARING_MSG_STATUS_READY;
    l_mpu_fin_rec.file_id          := i_mpu_file.id;
    l_mpu_fin_rec.dispute_id       := null;
    l_mpu_fin_rec.original_id      := null;
    l_mpu_fin_rec.message_number   := null;
    l_mpu_fin_rec.record_type      := get_field_char(1, 3);
    l_mpu_fin_rec.card_number      := get_field_char(4, 19);
    l_mpu_fin_rec.proc_code        := get_field_char(23, 6);
    l_mpu_fin_rec.trans_amount     := get_field_num(29, 12);
    l_mpu_fin_rec.sttl_amount      := get_field_num(41, 12);
    l_mpu_fin_rec.sttl_rate        := get_field_num(53, 8);
    l_mpu_fin_rec.sys_trace_num    := get_field_char(77, 6);
    l_mpu_fin_rec.trans_date       := null;
    l_mpu_fin_rec.sttl_date        := get_field_char(89, 4);
    l_mpu_fin_rec.mcc              := get_field_char(127, 4);
    l_mpu_fin_rec.acq_inst_code    := get_field_char(105, 11);
    l_mpu_fin_rec.iss_bank_code    := get_field_char(232, 11);
    l_mpu_fin_rec.bnb_bank_code    := null;
    l_mpu_fin_rec.forw_inst_code   := get_field_char(116, 11);
    l_mpu_fin_rec.receiv_inst_code := get_field_char(221, 11);
    l_mpu_fin_rec.auth_number      := get_field_char(83,6);
    l_mpu_fin_rec.rrn              := get_field_char(93, 12);
    l_mpu_fin_rec.terminal_number  := get_field_char(131, 8);
    l_mpu_fin_rec.trans_currency   := get_field_char(61, 3);
    l_mpu_fin_rec.sttl_currency    := get_field_char(64, 3);
    l_mpu_fin_rec.acct_from        := null;
    l_mpu_fin_rec.acct_to          := null;
    l_mpu_fin_rec.mti              := null;
    l_mpu_fin_rec.trans_status     := null;

    l_mpu_fin_rec.service_fee_receiv   := get_field_num(252, 12);
    l_mpu_fin_rec.service_fee_pay      := get_field_num(264, 12);
    l_mpu_fin_rec.service_fee_interchg := null;
    l_mpu_fin_rec.pos_entry_mode       := null;
    l_mpu_fin_rec.sys_trace_num_orig   := null;
    l_mpu_fin_rec.pos_cond_code        := get_field_char(244, 2);
    l_mpu_fin_rec.merchant_number      := get_field_char(139, 15);
    l_mpu_fin_rec.merchant_name        := get_field_char(154, 40);
    l_mpu_fin_rec.accept_amount        := null;
    l_mpu_fin_rec.cardholder_trans_fee := null;
    trc_log_pkg.debug('before transmit_date, get_field_char(67, 10)='||get_field_char(67, 10));
    l_mpu_fin_rec.transmit_date        := 
        date_without_year( 
            i_date     => get_field_char(67, 10)
          , i_filedate => i_mpu_file.file_date
          , i_datemask => 'MMddhh24miss'
        );
    l_mpu_fin_rec.orig_trans_info      := get_field_char(194, 23);
    l_mpu_fin_rec.trans_features       := get_field_char(243, 1);
    l_mpu_fin_rec.merchant_country     := get_field_char(246, 3);
    l_mpu_fin_rec.auth_type            := get_field_char(249, 3);
    l_mpu_fin_rec.reason_code          := get_field_char(217, 4);
-------------
    -- we dont need search original for refund, because it is different operation, but we must find original for Completion.
    if l_mpu_fin_rec.orig_trans_info is not null and l_mpu_fin_rec.record_type != cst_mpu_api_const_pkg.RECORD_TYPE_SETTL_REFUND then
        
        l_pre_auth_date        := 
            date_without_year( 
                i_date     => substr(l_mpu_fin_rec.orig_trans_info, 4, 10)
              , i_filedate => i_mpu_file.file_date
              , i_datemask => 'mmddhh24miss'
            );
        l_pre_auth_sys_trace   := substr(l_mpu_fin_rec.orig_trans_info, 14,  6);

        trc_log_pkg.debug(i_text => 'Try to find pre auth for completion' );
        -- try to find pre-auth
        select min(o.id)
             , min(o.oper_type)
          into l_mpu_fin_rec.original_id
             , l_oper_type
          from aut_auth a
             , opr_operation o
             , opr_participant pi
             , opr_participant pa
             , opr_card c
         where a.id                        = o.id
           and pi.oper_id                  = o.id
           and pi.participant_type         = com_api_const_pkg.PARTICIPANT_ISSUER
           and pa.oper_id                  = o.id
           and pa.participant_type         = com_api_const_pkg.PARTICIPANT_ACQUIRER
           and c.oper_id                   = o.id 
           and c.participant_type          = com_api_const_pkg.PARTICIPANT_ISSUER
           and o.msg_type                  = opr_api_const_pkg.MESSAGE_TYPE_PREAUTHORIZATION
           and a.system_trace_audit_number = l_pre_auth_sys_trace
           and o.oper_date                 = l_pre_auth_date
           and o.terminal_number           = l_mpu_fin_rec.terminal_number 
           and c.card_number               = l_mpu_fin_rec.card_number;
        
        -- set correct message type
        l_msg_type := opr_api_const_pkg.MESSAGE_TYPE_COMPLETION;
        
        if l_mpu_fin_rec.original_id is null then
        
            l_mpu_fin_rec.status := net_api_const_pkg.CLEARING_MSG_STATUS_INVALID;
            g_error_flag  := com_api_type_pkg.TRUE; 
            
            trc_log_pkg.error(
                i_text         => 'ORIGINAL_OPERATION_IS_NOT_FOUND'
              , i_env_param1   => l_pre_auth_sys_trace
              , i_env_param2   => l_mpu_fin_rec.trans_date
              , i_env_param3   => l_mpu_fin_rec.terminal_number
            );        
        else
            trc_log_pkg.debug(
                i_text          => 'Pre auth is found [' || l_mpu_fin_rec.original_id || ']'
            );            
        end if;
    end if;
    
    -- Determine that we is Acquirer via l_mpu_fin_rec.acq_inst_code
    l_inst_id := cmn_api_standard_pkg.find_value_owner(
        i_standard_id  => i_standard_id
      , i_entity_type  => net_api_const_pkg.ENTITY_TYPE_HOST
      , i_object_id    => i_host_id
      , i_param_name   => cst_mpu_api_const_pkg.MPU_BUSINESS_ID
      , i_value_char   => l_mpu_fin_rec.acq_inst_code
      , i_mask_error   => com_api_type_pkg.TRUE
      , i_masked_level => trc_config_pkg.DEBUG
    );
    -- for Acquirer we dont need to create operation. We should only match with original operation
    if l_inst_id is null then    

        create_operation(
            io_mpu_fin_rec       => l_mpu_fin_rec
          , i_auth_rec           => l_auth_rec  
          , i_standard_id        => i_standard_id
          , i_incom_sess_file_id => i_session_file_id
          , i_oper_type          => l_oper_type
          , i_msg_type           => l_msg_type
        );    
    else
        -- match record with operation
        l_oper_type :=  get_original(i_mpu_fin_rec  => l_mpu_fin_rec );
           
        if l_mpu_fin_rec.original_id is not null then
            
            trc_log_pkg.debug(i_text => 'Original operation is found [' || l_mpu_fin_rec.original_id || ', oper_type='||l_oper_type||']' );
            l_mpu_fin_rec.is_matched := com_api_const_pkg.TRUE;
        else
            trc_log_pkg.debug(i_text => 'Original operation is not found ' );
            g_error_flag  := com_api_type_pkg.TRUE; 
            l_mpu_fin_rec.status := net_api_const_pkg.CLEARING_MSG_STATUS_INVALID;
        end if;        
    end if;
    
    -- put message    
    l_mpu_fin_rec.id := cst_mpu_api_fin_message_pkg.put_message(
        i_fin_rec => l_mpu_fin_rec
    );

    trc_log_pkg.debug(
        i_text          => 'process_settlement end'
    );

exception
    when others then
        trc_log_pkg.debug(
            i_text          => sqlerrm
        );
        g_error_flag  := com_api_type_pkg.TRUE; 
        l_mpu_fin_rec.status := net_api_const_pkg.CLEARING_MSG_STATUS_INVALID;
end;

procedure process_dispute(
    i_tc_buffer             in      varchar2
  , i_mpu_file              in      cst_mpu_api_type_pkg.t_mpu_file_rec
  , i_standard_id           in      com_api_type_pkg.t_tiny_id
  , i_session_file_id       in      com_api_type_pkg.t_long_id
) is
    l_mpu_fin_rec                   cst_mpu_api_type_pkg.t_mpu_fin_mes_rec;
    l_msg_type                      com_api_type_pkg.t_dict_value;
    l_oper_type                     com_api_type_pkg.t_dict_value;
    l_auth_rec                      aut_api_type_pkg.t_auth_rec;
    function get_field_num(
        i_start  in    com_api_type_pkg.t_tiny_id
      , i_length in    com_api_type_pkg.t_tiny_id
    ) return number is
    begin
        return to_number(trim(substr(i_tc_buffer, i_start, i_length))
                       , com_api_const_pkg.NUMBER_INT_FORMAT_DEFAULT
               );
    end;
    
    function get_field_char(
        i_start  in    com_api_type_pkg.t_tiny_id
      , i_length in    com_api_type_pkg.t_tiny_id
    ) return varchar2 is
    begin
        return trim(substr(i_tc_buffer, i_start, i_length) );
    end; 
begin
    trc_log_pkg.debug(i_text => 'process_dispute start' );

    l_mpu_fin_rec.inst_id         := i_mpu_file.inst_id;
    l_mpu_fin_rec.network_id      := i_mpu_file.network_id;
    l_mpu_fin_rec.is_incoming     := com_api_const_pkg.TRUE;
    l_mpu_fin_rec.is_reversal     := com_api_const_pkg.FALSE;
    l_mpu_fin_rec.is_matched      := com_api_const_pkg.FALSE;
    l_mpu_fin_rec.file_id         := i_mpu_file.id;
    l_mpu_fin_rec.card_number     := get_field_char(4, 19);
    l_mpu_fin_rec.record_type     := get_field_char(1, 3);
    l_mpu_fin_rec.card_number     := get_field_char(4, 19);
    l_mpu_fin_rec.proc_code       := get_field_char(23, 6);
    l_mpu_fin_rec.trans_amount    := get_field_num(29, 12);
    l_mpu_fin_rec.sttl_amount     := get_field_num(41, 12);
    l_mpu_fin_rec.sttl_rate       := get_field_num(53, 8);
    l_mpu_fin_rec.sys_trace_num   := get_field_char(77, 6);
    l_mpu_fin_rec.orig_trans_info := get_field_char(194, 23);
    l_mpu_fin_rec.trans_date      := 
        date_without_year( 
            i_date     => substr(   l_mpu_fin_rec.orig_trans_info, 4, 10)
          , i_filedate => i_mpu_file.file_date
          , i_datemask => 'mmddhh24miss'
        );
  
    l_mpu_fin_rec.sttl_date      := 
        date_without_year( 
            i_date     => get_field_char(89, 4)
          , i_filedate => i_mpu_file.file_date
          , i_datemask => 'mmdd'
        );

    l_mpu_fin_rec.mcc                  := get_field_char(127, 4);
    l_mpu_fin_rec.acq_inst_code        := get_field_char(105, 11);
    l_mpu_fin_rec.iss_bank_code        := get_field_char(232, 11);
    l_mpu_fin_rec.bnb_bank_code        := null;
    l_mpu_fin_rec.forw_inst_code       := get_field_char(116, 11);
    l_mpu_fin_rec.receiv_inst_code     := get_field_char(221, 11);
    l_mpu_fin_rec.auth_number          := get_field_char(83, 6);
    l_mpu_fin_rec.rrn                  := get_field_char(93, 12);
    l_mpu_fin_rec.terminal_number      := get_field_char(131, 8);
    l_mpu_fin_rec.trans_currency       := get_field_char(61, 3);
    l_mpu_fin_rec.sttl_currency        := get_field_char(64, 3);
    l_mpu_fin_rec.acct_from            := null;
    l_mpu_fin_rec.acct_to              := null;
    l_mpu_fin_rec.mti                  := null;
    l_mpu_fin_rec.trans_status         := net_api_const_pkg.CLEARING_MSG_STATUS_READY;
    l_mpu_fin_rec.service_fee_receiv   := get_field_num(252, 12);
    l_mpu_fin_rec.service_fee_pay      := get_field_num(264, 12);
    l_mpu_fin_rec.service_fee_interchg := null;
    l_mpu_fin_rec.pos_entry_mode       := null;
    l_mpu_fin_rec.sys_trace_num_orig   := null;
    l_mpu_fin_rec.pos_cond_code        := get_field_char(244, 2);
    l_mpu_fin_rec.merchant_number      := get_field_char(139, 15);
    l_mpu_fin_rec.merchant_name        := get_field_char(154, 40);
    l_mpu_fin_rec.accept_amount        := null;
    l_mpu_fin_rec.cardholder_trans_fee := null;
    l_mpu_fin_rec.transmit_date        :=   
        date_without_year( 
            i_date     => get_field_char(67, 10)
          , i_filedate => i_mpu_file.file_date
          , i_datemask => 'mmddhh24miss'
        );
    l_mpu_fin_rec.orig_trans_info      := null;
    l_mpu_fin_rec.trans_features       := get_field_char(243, 1);
    l_mpu_fin_rec.merchant_country     := get_field_char(246, 3);
    l_mpu_fin_rec.auth_type            := get_field_char(249, 3);
    l_mpu_fin_rec.reason_code          := get_field_char(217, 4);


    -- get dispute_id 
    assign_dispute_id(
        io_mpu_fin_rec     => l_mpu_fin_rec
      , o_auth             => l_auth_rec
      , i_mask_error       => com_api_const_pkg.FALSE
    );

    create_operation(
        io_mpu_fin_rec       => l_mpu_fin_rec
      , i_auth_rec           => l_auth_rec  
      , i_standard_id        => i_standard_id
      , i_incom_sess_file_id => i_session_file_id
      , i_oper_type          => l_oper_type
      , i_msg_type           => l_msg_type
    );        
       
    -- put message    
    l_mpu_fin_rec.id := cst_mpu_api_fin_message_pkg.put_message(
        i_fin_rec => l_mpu_fin_rec
    );

    trc_log_pkg.debug(
        i_text          => 'process_dispute end'
    );

exception
    when others then
        trc_log_pkg.debug(
            i_text          => sqlerrm
        );
        g_error_flag  := com_api_type_pkg.TRUE;
        l_mpu_fin_rec.status := net_api_const_pkg.CLEARING_MSG_STATUS_INVALID;
end;
/*
 * Record_types are: 901(Incoming STF statistics) or 902(Outgoing STF statistics)
 * This record type is required to create operation 
*/
procedure process_fund_statistics(
    i_tc_buffer        in     varchar2
  , i_mpu_file         in     cst_mpu_api_type_pkg.t_mpu_file_rec
  , i_network_id       in     com_api_type_pkg.t_tiny_id
) is
    l_mpu_fund         cst_mpu_api_type_pkg.t_mpu_fund_sttl_rec;
    function get_field_num(
        i_start  in    com_api_type_pkg.t_tiny_id
      , i_length in    com_api_type_pkg.t_tiny_id
    ) return number is
    begin
        return to_number(trim(substr(i_tc_buffer, i_start, i_length))
                       , com_api_const_pkg.NUMBER_INT_FORMAT_DEFAULT
               );
    end;
    
    function get_field_char(
        i_start  in    com_api_type_pkg.t_tiny_id
      , i_length in    com_api_type_pkg.t_tiny_id
    ) return varchar2 is
    begin
        return trim(substr(i_tc_buffer, i_start, i_length) );
    end; 
begin
    trc_log_pkg.debug(i_text => 'process_fund_statistics start');
    l_mpu_fund.id                := null;
    l_mpu_fund.inst_id           := i_mpu_file.inst_id;
    l_mpu_fund.network_id        := i_network_id;
    l_mpu_fund.status            := cst_mpu_api_const_pkg.MPU_MSG_STATUS_UPLOADED;
    l_mpu_fund.file_id           := i_mpu_file.session_file_id;
    l_mpu_fund.record_type       := get_field_char(1, 3);  
    l_mpu_fund.member_inst_code  := get_field_char(4, 11);
    l_mpu_fund.out_amount_sign   := get_field_char(15, 1);
    l_mpu_fund.out_amount        := get_field_num(16, 16);
    l_mpu_fund.out_fee_sign      := get_field_char(32, 1);
    l_mpu_fund.out_fee_amount    := get_field_num(33, 16);
    l_mpu_fund.in_amount_sign    := get_field_char(49, 1);
    l_mpu_fund.in_amount         := get_field_num(50, 16);
    l_mpu_fund.in_fee_sign       := get_field_char(66, 1);
    l_mpu_fund.in_fee_amount     := get_field_num(67, 16);
    l_mpu_fund.stf_amount_sign   := get_field_char(83, 1);
    l_mpu_fund.stf_amount        := get_field_num(84, 16);
    l_mpu_fund.stf_fee_sign      := get_field_char(100, 1);
    l_mpu_fund.stf_fee_amount    := get_field_num(101, 16);
    l_mpu_fund.out_summary       := get_field_num(117, 10);
    l_mpu_fund.in_summary        := get_field_num(127, 10);
    l_mpu_fund.sttl_currency     := get_field_char(137, 3);
    
    cst_mpu_api_fin_message_pkg.put_fund_stat(
        i_fund_stat => l_mpu_fund
    ); 
    trc_log_pkg.debug(i_text => 'process_fund_statistics end');
end;

procedure process_volume_statistics(
    i_tc_buffer        in     varchar2
  , i_mpu_file         in     cst_mpu_api_type_pkg.t_mpu_file_rec
) is
    l_volume_stat   cst_mpu_api_type_pkg.t_mpu_volume_stat_rec;
    function get_field_num(
        i_start  in    com_api_type_pkg.t_tiny_id
      , i_length in    com_api_type_pkg.t_tiny_id
    ) return number is
    begin
        return to_number(trim(substr(i_tc_buffer, i_start, i_length))
                       , com_api_const_pkg.NUMBER_INT_FORMAT_DEFAULT
               );
        exception
            when others then
                trc_log_pkg.debug('get_field_num: '||substr(i_tc_buffer, i_start, i_length)
                               ||', start='||i_start||', length='||i_length||' ' ||sqlerrm);
            raise;
    end;
    
    function get_field_char(
        i_start  in    com_api_type_pkg.t_tiny_id
      , i_length in    com_api_type_pkg.t_tiny_id
    ) return varchar2 is
    begin
        return trim(substr(i_tc_buffer, i_start, i_length) );
    end; 
begin
    trc_log_pkg.debug(i_text => 'process_volume_statistics start');

    l_volume_stat.id               := null;
    l_volume_stat.inst_id          := i_mpu_file.inst_id;
    l_volume_stat.network_id       := i_mpu_file.network_id;
    l_volume_stat.status           := cst_mpu_api_const_pkg.MPU_MSG_STATUS_UPLOADED;
    l_volume_stat.file_id          := i_mpu_file.session_file_id;
    l_volume_stat.record_type      := get_field_char(1, 3);
    l_volume_stat.member_inst_code := get_field_char(4, 11);
    l_volume_stat.sttl_currency    := get_field_char(15, 3);
    l_volume_stat.stat_trans_code  := get_field_char(18, 3);
    l_volume_stat.summary          := get_field_num(21, 10);
    l_volume_stat.credit_amount    := get_field_num(31, 16);
    l_volume_stat.debit_amount     := get_field_num(47, 16);
    cst_mpu_api_fin_message_pkg.put_volume_stat(
        i_volume_stat => l_volume_stat
    );
    
    trc_log_pkg.debug(i_text => 'process_volume_statistics end');
end;

procedure process_merchant_settlement(
    i_tc_buffer    in     varchar2
  , i_mpu_file     in     cst_mpu_api_type_pkg.t_mpu_file_rec
) is
    l_merchant_sttl_rec   cst_mpu_api_type_pkg.t_mpu_mrch_settlement_rec;
    function get_field_num(
        i_start  in    com_api_type_pkg.t_tiny_id
      , i_length in    com_api_type_pkg.t_tiny_id
    ) return number is
    begin
        return to_number(trim(substr(i_tc_buffer, i_start, i_length))
                       , com_api_const_pkg.NUMBER_INT_FORMAT_DEFAULT
               );
    end;
    
    function get_field_char(
        i_start  in    com_api_type_pkg.t_tiny_id
      , i_length in    com_api_type_pkg.t_tiny_id
    ) return varchar2 is
    begin
        return trim(substr(i_tc_buffer, i_start, i_length) );
    end;
begin
    l_merchant_sttl_rec.id                      := null;
    l_merchant_sttl_rec.inst_id                 := i_mpu_file.inst_id;
    l_merchant_sttl_rec.network_id              := i_mpu_file.network_id;
    l_merchant_sttl_rec.status                  := cst_mpu_api_const_pkg.MPU_MSG_STATUS_UPLOADED;
    l_merchant_sttl_rec.file_id                 := i_mpu_file.session_file_id;
    l_merchant_sttl_rec.record_type             := get_field_char(1, 3);
    l_merchant_sttl_rec.member_inst_code        := get_field_char(4, 11);
    l_merchant_sttl_rec.merchant_number         := get_field_char(15, 15);
    l_merchant_sttl_rec.in_amount_sign          := get_field_char(30, 1);
    l_merchant_sttl_rec.in_amount               := get_field_num(31, 16);
    l_merchant_sttl_rec.in_fee_sign             := get_field_char(47, 1);
    l_merchant_sttl_rec.in_fee_amount           := get_field_num(48, 16);
    l_merchant_sttl_rec.total_sttl_amount_sign  := get_field_char(64, 1);
    l_merchant_sttl_rec.total_sttl_amount       := get_field_num(65, 16);
    l_merchant_sttl_rec.in_summary              := get_field_num(81, 10);
    l_merchant_sttl_rec.sttl_currency           := get_field_char(91, 3);
    l_merchant_sttl_rec.mrch_sttl_account       := get_field_char(94, 30);

    cst_mpu_api_fin_message_pkg.put_merchant_settlement(
        i_merchant_sttl => l_merchant_sttl_rec
    );
end;

procedure load_clearing(
    i_network_id            in     com_api_type_pkg.t_tiny_id
)is
    l_mpu_file         cst_mpu_api_type_pkg.t_mpu_file_rec;
    l_host_id          com_api_type_pkg.t_tiny_id;
    l_standard_id      com_api_type_pkg.t_tiny_id;
    l_record_number    com_api_type_pkg.t_long_id := 0;
    l_errors_count     com_api_type_pkg.t_long_id := 0;
    l_estimated_count  com_api_type_pkg.t_long_id;
    l_trailer_loaded   com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE;
    l_header_loaded    com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE;
    l_session_id       com_api_type_pkg.t_long_id;
    l_record_type      com_api_type_pkg.t_curr_code;
    cursor cu_records_count is
        select count(1)
          from prc_file_raw_data a
             , prc_session_file b
         where b.session_id      = l_session_id
           and a.session_file_id = b.id;
begin
    trc_log_pkg.debug(
        i_text        => 'mpu_prc_incoming_pkg.load_clearing start. i_network_id [#1]'
      , i_env_param1  => i_network_id
    );

    prc_api_stat_pkg.log_start;

    l_session_id   := prc_api_session_pkg.get_session_id;

    -- get estimated count
    open cu_records_count;
    fetch cu_records_count into l_estimated_count;
    close cu_records_count;

    prc_api_stat_pkg.log_estimation(i_estimated_count  => l_estimated_count);

    trc_log_pkg.debug(i_text => 'estimation record = ' || l_estimated_count );

    -- get network communication standard
    l_host_id     := net_api_network_pkg.get_default_host(
                         i_network_id => i_network_id
                     );
    l_standard_id := net_api_network_pkg.get_offline_standard(
                         i_host_id => l_host_id
                     );

    trc_log_pkg.debug(
        i_text        => 'load_clearing: host_id [#1], standard_id [#2]'
      , i_env_param1  => l_host_id
      , i_env_param2  => l_standard_id
    );

    for p in(
        select id as session_file_id
             , record_count
             , file_name
          from prc_session_file
         where session_id = l_session_id
         order by id
    ) loop
        l_errors_count := 0;
        l_trailer_loaded := com_api_const_pkg.FALSE;
        l_header_loaded  := com_api_const_pkg.FALSE;

        begin
            savepoint sp_mpu_incoming_file;
            trc_log_pkg.debug(
                i_text          => 'file processing start: session_file_id [' || p.session_file_id || '] file_name = [' || p.file_name || ']'
            );

            for r in(
                select record_number
                     , raw_data
                  from prc_file_raw_data
                 where session_file_id = p.session_file_id
                 order by record_number
            )
            -- processing current file
            loop
                g_error_flag := com_api_const_pkg.FALSE;
                l_record_type := substr(r.raw_data, 1, 3);
                -- check header
                if l_header_loaded = com_api_const_pkg.FALSE 
                and l_record_type = cst_mpu_api_const_pkg.RECORD_TYPE_HEADER -- '000'
                then
                    process_file_header(
                        i_file_name       => p.file_name
                      , i_header_data     => r.raw_data
                      , i_network_id      => i_network_id
                      , i_standard_id     => l_standard_id
                      , i_host_id         => l_host_id
                      , o_mpu_file        => l_mpu_file
                      , i_session_file_id => p.session_file_id
                    );
                    l_header_loaded := com_api_const_pkg.TRUE;
                    l_record_number := l_record_number + 1;

                elsif l_record_type = cst_mpu_api_const_pkg.RECORD_TYPE_TRAILER then  --'001'
                    process_file_trailer(
                        i_trailer_data => r.raw_data
                      , io_mpu_file    => l_mpu_file
                    );
                    l_trailer_loaded := com_api_const_pkg.TRUE;
                    l_record_number := l_record_number + 1;
                    
                else
                    --process_presentment
                    if l_trailer_loaded = com_api_const_pkg.TRUE then
                        com_api_error_pkg.raise_error(
                            i_error          => 'PRESENTMENT_AFTER_TRAILER'
                          , i_env_param1     => p.session_file_id
                        );
                    end if;

                    if l_record_type = cst_mpu_api_const_pkg.RECORD_TYPE_AUDIT_TRAILER then 
                        -- SMS process_audit_trailer, all fields implemented 
                        process_audit_trailer(
                            i_tc_buffer     => r.raw_data
                          , i_mpu_file      => l_mpu_file
                        );                    
                    elsif l_record_type = cst_mpu_api_const_pkg.RECORD_TYPE_DISPUTE_TRAILER then
                        -- SMS process_dispute_trailer
                        process_dispute_trailer(
                            i_tc_buffer       => r.raw_data
                          , i_mpu_file        => l_mpu_file
                          , i_standard_id     => l_standard_id
                          , i_session_file_id => p.session_file_id
                        );    
                    elsif l_record_type in(cst_mpu_api_const_pkg.RECORD_TYPE_SETTLEMENT, cst_mpu_api_const_pkg.RECORD_TYPE_SETTL_REFUND) then
                        -- DMS process_settlement
                        process_settlement(
                            i_tc_buffer       => r.raw_data
                          , i_mpu_file        => l_mpu_file
                          , i_standard_id     => l_standard_id
                          , i_host_id         => l_host_id  
                          , i_session_file_id => p.session_file_id
                        );
                    elsif l_record_type = cst_mpu_api_const_pkg.RECORD_TYPE_IN_DISPUTE then
                        -- DMS process_dispute
                        process_dispute(
                            i_tc_buffer       => r.raw_data
                          , i_mpu_file        => l_mpu_file
                          , i_standard_id     => l_standard_id
                          , i_session_file_id => p.session_file_id
                        );                    
                    else
                        com_api_error_pkg.raise_error(
                            i_error      => 'CST_MPU_UNKNOWN_MESSAGE'
                          , i_env_param1 => substr(r.raw_data, 1, 3)
                        );                        
                    end if;

                    l_record_number := l_record_number + 1;
                end if;

                if g_error_flag = com_api_const_pkg.TRUE then
                    l_errors_count := l_errors_count + 1;
                end if;

                if mod(l_record_number, 100) = 0 then
                    prc_api_stat_pkg.log_current(
                        i_current_count  => l_record_number
                      , i_excepted_count => l_errors_count
                    );
                end if;

            end loop;

            -- check trailer exists
            if l_trailer_loaded = com_api_const_pkg.FALSE then
                com_api_error_pkg.raise_error(
                    i_error       => 'TRAILER_NOT_FOUND'
                  , i_env_param1  => p.session_file_id
                );
            end if;

            trc_log_pkg.debug(
                i_text          => 'file processing end'
            );
            prc_api_file_pkg.close_file(
                i_sess_file_id => p.session_file_id
              , i_status       => prc_api_const_pkg.FILE_STATUS_ACCEPTED
              , i_record_count => nvl(l_record_number, 0)
            );

        exception
            when com_api_error_pkg.e_application_error then
                rollback to sp_mpu_incoming_file;

                l_errors_count := l_errors_count + p.record_count;
                l_record_number := l_record_number + p.record_count;

                prc_api_stat_pkg.log_current(
                    i_current_count  => l_record_number
                  , i_excepted_count => l_errors_count
                );

                prc_api_file_pkg.close_file(
                    i_sess_file_id => p.session_file_id
                  , i_status       => prc_api_const_pkg.FILE_STATUS_REJECTED
                  , i_record_count => l_record_number
                );

                raise;
        end;

    end loop;

    prc_api_stat_pkg.log_end(
        i_processed_total   => l_record_number
      , i_excepted_total    => nvl(l_errors_count , 0)
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug(
        i_text          => 'cup_prc_incoming_pkg.load_clearing finish'
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
end load_clearing;
-- Develop process for load record_types 900, 901, 902, 903
procedure load_statistics_data(
    i_network_id  in     com_api_type_pkg.t_tiny_id
) is
    l_mpu_file           cst_mpu_api_type_pkg.t_mpu_file_rec;
    l_session_id         com_api_type_pkg.t_long_id;
    l_standard_id        com_api_type_pkg.t_tiny_id;
    l_host_id            com_api_type_pkg.t_tiny_id;
    l_estimated_count    com_api_type_pkg.t_long_id;
    l_errors_count       com_api_type_pkg.t_long_id;
    l_trailer_loaded     com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE;
    l_header_loaded      com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE;
    l_record_type        com_api_type_pkg.t_curr_code;
    l_record_number      com_api_type_pkg.t_long_id := 0;
   
    cursor cu_records_count is
    select count(1)
      from prc_file_raw_data a
         , prc_session_file b
     where b.session_id      = l_session_id
       and a.session_file_id = b.id;
begin
    prc_api_stat_pkg.log_start;

    l_session_id   := prc_api_session_pkg.get_session_id;
    
    trc_log_pkg.debug(
        i_text => 'cst_mpu_prc_incoming_pkg.load_statistics_data start'
    );
    -- get estimated count
    open cu_records_count;
    fetch cu_records_count into l_estimated_count;
    close cu_records_count;

    prc_api_stat_pkg.log_estimation(i_estimated_count  => l_estimated_count);

    trc_log_pkg.debug(i_text => 'estimation record = ' || l_estimated_count);
 -- get network communication standard
    l_host_id     := net_api_network_pkg.get_default_host(
                         i_network_id => i_network_id
                     );
    l_standard_id := net_api_network_pkg.get_offline_standard(
                         i_host_id => l_host_id
                     );

    trc_log_pkg.debug(
        i_text        => 'load_clearing: host_id [#1], standard_id [#2]'
      , i_env_param1  => l_host_id
      , i_env_param2  => l_standard_id
    );

    for p in(
        select id as session_file_id
             , record_count
             , file_name
          from prc_session_file
         where session_id = l_session_id
         order by id
    ) loop
        l_errors_count := 0;
        l_trailer_loaded := com_api_const_pkg.FALSE;
        l_header_loaded  := com_api_const_pkg.FALSE;

        begin
            savepoint sp_mpu_incoming_file;
            trc_log_pkg.debug(
                i_text => 'file processing start: session_file_id [' || p.session_file_id || '] file_name = [' || p.file_name || ']'
            );

            for r in(
                select record_number
                     , raw_data
                  from prc_file_raw_data
                 where session_file_id = p.session_file_id
                 order by record_number
            )
            -- processing current file
            loop
                g_error_flag := com_api_const_pkg.FALSE;
                l_record_type := substr(r.raw_data, 1, 3);
                -- check header
                if l_header_loaded = com_api_const_pkg.FALSE 
                and l_record_type = cst_mpu_api_const_pkg.RECORD_TYPE_HEADER -- '000'
                then
                    process_file_header(
                        i_file_name       => p.file_name
                      , i_header_data     => r.raw_data
                      , i_network_id      => i_network_id
                      , i_standard_id     => l_standard_id
                      , i_host_id         => l_host_id
                      , o_mpu_file        => l_mpu_file
                      , i_session_file_id => p.session_file_id
                    );
                    l_header_loaded :=  com_api_const_pkg.TRUE;
                elsif l_record_type = cst_mpu_api_const_pkg.RECORD_TYPE_TRAILER -- '001'
                then
                    process_file_trailer(
                        i_trailer_data  => r.raw_data
                      , io_mpu_file     => l_mpu_file
                    );
                    l_trailer_loaded := com_api_const_pkg.TRUE;
                elsif l_record_type in(cst_mpu_api_const_pkg.RECORD_TYPE_FUND_STAT)
                then
                    process_fund_statistics(
                        i_tc_buffer   => r.raw_data
                      , i_mpu_file    => l_mpu_file
                      , i_network_id  => i_network_id
                    );
                elsif l_record_type in(cst_mpu_api_const_pkg.RECORD_TYPE_VOL_STAT_IN
                                     , cst_mpu_api_const_pkg.RECORD_TYPE_VOL_STAT_OUT)
                then
                    process_volume_statistics(
                        i_tc_buffer   => r.raw_data
                      , i_mpu_file    => l_mpu_file
                    );
                elsif l_record_type in(cst_mpu_api_const_pkg.RECORD_TYPE_MRCH_STTL)                  
                then
                    process_merchant_settlement(
                        i_tc_buffer   => r.raw_data
                      , i_mpu_file    => l_mpu_file
                    );
                else
                    com_api_error_pkg.raise_error(
                        i_error      => 'CST_MPU_UNKNOWN_MESSAGE'
                      , i_env_param1 => substr(r.raw_data, 1, 3)
                    );                        
                end if;
            
                l_record_number := l_record_number + 1;

                if g_error_flag = com_api_const_pkg.TRUE then
                    l_errors_count := l_errors_count + 1;
                end if;

                if mod(l_record_number, 100) = 0 then
                    prc_api_stat_pkg.log_current(
                        i_current_count  => l_record_number
                      , i_excepted_count => l_errors_count
                    );
                end if;
            end loop;

            -- check trailer exists
            if l_trailer_loaded = com_api_const_pkg.FALSE then
                com_api_error_pkg.raise_error(
                    i_error       => 'TRAILER_NOT_FOUND'
                  , i_env_param1  => p.session_file_id
                );
            end if;

            trc_log_pkg.debug(i_text => 'file processing end');
        exception
            when com_api_error_pkg.e_application_error then
                rollback to sp_mpu_incoming_file;

                l_errors_count := l_errors_count + p.record_count;
                l_record_number := l_record_number + p.record_count;

                prc_api_stat_pkg.log_current(
                    i_current_count  => l_record_number
                  , i_excepted_count => l_errors_count
                );

                prc_api_file_pkg.close_file(
                    i_sess_file_id => p.session_file_id
                  , i_status       => prc_api_const_pkg.FILE_STATUS_REJECTED
                  , i_record_count => nvl(l_record_number, 0)
                );
                raise;
        end;

    end loop;

    prc_api_stat_pkg.log_end(
        i_processed_total   => l_record_number
      , i_excepted_total    => nvl(l_errors_count , 0)
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
    trc_log_pkg.debug(
        i_text => 'cst_mpu_prc_incoming_pkg.load_statistics_data end'
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

end cst_mpu_prc_incoming_pkg;
/
