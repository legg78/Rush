create or replace package body cst_bof_gim_prc_outgoing_pkg as

type t_file_list_rec is record (
    logical_file_code     com_api_type_pkg.t_byte_char
  , is_processed          com_api_type_pkg.t_boolean
);
type t_file_list_tab      is table of t_file_list_rec index by binary_integer;

BULK_LIMIT       constant integer  := 1000;
LINE_LENGTH      constant integer  := 256;

g_default_charset         com_api_type_pkg.t_oracle_name := cst_bof_gim_api_const_pkg.g_default_charset;
g_charset                 com_api_type_pkg.t_oracle_name := cst_bof_gim_api_const_pkg.g_default_charset;
g_adjust_charset          com_api_type_pkg.t_boolean     := case
                                                                when g_charset != g_default_charset
                                                                then com_api_const_pkg.TRUE
                                                                else com_api_const_pkg.FALSE
                                                            end;

function get_rec_header(
    i_trans_code           in     com_api_type_pkg.t_byte_char
  , i_tcr                  in     com_api_type_pkg.t_byte_char
  , io_file                in out cst_bof_gim_api_type_pkg.t_gim_file_rec
) return com_api_type_pkg.t_text is
begin
    io_file.total_phys_records := nvl(io_file.total_phys_records, 0) + 1;
    return i_trans_code || lpad(io_file.total_phys_records, 6, '0') || lpad(i_tcr, 1, '0');
end;

function convert_data(
    i_data            in com_api_type_pkg.t_text
) return com_api_type_pkg.t_text is
begin
    if g_adjust_charset = com_api_const_pkg.TRUE then
        return rpad(convert(i_data, g_charset, g_default_charset), LINE_LENGTH, ' ');
    else
        return rpad(i_data, LINE_LENGTH, ' ');
    end if;
end;

function format_exchange_rate(
    i_rate                 in      number
  , i_field_length         in      com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_exponent
is
    l_str                          com_api_type_pkg.t_exponent;
    l_index                        com_api_type_pkg.t_tiny_id;
begin
    trc_log_pkg.debug(
        i_text => lower($$PLSQL_UNIT) || '.format_exchange_rate(#1, #2)'
      , i_env_param1 => to_char(i_rate, 'TM9', 'NLS_NUMERIC_CHARACTERS = ''.,''')
      , i_env_param2 => i_field_length
    );
    -- Convert number to specific string representation. Example: 1.2204968403(i_field_length = 9) => 712204968
    l_str := lpad(
                 substr(to_char(i_rate, 'TM9', 'NLS_NUMERIC_CHARACTERS = ''.,'''), 1, i_field_length)
               , i_field_length
               , '0'
             );
    l_index := instr(l_str, '.');

    return case
               when l_index = 0
               then 0
               else length(l_str) - l_index
           end
        || substr(replace(l_str, '.'), -(i_field_length - 1));
end;

procedure process_logical_file_header(
    io_file                in out  cst_bof_gim_api_type_pkg.t_gim_file_rec
  , o_logical_file            out  cst_bof_gim_api_type_pkg.t_logical_file_rec
  , i_logical_file_code    in      com_api_type_pkg.t_byte_char
  , i_session_file_id      in      com_api_type_pkg.t_long_id
) is
    l_line                         com_api_type_pkg.t_text;
begin
    -- init new logical file
    o_logical_file.logical_file_code := i_logical_file_code;
    o_logical_file.total_phys_records := 0;
    o_logical_file.total_merchant_credit := 0;
    o_logical_file.total_cash_withdrawal_credit := 0;
    o_logical_file.total_cash_advance_credit := 0;
    o_logical_file.total_tc050607_1 := 0;
    o_logical_file.total_tc05 := 0;
    o_logical_file.total_tc252627_1 := 0;
    o_logical_file.total_tc050607_2 := 0;
    o_logical_file.total_tc252627_2 := 0;
    o_logical_file.total_tc151617_1 := 0;
    o_logical_file.total_tc353637_1 := 0;
    o_logical_file.total_tc151617_2 := 0;
    o_logical_file.total_tc353637_2 := 0;
    o_logical_file.total_tc10_1 := 0;
    o_logical_file.total_tc10_2 := 0;
    o_logical_file.total_tc20_1 := 0;
    o_logical_file.total_tc20_2 := 0;
    o_logical_file.total_tc40 := 0;
    o_logical_file.total_tc48 := 0;
    o_logical_file.total_tc49 := 0;
    o_logical_file.total_tc50_1 := 0;
    o_logical_file.total_tc50_2 := 0;
    o_logical_file.total_tc51 := 0;
    o_logical_file.total_tc52 := 0;
    o_logical_file.total_tc53 := 0;
    o_logical_file.total_tc82 := 0;
    o_logical_file.total_tc46 := 0;
    o_logical_file.total_purchase_credit := 0;
    o_logical_file.total_purchase_debit := 0;
    o_logical_file.total_payment_incident := 0;
    o_logical_file.total_personnalisation := 0;
    o_logical_file.total_card_stand_in_prm := 0;
    o_logical_file.total_account_stand_in_prm := 0;
    o_logical_file.total_card_pers_confirmation := 0;
    o_logical_file.total_renewal_advice := 0;

    l_line :=
        get_rec_header(
            i_trans_code => i_logical_file_code
          , i_tcr        => '0'
          , io_file      => io_file
        );
    l_line := l_line || rpad(' ', 247);

    prc_api_file_pkg.put_line(
        i_raw_data      => convert_data(i_data => l_line)
      , i_sess_file_id  => i_session_file_id
    );
end process_logical_file_header;

procedure process_logical_file_trailer(
    io_file                in out cst_bof_gim_api_type_pkg.t_gim_file_rec
  , io_logical_file        in out cst_bof_gim_api_type_pkg.t_logical_file_rec
  , i_session_file_id      in     com_api_type_pkg.t_long_id
) is
    l_line                   com_api_type_pkg.t_text;
    l_trans_code             com_api_type_pkg.t_byte_char;
begin
    io_logical_file.total_phys_records := io_logical_file.total_phys_records + 1;
    l_trans_code :=
       case io_logical_file.logical_file_code
           when cst_bof_gim_api_const_pkg.TC_FM_HEADER  then cst_bof_gim_api_const_pkg.TC_FM_TRAILER
           when cst_bof_gim_api_const_pkg.TC_FV_HEADER  then cst_bof_gim_api_const_pkg.TC_FV_TRAILER
           when cst_bof_gim_api_const_pkg.TC_FMC_HEADER then cst_bof_gim_api_const_pkg.TC_FMC_TRAILER
           when cst_bof_gim_api_const_pkg.TC_FSW_HEADER then cst_bof_gim_api_const_pkg.TC_FSW_TRAILER
           when cst_bof_gim_api_const_pkg.TC_FL_HEADER  then cst_bof_gim_api_const_pkg.TC_FL_TRAILER
       end;
    l_line :=
        get_rec_header(
            i_trans_code => l_trans_code
          , i_tcr        => '0'
          , io_file      => io_file
        );

    l_line := l_line || lpad(io_logical_file.total_phys_records, 6, '0');
    l_line := l_line || lpad(io_logical_file.total_merchant_credit, 6, '0');
    l_line := l_line || lpad(io_logical_file.total_cash_withdrawal_credit, 6, '0');
    l_line := l_line || lpad(io_logical_file.total_cash_advance_credit, 6, '0');
    l_line := l_line || lpad(io_logical_file.total_tc050607_1, 6, '0');
    l_line := l_line || lpad(io_logical_file.total_tc05, 6, '0');
    l_line := l_line || lpad(io_logical_file.total_tc252627_1, 6, '0');
    l_line := l_line || lpad(io_logical_file.total_tc050607_2, 6, '0');
    l_line := l_line || lpad(io_logical_file.total_tc252627_2, 6, '0');
    l_line := l_line || lpad(io_logical_file.total_tc151617_1, 6, '0');
    l_line := l_line || lpad(io_logical_file.total_tc353637_1, 6, '0');
    l_line := l_line || lpad(io_logical_file.total_tc151617_2, 6, '0');
    l_line := l_line || lpad(io_logical_file.total_tc353637_2, 6, '0');
    l_line := l_line || lpad(io_logical_file.total_tc10_1, 6, '0');
    l_line := l_line || lpad(io_logical_file.total_tc10_2, 6, '0');
    l_line := l_line || lpad(io_logical_file.total_tc20_1, 6, '0');
    l_line := l_line || lpad(io_logical_file.total_tc20_2, 6, '0');
    l_line := l_line || lpad(io_logical_file.total_tc40, 6, '0');
    l_line := l_line || lpad(io_logical_file.total_tc48, 6, '0');
    l_line := l_line || lpad(io_logical_file.total_tc49, 6, '0');
    l_line := l_line || lpad(io_logical_file.total_tc50_1, 6, '0');
    l_line := l_line || lpad(io_logical_file.total_tc50_2, 6, '0');
    l_line := l_line || lpad(io_logical_file.total_tc51, 6, '0');
    l_line := l_line || lpad(io_logical_file.total_tc52, 6, '0');
    l_line := l_line || lpad(io_logical_file.total_tc53, 6, '0');
    l_line := l_line || lpad(io_logical_file.total_tc82, 6, '0');
    l_line := l_line || lpad(io_logical_file.total_tc46, 6, '0');
    l_line := l_line || lpad(io_logical_file.total_purchase_credit, 6, '0');
    l_line := l_line || lpad(io_logical_file.total_purchase_debit, 6, '0');
    l_line := l_line || lpad(io_logical_file.total_payment_incident, 6, '0');
    l_line := l_line || lpad(io_logical_file.total_personnalisation, 6, '0');
    l_line := l_line || lpad(io_logical_file.total_card_stand_in_prm, 6, '0');
    l_line := l_line || lpad(io_logical_file.total_account_stand_in_prm, 6, '0');
    l_line := l_line || lpad(io_logical_file.total_card_pers_confirmation, 6, '0');
    l_line := l_line || lpad(io_logical_file.total_renewal_advice, 6, '0');
    l_line := l_line || rpad(' ', 19);

    prc_api_file_pkg.put_line(
        i_raw_data      => convert_data(i_data => l_line)
      , i_sess_file_id  => i_session_file_id
    );
end process_logical_file_trailer;

procedure register_session_file(
    i_inst_id              in     com_api_type_pkg.t_inst_id
  , i_network_id           in     com_api_type_pkg.t_tiny_id
  , i_host_inst_id         in     com_api_type_pkg.t_inst_id
  , i_proc_bin             in     com_api_type_pkg.t_dict_value
  , i_gim_file_id          in     com_api_type_pkg.t_tag
  , o_session_file_id         out com_api_type_pkg.t_long_id
) is
    l_params                      com_api_type_pkg.t_param_tab;
begin
    l_params.delete;
    rul_api_param_pkg.set_param(
        i_name     => 'INST_ID'
      , i_value    => to_char(i_inst_id)
      , io_params  => l_params
    );
    rul_api_param_pkg.set_param(
        i_name     => 'NETWORK_ID'
      , i_value    => i_network_id
      , io_params  => l_params
    );
    rul_api_param_pkg.set_param(
        i_name     => 'HOST_INST_ID'
      , i_value    => i_host_inst_id
      , io_params  => l_params
    );
    rul_api_param_pkg.set_param(
        i_name     => 'ACQ_BIN'
      , i_value    => i_proc_bin
      , io_params  => l_params
    );
    rul_api_param_pkg.set_param(
        i_name     => 'KEY_INDEX'
      , i_value    => i_proc_bin
      , io_params  => l_params
    );
    rul_api_param_pkg.set_param(
        i_name     => 'FILE_NUMBER'
      , i_value    => i_gim_file_id
      , io_params  => l_params
    );
    prc_api_file_pkg.open_file(
        o_sess_file_id  => o_session_file_id
      , i_file_type     => cst_bof_gim_api_const_pkg.FILE_TYPE_CLEARING_GIM
      , io_params       => l_params
    );
end register_session_file;

procedure process_file_header(
    i_network_id           in     com_api_type_pkg.t_tiny_id
  , i_proc_bin             in     com_api_type_pkg.t_dict_value
  , i_inst_id              in     com_api_type_pkg.t_inst_id
  , i_standard_id          in     com_api_type_pkg.t_inst_id
  , i_host_id              in     com_api_type_pkg.t_tiny_id
  , i_host_inst_id         in     com_api_type_pkg.t_inst_id
  , o_file                    out cst_bof_gim_api_type_pkg.t_gim_file_rec
  , o_session_file_id         out com_api_type_pkg.t_long_id
) is
    l_line                        com_api_type_pkg.t_text;
    l_param_tab                   com_api_type_pkg.t_param_tab;
begin
    o_file.id              := cst_bof_gim_file_seq.nextval;
    o_file.is_incoming     := com_api_type_pkg.FALSE;
    o_file.is_returned     := com_api_type_pkg.FALSE;
    o_file.network_id      := i_network_id;
    o_file.proc_date       := trunc(com_api_sttl_day_pkg.get_sysdate);
    o_file.release_number  := null;
    o_file.proc_bin        := i_proc_bin;

    select nvl(max(to_number(gim_file_id)), 0) + 1
      into o_file.gim_file_id
      from cst_bof_gim_file
     where is_incoming = com_api_type_pkg.FALSE
       and proc_bin    = o_file.proc_bin
       and proc_date   = o_file.proc_date;

    o_file.file_status_ind := ' '; -- Normal
    o_file.inst_id         := i_inst_id;

    o_file.originator_bin :=
        cmn_api_standard_pkg.get_varchar_value(
            i_inst_id       => i_inst_id
          , i_standard_id   => cst_bof_gim_api_const_pkg.GIM_STANDARD_ID
          , i_object_id     => cst_bof_gim_api_const_pkg.GIM_HOST_ID
          , i_entity_type   => net_api_const_pkg.ENTITY_TYPE_HOST
          , i_param_name    => cst_bof_gim_api_const_pkg.ACQ_BUSINESS_ID
          , i_param_tab     => l_param_tab
        );

    trc_log_pkg.debug('originator_bin=' || o_file.originator_bin);

    if o_file.originator_bin is null then
        com_api_error_pkg.raise_error(
              i_error       => 'GIM_ACQ_BUSINESS_ID_NOT_FOUND'
            , i_env_param1  => o_file.inst_id
            , i_env_param2  => i_standard_id
            , i_env_param3  => i_host_id
        );
    end if;

    l_line :=
        get_rec_header(
            i_trans_code => cst_bof_gim_api_const_pkg.TC_FILE_HEADER
          , i_tcr        => '0'
          , io_file      => o_file
        );

    l_line := l_line || lpad(o_file.originator_bin,  6, '0');            -- Originator bank code
    l_line := l_line || to_char(o_file.proc_date,   'DDMMYY');           -- File processing date
    l_line := l_line || lpad(o_file.gim_file_id,     3, '0');            -- File sequence number
    l_line := l_line || rpad(o_file.file_status_ind, 1, ' ');            -- File status indicator
    l_line := l_line || rpad(nvl(o_file.release_number, ' '), 15, ' ');  -- LIS version
    if o_file.proc_bin is null then                                      -- Destination bank code
        l_line := l_line || lpad(nvl(o_file.proc_bin, ' '), 6, ' ');
    else
        l_line := l_line || rpad(o_file.proc_bin, 6, '0');
    end if;
    l_line := l_line || rpad(' ', 210);

    register_session_file(
        i_inst_id           => i_inst_id
      , i_network_id        => i_network_id
      , i_host_inst_id      => i_host_inst_id
      , i_proc_bin          => i_proc_bin
      , i_gim_file_id       => o_file.gim_file_id
      , o_session_file_id   => o_session_file_id
    );

    o_file.session_file_id  := o_session_file_id;

    if l_line is not null then
        prc_api_file_pkg.put_line(
            i_raw_data      => convert_data(
                                   i_data => l_line
                               )
          , i_sess_file_id  => o_session_file_id
        );
    end if;
end;

procedure process_file_trailer(
    io_file                in out  cst_bof_gim_api_type_pkg.t_gim_file_rec
  , i_session_file_id      in      com_api_type_pkg.t_long_id
) is
    l_line                   com_api_type_pkg.t_text;
begin
    l_line :=
        get_rec_header(
            i_trans_code => cst_bof_gim_api_const_pkg.TC_FILE_TRAILER
          , i_tcr        => '0'
          , io_file      => io_file
        );
    l_line := l_line || lpad(io_file.total_phys_records, 6, '0');
    l_line := l_line || lpad(nvl(io_file.total_tc70, 0), 6, '0');
    l_line := l_line || lpad(nvl(io_file.total_tc71, 0), 6, '0');
    l_line := l_line || lpad(nvl(io_file.total_tc72, 0), 6, '0');
    l_line := l_line || lpad(nvl(io_file.total_tc73, 0), 6, '0');
    l_line := l_line || lpad(nvl(io_file.total_tc74_1, 0), 6, '0');
    l_line := l_line || lpad(nvl(io_file.total_tc74_2, 0), 6, '0');
    l_line := l_line || lpad(nvl(io_file.total_tc050607_1, 0), 6, '0');
    l_line := l_line || lpad(nvl(io_file.total_tc050607_2, 0), 6, '0');
    l_line := l_line || lpad(nvl(io_file.total_tc252627_1, 0), 6, '0');
    l_line := l_line || lpad(nvl(io_file.total_tc050607_3, 0), 6, '0');
    l_line := l_line || lpad(nvl(io_file.total_tc252627_2, 0), 6, '0');
    l_line := l_line || lpad(nvl(io_file.total_tc151617_1, 0), 6, '0');
    l_line := l_line || lpad(nvl(io_file.total_tc353637_1, 0), 6, '0');
    l_line := l_line || lpad(nvl(io_file.total_tc151617_2, 0), 6, '0');
    l_line := l_line || lpad(nvl(io_file.total_tc353637_2, 0), 6, '0');
    l_line := l_line || lpad(nvl(io_file.total_tc10_1, 0), 4, '0');
    l_line := l_line || lpad(nvl(io_file.total_tc10_2, 0), 4, '0');
    l_line := l_line || lpad(nvl(io_file.total_tc20_1, 0), 4, '0');
    l_line := l_line || lpad(nvl(io_file.total_tc20_2, 0), 4, '0');
    l_line := l_line || lpad(nvl(io_file.total_tc40, 0), 4, '0');
    l_line := l_line || lpad(nvl(io_file.total_tc48, 0), 4, '0');
    l_line := l_line || lpad(nvl(io_file.total_tc49, 0), 4, '0');
    l_line := l_line || lpad(nvl(io_file.total_tc50_1, 0), 4, '0');
    l_line := l_line || lpad(nvl(io_file.total_tc50_2, 0), 4, '0');
    l_line := l_line || lpad(nvl(io_file.total_tc51, 0), 4, '0');
    l_line := l_line || lpad(nvl(io_file.total_tc52, 0), 4, '0');
    l_line := l_line || lpad(nvl(io_file.total_tc53, 0), 4, '0');
    l_line := l_line || lpad(nvl(io_file.total_tc82, 0), 4, '0');
    l_line := l_line || lpad(nvl(io_file.total_tc46, 0), 4, '0');
    l_line := l_line || lpad(nvl(io_file.total_tc60, 0), 6, '0');
    l_line := l_line || lpad(nvl(io_file.total_tc61, 0), 6, '0');
    l_line := l_line || lpad(nvl(io_file.total_tc62, 0), 6, '0');
    l_line := l_line || lpad(nvl(io_file.total_tc63, 0), 6, '0');
    l_line := l_line || lpad(nvl(io_file.total_tc64, 0), 6, '0');
    l_line := l_line || rpad(' ', 65);

    if l_line is not null then
        prc_api_file_pkg.put_line(
            i_raw_data      => convert_data(i_data => l_line)
          , i_sess_file_id  => i_session_file_id
        );
    end if;

    insert into cst_bof_gim_file (
        id
      , is_incoming
      , network_id
      , proc_bin
      , proc_date
      , release_number
      , gim_file_id
      , originator_bin
      , inst_id
      , session_file_id
      , total_phys_records
    ) values (
        io_file.id
      , io_file.is_incoming
      , io_file.network_id
      , io_file.proc_bin
      , io_file.proc_date
      , io_file.release_number
      , io_file.gim_file_id
      , io_file.originator_bin
      , io_file.inst_id
      , io_file.session_file_id
      , io_file.total_phys_records
    );
end process_file_trailer;

procedure process_draft(
    i_fin_message          in            cst_bof_gim_api_type_pkg.t_gim_fin_mes_rec
  , i_session_file_id      in            com_api_type_pkg.t_long_id
  , io_file                in out nocopy cst_bof_gim_api_type_pkg.t_gim_file_rec
) is
    l_line                               com_api_type_pkg.t_text;
    l_oper_currency_exponent             com_api_type_pkg.t_tiny_id;
    l_dest_currency_exponent             com_api_type_pkg.t_tiny_id;
begin
    l_oper_currency_exponent := com_api_currency_pkg.get_currency_exponent(
                                    i_curr_code => i_fin_message.oper_currency
                                );
    if i_fin_message.dest_currency is not null then
        l_dest_currency_exponent := com_api_currency_pkg.get_currency_exponent(
                                        i_curr_code => i_fin_message.dest_currency
                                    );
    end if;
    --------------------------- TCR0 ------------------------------------
    l_line :=
        get_rec_header(
            i_trans_code => i_fin_message.trans_code
          , i_tcr        => '0'
          , io_file      => io_file
        );

    -- Transaction route indicator; pos 10
    l_line := l_line || rpad(com_api_type_pkg.boolean_not(i_fin_message.is_incoming), 1, ' ');
    l_line := l_line || rpad(i_fin_message.merchant_number, 15, ' ');                -- merchant establishment number; pos 11
    l_line := l_line || rpad(i_fin_message.merchant_name, 25, ' ');                  -- merchant name; pos 26
    l_line := l_line || rpad(i_fin_message.merchant_city, 13, ' ');                  -- merchant city; pos 51
    l_line := l_line || rpad(i_fin_message.merchant_country, 3, ' ');                -- merchant country code; pos 64
    l_line := l_line || rpad(i_fin_message.mcc, 4, ' ');                             -- merchant category code; pos 67
    l_line := l_line || rpad(i_fin_message.merchant_type, 1, ' ');                   -- type of merchant; pos 71
    l_line := l_line || rpad(nvl(i_fin_message.spec_cond_ind, ' '), 2, ' ');         -- special merchant condition indicator; pos 72
    l_line := l_line || rpad(nvl(i_fin_message.electronic_term_ind, ' '), 1, ' ');   -- electronic terminal indicator; pos 74
    l_line := l_line || rpad(nvl(i_fin_message.terminal_number, ' '), 8, ' ');       -- card acceptor terminal identification; pos 75
    l_line := l_line || rpad(i_fin_message.usage_code, 1, ' ');                      -- usage code; pos 83
    l_line := l_line || rpad(nvl(i_fin_message.reconciliation_ind, ' '), 3, ' ');    -- reconciliation indicator; pos 84
    l_line := l_line || rpad(nvl(i_fin_message.member_msg_text, ' '), 50, ' ');      -- member message text; pos 87
    l_line := l_line || rpad(nvl(i_fin_message.reason_code, ' '), 4, ' ');           -- reason code for chargeback and representment; pos 137
    l_line := l_line || rpad(nvl(i_fin_message.chargeback_ref_num, ' '), 6, ' ');    -- chargeback reference number; pos 141
    l_line := l_line || rpad(nvl(i_fin_message.docum_ind, ' '), 1, ' ');             -- documentation indicator; pos 147
    l_line := l_line || rpad(nvl(i_fin_message.payment_product_ind, ' '), 1, ' ');   -- payment product indicator (ppi); pos 148
    l_line := l_line || rpad(i_fin_message.card_number, 19, ' ');                    -- cardholder card number involved in transaction; pos 149
    l_line := l_line || rpad(nvl(i_fin_message.card_expir_date, ' '), 4, ' ');       -- cardholder card number expiry date; pos 168
    l_line := l_line || rpad(i_fin_message.crdh_id_method, 1, ' ');                  -- cardholder identification method indicator; pos 172
    l_line := l_line || rpad(i_fin_message.crdh_cardnum_cap_ind, 1, ' ');            -- cardholder card number capture indicator; pos 173
    l_line := l_line || rpad(nvl(i_fin_message.account_selection, ' '), 2, '0');     -- atm account selection; pos 174
    l_line := l_line || rpad(nvl(i_fin_message.trans_status, ' '), 5, ' ');          -- transaction status; pos 176
    l_line := l_line || rpad(i_fin_message.trans_code_header, 2, ' ');               -- transaction code header; pos 181
    l_line := l_line || rpad(' ', 74);

    prc_api_file_pkg.put_line(
        i_raw_data      => convert_data(i_data => l_line)
      , i_sess_file_id  => i_session_file_id
    );

    --------------------------- TCR1 ------------------------------------
    l_line :=
        get_rec_header(
            i_trans_code => i_fin_message.trans_code
          , i_tcr        => '1'
          , io_file      => io_file
        );

    l_line := l_line || to_char(i_fin_message.oper_date, 'DDMMYY');            -- transaction date; pos 10
    l_line := l_line || rpad(i_fin_message.auth_code, 6, ' ');                 -- authorisation code; pos 16
    l_line := l_line || rpad(i_fin_message.auth_code_src_ind, 1, ' ');         -- authorisation code source indicator; pos 22
    l_line := l_line || rpad(i_fin_message.transaction_type, 1, ' ');          -- transaction type; pos 23
    l_line := l_line || rpad(i_fin_message.arn, 23, ' ');                      -- acquirer reference number; pos 24
    l_line := l_line || rpad(i_fin_message.forw_inst_id, 8, ' ');              -- forwarding institution identification (fid); pos 47
    l_line := l_line || rpad(i_fin_message.void_ind, 1, ' ');                  -- void indicator; pos 55

    l_line := l_line || nvl(l_oper_currency_exponent, '0');                    -- source currency exponent; pos 56
    l_line := l_line || lpad(i_fin_message.oper_amount, 12, '0');              -- source amount; pos 57

    l_line := l_line || rpad(i_fin_message.receiv_inst_id, 8, ' ');                 -- receiving institution identification (rid); pos 69
    l_line := l_line || rpad(nvl(i_fin_message.spec_chargeback_ind, ' '), 1, ' ');  -- special chargeback indicator; pos 77

    l_line := l_line || nvl(l_dest_currency_exponent, '0');                         -- destination currency exponent; pos 78
    l_line := l_line || lpad(i_fin_message.dest_amount, 12, '0');                   -- destination amount; pos 79

    -- Source or destination amount in local currency (CFA); pos 91, exponent of currency CFA (952) equals to 2
    l_line := l_line || lpad(i_fin_message.sttl_amount, 12, '0');
    -- Issuer reimbursement fee (irf); pos 103, in the billing currency of the issuer (dest_currency)
    l_line := l_line || lpad(i_fin_message.iss_reimb_fee, 12, '0');

    -- Value date; pos 115
    l_line := l_line || rpad(to_char(i_fin_message.value_date, 'DDMMYY'), 6, ' ');
    -- Transaction interchange processing date; pos 121
    l_line := l_line || rpad(to_char(i_fin_message.trans_inter_proc_date, 'DDMMYY'), 6, ' ');
    l_line := l_line || rpad(i_fin_message.merchant_region, 3, ' ');           -- merchant state/province code; pos 127
    l_line := l_line || rpad(' ', 1);                                           --filler; pos 130
    l_line := l_line || rpad(i_fin_message.voucher_dep_bank_code, 2, ' ');     -- voucher depositing bank code; pos 131
    l_line := l_line || rpad(i_fin_message.voucher_dep_branch_code, 4, ' ');   -- voucher depositing branch code; pos 133
    -- Value of i_fin_message.card_seq_number from an authorization isn't used, only ZEROS (see the specification)
    l_line := l_line || rpad('0', 3, '0');                                     -- card sequence number; pos 137
    l_line := l_line || nvl(to_char(i_fin_message.reconciliation_date, 'DDMMYY'), '000000');       -- reconciliation date; pos 140
    l_line := l_line || rpad(i_fin_message.rrn, 12, ' ');                      -- retrieval reference number; pos 146
    l_line := l_line || to_char(i_fin_message.oper_date, 'hh24miss');          -- transaction time; pos 158
    l_line := l_line || rpad(i_fin_message.oper_currency, 3, ' ');             -- source currency code; pos 164
    l_line := l_line || rpad(nvl(i_fin_message.dest_currency, ' '), 3, ' ');   -- destination currency code; pos 167

    l_line := l_line || lpad(i_fin_message.merch_serv_charge, 12, '0');        -- merchant service charge (msc); pos 170
    l_line := l_line || lpad(i_fin_message.acq_msc_revenue, 12, '0');          -- acquirer msc revenue; pos 182
    l_line := l_line || rpad(i_fin_message.electr_comm_ind, 1, ' ');           -- electronic commerce (ec) indicator; pos 194
    l_line := l_line || lpad(i_fin_message.crdh_billing_amount, 12, '0');      -- cardholder billing amount; pos 195
    -- Exchange rate from source amount or destination amount currency to local currency (cfa); pos 207
    l_line := l_line || rpad(
                            format_exchange_rate(
                                i_rate         => i_fin_message.rate_dst_loc_currency
                              , i_field_length => 9
                            )
                          , 9, '0'
                        );
    -- Exchange rate from local currency (CFA) to destination amount currency; pos 216
    l_line := l_line || rpad(
                            format_exchange_rate(
                                i_rate         => i_fin_message.rate_loc_dst_currency
                              , i_field_length => 9
                            )
                          , 9, '0'
                        );
    -- Filler; pos 225
    l_line := l_line || rpad(' ', 32);

    prc_api_file_pkg.put_line(
        i_raw_data      => convert_data(i_data => l_line)
      , i_sess_file_id  => i_session_file_id
    );

    --------------------------- TCR3 ------------------------------------
    l_line :=
        get_rec_header(
            i_trans_code => i_fin_message.trans_code
          , i_tcr        => '3'
          , io_file      => io_file
        );

    l_line := l_line || rpad(i_fin_message.cryptogram, 16, ' ');             -- application cryptogram; pos 10
    l_line := l_line || rpad(i_fin_message.cryptogram_info_data, 2, ' ');    -- cryptogram information data; pos 26
    l_line := l_line || rpad(i_fin_message.issuer_appl_data, 64, ' ');       -- issuer application data; pos 28
    l_line := l_line || rpad(i_fin_message.unpredict_number, 8, ' ');        -- unpredictable number; pos 92
    l_line := l_line || rpad(i_fin_message.appl_trans_counter, 4, ' ');      -- application transaction counter; pos 100
    l_line := l_line || rpad(i_fin_message.term_verif_result, 10, ' ');      -- terminal verification results; pos 104
    l_line := l_line || rpad(to_char(i_fin_message.trans_date, 'DDMMYY'), 6, ' ');   -- transaction date; pos 114
    l_line := l_line || lpad(i_fin_message.cryptogram_amount, 12, '0');      -- cryptogram amount; pos 120
    l_line := l_line || rpad(i_fin_message.trans_currency, 3, ' ');          -- transaction currency code; pos 132
    l_line := l_line || rpad(i_fin_message.appl_interch_profile, 4, ' ');    -- application interchange profile; pos 135
    l_line := l_line || rpad(i_fin_message.terminal_country, 3, ' ');        -- terminal country code; pos 139
    l_line := l_line || lpad(i_fin_message.cashback_amount, 12, '0');        -- amount other (cash back amount); pos 142
    l_line := l_line || rpad(i_fin_message.transaction_type_tcr3, 2, ' ');   -- transaction type; pos 154
    l_line := l_line || rpad(i_fin_message.crdh_verif_method, 6, ' ');       -- cardholder verification method; pos 156
    l_line := l_line || rpad(i_fin_message.terminal_profile, 6, ' ');        -- terminal capabilities; pos 162
    l_line := l_line || rpad(i_fin_message.terminal_type, 2, ' ');           -- terminal type; pos 168
    l_line := l_line || rpad(i_fin_message.trans_category_code, 1, chr(0));  -- transaction category code; pos 170
    l_line := l_line || rpad(i_fin_message.trans_seq_number, 8, ' ');        -- transaction sequence number; pos 171
    l_line := l_line || rpad(i_fin_message.iss_auth_data, 32, ' ');          -- issuer authentication data; pos 179
    l_line := l_line || rpad(i_fin_message.issuer_script_result, 10, ' ');   -- issuer script results; pos 211
    l_line := l_line || rpad(i_fin_message.card_seq_number, 3, ' ');         -- card sequence number; pos 221
    l_line := l_line || rpad(' ', 33);                                       -- filler; pos 224

    prc_api_file_pkg.put_line(
        i_raw_data      => convert_data(i_data => l_line)
      , i_sess_file_id  => i_session_file_id
    );
end process_draft;

procedure process_fee_funds(
    i_fin_message          in            cst_bof_gim_api_type_pkg.t_gim_fin_mes_rec
  , i_session_file_id      in            com_api_type_pkg.t_long_id
  , io_file                in out nocopy cst_bof_gim_api_type_pkg.t_gim_file_rec
) is
    l_oper_currency_exponent             com_api_type_pkg.t_tiny_id;
    l_dest_currency_exponent             com_api_type_pkg.t_tiny_id;
    l_fee_rec                            cst_bof_gim_api_type_pkg.t_fee_rec;
    l_line                               com_api_type_pkg.t_text;
begin
    l_oper_currency_exponent := com_api_currency_pkg.get_currency_exponent(
                                    i_curr_code => i_fin_message.oper_currency
                                );
    if i_fin_message.dest_currency is not null then
        l_dest_currency_exponent := com_api_currency_pkg.get_currency_exponent(
                                        i_curr_code => i_fin_message.dest_currency
                                    );
    end if;

    cst_bof_gim_api_fin_msg_pkg.get_fee(
        i_id       => i_fin_message.id
      , o_fee_rec  => l_fee_rec
    );

    if l_fee_rec.id is null then
        return;
    end if;

    --------------------------- TCR0 ------------------------------------
    l_line :=
        get_rec_header(
            i_trans_code => i_fin_message.trans_code
          , i_tcr        => '0'
          , io_file      => io_file
        );

    -- Transaction route indicator; pos 10
    l_line := l_line || rpad(com_api_type_pkg.boolean_not(i_fin_message.is_incoming), 1, ' ');
    -- Payment product indicator; pos 11
    l_line := l_line || rpad(nvl(i_fin_message.payment_product_ind, '0'), 1, '0');
    -- Forwarding institution identification; pos 12
    l_line := l_line || rpad(nvl(i_fin_message.forw_inst_id, '0'), 8, '0');
    -- Filler; pos 20
    l_line := l_line || rpad(' ', 1);
    -- Source currency exponent; pos 21
    l_line := l_line || nvl(l_oper_currency_exponent, '0');
    -- Source amount; pos 22
    l_line := l_line || case when l_oper_currency_exponent = 0
                             then lpad(nvl(i_fin_message.oper_amount, 0), 10, '0') || '00'
                             else lpad(nvl(i_fin_message.oper_amount, 0), 12, '0')
                        end;
    -- Receiving institution identification; pos 34
    l_line := l_line || rpad(nvl(i_fin_message.receiv_inst_id, '0'), 8, '0');
    -- Processing and authorisation fees type indicator; pos 42
    l_line := l_line || rpad(nvl(l_fee_rec.fee_type_ind, '0'), 1, '0');
    -- Destination currency code exponent; pos 43
    l_line := l_line || nvl(l_dest_currency_exponent, '0');
    -- Destination amount; pos 44
    l_line := l_line || case when l_dest_currency_exponent = 0
                             then lpad(nvl(i_fin_message.dest_amount, 0), 10, '0') || '00'
                             else lpad(nvl(i_fin_message.dest_amount, 0), 12, '0')
                        end;
    -- Cardholder card number involved in fee; pos 56
    l_line := l_line || rpad(nvl(i_fin_message.card_number, ' '), 19, ' ');
    -- Country code of forwarding institution; pos 75
    l_line := l_line || rpad(nvl(l_fee_rec.forw_inst_country_code, ' '), 3, ' ');
    -- Reason code for fee; pos 78
    l_line := l_line || rpad(nvl(l_fee_rec.reason_code, ' '), 4, ' ');
    l_line := l_line || rpad(nvl(l_fee_rec.collection_branch_code, ' '), 4, ' ');  -- collection branch code; pos 82
    l_line := l_line || rpad(nvl(l_fee_rec.trans_count, '0'), 8, '0');             -- number of transactions; pos 86
    l_line := l_line || rpad(nvl(l_fee_rec.unit_fee, ' '), 9, ' ');                -- unit fee; pos 94
    -- Event date; pos 103
    l_line := l_line || nvl(to_char(l_fee_rec.event_date, 'DDMMYY'), '000000');
    -- Transaction interchange processing date; pos 109
    l_line := l_line || nvl(to_char(io_file.proc_date, 'DDMMYY'), '000000');
    -- Filler; pos 115
    l_line := l_line || rpad(' ', 1);
    -- Source amount in CFA; pos 116
    l_line := l_line || lpad(nvl(l_fee_rec.source_amount_cfa, 0), 10, '0') || '00'; -- exponent of CFA is 0
    -- Value date; pos 128
    l_line := l_line || nvl(to_char(i_fin_message.value_date, 'DDMMYY'), '000000');
    l_line := l_line || rpad(nvl(i_fin_message.card_seq_number, ' '), 3, ' ');        -- original card sequence number; pos 157
    l_line := l_line || nvl(i_fin_message.oper_currency, '000');                      -- source currency code; pos 160
    l_line := l_line || nvl(i_fin_message.sttl_currency, '000');                      -- destination currency code; pos 163
    -- Filler; pos 166
    l_line := l_line || rpad(' ', 91);

    prc_api_file_pkg.put_line(
        i_raw_data      => convert_data(i_data => l_line)
      , i_sess_file_id  => i_session_file_id
    );
    --------------------------- TCR1 ------------------------------------
    l_line :=
        get_rec_header(
            i_trans_code => i_fin_message.trans_code
          , i_tcr        => '1'
          , io_file      => io_file
        );
    l_line := l_line || rpad(nvl(l_fee_rec.message_text, ' '), 100, ' ');       -- member message text; pos 10
    l_line := l_line || rpad(' ', 147);                                         -- filler; pos 20

    prc_api_file_pkg.put_line(
        i_raw_data      => convert_data(i_data => l_line)
      , i_sess_file_id  => i_session_file_id
    );
end process_fee_funds;

procedure process_retrieval_request(
    i_fin_message          in            cst_bof_gim_api_type_pkg.t_gim_fin_mes_rec
  , i_session_file_id      in            com_api_type_pkg.t_long_id
  , io_file                in out nocopy cst_bof_gim_api_type_pkg.t_gim_file_rec
) is
    l_oper_currency_exponent             com_api_type_pkg.t_tiny_id;
    l_retrieval_rec                      cst_bof_gim_api_type_pkg.t_retrieval_rec;
    l_line                               com_api_type_pkg.t_text;
begin
    cst_bof_gim_api_fin_msg_pkg.get_retrieval(
        i_id             => i_fin_message.id
      , o_retrieval_rec  => l_retrieval_rec
    );
    if l_retrieval_rec.id is null then
        return;
    end if;

    l_oper_currency_exponent := com_api_currency_pkg.get_currency_exponent(
                                    i_curr_code => i_fin_message.oper_currency
                                );
    --------------------------- TCR0 ------------------------------------
    l_line :=
        get_rec_header(
            i_trans_code => i_fin_message.trans_code
          , i_tcr        => '0'
          , io_file      => io_file
        );

    -- Transaction route indicator; pos 10
    l_line := l_line || rpad(com_api_type_pkg.boolean_not(i_fin_message.is_incoming), 1, ' ');
    -- Document type; pos 11
    l_line := l_line || rpad(nvl(l_retrieval_rec.document_type, '0'), 1, ' ');
    -- Cardholder card number involved in request; pos 12
    l_line := l_line || rpad(nvl(i_fin_message.card_number, '0'), 19, ' ');
    -- Acquirer’s (microfilm) reference number; pos 31
    l_line := l_line || rpad(nvl(i_fin_message.arn, '0'), 23, ' ');
    -- Transaction date and time; pos 54
    l_line := l_line || rpad(nvl(to_char(i_fin_message.oper_date, 'DDMMYYhh24mmss'), ' '), 12, ' ');
    -- Transaction amount; pos 66
    l_line := l_line || case when l_oper_currency_exponent = 0
                             then lpad(i_fin_message.oper_amount, 10, '0') || '00'
                             else lpad(i_fin_message.oper_amount, 12, '0')
                        end;
    -- Transaction currency code; pos 78
    l_line := l_line || rpad(nvl(i_fin_message.oper_currency, ' '), 3, ' ');
    -- Card sequence number; pos 81
    l_line := l_line || rpad(nvl(i_fin_message.card_seq_number, '0'), 3, '0');
    -- Card issuer reference number; pos 84
    l_line := l_line || rpad(nvl(l_retrieval_rec.card_iss_ref_num, '0'), 9, '0');
    -- Cancellation indicator; pos 93
    l_line := l_line || rpad(nvl(l_retrieval_rec.cancellation_ind, ' '), 1, ' ');
    -- Request reason code; pos 94
    l_line := l_line || rpad(nvl(i_fin_message.reason_code, '0'), 2, ' ');
    -- Potential chargeback reason code; pos 96
    l_line := l_line || rpad(nvl(l_retrieval_rec.potential_chback_reason_code, ' '), 4, ' ');
    -- Account selection; pos 100
    l_line := l_line || rpad(nvl(i_fin_message.account_selection, '0'), 2, '0');
    -- Retrieval reference number; pos 102
    l_line := l_line || rpad(nvl(i_fin_message.rrn, ' '), 12, ' ');
    l_line := l_line || rpad(nvl(i_fin_message.auth_code, '0'), 6, ' ');            -- authorisation code; pos 114
    -- Transaction interchange processing date; pos 120
    l_line := l_line || rpad(nvl(to_char(io_file.proc_date, 'DDMMYY'), ' '), 6, ' ');
    l_line := l_line || rpad(nvl(i_fin_message.forw_inst_id, '0'), 8, ' ');         -- forwarding institution identification; pos 126
    l_line := l_line || rpad(nvl(i_fin_message.receiv_inst_id, '0'), 8, ' ');       -- receiving institution identification; pos 134
    l_line := l_line || rpad(nvl(l_retrieval_rec.response_type, '0'), 1, ' ');      -- type of response; pos 142
    l_line := l_line || rpad(' ', 114);

    prc_api_file_pkg.put_line(
        i_raw_data      => convert_data(i_data => l_line)
      , i_sess_file_id  => i_session_file_id
    );
end process_retrieval_request;

procedure process_fraud_advice(
    i_fin_message          in            cst_bof_gim_api_type_pkg.t_gim_fin_mes_rec
  , i_session_file_id      in            com_api_type_pkg.t_long_id
  , io_file                in out nocopy cst_bof_gim_api_type_pkg.t_gim_file_rec
) is
    l_fraud_currency_exponent            com_api_type_pkg.t_tiny_id;
    l_fraud_rec                          cst_bof_gim_api_type_pkg.t_fraud_rec;
    l_line                               com_api_type_pkg.t_text;
begin
    cst_bof_gim_api_fin_msg_pkg.get_fraud(
        i_id         => i_fin_message.id
      , o_fraud_rec  => l_fraud_rec
    );
    if l_fraud_rec.id is null then
        return;
    end if;

    l_fraud_currency_exponent := com_api_currency_pkg.get_currency_exponent(
                                     i_curr_code => l_fraud_rec.fraud_currency
                                 );
    --------------------------- TCR0 ------------------------------------
    l_line :=
        get_rec_header(
            i_trans_code => i_fin_message.trans_code
          , i_tcr        => '0'
          , io_file      => io_file
        );
    -- Transaction route indicator; pos 10; 1 = outgoing
    l_line := l_line || rpad(com_api_type_pkg.boolean_not(l_fraud_rec.is_incoming), 1, ' ');
    -- Forwarding institution identification; pos 11
    l_line := l_line || rpad(nvl(i_fin_message.forw_inst_id, '0'), 8, '0');
    -- Receiving institution identification; pos 19
    l_line := l_line || rpad('40005000', 8, ' ');
    -- Cardholder card number involved in request; pos 27
    l_line := l_line || rpad(nvl(i_fin_message.card_number, '0'), 19, '0');
    -- Acquirer’s (microfilm) reference number; pos 46
    l_line := l_line || rpad(nvl(i_fin_message.arn, '0'), 23, ' ');
    -- Transaction date and time; pos 69
    l_line := l_line || rpad(nvl(to_char(i_fin_message.oper_date, 'DDMMYY'), ' '), 6, ' ');
    -- Merchant name; pos 75
    l_line := l_line || rpad(i_fin_message.merchant_name, 25, ' ');
    -- Merchant city; pos 100
    l_line := l_line || rpad(i_fin_message.merchant_city, 13, ' ');
    -- Merchant country code; pos 113
    l_line := l_line || rpad(i_fin_message.merchant_country, 3, ' ');
    -- Merchant category code; pos 116
    l_line := l_line || rpad(i_fin_message.mcc, 4, ' ');
    -- Merchant state/province code; pos 120
    l_line := l_line || rpad(i_fin_message.merchant_region, 3, ' ');
    -- Transaction amount; pos 123
    l_line := l_line || case when l_fraud_currency_exponent = 0
                             then lpad(l_fraud_rec.fraud_amount, 10, '0') || '00'
                             else lpad(l_fraud_rec.fraud_amount, 12, '0')
                        end;
    -- Fraud currency code; pos 135
    l_line := l_line || rpad(nvl(l_fraud_rec.fraud_currency, '0'), 3, ' ');
    -- Vic processing date; pos 138
    l_line := l_line || rpad(nvl(to_char(l_fraud_rec.vic_processing_date, 'DDMMYY'), ' '), 6, ' ');
    -- Norification code; pos 144
    l_line := l_line || rpad(nvl(l_fraud_rec.notification_code, '0'), 1, ' ');
    -- Account sequence number; pos 145
    l_line := l_line || rpad(nvl(l_fraud_rec.account_seq_number, '0'), 4, '0');
    -- Insurance year; pos 149
    l_line := l_line || rpad(nvl(l_fraud_rec.insurance_year, '0'), 2, '0');
    -- Fraud type; pos 151; 5 - Others, by default for NULL
    l_line := l_line || rpad(nvl(substr(l_fraud_rec.fraud_type, -1), '0'), 1, '5');
    -- Cardholder card number expiry date; pos 152
    l_line := l_line || rpad(nvl(l_fraud_rec.card_expir_date, '0'), 4, '0');
    -- Debit/Credit indicator; pos 156
    l_line := l_line || rpad(nvl(l_fraud_rec.debit_credit_indicator, '0'), 1, ' ');
    -- Transaction generation method; pos 157
    l_line := l_line || rpad(nvl(l_fraud_rec.trans_generation_method, '0'), 1, ' ');
    -- Electronic commerce indicator; pos 157
    l_line := l_line || rpad(nvl(l_fraud_rec.electr_comm_ind, '0'), 1, ' ');
    -- Filler; pos 158
    l_line := l_line || rpad(' ', 98);

    prc_api_file_pkg.put_line(
        i_raw_data      => convert_data(i_data => l_line)
      , i_sess_file_id  => i_session_file_id
    );
end process_fraud_advice;

procedure mark_fin_messages(
    i_id                   in      com_api_type_pkg.t_number_tab
  , i_file_id              in      com_api_type_pkg.t_number_tab
  , i_rec_num              in      com_api_type_pkg.t_number_tab
) is
begin
    trc_log_pkg.debug(
        i_text         => 'Mark financial messages'
    );

    forall i in 1..i_id.count
        update cst_bof_gim_fin_msg
           set file_id       = i_file_id(i)
             , record_number = i_rec_num(i)
             , status        = net_api_const_pkg.CLEARING_MSG_STATUS_UPLOADED
         where id = i_id(i);
end;

procedure process_logical_file(
    io_logical_file        in out nocopy cst_bof_gim_api_type_pkg.t_logical_file_rec
  , i_trans_code           in            com_api_type_pkg.t_byte_char
  , i_usage_code           in            com_api_type_pkg.t_byte_char
) is
begin
    if i_trans_code = cst_bof_gim_api_const_pkg.TC_SALES then
        io_logical_file.total_tc05 := io_logical_file.total_tc05 + 1;
    end if;

    if i_trans_code in (cst_bof_gim_api_const_pkg.TC_SALES
                      , cst_bof_gim_api_const_pkg.TC_VOUCHER
                      , cst_bof_gim_api_const_pkg.TC_CASH)
    then
        if i_usage_code = '1' then
            io_logical_file.total_tc050607_1 := io_logical_file.total_tc050607_1 + 1;
        elsif i_usage_code = '2' then
            io_logical_file.total_tc050607_2 := io_logical_file.total_tc050607_2 + 1;
        end if;

    elsif i_trans_code in (cst_bof_gim_api_const_pkg.TC_SALES_CHARGEBACK
                         , cst_bof_gim_api_const_pkg.TC_VOUCHER_CHARGEBACK
                         , cst_bof_gim_api_const_pkg.TC_CASH_CHARGEBACK)
    then
        if i_usage_code = '1' then
            io_logical_file.total_tc151617_1 := io_logical_file.total_tc151617_1 + 1;
        elsif i_usage_code = '2' then
            io_logical_file.total_tc151617_2 := io_logical_file.total_tc151617_2 + 1;
        end if;

    elsif i_trans_code in (cst_bof_gim_api_const_pkg.TC_SALES_REVERSAL
                         , cst_bof_gim_api_const_pkg.TC_VOUCHER_REVERSAL
                         , cst_bof_gim_api_const_pkg.TC_CASH_REVERSAL)
    then
        if i_usage_code = '1' then
            io_logical_file.total_tc252627_1 := io_logical_file.total_tc252627_1 + 1;
        elsif i_usage_code = '2' then
            io_logical_file.total_tc252627_2 := io_logical_file.total_tc252627_2 + 1;
        end if;

    elsif i_trans_code in (cst_bof_gim_api_const_pkg.TC_SALES_CHARGEBACK_REV
                         , cst_bof_gim_api_const_pkg.TC_VOUCHER_CHARGEBACK_REV
                         , cst_bof_gim_api_const_pkg.TC_CASH_CHARGEBACK_REV)
    then
        if i_usage_code = '1' then
            io_logical_file.total_tc353637_1 := io_logical_file.total_tc353637_1 + 1;
        elsif i_usage_code = '2' then
            io_logical_file.total_tc353637_2 := io_logical_file.total_tc353637_2 + 1;
        end if;

    elsif i_trans_code = cst_bof_gim_api_const_pkg.TC_FEE_COLLECTION then
        if i_usage_code = '1' then
            io_logical_file.total_tc10_1 := io_logical_file.total_tc10_1 + 1;
        elsif i_usage_code = '2' then
            io_logical_file.total_tc10_2 := io_logical_file.total_tc10_2 + 1;
        end if;

    elsif i_trans_code = cst_bof_gim_api_const_pkg.TC_FUNDS_DISBURSEMENT then
        if i_usage_code = '1' then
            io_logical_file.total_tc20_1 := io_logical_file.total_tc20_1 + 1;
        elsif i_usage_code = '2' then
            io_logical_file.total_tc20_2 := io_logical_file.total_tc20_2 + 1;
        end if;

    elsif i_trans_code = cst_bof_gim_api_const_pkg.TC_REQUEST_ORIGINAL_PAPER then
        io_logical_file.total_tc51 := io_logical_file.total_tc51 + 1;

    elsif i_trans_code = cst_bof_gim_api_const_pkg.TC_REQUEST_FOR_PHOTOCOPY then
        io_logical_file.total_tc52 := io_logical_file.total_tc52 + 1;

    elsif i_trans_code = cst_bof_gim_api_const_pkg.TC_MAILING_CONFIRMATION then
        io_logical_file.total_tc53 := io_logical_file.total_tc53 + 1;

    elsif i_trans_code = cst_bof_gim_api_const_pkg.TC_FRAUD_ADVICE then
        io_logical_file.total_tc40 := io_logical_file.total_tc40 + 1;

    end if;
end process_logical_file;

procedure process_file(
    io_file                in out nocopy cst_bof_gim_api_type_pkg.t_gim_file_rec
  , io_logical_file        in out nocopy cst_bof_gim_api_type_pkg.t_logical_file_rec
) is
    LOG_PREFIX                  constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_file ';
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || '<< total_tc050607_1 [#1]'
      , i_env_param1 => io_file.total_tc050607_1
    );

    io_file.total_tc050607_1 := nvl(io_file.total_tc050607_1, 0) + nvl(io_logical_file.total_tc050607_1, 0);
    io_file.total_tc050607_2 := nvl(io_file.total_tc050607_2, 0) + nvl(io_logical_file.total_tc050607_2, 0);

    io_file.total_tc151617_1 := nvl(io_file.total_tc151617_1, 0) + nvl(io_logical_file.total_tc151617_1, 0);
    io_file.total_tc151617_2 := nvl(io_file.total_tc151617_2, 0) + nvl(io_logical_file.total_tc151617_2, 0);

    io_file.total_tc252627_1 := nvl(io_file.total_tc252627_1, 0) + nvl(io_logical_file.total_tc252627_1, 0);
    io_file.total_tc252627_2 := nvl(io_file.total_tc252627_2, 0) + nvl(io_logical_file.total_tc252627_2, 0);

    io_file.total_tc353637_1 := nvl(io_file.total_tc353637_1, 0) + nvl(io_logical_file.total_tc353637_1, 0);
    io_file.total_tc353637_2 := nvl(io_file.total_tc353637_2, 0) + nvl(io_logical_file.total_tc353637_2, 0);

    io_file.total_tc10_1     := nvl(io_file.total_tc10_1, 0) + nvl(io_logical_file.total_tc10_1, 0);
    io_file.total_tc10_2     := nvl(io_file.total_tc10_2, 0) + nvl(io_logical_file.total_tc10_2, 0);

    io_file.total_tc20_1     := nvl(io_file.total_tc20_1, 0) + nvl(io_logical_file.total_tc20_1, 0);
    io_file.total_tc20_2     := nvl(io_file.total_tc20_2, 0) + nvl(io_logical_file.total_tc20_2, 0);

    io_file.total_tc51       := nvl(io_file.total_tc51, 0) + nvl(io_logical_file.total_tc51, 0);
    io_file.total_tc52       := nvl(io_file.total_tc52, 0) + nvl(io_logical_file.total_tc52, 0);
    io_file.total_tc53       := nvl(io_file.total_tc53, 0) + nvl(io_logical_file.total_tc53, 0);

    io_file.total_tc40       := nvl(io_file.total_tc40, 0) + nvl(io_logical_file.total_tc40, 0);

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || '>> total_tc050607_1 [#1], total_tc10_1 [#2], total_tc20_1 [#3], total_tc40 [#4]'
      , i_env_param1 => io_file.total_tc050607_1
      , i_env_param2 => io_file.total_tc10_1
      , i_env_param3 => io_file.total_tc20_1
      , i_env_param4 => io_file.total_tc40
    );
end process_file;

procedure process_empty_logical_file(
    io_file                in out  cst_bof_gim_api_type_pkg.t_gim_file_rec
  , i_logical_file_code    in      com_api_type_pkg.t_byte_char
  , i_session_file_id      in      com_api_type_pkg.t_long_id
  , io_file_list_tab       in out  t_file_list_tab
  , i_end_of_file          in      com_api_type_pkg.t_boolean
) is
    l_logical_file                 cst_bof_gim_api_type_pkg.t_logical_file_rec;
begin

    for i in 1 .. io_file_list_tab.count loop
      
        if io_file_list_tab(i).logical_file_code = i_logical_file_code then
            io_file_list_tab(i).is_processed := com_api_type_pkg.TRUE;

            if i_end_of_file = com_api_type_pkg.FALSE then
                exit;
            end if;
        end if;

        if nvl(io_file_list_tab(i).is_processed, com_api_type_pkg.FALSE) = com_api_type_pkg.FALSE then
            process_logical_file_header(
                io_file                => io_file
              , o_logical_file         => l_logical_file
              , i_logical_file_code    => io_file_list_tab(i).logical_file_code
              , i_session_file_id      => i_session_file_id
            );

            process_logical_file_trailer(
                io_file                => io_file
              , io_logical_file        => l_logical_file
              , i_session_file_id      => i_session_file_id
            );
            
            io_file_list_tab(i).is_processed := com_api_type_pkg.TRUE;
        end if;

    end loop;

end process_empty_logical_file;

procedure process(
    i_network_id           in      com_api_type_pkg.t_tiny_id
  , i_inst_id              in      com_api_type_pkg.t_inst_id
  , i_host_inst_id         in      com_api_type_pkg.t_inst_id
  , i_start_date           in      date
  , i_end_date             in      date
  , i_include_affiliate    in      com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
  , i_charset              in      com_api_type_pkg.t_oracle_name  default null
) is
    l_estimated_count              com_api_type_pkg.t_long_id := 0;
    l_processed_count              com_api_type_pkg.t_long_id := 0;
    l_record_count                 com_api_type_pkg.t_long_id;

    l_ok_mess_id                   com_api_type_pkg.t_number_tab;
    l_file_id                      com_api_type_pkg.t_number_tab;
    l_rec_num                      com_api_type_pkg.t_number_tab;

    l_proc_bin                     com_api_type_pkg.t_dict_value;

    l_fin_message                  cst_bof_gim_api_type_pkg.t_gim_fin_mes_tab;

    l_session_file_id              com_api_type_pkg.t_long_id;

    l_file                         cst_bof_gim_api_type_pkg.t_gim_file_rec;
    l_logical_file                 cst_bof_gim_api_type_pkg.t_logical_file_rec;
    l_trans_code                   varchar2(2);

    l_header_written               boolean := false;
    l_file_list_tab                t_file_list_tab;
    l_last_logical_file_code       com_api_type_pkg.t_byte_char;

    l_fin_cur                      cst_bof_gim_api_type_pkg.t_gim_fin_cur;

    procedure register_ok_message(
        i_mess_id      in     com_api_type_pkg.t_long_id
      , i_file_id      in     com_api_type_pkg.t_long_id
    ) is
        i                     binary_integer;
    begin
        i  := l_ok_mess_id.count + 1;
        l_ok_mess_id(i) := i_mess_id;
        l_file_id(i)    := i_file_id;
        l_rec_num(i)    := prc_api_file_pkg.get_record_number(i_sess_file_id => l_session_file_id);
    end;

    procedure mark_ok_message is
    begin
        mark_fin_messages(
            i_id        => l_ok_mess_id
          , i_file_id   => l_file_id
          , i_rec_num   => l_rec_num
        );

        opr_api_clearing_pkg.mark_uploaded(
            i_id_tab  => l_ok_mess_id
        );

        l_ok_mess_id.delete;
        l_file_id.delete;
        l_rec_num.delete;
    end;

    procedure check_ok_message is
    begin
        if l_ok_mess_id.count >= BULK_LIMIT then
            mark_ok_message;
        end if;
    end;

begin
    trc_log_pkg.debug(
        i_text  => 'GIM-UEMOA outgoing clearing START'
    );

    prc_api_stat_pkg.log_start;

    g_charset        := nvl(i_charset, g_default_charset);
    g_adjust_charset := case when g_charset != g_default_charset then com_api_const_pkg.TRUE else com_api_const_pkg.FALSE end;

    -- Make estimated count
    l_record_count := cst_bof_gim_api_fin_msg_pkg.estimate_messages_for_upload(
                          i_inst_id       => i_inst_id
                        , i_start_date    => trunc(i_start_date)
                        , i_end_date      => trunc(i_end_date)
                      );
    l_estimated_count := l_estimated_count + l_record_count;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count  => l_estimated_count
    );

    if l_estimated_count > 0 then
        -- Init
        l_proc_bin       := null;
        l_trans_code     := null;
        l_header_written := false;
        l_logical_file   := null;

        -- Indicator shows that logical file was processed, maybe, as empty logical file.
        l_file_list_tab.delete;
        l_file_list_tab(1).logical_file_code := cst_bof_gim_api_const_pkg.TC_FM_HEADER;
        l_file_list_tab(2).logical_file_code := cst_bof_gim_api_const_pkg.TC_FV_HEADER;
        l_file_list_tab(3).logical_file_code := cst_bof_gim_api_const_pkg.TC_FMC_HEADER;
        l_file_list_tab(4).logical_file_code := cst_bof_gim_api_const_pkg.TC_FL_HEADER;
        l_file_list_tab(5).logical_file_code := cst_bof_gim_api_const_pkg.TC_FSW_HEADER;

        cst_bof_gim_api_fin_msg_pkg.enum_messages_for_upload(
            o_fin_cur       => l_fin_cur
          , i_inst_id       => i_inst_id
          , i_start_date    => trunc(i_start_date)
          , i_end_date      => trunc(i_end_date)
        );
        loop
            fetch l_fin_cur bulk collect into l_fin_message limit BULK_LIMIT;

            for j in 1..l_fin_message.count loop
                -- If first record then create a new file and put a file header
                if not l_header_written then
                    process_file_header(
                        i_network_id       => cst_bof_gim_api_const_pkg.GIM_NETWORK_ID
                      , i_proc_bin         => l_fin_message(j).proc_bin
                      , i_inst_id          => i_inst_id
                      , i_standard_id      => cst_bof_gim_api_const_pkg.GIM_STANDARD_ID
                      , i_host_id          => cst_bof_gim_api_const_pkg.GIM_HOST_ID
                      , i_host_inst_id     => cst_bof_gim_api_const_pkg.GIM_INST
                      , o_file             => l_file
                      , o_session_file_id  => l_session_file_id
                    );

                    l_header_written := true;
                end if;

                if  l_logical_file.logical_file_code is null
                    or
                    l_logical_file.logical_file_code != l_fin_message(j).logical_file
                then
                    if l_logical_file.logical_file_code is not null then
                        process_logical_file_trailer(
                            io_file            => l_file
                          , io_logical_file    => l_logical_file
                          , i_session_file_id  => l_session_file_id
                        );
                        -- Increment counters of the file by counters of current logical file
                        process_file(
                            io_file            => l_file
                          , io_logical_file    => l_logical_file
                        );
                    end if;

                    l_last_logical_file_code  := l_fin_message(j).logical_file;

                    process_empty_logical_file(
                        io_file                => l_file
                      , i_logical_file_code    => l_last_logical_file_code
                      , i_session_file_id      => l_session_file_id
                      , io_file_list_tab       => l_file_list_tab
                      , i_end_of_file          => com_api_type_pkg.FALSE
                    );

                    process_logical_file_header(
                        io_file                => l_file
                      , o_logical_file         => l_logical_file
                      , i_logical_file_code    => l_fin_message(j).logical_file
                      , i_session_file_id      => l_session_file_id
                    );
                end if;

                -- Process draft transactions
                if  l_fin_message(j).trans_code in (
                        cst_bof_gim_api_const_pkg.TC_SALES
                      , cst_bof_gim_api_const_pkg.TC_VOUCHER
                      , cst_bof_gim_api_const_pkg.TC_CASH
                      , cst_bof_gim_api_const_pkg.TC_SALES_CHARGEBACK
                      , cst_bof_gim_api_const_pkg.TC_VOUCHER_CHARGEBACK
                      , cst_bof_gim_api_const_pkg.TC_CASH_CHARGEBACK
                      , cst_bof_gim_api_const_pkg.TC_SALES_REVERSAL
                      , cst_bof_gim_api_const_pkg.TC_VOUCHER_REVERSAL
                      , cst_bof_gim_api_const_pkg.TC_CASH_REVERSAL
                      , cst_bof_gim_api_const_pkg.TC_SALES_CHARGEBACK_REV
                      , cst_bof_gim_api_const_pkg.TC_VOUCHER_CHARGEBACK_REV
                      , cst_bof_gim_api_const_pkg.TC_CASH_CHARGEBACK_REV
                    )
                then
                    process_draft(
                        i_fin_message      => l_fin_message(j)
                      , i_session_file_id  => l_session_file_id
                      , io_file            => l_file
                    );
                -- process fee collections and funds diburstment
                elsif l_fin_message(j).trans_code in (
                          cst_bof_gim_api_const_pkg.TC_FEE_COLLECTION
                        , cst_bof_gim_api_const_pkg.TC_FUNDS_DISBURSEMENT
                      )
                then
                    process_fee_funds(
                        i_fin_message      => l_fin_message(j)
                      , i_session_file_id  => l_session_file_id
                      , io_file            => l_file
                    );
                -- process retrieval requests
                elsif l_fin_message(j).trans_code in (
                          cst_bof_gim_api_const_pkg.TC_REQUEST_ORIGINAL_PAPER
                        , cst_bof_gim_api_const_pkg.TC_REQUEST_FOR_PHOTOCOPY
                        , cst_bof_gim_api_const_pkg.TC_MAILING_CONFIRMATION
                      )
                then
                    process_retrieval_request(
                        i_fin_message      => l_fin_message(j)
                      , i_session_file_id  => l_session_file_id
                      , io_file            => l_file
                    );
                -- process fraud advices
                elsif l_fin_message(j).trans_code in (
                          cst_bof_gim_api_const_pkg.TC_FRAUD_ADVICE
                      )
                then
                    process_fraud_advice(
                        i_fin_message      => l_fin_message(j)
                      , i_session_file_id  => l_session_file_id
                      , io_file            => l_file
                    );
                end if;

                register_ok_message(
                    i_mess_id   => l_fin_message(j).id
                  , i_file_id   => l_file.id
                );

                check_ok_message();

                -- Increment counters of current logical file
                process_logical_file(
                    io_logical_file  => l_logical_file
                  , i_trans_code     => l_fin_message(j).trans_code
                  , i_usage_code     => l_fin_message(j).usage_code
                );
            end loop;

            l_processed_count := l_processed_count + l_fin_message.count;

            prc_api_stat_pkg.log_current(
                i_current_count   => l_processed_count
              , i_excepted_count  => 0
            );

            exit when l_fin_cur%notfound;
        end loop;

        close l_fin_cur;

        mark_ok_message;

        if l_header_written then
             process_logical_file_trailer(
                 io_file            => l_file
               , io_logical_file    => l_logical_file
               , i_session_file_id  => l_session_file_id
             );
            -- Increment counters of the file by counters of current logical file
            process_file(
                io_file             => l_file
              , io_logical_file     => l_logical_file
            );

            process_empty_logical_file(
                io_file                => l_file
              , i_logical_file_code    => l_last_logical_file_code
              , i_session_file_id      => l_session_file_id
              , io_file_list_tab       => l_file_list_tab
              , i_end_of_file          => com_api_type_pkg.TRUE
            );

            process_file_trailer(
                io_file             => l_file
              , i_session_file_id   => l_session_file_id
            );
            prc_api_file_pkg.close_file(
                i_sess_file_id      => l_session_file_id
              , i_status            => prc_api_const_pkg.FILE_STATUS_ACCEPTED
            );
        end if;
    end if;

    prc_api_stat_pkg.log_end(
        i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
      , i_processed_total  => l_processed_count
    );

    trc_log_pkg.debug(
        i_text  => 'GIM-UEMOA outgoing clearing END'
    );

exception
    when others then
        if l_fin_cur%isopen then
            close l_fin_cur;
        end if;

        prc_api_stat_pkg.log_end(
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if l_session_file_id is not null then
            prc_api_file_pkg.close_file(
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
end process;

end;
/
