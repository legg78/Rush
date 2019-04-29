create or replace package body cmp_prc_incoming_pkg as 

g_error_flag        com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE;

function get_field(
    i_tc_buffer    in   varchar2
    , i_ident      in   com_api_type_pkg.t_name 
    , i_max_length in   com_api_type_pkg.t_tiny_id default null
) return varchar2 is

    l_instr_field  com_api_type_pkg.t_tiny_id;
    l_length_ident com_api_type_pkg.t_sign;
    l_length_buf   com_api_type_pkg.t_tiny_id;
    l_value_field  com_api_type_pkg.t_name;
    l_instr_delim  com_api_type_pkg.t_tiny_id;
    
begin
    l_length_ident := length(i_ident);
    l_length_buf   := length(i_tc_buffer);
    -- position of value of field
    l_instr_field  := instr(i_tc_buffer, cmp_api_const_pkg.DELIM_FIELD || i_ident || '=') + 1; 
    if l_instr_field = 1 then
        return null;
    end if;
    --  position of delimitor
    l_instr_delim := instr(substr(i_tc_buffer, l_instr_field + l_length_ident + 1),cmp_api_const_pkg.DELIM_FIELD); 
        
    if l_instr_delim = 0 then
        -- case when the record is last
        l_instr_delim := l_length_buf + 1;
    end if;
    
    -- value of field
    l_value_field := substr(i_tc_buffer, l_instr_field + l_length_ident + 1, l_instr_delim - 1); 
        
    l_value_field := trim(l_value_field);
            
    if i_max_length is not null and i_max_length < length(l_value_field) then
        l_value_field := substr(l_value_field, 1, i_max_length);
    end if;
            
    return l_value_field;
end;

procedure process_file_header(
    i_header_data         in     varchar2
  , i_network_id          in     com_api_type_pkg.t_tiny_id
  , i_standard_id         in     com_api_type_pkg.t_tiny_id
  , i_action_code         in     com_api_type_pkg.t_curr_code
  , i_dst_inst_id         in     com_api_type_pkg.t_inst_id    
  , i_inst_name           in     com_api_type_pkg.t_name
  , i_host_id             in     com_api_type_pkg.t_tiny_id
  , i_incom_sess_file_id  in     com_api_type_pkg.t_long_id
  , o_cmp_file               out cmp_api_type_pkg.t_cmp_file_rec
) is
begin
    trc_log_pkg.debug (
        i_text          => 'cmp_prc_incoming_pkg.process_file_header start'
    );

    o_cmp_file.is_incoming         := com_api_type_pkg.TRUE;
    o_cmp_file.is_rejected         := com_api_type_pkg.FALSE;
    o_cmp_file.network_id          := i_network_id;
    o_cmp_file.trans_date          := get_sysdate;
    o_cmp_file.inst_name           := i_inst_name;
      
    --search inst_id of inst_name
    o_cmp_file.inst_id := i_dst_inst_id;
    if o_cmp_file.inst_id is null then
    
        o_cmp_file.inst_id := cmn_api_standard_pkg.find_value_owner (
            i_standard_id       => i_standard_id
          , i_entity_type       => net_api_const_pkg.ENTITY_TYPE_HOST
          , i_object_id         => i_host_id
          , i_param_name        => cmp_api_const_pkg.COMPASS_ACQUIRER_NAME
          , i_value_char        => i_inst_name
        );

        if o_cmp_file.inst_id is null then
            com_api_error_pkg.raise_error(
                i_error       => 'CMP_INSTITUTION_NOT_FOUND'
              , i_env_param1  => i_inst_name
              , i_env_param2  => i_network_id
            );
        end if;
    
    end if;
    
    o_cmp_file.action_code := get_field(
        i_tc_buffer  => i_header_data
      , i_ident      => cmp_api_const_pkg.IDENT_TEST 
      , i_max_length => null
    );
    trc_log_pkg.debug (
        i_text          => 'o_cmp_file.action_code=' || o_cmp_file.action_code || ' i_action_code='||i_action_code
    );
    
    if nvl(i_action_code, '0') != nvl(o_cmp_file.action_code, '0') then
        com_api_error_pkg.raise_error(
            i_error       => 'CMP_WRONG_TEST_OPTION_PARAMETER'
          , i_env_param1  => i_action_code
          , i_env_param2  => o_cmp_file.action_code
        );
    end if;
        
    o_cmp_file.file_number := 0;
    o_cmp_file.pack_no := get_field(
        i_tc_buffer  => i_header_data
      , i_ident      => cmp_api_const_pkg.IDENT_PACKNO 
      , i_max_length => null
    );
    o_cmp_file.version := get_field(
        i_tc_buffer    => i_header_data
        , i_ident      => cmp_api_const_pkg.IDENT_VERSION 
        , i_max_length => null
    );
    o_cmp_file.encoding := get_field(
        i_tc_buffer    => i_header_data
        , i_ident      => cmp_api_const_pkg.IDENT_ENCODING 
        , i_max_length => null
    );
    o_cmp_file.file_type := get_field(
        i_tc_buffer    => i_header_data
        , i_ident      => cmp_api_const_pkg.IDENT_FILETYPE 
        , i_max_length => null
    );

    if i_standard_id is null then
        com_api_error_pkg.raise_error(
            i_error         => 'UNKNOWN_NETWORK'
            , i_env_param1  => i_network_id
        );
    end if;

    o_cmp_file.session_file_id := i_incom_sess_file_id;
    o_cmp_file.id              := com_api_id_pkg.get_id(cmp_file_seq.nextval, get_sysdate);

    trc_log_pkg.debug (
        i_text          => 'o_cmp_file.id = ' || o_cmp_file.id
    );

    trc_log_pkg.debug (
        i_text          => 'cmp_prc_incoming_pkg.process_file_header end'
    );
end;

procedure process_file_trailer (
    i_trailer_data          in      varchar2
    , io_cmp_file           in  out cmp_api_type_pkg.t_cmp_file_rec
) is
begin
    trc_log_pkg.debug (
        i_text          => 'cmp_prc_incoming_pkg.process_file_trailer start, file_id='|| io_cmp_file.id
    );

    io_cmp_file.crc := get_field(
        i_tc_buffer    => i_trailer_data
        , i_ident      => cmp_api_const_pkg.IDENT_CRC 
        , i_max_length => null
    );

    insert into cmp_file (
        id
        , is_incoming
        , is_rejected
        , network_id
        , trans_date
        , inst_id
        , inst_name
        , action_code
        , file_number
        , pack_no
        , version
        , crc
        , encoding
        , file_type
        , session_file_id
    )
    values(
        io_cmp_file.id
        , io_cmp_file.is_incoming
        , io_cmp_file.is_rejected
        , io_cmp_file.network_id
        , io_cmp_file.trans_date
        , io_cmp_file.inst_id
        , io_cmp_file.inst_name
        , io_cmp_file.action_code
        , io_cmp_file.file_number
        , io_cmp_file.pack_no
        , io_cmp_file.version
        , io_cmp_file.crc
        , io_cmp_file.encoding
        , io_cmp_file.file_type
        , io_cmp_file.session_file_id
    );
    trc_log_pkg.debug (
        i_text          => 'cmp_prc_incoming_pkg.process_file_trailer end'
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

procedure create_operation(
    io_cmp_fin_rec       in out nocopy  cmp_api_type_pkg.t_cmp_fin_mes_rec
  , i_standard_id        in             com_api_type_pkg.t_tiny_id
  , i_incom_sess_file_id in             com_api_type_pkg.t_long_id
  , i_network_id         in             com_api_type_pkg.t_tiny_id
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
    l_standard_version_id   com_api_type_pkg.t_tiny_id;
    l_network_oper_type     com_api_type_pkg.t_dict_value;
begin
    trc_log_pkg.debug (
        i_text          => 'cmp_prc_incoming_pkg.create_operation start'
    );

    -- get card inst
    iss_api_bin_pkg.get_bin_info (
        i_card_number      => io_cmp_fin_rec.card_number
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
        io_cmp_fin_rec.is_invalid := com_api_type_pkg.TRUE;
        l_iss_inst_id     := io_cmp_fin_rec.inst_id;
        l_iss_network_id  := ost_api_institution_pkg.get_inst_network(io_cmp_fin_rec.inst_id);
    end if;

    if l_acq_inst_id is null then
        l_acq_network_id := io_cmp_fin_rec.network_id;
        l_acq_inst_id    := net_api_network_pkg.get_inst_id(io_cmp_fin_rec.network_id);
    end if;

    l_standard_version_id := cmn_api_standard_pkg.get_current_version(
        i_network_id => i_network_id
    );

    -- mapping
    l_network_oper_type := io_cmp_fin_rec.tran_code
                        || case
                           when l_standard_version_id >= cmp_api_const_pkg.CMP_STANDARD_VERSION_ID_17R2
                           then io_cmp_fin_rec.mcc
                           else '____'
                           end;

    trc_log_pkg.debug('network_oper_type=' || l_network_oper_type);

    l_oper.oper_type := net_api_map_pkg.get_oper_type (
        i_network_oper_type  => l_network_oper_type
      , i_standard_id        => i_standard_id
    );
 
    net_api_sttl_pkg.get_sttl_type (
        i_iss_inst_id      => l_iss_inst_id
      , i_acq_inst_id      => l_acq_inst_id
      , i_card_inst_id     => l_card_inst_id
      , i_iss_network_id   => l_iss_network_id
      , i_acq_network_id   => l_acq_network_id
      , i_card_network_id  => l_card_network_id
      , i_acq_inst_bin     => io_cmp_fin_rec.term_inst_id
      , o_sttl_type        => l_sttl_type
      , o_match_status     => l_match_status
      , i_oper_type        => l_oper.oper_type
    );
    trc_log_pkg.debug (i_text => 'standard_id=' || i_standard_id || ', standard_version_id=' || l_standard_version_id
                    || ', sttl_type=' || l_sttl_type || ', oper_type=' || l_oper.oper_type 
                    || ',tran_code=' || io_cmp_fin_rec.tran_code || ', mcc=' || io_cmp_fin_rec.mcc);

    io_cmp_fin_rec.card_id := iss_api_card_pkg.get_card_id(io_cmp_fin_rec.card_number);
    io_cmp_fin_rec.card_mask := iss_api_card_pkg.get_card_mask(io_cmp_fin_rec.card_number);

    l_oper.match_status := l_match_status;

    l_oper.sttl_type := l_sttl_type;
    if l_oper.sttl_type is null then
        io_cmp_fin_rec.status := net_api_const_pkg.CLEARING_MSG_STATUS_INVALID;
        io_cmp_fin_rec.is_invalid := com_api_type_pkg.TRUE;
        g_error_flag := com_api_type_pkg.TRUE;
        com_api_error_pkg.raise_error(
            i_error       => 'UNABLE_DETERMINE_STTL_TYPE'
          , i_env_param1  => io_cmp_fin_rec.tran_type
          , i_env_param2  => iss_api_card_pkg.get_card_mask(i_card_number => io_cmp_fin_rec.card_number)
          , i_env_param3  => l_iss_inst_id
          , i_env_param4  => l_acq_inst_id
          , i_env_param5  => l_card_inst_id
          , i_env_param6  => l_iss_network_id || '/' || l_acq_network_id
        );
    end if;
    trc_log_pkg.debug (i_text => '2');

    if l_oper.oper_type is null then
        io_cmp_fin_rec.status     := net_api_const_pkg.CLEARING_MSG_STATUS_INVALID;
        io_cmp_fin_rec.is_invalid := com_api_type_pkg.TRUE;
        g_error_flag := com_api_type_pkg.TRUE;
        com_api_error_pkg.raise_error(
            i_error         => 'UNABLE_DETERMINE_OPER_TYPE'
            , i_env_param1  => io_cmp_fin_rec.tran_code
        );
    end if;

    l_oper.msg_type := net_api_map_pkg.get_msg_type (
        i_network_msg_type  => io_cmp_fin_rec.tran_type
        , i_standard_id     => i_standard_id
    );

    if l_oper.msg_type is null then
        io_cmp_fin_rec.status     := net_api_const_pkg.CLEARING_MSG_STATUS_INVALID;
        io_cmp_fin_rec.is_invalid := com_api_type_pkg.TRUE;
        g_error_flag := com_api_type_pkg.TRUE;
        com_api_error_pkg.raise_error(
            i_error         => 'NETWORK_MESSAGE_TYPE_EXCEPT'
            , i_env_param1  => io_cmp_fin_rec.tran_type
            , i_env_param2  => i_standard_id
        );
    end if;

    if io_cmp_fin_rec.is_invalid = com_api_type_pkg.TRUE then

        l_oper.status := opr_api_const_pkg.OPERATION_STATUS_MANUAL;
    end if;
    
    l_oper.id                      := io_cmp_fin_rec.id;
    l_oper.incom_sess_file_id      := i_incom_sess_file_id;

    l_oper.is_reversal             := io_cmp_fin_rec.is_reversal;
    l_oper.terminal_type           := case io_cmp_fin_rec.mcc
                                          when '6011'
                                          then acq_api_const_pkg.TERMINAL_TYPE_ATM
                                          else acq_api_const_pkg.TERMINAL_TYPE_POS
                                      end;
    l_oper.oper_amount             := io_cmp_fin_rec.amount;
    l_oper.oper_currency           := io_cmp_fin_rec.currency;
    l_oper.sttl_amount             := io_cmp_fin_rec.reconcil_amount;
    l_oper.sttl_currency           := io_cmp_fin_rec.reconcil_currency;
    l_oper.oper_date               := io_cmp_fin_rec.orig_time;
    l_oper.host_date               := null;
    l_oper.mcc                     := io_cmp_fin_rec.mcc;
    l_oper.originator_refnum       := null;
    l_oper.acq_inst_bin            := io_cmp_fin_rec.term_inst_id;
    l_oper.merchant_number         := io_cmp_fin_rec.ext_term_retailer_name;
    l_oper.terminal_number         := io_cmp_fin_rec.term_name;
    l_oper.merchant_name           := io_cmp_fin_rec.term_owner;
    l_oper.merchant_city           := io_cmp_fin_rec.term_city;
    l_oper.merchant_street         := io_cmp_fin_rec.term_location;
    l_oper.merchant_country        := io_cmp_fin_rec.term_country;
    l_oper.merchant_postcode       := io_cmp_fin_rec.term_zip;

    --l_oper.original_id       := cmp_api_fin_message_pkg.get_original_id(io_cmp_fin_rec);

    l_iss_part.inst_id             := l_iss_inst_id;
    l_iss_part.network_id          := l_iss_network_id;
    l_iss_part.card_id             := io_cmp_fin_rec.card_id;
    case when l_card_type_id is not null then
        l_iss_part.card_type_id    := l_card_type_id;
    else
        l_iss_part.card_type_id    := iss_api_card_pkg.get_card (
            i_card_number   => io_cmp_fin_rec.card_number
            , i_mask_error  => com_api_type_pkg.TRUE
        ).card_type_id;
    end case;
    l_iss_part.card_expir_date     := date_yymm(io_cmp_fin_rec.exp_date);
    l_iss_part.client_id_type      := opr_api_const_pkg.CLIENT_ID_TYPE_CARD;
    l_iss_part.client_id_value     := io_cmp_fin_rec.card_number;
    l_iss_part.customer_id         := iss_api_card_pkg.get_card (
        i_card_number   => io_cmp_fin_rec.card_number
        , i_mask_error  => com_api_type_pkg.TRUE
    ).customer_id;
    l_iss_part.card_mask           := io_cmp_fin_rec.card_mask;
    l_iss_part.card_number         := io_cmp_fin_rec.card_number;
    l_iss_part.card_hash           := io_cmp_fin_rec.card_hash;
    case when l_country_code is not null then
        l_iss_part.card_country    := l_country_code;
    else
        l_iss_part.card_country    := iss_api_card_pkg.get_card(
            i_card_number   => io_cmp_fin_rec.card_number
            , i_mask_error  => com_api_type_pkg.TRUE
        ).country;
    end case;
    l_iss_part.card_inst_id        := l_card_inst_id;
    l_iss_part.card_network_id     := l_card_network_id;
    l_iss_part.split_hash          := com_api_hash_pkg.get_split_hash(io_cmp_fin_rec.card_number);
    l_iss_part.account_amount      := null;
    l_iss_part.account_currency    := null;
    l_iss_part.account_number      := null;
    l_iss_part.auth_code           := substr(io_cmp_fin_rec.approval_code, 1, 6); 

    l_acq_part.inst_id             := l_acq_inst_id;
    l_acq_part.network_id          := l_acq_network_id;
    l_acq_part.merchant_id         := null;
    l_acq_part.terminal_id         := null;
    l_acq_part.split_hash          := null;

    -- create operation
    cmp_api_fin_message_pkg.create_operation (
        i_oper        => l_oper
        , i_iss_part  => l_iss_part
        , i_acq_part  => l_acq_part
    );
        
    --if operation reversal in the same file with original operation
    --we must don't process reversal and original operation        
    if l_oper.is_reversal = com_api_type_pkg.TRUE then
        begin
            select f.id
              into l_orig_id
              from cmp_fin_message f
                 , cmp_card c 
             where f.file_id = io_cmp_fin_rec.file_id
               and c.id = f.id
               and iss_api_token_pkg.decode_card_number(i_card_number => c.card_number) = io_cmp_fin_rec.card_number
               and f.tran_number = io_cmp_fin_rec.tran_number
               and f.is_incoming = com_api_type_pkg.TRUE
               and f.tran_type   = cmp_api_const_pkg.MTID_PRESENTMENT
               and f.is_reversal = com_api_type_pkg.FALSE
               and f.amount      = io_cmp_fin_rec.amount;
            
            update opr_operation
               set status = opr_api_const_pkg.OPERATION_STATUS_DONT_PROCESS
             where id in (l_orig_id, io_cmp_fin_rec.id);
                   
        exception 
            when no_data_found then
                null;   
        end;   
    end if;

    trc_log_pkg.debug (
        i_text          => 'cmp_prc_incoming_pkg.create_operation end'
    );

end;

procedure process_presentment(
    i_tc_buffer          in     varchar2
  , i_cmp_file           in     cmp_api_type_pkg.t_cmp_file_rec
  , i_standard_id        in     com_api_type_pkg.t_tiny_id
  , i_incom_sess_file_id in     com_api_type_pkg.t_long_id
  , i_network_id         in     com_api_type_pkg.t_tiny_id
) is
    l_cmp_fin_rec           cmp_api_type_pkg.t_cmp_fin_mes_rec; 
    l_amount                com_api_type_pkg.t_money;
    l_orig_amount           com_api_type_pkg.t_money;
    l_currency              com_api_type_pkg.t_curr_code;
    l_orig_currency         com_api_type_pkg.t_curr_code;  
    l_currency_exponent     com_api_type_pkg.t_tiny_id;
begin
    trc_log_pkg.debug (
        i_text          => 'cmp_prc_incoming_pkg.process_presentment start'
    );
    -- init_record
    l_cmp_fin_rec.is_reversal := com_api_type_pkg.FALSE;
    l_cmp_fin_rec.is_incoming := com_api_type_pkg.TRUE;
    l_cmp_fin_rec.is_rejected := com_api_type_pkg.FALSE;
    l_cmp_fin_rec.is_invalid  := com_api_type_pkg.FALSE;
    l_cmp_fin_rec.status      := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;
    l_cmp_fin_rec.tran_type   := cmp_api_const_pkg.MTID_PRESENTMENT;
    l_cmp_fin_rec.file_id     := i_cmp_file.id;
    l_cmp_fin_rec.network_id  := i_cmp_file.network_id;
    l_cmp_fin_rec.inst_id     := i_cmp_file.inst_id;
    
    l_cmp_fin_rec.id          := opr_api_create_pkg.get_id;
      
    l_cmp_fin_rec.card_number := get_field(
        i_tc_buffer    => i_tc_buffer
        , i_ident      => cmp_api_const_pkg.IDENT_PAN 
    );
    l_cmp_fin_rec.card_hash   := com_api_hash_pkg.get_card_hash(l_cmp_fin_rec.card_number);
    l_cmp_fin_rec.card_mask   := iss_api_card_pkg.get_card_mask(l_cmp_fin_rec.card_number);
    
    l_cmp_fin_rec.tran_code := get_field(
        i_tc_buffer  => i_tc_buffer
      , i_ident      => cmp_api_const_pkg.IDENT_TRANCODE 
    );
    
    if l_cmp_fin_rec.tran_code is null then
        l_cmp_fin_rec.is_invalid := com_api_type_pkg.TRUE;
        l_cmp_fin_rec.status     := net_api_const_pkg.CLEARING_MSG_STATUS_INVALID;
    end if;
    
    l_cmp_fin_rec.conversion_rate := 1;
    l_cmp_fin_rec.ext_stan := get_field(
        i_tc_buffer  => i_tc_buffer
      , i_ident      => cmp_api_const_pkg.IDENT_EXTSTAN 
    );           

    l_cmp_fin_rec.tran_class := get_field(
        i_tc_buffer  => i_tc_buffer
      , i_ident      => cmp_api_const_pkg.IDENT_TRANCLASS 
    );           
           
    l_cmp_fin_rec.orig_time := cmp_api_const_pkg.GC_OLD_DATE +  to_number(get_field(
                                                                    i_tc_buffer    => i_tc_buffer
                                                                    , i_ident      => cmp_api_const_pkg.IDENT_ORIGTIME 
                                                                    , i_max_length => null
                                                                )) / 60 / 60 / 24;     
                     
    l_cmp_fin_rec.capability := '000000000000';

    l_cmp_fin_rec.tran_type := get_field(
        i_tc_buffer  => i_tc_buffer
      , i_ident      => cmp_api_const_pkg.IDENT_TRANSTYPE 
    );           

    if l_cmp_fin_rec.tran_type = cmp_api_const_pkg.MTID_PRESENTMENT then
        l_cmp_fin_rec.is_reversal := 0;
    elsif l_cmp_fin_rec.tran_type = cmp_api_const_pkg.MTID_PRESENTMENT_REV then
        l_cmp_fin_rec.is_reversal := 1;
    end if;

    l_cmp_fin_rec.mcc := get_field(
        i_tc_buffer  => i_tc_buffer
      , i_ident      => cmp_api_const_pkg.IDENT_TERMSIC 
    );           
    l_cmp_fin_rec.arn := get_field(
        i_tc_buffer  => i_tc_buffer
      , i_ident      => cmp_api_const_pkg.IDENT_ARN 
    );           
    l_cmp_fin_rec.ext_fid := coalesce(to_number(get_field(
        i_tc_buffer  => i_tc_buffer
      , i_ident      => cmp_api_const_pkg.IDENT_EXTFID 
    )), '111111');           
    
    l_cmp_fin_rec.tran_number := nvl(
        get_field(
            i_tc_buffer  => i_tc_buffer
          , i_ident      => cmp_api_const_pkg.IDENT_TRANNUMBER 
          , i_max_length => 36)
        , get_field(
            i_tc_buffer  => i_tc_buffer
          , i_ident      => cmp_api_const_pkg.IDENT_EXTRRN 
          , i_max_length => 36)
    );           
    l_cmp_fin_rec.approval_code := get_field(
        i_tc_buffer  => i_tc_buffer
      , i_ident      => cmp_api_const_pkg.IDENT_APPROVALCODE 
    );           
    -- terminal_number
    l_cmp_fin_rec.term_name := coalesce(get_field(
        i_tc_buffer  => i_tc_buffer
      , i_ident      => cmp_api_const_pkg.IDENT_TERMNAME 
      , i_max_length => 8)
    , get_field(
        i_tc_buffer  => i_tc_buffer
      , i_ident      => cmp_api_const_pkg.IDENT_EXTTERMNAME 
      , i_max_length => 8)
    );           
    -- merchant_number
    l_cmp_fin_rec.ext_term_retailer_name := coalesce(get_field(
        i_tc_buffer  => i_tc_buffer
      , i_ident      => cmp_api_const_pkg.IDENT_TERMRETAILERNAME 
      , i_max_length => 15)
    , get_field(
        i_tc_buffer  => i_tc_buffer
      , i_ident      => cmp_api_const_pkg.IDENT_EXTTERMRETAILERNAME 
      , i_max_length => 15)
    );           
    
    --merchant name
    l_cmp_fin_rec.term_owner := get_field(
        i_tc_buffer  => i_tc_buffer
      , i_ident      => cmp_api_const_pkg.IDENT_TERMOWNER
    );
    
    --merchatn city
    l_cmp_fin_rec.term_city := get_field(
        i_tc_buffer  => i_tc_buffer
      , i_ident      => cmp_api_const_pkg.IDENT_TERMCITY
    ); 
    --merchant street
    l_cmp_fin_rec.term_location := get_field(
        i_tc_buffer  => i_tc_buffer
      , i_ident      => cmp_api_const_pkg.IDENT_TERMLOCATION
    );    
    -- merchant country
    l_cmp_fin_rec.term_country := get_field(
        i_tc_buffer  => i_tc_buffer
      , i_ident      => cmp_api_const_pkg.IDENT_TERMCOUNTRY
    );
    --merchant postcode 
    l_cmp_fin_rec.term_zip := get_field(
        i_tc_buffer    => i_tc_buffer
        , i_ident      => cmp_api_const_pkg.IDENT_TERMZIP
    );     
    --expi_date
    l_cmp_fin_rec.exp_date := get_field(
        i_tc_buffer    => i_tc_buffer
        , i_ident      => cmp_api_const_pkg.IDENT_EXPDATE
    );     

    -- amount and currency    
    l_currency := get_field(
        i_tc_buffer    => i_tc_buffer
        , i_ident      => cmp_api_const_pkg.IDENT_CURRENCY
    ); 

    if l_currency = '810' then
        l_currency := '643';
    end if;  
    
    trc_log_pkg.debug (
        i_text          => 'l_currency = ' || l_currency
    );

    if l_currency is not null then
    
        -- get exponent of currency
        l_currency_exponent := com_api_currency_pkg.get_currency_exponent(i_curr_code => l_currency);

        l_amount :=  to_number(
                        get_field(
                            i_tc_buffer    => i_tc_buffer
                            , i_ident      => cmp_api_const_pkg.IDENT_AMOUNT
                        )
                      , 'FM999999999999999990.00000'
                      , 'nls_numeric_characters=,.'
                     ) * power(10, l_currency_exponent); 

        -- original amount and original currency    
        l_orig_currency := get_field(
            i_tc_buffer    => i_tc_buffer
            , i_ident      => cmp_api_const_pkg.IDENT_CURRENCYORIG
        ); 
        
        if l_orig_currency = '810' then
            l_orig_currency := '643';
        end if;  

        -- get exponent of original currency
        l_currency_exponent := com_api_currency_pkg.get_currency_exponent(i_curr_code => l_currency);

        l_orig_amount :=  to_number(
                            get_field(
                                i_tc_buffer    => i_tc_buffer
                                , i_ident      => cmp_api_const_pkg.IDENT_AMOUNTORIG
                            )    
                          , 'FM999999999999999990.00000'
                          , 'nls_numeric_characters=,.'
                         ) * power(10, l_currency_exponent); 

        l_cmp_fin_rec.orig_amount        := l_orig_amount;
        l_cmp_fin_rec.orig_currency      := l_orig_currency;

        l_cmp_fin_rec.amount             := nvl(l_orig_amount, l_amount);
        l_cmp_fin_rec.currency           := nvl(l_orig_currency, l_currency);
                                      
        l_cmp_fin_rec.reconcil_amount    := l_amount;
        l_cmp_fin_rec.reconcil_currency  := l_currency;
        l_cmp_fin_rec.pay_amount         := l_amount;
        l_cmp_fin_rec.pay_currency       := l_currency;

    end if;
    l_cmp_fin_rec.term_inst_id := get_field(
        i_tc_buffer    => i_tc_buffer
        , i_ident      => cmp_api_const_pkg.IDENT_TERMINSTID
    ); 

    l_cmp_fin_rec.msg_number :=  to_number(get_field(
        i_tc_buffer    => i_tc_buffer
        , i_ident      => cmp_api_const_pkg.IDENT_RECNO
    )); 
    --POS Condition
    l_cmp_fin_rec.pos_condition := get_field(
        i_tc_buffer    => i_tc_buffer
        , i_ident      => cmp_api_const_pkg.IDENT_POSCONDITION
    );
    --POS Entry mode
    l_cmp_fin_rec.pos_entry_mode := get_field(
        i_tc_buffer    => i_tc_buffer
        , i_ident      => cmp_api_const_pkg.IDENT_POSENTRYMODE
    );
    
    trc_log_pkg.debug (
        i_text          => 'cmp_prc_incoming_pkg.process_presentment msg_number=[' || l_cmp_fin_rec.msg_number || ']'
    );

/*
 if l_settlement_type in
                       (defs_networks.C_STTT61_US_ON_COMPASS_VISA,
                        defs_networks.C_STTT38_US_ON_COMPASS_PLUS) and
                       l_currencyOrig = '978' then
                    
                        sv_rec.pay_amount := l_amountOrig;
                        sv_rec.pay_cur    := l_currencyOrig;
                    
                    end if;
*/

    create_operation(
        io_cmp_fin_rec       => l_cmp_fin_rec
      , i_standard_id        => i_standard_id
      , i_incom_sess_file_id => i_incom_sess_file_id
      , i_network_id         => i_network_id
    );
    
    if l_cmp_fin_rec.is_invalid = com_api_type_pkg.TRUE then
        l_cmp_fin_rec.id     := null;
        g_error_flag         := com_api_type_pkg.TRUE;
        l_cmp_fin_rec.status := net_api_const_pkg.CLEARING_MSG_STATUS_INVALID;
    end if;
    
    l_cmp_fin_rec.id := cmp_api_fin_message_pkg.put_message (
        i_fin_rec => l_cmp_fin_rec
    );        
            
    trc_log_pkg.debug (
        i_text          => 'cmp_prc_incoming_pkg.process_presentment end'
    );
end process_presentment;    

procedure process (
    i_network_id  in     com_api_type_pkg.t_tiny_id
  , i_action_code in     com_api_type_pkg.t_curr_code default '0' -- possible value '1' for test processing
  , i_dst_inst_id in     com_api_type_pkg.t_inst_id default null
)is
    l_tc_buffer          cmp_api_type_pkg.t_tc_buffer;
    l_cmp_file           cmp_api_type_pkg.t_cmp_file_rec;
    l_host_id            com_api_type_pkg.t_tiny_id;
    l_standard_id        com_api_type_pkg.t_tiny_id;
    l_record_number      com_api_type_pkg.t_long_id := 0;
    l_record_count       com_api_type_pkg.t_long_id := 0;
    l_errors_count       com_api_type_pkg.t_long_id := 0;

    l_trailer_load       com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE;
    l_header_load        com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE;
    l_inst_name          com_api_type_pkg.t_name;
    l_tran_type          com_api_type_pkg.t_mcc;

    cursor cu_records_count is
        select count(1)
          from prc_file_raw_data a
             , prc_session_file b
         where b.session_id      = prc_api_session_pkg.get_session_id
           and a.record_number   > 1
           and instr(a.raw_data, cmp_api_const_pkg.IDENT_CRC) = 0
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
    -- get network communication standard
    l_host_id := net_api_network_pkg.get_default_host(i_network_id);
    l_standard_id := net_api_network_pkg.get_offline_standard(i_network_id => i_network_id);

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
            savepoint sp_cmp_incoming_file;
            trc_log_pkg.debug (
                i_text          => 'cmp_prc_incoming.process start. Session file=' || p.session_file_id
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
                g_error_flag := com_api_type_pkg.FALSE;
                l_tc_buffer(l_tc_buffer.count + 1)  := r.raw_data;
                
                --check header
                if l_header_load = com_api_type_pkg.FALSE then
                    l_inst_name := get_field(
                        i_tc_buffer          => l_tc_buffer(1)
                        , i_ident            => cmp_api_const_pkg.IDENT_INSTNAME 
                        , i_max_length       => null
                    );
                    if l_inst_name is not null then
                        process_file_header(
                            i_header_data          => l_tc_buffer(1)
                            , i_network_id         => i_network_id
                            , i_standard_id        => l_standard_id
                            , i_action_code        => i_action_code
                            , i_dst_inst_id        => i_dst_inst_id
                            , i_inst_name          => l_inst_name
                            , i_host_id            => l_host_id
                            , i_incom_sess_file_id => p.session_file_id
                            , o_cmp_file           => l_cmp_file
                        );
                        l_header_load := com_api_type_pkg.TRUE;
                    else
                        com_api_error_pkg.raise_error(
                            i_error          => 'HEADER_NOT_FOUND'
                            , i_env_param1   => p.session_file_id
                        );
                    end if;              
                    
                elsif instr(l_tc_buffer(1), cmp_api_const_pkg.IDENT_CRC) = 1 then
                    process_file_trailer (
                        i_trailer_data       =>  l_tc_buffer(1)
                        , io_cmp_file        =>  l_cmp_file
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

                    l_tran_type := get_field(
                        i_tc_buffer    => l_tc_buffer(1)
                        , i_ident      => cmp_api_const_pkg.IDENT_TRANSTYPE 
                    );           

                    if l_tran_type in (cmp_api_const_pkg.MTID_PRESENTMENT
                                     , cmp_api_const_pkg.MTID_PRESENTMENT_REV)
                    then
                        process_presentment(
                            i_tc_buffer            => l_tc_buffer(1)
                            , i_cmp_file           => l_cmp_file
                            , i_standard_id        => l_standard_id
                            , i_incom_sess_file_id => p.session_file_id
                            , i_network_id         => i_network_id
                        );
                        l_record_count := l_record_count + 1;
                    else
                        trc_log_pkg.info(
                            i_text          => 'NETWORK_MESSAGE_TYPE_EXCEPT'
                          , i_env_param1    => l_tran_type
                          , i_env_param2    => l_standard_id
                        );
                    end if;
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
                i_text          => 'cmp_prc_incoming.process end.'
            );
            
        exception
            when com_api_error_pkg.e_application_error then
                rollback to sp_cmp_incoming_file;

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
