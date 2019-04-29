create or replace package body tie_prc_incoming_pkg is

-- substring
function s(
    i_str      in varchar2
  , i_pos      in pls_integer
  , i_length   in pls_integer
) return varchar2 is
begin
    return trim(substr(i_str, i_pos, i_length));
end s;

-- number
function n(
    i_str      in varchar2
  , i_pos      in pls_integer
  , i_length   in pls_integer
) return number is
begin
    return to_number(trim(substr(i_str, i_pos, i_length)));
end n;

-- date or time
function d(
    i_str      in varchar2
  , i_pos      in pls_integer
  , i_length   in pls_integer
  , i_format   in varchar2
) return date is
begin
    return to_date(trim(substr(i_str, i_pos, i_length)), i_format);
end d;

-- rate
function r(
    i_str         in varchar2
  , i_pos         in pls_integer
  , i_length      in pls_integer
  , i_precision   in pls_integer default 9
) return number is
begin
    return to_number(trim(substr(i_str, i_pos, i_length)))/power(10, i_precision);
end r;


procedure process_file_header (
    i_header_data         in varchar2
  , i_network_id          in com_api_type_pkg.t_tiny_id
  , i_host_id             in com_api_type_pkg.t_tiny_id
  , i_standard_id         in com_api_type_pkg.t_tiny_id
  , i_dst_inst_id         in com_api_type_pkg.t_inst_id
  , i_session_file_id     in com_api_type_pkg.t_long_id
  , i_file_name           in com_api_type_pkg.t_name
  , o_file               out tie_api_type_pkg.t_file_rec
) is
    l_file_name_wo_ext    com_api_type_pkg.t_name;
begin

    o_file.id:= tie_file_seq.nextval;
    o_file.is_incoming    := com_api_const_pkg.TRUE;
    o_file.network_id     := i_network_id;
    o_file.inst_id        := i_dst_inst_id;
    o_file.session_file_id:= i_session_file_id;
    o_file.rec_centr      := n( i_header_data, 3, 2);
    o_file.send_centr     := n( i_header_data, 5, 2);
    o_file.file_name      := trim(s( i_header_data, 7, 8));
    o_file.card_id        := trim(s( i_header_data, 15, 8));
    o_file.file_version   := s( i_header_data, 23, 4);
    o_file.records_count  := 0;
    o_file.tran_sum       := 0;
    o_file.control_sum    := 0;

    -- check file name
    l_file_name_wo_ext:=
        tie_utl_pkg.cut_file_extension(i_file_name);
    if upper(o_file.file_name) <> upper(l_file_name_wo_ext) then
            com_api_error_pkg.raise_error(
                i_error         => 'TIE_FILE_NAME_NOT_MATCH'
              , i_env_param1  => l_file_name_wo_ext
              , i_env_param2  => o_file.file_name
            );
    end if;

    if o_file.rec_centr <> 0 then
        o_file.inst_id:=
            cmn_api_standard_pkg.find_value_owner(
                i_standard_id       => i_standard_id
              , i_entity_type       => net_api_const_pkg.ENTITY_TYPE_HOST
              , i_object_id         => i_host_id
              , i_param_name        => tie_api_const_pkg.CENTER_CODE
              , i_value_number      => o_file.rec_centr
            );
        if o_file.inst_id is null then
            com_api_error_pkg.raise_error(
                i_error       => 'TIE_CENTER_CODE_NOT_REGISTRED'
              , i_env_param1  => o_file.rec_centr
              , i_env_param2  => i_standard_id
              , i_env_param3  => i_host_id
            );
        end if;
        trc_log_pkg.debug(
            i_text         => 'Receiver institution determined by file header "rec_centr" value as #1'
          , i_env_param1   => o_file.inst_id
          , i_entity_type  => prc_api_const_pkg.ENTITY_TYPE_SESSION_FILE
          , i_object_id    => i_session_file_id
        );
    end if;
end process_file_header;

procedure process_file_trailer(
    i_trailer_data        in varchar2
  , i_control_sum         in tie_api_type_pkg.t_control_sum_rec
  , io_file               in out nocopy tie_api_type_pkg.t_file_rec
) is
begin

    io_file.records_count:= n( i_trailer_data, 15, 8);
    io_file.tran_sum     := case
                                when s(i_trailer_data, 23, 1) = '-' then -1
                                                                    else  1
                            end
                          * n( i_trailer_data, 24, 14);
    io_file.control_sum:= n( i_trailer_data, 38, 14);

    -- checking control sum

    if i_control_sum.records_count != io_file.records_count then
       -- todo raise records count mismatch
       com_api_error_pkg.raise_error(
           i_error       => 'TIE_FILE_REC_CNT_MISMATCH'
         , i_env_param1  => i_control_sum.records_count
         , i_env_param2  => io_file.records_count
       );
    elsif    i_control_sum.tran_sum != io_file.tran_sum
          or i_control_sum.control_sum != io_file.control_sum
    then
       com_api_error_pkg.raise_error(
           i_error       => 'TIE_FILE_AMOUNT_MISMATCH'
         , i_env_param1  => i_control_sum.tran_sum
         , i_env_param2  => io_file.tran_sum
         , i_env_param3  => i_control_sum.control_sum
         , i_env_param4  => io_file.control_sum
       );
       null;
    end if;

    insert into tie_file(
        id
      , is_incoming
      , network_id
      , rec_centr
      , send_centr
      , file_name
      , card_id
      , file_version
      , inst_id
      , records_count
      , tran_sum
      , control_sum
      , session_file_id
    )
    values(
        io_file.id
      , io_file.is_incoming
      , io_file.network_id
      , io_file.rec_centr
      , io_file.send_centr
      , io_file.file_name
      , io_file.card_id
      , io_file.file_version
      , io_file.inst_id
      , io_file.records_count
      , io_file.tran_sum
      , io_file.control_sum
      , io_file.session_file_id
    );

end process_file_trailer;

procedure process_presentment(
    i_buffer                 in tie_api_type_pkg.t_file_row_buffer
  , i_file_type              in com_api_type_pkg.t_dict_value default tie_api_const_pkg.FILE_TYPE_L
  , i_network_id             in com_api_type_pkg.t_tiny_id
  , i_host_id                in com_api_type_pkg.t_tiny_id
  , i_standard_id            in com_api_type_pkg.t_tiny_id
  , i_file_id                in com_api_type_pkg.t_long_id
  , io_control_sum           in out nocopy tie_api_type_pkg.t_control_sum_rec
) is
    l_file_fin_data            tie_api_type_pkg.t_mes_fin_rec;
    l_chip_data                tie_api_type_pkg.t_mes_fin_add_chip_rec;
    l_acq_ref_data             tie_api_type_pkg.t_mes_fin_acq_ref_rec;
    i                          pls_integer;
    function parse_fin_data(
        i_msg                  in varchar2
    ) return tie_api_type_pkg.t_mes_fin_rec is
        l_res                 tie_api_type_pkg.t_mes_fin_rec;
    begin
        l_res:= null;
        l_res.mtid               := s(i_msg,   1,  2);  -- 001 M '10'
        l_res.rec_centr          := n(i_msg,   3,  2);  -- 003 - Receiver center code
        l_res.send_centr         := n(i_msg,   5,  2);  -- 005 - Sender center code
        l_res.iss_cmi            := s(i_msg,   7,  8);  -- 007 O Issuer bank's CMI
        l_res.send_cmi           := s(i_msg,  15,  8);  -- 015 O Acquirer bank's CMI
        l_res.settl_cmi          := s(i_msg,  23,  8);  -- 023 M CMI of settlement bank of the Issuer bank  s center

        -- CMS reads data Send_ICA (Acquiring Bank ICA) in positions 31 - 34
        -- and Rec_ICA (Issuing Bank ICA) in positions 35 - 38.
      if i_file_type = tie_api_const_pkg.FILE_TYPE_W then
        l_res.acq_bank           := n(i_msg,  31,  2);  -- 031 O (W-File only) Acquirer bank
        l_res.acq_branch         := n(i_msg,  33,  3);  -- 033 O (W-File only) Acquirer bank branch
        l_res.member             := n(i_msg,  36,  1);  -- 036 O (W-File only) Acquirer bank member indicator
        l_res.clearing_group     := s(i_msg,  37,  2);  -- 037 O (W-File only) Local clearing group
      elsif i_file_type = tie_api_const_pkg.FILE_TYPE_L then
        l_res.sender_ica         := s(i_msg,  31,  4);  -- 031 O (L-File only) Sender ICA
        l_res.receiver_ica       := s(i_msg,  35,  4);  -- 035 O (L-File only) Receiver ICA
      end if;

        l_res.merchant           := s(i_msg,  39,  7);  -- 039 M Card acceptor - merchant code
                                                        --       (If Length of merchant code>7, than  substr(merchant code,1,7))
        l_res.batch_nr           := s(i_msg,  46,  7);  -- 046 M Batch No. (last 7 symbols from batch_id)
        l_res.slip_nr            := s(i_msg,  53,  7);  -- 053 M Transaction No. (must be unique in one batch)
        l_res.card               := s(i_msg,  60, 19);  -- 060 M Card No.
        l_res.exp_date           := d(i_msg,  79,  4, 'YYMM');   -- 079 M Card expiry date (YYMM)
        l_res.tran_date          := d(i_msg,  83,  8, 'YYYYMMDD');   -- 083 M Transaction date (YYYYMMDD)
        l_res.tran_time          := d(i_msg,  91,  6, 'HH24MISS');   -- 091 M Transaction time (HH24MISS)
        l_res.tran_type          := s(i_msg,  97,  2);  -- 097 M Transaction type
                                                        --       05, 25    purchases    direct / reversal transaction
                                                        --       07, 27    cash advance    direct / reversal transaction
                                                        --       06, 26    returned purchase   direct / reversal transaction
                                                        --       08, 28    deposit - direct / reversal transaction
                                                        --       09, 29    Cachback - direct / reversal transaction
        l_res.appr_code          := s(i_msg,  99,  6);  -- 099 M Authorization code
                                                        --       In the event of   On-line   authorization the value must be equal with that of authorization response;
                                                        --       in the event of   Off-line   authorization the value must either be assigned or left blank,
                                                        --       if the authorization code has not been assigned (e.g., imprinter transactions without authorization).
                                                        --       Field No 38 according to ISO-8583 specification.
        l_res.appr_src           := s(i_msg, 105,  1);  -- 105 M Source of authorization code
                                                        --       Identifier showing the source of the authorization code
                                                        --       Appr_code:
                                                        --         '1' = 'On-line'
                                                        --         '3' = 'Off-line'
                                                        --         '4' = voice authorization
                                                        --         '5' = pre-authorization.
        l_res.stan               := s(i_msg, 106,  6);  -- 106 M System Trace Audit Number
                                                        --       In case of EPI products the value must be equal with that of authorization response (the value does not matter for other products).
                                                        --       The input of appropriate values for clients in line with the VISA-EMEA Protocol is ensured by the interface file entry into TVS and transfer to   back office
                                                        --       with the authorization data entry in   on   position (configuration for card prefixes must hold the 'copy stan' reference).
                                                        --       Field No 11 according to ISO-8583 specification.
        l_res.ref_number         := s(i_msg, 112, 12);  -- 112 M Retrieval Reference Number
        l_res.amount             := n(i_msg, 124, 12);  -- 124 M Transaction amount in minor currency units
        l_res.cash_back          := n(i_msg, 136, 12);  -- 136 M Cash back = 0
        l_res.fee                := n(i_msg, 148, 10);  -- 148 O Processing fee
        l_res.currency           := s(i_msg, 158,  3);  -- 158 M Transaction currency code - symbolic
        l_res.ccy_exp            := n(i_msg, 161,  1);  -- 161 M Number of decimals in transaction currency
        l_res.sb_amount          := n(i_msg, 162, 12);  -- 162 O Transaction amount in inter-center settlement currency
        l_res.sb_cshback         := n(i_msg, 174, 12);  -- 174 O Cash back in inter-center settlement currency
        l_res.sb_fee             := n(i_msg, 186, 10);  -- 186 O Processing fee in inter-center settlement currency
        l_res.sbnk_ccy           := s(i_msg, 196,  3);  -- 196 O Inter-center settlement currency
        l_res.sb_ccyexp          := n(i_msg, 199,  1);  -- 199 O Number of decimal fractions in inter-center settlement currency
        l_res.sb_cnvrate         := r(i_msg, 200, 14);  -- 200 O Conversion rate from transaction currency to inter-center settlement currency
        l_res.sb_cnvdate         := d(i_msg, 214,  8, 'YYYYMMDD');   -- 214 O Conversion date (YYYYMMDD)
        l_res.i_amount           := n(i_msg, 222, 12);  -- 222 M Transaction amount in issuer bank  s currency
        l_res.i_cshback          := n(i_msg, 234, 12);  -- 234 O Cash back in issuer bank  s currency
        l_res.i_fee              := n(i_msg, 246, 10);  -- 246 O Processing fee in issuer bank  s currency
        l_res.ibnk_ccy           := s(i_msg, 256,  3);  -- 256 M Issuer bank  s currency code
        l_res.i_ccyexp           := n(i_msg, 259,  1);  -- 259 M Number of decimal fractions in issuer bank  s currency
        l_res.i_cnvrate          := r(i_msg, 260, 14);  -- 260 O Conversion rate from sender  s processing center currency to issuer bank  s currency
        l_res.i_cnvdate          := d(i_msg, 274,  8, 'YYYYMMDD');   -- 274 O Conversion date (YYYYMMDD)
        l_res.abvr_name          := s(i_msg, 282, 27);  -- 282 O Merchant name
        l_res.city               := s(i_msg, 309, 15);  -- 309 O Merchant city
        l_res.country            := s(i_msg, 324,  3);  -- 324 O Merchant country code
        l_res.point_code         := s(i_msg, 327, 12);  -- 327 O Point of Service Data Code
                                                        --       Must be assigned in compliance with the description of the field No 22 according to ISO-8583 specification, edition 1993.
        l_res.mcc_code           := s(i_msg, 339,  4);  -- 339 M Merchant category code
        l_res.terminal           := s(i_msg, 343,  1);  -- 343 O Terminal type (A    ATM, P    POS, N    imprinter, space - use MCC instead to determine terminal type)
        l_res.batch_id           := n(i_msg, 344, 11);  -- 344 O Batch identifier
        l_res.settl_nr           := s(i_msg, 355, 11);  -- 355 O Settlement identifier
        l_res.settl_date         := d(i_msg, 366,  8, 'YYYYMMDD');   -- 366 O Settlement date (YYYYMMDD)
        l_res.acqref_nr          := s(i_msg, 374, 23);  -- 374 O Acq Reference number
        l_res.file_id            := n(i_msg, 397, 18);  -- 397 O File identifier
        l_res.ms_number          := n(i_msg, 415,  8);  -- 415 - The sequence number of the record within the file
        l_res.file_date          := d(i_msg, 423,  8, 'YYYYMMDD');   -- 423 O File date (YYYYMMDD)
        l_res.source_algorithm   := s(i_msg, 431,  1);  -- 431 - Processing algorithm (1 - DOMESTIC, 2 - ECMC, 3 - VISA)
        l_res.err_code           := s(i_msg, 432,  2);  -- 432 - Reserved
        l_res.term_nr            := s(i_msg, 434,  8);  -- 434 O Terminal identifier
        l_res.ecmc_fee           := n(i_msg, 442,  8);  -- 442 - EUROPAY fee
        l_res.tran_info          := s(i_msg, 450,  6);  -- 450 O Additional transaction information:
                                                        --       1-2    card data reading method
                                                        --       3 - cardholder identification method
                                                        --       4-6 - CARD_SEQ_NR
                                                        --       1-2    mode of cards   data reading
                                                        --       (if substr(point_code,7,1) in (2,3,4, 8,9) then ->  90  ;
                                                        --       if substr(point_code,7,1) =  5   then ->  05  ;
                                                        --       any other->   01      manual input)
                                                        --       mode of cardholder identification - if substr(point_code,8,2) =  13   ->   P      on-line PIN; if  in(  1  ,  5  ,  6  )+any other ->   S      signature or off-line PIN; any other ->      "
        l_res.pr_amount          := n(i_msg, 456, 12);  -- 456 M Transaction amount in acquirer bank  s center currency
        l_res.pr_cshback         := n(i_msg, 468, 12);  -- 468 O Cash back in acquirer bank  s center currency
        l_res.pr_fee             := n(i_msg, 480, 10);  -- 480 O Processing fee in acquirer bank  s center currency
        l_res.prnk_ccy           := s(i_msg, 490,  3);  -- 490 M Code of acquirer bank  s center currency
        l_res.pr_ccyexp          := n(i_msg, 493,  1);  -- 493 M Number of decimal fractions in the currency
        l_res.pr_cnvrate         := r(i_msg, 494, 14);  -- 494 O Conversion rate from transaction currency to acquirer bank  s center currency
        l_res.pr_cnvdate         := d(i_msg, 508,  8, 'YYYYMMDD');   -- 508 - Conversion date (YYYYMMDD)
        l_res.region             := s(i_msg, 516,  1);  -- 516 - VISA region of reporting BIN
        l_res.card_type          := s(i_msg, 517,  1);  -- 517 - VISA Card Type
        l_res.proc_class         := s(i_msg, 518,  4);  -- 518 - O ECMC Processing Class
        l_res.card_seq_nr        := n(i_msg, 522,  3);  -- 522 O Card Sequence No.
        l_res.msg_type           := s(i_msg, 525,  4);  -- 525 - Transaction message type
        l_res.org_msg_type       := s(i_msg, 529,  4);  -- 529 - The type of original transaction
        l_res.proc_code          := s(i_msg, 533,  2);  -- 533 M Processing code
        l_res.msg_category       := s(i_msg, 535,  1);  -- 535 - Single/Dual
        l_res.merchant_code      := s(i_msg, 536, 15);  -- 536 O Full merchant code
        l_res.moto_ind           := s(i_msg, 551,  1);  -- 551 O Mail/Telephone or Electronic Commerce Indicator
        l_res.susp_status        := s(i_msg, 552,  1);  -- 552 O Suspected status of transaction
        l_res.transact_row       := s(i_msg, 553, 11);  -- 553 O RTPS transaction reference (N11)
        l_res.authoriz_row       := s(i_msg, 564, 11);  -- 564 O RTPS authorization reference (N11)
        l_res.fld_043            := s(i_msg, 575, 99);  -- 575 O Card acceptor name / location
        l_res.fld_098            := s(i_msg, 674, 25);  -- 674 O Payee  - girocode + account no
                                                        --       Only for P2P transactions
                                                        --       pos 1-16 Payment identifier assigned by payment initiator
                                                        --       pos 17-25 Reserved for internal use
        l_res.fld_102            := s(i_msg, 699, 28);  -- 699 O Account identification 1
        l_res.fld_103            := s(i_msg, 727, 28);  -- 727 O Account identification 2
        l_res.fld_104            := s(i_msg, 755,100);  -- 755 O Transaction description    contains receiver name
                                                        --       only P2P
                                                        --       pos  1-30 Sender name
                                                        --       pos 31-65 Sender address
                                                        --       pos 66-90 Sender city
                                                        --       pos 91-93 Sender country
                                                        --       pos 94-95 Funding source
        l_res.fld_039            := s(i_msg, 855,  3);  -- 855 O Response code    authorization response code
        l_res.fld_sh6            := s(i_msg, 858,  4);  -- 858 O Transaction Fee Rule
        l_res.batch_date         := d(i_msg, 862,  8, 'YYYYMMDD');   -- 862 O Batch date (YYYYMMDD)
        l_res.tr_fee             := n(i_msg, 870, 10);  -- 870 O On-line commission
        l_res.fld_040            := s(i_msg, 880,  3);  -- 880 O Service Code
        l_res.fld_123_1          := s(i_msg, 883,  1);  -- 883 O CVC2 result code
        l_res.epi_42_48          := s(i_msg, 884,  1);  -- 884 O Electronic Commerce Security Level Indicator/UCAF Status
        l_res.fld_003            := s(i_msg, 885,  6);  -- 885 O Full processing code
        l_res.msc                := n(i_msg, 891, 10);  -- 891 O Merchant Service Charge
        l_res.account_nr         := s(i_msg, 901, 35);  -- 901 O Merchant Account Number
        l_res.epi_42_48_full     := s(i_msg, 936,  3);  -- 936 O Full Electronic Commerce Security Level Indicator/UCAF Status
        l_res.other_code         := s(i_msg, 939, 20);  -- 939 O Departments other_code
        l_res.fld_015            := d(i_msg, 959,  8, 'YYYYMMDD');   -- 959 O FLD_015 (YYYYMMDD)
        l_res.fld_095            := s(i_msg, 967, 99);  -- 967 O Issuer Reference Data (TLV    Tag 4 ASCII symbols, Length 3 DEC symbols, Value; Sample - 0003002AB1111004XXXX)
        l_res.audit_date         := d(i_msg,1066, 14, 'YYYYMMDDHH24MISS');  -- 1066 O Audit date and time (YYYYMMDDHH24MISS) from FLD_031
        l_res.other_fee1         := n(i_msg,1080, 10);  -- 1080 O Another acquirer surcharge 1 from FLD_046
        l_res.other_fee2         := n(i_msg,1090, 10);  -- 1090 O Another acquirer surcharge 2 from FLD_046
        l_res.other_fee3         := n(i_msg,1100, 10);  -- 1100 O Another acquirer surcharge 3 from FLD_046
        l_res.other_fee4         := n(i_msg,1110, 10);  -- 1110 O Another acquirer surcharge 4 from FLD_046
        l_res.other_fee5         := n(i_msg,1120, 10);  -- 1120 O Another acquirer surcharge 5 from FLD_046
        l_res.fld_030a           := n(i_msg,1130, 12);  -- 1130 O Original transaction amount in minor currency units

        return l_res;

    end parse_fin_data;
    function parse_chip_data(
        i_msg                  in varchar2
    ) return tie_api_type_pkg.t_mes_fin_add_chip_rec is
        l_res                  tie_api_type_pkg.t_mes_fin_add_chip_rec;
    begin
        l_res.mtid      := s(i_msg, 1,   2);
        l_res.fld_055   := s(i_msg, 3, 999);

        return l_res;

    end parse_chip_data;
    function parse_acq_ref_data(
        i_msg                  in varchar2
    ) return tie_api_type_pkg.t_mes_fin_acq_ref_rec is
        l_res                  tie_api_type_pkg.t_mes_fin_acq_ref_rec;
    begin
        l_res.mtid      := s(i_msg, 1,   2);
        l_res.fld_126   := s(i_msg, 3,4000);

        return l_res;

    end parse_acq_ref_data;


    procedure calculate_control_sum is
    begin
        tie_utl_pkg.calculate_control_sum(
            i_impact       => tie_api_fin_pkg.get_msg_impact(
                                  i_msg_type      => l_file_fin_data.msg_type
                                , i_proc_code     => l_file_fin_data.proc_code
                              )
          , i_pr_amount    => l_file_fin_data.pr_amount
          , io_tran_sum    => io_control_sum.tran_sum
          , io_control_sum => io_control_sum.control_sum
        );
    end calculate_control_sum;

begin
    i:= i_buffer.first;
    while i is not null loop
        case s(i_buffer(i), 1, 2 )
            when tie_api_const_pkg.MTID_PRESENTMENT then
                l_file_fin_data:=
                    parse_fin_data(
                        i_msg  => i_buffer(i)
                    );
            when tie_api_const_pkg.MTID_PRESENTMENT_CHIP then
                l_chip_data:=
                    parse_chip_data(
                        i_msg  => i_buffer(i)
                    );
            when tie_api_const_pkg.MTID_DETAIL then
                null; -- not supported
            when tie_api_const_pkg.MTID_ACQ_FEFERENCE_DATA then
                l_acq_ref_data:=
                    parse_acq_ref_data(
                        i_msg  => i_buffer(i)
                    );
            when tie_api_const_pkg.MTID_AMEX_DETAIL then
                null; -- not supported
        end case;
        i := i_buffer.next(i);
    end loop;

    -- parcing done. store data
    tie_api_fin_pkg.create_incoming_first_pres (
        i_mes_fin_rec         => l_file_fin_data
      , i_mes_chip_rec        => l_chip_data
      , i_mes_acq_rec         => l_acq_ref_data
      , i_file_id             => i_file_id
      , i_network_id          => i_network_id
      , i_host_id             => i_host_id
      , i_standard_id         => i_standard_id
    );

    calculate_control_sum;

end;

procedure process(
    i_network_id            in com_api_type_pkg.t_tiny_id
  , i_host_inst_id          in com_api_type_pkg.t_inst_id
  , i_dst_inst_id           in com_api_type_pkg.t_inst_id
) is
    LOG_PREFIX        constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process: ';
    l_host_id                  com_api_type_pkg.t_tiny_id;
    l_standard_id              com_api_type_pkg.t_tiny_id;
    l_record_count             com_api_type_pkg.t_long_id := 0;
    l_current_count            com_api_type_pkg.t_long_id := 0;
    l_errors_count             com_api_type_pkg.t_long_id := 0;
    l_buffer                   tie_api_type_pkg.t_file_row_buffer:= tie_api_type_pkg.t_file_row_buffer();
    l_mtid                     varchar2(2);
    l_trailer_processed        com_api_type_pkg.t_boolean:= com_api_const_pkg.FALSE;
    l_file                     tie_api_type_pkg.t_file_rec;
    l_control_sum              tie_api_type_pkg.t_control_sum_rec;
    NO_UTIT_CODE exception;
    pragma exception_init(NO_UTIT_CODE, -6508);
    cursor cu_records_count is
        select count(1)
          from prc_file_raw_data a
             , prc_session_file b
         where b.session_id      = prc_api_session_pkg.get_session_id
           and a.session_file_id = b.id;
begin
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'i_network_id [' || i_network_id
                             || '], i_dst_inst_id [' || i_dst_inst_id || ']'
    );
    prc_api_stat_pkg.log_start;

    l_host_id := net_api_network_pkg.get_default_host(i_network_id => i_network_id, i_host_inst_id => i_host_inst_id);
    l_standard_id := net_api_network_pkg.get_offline_standard(i_host_id => l_host_id);

    open cu_records_count;
    fetch cu_records_count into l_record_count;
    close cu_records_count;

    prc_api_stat_pkg.log_estimation (
        i_estimated_count     => l_record_count
    );

    for p in (
        select s.id              as session_file_id
             , s.file_name
             , s.record_count
          from prc_session_file s
         where session_id = prc_api_session_pkg.get_session_id
         order by id
    ) loop
        trc_log_pkg.debug(
            i_text => 'Processing session_file_id [' || p.session_file_id
                   || '], record_count [' || p.record_count || ']'
        );

        begin

          savepoint incoming_tieto_file_process;

          l_buffer.delete;

          for r in (
              select record_number
                   , raw_data
                   , substr(raw_data, 1, 2)  as mtid
                   , substr(next_data, 1, 2) as next_mtid
                   , count(*) over()         as records_in_file
              from (
                    select record_number
                         , raw_data
                         , lead(raw_data) over (order by record_number) next_data
                      from prc_file_raw_data
                     where session_file_id = p.session_file_id
                   )
              order by record_number
          ) loop

              l_control_sum.records_count:= l_control_sum.records_count + 1;
              l_mtid  := substr(r.raw_data, 1, 2);

              l_current_count:= l_current_count + 1;

              if    l_mtid = tie_api_const_pkg.MTID_HEADER
                 or r.record_number = 1
              then
                  l_control_sum.records_count:= 1;
                  l_control_sum.tran_sum:= 0;
                  l_control_sum.control_sum:= 0;
                  if r.record_number = 1 then
                      process_file_header(
                          i_header_data      => r.raw_data
                        , i_network_id       => i_network_id
                        , i_host_id          => l_host_id
                        , i_standard_id      => l_standard_id
                        , i_dst_inst_id      => i_dst_inst_id
                        , i_session_file_id  => p.session_file_id
                        , i_file_name        => p.file_name
                        , o_file             => l_file
                      );
                  else
                      com_api_error_pkg.raise_error(
                          i_error         => 'TIE_HEADER_MUST_BE_FIRST_IN_FILE'
                        , i_env_param1    => r.record_number
                      );
                  end if;
              elsif l_mtid = tie_api_const_pkg.MTID_TRAILER then
                  process_file_trailer(
                      i_trailer_data     => r.raw_data
                    , io_file            => l_file
                    , i_control_sum      => l_control_sum
                  );
                  l_trailer_processed:= com_api_const_pkg.TRUE;

              elsif l_mtid in ( tie_api_const_pkg.MTID_PRESENTMENT
                              , tie_api_const_pkg.MTID_PRESENTMENT_CHIP
                              , tie_api_const_pkg.MTID_DETAIL
                              , tie_api_const_pkg.MTID_AMEX_DETAIL
                              , tie_api_const_pkg.MTID_ACQ_FEFERENCE_DATA
                              )
              then
                  l_buffer.extend;
                  l_buffer(l_buffer.last ):= r.raw_data;

                  if r.next_mtid in ( tie_api_const_pkg.MTID_PRESENTMENT_CHIP
                                    , tie_api_const_pkg.MTID_DETAIL
                                    , tie_api_const_pkg.MTID_AMEX_DETAIL
                                    , tie_api_const_pkg.MTID_ACQ_FEFERENCE_DATA
                                    )
                  then
                      continue; -- continue to read next message addendum into buffer
                  else
                      -- buffer populated with message. going to proceed
                      process_presentment(
                          i_buffer        => l_buffer
                        , i_file_type     => 'L'
                        , i_network_id    => i_network_id
                        , i_host_id       => l_host_id
                        , i_standard_id   => l_standard_id
                        , i_file_id       => p.session_file_id
                        , io_control_sum  => l_control_sum
                      );
                      l_buffer.delete;
                  end if;
              elsif l_mtid in ( tie_api_const_pkg.MTID_RETRIEVAL_REQUEST
                              , tie_api_const_pkg.MTID_DISPUTE
                              , tie_api_const_pkg.MTID_DISPUTE_CHIP
                              , tie_api_const_pkg.MTID_FEE
                              , tie_api_const_pkg.MTID_DETAIL
                              , tie_api_const_pkg.MTID_AMEX_DETAIL
                              )
              then
                    trc_log_pkg.debug(
                        i_text         => 'MTID #1 is not supported yet'
                      , i_env_param1   => l_mtid
                      , i_entity_type  => prc_api_const_pkg.ENTITY_TYPE_SESSION_FILE
                      , i_object_id    => p.session_file_id
                    );
              else
                  com_api_error_pkg.raise_error(
                      i_error         => 'TIE_UNKNOWN_MESSAGE'
                      , i_env_param1  => l_mtid
                  );
              end if;

              prc_api_stat_pkg.log_current(
                  i_current_count  => l_current_count
                , i_excepted_count => l_errors_count
              );

          end loop;

          if l_trailer_processed = com_api_const_pkg.FALSE then
              com_api_error_pkg.raise_error(
                  i_error         => 'TIE_NO_TRAILER_FOUND'
              );
          end if;

        exception
            when NO_UTIT_CODE then
                trc_log_pkg.warn(
                    i_text       => 'ORA-6508'
                );
                raise;
            when others then
                rollback to savepoint incoming_tieto_file_process;
                trc_log_pkg.error(
                    i_text       => 'Error processing file [#1]'
                  , i_env_param1 => p.file_name
                );
                trc_log_pkg.debug(sqlerrm);
                prc_api_file_pkg.close_file(
                    i_sess_file_id => p.session_file_id
                  , i_status       => prc_api_const_pkg.FILE_STATUS_REJECTED
                  , i_record_count => p.record_count
                );
        end;

    end loop;

    prc_api_stat_pkg.log_end (
        i_excepted_total    => l_errors_count
      , i_processed_total   => l_record_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
exception
    when others then

        prc_api_stat_pkg.log_end(
            i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;

        raise;
end process;

begin
    -- Initialization
    null;
end tie_prc_incoming_pkg;
/
