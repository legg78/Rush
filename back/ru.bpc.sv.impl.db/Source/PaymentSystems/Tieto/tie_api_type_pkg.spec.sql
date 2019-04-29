create or replace package tie_api_type_pkg authid definer is

-- Purpose : KONTS Financial message types

subtype t_clearing_data is varchar2(2000);

type t_mes_file_header_rec is record(
    mtid                     varchar2(2)   -- 01 '00'
  , rec_centr                varchar2(2)   -- 03 Receiver center code
  , send_centr               varchar2(2)   -- 05 Sender center code
  , file                     varchar2(8)   -- 07 File name(without extension)
  , card_id                  varchar2(8)   -- 15 Card type
  , version                  varchar2(4)   -- 23 File version
);

type t_mes_file_trailer_rec is record(
    mtid                     varchar2(2)   -- 01 '99'
  , rec_centr                varchar2(2)   -- 03 Receiver center code
  , send_centr               varchar2(2)   -- 05 Sender center code
  , file                     varchar2(8)   -- 07 File name(without extension)
  , number_of_recs           varchar2(8)   -- 15 Number of records in the file (including the header and trailer)
  , sum_sign                 varchar2(1)   -- 23 '+' or '-'
  , trx_sum                  varchar2(14)  -- 24 Transaction amount. Sum of transactions amount in acquirer bank's center
                                           --    currency(field position 456, field length 12 in transaction record).
                                           --    Sum is calculated considering transaction accounting type.
                                           --    If accounting type = debit, then Sum = Sum + transaction amount,
                                           --    else Sum = Sum  transaction amount).
                                           --    Accounting type depends on fields msg_type(field position 525, field length 4 in transaction
                                           --    record) and proc_code(field position 533, field length 2 in transaction record).
                                           --    If 2nd character of msg_type equals 1 or 2 and 1st character of proc_code equals 2
                                           --    then accounting type = credit.
                                           --    If 2nd character of msg_type equals 1 or 2 and 1st character of proc_code is not equal to 2
                                           --    then accounting type = debit.
                                           --    If 2nd character of msg_type is not equal to 1 or 2 and 1st character of proc_code is equal to 2
                                           --    then accounting type = debit.
                                           --    If 2nd character of msg_type is not equal to 1 or 2 and 1st character of proc_code is not equal to 2
                                           --    then accounting type = credit.

  , control                  varchar2(14)  -- 38 Control amount. Transaction amount.
                                           --    Sum of transactions amount in acquirer bank's center
                                           --    currency(field position 456, field length 12 in transaction record).
                                           --    Sum is calculated ignoring accounting type(Sum = Sum + transaction amount).
);

type t_mes_fin_rec is record(
    mtid                     varchar2(2)   -- 001 M '10'
  , rec_centr                number(2)     -- 003 - Receiver center code
  , send_centr               number(2)     -- 005 - Sender center code
  , iss_cmi                  varchar2(8)   -- 007 O Issuer bank`s CMI
  , send_cmi                 varchar2(8)   -- 015 O Acquirer bank`s CMI
  , settl_cmi                varchar2(8)   -- 023 M CMI of settlement bank of the Issuer bank`s center
  , acq_bank                 varchar2(2)   -- 031 O (W-File only) Acquirer bank
  , acq_branch               varchar2(3)   -- 033 O (W-File only) Acquirer bank branch
  , member                   varchar2(1)   -- 036 O (W-File only) Acquirer bank member indicator
  , clearing_group           varchar2(2)   -- 037 O (W-File only) Local clearing group
  , sender_ica               varchar2(4)   -- 031 O (L-File only) Sender ICA
  , receiver_ica             varchar2(4)   -- 035 O (L-File only) Receiver ICA
  , merchant                 varchar2(7)   -- 039 M Card acceptor  merchant code
                                           --       (If Length of merchant code>7, than  substr(merchant code,1,7))
  , batch_nr                 varchar2(7)   -- 046 M Batch No. (last 7 symbols from batch_id)
  , slip_nr                  varchar2(7)   -- 053 M Transaction No. (must be unique in one batch)
  , card                     varchar2(19)  -- 060 M Card No.
  , exp_date                 date          -- 079 M Card expiry date (YYMM)
  , tran_date                date          -- 083 M Transaction date (YYYYMMDD)
  , tran_time                date          -- 091 M Transaction time (HH24MISS)
  , tran_type                varchar2(2)   -- 097 M Transaction type
                                           --       05, 25  purchases  direct / reversal transaction
                                           --       07, 27  cash advance  direct / reversal transaction
                                           --       06, 26  returned purchase direct / reversal transaction
                                           --       08, 28  deposit - direct / reversal transaction
                                           --       09, 29  Cachback - direct / reversal transaction
  , appr_code                varchar2(6)   -- 099 M Authorization code
                                           --       In the event of On-line authorization the value must be equal with that of authorization response;
                                           --       in the event of Off-line authorization the value must either be assigned or left blank,
                                           --       if the authorization code has not been assigned (e.g., imprinter transactions without authorization).
                                           --       Field No 38 according to ISO-8583 specification.
  , appr_src                 varchar2(1)   -- 105 M Source of authorization code
                                           --       Identifier showing the source of the authorization code
                                           --       Appr_code:
                                           --         '1' = 'On-line'
                                           --         '3' = 'Off-line'
                                           --         '4' = voice authorization
                                           --         '5' = pre-authorization.
  , stan                     varchar2(6)   -- 106 M System Trace Audit Number
                                           --       In case of EPI products the value must be equal with that of authorization response (the value does not matter for other products).
                                           --       The input of appropriate values for clients in line with the VISA-EMEA Protocol is ensured by the interface file entry into TVS and transfer to 'back office'
                                           --       with the authorization data entry in on position (configuration for card prefixes must hold the 'copy stan' reference).
                                           --       Field No 11 according to ISO-8583 specification.
  , ref_number               varchar2(12)  -- 112 M Retrieval Reference Number
  , amount                   number(12)    -- 124 M Transaction amount in minor currency units
  , cash_back                number(12)    -- 136 M Cash back = 0
  , fee                      number(10)    -- 148 O Processing fee
  , currency                 varchar2(3)   -- 158 M Transaction currency code - symbolic
  , ccy_exp                  number(1)     -- 161 M Number of decimals in transaction currency
  , sb_amount                number(12)    -- 162 O Transaction amount in inter-center settlement currency
  , sb_cshback               number(12)    -- 174 O Cash back in inter-center settlement currency
  , sb_fee                   number(10)    -- 186 O Processing fee in inter-center settlement currency
  , sbnk_ccy                 varchar2(3)   -- 196 O Inter-center settlement currency
  , sb_ccyexp                number(1)     -- 199 O Number of decimal fractions in inter-center settlement currency
  , sb_cnvrate               number(14,9)  -- 200 O Conversion rate from transaction currency to inter-center settlement currency
  , sb_cnvdate               varchar2(8)   -- 214 O Conversion date (YYYYMMDD)
  , i_amount                 number(12)    -- 222 M Transaction amount in issuer bank's currency
  , i_cshback                number(12)    -- 234 O Cash back in issuer bank's currency
  , i_fee                    number(10)    -- 246 O Processing fee in issuer bank's currency
  , ibnk_ccy                 varchar2(3)   -- 256 M Issuer bank's currency code
  , i_ccyexp                 number(1)     -- 259 M Number of decimal fractions in issuer bank's currency
  , i_cnvrate                number(14,9)  -- 260 O Conversion rate from sender's processing center currency to issuer bank's currency
  , i_cnvdate                date          -- 274 O Conversion date (YYYYMMDD)
  , abvr_name                varchar2(27)  -- 282 O Merchant name
  , city                     varchar2(15)  -- 309 O Merchant city
  , country                  varchar2(3)   -- 324 O Merchant country code
  , point_code               varchar2(12)  -- 327 O Point of Service Data Code
                                           --       Must be assigned in compliance with the description of the field No 22 according to ISO-8583 specification, edition 1993.
  , mcc_code                 varchar2(4)   -- 339 M Merchant category code
  , terminal                 varchar2(1)   -- 343 O Terminal type (A - ATM, P - POS, N - imprinter, space - use MCC instead to determine terminal type)
  , batch_id                 varchar2(11)  -- 344 O Batch identifier
  , settl_nr                 varchar2(11)  -- 355 O Settlement identifier
  , settl_date               date          -- 366 O Settlement date (YYYYMMDD)
  , acqref_nr                varchar2(23)  -- 374 O Acq Reference number
  , file_id                  varchar2(18)  -- 397 O File identifier
  , ms_number                number(8)     -- 415 - The sequence number of the record within the file
  , file_date                date          -- 423 O File date (YYYYMMDD)
  , source_algorithm         varchar2(1)   -- 431 - Processing algorithm (1 - DOMESTIC, 2 - ECMC, 3 - VISA)
  , err_code                 varchar2(2)   -- 432 - Reserved
  , term_nr                  varchar2(8)   -- 434 O Terminal identifier
  , ecmc_fee                 number(8)     -- 442 - EUROPAY fee
  , tran_info                varchar2(6)   -- 450 O Additional transaction information:
                                           --       1-2  card data reading method
                                           --       3 - cardholder identification method
                                           --       4-6 - CARD_SEQ_NR
                                           --       1-2  mode of cards data reading
                                           --       (if substr(point_code,7,1) in (2,3,4, 8,9) then ->90;
                                           --       if substr(point_code,7,1) =5 then ->05;
                                           --       any other->  01    manual input)
                                           --       mode of cardholder identification - if substr(point_code,8,2) = 13  ->  P    on-line PIN; if  in( 1 , 5 , 6 )+any other ->  S    signature or off-line PIN; any other ->    "
  , pr_amount                number(12)    -- 456 M Transaction amount in acquirer bank s center currency
  , pr_cshback               number(12)    -- 468 O Cash back in acquirer bank s center currency
  , pr_fee                   number(10)    -- 480 O Processing fee in acquirer bank s center currency
  , prnk_ccy                 varchar2(3)   -- 490 M Code of acquirer bank s center currency
  , pr_ccyexp                number(1)     -- 493 M Number of decimal fractions in the currency
  , pr_cnvrate               number(14,9)  -- 494 O Conversion rate from transaction currency to acquirer bank s center currency
  , pr_cnvdate               date          -- 508 - Conversion date (YYYYMMDD)
  , region                   varchar2(1)   -- 516 - VISA region of reporting BIN
  , card_type                varchar2(1)   -- 517 - VISA Card Type
  , proc_class               varchar2(4)   -- 518 - O ECMC Processing Class
  , card_seq_nr              number(3)     -- 522 O Card Sequence No.
  , msg_type                 varchar2(4)   -- 525 - Transaction message type
  , org_msg_type             varchar2(4)   -- 529 - The type of original transaction
  , proc_code                varchar2(2)   -- 533 M Processing code
  , msg_category             varchar2(1)   -- 535 - Single/Dual
  , merchant_code            varchar2(15)  -- 536 O Full merchant code
  , moto_ind                 varchar2(1)   -- 551 O Mail/Telephone or Electronic Commerce Indicator
  , susp_status              varchar2(1)   -- 552 O Suspected status of transaction
  , transact_row             varchar2(11)  -- 553 O RTPS transaction reference (N11)
  , authoriz_row             varchar2(11)  -- 564 O RTPS authorization reference (N11)
  , fld_043                  varchar2(99)  -- 575 O Card acceptor name / location
  , fld_098                  varchar2(25)  -- 674 O Payee  - girocode + account no
                                           --       Only for P2P transactions
                                           --       pos 1-16 Payment identifier assigned by payment initiator
                                           --       pos 17-25 Reserved for internal use
  , fld_102                  varchar2(28)  -- 699 O Account identification 1
  , fld_103                  varchar2(28)  -- 727 O Account identification 2
  , fld_104                  varchar2(100) -- 755 O Transaction description   contains receiver name
                                           --       only P2P
                                           --       pos  1-30 Sender name
                                           --       pos 31-65 Sender address
                                           --       pos 66-90 Sender city
                                           --       pos 91-93 Sender country
                                           --       pos 94-95 Funding source
  , fld_039                  varchar2(3)   -- 855 O Response code   authorization response code
  , fld_sh6                  varchar2(4)   -- 858 O Transaction Fee Rule
  , batch_date               date          -- 862 O Batch date (YYYYMMDD)
  , tr_fee                   number(10)    -- 870 O On-line commission
  , fld_040                  varchar2(3)   -- 880 O Service Code
  , fld_123_1                varchar2(1)   -- 883 O CVC2 result code
  , epi_42_48                varchar2(1)   -- 884 O Electronic Commerce Security Level Indicator/UCAF Status
  , fld_003                  varchar2(6)   -- 885 O Full processing code
  , msc                      number(10)    -- 891 O Merchant Service Charge
  , account_nr               varchar2(35)  -- 901 O Merchant Account Number
  , epi_42_48_full           varchar2(3)   -- 936 O Full Electronic Commerce Security Level Indicator/UCAF Status
  , other_code               varchar2(20)  -- 939 O Departments other_code
  , fld_015                  date          -- 959 O FLD_015 (YYYYMMDD)
  , fld_095                  varchar2(99)  -- 967 O Issuer Reference Data (TLV   Tag 4 ASCII symbols, Length 3 DEC symbols, Value; Sample - 0003002AB1111004XXXX)
  , audit_date               date          -- 1066 O Audit date and time (YYYYMMDDHH24MISS) from FLD_031
  , other_fee1               number(10)    -- 1080 O Another acquirer surcharge 1 from FLD_046
  , other_fee2               number(10)    -- 1090 O Another acquirer surcharge 2 from FLD_046
  , other_fee3               number(10)    -- 1100 O Another acquirer surcharge 3 from FLD_046
  , other_fee4               number(10)    -- 1110 O Another acquirer surcharge 4 from FLD_046
  , other_fee5               number(10)    -- 1120 O Another acquirer surcharge 5 from FLD_046
  , fld_030a                 number(12)    -- 1130 O Original transaction amount in minor currency units
);

type t_mes_fin_add_chip_rec is record(
    mtid                     varchar2(2)   -- 001 M '11'
  , fld_055                  varchar2(999)
);

type t_mes_fin_acq_ref_rec is record(
    mtid                     varchar2(2)   -- 001 M '15'
  , fld_126                  varchar2(4000)
);

type t_file_row_buffer is table of varchar2(4000);

type t_file_rec is record(
    id                  com_api_type_pkg.t_long_id
  , is_incoming         number(1)
  , network_id          number(4)
  , rec_centr           number(2)
  , send_centr          number(2)
  , file_name           varchar2(8)
  , card_id             varchar2(15)
  , file_version        varchar2(4)
  , inst_id             number(4)
  , records_count       number(8)
  , tran_sum            number(14)
  , control_sum         number(14)
  , session_file_id     number(16)
  -- additional fields used for uploading
  , file_line_num       com_api_type_pkg.t_count default 0
  , ms_number           com_api_type_pkg.t_count default 0
  , card_network_id     com_api_type_pkg.t_network_id
  -- for bulk messages update
  , rowid_tab           com_api_type_pkg.t_rowid_tab
  , id_tab              com_api_type_pkg.t_number_tab
  , ms_number_tab       com_api_type_pkg.t_number_tab
  -- for bulk file generation
  , raw_data            com_api_type_pkg.t_raw_tab
  , record_number       com_api_type_pkg.t_integer_tab
);

type t_file_tab is table of t_file_rec index by com_api_type_pkg.t_name; -- index by synthetic key

type t_control_sum_rec is record(
    records_count       number(8)
  , tran_sum            number(14)
  , control_sum         number(14)
);

--- table types

subtype t_mtid                  is tie_fin.mtid                  %type;
subtype t_rec_centr             is tie_fin.rec_centr             %type;
subtype t_send_centr            is tie_fin.send_centr            %type;
subtype t_iss_cmi               is tie_fin.iss_cmi               %type;
subtype t_send_cmi              is tie_fin.send_cmi              %type;
subtype t_settl_cmi             is tie_fin.settl_cmi             %type;
subtype t_acq_bank              is tie_fin.acq_bank              %type;
subtype t_acq_branch            is tie_fin.acq_branch            %type;
subtype t_member                is tie_fin.member                %type;
subtype t_clearing_group        is tie_fin.clearing_group        %type;
subtype t_sender_ica            is tie_fin.sender_ica            %type;
subtype t_receiver_ica          is tie_fin.receiver_ica          %type;
subtype t_merchant              is tie_fin.merchant              %type;
subtype t_batch_nr              is tie_fin.batch_nr              %type;
subtype t_slip_nr               is tie_fin.slip_nr               %type;
subtype t_card                  is tie_fin.card                  %type;
subtype t_exp_date              is tie_fin.exp_date              %type;
subtype t_tran_date_time        is tie_fin.tran_date_time        %type;
subtype t_tran_type             is tie_fin.tran_type             %type;
subtype t_appr_code             is tie_fin.appr_code             %type;
subtype t_appr_src              is tie_fin.appr_src              %type;
subtype t_stan                  is tie_fin.stan                  %type;
subtype t_ref_number            is tie_fin.ref_number            %type;
subtype t_amount                is tie_fin.amount                %type;
subtype t_cash_back             is tie_fin.cash_back             %type;
subtype t_fee                   is tie_fin.fee                   %type;
subtype t_currency              is tie_fin.currency              %type;
subtype t_ccy_exp               is tie_fin.ccy_exp               %type;
subtype t_sb_amount             is tie_fin.sb_amount             %type;
subtype t_sb_cshback            is tie_fin.sb_cshback            %type;
subtype t_sb_fee                is tie_fin.sb_fee                %type;
subtype t_sbnk_ccy              is tie_fin.sbnk_ccy              %type;
subtype t_sb_ccyexp             is tie_fin.sb_ccyexp             %type;
subtype t_sb_cnvrate            is tie_fin.sb_cnvrate            %type;
subtype t_sb_cnvdate            is tie_fin.sb_cnvdate            %type;
subtype t_i_amount              is tie_fin.i_amount              %type;
subtype t_i_cshback             is tie_fin.i_cshback             %type;
subtype t_i_fee                 is tie_fin.i_fee                 %type;
subtype t_ibnk_ccy              is tie_fin.ibnk_ccy              %type;
subtype t_i_ccyexp              is tie_fin.i_ccyexp              %type;
subtype t_i_cnvrate             is tie_fin.i_cnvrate             %type;
subtype t_i_cnvdate             is tie_fin.i_cnvdate             %type;
subtype t_abvr_name             is tie_fin.abvr_name             %type;
subtype t_city                  is tie_fin.city                  %type;
subtype t_country               is tie_fin.country               %type;
subtype t_point_code            is tie_fin.point_code            %type;
subtype t_mcc_code              is tie_fin.mcc_code              %type;
subtype t_terminal              is tie_fin.terminal              %type;
subtype t_batch_id              is tie_fin.batch_id              %type;
subtype t_settl_nr              is tie_fin.settl_nr              %type;
subtype t_settl_date            is tie_fin.settl_date            %type;
subtype t_acqref_nr             is tie_fin.acqref_nr             %type;
subtype t_clr_file_id           is tie_fin.clr_file_id           %type;
subtype t_ms_number             is tie_fin.ms_number             %type;
subtype t_file_date             is tie_fin.file_date             %type;
subtype t_source_algorithm      is tie_fin.source_algorithm      %type;
subtype t_err_code              is tie_fin.err_code              %type;
subtype t_term_nr               is tie_fin.term_nr               %type;
subtype t_ecmc_fee              is tie_fin.ecmc_fee              %type;
subtype t_tran_info             is tie_fin.tran_info             %type;
subtype t_pr_amount             is tie_fin.pr_amount             %type;
subtype t_pr_cshback            is tie_fin.pr_cshback            %type;
subtype t_pr_fee                is tie_fin.pr_fee                %type;
subtype t_prnk_ccy              is tie_fin.prnk_ccy              %type;
subtype t_pr_ccyexp             is tie_fin.pr_ccyexp             %type;
subtype t_pr_cnvrate            is tie_fin.pr_cnvrate            %type;
subtype t_pr_cnvdate            is tie_fin.pr_cnvdate            %type;
subtype t_region                is tie_fin.region                %type;
subtype t_card_type             is tie_fin.card_type             %type;
subtype t_proc_class            is tie_fin.proc_class            %type;
subtype t_card_seq_nr           is tie_fin.card_seq_nr           %type;
subtype t_msg_type              is tie_fin.msg_type              %type;
subtype t_org_msg_type          is tie_fin.org_msg_type          %type;
subtype t_proc_code             is tie_fin.proc_code             %type;
subtype t_msg_category          is tie_fin.msg_category          %type;
subtype t_merchant_code         is tie_fin.merchant_code         %type;
subtype t_moto_ind              is tie_fin.moto_ind              %type;
subtype t_susp_status           is tie_fin.susp_status           %type;
subtype t_transact_row          is tie_fin.transact_row          %type;
subtype t_authoriz_row          is tie_fin.authoriz_row          %type;
subtype t_fld_043               is tie_fin.fld_043               %type;
subtype t_fld_098               is tie_fin.fld_098               %type;
subtype t_fld_102               is tie_fin.fld_102               %type;
subtype t_fld_103               is tie_fin.fld_103               %type;
subtype t_fld_104               is tie_fin.fld_104               %type;
subtype t_fld_039               is tie_fin.fld_039               %type;
subtype t_fld_sh6               is tie_fin.fld_sh6               %type;
subtype t_batch_date            is tie_fin.batch_date            %type;
subtype t_tr_fee                is tie_fin.tr_fee                %type;
subtype t_fld_040               is tie_fin.fld_040               %type;
subtype t_fld_123_1             is tie_fin.fld_123_1             %type;
subtype t_epi_42_48             is tie_fin.epi_42_48             %type;
subtype t_fld_003               is tie_fin.fld_003               %type;
subtype t_msc                   is tie_fin.msc                   %type;
subtype t_account_nr            is tie_fin.account_nr            %type;
subtype t_epi_42_48_full        is tie_fin.epi_42_48_full        %type;
subtype t_other_code            is tie_fin.other_code            %type;
subtype t_fld_015               is tie_fin.fld_015               %type;
subtype t_fld_095               is tie_fin.fld_095               %type;
subtype t_audit_date            is tie_fin.audit_date            %type;
subtype t_other_fee1            is tie_fin.other_fee1            %type;
subtype t_other_fee2            is tie_fin.other_fee2            %type;
subtype t_other_fee3            is tie_fin.other_fee3            %type;
subtype t_other_fee4            is tie_fin.other_fee4            %type;
subtype t_other_fee5            is tie_fin.other_fee5            %type;
subtype t_fld_030a              is tie_fin.fld_030a              %type;
subtype t_fld_055               is tie_fin.fld_055               %type;
subtype t_fld_126               is tie_fin.fld_126               %type;

type t_fin_rec is record(
    row_id                rowid
  , card_network_id       com_api_type_pkg.t_tiny_id
  , card_type_id          com_api_type_pkg.t_tiny_id
  , id                    com_api_type_pkg.t_long_id
  , status                com_api_type_pkg.t_dict_value
  , inst_id               com_api_type_pkg.t_inst_id
  , network_id            com_api_type_pkg.t_tiny_id
  , file_id               com_api_type_pkg.t_long_id
  , is_incoming           com_api_type_pkg.t_boolean
  , is_reversal           com_api_type_pkg.t_boolean
  , is_invalid            com_api_type_pkg.t_boolean
  , is_rejected           com_api_type_pkg.t_boolean
  , dispute_id            com_api_type_pkg.t_long_id
  , impact                com_api_type_pkg.t_sign
  , mtid                  t_mtid
  , rec_centr             t_rec_centr
  , send_centr            t_send_centr
  , iss_cmi               t_iss_cmi
  , send_cmi              t_send_cmi
  , settl_cmi             t_settl_cmi
  , acq_bank              t_acq_bank
  , acq_branch            t_acq_branch
  , member                t_member
  , clearing_group        t_clearing_group
  , sender_ica            t_sender_ica
  , receiver_ica          t_receiver_ica
  , merchant              t_merchant
  , batch_nr              t_batch_nr
  , slip_nr               t_slip_nr
  , card                  t_card
  , exp_date              t_exp_date
  , tran_date_time        t_tran_date_time
  , tran_type             t_tran_type
  , appr_code             t_appr_code
  , appr_src              t_appr_src
  , stan                  t_stan
  , ref_number            t_ref_number
  , amount                t_amount
  , cash_back             t_cash_back
  , fee                   t_fee
  , currency              t_currency
  , ccy_exp               t_ccy_exp
  , sb_amount             t_sb_amount
  , sb_cshback            t_sb_cshback
  , sb_fee                t_sb_fee
  , sbnk_ccy              t_sbnk_ccy
  , sb_ccyexp             t_sb_ccyexp
  , sb_cnvrate            t_sb_cnvrate
  , sb_cnvdate            t_sb_cnvdate
  , i_amount              t_i_amount
  , i_cshback             t_i_cshback
  , i_fee                 t_i_fee
  , ibnk_ccy              t_ibnk_ccy
  , i_ccyexp              t_i_ccyexp
  , i_cnvrate             t_i_cnvrate
  , i_cnvdate             t_i_cnvdate
  , abvr_name             t_abvr_name
  , city                  t_city
  , country               t_country
  , point_code            t_point_code
  , mcc_code              t_mcc_code
  , terminal              t_terminal
  , batch_id              t_batch_id
  , settl_nr              t_settl_nr
  , settl_date            t_settl_date
  , acqref_nr             t_acqref_nr
  , clr_file_id           t_clr_file_id
  , ms_number             t_ms_number
  , file_date             t_file_date
  , source_algorithm      t_source_algorithm
  , err_code              t_err_code
  , term_nr               t_term_nr
  , ecmc_fee              t_ecmc_fee
  , tran_info             t_tran_info
  , pr_amount             t_pr_amount
  , pr_cshback            t_pr_cshback
  , pr_fee                t_pr_fee
  , prnk_ccy              t_prnk_ccy
  , pr_ccyexp             t_pr_ccyexp
  , pr_cnvrate            t_pr_cnvrate
  , pr_cnvdate            t_pr_cnvdate
  , region                t_region
  , card_type             t_card_type
  , proc_class            t_proc_class
  , card_seq_nr           t_card_seq_nr
  , msg_type              t_msg_type
  , org_msg_type          t_org_msg_type
  , proc_code             t_proc_code
  , msg_category          t_msg_category
  , merchant_code         t_merchant_code
  , moto_ind              t_moto_ind
  , susp_status           t_susp_status
  , transact_row          t_transact_row
  , authoriz_row          t_authoriz_row
  , fld_043               t_fld_043
  , fld_098               t_fld_098
  , fld_102               t_fld_102
  , fld_103               t_fld_103
  , fld_104               t_fld_104
  , fld_039               t_fld_039
  , fld_sh6               t_fld_sh6
  , batch_date            t_batch_date
  , tr_fee                t_tr_fee
  , fld_040               t_fld_040
  , fld_123_1             t_fld_123_1
  , epi_42_48             t_epi_42_48
  , fld_003               t_fld_003
  , msc                   t_msc
  , account_nr            t_account_nr
  , epi_42_48_full        t_epi_42_48_full
  , other_code            t_other_code
  , fld_015               t_fld_015
  , fld_095               t_fld_095
  , audit_date            t_audit_date
  , other_fee1            t_other_fee1
  , other_fee2            t_other_fee2
  , other_fee3            t_other_fee3
  , other_fee4            t_other_fee4
  , other_fee5            t_other_fee5
  , fld_030a              t_fld_030a
  , fld_055               t_fld_055
  , fld_126               t_fld_126
);

type t_fin_cur is ref cursor return t_fin_rec;
type t_fin_tab is table of t_fin_rec;

end tie_api_type_pkg;
/
