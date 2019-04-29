create or replace package body bgn_fo_pkg as

    FO_MSG_PAYMENT_POS      constant    com_api_type_pkg.t_name := 'AAP714'; --payment on POS (real or virtual) including purchase with cash back or account transfer;
    FO_MSG_CARD_ATM         constant    com_api_type_pkg.t_name := 'AAP715'; --transaction with a card on ATM;
    FO_MSG_CANCEL_POS       constant    com_api_type_pkg.t_name := 'AAP720'; --cancelation of payment on POS (real or virtual) including cancelation of purchase with cash back or cancelation of a cash withdrawal from ATM;
    FO_MSG_INQUIRY          constant    com_api_type_pkg.t_name := 'AAP723'; --inquiry (for account balance or last five transactions);
    FO_MSG_CREDIT           constant    com_api_type_pkg.t_name := 'AAP728'; --Credit of a card account (payment of profits from betting);
    FO_MSG_PIN_CHANGE       constant    com_api_type_pkg.t_name := 'AAP734'; --PIN change;
    FO_MSG_PARTIAL_ATM      constant    com_api_type_pkg.t_name := 'AAP742'; --partial loading of ATM;
    FO_MSG_BALANCE_ATM      constant    com_api_type_pkg.t_name := 'AAP743'; --balance of ATM (closing of the period);
    FO_MSG_CANCEL_CREDIT    constant    com_api_type_pkg.t_name := 'AAP748'; --cancelation credit of a card account;
    
    FO_OPER_CASH_ATM                    constant    com_api_type_pkg.t_name := '01'; --cash withdrawal on ATM or cancelation of cash withdrawal on ATM;
    FO_OPER_TRANSFER_FROM_CARD_ATM      constant    com_api_type_pkg.t_name := '05'; --amount transfer from card to additional account (ATM);
    FO_OPER_PAYMENT_POS                 constant    com_api_type_pkg.t_name := '08'; --payment on POS (real or virtual) or cancelation of payment;
    FO_OPER_TRANSFER_TO_CARD_ATM        constant    com_api_type_pkg.t_name := '13'; --amount transfer from additional to card account (ATM);
    FO_OPER_TRANSFER_TO_CHIP_ATM        constant    com_api_type_pkg.t_name := '17'; --amount transfer to the card’s chip (ATM);
    FO_OPER_INQUIRY_CHIP_BAL_ATM        constant    com_api_type_pkg.t_name := '21'; --inquiry for the balance existing in card’s chip (ATM);
    FO_OPER_CREDIT_CARD_ACCT_POS        constant    com_api_type_pkg.t_name := '28'; --credit of a card account (virtual or real POS);
    FO_OPER_TRANSFER_FROM_CHIP_ATM      constant    com_api_type_pkg.t_name := '32'; --amount transfer from card’s chip (ATM);
    FO_OPER_DEPOSIT_CARD_ATM            constant    com_api_type_pkg.t_name := '41'; --deposit on the card account or on the card (ATM);
    FO_OPER_DEPOSIT_FOR_LOAN_ATM        constant    com_api_type_pkg.t_name := '42'; --deposit for installment loan (ATM);
    FO_OPER_CASH_M_ATM                  constant    com_api_type_pkg.t_name := '45'; --cash withdrawal on ATM (CashM operation);
    FO_OPER_INQUIRY_LAST_5_ATM          constant    com_api_type_pkg.t_name := '96'; --Inquiry for last five transactions (ATM);
    FO_OPER_INQUIRY_BALANCE             constant    com_api_type_pkg.t_name := '97'; --balance inquiry;
    
    FO_MSG_CODE_FILE_NAME               constant    com_api_type_pkg.t_tiny_id := 1; 
    FO_MSG_CODE_END_OF_FILE             constant    com_api_type_pkg.t_tiny_id := 99;
    FO_MSG_CODE_TITLE_PACKAGE           constant    com_api_type_pkg.t_tiny_id := 2;
    FO_MSG_CODE_END_PACKAGE             constant    com_api_type_pkg.t_tiny_id := 98;
    FO_MSG_CODE_DATA                    constant    com_api_type_pkg.t_tiny_id := 10;
    
    FO_PKG_TYPE_TRANSACTION             constant    com_api_type_pkg.t_name := '000';
    
    FO_DATA_RECORD_OPER                 constant    com_api_type_pkg.t_tiny_id := 1;
    FO_DATA_RECORD_PIN_CHANGE           constant    com_api_type_pkg.t_tiny_id := 2;
    FO_DATA_BALANCE_ATM                 constant    com_api_type_pkg.t_tiny_id := 3;
    
    FO_INDICATOR_CARD_ACCOUNT           constant    com_api_type_pkg.t_byte_char := '='; --card account balance is used;
    FO_INDICATOR_NO_BALANCE             constant    com_api_type_pkg.t_byte_char := '/'; --no balance is used;
    FO_INDICATOR_NO_DEFINED             constant    com_api_type_pkg.t_byte_char := ' '; --no balance is used, as such is not defined;
    FO_INDICATOR_UNLIMITED              constant    com_api_type_pkg.t_byte_char := '+'; --unlimited account balance.
    FO_INDICATOR_ZERO                   constant    com_api_type_pkg.t_byte_char := '0'; --???
    
    FO_TERMINAL_BORICA_ATM              constant    com_api_type_pkg.t_tiny_id := 1; --ATM in BORICA’s network;
    FO_TERMINAL_BORICA_POS              constant    com_api_type_pkg.t_tiny_id := 3; --POS in BORICA’s network;
    FO_TERMINAL_VIRT_POS_INTERNET       constant    com_api_type_pkg.t_tiny_id := 5; --virtual POS for INTERNET payment
    FO_TERMINAL_VIRT_POS_EVOICE         constant    com_api_type_pkg.t_tiny_id := 6; --virtual POS for payment through eVoice;
    FO_TERMINAL_VIRT_POS_MASS           constant    com_api_type_pkg.t_tiny_id := 7; --virtual POS for payment of bills of mass consumer through ATM.
    --From 10 to 28: ATM serviced by a bank with their own Card Management System.
    
    FO_CARD_NATIONAL                    constant    com_api_type_pkg.t_tiny_id := 4; --national debit card, issued by financial institution according to Regulation 16 of the Bulgarian National Bank regarding payments with bank cards and supported by BORICA; 
    FO_CARD_INTERN_BORICA               constant    com_api_type_pkg.t_tiny_id := 8; --international card (BIN is different from 6760), issued by financial institution, included in BORICA;
    FO_CARD_MC                          constant    com_api_type_pkg.t_tiny_id := 9; --international card MasterCard, accepted by BORICA;
    FO_CARD_VISA                        constant    com_api_type_pkg.t_tiny_id := 10; --international card Visa, accepted by BORICA;
    FO_CARD_AMEX                        constant    com_api_type_pkg.t_tiny_id := 11; --international card AMEX, accepted by BORICA;
    --from 12 to 30 :    card issued by bank with their own Card Management System
    
    FO_PIN_CHANGED                      constant    com_api_type_pkg.t_tiny_id := 0;
    
    g_session_file_id           com_api_type_pkg.t_long_id;
    g_record_number             com_api_type_pkg.t_short_id;
    
    g_prev_msg_code             com_api_type_pkg.t_tiny_id;             
    g_pkg_total                 com_api_type_pkg.t_short_id;
    g_control_amount            number;
    g_pkg_control_amount        number;
    g_seq_number                com_api_type_pkg.t_short_id;
    g_seq_pkg_number            com_api_type_pkg.t_short_id;
    
    g_package_rec               bgn_api_type_pkg.t_bgn_package_rec;

function check_control_amount(
    i_amount        in  number
  , i_control       in  number
  , i_num_chars     in  number  
) return com_api_type_pkg.t_boolean is
    l_tmp           com_api_type_pkg.t_name;
begin
    l_tmp   := i_amount;
    if length(l_tmp) < i_num_chars then
        l_tmp := lpad(l_tmp, i_num_chars, '0');
        
    elsif length(l_tmp) > i_num_chars then
        l_tmp := substr(l_tmp, -i_num_chars, i_num_chars);
        
    end if; 
    
    if i_control != to_number(l_tmp) then
        return  com_api_type_pkg.FALSE;
    else
        return  com_api_type_pkg.TRUE;
    end if;
    
end;

function check_record (
    io_string           in out nocopy   com_api_type_pkg.t_full_desc
) return com_api_type_pkg.t_tiny_id
is
    l_message_code  com_api_type_pkg.t_tiny_id;
    
begin
    if g_record_number = 1 then
        g_prev_msg_code := null;
        
    end if;   
    
    if g_prev_msg_code = FO_MSG_CODE_END_OF_FILE then
        com_api_error_pkg.raise_error(
            i_error         => 'BGN_RECORDS_AFTER_FOOTER'
          , i_entity_type   => prc_api_const_pkg.ENTITY_TYPE_SESSION_FILE
          , i_object_id     => g_session_file_id
          , i_env_param1    => g_record_number 
        );
        
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
    
    if substr(io_string, 1, 1) != '1' then
        com_api_error_pkg.raise_error(
            i_error         => 'BGN_WRONG_TITLE_CODE'
          , i_entity_type   => prc_api_const_pkg.ENTITY_TYPE_SESSION_FILE
          , i_object_id     => g_session_file_id
          , i_env_param1    => g_record_number  
          , i_env_param2    => substr(io_string, 1, 1) 
          , i_env_param3    => '1'
        );
        
    end if;
    
    if substr(io_string, 5, 2) != '04' then
        com_api_error_pkg.raise_error(
            i_error         => 'BGN_WRONG_APP_CODE'
          , i_entity_type   => prc_api_const_pkg.ENTITY_TYPE_SESSION_FILE
          , i_object_id     => g_session_file_id
          , i_env_param1    => g_record_number  
          , i_env_param2    => substr(io_string, 5, 2)
          , i_env_param3    => '04'
        );
        
    end if;
    
    l_message_code  := substr(io_string, 2, 3);
    
    case l_message_code
    when FO_MSG_CODE_FILE_NAME then
        if g_record_number > 1 then
            com_api_error_pkg.raise_error(
                i_error         => 'BGN_WRONG_MESSAGE_CODE'
              , i_entity_type   => prc_api_const_pkg.ENTITY_TYPE_SESSION_FILE
              , i_object_id     => g_session_file_id
              , i_env_param1    => g_record_number  
              , i_env_param2    => l_message_code
              , i_env_param3    => FO_MSG_CODE_FILE_NAME
            );
            
        end if;
        
    when FO_MSG_CODE_TITLE_PACKAGE then
        if g_prev_msg_code not in (
            FO_MSG_CODE_FILE_NAME
          , FO_MSG_CODE_END_PACKAGE  
        ) then
            com_api_error_pkg.raise_error(
                i_error         => 'BGN_WRONG_MESSAGE_CODE'
              , i_entity_type   => prc_api_const_pkg.ENTITY_TYPE_SESSION_FILE
              , i_object_id     => g_session_file_id
              , i_env_param1    => g_record_number  
              , i_env_param2    => l_message_code
              , i_env_param3    => FO_MSG_CODE_END_PACKAGE
            );
            
        end if;
        
    when FO_MSG_CODE_END_PACKAGE then
        if g_prev_msg_code != FO_MSG_CODE_DATA then
            com_api_error_pkg.raise_error(
                i_error         => 'BGN_WRONG_MESSAGE_CODE'
              , i_entity_type   => prc_api_const_pkg.ENTITY_TYPE_SESSION_FILE
              , i_object_id     => g_session_file_id
              , i_env_param1    => g_record_number  
              , i_env_param2    => l_message_code
              , i_env_param3    => FO_MSG_CODE_DATA
            );
        end if; 
        
    when FO_MSG_CODE_DATA then
        if g_prev_msg_code not in (
            FO_MSG_CODE_TITLE_PACKAGE
          , FO_MSG_CODE_DATA  
        ) then
            com_api_error_pkg.raise_error(
                i_error         => 'BGN_WRONG_MESSAGE_CODE'
              , i_entity_type   => prc_api_const_pkg.ENTITY_TYPE_SESSION_FILE
              , i_object_id     => g_session_file_id
              , i_env_param1    => g_record_number  
              , i_env_param2    => l_message_code
              , i_env_param3    => FO_MSG_CODE_DATA
            );
            
        end if;
       
    when FO_MSG_CODE_END_OF_FILE then
        if g_prev_msg_code != FO_MSG_CODE_END_PACKAGE then
            com_api_error_pkg.raise_error(
                i_error         => 'BGN_WRONG_MESSAGE_CODE'
              , i_entity_type   => prc_api_const_pkg.ENTITY_TYPE_SESSION_FILE
              , i_object_id     => g_session_file_id
              , i_env_param1    => g_record_number  
              , i_env_param2    => l_message_code
              , i_env_param3    => FO_MSG_CODE_END_PACKAGE
            );
            
        end if;        
        
    else
        com_api_error_pkg.raise_error(
            i_error         => 'BGN_WRONG_MESSAGE_CODE'
          , i_entity_type   => prc_api_const_pkg.ENTITY_TYPE_SESSION_FILE
          , i_object_id     => g_session_file_id
          , i_env_param1    => g_record_number  
          , i_env_param2    => l_message_code
        );    
        
    end case;
    
    g_prev_msg_code := l_message_code;
    
    return l_message_code;
end;
    
procedure process_title_of_file (
    io_string       in out nocopy   com_api_type_pkg.t_full_desc
  , io_file_rec     in out nocopy   bgn_api_type_pkg.t_bgn_file_rec      
)
is
begin
    io_file_rec.file_label     := substr(io_string, 19, 10);
    if substr(io_file_rec.file_label, 1, 6) != 'BORICA' then
        com_api_error_pkg.raise_error(
            i_error         => 'BGN_WRONG_FILE_LABEL'
          , i_entity_type   => prc_api_const_pkg.ENTITY_TYPE_SESSION_FILE
          , i_object_id     => g_session_file_id
          , i_env_param1    => g_record_number  
          , i_env_param2    => 'BORICAnnnn'
        );
            
    end if;
    
    io_file_rec.journal_period := substr(io_file_rec.file_label, 7, 4);
    io_file_rec.sender_code    := substr(io_string, 29, 5);
    io_file_rec.receiver_code  := substr(io_string, 34, 5);
    io_file_rec.creation_date  := to_date(substr(io_string, 39, 6), 'yymmdd');

end;

procedure process_end_of_file (
    io_string       in out nocopy   com_api_type_pkg.t_full_desc
  , io_file_rec     in out nocopy   bgn_api_type_pkg.t_bgn_file_rec  
) is
begin
    io_file_rec.package_total   := substr(io_string, 19, 6);
    io_file_rec.control_amount  := substr(io_string, 25, 13);
    
    if io_file_rec.package_total != g_pkg_total then
        com_api_error_pkg.raise_error(
            i_error         => 'BGN_WRONG_NUMBER_OF_PACKAGES'
          , i_entity_type   => prc_api_const_pkg.ENTITY_TYPE_SESSION_FILE
          , i_object_id     => g_session_file_id
          , i_env_param1    => g_record_number  
          , i_env_param2    => io_file_rec.package_total
          , i_env_param3    => g_pkg_total
        );
    end if;
    
    if check_control_amount(
        i_amount    => g_control_amount
      , i_control   => io_file_rec.control_amount
      , i_num_chars => 13  
    ) = com_api_const_pkg.FALSE then
    
        com_api_error_pkg.raise_error(
            i_error         => 'BGN_WRONG_CONTROL_AMOUNT'
          , i_entity_type   => prc_api_const_pkg.ENTITY_TYPE_SESSION_FILE
          , i_object_id     => g_session_file_id
          , i_env_param1    => g_record_number  
          , i_env_param2    => io_file_rec.control_amount
          , i_env_param3    => g_control_amount
        );
        
    end if;
        
    bgn_api_fin_pkg.put_file_rec(
        i_file_rec      => io_file_rec
    );
    
end;    

procedure process_title_of_package (
    io_string           in out nocopy   com_api_type_pkg.t_full_desc
  , io_file_rec         in out nocopy   bgn_api_type_pkg.t_bgn_file_rec
) is
    l_rec_number        com_api_type_pkg.t_short_id;
begin
    l_rec_number                     := substr(io_string, 7, 6);
    if l_rec_number != g_seq_number + 1 then
        com_api_error_pkg.raise_error(
            i_error         => 'BGN_WRONG_RECORD_SEQ_NUMBER'
          , i_entity_type   => prc_api_const_pkg.ENTITY_TYPE_SESSION_FILE
          , i_object_id     => g_session_file_id
          , i_env_param1    => g_record_number  
          , i_env_param2    => g_seq_number + 1
        );
        
    else
        g_seq_number := l_rec_number;    
        
    end if;
    
    g_package_rec.sender_code        := substr(io_string, 19, 5);
    g_package_rec.receiver_code      := substr(io_string, 24, 5);
    g_package_rec.creation_date      := to_date(substr(io_string, 29, 12), 'yymmddhh24miss');
    
    g_package_rec.package_type       := substr(io_string, 41, 3);
    if g_package_rec.package_type != FO_PKG_TYPE_TRANSACTION then
        com_api_error_pkg.raise_error(
            i_error         => 'BGN_WRONG_PACKAGE_TYPE'
          , i_entity_type   => prc_api_const_pkg.ENTITY_TYPE_SESSION_FILE
          , i_object_id     => g_session_file_id
          , i_env_param1    => g_record_number  
          , i_env_param2    => g_package_rec.package_type
          , i_env_param3    => FO_PKG_TYPE_TRANSACTION
        );
        
    end if;    
    
    g_package_rec.package_number     := substr(io_string, 44, 6);
    if g_package_rec.package_number != g_seq_pkg_number + 1 then
       com_api_error_pkg.raise_error(
            i_error         => 'BGN_WRONG_PACKAGE_SEQ_NUMBER'
          , i_entity_type   => prc_api_const_pkg.ENTITY_TYPE_SESSION_FILE
          , i_object_id     => g_session_file_id
          , i_env_param1    => g_record_number  
          , i_env_param2    => g_package_rec.package_number
          , i_env_param3    => g_seq_pkg_number + 1
        );
        g_package_rec.package_number    := null;
        
    else
        g_seq_pkg_number := g_package_rec.package_number;
            
    end if;
    
    g_package_rec.id    := bgn_package_seq.nextval();
    
end;

procedure process_end_of_package (
    io_string           in out nocopy   com_api_type_pkg.t_full_desc
  , io_file_rec         in out nocopy   bgn_api_type_pkg.t_bgn_file_rec
) is
begin
    g_package_rec.control_amount  := substr(io_string, 19, 13);
    
    if check_control_amount(
        i_amount    => g_pkg_control_amount
      , i_control   => g_package_rec.control_amount
      , i_num_chars => 13  
    ) = com_api_const_pkg.FALSE then 
    
        com_api_error_pkg.raise_error(
            i_error         => 'BGN_WRONG_CONTROL_AMOUNT'
          , i_entity_type   => prc_api_const_pkg.ENTITY_TYPE_SESSION_FILE
          , i_object_id     => g_session_file_id
          , i_env_param1    => g_record_number  
          , i_env_param2    => g_package_rec.control_amount
          , i_env_param3    => g_pkg_control_amount
        );
        
    end if;
    
    g_pkg_total := g_pkg_total + 1;
    g_control_amount    := g_control_amount + g_pkg_control_amount;
    
    bgn_api_fin_pkg.put_package_rec(
        io_package_rec      => g_package_rec
    );
    
end;

procedure register_operation (
    io_fin_rec           in out nocopy  bgn_api_type_pkg.t_bgn_fin_rec
) is
    l_oper                  opr_api_type_pkg.t_oper_rec;
    l_iss_part              opr_api_type_pkg.t_oper_part_rec;
    l_acq_part              opr_api_type_pkg.t_oper_part_rec;
begin
    trc_log_pkg.debug(
        i_text          => 'bgn_fo_pkg.register_operation [#1] [#2]'
      , i_env_param1    => io_fin_rec.inst_id
      , i_env_param2    => io_fin_rec.network_id
    );

    --amounts and currencies
    l_oper.oper_amount              := io_fin_rec.transaction_amount;
    l_oper.oper_currency            := bgn_api_const_pkg.BGN_DEFAULT_CURRENCY;
    l_iss_part.account_amount       := io_fin_rec.other_amount;
    l_iss_part.account_currency     := bgn_api_const_pkg.BGN_DEFAULT_CURRENCY; 

    io_fin_rec.is_invalid           := com_api_const_pkg.FALSE;
    l_oper.originator_refnum        := io_fin_rec.stan;
    
    bgn_api_fin_pkg.fin_to_oper(
        io_fin_rec          => io_fin_rec
      , io_oper             => l_oper
      , io_iss_part         => l_iss_part
      , io_acq_part         => l_acq_part
      , i_session_file_id   => g_session_file_id
      , i_record_number     => g_record_number 
      , i_file_code         => 'FO'  
    );  
    
    if l_oper.is_reversal = com_api_const_pkg.TRUE then
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
        
    if io_fin_rec.terminal_type in (
        FO_TERMINAL_BORICA_ATM
    ) then
        l_oper.terminal_type    := acq_api_const_pkg.TERMINAL_TYPE_ATM;
            
    elsif io_fin_rec.terminal_type in (
        FO_TERMINAL_BORICA_POS
      , FO_TERMINAL_VIRT_POS_MASS  
    ) then
        l_oper.terminal_type    := acq_api_const_pkg.TERMINAL_TYPE_POS;    
        
    elsif io_fin_rec.terminal_type in (
        FO_TERMINAL_VIRT_POS_INTERNET
    ) then
        l_oper.terminal_type    := acq_api_const_pkg.TERMINAL_TYPE_INTERNET;
                
    elsif io_fin_rec.terminal_type in (
        FO_TERMINAL_VIRT_POS_EVOICE
    ) then
        l_oper.terminal_type    := acq_api_const_pkg.TERMINAL_TYPE_EPOS;
            
    elsif io_fin_rec.mcc = '6011' then 
        l_oper.terminal_type    := acq_api_const_pkg.TERMINAL_TYPE_ATM;
         
    else
        l_oper.terminal_type    := acq_api_const_pkg.TERMINAL_TYPE_POS;
            
    end if;       
            
    l_iss_part.account_number   := io_fin_rec.card_acc_number;
    
    if io_fin_rec.message_type = FO_MSG_PAYMENT_POS
    and io_fin_rec.cashback_acq_amount > 0 then
        l_oper.oper_type            := opr_api_const_pkg.OPERATION_TYPE_CASHBACK;
        l_oper.oper_cashback_amount := io_fin_rec.cashback_acq_amount;
        
    end if;
    
    if io_fin_rec.mcc = 6010 then
        l_oper.oper_type   := opr_api_const_pkg.OPERATION_TYPE_POS_CASH;
        
    end if;
    
    l_oper.incom_sess_file_id   := g_session_file_id; 
    
    trc_log_pkg.debug(
        i_text          => 'card_instance id [#1]'
      , i_env_param1    =>  l_iss_part.card_instance_id 
    );
     
    bgn_api_fin_pkg.create_operation(
        i_oper      => l_oper
      , i_iss_part  => l_iss_part
      , i_acq_part  => l_acq_part  
    );
    
    bgn_api_fin_pkg.match_usonus(
        io_oper             => l_oper
      , io_iss_part         => l_iss_part
      , io_acq_part         => l_acq_part
    );
    
end register_operation;

function process_data_rec (
    io_data_string      in out nocopy   com_api_type_pkg.t_full_desc
  , io_file_rec         in out nocopy   bgn_api_type_pkg.t_bgn_file_rec 
) return com_api_type_pkg.t_boolean is
    l_card_id           com_api_type_pkg.t_card_number;
    l_pos               binary_integer;
    l_data_rec          bgn_api_type_pkg.t_bgn_fin_rec;
    
    procedure check_card_type(
        i_card_type     in  com_api_type_pkg.t_tiny_id
    ) is
    begin
        if i_card_type not in (
            FO_CARD_NATIONAL      
          , FO_CARD_INTERN_BORICA 
          , FO_CARD_MC            
          , FO_CARD_VISA          
          , FO_CARD_AMEX
        ) and l_data_rec.card_type not between 12 and 30 then
            trc_log_pkg.error(
                i_text          => 'BGN_WRONG_CARD_TYPE'
              , i_entity_type   => prc_api_const_pkg.ENTITY_TYPE_SESSION_FILE
              , i_object_id     => g_session_file_id
              , i_env_param1    => g_record_number  
              , i_env_param2    => i_card_type  
            );
            l_data_rec.is_invalid   := com_api_const_pkg.TRUE;
        end if;
        
    end check_card_type;  
    
    procedure check_terminal_type(
        i_terminal_type     in  com_api_type_pkg.t_tiny_id
    ) is
    begin
        if i_terminal_type not in (
            FO_TERMINAL_BORICA_ATM        
          , FO_TERMINAL_BORICA_POS        
          , FO_TERMINAL_VIRT_POS_INTERNET 
          , FO_TERMINAL_VIRT_POS_EVOICE   
          , FO_TERMINAL_VIRT_POS_MASS    
        ) and l_data_rec.terminal_type not between 10 and 28 then
            trc_log_pkg.error(
                i_text          => 'BGN_WRONG_CARD_TYPE'
              , i_entity_type   => prc_api_const_pkg.ENTITY_TYPE_SESSION_FILE
              , i_object_id     => g_session_file_id
              , i_env_param1    => g_record_number  
              , i_env_param2    => i_terminal_type
            );
            l_data_rec.is_invalid   := com_api_const_pkg.TRUE;
        end if;
        
    end check_terminal_type;
      
begin
    l_data_rec.id           := opr_api_create_pkg.get_id;
    trc_log_pkg.set_object(
        i_entity_type   => opr_api_const_pkg.ENTITY_TYPE_OPERATION
      , i_object_id     => l_data_rec.id  
    );
    l_data_rec.inst_id      := io_file_rec.inst_id;
    l_data_rec.network_id   := io_file_rec.network_id;

    l_data_rec.record_type   := substr(io_data_string, 2, 3);
    l_data_rec.record_number := substr(io_data_string, 7, 6);
    l_data_rec.message_type  := substr(io_data_string, 13, 6);
    l_data_rec.file_id       := io_file_rec.id;
    l_data_rec.package_id    := g_package_rec.id;
    
    l_data_rec.transaction_date    := to_date(trim(substr(io_data_string, 19, 12)), 'yymmddhh24miss');
    
    if l_data_rec.message_type in (
        FO_MSG_PAYMENT_POS  
      , FO_MSG_CARD_ATM     
      , FO_MSG_CANCEL_POS   
      , FO_MSG_INQUIRY      
      , FO_MSG_CREDIT       
      , FO_MSG_CANCEL_CREDIT
    ) then
        l_data_rec.transaction_type        := trim(substr(io_data_string, 31, 2));
        if l_data_rec.transaction_type not in (
            FO_OPER_CASH_ATM              
          , FO_OPER_TRANSFER_FROM_CARD_ATM
          , FO_OPER_PAYMENT_POS           
          , FO_OPER_TRANSFER_TO_CARD_ATM  
          , FO_OPER_TRANSFER_TO_CHIP_ATM  
          , FO_OPER_INQUIRY_CHIP_BAL_ATM  
          , FO_OPER_CREDIT_CARD_ACCT_POS  
          , FO_OPER_TRANSFER_FROM_CHIP_ATM
          , FO_OPER_DEPOSIT_CARD_ATM      
          , FO_OPER_DEPOSIT_FOR_LOAN_ATM  
          , FO_OPER_CASH_M_ATM            
          , FO_OPER_INQUIRY_LAST_5_ATM    
          , FO_OPER_INQUIRY_BALANCE 
        ) then
            trc_log_pkg.error(
                i_text          => 'BGN_WRONG_OPERATION_TYPE'
              , i_entity_type   => prc_api_const_pkg.ENTITY_TYPE_SESSION_FILE
              , i_object_id     => g_session_file_id
              , i_env_param1    => g_record_number  
              , i_env_param2    => l_data_rec.transaction_type
            );
            l_data_rec.is_invalid   := com_api_const_pkg.TRUE;
        end if;
        
        l_data_rec.transaction_amount      := trim(substr(io_data_string, 33, 6));
        
        l_data_rec.auth_indicator          := trim(substr(io_data_string, 39, 1));
        if l_data_rec.auth_indicator not in (
            FO_INDICATOR_CARD_ACCOUNT
          , FO_INDICATOR_NO_BALANCE  
          , FO_INDICATOR_NO_DEFINED  
          , FO_INDICATOR_UNLIMITED
          , FO_INDICATOR_ZERO
        ) then
            trc_log_pkg.error(
                i_text          => 'BGN_WRONG_BALANCE_INDICATOR'
              , i_entity_type   => prc_api_const_pkg.ENTITY_TYPE_SESSION_FILE
              , i_object_id     => g_session_file_id
              , i_env_param1    => g_record_number  
              , i_env_param2    => l_data_rec.auth_indicator
            );
            l_data_rec.is_invalid   := com_api_const_pkg.TRUE;
        end if;
        
        l_data_rec.other_amount            := trim(substr(io_data_string, 40, 12));
        l_data_rec.add_response_data       := trim(substr(io_data_string, 52, 1));
        
        if l_data_rec.message_type = FO_MSG_CANCEL_CREDIT then 
            l_data_rec.reject_code         := trim(substr(io_data_string, 53, 4));
        end if;    
        
        --terminal block 
        l_data_rec.terminal_number         := trim(substr(io_data_string, 57, 8));
        
        l_data_rec.terminal_type           := trim(substr(io_data_string, 65, 2));
        check_terminal_type(l_data_rec.terminal_type);
        
        l_data_rec.terminal_subtype        := trim(substr(io_data_string, 67, 2));
        l_data_rec.account_number          := trim(substr(io_data_string, 69, 22));
        l_data_rec.report_period           := trim(substr(io_data_string, 91, 4));
        l_data_rec.withdrawal_number       := trim(substr(io_data_string, 95, 5));
        l_data_rec.period_amount           := trim(substr(io_data_string, 100, 12));
        
        --card block
        l_card_id                          := trim(substr(io_data_string, 112, 24));
        g_pkg_control_amount    := g_pkg_control_amount + to_number(substr(l_card_id, 1, 13));
        
        l_data_rec.card_type               := trim(substr(io_data_string, 136, 2));
        check_card_type(l_data_rec.card_type);
        
        l_data_rec.card_subtype            := trim(substr(io_data_string, 138, 2));
        l_data_rec.issuer_code             := trim(substr(io_data_string, 140, 5));
        l_data_rec.card_acc_number         := trim(substr(io_data_string, 145, 22));
        l_data_rec.add_acc_number          := trim(substr(io_data_string, 167, 22));
        
        if l_data_rec.card_type = FO_CARD_NATIONAL then
            /*
            0000 YYMM BBBB CCCCCC DD HH S K     
            0000 1412 3456 789036 19 77 0 7     l_card_id
            
            YYMM            : Expiration date    
            BBBBCCCCCCHH    : Cardholders Identifier
            DD            : Check digit modulo 97 of BBBBCCCCCC
            S            : Sequence number of the card for this cardholder
            K            : Check digit modulo 7 of BBBBCCCCCCDDHHS
            */
            l_data_rec.card_number         := bgn_api_const_pkg.BGN_LOCAL_BIN   --6760 
                                           || substr(l_card_id, 9, 10)          --BBBBCCCCCC
                                           || substr(l_card_id, 21, 2);         --HH
            l_data_rec.card_number         := l_data_rec.card_number || com_api_checksum_pkg.get_luhn_checksum(i_number => l_data_rec.card_number);
            
            l_data_rec.card_seq_number     := trim(substr(l_card_id, 23, 1));   --S
            l_data_rec.card_expire_date    := trim(substr(l_card_id, 5, 4));    --YYMM
        
        else
            l_data_rec.card_number         := trim(substr(l_card_id, 1, 19));
            l_data_rec.card_seq_number     := trim(substr(l_card_id, 20, 1));
            l_data_rec.card_expire_date    := trim(substr(l_card_id, 21, 4));
            
        end if;
        
        --additional data
        l_data_rec.transaction_number      := trim(substr(io_data_string, 189, 6));
        l_data_rec.stan                    := trim(substr(io_data_string, 195, 6));
        l_data_rec.trace_number            := l_data_rec.stan;
        l_data_rec.auth_code               := trim(substr(io_data_string, 201, 6));
        l_data_rec.atm_bank_code           := trim(substr(io_data_string, 207, 3));
        l_data_rec.pos_text                := trim(substr(io_data_string, 210, 40));
        l_data_rec.cashback_acq_amount     := trim(substr(io_data_string, 250, 12));
        l_data_rec.mcc                     := trim(substr(io_data_string, 262, 4));
        l_data_rec.deposit_number          := trim(substr(io_data_string, 266, 22));
        l_data_rec.ecommerce               := trim(substr(io_data_string, 288, 3));
        l_data_rec.interbank_fee_amount    := trim(substr(io_data_string, 291, 8));  
        
        l_pos   := instr(l_data_rec.pos_text, '>');
        
        if l_pos > 0 then
            l_data_rec.merchant_name := trim(substr(l_data_rec.pos_text, 1, l_pos - 1));
            l_data_rec.merchant_city := trim(substr(l_data_rec.pos_text, l_pos + 1, length(l_data_rec.pos_text) - l_pos));
            
        end if;         
        
    elsif l_data_rec.message_type in (
        FO_MSG_PARTIAL_ATM
      , FO_MSG_BALANCE_ATM
    ) then
        --terminal block 
        l_data_rec.terminal_number         := trim(substr(io_data_string, 57, 8));
        l_data_rec.terminal_type           := trim(substr(io_data_string, 65, 2));
        check_terminal_type(l_data_rec.terminal_type);
        
        l_data_rec.terminal_subtype        := trim(substr(io_data_string, 67, 2));
        
        l_data_rec.account_number          := trim(substr(io_data_string, 69, 22));
        g_pkg_control_amount    := g_pkg_control_amount + to_number(substr(l_data_rec.account_number, 1, 13));
        
        l_data_rec.report_period           := trim(substr(io_data_string, 91, 4));
        
         --balance block
        l_data_rec.loaded_amount_atm       := trim(substr(io_data_string, 112, 9));
        l_data_rec.is_fullload             := trim(substr(io_data_string, 121, 1));
        l_data_rec.total_amount_atm        := trim(substr(io_data_string, 122, 9));
        l_data_rec.total_amount_tandem     := trim(substr(io_data_string, 131, 9));
        l_data_rec.withdrawal_count        := trim(substr(io_data_string, 140, 5));
        l_data_rec.receipt_count           := trim(substr(io_data_string, 145, 5));
        
    elsif l_data_rec.message_type = FO_MSG_PIN_CHANGE then
                
        --transaction block
        l_data_rec.transaction_type        := trim(substr(io_data_string, 31, 2));
        
        --terminal block 
        l_data_rec.terminal_number         := trim(substr(io_data_string, 57, 8));
        
        --card block
        l_card_id                          := trim(substr(io_data_string, 108, 24));
        g_pkg_control_amount    := g_pkg_control_amount + to_number(substr(l_card_id, 1, 13));
        
        l_data_rec.card_type               := trim(substr(io_data_string, 132, 2));
        check_card_type(l_data_rec.card_type);
        
        l_data_rec.card_acc_number         := trim(substr(io_data_string, 141, 22));
        l_data_rec.incident_cause          := trim(substr(io_data_string, 181, 4));
        
        if l_data_rec.card_type = FO_CARD_NATIONAL then
            l_data_rec.card_number         := l_card_id;
            l_data_rec.card_seq_number     := trim(substr(l_card_id, 23, 1));
            l_data_rec.card_expire_date    := trim(substr(l_card_id, 5, 4));   
        
        else
            l_data_rec.card_number         := trim(substr(l_card_id, 1, 19));
            l_data_rec.card_seq_number     := trim(substr(l_card_id, 20, 1));
            l_data_rec.card_expire_date    := trim(substr(l_card_id, 21, 4));
            
        end if;
        
    else
        trc_log_pkg.error(
            i_text          => 'BGN_WRONG_MESSAGE_TYPE'
          , i_entity_type   => prc_api_const_pkg.ENTITY_TYPE_SESSION_FILE
          , i_object_id     => g_session_file_id
          , i_env_param1    => g_record_number  
          , i_env_param2    => l_data_rec.message_type
        );    
        l_data_rec.is_invalid   := com_api_const_pkg.TRUE;
    end if;
    
    if l_data_rec.message_type in (
        FO_MSG_CANCEL_CREDIT
      , FO_MSG_CANCEL_POS  
    ) then
        l_data_rec.is_reject := 'R';
        l_data_rec.is_reversal := com_api_type_pkg.TRUE;
        
    else
        l_data_rec.is_reject := 'N';
        l_data_rec.is_reversal := com_api_type_pkg.FALSE;
    
    end if;
    
    l_data_rec.is_incoming  := io_file_rec.is_incoming;
    l_data_rec.status       := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;
    l_data_rec.file_record_number   := g_record_number;
    
    register_operation(
        io_fin_rec          => l_data_rec
    );
    
    return nvl(l_data_rec.is_invalid, com_api_const_pkg.FALSE);
    
end process_data_rec;

procedure process_string(
    io_data             in out nocopy   com_api_type_pkg.t_raw_data
  , i_session_file_id   in              com_api_type_pkg.t_long_id
  , i_record_number     in              com_api_type_pkg.t_short_id
  , i_inst_id           in              com_api_type_pkg.t_inst_id
  , i_network_id        in              com_api_type_pkg.t_network_id
  , o_is_invalid           out          com_api_type_pkg.t_boolean
) is
    l_record_type       com_api_type_pkg.t_tiny_id;
    l_fin_rec           bgn_api_type_pkg.t_bgn_fin_rec;
begin
    trc_log_pkg.debug(
        i_text          => 'bgn_fo_pkg.process_string'
    );
    
    g_session_file_id   := i_session_file_id;
    g_record_number     := i_record_number;
    o_is_invalid        := com_api_const_pkg.FALSE;
    
    l_record_type   := check_record(
        io_string           => io_data
    );
    
    case l_record_type
    when FO_MSG_CODE_FILE_NAME then   
        process_title_of_file (
            io_string   => io_data
          , io_file_rec => bgn_prc_import_pkg.g_file_rec  
        );
        
        g_pkg_total             := 0;
        g_control_amount        := 0;
        g_seq_pkg_number        := 0;
        
    when FO_MSG_CODE_END_OF_FILE then
        process_end_of_file (
            io_string   => io_data
          , io_file_rec => bgn_prc_import_pkg.g_file_rec  
        );    
    
    when FO_MSG_CODE_TITLE_PACKAGE then
        g_package_rec               := null;
        g_pkg_control_amount        := 0;
        g_seq_number                := 0;
        
        process_title_of_package (
            io_string       => io_data
          , io_file_rec     => bgn_prc_import_pkg.g_file_rec  
        );
        
        g_package_rec.file_id := bgn_prc_import_pkg.g_file_rec.id;
        
    when FO_MSG_CODE_END_PACKAGE then
        process_end_of_package (
            io_string       => io_data
          , io_file_rec     => bgn_prc_import_pkg.g_file_rec
        );    
        
    when FO_MSG_CODE_DATA then
        o_is_invalid := 
            process_data_rec (
                io_data_string      => io_data
              , io_file_rec         => bgn_prc_import_pkg.g_file_rec   
            );
            
        trc_log_pkg.clear_object;         
        
    end case;
    
end;

end bgn_fo_pkg;
/
 