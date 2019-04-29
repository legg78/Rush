create or replace package body mcw_prc_250byte_pkg as

procedure process_file_header (
    i_header_data           in  varchar2
    , i_inst_id             in  com_api_type_pkg.t_inst_id
    , i_session_file_id     in  com_api_type_pkg.t_long_id
    , i_test_option         in  varchar2
    , o_mcw_file            out mcw_api_type_pkg.t_mcw_250byte_file_rec
) is
    l_count                 pls_integer := 0;
begin
    o_mcw_file.header_mti      := substr(i_header_data, 1, 4);
    o_mcw_file.sttl_date       := to_date(substr(i_header_data, 5, 6), 'MMDDYY');
    o_mcw_file.processor_id    := substr(i_header_data, 11, 10);
    o_mcw_file.record_size     := to_number(substr(i_header_data, 21, 3));
    o_mcw_file.file_type       := substr(i_header_data, 24, 1);
    o_mcw_file.version         := trim(substr(i_header_data, 25, 10));
    o_mcw_file.session_file_id := i_session_file_id;
    o_mcw_file.inst_id         := i_inst_id;

    begin
        select 1
          into l_count
          from mcw_250byte_file
         where sttl_date     = o_mcw_file.sttl_date
           and inst_id       = o_mcw_file.inst_id
           and processor_id  = o_mcw_file.processor_id;

        com_api_error_pkg.raise_error (
            i_error         => 'MCW_250B_BATCH_FILE_ALREADY_PROCESSED'
            , i_env_param1  => to_char(o_mcw_file.sttl_date,'yyyy-mm-dd')
            , i_env_param2  => o_mcw_file.processor_id
            , i_env_param3  => o_mcw_file.inst_id
        );
    exception
        when no_data_found then
            null;
    end;

    -- check processing type
    if nvl(i_test_option, ' ') != nvl(o_mcw_file.file_type, ' ') then
        com_api_error_pkg.raise_error(
            i_error       => 'MCW_250B_BATCH_FILE_WRONG_TEST_OPTION'
          , i_env_param1  => i_test_option
          , i_env_param2  => o_mcw_file.file_type
        );
    end if;

    o_mcw_file.id              := mcw_250byte_file_seq.nextval;

    trc_log_pkg.debug(
        i_text => 'Header processed.'
    );

end;

procedure process_file_trailer (
    i_trailer_data          in     varchar2
    , io_mcw_file           in out mcw_api_type_pkg.t_mcw_250byte_file_rec
) is
begin
    if io_mcw_file.processor_id != substr(i_trailer_data, 5, 10) then
        com_api_error_pkg.raise_error (
            i_error         => 'MCW_250B_BATCH_FILE_INCORR_TRAILER_PROCESSOR'
            , i_env_param1  => io_mcw_file.processor_id
            , i_env_param2  => substr(i_trailer_data, 5, 10)
        );
    end if;

    io_mcw_file.total_count      := to_number(substr(i_trailer_data, 15, 11));

    insert into mcw_250byte_file (
          id
        , header_mti
        , sttl_date
        , processor_id
        , record_size
        , file_type
        , version
        , session_file_id
        , inst_id
        , network_id
        , total_count
      ) values (
          io_mcw_file.id
        , io_mcw_file.header_mti
        , io_mcw_file.sttl_date
        , io_mcw_file.processor_id
        , io_mcw_file.record_size
        , io_mcw_file.file_type
        , io_mcw_file.version
        , io_mcw_file.session_file_id
        , io_mcw_file.inst_id
        , io_mcw_file.network_id
        , io_mcw_file.total_count
    );

    trc_log_pkg.debug(
        i_text => 'Trailer processed. Saved file [' || io_mcw_file.id || ']'
    );

end;

procedure process_fin_rec (
    i_rec_data       in      varchar2
  , i_record_number  in      com_api_type_pkg.t_short_id
  , i_mcw_file       in      mcw_api_type_pkg.t_mcw_250byte_file_rec
) is
    l_mcw_fin                mcw_250byte_message%rowtype := null;
    l_card_number            com_api_type_pkg.t_card_number;
    l_recon_activity         com_api_type_pkg.t_one_char;
    function get_field (
        i_start       in pls_integer
        , i_length    in pls_integer
    ) return varchar2 is
    begin
        return rtrim(substr(i_rec_data, i_start, i_length ), ' ');
    end;

begin
    l_mcw_fin.status               := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;
    l_mcw_fin.file_id              := i_mcw_file.id;
    l_mcw_fin.record_number        := i_record_number;
    l_mcw_fin.inst_id              := i_mcw_file.inst_id;
    l_mcw_fin.mti                  := get_field(1, 4);
    l_mcw_fin.switch_serial_number := get_field(5, 9);
    l_mcw_fin.processor            := get_field(14, 1);
    l_mcw_fin.processor_id         := get_field(15, 4);
    l_mcw_fin.transaction_date     := to_date(get_field(19, 6) || get_field(25, 6), 'mmddyyhh24miss');
    l_mcw_fin.pan_length           := to_number(get_field(31, 2));
    l_card_number                  := get_field(33, 19); 
    l_mcw_fin.card_number          := iss_api_card_pkg.get_card_mask(l_card_number);
    l_mcw_fin.proc_code            := get_field(52, 6); 
    l_mcw_fin.trace_number         := get_field(58, 6);
    l_mcw_fin.mcc                  := get_field(64, 4);
    l_mcw_fin.pos_entry            := get_field(68, 3);
    l_mcw_fin.reference_number     := get_field(71, 12);
    l_mcw_fin.acq_institution_id   := get_field(83, 10);
    l_mcw_fin.terminal_id          := get_field(93, 10);
    l_mcw_fin.resp_code            := get_field(103, 2);
    l_mcw_fin.brand                := get_field(105, 3);
    l_mcw_fin.advice_reason_code   := get_field(108, 7);
    l_mcw_fin.intra_cur_agrmt_code := get_field(115, 4);    
    l_mcw_fin.authorization_id     := get_field(119, 6);
    l_mcw_fin.trans_currency       := get_field(125, 3);  
    l_mcw_fin.trans_implied_decimal:= get_field(128, 1);
    l_mcw_fin.trans_amount         := to_number(get_field(129, 12));
    l_mcw_fin.trans_indicator      := get_field(141, 1);
    l_mcw_fin.cashback_amount      := to_number(get_field(142, 12));    
    l_mcw_fin.cashback_indicator   := get_field(154, 1);
    l_mcw_fin.access_fee           := to_number(get_field(155, 8));
    l_mcw_fin.access_fee_indicator := get_field(163, 1);
    l_mcw_fin.sttl_currency        := get_field(164, 3);  
    l_mcw_fin.sttl_implied_decimal := get_field(167, 1);
    l_mcw_fin.sttl_rate            := to_number(get_field(168, 8));
    l_mcw_fin.sttl_amount          := to_number(get_field(176, 12));
    l_mcw_fin.sttl_indicator       := get_field(188, 1);
    l_mcw_fin.interchange_fee      := to_number(get_field(189, 10));
    l_mcw_fin.intrchg_fee_indicator:= get_field(199, 1);
    l_mcw_fin.positive_id_indicator:= get_field(215, 1);
    l_mcw_fin.cross_border_indicator:= get_field(217, 1);
    l_mcw_fin.crossb_curr_indicator:= get_field(218, 1);
    l_mcw_fin.isa_fee_indicator    := get_field(219, 1);    
    l_mcw_fin.request_amount       := to_number(get_field(220, 12));
    l_mcw_fin.trace_number_adjust  := get_field(244, 6);
    l_recon_activity               := get_field(250, 1);
    
    --search card_id and operation.
    l_mcw_fin.card_id              := iss_api_card_pkg.get_card_id(l_card_number);
    trc_log_pkg.debug(
        i_text => 'iss_api_card_pkg.get_card_id: l_mcw_fin.card_id [' || l_mcw_fin.card_id || ']'
    );

    trc_log_pkg.debug(
          i_text       => 'Search of operation. Parameters: [#1], [#2], [#3], [#4], [#5], [#6]'
        , i_env_param1 => l_mcw_fin.card_number --mask
        , i_env_param2 => l_mcw_fin.reference_number
        , i_env_param3 => l_mcw_fin.transaction_date
        , i_env_param4 => l_mcw_fin.terminal_id
        , i_env_param5 => l_mcw_fin.mcc
    );
    trc_log_pkg.debug(
          i_text       => 'Search of operation. Amounts and currencies: [#1], [#2], [#3], [#4]'
        , i_env_param1 => l_mcw_fin.trans_amount
        , i_env_param2 => l_mcw_fin.trans_currency
        , i_env_param3 => l_mcw_fin.sttl_amount
        , i_env_param4 => l_mcw_fin.sttl_currency
    );

    begin
        select o.id
          into l_mcw_fin.oper_id
          from opr_operation o
             , opr_card c
         where c.oper_id           = o.id
           and o.status            in (opr_api_const_pkg.OPERATION_STATUS_PROCESSED
                                     , opr_api_const_pkg.OPERATION_STATUS_DONE_WO_PROC
                                     , opr_api_const_pkg.OPERATION_STATUS_UNHOLDED
                                     , opr_api_const_pkg.OPERATION_STATUS_AUTHORIZED
                                     , opr_api_const_pkg.OPERATION_STATUS_AWAITS_UNHOLD
                                   )
           and c.card_number       = l_card_number
           and c.participant_type  = com_api_const_pkg.PARTICIPANT_ISSUER
           and o.originator_refnum = l_mcw_fin.reference_number
           and trunc(o.oper_date)  = trunc(l_mcw_fin.transaction_date)
           and o.terminal_number   = l_mcw_fin.terminal_id
           and o.mcc               = l_mcw_fin.mcc
           and o.oper_amount       = l_mcw_fin.trans_amount
           and o.oper_currency     = l_mcw_fin.trans_currency
           and o.sttl_amount       = l_mcw_fin.sttl_amount
           and o.sttl_currency     = l_mcw_fin.sttl_currency
        ;

    exception
        when no_data_found then

            l_mcw_fin.oper_id := null;
            trc_log_pkg.warn(
                  i_text       => 'Operation not found. oper_id set to null'
            );

        when too_many_rows then
            
            --get first row
            select min(o.id)
              into l_mcw_fin.oper_id
              from opr_operation o
                 , opr_card c
             where c.oper_id           = o.id
               and c.card_number       = l_card_number
               and o.originator_refnum = l_mcw_fin.reference_number
               and o.oper_date         = l_mcw_fin.transaction_date
               and o.terminal_number   = l_mcw_fin.terminal_id
               and o.mcc               = l_mcw_fin.mcc
               and o.oper_amount       = l_mcw_fin.trans_amount
               and o.oper_currency     = l_mcw_fin.trans_currency
               and o.sttl_amount       = l_mcw_fin.sttl_amount
               and o.sttl_currency     = l_mcw_fin.sttl_currency
            ;
            trc_log_pkg.warn(
                  i_text       => 'Too many operations found. oper_id set to [' || l_mcw_fin.oper_id  || ']'
            );

        when others then

            l_mcw_fin.oper_id := null;
            trc_log_pkg.warn(
                  i_text       => sqlerrm
            );
    end;

    trc_log_pkg.debug(
        i_text       => 'Operation found. Oper_id = [' || l_mcw_fin.oper_id || ']'
    );

    l_mcw_fin.id                   := mcw_250byte_message_seq.nextval;
    insert into mcw_250byte_message(
          id
        , status
        , file_id
        , record_number
        , inst_id
        , network_id
        , card_id
        , oper_id
        , mti
        , switch_serial_number
        , processor
        , processor_id
        , transaction_date
        , pan_length
        , card_number
        , proc_code
        , trace_number
        , mcc
        , pos_entry
        , reference_number
        , acq_institution_id
        , terminal_id
        , resp_code
        , brand
        , advice_reason_code
        , intra_cur_agrmt_code
        , authorization_id
        , trans_currency
        , trans_implied_decimal
        , trans_amount
        , trans_indicator
        , cashback_amount
        , cashback_indicator
        , access_fee
        , access_fee_indicator
        , sttl_currency
        , sttl_implied_decimal
        , sttl_rate
        , sttl_amount
        , sttl_indicator
        , interchange_fee
        , intrchg_fee_indicator
        , positive_id_indicator
        , cross_border_indicator
        , crossb_curr_indicator
        , isa_fee_indicator
        , request_amount
        , trace_number_adjust
        , recon_activity
    ) values(
          l_mcw_fin.id               
        , l_mcw_fin.status           
        , l_mcw_fin.file_id          
        , l_mcw_fin.record_number    
        , l_mcw_fin.inst_id          
        , l_mcw_fin.network_id       
        , l_mcw_fin.card_id          
        , l_mcw_fin.oper_id          
        , l_mcw_fin.mti              
        , l_mcw_fin.switch_serial_number
        , l_mcw_fin.processor           
        , l_mcw_fin.processor_id        
        , l_mcw_fin.transaction_date    
        , l_mcw_fin.pan_length          
        , l_mcw_fin.card_number           
        , l_mcw_fin.proc_code           
        , l_mcw_fin.trace_number        
        , l_mcw_fin.mcc                 
        , l_mcw_fin.pos_entry           
        , l_mcw_fin.reference_number    
        , l_mcw_fin.acq_institution_id  
        , l_mcw_fin.terminal_id         
        , l_mcw_fin.resp_code           
        , l_mcw_fin.brand               
        , l_mcw_fin.advice_reason_code  
        , l_mcw_fin.intra_cur_agrmt_code    
        , l_mcw_fin.authorization_id    
        , l_mcw_fin.trans_currency        
        , l_mcw_fin.trans_implied_decimal
        , l_mcw_fin.trans_amount         
        , l_mcw_fin.trans_indicator      
        , l_mcw_fin.cashback_amount          
        , l_mcw_fin.cashback_indicator   
        , l_mcw_fin.access_fee           
        , l_mcw_fin.access_fee_indicator 
        , l_mcw_fin.sttl_currency          
        , l_mcw_fin.sttl_implied_decimal 
        , l_mcw_fin.sttl_rate            
        , l_mcw_fin.sttl_amount          
        , l_mcw_fin.sttl_indicator       
        , l_mcw_fin.interchange_fee      
        , l_mcw_fin.intrchg_fee_indicator
        , l_mcw_fin.positive_id_indicator
        , l_mcw_fin.cross_border_indicator
        , l_mcw_fin.crossb_curr_indicator 
        , l_mcw_fin.isa_fee_indicator     
        , l_mcw_fin.request_amount        
        , l_mcw_fin.trace_number_adjust   
        , l_recon_activity
    );
        
end;

procedure load (
    i_inst_id      in    com_api_type_pkg.t_tiny_id
  , i_test_option  in    varchar2 default null -- possible value 'M' for test processing
)is
    LOG_PREFIX        constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process: ';
    l_record_count             com_api_type_pkg.t_long_id := 0;    
    l_errors_count             com_api_type_pkg.t_long_id := 0;
    l_processed_count          com_api_type_pkg.t_long_id := 0; 
    l_mcw_file                 mcw_api_type_pkg.t_mcw_250byte_file_rec;
    l_mti                      com_api_type_pkg.t_mcc; 
    
    cursor cu_records_count is
        select count(1)
          from prc_file_raw_data a
             , prc_session_file b
         where b.session_id      = prc_api_session_pkg.get_session_id
           and a.session_file_id = b.id;
    
begin
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'i_inst_id [' || i_inst_id
                             || '], i_test_option [' || i_test_option || ']'
    );
    prc_api_stat_pkg.log_start;

    open cu_records_count;
    fetch cu_records_count into l_record_count;
    close cu_records_count;

    prc_api_stat_pkg.log_estimation (
        i_estimated_count     => l_record_count
    );
    
    for p in (
        select id session_file_id
             , record_count
          from prc_session_file
         where session_id = prc_api_session_pkg.get_session_id
         order by id
    ) loop
        trc_log_pkg.debug(
            i_text => 'Processing session_file_id [' || p.session_file_id || '], record_count [' || p.record_count || ']'
        );
        
        begin
            savepoint sp_mc_rcn_incoming_file;

            for r in (
                  select record_number rn
                       , raw_data
                    from prc_file_raw_data
                   where session_file_id = p.session_file_id
            ) loop
                trc_log_pkg.debug(
                    i_text => 'record_number [' || r.rn || '], raw_data [' || r.raw_data || ']'
                );
                
                l_mti := substr(r.raw_data, 1, 4);
                
                if l_mti = mcw_api_const_pkg.MSG_TYPE_250B_HEADER then
                
                    -- process header
                    process_file_header (
                        i_header_data        => r.raw_data
                        , i_inst_id          => i_inst_id
                        , i_session_file_id  => p.session_file_id
                        , i_test_option      => i_test_option
                        , o_mcw_file         => l_mcw_file
                    );

                elsif l_mti = mcw_api_const_pkg.MSG_TYPE_250B_TRAILER then
                
                    --process_file_trailer
                    process_file_trailer (
                        i_trailer_data       => r.raw_data
                        , io_mcw_file        => l_mcw_file
                    );                
                elsif l_mti = mcw_api_const_pkg.MSG_TYPE_250B_FREC then
                
                    -- process financia record
                    process_fin_rec (
                        i_rec_data           => r.raw_data
                        , i_record_number    => r.rn
                        , i_mcw_file         => l_mcw_file
                    );                    
                end if;                
                  
                l_processed_count := l_processed_count + 1;
                
                if mod(l_processed_count, 100) = 0 then 
                    prc_api_stat_pkg.log_current(
                        i_current_count  => l_processed_count
                      , i_excepted_count => l_errors_count
                    );
                end if;

            end loop;

        exception
            when com_api_error_pkg.e_application_error then
                rollback to sp_mc_rcn_incoming_file;
                
                l_errors_count := l_errors_count + 1;
                                
                prc_api_stat_pkg.log_current(
                    i_current_count  => l_processed_count
                  , i_excepted_count => l_errors_count
                );

                prc_api_file_pkg.close_file(
                    i_sess_file_id   => p.session_file_id
                  , i_status         => prc_api_const_pkg.FILE_STATUS_REJECTED
                );

                raise;
        end;

    end loop;

    prc_api_stat_pkg.log_end(
        i_processed_total   => l_processed_count
      , i_excepted_total    => l_errors_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug(LOG_PREFIX || 'END');
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
