create or replace package body bgn_so_pkg as

    SO_FILE_TEST                    constant        com_api_type_pkg.t_byte_char    := 'T';
    SO_FILE_REAL                    constant        com_api_type_pkg.t_byte_char    := 'R';

    SO_STRING_TYPE_HEAD             constant        com_api_type_pkg.t_byte_char    := 'FH';
    SO_STRING_TYPE_DATA             constant        com_api_type_pkg.t_byte_char    := 'RD';
    SO_STRING_TYPE_BOTTOM           constant        com_api_type_pkg.t_byte_char    := 'FT';
    
    SO_CODE_NO_ERROR                constant        com_api_type_pkg.t_tiny_id      := 0;    
    
    g_session_file_id               com_api_type_pkg.t_long_id;
    g_record_number                 com_api_type_pkg.t_short_id;
    g_prev_string_type              com_api_type_pkg.t_byte_char;

function check_record (
    io_string           in out nocopy   com_api_type_pkg.t_full_desc
) return com_api_type_pkg.t_byte_char
is 
    l_result            com_api_type_pkg.t_byte_char;            
    l_expected          com_api_type_pkg.t_byte_char;
begin
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
    
    if g_prev_string_type = SO_STRING_TYPE_BOTTOM then
        com_api_error_pkg.raise_error(
            i_error         => 'BGN_RECORDS_AFTER_FOOTER'
          , i_entity_type   => prc_api_const_pkg.ENTITY_TYPE_SESSION_FILE
          , i_object_id     => g_session_file_id
          , i_env_param1    => g_record_number 
        );
        
    end if;
    
    case l_result
    when SO_STRING_TYPE_HEAD then
        if g_record_number > 1 then
            com_api_error_pkg.raise_error(
                i_error         => 'BGN_WRONG_STRING_IDENTIFICATOR'
              , i_entity_type   => prc_api_const_pkg.ENTITY_TYPE_SESSION_FILE
              , i_object_id     => g_session_file_id
              , i_env_param1    => g_record_number
              , i_env_param2    => SO_STRING_TYPE_DATA 
            );    
            
        end if;
        
    when SO_STRING_TYPE_DATA then    
        if g_record_number = 1 then
            com_api_error_pkg.raise_error(
                i_error         => 'BGN_WRONG_STRING_IDENTIFICATOR'
              , i_entity_type   => prc_api_const_pkg.ENTITY_TYPE_SESSION_FILE
              , i_object_id     => g_session_file_id
              , i_env_param1    => g_record_number
              , i_env_param2    => SO_STRING_TYPE_HEAD 
            );
            
        elsif g_prev_string_type not in (
            SO_STRING_TYPE_HEAD
          , SO_STRING_TYPE_DATA  
        ) then  
             com_api_error_pkg.raise_error(
                i_error         => 'BGN_WRONG_STRING_IDENTIFICATOR'
              , i_entity_type   => prc_api_const_pkg.ENTITY_TYPE_SESSION_FILE
              , i_object_id     => g_session_file_id
              , i_env_param1    => g_record_number
              , i_env_param2    => SO_STRING_TYPE_DATA 
            );
             
        end if;
        
    when SO_STRING_TYPE_BOTTOM then
        null;
        
    else
        if g_record_number = 1 then
            l_expected := SO_STRING_TYPE_HEAD;
            
        else    
            l_expected := SO_STRING_TYPE_DATA;
            
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
        i_text          => 'bgn_so_pkg.parse_title_of_file'
    );
    
    io_file_rec.file_label         := trim(substr(io_string, 3, 10));
    if io_file_rec.file_label != 'SETTLRESLT' then
        com_api_error_pkg.raise_error(
            i_error         => 'BGN_WRONG_FILE_LABEL'
          , i_entity_type   => prc_api_const_pkg.ENTITY_TYPE_SESSION_FILE
          , i_object_id     => g_session_file_id
          , i_env_param1    => g_record_number
          , i_env_param2    => 'SETTLRESLT' 
        );
            
    end if;
    io_file_rec.sender_code        := trim(substr(io_string, 13, 5));
    io_file_rec.receiver_code      := trim(substr(io_string, 18, 5));
    
    io_file_rec.file_number        := trim(substr(io_string, 23, 3));
    begin
        select file_number
          into l_file_number
          from bgn_file
         where file_type = io_file_rec.file_type
           and trunc(creation_date) = trunc(io_file_rec.creation_date)
           and file_number = io_file_rec.file_number;
        
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
end;

procedure process_end_of_file (
    io_string       in out nocopy   com_api_type_pkg.t_full_desc
  , io_file_rec     in out nocopy   bgn_api_type_pkg.t_bgn_file_rec    
)
is
begin
    trc_log_pkg.debug(
        i_text          => 'bgn_so_pkg.parse_end_of_file'
    );
    
    io_file_rec.debit_total            := trim(substr(io_string, 3, 6));
    io_file_rec.credit_total           := trim(substr(io_string, 9, 6));
    io_file_rec.debit_amount           := trim(substr(io_string, 15, 18));
    io_file_rec.credit_amount          := trim(substr(io_string, 33, 18));
    io_file_rec.debit_fee_amount       := trim(substr(io_string, 31, 18));
    io_file_rec.credit_fee_amount      := trim(substr(io_string, 69, 18));
    io_file_rec.net_amount             := trim(substr(io_string, 87, 19));
    io_file_rec.borica_sttl_date       :=
        case when io_file_rec.debit_total + io_file_rec.credit_total > 0 then
            to_date(trim(substr(io_string, 106, 8)), 'yyyymmdd')
        else
            null
        end;        
    io_file_rec.error_total            := trim(substr(io_string, 114, 6));
    
    bgn_api_fin_pkg.put_file_rec(
        i_file_rec          => io_file_rec
    );
end;

function process_data_rec (
    io_data_string      in out nocopy   com_api_type_pkg.t_full_desc
  , io_file_rec         in out nocopy   bgn_api_type_pkg.t_bgn_file_rec 
) return com_api_type_pkg.t_boolean is
    l_retrieval_rec     bgn_api_type_pkg.t_bgn_retrieval_rec;
begin
    l_retrieval_rec.file_id                 := io_file_rec.id;                 
    l_retrieval_rec.record_type             := substr(io_data_string, 1, 2);
    l_retrieval_rec.record_number           := substr(io_data_string, 3, 6);
    l_retrieval_rec.sender_code             := substr(io_data_string, 19, 5);
    l_retrieval_rec.receiver_code           := substr(io_data_string, 24, 5);
    l_retrieval_rec.file_number             := substr(io_data_string, 29, 3);
    l_retrieval_rec.test_option             := substr(io_data_string, 32, 1);
    l_retrieval_rec.creation_date           := to_date(substr(io_data_string, 33, 14), 'yyyymmddhh24miss');
    l_retrieval_rec.transaction_number      := substr(io_data_string, 51, 20);
    l_retrieval_rec.sttl_amount             := substr(io_data_string, 71, 19); 
    l_retrieval_rec.interbank_fee_amount    := substr(io_data_string, 90, 19);
    l_retrieval_rec.bank_card_id            := substr(io_data_string, 109, 5);
    l_retrieval_rec.error_code              := substr(io_data_string, 114, 3);
    
    bgn_api_fin_pkg.find_original_id(
        io_retrieval_rec    => l_retrieval_rec
      , i_mask_error        => com_api_const_pkg.TRUE 
    );
                                            
    if l_retrieval_rec.original_file_id is null
    or l_retrieval_rec.original_fin_id is null then
        l_retrieval_rec.is_invalid  := com_api_const_pkg.TRUE;
    else
        l_retrieval_rec.is_invalid  := com_api_const_pkg.FALSE;
        
        update bgn_fin
           set interbank_fee_amount = l_retrieval_rec.interbank_fee_amount
         where id = l_retrieval_rec.original_fin_id;  
    end if;
    
    bgn_api_fin_pkg.put_retrieval_rec(
        io_retrieval_rec    => l_retrieval_rec
    );
    
    return l_retrieval_rec.is_invalid;

exception
    when others then
        trc_log_pkg.error(
            i_text          => 'Record number [#1]; transaction_number [#2]'
          , i_env_param1    => l_retrieval_rec.record_number
          , i_env_param2    => l_retrieval_rec.transaction_number 
        );    
        raise;
    
end process_data_rec;

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
    g_session_file_id       := i_session_file_id;
    g_record_number         := i_record_number;
    
    l_record_type   := check_record(
        io_string           => io_data
    );
    
    o_is_invalid    := com_api_const_pkg.FALSE;
    
    case l_record_type
    when SO_STRING_TYPE_HEAD then       
        process_title_of_file (
            io_string           => io_data
          , io_file_rec         => bgn_prc_import_pkg.g_file_rec
        );
        
    when SO_STRING_TYPE_BOTTOM then
        process_end_of_file (
            io_string   => io_data
          , io_file_rec => bgn_prc_import_pkg.g_file_rec  
        );    
        
    when SO_STRING_TYPE_DATA then
        o_is_invalid    := 
            process_data_rec (
                io_data_string  => io_data
              , io_file_rec     => bgn_prc_import_pkg.g_file_rec  
            );
        
    else
        o_is_invalid    := com_api_const_pkg.TRUE;    
         
    end case;
    
end process_string;

end bgn_so_pkg;
/
 