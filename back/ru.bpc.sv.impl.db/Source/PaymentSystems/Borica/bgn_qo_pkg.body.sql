create or replace package body bgn_qo_pkg as
    
    QO_TRANS_PURCHASE_M             constant        com_api_type_pkg.t_tiny_id  :=  1;
    QO_TRANS_CREDIT_VAUCHER_M       constant        com_api_type_pkg.t_tiny_id  :=  2;
    QO_TRANS_CASH_ADVANCE_M         constant        com_api_type_pkg.t_tiny_id  :=  3;
    QO_TRANS_CASHBACK_M             constant        com_api_type_pkg.t_tiny_id  :=  4;
    QO_TRANS_PURCHASE_E             constant        com_api_type_pkg.t_tiny_id  := 11;
    QO_TRANS_CREDIT_VAUCHER_E       constant        com_api_type_pkg.t_tiny_id  := 12;
    QO_TRANS_CASH_ADVANCE_E         constant        com_api_type_pkg.t_tiny_id  := 13;
    QO_TRANS_CASHBACK_E             constant        com_api_type_pkg.t_tiny_id  := 14;
    QO_TRANS_OFFLINE                constant        com_api_type_pkg.t_tiny_id  := 15;
    QO_TRANS_SETTLEMENT             constant        com_api_type_pkg.t_tiny_id  := 21;
    
    QO_FILE_TEST                    constant        com_api_type_pkg.t_byte_char    := 'T';
    QO_FILE_REAL                    constant        com_api_type_pkg.t_byte_char    := 'R';

    QO_DATA_REVERSAL                constant        com_api_type_pkg.t_name := 'R';
    QO_DATA_NORMAL                  constant        com_api_type_pkg.t_name := 'N';
 
    QO_STRING_TYPE_HEAD             constant        com_api_type_pkg.t_byte_char := 'FH';
    QO_STRING_TYPE_DATA             constant        com_api_type_pkg.t_byte_char := 'RD';
    QO_STRING_TYPE_BOTTOM           constant        com_api_type_pkg.t_byte_char := 'FT';
    
    QO_REQUEST_LABEL                constant        com_api_type_pkg.t_name := 'SETTLREQST';
    
    g_prev_string_type              com_api_type_pkg.t_byte_char;
    g_session_file_id               com_api_type_pkg.t_long_id;
    g_record_number                 com_api_type_pkg.t_short_id;
    g_seq_number                    com_api_type_pkg.t_short_id;

function check_record (
    io_string           in out nocopy   com_api_type_pkg.t_full_desc
) return com_api_type_pkg.t_byte_char
is 
    l_result            com_api_type_pkg.t_byte_char;            
    l_expected          com_api_type_pkg.t_byte_char;
begin
    trc_log_pkg.debug(
        i_text          => 'bgn_qo_pkg.check_record'
    );
    
    if g_record_number = 1 then
        g_prev_string_type := null;
        
    end if;
    
    if length(io_string) != 300 then
        com_api_error_pkg.raise_error(
            i_error         => 'BGN_WRONG_STRING_LENGTH'
          , i_entity_type   => prc_api_const_pkg.ENTITY_TYPE_SESSION_FILE
          , i_object_id     => g_session_file_id
          , i_env_param1    => g_record_number 
          , i_env_param2    => 300 
        );
        
    end if;
    
    l_result := substr(io_string, 1, 2);
    
    if g_prev_string_type = QO_STRING_TYPE_BOTTOM then
        com_api_error_pkg.raise_error(
            i_error         => 'BGN_RECORDS_AFTER_FOOTER'
          , i_entity_type   => prc_api_const_pkg.ENTITY_TYPE_SESSION_FILE
          , i_object_id     => g_session_file_id
          , i_env_param1    => g_record_number 
        );
        
    end if;
    
    case l_result
    when QO_STRING_TYPE_HEAD then
        if g_record_number > 1 then
            com_api_error_pkg.raise_error(
                i_error         => 'BGN_WRONG_STRING_IDENTIFICATOR'
              , i_entity_type   => prc_api_const_pkg.ENTITY_TYPE_SESSION_FILE
              , i_object_id     => g_session_file_id
              , i_env_param1    => g_record_number
              , i_env_param2    => QO_STRING_TYPE_DATA 
            );    
            
        end if;
        
    when QO_STRING_TYPE_DATA then    
        if g_record_number = 1 then
            com_api_error_pkg.raise_error(
                i_error         => 'BGN_WRONG_STRING_IDENTIFICATOR'
              , i_entity_type   => prc_api_const_pkg.ENTITY_TYPE_SESSION_FILE
              , i_object_id     => g_session_file_id
              , i_env_param1    => g_record_number
              , i_env_param2    => QO_STRING_TYPE_HEAD 
            );
            
        elsif g_prev_string_type not in (
            QO_STRING_TYPE_HEAD
          , QO_STRING_TYPE_DATA  
        ) then  
             com_api_error_pkg.raise_error(
                i_error         => 'BGN_WRONG_STRING_IDENTIFICATOR'
              , i_entity_type   => prc_api_const_pkg.ENTITY_TYPE_SESSION_FILE
              , i_object_id     => g_session_file_id
              , i_env_param1    => g_record_number
              , i_env_param2    => QO_STRING_TYPE_DATA 
            );
             
        end if;
        
    when QO_STRING_TYPE_BOTTOM then
        null;
        
    else
        if g_record_number = 1 then
            l_expected := QO_STRING_TYPE_HEAD;
            
        else    
            l_expected := QO_STRING_TYPE_DATA;
            
        end if;
        
        com_api_error_pkg.raise_error(
            i_error         => 'BGN_WRONG_STRING_IDENTIFICATOR'
          , i_entity_type   => prc_api_const_pkg.ENTITY_TYPE_SESSION_FILE
          , i_object_id     => g_session_file_id
          , i_env_param1    => g_record_number
          , i_env_param2    => l_expected 
        );        
                 
    end case;
    
    g_prev_string_type := l_result;
    
    return l_result;
end;

procedure process_title_of_file (
    io_string       in out nocopy   com_api_type_pkg.t_full_desc
  , io_file_rec     in out nocopy   bgn_api_type_pkg.t_bgn_file_rec  
)
is  
    l_file_number       com_api_type_pkg.t_tiny_id; 
begin
    trc_log_pkg.debug(
        i_text          => 'bgn_qo_pkg.process_title_of_file'
    );

    io_file_rec.file_label         := trim(substr(io_string, 3, 10));
    if io_file_rec.file_label != QO_REQUEST_LABEL then
        com_api_error_pkg.raise_error(
            i_error         => 'BGN_WRONG_FILE_LABEL'
          , i_entity_type   => prc_api_const_pkg.ENTITY_TYPE_SESSION_FILE
          , i_object_id     => g_session_file_id
          , i_env_param1    => g_record_number
          , i_env_param2    => QO_REQUEST_LABEL 
        );
            
    end if;
    
    io_file_rec.sender_code        := trim(substr(io_string, 13, 5));
    io_file_rec.receiver_code      := trim(substr(io_string, 18, 5));
    io_file_rec.file_number        := trim(substr(io_string, 23, 3));
    io_file_rec.test_option        := trim(substr(io_string, 26, 1));
    io_file_rec.creation_date      := to_date(substr(io_string, 27, 14), 'yyyymmddhh24miss');
    io_file_rec.gmt_offset         := case when instr(substr(io_string, 41, 4), 'GMT') = 1 then 
                                         --GMTn = -n hours
                                        -to_number(replace(substr(io_string, 41, 4), 'GMT')) 
                                      else 
                                         --nGMT = +n hours
                                         to_number(replace(substr(io_string, 41, 4), 'GMT')) 
                                      end;
    
    io_file_rec.bgn_sttl_type       := trim(substr(io_string, 45, 4));
    io_file_rec.sttl_currency       := trim(substr(io_string, 49, 3));
    io_file_rec.interface_version   := trim(substr(io_string, 52, 2));
    
    begin
        select file_number
          into l_file_number
          from bgn_file
         where file_type = io_file_rec.file_type
           and trunc(creation_date) = trunc(io_file_rec.creation_date)
           and file_number = io_file_rec.file_number
           and is_incoming = com_api_const_pkg.TRUE;
        
        com_api_error_pkg.raise_error(
            i_error         => 'BGN_FILE_ALREADY_PROCESSED'
          , i_entity_type   => prc_api_const_pkg.ENTITY_TYPE_SESSION_FILE
          , i_object_id     => g_session_file_id
          , i_env_param1    => l_file_number
        );   
        
    exception
        when no_data_found then
            null;    
        
    end;
end;

procedure process_end_of_file (
    io_string       in out nocopy   com_api_type_pkg.t_full_desc
  , io_file_rec     in out nocopy   bgn_api_type_pkg.t_bgn_file_rec  
)
is
 begin
    trc_log_pkg.debug(
        i_text          => 'bgn_qo_pkg.process_end_of_file'
    );

    io_file_rec.debit_total            := trim(substr(io_string, 3, 6));
    io_file_rec.credit_total           := trim(substr(io_string, 9, 6));
    io_file_rec.debit_amount           := trim(substr(io_string, 15, 18));
    io_file_rec.credit_amount          := trim(substr(io_string, 33, 18));
    io_file_rec.debit_fee_amount       := trim(substr(io_string, 51, 18));
    io_file_rec.credit_fee_amount      := trim(substr(io_string, 69, 18));
    io_file_rec.net_amount             := trim(substr(io_string, 87, 19));
    io_file_rec.borica_sttl_date       := to_date(trim(substr(io_string, 106, 8)), 'yyyymmdd');
    
    bgn_api_fin_pkg.put_file_rec(
        i_file_rec          => io_file_rec
    );
    
end;

procedure register_operation (
    io_fin_rec          in out nocopy   bgn_api_type_pkg.t_bgn_fin_rec
) is
    l_oper                  opr_api_type_pkg.t_oper_rec;
    l_iss_part              opr_api_type_pkg.t_oper_part_rec;
    l_acq_part              opr_api_type_pkg.t_oper_part_rec;
begin
    trc_log_pkg.debug(
        i_text          => 'bgn_qo_pkg.register_operation'
    );
    
    --amounts and currencies
    l_oper.oper_amount              := io_fin_rec.transaction_amount;
    l_oper.oper_currency            := lpad(io_fin_rec.transaction_currency, 3, '0');
    l_oper.sttl_amount              := abs(io_fin_rec.sttl_amount);
    l_oper.sttl_currency            := '975';
    l_oper.oper_cashback_amount     := io_fin_rec.cashback_acq_amount;

    l_oper.terminal_type    := case io_fin_rec.mcc 
                               when '6011' then 
                                   acq_api_const_pkg.TERMINAL_TYPE_ATM
                               else 
                                   acq_api_const_pkg.TERMINAL_TYPE_POS
                               end;
    
    bgn_api_fin_pkg.fin_to_oper(
        io_fin_rec          => io_fin_rec
      , io_oper             => l_oper
      , io_iss_part         => l_iss_part
      , io_acq_part         => l_acq_part
      , i_session_file_id   => g_session_file_id
      , i_record_number     => g_record_number 
      , i_file_code         => 'QO'  
    );            
    
    if l_oper.is_reversal = com_api_const_pkg.TRUE then 
        l_oper.original_id  :=
            bgn_api_fin_pkg.get_original_for_reversal(
                io_oper         => l_oper
              , i_refnum        => io_fin_rec.original_trans_number
              , i_card_number   => l_iss_part.card_number
              , i_mask_error    => com_api_const_pkg.TRUE
            );
            
        if l_oper.original_id is null then
            io_fin_rec.is_invalid   := com_api_const_pkg.TRUE;
            l_oper.status           := opr_api_const_pkg.OPERATION_STATUS_MANUAL;
        end if;
    end if;   
    
    io_fin_rec.is_invalid   := nvl(io_fin_rec.is_invalid, com_api_const_pkg.FALSE);
            
    l_oper.originator_refnum    := io_fin_rec.transaction_number;
    
    io_fin_rec.id := bgn_api_fin_pkg.put_message(
        i_fin_rec           => io_fin_rec
    );
    
    l_oper.incom_sess_file_id   := g_session_file_id; 
        
    bgn_api_fin_pkg.create_operation(
        i_oper      => l_oper
      , i_iss_part  => l_iss_part
      , i_acq_part  => l_acq_part  
    );  
    
end register_operation;

function process_data_rec (
    io_data_string      in out nocopy   com_api_type_pkg.t_full_desc
  , io_file_rec         in out nocopy   bgn_api_type_pkg.t_bgn_file_rec  
) return com_api_type_pkg.t_boolean
is 
    l_data_rec          bgn_api_type_pkg.t_bgn_fin_rec;
begin
    l_data_rec.id           := opr_api_create_pkg.get_id;
    trc_log_pkg.set_object(
        i_entity_type   => opr_api_const_pkg.ENTITY_TYPE_OPERATION
      , i_object_id     => l_data_rec.id  
    );
    
    trc_log_pkg.debug(
        i_text          => 'bgn_qo_pkg.process_data_rec'
    );
    
    l_data_rec.inst_id      := io_file_rec.inst_id;
    l_data_rec.network_id   := io_file_rec.network_id;
    l_data_rec.file_id                   := io_file_rec.id;
    
    l_data_rec.record_number             := trim(substr(io_data_string, 3, 6));
    if l_data_rec.record_number != g_seq_number + 1 then
        trc_log_pkg.error(
            i_text          => 'Wrong record sequence number, expected [#2]; raw_data record [#1]'
          , i_entity_type   => prc_api_const_pkg.ENTITY_TYPE_SESSION_FILE
          , i_object_id     => g_session_file_id
          , i_env_param1    => g_record_number
          , i_env_param2    => g_seq_number + 1
        );
        l_data_rec.is_invalid   := com_api_const_pkg.TRUE;
        
    else
        g_seq_number := l_data_rec.record_number;
           
    end if; 
    
    l_data_rec.transaction_date          := to_date(substr(io_data_string, 9, 14), 'yyyymmddhh24miss');
    l_data_rec.transaction_type          := trim(substr(io_data_string, 23, 2));
    
    l_data_rec.is_reject                 := trim(substr(io_data_string, 25, 1));
    if l_data_rec.is_reject not in (
        QO_DATA_REVERSAL
      , QO_DATA_NORMAL  
    ) then
        trc_log_pkg.error(
            i_text          => 'Wrong test option field; raw_data record [#1]'
          , i_entity_type   => prc_api_const_pkg.ENTITY_TYPE_SESSION_FILE
          , i_object_id     => g_session_file_id
          , i_env_param1    => g_record_number
        );
        l_data_rec.is_invalid   := com_api_const_pkg.TRUE;
        
    end if;
    
    l_data_rec.card_number               := trim(substr(io_data_string, 26, 19));
    l_data_rec.card_seq_number           := trim(substr(io_data_string, 45, 3));
    l_data_rec.card_expire_date          := trim(substr(io_data_string, 48, 4));
    l_data_rec.transaction_amount        := trim(substr(io_data_string, 52, 18));
    l_data_rec.transaction_currency      := trim(substr(io_data_string, 70, 3));
    l_data_rec.auth_code                 := trim(substr(io_data_string, 73, 6));
    l_data_rec.trace_number              := trim(substr(io_data_string, 79, 6));
    l_data_rec.stan                      := l_data_rec.trace_number;
    l_data_rec.merchant_number           := trim(substr(io_data_string, 85, 15));
    l_data_rec.merchant_name             := trim(substr(io_data_string, 100, 25));
    l_data_rec.merchant_city             := trim(substr(io_data_string, 125, 13));
    l_data_rec.mcc                       := trim(substr(io_data_string, 138, 4));
    l_data_rec.terminal_number           := trim(substr(io_data_string, 142, 8));
    l_data_rec.pos_entry_mode            := trim(substr(io_data_string, 150, 4));
    l_data_rec.ain                       := trim(substr(io_data_string, 154, 11));
    l_data_rec.transaction_number        := trim(substr(io_data_string, 165, 20));
    l_data_rec.original_trans_number     := trim(substr(io_data_string, 185, 20));
    l_data_rec.sttl_amount               := trim(substr(io_data_string, 205, 19));
    l_data_rec.interbank_fee_amount      := trim(substr(io_data_string, 224, 19));
    l_data_rec.bank_card_id              := trim(substr(io_data_string, 243, 5));
    l_data_rec.cashback_acq_amount       := trim(substr(io_data_string, 248, 18));
    l_data_rec.ecommerce                 := trim(substr(io_data_string, 266, 3));
    l_data_rec.terminal_type             := trim(substr(io_data_string, 270, 2));
    
    l_data_rec.is_reversal  :=  case l_data_rec.is_reject 
                                when QO_DATA_REVERSAL then
                                    com_api_const_pkg.TRUE
                                else
                                    com_api_const_pkg.FALSE
                                end;
    
    l_data_rec.is_incoming  := io_file_rec.is_incoming;
    l_data_rec.status       := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;
    
    if rtrim(l_data_rec.original_trans_number, '0') is null then
        l_data_rec.original_trans_number := null;
        
    end if;
    
    if rtrim(l_data_rec.transaction_number, '0') is null then
        l_data_rec.transaction_number := null;
        
    end if;
    
    if l_data_rec.transaction_type = QO_TRANS_OFFLINE then
        l_data_rec.is_offline   := com_api_const_pkg.TRUE;
    else
        l_data_rec.is_offline   := com_api_const_pkg.FALSE;
    end if;
    
    l_data_rec.file_record_number   := g_record_number;
    
    register_operation(
        io_fin_rec          => l_data_rec
    );
    
    return nvl(l_data_rec.is_invalid, com_api_type_pkg.FALSE);
end;

procedure process_string(
    io_data             in out nocopy   com_api_type_pkg.t_raw_data
  , i_session_file_id   in              com_api_type_pkg.t_long_id
  , i_record_number     in              com_api_type_pkg.t_short_id
  , i_inst_id           in              com_api_type_pkg.t_inst_id
  , i_network_id        in              com_api_type_pkg.t_network_id
  , o_is_invalid           out          com_api_type_pkg.t_boolean
) is
    l_record_type           com_api_type_pkg.t_byte_char; 
    
begin
    trc_log_pkg.debug(
        i_text          => 'bgn_qo_pkg.process_string; session_file_id [#1], record_number [#2]'
      , i_env_param1    => i_session_file_id
      , i_env_param2    => i_record_number  
    );
    
    g_session_file_id   := i_session_file_id;
    g_record_number     := i_record_number;
    o_is_invalid        := com_api_const_pkg.FALSE;
    
    l_record_type   := check_record(
        io_string           => io_data
    );
    
    case l_record_type
    when QO_STRING_TYPE_HEAD then      
        process_title_of_file (
            io_string   => io_data
          , io_file_rec => bgn_prc_import_pkg.g_file_rec  
        );
        
        g_seq_number    := 0;
        
    when QO_STRING_TYPE_BOTTOM then
        process_end_of_file (
            io_string   => io_data
          , io_file_rec => bgn_prc_import_pkg.g_file_rec  
        );    
        
    when QO_STRING_TYPE_DATA then
        o_is_invalid := 
            process_data_rec (
                io_data_string  => io_data
              , io_file_rec     => bgn_prc_import_pkg.g_file_rec   
            );
            
        trc_log_pkg.clear_object;         
            
    end case;
    
end;

procedure export_header(
    io_line             in out nocopy   com_api_type_pkg.t_raw_data
  , i_session_file_id   in              com_api_type_pkg.t_long_id
  , i_network_id        in              com_api_type_pkg.t_network_id
  , i_inst_id           in              com_api_type_pkg.t_inst_id
  , i_host_inst_id      in              com_api_type_pkg.t_inst_id
  , io_file_rec         in out nocopy   bgn_api_type_pkg.t_bgn_file_rec
) is
    l_gmt_offset                        com_api_type_pkg.t_tiny_id;
    l_param_tab                         com_api_type_pkg.t_param_tab;
begin
    trc_log_pkg.debug(
        i_text          => 'bgn_qo_pkg.export_header start'
    );
    
    io_file_rec.id           := i_session_file_id;
    io_file_rec.file_type    := bgn_api_const_pkg.FILE_TYPE_BORICA_QO;
    io_file_rec.sender_code  := '59' || bgn_api_fin_pkg.get_borica_code(
        i_inst_id   => i_inst_id
    );
    io_file_rec.receiver_code  := '59' || bgn_api_const_pkg.BORICA_OWN_CODE;
    
    io_file_rec.test_option      := QO_FILE_REAL;
    io_file_rec.creation_date    := com_api_sttl_day_pkg.get_sysdate;
    
    begin
        l_gmt_offset    :=
            cmn_api_standard_pkg.get_number_value(
                i_inst_id           => i_inst_id
              , i_standard_id       => bgn_api_const_pkg.BGN_CLEARING_STANDARD
              , i_entity_type       => net_api_const_pkg.ENTITY_TYPE_HOST
              , i_object_id         => net_api_network_pkg.get_default_host(
                                            i_network_id    => i_network_id
                                        )
              , i_param_name        => 'GMT_OFFSET'
              , i_param_tab         => l_param_tab
            );
            
        if l_gmt_offset is null then
            l_gmt_offset    := to_number(substr(dbtimezone, 1, 1 ) || substr(dbtimezone, 3, 1 ));
        end if;            
            
    exception
        when com_api_error_pkg.e_application_error then
            l_gmt_offset    := to_number(substr(dbtimezone, 1, 1 ) || substr(dbtimezone, 3, 1 ));
    end;
    
    io_file_rec.gmt_offset       := l_gmt_offset;
    io_file_rec.bgn_sttl_type    := 'BNS0';
    io_file_rec.sttl_currency    := bgn_api_const_pkg.BGN_DEFAULT_CURRENCY;
    io_file_rec.interface_version    := '10';
   
    io_line := QO_STRING_TYPE_HEAD 
            || QO_REQUEST_LABEL
            || io_file_rec.sender_code
            || io_file_rec.receiver_code
            || lpad(io_file_rec.file_number, 3, '0')
            || io_file_rec.test_option
            || to_char(io_file_rec.sttl_date, 'yyyymmdd')
            || to_char(io_file_rec.creation_date, 'hh24miss')
            || case when io_file_rec.gmt_offset >= 0 then
                    --nGMT = +n hours    
                    io_file_rec.gmt_offset || 'GMT'
               else
                    --GMTn = -n hours
                    'GMT' || abs(io_file_rec.gmt_offset)  
               end
            || io_file_rec.bgn_sttl_type
            || io_file_rec.sttl_currency
            || io_file_rec.interface_version
            ;
        
    io_line := rpad(io_line, 300, ' ');
    
end; 

procedure export_fin(
    io_line             in out nocopy   com_api_type_pkg.t_raw_data
  , i_record_number     in              com_api_type_pkg.t_short_id
  , i_session_file_id   in              com_api_type_pkg.t_long_id
  , i_network_id        in              com_api_type_pkg.t_network_id
  , i_inst_id           in              com_api_type_pkg.t_inst_id
  , i_host_inst_id      in              com_api_type_pkg.t_inst_id
  , io_fin_rec          in out nocopy   bgn_api_type_pkg.t_bgn_fin_rec
  , io_file_rec         in out nocopy   bgn_api_type_pkg.t_bgn_file_rec
) is
begin
    trc_log_pkg.debug(
        i_text          => 'bgn_qo_pkg.export_fin'
    );
    
    io_line := QO_STRING_TYPE_DATA
        || lpad(i_record_number, 6, '0')
        || to_char(io_fin_rec.transaction_date, 'yyyymmddhh24miss')
        || lpad(io_fin_rec.transaction_type, 2, '0')
        || nvl(io_fin_rec.is_reject, 'N')
        || rpad(nvl(io_fin_rec.card_number, ' '), 19, ' ')
        || lpad(nvl(io_fin_rec.card_seq_number, '0'), 3, '0')
        || lpad(nvl(io_fin_rec.card_expire_date, '0'), 4, '0')
        || lpad(nvl(io_fin_rec.transaction_amount, '0'), 18, '0')
        || lpad(nvl(io_fin_rec.transaction_currency, '0'), 3, '0')
        || lpad(nvl(io_fin_rec.auth_code, '0'), 6, '0')
        || lpad(nvl(io_fin_rec.trace_number, '0'), 6, '0')
        || rpad(nvl(io_fin_rec.merchant_number, ' '), 15, ' ')
        || rpad(nvl(io_fin_rec.merchant_name, ' '), 25, ' ')
        || rpad(nvl(io_fin_rec.merchant_city, ' '), 13, ' ')
        || lpad(nvl(io_fin_rec.mcc, '0'), 4, '0')
        || rpad(nvl(io_fin_rec.terminal_number, ' '), 8, ' ')
        || lpad(nvl(io_fin_rec.pos_entry_mode, '0'), 4, '0')
        || lpad(nvl(io_fin_rec.ain, '0'), 11, '0')
        || lpad(nvl(io_fin_rec.transaction_number, '0'), 20, '0')
        || lpad(nvl(io_fin_rec.original_trans_number, '0'), 20, '0')
        || case when nvl(io_fin_rec.sttl_amount, 0) >= 0 then '+' else '-' end          --borica
        || lpad(nvl(abs(io_fin_rec.sttl_amount), '0'), 18, '0')                           --borica
        || case when nvl(io_fin_rec.interbank_fee_amount, 0) >= 0 then '+' else '-' end --borica
        || lpad(nvl(abs(io_fin_rec.interbank_fee_amount), '0'), 18, '0')                  --borica
        || lpad(nvl(io_fin_rec.bank_card_id, '0'), 5, '0')                                --borica
        || lpad(nvl(io_fin_rec.cashback_acq_amount, '0'), 18, '0')
        || lpad(nvl(io_fin_rec.ecommerce, '0'), 3, '0')
        || rpad(nvl(io_fin_rec.terminal_type, ' '), 2, ' ')
    ;
    
    io_line := rpad(io_line, 300, ' ');
    
    if io_fin_rec.is_reject = QO_DATA_REVERSAL and io_fin_rec.transaction_type not in (QO_TRANS_CREDIT_VAUCHER_E, QO_TRANS_CREDIT_VAUCHER_M)
    or io_fin_rec.is_reject != QO_DATA_REVERSAL and io_fin_rec.transaction_type in (QO_TRANS_CREDIT_VAUCHER_E, QO_TRANS_CREDIT_VAUCHER_M)
    then
        io_file_rec.debit_total     := nvl(io_file_rec.debit_total, 0) + 1;
        io_file_rec.debit_amount    := nvl(io_file_rec.debit_amount, 0) + io_fin_rec.transaction_amount;
    else
        io_file_rec.credit_total    := nvl(io_file_rec.credit_total, 0) + 1;
        io_file_rec.credit_amount   := nvl(io_file_rec.credit_amount, 0) + io_fin_rec.transaction_amount;
    end if;
    
end;

procedure export_end_of_file(
    io_line             in out nocopy   com_api_type_pkg.t_raw_data
  , i_session_file_id   in              com_api_type_pkg.t_long_id
  , i_network_id        in              com_api_type_pkg.t_network_id
  , i_inst_id           in              com_api_type_pkg.t_inst_id
  , i_host_inst_id      in              com_api_type_pkg.t_inst_id
  , io_file_rec         in out nocopy   bgn_api_type_pkg.t_bgn_file_rec   
) is
begin
    trc_log_pkg.debug(
        i_text          => 'bgn_qo_pkg.export_end_of_file'
    );
    
    trc_log_pkg.debug(
        i_text          => 'io_file_rec.file_number [#1], io_file_rec.is_incoming [#2]'
      , i_env_param1    => io_file_rec.file_number
      , i_env_param2    => io_file_rec.is_incoming    
    );
    
    io_line     := QO_STRING_TYPE_BOTTOM
        || lpad(nvl(io_file_rec.debit_total, 0), 6, 0)
        || lpad(nvl(io_file_rec.credit_total, 0), 6, 0)
        || lpad(nvl(io_file_rec.debit_amount, 0), 18, 0)
        || lpad(nvl(io_file_rec.credit_amount, 0), 18, 0)
        || lpad(nvl(io_file_rec.debit_fee_amount, 0), 18, 0)                    --borica
        || lpad(nvl(io_file_rec.credit_fee_amount, 0), 18, 0)                   --borica
        || case when nvl(io_file_rec.net_amount, 0) >= 0 then '+' else '-' end  --borica
        || lpad(abs(nvl(io_file_rec.net_amount, 0)), 18, '0')                   --borica
        ;
        
    io_line := rpad(io_line, 300, ' ');    
    
    trc_log_pkg.debug(
        i_text          => 'io_file_rec.file_number [#1]'
      , i_env_param1    => io_file_rec.file_number  
    );
    
    bgn_api_fin_pkg.put_file_rec(
        i_file_rec      => io_file_rec
    );
    
end;


procedure export_line(
    io_line             in out nocopy   com_api_type_pkg.t_raw_data
  , i_record_number     in              com_api_type_pkg.t_short_id
  , i_session_file_id   in              com_api_type_pkg.t_long_id
  , i_network_id        in              com_api_type_pkg.t_network_id
  , i_inst_id           in              com_api_type_pkg.t_inst_id
  , i_host_inst_id      in              com_api_type_pkg.t_inst_id
  , i_is_file_trail     in              com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
) is
    
begin
    trc_log_pkg.debug(
        i_text          => 'bgn_qo_pkg.export_line start'
    );
    
    if i_is_file_trail = com_api_const_pkg.TRUE then
        export_end_of_file(
            io_line             => io_line
          , i_session_file_id   => i_session_file_id
          , i_network_id        => i_network_id
          , i_inst_id           => i_inst_id
          , i_host_inst_id      => i_host_inst_id
          , io_file_rec         => bgn_prc_export_pkg.g_file_rec
        );
        
    else
        if i_record_number = 0 then
            export_header(
                io_line             => io_line
              , i_session_file_id   => i_session_file_id
              , i_network_id        => i_network_id
              , i_inst_id           => i_inst_id
              , i_host_inst_id      => i_host_inst_id
              , io_file_rec         => bgn_prc_export_pkg.g_file_rec
            );
        
        else
            export_fin(
                io_line             => io_line
              , i_record_number     => i_record_number
              , i_session_file_id   => i_session_file_id
              , i_network_id        => i_network_id
              , i_inst_id           => i_inst_id
              , i_host_inst_id      => i_host_inst_id
              , io_fin_rec          => bgn_prc_export_pkg.g_fin_rec
              , io_file_rec         => bgn_prc_export_pkg.g_file_rec
            );
            
        end if;    
        
    end if;
    
end;

end bgn_qo_pkg;
/
 