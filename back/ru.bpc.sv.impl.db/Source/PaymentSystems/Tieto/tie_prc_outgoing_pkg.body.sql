create or replace package body tie_prc_outgoing_pkg is

BULK_LIMIT           constant integer := 1000;
MAX_BATCH_LIMIT      constant integer := 99999999 - 5;

function s(
    i_len              in pls_integer
  , i_string           in varchar2
) return varchar2 is
begin
    return rpad(nvl(i_string, ' '), i_len, ' ');
end;

function n(
    i_len              in pls_integer
  , i_num              in integer
  , i_justify          in char default 'E' -- L - left(fill with spaces) , R - right(fill with spaces), E - right(fill with zeroes)
  , i_default          in integer default null
) return varchar2 is
begin
    if nvl(i_num, i_default) is null then
        return rpad( ' ', i_len, ' ');
    else
        case i_justify
            when 'L' then
                return rpad(nvl(i_num, i_default), i_len, ' ');
            when 'R' then
                return lpad(nvl(i_num, i_default), i_len, ' ');
            when 'E' then
                return lpad(nvl(i_num, i_default), i_len, '0');
        end case;

    end if;
end;

function d(
    i_len              in pls_integer
  , i_date             in date
  , i_format           in varchar2
) return varchar2 is
begin
    if i_date is null then
        return rpad( ' ', i_len, ' ');
    else
        return rpad(to_char(i_date, i_format), i_len, ' ');
    end if;
end;

procedure clear_global_data(
    io_file_rec             in out nocopy tie_api_type_pkg.t_file_rec
) is
begin
    io_file_rec.raw_data.delete;
    io_file_rec.record_number.delete;
end;

procedure flush_file (
    io_file_rec             in out nocopy tie_api_type_pkg.t_file_rec
) is
begin
    prc_api_file_pkg.put_bulk(
        i_sess_file_id  => io_file_rec.session_file_id
      , i_raw_tab       => io_file_rec.raw_data
      , i_num_tab       => io_file_rec.record_number
    );

    clear_global_data(io_file_rec);
end;

procedure put_line (
    i_line                  in com_api_type_pkg.t_raw_data
  , io_file_rec             in out nocopy tie_api_type_pkg.t_file_rec
) is
    i                       binary_integer;
begin
    if i_line is not null then
        i := io_file_rec.record_number.count + 1;

        io_file_rec.raw_data(i) := i_line;
        io_file_rec.record_number(i) := io_file_rec.file_line_num;

        io_file_rec.file_line_num := io_file_rec.file_line_num + 1;

        if i >= BULK_LIMIT then
            flush_file(io_file_rec);
        end if;
    end if;
end;

function get_card_type(
    i_file_type             in com_api_type_pkg.t_name
  , i_card_network_id       in com_api_type_pkg.t_network_id
  , i_card_type_id          in com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_name is
    l_result                com_api_type_pkg.t_name;
begin
    if i_file_type in ('L','W','D') then
        if i_card_network_id = 1002 then
            if i_card_type_id = 1005 then
                l_result:= 'EC';
            else
                l_result:= 'EM';
            end if;
        elsif i_card_network_id = 1003 then
            l_result:= 'VI';
        else
            l_result:= null;
        end if;
    else
        l_result:= null;
    end if;

    return l_result;

end;

procedure generate_file_header(
    o_raw_data             out com_api_type_pkg.t_raw_data
  , io_file_rec             in out nocopy tie_api_type_pkg.t_file_rec
  , i_center_code           in com_api_type_pkg.t_tiny_id
  , i_file_type             in com_api_type_pkg.t_name
  , i_file_name             in com_api_type_pkg.t_name
  , i_version               in com_api_type_pkg.t_name
  , i_network_id            in com_api_type_pkg.t_tiny_id
  , i_inst_id               in com_api_type_pkg.t_inst_id
  , i_card_type_id          in com_api_type_pkg.t_tiny_id
) is
begin
    io_file_rec.id              := tie_file_seq.nextval;
    io_file_rec.is_incoming     := com_api_const_pkg.FALSE;
    io_file_rec.network_id      := i_network_id;
    io_file_rec.rec_centr       := 0;
    io_file_rec.send_centr      := i_center_code;
    io_file_rec.file_name       := substr(tie_utl_pkg.cut_file_extension(i_file_name), 1,8);
    io_file_rec.card_id:=
        get_card_type(
            i_file_type             => i_file_type
          , i_card_network_id       => io_file_rec.card_network_id
          , i_card_type_id          => i_card_type_id
        );
    io_file_rec.file_version    := lpad(replace(i_version, '.', null), 4, 0);
    io_file_rec.inst_id         := i_inst_id;
    io_file_rec.records_count   := 1;
    io_file_rec.tran_sum        := 0;
    io_file_rec.control_sum     := 0;

    o_raw_data:=
        tie_api_const_pkg.MTID_HEADER                  -- Mtid
      ||n(  2, io_file_rec.rec_centr, 'E', 0)          -- Rec_centr
      ||n(  2, io_file_rec.send_centr, 'E', 0)         -- Sender_centr
      ||s(  8, io_file_rec.file_name)                  -- file_name
      ||s(  8, io_file_rec.card_id)                    -- card_id
      ||s(  4, io_file_rec.file_version )              -- file_version
    ;
end;

procedure generate_file_trailer(
    o_raw_data             out com_api_type_pkg.t_raw_data
  , io_file_rec             in out nocopy tie_api_type_pkg.t_file_rec
) is
begin

    io_file_rec.records_count:= io_file_rec.records_count+1;

    o_raw_data:=
        tie_api_const_pkg.MTID_TRAILER                 -- Mtid
      ||n(  2, io_file_rec.rec_centr, 'E', 0)          -- Rec_centr
      ||n(  2, io_file_rec.send_centr, 'E', 0)         -- Sender_centr
      ||s(  8, io_file_rec.file_name)                  -- file_name
      ||n(  8, io_file_rec.records_count, 'R', 0)      -- Number of records in the file
      ||s(  1, case
                   when io_file_rec.tran_sum < 0 then '-'
                                                else '+'
               end
         )                                             -- sign
      ||n( 14, abs(io_file_rec.tran_sum), 'R', 0)      -- Transaction amount
      ||n( 14, io_file_rec.control_sum, 'R', 0)        -- Control amount
    ;

end;

procedure register_file(
    i_file_rec             in tie_api_type_pkg.t_file_rec
) is
begin
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
        i_file_rec.id
      , i_file_rec.is_incoming
      , i_file_rec.network_id
      , i_file_rec.rec_centr
      , i_file_rec.send_centr
      , i_file_rec.file_name
      , i_file_rec.card_id
      , i_file_rec.file_version
      , i_file_rec.inst_id
      , i_file_rec.records_count
      , i_file_rec.tran_sum
      , i_file_rec.control_sum
      , i_file_rec.session_file_id
    );
end;

procedure generate_presentment(
    o_raw_data             out com_api_type_pkg.t_raw_data
  , i_fin_rec               in tie_api_type_pkg.t_fin_rec
  , io_file_rec             in out nocopy tie_api_type_pkg.t_file_rec
  , i_version               in com_api_type_pkg.t_name
  , i_use_ica               in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
) is
begin

    o_raw_data:=
        s(  2, i_fin_rec.mtid )                                  -- Message type
      ||n(  2, i_fin_rec.rec_centr, 'E', 0 )                     -- Receiver center code
      ||n(  2, i_fin_rec.send_centr, 'E', 0 )                    -- Sender center code
      ||s(  8, i_fin_rec.iss_cmi )                               -- Issuer bank's CMI
      ||s(  8, i_fin_rec.send_cmi )                              -- Acquirer bank's CMI
      ||s(  8, i_fin_rec.settl_cmi )                             -- CMI of settlement bank of the Issuer bank's center
      ;
      if i_use_ica = com_api_const_pkg.FALSE then
      o_raw_data:= o_raw_data
      ||n(  2, i_fin_rec.acq_bank, 'E' )                         -- (W-File only ) Acquirer bank
      ||n(  3, i_fin_rec.acq_branch, 'E' )                       -- (W-File only ) Acquirer bank branch
      ||n(  1, i_fin_rec.member, 'E' )                           -- (W-File only ) Acquirer bank member indicator
      ||s(  2, i_fin_rec.clearing_group )                        -- (W-File only ) Local clearing group
      ;
      else
      o_raw_data:= o_raw_data
      ||s(  4, i_fin_rec.sender_ica )                            -- (L-File only ) Sender ICA
      ||s(  4, i_fin_rec.receiver_ica )                          -- (L-File only ) Receiver ICA
      ;
      end if;
      o_raw_data:= o_raw_data
      ||s(  7, i_fin_rec.merchant )                              -- Card acceptor - merchant code
      ||n(  7, i_fin_rec.batch_nr, 'R' )                         -- Batch No. (last 7 symbols from batch_id )
      ||n(  7, i_fin_rec.slip_nr, 'R' )                          -- Transaction No. (must be unique in one batch )
      ||s( 19, i_fin_rec.card )                                  -- Card No.
      ||d(  4, i_fin_rec.exp_date, 'YYMM' )                      -- Card expiry date
      ||d(  8, i_fin_rec.tran_date_time, 'YYYYMMDD' )            -- Transaction date
      ||d(  6, i_fin_rec.tran_date_time, 'HH24MISS' )            -- Transaction time
      ||n(  2, i_fin_rec.tran_type )                             -- Transaction type
      ||n(  6, i_fin_rec.appr_code )                             -- Authorization code
      ||n(  1, i_fin_rec.appr_src )                              -- Source of authorization code
      ||n(  6, i_fin_rec.stan )                                  -- System Trace Audit Number
      ||n( 12, i_fin_rec.ref_number, 'R' )                       -- Retrieval Reference Number
      ||n( 12, i_fin_rec.amount )                                -- Transaction amount in minor currency units
      ||n( 12, i_fin_rec.cash_back )                             -- Cash back = 0
      ||n( 10, i_fin_rec.fee )                                   -- Processing fee
      ||s(  3, i_fin_rec.currency )                              -- Transaction currency code - symbolic
      ||n(  1, i_fin_rec.ccy_exp )                               -- Number of decimals in transaction currency
      ||n( 12, i_fin_rec.sb_amount )                             -- Transaction amount in inter-center settlement currency
      ||n( 12, i_fin_rec.sb_cshback )                            -- Cash back in inter-center settlement currency
      ||n( 10, i_fin_rec.sb_fee )                                -- Processing fee in inter-center settlement currency
      ||s(  3, i_fin_rec.sbnk_ccy )                              -- Inter-center settlement currency
      ||n(  1, i_fin_rec.sb_ccyexp )                             -- Number of decimal fractions in inter-center settlement currency
      ||n( 14, i_fin_rec.sb_cnvrate )                            -- Conversion rate from transaction currency to inter-center settlement currency
      ||d(  8, i_fin_rec.sb_cnvdate, 'YYYYMMDD' )                -- Conversion date
      ||n( 12, i_fin_rec.i_amount )                              -- Transaction amount in issuer bank's currency
      ||n( 12, i_fin_rec.i_cshback )                             -- Cash back in issuer bank's currency
      ||n( 10, i_fin_rec.i_fee )                                 -- Processing fee in issuer bank's currency
      ||s(  3, i_fin_rec.ibnk_ccy )                              -- Issuer bank's currency code
      ||n(  1, i_fin_rec.i_ccyexp )                              -- Number of decimal fractions in issuer bank's currency
      ||n( 14, i_fin_rec.i_cnvrate )                             -- Conversion rate from sender's processing center currency to issuer bank's currency
      ||d(  8, i_fin_rec.i_cnvdate, 'YYYYMMDD' )                 -- Conversion date
      ||s( 27, i_fin_rec.abvr_name )                             -- Merchant name
      ||s( 15, i_fin_rec.city )                                  -- Merchant city
      ||s(  3, i_fin_rec.country )                               -- Merchant country code
      ||n( 12, i_fin_rec.point_code )                            -- Point of Service Data Code
      ||n(  4, i_fin_rec.mcc_code )                              -- Merchant category code
      ||s(  1, i_fin_rec.terminal )                              -- Terminal type (A - ATM, i_fin_rec.P - POS, i_fin_rec.N - imprinter, i_fin_rec.space - use MCC instead to determine terminal type )
      ||n( 11, i_fin_rec.batch_id, 'R' )                         -- Batch identifier
      ||s( 11, i_fin_rec.settl_nr )                              -- Settlement identifier
      ||d(  8, i_fin_rec.settl_date, 'YYYYMMDD' )                -- Settlement date
      ||s( 23, i_fin_rec.acqref_nr )                             -- Acq Reference number
      ||n( 18, i_fin_rec.clr_file_id, 'L' )                      -- File identifier
      ||n(  8, i_fin_rec.ms_number )                             -- The sequence number of the record within the file
      ||d(  8, i_fin_rec.file_date, 'YYYYMMDD' )                 -- File date
      ||s(  1, i_fin_rec.source_algorithm )                      -- Processing algorithm (1 - DOMESTIC, i_fin_rec.2 - ECMC, i_fin_rec.3 - VISA )
      ||s(  2, i_fin_rec.err_code )                              -- Reserved
      ||s(  8, i_fin_rec.term_nr )                               -- Terminal identifier
      ||n(  8, i_fin_rec.ecmc_fee )                              -- EUROPAY fee
      ||s(  6, i_fin_rec.tran_info )                             -- Additional transaction information:
      ||n( 12, i_fin_rec.pr_amount )                             -- Transaction amount in acquirer bank's center currency
      ||n( 12, i_fin_rec.pr_cshback )                            -- Cash back in acquirer bank's center currency
      ||n( 10, i_fin_rec.pr_fee )                                -- Processing fee in acquirer bank's center currency
      ||s(  3, i_fin_rec.prnk_ccy )                              -- Code of acquirer bank's center currency
      ||n(  1, i_fin_rec.pr_ccyexp )                             -- Number of decimal fractions in the currency
      ||n( 14, i_fin_rec.pr_cnvrate )                            -- Conversion rate from transaction currency to acquirer bank's center currency
      ||d(  8, i_fin_rec.pr_cnvdate, 'YYYYMMDD' )                -- Conversion date
      ||s(  1, i_fin_rec.region )                                -- VISA region of reporting BIN
      ||s(  1, i_fin_rec.card_type )                             -- VISA Card Type
      ||s(  4, i_fin_rec.proc_class )                            -- O ECMC Processing Class
      ||n(  3, i_fin_rec.card_seq_nr )                           -- Card Sequence No.
      ||s(  4, i_fin_rec.msg_type )                              -- Transaction message type
      ||s(  4, i_fin_rec.org_msg_type )                          -- The type of original transaction
      ||s(  2, i_fin_rec.proc_code )                             -- Processing code
      ||s(  1, i_fin_rec.msg_category )                          -- Single/Dual
      ||s( 15, i_fin_rec.merchant_code )                         -- Full merchant code
      ;
      if i_version >= '2.02' then
      o_raw_data:= o_raw_data
      ||s(  1, i_fin_rec.moto_ind )                              -- Mail/Telephone or Electronic Commerce Indicator
      ||s(  1, i_fin_rec.susp_status )                           -- Suspected status of transaction
      ||n( 11, i_fin_rec.transact_row, 'R' )                     -- RTPS transaction reference (N11 )
      ||n( 11, i_fin_rec.authoriz_row, 'R' )                     -- RTPS authorization reference (N11 )
      ||s( 99, i_fin_rec.fld_043 )                               -- Card acceptor name / location
      ||s( 25, i_fin_rec.fld_098 )                               -- Payee  - girocode + account no
      ||s( 28, i_fin_rec.fld_102 )                               -- Account identification 1
      ||s( 28, i_fin_rec.fld_103 )                               -- Account identification 2
      ||s(100, i_fin_rec.fld_104 )                               -- Transaction description - contains receiver name
      ||s(  3, i_fin_rec.fld_039 )                               -- Response code - authorization response code
      ;
      end if;
      if i_version >= '3.10' then
      o_raw_data:= o_raw_data
      ||s(  4, i_fin_rec.fld_sh6 )                               -- Transaction Fee Rule
      ;
      end if;
      if i_version >= '3.11' then
      o_raw_data:= o_raw_data
      ||s(  8, i_fin_rec.batch_date )                            -- Batch date
      ;
      end if;
      if i_version >= '3.12' then
      o_raw_data:= o_raw_data
      ||n( 10, i_fin_rec.tr_fee )                                -- On-line commission
      ;
      end if;
      if i_version >= '3.13' then
      o_raw_data:= o_raw_data
      ||s(  3, i_fin_rec.fld_040 )                               -- Service Code
      ||s(  1, i_fin_rec.fld_123_1 )                             -- CVC2 result code
      ||s(  1, i_fin_rec.epi_42_48 )                             -- Electronic Commerce Security Level Indicator/UCAF Status
      ||s(  6, i_fin_rec.fld_003 )                               -- Full processing code
      ||n( 10, i_fin_rec.msc, 'R' )                              -- Merchant Service Charge
      ;
      end if;
      if i_version >= '3.17' then
      o_raw_data:= o_raw_data
      ||s( 35, i_fin_rec.account_nr )                            -- Merchant Account Number
      ||s(  3, i_fin_rec.epi_42_48_full )                        -- Full Electronic Commerce Security Level Indicator/UCAF Status
      ;
      end if;
      if i_version >= '3.19' then
      o_raw_data:= o_raw_data
      ||s( 20, i_fin_rec.other_code )                            -- Departments other_code
      ||d(  8, i_fin_rec.fld_015, 'YYYYMMDD' )                   -- FLD_015
      ;
      end if;
      if i_version >= '3.21' then
      o_raw_data:= o_raw_data
      ||s( 99, i_fin_rec.fld_095 )                               -- Issuer Reference Data (TLV - Tag 4 ASCII symbols, i_fin_rec.Length 3 DEC symbols, i_fin_rec.Value; Sample - 0003002AB1111004XXXX )
      ||d( 14, i_fin_rec.audit_date, 'YYYYMMDDHH24MISS' )        -- Audit date and time (YYYYMMDDHH24MISS ) from FLD_031
      ||n( 10, i_fin_rec.other_fee1, 'R' )                       -- Another acquirer surcharge 1 from FLD_046
      ||n( 10, i_fin_rec.other_fee2, 'R' )                       -- Another acquirer surcharge 2 from FLD_046
      ||n( 10, i_fin_rec.other_fee3, 'R' )                       -- Another acquirer surcharge 3 from FLD_046
      ||n( 10, i_fin_rec.other_fee4, 'R' )                       -- Another acquirer surcharge 4 from FLD_046
      ||n( 10, i_fin_rec.other_fee5, 'R' )                       -- Another acquirer surcharge 5 from FLD_046
      ||n( 12, i_fin_rec.fld_030a )                              -- Original transaction amount in minor currency units
      ;
      end if;

    -- protocol allows to trim spaces at the end of line
    o_raw_data:= trim(o_raw_data);

    io_file_rec.records_count:= io_file_rec.records_count + 1;

    tie_utl_pkg.calculate_control_sum(
        i_impact       => i_fin_rec.impact
      , i_pr_amount    => i_fin_rec.pr_amount
      , io_tran_sum    => io_file_rec.tran_sum
      , io_control_sum => io_file_rec.control_sum
    );
end;

procedure generate_chip_data(
    o_raw_data             out com_api_type_pkg.t_raw_data
  , i_fin_rec               in tie_api_type_pkg.t_fin_rec
  , io_file_rec             in out nocopy tie_api_type_pkg.t_file_rec
  , i_version               in com_api_type_pkg.t_name
) is
begin
    if i_fin_rec.fld_055 is not null then
        o_raw_data:=
            tie_api_const_pkg.MTID_PRESENTMENT_CHIP   -- Mtid
          ||i_fin_rec.fld_055                         -- Integrated Circuit Card (ICC) System-Related Data
        ;
        o_raw_data:= trim(o_raw_data);
        io_file_rec.records_count:= io_file_rec.records_count+1;
    end if;
end;

procedure generate_acq_ref_data(
    o_raw_data             out com_api_type_pkg.t_raw_data
  , i_fin_rec               in tie_api_type_pkg.t_fin_rec
  , io_file_rec             in out nocopy tie_api_type_pkg.t_file_rec
  , i_version               in com_api_type_pkg.t_name
) is
begin
    if i_fin_rec.fld_126 is not null
       and i_version >= '322'
    then
        o_raw_data:=
            tie_api_const_pkg.MTID_ACQ_FEFERENCE_DATA   -- Mtid
          ||i_fin_rec.fld_126                           -- Acquirer reference data
        ;
        o_raw_data:= trim(o_raw_data);
        io_file_rec.records_count:= io_file_rec.records_count+1;
    end if;
end;

procedure process(
    i_network_id          in com_api_type_pkg.t_tiny_id
  , i_inst_id             in com_api_type_pkg.t_inst_id
  , i_start_date          in date default null
  , i_end_date            in date default null
  , i_card_network_id     in com_api_type_pkg.t_tiny_id default null
  , i_file_type           in com_api_type_pkg.t_name default 'D'
) is
    l_file_name               com_api_type_pkg.t_name;
    l_estimated_count         com_api_type_pkg.t_count             := 0;
    l_excepted_count          com_api_type_pkg.t_count             := 0;
    l_processed_count         com_api_type_pkg.t_count             := 0;
    l_host_id                 com_api_type_pkg.t_tiny_id;
    l_standard_id             com_api_type_pkg.t_tiny_id;
    l_standard_version_id     com_api_type_pkg.t_tiny_id;
    l_standard_version_name   com_api_type_pkg.t_name;
    l_center_code             com_api_type_pkg.t_tiny_id;
    l_fin_cur                 tie_api_type_pkg.t_fin_cur;
    l_fin_tab                 tie_api_type_pkg.t_fin_tab;
    i                         pls_integer;
    l_param_tab               com_api_type_pkg.t_param_tab;
    l_raw_data                com_api_type_pkg.t_raw_data;
    l_file_tab                tie_api_type_pkg.t_file_tab;

    l_file_key                com_api_type_pkg.t_name;

    function get_file_key(
        i_fin_rec        in tie_api_type_pkg.t_fin_rec
    ) return com_api_type_pkg.t_name is
        l_result       com_api_type_pkg.t_name;
    begin
        if i_file_type in ('L','W','D') then
            -- these files have to be uploaded by TIETO card type separatelly
            l_result:=
                get_card_type(
                    i_file_type       => i_file_type
                  , i_card_network_id => i_fin_rec.card_network_id
                  , i_card_type_id    => i_fin_rec.card_type_id
                );
        else
            l_result:= 'x';
        end if;
        if not l_file_tab.exists(l_result) then
           l_file_tab(l_result):= null;
           l_file_tab(l_result).file_line_num:= 0;
           l_file_tab(l_result).ms_number:= 0;
           l_file_tab(l_result).card_network_id:= i_fin_rec.card_network_id;
        end if;

        return l_result;

    end;

    procedure register_session_file (
        i_center_code         in com_api_type_pkg.t_medium_id
      , i_card_network_id     in com_api_type_pkg.t_network_id
      , i_card_type_id        in com_api_type_pkg.t_tiny_id
      , o_session_file_id    out com_api_type_pkg.t_long_id
      , o_file_name          out com_api_type_pkg.t_name
    ) is
        function get_file_name return com_api_type_pkg.t_name is
            l_result           com_api_type_pkg.t_name;
            l_card_type        com_api_type_pkg.t_name;
            l_last_file_num    com_api_type_pkg.t_tiny_id;
            function locate_last_D_file(
                i_pattern     in com_api_type_pkg.t_name
            ) return com_api_type_pkg.t_tiny_id is
                l_result com_api_type_pkg.t_tiny_id;
            begin
                select regexp_substr(
                           max(a.file_name)
                         , i_pattern
                         , 1
                         , 1
                         , 'c'
                         , 1
                       )
                into l_result
                from prc_session_file a
                   , prc_session b
                   , prc_file f
                where trunc(a.file_date, 'YEAR') = trunc(get_sysdate(), 'YEAR')
                  and a.file_type = tie_api_const_pkg.FILE_TYPE_CLEARING
                  and f.file_purpose = prc_api_const_pkg.FILE_PURPOSE_OUT
                  and a.session_id = b.id
                  and b.process_id = f.process_id
                  and regexp_like(a.file_name, i_pattern )
                ;

                return l_result;

            end;
        begin
            l_card_type:=
                get_card_type(
                    i_file_type             => i_file_type
                  , i_card_network_id       => i_card_network_id
                  , i_card_type_id          => i_card_type_id
                );
            if i_file_type = 'D' then
                l_result:= 'D'
                         ||lpad(i_center_code, 2, '0')
                         ||to_char(get_sysdate, 'Y')
                         ||'([[:digit:]]{4})'
                         ||'\.'
                         ||l_card_type
                ;
                l_last_file_num:=
                    locate_last_D_file(l_result);
                if l_last_file_num is null then
                    l_result:= 'D'
                             ||lpad(i_center_code, 2, '0')
                             ||to_char(get_sysdate, 'Y')
                             ||lpad('1', 4, '0')
                             ||'.'
                             ||l_card_type
                    ;
                else
                    l_result:= 'D'
                             ||lpad(i_center_code, 2, '0')
                             ||to_char(get_sysdate, 'Y')
                             ||lpad(to_char(l_last_file_num+1), 4, '0')
                             ||'.'
                             ||l_card_type
                    ;
                end if;

            else
                l_result:= null;
            end if;

            return l_result;
        end;
    begin
        l_param_tab.delete;
        prc_api_file_pkg.open_file(
            o_sess_file_id   => o_session_file_id
            , i_file_name    => get_file_name
            , i_file_type    => tie_api_const_pkg.FILE_TYPE_CLEARING
            , i_file_purpose => prc_api_const_pkg.FILE_PURPOSE_OUT
            , io_params      => l_param_tab
        );
        select f.file_name
        into o_file_name
        from prc_session_file f
        where f.id = o_session_file_id;
    end;

    procedure register_uploaded_msg(
        i_rowid        in rowid
      , i_id           in com_api_type_pkg.t_long_id
      , i_ms_number    in tie_api_type_pkg.t_ms_number
      , io_file_rec    in out nocopy tie_api_type_pkg.t_file_rec
    ) is
        i         pls_integer;
    begin
       i:= nvl(io_file_rec.rowid_tab.last, 0) + 1;
       io_file_rec.rowid_tab( i )    := i_rowid;
       io_file_rec.id_tab( i )       := i_id;
       io_file_rec.ms_number_tab( i ):= i_ms_number;
    end;

    procedure mark_uploaded_msg(
        io_file_rec    in out nocopy tie_api_type_pkg.t_file_rec
    ) is
    begin
       if io_file_rec.rowid_tab.first is not null then
           forall i in io_file_rec.rowid_tab.first..io_file_rec.rowid_tab.last
               update tie_fin
               set status = net_api_const_pkg.CLEARING_MSG_STATUS_UPLOADED
                 , is_rejected = com_api_type_pkg.FALSE
                 , ms_number   = io_file_rec.ms_number_tab(i)
                 , file_id     = io_file_rec.session_file_id
               where rowid = io_file_rec.rowid_tab(i)
           ;

           opr_api_clearing_pkg.mark_uploaded (
               i_id_tab            => io_file_rec.id_tab
           );

           io_file_rec.ms_number_tab.delete;
           io_file_rec.rowid_tab.delete;
           io_file_rec.id_tab.delete;
       end if;
    end;

begin
    trc_log_pkg.debug (
        i_text  => 'Tieto KONTS outgoing clearing start'
    );

    savepoint tieto_start_cearing_upload;

    prc_api_stat_pkg.log_start;

    l_host_id := net_api_network_pkg.get_default_host(i_network_id);
    l_standard_id := net_api_network_pkg.get_offline_standard(
        i_host_id       => l_host_id
    );

    l_center_code:=
        cmn_api_standard_pkg.get_number_value(
            i_inst_id       => i_inst_id
          , i_standard_id   => l_standard_id
          , i_object_id     => l_host_id
          , i_entity_type   => net_api_const_pkg.ENTITY_TYPE_HOST
          , i_param_name    => tie_api_const_pkg.CENTER_CODE
          , i_param_tab     => l_param_tab
        );
    l_standard_version_id:=
        cmn_api_standard_pkg.get_current_version(
            i_standard_id => l_standard_id
          , i_entity_type => net_api_const_pkg.ENTITY_TYPE_HOST
          , i_object_id   => l_host_id
          , i_eff_date    => nvl(i_end_date, get_sysdate)
        );
    select v.version_number
    into l_standard_version_name
    from cmn_standard_version v
    where v.id = l_standard_version_id
    ;

    l_estimated_count:=
        tie_api_fin_pkg.estimate_messages_for_upload(
            i_network_id    => i_network_id
          , i_inst_id       => i_inst_id
          , i_start_date    => trunc(i_start_date)
          , i_end_date      => trunc(i_end_date)
        );
    prc_api_stat_pkg.log_estimation(
        i_estimated_count => l_estimated_count
    );

    tie_api_fin_pkg.enum_messages_for_upload(
        i_network_id    => i_network_id
      , i_inst_id       => i_inst_id
      , i_start_date    => trunc(i_start_date)
      , i_end_date      => trunc(i_end_date)
      , o_fin_cur       => l_fin_cur
    );

    loop
        fetch l_fin_cur bulk collect into l_fin_tab;

        i:= l_fin_tab.first;
        while i is not null loop
            l_file_key:=
                get_file_key(
                    i_fin_rec    => l_fin_tab(i)
                );
            if l_file_tab(l_file_key).session_file_id is null then
                register_session_file(
                    i_center_code         => l_center_code
                  , i_card_network_id     => l_file_tab(l_file_key).card_network_id
                  , i_card_type_id        => l_fin_tab(i).card_type_id
                  , o_session_file_id     => l_file_tab(l_file_key).session_file_id
                  , o_file_name           => l_file_name
                );
                l_file_tab(l_file_key).ms_number:= l_file_tab(l_file_key).ms_number + 1;
                generate_file_header(
                    o_raw_data              => l_raw_data
                  , io_file_rec             => l_file_tab(l_file_key)
                  , i_center_code           => l_center_code
                  , i_file_name             => l_file_name
                  , i_file_type             => i_file_type
                  , i_version               => l_standard_version_name
                  , i_network_id            => i_network_id
                  , i_inst_id               => i_inst_id
                  , i_card_type_id          => l_fin_tab(i).card_type_id
                );

                put_line (
                    i_line                  => l_raw_data
                  , io_file_rec             => l_file_tab(l_file_key)
                );
            end if;

            l_file_tab(l_file_key).ms_number:= l_file_tab(l_file_key).ms_number + 1;
            l_fin_tab(i).ms_number:= l_file_tab(l_file_key).ms_number;

            generate_presentment(
                o_raw_data              => l_raw_data
              , i_fin_rec               => l_fin_tab(i)
              , io_file_rec             => l_file_tab(l_file_key)
              , i_version               => l_standard_version_name
            );
            put_line (
                i_line                  => l_raw_data
              , io_file_rec             => l_file_tab(l_file_key)
            );
            register_uploaded_msg(
                i_rowid        => l_fin_tab(i).row_id
              , i_id           => l_fin_tab(i).id
              , i_ms_number    => l_fin_tab(i).ms_number
              , io_file_rec    => l_file_tab(l_file_key)
            );

            generate_chip_data(
                o_raw_data              => l_raw_data
              , i_fin_rec               => l_fin_tab(i)
              , io_file_rec             => l_file_tab(l_file_key)
              , i_version               => l_standard_version_name
            );
            put_line (
                i_line                  => l_raw_data
              , io_file_rec             => l_file_tab(l_file_key)
            );
            generate_acq_ref_data(
                o_raw_data              => l_raw_data
              , i_fin_rec               => l_fin_tab(i)
              , io_file_rec             => l_file_tab(l_file_key)
              , i_version               => l_standard_version_name
            );
            put_line (
                i_line                  => l_raw_data
              , io_file_rec             => l_file_tab(l_file_key)
            );

            i:= l_fin_tab.next(i);
        end loop;

        l_processed_count := l_processed_count + l_fin_tab.count;

        prc_api_stat_pkg.log_current (
            i_current_count     => l_processed_count
          , i_excepted_count    => l_excepted_count
        );

        exit when l_fin_cur%notfound;
    end loop;
    close l_fin_cur;

    l_file_key:= l_file_tab.first;
    while l_file_key is not null loop

        l_file_tab(l_file_key).ms_number:= l_file_tab(l_file_key).ms_number + 1;
        generate_file_trailer(
            o_raw_data              => l_raw_data
          , io_file_rec             => l_file_tab(l_file_key)
        );
        put_line (
            i_line                  => l_raw_data
          , io_file_rec             => l_file_tab(l_file_key)
        );

        register_file(
            i_file_rec              => l_file_tab(l_file_key)
        );

        flush_file(
            io_file_rec             => l_file_tab(l_file_key)
        );

        mark_uploaded_msg(
            io_file_rec             => l_file_tab(l_file_key)
        );
        l_file_key := l_file_tab.next(l_file_key);
    end loop;

    prc_api_stat_pkg.log_end (
        i_excepted_total    => l_excepted_count
      , i_processed_total   => l_processed_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug (
        i_text  => 'Tieto KONTS outgoing clearing finished successfully'
    );

exception
    when others then
        rollback to savepoint tieto_start_cearing_upload;
        if l_fin_cur%isopen then
            close l_fin_cur;
        end if;

        l_file_key:= l_file_tab.first;
        while l_file_key is not null loop
            clear_global_data(
                io_file_rec             => l_file_tab(l_file_key)
            );
            l_file_key := l_file_tab.next(l_file_key);
        end loop;

        prc_api_stat_pkg.log_end(
            i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        trc_log_pkg.error (
            i_text          => sqlerrm
        );

        raise;

end;

begin
    -- Initialization
    null;
end tie_prc_outgoing_pkg;
/
