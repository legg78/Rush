create or replace package body vis_prc_outgoing_pkg as
/*********************************************************
 *  Visa outgoing files API  <br />
 *  Created by Filimonov A.(filimonov@bpcbt.com)  at 21.10.2009 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: vis_api_incoming_pkg <br />
 *  @headcom
 **********************************************************/

BULK_LIMIT       constant integer  := 1000;
BATCH_REC_LIMIT  constant integer  := 950;   -- max number of batch records

g_default_charset         com_api_type_pkg.t_oracle_name := vis_api_const_pkg.g_default_charset;
g_charset                 com_api_type_pkg.t_oracle_name := vis_api_const_pkg.g_default_charset;
g_adjust_charset          com_api_type_pkg.t_boolean     := case when g_charset != g_default_charset then com_api_const_pkg.TRUE else com_api_const_pkg.FALSE end;

function get_operation_date(
    i_visa_dialect    com_api_type_pkg.t_dict_value
  , i_operation_id    com_api_type_pkg.t_long_id
  , i_oper_date       date
  , i_host_date       date
) return date
is
    ACQUIRER_SWITCH_DATE_TAG     constant com_api_type_pkg.t_short_id := 8716;              -- authorization tag DF8423
    ACQUIRER_SWITCH_DATE_FORMAT  constant com_api_type_pkg.t_name     := 'yymmddhh24miss';

    l_operation_date  date;
begin
    if i_visa_dialect = vis_api_const_pkg.VISA_DIALECT_OPENWAY then
        l_operation_date := to_date(
                                aup_api_tag_pkg.get_tag_value(
                                    i_auth_id => i_operation_id
                                  , i_tag_id  => ACQUIRER_SWITCH_DATE_TAG
                                )
                              , ACQUIRER_SWITCH_DATE_FORMAT
                            );
        if l_operation_date is null then
            l_operation_date := i_host_date;
        end if;
    else
        l_operation_date := i_oper_date;
    end if;
    return l_operation_date;
end;

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

procedure process_file_header(
    i_network_id        in     com_api_type_pkg.t_tiny_id
  , i_proc_bin_header   in     com_api_type_pkg.t_dict_value
  , i_proc_bin          in     com_api_type_pkg.t_dict_value
  , i_inst_id           in     com_api_type_pkg.t_inst_id
  , i_standard_id       in     com_api_type_pkg.t_inst_id
  , i_host_id           in     com_api_type_pkg.t_tiny_id
  , i_test_option       in     varchar2 default null
  , i_session_file_id   in     com_api_type_pkg.t_long_id
  , o_file                 out vis_api_type_pkg.t_visa_file_rec
) is
    l_line                     com_api_type_pkg.t_text;
    l_param_tab                com_api_type_pkg.t_param_tab;
begin
    l_line := '90';

    -- get security code
    rul_api_param_pkg.set_param(
        i_name             => 'ACQ_PROC_BIN'
      , i_value            => i_proc_bin
      , io_params          => l_param_tab
    );
    cmn_api_standard_pkg.get_param_value(
        i_inst_id          => i_inst_id
        , i_standard_id    => i_standard_id
        , i_object_id      => i_host_id
        , i_entity_type    => net_api_const_pkg.ENTITY_TYPE_HOST
        , i_param_name     => vis_api_const_pkg.VISA_SECURITY_CODE
        , o_param_value    => o_file.security_code
        , i_param_tab      => l_param_tab
    );

    o_file.id              := vis_file_seq.nextval;

    o_file.session_file_id := i_session_file_id;
    o_file.is_incoming     := com_api_type_pkg.FALSE;
    o_file.network_id      := i_network_id;

    o_file.proc_date       := trunc(com_api_sttl_day_pkg.get_sysdate);
    o_file.sttl_date       := null;
    o_file.release_number  := null;
    o_file.test_option     := i_test_option;

    o_file.proc_bin        := i_proc_bin_header;

    select nvl(max(to_number(visa_file_id)), 0) + 1
      into o_file.visa_file_id
      from vis_file
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

    if o_file.proc_bin is null then
        l_line := l_line || lpad(nvl(o_file.proc_bin, ' '), 6, ' ');
    else
        l_line := l_line || rpad(o_file.proc_bin, 6, '0');
    end if;

    l_line := l_line || to_char(com_api_sttl_day_pkg.get_sysdate, 'YYDDD');
    l_line := l_line || rpad(' ', 16);
    l_line := l_line || rpad(nvl(o_file.test_option, ' '), 4);
    l_line := l_line || rpad(' ', 29);
    l_line := l_line || rpad(nvl(o_file.security_code, ' '), 8);
    l_line := l_line || rpad(' ', 6);
    l_line := l_line || lpad(o_file.visa_file_id, 3, '0');
    l_line := l_line || rpad(' ', 89);

    if l_line is not null then
        prc_api_file_pkg.put_line(
            i_raw_data      => convert_data(i_data => l_line)
          , i_sess_file_id  => i_session_file_id
        );
    end if;

end;

function get_next_batch_number (
    i_batch_number           in com_api_type_pkg.t_tag
    , i_proc_date            in date
) return com_api_type_pkg.t_tag is
    l_batch_number              com_api_type_pkg.t_tag;
begin
    if i_batch_number is not null then
        l_batch_number := i_batch_number + 1;
    else
        select nvl(max(to_number(batch_number)),0) + 1
          into l_batch_number
          from vis_batch
         where trunc(proc_date) = i_proc_date;
    end if;
    return l_batch_number;
end;

procedure init_batch (
    io_batch                 in out vis_api_type_pkg.t_visa_batch_rec
    , i_session_file_id      in com_api_type_pkg.t_long_id
    , i_file_proc_bin        in varchar2
) is
begin
    io_batch.id              := vis_batch_seq.nextval;
    io_batch.file_id         := i_session_file_id;
    io_batch.proc_bin        := i_file_proc_bin;
    io_batch.proc_date       := trunc(com_api_sttl_day_pkg.get_sysdate);
    io_batch.batch_number    := get_next_batch_number(io_batch.batch_number, io_batch.proc_date);
    io_batch.center_batch_id := mod(io_batch.id, 100000000);
    io_batch.monetary_total  := 0;
    io_batch.tcr_total       := 0;
    io_batch.trans_total     := 0;
    io_batch.src_amount      := 0;
    io_batch.dst_amount      := 0;
end;

procedure process_batch_trailer (
    io_batch                 in out vis_api_type_pkg.t_visa_batch_rec
    , i_network_id           in com_api_type_pkg.t_tiny_id
    , i_host_id              in com_api_type_pkg.t_tiny_id
    , i_inst_id              in com_api_type_pkg.t_inst_id
    , i_standard_id          in com_api_type_pkg.t_inst_id
    , i_session_file_id      in com_api_type_pkg.t_long_id
) is
    l_line                   com_api_type_pkg.t_text;
    l_visa_dialect           com_api_type_pkg.t_dict_value;
    l_param_tab                 com_api_type_pkg.t_param_tab;
begin
    cmn_api_standard_pkg.get_param_value(
        i_inst_id       => i_inst_id
      , i_standard_id   => i_standard_id
      , i_object_id     => i_host_id
      , i_entity_type   => net_api_const_pkg.ENTITY_TYPE_HOST
      , i_param_name    => vis_api_const_pkg.VISA_BASEII_DIALECT
      , o_param_value   => l_visa_dialect
      , i_param_tab     => l_param_tab
    );
--*/l_visa_dialect := 'BBB';

    io_batch.tcr_total      := io_batch.tcr_total + 1;
    io_batch.trans_total    := io_batch.trans_total + 1;

    l_line := l_line || '9100';   -- tc, tcq, tcr

    if l_visa_dialect in (vis_api_const_pkg.VISA_DIALECT_OPENWAY, vis_api_const_pkg.VISA_DIALECT_TIETO) then
        l_line := l_line || lpad(nvl(io_batch.proc_bin, '0'), 6, '0'); -- BIN
    else
        l_line := l_line || lpad('0', 6, '0'); -- BIN
    end if;

    if l_visa_dialect = vis_api_const_pkg.VISA_DIALECT_TIETO then
        l_line := l_line || to_char(com_api_sttl_day_pkg.get_sysdate, 'YYDDD');
    else
        l_line := l_line || lpad('0', 5, '0'); -- date
    end if;

    if l_visa_dialect in (vis_api_const_pkg.VISA_DIALECT_OPENWAY, vis_api_const_pkg.VISA_DIALECT_TIETO) then
        l_line := l_line || lpad(nvl(io_batch.src_amount, '0'), 15, '0');
    else
        l_line := l_line || lpad('0', 15, '0'); -- dst amount
    end if;

    l_line := l_line || lpad(nvl(io_batch.monetary_total, '0'), 12, '0');
    l_line := l_line || lpad(nvl(io_batch.batch_number, '0'), 6, '0');
    l_line := l_line || lpad(nvl(io_batch.tcr_total, '0'), 12, '0');
    l_line := l_line || lpad('0', 6, '0');

    if l_visa_dialect = vis_api_const_pkg.VISA_DIALECT_TIETO then
        l_line := l_line || lpad(' ', 8);
    else
        l_line := l_line || rpad(nvl(io_batch.center_batch_id, ' '), 8);
    end if;

    l_line := l_line || lpad(nvl(io_batch.trans_total, '0'), 9, '0');
    l_line := l_line || lpad('0', 18, '0');
    l_line := l_line || lpad(nvl(io_batch.src_amount, '0'), 15, '0');
    l_line := l_line || lpad('0', 15, '0');
    l_line := l_line || lpad('0', 15, '0');
    l_line := l_line || lpad('0', 15, '0');
    l_line := l_line || lpad(' ', 7);

    if l_line is not null then
        prc_api_file_pkg.put_line(
            i_raw_data      => convert_data(i_data => l_line)
          , i_sess_file_id  => i_session_file_id
        );
    end if;
--*/dbms_output.put_line('batch_trailer:'||l_line);

    insert into vis_batch(
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
    io_file                  in out vis_api_type_pkg.t_visa_file_rec
    , i_network_id           in com_api_type_pkg.t_tiny_id
    , i_host_id              in com_api_type_pkg.t_tiny_id
    , i_inst_id              in com_api_type_pkg.t_inst_id
    , i_standard_id          in com_api_type_pkg.t_inst_id
    , i_session_file_id      in com_api_type_pkg.t_long_id
) is
    l_visa_dialect           com_api_type_pkg.t_dict_value;
    l_line                   com_api_type_pkg.t_text;
    l_param_tab              com_api_type_pkg.t_param_tab;
begin
    cmn_api_standard_pkg.get_param_value(
        i_inst_id       => i_inst_id
      , i_standard_id   => i_standard_id
      , i_object_id     => i_host_id
      , i_entity_type   => net_api_const_pkg.ENTITY_TYPE_HOST
      , i_param_name    => vis_api_const_pkg.VISA_BASEII_DIALECT
      , o_param_value   => l_visa_dialect
      , i_param_tab     => l_param_tab
    );

    io_file.tcr_total      := io_file.tcr_total + 1;
    io_file.trans_total    := io_file.trans_total + 1;

    l_line := l_line || '9200';   -- tc, tcq, tcr

    if l_visa_dialect in (vis_api_const_pkg.VISA_DIALECT_OPENWAY, vis_api_const_pkg.VISA_DIALECT_TIETO) then
        l_line := l_line || lpad(nvl(io_file.proc_bin, '0'), 6, '0'); -- BIN
    else
        l_line := l_line || lpad('0', 6, '0'); -- BIN
    end if;

    if l_visa_dialect = vis_api_const_pkg.VISA_DIALECT_TIETO then
        l_line := l_line || to_char(com_api_sttl_day_pkg.get_sysdate, 'YYDDD');
    else
        l_line := l_line || lpad('0', 5, '0'); -- date
    end if;

    if l_visa_dialect in (vis_api_const_pkg.VISA_DIALECT_OPENWAY, vis_api_const_pkg.VISA_DIALECT_TIETO) then
        l_line := l_line || lpad(nvl(io_file.src_amount, '0'), 15, '0');
    else
        l_line := l_line || lpad('0', 15, '0'); -- dst amount
    end if;

    l_line := l_line || lpad(nvl(io_file.monetary_total, '0'), 12, '0');
    l_line := l_line || lpad(nvl(io_file.batch_total, '0'), 6, '0');
    l_line := l_line || lpad(nvl(io_file.tcr_total, '0'), 12, '0');
    l_line := l_line || lpad('0', 6, '0');
    l_line := l_line || rpad(' ', 8);
    l_line := l_line || lpad(nvl(io_file.trans_total, '0'), 9, '0');
    l_line := l_line || lpad('0', 18, '0');
    l_line := l_line || lpad(nvl(io_file.src_amount, '0'), 15, '0');
    l_line := l_line || lpad('0', 15, '0');
    l_line := l_line || lpad('0', 15, '0');
    l_line := l_line || lpad('0', 15, '0');
    l_line := l_line || lpad(' ', 7);

    if l_line is not null then
        prc_api_file_pkg.put_line(
            i_raw_data      => convert_data(i_data => l_line)
          , i_sess_file_id  => i_session_file_id
        );
    end if;
--*/dbms_output.put_line('file_trailer:'||l_line);

    insert into vis_file (
        id
      , is_incoming
      , network_id
      , proc_bin
      , proc_date
      , sttl_date
      , release_number
      , test_option
      , security_code
      , visa_file_id
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
      , io_file.visa_file_id
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

procedure process_draft(
    i_fin_message            in vis_api_type_pkg.t_visa_fin_mes_fraud_rec
    , i_network_id           in com_api_type_pkg.t_tiny_id
    , i_host_id              in com_api_type_pkg.t_tiny_id
    , i_inst_id              in com_api_type_pkg.t_inst_id
    , i_standard_id          in com_api_type_pkg.t_inst_id
    , i_session_file_id      in com_api_type_pkg.t_long_id
    , io_batch               in out vis_api_type_pkg.t_visa_batch_rec
    , i_create_disp_case     in com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
) is
    l_visa_dialect           com_api_type_pkg.t_dict_value;
    l_line                   com_api_type_pkg.t_text;
    l_param_tab              com_api_type_pkg.t_param_tab;
    l_oper_currency_exponent com_api_type_pkg.t_tiny_id;
    l_operation_date         date;
    
    l_seqnum                 com_api_type_pkg.t_seqnum;
    l_reason_code            com_api_type_pkg.t_byte_char;
begin
    trc_log_pkg.debug(
        i_text => 'process_draft START, i_create_disp_case=' || i_create_disp_case || ' id=' || i_fin_message.id
    );
    cmn_api_standard_pkg.get_param_value(
        i_inst_id       => i_inst_id
      , i_standard_id   => i_standard_id
      , i_object_id     => i_host_id
      , i_entity_type   => net_api_const_pkg.ENTITY_TYPE_HOST
      , i_param_name    => vis_api_const_pkg.VISA_BASEII_DIALECT
      , o_param_value   => l_visa_dialect
      , i_param_tab     => l_param_tab
    );

    --*/l_visa_dialect := 'AAA';
    l_oper_currency_exponent := com_api_currency_pkg.get_currency_exponent(i_fin_message.oper_currency);
    l_operation_date         := get_operation_date(
                                    i_visa_dialect    => l_visa_dialect
                                  , i_operation_id    => i_fin_message.id
                                  , i_oper_date       => i_fin_message.oper_date
                                  , i_host_date       => i_fin_message.host_date
                                );

    --------------------------- TCR0 ------------------------------------
    l_line := null;
    l_line := l_line || i_fin_message.trans_code;
    l_line := l_line || i_fin_message.trans_code_qualifier;
    l_line := l_line || '0';

    if l_visa_dialect = vis_api_const_pkg.VISA_DIALECT_TIETO then
        l_line := l_line || rpad(nvl(i_fin_message.card_number, '0'), 16, '0');
        l_line := l_line || '      ';
    else
        l_line := l_line || rpad(nvl(i_fin_message.card_number, '0'), 19, '0');
        l_line := l_line || nvl(i_fin_message.floor_limit_ind, ' ');
        l_line := l_line || nvl(i_fin_message.exept_file_ind, ' ');
        l_line := l_line || nvl(i_fin_message.pcas_ind, ' ');
    end if;

    l_line := l_line || rpad(i_fin_message.arn, 23, '0');

    if l_visa_dialect = vis_api_const_pkg.VISA_DIALECT_TIETO then
        l_line := l_line || '00000000';
    else
        l_line := l_line || lpad(i_fin_message.acq_business_id, 8, '0');
    end if;

    l_line := l_line || nvl(to_char(l_operation_date, 'MMDD'), '    ');

    -- if working via sponsor then fill fields as in incoming format
    if l_visa_dialect in (vis_api_const_pkg.VISA_DIALECT_OPENWAY, vis_api_const_pkg.VISA_DIALECT_TIETO) then
        -- if currency exponent equal to zero then append two zeros in accordance with VISA rules
        l_line := l_line || case when l_oper_currency_exponent = 0
                                 then lpad(i_fin_message.oper_amount, 10, '0') || '00'
                                 else lpad(i_fin_message.oper_amount, 12, '0')
                            end;
        l_line := l_line || i_fin_message.oper_currency;
    else
        l_line := l_line || lpad('0', 12, '0');
        l_line := l_line || lpad(' ', 3);
    end if;

    -- if currency exponent equal to zero then append two zeros in accordance with VISA rules
    if l_oper_currency_exponent = 0 then
        l_line := l_line || lpad(i_fin_message.oper_amount, 10, '0') || '00';
    else
        l_line := l_line || lpad(i_fin_message.oper_amount, 12, '0');
    end if;

    l_line := l_line || lpad(nvl(i_fin_message.oper_currency, ' '), 3);
    l_line := l_line || rpad(nvl(i_fin_message.merchant_name, ' '), 25);
    l_line := l_line || rpad(nvl(i_fin_message.merchant_city, ' '), 13);
    l_line := l_line || rpad(nvl(com_api_country_pkg.get_visa_code(i_fin_message.merchant_country, com_api_type_pkg.FALSE), ' '), 3);
    l_line := l_line || rpad(nvl(i_fin_message.mcc, ' '), 4);                  -- Merchant Category Code

    if l_visa_dialect = vis_api_const_pkg.VISA_DIALECT_TIETO then
        l_line := l_line || '          ';
    else
        l_line := l_line || lpad(nvl(i_fin_message.merchant_postal_code, '0'), 5, '0'); -- Merchant ZIP Code
        l_line := l_line || rpad(nvl(i_fin_message.merchant_region, ' '), 3);      -- Merchant State/Province Code
        l_line := l_line ||      nvl(i_fin_message.req_pay_service, ' ');
        l_line := l_line ||      nvl(i_fin_message.payment_forms_num, ' ');
    end if;

    l_line := l_line ||      nvl(i_fin_message.usage_code, ' ');
    l_line := l_line || lpad(nvl(i_fin_message.reason_code, ' '), 2);

    if l_visa_dialect = vis_api_const_pkg.VISA_DIALECT_TIETO then
        l_line := l_line || '9N';
    else
        l_line := l_line ||      nvl(i_fin_message.settlement_flag, ' ');
        l_line := l_line ||      nvl(i_fin_message.auth_char_ind, ' ');
    end if;

    if i_fin_message.trans_code in (vis_api_const_pkg.TC_VOUCHER
                                  , vis_api_const_pkg.TC_VOUCHER_CHARGEBACK
                                  , vis_api_const_pkg.TC_VOUCHER_REVERSAL
                                  , vis_api_const_pkg.TC_VOUCHER_CHARGEBACK_REV)
       and i_fin_message.trans_code_qualifier = '0' then
        l_line := l_line || rpad(' ', 6);
    else
        l_line := l_line || rpad(nvl(i_fin_message.auth_code, ' '), 6);
    end if;
    l_line := l_line ||      nvl(i_fin_message.pos_terminal_cap, ' ');

    l_line := l_line || ' '; --i_fin_message.inter_fee_ind is not used

    l_line := l_line ||      nvl(i_fin_message.crdh_id_method, ' ');

    if l_visa_dialect = vis_api_const_pkg.VISA_DIALECT_TIETO then
        l_line := l_line || ' ';
    else
        l_line := l_line ||      nvl(i_fin_message.collect_only_flag, ' ');
    end if;

    l_line := l_line || rpad(nvl(i_fin_message.pos_entry_mode, ' '), 2);

    if l_visa_dialect = vis_api_const_pkg.VISA_DIALECT_TIETO then
        l_line := l_line || i_fin_message.central_proc_date;
        l_line := l_line || ' ';
    else
        if i_fin_message.usage_code = 1 and
           i_fin_message.trans_code in (
            vis_api_const_pkg.TC_SALES,
            vis_api_const_pkg.TC_VOUCHER,
            vis_api_const_pkg.TC_CASH
           ) and
           l_visa_dialect != vis_api_const_pkg.VISA_DIALECT_OPENWAY
        then
            l_line := l_line || '0000';
        else
            l_line := l_line || i_fin_message.central_proc_date;
        end if;
        l_line := l_line ||      nvl(i_fin_message.reimburst_attr, ' ');
    end if;

    l_reason_code := substr(l_line, 148, 2);

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
    l_line := l_line || i_fin_message.trans_code_qualifier;
    l_line := l_line || '1';

    if l_visa_dialect = vis_api_const_pkg.VISA_DIALECT_TIETO then
        l_line := l_line || com_api_type_pkg.pad_char(' ', 12, 12);
    else
        l_line := l_line || com_api_type_pkg.pad_char(i_fin_message.business_format_code, 1, 1);
        l_line := l_line || com_api_type_pkg.pad_char(i_fin_message.token_assurance_level, 2, 2);
        l_line := l_line || com_api_type_pkg.pad_char(' ', 9, 9);
    end if;

    l_line := l_line || lpad(nvl(i_fin_message.chargeback_ref_num, '0'), 6, '0');
    l_line := l_line ||      nvl(i_fin_message.docum_ind, ' ');
    l_line := l_line || com_api_type_pkg.pad_char(i_fin_message.member_msg_text, 50, 50);

    if l_visa_dialect = vis_api_const_pkg.VISA_DIALECT_TIETO then
        l_line := l_line || com_api_type_pkg.pad_char(' ', 6, 6);
    else
        l_line := l_line || lpad(nvl(i_fin_message.spec_cond_ind, ' '), 2);
        l_line := l_line || com_api_type_pkg.pad_char(i_fin_message.fee_program_ind, 3, 3);
        l_line := l_line || com_api_type_pkg.pad_char(i_fin_message.issuer_charge, 1, 1);
    end if;

    l_line := l_line || com_api_type_pkg.pad_char(' ', 1, 1); -- reserved filler
    l_line := l_line || com_api_type_pkg.pad_char(i_fin_message.merchant_number, 15, 15);
    l_line := l_line || com_api_type_pkg.pad_char(i_fin_message.terminal_number, 8, 8);

    if l_visa_dialect = vis_api_const_pkg.VISA_DIALECT_TIETO then
        l_line := l_line || '000000000000';
    else
        l_line := l_line || lpad(nvl(i_fin_message.national_reimb_fee, '0'), 12, '0');
    end if;

    l_line := l_line || nvl(i_fin_message.electr_comm_ind, ' ');
    l_line := l_line || nvl(i_fin_message.spec_chargeback_ind, ' ');

    l_line := l_line || '0000'; -- Conversion date constant
    l_line := l_line || '00';   -- Reserved

    l_line := l_line || nvl(i_fin_message.unatt_accept_term_ind, ' ');

    if l_visa_dialect = vis_api_const_pkg.VISA_DIALECT_TIETO then
        l_line := l_line || '     000';
        l_line := l_line || com_api_type_pkg.pad_char(' ', 25, 25);
    else
        l_line := l_line ||      nvl(i_fin_message.prepaid_card_ind, ' ');
        l_line := l_line ||      nvl(i_fin_message.service_development, '0');
        l_line := l_line ||      nvl(i_fin_message.avs_resp_code, ' ');
        l_line := l_line ||      nvl(i_fin_message.auth_source_code, ' ');
        l_line := l_line ||      nvl(i_fin_message.purch_id_format, ' ');
        l_line := l_line ||      nvl(i_fin_message.account_selection, ' ');
        l_line := l_line || '  '; -- installment payment count not applicable
        l_line := l_line || rpad(nvl(i_fin_message.purch_id, ' '), 25);
    end if;

    l_line := l_line || lpad(nvl(i_fin_message.cashback, '0'), 9, '0');
    l_line := l_line ||      nvl(i_fin_message.chip_cond_code, ' ');
    l_line := l_line ||      nvl(i_fin_message.pos_environment, ' ');

    if l_line is not null then
        prc_api_file_pkg.put_line(
            i_raw_data      => convert_data(i_data => l_line)
          , i_sess_file_id  => i_session_file_id
        );
        io_batch.tcr_total := io_batch.tcr_total + 1;
        --dbms_output.put_line('dr:'||io_batch.tcr_total||':'||l_line);
    end if;


    --------------------------- TCR3 ------------------------------------
    if i_fin_message.business_format_code_3 in (
           vis_api_const_pkg.INDUSTRY_SPEC_DATA_CREDIT_FUND
         , vis_api_const_pkg.INDUSTRY_SPEC_DATA_PASS_ITINER
       )
    then
        l_line := null;
        if i_fin_message.business_format_code_3 = vis_api_const_pkg.INDUSTRY_SPEC_DATA_PASS_ITINER then
            l_line := l_line || i_fin_message.trans_code;                                        --1-2
            l_line := l_line || i_fin_message.trans_code_qualifier;                              --3
            l_line := l_line || i_fin_message.trans_comp_number_tcr3;                            --4
            l_line := l_line || rpad(' ', 10);                                                   --reserved --5-14
            l_line := l_line || rpad(nvl(i_fin_message.business_application_id_tcr3, ' '), 2);   --15-16
            l_line := l_line || i_fin_message.business_format_code_3;                            --17-18
            l_line := l_line || rpad(' ', 8);                                                    --reserved --19-26
            l_line := l_line || rpad(nvl(i_fin_message.passenger_name, ' '), 20);                --27-46
            l_line := l_line || to_char(i_fin_message.departure_date, 'MMDDYY');                 --47-52
            l_line := l_line || rpad(nvl(i_fin_message.orig_city_airport_code, ' '), 3);         --53-55
                                                                                                 --56-62 Trip Leg1 Information
            l_line := l_line || rpad(nvl(i_fin_message.carrier_code_1, ' '), 2);                   --56-57
            l_line := l_line || nvl(i_fin_message.service_class_code_1, ' ');                      --58
            l_line := l_line || nvl(i_fin_message.stop_over_code_1, ' ');                          --59
            l_line := l_line || rpad(nvl(i_fin_message.dest_city_airport_code_1, ' '), 3);         --60-62
                                                                                                 --63-69 Trip Leg2 Information
            l_line := l_line || rpad(nvl(i_fin_message.carrier_code_2, ' '), 2);                   --63-64
            l_line := l_line || nvl(i_fin_message.service_class_code_2, ' ');                      --65
            l_line := l_line || nvl(i_fin_message.stop_over_code_2, ' ');                          --66
            l_line := l_line || rpad(nvl(i_fin_message.dest_city_airport_code_2, ' '), 3);         --67-69
                                                                                                 --70-76 Trip Leg3 Information
            l_line := l_line || rpad(nvl(i_fin_message.carrier_code_3, ' '), 2);                   --70-71
            l_line := l_line || nvl(i_fin_message.service_class_code_3, ' ');                      --72
            l_line := l_line || nvl(i_fin_message.stop_over_code_3, ' ');                          --73
            l_line := l_line || rpad(nvl(i_fin_message.dest_city_airport_code_3, ' '), 3);         --74-76
                                                                                                 --77-83 Trip Leg4 Information
            l_line := l_line || rpad(nvl(i_fin_message.carrier_code_4, ' '), 2);                   --77-78
            l_line := l_line || nvl(i_fin_message.service_class_code_4, ' ');                      --79
            l_line := l_line || nvl(i_fin_message.stop_over_code_4, ' ');                          --80
            l_line := l_line || rpad(nvl(i_fin_message.dest_city_airport_code_4, ' '), 3);         --81-83
            l_line := l_line || rpad(nvl(i_fin_message.travel_agency_code, ' '), 8);             --84-91
            l_line := l_line || rpad(nvl(i_fin_message.travel_agency_name, ' '), 25);            --92-116
            l_line := l_line || nvl(i_fin_message.restrict_ticket_indicator, ' ');               --117
            l_line := l_line || rpad(nvl(i_fin_message.fare_basis_code_1, ' '), 6);              --118-123
            l_line := l_line || rpad(nvl(i_fin_message.fare_basis_code_2, ' '), 6);              --124-129
            l_line := l_line || rpad(nvl(i_fin_message.fare_basis_code_3, ' '), 6);              --130-135
            l_line := l_line || rpad(nvl(i_fin_message.fare_basis_code_4, ' '), 6);              --136-141
            l_line := l_line || rpad(nvl(i_fin_message.comp_reserv_system, ' '), 4);             --142-145
            l_line := l_line || rpad(nvl(i_fin_message.flight_number_1, ' '), 5);                --146-150
            l_line := l_line || rpad(nvl(i_fin_message.flight_number_2, ' '), 5);                --151-155
            l_line := l_line || rpad(nvl(i_fin_message.flight_number_3, ' '), 5);                --156-160
            l_line := l_line || rpad(nvl(i_fin_message.flight_number_4, ' '), 5);                --161-165
            l_line := l_line || nvl(i_fin_message.credit_reason_indicator, ' ');                 --166
            l_line := l_line || nvl(i_fin_message.ticket_change_indicator, ' ');                 --167
            l_line := l_line || ' ';                                                             --reserved --168
        elsif i_fin_message.business_format_code_3 = vis_api_const_pkg.INDUSTRY_SPEC_DATA_CREDIT_FUND then
            l_line := l_line || i_fin_message.trans_code;                                   --1-2
            l_line := l_line || i_fin_message.trans_code_qualifier;                         --3
            l_line := l_line || '3';                                                        --4
            l_line := l_line || rpad(' ', 11);                                              --reserved --5-15
            l_line := l_line || nvl(i_fin_message.fast_funds_indicator, ' ');               --16
            l_line := l_line || rpad(nvl(i_fin_message.business_format_code_3, ' '), 2);    --17-18
            l_line := l_line || rpad(nvl(i_fin_message.business_application_id, ' '), 2);   --19-20
            l_line := l_line || nvl(i_fin_message.source_of_funds, '3');                    --21
            if i_fin_message.trans_code in (vis_api_const_pkg.TC_SALES
                                          , vis_api_const_pkg.TC_VOUCHER
                                          , vis_api_const_pkg.TC_SALES_CHARGEBACK
                                          , vis_api_const_pkg.TC_VOUCHER_CHARGEBACK
                                          , vis_api_const_pkg.TC_SALES_REVERSAL
                                          , vis_api_const_pkg.TC_VOUCHER_REVERSAL
                                          , vis_api_const_pkg.TC_SALES_CHARGEBACK_REV
                                          , vis_api_const_pkg.TC_VOUCHER_CHARGEBACK_REV) then
                l_line := l_line || rpad(' ', 147);                                             --22-168
            else
                l_line := l_line || rpad(nvl(i_fin_message.payment_reversal_code, ' '), 2);     --22-23
                l_line := l_line || rpad(nvl(i_fin_message.sender_reference_number, ' '), 16);  --24-39
                l_line := l_line || rpad(nvl(i_fin_message.sender_account_number, ' '), 34);    --40-73
                l_line := l_line || rpad(nvl(i_fin_message.sender_name, ' '), 30);              --74-103
                l_line := l_line || rpad(nvl(i_fin_message.sender_address, ' '), 35);           --104-138
                l_line := l_line || rpad(nvl(i_fin_message.sender_city, ' '), 25);              --139-163
                l_line := l_line || rpad(nvl(i_fin_message.sender_state, ' '), 2);              --164-165
                l_line := l_line || rpad(nvl(i_fin_message.sender_country, ' '), 3);            --166-168
            end if;
        end if;
        if l_line is not null then
            prc_api_file_pkg.put_line(
                i_raw_data      => convert_data(i_data => l_line)
              , i_sess_file_id  => i_session_file_id
            );
            io_batch.tcr_total := io_batch.tcr_total + 1;
        end if;
    end if;

    --------------------------- TCR4 ------------------------------------
    if (i_fin_message.agent_unique_id is not null
        or (
            i_fin_message.trans_code = vis_api_const_pkg.TC_CASH
            and nvl(i_fin_message.surcharge_amount, 0) != 0
            and i_fin_message.mcc = vis_api_const_pkg.MCC_CASH
        ))
        and i_fin_message.usage_code != '9'  
    then
        l_line := null;
        l_line := l_line || i_fin_message.trans_code;
        l_line := l_line || i_fin_message.trans_code_qualifier;
        l_line := l_line || '4';
        l_line := l_line || com_api_type_pkg.pad_char(nvl(i_fin_message.agent_unique_id, ' '), 5, 5); -- 5-9
        l_line := l_line || com_api_type_pkg.pad_char(' ', 5, 5); -- reserved, 10-14
        l_line := l_line || 'SD'; -- Business Format Code
        l_line := l_line || com_api_type_pkg.pad_number(nvl(i_fin_message.network_code, '0002'), 4, 4); -- Network Identification Code
        l_line := l_line || com_api_type_pkg.pad_char(' ', 25, 25); -- Contact Information
        l_line := l_line || ' '; -- Adjustment Processing Indicator
        l_line := l_line || com_api_type_pkg.pad_char(' ', 4, 4); -- Message Reason Code
        l_line := l_line || com_api_type_pkg.pad_number(i_fin_message.surcharge_amount, 8, 8); -- Surcharge Amount
        l_line := l_line
               || nvl(
                    i_fin_message.surcharge_sign
                  , case -- Surcharge Credit/Debit Indicator
                    when nvl(i_fin_message.surcharge_amount, 0) = 0 then
                        com_api_type_pkg.pad_char(' ', 2, 2)
                    when i_fin_message.oper_request_amount > i_fin_message.oper_amount - i_fin_message.surcharge_amount then
                        'CR'
                    else
                        'DB'
                    end
                  );
        l_line := l_line || com_api_type_pkg.pad_char(' ', 16, 16); -- Visa Internal Use Only
        l_line := l_line || com_api_type_pkg.pad_char(' ', 27, 27); -- Reserved
        l_line := l_line || com_api_type_pkg.pad_number(i_fin_message.surcharge_amount, 8, 8); -- Surcharge Amount in Cardholder Billing Currency
        l_line := l_line || com_api_type_pkg.pad_number('0', 8, 8); -- Money Transfer Foreign Exchange Fee
        l_line := l_line || com_api_type_pkg.pad_char(nvl(i_fin_message.payment_acc_ref, ' '), 29, 29); -- Payment Account Reference
        l_line := l_line || com_api_type_pkg.pad_char(nvl(i_fin_message.token_requestor_id, ' '), 11, 11); -- Token Requestor ID
        l_line := l_line || com_api_type_pkg.pad_char(' ', 9, 9); -- Reserved

        if l_line is not null then
            prc_api_file_pkg.put_line(
                i_raw_data      => convert_data(i_data => l_line)
              , i_sess_file_id  => i_session_file_id
            );
            io_batch.tcr_total := io_batch.tcr_total + 1;
        end if;
    elsif i_fin_message.trans_code in (vis_api_const_pkg.TC_SALES
                                     , vis_api_const_pkg.TC_VOUCHER
                                     , vis_api_const_pkg.TC_CASH
                                     , vis_api_const_pkg.TC_SALES_CHARGEBACK
                                     , vis_api_const_pkg.TC_VOUCHER_CHARGEBACK
                                     , vis_api_const_pkg.TC_CASH_CHARGEBACK
                                     , vis_api_const_pkg.TC_SALES_REVERSAL
                                     , vis_api_const_pkg.TC_VOUCHER_REVERSAL
                                     , vis_api_const_pkg.TC_CASH_REVERSAL
                                     , vis_api_const_pkg.TC_SALES_CHARGEBACK_REV
                                     , vis_api_const_pkg.TC_VOUCHER_CHARGEBACK_REV
                                     , vis_api_const_pkg.TC_CASH_CHARGEBACK_REV)
          and i_fin_message.usage_code = '9'                                         -- Visa Claims Resolution
    then
        l_line := null;
        l_line := l_line || i_fin_message.trans_code;
        l_line := l_line || i_fin_message.trans_code_qualifier;
        l_line := l_line || '4';
        l_line := l_line || com_api_type_pkg.pad_char(nvl(i_fin_message.agent_unique_id, ' '), 5, 5); -- 5-9
        l_line := l_line || com_api_type_pkg.pad_char(' ', 5, 5); -- reserved, 10-14
        l_line := l_line || 'DF'; -- Business Format Code, 15-16
        l_line := l_line || com_api_type_pkg.pad_number(nvl(i_fin_message.network_code, '0002'), 4, 4); -- Network Identification Code, 17-20
        l_line := l_line || com_api_type_pkg.pad_char(' ', 25, 25); -- Contact Information, 21-45 
        l_line := l_line || ' '; -- Adjustment Processing Indicator, 46
        l_line := l_line || com_api_type_pkg.pad_char(nvl(substr(i_fin_message.message_reason_code, -4), ' '), 4, 4); -- Message Reason Code, 47-50
        l_line := l_line || com_api_type_pkg.pad_char(nvl(i_fin_message.dispute_condition, ' '), 3, 3); -- Dispute Condition, 51-53
        l_line := l_line || com_api_type_pkg.pad_char(nvl(i_fin_message.vrol_financial_id, ' '), 11, 11); -- VROL Financial ID, 54-64
        l_line := l_line || com_api_type_pkg.pad_char(nvl(i_fin_message.vrol_case_number, ' '), 10, 10); -- VROL Case Number, 65-74
        l_line := l_line || com_api_type_pkg.pad_char(nvl(i_fin_message.vrol_bundle_number, ' '), 10, 10); -- VROL Bundle Case Number, 75-84
        l_line := l_line || com_api_type_pkg.pad_char(nvl(i_fin_message.client_case_number, ' '), 20, 20); -- Client Case Number, 85-104
        l_line := l_line || com_api_type_pkg.pad_char(nvl(i_fin_message.dispute_status, ' '), 2, 2); -- Dispute Status, 105-106
        l_line := l_line || com_api_type_pkg.pad_number(i_fin_message.surcharge_amount, 8, 8); -- Surcharge Amount, 107-114
        l_line := l_line
               || case -- Surcharge Credit/Debit Indicator, 115-116
                      when nvl(i_fin_message.surcharge_amount, 0) = 0 then
                          com_api_type_pkg.pad_char(' ', 2, 2)
                      when i_fin_message.oper_request_amount > i_fin_message.oper_amount - i_fin_message.surcharge_amount then
                          'CR'
                      else
                          'DB'
                  end;
        l_line := l_line || com_api_type_pkg.pad_char(' ', 52, 52); -- Reserved, 117-168

        if l_line is not null then
            prc_api_file_pkg.put_line(
                i_raw_data      => convert_data(i_data => l_line)
              , i_sess_file_id  => i_session_file_id
            );
            io_batch.tcr_total := io_batch.tcr_total + 1;
        end if;
    end if;

    --------------------------- TCR5 ------------------------------------
    --if i_fin_message.pos_entry_mode in ('05', '07') or l_visa_dialect = vis_api_const_pkg.VISA_DIALECT_OPENWAY then
        l_line := null;
        l_line := l_line || i_fin_message.trans_code;
        l_line := l_line || i_fin_message.trans_code_qualifier;
        l_line := l_line || '5';

        -- transaction identifier
        if l_visa_dialect = vis_api_const_pkg.VISA_DIALECT_OPENWAY Then
            l_line := l_line || rpad(nvl(i_fin_message.transaction_id, '0'), 15, '0');
        elsif l_visa_dialect = vis_api_const_pkg.VISA_DIALECT_TIETO then
            l_line := l_line || rpad('0', 15, '0');
        else
            l_line := l_line || rpad(nvl(i_fin_message.transaction_id, '0'), 15, '0');
        end if;

        -- if currency exponent equal to zero then append two zeros in accordance with VISA rules
        if com_api_currency_pkg.get_currency_exponent(nvl(i_fin_message.auth_currency, i_fin_message.oper_currency)) = 0 then
            l_line := l_line || lpad(nvl(nvl(i_fin_message.auth_amount, i_fin_message.oper_amount), '0'), 10, '0') || '00';
        else
            l_line := l_line || lpad(nvl(nvl(i_fin_message.auth_amount, i_fin_message.oper_amount), '0'), 12, '0');
        end if;

        l_line := l_line || rpad(nvl(nvl(i_fin_message.auth_currency, i_fin_message.oper_currency), ' '), 3);

        l_line := l_line || rpad(nvl(i_fin_message.auth_resp_code, ' '), 2);

        if l_visa_dialect = vis_api_const_pkg.VISA_DIALECT_TIETO then
            l_line := l_line || lpad(' ', 8);
            l_line := l_line || lpad('0', 4, '0');
            l_line := l_line || ' ';
            l_line := l_line || lpad('0', 12, '0');
            l_line := l_line || 'N';
            l_line := l_line || lpad(' ', 106);
        else
            l_line := l_line || rpad(nvl(i_fin_message.validation_code, ' '), 4);       -- validation code
            l_line := l_line || ' ';                                                    -- excluded trans. identifier reason
            l_line := l_line || lpad(' ', 3);                                           -- reserved
            l_line := l_line || lpad('0', 2, '0');                                      -- mult. clearing seq. number
            l_line := l_line || lpad('0', 2, '0');                                      -- mult. clearing seq. count
            l_line := l_line || ' ';                                                    -- market-specific auth. data indicator

            -- if currency exponent equal to zero then append two zeros in accordance with VISA rules
            if com_api_currency_pkg.get_currency_exponent(nvl(i_fin_message.auth_currency, i_fin_message.oper_currency)) = 0 then
                l_line := l_line || lpad(nvl(nvl(i_fin_message.auth_amount, i_fin_message.oper_amount), '0'), 10, '0') || '00'; -- total authorized amount
            else
                l_line := l_line || lpad(nvl(nvl(i_fin_message.auth_amount, i_fin_message.oper_amount), '0'), 12, '0');         -- total authorized amount
            end if;

            l_line := l_line || 'N';                                                    -- information indicator
            l_line := l_line || rpad(' ', 14);                                          -- merchant tel. number
            l_line := l_line || ' ';                                                    -- additional data indicator
            l_line := l_line || lpad(' ', 2);                                           -- merchant volume indicator 78-79
            l_line := l_line || lpad(' ', 2);                                           -- Electronic Commerce Goods Indicator 80-81
            l_line := l_line || lpad(nvl(i_fin_message.merchant_verif_value, ' '), 10); -- merchant verification value 82-91
            l_line := l_line || lpad('0', 15, '0');                                     -- Interchange Fee Amount 92-106
            l_line := l_line || ' ';                                                    -- Interchange Fee Sign 107
            l_line := l_line || lpad('0', 8, '0');                                      -- Source Currency to Base Currency Exchange Rate 108-115
            l_line := l_line || lpad('0', 8, '0');                                      -- Base Currency to Destination Currency Exchange Rate 116-123
            l_line := l_line || lpad('0', 12, '0');                                     -- Optional Issuer ISA Amount 124-135
            l_line := l_line || rpad(nvl(i_fin_message.product_id, ' '), 2);            -- Product ID 136-137
            l_line := l_line || lpad(' ', 6);                                           -- Program ID 138-143
            l_line := l_line || nvl(case
                                        when i_fin_message.dcc_indicator = '0'
                                        then null
                                        else i_fin_message.dcc_indicator
                                    end, ' ');                                          -- DCC Indicator 144
            l_line := l_line || lpad(' ', 4);                                           -- Reserved 145-148
            l_line := l_line || lpad(nvl(i_fin_message.spend_qualified_ind, ' '), 1);   -- Spend Qualified Indicator 149
            l_line := l_line || lpad(nvl(to_char(case
                                                     when i_fin_message.pan_token = 0
                                                     then null
                                                     else i_fin_message.pan_token
                                                 end
                                         )
                                       , '0'
                                     )
                                  , 16
                                  , '0'
                                );                                                      -- PAN Token 150-165
            l_line := l_line || lpad(' ', 2);                                           -- Reserved 166-167
            l_line := l_line || nvl(i_fin_message.cvv2_result_code, ' ');               -- CVV2 result code 168
        end if;

        if l_line is not null then
            prc_api_file_pkg.put_line(
                i_raw_data      => convert_data(i_data => l_line)
              , i_sess_file_id  => i_session_file_id
            );
            io_batch.tcr_total := io_batch.tcr_total + 1;
            --dbms_output.put_line('dr:'||io_batch.tcr_total||':'||l_line);
        end if;

    --end if;

    --------------------------- TCR7 ------------------------------------
    if i_fin_message.pos_entry_mode in ('05', '07') and l_visa_dialect <> vis_api_const_pkg.VISA_DIALECT_TIETO then
        l_line := null;
        l_line := l_line || i_fin_message.trans_code;
        l_line := l_line || i_fin_message.trans_code_qualifier;
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
        l_line := l_line || rpad(nvl(i_fin_message.term_verif_result, ' '), 10);
        l_line := l_line || rpad(nvl(i_fin_message.card_verif_result, ' '), 8);                 -- byte 4-7
        l_line := l_line || lpad(nvl(i_fin_message.cryptogram_amount, '0'), 12, '0');
        l_line := l_line || rpad(nvl(substr(i_fin_message.issuer_appl_data, 15, 2), ' '), 2);   -- byte 8
        l_line := l_line || rpad(nvl(substr(i_fin_message.issuer_appl_data, 17, 16), ' '), 16); -- bytes 9-16
        l_line := l_line || rpad(nvl(substr(i_fin_message.issuer_appl_data, 1, 2), ' '), 2);    -- byte 1
        l_line := l_line || rpad(nvl(substr(i_fin_message.issuer_appl_data, 33, 2), ' '), 2);   -- byte 17
        l_line := l_line || rpad(nvl(substr(i_fin_message.issuer_appl_data, 35, 30), ' '), 30); -- bytes 18-32
        l_line := l_line || lpad(nvl(i_fin_message.form_factor_indicator, lpad(' ', 8, ' ')), 8, '0'); 
        l_line := l_line || rpad(nvl(i_fin_message.issuer_script_result, ' '), 10);

        if l_line is not null then
            prc_api_file_pkg.put_line(
                i_raw_data      => convert_data(i_data => l_line)
              , i_sess_file_id  => i_session_file_id
            );
            io_batch.tcr_total := io_batch.tcr_total + 1;
            --dbms_output.put_line('dr:'||io_batch.tcr_total||':'||l_line);
        end if;

    end if;

    --------------------------- TCR8 ------------------------------------
    if l_visa_dialect = vis_api_const_pkg.VISA_DIALECT_OPENWAY  then
        l_line := null;
        --Transaction Code
        l_line := l_line || i_fin_message.trans_code;
        --Transaction Component Sequence Number
        l_line := l_line || '0';
        l_line := l_line || '8';
        --Transaction Date
        l_line := l_line || to_char(l_operation_date, 'YYYYMMDD');
        --Transaction Time
        l_line := l_line || to_char(l_operation_date, 'HH24MISS');
        --Retrieval Reference Number
        l_line := l_line || case when length(nvl(i_fin_message.rrn, ' ')) < 12 then
                                 rpad (nvl(i_fin_message.rrn, ' '), 12, ' ')
                                 else substr(i_fin_message.rrn, -12)
                            end;
        --Card Expiration Date
        l_line := l_line || rpad(nvl(i_fin_message.card_expir_date, '0'), 4, '0');
        --Card Sequence Number
        l_line := l_line || lpad(nvl(i_fin_message.card_seq_number, '0'), 3, '0');
        --Card Acceptor Terminal Identification
        l_line := l_line || rpad(nvl(i_fin_message.terminal_number, ' '), 8, ' ');
        --Card Acceptor Identification Code
        l_line := l_line || rpad(nvl(i_fin_message.merchant_number, ' '), 15, ' ');
        --PAN Length
        l_line := l_line || lpad(nvl(length(i_fin_message.card_number), '0'), 2, '0');
        --Chargeback Reason Code
        l_line := l_line || rpad(nvl(i_fin_message.chargeback_reason_code, ' '), 4, ' ');
        --Destination Channel
        l_line := l_line || rpad(' ', 1, ' ');
        --Source Channel
        l_line := l_line || rpad(' ', 1, ' ');
        --Source Member ID
        l_line := l_line || rpad(nvl(i_fin_message.acquirer_bin, ' '), 12, ' ');

        --Cryptogram Information Data    If this information is not available this field must be space filled (2).
        l_line := l_line || rpad(nvl(i_fin_message.cryptogram_info_data, ' '), 2, ' ');

        --Issuer Application Data Length    If this information is not available this field must be space filled (2).
        l_line := l_line || lpad(nvl(lpad(length(i_fin_message.issuer_appl_data), 2, '0'), ' ') , 2, ' ');
        --Merchant Location.
        l_line := l_line || rpad(nvl(i_fin_message.merchant_street, ' '), 30, ' ');
        --Merchant Postal Code.
        l_line := l_line || rpad(nvl(i_fin_message.merchant_postal_code, ' '), 10, ' ');
        --MasterCard Service Restriction Code.
        l_line := l_line || rpad(nvl(i_fin_message.service_code, ' '), 3, ' ');
        --Reserved    This field must be space filled (41)
        l_line := l_line || rpad(' ', 41, ' ');

        if l_line is not null then
            prc_api_file_pkg.put_line(
                i_raw_data      => convert_data(i_data => l_line)
              , i_sess_file_id  => i_session_file_id
            );
            io_batch.tcr_total := io_batch.tcr_total + 1;
            --dbms_output.put_line('dr:'||io_batch.tcr_total||':'||l_line);
        end if;

    end if;

    case i_fin_message.business_format_code_e
    -- Visa Europe V.me by Visa Data
    when 'JA' then
        l_line := null;
        --Transaction Code
        l_line := l_line || i_fin_message.trans_code;
        --Transaction Code Qualifier
        l_line := l_line || '0';
        --Transaction Component Sequence Number
        l_line := l_line || 'E';
        --Business Format Code
        l_line := l_line || 'JA';
        --Agent Unique ID
        l_line := l_line || rpad(nvl(i_fin_message.agent_unique_id, 'a9001'), 5, ' ');
        --12-13  2  AN  Additional Authentication Method
        l_line := l_line || rpad(nvl(i_fin_message.additional_auth_method, ' '), 2, ' ');
        --14-15  2  AN  Additional Authentication Reason Code
        l_line := l_line || rpad(nvl(i_fin_message.additional_reason_code, ' '), 2, ' ');
        --Reserved
        l_line := l_line || rpad(' ', 153, ' ');

        if l_line is not null then
            prc_api_file_pkg.put_line(
                i_raw_data      => convert_data(i_data => l_line)
              , i_sess_file_id  => i_session_file_id
            );
            io_batch.tcr_total := io_batch.tcr_total + 1;
        --dbms_output.put_line('dr:'||io_batch.tcr_total||':'||l_line);
        end if;
    else
        null;
    end case;

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

    if i_create_disp_case = com_api_const_pkg.TRUE then
        declare
            l_msg_type      com_api_type_pkg.t_dict_value;
        begin
            select msg_type
              into l_msg_type
              from opr_operation
             where id = i_fin_message.id;

            vis_api_dispute_pkg.change_case_status(
                i_dispute_id        => i_fin_message.dispute_id
              , i_usage_code        => i_fin_message.usage_code
              , i_trans_code        => i_fin_message.trans_code
              , i_reason_code       => i_fin_message.reason_code
              , i_msg_status        => net_api_const_pkg.CLEARING_MSG_STATUS_UPLOADED
              , i_dispute_condition => i_fin_message.dispute_condition
              , i_msg_type          => l_msg_type
              , i_is_reversal       => i_fin_message.is_reversal
            );
        exception
            when no_data_found then
                trc_log_pkg.debug(
                    i_text       => 'Message type not found for op [#1]'
                  , i_env_param1 => i_fin_message.id
                );
        end;
    end if;
    trc_log_pkg.debug('process_draft end');

end;

procedure process_returned (
    i_fin_message            in vis_api_type_pkg.t_visa_fin_mes_fraud_rec
    , i_session_file_id      in com_api_type_pkg.t_long_id
) is
begin
    null;
end;

procedure process_money_transfer (
    i_fin_message            in vis_api_type_pkg.t_visa_fin_mes_fraud_rec
    , i_session_file_id      in com_api_type_pkg.t_long_id
) is
begin
    null;
end;

procedure process_fee_funds (
    i_fin_message            in vis_api_type_pkg.t_visa_fin_mes_fraud_rec
    , i_session_file_id      in com_api_type_pkg.t_long_id
    , io_batch               in out vis_api_type_pkg.t_visa_batch_rec
) is
    VISA_REASON_SEND_CARD_NUMBER  constant com_api_type_pkg.t_short_id := 10000049;

    l_fee_rec                vis_api_type_pkg.t_fee_rec;
    l_line                   com_api_type_pkg.t_text;
    l_reason_code            com_api_type_pkg.t_mcc;
    l_country_code           com_api_type_pkg.t_curr_code;
    
begin
    vis_api_fin_message_pkg.get_fee (
        i_id         => i_fin_message.id
        , o_fee_rec  => l_fee_rec
    );

    if l_fee_rec.id is null then
        return; --raise error?
    end if;

    --------------------------- TCR0 ------------------------------------
    l_line :=
    -- Transaction Code
    i_fin_message.trans_code
    -- Transaction Code Qualifier
    || '0'
    -- Transaction Component Sequence Number
    || '0'
    -- Destination BIN
    || rpad(nvl(l_fee_rec.dst_bin, ' '), 6, ' ')
    -- Source BIN
    || rpad(nvl(l_fee_rec.src_bin, ' '), 6, ' ')
    -- Reason Code
    || lpad(nvl(l_fee_rec.reason_code, '0'), 4, '0');
        
    l_reason_code := lpad(nvl(l_fee_rec.reason_code, '0'), 4, '0');
    
    trc_log_pkg.debug(
        i_text          => 'l_reason_code=' || l_reason_code
    );
    
    -- Country Code
    l_country_code := rpad(nvl(com_api_country_pkg.get_visa_code(l_fee_rec.country_code, com_api_type_pkg.FALSE), ' '), 3);
    if l_reason_code in ('0100', '0300', '0390', '5260') then
    
        l_line := l_line || l_country_code;
    
    else
        l_line := l_line || '   ';    
    end if;    
    
    -- Event Date (MMDD)
    l_line := l_line 
        || nvl(to_char(l_fee_rec.event_date, 'MMDD'), '    ');
    
    -- Account Number
    if com_api_array_pkg.is_element_in_array(
           i_array_id   => VISA_REASON_SEND_CARD_NUMBER
         , i_elem_value => l_reason_code
       ) = com_api_type_pkg.TRUE
    then
        l_line := l_line || rpad(nvl(i_fin_message.card_number, '0'), 19, '0');
    else    
        l_line := l_line || rpad('0', 19, '0');                 
    end if;         
                    
    -- Destination Amount
    l_line := l_line 
    || lpad('0', 12, '0')
    -- Destination Currency Code
    || lpad(' ', 3, ' ')
    -- Source Amount
    || lpad(l_fee_rec.src_amount, 12, '0')
    -- Source Currency Code
    || lpad(nvl(l_fee_rec.src_currency, ' '), 3)
    -- Message Text
    || rpad(nvl(l_fee_rec.message_text, ' '), 70)
    -- Settlement Flag
    || nvl(i_fin_message.settlement_flag, ' ')
    -- Transaction Identifier
    || lpad(nvl(l_fee_rec.trans_id, '0'), 15, '0')
    -- Reserved
    || ' '
    -- Central Processing Date (YDDD)
    || nvl(i_fin_message.central_proc_date, '    ')
    -- Reimbursement Attribute
    || nvl(i_fin_message.reimburst_attr, ' ')
    ;

    if l_line is not null then
        prc_api_file_pkg.put_line(
            i_raw_data        => convert_data(i_data => l_line)
            , i_sess_file_id  => i_session_file_id
        );
        io_batch.tcr_total := io_batch.tcr_total + 1;
    end if;

    io_batch.trans_total    := io_batch.trans_total + 1;
    io_batch.monetary_total := io_batch.monetary_total + 1;
    io_batch.src_amount     := io_batch.src_amount + l_fee_rec.src_amount;
    io_batch.dst_amount     := io_batch.dst_amount + l_fee_rec.pay_amount;
end;

procedure process_retrieval_request (
    i_fin_message            in vis_api_type_pkg.t_visa_fin_mes_fraud_rec
    , i_session_file_id      in com_api_type_pkg.t_long_id
    , io_batch               in out vis_api_type_pkg.t_visa_batch_rec
    , i_create_disp_case     in com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
) is
    l_retrieval_rec          vis_api_type_pkg.t_retrieval_rec;
    l_line                   com_api_type_pkg.t_text;
    
    l_reason_code            com_api_type_pkg.t_byte_char;
    l_seqnum                 com_api_type_pkg.t_seqnum;
begin
    vis_api_fin_message_pkg.get_retrieval (
        i_id               => i_fin_message.id
        , o_retrieval_rec  => l_retrieval_rec
    );
    if l_retrieval_rec.id is null then
        return; --raise error?
    end if;

    --------------------------- TCR0 ------------------------------------
    l_line :=
    -- Transaction Code
    i_fin_message.trans_code -- 52 = Request for Copy
    -- Transaction Code Qualifier
    || '0'
    -- Transaction Component Sequence Number
    || '0'
    -- Account Number
    || rpad(nvl(i_fin_message.card_number, '0'), 19, '0')
    -- Acquirer Reference Number
    || rpad(nvl(i_fin_message.arn,'0'), 23, '0')
    -- Acquirers Business ID
    || lpad(nvl(i_fin_message.acq_business_id,'0'), 8, '0')
    -- Purchase Date
    || nvl(to_char(l_retrieval_rec.purchase_date, 'MMDD'), '    ')
    -- Transaction Amount
    || lpad(nvl(l_retrieval_rec.source_amount,'0'), 12, '0')
    -- Transaction Currency Code
    || lpad(nvl(l_retrieval_rec.source_currency, ' '), 3)
    -- Merchant Name
    || rpad(nvl(i_fin_message.merchant_name, ' '), 25)
    -- Merchant City
    || rpad(nvl(i_fin_message.merchant_city, ' '), 13)
    -- Merchant Country Code
    || rpad(nvl(com_api_country_pkg.get_visa_code(i_fin_message.merchant_country, com_api_type_pkg.FALSE), ' '), 3)
    -- Merchant Category Code
    || rpad(nvl(i_fin_message.mcc, ' '), 4)
    -- U.S. Merchant ZIP Code
    || lpad(nvl(i_fin_message.merchant_postal_code, '0'), 5, '0')
    -- Merchant State/Province Code
    || rpad(nvl(i_fin_message.merchant_region, '   '), 3)
    -- Issuer Control Number
    || rpad('0', 9, '0')
    -- Request Reason Code
    || lpad(nvl(l_retrieval_rec.reason_code, ' '), 2)
    -- Settlement Flag
    || nvl(i_fin_message.settlement_flag, ' ')
    -- National Reimbursement Fee
    || lpad(nvl(l_retrieval_rec.reimb_flag, '0'), 12, '0')
    -- Account Selection
    || nvl(l_retrieval_rec.atm_account_sel, ' ')
    -- Retrieval Request ID
    || lpad(nvl(l_retrieval_rec.req_id, '0'), 12, '0')
    -- Central Processing Date
    || nvl(i_fin_message.central_proc_date, '    ')
    -- Reimbursement Attribute
    || nvl(l_retrieval_rec.reimb_flag, ' ')
    ;

    l_reason_code := substr(l_line, 148, 2);

    if l_line is not null then
        prc_api_file_pkg.put_line(
            i_raw_data        => convert_data(i_data => l_line)
            , i_sess_file_id  => i_session_file_id
        );
        io_batch.tcr_total := io_batch.tcr_total + 1;
    end if;

    --------------------------- TCR1 ------------------------------------
    l_line :=
    -- Transaction Code
    i_fin_message.trans_code -- 52 = Request for Copy
    -- Transaction Code Qualifier
    || '0'
    -- Transaction Component Sequence Number
    || '1'
    -- Reserved
    || rpad(' ', 12)
    -- Fax Number
    || rpad(nvl(l_retrieval_rec.fax_number, ' '), 16, ' ')
    -- Interface Trace Number
    || rpad(' ', 6)
    -- Requested Fulfillment Method
    || nvl(l_retrieval_rec.req_fulfill_method, '0')
    -- Established Fulfillment Method
    || nvl(l_retrieval_rec.used_fulfill_method, '0')
    -- Issuer RFC BIN
    || rpad(nvl(l_retrieval_rec.iss_rfc_bin, '0'), 6, '0')
    -- Issuer RFC Sub-Address
    || rpad(nvl(l_retrieval_rec.iss_rfc_subaddr, '0'), 7, '0')
    -- Issuer Billing Currency Code
    || lpad(nvl(l_retrieval_rec.iss_billing_currency, ' '), 3)
    -- Issuer Billing Transaction Amount
    || lpad(nvl(l_retrieval_rec.iss_billing_amount, 0), 12, '0')
    -- Transaction Identifier
    || lpad(nvl(l_retrieval_rec.transaction_id, '0'), 15, '0')
    -- Excluded Transaction Identifier Reason
    || nvl(l_retrieval_rec.excluded_trans_id_reason, ' ')
    -- CRS Processing Code
    || nvl(l_retrieval_rec.crs_code, ' ')
    -- Multiple Clearing Sequence Number
    || lpad(nvl(l_retrieval_rec.multiple_clearing_seqn, '0'), 2, '0')
    -- PAN Token
    || rpad(nvl(i_fin_message.pan_token, 0), 16, ' ')
    -- Reserved
    || rpad(' ', 65)
    ;

    if l_line is not null then
        prc_api_file_pkg.put_line(
            i_raw_data        => convert_data(i_data => l_line)
            , i_sess_file_id  => i_session_file_id
        );
        io_batch.tcr_total := io_batch.tcr_total + 1;
    end if;

    --------------------------- TCR4 ------------------------------------
    l_line :=
    -- Transaction Code Qualifier
    i_fin_message.trans_code -- 52 = Request for Copy
    -- Transaction Code Qualifier
    || '0'
    -- Transaction Component Sequence Number
    || '4'
    -- AN Reserved
    || rpad(' ', 12)
    -- Network Identification Code
    || lpad(nvl(l_retrieval_rec.product_code, '0'), 4, '0')
    -- Contact for Information
    || rpad(nvl(l_retrieval_rec.contact_info, ' '), 25)
    -- Reserved
    || rpad(' ', 123)
    ;

    if l_line is not null then
        prc_api_file_pkg.put_line(
            i_raw_data        => convert_data(i_data => l_line)
            , i_sess_file_id  => i_session_file_id
        );
        io_batch.tcr_total := io_batch.tcr_total + 1;
    end if;

    io_batch.trans_total := io_batch.trans_total + 1;
    
    if i_create_disp_case = com_api_const_pkg.TRUE then
        
        declare
            l_msg_type      com_api_type_pkg.t_dict_value;
        begin
            select msg_type
              into l_msg_type
              from opr_operation
             where id = i_fin_message.id;
            trc_log_pkg.debug('message type = ' || l_msg_type);
            vis_api_dispute_pkg.change_case_status(
                i_dispute_id        => i_fin_message.dispute_id
              , i_usage_code        => i_fin_message.usage_code
              , i_trans_code        => i_fin_message.trans_code
              , i_reason_code       => i_fin_message.reason_code
              , i_msg_status        => net_api_const_pkg.CLEARING_MSG_STATUS_UPLOADED
              , i_dispute_condition => null
              , i_msg_type          => l_msg_type
              , i_is_reversal       => i_fin_message.is_reversal
            );
        exception
            when no_data_found then
                trc_log_pkg.debug(
                    i_text       => 'Message type not found for op [#1]'
                  , i_env_param1 => i_fin_message.id
                );
        end;
    end if;
    trc_log_pkg.debug('process_retrieval_request end');
    
end;

procedure process_currency_rate (
    i_fin_message            in vis_api_type_pkg.t_visa_fin_mes_fraud_rec
    , i_session_file_id      in com_api_type_pkg.t_long_id
) is
begin
    null;
end;

procedure process_delivery_report (
    i_fin_message            in vis_api_type_pkg.t_visa_fin_mes_fraud_rec
    , i_session_file_id      in com_api_type_pkg.t_long_id
) is
begin
    null;
end;

procedure process_settlement_data (
    i_fin_message            in vis_api_type_pkg.t_visa_fin_mes_fraud_rec
    , i_session_file_id      in com_api_type_pkg.t_long_id
) is
begin
    null;
end;

procedure process_fraud (
    i_fin_message      in      vis_api_type_pkg.t_visa_fin_mes_fraud_rec
  , i_host_id          in      com_api_type_pkg.t_tiny_id
  , i_inst_id          in      com_api_type_pkg.t_inst_id
  , i_standard_id      in      com_api_type_pkg.t_inst_id
  , i_session_file_id  in      com_api_type_pkg.t_long_id
  , io_batch           in out  vis_api_type_pkg.t_visa_batch_rec
) is
    l_visa_dialect     com_api_type_pkg.t_dict_value;
    l_line             com_api_type_pkg.t_text;
    l_param_tab        com_api_type_pkg.t_param_tab;
    l_operation_date   date;
    l_current_date     date := trunc(com_api_sttl_day_pkg.get_sysdate);
begin
    cmn_api_standard_pkg.get_param_value(
        i_inst_id       => i_inst_id
      , i_standard_id   => i_standard_id
      , i_object_id     => i_host_id
      , i_entity_type   => net_api_const_pkg.ENTITY_TYPE_HOST
      , i_param_name    => vis_api_const_pkg.VISA_BASEII_DIALECT
      , o_param_value   => l_visa_dialect
      , i_param_tab     => l_param_tab
    );

    l_operation_date    := get_operation_date(
                               i_visa_dialect    => l_visa_dialect
                             , i_operation_id    => i_fin_message.id
                             , i_oper_date       => i_fin_message.oper_date
                             , i_host_date       => i_fin_message.host_date
                           );

    --------------------------- TCR0 ------------------------------------
    l_line := l_line || i_fin_message.trans_code;  --'40'
    l_line := l_line || '0';
    l_line := l_line || '0';
    l_line := l_line || rpad(nvl(i_fin_message.dest_bin, ' '), 6, ' ');
    l_line := l_line || rpad(nvl(i_fin_message.source_bin, ' '), 6, ' ');
    l_line := l_line || rpad(nvl(i_fin_message.account_number, '0'), 23, '0'); -- why rpad ?, '0'=>' '?
    l_line := l_line || rpad(nvl(i_fin_message.arn, '0'), 23, '0');
    l_line := l_line || rpad(nvl(i_fin_message.acq_business_id, '0'), 8, '0');
    l_line := l_line || rpad(' ', 2, ' '); -- response code
    l_line := l_line || case when l_operation_date is null
                             then '0000'
                             else to_char(l_operation_date, 'MMDD')
                        end;
    l_line := l_line || rpad(nvl(i_fin_message.merchant_name, ' '), 25, ' ');
    l_line := l_line || rpad(nvl(i_fin_message.merchant_city, ' '), 13, ' ');
    l_line := l_line || rpad(nvl(com_api_country_pkg.get_visa_code(
                                     i_country_code => i_fin_message.merchant_country
                                   , i_raise_error  => com_api_type_pkg.FALSE
                                 )
                               , ' ')
                           , 3, ' ');
    l_line := l_line || lpad(nvl(i_fin_message.mcc, '0'), 4, '0');
    l_line := l_line || rpad(nvl(i_fin_message.merchant_region, ' '), 3, ' ');
    l_line := l_line || lpad(nvl(i_fin_message.fraud_amount, '0'), 12, '0');
    l_line := l_line || rpad(nvl(i_fin_message.fraud_currency, ' '), 3, ' ');
    l_line := l_line || nvl(to_char(i_fin_message.vic_processing_date, 'YDDD'), '0000');
    l_line := l_line ||      nvl(substr(i_fin_message.iss_gen_auth, 8, 1), ' ');
    l_line := l_line ||      nvl(substr(i_fin_message.notification_code, 8, 1), ' ');
    l_line := l_line || lpad(nvl(i_fin_message.account_seq_number, '0'), 4, '0');
    l_line := l_line ||      nvl(i_fin_message.reserved, ' '); -- here is 'C'
    l_line := l_line ||      nvl(substr(i_fin_message.fraud_type, 8, 1), ' ');
    l_line := l_line || rpad(nvl(i_fin_message.card_expir_date, ' '), 4, ' ') ;
    l_line := l_line || rpad(nvl(i_fin_message.merchant_postal_code, ' '), 10, ' ');
    l_line := l_line || rpad(nvl(i_fin_message.fraud_inv_status, ' '), 2, ' ');
    l_line := l_line ||      nvl(i_fin_message.reimburst_attr, ' ');

    if l_line is not null then
        prc_api_file_pkg.put_line(
            i_raw_data      => convert_data(i_data => l_line)
          , i_sess_file_id  => i_session_file_id
        );
        io_batch.tcr_total := io_batch.tcr_total + 1;
    end if;

    --------------------------- TCR2 ------------------------------------
    if i_fin_message.addendum_present = 1 then
        l_line := null;
        l_line := l_line || i_fin_message.trans_code;  --'40'
        l_line := l_line || '0';
        l_line := l_line || '2';
        l_line := l_line || rpad(nvl(i_fin_message.transaction_id, '0'), 15, '0');        -- 5-19
        l_line := l_line ||      nvl(i_fin_message.excluded_trans_id_reason, ' ');        -- 20
        l_line := l_line || lpad(nvl(i_fin_message.multiple_clearing_seqn, '0'), 2, '0'); -- 21-22
        l_line := l_line || rpad(nvl(i_fin_message.merchant_number, ' '), 15, ' ');       -- 23-37
        l_line := l_line || rpad(nvl(i_fin_message.terminal_number, ' '), 8, ' ');        -- 38-45
        l_line := l_line || rpad(nvl(i_fin_message.travel_agency_id, ' '), 8, ' ');       -- 46-53
        l_line := l_line ||      nvl(i_fin_message.cashback_ind, ' ');                    -- 54
        l_line := l_line || rpad(nvl(i_fin_message.auth_code, ' '), 6, ' ');              -- 55-60
        l_line := l_line || rpad(nvl(i_fin_message.crdh_id_method, '0'), 1, '0');         -- 61
        l_line := l_line || lpad(nvl(i_fin_message.pos_entry_mode, ' '), 2, '0');         -- 62-63
        l_line := l_line || rpad(nvl(i_fin_message.pos_terminal_cap, '0'), 1, '0' );      -- 64 (t_dict_value?!)
        l_line := l_line ||      nvl(i_fin_message.card_capability, ' ');                 -- 65
        l_line := l_line || rpad(' ', 6, ' ');                                            -- reserved, 66-71
        l_line := l_line || lpad(nvl(i_fin_message.cashback, '0'), 9, '0');               -- 72-80
        l_line := l_line ||      nvl(i_fin_message.crdh_activated_term_ind, ' ');         -- 81
        l_line := l_line ||      nvl(i_fin_message.electr_comm_ind, ' ');                 -- 82
        l_line := l_line || rpad(nvl(i_fin_message.agent_unique_id, ' '), 5, ' ');        -- 83-87

        l_line := l_line || rpad(nvl(i_fin_message.fraud_payment_account_ref, ' '), 29, ' ');   -- 88-116
        l_line := l_line || rpad(' ', 29, ' ');                                           -- reserved, 117-145
   
        l_line := l_line || rpad(nvl(i_fin_message.pan_token, 0), 16, '0');               -- 146-161
        l_line := l_line || '000'; -- use zeros because PAN Token Extension is not used,     162-164
        l_line := l_line || rpad(' ', 4, ' '); -- network ID: Spaces or 0002 = Visa,         165-168

        if l_line is not null then
            prc_api_file_pkg.put_line(
                i_raw_data      => convert_data(i_data => l_line)
              , i_sess_file_id  => i_session_file_id
            );
            io_batch.tcr_total := io_batch.tcr_total + 1;
        end if;
    end if;

    io_batch.trans_total := io_batch.trans_total + 1;
end process_fraud;

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
            vis_fin_message_vw
        set
            file_id = i_file_id(i)
            , batch_id = i_batch_id(i)
            , record_number = i_rec_num(i)
            , status = net_api_const_pkg.CLEARING_MSG_STATUS_UPLOADED
        where
            id = i_id(i);
end;

procedure mark_fraud_messages (
    i_id                    in com_api_type_pkg.t_number_tab
    , i_file_id             in com_api_type_pkg.t_number_tab
    , i_batch_id            in com_api_type_pkg.t_number_tab
    , i_rec_num             in com_api_type_pkg.t_number_tab
) is
begin
    trc_log_pkg.debug ( i_text => 'Mark fraud messages' );

    forall i in 1..i_id.count
        update
            vis_fraud
        set
            file_id = i_file_id(i)
            , batch_file_id = i_batch_id(i)
            , rec_no = i_rec_num(i)
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
    l_estimated_count         com_api_type_pkg.t_long_id := 0;
    l_processed_count         com_api_type_pkg.t_long_id := 0;
    l_record_count            com_api_type_pkg.t_long_id;

    l_inst_id                 com_api_type_pkg.t_inst_id_tab;
    l_host_inst_id            com_api_type_pkg.t_inst_id_tab;
    l_network_id              com_api_type_pkg.t_network_tab;
    l_host_id                 com_api_type_pkg.t_number_tab;
    l_standard_id             com_api_type_pkg.t_number_tab;
    l_proc_bin_header         com_api_type_pkg.t_dict_value;
    l_param_proc_bin_header   com_api_type_pkg.t_param_tab;

    l_params                  com_api_type_pkg.t_param_tab;

    l_ok_mess_id              com_api_type_pkg.t_number_tab;
    l_batch_id                com_api_type_pkg.t_number_tab;
    l_file_id                 com_api_type_pkg.t_number_tab;
    l_rec_num                 com_api_type_pkg.t_number_tab;

    l_ok_fraud_id             com_api_type_pkg.t_number_tab;
    l_batch_fraud_id          com_api_type_pkg.t_number_tab;
    l_file_fraud_id           com_api_type_pkg.t_number_tab;
    l_rec_fraud_num           com_api_type_pkg.t_number_tab;

    l_last_proc_bin_header    com_api_type_pkg.t_dict_value;
    l_fin_message             vis_api_type_pkg.t_visa_fin_mes_fraud_tab;

    l_session_file_id         com_api_type_pkg.t_long_id;

    l_file                    vis_api_type_pkg.t_visa_file_rec;
    l_batch                   vis_api_type_pkg.t_visa_batch_rec;
    l_trans_code              varchar2(2);
    l_header_writed           boolean := false;
    l_fin_cur                 vis_api_type_pkg.t_visa_fin_fraud_cur;

    procedure register_ok_message(
        i_mess_id               com_api_type_pkg.t_long_id
        , i_batch_id            com_api_type_pkg.t_medium_id
        , i_file_id             com_api_type_pkg.t_long_id
        , i_fraud_id            com_api_type_pkg.t_long_id
    ) is
        i                       binary_integer;
    begin
        if i_fraud_id is null then          -- record from vis_fin_message
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

        mark_fraud_messages (
            i_id          => l_ok_fraud_id
            , i_file_id   => l_file_fraud_id
            , i_batch_id  => l_batch_fraud_id
            , i_rec_num   => l_rec_fraud_num
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
    ) is
    begin
        l_params.delete;
        rul_api_param_pkg.set_param (
            i_name       => 'INST_ID'
            --, i_value    => i_inst_id
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
            o_sess_file_id  => l_session_file_id
            , i_file_type   => vis_api_const_pkg.FILE_TYPE_CLEARING_VISA
            , io_params     => l_params
        );
    end;

begin
    trc_log_pkg.debug (
        i_text  => 'VISA BASEII outgoing clearing start'
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

    -- make estimated count
    for i in 1..l_host_id.count loop                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
        --l_record_count := vis_api_fin_message_pkg.estimate_messages_for_upload (
        l_record_count := vis_api_fin_message_pkg.estimate_fin_fraud_for_upload (
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
            l_last_proc_bin_header := null;
            l_trans_code           := null;
            l_header_writed        := false;

            --vis_api_fin_message_pkg.enum_messages_for_upload (
            vis_api_fin_message_pkg.enum_fin_msg_fraud_for_upload (
                o_fin_cur         => l_fin_cur
                , i_network_id    => l_network_id(i)
                , i_inst_id       => l_inst_id(i)
                , i_host_inst_id  => l_host_inst_id(i)
                , i_start_date    => trunc(i_start_date)
                , i_end_date      => trunc(i_end_date)
            );

            loop
                fetch l_fin_cur bulk collect into l_fin_message limit BULK_LIMIT;
                for j in 1..l_fin_message.count loop

                    vis_cst_outgoing_pkg.process_fin_message(
                        io_fin_message => l_fin_message(j)
                      , i_network_id   => l_network_id(i)
                      , i_host_id      => l_host_id(i)
                      , i_inst_id      => l_inst_id(i)
                      , i_standard_id  => l_standard_id(i)
                    );

                    -- get proc_bin_header
                    rul_api_param_pkg.set_param(
                        i_name         => 'ACQ_PROC_BIN'
                      , i_value        => l_fin_message(j).proc_bin
                      , io_params      => l_param_proc_bin_header
                    );
                    cmn_api_standard_pkg.get_param_value(
                        i_inst_id      => l_inst_id(i)
                      , i_standard_id  => l_standard_id(i)
                      , i_object_id    => l_host_id(i)
                      , i_entity_type  => net_api_const_pkg.ENTITY_TYPE_HOST
                      , i_param_name   => vis_api_const_pkg.VISA_ACQ_PROC_BIN_HEADER
                      , o_param_value  => l_proc_bin_header
                      , i_param_tab    => l_param_proc_bin_header
                    );
                    l_proc_bin_header := nvl(l_proc_bin_header, l_fin_message(j).proc_bin);

                    if l_header_writed and (l_last_proc_bin_header is not null and l_proc_bin_header != l_last_proc_bin_header) then
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
                    if l_last_proc_bin_header is null or (l_last_proc_bin_header is not null and l_proc_bin_header != l_last_proc_bin_header) then
                        register_session_file (
                            i_inst_id          => l_inst_id(i)
                          , i_network_id       => l_network_id(i)
                          , i_host_inst_id     => l_host_inst_id(i)
                          , i_proc_bin         => l_fin_message(j).proc_bin
                        );

                        process_file_header (
                            i_network_id       => l_network_id(i)
                          , i_proc_bin_header  => l_proc_bin_header
                          , i_proc_bin         => l_fin_message(j).proc_bin
                          , i_inst_id          => l_inst_id(i)
                          , i_standard_id      => l_standard_id(i)
                          , i_host_id          => l_host_id(i)
                          , i_test_option      => i_test_option
                          , i_session_file_id  => l_session_file_id
                          , o_file             => l_file
                        );

                        init_batch (
                            io_batch           => l_batch
                          , i_session_file_id  => l_file.id
                          , i_file_proc_bin    => l_file.proc_bin
                        );

                        l_trans_code           := l_fin_message(j).trans_code;
                        l_last_proc_bin_header := l_proc_bin_header;
                        l_header_writed        := true;
                    end if;

                    -- when new transaction code started put batch trailer
                    if l_trans_code is not null and (l_trans_code != l_fin_message(j).trans_code or l_batch.tcr_total > BATCH_REC_LIMIT) then
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
                            io_batch            => l_batch
                          , i_session_file_id   => l_file.id
                          , i_file_proc_bin     => l_file.proc_bin
                        );
                        l_trans_code := l_fin_message(j).trans_code;
                    end if;

                    -- process returned and rejected transactions
                    if l_fin_message(j).trans_code in (
                        vis_api_const_pkg.TC_RETURNED_CREDIT
                      , vis_api_const_pkg.TC_RETURNED_DEBIT
                      , vis_api_const_pkg.TC_RETURNED_NONFINANCIAL
                    ) then
                        process_returned (
                            i_fin_message        => l_fin_message(j)
                            , i_session_file_id  => l_session_file_id
                        );

                    -- process draft transactions
                    elsif l_fin_message(j).trans_code in (
                        vis_api_const_pkg.TC_SALES
                      , vis_api_const_pkg.TC_VOUCHER
                      , vis_api_const_pkg.TC_CASH
                      , vis_api_const_pkg.TC_SALES_CHARGEBACK
                      , vis_api_const_pkg.TC_VOUCHER_CHARGEBACK
                      , vis_api_const_pkg.TC_CASH_CHARGEBACK
                      , vis_api_const_pkg.TC_SALES_REVERSAL
                      , vis_api_const_pkg.TC_VOUCHER_REVERSAL
                      , vis_api_const_pkg.TC_CASH_REVERSAL
                      , vis_api_const_pkg.TC_SALES_CHARGEBACK_REV
                      , vis_api_const_pkg.TC_VOUCHER_CHARGEBACK_REV
                      , vis_api_const_pkg.TC_CASH_CHARGEBACK_REV
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

                    -- process money transfer transactions
                    elsif l_fin_message(j).trans_code in (
                              vis_api_const_pkg.TC_MONEY_TRANSFER
                            , vis_api_const_pkg.TC_MONEY_TRANSFER2
                          )
                    then
                        process_money_transfer (
                            i_fin_message        => l_fin_message(j)
                            , i_session_file_id  => l_session_file_id
                        );

                    -- process fee collections and funds diburstment
                    elsif l_fin_message(j).trans_code in (
                              vis_api_const_pkg.TC_FEE_COLLECTION
                            , vis_api_const_pkg.TC_FUNDS_DISBURSEMENT
                          )
                    then
                        process_fee_funds (
                            i_fin_message        => l_fin_message(j)
                            , i_session_file_id  => l_session_file_id
                            , io_batch           => l_batch
                        );

                    -- process retrieval requests
                    elsif l_fin_message(j).trans_code in (
                              vis_api_const_pkg.TC_REQUEST_ORIGINAL_PAPER
                            , vis_api_const_pkg.TC_REQUEST_FOR_PHOTOCOPY
                            , vis_api_const_pkg.TC_MAILING_CONFIRMATION
                          )
                    then
                        process_retrieval_request (
                            i_fin_message        => l_fin_message(j)
                            , i_session_file_id  => l_session_file_id
                            , io_batch           => l_batch
                            , i_create_disp_case => i_create_disp_case
                        );

                    -- process currency convertional rate updates
                    elsif l_fin_message(j).trans_code in (vis_api_const_pkg.TC_CURRENCY_RATE_UPDATE) then
                        process_currency_rate(
                            i_fin_message       => l_fin_message(j)
                          , i_session_file_id   => l_session_file_id
                        );

                    -- process general delivery report
                    elsif l_fin_message(j).trans_code in (vis_api_const_pkg.TC_GENERAL_DELIVERY_REPORT) then
                        process_delivery_report (
                            i_fin_message        => l_fin_message(j)
                            , i_session_file_id  => l_session_file_id
                        );

                    -- process member settlement data
                    elsif l_fin_message(j).trans_code in (vis_api_const_pkg.TC_MEMBER_SETTLEMENT_DATA) then
                        process_settlement_data(
                            i_fin_message        => l_fin_message(j)
                            , i_session_file_id  => l_session_file_id
                        );

                    -- process fraud data
                    elsif l_fin_message(j).trans_code in (vis_api_const_pkg.TC_FRAUD_ADVICE) then
                        process_fraud (
                            i_fin_message        => l_fin_message(j)
                            , i_host_id          => l_host_id(i)
                            , i_inst_id          => l_inst_id(i)
                            , i_standard_id      => l_standard_id(i)
                            , i_session_file_id  => l_session_file_id
                            , io_batch           => l_batch
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
        i_text  => 'VISA BASEII outgoing clearing end'
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

procedure process_unload_sms_dispute(
    i_start_date in    date,
    i_end_date   in    date
) is
    l_session_file_id    com_api_type_pkg.t_long_id;
    l_params             com_api_type_pkg.t_param_tab;
    l_processed_count    com_api_type_pkg.t_long_id    := 0;
    l_sysdate            date                          :=  com_api_sttl_day_pkg.get_sysdate;
    l_subscriber_name    com_api_type_pkg.t_name       := 'VIS_PRC_OUTGOING_PKG.PROCESS_UNLOAD_SMS_DISPUTE';
begin
    trc_log_pkg.debug (
        i_text  => 'Unload VISA SMS dispute messages to FE'
    );
    prc_api_file_pkg.open_file (
        o_sess_file_id  => l_session_file_id
      , i_file_type     => vis_api_const_pkg.FILE_TYPE_VSMS_DISPUTE_TO_FE
      , io_params       => l_params
    );

    prc_api_stat_pkg.log_start;

    for rec in (
        select o.id 
             , lpad(to_char(a.external_auth_id, com_api_const_pkg.XML_NUMBER_FORMAT), 9,' ')
            || o.is_reversal 
            || lpad(case 
                    when fm.usage_code = '2'                                            then 'ACQ_REPRESM'
                    when fm.trans_code = vis_api_const_pkg.TC_FEE_COLLECTION            then 'ACQ_FEE_COLL'
                    when fm.trans_code = vis_api_const_pkg.TC_FUNDS_DISBURSEMENT        then 'ACQ_FUND_DISB'
                    when o.oper_type   = opr_api_const_pkg.OPERATION_TYPE_DEBIT_ADJUST  then 'ACQ_DEBADJ_BO'
                    when o.oper_type   = opr_api_const_pkg.OPERATION_TYPE_CREDIT_ADJUST then 'ACQ_CREADJ_BO'
                    when o.is_reversal = com_api_const_pkg.TRUE                         then 'MANUAL_REVERSAL'
                    else '' 
                    end, 20, ' ')
            || lpad(nvl(f.reason_code,' '), 4, ' ') 
            || lpad(to_char(o.oper_amount, com_api_const_pkg.XML_FLOAT_FORMAT), 12, '0') line
          from opr_operation o
             , opr_operation prev_oper
             , aut_auth a
             , vis_fin_message fm
             , vis_fee f
             , evt_event e
             , evt_event_object eo
         where decode(eo.status, 'EVST0001', eo.procedure_name, null) = l_subscriber_name
           and eo.object_id     = o.id 
           and eo.entity_type   = opr_api_const_pkg.ENTITY_TYPE_OPERATION
           and eo.eff_date     >= trunc(i_start_date) and eo.eff_date < trunc(i_end_date) + 1
           and eo.eff_date     <= l_sysdate
           and eo.event_id      = e.id
           and e.event_type     = vis_api_const_pkg.EVENT_TYPE_SMS_DISPUTE_CREATED
           and e.id             = eo.event_id
           and o.dispute_id     = prev_oper.dispute_id
           and a.id             = prev_oper.id
           and fm.id            = o.id
           and f.id(+)          = o.id
          order by o.id
    ) loop
        if rec.line is not null then
            prc_api_file_pkg.put_line(
                i_raw_data      => rec.line
              , i_sess_file_id  => l_session_file_id
            );
            l_processed_count := l_processed_count + 1;
        end if;
    end loop;

    prc_api_file_pkg.close_file(
        i_sess_file_id  => l_session_file_id
      , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
    );

    prc_api_stat_pkg.log_end(
        i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
      , i_processed_total  => l_processed_count
    );
end process_unload_sms_dispute;

end vis_prc_outgoing_pkg;
/
