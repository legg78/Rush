create or replace package body amx_prc_outgoing_pkg as

BULK_LIMIT      constant integer := 1000;

procedure process_file_header(
    i_network_id            in     com_api_type_pkg.t_tiny_id
  , i_forw_inst_code        in     com_api_type_pkg.t_cmid
  , i_receiv_inst_code      in     com_api_type_pkg.t_cmid
  , i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_collection_only       in     com_api_type_pkg.t_boolean
  , i_action_code           in     com_api_type_pkg.t_curr_code  default null
  , i_session_file_id       in     com_api_type_pkg.t_long_id
  , o_file                     out amx_api_type_pkg.t_amx_file_rec
) is
    l_line                   com_api_type_pkg.t_text;
begin
    trc_log_pkg.debug (
        i_text         => 'amx_prc_outgoing_pkg.process_file_header start'
    );

    o_file.id                    := amx_file_seq.nextval;
    o_file.is_incoming           := com_api_type_pkg.FALSE;  
    o_file.is_rejected           := com_api_type_pkg.FALSE;       
    o_file.network_id            := i_network_id;      
    o_file.transmittal_date      := trunc(com_api_sttl_day_pkg.get_sysdate);    
    o_file.inst_id               := i_inst_id;   
    o_file.forw_inst_code        := i_forw_inst_code;    
    o_file.receiv_inst_code      := i_receiv_inst_code;       
    o_file.action_code           := i_action_code;  
    o_file.session_file_id       := i_session_file_id;
    o_file.func_code             := amx_api_const_pkg.FUNC_CODE_ACKNOWLEDGMENT;
           

    amx_api_file_pkg.generate_file_number (
        i_cmid                  => o_file.forw_inst_code
        , i_transmittal_date    => o_file.transmittal_date
        , i_inst_id             => o_file.inst_id
        , i_network_id          => o_file.network_id 
        , i_action_code         => o_file.action_code
        , i_func_code           => o_file.func_code
        , o_file_number         => o_file.file_number
    );    
    o_file.reject_code           := null;     
    o_file.receipt_file_id       := null;   
    o_file.reject_msg_id         := null;
   
    if i_collection_only = com_api_type_pkg.FALSE then
        -- counts for non-collection only
        o_file.msg_total             := 0;    
        o_file.credit_count          := 0;    
        o_file.debit_count           := 0;    
        o_file.credit_amount         := 0;    
        o_file.debit_amount          := 0;    
        o_file.total_amount          := 0; 
                
        l_line := l_line || amx_api_const_pkg.MTID_HEADER; --1
        l_line := l_line || rpad(' ', 107, ' '); --2
        l_line := l_line || nvl(to_char(o_file.transmittal_date, amx_api_const_pkg.FORMAT_OUT_DATE), amx_api_const_pkg.DEFAULT_DATE); --3
        l_line := l_line || nvl(to_char(o_file.transmittal_date, amx_api_const_pkg.FORMAT_OUT_TIME), amx_api_const_pkg.DEFAULT_TIME); --4
        l_line := l_line || rpad(' ', 86, ' '); --5
        l_line := l_line || rpad(o_file.forw_inst_code, 11, ' '); --6
        l_line := l_line || rpad(' ', 29, ' '); --7
        l_line := l_line || rpad(i_action_code, 3, ' '); --8
        l_line := l_line || rpad(' ', 719, ' '); --9
        l_line := l_line || rpad(' ', 26, ' '); --10
        l_line := l_line || lpad(o_file.file_number, 6, '0'); --11
        l_line := l_line || rpad(' ', 26, ' '); --12,13,14
        l_line := l_line || lpad('1', 8, '0'); --15
        l_line := l_line || rpad(nvl(o_file.receiv_inst_code, ' '), 11, ' '); --16
        l_line := l_line || rpad(' ', 228, ' '); --17
        l_line := l_line || rpad(' ', 40, ' '); --18
        l_line := l_line || rpad(' ', 82, ' '); --19
        
    else
        --collection only header
        l_line := l_line || amx_api_const_pkg.MTID_DC_HEADER;
        l_line := l_line || lpad(o_file.file_number, 6, '0');
        l_line := l_line || nvl(to_char(o_file.transmittal_date, amx_api_const_pkg.FORMAT_OUT_DATE), amx_api_const_pkg.DEFAULT_DATE); 
        l_line := l_line || nvl(to_char(o_file.transmittal_date, amx_api_const_pkg.FORMAT_OUT_TIME), amx_api_const_pkg.DEFAULT_TIME); 
        l_line := l_line || rpad(o_file.forw_inst_code, 11, ' '); --Originating Institution Identification Code set the same like Forwarding
        l_line := l_line || rpad(o_file.forw_inst_code, 11, ' '); 
        l_line := l_line || rpad(o_file.receiv_inst_code, 11, ' ');
        l_line := l_line || rpad(o_file.receiv_inst_code, 11, ' '); --Destination Institution Identification Code set the same like Receiving
        l_line := l_line || rpad(i_action_code, 3, ' ');
        l_line := l_line || lpad('1', 8, '0'); --message number
        l_line := l_line || rpad('ON-US.DTL.V2', 17, ' '); --File Name Code 
        l_line := l_line || rpad(' ', 40, ' ');
        l_line := l_line || rpad(' ', 1264, ' ');
    end if;
        
    if l_line is not null then
    
        prc_api_file_pkg.put_line(
            i_raw_data      => l_line
          , i_sess_file_id  => i_session_file_id
        );
    end if;    
    trc_log_pkg.debug (
        i_text         => 'amx_prc_outgoing_pkg.process_file_header end'
    );
end;

procedure process_file_trailer(
    i_rec_number            in     com_api_type_pkg.t_short_id   
  , i_session_file_id       in     com_api_type_pkg.t_long_id
  , i_collection_only       in     com_api_type_pkg.t_boolean
  , io_file                 in out amx_api_type_pkg.t_amx_file_rec
) is
    l_line                   com_api_type_pkg.t_text;
    l_total_amount           com_api_type_pkg.t_money;
begin
    trc_log_pkg.debug (
        i_text         => 'amx_prc_outgoing_pkg.process_file_trailer start'
    );

    if i_collection_only = com_api_type_pkg.FALSE then

        amx_api_file_pkg.format_trailer_counts_amounts(
            io_credit_count    => io_file.credit_count
            , io_debit_count   => io_file.debit_count
            , io_credit_amount => io_file.credit_amount
            , io_debit_amount  => io_file.debit_amount
            , io_total_amount  => io_file.total_amount
        );

        l_line := l_line || amx_api_const_pkg.MTID_TRAILER; --1
        l_line := l_line || rpad(' ', 107, ' '); --2
        l_line := l_line || nvl(to_char(io_file.transmittal_date, amx_api_const_pkg.FORMAT_OUT_DATE), amx_api_const_pkg.DEFAULT_DATE); --3
        l_line := l_line || nvl(to_char(io_file.transmittal_date, amx_api_const_pkg.FORMAT_OUT_TIME), amx_api_const_pkg.DEFAULT_TIME); --4
        l_line := l_line || rpad(' ', 86, ' '); --5
        l_line := l_line || rpad(io_file.forw_inst_code, 11, ' '); --6
        l_line := l_line || rpad(' ', 29, ' '); --7
        l_line := l_line || rpad(io_file.action_code, 3, ' '); --8
        l_line := l_line || rpad(' ', 635, ' '); --9
        l_line := l_line || lpad('0', 49, '0'); --10
        l_line := l_line || lpad(nvl(io_file.credit_count, '0'), 6, '0'); --11
        l_line := l_line || lpad(nvl(io_file.debit_count, '0'), 6, '0'); --12
        l_line := l_line || lpad(nvl(io_file.credit_amount, '0'), 16, '0'); --13
        l_line := l_line || lpad(nvl(io_file.debit_amount, '0'), 16, '0'); --14
        l_line := l_line || lpad(nvl(io_file.total_amount, '0'), 17, '0'); --15 in examples of amex-files in this position is total amount instead of hash
        l_line := l_line || lpad(io_file.file_number, 6, '0'); --16
        l_line := l_line || rpad(' ', 26, ' '); --17,18,19
        l_line := l_line || lpad(i_rec_number, 8, '0'); -- 20 message number
        l_line := l_line || rpad(io_file.receiv_inst_code, 11, ' '); --21
        l_line := l_line || rpad(' ', 228, ' '); --22
        l_line := l_line || rpad(' ', 40, ' '); --23
        l_line := l_line || rpad(' ', 82, ' '); --24
    else
        --collection only
        l_total_amount := io_file.total_amount;
        io_file.total_amount := 
                           case 
                               when length(l_total_amount) > amx_api_const_pkg.MAX_DIGIT_TOTAL_AMOUNT_FIELD
                               then to_number(substr(to_char(l_total_amount), -1*amx_api_const_pkg.MAX_DIGIT_TOTAL_AMOUNT_FIELD))
                               else l_total_amount
                           end;
        
        l_line := l_line || amx_api_const_pkg.MTID_DC_TRAILER;
        l_line := l_line || lpad(io_file.file_number, 6, '0');    
        l_line := l_line || nvl(to_char(io_file.transmittal_date, amx_api_const_pkg.FORMAT_OUT_DATE), amx_api_const_pkg.DEFAULT_DATE); 
        l_line := l_line || nvl(to_char(io_file.transmittal_date, amx_api_const_pkg.FORMAT_OUT_TIME), amx_api_const_pkg.DEFAULT_TIME); 
        l_line := l_line || rpad(io_file.forw_inst_code, 11, ' '); --Originating Institution Identification Code set the same like Forwarding
        l_line := l_line || rpad(io_file.forw_inst_code, 11, ' '); 
        l_line := l_line || rpad(io_file.receiv_inst_code, 11, ' ');
        l_line := l_line || rpad(io_file.receiv_inst_code, 11, ' '); --Destination Institution Identification Code set the same like Receiving
        l_line := l_line || rpad(io_file.action_code, 3, ' ');
        l_line := l_line || lpad(i_rec_number, 8, '0');    
        l_line := l_line || rpad('ON-US.DTL.V2', 17, ' '); --File Name Code 
        l_line := l_line || rpad(' ', 40, ' ');
        l_line := l_line || lpad(nvl(l_total_amount, '0'), 17, '0'); --in examples of amex-files in this position is total amount instead of hash
        l_line := l_line || rpad(' ', 1254, ' ');

    end if;
    
    if l_line is not null then
        prc_api_file_pkg.put_line(
            i_raw_data      => l_line
          , i_sess_file_id  => i_session_file_id
        );
    end if;    
    
    insert into amx_file (
        id              
        , is_incoming       
        , is_rejected           
        , network_id             
        , transmittal_date    
        , inst_id                 
        , forw_inst_code          
        , receiv_inst_code        
        , action_code             
        , file_number         
        , reject_code         
        , msg_total           
        , credit_count        
        , debit_count         
        , credit_amount        
        , debit_amount         
        , total_amount
        , session_file_id
        , func_code
    )
    values(
        io_file.id
        , io_file.is_incoming   
        , io_file.is_rejected       
        , io_file.network_id
        , io_file.transmittal_date
        , io_file.inst_id
        , io_file.forw_inst_code        
        , io_file.receiv_inst_code        
        , io_file.action_code        
        , io_file.file_number
        , io_file.reject_code
        , i_rec_number
        , io_file.credit_count
        , io_file.debit_count  
        , io_file.credit_amount 
        , io_file.debit_amount 
        , io_file.total_amount
        , io_file.session_file_id
        , io_file.func_code
    );    
    trc_log_pkg.debug (
        i_text         => 'amx_prc_outgoing_pkg.process_file_trailer end'
    );
    
end;

procedure process_presentment(
    i_fin_rec               in     amx_api_type_pkg.t_amx_fin_mes_rec    
  , io_file                 in out amx_api_type_pkg.t_amx_file_rec
  , i_rec_number            in     com_api_type_pkg.t_short_id
  , i_session_file_id       in     com_api_type_pkg.t_long_id
  , i_collection_only       in     com_api_type_pkg.t_boolean
) is
    l_line                   com_api_type_pkg.t_text;
    l_operation              opr_api_type_pkg.t_oper_rec;
    l_terminal_type          com_api_type_pkg.t_dict_value;
begin
    trc_log_pkg.debug (
        i_text         => 'amx_prc_outgoing_pkg.process_presentment start'
    );
    
    opr_api_operation_pkg.get_operation(
        i_oper_id    => i_fin_rec.id
      , o_operation  => l_operation
    );
    l_terminal_type  := l_operation.terminal_type;

    trc_log_pkg.debug (
        i_text       => 'mtid [' || i_fin_rec.mtid || '], func_code [' || i_fin_rec.func_code || '], terminal_type [' || l_terminal_type || ']'
    );

    if i_collection_only = com_api_type_pkg.FALSE then

        --FP&SP POS. ATM dont need to send
        l_line := l_line || i_fin_rec.mtid; --1 
        l_line := l_line || lpad(nvl(i_fin_rec.pan_length, '0'), 2, '0'); --2 
        l_line := l_line || rpad(nvl(i_fin_rec.card_number, ' '), 19, ' '); --3
        l_line := l_line || rpad(i_fin_rec.proc_code, 6, ' '); --4
        l_line := l_line || lpad(i_fin_rec.trans_amount, 15, '0');--5 
        l_line := l_line || lpad('0', 15, '0');--6
        l_line := l_line || lpad('0', 15, '0');--7
        l_line := l_line || rpad(' ', 12, ' ');--8            

        if l_terminal_type = acq_api_const_pkg.TERMINAL_TYPE_ATM then
            l_line := l_line || lpad(' ', 15, ' '); --9
        else
            l_line := l_line || lpad('0', 15, '0'); --9
        end if;

        l_line := l_line || rpad(' ', 8, ' ');--10    
        l_line := l_line || nvl(to_char(i_fin_rec.trans_date, amx_api_const_pkg.FORMAT_OUT_DATE), amx_api_const_pkg.DEFAULT_DATE); --11
        l_line := l_line || nvl(to_char(i_fin_rec.trans_date, amx_api_const_pkg.FORMAT_OUT_TIME), amx_api_const_pkg.DEFAULT_TIME);  --12
        l_line := l_line || rpad(nvl(i_fin_rec.card_expir_date, ' '), 4, ' '); --13 
        l_line := l_line || lpad('0', 4, '0'); --14
        l_line := l_line || nvl(to_char(i_fin_rec.capture_date, amx_api_const_pkg.FORMAT_OUT_DATE), amx_api_const_pkg.DEFAULT_DATE); --15
        l_line := l_line || rpad(nvl(i_fin_rec.mcc, ' '), 4, ' '); --16

        if l_terminal_type = acq_api_const_pkg.TERMINAL_TYPE_ATM then
            l_line := l_line || rpad('0', 9, '0'); --17
        else
            l_line := l_line || rpad(' ', 9, ' '); --17
        end if;

        l_line := l_line || i_fin_rec.pdc_1 || i_fin_rec.pdc_2 --18
                         || i_fin_rec.pdc_3 || i_fin_rec.pdc_4 
                         || i_fin_rec.pdc_5 || i_fin_rec.pdc_6 
                         || i_fin_rec.pdc_7 || i_fin_rec.pdc_8 
                         || i_fin_rec.pdc_9 || i_fin_rec.pdc_10
                         || i_fin_rec.pdc_11 || i_fin_rec.pdc_12;
        l_line := l_line || rpad(i_fin_rec.func_code, 3, ' '); --19
        l_line := l_line || rpad(nvl(i_fin_rec.reason_code, ' '), 4, ' '); --20 Message reason code for SP, for FP is null
        l_line := l_line || nvl(i_fin_rec.approval_code_length, '0'); --21
        l_line := l_line || nvl(to_char(i_fin_rec.iss_sttl_date, amx_api_const_pkg.FORMAT_OUT_DATE), '00000000'); --22

        if l_terminal_type = acq_api_const_pkg.TERMINAL_TYPE_ATM then
            l_line := l_line || '000'; --23
        else
            l_line := l_line || rpad(nvl(i_fin_rec.eci, ' '), 2, ' '); --23
            l_line := l_line || ' '; --24
        end if;

        l_line := l_line || lpad(nvl(i_fin_rec.fp_trans_amount, '0'), 15, '0'); --25
        l_line := l_line || rpad(i_fin_rec.ain, 11, ' '); --26
        l_line := l_line || rpad(i_fin_rec.apn, 11, ' '); --27
        l_line := l_line || rpad(i_fin_rec.arn, 23, ' '); --28
        l_line := l_line || rpad(nvl(i_fin_rec.approval_code, ' '), 6, ' '); --29
        l_line := l_line || ' '; --30
        l_line := l_line || rpad(' ', 2, ' '); --31
        l_line := l_line || rpad(nvl(i_fin_rec.terminal_number, ' '), 8, ' '); --32
        l_line := l_line || rpad(nvl(i_fin_rec.merchant_number, ' '), 15, ' '); --33
        l_line := l_line || rpad(nvl(i_fin_rec.merchant_name, ' '), 38, ' '); --34
        l_line := l_line || rpad(nvl(i_fin_rec.merchant_addr1, ' '), 38, ' '); --35
        l_line := l_line || rpad(nvl(i_fin_rec.merchant_addr2, ' '), 38, ' '); --36
        l_line := l_line || rpad(nvl(i_fin_rec.merchant_city, ' '), 21, ' '); --37
        l_line := l_line || rpad(nvl(i_fin_rec.merchant_postal_code, ' '), 15, ' '); --38
        l_line := l_line || rpad(nvl(i_fin_rec.merchant_country, ' '), 3, ' '); --39
        l_line := l_line || rpad(nvl(i_fin_rec.merchant_region, ' '), 3, ' '); --40

        l_line := l_line || lpad(nvl(i_fin_rec.iss_gross_sttl_amount, '0'), 15, '0'); --41 
        l_line := l_line || lpad(nvl(i_fin_rec.iss_rate_amount, '0'), 15, '0'); --42
        l_line := l_line || '000000000000000'; --43 9(7)v9(8)
        l_line := l_line || '000000000000000'; --44 9(7)v9(8)
        l_line := l_line || '000000000000000'; --45 9(7)v9(8)
        l_line := l_line || ' '; --46
        l_line := l_line || rpad(nvl(i_fin_rec.matching_key_type, ' '), 2, ' '); --47
        l_line := l_line || rpad(nvl(i_fin_rec.matching_key, ' '), 21, ' '); --48
        l_line := l_line || rpad(' ', 15, ' '); --49
        l_line := l_line || ' '; --50      
        l_line := l_line || lpad('0', 15, '0'); --51
        l_line := l_line || rpad(' ', 3, ' ');  --52
        l_line := l_line || '0'; --53   
        l_line := l_line || '0'; --54  
        l_line := l_line || lpad(nvl(i_fin_rec.iss_net_sttl_amount, '0'), 15, '0'); --55        
        l_line := l_line || '000000000000000'; --56 9(7)v9(8)       
        l_line := l_line || rpad(nvl(i_fin_rec.iss_sttl_currency, ' '), 3, ' '); --57           
        l_line := l_line || nvl(i_fin_rec.iss_sttl_decimalization, '0'); --58        
        l_line := l_line || rpad(nvl(i_fin_rec.fp_trans_currency, ' '), 3, ' '); --59 FP is null SP - fp_trans_currency   
        
        if i_fin_rec.func_code = amx_api_const_pkg.FUNC_CODE_FIRST_PRES then         
            l_line := l_line || nvl(i_fin_rec.trans_decimalization, '0');--60 FP
        else
            l_line := l_line || nvl(i_fin_rec.fp_trans_decimalization, '0');--60 SP
        end if;    
        
        l_line := l_line || lpad(nvl(i_fin_rec.fp_pres_amount, '0'), 15, '0');--61
        l_line := l_line || ltrim(replace(to_char(i_fin_rec.fp_pres_conversion_rate, '0000000.00000000'), '.')); --62
        l_line := l_line || rpad(nvl(i_fin_rec.fp_pres_currency, ' '), 3, ' '); --63   
        l_line := l_line || nvl(i_fin_rec.fp_pres_decimalization, '0'); --64       
        l_line := l_line || nvl(i_fin_rec.merchant_multinational, ' '); --65
        l_line := l_line || rpad(nvl(i_fin_rec.trans_currency, ' '), 3, ' '); --66   
        l_line := l_line || rpad(' ', 3, ' ');  --67    
        l_line := l_line || rpad(' ', 3, ' ');  --68    
        l_line := l_line || ' ';            --69
        l_line := l_line || nvl(i_fin_rec.add_acc_eff_type1, ' ');            --70
        l_line := l_line || lpad(nvl(i_fin_rec.add_amount1, '0'), 15, '0'); --71
        l_line := l_line || rpad(nvl(i_fin_rec.add_amount_type1, ' '), 3, ' '); --72
        l_line := l_line || nvl(i_fin_rec.add_acc_eff_type2, ' '); --73
        l_line := l_line || lpad(nvl(i_fin_rec.add_amount2, '0'), 15, '0'); --74
        l_line := l_line || rpad(nvl(i_fin_rec.add_amount_type2, ' '), 3, ' '); --75
        l_line := l_line || nvl(i_fin_rec.add_acc_eff_type3, ' '); --76
        l_line := l_line || lpad(nvl(i_fin_rec.add_amount3, '0'), 15, '0'); --77
        l_line := l_line || rpad(nvl(i_fin_rec.add_amount_type3, ' '), 3, ' '); --78
        l_line := l_line || nvl(i_fin_rec.add_acc_eff_type4, ' '); --79
        l_line := l_line || lpad(nvl(i_fin_rec.add_amount4, '0'), 15, '0'); --80
        l_line := l_line || rpad(nvl(i_fin_rec.add_amount_type4, ' '), 3, ' '); --81
        l_line := l_line || nvl(i_fin_rec.add_acc_eff_type5, ' '); --82
        l_line := l_line || lpad(nvl(i_fin_rec.add_amount5, '0'), 15, '0'); --83
        l_line := l_line || rpad(nvl(i_fin_rec.add_amount_type5, ' '), 3, ' '); --84

        if l_terminal_type = acq_api_const_pkg.TERMINAL_TYPE_ATM then
            l_line := l_line || ' '; --85
            l_line := l_line || rpad('0', 15, '0'); --86
            l_line := l_line || rpad(' ', 3, ' '); --87
        else
            l_line := l_line || nvl(trim(to_char(length(i_fin_rec.alt_merchant_number), '00')), '00'); --85
            l_line := l_line || rpad(nvl(i_fin_rec.alt_merchant_number, ' '), 15, ' '); --86
            l_line := l_line || rpad(' ', 2, ' ');  --87
        end if;

        if i_fin_rec.func_code = amx_api_const_pkg.FUNC_CODE_FIRST_PRES then         
            l_line := l_line || '00000000'; --88 FP - filler        
            l_line := l_line || '000000';   --89 FP - filler
        else
            l_line := l_line || nvl(to_char(i_fin_rec.fp_trans_date, amx_api_const_pkg.FORMAT_OUT_DATE), amx_api_const_pkg.DEFAULT_DATE); --88 SP fp_trans_date        
            l_line := l_line || nvl(to_char(i_fin_rec.fp_trans_date, amx_api_const_pkg.FORMAT_OUT_TIME), amx_api_const_pkg.DEFAULT_TIME); --89 SP fp_trans_date
        end if;             

        if l_terminal_type = acq_api_const_pkg.TERMINAL_TYPE_ATM then
            l_line := l_line || rpad(' ', 7, ' '); --90
        else
            l_line := l_line || rpad(' ', 4, ' '); --90
            l_line := l_line || rpad(nvl(i_fin_rec.icc_pin_indicator, ' '), 2, ' '); --91 should be null for FP&SP
            l_line := l_line || nvl(i_fin_rec.card_capability, ' '); --92
        end if;

        if i_fin_rec.func_code = amx_api_const_pkg.FUNC_CODE_FIRST_PRES then         
            l_line := l_line || '00000000'; --93 FP - filler        
            l_line := l_line || '000000';   --94 FP - filler
        else
            l_line := l_line || nvl(to_char(i_fin_rec.network_proc_date, amx_api_const_pkg.FORMAT_OUT_DATE), '00000000');   --93 SP network_proc_date
            l_line := l_line || nvl(to_char(i_fin_rec.network_proc_date, amx_api_const_pkg.FORMAT_OUT_TIME), amx_api_const_pkg.DEFAULT_TIME);     --94 SP network_proc_date
        end if;
        
        if i_fin_rec.func_code = amx_api_const_pkg.FUNC_CODE_FIRST_PRES then         
            l_line := l_line || '0';--95 FP
        else
            l_line := l_line || nvl(i_fin_rec.trans_decimalization, '0');--95 SP
        end if;    
        
        if l_terminal_type = acq_api_const_pkg.TERMINAL_TYPE_ATM then
            l_line := l_line || rpad('0', 15, '0'); --91
            l_line := l_line || rpad('0', 15, '0'); --92
            l_line := l_line || rpad('0', 15, '0'); --93
            l_line := l_line || rpad('0', 15, '0'); --94
            l_line := l_line || rpad('0', 15, '0'); --95
            l_line := l_line || rpad('0', 15, '0'); --96
        else
            l_line := l_line || rpad(' ', 90, ' '); --96
        end if;
        
        if i_fin_rec.func_code = amx_api_const_pkg.FUNC_CODE_FIRST_PRES then         
            l_line := l_line || rpad(nvl(i_fin_rec.program_indicator, ' '), 2, ' '); --97
        else
            l_line := l_line || rpad(' ', 2, ' '); --97
        end if;                
        l_line := l_line || rpad(nvl(i_fin_rec.tax_reason_code, ' '), 2, ' '); --98
        l_line := l_line || ' '; --99
        l_line := l_line || nvl(to_char(i_fin_rec.capture_date, amx_api_const_pkg.FORMAT_OUT_TIME), amx_api_const_pkg.DEFAULT_TIME);   --100  
        l_line := l_line || nvl(to_char(i_fin_rec.iss_sttl_date, amx_api_const_pkg.FORMAT_OUT_TIME), amx_api_const_pkg.DEFAULT_TIME);   --101       
             
        if i_fin_rec.func_code = amx_api_const_pkg.FUNC_CODE_FIRST_PRES then         
            l_line := l_line || '00000000'; --102 FP - filler        
            l_line := l_line || '000000';   --103 FP - filler
        else
            l_line := l_line || nvl(to_char(i_fin_rec.fp_network_proc_date, amx_api_const_pkg.FORMAT_OUT_DATE), '00000000');  --102 SP fp_network_proc_date
            l_line := l_line || nvl(to_char(i_fin_rec.fp_network_proc_date, amx_api_const_pkg.FORMAT_OUT_TIME), amx_api_const_pkg.DEFAULT_TIME);   --103 SP fp_network_proc_date
        end if;
        
        l_line := l_line || rpad(nvl(i_fin_rec.format_code, ' '), 2, ' '); --104

        if i_fin_rec.func_code = amx_api_const_pkg.FUNC_CODE_FIRST_PRES then         
            l_line := l_line || rpad(' ', 11, ' '); --105 FP filler
            l_line := l_line || rpad(nvl(i_fin_rec.media_code, ' '), 2, ' '); --106
        else
            l_line := l_line || rpad(nvl(i_fin_rec.iin, ' '), 11, ' '); --105 SP iin
            l_line := l_line || rpad(' ', 2, ' '); --106
        end if;
        
        l_line := l_line || '001'; --107                    
        l_line := l_line || rpad(nvl(i_fin_rec.merchant_location_text, ' '), 40, ' ');--108        

        if l_terminal_type = acq_api_const_pkg.TERMINAL_TYPE_ATM then
            l_line := l_line || rpad(' ', 2, ' '); --114
            l_line := l_line || rpad(' ', 23, ' '); --115
        else
            l_line := l_line || rpad(nvl(i_fin_rec.itemized_doc_code, ' '), 2, ' '); --109
            l_line := l_line || rpad(nvl(i_fin_rec.itemized_doc_ref_number, ' '), 23, ' '); --110
        end if;

        l_line := l_line || lpad(nvl(i_fin_rec.transaction_id, '0'), 15, '0');--111        
        l_line := l_line || lpad(nvl(i_fin_rec.ext_payment_data, '0'), 2, '0'); --112        
        l_line := l_line || rpad(' ', 9, ' '); --113        
        l_line := l_line || lpad(nvl(i_rec_number, '0'), 8, '0');--114  

        if i_fin_rec.func_code = amx_api_const_pkg.FUNC_CODE_FIRST_PRES then         
            l_line := l_line || rpad(' ', 11, ' '); --115 FP filler
        else
            l_line := l_line || rpad(nvl(i_fin_rec.ipn, ' '), 11, ' '); --115 SP ipn
        end if;
        
        l_line := l_line || rpad(' ', 180, ' ');--116
        l_line := l_line || rpad(nvl(i_fin_rec.invoice_number, ' '), 30, ' ');--117        

        if i_fin_rec.func_code = amx_api_const_pkg.FUNC_CODE_FIRST_PRES
        and i_fin_rec.merchant_discount_rate is not null then
            l_line := l_line || lpad(i_fin_rec.merchant_discount_rate, 15, ' '); --118 MDR
        else
            l_line := l_line || lpad(' ', 15, ' '); --118 SP filler
        end if;

        l_line := l_line || rpad(' ', 3, ' '); --119
        l_line := l_line || rpad(nvl(i_fin_rec.reject_reason_code, ' '), 40, ' ');--120
        l_line := l_line || rpad(' ', 82, ' '); --last fields

        -- add debit/credit
            if i_fin_rec.impact = 1 then
                io_file.credit_count  := io_file.credit_count + 1;
                io_file.credit_amount := io_file.credit_amount + i_fin_rec.trans_amount;
            elsif i_fin_rec.impact = -1 then
                io_file.debit_count   := io_file.debit_count + 1;
                io_file.debit_amount  := io_file.debit_amount + i_fin_rec.trans_amount;
            end if;
    else
        --collection FP&SP POS. ATM dont need to send
        l_line := l_line || i_fin_rec.mtid; --1 
        l_line := l_line || lpad(nvl(i_fin_rec.pan_length, '0'), 2, '0'); --2 
        l_line := l_line || rpad(nvl(i_fin_rec.card_number, ' '), 19, ' '); --3
        l_line := l_line || rpad(i_fin_rec.proc_code, 6, ' '); --4
        l_line := l_line || lpad(i_fin_rec.trans_amount, 15, '0');--5 
        l_line := l_line || lpad(' ', 15, ' ');--6
        l_line := l_line || lpad('0', 15, '0');--7
        l_line := l_line || rpad(' ', 12, ' ');--8            
        l_line := l_line || '000000000000000'; --9    
        l_line := l_line || rpad(' ', 8, ' ');--10    
        l_line := l_line || nvl(to_char(i_fin_rec.trans_date, amx_api_const_pkg.FORMAT_OUT_DATE), amx_api_const_pkg.DEFAULT_DATE); --11
        l_line := l_line || nvl(to_char(i_fin_rec.trans_date, amx_api_const_pkg.FORMAT_OUT_TIME), amx_api_const_pkg.DEFAULT_TIME);  --12
        l_line := l_line || rpad(' ', 8, ' ');--13    
        l_line := l_line || nvl(to_char(i_fin_rec.capture_date, amx_api_const_pkg.FORMAT_OUT_DATE), amx_api_const_pkg.DEFAULT_DATE); --14        
        l_line := l_line || rpad(nvl(i_fin_rec.mcc, ' '), 4, ' '); --15
        l_line := l_line || rpad(' ', 9, ' '); --16        
        l_line := l_line || i_fin_rec.pdc_1 || i_fin_rec.pdc_2 --17
                         || i_fin_rec.pdc_3 || i_fin_rec.pdc_4 
                         || i_fin_rec.pdc_5 || i_fin_rec.pdc_6 
                         || i_fin_rec.pdc_7 || i_fin_rec.pdc_8 
                         || i_fin_rec.pdc_9 || i_fin_rec.pdc_10
                         || i_fin_rec.pdc_11 || i_fin_rec.pdc_12;                         
        l_line := l_line || rpad(i_fin_rec.func_code, 3, ' '); --18
        l_line := l_line || rpad(' ', 4, ' '); --19
        l_line := l_line || nvl(i_fin_rec.approval_code_length, '0'); --20
        l_line := l_line || lpad('0', 8, '0'); --21
        l_line := l_line || lpad('0', 3, '0'); --22
        l_line := l_line || lpad(nvl(i_fin_rec.fp_trans_amount, '0'), 15, '0'); --23
        l_line := l_line || rpad(i_fin_rec.ain, 11, ' '); --24
        l_line := l_line || rpad(i_fin_rec.apn, 11, ' '); --25
        l_line := l_line || rpad(i_fin_rec.arn, 23, ' '); --26
        l_line := l_line || rpad(nvl(i_fin_rec.approval_code, ' '), 6, ' '); --27
        l_line := l_line || rpad(' ', 3, ' '); --28
        l_line := l_line || rpad(nvl(i_fin_rec.terminal_number, ' '), 8, ' '); --29
        l_line := l_line || rpad(nvl(i_fin_rec.merchant_number, ' '), 15, ' '); --30
        l_line := l_line || rpad(nvl(i_fin_rec.merchant_name, ' '), 38, ' '); --31
        l_line := l_line || rpad(nvl(i_fin_rec.merchant_addr1, ' '), 38, ' '); --32
        l_line := l_line || rpad(nvl(i_fin_rec.merchant_addr2, ' '), 38, ' '); --33
        l_line := l_line || rpad(nvl(i_fin_rec.merchant_city, ' '), 21, ' '); --34
        l_line := l_line || rpad(nvl(i_fin_rec.merchant_postal_code, ' '), 15, ' '); --35
        l_line := l_line || rpad(nvl(i_fin_rec.merchant_country, ' '), 3, ' '); --36
        l_line := l_line || rpad(nvl(i_fin_rec.merchant_region, ' '), 3, ' '); --37
        l_line := l_line || lpad('0', 15, '0'); --38
        l_line := l_line || lpad('0', 15, '0'); --39
        l_line := l_line || rpad(' ', 103, ' '); --40
        l_line := l_line || lpad('0', 2, '0'); --41
        l_line := l_line || lpad('0', 15, '0'); --42
        l_line := l_line || '000000000000000'; --43 9(7)v9(8)
        l_line := l_line || rpad(' ', 3, ' '); --44
        l_line := l_line || '0'; --45
        l_line := l_line || rpad(nvl(i_fin_rec.fp_trans_currency, ' '), 3, ' '); --46
        l_line := l_line || nvl(i_fin_rec.fp_trans_decimalization, '0');--47
        l_line := l_line || lpad(nvl(i_fin_rec.fp_pres_amount, '0'), 15, '0');--48
        l_line := l_line || ltrim(replace(to_char(i_fin_rec.fp_pres_conversion_rate, '0000000.00000000'), '.')); --49
        l_line := l_line || rpad(nvl(i_fin_rec.fp_pres_currency, ' '), 3, ' '); --50
        l_line := l_line || nvl(i_fin_rec.fp_pres_decimalization, '0'); --51       
        l_line := l_line || nvl(i_fin_rec.merchant_multinational, ' '); --52
        l_line := l_line || rpad(nvl(i_fin_rec.trans_currency, ' '), 3, ' '); --53   
        l_line := l_line || rpad(' ', 3, ' '); --54
        l_line := l_line || rpad(' ', 3, ' '); --55
        l_line := l_line || ' '; --56 
        l_line := l_line || nvl(i_fin_rec.add_acc_eff_type1, ' ');  --57
        l_line := l_line || lpad(nvl(i_fin_rec.add_amount1, '0'), 15, '0'); --58
        l_line := l_line || rpad(nvl(i_fin_rec.add_amount_type1, ' '), 3, ' '); --59
        l_line := l_line || nvl(i_fin_rec.add_acc_eff_type2, ' '); --60
        l_line := l_line || lpad(nvl(i_fin_rec.add_amount2, '0'), 15, '0'); --61
        l_line := l_line || rpad(nvl(i_fin_rec.add_amount_type2, ' '), 3, ' '); --62
        l_line := l_line || nvl(i_fin_rec.add_acc_eff_type3, ' '); --63
        l_line := l_line || lpad(nvl(i_fin_rec.add_amount3, '0'), 15, '0'); --64
        l_line := l_line || rpad(nvl(i_fin_rec.add_amount_type3, ' '), 3, ' '); --65
        l_line := l_line || nvl(i_fin_rec.add_acc_eff_type4, ' '); --66
        l_line := l_line || lpad(nvl(i_fin_rec.add_amount4, '0'), 15, '0'); --67
        l_line := l_line || rpad(nvl(i_fin_rec.add_amount_type4, ' '), 3, ' '); --68
        l_line := l_line || nvl(i_fin_rec.add_acc_eff_type5, ' '); --69
        l_line := l_line || lpad(nvl(i_fin_rec.add_amount5, '0'), 15, '0'); --70
        l_line := l_line || rpad(nvl(i_fin_rec.add_amount_type5, ' '), 3, ' '); --71
        l_line := l_line || nvl(trim(to_char(length(i_fin_rec.alt_merchant_number), '00')), '00'); --72              
        l_line := l_line || rpad(nvl(i_fin_rec.alt_merchant_number, ' '), 15, ' '); --73
        l_line := l_line || rpad(' ', 2, ' ');  --74    
        l_line := l_line || nvl(to_char(i_fin_rec.fp_trans_date, amx_api_const_pkg.FORMAT_OUT_DATE), amx_api_const_pkg.DEFAULT_DATE); --75        
        l_line := l_line || nvl(to_char(i_fin_rec.fp_trans_date, amx_api_const_pkg.FORMAT_OUT_TIME), amx_api_const_pkg.DEFAULT_TIME);   --76             
        l_line := l_line || rpad(' ', 4, ' '); --77       
        l_line := l_line || rpad(nvl(i_fin_rec.icc_pin_indicator, ' '), 2, ' '); --78           
        l_line := l_line || nvl(i_fin_rec.card_capability, ' '); --79
        l_line := l_line || lpad('0', 8, '0'); --80
        l_line := l_line || lpad('0', 6, '0'); --81
        l_line := l_line || nvl(i_fin_rec.trans_decimalization, '0');--82
        l_line := l_line || rpad(' ', 5, ' '); --83       
        l_line := l_line || nvl(to_char(i_fin_rec.capture_date, amx_api_const_pkg.FORMAT_OUT_TIME), amx_api_const_pkg.DEFAULT_TIME);   --84  
        l_line := l_line || lpad('0', 6, '0'); --85
        l_line := l_line || lpad('0', 8, '0'); --86
        l_line := l_line || lpad('0', 6, '0'); --87
        l_line := l_line || rpad(nvl(i_fin_rec.format_code, ' '), 2, ' '); --88
        l_line := l_line || rpad(nvl(i_fin_rec.iin, ' '), 11, ' '); --89
        l_line := l_line || rpad(nvl(i_fin_rec.media_code, ' '), 2, ' '); --90
        l_line := l_line || '001'; --91                   
        l_line := l_line || rpad(nvl(i_fin_rec.merchant_location_text, ' '), 40, ' ');--92        
        l_line := l_line || rpad(' ', 2, ' '); --93      
        l_line := l_line || rpad(' ', 23, ' '); --94       
        l_line := l_line || lpad('0', 15, '0'); --95
        l_line := l_line || lpad(nvl(i_fin_rec.ext_payment_data, '0'), 2, '0'); --96        
        l_line := l_line || rpad(' ', 9, ' ');  --97    
        l_line := l_line || lpad(nvl(i_rec_number, '0'), 8, '0');--98 
        l_line := l_line || rpad(nvl(i_fin_rec.ipn, ' '), 11, ' ');--99     
        l_line := l_line || rpad(' ', 180, ' '); --100
        l_line := l_line || rpad(nvl(i_fin_rec.invoice_number, ' '), 30, ' ');--101        
        l_line := l_line || rpad(' ', 15, ' ');  --102    
        l_line := l_line || rpad(' ', 3, ' ');  --103    
        l_line := l_line || rpad(nvl(i_fin_rec.reject_reason_code, ' '), 40, ' ');--104
        l_line := l_line || rpad(' ', 56, ' ');  --105    
        l_line := l_line || rpad(' ', 15, ' ');  --106    
        l_line := l_line || rpad(' ', 11, ' ');  --107    
    end if;

    if l_line is not null then
        prc_api_file_pkg.put_line(
            i_raw_data      => l_line
          , i_sess_file_id  => i_session_file_id
        );
    end if;    
    
    io_file.total_amount      := io_file.total_amount + i_fin_rec.trans_amount;
    trc_log_pkg.debug (
        i_text         => 'amx_prc_outgoing_pkg.process_presentment end'
    );
    
end;

procedure process_chargeback(
    i_fin_rec               in     amx_api_type_pkg.t_amx_fin_mes_rec    
  , io_file                 in out amx_api_type_pkg.t_amx_file_rec
  , i_rec_number            in     com_api_type_pkg.t_short_id
  , i_session_file_id       in     com_api_type_pkg.t_long_id
  , i_collection_only       in     com_api_type_pkg.t_boolean
) is
    l_line                   com_api_type_pkg.t_text;
begin
    trc_log_pkg.debug (
        i_text         => 'amx_prc_outgoing_pkg.process_chargeback start'
    );

    if i_collection_only = com_api_type_pkg.FALSE then
        --ChargeBack POS. ATM dont need to send
        l_line := l_line || i_fin_rec.mtid; --1 
        l_line := l_line || lpad(nvl(i_fin_rec.pan_length, '0'), 2, '0'); --2 
        l_line := l_line || rpad(nvl(i_fin_rec.card_number, ' '), 19, ' '); --3
        l_line := l_line || rpad(i_fin_rec.proc_code, 6, ' '); --4
        l_line := l_line || lpad(i_fin_rec.trans_amount, 15, '0');--5 
        l_line := l_line || rpad(' ', 65, ' ');--6                    
        l_line := l_line || nvl(to_char(i_fin_rec.trans_date, amx_api_const_pkg.FORMAT_OUT_DATE), amx_api_const_pkg.DEFAULT_DATE); --7
        l_line := l_line || nvl(to_char(i_fin_rec.trans_date, amx_api_const_pkg.FORMAT_OUT_TIME), amx_api_const_pkg.DEFAULT_TIME);  --8        
        l_line := l_line || rpad(nvl(i_fin_rec.card_expir_date, ' '), 4, ' '); --9         
        l_line := l_line || lpad('0', 4, '0');--10        
        l_line := l_line || nvl(to_char(i_fin_rec.capture_date, amx_api_const_pkg.FORMAT_OUT_DATE), amx_api_const_pkg.DEFAULT_DATE); --11
        l_line := l_line || rpad(nvl(i_fin_rec.mcc, ' '), 4, ' '); --12        
        l_line := l_line || rpad(' ', 21, ' ');--13            
        l_line := l_line || rpad(i_fin_rec.func_code, 3, ' '); --14
        l_line := l_line || rpad(nvl(i_fin_rec.reason_code, ' '), 4, ' '); --15        
        l_line := l_line || rpad(' ', 12, ' ');--16    
        l_line := l_line || lpad(nvl(i_fin_rec.fp_trans_amount, '0'), 15, '0'); --17        
        l_line := l_line || rpad(i_fin_rec.ain, 11, ' '); --18
        l_line := l_line || rpad(i_fin_rec.ipn, 11, ' '); --19
        l_line := l_line || rpad(i_fin_rec.arn, 23, ' '); --20        
        l_line := l_line || rpad(' ', 9, ' '); --21    
        l_line := l_line || rpad(nvl(i_fin_rec.terminal_number, ' '), 8, ' '); --22
        l_line := l_line || rpad(nvl(i_fin_rec.merchant_number, ' '), 15, ' '); --23
        l_line := l_line || nvl(trim(to_char(length(i_fin_rec.alt_merchant_number), '00')), '00'); --24              
        l_line := l_line || rpad(nvl(i_fin_rec.alt_merchant_number, ' '), 15, ' '); --25
        l_line := l_line || rpad(' ', 139, ' '); --26    
        l_line := l_line || rpad(' ', 15, ' '); --27    
        l_line := l_line || rpad(' ', 15, ' '); --28    
        l_line := l_line || rpad(' ', 104, ' '); --29
        l_line := l_line || ' '; --30    
        l_line := l_line || lpad(nvl(i_fin_rec.iss_net_sttl_amount, '0'), 15, '0');--31 
        l_line := l_line || '000000000000000'; --32 9(7)v9(8)       
        l_line := l_line || rpad(nvl(i_fin_rec.iss_sttl_currency, ' '), 3, ' '); --33   
        l_line := l_line || nvl(i_fin_rec.iss_sttl_decimalization, '0'); --34
        l_line := l_line || rpad(nvl(i_fin_rec.fp_trans_currency, ' '), 3, ' '); --35   
        l_line := l_line || nvl(i_fin_rec.fp_trans_decimalization, '0'); --36
        l_line := l_line || lpad(i_fin_rec.fp_pres_amount, 15, '0');--37 
        l_line := l_line || ltrim(replace(to_char(i_fin_rec.fp_pres_conversion_rate, '0000000.00000000'), '.'));    --38
        l_line := l_line || rpad(nvl(i_fin_rec.fp_pres_currency, ' '), 3, ' '); --39   
        l_line := l_line || nvl(i_fin_rec.fp_pres_decimalization, '0'); --40
        l_line := l_line || ' '; --41    
        l_line := l_line || rpad(nvl(i_fin_rec.trans_currency, ' '), 3, ' '); --42   
        l_line := l_line || rpad(' ', 3, ' '); --43    
        l_line := l_line || rpad(' ', 118, ' '); --44    
        l_line := l_line || nvl(to_char(i_fin_rec.fp_trans_date, amx_api_const_pkg.FORMAT_OUT_DATE), amx_api_const_pkg.DEFAULT_DATE); --45    
        l_line := l_line || nvl(to_char(i_fin_rec.fp_trans_date, amx_api_const_pkg.FORMAT_OUT_TIME), amx_api_const_pkg.DEFAULT_TIME); --46    
        l_line := l_line || rpad(' ', 7, ' ');--47    
        l_line := l_line || '00000000'; --48 filler        
        l_line := l_line || '000000';   --49 filler
        l_line := l_line || nvl(i_fin_rec.trans_decimalization, '0'); --50
        l_line := l_line || rpad(nvl(i_fin_rec.chbck_reason_text, ' '), 95, ' '); --51   
        l_line := l_line || nvl(to_char(i_fin_rec.capture_date, amx_api_const_pkg.FORMAT_OUT_TIME), amx_api_const_pkg.DEFAULT_TIME); --52  
        l_line := l_line || rpad(' ', 6, ' ');--53    
        l_line := l_line || nvl(to_char(i_fin_rec.fp_network_proc_date, amx_api_const_pkg.FORMAT_OUT_DATE), amx_api_const_pkg.DEFAULT_DATE); --54    
        l_line := l_line || nvl(to_char(i_fin_rec.fp_network_proc_date, amx_api_const_pkg.FORMAT_OUT_TIME), amx_api_const_pkg.DEFAULT_TIME); --55    
        l_line := l_line || rpad(' ', 2, ' ');--56    
        l_line := l_line || rpad(i_fin_rec.iin, 11, ' '); --57
        l_line := l_line || rpad(' ', 2, ' ');--58    
        l_line := l_line || '001'; --59
        l_line := l_line || rpad(' ', 40, ' ');--60    
        l_line := l_line || rpad(' ', 2, ' ');--61    
        l_line := l_line || rpad(' ', 23, ' ');--62    
        l_line := l_line || lpad(i_fin_rec.transaction_id, 15, '0');--63 
        l_line := l_line || rpad(' ', 11, ' ');--64    
        l_line := l_line || lpad(i_rec_number, 8, '0');--65
        l_line := l_line || rpad(i_fin_rec.apn, 11, ' '); --66
        l_line := l_line || rpad(' ', 228, ' ');--67    
        l_line := l_line || rpad(' ', 40, ' ');--68    
        l_line := l_line || rpad(' ', 82, ' ');--69           

        -- add debit/credit
        if i_fin_rec.impact = 1 then
            io_file.credit_count  := io_file.credit_count + 1;
            io_file.credit_amount := io_file.credit_amount + i_fin_rec.trans_amount;
        elsif i_fin_rec.impact = -1 then
            io_file.debit_count   := io_file.debit_count + 1;
            io_file.debit_amount  := io_file.debit_amount + i_fin_rec.trans_amount;
        end if;    
        io_file.total_amount      := io_file.total_amount + i_fin_rec.trans_amount;       

    else
        null; --currently does not support upload collection chargeback
    end if;
    
    if l_line is not null then
        prc_api_file_pkg.put_line(
            i_raw_data      => l_line
          , i_sess_file_id  => i_session_file_id
        );
    end if;    
    
    trc_log_pkg.debug (
        i_text         => 'amx_prc_outgoing_pkg.process_chargeback end'
    );
    
end;

procedure process_retrieval(
    i_fin_rec               in     amx_api_type_pkg.t_amx_fin_mes_rec    
  , io_file                 in out amx_api_type_pkg.t_amx_file_rec
  , i_rec_number            in     com_api_type_pkg.t_short_id
  , i_session_file_id       in     com_api_type_pkg.t_long_id
) is
    l_line                   com_api_type_pkg.t_text;
begin
    trc_log_pkg.debug (
        i_text         => 'amx_prc_outgoing_pkg.process_retrieval start'
    );

    l_line := l_line || i_fin_rec.mtid; --1 
    l_line := l_line || lpad(nvl(i_fin_rec.pan_length, '0'), 2, '0'); --2 
    l_line := l_line || rpad(nvl(i_fin_rec.card_number, ' '), 19, ' '); --3
    l_line := l_line || rpad(i_fin_rec.proc_code, 6, ' '); --4
    l_line := l_line || rpad(' ', 80, ' ');--5            
    l_line := l_line || nvl(to_char(i_fin_rec.trans_date, amx_api_const_pkg.FORMAT_OUT_DATE), amx_api_const_pkg.DEFAULT_DATE); --6
    l_line := l_line || nvl(to_char(i_fin_rec.trans_date, amx_api_const_pkg.FORMAT_OUT_TIME), amx_api_const_pkg.DEFAULT_TIME);  --7
    l_line := l_line || rpad(nvl(i_fin_rec.card_expir_date, ' '), 4, ' '); --8     
    l_line := l_line || lpad('0', 4, '0');--9    
    l_line := l_line || nvl(to_char(i_fin_rec.capture_date, amx_api_const_pkg.FORMAT_OUT_DATE), amx_api_const_pkg.DEFAULT_DATE); --10
    l_line := l_line || rpad(nvl(i_fin_rec.mcc, ' '), 4, ' '); --11    
    l_line := l_line || rpad(' ', 21, ' ');--12    
    l_line := l_line || rpad(i_fin_rec.func_code, 3, ' '); --13    
    l_line := l_line || rpad(nvl(i_fin_rec.reason_code, ' '), 4, ' '); --14    
    l_line := l_line || rpad(' ', 12, ' ');--15        
    l_line := l_line || lpad(nvl(i_fin_rec.fp_trans_amount, '0'), 15, '0'); --16
    l_line := l_line || rpad(i_fin_rec.ain, 11, ' '); --17
    
    if i_fin_rec.mtid = amx_api_const_pkg.MTID_RETRIEVAL_REQUEST then    
        l_line := l_line || rpad(i_fin_rec.ipn, 11, ' '); --18
    else
        l_line := l_line || rpad(i_fin_rec.apn, 11, ' '); --18
    end if;
    
    l_line := l_line || rpad(i_fin_rec.arn, 23, ' '); --19    
    l_line := l_line || rpad(' ', 9, ' ');--20    
    l_line := l_line || rpad(nvl(i_fin_rec.terminal_number, ' '), 8, ' '); --21
    l_line := l_line || rpad(nvl(i_fin_rec.merchant_number, ' '), 15, ' '); --22
    l_line := l_line || nvl(trim(to_char(length(i_fin_rec.alt_merchant_number), '00')), '00'); --23              
    l_line := l_line || rpad(nvl(i_fin_rec.alt_merchant_number, ' '), 15, ' '); --24
    l_line := l_line || rpad(' ', 308, ' ');--25    
    l_line := l_line || rpad(nvl(i_fin_rec.fp_trans_currency, ' '), 3, ' '); --26       
    l_line := l_line || nvl(i_fin_rec.fp_trans_decimalization, '0'); --27
    l_line := l_line || lpad(i_fin_rec.fp_pres_amount, 15, '0');--28 
    l_line := l_line || rpad(' ', 15, ' ');--29    
    l_line := l_line || rpad(nvl(i_fin_rec.fp_pres_currency, ' '), 3, ' '); --30   
    l_line := l_line || nvl(i_fin_rec.fp_pres_decimalization, '0'); --31
    l_line := l_line || rpad(' ', 125, ' ');--32
    l_line := l_line || nvl(to_char(i_fin_rec.fp_trans_date, amx_api_const_pkg.FORMAT_OUT_DATE), amx_api_const_pkg.DEFAULT_DATE); --33    
    l_line := l_line || nvl(to_char(i_fin_rec.fp_trans_date, amx_api_const_pkg.FORMAT_OUT_TIME), amx_api_const_pkg.DEFAULT_TIME); --34
    l_line := l_line || rpad(' ', 3, ' ');--35
    l_line := l_line || rpad(nvl(i_fin_rec.chbck_reason_code, ' '), 4, ' '); --36
    l_line := l_line || '00000000'; --37 filler        
    l_line := l_line || '000000';   --38 filler
    l_line := l_line || rpad(' ', 96, ' ');--39
    l_line := l_line || nvl(to_char(i_fin_rec.capture_date, amx_api_const_pkg.FORMAT_OUT_TIME), amx_api_const_pkg.DEFAULT_TIME); --40      
    l_line := l_line || rpad(' ', 6, ' ');--41    
    l_line := l_line || nvl(to_char(i_fin_rec.fp_network_proc_date, amx_api_const_pkg.FORMAT_OUT_DATE), amx_api_const_pkg.DEFAULT_DATE); --42    
    l_line := l_line || nvl(to_char(i_fin_rec.fp_network_proc_date, amx_api_const_pkg.FORMAT_OUT_TIME), amx_api_const_pkg.DEFAULT_TIME); --43        
    l_line := l_line || rpad(' ', 2, ' ');--44
    l_line := l_line || rpad(i_fin_rec.iin, 11, ' '); --45
    l_line := l_line || rpad(' ', 2, ' ');--46
    l_line := l_line || '001'; --47
    l_line := l_line || rpad(' ', 40, ' ');--48
    l_line := l_line || rpad(nvl(i_fin_rec.itemized_doc_code, ' '), 2, ' '); --49
    l_line := l_line || rpad(nvl(i_fin_rec.itemized_doc_ref_number, ' '), 23, ' '); --50
    l_line := l_line || lpad(i_fin_rec.transaction_id, 15, '0');--51
    l_line := l_line || rpad(' ', 11, ' ');--52
    l_line := l_line || lpad(i_rec_number, 8, '0');--53 
    
    if i_fin_rec.mtid = amx_api_const_pkg.MTID_RETRIEVAL_REQUEST then    
        l_line := l_line || rpad(i_fin_rec.apn, 11, ' '); --54
    else
        l_line := l_line || rpad(i_fin_rec.ipn, 11, ' '); --54
    end if;
    
    l_line := l_line || rpad(' ', 228, ' ');--55    
    l_line := l_line || rpad(nvl(i_fin_rec.reject_reason_code, ' '), 40, ' ');--56
    l_line := l_line || rpad(' ', 82, ' ');--57   

    if l_line is not null then
        prc_api_file_pkg.put_line(
            i_raw_data      => l_line
          , i_sess_file_id  => i_session_file_id
        );
    end if;    
    
    trc_log_pkg.debug (
        i_text         => 'amx_prc_outgoing_pkg.process_retrieval end'
    );
    
end;

procedure mark_fin_messages (
    i_id                    in     com_api_type_pkg.t_number_tab
  , i_file_id               in     com_api_type_pkg.t_number_tab
  , i_rec_num               in     com_api_type_pkg.t_number_tab
) is
begin
    trc_log_pkg.debug (
        i_text         => 'Mark financial messages start'
    );

    forall i in 1..i_id.count
        update
            amx_fin_message_vw
        set
            file_id = i_file_id(i)
            , message_number = i_rec_num(i)
            , status = net_api_const_pkg.CLEARING_MSG_STATUS_UPLOADED
        where
            id = i_id(i);
            
    trc_log_pkg.debug (
        i_text         => 'Mark financial messages end'
    );
end;

procedure mark_add_fin_messages (
    i_id                    in     com_api_type_pkg.t_number_tab
  , i_file_id               in     com_api_type_pkg.t_number_tab
  , i_rec_num               in     com_api_type_pkg.t_number_tab
) is
begin
    trc_log_pkg.debug (
        i_text         => 'Mark addenda messages start'
    );

    forall i in 1..i_id.count
        update
            amx_add
         set
            file_id = i_file_id(i)
            , message_number = i_rec_num(i)
        where
            id = i_id(i);

    forall i in 1..i_id.count
        update
            amx_add_chip
         set
            file_id = i_file_id(i)
            , message_number = i_rec_num(i)
        where
            id = i_id(i);
            
    trc_log_pkg.debug (
        i_text         => 'Mark addenda messages end'
    );
end;

procedure register_session_file (
    i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_network_id            in     com_api_type_pkg.t_tiny_id
  , i_apn                   in     com_api_type_pkg.t_cmid
  , i_org_identifier        in     com_api_type_pkg.t_cmid      := null
  , i_func_code             in     com_api_type_pkg.t_curr_code := null
  , o_session_file_id          out com_api_type_pkg.t_long_id   
) is
    l_params                  com_api_type_pkg.t_param_tab;
begin
    l_params.delete;
    rul_api_param_pkg.set_param (
        i_name       => 'INST_ID'
        , i_value    => to_char(i_inst_id)
        , io_params  => l_params
    );
    rul_api_param_pkg.set_param (
        i_name       => 'NETWORK_ID'
        , i_value    => i_network_id
        , io_params  => l_params
    );
    rul_api_param_pkg.set_param (
        i_name       => 'ACQ_BIN'
        , i_value    => i_apn
        , io_params  => l_params
    );
    rul_api_param_pkg.set_param (
        i_name       => 'KEY_INDEX'
        , i_value    => i_org_identifier
        , io_params  => l_params
    );
    rul_api_param_pkg.set_param (
        i_name       => 'TRACKING_NUMBER'
        , i_value    => i_func_code
        , io_params  => l_params
    );

    prc_api_file_pkg.open_file (
        o_sess_file_id  => o_session_file_id
        , i_file_type   => amx_api_const_pkg.FILE_TYPE_CLEARING_AMEX
        , io_params     => l_params
    );
end;

procedure process (
    i_network_id            in     com_api_type_pkg.t_tiny_id    default null
  , i_inst_id               in     com_api_type_pkg.t_inst_id    default null
  , i_collection_only       in     com_api_type_pkg.t_boolean    default com_api_type_pkg.FALSE
  , i_amx_action_code       in     com_api_type_pkg.t_curr_code  default null 
  , i_start_date            in     date                          default null
  , i_end_date              in     date                          default null
  , i_include_affiliate     in     com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
  , i_apn                   in     com_api_type_pkg.t_cmid       default null
)is
    l_processed_count         com_api_type_pkg.t_long_id := 0;
    l_excepted_count          com_api_type_pkg.t_long_id := 0;

    l_host_id                 com_api_type_pkg.t_tiny_id;
    l_standard_id             com_api_type_pkg.t_tiny_id;
   
    l_fin_cur                 amx_api_type_pkg.t_amx_fin_cur;
    l_fin_message             amx_api_type_pkg.t_amx_fin_mes_tab;    
    
    l_ok_mess_id              com_api_type_pkg.t_number_tab;
    l_file_id                 com_api_type_pkg.t_number_tab;
    l_rec_num                 com_api_type_pkg.t_number_tab;   

    l_add_ok_mess_id          com_api_type_pkg.t_number_tab;
    l_add_file_id             com_api_type_pkg.t_number_tab;
    l_add_rec_num             com_api_type_pkg.t_number_tab;   

    l_session_file_id         com_api_type_pkg.t_long_id;   
    l_apn                     com_api_type_pkg.t_cmid;
    
    l_file                    amx_api_type_pkg.t_amx_file_rec;
    l_rec_number              com_api_type_pkg.t_short_id;   
    l_collection_only         com_api_type_pkg.t_boolean;
    l_amx_add_tab             amx_api_type_pkg.t_amx_add_tab;
    
    procedure register_ok_message (
        i_mess_id               com_api_type_pkg.t_long_id
        , i_file_id             com_api_type_pkg.t_long_id
        , i_rec_num             com_api_type_pkg.t_long_id
    ) is
        i                       binary_integer;
    begin
        i := l_ok_mess_id.count + 1;
        l_ok_mess_id(i) := i_mess_id;
        l_file_id(i) := i_file_id;
        l_rec_num(i) := i_rec_num;--prc_api_file_pkg.get_record_number(i_sess_file_id => l_session_file_id);
    end;   

    procedure register_add_ok_message (
        i_mess_id               com_api_type_pkg.t_long_id
        , i_file_id             com_api_type_pkg.t_long_id
        , i_rec_num             com_api_type_pkg.t_long_id
    ) is
        i                       binary_integer;
    begin
        i := l_add_ok_mess_id.count + 1;
        l_add_ok_mess_id(i) := i_mess_id;
        l_add_file_id(i)    := i_file_id;
        l_add_rec_num(i)    := i_rec_num;
    end;   

    procedure mark_ok_message is
    begin
        mark_fin_messages (
            i_id          => l_ok_mess_id
            , i_file_id   => l_file_id
            , i_rec_num   => l_rec_num
        );
        
        mark_add_fin_messages (
            i_id          => l_add_ok_mess_id
            , i_file_id   => l_add_file_id
            , i_rec_num   => l_add_rec_num
        );
         
        opr_api_clearing_pkg.mark_uploaded (
            i_id_tab  => l_ok_mess_id
        );

        l_ok_mess_id.delete;
        l_file_id.delete;
        l_rec_num.delete;
        l_add_ok_mess_id.delete;
        l_add_file_id.delete;
        l_add_rec_num.delete;
    end;     
    
    procedure check_ok_message is
    begin
        if l_ok_mess_id.count >= BULK_LIMIT then
            mark_ok_message;
        end if;
    end;
           
begin
    trc_log_pkg.debug (
        i_text  => 'AMEX outgoing clearing start'
    );

    prc_api_stat_pkg.log_start;

    l_host_id     := net_api_network_pkg.get_default_host(i_network_id => i_network_id);
    l_standard_id := net_api_network_pkg.get_offline_standard(i_host_id => l_host_id);
    
    l_collection_only := nvl(i_collection_only, com_api_type_pkg.FALSE);
    l_excepted_count  := 0;
    l_processed_count := 0;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count => amx_api_fin_message_pkg.estimate_messages_for_upload(
                                i_network_id            => i_network_id
                                , i_inst_id             => i_inst_id
                                , i_collection_only     => l_collection_only
                                , i_start_date          => trunc(i_start_date)
                                , i_end_date            => trunc(i_end_date)
                                , i_include_affiliate   => i_include_affiliate
                                , i_apn                 => i_apn
                             )
    );

    trc_log_pkg.debug (
        i_text          => 'enumerating messages'
    );

    amx_api_fin_message_pkg.enum_messages_for_upload (
        o_fin_cur               => l_fin_cur
        , i_network_id          => i_network_id
        , i_inst_id             => i_inst_id
        , i_collection_only     => l_collection_only
        , i_start_date          => trunc(i_start_date)
        , i_end_date            => trunc(i_end_date)
        , i_include_affiliate   => i_include_affiliate
        , i_apn                 => i_apn
    );

    loop
        fetch l_fin_cur bulk collect into l_fin_message limit BULK_LIMIT;
        for j in 1..l_fin_message.count loop

            -- if first record create new file and put file header
            if l_file.id is null then 
                    
                l_apn := case when i_apn is not null then i_apn else l_fin_message(j).apn end;

                register_session_file (
                    i_inst_id           => i_inst_id
                    , i_network_id      => i_network_id
                    , i_apn              => l_apn
                    , o_session_file_id => l_session_file_id   
                );

                process_file_header (
                    i_network_id         => i_network_id
                    , i_forw_inst_code   => l_apn
                    , i_receiv_inst_code => amx_api_const_pkg.GLOBAL_INST_ID
                    , i_inst_id          => i_inst_id
                    , i_collection_only  => l_collection_only
                    , i_action_code      => i_amx_action_code
                    , i_session_file_id  => l_session_file_id
                    , o_file             => l_file
                );
                l_rec_number := 1;
            end if;

            if l_fin_message(j).mtid = amx_api_const_pkg.MTID_PRESENTMENT then

                l_rec_number := l_rec_number + 1;
                process_presentment(
                    i_fin_rec                => l_fin_message(j)    
                    , io_file                => l_file
                    , i_rec_number           => l_rec_number
                    , i_session_file_id      => l_session_file_id
                    , i_collection_only      => l_collection_only
                ); 
                
                --process addenda  
                amx_api_add_pkg.enum_messages_for_upload(
                    i_fin_id          => l_fin_message(j).id
                  , o_amx_add_tab     => l_amx_add_tab
                );

                for k in 1 .. l_amx_add_tab.count loop
                    
                    l_rec_number := l_rec_number + 1;
                    amx_api_add_pkg.process_addenda (
                        i_amx_add_rec         => l_amx_add_tab(k)
                        , i_file_id           => l_file.id
                        , i_rec_number        => l_rec_number    
                        , i_session_file_id   => l_session_file_id
                    );
                end loop;
                                     
            elsif l_fin_message(j).mtid in(amx_api_const_pkg.MTID_RETRIEVAL_REQUEST, amx_api_const_pkg.MTID_FULFILLMENT) then

                l_rec_number := l_rec_number + 1;
                process_retrieval(
                    i_fin_rec                => l_fin_message(j)    
                    , io_file                => l_file
                    , i_rec_number           => l_rec_number
                    , i_session_file_id      => l_session_file_id
                );
                        
            elsif l_fin_message(j).mtid = amx_api_const_pkg.MTID_CHARGEBACK then

                l_rec_number := l_rec_number + 1;
                process_chargeback(
                    i_fin_rec                => l_fin_message(j)    
                    , io_file                => l_file
                    , i_rec_number           => l_rec_number
                    , i_session_file_id      => l_session_file_id
                    , i_collection_only      => l_collection_only
                );                        
            end if;
                    
            register_ok_message (
                i_mess_id     => l_fin_message(j).id
                , i_file_id   => l_file.id
                , i_rec_num   => l_rec_number
            );
            
            for k in 1 .. l_amx_add_tab.count loop
            
                register_add_ok_message(
                    i_mess_id    => l_amx_add_tab(k).id
                    , i_file_id  => l_amx_add_tab(k).file_id
                    , i_rec_num  => l_amx_add_tab(k).message_number
                );
            end loop;            

            check_ok_message;
        end loop;

        l_processed_count := l_processed_count + l_fin_message.count;

        prc_api_stat_pkg.log_current (
            i_current_count     => l_processed_count
            , i_excepted_count  => 0
        );

        exit when l_fin_cur%notfound;
    end loop;
    close l_fin_cur;

    mark_ok_message;

    if l_file.id is not null then
        --process trailer
        l_rec_number := l_rec_number + 1;
        
        process_file_trailer(
            i_rec_number         => l_rec_number   
            , i_session_file_id  => l_session_file_id
            , i_collection_only  => l_collection_only
            , io_file            => l_file
        );              

        prc_api_file_pkg.close_file (
            i_sess_file_id  => l_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
        );

    end if;

    prc_api_stat_pkg.log_end(
        i_result_code        => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        , i_processed_total  => l_processed_count
    );

    trc_log_pkg.debug (
        i_text  => 'AMEX outgoing clearing end'
    );

exception
    when others then
        if l_fin_cur%isopen then
            close l_fin_cur;
        end if;

        prc_api_stat_pkg.log_end (
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        prc_api_file_pkg.close_file (
            i_sess_file_id  => l_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
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

procedure process_rec_ack(
    i_session_file_id       in     com_api_type_pkg.t_long_id
  , i_original_file         in     amx_api_type_pkg.t_amx_file_rec
  , io_file                 in out amx_api_type_pkg.t_amx_file_rec
  , i_standard_id           in     com_api_type_pkg.t_tiny_id
  , i_host_id               in     com_api_type_pkg.t_tiny_id
) is
    l_line                  com_api_type_pkg.t_text;
    l_file_date             date;
    l_organization_id       com_api_type_pkg.t_region_code;
    l_param_tab             com_api_type_pkg.t_param_tab; 
begin
    trc_log_pkg.debug (
        i_text         => 'amx_prc_outgoing_pkg.process_rec_ack start'
    );

    begin    
        -- get File Receipt Date of original incoming file
        select f.file_date
          into l_file_date
          from prc_session_file f
         where f.id = i_original_file.session_file_id;    
    exception
        when no_data_found then
            com_api_error_pkg.raise_error (
                i_error         => 'SESSION_FILE_NOT_FOUND'
                , i_env_param1  => i_original_file.session_file_id
            );
        when others then
            raise;      
    end;

    begin
        l_organization_id := 
            cmn_api_standard_pkg.get_varchar_value(
                i_inst_id     => io_file.inst_id
              , i_standard_id => i_standard_id
              , i_entity_type => net_api_const_pkg.ENTITY_TYPE_HOST
              , i_object_id   => i_host_id
              , i_param_name  => amx_api_const_pkg.PARAM_ORGANIZATION_ID --'ORGANIZATION_ID'
              , i_eff_date    => get_sysdate()
              , i_param_tab   => l_param_tab
        );
    exception
        when others then
            trc_log_pkg.debug(sqlerrm);
            l_organization_id := null;
    end;          

    l_line := l_line || amx_api_const_pkg.MTID_ACKNOWLEDGMENT; --1
    l_line := l_line || rpad(nvl(io_file.org_identifier, l_organization_id), 11, ' '); --2
    l_line := l_line || rpad(' ', 61, ' '); --3 
    l_line := l_line || nvl(to_char(l_file_date, amx_api_const_pkg.FORMAT_OUT_DATE), amx_api_const_pkg.DEFAULT_DATE);--4
    l_line := l_line || nvl(to_char(l_file_date, amx_api_const_pkg.FORMAT_OUT_TIME), amx_api_const_pkg.DEFAULT_TIME); --5
    l_line := l_line || rpad(' ', 76, ' '); --6 
    l_line := l_line || i_original_file.func_code; --7
    l_line := l_line || amx_api_const_pkg.MSG_REASON_CODE_ACKNOWLEDG; --8
    l_line := l_line || lpad(i_original_file.debit_count, 8, '0'); --9    
    l_line := l_line || lpad(i_original_file.credit_count, 8, '0'); --10
    l_line := l_line || lpad(i_original_file.debit_amount, 17, '0'); --11
    l_line := l_line || lpad(i_original_file.credit_amount, 17, '0'); --12
    l_line := l_line || lpad((i_original_file.debit_count + i_original_file.credit_count), 8, '0'); --13 Total Record Count
    l_line := l_line || lpad(i_original_file.total_amount, 17, '0');--14 Hash Total Amount
    l_line := l_line || rpad(' ', 751, ' '); --15 
    l_line := l_line || lpad(i_original_file.file_number, 6, '0'); --16    
    l_line := l_line || rpad(' ', 26, ' '); --17 
    l_line := l_line || lpad('2', 8, '0'); --18 Message number
    l_line := l_line || rpad(' ', 239, ' '); --19 
    l_line := l_line || rpad(' ', 40, ' '); --20 
    l_line := l_line || rpad(' ', 82, ' '); --21 
        
    if l_line is not null then
        prc_api_file_pkg.put_line(
            i_raw_data      => l_line
          , i_sess_file_id  => i_session_file_id
        );

        io_file.credit_count  := io_file.credit_count + i_original_file.credit_count;
        io_file.debit_count   := io_file.debit_count + i_original_file.debit_count;
        io_file.credit_amount := io_file.credit_amount + i_original_file.credit_amount;
        io_file.debit_amount  := io_file.debit_amount + i_original_file.debit_amount;
        io_file.total_amount  := io_file.total_amount + i_original_file.total_amount;
    end if;    

    trc_log_pkg.debug (
        i_text         => 'amx_prc_outgoing_pkg.process_rec_ack end'
    );
    
end;

procedure process_header_ack(
    i_session_file_id      in   com_api_type_pkg.t_long_id
    , i_original_file      in   amx_api_type_pkg.t_amx_file_rec
    , i_action_code        in   com_api_type_pkg.t_curr_code
    , o_file               out  amx_api_type_pkg.t_amx_file_rec
) is
    l_line                   com_api_type_pkg.t_text;
begin
    trc_log_pkg.debug (
        i_text         => 'amx_prc_outgoing_pkg.process_header_ack start'
    );
    
    o_file.id                    := amx_file_seq.nextval;
    o_file.is_incoming           := com_api_type_pkg.FALSE;  
    o_file.is_rejected           := com_api_type_pkg.FALSE;       
    o_file.network_id            := i_original_file.network_id;      
    o_file.transmittal_date      := trunc(com_api_sttl_day_pkg.get_sysdate);    
    o_file.inst_id               := i_original_file.inst_id;   
    o_file.forw_inst_code        := i_original_file.receiv_inst_code;     
    o_file.receiv_inst_code      := i_original_file.forw_inst_code;       
    o_file.org_identifier        := i_original_file.org_identifier;
    o_file.action_code           := i_original_file.action_code;
    o_file.session_file_id       := i_session_file_id;
           
    o_file.file_number           := i_original_file.file_number;
    o_file.func_code             := i_original_file.func_code;
    
    o_file.reject_code           := null;     
    o_file.msg_total             := 3;    
    o_file.credit_count          := 0;    
    o_file.debit_count           := 0;    
    o_file.credit_amount         := 0;    
    o_file.debit_amount          := 0;    
    o_file.total_amount          := 0;         

    o_file.receipt_file_id       := null;   
    o_file.reject_msg_id         := null;
   
    l_line := l_line || amx_api_const_pkg.MTID_HEADER;
    l_line := l_line || rpad(' ', 107, ' ');
    l_line := l_line || nvl(to_char(o_file.transmittal_date, amx_api_const_pkg.FORMAT_OUT_DATE), amx_api_const_pkg.DEFAULT_DATE); 
    l_line := l_line || nvl(to_char(o_file.transmittal_date, amx_api_const_pkg.FORMAT_OUT_TIME), amx_api_const_pkg.DEFAULT_TIME); 
    l_line := l_line || rpad(' ', 86, ' ');
    l_line := l_line || rpad(o_file.forw_inst_code, 11, ' ');
    l_line := l_line || rpad(' ', 29, ' ');
    l_line := l_line || rpad(i_action_code, 3, ' ');
    l_line := l_line || rpad(' ', 719, ' ');
    l_line := l_line || rpad(' ', 26, ' ');
    l_line := l_line || lpad(o_file.file_number, 6, '0');
    l_line := l_line || rpad(' ', 26, ' ');
    l_line := l_line || lpad('1', 8, '0');
    l_line := l_line || rpad(o_file.receiv_inst_code, 11, ' ');
    l_line := l_line || rpad(' ', 228, ' ');
    l_line := l_line || rpad(' ', 40, ' ');
    l_line := l_line || rpad(' ', 82, ' ');
    
    if l_line is not null then
        prc_api_file_pkg.put_line(
            i_raw_data      => l_line
          , i_sess_file_id  => i_session_file_id
        );
    end if; 
    
    trc_log_pkg.debug (
        i_text         => 'amx_prc_outgoing_pkg.process_header_ack end'
    );
       
end;

procedure process_ack (
    i_network_id            in     com_api_type_pkg.t_tiny_id    default null
  , i_inst_id               in     com_api_type_pkg.t_inst_id    default null
  , i_amx_action_code       in     com_api_type_pkg.t_curr_code  default null 
)is
    l_estimated_count         com_api_type_pkg.t_long_id := 0;
    l_processed_count         com_api_type_pkg.t_long_id := 0;

    l_session_file_id         com_api_type_pkg.t_long_id;   
    l_file                    amx_api_type_pkg.t_amx_file_rec;
    l_original_file           amx_api_type_pkg.t_amx_file_rec;
    l_host_id                 com_api_type_pkg.t_tiny_id;
    l_standard_id             com_api_type_pkg.t_tiny_id;

    cursor l_file_cur is
        select f.*
          from amx_file f
         where f.is_incoming = 1 
           and f.network_id  = nvl(i_network_id, amx_api_const_pkg.TARGET_NETWORK)
           and f.func_code in (amx_api_const_pkg.FUNC_CODE_ACKNOWLEDGMENT, amx_api_const_pkg.FUNC_CODE_DAF)
           and f.receipt_file_id is null
           and f.inst_id = i_inst_id;         
begin
    trc_log_pkg.debug (
        i_text  => 'AMEX outgoing clearing acknowledgment start'
    );

    prc_api_stat_pkg.log_start;

    l_host_id     := net_api_network_pkg.get_default_host(i_network_id => i_network_id);
    l_standard_id := net_api_network_pkg.get_offline_standard(i_host_id => l_host_id);

    -- make estimated count
    select count(*)
      into l_estimated_count 
      from amx_file f
     where f.is_incoming = 1 
       and f.network_id  = nvl(i_network_id, amx_api_const_pkg.TARGET_NETWORK)
       and f.action_code = nvl(i_amx_action_code, f.action_code)
       and f.receipt_file_id is null
       and f.inst_id = i_inst_id;

    prc_api_stat_pkg.log_estimation (
        i_estimated_count  => l_estimated_count
    );
    
    if l_estimated_count > 0 then 
        open l_file_cur;
        loop
            fetch l_file_cur into l_original_file;
            
            exit when l_file_cur%notfound;
            
            trc_log_pkg.debug (
                i_text  => 'l_original_file.id = ' || l_original_file.id || ', l_estimated_count = ' || l_estimated_count
            );
            
            -- open new file
            register_session_file (
                i_inst_id            => i_inst_id
                , i_network_id       => i_network_id
                , i_apn              => l_original_file.receiv_inst_code
                , i_func_code        => l_original_file.func_code
                , i_org_identifier   => l_original_file.org_identifier
                , o_session_file_id  => l_session_file_id   
            );

            process_header_ack(
                i_session_file_id    => l_session_file_id
                , i_original_file    => l_original_file
                , i_action_code      => i_amx_action_code
                , o_file             => l_file
            );                  
            
            --process acknowledgment 1824
            process_rec_ack(
                i_session_file_id    => l_session_file_id
                , i_original_file    => l_original_file
                , io_file            => l_file
                , i_standard_id      => l_standard_id
                , i_host_id          => l_host_id
            );
                  
            process_file_trailer(
                i_rec_number         => 3   
                , i_session_file_id  => l_session_file_id
                , i_collection_only  => com_api_type_pkg.FALSE
                , io_file            => l_file
            );         
            
            -- update original file
            update amx_file 
               set receipt_file_id = l_file.id
             where id = l_original_file.id;        
            
            l_processed_count := l_processed_count + 1;

            prc_api_stat_pkg.log_current (
                i_current_count     => l_processed_count
                , i_excepted_count  => 0
            );
            
            -- close created file
            prc_api_file_pkg.close_file (
                i_sess_file_id  => l_session_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
            );            
            
--            exit when l_file_cur%notfound;
            
        end loop;  
        close l_file_cur;
              
    end if;

    prc_api_stat_pkg.log_end(
        i_result_code        => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        , i_processed_total  => l_processed_count
    );

    trc_log_pkg.debug (
        i_text  => 'AMEX outgoing clearing acknowledgment end'
    );

exception
    when others then
        prc_api_stat_pkg.log_end (
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        prc_api_file_pkg.close_file (
            i_sess_file_id  => l_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
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

end;
/

