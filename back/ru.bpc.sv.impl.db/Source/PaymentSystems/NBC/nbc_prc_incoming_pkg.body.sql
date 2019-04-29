create or replace package body nbc_prc_incoming_pkg as
/*********************************************************
 *  NBC incoming files API  <br />
 *  Created by Kolodkina Y.(kolodkina@bpcbt.com)  at 21.11.2016 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: nbc_prc_incoming_pkg <br />
 *  @headcom
 **********************************************************/

g_error_flag        com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE;

function get_field (
    i_raw_data     in varchar2
    , i_start      in pls_integer
    , i_length     in pls_integer
) return varchar2 is
begin
    return rtrim (substr (i_raw_data, i_start, i_length), ' ');
end;

function date_yymmdd (
    p_date                  in varchar2
) return date is
begin
    if p_date = '000000' then
        return null;
    end if;
    return to_date (p_date, 'YYMMDD');
end;

function date_mmdd (
    p_date                  in varchar2
) return date is
begin
    if p_date = '0000' then
        return null;
    end if;
    return to_date (p_date, 'MMDD');
end;

function date_mmdd_time (
    p_date                  in varchar2
    , p_time                in varchar2
) return date is
  l_time varchar2(6) := p_time;
begin
  
    if p_date = '0000' then
        return null;
    end if;
    if l_time is null then
        l_time := '000000';
    end if;
    
    return to_date (to_char(trunc(get_sysdate), 'YYYY')||p_date||l_time, 'YYYYMMDDhh24miss');
end;

function date_mmddyy (
    p_date                  in varchar2
) return date is
begin
    if p_date = '000000' then
        return null;
    end if;
    return to_date (p_date, 'MMDDYY');
end;

function get_original_id(
    i_nbc_fin_rec     in      nbc_api_type_pkg.t_nbc_fin_mes_rec
) return com_api_type_pkg.t_long_id is
    l_original_id   com_api_type_pkg.t_long_id;
begin
    trc_log_pkg.debug (
        i_text          => 'nbc_prc_incoming_pkg.get_original_id start'
    );

    trc_log_pkg.debug (
        i_text          => 'Search by split_hash[#1] card_number[#2] system_trace_number[#3] proc_code[#4] trans_amount [#5] local_trans_date [#6]'
        , i_env_param1  => i_nbc_fin_rec.split_hash
        , i_env_param2  => i_nbc_fin_rec.card_number 
        , i_env_param3  => i_nbc_fin_rec.system_trace_number
        , i_env_param4  => i_nbc_fin_rec.proc_code
        , i_env_param5  => i_nbc_fin_rec.trans_amount
        , i_env_param6  => i_nbc_fin_rec.local_trans_date       
    );

    select min(m.id)
      into l_original_id
      from nbc_fin_message m
         , nbc_card c
     where m.split_hash            = i_nbc_fin_rec.split_hash
       and m.id                    = c.id
       and c.card_number           = i_nbc_fin_rec.card_number 
       and m.rrn                   = i_nbc_fin_rec.rrn
       and m.trans_amount          = i_nbc_fin_rec.trans_amount
       and m.local_trans_date      = i_nbc_fin_rec.local_trans_date       
       and m.is_incoming           = com_api_type_pkg.FALSE;       
              
    trc_log_pkg.debug (
        i_text          => 'l_original_id [' || l_original_id || ']'
    );    
    
    trc_log_pkg.debug (
        i_text          => 'nbc_prc_incoming_pkg.get_original_id end'
    );
    
    return l_original_id;
    
end get_original_id;

procedure assign_dispute(
    io_nbc_fin_rec      in out nocopy nbc_api_type_pkg.t_nbc_fin_mes_rec
) is
    l_dispute_id            com_api_type_pkg.t_long_id;
    
   cursor match_cur is
   select min(m.id) id
        , min(m.dispute_id) dispute_id
        , io_nbc_fin_rec.card_number as card_number
     from nbc_fin_message m
        , nbc_card c
    where m.system_trace_number = io_nbc_fin_rec.system_trace_number
      and m.local_trans_date    = io_nbc_fin_rec.local_trans_date  
      and m.trans_amount        = io_nbc_fin_rec.trans_amount 
      and c.id                  = m.id
      and c.card_number         = iss_api_token_pkg.encode_card_number(i_card_number => io_nbc_fin_rec.card_number)
    ;
begin
    trc_log_pkg.debug (
        i_text          => 'assign_dispute: card_number[#1], system_trace_number[#2]'
        , i_env_param1  => iss_api_card_pkg.get_card_mask(io_nbc_fin_rec.card_number)
        , i_env_param2  => io_nbc_fin_rec.system_trace_number
    );
   
    for rec in match_cur loop

        if rec.id is not null then
        
            io_nbc_fin_rec.dispute_id  := rec.id;
            l_dispute_id               := rec.dispute_id;

            trc_log_pkg.debug (
                i_text          => 'Original message found. id = [#1], dispute_id = [#2]'
                , i_env_param1  => rec.id
                , i_env_param2  => rec.dispute_id
            );
        end if;

        exit;
    end loop;

    if io_nbc_fin_rec.dispute_id is null then
    
        io_nbc_fin_rec.is_invalid := get_true;
        
        trc_log_pkg.warn (
            i_text           => 'ORIGINAL_OPERATION_IS_NOT_FOUND'
            , i_env_param1   => io_nbc_fin_rec.id
            , i_env_param2   => io_nbc_fin_rec.system_trace_number
            , i_env_param3   => iss_api_card_pkg.get_card_mask(io_nbc_fin_rec.card_number)
            , i_env_param4   => com_api_type_pkg.convert_to_char(io_nbc_fin_rec.local_trans_date)
            , i_object_id    => io_nbc_fin_rec.id
        );
    end if;

    -- assign a new dispute id
    if l_dispute_id is null then
        update
            nbc_fin_message
        set
            dispute_id = io_nbc_fin_rec.dispute_id
        where
            id = io_nbc_fin_rec.dispute_id;
    end if;
end;

procedure process_file_header(
    i_header_data           in varchar2
    , i_network_id          in com_api_type_pkg.t_tiny_id
    , i_standard_id         in com_api_type_pkg.t_tiny_id
    , i_host_id             in com_api_type_pkg.t_tiny_id
    , i_session_file_id     in com_api_type_pkg.t_long_id
    , i_file_type           in com_api_type_pkg.t_dict_value          
    , o_nbc_file            out nbc_api_type_pkg.t_nbc_file_rec
) is
begin

    trc_log_pkg.debug (
        i_text          => 'nbc_prc_incoming_pkg.process_file_header start'
    );
    
    o_nbc_file.is_incoming         := com_api_type_pkg.TRUE;
    o_nbc_file.network_id          := i_network_id;
    o_nbc_file.bin_number          := get_field(i_header_data, 5, 7);

    --search inst_id of BIN
    if o_nbc_file.inst_id is null then
    
        o_nbc_file.inst_id := cmn_api_standard_pkg.find_value_owner (
            i_standard_id    => i_standard_id
            , i_entity_type  => net_api_const_pkg.ENTITY_TYPE_HOST
            , i_object_id    => i_host_id
            , i_param_name   => nbc_api_const_pkg.NBC_BANK_CODE
            , i_value_char   => o_nbc_file.bin_number 
        );

        if o_nbc_file.inst_id is null then
            com_api_error_pkg.raise_error(
                i_error         => 'NBC_INSTITUTION_NOT_FOUND'
                , i_env_param1  => o_nbc_file.bin_number 
                , i_env_param2  => i_network_id
            );
        end if;
    
    end if;
    
    o_nbc_file.proc_date           := get_sysdate;
    trc_log_pkg.debug (
        i_text          => 'get_field(i_header_data, 12, 6) = ' || get_field(i_header_data, 12, 6)
    );
    -- 082916
    o_nbc_file.sttl_date           := date_yymmdd(get_field(i_header_data, 12, 6)); 
    o_nbc_file.file_number         := 0;     
    
    if i_file_type is null 
       or i_file_type not in (nbc_api_const_pkg.FILE_TYPE_NBC_ISS
                            , nbc_api_const_pkg.FILE_TYPE_NBC_ACQ
                            , nbc_api_const_pkg.FILE_TYPE_NBC_BNB
                            , nbc_api_const_pkg.FILE_TYPE_NBC_DSP)
    then
        com_api_error_pkg.raise_error(
            i_error         => 'NBC_UNKNOWN_FILE_TYPE'
            , i_env_param1  => i_file_type
        );
    end if;       
               
    if i_file_type != nbc_api_const_pkg.FILE_TYPE_NBC_DSP then      
        o_nbc_file.participant_type := case i_file_type 
                                                 when nbc_api_const_pkg.FILE_TYPE_NBC_ISS 
                                              then 'ISS'
                                                 when nbc_api_const_pkg.FILE_TYPE_NBC_ACQ 
                                              then 'ACQ'
                                                 when nbc_api_const_pkg.FILE_TYPE_NBC_BNB 
                                              then 'BNB'
                                       end;
        o_nbc_file.file_type        := 'RF';                                       
    else
        o_nbc_file.participant_type := 'DSP';                                        
        o_nbc_file.file_type        := 'DF';                                       
    end if;           
         
    o_nbc_file.session_file_id     := i_session_file_id;          

    o_nbc_file.id                  := nbc_file_seq.nextval;
    trc_log_pkg.debug (
        i_text          => 'o_nbc_file.id = ' || o_nbc_file.id
    );

    trc_log_pkg.debug (
        i_text          => 'nbc_prc_incoming_pkg.process_file_header end'
    );
end process_file_header;

procedure process_file_trailer (
    i_trailer_data          in      varchar2
    , io_nbc_file           in  out nbc_api_type_pkg.t_nbc_file_rec
) is
begin
    trc_log_pkg.debug (
        i_text          => 'nbc_prc_incoming_pkg.process_file_trailer start'
    );

    io_nbc_file.records_total := get_field(i_trailer_data, 5, 9);
    
    insert into nbc_file (
        id
      , file_type
      , is_incoming
      , inst_id    
      , network_id 
      , bin_number 
      , sttl_date  
      , proc_date  
      , file_number
      , participant_type
      , session_file_id 
      , records_total      
      , md5           
    )
    values(
        io_nbc_file.id
      , io_nbc_file.file_type
      , io_nbc_file.is_incoming
      , io_nbc_file.inst_id    
      , io_nbc_file.network_id 
      , io_nbc_file.bin_number 
      , io_nbc_file.sttl_date  
      , io_nbc_file.proc_date  
      , io_nbc_file.file_number
      , io_nbc_file.participant_type
      , io_nbc_file.session_file_id 
      , io_nbc_file.records_total      
      , io_nbc_file.md5       
    );
    trc_log_pkg.debug (
        i_text          => 'nbc_prc_incoming_pkg.process_file_trailer end'
    );
end process_file_trailer;

procedure process_presentment_rf(
    i_tc_buffer             in      varchar2
    , i_nbc_file            in      nbc_api_type_pkg.t_nbc_file_rec
    , i_standard_id         in      com_api_type_pkg.t_tiny_id
) is
    l_nbc_fin_rec           nbc_api_type_pkg.t_nbc_fin_mes_rec;
    l_currency_exponent     com_api_type_pkg.t_tiny_id;
    l_decimal_place         pls_integer := 0;
    l_crdh_bill_rate        com_api_type_pkg.t_cmid;
    l_sttl_rate             com_api_type_pkg.t_cmid;
    
    function get_amount(
        i_currency_exponent     in com_api_type_pkg.t_tiny_id
      , i_start                 in pls_integer
      , i_length                in pls_integer
    ) return com_api_type_pkg.t_money is
        l_amount    com_api_type_pkg.t_money := 0;
    begin
        if i_currency_exponent = 0 then
        
            l_amount     := get_field(i_tc_buffer, i_start, i_length - 2);
        else
            l_amount     := get_field(i_tc_buffer, i_start, i_length);
            
            if i_currency_exponent > 2 then
                l_amount := l_amount * power(10, i_currency_exponent - 2);
            end if;
        end if;
        
        return l_amount;
    end;
   
begin
    trc_log_pkg.debug (
        i_text          => 'nbc_prc_incoming_pkg.process_presentment_rf start'
    );

    -- init_record
    l_nbc_fin_rec.id                   := opr_api_create_pkg.get_id;
    l_nbc_fin_rec.status               := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;
    l_nbc_fin_rec.is_reversal          := com_api_type_pkg.FALSE;
    l_nbc_fin_rec.is_incoming          := com_api_type_pkg.TRUE;
    l_nbc_fin_rec.is_invalid           := com_api_type_pkg.FALSE;
    l_nbc_fin_rec.inst_id              := i_nbc_file.inst_id;
    l_nbc_fin_rec.network_id           := i_nbc_file.network_id;
    l_nbc_fin_rec.msg_file_type        := i_nbc_file.file_type;
    l_nbc_fin_rec.participant_type     := i_nbc_file.participant_type;
    l_nbc_fin_rec.file_id              := i_nbc_file.id;

    l_nbc_fin_rec.record_type          := get_field(i_tc_buffer, 1, 4); 
    l_nbc_fin_rec.card_number          := trim(leading '0' from get_field(i_tc_buffer, 5, 19));
    l_nbc_fin_rec.card_mask            := iss_api_card_pkg.get_card_mask(l_nbc_fin_rec.card_number);
    l_nbc_fin_rec.card_hash            := com_api_hash_pkg.get_card_hash(l_nbc_fin_rec.card_number);
    l_nbc_fin_rec.proc_code            := get_field(i_tc_buffer, 24, 6);  
    
    l_nbc_fin_rec.trans_currency       := get_field(i_tc_buffer, 171, 3);
    l_currency_exponent                := com_api_currency_pkg.get_currency_exponent(i_curr_code => l_nbc_fin_rec.trans_currency);
    l_nbc_fin_rec.trans_amount         := get_amount(
                                              i_currency_exponent => l_currency_exponent
                                            , i_start             => 30
                                            , i_length            => 12
                                          );
    trc_log_pkg.debug (
        i_text          => 'l_nbc_fin_rec.trans_amount [' || l_nbc_fin_rec.trans_amount || ']'
    );

    -- 0 will be added up if the value is null
    if get_field(i_tc_buffer, 42, 12) != '000000000000' then
    
        l_nbc_fin_rec.settl_currency       := get_field(i_tc_buffer, 174, 3);
        l_currency_exponent                := com_api_currency_pkg.get_currency_exponent(i_curr_code => l_nbc_fin_rec.settl_currency);
        l_nbc_fin_rec.sttl_amount          := get_amount(
                                                  i_currency_exponent => l_currency_exponent
                                                , i_start             => 42
                                                , i_length            => 12
                                              );
    end if;                                        
    trc_log_pkg.debug (
        i_text          => 'l_nbc_fin_rec.sttl_amount [' || l_nbc_fin_rec.sttl_amount || ']'
    );

    -- 0 will be added up if the value is null
    if get_field(i_tc_buffer, 54, 12) != '000000000000' then
        l_nbc_fin_rec.crdh_bill_currency   := get_field(i_tc_buffer, 177, 3);
        l_currency_exponent                := com_api_currency_pkg.get_currency_exponent(i_curr_code => l_nbc_fin_rec.crdh_bill_currency);
        l_nbc_fin_rec.crdh_bill_amount     := get_amount(
                                                  i_currency_exponent => l_currency_exponent
                                                , i_start             => 54
                                                , i_length            => 12
                                              );
    end if;                                        
    trc_log_pkg.debug (
        i_text          => 'l_nbc_fin_rec.crdh_bill_amount [' || l_nbc_fin_rec.crdh_bill_amount || ']'
    );
        
    l_nbc_fin_rec.crdh_bill_fee        := get_field(i_tc_buffer, 66, 8); --decimal place?
    
    
    l_sttl_rate                        := get_field(i_tc_buffer, 74, 8);    
    trc_log_pkg.debug (
        i_text          => 'l_sttl_rate  [' || l_sttl_rate  || ']'
    );
    -- 0 will be added up if the value is null
    if l_sttl_rate != '00000000' then

        l_decimal_place          := substr(l_sttl_rate, 1, 1); 
        if l_decimal_place != '0' then
            l_nbc_fin_rec.settl_rate := to_number(substr(l_sttl_rate, 2, l_decimal_place))/ power(10, l_decimal_place);  
        else
            l_nbc_fin_rec.settl_rate := to_number(l_sttl_rate)/ power(10, l_decimal_place);  
        end if;
        trc_log_pkg.debug (
            i_text          => 'l_decimal_place [' || l_decimal_place || '], l_nbc_fin_rec.settl_rate [' || l_nbc_fin_rec.settl_rate || ']'
        );        
    end if;
    
    l_crdh_bill_rate             := get_field(i_tc_buffer, 82, 8);
    trc_log_pkg.debug (
        i_text          => 'l_crdh_bill_rate [' || l_crdh_bill_rate || ']'
    );
    -- 0 will be added up if the value is null
    if l_crdh_bill_rate != '00000000' then

        l_decimal_place          := substr(l_crdh_bill_rate, 1, 1); 
        
        if l_decimal_place != '0' then
            l_nbc_fin_rec.crdh_bill_rate := to_number(substr(l_crdh_bill_rate, 2, l_decimal_place))/ power(10, l_decimal_place);  
        else
            l_nbc_fin_rec.crdh_bill_rate := to_number(l_crdh_bill_rate)/ power(10, l_decimal_place);  
        end if;
        
        trc_log_pkg.debug (
            i_text          => 'l_decimal_place [' || l_decimal_place || '], l_nbc_fin_rec.crdh_bill_rate [' || l_nbc_fin_rec.crdh_bill_rate || ']'
        );
        
    end if;

    l_nbc_fin_rec.system_trace_number  := get_field(i_tc_buffer, 90, 6);
    
    l_nbc_fin_rec.local_trans_time     := get_field(i_tc_buffer, 96, 6);        
    l_nbc_fin_rec.local_trans_date     := date_mmdd_time (
                                              p_date   => get_field(i_tc_buffer, 102, 4)
                                            , p_time   => l_nbc_fin_rec.local_trans_time
                                          );
    
    l_nbc_fin_rec.settlement_date      := date_mmdd(get_field(i_tc_buffer, 106, 4));
    
    l_nbc_fin_rec.merchant_type        := get_field(i_tc_buffer, 110, 4);

    l_currency_exponent                := com_api_currency_pkg.get_currency_exponent(i_curr_code => l_nbc_fin_rec.trans_currency);
    l_nbc_fin_rec.trans_fee_amount     := get_amount(
                                              i_currency_exponent => l_currency_exponent
                                            , i_start             => 114
                                            , i_length            => 8
                                          );
    
    l_nbc_fin_rec.acq_inst_code        := get_field(i_tc_buffer, 122, 7);
    l_nbc_fin_rec.iss_inst_code        := get_field(i_tc_buffer, 129, 7);
    l_nbc_fin_rec.bnb_inst_code        := get_field(i_tc_buffer, 136, 7);
    l_nbc_fin_rec.rrn                  := get_field(i_tc_buffer, 143, 12);
    l_nbc_fin_rec.auth_number          := get_field(i_tc_buffer, 155, 6);
    l_nbc_fin_rec.resp_code            := get_field(i_tc_buffer, 161, 2);      
    l_nbc_fin_rec.terminal_id          := get_field(i_tc_buffer, 163, 8);
    l_nbc_fin_rec.from_account_id      := get_field(i_tc_buffer, 180, 28);
    l_nbc_fin_rec.to_account_id        := get_field(i_tc_buffer, 208, 28);
    
    l_currency_exponent                := com_api_currency_pkg.get_currency_exponent(i_curr_code => l_nbc_fin_rec.trans_currency);

    -- 0 will be added up if the value is null
    if get_field(i_tc_buffer, 236, 8) != '00000000' then 
        l_nbc_fin_rec.nbc_fee := get_amount(
                                     i_currency_exponent => l_currency_exponent
                                   , i_start             => 236
                                   , i_length            => 8
                                 );
    end if;                                           
    
    if get_field(i_tc_buffer, 244, 8) != '00000000' then
        l_nbc_fin_rec.acq_fee := get_amount(
                                     i_currency_exponent => l_currency_exponent
                                   , i_start             => 244
                                   , i_length            => 8
                                 );
    end if;
  
    if get_field(i_tc_buffer, 252, 8) != '00000000' then
        l_nbc_fin_rec.iss_fee := get_amount(
                                     i_currency_exponent => l_currency_exponent
                                   , i_start             => 252
                                   , i_length            => 8
                                 );
    end if;
    
    if get_field(i_tc_buffer, 260, 8) != '00000000' then
        l_nbc_fin_rec.bnb_fee := get_amount(
                                     i_currency_exponent => l_currency_exponent
                                   , i_start             => 260
                                   , i_length            => 8
                                 );
    end if;
    
    l_nbc_fin_rec.mti                  := get_field(i_tc_buffer, 268, 4);
    
    l_nbc_fin_rec.split_hash           := com_api_hash_pkg.get_split_hash(l_nbc_fin_rec.card_number);

    -- search original_id status = Invalid if don't found 
    l_nbc_fin_rec.original_id := get_original_id(
                                     i_nbc_fin_rec     => l_nbc_fin_rec
                                 );
    if l_nbc_fin_rec.original_id is null then
    
        l_nbc_fin_rec.is_invalid := com_api_type_pkg.TRUE;
        l_nbc_fin_rec.status     := net_api_const_pkg.CLEARING_MSG_STATUS_INVALID;
        g_error_flag             := com_api_type_pkg.TRUE;

        trc_log_pkg.warn (
            i_text          => 'Original operation not found. original_id [' || l_nbc_fin_rec.original_id ||']'
        );    
        
    end if;

    l_nbc_fin_rec.id := nbc_api_fin_message_pkg.put_message (
        i_fin_rec => l_nbc_fin_rec
    );        

    trc_log_pkg.debug (
        i_text          => 'nbc_prc_incoming_pkg.process_presentment_rf end'
    );    
end;    

procedure process_presentment_df(
    i_tc_buffer             in      varchar2
    , i_nbc_file            in      nbc_api_type_pkg.t_nbc_file_rec
    , i_standard_id         in      com_api_type_pkg.t_tiny_id
) is
    l_nbc_fin_rec           nbc_api_type_pkg.t_nbc_fin_mes_rec;
    l_currency_exponent     com_api_type_pkg.t_tiny_id;
    l_decimal_place         pls_integer := 0;
    l_crdh_bill_rate        com_api_type_pkg.t_cmid;
    l_sttl_rate             com_api_type_pkg.t_cmid;
    
    function get_amount(
        i_currency_exponent     in com_api_type_pkg.t_tiny_id
      , i_start                 in pls_integer
      , i_length                in pls_integer
    ) return com_api_type_pkg.t_money is
        l_amount    com_api_type_pkg.t_money := 0;
    begin
        if i_currency_exponent = 0 then
        
            l_amount     := get_field(i_tc_buffer, i_start, i_length - 2);
        else
            l_amount     := get_field(i_tc_buffer, i_start, i_length);
            
            if i_currency_exponent > 2 then
                l_amount := l_amount * power(10, i_currency_exponent - 2);
            end if;
        end if;
        
        return l_amount;
    end;
   
begin
    trc_log_pkg.debug (
        i_text          => 'nbc_prc_incoming_pkg.process_presentment_df start'
    );

    -- init_record
    l_nbc_fin_rec.id                   := opr_api_create_pkg.get_id;
    l_nbc_fin_rec.status               := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;
    l_nbc_fin_rec.is_reversal          := com_api_type_pkg.FALSE;
    l_nbc_fin_rec.is_incoming          := com_api_type_pkg.TRUE;
    l_nbc_fin_rec.is_invalid           := com_api_type_pkg.FALSE;
    l_nbc_fin_rec.inst_id              := i_nbc_file.inst_id;
    l_nbc_fin_rec.network_id           := i_nbc_file.network_id;
    l_nbc_fin_rec.msg_file_type        := i_nbc_file.file_type;
    l_nbc_fin_rec.participant_type     := i_nbc_file.participant_type;
    l_nbc_fin_rec.file_id              := i_nbc_file.id;

    l_nbc_fin_rec.record_type          := get_field(i_tc_buffer, 1, 4); 
    l_nbc_fin_rec.card_number          := trim(leading '0' from get_field(i_tc_buffer, 5, 19));
    l_nbc_fin_rec.card_mask            := iss_api_card_pkg.get_card_mask(l_nbc_fin_rec.card_number);
    l_nbc_fin_rec.card_hash            := com_api_hash_pkg.get_card_hash(l_nbc_fin_rec.card_number);
    l_nbc_fin_rec.proc_code            := get_field(i_tc_buffer, 24, 6);  
    
    l_nbc_fin_rec.trans_currency       := get_field(i_tc_buffer, 177, 3);
    l_currency_exponent                := com_api_currency_pkg.get_currency_exponent(i_curr_code => l_nbc_fin_rec.trans_currency);
    l_nbc_fin_rec.trans_amount         := get_amount(
                                              i_currency_exponent => l_currency_exponent
                                            , i_start             => 30
                                            , i_length            => 12
                                          );
    trc_log_pkg.debug (
        i_text          => 'l_nbc_fin_rec.trans_amount [' || l_nbc_fin_rec.trans_amount || ']'
    );
        
    if get_field(i_tc_buffer, 42, 12) != '000000000000' then
        l_nbc_fin_rec.settl_currency       := get_field(i_tc_buffer, 180, 3);
        l_currency_exponent                := com_api_currency_pkg.get_currency_exponent(i_curr_code => l_nbc_fin_rec.settl_currency);
        l_nbc_fin_rec.sttl_amount          := get_amount(
                                                  i_currency_exponent => l_currency_exponent
                                                , i_start             => 42
                                                , i_length            => 12
                                              );
    end if;                                            
    trc_log_pkg.debug (
        i_text          => 'l_nbc_fin_rec.sttl_amount [' || l_nbc_fin_rec.sttl_amount || ']'
    );

    if get_field(i_tc_buffer, 54, 12) != '000000000000' then
        l_nbc_fin_rec.crdh_bill_currency   := get_field(i_tc_buffer, 183, 3);
        l_currency_exponent                := com_api_currency_pkg.get_currency_exponent(i_curr_code => l_nbc_fin_rec.crdh_bill_currency);
        l_nbc_fin_rec.crdh_bill_amount     := get_amount(
                                                  i_currency_exponent => l_currency_exponent
                                                , i_start             => 54
                                                , i_length            => 12
                                              );
    end if;                                        
    trc_log_pkg.debug (
        i_text          => 'l_nbc_fin_rec.crdh_bill_amount [' || l_nbc_fin_rec.crdh_bill_amount || ']'
    );
        
    l_nbc_fin_rec.crdh_bill_fee        := get_field(i_tc_buffer, 66, 8); --decimal place?
    
    l_sttl_rate                        := get_field(i_tc_buffer, 74, 8);    
    trc_log_pkg.debug (
        i_text          => 'l_sttl_rate  [' || l_sttl_rate  || ']'
    );
    if l_sttl_rate != '00000000' then

        l_decimal_place          := substr(l_sttl_rate, 1, 1); 
        if l_decimal_place != '0' then
            l_nbc_fin_rec.settl_rate := to_number(substr(l_sttl_rate, 2, l_decimal_place))/ power(10, l_decimal_place);  
        else
            l_nbc_fin_rec.settl_rate := to_number(l_sttl_rate)/ power(10, l_decimal_place);  
        end if;
        trc_log_pkg.debug (
            i_text          => 'l_decimal_place [' || l_decimal_place || '], l_nbc_fin_rec.settl_rate [' || l_nbc_fin_rec.settl_rate || ']'
        );        
    end if;
    
    l_crdh_bill_rate             := get_field(i_tc_buffer, 82, 8);
    trc_log_pkg.debug (
        i_text          => 'l_crdh_bill_rate [' || l_crdh_bill_rate || ']'
    );
    if l_crdh_bill_rate != '00000000' then

        l_decimal_place          := substr(l_crdh_bill_rate, 1, 1); 
        
        if l_decimal_place != '0' then
            l_nbc_fin_rec.crdh_bill_rate := to_number(substr(l_crdh_bill_rate, 2, l_decimal_place))/ power(10, l_decimal_place);  
        else
            l_nbc_fin_rec.crdh_bill_rate := to_number(l_crdh_bill_rate)/ power(10, l_decimal_place);  
        end if;
        
        trc_log_pkg.debug (
            i_text          => 'l_decimal_place [' || l_decimal_place || '], l_nbc_fin_rec.crdh_bill_rate [' || l_nbc_fin_rec.crdh_bill_rate || ']'
        );
        
    end if;

    l_nbc_fin_rec.system_trace_number  := get_field(i_tc_buffer, 90, 6);
    trc_log_pkg.debug (
        i_text          => 'l_nbc_fin_rec.system_trace_number [' || l_nbc_fin_rec.system_trace_number || ']'
    );
    
    l_nbc_fin_rec.local_trans_time     := get_field(i_tc_buffer, 96, 6);   

    trc_log_pkg.debug (
        i_text          => 'get_field(i_tc_buffer, 102, 4) [' || get_field(i_tc_buffer, 102, 4) || '], l_nbc_fin_rec.local_trans_time ['||l_nbc_fin_rec.local_trans_time||']'
    );
     
    l_nbc_fin_rec.local_trans_date     := date_mmdd_time (
                                              p_date   => get_field(i_tc_buffer, 102, 4)
                                            , p_time   => l_nbc_fin_rec.local_trans_time
                                          );
    
    l_nbc_fin_rec.settlement_date      := date_mmdd(get_field(i_tc_buffer, 106, 4));
    
    l_nbc_fin_rec.merchant_type        := get_field(i_tc_buffer, 110, 4);

    l_currency_exponent                := com_api_currency_pkg.get_currency_exponent(i_curr_code => l_nbc_fin_rec.trans_currency);
    l_nbc_fin_rec.trans_fee_amount     := get_amount(
                                              i_currency_exponent => l_currency_exponent
                                            , i_start             => 114
                                            , i_length            => 8
                                          );
    
    l_nbc_fin_rec.acq_inst_code        := get_field(i_tc_buffer, 122, 7);
    l_nbc_fin_rec.iss_inst_code        := get_field(i_tc_buffer, 129, 7);
    l_nbc_fin_rec.bnb_inst_code        := get_field(i_tc_buffer, 136, 7);
    l_nbc_fin_rec.rrn                  := get_field(i_tc_buffer, 143, 12);
    l_nbc_fin_rec.auth_number          := get_field(i_tc_buffer, 155, 6);

    l_nbc_fin_rec.nbc_resp_code        := get_field(i_tc_buffer, 161, 2);
    l_nbc_fin_rec.acq_resp_code        := get_field(i_tc_buffer, 163, 2);
    l_nbc_fin_rec.iss_resp_code        := get_field(i_tc_buffer, 165, 2);
    l_nbc_fin_rec.bnb_resp_code        := get_field(i_tc_buffer, 167, 2);
    
    l_nbc_fin_rec.terminal_id          := get_field(i_tc_buffer, 169, 8);
    
    l_nbc_fin_rec.from_account_id      := get_field(i_tc_buffer, 186, 28);
    l_nbc_fin_rec.to_account_id        := get_field(i_tc_buffer, 214, 28);
    
    l_currency_exponent                := com_api_currency_pkg.get_currency_exponent(i_curr_code => l_nbc_fin_rec.trans_currency);
    if get_field(i_tc_buffer, 242, 8) != '00000000' then
        l_nbc_fin_rec.nbc_fee := get_amount(
                                     i_currency_exponent => l_currency_exponent
                                   , i_start             => 242
                                   , i_length            => 8
                                 );
    end if;

    if get_field(i_tc_buffer, 250, 8) != '00000000' then
        l_nbc_fin_rec.acq_fee := get_amount(
                                     i_currency_exponent => l_currency_exponent
                                   , i_start             => 250
                                   , i_length            => 8
                                 );
    end if;
    
    if get_field(i_tc_buffer, 258, 8)  != '00000000' then
        l_nbc_fin_rec.iss_fee := get_amount(
                                     i_currency_exponent => l_currency_exponent
                                   , i_start             => 258
                                   , i_length            => 8
                                 );
    end if;

    if get_field(i_tc_buffer, 266, 8) != '00000000' then
        l_nbc_fin_rec.bnb_fee := get_amount(
                                     i_currency_exponent => l_currency_exponent
                                   , i_start             => 266
                                   , i_length            => 8
                                 );
    end if;
    
    l_nbc_fin_rec.mti                  := get_field(i_tc_buffer, 274, 4);

    l_nbc_fin_rec.split_hash           := com_api_hash_pkg.get_split_hash(l_nbc_fin_rec.card_number);
    
    l_nbc_fin_rec.dispute_trans_result := get_field(i_tc_buffer, 278, 2);
    
    -- search original_id status = Invalid if don't found 
    l_nbc_fin_rec.original_id := get_original_id(
                                     i_nbc_fin_rec     => l_nbc_fin_rec
                                 );
    if l_nbc_fin_rec.original_id is null then
    
        l_nbc_fin_rec.is_invalid := com_api_type_pkg.TRUE;
        l_nbc_fin_rec.status     := net_api_const_pkg.CLEARING_MSG_STATUS_INVALID;
        g_error_flag             := com_api_type_pkg.TRUE;
    end if;
    
    assign_dispute(
        io_nbc_fin_rec  => l_nbc_fin_rec
    );
    
    if l_nbc_fin_rec.dispute_id is null then
    
        l_nbc_fin_rec.is_invalid := com_api_type_pkg.TRUE;
        l_nbc_fin_rec.status     := net_api_const_pkg.CLEARING_MSG_STATUS_INVALID;
        g_error_flag             := com_api_type_pkg.TRUE;
    end if;
    
    l_nbc_fin_rec.id := nbc_api_fin_message_pkg.put_message (
        i_fin_rec => l_nbc_fin_rec
    );        
      
    trc_log_pkg.debug (
        i_text          => 'nbc_prc_incoming_pkg.process_presentment_df end'
    );    
end;    

procedure process_rf (
    i_network_id            in com_api_type_pkg.t_tiny_id
)is
    l_tc_buffer             nbc_api_type_pkg.t_tc_buffer;
    l_nbc_file              nbc_api_type_pkg.t_nbc_file_rec;
    l_host_id               com_api_type_pkg.t_tiny_id;
    l_standard_id           com_api_type_pkg.t_tiny_id;
    l_record_count          com_api_type_pkg.t_long_id := 0;
    l_errors_count          com_api_type_pkg.t_long_id := 0;

    l_trailer_load          com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE;
    l_header_load           com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE;
    l_file_found            com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE;
    l_files_tab             com_api_type_pkg.t_name_tab;

    cursor cu_records_count is
        select count(1)
          from prc_file_raw_data a
             , prc_session_file b
         where b.session_id      = prc_api_session_pkg.get_session_id
           and a.session_file_id = b.id
           and substr(a.raw_data, 1, 4) = nbc_api_const_pkg.RECORD_TYPE_DETAIL;
               
    procedure check_sf_file is
    begin
        trc_log_pkg.debug (
            i_text          => 'check_sf_file start'
        );    
        for r in (
            select extractValue(column_value, '/file_name') as file_name
              from prc_session_file s
                 , xmltable('/statistics/list_file/file_name' passing s.file_xml_contents
                       columns
                           file_name           varchar2(200)   path 'file_name'
                   ) x
             where s.session_id = prc_api_session_pkg.get_session_id
               and s.file_type  = nbc_api_const_pkg.FILE_TYPE_NBC_SF
        ) 
        loop
        
            l_file_found := com_api_type_pkg.FALSE;
            
            for i in 1..l_files_tab.count loop
            
                if l_files_tab(i) = r.file_name then
                
                    l_file_found := com_api_type_pkg.TRUE;
                    exit;
                end if;
            end loop;
            
            if l_file_found = com_api_type_pkg.FALSE then
            
                com_api_error_pkg.raise_error(
                    i_error         => 'NBC_SF_NOT_MATCH_WITH_LOADED_FILES'
                    , i_env_param1  => r.file_name
                );
            end if;  
        end loop;
        
      --  close cu_sf;
        
        trc_log_pkg.debug (
            i_text          => 'check_sf_file end'
        );    
        
    end;

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
    -- get network communication standard
    l_host_id       := net_api_network_pkg.get_default_host(i_network_id);
    l_standard_id   := net_api_network_pkg.get_offline_standard(i_network_id => i_network_id);

    for p in (
        select id session_file_id
             , record_count
             , file_type
             , file_name
          from prc_session_file
         where session_id = prc_api_session_pkg.get_session_id
         order by decode(file_type, 'FLTPNBSF', 1, 0)
             , id
    ) loop
        l_errors_count := 0;
        l_trailer_load := com_api_type_pkg.FALSE;
        l_header_load  := com_api_type_pkg.FALSE;

        if p.file_type != nbc_api_const_pkg.FILE_TYPE_NBC_SF then 
        
            begin
                savepoint sp_nbc_incoming_file;
                
                trc_log_pkg.debug (
                    i_text          => 'nbc_prc_incoming_pkg.process_rf start. Session file=' || p.session_file_id
                );
                
                for r in (
                    select
                        record_number
                        , raw_data
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
                        
                        if substr(l_tc_buffer(1), 1, 4) = nbc_api_const_pkg.RECORD_TYPE_HEADER then
                        
                            process_file_header(
                                i_header_data       =>  l_tc_buffer(1)
                                , i_network_id      =>  i_network_id
                                , i_standard_id     =>  l_standard_id
                                , i_host_id         =>  l_host_id
                                , i_session_file_id =>  p.session_file_id
                                , i_file_type       =>  p.file_type
                                , o_nbc_file        =>  l_nbc_file
                            );
                            l_header_load := com_api_type_pkg.TRUE;
                        else
                            com_api_error_pkg.raise_error(
                                i_error          => 'HEADER_NOT_FOUND'
                                , i_env_param1   => p.session_file_id
                            );
                        end if;              
                        
                    elsif substr(l_tc_buffer(1), 1, 4) = nbc_api_const_pkg.RECORD_TYPE_TRAILER then
                    
                        process_file_trailer (
                            i_trailer_data       =>  l_tc_buffer(1)
                            , io_nbc_file        =>  l_nbc_file
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
                        
                        process_presentment_rf(
                            i_tc_buffer          =>  l_tc_buffer(1)
                            , i_nbc_file         =>  l_nbc_file
                            , i_standard_id      =>  l_standard_id
                        );
                        l_record_count := l_record_count + 1;
                    end if;                                

                    -- cleanup buffer before loading next record(s)
                    l_tc_buffer.delete;

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
                
                l_files_tab(nvl(l_files_tab.last, 0) + 1) := p.file_name;

                trc_log_pkg.debug (
                    i_text          => 'nbc_prc_incoming.process_rf end. Session file=' || p.session_file_id
                );
                
            exception
                when com_api_error_pkg.e_application_error then
                
                    rollback to sp_nbc_incoming_file;

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
        
        else
            -- parse SF file
            check_sf_file;
        end if;
    end loop;
    
    prc_api_stat_pkg.log_end(
        i_processed_total   => l_record_count
      , i_excepted_total    => l_errors_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug (
        i_text          => 'nbc_prc_incoming.process_rf end.'
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
    
end process_rf;

procedure process_df (
    i_network_id            in com_api_type_pkg.t_tiny_id
) is
    l_tc_buffer             nbc_api_type_pkg.t_tc_buffer;
    l_nbc_file              nbc_api_type_pkg.t_nbc_file_rec;
    l_host_id               com_api_type_pkg.t_tiny_id;
    l_standard_id           com_api_type_pkg.t_tiny_id;
    l_record_count          com_api_type_pkg.t_long_id := 0;
    l_errors_count          com_api_type_pkg.t_long_id := 0;

    l_trailer_load          com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE;
    l_header_load           com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE;

    cursor cu_records_count is
        select count(1)
          from prc_file_raw_data a
             , prc_session_file b
         where b.session_id      = prc_api_session_pkg.get_session_id
           and a.session_file_id = b.id
           and substr(a.raw_data, 1, 4) = nbc_api_const_pkg.RECORD_TYPE_DETAIL;

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
    -- get network communication standard
    l_host_id       := net_api_network_pkg.get_default_host(i_network_id);
    l_standard_id   := net_api_network_pkg.get_offline_standard(i_network_id => i_network_id);

    for p in (
        select id session_file_id
             , record_count
             , file_type
          from prc_session_file
         where session_id = prc_api_session_pkg.get_session_id
         order by id
    ) loop
        l_errors_count := 0;
        l_trailer_load := com_api_type_pkg.FALSE;
        l_header_load  := com_api_type_pkg.FALSE;
        
        begin
            savepoint sp_nbc_incoming_file;
            
            trc_log_pkg.debug (
                i_text          => 'nbc_prc_incoming_pkg.process_df start. Session file=' || p.session_file_id
            );
            
            for r in (
                select
                    record_number
                    , raw_data
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
                    
                    if substr(l_tc_buffer(1), 1, 4) = nbc_api_const_pkg.RECORD_TYPE_HEADER then
                    
                        process_file_header(
                            i_header_data       =>  l_tc_buffer(1)
                            , i_network_id      =>  i_network_id
                            , i_standard_id     =>  l_standard_id
                            , i_host_id         =>  l_host_id
                            , i_session_file_id =>  p.session_file_id
                            , i_file_type       =>  p.file_type
                            , o_nbc_file        =>  l_nbc_file
                        );
                        l_header_load := com_api_type_pkg.TRUE;
                    else
                        com_api_error_pkg.raise_error(
                            i_error          => 'HEADER_NOT_FOUND'
                            , i_env_param1   => p.session_file_id
                        );
                    end if;              
                    
                elsif substr(l_tc_buffer(1), 1, 4) = nbc_api_const_pkg.RECORD_TYPE_TRAILER then
                
                    process_file_trailer (
                        i_trailer_data       =>  l_tc_buffer(1)
                        , io_nbc_file        =>  l_nbc_file
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
                    
                    process_presentment_df(
                        i_tc_buffer          =>  l_tc_buffer(1)
                        , i_nbc_file         =>  l_nbc_file
                        , i_standard_id      =>  l_standard_id
                    );
                    l_record_count := l_record_count + 1;
                end if;                                

                -- cleanup buffer before loading next record(s)
                l_tc_buffer.delete;

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
                i_text          => 'nbc_prc_incoming.process_df end.'
            );
            
        exception
            when com_api_error_pkg.e_application_error then
            
                rollback to sp_nbc_incoming_file;

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
    
end process_df;

end;
/
