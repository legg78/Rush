create or replace package body bgn_eo_pkg as

    EO_TYPE_AUTH                constant    com_api_type_pkg.t_name := 'AUTHORIZED'; --authorizations
    EO_TYPE_FIN                 constant    com_api_type_pkg.t_name := 'DATACAPTUR'; --finance transcations
    EO_TYPE_REJECT              constant    com_api_type_pkg.t_name := 'NOTAPPROVD'; --rejects
    EO_TYPE_BALANCE_PINS        constant    com_api_type_pkg.t_name := 'BALANCEPIN'; --balance inquries and pin changes

    EO_STRING_TYPE_HEAD         constant    com_api_type_pkg.t_byte_char := 'FH';
    EO_STRING_TYPE_DATA         constant    com_api_type_pkg.t_byte_char := 'RD';
    EO_STRING_TYPE_BOTTOM       constant    com_api_type_pkg.t_byte_char := 'FT';

    EO_DATA_REVERSAL            constant    com_api_type_pkg.t_name := 'R';
    EO_DATA_NORMAL              constant    com_api_type_pkg.t_name := 'N';

    EO_DATA_MC                  constant    com_api_type_pkg.t_name := 'EUR';
    EO_DATA_VISA                constant    com_api_type_pkg.t_name := 'VIS';

    EO_TRANS_ACQUIRING          constant    com_api_type_pkg.t_name := '1';
    EO_TRANS_PURCHASE_ON_US     constant    com_api_type_pkg.t_name := '2';
    EO_TRANS_PURCHASE_ACQ       constant    com_api_type_pkg.t_name := '3';
    EO_TRANS_ON_US              constant    com_api_type_pkg.t_name := '5';
    EO_TRANS_DEPOSIT            constant    com_api_type_pkg.t_name := '6';
    EO_TRANS_TO_CHIP_ATM        constant    com_api_type_pkg.t_name := '7';
    EO_TRANS_FROM_CHIP_ATM      constant    com_api_type_pkg.t_name := '8';
    EO_TRANS_ISSUING            constant    com_api_type_pkg.t_name := '9';
    EO_TRANS_BALANCE_3D_ATM     constant    com_api_type_pkg.t_name := 'B';
    EO_TRANS_PIN_CHANGE         constant    com_api_type_pkg.t_name := 'P';

    EO_TYPE_BAL_PIN_CHANGE_ATM  constant    com_api_type_pkg.t_name := '00';
    EO_TYPE_TO_CHIP_ATM         constant    com_api_type_pkg.t_name := '17';
    EO_TYPE_FROM_CHIP_ATM       constant    com_api_type_pkg.t_name := '32';
    EO_TYPE_DEPOSIT_CARD_ATM    constant    com_api_type_pkg.t_name := '41';
    EO_TYPE_PAY_LOAN_ATM        constant    com_api_type_pkg.t_name := '42';
    EO_TYPE_CASH_M_ATM          constant    com_api_type_pkg.t_name := '46';
    EO_TYPE_AVAIL_EBG           constant    com_api_type_pkg.t_name := '76';
    EO_TYPE_AVAIL_EPAY          constant    com_api_type_pkg.t_name := '77';
    EO_TYPE_3DREG_TEMPPASS_ATM  constant    com_api_type_pkg.t_name := '91';
    EO_TYPE_3DREG_SECRET_ATM    constant    com_api_type_pkg.t_name := '92';
    EO_TYPE_3D_CHANGE_PASS_ATM  constant    com_api_type_pkg.t_name := '93';

    g_prev_string_type              com_api_type_pkg.t_byte_char;
    g_session_file_id               com_api_type_pkg.t_long_id;
    g_record_number                 com_api_type_pkg.t_short_id;

    g_debit_total                   com_api_type_pkg.t_short_id;
    g_credit_total                  com_api_type_pkg.t_short_id;
    g_debit_amount                  com_api_type_pkg.t_money;
    g_credit_amount                 com_api_type_pkg.t_money;
    g_seq_number                    com_api_type_pkg.t_short_id;

function check_record (
    io_string           in out nocopy   com_api_type_pkg.t_full_desc
) return com_api_type_pkg.t_byte_char
is
    l_result            com_api_type_pkg.t_byte_char;
    l_expected          com_api_type_pkg.t_byte_char;
begin
    trc_log_pkg.debug(
        i_text          => 'bgn_eo_pkg.check_record'
    );

    if g_record_number = 1 then
        g_prev_string_type := null;

    end if;

    if length(io_string) != 800 then
        com_api_error_pkg.raise_error(
            i_error         => 'BGN_WRONG_STRING_LENGTH'
          , i_entity_type   => prc_api_const_pkg.ENTITY_TYPE_SESSION_FILE
          , i_object_id     => g_session_file_id
          , i_env_param1    => g_record_number
          , i_env_param2    => 800
        );

    end if;

    l_result := substr(io_string, 1, 2);

    if g_prev_string_type = EO_STRING_TYPE_BOTTOM then
        com_api_error_pkg.raise_error(
            i_error         => 'BGN_RECORDS_AFTER_FOOTER'
          , i_entity_type   => prc_api_const_pkg.ENTITY_TYPE_SESSION_FILE
          , i_object_id     => g_session_file_id
          , i_env_param1    => g_record_number
        );

    end if;

    case l_result
    when EO_STRING_TYPE_HEAD then
        if g_record_number > 1 then
            com_api_error_pkg.raise_error(
                i_error         => 'BGN_WRONG_STRING_IDENTIFICATOR'
              , i_entity_type   => prc_api_const_pkg.ENTITY_TYPE_SESSION_FILE
              , i_object_id     => g_session_file_id
              , i_env_param1    => g_record_number
              , i_env_param2    => EO_STRING_TYPE_DATA
            );

        end if;

    when EO_STRING_TYPE_DATA then
        if g_record_number = 1 then
            com_api_error_pkg.raise_error(
                i_error         => 'BGN_WRONG_STRING_IDENTIFICATOR'
              , i_entity_type   => prc_api_const_pkg.ENTITY_TYPE_SESSION_FILE
              , i_object_id     => g_session_file_id
              , i_env_param1    => g_record_number
              , i_env_param2    => EO_STRING_TYPE_HEAD
            );

        elsif g_prev_string_type not in (
            EO_STRING_TYPE_HEAD
          , EO_STRING_TYPE_DATA
        ) then
             com_api_error_pkg.raise_error(
                i_error         => 'BGN_WRONG_STRING_IDENTIFICATOR'
              , i_entity_type   => prc_api_const_pkg.ENTITY_TYPE_SESSION_FILE
              , i_object_id     => g_session_file_id
              , i_env_param1    => g_record_number
              , i_env_param2    => EO_STRING_TYPE_DATA
            );

        end if;

    when EO_STRING_TYPE_BOTTOM then
        null;

    else
        if g_record_number = 1 then
            l_expected := EO_STRING_TYPE_HEAD;

        else
            l_expected := EO_STRING_TYPE_DATA;

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
    l_flag          com_api_type_pkg.t_boolean;
begin
    trc_log_pkg.debug(
        i_text          => 'bgn_eo_pkg.process_title_of_file'
    );

    io_file_rec.file_label     := substr(io_string, 3, 10);
    if io_file_rec.file_label not in (
        EO_TYPE_AUTH
      , EO_TYPE_FIN
      , EO_TYPE_REJECT
      , EO_TYPE_BALANCE_PINS
    ) then
        com_api_error_pkg.raise_error(
            i_error         => 'BGN_WRONG_FILE_LABEL'
          , i_entity_type   => prc_api_const_pkg.ENTITY_TYPE_SESSION_FILE
          , i_object_id     => g_session_file_id
          , i_env_param1    => g_record_number
        );

    end if;

    io_file_rec.creation_date  := to_date(substr(io_string, 13, 8), 'yyyymmdd');
    io_file_rec.journal_period := substr(io_string, 21, 4);

    begin
        select com_api_const_pkg.TRUE
          into l_flag
          from bgn_file
         where file_type = bgn_api_const_pkg.FILE_TYPE_BORICA_EO
           and file_label = io_file_rec.file_label
           and journal_period = io_file_rec.journal_period;

        com_api_error_pkg.raise_error(
            i_error         => 'BGN_FILE_ALREADY_PROCESSED'
          , i_entity_type   => prc_api_const_pkg.ENTITY_TYPE_SESSION_FILE
          , i_object_id     => g_session_file_id
          , i_env_param1    => io_file_rec.journal_period
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
        i_text          => 'bgn_eo_pkg.process_end_of_file'
    );
    io_file_rec.debit_total     := substr(io_string, 3, 6);
    io_file_rec.credit_total    := substr(io_string, 9, 6);
    io_file_rec.debit_amount    := substr(io_string, 15, 18);
    io_file_rec.credit_amount   := substr(io_string, 33, 18);

    if io_file_rec.debit_total != g_debit_total then
       com_api_error_pkg.raise_error(
            i_error         => 'BGN_WRONG_DEBIT_TOTAL'
          , i_entity_type   => prc_api_const_pkg.ENTITY_TYPE_SESSION_FILE
          , i_object_id     => g_session_file_id
          , i_env_param1    => g_record_number
          , i_env_param2    => g_debit_total
          , i_env_param3    => io_file_rec.debit_total
        );
        io_file_rec.debit_total := null;

    end if;

    if io_file_rec.credit_total != g_credit_total then
        com_api_error_pkg.raise_error(
            i_error         => 'BGN_WRONG_CREDIT_TOTAL'
          , i_entity_type   => prc_api_const_pkg.ENTITY_TYPE_SESSION_FILE
          , i_object_id     => g_session_file_id
          , i_env_param1    => g_record_number
          , i_env_param2    => g_credit_total
          , i_env_param3    => io_file_rec.credit_total
        );
        io_file_rec.credit_total    := null;

    end if;

    if io_file_rec.debit_amount != g_debit_amount then
        com_api_error_pkg.raise_error(
            i_error         => 'BGN_WRONG_DEBIT_AMOUNT'
          , i_entity_type   => prc_api_const_pkg.ENTITY_TYPE_SESSION_FILE
          , i_object_id     => g_session_file_id
          , i_env_param1    => g_record_number
          , i_env_param2    => g_debit_amount
          , i_env_param3    => io_file_rec.debit_amount
        );
        io_file_rec.debit_amount    := null;

    end if;

    if io_file_rec.credit_amount != g_credit_amount then
        com_api_error_pkg.raise_error(
            i_error         => 'BGN_WRONG_CREDIT_AMOUNT'
          , i_entity_type   => prc_api_const_pkg.ENTITY_TYPE_SESSION_FILE
          , i_object_id     => g_session_file_id
          , i_env_param1    => g_record_number
          , i_env_param2    => g_credit_amount
          , i_env_param3    => io_file_rec.credit_amount
        );
        io_file_rec.credit_amount   := null;

    end if;


    bgn_api_fin_pkg.put_file_rec(
        i_file_rec      => io_file_rec
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
        i_text          => 'bgn_eo_pkg.register_operation'
    );

    --amounts and currencies
    l_oper.oper_amount          := io_fin_rec.acquirer_amount;
    l_oper.oper_currency        := lpad(io_fin_rec.acquirer_currency, 3, '0');
    l_oper.sttl_amount          := io_fin_rec.acquirer_amount;
    l_oper.sttl_currency        := lpad(io_fin_rec.acquirer_currency, 3, '0');
	--the card is processed by Borica as issuer, the POS is also connected to Borica system
	--and the result is that no network is involved in these transactions (network amount  = 0 and network currency = 0)
	--Use fields 12 and 13 ( Acquirer transaction amount and currency ) instead of network amount and currency.
    l_oper.oper_cashback_amount := io_fin_rec.cashback_acq_amount;

    l_oper.originator_refnum    := io_fin_rec.retrieval_refnum;
    io_fin_rec.is_invalid       := nvl(io_fin_rec.is_invalid, com_api_const_pkg.FALSE);

    bgn_api_fin_pkg.fin_to_oper(
        io_fin_rec          => io_fin_rec
      , io_oper             => l_oper
      , io_iss_part         => l_iss_part
      , io_acq_part         => l_acq_part
      , i_session_file_id   => g_session_file_id
      , i_record_number     => g_record_number
      , i_file_code         => 'EO'
    );

    if l_oper.is_reversal = com_api_const_pkg.TRUE
       and
       l_oper.originator_refnum is not null then
        l_oper.original_id  :=
            bgn_api_fin_pkg.get_original_for_reversal(
                io_oper         => l_oper
              , i_refnum        => l_oper.originator_refnum
              , i_card_number   => l_iss_part.card_number
              , i_mask_error    => com_api_const_pkg.TRUE
            );
        if l_oper.original_id is null then
            io_fin_rec.is_invalid   := com_api_const_pkg.TRUE;
            l_oper.status           := opr_api_const_pkg.OPERATION_STATUS_MANUAL;
        end if;        
    end if;   
    
    io_fin_rec.id := bgn_api_fin_pkg.put_message(
        i_fin_rec           => io_fin_rec
    );

    l_oper.terminal_type    := case io_fin_rec.mcc
                               when '6011' then
                                   acq_api_const_pkg.TERMINAL_TYPE_ATM
                               else
                                   acq_api_const_pkg.TERMINAL_TYPE_POS
                               end;

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
    l_length            com_api_type_pkg.t_tiny_id;
    l_data_rec          bgn_api_type_pkg.t_bgn_fin_rec;
begin
    l_data_rec.id           := opr_api_create_pkg.get_id;
    trc_log_pkg.set_object(
        i_entity_type   => opr_api_const_pkg.ENTITY_TYPE_OPERATION
      , i_object_id     => l_data_rec.id
    );

    trc_log_pkg.debug(
        i_text          => 'bgn_eo_pkg.parse_data_rec'
    );


    l_data_rec.inst_id      := io_file_rec.inst_id;
    l_data_rec.network_id   := io_file_rec.network_id;

    l_data_rec.file_id                      := io_file_rec.id;
    l_data_rec.record_type                  := trim(substr(io_data_string, 1, 2 ));

    l_data_rec.record_number                := trim(substr(io_data_string, 3, 6 ));
    if l_data_rec.record_number != g_seq_number + 1 then
        trc_log_pkg.error(
            i_text          => 'BGN_WRONG_RECORD_SEQ_NUMBER'
          , i_entity_type   => prc_api_const_pkg.ENTITY_TYPE_SESSION_FILE
          , i_object_id     => g_session_file_id
          , i_env_param1    => g_record_number
          , i_env_param2    => g_seq_number + 1
        );
        l_data_rec.is_invalid    := com_api_const_pkg.TRUE;
    else
        g_seq_number := l_data_rec.record_number;

    end if;

    l_data_rec.transaction_date             := to_date(trim(substr(io_data_string, 9, 14 )), 'yyyymmddhh24miss');

    l_data_rec.transaction_type             := trim(substr(io_data_string, 23, 1 ));
    if l_data_rec.transaction_type not in (
        EO_TRANS_ACQUIRING
      , EO_TRANS_PURCHASE_ON_US
      , EO_TRANS_PURCHASE_ACQ
      , EO_TRANS_ON_US
      , EO_TRANS_DEPOSIT
      , EO_TRANS_TO_CHIP_ATM
      , EO_TRANS_FROM_CHIP_ATM
      , EO_TRANS_ISSUING
      , EO_TRANS_BALANCE_3D_ATM
      , EO_TRANS_PIN_CHANGE
    ) then
        trc_log_pkg.error(
            i_text          => 'BGN_WRONG_TRANSACTION_TYPE'
          , i_entity_type   => prc_api_const_pkg.ENTITY_TYPE_SESSION_FILE
          , i_object_id     => g_session_file_id
          , i_env_param1    => g_record_number
          , i_env_param2    => l_data_rec.transaction_type
        );
        l_data_rec.is_invalid   := com_api_const_pkg.TRUE;

    end if;

    l_data_rec.is_reject                    := trim(substr(io_data_string, 24, 1 ));
    if l_data_rec.is_reject not in (
        EO_DATA_REVERSAL
      , EO_DATA_NORMAL
    ) then
        trc_log_pkg.error(
            i_text          => 'BGN_WRONG_TEST_OPTION'
          , i_entity_type   => prc_api_const_pkg.ENTITY_TYPE_SESSION_FILE
          , i_object_id     => g_session_file_id
          , i_env_param1    => g_record_number
        );
        l_data_rec.is_invalid   := com_api_const_pkg.TRUE;
    end if;

    l_data_rec.is_finance                   := trim(substr(io_data_string, 25, 1 ));
    l_data_rec.card_number                  := trim(substr(io_data_string, 26, 19));
    l_data_rec.card_seq_number              := trim(substr(io_data_string, 45, 3 ));
    l_data_rec.card_expire_date             := trim(substr(io_data_string, 48, 4 ));
    l_data_rec.card_type                    := trim(substr(io_data_string, 52, 3 ));
    l_data_rec.acquirer_amount              := trim(substr(io_data_string, 55, 18));
    l_data_rec.acquirer_currency            := trim(substr(io_data_string, 73, 3 ));
    l_data_rec.network_amount               := trim(substr(io_data_string, 76, 18));
    l_data_rec.network_currency             := trim(substr(io_data_string, 94, 3 ));
    l_data_rec.card_amount                  := trim(substr(io_data_string, 97, 18));
    l_data_rec.card_currency                := trim(substr(io_data_string, 115, 3 ));
    l_data_rec.auth_code                    := trim(substr(io_data_string, 118, 6 ));
    l_data_rec.trace_number                 := trim(substr(io_data_string, 124, 6 ));
    l_data_rec.stan                         := l_data_rec.trace_number;
    l_data_rec.retrieval_refnum             := trim(substr(io_data_string, 130, 12));
    l_data_rec.merchant_number              := trim(substr(io_data_string, 142, 15));
    l_data_rec.merchant_name                := trim(substr(io_data_string, 157, 25));
    l_data_rec.merchant_city                := trim(substr(io_data_string, 182, 13));
    l_data_rec.mcc                          := trim(substr(io_data_string, 195, 4 ));
    l_data_rec.terminal_number              := trim(substr(io_data_string, 199, 8 ));
    l_data_rec.pos_entry_mode               := trim(substr(io_data_string, 207, 4 ));
    l_data_rec.ain                          := trim(substr(io_data_string, 211, 11));
    l_data_rec.auth_indicator               := trim(substr(io_data_string, 222, 1 ));
    l_data_rec.transaction_number           := trim(substr(io_data_string, 223, 15));
    l_data_rec.validation_code              := trim(substr(io_data_string, 238, 4 ));
    l_data_rec.market_data_id               := trim(substr(io_data_string, 242, 1 ));
    l_data_rec.add_response_data            := trim(substr(io_data_string, 243, 1 ));
    l_data_rec.reject_code                  := trim(substr(io_data_string, 244, 3 ));
    l_data_rec.response_code                := trim(substr(io_data_string, 247, 2 ));
    l_data_rec.reject_text                  := trim(substr(io_data_string, 249, 52));
    l_data_rec.is_offline                   := trim(substr(io_data_string, 301, 1 ));
    l_data_rec.pos_text                     := trim(substr(io_data_string, 302, 26));
    l_data_rec.result_code                  := trim(substr(io_data_string, 328, 1 ));
    l_data_rec.terminal_cap                 := trim(substr(io_data_string, 329, 6 ));
    l_data_rec.terminal_result              := trim(substr(io_data_string, 335, 10));
    l_data_rec.unpred_number                := trim(substr(io_data_string, 345, 8 ));
    l_data_rec.terminal_seq_number          := trim(substr(io_data_string, 353, 8 ));
    l_data_rec.derivation_key_index         := trim(substr(io_data_string, 361, 2 ));
    l_data_rec.crypto_version               := trim(substr(io_data_string, 363, 2 ));
    l_length                                := trim(substr(io_data_string, 365, 1));
    l_data_rec.card_result                  := trim(substr(io_data_string, 366, least(l_length * 2, 6)));
    l_data_rec.app_crypto                   := trim(substr(io_data_string, 372, 16));
    l_data_rec.app_trans_counter            := trim(substr(io_data_string, 388, 4 ));
    l_data_rec.app_interchange_profile      := trim(substr(io_data_string, 392, 4 ));
    l_data_rec.iss_script1_result           := trim(substr(io_data_string, 396, 10));
    l_data_rec.iss_script2_result           := trim(substr(io_data_string, 406, 10));
    l_data_rec.terminal_country             := trim(substr(io_data_string, 416, 3 ));
    l_data_rec.terminal_date                := trim(substr(io_data_string, 419, 6 ));
    l_data_rec.auth_response_code           := trim(substr(io_data_string, 425, 2 ));
    l_data_rec.other_amount                 := trim(substr(io_data_string, 427, 12));
    l_data_rec.trans_type_1                 := trim(substr(io_data_string, 439, 2 ));
    l_data_rec.terminal_type                := trim(substr(io_data_string, 441, 2 ));
    l_data_rec.trans_category               := trim(substr(io_data_string, 443, 1 ));
    l_data_rec.trans_seq_counter            := trim(substr(io_data_string, 444, 8 ));
    l_data_rec.crypto_info_data             := trim(substr(io_data_string, 452, 2 ));
    l_length                                := trim(substr(io_data_string, 454, 2));
    l_data_rec.dedicated_filename           := trim(substr(io_data_string, 456, least(l_length * 2, 32)));
    l_length                                := trim(substr(io_data_string, 488, 2));
    l_data_rec.iss_app_data                 := trim(substr(io_data_string, 490, least(l_length * 2, 64)));
    l_data_rec.cvm_result                   := trim(substr(io_data_string, 554, 6 ));
    l_data_rec.terminal_app_version         := trim(substr(io_data_string, 560, 4 ));
    l_data_rec.sttl_date                    := trim(substr(io_data_string, 564, 4 ));
    l_length                                := trim(substr(io_data_string, 568, 3));
    l_data_rec.network_data                 := trim(substr(io_data_string, 571, least(l_length * 2, 50)));
    l_data_rec.cashback_acq_amount          := trim(substr(io_data_string, 621, 18));
    l_data_rec.cashback_acq_currency        := trim(substr(io_data_string, 639, 3 ));
    l_data_rec.cashback_net_amount          := trim(substr(io_data_string, 642, 18));
    l_data_rec.cashback_net_currency        := trim(substr(io_data_string, 660, 3 ));
    l_data_rec.cashback_card_amount         := trim(substr(io_data_string, 663, 18));
    l_data_rec.cashback_card_currency       := trim(substr(io_data_string, 681, 3 ));
    l_data_rec.term_type                    := trim(substr(io_data_string, 684, 2 ));
    l_data_rec.terminal_subtype             := trim(substr(io_data_string, 686, 2 ));
    l_data_rec.trans_type_2                 := trim(substr(io_data_string, 688, 2 ));
    l_data_rec.cashm_refnum                 := trim(substr(io_data_string, 690, 22));

    l_data_rec.is_reversal  :=  case l_data_rec.is_reject
                                when EO_DATA_REVERSAL then
                                    com_api_const_pkg.TRUE
                                else
                                    com_api_const_pkg.FALSE
                                end;

    if l_data_rec.is_reversal = com_api_const_pkg.TRUE then
        g_credit_total  := g_credit_total + 1;
        g_credit_amount := g_credit_amount + l_data_rec.acquirer_amount;
    else
        g_debit_total   := g_debit_total + 1;
        g_debit_amount  := g_debit_amount + l_data_rec.acquirer_amount;
    end if;

    l_data_rec.is_incoming  := io_file_rec.is_incoming;
    l_data_rec.status       := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;

    l_data_rec.file_record_number   := g_record_number;

    register_operation(
        io_fin_rec          => l_data_rec
    );

    return nvl(l_data_rec.is_invalid, com_api_const_pkg.FALSE);

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
        i_text          => 'bgn_eo_pkg.process_string'
    );

    g_session_file_id   := i_session_file_id;
    g_record_number     := i_record_number;
    o_is_invalid        := com_api_const_pkg.FALSE;

    l_record_type   := check_record(
        io_string           => io_data
    );

    case l_record_type
    when EO_STRING_TYPE_HEAD then
        process_title_of_file (
            io_string   => io_data
          , io_file_rec => bgn_prc_import_pkg.g_file_rec
        );

        g_seq_number    := 0;
        g_debit_total   := 0;
        g_credit_total  := 0;
        g_debit_amount  := 0;
        g_credit_amount := 0;

    when EO_STRING_TYPE_BOTTOM then
        process_end_of_file (
            io_string   => io_data
          , io_file_rec => bgn_prc_import_pkg.g_file_rec
        );

    when EO_STRING_TYPE_DATA then
         o_is_invalid :=
            process_data_rec (
                io_data_string  => io_data
              , io_file_rec => bgn_prc_import_pkg.g_file_rec
            );

         trc_log_pkg.clear_object;

    end case;

end;

end bgn_eo_pkg;
/
