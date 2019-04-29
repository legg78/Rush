create or replace package body cst_itmx_prc_outgoing_pkg as
/*********************************************************
 *  ITMX outgoing files API  <br />
 *  Created by Zakharov M.(m.zakharov@bpcbt.com)  at 17.12.2018 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: cst_itmx_api_incoming_pkg <br />
 *  @headcom
 **********************************************************/

BULK_LIMIT       constant integer  := 1000;
BATCH_REC_LIMIT  constant integer  := 950;   -- max number of batch records

g_default_charset         com_api_type_pkg.t_oracle_name := cst_itmx_api_const_pkg.g_default_charset;
g_charset                 com_api_type_pkg.t_oracle_name := cst_itmx_api_const_pkg.g_default_charset;
g_adjust_charset          com_api_type_pkg.t_boolean     := case when g_charset != g_default_charset then com_api_const_pkg.TRUE else com_api_const_pkg.FALSE end;

function convert_data(
    i_data            in com_api_type_pkg.t_text
) return com_api_type_pkg.t_text is
begin
    if g_adjust_charset = com_api_const_pkg.TRUE then
        return convert(i_data, g_charset, g_default_charset);
    else
        return i_data;
    end if;
end;

function get_next_batch_number (
    i_batch_number           in com_api_type_pkg.t_tag
    , i_proc_date            in date
    , i_batch_number_shift   in com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_tag is
    l_batch_number              com_api_type_pkg.t_tag;
begin
    if i_batch_number is not null then
        l_batch_number := i_batch_number + 1;
    else
        select nvl(max(to_number(batch_number)), nvl(i_batch_number_shift,0)) + 1
          into l_batch_number
          from cst_itmx_batch
         where trunc(proc_date) = i_proc_date;
    end if;
    return l_batch_number;
end;

procedure init_batch (
    io_batch                 in out cst_itmx_api_type_pkg.t_itmx_batch_rec
    , i_session_file_id      in com_api_type_pkg.t_long_id
    , i_file_proc_bin        in varchar2
    , i_batch_number_shift   in com_api_type_pkg.t_short_id
) is
begin
    io_batch.id              := com_api_id_pkg.get_id(cst_itmx_batch_seq.nextval);
    io_batch.file_id         := i_session_file_id;
    io_batch.proc_bin        := i_file_proc_bin;
    io_batch.proc_date       := trunc(com_api_sttl_day_pkg.get_sysdate);
    io_batch.batch_number    := get_next_batch_number(io_batch.batch_number, io_batch.proc_date, i_batch_number_shift);
    io_batch.center_batch_id := mod(io_batch.id, 100000000);
    io_batch.monetary_total  := 0;
    io_batch.tcr_total       := 0;
    io_batch.trans_total     := 0;
    io_batch.src_amount      := 0;
    io_batch.dst_amount      := 0;
end;

procedure process_file_header(
    i_network_id             in com_api_type_pkg.t_tiny_id
    , i_proc_bin             in com_api_type_pkg.t_dict_value
    , i_inst_id              in com_api_type_pkg.t_inst_id
    , i_standard_id          in com_api_type_pkg.t_inst_id
    , i_host_id              in com_api_type_pkg.t_tiny_id
    , i_test_option          in varchar2 default null
    , i_session_file_id      in com_api_type_pkg.t_long_id
    , o_file                 out cst_itmx_api_type_pkg.t_itmx_file_rec
    , io_batch               in out cst_itmx_api_type_pkg.t_itmx_batch_rec
) is
    l_line                   com_api_type_pkg.t_text;
    l_param_tab              com_api_type_pkg.t_param_tab;
    l_batch_number_shift     com_api_type_pkg.t_short_id;
begin
    l_line := '90';

    -- get security code
    rul_api_param_pkg.set_param(
        i_name           => 'ACQ_PROC_BIN'
      , i_value          => i_proc_bin
      , io_params        => l_param_tab
    );
    cmn_api_standard_pkg.get_param_value(
        i_inst_id        => i_inst_id
        , i_standard_id  => i_standard_id
        , i_object_id    => i_host_id
        , i_entity_type  => net_api_const_pkg.ENTITY_TYPE_HOST
        , i_param_name   => cst_itmx_api_const_pkg.ITMX_SECURITY_CODE
        , o_param_value  => o_file.security_code
        , i_param_tab    => l_param_tab
    );

    o_file.id              := com_api_id_pkg.get_id(cst_itmx_file_seq.nextval);

    o_file.session_file_id := i_session_file_id;
    o_file.is_incoming     := com_api_type_pkg.FALSE;
    o_file.network_id      := i_network_id;

    o_file.proc_date       := trunc(com_api_sttl_day_pkg.get_sysdate);
    o_file.sttl_date       := null;
    o_file.release_number  := null;
    o_file.test_option     := i_test_option;

    cmn_api_standard_pkg.get_param_value(
        i_inst_id      => i_inst_id
      , i_standard_id  => i_standard_id
      , i_object_id    => i_host_id
      , i_entity_type  => net_api_const_pkg.ENTITY_TYPE_HOST
      , i_param_name   => cst_itmx_api_const_pkg.ITMX_ACQ_PROC_BIN_HEADER
      , o_param_value  => o_file.proc_bin
      , i_param_tab    => l_param_tab
    );

    o_file.proc_bin := nvl(o_file.proc_bin, i_proc_bin);

    select nvl(max(to_number(itmx_file_id)), 0) + 1
      into o_file.itmx_file_id
      from cst_itmx_file
     where is_incoming = com_api_type_pkg.FALSE
       and proc_bin    = o_file.proc_bin
       and proc_date   = o_file.proc_date;

    o_file.trans_total    := 0;
    o_file.batch_total    := 0;
    o_file.tcr_total      := 0;
    o_file.monetary_total := 0;
    o_file.src_amount     := 0;
    o_file.dst_amount     := 0;
    o_file.inst_id        := i_inst_id;

    cmn_api_standard_pkg.get_param_value(
        i_inst_id      => i_inst_id
      , i_standard_id  => i_standard_id
      , i_object_id    => i_host_id
      , i_entity_type  => net_api_const_pkg.ENTITY_TYPE_HOST
      , i_param_name   => cst_itmx_api_const_pkg.ITMX_BATCH_NUMBER_SHIFT
      , o_param_value  => l_batch_number_shift
      , i_param_tab    => l_param_tab
    );

    init_batch (
        io_batch               => io_batch
        , i_session_file_id    => o_file.id
        , i_file_proc_bin      => o_file.proc_bin
        , i_batch_number_shift => l_batch_number_shift
    );

    l_line := l_line || rpad(' ', 2);
    l_line := l_line || rpad('0', 6, '0');  -- BIN for OTF file
    l_line := l_line || rpad('0', 5, '0');
    l_line := l_line || rpad(' ', 6);
    l_line := l_line || rpad('0', 5, '0');
    l_line := l_line || rpad(' ', 14);
    l_line := l_line || lpad(io_batch.batch_number, 6, '0');
    l_line := l_line || 'LOCAL-SWITCHING-DATA';
    l_line := l_line || rpad(' ', 104);

    if l_line is not null then
        prc_api_file_pkg.put_line(
            i_raw_data      => convert_data(i_data => l_line)
          , i_sess_file_id  => i_session_file_id
        );
    end if;

end;

procedure process_batch_trailer (
    io_batch                 in out cst_itmx_api_type_pkg.t_itmx_batch_rec
    , i_network_id           in com_api_type_pkg.t_tiny_id
    , i_host_id              in com_api_type_pkg.t_tiny_id
    , i_inst_id              in com_api_type_pkg.t_inst_id
    , i_standard_id          in com_api_type_pkg.t_inst_id
    , i_session_file_id      in com_api_type_pkg.t_long_id
) is
    l_line                   com_api_type_pkg.t_text;
    l_param_tab                 com_api_type_pkg.t_param_tab;
begin

    io_batch.tcr_total      := io_batch.tcr_total + 1;
    io_batch.trans_total    := io_batch.trans_total + 1;

    l_line := l_line || '91';
    l_line := l_line || lpad(' ', 2);
    l_line := l_line || '0';  -- Trailer Code
    l_line := l_line || '0';  -- Trailer Sequence No.
    l_line := l_line || lpad('0', 6, '0'); -- BIN
    l_line := l_line || lpad('0', 5, '0'); -- to_char(com_api_sttl_day_pkg.get_sysdate, 'YYDDD');
    l_line := l_line || lpad(' ', 27);
    l_line := l_line || lpad(io_batch.batch_number, 6, '0');  -- Batch Number
    l_line := l_line || lpad(nvl(io_batch.tcr_total, '0'), 12, '0');
    l_line := l_line || lpad(' ', 14);
    l_line := l_line || lpad(nvl(io_batch.trans_total, '0'), 9, '0');
    l_line := l_line || lpad(' ', 18);
    l_line := l_line || lpad(nvl(io_batch.src_amount, '0'), 15, '0');
    l_line := l_line || lpad(' ', 52);

    if l_line is not null then
        prc_api_file_pkg.put_line(
            i_raw_data      => convert_data(i_data => l_line)
          , i_sess_file_id  => i_session_file_id
        );
    end if;

    insert into cst_itmx_batch(
        id
      , file_id
      , proc_bin
      , proc_date
      , batch_number
      , center_batch_id
      , monetary_total
      , tcr_total
      , trans_total
      , src_amount
      , dst_amount
    ) values (
        io_batch.id
      , io_batch.file_id
      , io_batch.proc_bin
      , io_batch.proc_date
      , io_batch.batch_number
      , io_batch.center_batch_id
      , io_batch.monetary_total
      , io_batch.tcr_total
      , io_batch.trans_total
      , io_batch.src_amount
      , io_batch.dst_amount
    );

end;

procedure process_file_trailer (
    io_file                  in out cst_itmx_api_type_pkg.t_itmx_file_rec
    , i_network_id           in com_api_type_pkg.t_tiny_id
    , i_host_id              in com_api_type_pkg.t_tiny_id
    , i_inst_id              in com_api_type_pkg.t_inst_id
    , i_standard_id          in com_api_type_pkg.t_inst_id
    , i_session_file_id      in com_api_type_pkg.t_long_id
) is
    l_line                   com_api_type_pkg.t_text;
    l_param_tab              com_api_type_pkg.t_param_tab;
begin

    io_file.tcr_total      := io_file.tcr_total + 1;
    io_file.trans_total    := io_file.trans_total + 1;

    l_line := l_line || '92';
    l_line := l_line || lpad(' ', 2);
    l_line := l_line || '0';  -- Trailer Code
    l_line := l_line || '0';  -- Trailer Sequence No.
    l_line := l_line || lpad('0', 6, '0'); -- BIN
    l_line := l_line || lpad('0', 5, '0'); -- to_char(com_api_sttl_day_pkg.get_sysdate, 'YYDDD');
    l_line := l_line || lpad(' ', 27);
    l_line := l_line || lpad(nvl(io_file.batch_total, '0'), 6, '0');
    l_line := l_line || lpad(nvl(io_file.tcr_total, '0'), 12, '0');
    l_line := l_line || rpad(' ', 14);
    l_line := l_line || lpad(nvl(io_file.trans_total, '0'), 9, '0');
    l_line := l_line || lpad(' ', 18);
    l_line := l_line || lpad(nvl(io_file.src_amount, '0'), 15, '0');
    l_line := l_line || lpad(' ', 52);

    if l_line is not null then
        prc_api_file_pkg.put_line(
            i_raw_data      => convert_data(i_data => l_line)
          , i_sess_file_id  => i_session_file_id
        );
    end if;

    insert into cst_itmx_file (
        id
      , is_incoming
      , network_id
      , proc_bin
      , proc_date
      , sttl_date
      , release_number
      , test_option
      , security_code
      , itmx_file_id
      , trans_total
      , batch_total
      , tcr_total
      , monetary_total
      , src_amount
      , dst_amount
      , inst_id
      , session_file_id
    ) values (
        io_file.id
      , io_file.is_incoming
      , io_file.network_id
      , io_file.proc_bin
      , io_file.proc_date
      , io_file.sttl_date
      , io_file.release_number
      , io_file.test_option
      , io_file.security_code
      , io_file.itmx_file_id
      , io_file.trans_total
      , io_file.batch_total
      , io_file.tcr_total
      , io_file.monetary_total
      , io_file.src_amount
      , io_file.dst_amount
      , io_file.inst_id
      , io_file.session_file_id
   );

end;

procedure process_draft (
    i_fin_message            in cst_itmx_api_type_pkg.t_itmx_fin_mes_fraud_rec
    , i_network_id           in com_api_type_pkg.t_tiny_id
    , i_host_id              in com_api_type_pkg.t_tiny_id
    , i_inst_id              in com_api_type_pkg.t_inst_id
    , i_standard_id          in com_api_type_pkg.t_inst_id
    , i_session_file_id      in com_api_type_pkg.t_long_id
    , io_batch               in out cst_itmx_api_type_pkg.t_itmx_batch_rec
    , i_create_disp_case     in com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
) is
    l_line                   com_api_type_pkg.t_text;
    l_param_tab              com_api_type_pkg.t_param_tab;
    l_oper_currency_exponent com_api_type_pkg.t_tiny_id;
    l_operation_date         date;
    
    l_seqnum                 com_api_type_pkg.t_seqnum;
    l_reason_code            com_api_type_pkg.t_byte_char;
begin

    l_oper_currency_exponent := com_api_currency_pkg.get_currency_exponent(i_fin_message.oper_currency);
    l_operation_date         := i_fin_message.oper_date;

    --------------------------- TCR0 ------------------------------------
    l_line := null;
    l_line := l_line || i_fin_message.trans_code;
    l_line := l_line || lpad(' ',2);
    l_line := l_line || '0';
    l_line := l_line || '0';  -- Detail Sequence Number

    l_line := l_line || rpad(nvl(i_fin_message.card_number, '0'), 19);
    l_line := l_line || nvl(i_fin_message.floor_limit_ind, ' ');
    l_line := l_line || ' ';
    l_line := l_line || ' ';

    l_line := l_line || rpad(i_fin_message.arn, 23, '0');
    l_line := l_line || lpad(i_fin_message.acq_business_id, 8, '0');

    l_line := l_line || nvl(to_char(l_operation_date, 'MMDD'), '0000');

    -- if currency exponent equal to zero then append two zeros in accordance with VISA rules
    l_line := l_line || case when l_oper_currency_exponent = 0
                             then lpad(i_fin_message.oper_amount, 10, '0') || '00'
                             else lpad(i_fin_message.oper_amount, 12, '0')
                        end;
    l_line := l_line || lpad(' ',3);
    -- if currency exponent equal to zero then append two zeros in accordance with VISA rules
    l_line := l_line || case when l_oper_currency_exponent = 0
                             then lpad(i_fin_message.oper_amount, 10, '0') || '00'
                             else lpad(i_fin_message.oper_amount, 12, '0')
                        end;
    l_line := l_line || lpad(nvl(i_fin_message.oper_currency, ' '), 3);

    l_line := l_line || rpad(nvl(i_fin_message.merchant_name, ' '), 25);
    l_line := l_line || rpad(nvl(ltrim(i_fin_message.merchant_city), ' '), 13);
    l_line := l_line || rpad(nvl(com_api_country_pkg.get_country_name(i_fin_message.merchant_country, com_api_type_pkg.FALSE), ' '), 3);
    l_line := l_line || rpad(nvl(i_fin_message.mcc, ' '), 4);                  -- Merchant Category Code
    l_line := l_line || lpad(nvl(i_fin_message.merchant_postal_code, '0'), 5, '0'); -- Merchant ZIP Code
    l_line := l_line || lpad(nvl(i_fin_message.merchant_region, '0'), 3, '0');      -- Merchant State/Province Code

    l_line := l_line || ' ';
    l_line := l_line || ' ';
    l_line := l_line || '000';

    l_line := l_line || nvl(i_fin_message.settlement_flag, ' ');
    l_line := l_line || ' ';
    l_line := l_line || rpad(nvl(i_fin_message.auth_code, ' '), 6);

    l_line := l_line || nvl(i_fin_message.pos_terminal_cap, ' ');  -- EDC Terminal Capability
    l_line := l_line || ' ';
    l_line := l_line || nvl(i_fin_message.crdh_id_method, ' ');
    l_line := l_line || ' ';
    l_line := l_line || rpad(nvl(i_fin_message.pos_entry_mode, ' '), 2);

    l_line := l_line || i_fin_message.central_proc_date;
    l_line := l_line || ' ';

    if l_line is not null then
        prc_api_file_pkg.put_line(
            i_raw_data      => convert_data(i_data => l_line)
          , i_sess_file_id  => i_session_file_id
        );
        io_batch.tcr_total := io_batch.tcr_total + 1;
    end if;

    --------------------------- TCR1 ------------------------------------
    l_line := null;
    l_line := l_line || i_fin_message.trans_code;
    l_line := l_line || lpad(' ',2);
    l_line := l_line || '0';
    l_line := l_line || '1';  -- Detail Sequence Number

    l_line := l_line || lpad(nvl(i_fin_message.iss_workst_bin, ' '), 6);
    l_line := l_line || lpad(nvl(i_fin_message.acq_workst_bin, ' '), 6);

    l_line := l_line || lpad(nvl(i_fin_message.chargeback_ref_num, '0'), 6, '0');
    l_line := l_line || ' ';
    l_line := l_line || com_api_type_pkg.pad_char(i_fin_message.member_msg_text, 50, 50);

    l_line := l_line || lpad(nvl(i_fin_message.spec_cond_ind, ' '), 2);
    l_line := l_line || lpad(nvl(i_fin_message.fee_program_ind, ' '), 3);
    l_line := l_line || nvl(i_fin_message.issuer_charge, ' ');

    l_line := l_line || ' ';
    l_line := l_line || com_api_type_pkg.pad_char(i_fin_message.merchant_number, 15, 15);
    l_line := l_line || com_api_type_pkg.pad_char(i_fin_message.terminal_number, 8, 8);

    l_line := l_line || '000000000000';

    l_line := l_line || nvl(i_fin_message.electr_comm_ind, ' ');

    l_line := l_line || lpad(' ',9);

    l_line := l_line || nvl(i_fin_message.service_development, '0');

    l_line := l_line || lpad(' ',3);

    l_line := l_line || nvl(i_fin_message.account_selection, ' ');

    l_line := l_line || lpad(' ',36);

    l_line := l_line || nvl(i_fin_message.chip_cond_code, ' ');
    l_line := l_line || nvl(i_fin_message.pos_environment, ' ');

    if l_line is not null then
        prc_api_file_pkg.put_line(
            i_raw_data      => convert_data(i_data => l_line)
          , i_sess_file_id  => i_session_file_id
        );
        io_batch.tcr_total := io_batch.tcr_total + 1;
    end if;

    --------------------------- TCR5 ------------------------------------

    l_line := null;
    l_line := l_line || i_fin_message.trans_code;
    l_line := l_line || lpad(' ', 2);
    l_line := l_line || '0';
    l_line := l_line || '5';

    l_line := l_line || lpad(' ', 15);

    -- if currency exponent equal to zero then append two zeros in accordance with VISA rules
    if com_api_currency_pkg.get_currency_exponent(nvl(i_fin_message.auth_currency, i_fin_message.oper_currency)) = 0 then
        l_line := l_line || lpad(nvl(nvl(i_fin_message.auth_amount, i_fin_message.oper_amount), '0'), 10, '0') || '00';
    else
        l_line := l_line || lpad(nvl(nvl(i_fin_message.auth_amount, i_fin_message.oper_amount), '0'), 12, '0');
    end if;

    l_line := l_line || rpad(nvl(nvl(i_fin_message.auth_currency, i_fin_message.oper_currency), ' '), 3);

    l_line := l_line || rpad(nvl(i_fin_message.auth_resp_code, ' '), 2);

    l_line := l_line || lpad(' ', 13);

    -- if currency exponent equal to zero then append two zeros in accordance with VISA rules
    if com_api_currency_pkg.get_currency_exponent(nvl(i_fin_message.auth_currency, i_fin_message.oper_currency)) = 0 then
        l_line := l_line || lpad(nvl(nvl(i_fin_message.auth_amount, i_fin_message.oper_amount), '0'), 10, '0') || '00'; -- total authorized amount
    else
        l_line := l_line || lpad(nvl(nvl(i_fin_message.auth_amount, i_fin_message.oper_amount), '0'), 12, '0');         -- total authorized amount
    end if;

    l_line := l_line || 'N';                                                    -- information indicator
    l_line := l_line || lpad(' ', 14);                                          -- merchant tel. number
    l_line := l_line || ' ';                                                    -- additional data indicator
    l_line := l_line || lpad(' ', 2);                                           -- merchant volume indicator

    l_line := l_line || lpad(' ', 2);                                           -- Electronic Commerce Goods Indicator

    l_line := l_line || lpad(' ', 10);

    l_line := l_line || lpad('0', 15, '0');                                     -- Interchange Fee Amount
    l_line := l_line || ' ';                                                    -- Interchange Fee Sign
    
    l_line := l_line || lpad(' ', 60);

    l_line := l_line || nvl(i_fin_message.cvv2_result_code, ' ');               -- CVV2 result code

    if l_line is not null then
        prc_api_file_pkg.put_line(
            i_raw_data      => convert_data(i_data => l_line)
          , i_sess_file_id  => i_session_file_id
        );
        io_batch.tcr_total := io_batch.tcr_total + 1;
    end if;

    --------------------------- TCR7 ------------------------------------
    l_line := null;
    l_line := l_line || i_fin_message.trans_code;
    l_line := l_line || lpad(' ', 2);
    l_line := l_line || '0';
    l_line := l_line || '7';

    l_line := l_line || lpad(nvl(i_fin_message.transaction_type, '0'), 2, '0');
    l_line := l_line || lpad(nvl(i_fin_message.card_seq_number, '0'), 3, '0');
    l_line := l_line || nvl(to_char(l_operation_date, 'YYMMDD'), '      ');
    l_line := l_line || rpad(nvl(i_fin_message.terminal_profile, ' '), 6);
    l_line := l_line || lpad(coalesce(i_fin_message.terminal_country, i_fin_message.merchant_country, '0'), 3, '0');
    l_line := l_line || rpad(' ', 8);
    l_line := l_line || rpad(nvl(i_fin_message.unpredict_number, ' '), 8);
    l_line := l_line || rpad(nvl(i_fin_message.appl_trans_counter, ' '), 4);
    l_line := l_line || rpad(nvl(i_fin_message.appl_interch_profile, ' '), 4);
    l_line := l_line || rpad(nvl(i_fin_message.cryptogram, ' '), 16);
    l_line := l_line || rpad(nvl(substr(i_fin_message.issuer_appl_data, 3, 2), ' '), 2);    -- byte 2
    l_line := l_line || rpad(nvl(i_fin_message.cryptogram_version, ' '), 2);                -- byte 3
    l_line := l_line || lpad(' ', 10);
    l_line := l_line || rpad(nvl(i_fin_message.card_verif_result, ' '), 8);                 -- byte 4-7
    l_line := l_line || lpad(nvl(i_fin_message.cryptogram_amount, '0'), 12, '0');
    l_line := l_line || rpad(nvl(substr(i_fin_message.issuer_appl_data, 15, 2), ' '), 2);   -- byte 8
    l_line := l_line || rpad(nvl(substr(i_fin_message.issuer_appl_data, 17, 16), ' '), 16); -- bytes 9-16
    l_line := l_line || rpad(nvl(substr(i_fin_message.issuer_appl_data, 1, 2), ' '), 2);    -- byte 1
    l_line := l_line || rpad(nvl(substr(i_fin_message.issuer_appl_data, 33, 2), ' '), 2);   -- byte 17
    l_line := l_line || rpad(nvl(substr(i_fin_message.issuer_appl_data, 35, 30), ' '), 30); -- bytes 18-32

    l_line := l_line || lpad(' ', 18);

    if l_line is not null then
        prc_api_file_pkg.put_line(
            i_raw_data      => convert_data(i_data => l_line)
          , i_sess_file_id  => i_session_file_id
        );
        io_batch.tcr_total := io_batch.tcr_total + 1;
    end if;

    ------------------------------------------------------------------------------------------------------------
    io_batch.trans_total    := io_batch.trans_total + 1;
    io_batch.monetary_total := io_batch.monetary_total + 1;
    -- if currency exponent equal to zero then append two zeros in accordance with VISA rules
    if i_fin_message.oper_currency is not null and l_oper_currency_exponent = 0 then
        io_batch.src_amount := io_batch.src_amount + i_fin_message.oper_amount*100;
    else
        io_batch.src_amount := io_batch.src_amount + i_fin_message.oper_amount;
    end if;

    if i_fin_message.sttl_currency is not null and com_api_currency_pkg.get_currency_exponent(i_fin_message.sttl_currency) = 0 then
        io_batch.dst_amount := io_batch.dst_amount + i_fin_message.sttl_amount*100;
    else
        io_batch.dst_amount := io_batch.dst_amount + i_fin_message.sttl_amount;
    end if;

end;

procedure mark_fin_messages (
    i_id                    in com_api_type_pkg.t_number_tab
    , i_file_id             in com_api_type_pkg.t_number_tab
    , i_batch_id            in com_api_type_pkg.t_number_tab
    , i_rec_num             in com_api_type_pkg.t_number_tab
) is
begin
    trc_log_pkg.debug (
        i_text         => 'Mark financial messages'
    );

    forall i in 1..i_id.count
        update
            cst_itmx_fin_message
        set
            file_id = i_file_id(i)
            , batch_id = i_batch_id(i)
            , record_number = i_rec_num(i)
            , status = net_api_const_pkg.CLEARING_MSG_STATUS_UPLOADED
        where
            id = i_id(i);
end;

procedure process(
    i_network_id            in com_api_type_pkg.t_tiny_id
  , i_inst_id               in com_api_type_pkg.t_inst_id
  , i_host_inst_id          in com_api_type_pkg.t_inst_id
  , i_test_option           in varchar2
  , i_start_date            in date
  , i_end_date              in date
  , i_include_affiliate     in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
  , i_charset               in com_api_type_pkg.t_oracle_name    default null
  , i_create_disp_case      in com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
) is
    LOG_PREFIX constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process ';

    l_estimated_count         com_api_type_pkg.t_long_id := 0;
    l_processed_count         com_api_type_pkg.t_long_id := 0;
    l_record_count            com_api_type_pkg.t_long_id;

    l_inst_id                 com_api_type_pkg.t_inst_id_tab;
    l_host_inst_id            com_api_type_pkg.t_inst_id_tab;
    l_network_id              com_api_type_pkg.t_network_tab;
    l_host_id                 com_api_type_pkg.t_number_tab;
    l_standard_id             com_api_type_pkg.t_number_tab;

    l_params                  com_api_type_pkg.t_param_tab;

    l_ok_mess_id              com_api_type_pkg.t_number_tab;
    l_batch_id                com_api_type_pkg.t_number_tab;
    l_file_id                 com_api_type_pkg.t_number_tab;
    l_rec_num                 com_api_type_pkg.t_number_tab;

    l_ok_fraud_id             com_api_type_pkg.t_number_tab;
    l_batch_fraud_id          com_api_type_pkg.t_number_tab;
    l_file_fraud_id           com_api_type_pkg.t_number_tab;
    l_rec_fraud_num           com_api_type_pkg.t_number_tab;

    l_proc_bin                com_api_type_pkg.t_dict_value;

    l_fin_message             cst_itmx_api_type_pkg.t_itmx_fin_mes_fraud_tab;

    l_session_file_id         com_api_type_pkg.t_long_id;

    l_file                    cst_itmx_api_type_pkg.t_itmx_file_rec;
    l_batch                   cst_itmx_api_type_pkg.t_itmx_batch_rec;
    l_trans_code              varchar2(2);

    l_header_writed           boolean := false;

    l_fin_cur                 cst_itmx_api_type_pkg.t_itmx_fin_fraud_cur;

    procedure register_ok_message (
        i_mess_id               com_api_type_pkg.t_long_id
        , i_batch_id            com_api_type_pkg.t_medium_id
        , i_file_id             com_api_type_pkg.t_long_id
        , i_fraud_id            com_api_type_pkg.t_long_id
    ) is
        i                       binary_integer;
    begin
        if i_fraud_id is null then          -- record from cst_itmx_fin_message
            i := l_ok_mess_id.count + 1;

            l_ok_mess_id(i) := i_mess_id;
            l_batch_id(i) := i_batch_id;
            l_file_id(i) := i_file_id;
            l_rec_num(i) := prc_api_file_pkg.get_record_number(i_sess_file_id => l_session_file_id);

        elsif i_fraud_id is not null then   -- record from vis_fraud
            i := l_ok_fraud_id.count + 1;

            l_ok_fraud_id(i) := i_fraud_id;
            l_batch_fraud_id(i) := i_batch_id;
            l_file_fraud_id(i) := i_file_id;
            l_rec_fraud_num(i) := prc_api_file_pkg.get_record_number(i_sess_file_id => l_session_file_id);
        end if;
    end;

    procedure mark_ok_message is
    begin
        mark_fin_messages (
            i_id          => l_ok_mess_id
            , i_file_id   => l_file_id
            , i_batch_id  => l_batch_id
            , i_rec_num   => l_rec_num
        );

        opr_api_clearing_pkg.mark_uploaded (
            i_id_tab  => l_ok_mess_id
        );

        l_ok_mess_id.delete;
        l_batch_id.delete;
        l_file_id.delete;
        l_rec_num.delete;

        l_ok_fraud_id.delete;
        l_batch_fraud_id.delete;
        l_file_fraud_id.delete;
        l_rec_fraud_num.delete;
    end;

    procedure check_ok_message is
    begin
        if l_ok_mess_id.count >= BULK_LIMIT then
            mark_ok_message;
        end if;
    end;

    procedure register_session_file (
        i_inst_id               in com_api_type_pkg.t_inst_id
        , i_network_id          in com_api_type_pkg.t_tiny_id
        , i_host_inst_id        in com_api_type_pkg.t_inst_id
        , i_proc_bin            in com_api_type_pkg.t_dict_value
        , o_session_file_id     out com_api_type_pkg.t_long_id
    ) is
        LOG_PREFIX constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.register_session_file '; 
    begin
        trc_log_pkg.debug(
            i_text => LOG_PREFIX || '<< i_inst_id [#1], i_network_id [#2], i_host_inst_id [#3]'
            || ', i_proc_bin [#4]'
            , i_env_param1 => i_inst_id
            , i_env_param2 => i_network_id
            , i_env_param3 => i_host_inst_id
            , i_env_param4 => i_proc_bin
        );

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
            i_name       => 'HOST_INST_ID'
            , i_value    => i_host_inst_id
            , io_params  => l_params
        );
        rul_api_param_pkg.set_param (
            i_name       => 'ACQ_BIN'
            , i_value    => i_proc_bin
            , io_params  => l_params
        );
        rul_api_param_pkg.set_param (
            i_name       => 'KEY_INDEX'
            , i_value    => i_proc_bin
            , io_params  => l_params
        );
        prc_api_file_pkg.open_file (
            o_sess_file_id  => o_session_file_id
            , i_file_type   => cst_itmx_api_const_pkg.FILE_TYPE_CLEARING
            , io_params     => l_params
        );

       trc_log_pkg.debug(
            i_text => LOG_PREFIX || '>> o_session_file_id [#1]'
            , i_env_param1 => o_session_file_id
        );
    end;

begin
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || '<< ITMX outgoing clearing start: i_network_id [#1], i_inst_id [#2], i_host_inst_id [#3]'
        || ', i_start_date [#4], i_end_date [#5], i_include_affiliate [#6]'
        , i_env_param1 => i_network_id
        , i_env_param2 => i_inst_id
        , i_env_param3 => i_host_inst_id
        , i_env_param4 => to_char(i_start_date, 'dd.mm.yyyy hh24:mi:ss')
        , i_env_param5 => to_char(i_end_date, 'dd.mm.yyyy hh24:mi:ss')
        , i_env_param6 => i_include_affiliate
    );

    prc_api_stat_pkg.log_start;

    g_charset        := nvl(i_charset, g_default_charset);
    g_adjust_charset := case when g_charset != g_default_charset then com_api_const_pkg.TRUE else com_api_const_pkg.FALSE end;

    -- fetch parameters
    select
        m.id host_id
        , m.inst_id host_inst_id
        , n.id network_id
        , r.inst_id
        , s.standard_id
    bulk collect into
        l_host_id
        , l_host_inst_id
        , l_network_id
        , l_inst_id
        , l_standard_id
    from
        net_network n
        , net_member m
        , net_interface i
        , net_member r
        , cmn_standard_object s
    where
        (n.id = i_network_id or i_network_id is null)
        and n.id = m.network_id
        and n.inst_id = m.inst_id
        and (m.inst_id = i_host_inst_id or i_host_inst_id is null)
        and s.object_id = m.id
        and s.entity_type = net_api_const_pkg.ENTITY_TYPE_HOST
        and s.standard_type = cmn_api_const_pkg.STANDART_TYPE_NETW_CLEARING
        and (r.inst_id = i_inst_id or i_inst_id is null
             or (i_include_affiliate = com_api_const_pkg.TRUE
                 and i_inst_id is not null
                 and r.inst_id in (select m.inst_id
                                     from net_interface i
                                        , net_member m
                                    where i.msp_member_id in (select id
                                                                from net_member
                                                               where network_id = i_network_id
                                                                 and inst_id    = i_inst_id
                                                             )
                                      and m.id = i.consumer_member_id
                                   )
                )
            )
        and r.id = i.consumer_member_id
        and i.host_member_id = m.id;

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || ' l_host_id.count [#1]'
        , i_env_param1 => l_host_id.count
    );

    -- make estimated count
    for i in 1..l_host_id.count loop                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
        l_record_count := cst_itmx_api_fin_message_pkg.estimate_fin_fraud_for_upload (
            i_network_id      => l_network_id(i)
            , i_inst_id       => l_inst_id(i)
            , i_host_inst_id  => l_host_inst_id(i)
            , i_start_date    => trunc(i_start_date)
            , i_end_date      => trunc(i_end_date)
        );

        l_estimated_count := l_estimated_count + l_record_count;
    end loop;

    prc_api_stat_pkg.log_estimation (
        i_estimated_count  => l_estimated_count
    );

    if l_estimated_count > 0 then
        for i in 1..l_host_id.count loop
            -- init
            l_proc_bin := null;
            l_trans_code := null;
            l_header_writed := false;

            cst_itmx_api_fin_message_pkg.enum_fin_msg_fraud_for_upload (
                o_fin_cur         => l_fin_cur
                , i_network_id    => l_network_id(i)
                , i_inst_id       => l_inst_id(i)
                , i_host_inst_id  => l_host_inst_id(i)
                , i_start_date    => trunc(i_start_date)
                , i_end_date      => trunc(i_end_date)
            );
            loop
                fetch l_fin_cur bulk collect into l_fin_message limit BULK_LIMIT;

                trc_log_pkg.debug(
                    i_text => LOG_PREFIX || ' l_fin_message.count [#1]'
                    , i_env_param1 => l_fin_message.count
                );

                for j in 1..l_fin_message.count loop

                    if l_header_writed and (l_proc_bin is not null and l_fin_message(j).proc_bin != l_proc_bin) then
                        process_batch_trailer (
                            io_batch             => l_batch
                            , i_network_id       => l_network_id(i)
                            , i_host_id          => l_host_id(i)
                            , i_inst_id          => l_inst_id(i)
                            , i_standard_id      => l_standard_id(i)
                            , i_session_file_id  => l_session_file_id
                        );

                        l_file.tcr_total      := l_file.tcr_total      + l_batch.tcr_total;
                        l_file.trans_total    := l_file.trans_total    + l_batch.trans_total;
                        l_file.src_amount     := l_file.src_amount     + l_batch.src_amount;
                        l_file.monetary_total := l_file.monetary_total + l_batch.monetary_total;
                        l_file.dst_amount     := l_file.dst_amount     + l_batch.dst_amount;
                        l_file.batch_total    := l_file.batch_total    + 1;

                        process_file_trailer (
                            io_file              => l_file
                            , i_network_id       => l_network_id(i)
                            , i_host_id          => l_host_id(i)
                            , i_inst_id          => l_inst_id(i)
                            , i_standard_id      => l_standard_id(i)
                            , i_session_file_id  => l_session_file_id
                        );

                        prc_api_file_pkg.close_file (
                            i_sess_file_id  => l_session_file_id
                          , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
                        );

                        l_header_writed := false;
                    end if;

                    -- if first record create new file and put file header
                    if l_proc_bin is null or (l_proc_bin is not null and l_fin_message(j).proc_bin != l_proc_bin) then
                        register_session_file (
                            i_inst_id            => l_inst_id(i)
                            , i_network_id       => l_network_id(i)
                            , i_host_inst_id     => l_host_inst_id(i)
                            , i_proc_bin         => l_fin_message(j).proc_bin
                            , o_session_file_id  => l_session_file_id
                        );

                        process_file_header (
                            i_network_id         => l_network_id(i)
                            , i_proc_bin         => l_fin_message(j).proc_bin
                            , i_inst_id          => l_inst_id(i)
                            , i_standard_id      => l_standard_id(i)
                            , i_host_id          => l_host_id(i)
                            , i_test_option      => i_test_option
                            , i_session_file_id  => l_session_file_id
                            , o_file             => l_file
                            , io_batch           => l_batch
                        );

                        l_trans_code := l_fin_message(j).trans_code;
                        l_proc_bin := l_fin_message(j).proc_bin;

                        l_header_writed := true;
                    end if;

                    -- when batch limit is exceeded put batch trailer
                    if l_trans_code is not null and l_batch.tcr_total > BATCH_REC_LIMIT then
                        process_batch_trailer (
                            io_batch             => l_batch
                            , i_network_id       => l_network_id(i)
                            , i_host_id          => l_host_id(i)
                            , i_inst_id          => l_inst_id(i)
                            , i_standard_id      => l_standard_id(i)
                            , i_session_file_id  => l_session_file_id
                        );

                        l_file.tcr_total      := l_file.tcr_total      + l_batch.tcr_total;
                        l_file.trans_total    := l_file.trans_total    + l_batch.trans_total;
                        l_file.src_amount     := l_file.src_amount     + l_batch.src_amount;
                        l_file.monetary_total := l_file.monetary_total + l_batch.monetary_total;
                        l_file.dst_amount     := l_file.dst_amount     + l_batch.dst_amount;
                        l_file.batch_total    := l_file.batch_total    + 1;

                        init_batch(
                            io_batch             => l_batch
                          , i_session_file_id    => l_file.id
                          , i_file_proc_bin      => l_file.proc_bin
                          , i_batch_number_shift => 0
                        );
                        l_trans_code := l_fin_message(j).trans_code;
                    end if;

                    -- process draft transactions
                    if l_fin_message(j).trans_code in (
                        cst_itmx_api_const_pkg.TC_SALES
                      , cst_itmx_api_const_pkg.TC_VOUCHER
                      , cst_itmx_api_const_pkg.TC_CASH
                      , cst_itmx_api_const_pkg.TC_SALES_CHARGEBACK
                      , cst_itmx_api_const_pkg.TC_VOUCHER_CHARGEBACK
                      , cst_itmx_api_const_pkg.TC_CASH_CHARGEBACK
                      , cst_itmx_api_const_pkg.TC_SALES_REVERSAL
                      , cst_itmx_api_const_pkg.TC_VOUCHER_REVERSAL
                      , cst_itmx_api_const_pkg.TC_CASH_REVERSAL
                      , cst_itmx_api_const_pkg.TC_SALES_CHARGEBACK_REV
                      , cst_itmx_api_const_pkg.TC_VOUCHER_CHARGEBACK_REV
                      , cst_itmx_api_const_pkg.TC_CASH_CHARGEBACK_REV
                    ) then
                        process_draft(
                            i_fin_message        => l_fin_message(j)
                            , i_network_id       => l_network_id(i)
                            , i_host_id          => l_host_id(i)
                            , i_inst_id          => l_inst_id(i)
                            , i_standard_id      => l_standard_id(i)
                            , i_session_file_id  => l_session_file_id
                            , io_batch           => l_batch
                            , i_create_disp_case => i_create_disp_case
                        );
                    end if;

                    register_ok_message (
                        i_mess_id     => l_fin_message(j).id
                        , i_batch_id  => l_batch.id
                        , i_file_id   => l_file.id
                        , i_fraud_id  => l_fin_message(j).fraud_id
                    );

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

            if l_header_writed then
                process_batch_trailer (
                    io_batch             => l_batch
                    , i_network_id       => l_network_id(i)
                    , i_host_id          => l_host_id(i)
                    , i_inst_id          => l_inst_id(i)
                    , i_standard_id      => l_standard_id(i)
                    , i_session_file_id  => l_session_file_id
                );

                l_file.tcr_total      := l_file.tcr_total      + l_batch.tcr_total;
                l_file.trans_total    := l_file.trans_total    + l_batch.trans_total;
                l_file.src_amount     := l_file.src_amount     + l_batch.src_amount;
                l_file.monetary_total := l_file.monetary_total + l_batch.monetary_total;
                l_file.dst_amount     := l_file.dst_amount     + l_batch.dst_amount;
                l_file.batch_total    := l_file.batch_total    + 1;

                process_file_trailer (
                    io_file              => l_file
                    , i_network_id       => l_network_id(i)
                    , i_host_id          => l_host_id(i)
                    , i_inst_id          => l_inst_id(i)
                    , i_standard_id      => l_standard_id(i)
                    , i_session_file_id  => l_session_file_id
                );

                prc_api_file_pkg.close_file (
                    i_sess_file_id  => l_session_file_id
                  , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
                );
            end if;
        end loop;
    end if;

    prc_api_stat_pkg.log_end(
        i_result_code        => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        , i_processed_total  => l_processed_count
    );

    trc_log_pkg.debug (
        i_text  => LOG_PREFIX || '>> ITMX outgoing clearing end'
    );

exception
    when others then
        if l_fin_cur%isopen then
            close l_fin_cur;
        end if;

        prc_api_stat_pkg.log_end (
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if l_session_file_id is not null then
            prc_api_file_pkg.close_file (
                i_sess_file_id  => l_session_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
            );
        end if;

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
