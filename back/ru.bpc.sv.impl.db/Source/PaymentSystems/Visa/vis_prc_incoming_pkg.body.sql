create or replace package body vis_prc_incoming_pkg as
/*********************************************************
 *  Visa incoming files API  <br />
 *  Created by Filimonov A.(filimonov@bpcbt.com)  at 18.03.2010 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: vis_api_incoming_pkg <br />
 *  @headcom
 **********************************************************/

type t_amount_count_tab is table of integer index by com_api_type_pkg.t_curr_code;

g_processing_date   date   := null;
g_filedate          date   := null;
g_error_flag        com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE;
g_errors_count      com_api_type_pkg.t_long_id := 0;

type t_no_dispute_id_rec is record (
    i_first_tc                 com_api_type_pkg.t_byte_char
  , i_vcr                      com_api_type_pkg.t_name
  , i_tc_buffer                vis_api_type_pkg.t_tc_buffer
  , i_network_id               com_api_type_pkg.t_tiny_id
  , i_host_id                  com_api_type_pkg.t_tiny_id
  , i_standard_id              com_api_type_pkg.t_tiny_id
  , i_standard_version         com_api_type_pkg.t_tiny_id
  , i_inst_id                  com_api_type_pkg.t_inst_id
  , i_proc_date                date
  , i_file_id                  com_api_type_pkg.t_long_id
  , i_incom_sess_file_id       com_api_type_pkg.t_long_id
  , i_batch_id                 com_api_type_pkg.t_medium_id
  , i_record_number            com_api_type_pkg.t_short_id
  , i_proc_bin                 com_api_type_pkg.t_dict_value
  , i_create_operation         com_api_type_pkg.t_boolean
);
type t_no_dispute_id_tab is table of t_no_dispute_id_rec index by binary_integer;
g_no_dispute_id_tab       t_no_dispute_id_tab;

function get_inst_id_by_proc_bin(
    i_proc_bin              in      com_api_type_pkg.t_name
  , i_network_id            in      com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_inst_id is
    l_proc_bin              com_api_type_pkg.t_name;
    l_result                com_api_type_pkg.t_inst_id;
    l_param_tab             com_api_type_pkg.t_param_tab;
begin
    for r in (
        select m.inst_id
             , i.host_member_id host_id
          from net_interface i
             , net_member m
         where m.network_id = i_network_id
           and m.id         = i.consumer_member_id
    ) loop
        begin
            cmn_api_standard_pkg.get_param_value(
                i_inst_id      => r.inst_id
              , i_standard_id  => vis_api_const_pkg.VISA_BASEII_STANDARD
              , i_entity_type  => net_api_const_pkg.ENTITY_TYPE_HOST
              , i_object_id    => r.host_id
              , i_param_name   => vis_api_const_pkg.CMID
              , o_param_value  => l_proc_bin
              , i_param_tab    => l_param_tab
            );
        exception
            when com_api_error_pkg.e_application_error then
                null;
        end;

        if trim(l_proc_bin) = trim(i_proc_bin) then
            l_result :=  r.inst_id;
            exit;
        end if;

    end loop;

    return l_result;
end;

procedure init_fin_record (
    io_visa                 in out  vis_api_type_pkg.t_visa_fin_mes_rec
) is
begin
    io_visa.id           := null;
    io_visa.is_incoming  := com_api_type_pkg.TRUE;
    io_visa.is_returned  := com_api_type_pkg.FALSE;
    io_visa.is_invalid   := com_api_type_pkg.FALSE;
    io_visa.is_reversal  := com_api_type_pkg.FALSE;
end;

function date_ddmmmyy (
    p_date                  in varchar2
) return date is
begin
    if p_date is null or p_date = '0000000' or trim(p_date) is null then
        return null;
    end if;

    return to_date(p_date, 'DDMONYY');
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

function date_mmdd (
    p_date                  in varchar2
) return date is
    l_century               varchar2(4) := to_char(g_filedate, 'YYYY');
    l_dt                    date;
begin
    if p_date is null or p_date = '0000' then
        return null;
    end if;
    l_dt := to_date (l_century || p_date, 'YYYYMMDD');
    if l_dt > g_filedate and l_dt > g_processing_date then
        l_century := to_char (to_number (l_century) - 1);
        l_dt := to_date (l_century || p_date, 'YYYYMMDD');
        if abs(months_between(l_dt, g_filedate))>11 then
            l_century := to_char (g_filedate, 'YYYY');
            l_dt := to_date (l_century || p_date, 'YYYYMMDD');
        end if;
    end if;
    return l_dt;
end;

function date_yddd (
    p_date                  in varchar2
) return date is
    v_century               varchar2(4) := to_char (g_filedate, 'YYYY');
    v_dt                    date;
begin
    if p_date is null then
        return null;
    end if;

    if p_date = '0000' then
        return trunc (g_filedate);
    end if;
    v_dt := to_date (substr (v_century, 1, 3) || p_date, 'YYYYDDD');

    return v_dt;
end;

function strange_date_yyyyddd (
    p_date                  in varchar2
) return date is
begin
    if substr (p_date, 1, 2) = '00' then
        return to_date(substr(p_date, 3, 5), 'RRDDD');
    end if;
    return to_date(p_date, 'YYYYDDD');
end;

function date_yyyyddd (
    p_date                  in varchar2
) return date is
begin
    if p_date = '0000000' then
        return null;
    end if;
    return to_date (p_date, 'YYYYDDD');
end;

function date_yymmdd (
    p_date                  in varchar2
) return date is
begin
    if p_date = '000000' then
        return null;
    end if;
    return to_date (p_date, 'YYMMDD');
end;

function date_mmddyy (
    p_date                  in varchar2
) return date is
begin
    if p_date = '000000' then
        return null;
    end if;
    return to_date (p_date, 'MMDDYY');
end;

function date_yyyymmdd (
    p_date                  in varchar2
  , p_time                  in varchar2
) return date
is
    l_time varchar2(6) := p_time;
begin
    if p_date = '000000' then
        return null;
    end if;
    if l_time is null then
        l_time := '000000';
    end if;

    return to_date (p_date||l_time, 'YYYYMMDDhh24miss');
end;

function correct_sign (
    p_amt                   in number
    , p_sign                in varchar2
) return number is
begin
    return case p_sign when 'DB' then -p_amt else p_amt end;
end;

procedure count_amount (
    io_amount_tab           in out nocopy t_amount_count_tab
    , i_sttl_amount         in com_api_type_pkg.t_money
    , i_sttl_currency       in com_api_type_pkg.t_curr_code
) is
begin
    if io_amount_tab.exists(nvl(i_sttl_currency, '')) then
        io_amount_tab(nvl(i_sttl_currency, '')) := nvl(io_amount_tab(nvl(i_sttl_currency, '')), 0) + i_sttl_amount;
    else
        io_amount_tab(nvl(i_sttl_currency, '')) := i_sttl_amount;
    end if;
end;

procedure info_amount (
    i_amount_tab            in t_amount_count_tab
) is
    l_result                com_api_type_pkg.t_name;
begin
    l_result := i_amount_tab.first;
    loop
        exit when l_result is null;

        trc_log_pkg.info(
            i_text        => 'Settlement currency [#1] amount [#2]'
          , i_env_param1  => l_result
          , i_env_param2  => com_api_currency_pkg.get_amount_str(
                                 i_amount          => i_amount_tab(l_result)
                               , i_curr_code       => l_result
                               , i_mask_curr_code  => com_api_type_pkg.TRUE
                               , i_mask_error      => com_api_type_pkg.TRUE
                             )
        );

        l_result := i_amount_tab.next(l_result);
    end loop;
end;

procedure process_csm(
    i_oper              in  opr_api_type_pkg.t_oper_rec
  , i_visa              in  vis_api_type_pkg.t_visa_fin_mes_rec
  , i_card_inst_id      in  com_api_type_pkg.t_inst_id
  , i_standard_id       in  com_api_type_pkg.t_tiny_id
  , i_perform_check     in  com_api_type_pkg.t_boolean
  , i_create_disp_case  in  com_api_type_pkg.t_boolean            default com_api_const_pkg.FALSE
) as
    LOG_PREFIX     constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_csm: ';
begin
    if i_create_disp_case = com_api_type_pkg.FALSE then
        return;
    end if;
    
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'trans_code [#1], usage_code [#2], i_perform_check [#3]'
      , i_env_param1 => i_visa.trans_code
      , i_env_param2 => i_visa.usage_code
      , i_env_param3 => i_perform_check
    );
    
    -- add new case if required
    if i_perform_check = com_api_const_pkg.TRUE then
        csm_api_check_pkg.perform_check(
            i_oper_id           => i_oper.id
          , i_card_number       => i_visa.card_number
          , i_merchant_number   => i_oper.merchant_number
          , i_inst_id           => i_card_inst_id
          , i_msg_type          => i_oper.msg_type
          , i_dispute_id        => i_oper.dispute_id
          , i_de_024            => null
          , i_reason_code       => i_visa.reason_code
          , i_original_id       => i_oper.original_id
          , i_de004             => i_visa.dispute_amount
          , i_de049             => i_visa.dispute_currency
        );
    end if;
    
    -- calculate dispute due date and set it as a new value
    vis_api_dispute_pkg.update_due_date(
        i_dispute_id       => i_visa.dispute_id
      , i_standard_id      => i_standard_id
      , i_trans_code       => i_visa.trans_code
      , i_usage_code       => i_visa.usage_code
      , i_eff_date         => i_visa.oper_date
      , i_action           => csm_api_const_pkg.CASE_ACTION_ITEM_LOAD_LABEL
      , i_reason_code      => case 
                                  when i_visa.usage_code = '9'
                                      then i_visa.dispute_condition
                                      else i_visa.reason_code
                              end
    );
    
    trc_log_pkg.debug(
        i_text => 'process_csm: msg_type= ' || i_oper.msg_type || ' is_reversal=' || i_oper.is_reversal
    );
    
    vis_api_dispute_pkg.change_case_status(
        i_dispute_id        => i_visa.dispute_id
      , i_usage_code        => i_visa.usage_code
      , i_trans_code        => i_visa.trans_code
      , i_reason_code       => i_visa.reason_code
      , i_msg_status        => net_api_const_pkg.CLEARING_MSG_STATUS_LOADED
      , i_dispute_condition => i_visa.dispute_condition
      , i_msg_type          => i_oper.msg_type
      , i_is_reversal       => i_oper.is_reversal
    );
    trc_log_pkg.debug(LOG_PREFIX || ' END');

end;

procedure process_file_header (
    i_header_data           in varchar2
    , i_network_id          in com_api_type_pkg.t_tiny_id
    , i_host_id             in com_api_type_pkg.t_tiny_id
    , i_standard_id         in com_api_type_pkg.t_tiny_id
    , i_test_option         in varchar2
    , i_dst_inst_id         in com_api_type_pkg.t_inst_id
    , i_session_file_id     in com_api_type_pkg.t_long_id
    , o_visa_file           out vis_api_type_pkg.t_visa_file_rec
    , i_validate_record     in com_api_type_pkg.t_boolean
) is
    l_security_code         com_api_type_pkg.t_dict_value;
    l_count                 pls_integer;
    l_param_tab             com_api_type_pkg.t_param_tab;
begin
    o_visa_file.is_incoming     := com_api_type_pkg.TRUE;
    o_visa_file.proc_bin        := substr(i_header_data, 3, 6);
    o_visa_file.proc_date       := to_date(substr(i_header_data, 9, 5), 'YYDDD');
    g_filedate                  := o_visa_file.proc_date;

--    if substr(i_header_data, 20, 5) = '00000' then
--        o_visa_file.sttl_date   := o_visa_file.proc_date;
    if nvl(trim(substr(i_header_data, 20, 5)), '00000') = '00000' then
        o_visa_file.sttl_date   := trunc(o_visa_file.proc_date);
    else
        o_visa_file.sttl_date   := to_date(substr(i_header_data, 20, 5), 'YYDDD');
    end if;

    g_processing_date           := o_visa_file.sttl_date;

    o_visa_file.release_number  := substr(i_header_data, 27, 3);
    o_visa_file.test_option     := trim(substr(i_header_data, 30, 4));
    o_visa_file.security_code   := trim(substr(i_header_data, 63, 8));
    o_visa_file.visa_file_id    := substr(i_header_data, 77, 3);
    o_visa_file.network_id      := i_network_id;
    begin
        select 1
          into l_count
          from vis_file
         where proc_date    = o_visa_file.proc_date
           and visa_file_id = o_visa_file.visa_file_id
           and proc_bin     = o_visa_file.proc_bin;

        com_api_error_pkg.raise_error (
            i_error         => 'VISA_FILE_ALREADY_PROCESSED'
            , i_env_param1  => to_char(o_visa_file.proc_date,'yyyy-mm-dd')
            , i_env_param2  => o_visa_file.visa_file_id
        );
    exception
        when no_data_found then
            null;
    end;

    if i_standard_id is null then
        com_api_error_pkg.raise_error(
            i_error         => 'UNKNOWN_NETWORK'
            , i_env_param1  => i_network_id
        );
    end if;

    -- determine internal institution number
    o_visa_file.inst_id := i_dst_inst_id;
    if o_visa_file.inst_id is null then
        o_visa_file.inst_id := get_inst_id_by_proc_bin(o_visa_file.proc_bin, i_network_id);
    end if;
    if o_visa_file.inst_id is null then
        com_api_error_pkg.raise_error(
            i_error       => 'VISA_BIN_NOT_REGISTERED'
          , i_env_param1  => o_visa_file.proc_bin
          , i_env_param2  => i_network_id
          , i_env_param3 =>  o_visa_file.inst_id
        );
    end if;

    -- get security code
    cmn_api_standard_pkg.get_param_value (
        i_inst_id        => o_visa_file.inst_id
        , i_standard_id  => i_standard_id
        , i_object_id    => i_host_id
        , i_entity_type  => net_api_const_pkg.ENTITY_TYPE_HOST
        , i_param_name   => vis_api_const_pkg.VISA_SECURITY_CODE
        , o_param_value  => l_security_code
        , i_param_tab    => l_param_tab
    );

    -- check security code
    if nvl(l_security_code, '') != nvl(o_visa_file.security_code, '') then
        com_api_error_pkg.raise_error (
            i_error         => 'VISA_WRONG_INST_SECURITY_CODE'
            , i_env_param1  => o_visa_file.inst_id
            , i_env_param2  => o_visa_file.security_code
            , i_env_param3  => l_security_code
        );
    end if;
    -- check processing type
    if nvl(i_test_option, ' ') != nvl(o_visa_file.test_option, ' ') then
        com_api_error_pkg.raise_error(
            i_error       => 'VISA_WRONG_TEST_OPTION_PARAMETER'
          , i_env_param1  => i_test_option
          , i_env_param2  => o_visa_file.test_option
        );
    end if;

    o_visa_file.session_file_id := i_session_file_id;
    o_visa_file.id := vis_file_seq.nextval;

    if i_validate_record = com_api_const_pkg.TRUE
    then
        vis_api_reject_pkg.validate_visa_record_auth(
            i_oper_id     => null
            , i_visa_data => i_header_data
        );
    end if;

end;

procedure process_batch_trailer (
    i_tc_buffer             in vis_api_type_pkg.t_tc_buffer
    , i_file_id             in com_api_type_pkg.t_long_id
    , i_batch_id            in com_api_type_pkg.t_medium_id
    , i_validate_record     in com_api_type_pkg.t_boolean
) is
    l_batch                 vis_api_type_pkg.t_visa_batch_rec;
begin
    l_batch.id              := i_batch_id;
    l_batch.file_id         := i_file_id;
    l_batch.proc_bin        := substr(i_tc_buffer(1), 5, 6);
    l_batch.proc_date       := to_date(substr(i_tc_buffer(1), 11, 5), 'YYDDD');
    l_batch.batch_number    := substr(i_tc_buffer(1), 43, 6);
    l_batch.center_batch_id := substr(i_tc_buffer(1), 67, 8);
    l_batch.monetary_total  := substr(i_tc_buffer(1), 31, 12);
    l_batch.tcr_total       := substr(i_tc_buffer(1), 49, 12);
    l_batch.trans_total     := substr(i_tc_buffer(1), 75, 9);
    l_batch.src_amount      := substr(i_tc_buffer(1), 102, 15);
    l_batch.dst_amount      := substr(i_tc_buffer(1), 16, 15);

    insert into vis_batch (
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
        l_batch.id
        , l_batch.file_id
        , l_batch.proc_bin
        , l_batch.proc_date
        , l_batch.batch_number
        , l_batch.center_batch_id
        , l_batch.monetary_total
        , l_batch.tcr_total
        , l_batch.trans_total
        , l_batch.src_amount
        , l_batch.dst_amount
    );

    if i_validate_record = com_api_const_pkg.TRUE
    then
        vis_api_reject_pkg.validate_visa_record_auth(
            i_oper_id     => null
            , i_visa_data => i_tc_buffer(1)
        );
    end if;
end;

procedure process_file_trailer (
    i_tc_buffer             in vis_api_type_pkg.t_tc_buffer
    , io_visa_file          in out vis_api_type_pkg.t_visa_file_rec
    , i_validate_record     in com_api_type_pkg.t_boolean
) is
begin
    if io_visa_file.proc_bin != substr(i_tc_buffer(1), 5, 6) then
        com_api_error_pkg.raise_error (
            i_error         => 'VISA_FILE_CORRUPTED_INCORRECT_TRAILER_BIN'
            , i_env_param1  => io_visa_file.proc_bin
            , i_env_param2  => substr(i_tc_buffer(1), 5, 6)
        );
    end if;

    if io_visa_file.proc_date != to_date(substr(i_tc_buffer(1), 11, 5),'YYDDD') then
        com_api_error_pkg.raise_error (
            i_error         => 'VISA_FILE_CORRUPTED_INCORRECT_TRAILER_DATE'
            , i_env_param1  => to_char(io_visa_file.proc_date, 'YYDDD')
            , i_env_param2  => substr(i_tc_buffer(1), 11, 5)
        );
    end if;

    io_visa_file.dst_amount      := substr(i_tc_buffer(1), 16, 15);
    io_visa_file.monetary_total  := substr(i_tc_buffer(1), 31, 12);
    io_visa_file.batch_total     := substr(i_tc_buffer(1), 43, 6);
    io_visa_file.tcr_total       := substr(i_tc_buffer(1), 49, 12);
    io_visa_file.trans_total     := substr(i_tc_buffer(1), 75, 9);
    io_visa_file.src_amount      := substr(i_tc_buffer(1), 102, 15);

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
        io_visa_file.id
        , io_visa_file.is_incoming
        , io_visa_file.network_id
        , io_visa_file.proc_bin
        , io_visa_file.proc_date
        , io_visa_file.sttl_date
        , io_visa_file.release_number
        , io_visa_file.test_option
        , io_visa_file.security_code
        , io_visa_file.visa_file_id
        , io_visa_file.trans_total
        , io_visa_file.batch_total
        , io_visa_file.tcr_total
        , io_visa_file.monetary_total
        , io_visa_file.src_amount
        , io_visa_file.dst_amount
        , io_visa_file.inst_id
        , io_visa_file.session_file_id
    );

    if i_validate_record = com_api_const_pkg.TRUE
    then
        vis_api_reject_pkg.validate_visa_record_auth(
            i_oper_id     => null
            , i_visa_data => i_tc_buffer(1)
        );
    end if;
end;

procedure process_without_file_header (
    i_record_number         in com_api_type_pkg.t_short_id
    , i_network_id          in com_api_type_pkg.t_tiny_id
    , i_host_id             in com_api_type_pkg.t_tiny_id
    , i_standard_id         in com_api_type_pkg.t_tiny_id
    , i_dst_inst_id         in com_api_type_pkg.t_inst_id
    , i_session_file_id     in com_api_type_pkg.t_long_id
    , o_visa_file           out vis_api_type_pkg.t_visa_file_rec
) is
    LOG_PREFIX     constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_without_file_header: ';
    l_trailer_data          com_api_type_pkg.t_text;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'i_record_number = ' || i_record_number
                                   || ', i_dst_inst_id [' || i_dst_inst_id
                                   || '], i_network_id [' || i_network_id
                                   || '], i_host_id [' || i_host_id
                                   || '], i_standard_id [' || i_standard_id
                                   || '], i_session_file_id [' || i_session_file_id
                                   || ']'
    );

    select raw_data
      into l_trailer_data
      from prc_file_raw_data
     where session_file_id = i_session_file_id
       and record_number = i_record_number;

    if substr(l_trailer_data, 1, 2) = vis_api_const_pkg.TC_FILE_TRAILER then
        o_visa_file.is_incoming     := com_api_type_pkg.TRUE;
        o_visa_file.proc_bin        := substr(l_trailer_data, 5, 6);
        o_visa_file.proc_date       := to_date(substr(l_trailer_data, 11, 5), 'YYDDD');
        g_filedate                  := o_visa_file.proc_date;

        o_visa_file.sttl_date       := trunc(o_visa_file.proc_date);
        g_processing_date           := o_visa_file.sttl_date;

        if i_standard_id is null then
            com_api_error_pkg.raise_error(
                i_error         => 'UNKNOWN_NETWORK'
                , i_env_param1  => i_network_id
            );
        end if;

        -- determine internal institution number
        o_visa_file.inst_id := i_dst_inst_id;
        if o_visa_file.inst_id is null then
            o_visa_file.inst_id := get_inst_id_by_proc_bin(o_visa_file.proc_bin, i_network_id);
        end if;
        if o_visa_file.inst_id is null then
            com_api_error_pkg.raise_error(
                i_error       => 'VISA_BIN_NOT_REGISTERED'
              , i_env_param1  => o_visa_file.proc_bin
              , i_env_param2  => i_network_id
              , i_env_param3 =>  o_visa_file.inst_id
            );
        end if;

        o_visa_file.session_file_id := i_session_file_id;
        o_visa_file.id := vis_file_seq.nextval;
    end if;
end;

function get_card_number (
    i_card_number           in com_api_type_pkg.t_card_number
    , i_network_id          in com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_card_number
is
    LOG_PREFIX     constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_card_number: ';
    l_card_type_id          com_api_type_pkg.t_tiny_id;
    l_card_country          com_api_type_pkg.t_curr_code;
    l_pan_length            com_api_type_pkg.t_tiny_id;
    l_iss_inst_id           com_api_type_pkg.t_inst_id;
    l_iss_network_id        com_api_type_pkg.t_tiny_id;
    l_iss_host_id           com_api_type_pkg.t_tiny_id;
    l_card_inst_id          com_api_type_pkg.t_inst_id;
    l_card_network_id       com_api_type_pkg.t_tiny_id;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'i_card_number [#1], i_network_id [' || i_network_id || ']'
      , i_env_param1 => iss_api_card_pkg.get_card_mask(i_card_number => i_card_number)
    );

    iss_api_bin_pkg.get_bin_info (
        i_card_number        => i_card_number
        , o_iss_inst_id      => l_iss_inst_id
        , o_iss_network_id   => l_iss_network_id
        , o_iss_host_id      => l_iss_host_id
        , o_card_type_id     => l_card_type_id
        , o_card_country     => l_card_country
        , o_card_inst_id     => l_card_inst_id
        , o_card_network_id  => l_card_network_id
        , o_pan_length       => l_pan_length
        , i_raise_error      => com_api_const_pkg.FALSE
    );
    trc_log_pkg.debug(
        i_text => 'iss_api_bin_pkg.get_bin_info: '
               || 'l_card_inst_id [' || l_card_inst_id
               || '], l_pan_length [' || l_pan_length || ']'
    );

    if l_card_inst_id is null then
        net_api_bin_pkg.get_bin_info (
            i_card_number        => i_card_number
            , i_network_id       => i_network_id
            , o_iss_inst_id      => l_iss_inst_id
            , o_iss_host_id      => l_iss_host_id
            , o_card_type_id     => l_card_type_id
            , o_card_country     => l_card_country
            , o_card_inst_id     => l_card_inst_id
            , o_card_network_id  => l_card_network_id
            , o_pan_length       => l_pan_length
            , i_raise_error      => com_api_const_pkg.FALSE
        );
        trc_log_pkg.debug(
            i_text => 'net_api_bin_pkg.get_bin_info: '
                   || 'l_card_inst_id [' || l_card_inst_id
                   || '], l_pan_length [' || l_pan_length || ']'
        );
    end if;

    if l_pan_length is null then
        com_api_error_pkg.raise_error (
            i_error         => 'UNKNOWN_BIN_CARD_NUMBER_NETWORK'
            , i_env_param1  => substr(i_card_number, 1, 6)
            , i_env_param2  => i_network_id
        );
    end if;

    if l_pan_length = 0 then
        l_pan_length := 16;
    end if;

    trc_log_pkg.debug(LOG_PREFIX || 'END; l_pan_length [' || l_pan_length || ']');

    return substr(i_card_number, 1, l_pan_length);
end;

procedure assign_dispute(
    io_visa                 in out nocopy vis_api_type_pkg.t_visa_fin_mes_rec
  , i_standard_id           in            com_api_type_pkg.t_tiny_id
  , o_iss_inst_id              out        com_api_type_pkg.t_inst_id
  , o_iss_network_id           out        com_api_type_pkg.t_tiny_id
  , o_acq_inst_id              out        com_api_type_pkg.t_inst_id
  , o_acq_network_id           out        com_api_type_pkg.t_tiny_id
  , o_sttl_type                out        com_api_type_pkg.t_dict_value
  , o_match_status             out        com_api_type_pkg.t_dict_value
  , i_dispute_status        in            com_api_type_pkg.t_byte_char  default null
  , i_need_repeat           in            com_api_type_pkg.t_boolean
) is
    l_dispute_id                          com_api_type_pkg.t_long_id;
    l_is_incoming                         com_api_type_pkg.t_boolean;
    l_card_type_id                        com_api_type_pkg.t_tiny_id;
    l_card_country                        com_api_type_pkg.t_curr_code;
    l_pan_length                          com_api_type_pkg.t_tiny_id;
    l_iss_inst_id                         com_api_type_pkg.t_inst_id;
    l_iss_network_id                      com_api_type_pkg.t_tiny_id;
    l_iss_host_id                         com_api_type_pkg.t_tiny_id;
    l_card_inst_id                        com_api_type_pkg.t_inst_id;
    l_card_network_id                     com_api_type_pkg.t_tiny_id;

    cursor match_cur is
        select min(m.id)           as id
             , min(m.dispute_id)   as dispute_id
             , min(m.card_id)      as card_id
             , io_visa.card_number as card_number
             , min(o.sttl_type)    as sttl_type
             , min(o.match_status) as match_status
             , min(o.status)       as status
             , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER,   p.inst_id,    null)) as iss_inst_id
             , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER,   p.network_id, null)) as iss_network_id
             , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ACQUIRER, p.inst_id,    null)) as acq_inst_id
             , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ACQUIRER, p.network_id, null)) as acq_network_id
          from vis_fin_message m
             , vis_card c
             , opr_operation o
             , opr_participant p
         where m.trans_code  in (vis_api_const_pkg.TC_SALES, vis_api_const_pkg.TC_VOUCHER, vis_api_const_pkg.TC_CASH)
           and m.usage_code   = '1'
           and m.is_incoming  = l_is_incoming
           and m.arn          = io_visa.arn
           and c.id           = m.id
           and c.card_number  = iss_api_token_pkg.encode_card_number(i_card_number => io_visa.card_number)
           and o.id           = m.id
           and p.oper_id      = o.id;

    cursor match_cur_extended is
        select min(m.id)           as id
             , min(m.dispute_id)   as dispute_id
             , min(m.card_id)      as card_id
             , io_visa.card_number as card_number
             , min(o.sttl_type)    as sttl_type
             , min(o.match_status) as match_status
             , min(o.status)       as status
             , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER,   p.inst_id,    null)) as iss_inst_id
             , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER,   p.network_id, null)) as iss_network_id
             , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ACQUIRER, p.inst_id,    null)) as acq_inst_id
             , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ACQUIRER, p.network_id, null)) as acq_network_id
          from vis_fin_message m
             , vis_card c
             , opr_operation o
             , opr_participant p
         where m.trans_code  in (vis_api_const_pkg.TC_SALES, vis_api_const_pkg.TC_VOUCHER, vis_api_const_pkg.TC_CASH)
           and m.usage_code   = '1'
           and m.is_incoming  = l_is_incoming
           -- BIN subfield must match to field acquirer BIN (field 32 in online message)
           -- Date part of ARN must correspond to local date (field 13 in online message)
           and m.arn like '_' || substr(io_visa.arn, 2, 10) || '%'
           -- The 8 digits of the Film Locator subfield of ARN must match last 8 digits of RRN(refnum is sent in field 37 of online message). 
           and substr(o.originator_refnum, -8) = substr(io_visa.arn, 15, 8)
           and c.id           = m.id
           and c.card_number  = iss_api_token_pkg.encode_card_number(i_card_number => io_visa.card_number)
           and o.id           = m.id
           and p.oper_id      = o.id;

begin
    trc_log_pkg.debug(
        i_text        => 'assign_dispute: card_number[#1], arn[#2]'
      , i_env_param1  => iss_api_card_pkg.get_card_mask(io_visa.card_number)
      , i_env_param2  => io_visa.arn
    );

    case
    when io_visa.trans_code in (
        vis_api_const_pkg.TC_REQUEST_ORIGINAL_PAPER
        , vis_api_const_pkg.TC_REQUEST_FOR_PHOTOCOPY
    ) then
        l_is_incoming := com_api_type_pkg.FALSE;

    when io_visa.trans_code in (
        vis_api_const_pkg.TC_SALES_CHARGEBACK
        , vis_api_const_pkg.TC_VOUCHER_CHARGEBACK
        , vis_api_const_pkg.TC_CASH_CHARGEBACK
        , vis_api_const_pkg.TC_SALES_CHARGEBACK_REV
        , vis_api_const_pkg.TC_VOUCHER_CHARGEBACK_REV
        , vis_api_const_pkg.TC_CASH_CHARGEBACK_REV
    ) then
         l_is_incoming := com_api_type_pkg.FALSE;
    when io_visa.trans_code = vis_api_const_pkg.TC_MULTIPURPOSE_MESSAGE 
      then
         iss_api_bin_pkg.get_bin_info (
             i_card_number        => io_visa.card_number
             , o_iss_inst_id      => l_iss_inst_id
             , o_iss_network_id   => l_iss_network_id
             , o_iss_host_id      => l_iss_host_id
             , o_card_type_id     => l_card_type_id
             , o_card_country     => l_card_country
             , o_card_inst_id     => l_card_inst_id
             , o_card_network_id  => l_card_network_id
             , o_pan_length       => l_pan_length
             , i_raise_error      => com_api_const_pkg.FALSE
         );
         trc_log_pkg.debug(
             i_text => 'iss_api_bin_pkg.get_bin_info: '
                    || 'l_card_inst_id [' || l_card_inst_id
                    || '], l_pan_length [' || l_pan_length || ']'
         );

         if l_iss_inst_id is not null then
             l_is_incoming := com_api_type_pkg.TRUE;
         else
             l_is_incoming := com_api_type_pkg.FALSE;
         end if;
    else
         l_is_incoming := com_api_type_pkg.TRUE;
    end case;

    for rec in match_cur loop
        if rec.id is not null then
            io_visa.dispute_id  := nvl(rec.dispute_id, rec.id);
            io_visa.card_id     := rec.card_id;
            io_visa.card_number := rec.card_number;
            if rec.status = opr_api_const_pkg.OPERATION_STATUS_MANUAL then
                io_visa.is_invalid := com_api_type_pkg.TRUE;
            end if;

            l_dispute_id        := rec.dispute_id;

            o_iss_inst_id       := rec.iss_inst_id;
            o_iss_network_id    := rec.iss_network_id;
            o_acq_inst_id       := rec.acq_inst_id;
            o_acq_network_id    := rec.acq_network_id;
            o_sttl_type         := rec.sttl_type;
            o_match_status      := rec.match_status;

            trc_log_pkg.debug(
                i_text        => 'Original message found. id = [#1], o_iss_inst_id = [#2], dispute_id = [#3]'
              , i_env_param1  => rec.id
              , i_env_param2  => o_iss_inst_id
              , i_env_param3  => io_visa.dispute_id
            );
        end if;

        exit;
    end loop;
    
    if io_visa.dispute_id is null then
        for rec in match_cur_extended loop
            if rec.id is not null then
                io_visa.dispute_id  := nvl(rec.dispute_id, rec.id);
                io_visa.card_id     := rec.card_id;
                io_visa.card_number := rec.card_number;
                if rec.status = opr_api_const_pkg.OPERATION_STATUS_MANUAL then
                    io_visa.is_invalid := com_api_type_pkg.TRUE;
                end if;

                l_dispute_id        := rec.dispute_id;

                o_iss_inst_id       := rec.iss_inst_id;
                o_iss_network_id    := rec.iss_network_id;
                o_acq_inst_id       := rec.acq_inst_id;
                o_acq_network_id    := rec.acq_network_id;
                o_sttl_type         := rec.sttl_type;
                o_match_status      := rec.match_status;

                trc_log_pkg.debug(
                    i_text        => 'Original message found. id = [#1], o_iss_inst_id = [#2], dispute_id = [#3]'
                  , i_env_param1  => rec.id
                  , i_env_param2  => o_iss_inst_id
                  , i_env_param3  => io_visa.dispute_id
                );
            end if;
            exit;
        end loop;
    end if;
    
    if io_visa.dispute_id is null then
        vis_cst_incoming_pkg.assign_dispute(
            io_visa           => io_visa
          , o_iss_inst_id     => o_iss_inst_id
          , o_iss_network_id  => o_iss_network_id
          , o_acq_inst_id     => o_acq_inst_id
          , o_acq_network_id  => o_acq_network_id
          , o_sttl_type       => o_sttl_type
          , o_match_status    => o_match_status
        );
    end if;

    if io_visa.dispute_id is null then
        if i_need_repeat = com_api_type_pkg.TRUE then
            trc_log_pkg.debug (
                i_text          => 'Need repeat for dispute id'
            );
            raise com_api_error_pkg.e_need_original_record;

        else
            trc_log_pkg.warn(
                i_text         => 'ORIGINAL_OPERATION_IS_NOT_FOUND'
              , i_env_param1   => io_visa.id
              , i_env_param2   => io_visa.arn
              , i_env_param3   => iss_api_card_pkg.get_card_mask(io_visa.card_number)
              , i_env_param4   => com_api_type_pkg.convert_to_char(io_visa.oper_date)
              , i_entity_type  => opr_api_const_pkg.ENTITY_TYPE_OPERATION
              , i_object_id    => io_visa.id
            );

            if io_visa.trans_code not in (vis_api_const_pkg.TC_SALES_REVERSAL, vis_api_const_pkg.TC_VOUCHER_REVERSAL)
            then
                io_visa.is_invalid := com_api_type_pkg.TRUE;
            end if;

        end if;
    end if;

    -- Aassign a new dispute ID
    if l_dispute_id is null then
        update vis_fin_message
           set dispute_id = io_visa.dispute_id
         where id         = io_visa.dispute_id;

        update opr_operation
           set dispute_id = io_visa.dispute_id
         where id         = io_visa.dispute_id;
    end if;
end assign_dispute;

procedure create_fin_addendum(
    i_fin_msg_id            in com_api_type_pkg.t_long_id
  , i_raw_data              in varchar2
) is
begin
    insert into vis_fin_addendum (
        id
      , fin_msg_id
      , tcr
      , raw_data
    ) values (
        vis_fin_addendum_seq.nextval
      , i_fin_msg_id
      , substr(i_raw_data, 4, 1)
      , i_raw_data
    );
end;

procedure get_oper_type (
    io_oper_type            in out com_api_type_pkg.t_dict_value
    , i_mcc                 in com_api_type_pkg.t_mcc
    , i_mask_error          in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
) is
    l_cab_type              com_api_type_pkg.t_mcc;
begin
    select
        mastercard_cab_type
    into
        l_cab_type
    from
        com_mcc
    where
        mcc = i_mcc;

    if io_oper_type in (
        opr_api_const_pkg.OPERATION_TYPE_PURCHASE
    ) then
        case l_cab_type
            when mcw_api_const_pkg.CAB_TYPE_UNIQUE then
                io_oper_type := opr_api_const_pkg.OPERATION_TYPE_UNIQUE;
            else
                null;
        end case;
    end if;
exception
    when no_data_found then
        if i_mask_error = com_api_type_pkg.TRUE then
            trc_log_pkg.warn (
                i_text          => 'MCW_UNDEFINED_MCC'
                , i_env_param1  => i_mcc
            );
        else
            com_api_error_pkg.raise_error (
                i_error         => 'MCW_UNDEFINED_MCC'
                , i_env_param1  => i_mcc
            );
        end if;
end get_oper_type;

procedure process_draft(
    i_tc_buffer               in vis_api_type_pkg.t_tc_buffer
  , i_network_id              in com_api_type_pkg.t_tiny_id
  , i_host_id                 in com_api_type_pkg.t_tiny_id
  , i_standard_id             in com_api_type_pkg.t_tiny_id
  , i_inst_id                 in com_api_type_pkg.t_inst_id
  , i_proc_date               in date
  , i_file_id                 in com_api_type_pkg.t_long_id
  , i_incom_sess_file_id      in com_api_type_pkg.t_long_id
  , i_batch_id                in com_api_type_pkg.t_medium_id
  , i_record_number           in com_api_type_pkg.t_short_id
  , i_proc_bin                in com_api_type_pkg.t_dict_value
  , io_amount_tab             in out nocopy t_amount_count_tab
  , i_create_operation        in com_api_type_pkg.t_boolean
  , i_validate_record         in com_api_type_pkg.t_boolean
  , i_need_repeat             in com_api_type_pkg.t_boolean
  , io_no_original_id_tab     in out nocopy vis_api_type_pkg.t_visa_fin_mes_tab
  , i_create_disp_case        in com_api_type_pkg.t_boolean  default com_api_const_pkg.FALSE
  , i_register_loading_event  in com_api_type_pkg.t_boolean  default com_api_const_pkg.FALSE
) is
    LOG_PREFIX     constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_draft: ';
    l_visa                  vis_api_type_pkg.t_visa_fin_mes_rec;
    l_recnum                pls_integer := 1;
    l_tcr                   varchar2(1);
    l_iss_inst_id           com_api_type_pkg.t_inst_id;
    l_acq_inst_id           com_api_type_pkg.t_inst_id;
    l_card_inst_id          com_api_type_pkg.t_inst_id;
    l_iss_network_id        com_api_type_pkg.t_tiny_id;
    l_acq_network_id        com_api_type_pkg.t_tiny_id;
    l_card_network_id       com_api_type_pkg.t_tiny_id;
    l_card_type_id          com_api_type_pkg.t_tiny_id;
    l_country_code          com_api_type_pkg.t_country_code;
    l_bin_currency          com_api_type_pkg.t_curr_code;
    l_sttl_currency         com_api_type_pkg.t_curr_code;
    l_other_settlement      com_api_type_pkg.t_boolean;
    l_visa_dialect          com_api_type_pkg.t_dict_value;
    l_sttl_type             com_api_type_pkg.t_dict_value;
    l_match_status          com_api_type_pkg.t_dict_value;
    l_match_id              com_api_type_pkg.t_long_id;
    l_card_service_code     com_api_type_pkg.t_curr_code;
    l_param_tab             com_api_type_pkg.t_param_tab;
    l_iss_inst_id2          com_api_type_pkg.t_inst_id;
    l_iss_network_id2       com_api_type_pkg.t_tiny_id;
    l_iss_host_id           com_api_type_pkg.t_tiny_id;
    l_card_country          com_api_type_pkg.t_country_code;
    l_pan_length            com_api_type_pkg.t_tiny_id;
    l_currency_exponent     com_api_type_pkg.t_tiny_id;
    l_oper                  opr_api_type_pkg.t_oper_rec;
    l_iss_part              opr_api_type_pkg.t_oper_part_rec;
    l_acq_part              opr_api_type_pkg.t_oper_part_rec;
    l_operation             opr_api_type_pkg.t_oper_rec;
    l_participant           opr_api_type_pkg.t_oper_part_rec;
    l_need_original_id      com_api_type_pkg.t_boolean;
    l_interchng_fee_amount  number(15, 6);
    l_bin_rec               iss_api_type_pkg.t_bin_rec;
    l_card_rec              iss_api_type_pkg.t_card_rec;
    l_standard_version      com_api_type_pkg.t_tiny_id;
begin
    l_standard_version :=
        cmn_api_standard_pkg.get_current_version(
            i_standard_id  => i_standard_id
          , i_entity_type  => net_api_const_pkg.ENTITY_TYPE_HOST
          , i_object_id    => i_host_id
          , i_eff_date     => com_api_sttl_day_pkg.get_sysdate()
        );

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'i_tc_buffer.count() = ' || i_tc_buffer.count()
                                   || ', io_amount_tab.count() = ' || io_amount_tab.count()
                                   || ', i_inst_id [' || i_inst_id
                                   || '], i_file_id [' || i_file_id
                                   || '], i_batch_id [' || i_batch_id
                                   || '], i_record_number [' || i_record_number
                                   || '], i_create_operation [' || i_create_operation
                                   || '], i_proc_date [#1], i_proc_bin [#2]'
                                   || '], l_standard_version [' || l_standard_version || ']'
      , i_env_param1 => to_char(i_proc_date, com_api_const_pkg.XML_DATE_FORMAT)
      , i_env_param2 => i_proc_bin
    );

    cmn_api_standard_pkg.get_param_value(
        i_inst_id      => i_inst_id
      , i_standard_id  => i_standard_id
      , i_object_id    => i_host_id
      , i_entity_type  => net_api_const_pkg.ENTITY_TYPE_HOST
      , i_param_name   => vis_api_const_pkg.VISA_BASEII_DIALECT
      , o_param_value  => l_visa_dialect
      , i_param_tab    => l_param_tab
    );

    -- Message specific fields
    -- data from TCR0
    init_fin_record(l_visa);
    l_visa.id                   := opr_api_create_pkg.get_id;
    l_visa.trans_code           := substr(i_tc_buffer(l_recnum), 1, 2);
    l_visa.trans_code_qualifier := substr(i_tc_buffer(l_recnum), 3, 1);
    l_tcr                       := substr(i_tc_buffer(l_recnum), 4, 1);
    l_visa.file_id              := i_file_id;
    l_visa.batch_id             := i_batch_id;
    l_visa.record_number        := i_record_number;

    l_visa.is_reversal := case when l_visa.trans_code in (
                                                             vis_api_const_pkg.TC_SALES_REVERSAL
                                                           , vis_api_const_pkg.TC_VOUCHER_REVERSAL
                                                           , vis_api_const_pkg.TC_CASH_REVERSAL
                                                           , vis_api_const_pkg.TC_SALES_CHARGEBACK_REV
                                                           , vis_api_const_pkg.TC_VOUCHER_CHARGEBACK_REV
                                                           , vis_api_const_pkg.TC_CASH_CHARGEBACK_REV
                                                         )
                          then
                              com_api_type_pkg.TRUE
                          else
                              com_api_type_pkg.FALSE
                          end;

    begin
        l_bin_rec := iss_api_bin_pkg.get_bin(
                         i_bin         => substr(i_tc_buffer(l_recnum), 28, 6)
                       , i_mask_error  => com_api_type_pkg.TRUE
                     );

        trc_log_pkg.debug(
            i_text       => 'BIN [#1] (TCR0, position 28) was found among issuing BINs: '
                         || 'institution [#2], network [#3]'
          , i_env_param1 => l_bin_rec.bin
          , i_env_param2 => l_bin_rec.inst_id
          , i_env_param3 => l_bin_rec.network_id
        );

        l_visa.inst_id    := l_bin_rec.inst_id;
        l_visa.network_id := l_bin_rec.network_id;
    exception
        when com_api_error_pkg.e_application_error then
            if com_api_error_pkg.get_last_error = 'BIN_IS_NOT_FOUND' then
                l_visa.inst_id      := null;
                l_visa.network_id   := null;
            else
                raise;
            end if;
    end;

    if l_visa.inst_id is null then
        l_visa.inst_id     := i_inst_id;
        l_visa.network_id  := i_network_id;
    end if;

    l_visa.card_number         := get_card_number(
                                      i_card_number => substr(i_tc_buffer(l_recnum), 5, 19)
                                    , i_network_id  => i_network_id
                                  );
    l_visa.card_hash           := com_api_hash_pkg.get_card_hash(i_card_number => l_visa.card_number);
    l_visa.card_mask           := iss_api_card_pkg.get_card_mask(i_card_number => l_visa.card_number);
    l_visa.oper_currency       := substr(i_tc_buffer(l_recnum), 89, 3);

    trc_log_pkg.debug(
        i_text => 'l_visa.inst_id [' || l_visa.inst_id
               || '], l_visa.network_id [' || l_visa.network_id
               || '], l_visa.card_mask [' || l_visa.card_mask || ']'
    );

    if l_visa.oper_currency in ('000', '00', '0') then
        l_visa.oper_currency      := null;
    end if;

    -- if currency exponent equal to zero then cut-off last two digits from amount in accordance with VISA rules
    if l_visa.oper_currency is not null then
        l_currency_exponent := com_api_currency_pkg.get_currency_exponent(i_curr_code => l_visa.oper_currency);
        if l_currency_exponent = 0 then
            l_visa.oper_amount     := substr(i_tc_buffer(l_recnum), 77, 12 - 2);
        else
            l_visa.oper_amount     := substr(i_tc_buffer(l_recnum), 77, 12);
            if l_currency_exponent > 2 then
                l_visa.oper_amount := l_visa.oper_amount * power(10, l_currency_exponent - 2);
            end if;
        end if;
    end if;

    l_visa.oper_date           := date_mmdd(substr(i_tc_buffer(l_recnum), 58, 4));
    -- if operation date greater than file date then lessen date for a year
    if l_visa.oper_date > i_proc_date then
        l_visa.oper_date       := add_months(l_visa.oper_date, -12);
    end if;

    l_visa.sttl_currency       := substr(i_tc_buffer(l_recnum), 74, 3);
    if l_visa.sttl_currency in ('000', '00', '0') then
        l_visa.sttl_currency      := null;
    end if;
    -- if currency exponent equal to zero then cut-off last two digits from amount in accordance with VISA rules
    if l_visa.sttl_currency is not null then
        l_currency_exponent := com_api_currency_pkg.get_currency_exponent(i_curr_code => l_visa.sttl_currency);
        if l_currency_exponent = 0 then
            l_visa.sttl_amount     := substr(i_tc_buffer(l_recnum), 62, 12 - 2);
        else
            l_visa.sttl_amount     := substr(i_tc_buffer(l_recnum), 62, 12);
            if l_currency_exponent > 2 then
                l_visa.sttl_amount := l_visa.sttl_amount * power(10, l_currency_exponent - 2);
            end if;
        end if;
    end if;
    l_visa.dispute_amount       := l_visa.sttl_amount;
    l_visa.dispute_currency     := l_visa.sttl_currency;
    l_visa.floor_limit_ind      := substr(i_tc_buffer(l_recnum), 24, 1);
    l_visa.exept_file_ind       := substr(i_tc_buffer(l_recnum), 25, 1);
    l_visa.pcas_ind             := substr(i_tc_buffer(l_recnum), 26, 1);
    l_visa.arn                  := substr(i_tc_buffer(l_recnum), 27, 23);
    l_visa.acq_inst_bin         := substr(i_tc_buffer(l_recnum), 28, 6);
    l_visa.acq_business_id      := substr(i_tc_buffer(l_recnum), 50, 8);
    l_visa.merchant_name        := substrb(i_tc_buffer(l_recnum), 92, 25);
    l_visa.merchant_city        := substrb(i_tc_buffer(l_recnum), 117, 13);
    l_visa.merchant_country     := com_api_country_pkg.get_country_code(
                                       i_visa_country_code => trim(substr(i_tc_buffer(l_recnum), 130, 3))
                                   );
    l_visa.mcc                  := substr(i_tc_buffer(l_recnum), 133, 4);
    l_visa.merchant_postal_code := substr(i_tc_buffer(l_recnum), 137, 5);
    l_visa.merchant_region      := substr(i_tc_buffer(l_recnum), 142, 3);
    l_visa.req_pay_service      := substr(i_tc_buffer(l_recnum), 145, 1);
    l_visa.payment_forms_num    := substr(i_tc_buffer(l_recnum), 146, 1);
    l_visa.usage_code           := substr(i_tc_buffer(l_recnum), 147, 1);
    l_visa.reason_code          := substr(i_tc_buffer(l_recnum), 148, 2);
    l_visa.settlement_flag      := substr(i_tc_buffer(l_recnum), 150, 1);
    l_visa.auth_char_ind        := substr(i_tc_buffer(l_recnum), 151, 1);
    l_visa.auth_code            := substr(i_tc_buffer(l_recnum), 152, 6);
    l_visa.pos_terminal_cap     := substr(i_tc_buffer(l_recnum), 158, 1);
    l_visa.crdh_id_method       := substr(i_tc_buffer(l_recnum), 160, 1);
    l_visa.collect_only_flag    := substr(i_tc_buffer(l_recnum), 161, 1);
    l_visa.pos_entry_mode       := substr(i_tc_buffer(l_recnum), 162, 2);
    l_visa.central_proc_date    := substr(i_tc_buffer(l_recnum), 164, 4);
    -- if central processing date greater than file date then lessen base date for a year
    if to_date(l_visa.central_proc_date,'YDDD') > i_proc_date then
        l_visa.central_proc_date := to_char(to_date(substr(to_char(add_months(i_proc_date, -12), 'YYYY'), 1, 3)
                                 || substr(i_tc_buffer(l_recnum), 164, 4), 'YYYYDDD'), 'YDDD');
    end if;
    l_visa.reimburst_attr       := substr(i_tc_buffer(l_recnum), 168, 1);

    l_recnum := 2;

    -- TCR1 data present
    if i_tc_buffer.exists(l_recnum) then
        l_tcr := substr(i_tc_buffer(l_recnum), 4, 1);
    end if;

    -- TCR1 - additional data
    if l_tcr = '1' then
        l_visa.business_format_code  := substr(i_tc_buffer(l_recnum), 5, 1);
        l_visa.token_assurance_level := substr(i_tc_buffer(l_recnum), 6, 2);
        l_visa.chargeback_ref_num    := substr(i_tc_buffer(l_recnum), 17, 6);
        l_visa.docum_ind             := substr(i_tc_buffer(l_recnum), 23, 1);
        l_visa.member_msg_text       := substr(i_tc_buffer(l_recnum), 24, 50);
        l_visa.spec_cond_ind         := substr(i_tc_buffer(l_recnum), 74, 2);
        l_visa.fee_program_ind       := substr(i_tc_buffer(l_recnum), 76, 3);
        l_visa.issuer_charge         := substr(i_tc_buffer(l_recnum), 79, 1);
        l_visa.merchant_number       := substr(i_tc_buffer(l_recnum), 81, 15);
        l_visa.terminal_number       := substr(i_tc_buffer(l_recnum), 96, 8);
        l_visa.national_reimb_fee    := substr(i_tc_buffer(l_recnum), 104, 12);
        l_visa.electr_comm_ind       := substr(i_tc_buffer(l_recnum), 116, 1);
        l_visa.spec_chargeback_ind   := substr(i_tc_buffer(l_recnum), 117, 1);

        if l_standard_version >= vis_api_const_pkg.STANDARD_VERSION_ID_19Q2 then
            l_visa.conv_date             := substr(i_tc_buffer(l_recnum), 118, 4);
        else
            l_visa.interface_trace_num   := substr(i_tc_buffer(l_recnum), 118, 6);
        end if;

        l_visa.unatt_accept_term_ind := substr(i_tc_buffer(l_recnum), 124, 1);
        l_visa.prepaid_card_ind      := substr(i_tc_buffer(l_recnum), 125, 1);
        l_visa.service_development   := substr(i_tc_buffer(l_recnum), 126, 1);
        l_visa.avs_resp_code         := substr(i_tc_buffer(l_recnum), 127, 1);
        l_visa.auth_source_code      := substr(i_tc_buffer(l_recnum), 128, 1);
        l_visa.purch_id_format       := substr(i_tc_buffer(l_recnum), 129, 1);
        l_visa.account_selection     := substr(i_tc_buffer(l_recnum), 130, 1);
        l_visa.installment_pay_count := substr(i_tc_buffer(l_recnum), 131, 2);
        l_visa.purch_id              := substr(i_tc_buffer(l_recnum), 133, 25);
        -- if currency exponent equal to zero then cut-off last two digits from amount in accordance with VISA rules
        if com_api_currency_pkg.get_currency_exponent(i_curr_code => l_visa.oper_currency) = 0 then
            l_visa.cashback          := substr(i_tc_buffer(l_recnum), 158, 9 - 2);
        else
            l_visa.cashback          := substr(i_tc_buffer(l_recnum), 158, 9);
        end if;

        l_visa.chip_cond_code        := substr(i_tc_buffer(l_recnum), 167, 1);
        l_visa.pos_environment       := substr(i_tc_buffer(l_recnum), 168, 1);
--        r_fin.addendum_present          := logical_pkg.bitor (r_fin.addendum_present, c_tcr1_present);
    end if;

    -- TCR5, TCR7 - chip card transaction data, and TCR8 for OPENWAY
    for i in i_tc_buffer.first..i_tc_buffer.last loop
        l_recnum := i; -- Save index value for debug logging on possible exception
        if i_tc_buffer.exists(i) and substr(i_tc_buffer(i), 4, 1) = '5' then

            l_visa.transaction_id         := trim(substr(i_tc_buffer(i), 5, 15));
            l_visa.auth_currency          := trim(substr(i_tc_buffer(i), 32, 3));
            if l_visa.auth_currency in ('000', '00', '0') then
                l_visa.auth_currency      := null;
            end if;

            -- if currency exponent equal to zero then cut-off last two digits from amount in accordance with VISA rules
            if l_visa.auth_currency is not null then
                if com_api_currency_pkg.get_currency_exponent(i_curr_code => l_visa.auth_currency) = 0 then
                    l_visa.auth_amount := substr(i_tc_buffer(i), 20, 12 - 2);
                else
                    l_visa.auth_amount := substr(i_tc_buffer(i), 20, 12);
                end if;
            end if;
            l_visa.auth_resp_code         := trim(substr(i_tc_buffer(i), 35, 2));
            l_visa.clearing_sequence_num  := trim(substr(i_tc_buffer(i), 45, 2));
            l_visa.clearing_sequence_count:= trim(substr(i_tc_buffer(i), 47, 2));
            l_visa.merchant_verif_value   := trim(substr(i_tc_buffer(i), 82, 10));
            l_visa.product_id             := trim(substr(i_tc_buffer(i), 136, 2));
            l_visa.spend_qualified_ind    := trim(substr(i_tc_buffer(i), 149, 1));
            l_visa.pan_token              := trim(substr(i_tc_buffer(i), 150, 16));
            l_visa.cvv2_result_code       := trim(substr(i_tc_buffer(i), 168, 1));

            -- Interchange fee defined as a number with six decimals implied, we need to round it with used exponent,
            -- e.g. string '000002268566820' with l_visa.sttl_currency = 840/USD will be converted to amount 226857
            begin
                l_interchng_fee_amount := nvl(trim(substr(i_tc_buffer(i), 92, 9)), 0)
                                        + nvl(trim(substr(i_tc_buffer(i), 101, 6)), 0) / 1000000;
                l_currency_exponent := com_api_currency_pkg.get_currency_exponent(i_curr_code => l_visa.sttl_currency);
                l_visa.interchange_fee_amount := round(l_interchng_fee_amount * power(10, l_currency_exponent));
            exception
                when com_api_error_pkg.e_value_error then
                    trc_log_pkg.debug(
                        i_text       => sqlcode || ': i_tc_buffer[#1][92..106] = [#2]'
                                     || ', l_interchng_fee_amount [#3], l_currency_exponent [#4]'
                      , i_env_param1 => i
                      , i_env_param2 => substr(i_tc_buffer(i), 92, 15)
                      , i_env_param3 => l_interchng_fee_amount
                      , i_env_param4 => l_currency_exponent
                    );
                    raise;
            end;

            l_visa.interchange_fee_sign   := case trim(substr(i_tc_buffer(i), 107, 1))
                                                 when 'C' then  1
                                                 when 'D' then -1
                                                 else to_number(null)
                                             end;
            l_visa.program_id             := trim(substr(i_tc_buffer(i), 138, 6));
            l_visa.dcc_indicator          := nvl(trim(substr(i_tc_buffer(i), 144, 1)), ' ');

        elsif i_tc_buffer.exists(i) and substr(i_tc_buffer(i), 4, 1) = '7' then

            l_visa.transaction_type     := substr(i_tc_buffer(i), 5, 2);
            l_visa.card_seq_number      := trim(substr(i_tc_buffer(i), 7, 3));
            l_visa.terminal_trans_date  := date_yymmdd(substr(i_tc_buffer(i), 10, 6));
            l_visa.terminal_profile     := substr(i_tc_buffer(i), 16, 6);
            l_visa.terminal_country     := substr(i_tc_buffer(i), 22, 3);
            l_visa.unpredict_number     := substr(i_tc_buffer(i), 33, 8);
            l_visa.appl_trans_counter   := substr(i_tc_buffer(i), 41, 4);
            l_visa.appl_interch_profile := substr(i_tc_buffer(i), 45, 4);
            l_visa.cryptogram           := substr(i_tc_buffer(i), 49, 16);
            l_visa.cryptogram_version   := substr(i_tc_buffer(i), 67, 2);
            l_visa.term_verif_result    := substr(i_tc_buffer(i), 69, 10);
            l_visa.card_verif_result    := substr(i_tc_buffer(i), 79, 8);
            l_visa.cryptogram_amount    := substr(i_tc_buffer(i), 87, 12);
            l_visa.issuer_appl_data     :=
                substr(i_tc_buffer(i), 117, 2) ||
                substr(i_tc_buffer(i), 65,  2) ||
                substr(i_tc_buffer(i), 67,  2) ||
                substr(i_tc_buffer(i), 79,  8) ||
                substr(i_tc_buffer(i), 99,  2) ||
                substr(i_tc_buffer(i), 101, 16)||
                substr(i_tc_buffer(i), 119, 2) ||
                substr(i_tc_buffer(i), 121, 30);
            l_visa.form_factor_indicator := substr(i_tc_buffer(i), 151, 8);
            l_visa.issuer_script_result  := substr(i_tc_buffer(i), 159, 10);

        elsif i_tc_buffer.exists(i) and substr(i_tc_buffer(i), 4, 1) = '8'
          and l_visa_dialect = vis_api_const_pkg.VISA_DIALECT_OPENWAY
         then
            l_visa.oper_date                := nvl(date_yyyymmdd(
                                                       p_date => substr(i_tc_buffer(i), 5, 8)
                                                     , p_time => substr(i_tc_buffer(i), 13, 6)
                                                   )
                                                 , l_visa.oper_date
                                               );
            l_visa.card_expir_date          := substr(i_tc_buffer(i), 31, 4);
            l_visa.card_seq_number          := substr(i_tc_buffer(i), 35, 3);
            l_card_service_code             := substr(i_tc_buffer(i), 125, 3);
            l_visa.rrn                      := substr(i_tc_buffer(i), 19, 12);
            l_visa.merchant_street          := trim(substrb(i_tc_buffer(i), 85, 30));
            l_visa.merchant_postal_code     := trim(substr(i_tc_buffer(i), 115, 10));
            l_visa.chargeback_reason_code   := trim(substr(i_tc_buffer(i), 63, 4));
            l_visa.destination_channel      := trim(substr(i_tc_buffer(i), 67, 1));
            l_visa.source_channel           := trim(substr(i_tc_buffer(i), 68, 1));

        elsif i_tc_buffer.exists(i) and substr(i_tc_buffer(i), 4, 1) = 'E' then
            l_visa.business_format_code_e := substr(i_tc_buffer(i), 5, 2);
            case l_visa.business_format_code_e
                -- Visa Europe V.me by Visa Data
                when 'JA' then
                    l_visa.agent_unique_id := substr(i_tc_buffer(i), 7, 5);
                    l_visa.additional_auth_method := substr(i_tc_buffer(i), 12, 2);
                    l_visa.additional_reason_code := substr(i_tc_buffer(i), 14, 2);
                -- Visa Commerce Overflow Data
                when 'BB' then
                    null;
                else
                    null;
            end case;

        elsif i_tc_buffer.exists(i) and substr(i_tc_buffer(i), 4, 1) = '3' then
            -- TCR 3
            l_visa.business_format_code_3   := substr(i_tc_buffer(i), 17, 2);
            if l_visa.business_format_code_3 =  vis_api_const_pkg.INDUSTRY_SPEC_DATA_CREDIT_FUND then
                l_visa.fast_funds_indicator     := substr(i_tc_buffer(i), 16, 1);
                l_visa.business_application_id  := substr(i_tc_buffer(i), 19, 2);
                l_visa.source_of_funds          := substr(i_tc_buffer(i), 21, 1);
                l_visa.payment_reversal_code    := substr(i_tc_buffer(i), 22, 2);
                l_visa.sender_reference_number  := substr(i_tc_buffer(i), 24, 16);
                l_visa.sender_account_number    := substr(i_tc_buffer(i), 40, 34);
                l_visa.sender_name              := substr(i_tc_buffer(i), 74, 30);
                l_visa.sender_address           := substr(i_tc_buffer(i), 104, 35);
                l_visa.sender_city              := substr(i_tc_buffer(i), 139, 25);
                l_visa.sender_state             := substr(i_tc_buffer(i), 164, 2);
                l_visa.sender_country           := substr(i_tc_buffer(i), 166, 3);
            elsif l_visa.business_format_code_3 =  vis_api_const_pkg.INDUSTRY_SPEC_DATA_PASS_ITINER then
                l_visa.trans_comp_number_tcr3       := substr(i_tc_buffer(i), 4, 1);
                l_visa.business_application_id_tcr3 := substr(i_tc_buffer(i), 15, 2);
                l_visa.passenger_name               := substr(i_tc_buffer(i), 27, 20);
                l_visa.departure_date               := date_mmddyy(p_date => substr(i_tc_buffer(i), 47, 6));
                l_visa.orig_city_airport_code       := substr(i_tc_buffer(i), 53, 3);
                l_visa.carrier_code_1               := substr(i_tc_buffer(i), 56, 2);
                l_visa.service_class_code_1         := substr(i_tc_buffer(i), 58, 1);
                l_visa.stop_over_code_1             := substr(i_tc_buffer(i), 59, 1);
                l_visa.dest_city_airport_code_1     := substr(i_tc_buffer(i), 60, 3);
                l_visa.carrier_code_2               := substr(i_tc_buffer(i), 63, 2);
                l_visa.service_class_code_2         := substr(i_tc_buffer(i), 65, 1);
                l_visa.stop_over_code_2             := substr(i_tc_buffer(i), 66, 1);
                l_visa.dest_city_airport_code_2     := substr(i_tc_buffer(i), 67, 3);
                l_visa.carrier_code_3               := substr(i_tc_buffer(i), 70, 2);
                l_visa.service_class_code_3         := substr(i_tc_buffer(i), 72, 1);
                l_visa.stop_over_code_3             := substr(i_tc_buffer(i), 73, 1);
                l_visa.dest_city_airport_code_3     := substr(i_tc_buffer(i), 74, 3);
                l_visa.carrier_code_4               := substr(i_tc_buffer(i), 77, 2);
                l_visa.service_class_code_4         := substr(i_tc_buffer(i), 79, 1);
                l_visa.stop_over_code_4             := substr(i_tc_buffer(i), 80, 1);
                l_visa.dest_city_airport_code_4     := substr(i_tc_buffer(i), 81, 3);
                l_visa.travel_agency_code           := substr(i_tc_buffer(i), 84, 8);
                l_visa.travel_agency_name           := substr(i_tc_buffer(i), 92, 25);
                l_visa.restrict_ticket_indicator    := substr(i_tc_buffer(i), 117, 1);
                l_visa.fare_basis_code_1            := substr(i_tc_buffer(i), 118, 6);
                l_visa.fare_basis_code_2            := substr(i_tc_buffer(i), 124, 6);
                l_visa.fare_basis_code_3            := substr(i_tc_buffer(i), 130, 6);
                l_visa.fare_basis_code_4            := substr(i_tc_buffer(i), 136, 6);
                l_visa.comp_reserv_system           := substr(i_tc_buffer(i), 142, 4);
                l_visa.flight_number_1              := substr(i_tc_buffer(i), 146, 5);
                l_visa.flight_number_2              := substr(i_tc_buffer(i), 151, 5);
                l_visa.flight_number_3              := substr(i_tc_buffer(i), 156, 5);
                l_visa.flight_number_4              := substr(i_tc_buffer(i), 161, 5);
                l_visa.credit_reason_indicator      := substr(i_tc_buffer(i), 166, 1);
                l_visa.ticket_change_indicator      := substr(i_tc_buffer(i), 167, 1);
            end if;
        elsif i_tc_buffer.exists(i) and substr(i_tc_buffer(i), 4, 1) = 'D' then
            if substr(i_tc_buffer(i), 5, 2) = 'OC' then
                l_visa.recipient_name  := substr(i_tc_buffer(i), 7, 30);
            end if;

        elsif l_standard_version >= vis_api_const_pkg.STANDARD_VERSION_ID_19Q2
          and i_tc_buffer.exists(i)
          and substr(i_tc_buffer(i), 4, 1) = '4' -- TCR 4
         then
            l_visa.business_format_code_4   := substr(i_tc_buffer(i), 5, 2);

            -- Visa Claim Resolution
            if l_visa.business_format_code_4 = 'DF' then
                l_visa.agent_unique_id          := substr(i_tc_buffer(i), 5, 5);
                l_visa.message_reason_code      := 'VMRC'||lpad(trim(substr(i_tc_buffer(i), 47, 4)), 4, '0');
                l_visa.dispute_condition        := substr(i_tc_buffer(i), 51, 3);
                l_visa.vrol_financial_id        := substr(i_tc_buffer(i), 54, 11);
                l_visa.vrol_case_number         := substr(i_tc_buffer(i), 65, 10);
                l_visa.vrol_bundle_number       := substr(i_tc_buffer(i), 75, 10);
                l_visa.client_case_number       := substr(i_tc_buffer(i), 85, 20);
                l_visa.dispute_status           := substr(i_tc_buffer(i), 105, 2);

            -- Supplemental Financial Data & Supplemental Financial and Promotion Data
            elsif l_visa.business_format_code_4 in ('SD', 'SP') then
                l_visa.agent_unique_id          := substr(i_tc_buffer(i), 5, 5);
                l_visa.payment_acc_ref          := substr(i_tc_buffer(i), 120, 29);
                l_visa.token_requestor_id       := substr(i_tc_buffer(i), 149, 11);

                if com_api_currency_pkg.get_currency_exponent(i_curr_code => l_visa.oper_currency) = 0 then
                    l_visa.surcharge_amount     := substr(i_tc_buffer(i), 51, 8 - 2);
                else
                    l_visa.surcharge_amount     := substr(i_tc_buffer(i), 51, 8);
                end if;

                l_visa.surcharge_sign           := upper(substr(i_tc_buffer(i), 59, 2));

                l_visa.message_reason_code      := 'VMRC'||lpad(trim(substr(i_tc_buffer(i), 47, 4)), 4, '0');
            else
                null;
            end if;

        elsif i_tc_buffer.exists(i) -- Will be obsolete after Mandates 19Q2 take effect
            and substr(i_tc_buffer(i), 4, 1) = '4' -- TCR 4
            and (l_visa.trans_code like '_5' or l_visa.trans_code like '_6' or l_visa.trans_code like '_7') -- TC_SALES*, TC_VOUCHER* , TC_CASH*
            and l_visa.trans_code_qualifier = '0'
            and l_visa.usage_code != '9'
        then
            l_visa.agent_unique_id          := substr(i_tc_buffer(i), 5, 5);
            l_visa.payment_acc_ref          := substr(i_tc_buffer(i), 120, 29);
            l_visa.token_requestor_id       := substr(i_tc_buffer(i), 149, 11);

        elsif i_tc_buffer.exists(i) -- Will be obsolete after Mandates 19Q2 take effect
            and substr(i_tc_buffer(i), 4, 1) = '4' -- TCR 4
            and l_visa.usage_code = '9'            -- Visa Claims Resolution
        then
            l_visa.agent_unique_id          := substr(i_tc_buffer(i), 5, 5);
            l_visa.message_reason_code      := 'VMRC'||lpad(trim(substr(i_tc_buffer(i), 47, 4)), 4, '0');
            l_visa.dispute_condition        := substr(i_tc_buffer(i), 51, 3);
            l_visa.vrol_financial_id        := substr(i_tc_buffer(i), 54, 11);
            l_visa.vrol_case_number         := substr(i_tc_buffer(i), 65, 10);
            l_visa.vrol_bundle_number       := substr(i_tc_buffer(i), 75, 10);
            l_visa.client_case_number       := substr(i_tc_buffer(i), 85, 20);
            l_visa.dispute_status           := substr(i_tc_buffer(i), 105, 2);
        end if;
    end loop;

    l_oper.oper_type :=
        net_api_map_pkg.get_oper_type(
            i_network_oper_type  => l_visa.trans_code || l_visa.trans_code_qualifier || l_visa.mcc || nvl(l_visa.business_application_id, '__')
          , i_standard_id        => i_standard_id
        );

    -- Check trans_code
    if l_visa.trans_code = vis_api_const_pkg.TC_SALES and to_number(l_visa.cashback) > 0 then
        l_oper.oper_cashback_amount := to_number(l_visa.cashback);
        l_oper.oper_type            := opr_api_const_pkg.OPERATION_TYPE_CASHBACK;
    end if;

    -- Quasi cash transactions
    get_oper_type(
        io_oper_type  => l_oper.oper_type
      , i_mcc         => l_visa.mcc
      , i_mask_error  => com_api_type_pkg.TRUE
    );
    if l_oper.oper_type is null then
        trc_log_pkg.warn(
            i_text        => 'OPERATION_TYPE_EXCEPT'
          , i_env_param1  => l_visa.trans_code || l_visa.trans_code_qualifier || l_visa.mcc
          , i_env_param2  => i_standard_id
          , i_entity_type => opr_api_const_pkg.ENTITY_TYPE_OPERATION
          , i_object_id   => l_visa.id
        );
        l_visa.status     := net_api_const_pkg.CLEARING_MSG_STATUS_INVALID;
        l_visa.is_invalid := com_api_type_pkg.TRUE;
        g_error_flag      := com_api_type_pkg.TRUE;
    end if;

    -- post assignment
    if l_visa.trans_code in (
           vis_api_const_pkg.TC_SALES
         , vis_api_const_pkg.TC_VOUCHER
         , vis_api_const_pkg.TC_CASH
       )
     and l_visa.usage_code = '1'
    then
        iss_api_bin_pkg.get_bin_info(
            i_card_number      => l_visa.card_number
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
            l_visa.is_invalid := com_api_type_pkg.TRUE;
            l_iss_inst_id     := i_inst_id;
            l_iss_network_id  := ost_api_institution_pkg.get_inst_network(i_inst_id);

            trc_log_pkg.warn(
                i_text        => 'BIN_NOT_FOUND_BY_CARD_NUMBER'
              , i_env_param1  => l_visa.card_mask
              , i_env_param2  => substr(l_visa.card_number, 1, 6)
              , i_entity_type => opr_api_const_pkg.ENTITY_TYPE_OPERATION
              , i_object_id   => l_visa.id
            );
        end if;

        begin
            l_acq_inst_id := cmn_api_standard_pkg.find_value_owner(
                                 i_standard_id       => i_standard_id
                               , i_entity_type       => net_api_const_pkg.ENTITY_TYPE_HOST
                               , i_object_id         => i_host_id
                               , i_param_name        => vis_api_const_pkg.ACQ_BUSINESS_ID
                               , i_value_char        => l_visa.acq_business_id
                               , i_mask_error        => com_api_const_pkg.TRUE
                             );
            l_acq_network_id := ost_api_institution_pkg.get_inst_network(i_inst_id => l_acq_inst_id);
        exception
            when com_api_error_pkg.e_application_error then
                if com_api_error_pkg.get_last_error = 'NOT_FOUND_VALUE_OWNER' then
                    l_acq_inst_id := null;
                else
                    raise;
                end if;
        end;

        if l_acq_inst_id is null then
            l_acq_network_id := i_network_id;
            l_acq_inst_id    := net_api_network_pkg.get_inst_id(i_network_id);
        end if;

        net_api_sttl_pkg.get_sttl_type(
            i_iss_inst_id      => l_iss_inst_id
          , i_acq_inst_id      => l_acq_inst_id
          , i_card_inst_id     => l_card_inst_id
          , i_iss_network_id   => l_iss_network_id
          , i_acq_network_id   => l_acq_network_id
          , i_card_network_id  => l_card_network_id
          , i_acq_inst_bin     => l_visa.acq_inst_bin
          , o_sttl_type        => l_sttl_type
          , o_match_status     => l_match_status
          , i_oper_type        => l_oper.oper_type
        );

    -- assign dispute id
    else
        assign_dispute(
            io_visa            => l_visa
          , i_standard_id      => i_standard_id
          , o_iss_inst_id      => l_iss_inst_id
          , o_iss_network_id   => l_iss_network_id
          , o_acq_inst_id      => l_acq_inst_id
          , o_acq_network_id   => l_acq_network_id
          , o_sttl_type        => l_sttl_type
          , o_match_status     => l_match_status
          , i_need_repeat      => i_need_repeat
        );

        -- dispute is found for reversal presentment and original presentment is matched
        if l_visa.dispute_id is not null then

            opr_api_clearing_pkg.match_reversal(
                i_oper_id           => l_visa.id
              , i_is_reversal       => l_visa.is_reversal
              , i_network_refnum    => l_visa.arn
              , i_oper_amount       => l_visa.oper_amount
              , i_oper_currency     => l_visa.oper_currency
              , i_card_number       => l_visa.card_number
              , i_inst_id           => l_iss_inst_id
              , io_match_status     => l_match_status
              , io_match_id         => l_match_id
            );

        -- dispute is not found
        elsif l_visa.dispute_id is null then
            if l_visa.trans_code in (
                vis_api_const_pkg.TC_SALES_CHARGEBACK
              , vis_api_const_pkg.TC_VOUCHER_CHARGEBACK
              , vis_api_const_pkg.TC_CASH_CHARGEBACK
              , vis_api_const_pkg.TC_SALES_CHARGEBACK_REV
              , vis_api_const_pkg.TC_VOUCHER_CHARGEBACK_REV
              , vis_api_const_pkg.TC_CASH_CHARGEBACK_REV
            ) then

                iss_api_bin_pkg.get_bin_info(
                    i_card_number      => l_visa.card_number
                  , o_iss_inst_id      => l_iss_inst_id
                  , o_iss_network_id   => l_iss_network_id
                  , o_card_inst_id     => l_card_inst_id
                  , o_card_network_id  => l_card_network_id
                  , o_card_type        => l_card_type_id
                  , o_card_country     => l_country_code
                  , o_bin_currency     => l_bin_currency
                  , o_sttl_currency    => l_sttl_currency
                );

                if l_iss_inst_id is null then
                    l_iss_network_id := i_network_id;--src
                    l_iss_inst_id    := net_api_network_pkg.get_inst_id(i_network_id => i_network_id);
                end if;
                l_card_inst_id     := null;
                l_card_network_id  := null;
                l_card_type_id     := null;
                l_country_code     := null;
                l_bin_currency     := null;
                l_sttl_currency    := null;

                begin
                    l_acq_inst_id := cmn_api_standard_pkg.find_value_owner(
                                         i_standard_id       => i_standard_id
                                       , i_entity_type       => net_api_const_pkg.ENTITY_TYPE_HOST
                                       , i_object_id         => i_host_id
                                       , i_param_name        => vis_api_const_pkg.ACQ_BUSINESS_ID
                                       , i_value_char        => l_visa.acq_business_id
                                       , i_mask_error        => com_api_const_pkg.TRUE
                                     );
                    l_acq_network_id := ost_api_institution_pkg.get_inst_network(i_inst_id => l_acq_inst_id);
                exception
                    when com_api_error_pkg.e_application_error then
                        if com_api_error_pkg.get_last_error = 'NOT_FOUND_VALUE_OWNER' then
                            l_acq_inst_id := null;
                        else
                            raise;
                        end if;
                end;

                if l_acq_inst_id is null then
                    l_acq_inst_id    := i_inst_id; --dst
                    l_acq_network_id := ost_api_institution_pkg.get_inst_network(i_inst_id => i_inst_id);
                end if;

            elsif l_visa.trans_code in (
                      vis_api_const_pkg.TC_SALES
                    , vis_api_const_pkg.TC_VOUCHER
                    , vis_api_const_pkg.TC_CASH
                    , vis_api_const_pkg.TC_SALES_REVERSAL
                    , vis_api_const_pkg.TC_VOUCHER_REVERSAL
                    , vis_api_const_pkg.TC_CASH_REVERSAL
                  )
            then
                iss_api_bin_pkg.get_bin_info(
                    i_card_number      => l_visa.card_number
                  , o_iss_inst_id      => l_iss_inst_id
                  , o_iss_network_id   => l_iss_network_id
                  , o_card_inst_id     => l_card_inst_id
                  , o_card_network_id  => l_card_network_id
                  , o_card_type        => l_card_type_id
                  , o_card_country     => l_country_code
                  , o_bin_currency     => l_bin_currency
                  , o_sttl_currency    => l_sttl_currency
                );

                if l_iss_inst_id is null then
                    l_iss_inst_id     := i_inst_id; --dst
                    l_iss_network_id  := ost_api_institution_pkg.get_inst_network(i_inst_id => i_inst_id);
                end if;
                l_card_inst_id     := null;
                l_card_network_id  := null;
                l_card_type_id     := null;
                l_country_code     := null;
--                l_bin_currency     := null;
--                l_sttl_currency    := null;

                begin
                    l_acq_inst_id := cmn_api_standard_pkg.find_value_owner(
                                         i_standard_id       => i_standard_id
                                       , i_entity_type       => net_api_const_pkg.ENTITY_TYPE_HOST
                                       , i_object_id         => i_host_id
                                       , i_param_name        => vis_api_const_pkg.ACQ_BUSINESS_ID
                                       , i_value_char        => l_visa.acq_business_id
                                       , i_mask_error        => com_api_const_pkg.TRUE
                                     );
                    l_acq_network_id := ost_api_institution_pkg.get_inst_network(i_inst_id => l_acq_inst_id);
                exception
                    when com_api_error_pkg.e_application_error then
                        if com_api_error_pkg.get_last_error = 'NOT_FOUND_VALUE_OWNER' then
                            l_acq_inst_id := null;
                        else
                            raise;
                        end if;
                end;

                if l_acq_inst_id is null then
                    l_acq_network_id := i_network_id;--src
                    l_acq_inst_id    := net_api_network_pkg.get_inst_id(i_network_id => i_network_id);
                end if;
            end if;

            if l_card_inst_id is null then
                net_api_bin_pkg.get_bin_info(
                    i_card_number           => l_visa.card_number
                  , i_oper_type             => null
                  , i_terminal_type         => null
                  , i_acq_inst_id           => l_acq_inst_id
                  , i_acq_network_id        => l_acq_network_id
                  , i_msg_type              => null
                  , i_oper_reason           => null
                  , i_oper_currency         => null
                  , i_merchant_id           => null
                  , i_terminal_id           => null
                  , o_iss_inst_id           => l_iss_inst_id2
                  , o_iss_network_id        => l_iss_network_id2
                  , o_iss_host_id           => l_iss_host_id
                  , o_card_type_id          => l_card_type_id
                  , o_card_country          => l_card_country
                  , o_card_inst_id          => l_card_inst_id
                  , o_card_network_id       => l_card_network_id
                  , o_pan_length            => l_pan_length
                  , i_raise_error           => com_api_type_pkg.FALSE
                );
            end if;

            net_api_sttl_pkg.get_sttl_type(
                i_iss_inst_id      => l_iss_inst_id
              , i_acq_inst_id      => l_acq_inst_id
              , i_card_inst_id     => l_card_inst_id
              , i_iss_network_id   => l_iss_network_id
              , i_acq_network_id   => l_acq_network_id
              , i_card_network_id  => l_card_network_id
              , i_acq_inst_bin     => l_visa.acq_inst_bin
              , o_sttl_type        => l_sttl_type
              , o_match_status     => l_match_status
              , i_oper_type        => l_oper.oper_type
            );
        end if;
    end if;

    -- Settlement in EUR is used for some TC(s)
    if l_visa.trans_code in (
           vis_api_const_pkg.TC_SALES
         , vis_api_const_pkg.TC_VOUCHER
         , vis_api_const_pkg.TC_CASH
         , vis_api_const_pkg.TC_SALES_REVERSAL
         , vis_api_const_pkg.TC_VOUCHER_REVERSAL
         , vis_api_const_pkg.TC_CASH_REVERSAL
       )
    then
        if l_visa.oper_currency in (com_api_currency_pkg.EURO, com_api_currency_pkg.RUBLE) then
            cmn_api_standard_pkg.get_param_value(
                i_inst_id      => l_iss_inst_id
              , i_standard_id  => i_standard_id
              , i_object_id    => i_host_id
              , i_entity_type  => net_api_const_pkg.ENTITY_TYPE_HOST
              , i_param_name   => case 
                                   when l_visa.oper_currency = com_api_currency_pkg.EURO then vis_api_const_pkg.EURO_SETTLEMENT
                                   else vis_api_const_pkg.RUB_SETTLEMENT
                                   end
              , o_param_value  => l_other_settlement
              , i_param_tab    => l_param_tab
            );
            if l_other_settlement = com_api_type_pkg.TRUE then
                l_visa.network_amount   := l_visa.sttl_amount;
                l_visa.network_currency := l_visa.sttl_currency;
                l_visa.sttl_amount      := l_visa.oper_amount;
                l_visa.sttl_currency    := l_visa.oper_currency;
            end if;
        end if;
    end if;

    l_card_rec := iss_api_card_pkg.get_card(
                      i_card_number   => l_visa.card_number
                    , i_mask_error    => com_api_type_pkg.TRUE
                  );

    l_visa.card_id   := l_card_rec.id;
    l_visa.status    := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;

    l_oper.match_status := l_match_status;
    l_oper.match_id     := l_match_id;

    l_oper.sttl_type := l_sttl_type;
    if l_oper.sttl_type is null then
        l_visa.status := net_api_const_pkg.CLEARING_MSG_STATUS_INVALID;
        l_visa.is_invalid := com_api_type_pkg.TRUE;

        trc_log_pkg.warn(
            i_text        => 'UNABLE_TO_DEFINE_SETTLEMENT_TYPE'
          , i_env_param1  => l_iss_inst_id
          , i_env_param2  => l_acq_inst_id
          , i_env_param3  => l_card_inst_id
          , i_env_param4  => l_iss_network_id
          , i_env_param5  => l_acq_network_id
          , i_env_param6  => l_card_network_id
          , i_entity_type => opr_api_const_pkg.ENTITY_TYPE_OPERATION
          , i_object_id   => l_visa.id
        );

        g_error_flag := com_api_type_pkg.TRUE;
    end if;

    if l_visa.usage_code = '1'
       and l_visa.trans_code in (vis_api_const_pkg.TC_SALES, vis_api_const_pkg.TC_SALES_REVERSAL)
    then
        if l_visa.clearing_sequence_num         = l_visa.clearing_sequence_count
            and l_visa.clearing_sequence_count in (0, 1)
        then
            l_oper.msg_type := opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT;
 
        elsif l_visa.clearing_sequence_num      < l_visa.clearing_sequence_count then
            l_oper.msg_type := opr_api_const_pkg.MESSAGE_TYPE_PARTIAL_AMOUNT;
 
        elsif l_visa.clearing_sequence_num      = l_visa.clearing_sequence_count then
            l_oper.msg_type := opr_api_const_pkg.MESSAGE_TYPE_PART_AMOUNT_COMPL;
 
        end if;
    end if;

    if l_oper.msg_type is null then
        l_oper.msg_type :=
            net_api_map_pkg.get_msg_type(
                i_network_msg_type  => l_visa.usage_code || l_visa.trans_code
              , i_standard_id       => i_standard_id
            );
    end if;

    if l_oper.msg_type is null then
        trc_log_pkg.warn(
            i_text        => 'NETWORK_MESSAGE_TYPE_EXCEPT'
          , i_env_param1  => l_visa.usage_code||l_visa.trans_code
          , i_env_param2  => i_standard_id
          , i_entity_type => opr_api_const_pkg.ENTITY_TYPE_OPERATION
          , i_object_id   => l_visa.id
        );
        l_visa.status     := net_api_const_pkg.CLEARING_MSG_STATUS_INVALID;
        l_visa.is_invalid := com_api_type_pkg.TRUE;
        g_error_flag      := com_api_type_pkg.TRUE;
    end if;

    l_oper.id                := l_visa.id;
    l_oper.is_reversal       := l_visa.is_reversal;
    l_oper.oper_amount       := l_visa.oper_amount;
    l_oper.oper_currency     := l_visa.oper_currency;
    l_oper.sttl_amount       := l_visa.sttl_amount;
    l_oper.sttl_currency     := l_visa.sttl_currency;
    l_oper.oper_date         := l_visa.oper_date;
    l_oper.host_date         := null;
    l_oper.mcc               := l_visa.mcc;
    l_oper.originator_refnum := l_visa.rrn;
    l_oper.network_refnum    := l_visa.arn;
    l_oper.acq_inst_bin      := l_visa.acq_inst_bin;
    l_oper.merchant_number   := l_visa.merchant_number;
    l_oper.merchant_name     := l_visa.merchant_name;
    l_oper.merchant_street   := l_visa.merchant_street;
    l_oper.merchant_city     := l_visa.merchant_city;
    l_oper.merchant_region   := l_visa.merchant_region;
    l_oper.merchant_postcode := l_visa.merchant_postal_code;

    -- Original_id is calculated after dispute_id. It is need for correct post-processing of the deferred messages.
    l_oper.dispute_id        := l_visa.dispute_id;
    l_oper.original_id       := vis_api_fin_message_pkg.get_original_id(
                                    i_fin_rec          => l_visa
                                  , i_fee_rec          => null
                                  , o_need_original_id => l_need_original_id
                                );

    if l_need_original_id = com_api_type_pkg.TRUE then
        io_no_original_id_tab(io_no_original_id_tab.count + 1) := l_visa;
    end if;

    if l_visa.dispute_id is null then
        l_oper.merchant_country  := l_visa.merchant_country;
        l_acq_part.merchant_id   := null;
        l_acq_part.terminal_id   := null;
        l_oper.terminal_number   := l_visa.terminal_number;
        l_oper.terminal_type     :=
            case
                when l_visa.electr_comm_ind in ('5', '6', '7', '8') then
                    acq_api_const_pkg.TERMINAL_TYPE_EPOS
                when l_visa.mcc in ('6012','4829')
                 and l_oper.oper_type in (opr_api_const_pkg.OPERATION_TYPE_P2P_DEBIT
                                        , opr_api_const_pkg.OPERATION_TYPE_P2P_CREDIT)
                then
                    case l_visa.pos_terminal_cap
                        when '5'
                        then acq_api_const_pkg.TERMINAL_TYPE_ATM
                        else acq_api_const_pkg.TERMINAL_TYPE_EPOS
                    end
                when l_visa.mcc = '6011' then
                    acq_api_const_pkg.TERMINAL_TYPE_ATM
                else
                    acq_api_const_pkg.TERMINAL_TYPE_POS
            end;
        l_iss_part.card_expir_date := date_yymm(l_visa.card_expir_date);
    else
        opr_api_operation_pkg.get_operation(
            i_oper_id             => l_visa.dispute_id
          , o_operation           => l_operation
        );
        l_oper.terminal_type     := l_operation.terminal_type;
        l_oper.merchant_country  := l_operation.merchant_country;
        -- inherit terminal_number from original operation to support long terminal_number version
        l_oper.terminal_number   := l_operation.terminal_number;
        opr_api_operation_pkg.get_participant(
            i_oper_id            => l_operation.id
          , i_participaint_type  => com_api_const_pkg.PARTICIPANT_ACQUIRER
          , o_participant        => l_participant
        );
        l_acq_part.merchant_id   := l_participant.merchant_id;
        l_acq_part.terminal_id   := l_participant.terminal_id;
        opr_api_operation_pkg.get_participant(
            i_oper_id            => l_operation.id
          , i_participaint_type  => com_api_const_pkg.PARTICIPANT_ISSUER
          , o_participant        => l_participant
        );
        l_iss_part.card_expir_date := l_participant.card_expir_date;
    end if;

    l_oper.incom_sess_file_id      := i_incom_sess_file_id;

    l_iss_part.inst_id             := l_iss_inst_id;
    l_iss_part.network_id          := l_iss_network_id;
    l_iss_part.card_id             := l_visa.card_id;
    l_iss_part.card_type_id        := nvl(l_card_type_id, l_card_rec.card_type_id);
    l_iss_part.card_seq_number     := replace(l_visa.card_seq_number, ' ', '');
    l_iss_part.client_id_type      := opr_api_const_pkg.CLIENT_ID_TYPE_CARD;
    l_iss_part.client_id_value     := l_visa.card_number;
    l_iss_part.customer_id         := l_card_rec.customer_id;
    l_iss_part.card_mask           := l_visa.card_mask;
    l_iss_part.card_number         := l_visa.card_number;
    l_iss_part.card_hash           := l_visa.card_hash;
    l_iss_part.card_country        := nvl(l_country_code, l_card_rec.country);
    l_iss_part.card_inst_id        := l_card_inst_id;
    l_iss_part.card_network_id     := l_card_network_id;
    l_iss_part.split_hash          := com_api_hash_pkg.get_split_hash(l_visa.card_number);
    l_iss_part.card_service_code   := l_card_service_code;
    l_iss_part.account_amount      := null;
    l_iss_part.account_currency    := null;
    --l_oper.netw_date               := to_date(l_visa.central_proc_date,'YDDD');
    l_iss_part.account_number      := null;
    l_iss_part.auth_code           := l_visa.auth_code;

    l_acq_part.inst_id             := l_acq_inst_id;
    l_acq_part.network_id          := l_acq_network_id;
    l_acq_part.split_hash          := null;

    if  l_visa.trans_code in (vis_api_const_pkg.TC_SALES, vis_api_const_pkg.TC_VOUCHER, vis_api_const_pkg.TC_CASH)
        and l_visa.usage_code = com_api_type_pkg.TRUE
        and l_card_rec.id is null
    then
        l_oper.proc_mode := aut_api_const_pkg.AUTH_PROC_MODE_CARD_ABSENT;
        l_oper.status    := opr_api_const_pkg.OPERATION_STATUS_MANUAL;
        trc_log_pkg.warn(
            i_text         => 'CARD_NOT_FOUND'
          , i_env_param1   => l_visa.card_mask
          , i_entity_type  => opr_api_const_pkg.ENTITY_TYPE_OPERATION
          , i_object_id    => l_visa.id
        );
    end if;

    if l_visa.is_invalid = com_api_type_pkg.TRUE then
        g_error_flag  := com_api_type_pkg.TRUE;
        l_visa.status := net_api_const_pkg.CLEARING_MSG_STATUS_INVALID;
        l_oper.status := opr_api_const_pkg.OPERATION_STATUS_MANUAL;
    end if;

    l_oper.clearing_sequence_num   := l_visa.clearing_sequence_num;
    l_oper.clearing_sequence_count := l_visa.clearing_sequence_count;

    if nvl(i_create_operation, com_api_type_pkg.TRUE) = com_api_type_pkg.TRUE then
        -- create operation
        if l_visa.business_application_id in (vis_api_const_pkg.BAI_MERCHANT_PAYMENT, vis_api_const_pkg.BAI_CASH_OUT)
            and l_visa.trans_code = vis_api_const_pkg.TC_VOUCHER then

            l_acq_part.card_number     := trim(l_visa.sender_account_number);
            l_acq_part.client_id_type  := opr_api_const_pkg.CLIENT_ID_TYPE_CARD;
            l_acq_part.client_id_value := l_visa.card_number;

            vis_cst_incoming_pkg.before_creating_operation(
                io_oper     => l_oper
              , io_iss_part => l_acq_part
              , io_acq_part => l_iss_part
            );
            opr_api_create_pkg.create_operation(
                i_oper      => l_oper
              , i_iss_part  => l_acq_part
              , i_acq_part  => l_iss_part
            );

        else
            vis_cst_incoming_pkg.before_creating_operation(
                io_oper     => l_oper
              , io_iss_part => l_iss_part
              , io_acq_part => l_acq_part
            );
            opr_api_create_pkg.create_operation(
                i_oper      => l_oper
              , i_iss_part  => l_iss_part
              , i_acq_part  => l_acq_part
            );
        end if;

        process_csm(
            i_oper              => l_oper
          , i_visa              => l_visa
          , i_card_inst_id      => l_card_inst_id
          , i_standard_id       => i_standard_id
          , i_perform_check     => com_api_const_pkg.TRUE
          , i_create_disp_case  => i_create_disp_case
        );
        if i_register_loading_event = com_api_type_pkg.TRUE then
            evt_api_event_pkg.register_event(
                i_event_type        => case when l_visa.is_invalid = com_api_type_pkg.TRUE then
                                           opr_api_const_pkg.EVENT_LOADED_WITH_ERRORS
                                       else
                                           opr_api_const_pkg.EVENT_LOADED_SUCCESSFULLY
                                       end
              , i_eff_date          => get_sysdate
              , i_entity_type       => opr_api_const_pkg.ENTITY_TYPE_OPERATION
              , i_object_id         => l_oper.id
              , i_inst_id           => l_visa.inst_id
              , i_split_hash        => com_api_hash_pkg.get_split_hash(
                                           i_entity_type   => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                                         , i_object_id     => l_oper.id
                                       )
            );
        end if;
    end if;

    l_visa.host_inst_id := net_api_network_pkg.get_inst_id(i_network_id => l_visa.network_id);
    l_visa.proc_bin     := i_proc_bin;

    vis_cst_incoming_pkg.process_fin_message(io_fin_rec => l_visa);

    l_visa.id := vis_api_fin_message_pkg.put_message(i_fin_rec => l_visa);

    -- Collect addendum TCRs
    for i in i_tc_buffer.first..i_tc_buffer.last loop
        l_recnum := i; -- Save index value for debug logging on possible exception
        if i_tc_buffer.exists(i) and substr(i_tc_buffer(i), 4, 1) not in ('0', '1', '7') then
            create_fin_addendum(
                i_fin_msg_id  => l_visa.id
              , i_raw_data    => i_tc_buffer(i)
            );
        end if;
    end loop;

    count_amount(
        io_amount_tab    => io_amount_tab
      , i_sttl_amount    => l_oper.sttl_amount
      , i_sttl_currency  => l_oper.sttl_currency
    );

    if i_validate_record = com_api_const_pkg.TRUE then
        for i in i_tc_buffer.first .. i_tc_buffer.last loop
            l_recnum := i; -- Save index value for debug logging on possible exception
            if i_tc_buffer.exists(i) then
                vis_api_reject_pkg.validate_visa_record_auth(
                    i_oper_id     => l_visa.id
                  , i_visa_data   => i_tc_buffer(i)
                );
            end if;
        end loop;
    end if;

    trc_log_pkg.debug(LOG_PREFIX || 'END');

exception
    when com_api_error_pkg.e_application_error
      or com_api_error_pkg.e_fatal_error
      or com_api_error_pkg.e_need_original_record
    then
        raise;
    when others then
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'FAILED on i_tc_buffer[#2] = [#1]'
          , i_env_param1 => case
                                when i_tc_buffer.exists(l_recnum)
                                then case
                                         when l_recnum != 1
                                         then i_tc_buffer(l_recnum)
                                         -- Masking card number for TC = 1
                                         else substr(i_tc_buffer(l_recnum), 1, 10) -- first 6 digits
                                              || lpad('*', 9, '*') ||
                                              substr(i_tc_buffer(l_recnum), 20)    -- last 4 digits
                                     end
                                
                            end
          , i_env_param2 => l_recnum
        );
        com_api_error_pkg.raise_fatal_error(
            i_error      => 'UNHANDLED_EXCEPTION'
          , i_env_param1 => sqlerrm
        );
end process_draft;

procedure process_returned (
    i_tc_buffer             in vis_api_type_pkg.t_tc_buffer
    , i_record_number       in com_api_type_pkg.t_short_id
    , i_file_id             in com_api_type_pkg.t_long_id
    , i_batch_id            in com_api_type_pkg.t_medium_id
    , i_validate_record     in com_api_type_pkg.t_boolean
) is
    l_msg                   vis_returned%rowtype := NULL;
    l_orig_file_id          com_api_type_pkg.t_long_id;
    l_orig_batch_id         com_api_type_pkg.t_long_id;
    l_arn                   varchar2(23);

    function get_field (
        i_start       in pls_integer
        , i_length    in pls_integer
    ) return varchar2 is
    begin
        return trim(substr(i_tc_buffer(i_tc_buffer.count), i_start, i_length));
    end;

    procedure insert_returned (
        i_msg in vis_returned%rowtype
    ) is
    begin
        insert into vis_returned (
            id
            , dst_bin
            , src_bin
            , original_tc
            , original_tcq
            , original_tcr
            , src_batch_date
            , src_batch_number
            , item_seq_number
            , original_amount
            , original_currency
            , original_sttl_flag
            , crs_return_flag
            , reason_code1
            , reason_code2
            , reason_code3
            , reason_code4
            , reason_code5
            , original_id
            , file_id
            , batch_id
            , record_number
        )
        values (
            vis_returned_seq.nextval
            , i_msg.dst_bin
            , i_msg.src_bin
            , i_msg.original_tc
            , i_msg.original_tcq
            , i_msg.original_tcr
            , i_msg.src_batch_date
            , i_msg.src_batch_number
            , i_msg.item_seq_number
            , i_msg.original_amount
            , i_msg.original_currency
            , i_msg.original_sttl_flag
            , i_msg.crs_return_flag
            , i_msg.reason_code1
            , i_msg.reason_code2
            , i_msg.reason_code3
            , i_msg.reason_code4
            , i_msg.reason_code5
            , i_msg.original_id
            , i_msg.file_id
            , i_msg.batch_id
            , i_msg.record_number
       );
    end;
begin
    if substr(i_tc_buffer(i_tc_buffer.count),4,1)<>'9' then
        trc_log_pkg.error (
            i_text          => 'TCR9_NOT_FOUND_IN_RETURNED_ITEM'
            , i_env_param1  => i_record_number
        );
    end if;

    l_msg.dst_bin            := get_field(5, 6);
    l_msg.src_bin            := get_field(11, 6);
    l_msg.original_tc        := get_field(17, 2);
    l_msg.original_tcq       := get_field(19, 1);
    l_msg.original_tcr       := get_field(20, 1);
    l_msg.src_batch_date     := to_date(get_field(21, 5), 'YYDDD');
    l_msg.src_batch_number   := get_field(26, 6);
    l_msg.item_seq_number    := get_field(32, 4);
    l_msg.original_amount    := get_field(39, 12);
    l_msg.original_currency  := get_field(51, 3);
    l_msg.original_sttl_flag := get_field(54, 1);
    l_msg.crs_return_flag    := get_field(55, 1);
    l_msg.reason_code1       := get_field(36, 3);
    l_msg.reason_code2       := get_field(56, 3);
    l_msg.reason_code3       := get_field(59, 3);
    l_msg.reason_code4       := get_field(62, 3);
    l_msg.reason_code5       := get_field(65, 3);

    -- arn from the transaction being returned
    l_arn := substr(i_tc_buffer(1), 27, 23);

    -- mark original outgoing batch as returned
    update
        vis_batch b
    set
        b.is_returned = com_api_const_pkg.TRUE
    where
        b.batch_number = to_number(l_msg.src_batch_number)
        and trunc(b.proc_date) = l_msg.src_batch_date
        and exists (
            select
                1
            from
                vis_file f
            where
                f.id = b.file_id
                and f.is_incoming = 0
        )
    returning
        b.id
        , b.file_id
    into
        l_orig_batch_id
        , l_orig_file_id;

    -- mark original file as returned
    update
        vis_file
    set
        is_returned = com_api_const_pkg.TRUE
    where
        id = l_orig_file_id;

    -- mark original message as returned
    update vis_fin_message o
       set o.is_returned = com_api_const_pkg.TRUE
     where o.batch_id                         = l_orig_batch_id
       and o.file_id                          = l_orig_file_id
       and to_char(o.record_number, 'FM0000') = l_msg.item_seq_number
       and o.arn                              = l_arn
 returning id
      into l_msg.original_id;

    if l_msg.original_id is null then
        com_api_error_pkg.raise_error (
            i_error         =>  'CAN_NOT_MARK_ORIGINAL_MESSAGE_AS_RETURNED'
            , i_env_param1  => l_orig_batch_id
            , i_env_param2  => l_orig_file_id
            , i_env_param3  => l_msg.item_seq_number
        );
    end if;

    l_msg.file_id            := i_file_id;
    l_msg.batch_id           := i_batch_id;
    l_msg.record_number      := i_record_number;

    insert_returned(l_msg);

    if i_validate_record = com_api_const_pkg.TRUE
    then
        vis_api_reject_pkg.validate_visa_record_auth(
            i_oper_id     => null
            , i_visa_data => i_tc_buffer(i_tc_buffer.count)
        );
    end if;
end process_returned;

procedure process_money_transfer (
    i_tc_buffer             in vis_api_type_pkg.t_tc_buffer
    , i_file_id             in com_api_type_pkg.t_long_id
    , i_record_number       in com_api_type_pkg.t_short_id
    , i_inst_id             in com_api_type_pkg.t_inst_id
    , i_network_id          in com_api_type_pkg.t_tiny_id
    , i_validate_record     in com_api_type_pkg.t_boolean
) is
    l_visa                  vis_api_type_pkg.t_visa_fin_mes_rec := null;
    l_det                   vis_money_transfer%rowtype          := null;
    l_currec                pls_integer                         := 1;
    l_invalid               com_api_type_pkg.t_boolean;

    function get_field (
        i_begin       in pls_integer
      , i_length      in pls_integer
    ) return varchar2 is
    begin
        return rtrim(substr(i_tc_buffer(l_currec), i_begin, i_length), ' ');
    end;
begin
    init_fin_record (l_visa);

    -- message specific fields
    l_visa.trans_code  := get_field(1,2);
    l_visa.id          := null;
    l_det.pay_fee      := null;
    -- data from tcr0
    l_det.dst_bin      := get_field(5, 6);
    l_det.src_bin      := get_field(11, 6);
    l_det.trans_type   := get_field(17, 1);
    l_det.network_id   := get_field(18, 4);
    l_det.an_format    := get_field(22, 1);
    l_visa.card_number := get_field(23, 28);
    if l_det.an_format = 'A' then
        l_visa.card_number  := get_card_number(i_card_number => get_field(23, 19), i_network_id => i_network_id);
    end if;
    l_det.origination_date    := to_date(get_field(51, 6),'YYMMDD');
    l_det.pay_amount          := get_field(62, 12);
    l_det.pay_currency        := get_field(74, 3);
    l_det.src_amount          := get_field(77, 12);
    l_det.src_currency        := get_field(89, 3);
    l_det.orig_ref_number     := get_field(92, 12);
    l_det.benef_ref_number    := get_field(104, 6);
    l_det.service_code        := get_field(110, 2);
    l_det.transfer_code       := get_field(112, 4); --, '5069');
    l_det.sendback_reason_code:= get_field(148, 2);  --, '5070');
    l_visa.settlement_flag    := get_field(150, 1);
    l_det.authorization_code  := get_field(152, 6);
    l_visa.central_proc_date  := date_yddd (get_field(163, 4));
    l_det.market_ind          := get_field(167, 1);
    l_visa.reimburst_attr     := get_field(168, 1);

    begin
        l_det.dst_inst_id := iss_api_bin_pkg.get_bin(
                                 i_bin          => l_det.dst_bin
                               , i_mask_error   => com_api_type_pkg.TRUE
                             ).inst_id;
    exception
        when com_api_error_pkg.e_application_error then
            if com_api_error_pkg.get_last_error = 'BIN_IS_NOT_FOUND' then
                l_det.dst_inst_id := null;
            else
                raise;
            end if;
    end;
    if l_det.dst_inst_id is null then
        l_det.dst_inst_id := i_inst_id;
    end if;

    begin
        l_det.src_inst_id := iss_api_bin_pkg.get_bin(
                                 i_bin          => l_det.src_bin
                               , i_mask_error   => com_api_type_pkg.TRUE
                             ).inst_id;
    exception
        when com_api_error_pkg.e_application_error then
            if com_api_error_pkg.get_last_error = 'BIN_IS_NOT_FOUND' then
                l_det.src_inst_id := null;
            else
                raise;
            end if;
    end;
    if l_det.src_inst_id is null then
        l_det.src_inst_id := net_api_network_pkg.get_inst_id(i_network_id);
    end if;

    -- iss_api_card_pkg.get_card_id
    if l_det.an_format = 'A' then
        --get_issuer_agent (
--            p_institution => l_visa.inst_id,
--            p_cardnum => l_visa.card_number,
--            p_agent => l_visa.agent,
--            p_invalid => v_invalid
--        );
        if l_invalid = com_api_const_pkg.TRUE then
            -- issuer agent fetched ok
            --l_visa.iss       :=  bf_300defs.c_true;
            l_det.dst_inst_id  := i_inst_id;
            l_det.src_inst_id  := net_api_network_pkg.get_inst_id(i_network_id);
        end if;
    end if;
    l_visa.status := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;
    l_visa.id     := vis_api_fin_message_pkg.put_message(l_visa);

    --l_det.pay_currency     :=  network_utl.get_curr_code4inst(r_fin.institution, r_det.pay_cur);
    --l_det.source_currency  := network_utl.get_curr_code4inst(r_fin.institution, r_det.c049);

    insert into vis_money_transfer (
        id
        , pay_fee
        , dst_bin
        , src_bin
        , trans_type
        , network_id
        , an_format
        , origination_date
        , pay_amount
        , pay_currency
        , src_amount
        , src_currency
        , orig_ref_number
        , benef_ref_number
        , service_code
        , transfer_code
        , sendback_reason_code
        , authorization_code
        , market_ind
        , dst_inst_id
        , src_inst_id
    )
    values (
        l_visa.id
        , l_det.pay_fee
        , l_det.dst_bin
        , l_det.src_bin
        , l_det.trans_type
        , l_det.network_id
        , l_det.an_format
        , l_det.origination_date
        , l_det.pay_amount
        , l_det.pay_currency
        , l_det.src_amount
        , l_det.src_currency
        , l_det.orig_ref_number
        , l_det.benef_ref_number
        , l_det.service_code
        , l_det.transfer_code
        , l_det.sendback_reason_code
        , l_det.authorization_code
        , l_det.market_ind
        , l_det.dst_inst_id
        , l_det.src_inst_id
    );
    -- collect addendum tcrs
    while l_currec <= i_tc_buffer.count loop
        create_fin_addendum (
            i_fin_msg_id  => l_visa.id
            , i_raw_data  => i_tc_buffer(l_currec)
        );
        l_currec := l_currec + 1;
    end loop;

    if i_validate_record = com_api_const_pkg.TRUE
    then
        vis_api_reject_pkg.validate_visa_record_auth(
            i_oper_id     => l_visa.id
            , i_visa_data => i_tc_buffer(l_currec)
        );
    end if;
end process_money_transfer;

-- messages 10/20 fee collection/funds disbursement
procedure process_fee_funds (
    i_tc_buffer             in vis_api_type_pkg.t_tc_buffer
    , i_network_id          in com_api_type_pkg.t_tiny_id
    , i_standard_id         in com_api_type_pkg.t_tiny_id
    , i_inst_id             in com_api_type_pkg.t_inst_id
    , i_file_id             in com_api_type_pkg.t_long_id
    , i_incom_sess_file_id  in com_api_type_pkg.t_long_id
    , i_batch_id            in com_api_type_pkg.t_medium_id
    , i_record_number       in com_api_type_pkg.t_short_id
    , i_validate_record     in com_api_type_pkg.t_boolean
    , i_create_operation    in com_api_type_pkg.t_boolean
    , i_create_disp_case    in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
) is
    l_visa                  vis_api_type_pkg.t_visa_fin_mes_rec;
    l_fee                   vis_api_type_pkg.t_fee_rec;
    l_recnum                pls_integer := 1;

    function get_field (
        i_start     in    pls_integer
      , i_length    in    pls_integer
    ) return varchar2 is
    begin
        return rtrim(substr(i_tc_buffer(l_recnum), i_start, i_length), ' ');
    end;

begin
    -- fee
    l_fee.file_id            := i_file_id;
    l_fee.pay_fee            := null;
    l_fee.dst_bin            := get_field(5, 6);
    l_fee.src_bin            := get_field(11, 6);
    l_fee.reason_code        := get_field(17, 4);
    if trim(get_field(21, 3)) is not null then
        l_fee.country_code   := com_api_country_pkg.get_country_code(
                                    i_visa_country_code => get_field(21, 3)
                                );
    end if;
    l_fee.event_date         := date_mmdd(get_field(24, 4));
    l_fee.pay_amount         := get_field(47, 12);
    l_fee.pay_currency       := get_field(59, 3);
    l_fee.src_amount         := get_field(62, 12);
    l_fee.src_currency       := get_field(74, 3);
    l_fee.message_text       := get_field(77, 70);
    l_fee.trans_id           := get_field(148, 15);
    l_fee.funding_source     := get_field(163, 1);
    l_fee.reimb_attr         := get_field(168, 1);

    begin
        l_fee.dst_inst_id := iss_api_bin_pkg.get_bin(
                                 i_bin          => l_fee.dst_bin
                               , i_mask_error   => com_api_type_pkg.TRUE
                             ).inst_id;
    exception
        when com_api_error_pkg.e_application_error then
            if com_api_error_pkg.get_last_error = 'BIN_IS_NOT_FOUND' then
                l_fee.dst_inst_id := null;
            else
                raise;
            end if;
    end;

    if l_fee.dst_inst_id is null then
        l_fee.dst_inst_id := i_inst_id;
    end if;

    begin
        l_fee.src_inst_id := iss_api_bin_pkg.get_bin(
                                 i_bin          => l_fee.src_bin
                               , i_mask_error   => com_api_type_pkg.TRUE
                             ).inst_id;
    exception
        when com_api_error_pkg.e_application_error then
            if com_api_error_pkg.get_last_error = 'BIN_IS_NOT_FOUND' then
                l_fee.src_inst_id := null;
            else
                raise;
            end if;
    end;

    if l_fee.src_inst_id is null then
        l_fee.src_inst_id := net_api_network_pkg.get_inst_id(i_network_id => i_network_id);
    end if;

    -- financial message
    init_fin_record(l_visa);

    l_visa.status            := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;
    l_visa.trans_code        := get_field(1, 2);
    l_visa.trans_code_qualifier := get_field(3, 1);
    l_visa.file_id           := i_file_id;
    l_visa.batch_id          := i_batch_id;
    l_visa.record_number     := i_record_number;
    l_visa.is_reversal       :=
        case
            when l_visa.trans_code in (vis_api_const_pkg.TC_FEE_COLLECTION
                                     , vis_api_const_pkg.TC_FUNDS_DISBURSEMENT
                                      )                                       
                 and l_fee.reason_code in (vis_api_const_pkg.FEE_RSN_CODE_AWARD_REVERSAL
                                         , vis_api_const_pkg.FEE_RSN_POINTS_SETTLE_RVRSL
                                         , vis_api_const_pkg.FEE_RSN_SWEEP_AWARD_RVRSL 
                                         , vis_api_const_pkg.FEE_RSN_SWEEP_SUMMARY_RVRSL
                                         , vis_api_const_pkg.FEE_RSN_POINTS_CREDIT_RVRSL
                                         , vis_api_const_pkg.FEE_RSN_CODE_OFFSET_SUM_RVRSL
                                         , vis_api_const_pkg.FEE_RSN_VISA_REWARD_RVRSL
                                         , vis_api_const_pkg.FEE_RSN_CARDHOLDER_FEE_RVRSL
                                         , vis_api_const_pkg.FEE_RSN_CARDHOLDER_CRED_RVRSL
                                         , vis_api_const_pkg.FEE_RSN_PURCHASING_VAT_RVRSL
                                          )   
            then
                com_api_type_pkg.TRUE
            else
                com_api_type_pkg.FALSE
        end;
    l_visa.settlement_flag   := get_field(147, 1);

    begin
        l_visa.inst_id    := iss_api_bin_pkg.get_bin(
                                 i_bin         => substr(i_tc_buffer(l_recnum), 11, 6)
                               , i_mask_error  => com_api_type_pkg.TRUE
                             ).inst_id;
        l_visa.network_id := ost_api_institution_pkg.get_inst_network(l_visa.inst_id);
    exception
        when com_api_error_pkg.e_application_error then
            if com_api_error_pkg.get_last_error = 'BIN_IS_NOT_FOUND' then
                l_visa.inst_id     := null;
                l_visa.network_id  := null;
            else
                raise;
            end if;
    end;

    if l_visa.inst_id is null then
        l_visa.inst_id     := i_inst_id;
        l_visa.network_id  := i_network_id;
    end if;

    l_visa.host_inst_id      := net_api_network_pkg.get_inst_id(l_visa.network_id);

    -- From specification: the field must be filled with zeros for those Funds Disbursement Reason Codes
    --                     so specified in the Fee Collection/Funds Disbursement Reason Codes table
    if trim('0' from substr(i_tc_buffer(l_recnum), 28, 19)) is null then
        trc_log_pkg.debug(
            i_text => 'Card number filled zeros. card_number[' || substr(i_tc_buffer(l_recnum), 28, 19)
                   || '] Reason code [' || l_fee.reason_code || ']'
        );
        l_visa.card_number       := null;
        l_visa.card_hash         := null;
        l_visa.card_mask         := null;
    else
        l_visa.card_number       := get_card_number(substr(i_tc_buffer(l_recnum), 28, 19), i_network_id);
        l_visa.card_hash         := com_api_hash_pkg.get_card_hash(l_visa.card_number);
        l_visa.card_mask         := iss_api_card_pkg.get_card_mask(l_visa.card_number);
    end if;

    l_visa.oper_currency     := substr(i_tc_buffer(l_recnum), 74, 3); -- Source Currency
    -- if currency exponent equal to zero then cut-off last two digits from amount in accordance with VISA rules
    l_visa.oper_amount       := substr(i_tc_buffer(l_recnum), 62 -- Source Amount
      , 12 - case com_api_currency_pkg.get_currency_exponent(l_visa.oper_currency) when 0 then 2 else 0 end);

    l_visa.sttl_currency     := substr(i_tc_buffer(l_recnum), 59, 3); -- Dest Currency
    -- if currency exponent equal to zero then cut-off last two digits from amount in accordance with VISA rules
    l_visa.sttl_amount       := substr(i_tc_buffer(l_recnum), 47    -- Dest Amount
      , 12 - case com_api_currency_pkg.get_currency_exponent(l_visa.oper_currency) when 0 then 2 else 0 end);

    l_visa.oper_date         := to_date(substr(i_tc_buffer(l_recnum), 24, 4), 'MMDD');
    l_visa.central_proc_date := get_field(164, 4);
    l_visa.usage_code        := '1';

    vis_cst_incoming_pkg.process_fin_message(io_fin_rec => l_visa);

    l_visa.id                := vis_api_fin_message_pkg.put_message(l_visa);

    l_fee.id                 := l_visa.id;

    vis_api_fin_message_pkg.put_fee (
        i_fee_rec  => l_fee
    );

    -- collect addendum tcrs
    l_recnum := l_recnum + 1;
    while l_recnum <= i_tc_buffer.count loop
        create_fin_addendum(
            i_fin_msg_id  => l_visa.id
          , i_raw_data    => i_tc_buffer(l_recnum)
        );
        l_recnum := l_recnum + 1;
    end loop;

    /*-- link raw records to this record
    for l_currec in 1 .. i_tc_buffer.count
    loop
        if not i_tc_buffer (l_currec).utrnno is null then
            update visa_tcrraw_tab
               set rtn = r_fin.bo_utrnno
             where bo_utrnno = pt_trx (v_currec#).utrnno;
        end if;
    end loop; */

    if i_validate_record = com_api_const_pkg.TRUE
    then
        vis_api_reject_pkg.validate_visa_record_auth(
            i_oper_id    => l_visa.id
          , i_visa_data  => i_tc_buffer(l_recnum)
        );
    end if;

    if nvl(i_create_operation, com_api_type_pkg.FALSE) = com_api_type_pkg.TRUE then
        if l_fee.reason_code is not null
        then
            vis_api_fin_message_pkg.create_operation(
                i_fin_rec            => l_visa
              , i_standard_id        => i_standard_id
              , i_fee_rec            => l_fee
              , i_create_disp_case   => i_create_disp_case
              , i_incom_sess_file_id => i_incom_sess_file_id
            );
        else
            vis_api_fin_message_pkg.create_operation(
                i_fin_rec            => l_visa
              , i_standard_id        => i_standard_id
              , i_fee_rec            => l_fee
              , i_status             => opr_api_const_pkg.OPERATION_STATUS_DONT_PROCESS
              , i_create_disp_case   => i_create_disp_case
              , i_incom_sess_file_id => i_incom_sess_file_id
            );
        end if;
    end if;
end process_fee_funds;

procedure process_retrieval_request (
    i_tc_buffer             in vis_api_type_pkg.t_tc_buffer
    , i_network_id          in com_api_type_pkg.t_tiny_id
    , i_host_id             in com_api_type_pkg.t_tiny_id
    , i_standard_id         in com_api_type_pkg.t_tiny_id
    , i_inst_id             in com_api_type_pkg.t_inst_id
    , i_file_id             in com_api_type_pkg.t_long_id
    , i_incom_sess_file_id  in com_api_type_pkg.t_long_id
    , i_batch_id            in com_api_type_pkg.t_medium_id
    , i_record_number       in com_api_type_pkg.t_short_id
    , i_create_operation    in com_api_type_pkg.t_boolean
    , i_validate_record     in com_api_type_pkg.t_boolean
    , i_need_repeat         in com_api_type_pkg.t_boolean
    , i_create_disp_case    in com_api_type_pkg.t_boolean  default com_api_const_pkg.FALSE
) is
    l_visa                  vis_api_type_pkg.t_visa_fin_mes_rec;
    l_retrieval             vis_api_type_pkg.t_retrieval_rec;
    l_currec                pls_integer := 1;

    l_iss_network_id        com_api_type_pkg.t_tiny_id;
    l_acq_network_id        com_api_type_pkg.t_tiny_id;
    l_sttl_type             com_api_type_pkg.t_dict_value;
    l_match_status          com_api_type_pkg.t_dict_value;

    l_card_inst_id          com_api_type_pkg.t_inst_id;
    l_card_network_id       com_api_type_pkg.t_tiny_id;
    l_card_type_id          com_api_type_pkg.t_tiny_id;
    l_country_code          com_api_type_pkg.t_country_code;
    l_bin_currency          com_api_type_pkg.t_curr_code;
    l_sttl_currency         com_api_type_pkg.t_curr_code;

    function get_field (
        i_start       in pls_integer
      , i_length      in pls_integer
    ) return varchar2 is
    begin
        return rtrim(substr(i_tc_buffer(l_currec), i_start, i_length), ' ');
    end;
begin
    init_fin_record (l_visa);

    -- data from tcr0
    l_retrieval.file_id         := i_file_id;
    l_visa.trans_code           := get_field(1, 2);
    l_visa.usage_code           := '1';
    l_visa.card_number          := get_card_number(get_field(5, 19), i_network_id);
    l_visa.arn                  := get_field(24, 23);
    l_visa.acq_business_id      := get_field(47, 8);
    l_visa.dispute_amount       := get_field(59, 12);
    l_visa.dispute_currency     := get_field(71, 3);
    l_visa.merchant_name        := get_field(74, 25);
    l_visa.merchant_city        := get_field(99, 13);
    l_visa.merchant_country     := com_api_country_pkg.get_country_code(
                                       i_visa_country_code => trim(get_field(112, 3))
                                     , i_raise_error       => com_api_const_pkg.FALSE
                                   );
    l_visa.mcc                  := get_field(115, 4);
    l_visa.merchant_postal_code := get_field(119, 5);
    l_visa.merchant_region      := get_field(124, 3);

    l_visa.central_proc_date    := get_field(164, 4);

    begin
        l_visa.inst_id      := iss_api_bin_pkg.get_bin(
                                   i_bin        => get_field(28, 6)
                                 , i_mask_error => com_api_type_pkg.TRUE
                               ).inst_id;
        l_visa.network_id   := ost_api_institution_pkg.get_inst_network(l_visa.inst_id);
    exception
        when com_api_error_pkg.e_application_error then
            if com_api_error_pkg.get_last_error = 'BIN_IS_NOT_FOUND' then
                l_visa.inst_id     := null;
                l_visa.network_id  := null;
            else
                raise;
            end if;
    end;

    if l_visa.inst_id is null then
        l_visa.inst_id     := i_inst_id;
        l_visa.network_id  := i_network_id;
    end if;

    l_visa.settlement_flag      := get_field(138, 1);
    l_visa.status               := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;

    l_retrieval.purchase_date        := date_mmdd (get_field(55, 4));
    l_retrieval.source_amount        := get_field(59, 12);
    l_retrieval.source_currency      := get_field(71, 3);
    l_retrieval.reason_code          := get_field(136, 2);
    l_retrieval.national_reimb_fee   := get_field(139, 12);
    l_retrieval.atm_account_sel      := get_field(151, 1);
    l_retrieval.req_id               := get_field(152, 12);
    l_retrieval.reimb_flag           := get_field(168, 1);

    l_currec := l_currec + 1;

    -- data from tcr1 present?
    if l_currec <= i_tc_buffer.count and substr(i_tc_buffer(l_currec), 4, 1) = '1' then
        -- tcr1 data
        l_retrieval.fax_number               := get_field(17, 16);
        l_retrieval.req_fulfill_method       := get_field(39, 1);
        l_retrieval.used_fulfill_method      := get_field(40, 1);
        l_retrieval.iss_rfc_bin              := get_field(41, 6);
        l_retrieval.iss_rfc_subaddr          := get_field(47, 7);
        l_retrieval.iss_billing_currency     := get_field(54, 3);
        l_retrieval.iss_billing_amount       := get_field(57, 12);
        l_retrieval.transaction_id           := get_field(69, 15);
        l_retrieval.excluded_trans_id_reason := get_field(84, 1);
        l_retrieval.crs_code                 := get_field(85, 1);
        l_retrieval.multiple_clearing_seqn   := get_field(86, 2);
        l_visa.pan_token                     := get_field(88, 16);
        l_currec                             := l_currec + 1;
    end if;

    -- data from tcr4 present?
    if l_currec <= i_tc_buffer.count and substr(i_tc_buffer(l_currec), 4, 1) = '4' then
      -- tcr4 data
        l_retrieval.product_code := get_field(17, 4);
        l_retrieval.contact_info := get_field(21, 25);
    end if;

    -- assign dispute id. if dispute found, then iss_inst and acq_inst taked from dispute.
    assign_dispute(
        io_visa           => l_visa
      , i_standard_id     => i_standard_id
      , o_iss_inst_id     => l_retrieval.iss_inst_id
      , o_iss_network_id  => l_iss_network_id
      , o_acq_inst_id     => l_retrieval.acq_inst_id
      , o_acq_network_id  => l_acq_network_id
      , o_sttl_type       => l_sttl_type
      , o_match_status    => l_match_status
      , i_need_repeat     => i_need_repeat
    );

    -- if dispute not found, then iss_inst taked from network, acq = file receiver.
    if l_visa.dispute_id is null then
        iss_api_bin_pkg.get_bin_info(
            i_card_number      => l_visa.card_number
          , o_iss_inst_id      => l_retrieval.iss_inst_id
          , o_iss_network_id   => l_iss_network_id
          , o_card_inst_id     => l_card_inst_id
          , o_card_network_id  => l_card_network_id
          , o_card_type        => l_card_type_id
          , o_card_country     => l_country_code
          , o_bin_currency     => l_bin_currency
          , o_sttl_currency    => l_sttl_currency
        );
        if l_retrieval.iss_inst_id is null then
            l_retrieval.iss_inst_id := net_api_network_pkg.get_inst_id(i_network_id);
        end if;

        begin
            l_retrieval.acq_inst_id := cmn_api_standard_pkg.find_value_owner(
                                           i_standard_id       => i_standard_id
                                         , i_entity_type       => net_api_const_pkg.ENTITY_TYPE_HOST
                                         , i_object_id         => i_host_id
                                         , i_param_name        => vis_api_const_pkg.ACQ_BUSINESS_ID
                                         , i_value_char        => get_field(28, 6)
                                         , i_mask_error        => com_api_const_pkg.TRUE
                                       );
        exception
            when com_api_error_pkg.e_application_error then
                if com_api_error_pkg.get_last_error = 'NOT_FOUND_VALUE_OWNER' then
                    l_retrieval.acq_inst_id := null;
                else
                    raise;
                end if;
        end;

        if l_retrieval.acq_inst_id is null then
            l_retrieval.acq_inst_id := i_inst_id;
        end if;
    end if;

    l_visa.file_id       := i_file_id;
    l_visa.batch_id      := i_batch_id;
    l_visa.record_number := i_record_number;

    vis_cst_incoming_pkg.process_fin_message(io_fin_rec => l_visa);

    l_visa.id := vis_api_fin_message_pkg.put_message(
        i_fin_rec  => l_visa
    );

    l_retrieval.id := l_visa.id;

    vis_api_fin_message_pkg.put_retrieval(
        i_retrieval_rec  => l_retrieval
    );

    if i_validate_record = com_api_const_pkg.TRUE
    then
        vis_api_reject_pkg.validate_visa_record_auth(
            i_oper_id    => l_visa.id
          , i_visa_data  => i_tc_buffer(l_currec)
        );
    end if;

    if nvl(i_create_operation, com_api_type_pkg.TRUE) = com_api_type_pkg.TRUE then
        vis_api_fin_message_pkg.create_operation(
            i_fin_rec            => l_visa
          , i_standard_id        => i_standard_id
          , i_create_disp_case   => i_create_disp_case
          , i_incom_sess_file_id => i_incom_sess_file_id
        );
        process_csm(
            i_oper              => null
          , i_visa              => l_visa
          , i_card_inst_id      => l_card_inst_id
          , i_standard_id       => i_standard_id
          , i_perform_check     => com_api_const_pkg.FALSE
          , i_create_disp_case  => i_create_disp_case
        );
    end if;

end process_retrieval_request;

procedure process_currency_rate(
    i_tc_buffer            in vis_api_type_pkg.t_tc_buffer
  , i_file_id              in com_api_type_pkg.t_long_id
  , i_proc_date            in date
  , i_inst_id              in com_api_type_pkg.t_inst_id
) is
    l_pos                     pls_integer;
    l_effective_date          date;
    l_recnum                  pls_integer := 1;
    l_tcr                     varchar2(1);
    l_groups                  pls_integer;
    l_action_code             varchar2(1);
    l_count                   number;
    l_mmdd                    date;
    l_dst_bin                 com_api_type_pkg.t_bin;
    l_src_bin                 com_api_type_pkg.t_bin;
    l_currency_entry          com_api_type_pkg.t_name;
    l_counter_currency_code   com_api_type_pkg.t_curr_code;
    l_base_currency_code      com_api_type_pkg.t_curr_code;
    l_buy_scale               com_api_type_pkg.t_tiny_id;
    l_buy_conversion_rate     com_api_type_pkg.t_short_id;
    l_sell_scale              com_api_type_pkg.t_tiny_id;
    l_sell_conversion_rate    com_api_type_pkg.t_short_id;
    l_id                      com_api_type_pkg.t_long_id;
    l_seqnum                  com_api_type_pkg.t_tiny_id;
    l_buy_rate                com_api_type_pkg.t_rate;
    l_sell_rate               com_api_type_pkg.t_rate;

    function get_field(
        i_start       in pls_integer
      , i_length      in pls_integer
    ) return varchar2
    is
    begin
        return rtrim(substr(i_tc_buffer(l_recnum), i_start, i_length), ' ');
    end;

begin
    trc_log_pkg.debug('currency_rate is not realized: ' || i_tc_buffer(1));

    while l_recnum <= i_tc_buffer.count loop
        l_tcr := substr(i_tc_buffer(l_recnum), 4, 1);
        if l_tcr = 0 then
            l_dst_bin := get_field(5, 6);
            l_src_bin := get_field(11, 6);
            l_pos := 17;
            l_groups := 5;
        elsif l_tcr = 1 then
            l_pos := 5;
            l_groups := 6;
        end if;

        while l_groups > 0 loop
            -- get currency entry
            l_currency_entry := get_field(l_pos, 27);
            exit when l_currency_entry is null;

            l_action_code           := substr(l_currency_entry, 1, 1);
            l_counter_currency_code := substr(l_currency_entry, 2, 3);
            l_base_currency_code    := substr(l_currency_entry, 5, 3);
            l_mmdd                  := to_date(substr(l_currency_entry, 8, 4), 'MMDD');
            l_buy_scale             := to_number(substr(l_currency_entry, 12, 2));
            l_buy_conversion_rate   := to_number(substr(l_currency_entry, 14, 6));
            l_sell_scale            := to_number(substr(l_currency_entry, 20, 2));
            l_sell_conversion_rate  := to_number(substr(l_currency_entry, 22, 6));

            l_effective_date        := trunc(i_proc_date, 'YEAR') + to_number(to_char(l_mmdd, 'DDD')) - 1;
            l_buy_rate              := l_buy_conversion_rate * power(10, -1 * l_buy_scale);
            l_sell_rate             := l_sell_conversion_rate * power(10, -1 * l_sell_scale);

            if l_counter_currency_code != l_base_currency_code then
                insert into vis_currency_rate (
                    id
                  , file_id
                  , dst_bin
                  , src_bin
                  , action_code
                  , effective_date
                  , counter_currency_code
                  , base_currency_code
                  , buy_rate
                  , sell_rate
                )
                values (
                    vis_currency_rate_seq.nextval
                  , i_file_id
                  , l_dst_bin
                  , l_src_bin
                  , l_action_code
                  , l_effective_date
                  , l_counter_currency_code
                  , l_base_currency_code
                  , l_buy_rate
                  , l_sell_rate
                );

                -- add sell rate to com_rate (sell by fin institute)
                com_api_rate_pkg.set_rate(
                    o_id            => l_id
                  , o_seqnum        => l_seqnum
                  , o_count         => l_count
                  , i_src_currency  => l_counter_currency_code
                  , i_dst_currency  => l_base_currency_code
                  , i_rate_type     => vis_api_const_pkg.VISA_STTL_SELL_RATE_TYPE
                  , i_inst_id       => i_inst_id
                  , i_eff_date      => l_effective_date
                  , i_rate          => l_sell_rate
                  , i_inverted      => com_api_type_pkg.FALSE
                  , i_src_scale     => 1
                  , i_dst_scale     => 1
                  , i_exp_date      => null
                );

                -- add buy rate to com_rate (buy by fin institute)
                com_api_rate_pkg.set_rate(
                    o_id            => l_id
                  , o_seqnum        => l_seqnum
                  , o_count         => l_count
                  , i_src_currency  => l_counter_currency_code
                  , i_dst_currency  => l_base_currency_code
                  , i_rate_type     => vis_api_const_pkg.VISA_STTL_BUY_RATE_TYPE
                  , i_inst_id       => i_inst_id
                  , i_eff_date      => l_effective_date
                  , i_rate          => l_buy_rate
                  , i_inverted      => com_api_type_pkg.FALSE
                  , i_src_scale     => 1
                  , i_dst_scale     => 1
                  , i_exp_date      => null
                );
            end if;

            l_pos    := l_pos + 27;
            l_groups := l_groups - 1;
        end loop;
        l_recnum := l_recnum + 1;
    end loop;
end;

procedure process_delivery_report (
    i_tc_buffer             in vis_api_type_pkg.t_tc_buffer
    , i_file_id             in com_api_type_pkg.t_long_id
    , i_inst_id             in com_api_type_pkg.t_inst_id
    , i_record_number       in com_api_type_pkg.t_short_id
    , i_validate_record     in com_api_type_pkg.t_boolean
) is
    l_rep                   vis_general_report%rowtype;

    function get_field (
        i_start       in pls_integer
        , i_length    in pls_integer
    ) return varchar2 is
    begin
        return rtrim(substr(i_tc_buffer(1), i_start, i_length), ' ');
    end;

begin
    l_rep.file_id          := i_file_id;
    l_rep.dst_bin          := get_field(5, 6);
    l_rep.src_bin          := get_field(11, 6);
    l_rep.report_text      := get_field(17, 132);
    l_rep.report_id        := get_field(150, 10);
    l_rep.rep_day_seq_num  := to_number(get_field(160, 1));
    l_rep.rep_line_seq_num := to_number(get_field(161, 7));
    l_rep.reimb_attr       := get_field(168, 1);
    l_rep.inst_id          := i_inst_id;

    insert into vis_general_report (
        id
      , file_id
      , dst_bin
      , src_bin
      , report_text
      , report_id
      , rep_day_seq_num
      , rep_line_seq_num
      , reimb_attr
      , inst_id
    )
    values (
        vis_general_report_seq.nextval
      , l_rep.file_id
      , l_rep.dst_bin
      , l_rep.src_bin
      , l_rep.report_text
      , l_rep.report_id
      , l_rep.rep_day_seq_num
      , l_rep.rep_line_seq_num
      , l_rep.reimb_attr
      , l_rep.inst_id
    );

    if i_validate_record = com_api_const_pkg.TRUE
    then
        vis_api_reject_pkg.validate_visa_record_auth(
            i_oper_id     => null
            , i_visa_data => i_tc_buffer(1)
        );
    end if;
end process_delivery_report;

procedure process_report_v1 (
    i_tc_buffer             in     vis_api_type_pkg.t_tc_buffer
    , i_file_id             in     com_api_type_pkg.t_long_id
    , i_inst_id             in     com_api_type_pkg.t_inst_id
    , i_record_number       in     com_api_type_pkg.t_short_id
    , o_sttl_data              out vis_api_type_pkg.t_settlement_data_rec
) is
    l_rep                   vis_vss1%rowtype := null;

    function get_field (
        i_start        in pls_integer
        , i_length     in pls_integer
    ) return varchar2 is
    begin
        return rtrim (substr (i_tc_buffer (1), i_start, i_length), ' ');
    end;

begin
    l_rep.file_id         := i_file_id;
    l_rep.record_number   := i_record_number;
    l_rep.status          := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;
    o_sttl_data.dst_bin         := get_field(5, 6);
    o_sttl_data.src_bin         := get_field(11, 6);
    o_sttl_data.sre_id          := get_field(17, 10);
    o_sttl_data.sttl_service    := get_field(27, 3);
    o_sttl_data.report_date     := date_yyyyddd(get_field (30, 7));
    l_rep.sre_level       := get_field(37, 1);
    o_sttl_data.report_group    := get_field(59, 1);
    o_sttl_data.report_subgroup := get_field(60, 1);
    o_sttl_data.rep_id_num      := get_field(61, 3);
    o_sttl_data.rep_id_sfx      := get_field(64, 2);
    l_rep.sub_sre_id      := get_field(66, 10);
    l_rep.sub_sre_name    := get_field(76, 15);
    l_rep.funds_ind       := get_field(91, 1);
    l_rep.entity_type     := get_field(92, 1);
    l_rep.entity_id1      := get_field(93, 18);
    l_rep.entity_id2      := get_field(111, 18);
    l_rep.proc_sind       := get_field(129, 1);
    l_rep.proc_id         := get_field(130, 10);
    l_rep.network_sind    := get_field(140, 1);
    l_rep.network_id      := get_field(141, 4);
    l_rep.reimb_attr      := get_field(168, 1);
    l_rep.inst_id         := i_inst_id;

    insert into vis_vss1 (
        id
      , file_id
      , record_number
      , status
      , dst_bin
      , src_bin
      , sre_id
      , sttl_service
      , report_date
      , sre_level
      , report_group
      , report_subgroup
      , rep_id_num
      , rep_id_sfx
      , sub_sre_id
      , sub_sre_name
      , funds_ind
      , entity_type
      , entity_id1
      , entity_id2
      , proc_sind
      , proc_id
      , network_sind
      , network_id
      , reimb_attr
      , inst_id
    )
    values (
        vis_vss1_seq.nextval
      , l_rep.file_id
      , l_rep.record_number
      , l_rep.status
      , o_sttl_data.dst_bin
      , o_sttl_data.src_bin
      , o_sttl_data.sre_id
      , o_sttl_data.sttl_service
      , o_sttl_data.report_date
      , l_rep.sre_level
      , o_sttl_data.report_group
      , o_sttl_data.report_subgroup
      , o_sttl_data.rep_id_num
      , o_sttl_data.rep_id_sfx
      , l_rep.sub_sre_id
      , l_rep.sub_sre_name
      , l_rep.funds_ind
      , l_rep.entity_type
      , l_rep.entity_id1
      , l_rep.entity_id2
      , l_rep.proc_sind
      , l_rep.proc_id
      , l_rep.network_sind
      , l_rep.network_id
      , l_rep.reimb_attr
      , l_rep.inst_id
    );
end process_report_v1;

procedure process_report_v2 (
    i_tc_buffer      in     vis_api_type_pkg.t_tc_buffer
  , i_file_id        in     com_api_type_pkg.t_long_id
  , i_inst_id        in     com_api_type_pkg.t_inst_id
  , i_record_number  in     com_api_type_pkg.t_short_id
  , o_sttl_data         out vis_api_type_pkg.t_settlement_data_rec
  , i_register_event in     com_api_type_pkg.t_boolean
) is
    l_rep            vis_vss2%rowtype := null;
    l_param_tab      com_api_type_pkg.t_param_tab;

    function get_field (
        i_start  in     pls_integer
      , i_length in     pls_integer
    ) return varchar2 is
    begin
        return rtrim(substr(i_tc_buffer(1), i_start, i_length), ' ');
    end;

begin
    l_rep.file_id         := i_file_id;
    l_rep.record_number   := i_record_number;
    l_rep.status          := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;
    o_sttl_data.dst_bin         := get_field(5, 6);
    o_sttl_data.src_bin         := get_field(11, 6);
    o_sttl_data.sre_id          := get_field(17, 10);
    o_sttl_data.up_sre_id       := get_field(27, 10);
    o_sttl_data.funds_id        := get_field(37, 10);
    o_sttl_data.sttl_service    := get_field(47, 3);
    o_sttl_data.sttl_currency   := get_field(50, 3);
    o_sttl_data.no_data         := get_field(53, 1);
    o_sttl_data.report_group    := get_field(59, 1);
    o_sttl_data.report_subgroup := get_field(60, 1);
    o_sttl_data.rep_id_num      := get_field(61, 3);
    o_sttl_data.rep_id_sfx      := get_field(64, 2);
    o_sttl_data.report_date     := date_yyyyddd (get_field(73, 7));

    if o_sttl_data.no_data = 'Y' and o_sttl_data.rep_id_num = '111' then
        o_sttl_data.sttl_date := null;
        o_sttl_data.date_from := null;
        o_sttl_data.date_to   := null;
    else
        o_sttl_data.sttl_date := date_yyyyddd (get_field(66, 7));
        o_sttl_data.date_from := date_yyyyddd (get_field(80, 7));
        o_sttl_data.date_to   := date_yyyyddd (get_field(87, 7));
    end if;

    o_sttl_data.bus_mode  := get_field(95, 1);
    l_rep.amount_type     := get_field(94, 1);
    l_rep.trans_count     := get_field(96, 15);
    l_rep.credit_amount   := get_field(111, 15);
    l_rep.debit_amount    := get_field(126, 15);
    l_rep.net_amount      := correct_sign (get_field(141, 15), get_field(156, 2));
    l_rep.reimb_attr      := get_field(168, 1);
    l_rep.inst_id         := i_inst_id;

    l_rep.id := vis_vss2_seq.nextval;
    insert into vis_vss2(
        id
      , file_id
      , record_number
      , status
      , dst_bin
      , src_bin
      , sre_id
      , up_sre_id
      , funds_id
      , sttl_service
      , sttl_currency
      , no_data
      , report_group
      , report_subgroup
      , rep_id_num
      , rep_id_sfx
      , sttl_date
      , report_date
      , date_from
      , date_to
      , amount_type
      , bus_mode
      , trans_count
      , credit_amount
      , debit_amount
      , net_amount
      , reimb_attr
      , inst_id)
    values(
        l_rep.id
      , l_rep.file_id
      , l_rep.record_number
      , l_rep.status
      , o_sttl_data.dst_bin
      , o_sttl_data.src_bin
      , o_sttl_data.sre_id
      , o_sttl_data.up_sre_id
      , o_sttl_data.funds_id
      , o_sttl_data.sttl_service
      , o_sttl_data.sttl_currency
      , o_sttl_data.no_data
      , o_sttl_data.report_group
      , o_sttl_data.report_subgroup
      , o_sttl_data.rep_id_num
      , o_sttl_data.rep_id_sfx
      , o_sttl_data.sttl_date
      , o_sttl_data.report_date
      , o_sttl_data.date_from
      , o_sttl_data.date_to
      , l_rep.amount_type
      , o_sttl_data.bus_mode
      , l_rep.trans_count
      , l_rep.credit_amount
      , l_rep.debit_amount
      , l_rep.net_amount
      , l_rep.reimb_attr
      , l_rep.inst_id
    );
    
    if nvl(i_register_event, com_api_const_pkg.FALSE) = com_api_type_pkg.TRUE then
        evt_api_event_pkg.register_event(
            i_event_type  => vis_api_const_pkg.EVENT_TYPE_VSS_MESSAGE --'EVNT1912'
          , i_eff_date    => com_api_sttl_day_pkg.get_sysdate
          , i_entity_type => vis_api_const_pkg.ENTITY_TYPE_VSS_MESSAGE --'ENTTVSSM'
          , i_object_id   => l_rep.id
          , i_inst_id     => i_inst_id
          , i_split_hash  => null
          , i_param_tab   => l_param_tab
          , i_status      => evt_api_const_pkg.EVENT_STATUS_READY
        );
    end if;
end process_report_v2;

procedure process_report_v4 (
    i_tc_buffer      in     vis_api_type_pkg.t_tc_buffer
  , i_file_id        in     com_api_type_pkg.t_long_id
  , i_inst_id        in     com_api_type_pkg.t_inst_id
  , i_record_number  in     com_api_type_pkg.t_short_id
  , o_sttl_data         out vis_api_type_pkg.t_settlement_data_rec
) is
    l_rep            vis_vss4%rowtype := null;
    l_data           varchar2(200);

    function get_field (
        i_start       in pls_integer
        , i_length    in pls_integer
    ) return varchar2 is
    begin
        return rtrim(substr(l_data, i_start, i_length), ' ');
    end;

begin
    l_data                := i_tc_buffer(1);
    l_rep.file_id         := i_file_id;
    l_rep.record_number   := i_record_number;
    l_rep.status          := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;
    o_sttl_data.dst_bin         := get_field(5, 6);
    o_sttl_data.src_bin         := get_field(11, 6);
    o_sttl_data.sre_id          := get_field(17, 10);
    o_sttl_data.up_sre_id       := get_field(27, 10);
    o_sttl_data.funds_id        := get_field(37, 10);
    o_sttl_data.sttl_service    := get_field(47, 3); --, '5STL');
    o_sttl_data.sttl_currency   := get_field(50, 3);
    o_sttl_data.clear_currency  := get_field(53, 3);
    o_sttl_data.bus_mode        := get_field(56, 1); --, '5VBM');
    o_sttl_data.no_data         := get_field(57, 1);
    o_sttl_data.report_group    := get_field(59, 1);
    o_sttl_data.report_subgroup := get_field(60, 1);
    o_sttl_data.rep_id_num      := get_field(61, 3);
    o_sttl_data.rep_id_sfx      := get_field(64, 2);
    o_sttl_data.sttl_date       := case trim(o_sttl_data.rep_id_sfx)
                                       when 'M' then null
                                       else date_yyyyddd(get_field (66, 7))
                                   end;
    o_sttl_data.report_date     := date_yyyyddd(get_field(73, 7));
    o_sttl_data.date_from       := date_yyyyddd(get_field(80, 7));
    o_sttl_data.date_to         := date_yyyyddd(get_field(87, 7));
    o_sttl_data.charge_type     := get_field(94, 3); --, '5CHA');
    o_sttl_data.bus_tr_type     := get_field(97, 3); --, '5BTT');
    o_sttl_data.bus_tr_cycle    := get_field(100, 1); --, '5BTC');
    o_sttl_data.revers_ind      := get_field(101, 1);
    o_sttl_data.return_ind      := get_field(102, 1);
    o_sttl_data.jurisdict       := get_field(103, 2); --, '5JUR');
    o_sttl_data.routing         := get_field(105, 1);
    o_sttl_data.src_country     := get_field(106, 3);
    o_sttl_data.dst_country     := get_field(109, 3);
    o_sttl_data.src_region      := get_field(112, 2);
    o_sttl_data.dst_region      := get_field(114, 2);
    o_sttl_data.fee_level       := get_field(116, 16);
    o_sttl_data.cr_db_net       := get_field(132, 1);
    o_sttl_data.summary_level   := get_field(133, 2); --, '5SML');
    o_sttl_data.first_count     := 0;
    o_sttl_data.second_count    := 0;
    o_sttl_data.first_amount    := 0;
    o_sttl_data.second_amount   := 0;
    o_sttl_data.third_amount    := 0;
    o_sttl_data.fourth_amount   := 0;
    o_sttl_data.fifth_amount    := 0;
    l_rep.reimb_attr      := get_field(168, 1); -- obsolete, so it isn't passed to o_sttl_data
    l_rep.inst_id         := i_inst_id;

    if nvl(o_sttl_data.no_data, ' ') != 'Y' then
        -- there is tcr 1 record for this report
        if i_tc_buffer.count < 2 then
            com_api_error_pkg.raise_error(
                i_error      => 'VIS_TCR1_RECORD_IS_NOT_PRESENT'
              , i_env_param1 => i_file_id
              , i_env_param2 => i_record_number
            );
        end if;
        l_data                          := i_tc_buffer (2);
        o_sttl_data.currency_table_date := strange_date_yyyyddd(get_field (5, 7));
        o_sttl_data.first_count         := get_field(12, 15);
        o_sttl_data.second_count        := get_field(27, 15);
        o_sttl_data.first_amount        := correct_sign(get_field(42,  15), get_field(57,  2));
        o_sttl_data.second_amount       := correct_sign(get_field(59,  15), get_field(74,  2));
        o_sttl_data.third_amount        := correct_sign(get_field(76,  15), get_field(91,  2));
        o_sttl_data.fourth_amount       := correct_sign(get_field(93,  15), get_field(108, 2));
        o_sttl_data.fifth_amount        := correct_sign(get_field(110, 15), get_field(125, 2));
    end if;

    insert into vis_vss4(
        id
      , file_id
      , record_number
      , status
      , dst_bin
      , src_bin
      , sre_id
      , up_sre_id
      , funds_id
      , sttl_service
      , sttl_currency
      , clear_currency
      , bus_mode
      , no_data
      , report_group
      , report_subgroup
      , rep_id_num
      , rep_id_sfx
      , sttl_date
      , report_date
      , date_from
      , date_to
      , charge_type
      , bus_tr_type
      , bus_tr_cycle
      , revers_ind
      , return_ind
      , jurisdict
      , routing
      , src_country
      , dst_country
      , src_region
      , dst_region
      , fee_level
      , cr_db_net
      , summary_level
      , reimb_attr
      , currency_table_date
      , first_count
      , second_count
      , first_amount
      , second_amount
      , third_amount
      , fourth_amount
      , fifth_amount
      , inst_id)
    values(
        vis_vss4_seq.nextval
      , l_rep.file_id
      , l_rep.record_number
      , l_rep.status
      , o_sttl_data.dst_bin
      , o_sttl_data.src_bin
      , o_sttl_data.sre_id
      , o_sttl_data.up_sre_id
      , o_sttl_data.funds_id
      , o_sttl_data.sttl_service
      , o_sttl_data.sttl_currency
      , o_sttl_data.clear_currency
      , o_sttl_data.bus_mode
      , o_sttl_data.no_data
      , o_sttl_data.report_group
      , o_sttl_data.report_subgroup
      , o_sttl_data.rep_id_num
      , o_sttl_data.rep_id_sfx
      , o_sttl_data.sttl_date
      , o_sttl_data.report_date
      , o_sttl_data.date_from
      , o_sttl_data.date_to
      , o_sttl_data.charge_type
      , o_sttl_data.bus_tr_type
      , o_sttl_data.bus_tr_cycle
      , o_sttl_data.revers_ind
      , o_sttl_data.return_ind
      , o_sttl_data.jurisdict
      , o_sttl_data.routing
      , o_sttl_data.src_country
      , o_sttl_data.dst_country
      , o_sttl_data.src_region
      , o_sttl_data.dst_region
      , o_sttl_data.fee_level
      , o_sttl_data.cr_db_net
      , o_sttl_data.summary_level
      , l_rep.reimb_attr
      , o_sttl_data.currency_table_date
      , o_sttl_data.first_count
      , o_sttl_data.second_count
      , o_sttl_data.first_amount
      , o_sttl_data.second_amount
      , o_sttl_data.third_amount
      , o_sttl_data.fourth_amount
      , o_sttl_data.fifth_amount
      , l_rep.inst_id
    );
end process_report_v4;

procedure process_report_v6 (
    i_tc_buffer      in     vis_api_type_pkg.t_tc_buffer
  , i_file_id        in     com_api_type_pkg.t_long_id
  , i_inst_id        in     com_api_type_pkg.t_inst_id
  , i_record_number  in     com_api_type_pkg.t_short_id
  , o_sttl_data         out vis_api_type_pkg.t_settlement_data_rec
) is
    l_rep  vis_vss6%rowtype := null;

    function get_field (
        i_start       in pls_integer
        , i_length    in pls_integer
    ) return varchar2 is
    begin
        return rtrim(substr(i_tc_buffer(1), i_start, i_length ), ' ');
    end;

begin
    l_rep.file_id        := i_file_id;
    l_rep.record_number  := i_record_number;
    l_rep.status         := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;
    o_sttl_data.dst_bin        := get_field(5, 6);
    o_sttl_data.src_bin        := get_field(11, 6);
    o_sttl_data.sre_id         := get_field(17, 10);
    l_rep.proc_id        := get_field(27, 10);
    l_rep.clear_bin      := get_field(37, 10);
    o_sttl_data.clear_currency := get_field(47, 3);
    o_sttl_data.sttl_service   := get_field(50, 3); --, '5STL');
    o_sttl_data.bus_mode       := get_field(53, 1); --, '5VBM');
    o_sttl_data.no_data        := get_field(54, 1);
    o_sttl_data.report_group   := get_field(59, 1);
    o_sttl_data.report_subgroup:= get_field(60, 1);
    o_sttl_data.rep_id_num     := get_field(61, 3);
    o_sttl_data.rep_id_sfx     := get_field(64, 2);
    o_sttl_data.sttl_date      := date_yyyyddd(get_field(66, 7));
    o_sttl_data.report_date    := date_yyyyddd(get_field(73, 7));
    l_rep.fin_ind        := get_field(80, 1);
    l_rep.clear_only     := get_field(81, 1);
    o_sttl_data.bus_tr_type    := get_field(82, 3); --, '5BTT');
    o_sttl_data.bus_tr_cycle   := get_field(85, 1); --, '5BTC');
    o_sttl_data.revers_ind     := get_field(86, 1);
    l_rep.trans_dispos   := get_field(87, 2); --, '5TDP');
    l_rep.trans_count    := get_field(89, 15);
    l_rep.amount         := correct_sign(get_field(104, 15), get_field(119, 2) );
    o_sttl_data.summary_level  := get_field(121, 2); --, '5SML');
    l_rep.crs_date       := date_ddmmmyy(get_field(123, 7));
    l_rep.reimb_attr     := get_field(168, 1);
    l_rep.inst_id        := i_inst_id;

    insert into vis_vss6(
        id
      , file_id
      , record_number
      , status
      , dst_bin
      , src_bin
      , sre_id
      , proc_id
      , clear_bin
      , clear_currency
      , sttl_service
      , bus_mode
      , no_data
      , report_group
      , report_subgroup
      , rep_id_num
      , rep_id_sfx
      , sttl_date
      , report_date
      , fin_ind
      , clear_only
      , bus_tr_type
      , bus_tr_cycle
      , reversal
      , trans_dispos
      , trans_count
      , amount
      , summary_level
      , reimb_attr
      , inst_id
      , crs_date)
    values(
        vis_vss6_seq.nextval
      , l_rep.file_id
      , l_rep.record_number
      , l_rep.status
      , o_sttl_data.dst_bin
      , o_sttl_data.src_bin
      , o_sttl_data.sre_id
      , l_rep.proc_id
      , l_rep.clear_bin
      , o_sttl_data.clear_currency
      , o_sttl_data.sttl_service
      , o_sttl_data.bus_mode
      , o_sttl_data.no_data
      , o_sttl_data.report_group
      , o_sttl_data.report_subgroup
      , o_sttl_data.rep_id_num
      , o_sttl_data.rep_id_sfx
      , o_sttl_data.sttl_date
      , o_sttl_data.report_date
      , l_rep.fin_ind
      , l_rep.clear_only
      , o_sttl_data.bus_tr_type
      , o_sttl_data.bus_tr_cycle
      , o_sttl_data.revers_ind
      , l_rep.trans_dispos
      , l_rep.trans_count
      , l_rep.amount
      , o_sttl_data.summary_level
      , l_rep.reimb_attr
      , l_rep.inst_id
      , l_rep.crs_date
    );
end process_report_v6;

procedure process_settlement_data(
    i_tc_buffer      in     vis_api_type_pkg.t_tc_buffer
  , i_file_id        in     com_api_type_pkg.t_long_id
  , i_record_number  in     com_api_type_pkg.t_short_id
  , i_inst_id        in     com_api_type_pkg.t_inst_id
  , i_host_id        in     com_api_type_pkg.t_tiny_id
  , i_standard_id    in     com_api_type_pkg.t_tiny_id
  , i_register_event in     com_api_type_pkg.t_boolean  default com_api_const_pkg.FALSE
) is
    v_report_group          char(1) := substr(i_tc_buffer(1), 59, 1);
    v_report_subgroup       char(1) := substr(i_tc_buffer(1), 60, 1);
    l_sttl_data_rec         vis_api_type_pkg.t_settlement_data_rec;
begin
    case v_report_group || v_report_subgroup
    when 'V1' then
        process_report_v1(
            i_tc_buffer     => i_tc_buffer
          , i_file_id       => i_file_id
          , i_inst_id       => i_inst_id
          , i_record_number => i_record_number
          , o_sttl_data     => l_sttl_data_rec
        );
    when 'V2' then
        process_report_v2(
            i_tc_buffer      => i_tc_buffer
          , i_file_id        => i_file_id
          , i_inst_id        => i_inst_id
          , i_record_number  => i_record_number
          , o_sttl_data      => l_sttl_data_rec
          , i_register_event => i_register_event
        );
    when 'V4' then
        process_report_v4(
            i_tc_buffer     => i_tc_buffer
          , i_file_id       => i_file_id
          , i_inst_id       => i_inst_id
          , i_record_number => i_record_number
          , o_sttl_data     => l_sttl_data_rec
        );
    when 'V6' then
        process_report_v6(
            i_tc_buffer     => i_tc_buffer
          , i_file_id       => i_file_id
          , i_inst_id       => i_inst_id
          , i_record_number => i_record_number
          , o_sttl_data     => l_sttl_data_rec
        );
    else
        trc_log_pkg.warn(
            i_text        => 'VIS_UNKNOWN_REPORT_GROUP'
          , i_env_param1  =>  v_report_group
          , i_env_param2  =>  v_report_subgroup
        );
    end case;

    if l_sttl_data_rec.rep_id_num is not null then
        vis_cst_incoming_pkg.process_settlement_data(
            i_sttl_data   => l_sttl_data_rec
          , i_host_id     => i_host_id
          , i_standard_id => i_standard_id
        );
    end if;
end;  

procedure process_multipurpose(
    i_tc_buffer       in     vis_api_type_pkg.t_tc_buffer
  , i_file_id         in     com_api_type_pkg.t_long_id
  , i_record_number   in     com_api_type_pkg.t_short_id
  , i_inst_id         in     com_api_type_pkg.t_inst_id
  , i_validate_record in     com_api_type_pkg.t_boolean
  , i_network_id      in     com_api_type_pkg.t_tiny_id
  , i_host_id         in     com_api_type_pkg.t_tiny_id
  , i_standard_id     in     com_api_type_pkg.t_tiny_id
) is
    l_msg                    vis_api_type_pkg.t_visa_multipurpose_rec := null;
    l_data                   com_api_type_pkg.t_name;
    l_record_type            varchar2(6);
    l_auth_oper_type         com_api_type_pkg.t_dict_value;
    l_currency_exponent      com_api_type_pkg.t_tiny_id;

    l_iss_inst_id            com_api_type_pkg.t_inst_id;
    l_iss_network_id         com_api_type_pkg.t_tiny_id;
    l_card_inst_id           com_api_type_pkg.t_inst_id;
    l_card_network_id        com_api_type_pkg.t_tiny_id;
    l_card_type_id           com_api_type_pkg.t_tiny_id;
    l_country_code           com_api_type_pkg.t_country_code;
    l_bin_currency           com_api_type_pkg.t_curr_code;
    l_sttl_currency          com_api_type_pkg.t_curr_code;
    l_acq_inst_id            com_api_type_pkg.t_inst_id;
    l_dst_bin                com_api_type_pkg.t_bin;
    
    ----V23200
    l_msg_sms1               vis_api_type_pkg.t_visa_sms1_rec;
    
    function get_field (
        i_start       in pls_integer
        , i_length    in pls_integer
    ) return varchar2 is
    begin
        return rtrim(substr(substr(l_data, 35), i_start, i_length), ' ');
    end;

    function get_common_field (
        i_begin       in pls_integer
        , i_length    in pls_integer
    ) return varchar2 is
    begin
        return rtrim(substr(l_data, i_begin, i_length), ' ');
    end;

    function get_sms_oper_type (
        i_proc_code in varchar2
    ) return com_api_type_pkg.t_dict_value is
    begin
        return
            case substr(i_proc_code, 1, 2)
                when '00' then
                    opr_api_const_pkg.OPERATION_TYPE_PURCHASE
                when '01' then
                    opr_api_const_pkg.OPERATION_TYPE_ATM_CASH
                else
                    null
            end;
    end;

begin
    l_data                := i_tc_buffer(1);
    l_record_type         := get_field(1, 6);

    -- we need to retrieve data only for Financial Transaction Record 1 (V22200) that contains general information about trxn.
    if l_record_type = vis_api_const_pkg.VISA_VSS_RECORD_TYPE_1 then

        l_dst_bin             := get_common_field(5, 6);
        l_msg.file_id         := i_file_id;
        l_msg.record_number   := i_record_number;
        l_msg.inst_id         := i_inst_id;
        l_msg.status          := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;
        l_msg.iss_acq         := get_field(7, 1);
        l_msg.mvv_code        := get_field(8, 10);
        l_msg.remote_terminal := get_field(18, 1);
        l_msg.charge_ind      := get_field(19, 1);
        l_msg.account_prod_id := get_field(20, 2);
        l_msg.bus_app_ind     := get_field(22, 2);
        l_msg.funds_source    := get_field(24, 1);
        l_msg.affiliate_bin   := get_field(28, 10);
        l_msg.sttl_date       := date_mmddyy(get_field(38, 6));
        l_msg.trxn_ind        := get_field(44, 15);
        l_msg.val_code        := get_field(59, 4);
        l_msg.refnum          := get_field(63, 12);
        l_msg.trace_num       := get_field(75, 6);
        l_msg.batch_num       := get_field(81, 4);
        l_msg.req_msg_type    := get_field(85, 4);
        l_msg.resp_code       := get_field(89, 2);
        l_msg.proc_code       := get_field(91, 6);
        l_msg.card_number     := get_field(97, 19);
        l_msg.trxn_amount     := to_number(get_field(116, 11) ||
                                     case substr(get_field(116, 12), -1)
                                         when '{' then '0'
                                         when 'A' then '1'
                                         when 'B' then '2'
                                         when 'C' then '3'
                                         when 'D' then '4'
                                         when 'E' then '5'
                                         when 'F' then '6'
                                         when 'G' then '7'
                                         when 'H' then '8'
                                         when 'I' then '9'
                                         when '}' then '0'
                                         when 'J' then '1'
                                         when 'K' then '2'
                                         when 'L' then '3'
                                         when 'M' then '4'
                                         when 'N' then '5'
                                         when 'O' then '6'
                                         when 'P' then '7'
                                         when 'Q' then '8'
                                         when 'R' then '9'
                                         else substr(get_field(116, 12), -1)
                                     end
                                 );
        l_msg.currency_code   := get_field(128, 3);

         -- if currency exponent equal to zero then cut-off last two digits from amount in accordance with VISA rules
        l_currency_exponent   := com_api_currency_pkg.get_currency_exponent(i_curr_code => l_msg.currency_code);
        if l_currency_exponent < 2 then
            l_msg.trxn_amount := round(l_msg.trxn_amount / power(10, 2 - l_currency_exponent));
        elsif l_currency_exponent > 2 then
            l_msg.trxn_amount := l_msg.trxn_amount * power(10, l_currency_exponent - 2);
        end if;

        l_auth_oper_type      := get_sms_oper_type(l_msg.proc_code);

        if l_msg.iss_acq = 'I' then
 
            -- Get "l_acq_inst_id" value
            iss_api_bin_pkg.get_bin_info (
                i_card_number        => l_msg.card_number
                , o_iss_inst_id      => l_iss_inst_id
                , o_iss_network_id   => l_iss_network_id
                , o_card_inst_id     => l_card_inst_id
                , o_card_network_id  => l_card_network_id
                , o_card_type        => l_card_type_id
                , o_card_country     => l_country_code
                , o_bin_currency     => l_bin_currency
                , o_sttl_currency    => l_sttl_currency
            );

            begin
                l_acq_inst_id := cmn_api_standard_pkg.find_value_owner(
                                     i_standard_id       => i_standard_id
                                   , i_entity_type       => net_api_const_pkg.ENTITY_TYPE_HOST
                                   , i_object_id         => i_host_id
                                   , i_param_name        => vis_api_const_pkg.ACQ_BUSINESS_ID
                                   , i_value_char        => l_dst_bin
                                 );
            exception
                when others then
                    if com_api_error_pkg.get_last_error = 'NOT_FOUND_VALUE_OWNER' then
                        l_acq_inst_id := null;
                    else
                        raise;
                    end if;
            end;

            if l_acq_inst_id is null then
                l_acq_inst_id := net_api_network_pkg.get_inst_id(i_network_id);
            end if;
        else
            l_acq_inst_id     := i_inst_id;
        end if;

        -- matching with authorization
        begin
            select m.id
              into l_msg.match_auth_id
              from (
                  select op.id
                    from opr_operation_participant_vw op
                       , aut_auth a
                   where op.originator_refnum   = l_msg.refnum
                     and a.id                   = op.id         -- Find authorization which has the "aut_auth" record
                     and (
                           op.oper_type         = l_auth_oper_type
                           or l_auth_oper_type is null
                         )
                     and op.msg_type            = aut_api_const_pkg.MESSAGE_TYPE_AUTHORIZATION
                     and op.acq_inst_id         = l_acq_inst_id
                     and abs(trunc(op.host_date) - trunc(l_msg.sttl_date)) <= 30
                     and nvl(l_msg.card_number, op.card_number) = nvl(op.card_number, l_msg.card_number)
                     and (
                             (
                                 op.is_reversal = 1
                                 and l_msg.req_msg_type in (vis_api_const_pkg.SMS_MSG_TYPE_REVERSAL
                                                          , vis_api_const_pkg.SMS_MSG_TYPE_REVERSAL_ADVICE)
                             )
                             or
                             (
                                 op.is_reversal = 0
                                 and l_msg.req_msg_type not in (vis_api_const_pkg.SMS_MSG_TYPE_REVERSAL
                                                              , vis_api_const_pkg.SMS_MSG_TYPE_REVERSAL_ADVICE)
                             )
                         )
                   order by op.id desc
              ) m
             where rownum = 1;

        exception
            when no_data_found then
                l_msg.match_auth_id := null;
                trc_log_pkg.info('AUTH_NOT_FOUND');
        end;

        insert into vis_multipurpose(
            id
          , file_id
          , record_number
          , status
          , iss_acq
          , mvv_code
          , remote_terminal
          , charge_ind
          , account_prod_id
          , bus_app_ind
          , funds_source
          , affiliate_bin
          , sttl_date
          , trxn_ind
          , val_code
          , refnum
          , trace_num
          , batch_num
          , req_msg_type
          , resp_code
          , proc_code
          , card_number
          , trxn_amount
          , currency_code
          , match_auth_id
          , inst_id)
        values(
            vis_multipurpose_seq.nextval
          , l_msg.file_id
          , l_msg.record_number
          , l_msg.status
          , l_msg.iss_acq
          , l_msg.mvv_code
          , l_msg.remote_terminal
          , l_msg.charge_ind
          , l_msg.account_prod_id
          , l_msg.bus_app_ind
          , l_msg.funds_source
          , l_msg.affiliate_bin
          , l_msg.sttl_date
          , l_msg.trxn_ind
          , l_msg.val_code
          , l_msg.refnum
          , l_msg.trace_num
          , l_msg.batch_num
          , l_msg.req_msg_type
          , l_msg.resp_code
          , l_msg.proc_code
          , l_msg.card_number
          , l_msg.trxn_amount
          , l_msg.currency_code
          , l_msg.match_auth_id
          , l_msg.inst_id
       );
    elsif l_record_type = vis_api_const_pkg.VISA_SMS_RECORD_TYPE_1 then

        l_msg_sms1.id                  := opr_api_create_pkg.get_id;
        l_msg_sms1.record_type         := l_record_type;
        l_msg_sms1.file_id             := i_file_id;
        l_msg_sms1.record_number       := i_record_number;
        l_msg_sms1.inst_id             := i_inst_id;
        l_msg_sms1.status              := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;
        l_msg_sms1.iss_acq             := get_field(7, 1);
        l_msg_sms1.isa_ind             := get_field(8, 1);
        l_msg_sms1.giv_flag            := get_field(9, 1);
        l_msg_sms1.affiliate_bin       := get_field(10, 10);
        l_msg_sms1.sttl_date           := date_mmddyy(get_field(20, 6));
        l_msg_sms1.val_code            := get_field(26, 4);
        l_msg_sms1.refnum              := get_field(30, 12);
        l_msg_sms1.trace_num           := get_field(42, 6);
        l_msg_sms1.req_msg_type        := get_field(48, 4);
        l_msg_sms1.resp_code           := get_field(52, 2);
        l_msg_sms1.proc_code           := get_field(54, 6);
        l_msg_sms1.msg_reason_code     := get_field(60, 4);
        l_msg_sms1.card_number         := get_field(64, 19);
        l_msg_sms1.trxn_ind            := get_field(83, 15);
        l_msg_sms1.sttl_amount         := get_field(101,12);
        l_msg_sms1.surcharge_amount    := get_field(122, 8);
        l_msg_sms1.sttl_curr_code      := get_field(98, 3);
        
        -- if currency exponent equal to zero then cut-off last two digits from amount in accordance with VISA rules
        l_currency_exponent   := com_api_currency_pkg.get_currency_exponent(i_curr_code => l_msg_sms1.sttl_curr_code);
        if l_currency_exponent < 2 then
            l_msg_sms1.sttl_amount := round(l_msg_sms1.sttl_amount / power(10, 2 - l_currency_exponent));
        elsif l_currency_exponent > 2 then
            l_msg_sms1.sttl_amount := l_msg_sms1.sttl_amount * power(10, l_currency_exponent - 2);
        end if;
        
        l_msg_sms1.sttl_sign           := get_field(113, 1);
        l_msg_sms1.reserved            := get_field(114, 7);
        l_msg_sms1.spend_qualified_ind := get_field(121, 1);
        l_msg_sms1.surcharge_sign      := get_field(130, 1);
      
        insert into vis_sms1(
            id
          , file_id
          , record_number
          , status
          , record_type
          , iss_acq
          , isa_ind
          , giv_flag
          , affiliate_bin
          , sttl_date
          , val_code
          , refnum
          , trace_num
          , req_msg_type
          , resp_code
          , proc_code
          , msg_reason_code
          , trxn_ind
          , sttl_curr_code
          , sttl_amount
          , sttl_sign
          , reserved
          , spend_qualified_ind
          , surcharge_amount
          , surcharge_sign
          , inst_id
        ) values (
            l_msg_sms1.id
          , l_msg_sms1.file_id
          , l_msg_sms1.record_number
          , l_msg_sms1.status
          , l_msg_sms1.record_type
          , l_msg_sms1.iss_acq
          , l_msg_sms1.isa_ind
          , l_msg_sms1.giv_flag
          , l_msg_sms1.affiliate_bin
          , l_msg_sms1.sttl_date
          , l_msg_sms1.val_code
          , l_msg_sms1.refnum
          , l_msg_sms1.trace_num
          , l_msg_sms1.req_msg_type
          , l_msg_sms1.resp_code
          , l_msg_sms1.proc_code
          , l_msg_sms1.msg_reason_code
          , l_msg_sms1.trxn_ind
          , l_msg_sms1.sttl_curr_code
          , l_msg_sms1.sttl_amount
          , l_msg_sms1.sttl_sign
          , l_msg_sms1.reserved
          , l_msg_sms1.spend_qualified_ind
          , l_msg_sms1.surcharge_amount
          , l_msg_sms1.surcharge_sign
          , l_msg_sms1.inst_id
        );
        
        insert into vis_card(
            id
          , card_number
        ) values (
            l_msg_sms1.id
          , iss_api_token_pkg.encode_card_number(i_card_number => l_msg_sms1.card_number)
        );

    end if;

    if i_validate_record = com_api_const_pkg.TRUE
    then
        vis_api_reject_pkg.validate_visa_record_auth(
            i_oper_id     => l_msg.match_auth_id
            , i_visa_data => substr(l_data, 35)
        );
    end if;
end;

-- Process VISA clearing files for records TC 44 - Collection Batch Acknowledgment Transactions
procedure process_rejected (
    i_tc_buffer             in vis_api_type_pkg.t_tc_buffer
    , i_record_number       in com_api_type_pkg.t_short_id -- record number in file
    , i_validate_record     in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
) is
    l_msg                   vis_reject%rowtype := NULL;
    l_orig_file_id          com_api_type_pkg.t_long_id;
    l_orig_batch_id         com_api_type_pkg.t_long_id;
    l_record_number         com_api_type_pkg.t_short_id;
    l_validation_result     com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE;
    l_reject_data_id        com_api_type_pkg.t_long_id;

    function get_field (
        i_start       in pls_integer
        , i_length    in pls_integer
    ) return varchar2 is
    begin
        return trim(substr(i_tc_buffer(i_tc_buffer.count), i_start, i_length));
    end get_field;

begin
    l_validation_result := com_api_const_pkg.TRUE;
    -- Transaction Component Sequence Number must be = 9
    if substr(i_tc_buffer(i_tc_buffer.count),4,1)<>'9' then
        trc_log_pkg.error (
            i_text          => 'TCR9_NOT_FOUND_IN_RETURNED_ITEM'
            , i_env_param1  => i_record_number
        );
    end if;
    --1 save visa reject data
    l_msg.dst_bin            := get_field(5, 6);  -- Destination BIN
    l_msg.src_bin            := get_field(11, 6); -- Source BIN
    l_msg.original_tc        := get_field(1, 2);  -- Transaction Code
    l_msg.original_tcq       := get_field(3, 1);  -- Transaction Code Qualifier
    l_msg.original_tcr       := get_field(4, 1);  -- Transaction Component Sequence Number
    l_msg.src_batch_date     := to_date(get_field(17, 5), 'YYDDD'); -- Edit Package Batch Date
    l_msg.src_batch_number   := get_field(22, 6); -- Edit Package Batch Number
    l_msg.item_seq_number    := get_field(28, 8);  -- Interchange Window ID Number (?)
    l_msg.original_amount    := null; --get_field(39, 12); -- Source amount of the rejected transaction
    l_msg.original_currency  := null; --get_field(51, 3);  -- Source currency code of the rejected transaction
    l_msg.original_sttl_flag := null; --get_field(54, 1);  -- Settlement flag of the rejected transaction
    l_msg.crs_return_flag    := null; --get_field(55, 1);  -- Chargeback Reduction Service (CRS) Return Flag
    l_msg.reason_code1       := get_field(37, 3); -- Reject Reason Code 1
    l_msg.reason_code2       := null; -- Reject Reason Code 2
    l_msg.reason_code3       := null; -- Reject Reason Code 3
    l_msg.reason_code4       := null; -- Reject Reason Code 4
    l_msg.reason_code5       := null; -- Reject Reason Code 5
    l_msg.reason_code6       := null; -- Reject Reason Code 6
    l_msg.reason_code7       := null; -- Reject Reason Code 7
    l_msg.reason_code8       := null; -- Reject Reason Code 8
    l_msg.reason_code9       := null; -- Reject Reason Code 9
    l_msg.reason_code10      := null; -- Reject Reason Code 10

    --2 mark original outgoing batch as rejected
    update
        vis_batch b
    set
        b.is_rejected = com_api_const_pkg.TRUE
    where
        b.batch_number = to_number(l_msg.src_batch_number)
        and trunc(b.proc_date) = l_msg.src_batch_date
        and exists (
            select 1
              from vis_file f
             where f.id = b.file_id
               and f.is_incoming = 0
        )
    returning
        b.id
        , b.file_id
    into
        l_orig_batch_id
        , l_orig_file_id;

    -- mark original file as rejected
    update vis_file
       set is_rejected = com_api_const_pkg.TRUE
     where id          = l_orig_file_id;

    -- arn from the transaction being rejected (not specified in TC44)
    --l_arn := substr(i_tc_buffer(1), 27, 23);

    -- select record_number from batch
    select min(record_number)
      into l_record_number
      from (select record_number -- Number of record in clearing file
                 , arn
                 , row_number() over(order by record_number) as rn -- Number of record in batch
              from vis_fin_message fm
             where batch_id = l_orig_batch_id
               and file_id  = l_orig_file_id
           ) f
     where f.rn >= to_number(l_msg.item_seq_number); -- in TC44 in 'Interchange Window ID Number') ?
     --and arn = l_arn;

    -- 3 mark original message as rejected
    update vis_fin_message
       set is_rejected   = com_api_const_pkg.TRUE
     where batch_id      = l_orig_batch_id
       and file_id       = l_orig_file_id
       and record_number = l_record_number
 returning id
      into l_msg.original_id;

    if l_msg.original_id is null then
        com_api_error_pkg.raise_error (
            i_error      =>  'CAN_NOT_MARK_ORIGINAL_MESSAGE_AS_REJECTED'
          , i_env_param1  => l_orig_batch_id
          , i_env_param2  => l_orig_file_id
          , i_env_param3  => l_msg.item_seq_number
        );
    end if;

    l_msg.file_id            := l_orig_file_id;
    l_msg.batch_id           := l_orig_batch_id;
    l_msg.record_number      := l_record_number;
    --
    vis_api_reject_pkg.put_reject(l_msg);

    -- 4 save operation rejected data in format 'Operation reject data'
    vis_api_reject_pkg.put_reject_data(
        i_reject_rec      => l_msg
      , o_reject_data_id  => l_reject_data_id
    );

    --5 validate record and save visa rejected codes
    if i_validate_record = com_api_const_pkg.TRUE
    then
       l_validation_result :=
           vis_api_reject_pkg.validate_visa_record(
               i_reject_data_id  => l_reject_data_id
             , i_visa_record     => i_tc_buffer(i_tc_buffer.count)
           );
       -- set that record failed on format validation
       if l_validation_result = com_api_const_pkg.FALSE
       then
           update vis_reject_data
              --1(REJECTS DUE TO FORMAL/LOGICAL-FORMAL VALIDATIONS
              set reject_type = com_api_reject_pkg.REJECT_TYPE_PRIMARY_VALIDATION -- RJTP0001
            where id = l_reject_data_id;
       end if;
    end if;
end process_rejected;

-- process VISA Rejected Item File record
procedure process_rejected_item (
    i_tc_buffer       in      com_api_type_pkg.t_text --vis_api_type_pkg.t_tc_buffer
  , i_record_number   in      com_api_type_pkg.t_short_id
  , i_validate_record in     com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
) is
    l_msg                   vis_reject%rowtype := NULL;
    l_orig_file_id          com_api_type_pkg.t_long_id;
    l_orig_batch_id         com_api_type_pkg.t_long_id;
    l_record_number         com_api_type_pkg.t_short_id;
    l_validation_result     com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE;
    l_reject_data_id        com_api_type_pkg.t_long_id;

    function get_field (
        i_start       in pls_integer
      , i_length      in pls_integer
    ) return varchar2 is
    begin
        return trim(substr(i_tc_buffer, i_start, i_length));
    end;

begin
    l_validation_result := com_api_const_pkg.TRUE;
    -- Transaction Component Sequence Number must be = 9
    if substr(i_tc_buffer, 4, 1) != '9' then
        trc_log_pkg.error(
            i_text        => 'TCR9_NOT_FOUND_IN_RETURNED_ITEM'
          , i_env_param1  => i_record_number
        );
        g_error_flag := com_api_type_pkg.TRUE;
    end if;
    --1 save visa reject data
    l_msg.dst_bin            := get_field(5, 6);  -- Destination BIN
    l_msg.src_bin            := get_field(11, 6); -- Source BIN
    l_msg.original_tc        := get_field(1, 2);  -- Transaction Code
    l_msg.original_tcq       := get_field(3, 1);  -- Transaction Code Qualifier
    l_msg.original_tcr       := get_field(4, 1);  -- Transaction Component Sequence Number
    l_msg.src_batch_date     := to_date(get_field(21, 5), 'YYDDD'); -- Run Date
    l_msg.src_batch_number   := get_field(26, 6);  -- Batch Number
    l_msg.item_seq_number    := get_field(32, 4);  -- Batch Sequence
    l_msg.original_amount    := get_field(39, 12); -- Source Amount
    l_msg.original_currency  := get_field(51, 3);  -- Source Currency
    l_msg.original_sttl_flag := get_field(54, 1);  -- Settlement Flag
    l_msg.crs_return_flag    := null;-- get_field(55, 1);  -- Chargeback Reduction Service (CRS) Return Flag
    l_msg.reason_code1       := get_field(68, 4); -- Validation Message Code 1
    l_msg.reason_code2       := get_field(72, 4); -- Validation Message Code 2
    l_msg.reason_code3       := get_field(76, 4); -- Validation Message Code 3
    l_msg.reason_code4       := get_field(80, 4); -- Validation Message Code 4
    l_msg.reason_code5       := get_field(84, 4); -- Validation Message Code 5
    l_msg.reason_code6       := get_field(88, 4); -- Validation Message Code 6
    l_msg.reason_code7       := get_field(92, 4); -- Validation Message Code 7
    l_msg.reason_code8       := get_field(96, 4); -- Validation Message Code 8
    l_msg.reason_code9       := get_field(100, 4); -- Validation Message Code 9
    l_msg.reason_code10      := get_field(104, 4); -- Validation Message Code 10

    --2 mark original outgoing batch as rejected
    update vis_batch b
       set b.is_rejected      = com_api_const_pkg.TRUE
     where b.batch_number     = to_number(l_msg.src_batch_number)
       and trunc(b.proc_date) = l_msg.src_batch_date
       and exists (select 1
                     from vis_file f
                    where f.id          = b.file_id
                      and f.is_incoming = 0
        )
 returning b.id
         , b.file_id
      into l_orig_batch_id
         , l_orig_file_id;

    -- mark original file as rejected
    update vis_file
       set is_rejected = com_api_const_pkg.TRUE
     where id          = l_orig_file_id;

    -- select record_number from batch
    select min(record_number)
      into l_record_number
      from (select record_number -- Number of record in clearing file
                 , row_number() over(order by record_number) as rn -- Number of record in batch
              from vis_fin_message fm
             where batch_id = l_orig_batch_id
               and file_id  = l_orig_file_id
           ) f
     where f.rn >= to_number(l_msg.item_seq_number);

    -- 3 mark original message as rejected
    update vis_fin_message
       set is_rejected   = com_api_const_pkg.TRUE
     where batch_id      = l_orig_batch_id
       and file_id       = l_orig_file_id
       and record_number = l_record_number
 returning id
      into l_msg.original_id;

    if l_msg.original_id is null then
        com_api_error_pkg.raise_error (
            i_error       => 'CAN_NOT_MARK_ORIGINAL_MESSAGE_AS_REJECTED'
          , i_env_param1  => l_orig_batch_id
          , i_env_param2  => l_orig_file_id
          , i_env_param3  => l_msg.item_seq_number
        );
    end if;

    l_msg.file_id       := l_orig_file_id;
    l_msg.batch_id      := l_orig_batch_id;
    l_msg.record_number := l_record_number;

    vis_api_reject_pkg.put_reject(i_msg => l_msg);

    -- 4 save operation rejected data in format 'Operation reject data'
    vis_api_reject_pkg.put_reject_data(
        i_reject_rec      => l_msg
      , o_reject_data_id  => l_reject_data_id
    );

    --5 validate record and save visa rejected codes
    if i_validate_record = com_api_const_pkg.TRUE
    then
        l_validation_result :=
            vis_api_reject_pkg.validate_visa_record(
                i_reject_data_id => l_reject_data_id
              , i_visa_record    => i_tc_buffer
            );
        -- set that record failed on format validation
        if l_validation_result = com_api_const_pkg.FALSE
        then
            update vis_reject_data
               set reject_type = com_api_reject_pkg.REJECT_TYPE_PRIMARY_VALIDATION -- RJTP0001
             where id = l_reject_data_id;
        end if;
    end if;
end process_rejected_item;

procedure process_multipurpose_message(
    i_tc_buffer             in vis_api_type_pkg.t_tc_buffer
) is
    l_low_range                com_api_type_pkg.t_card_number;
    l_high_range               com_api_type_pkg.t_card_number;
    l_curr_code                com_api_type_pkg.t_curr_code;

    function get_field (
        i_start       in pls_integer
        , i_length    in pls_integer
    ) return varchar2 is
    begin
        return rtrim(substr(i_tc_buffer(1), i_start, i_length), ' ');
    end;

begin
    if get_field(4, 1) = '0' and get_field(35, 10) like vis_api_const_pkg.DCC_CURRENCY_TCR_MARKER then
        -- This is Account Billing Currency File record (DCC currencies)
        l_low_range  := to_number(get_field(59, 18));
        l_high_range := to_number(get_field(78, 18));
        l_curr_code  := get_field(97, 3);
        merge into vis_acc_billing_currency d
        using (
            select l_low_range as low_range, l_high_range as high_range,
                   l_curr_code as currency,  get_sysdate  as load_date
              from dual
        ) s
        on (d.low_range = s.low_range and d.high_range = s.high_range)
        when matched then
            update set
                d.currency = s.currency, d.load_date = s.load_date
        when not matched then
            insert (d.low_range, d.high_range, d.currency, d.load_date)
            values (s.low_range, s.high_range, s.currency, s.load_date);
    else
        trc_log_pkg.debug('unknown multipurpose message: ' ||i_tc_buffer(1));
    end if;
end process_multipurpose_message;

procedure process_vcr_advice(
    i_tc_buffer          in     vis_api_type_pkg.t_tc_buffer
  , i_file_id            in     com_api_type_pkg.t_long_id
  , i_record_number      in     com_api_type_pkg.t_short_id
  , i_inst_id            in     com_api_type_pkg.t_inst_id
  , i_network_id         in     com_api_type_pkg.t_tiny_id
  , i_standard_id        in     com_api_type_pkg.t_tiny_id
  , i_standard_version   in     com_api_type_pkg.t_tiny_id
  , i_create_operation   in     com_api_type_pkg.t_boolean
  , i_incom_sess_file_id in     com_api_type_pkg.t_long_id
  , i_need_repeat        in     com_api_type_pkg.t_boolean
  , i_create_disp_case   in     com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
) is
    l_msg                       vis_api_type_pkg.t_vcr_advice_rec;
    l_data                      com_api_type_pkg.t_name;
    l_currency_exponent         com_api_type_pkg.t_tiny_id;
    l_visa                      vis_api_type_pkg.t_visa_fin_mes_rec;
    
    l_iss_network_id            com_api_type_pkg.t_tiny_id;
    l_acq_network_id            com_api_type_pkg.t_tiny_id;
    l_sttl_type                 com_api_type_pkg.t_dict_value;
    l_match_status              com_api_type_pkg.t_dict_value;
    
    l_iss_inst_id               com_api_type_pkg.t_inst_id;
    l_acq_inst_id               com_api_type_pkg.t_inst_id;

    function get_field (
        i_start  in     pls_integer
      , i_length in     pls_integer
    ) return varchar2 is
    begin
        return rtrim(substr(l_data, i_start, i_length), ' ');
    end;
begin
    l_msg.file_id         := i_file_id;
    l_msg.record_number   := i_record_number;
    l_msg.inst_id         := i_inst_id;
    l_msg.status          := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;
    
    l_data := i_tc_buffer(1);
    if get_field(3, 1) = '0' then
        --  BASE II Dispute Financial Status Advice, TCR 0 Record
        l_msg.trans_code           := get_field(1, 2);    -- 1-2     Transaction Code  2 UN
        l_msg.trans_code_qualifier := get_field(3, 1);    -- 3       Transaction Code Qualifier 1 UN
        l_msg.trans_component_seq  := get_field(4, 1);    -- 4       Transaction Component Sequence Number  1 UN
        l_msg.dest_bin             := get_field(5, 6);    -- 5-10    Destination BIN 6 AN
        l_msg.source_bin           := get_field(11, 6);   -- 11-16   Source BIN  6 AN
        l_msg.vcr_record_id        := get_field(17, 3);   -- 17-19   VCR Record Identifier 3 AN
        l_msg.dispute_status       := get_field(20, 2);   -- 20-21   Dispute Status  2 AN
        l_msg.dispute_trans_code   := get_field(22, 2);   -- 22-23   Dispute Transaction Code  2 AN
        l_msg.dispute_tc_qualifier := get_field(24, 1);   -- 24      Dispute Transaction Code Qualifier 1 AN
        l_msg.orig_recipient_ind   := get_field(25, 1);   -- 25      Originator/Recipient Indicator 1 AN
        l_msg.card_number          := get_card_number(
                                          i_card_number => get_field(26, 16)
                                        , i_network_id  => i_network_id
                                      ); -- 26-41   Account Number 16  AN
        l_msg.card_number_ext      := get_field(42, 3);   -- 42-44   Account Number Extension 3 UN
        l_msg.acq_ref_number       := get_field(45, 23);  -- 45-67   Acquirer Reference Number 23 UN
        l_msg.purchase_date        := get_field(68, 4);   -- 68-71   Purchase Date (MMDD) 4 UN
        
        l_msg.source_curr_code     := get_field(84, 3);   -- 84-86   Source Currency Code 3 UN
        -- 72-83   Source Amount 12 UN
        -- if currency exponent equal to zero then cut-off last two digits from amount in accordance with VISA rules
        l_currency_exponent := com_api_currency_pkg.get_currency_exponent(i_curr_code => l_msg.source_curr_code);
        if l_currency_exponent = 0 then
            l_msg.source_amount     := get_field(72, 12 - 2);
        else
            l_msg.source_amount     := get_field(72, 12);
            if l_currency_exponent > 2 then
                l_msg.source_amount := l_msg.source_amount * power(10, l_currency_exponent - 2);
            end if;
        end if;
        
        l_msg.merchant_name        := get_field(87, 25);  -- 87-111  Merchant Name 25  AN
        l_msg.merchant_city        := get_field(112, 13); -- 112-124 Merchant City 13  AN
        l_msg.merchant_country     := com_api_country_pkg.get_country_code(
                                          i_visa_country_code => trim(get_field(125, 3))
                                      );                  -- 125-127 Merchant Country Code 3 AN
        l_msg.mcc                  := get_field(128, 4);  -- 128-131 Merchant Category Code 4 UN
        l_msg.merchant_region_code := get_field(132, 3);  -- 132-134 Merchant State/Province Code 3 AN
        l_msg.merchant_postal_code := get_field(135, 5);  -- 135-139 Merchant ZIP Code 5 UN
        l_msg.req_payment_service  := get_field(140, 1);  -- 140     Requested Payment Service 1 AN
        l_msg.auth_code            := get_field(141, 6);  -- 141-146 Authorization Code 6 AN
        l_msg.pos_entry_mode       := get_field(147, 2);  -- 147-148 POS Entry Mode 2 AN
        l_msg.central_proc_date    := get_field(149, 4);  -- 149-152 Central ProcessingDate (YDDD) 4 UN
        l_msg.card_acceptor_id     := get_field(153, 15); -- 153-167 Card Acceptor ID 15  AN
        l_msg.reimbursement        := get_field(168, 1);  -- 168     Reimbursement Attribute 1 AN
      
        l_data := i_tc_buffer(2);
        -- BASE II Dispute Financial Status Advice, TCR 1 Record
        l_msg.network_code         := get_field(5, 4);   -- 5-8 Network Identification Code 4 UN
        l_msg.dispute_condition    := get_field(9, 3);   -- 9-11 Dispute Condition 3 ANS 
        l_msg.vrol_fin_id          := get_field(12, 11); -- 12-22 VROL Financial ID 11 ANS
        l_msg.vrol_case_number     := get_field(23, 10); -- 23-32 VROL Case Number  10 UN 
        l_msg.vrol_bundle_case_num := get_field(33, 10); -- 33-42 VROL Bundle Case Number 10 UN
        l_msg.client_case_number   := get_field(43, 20); -- 43-62 Client Case Number  20  ANS
        --l_msg.reserved           := get_field(63, 6);  -- 63-66 field is reserved for future use 4 AN
        l_msg.clearing_seq_number  := get_field(67, 2);  -- 67-68 Multiple Clearing Sequence Number 2 UN
        l_msg.clearing_seq_count   := get_field(69, 2);  -- 69-70 Multiple Clearing Sequence Count 2 UN
        l_msg.product_id           := get_field(71, 2);  -- 71-72  Product ID  2 AN
        l_msg.spend_qualified_ind  := get_field(73, 1);  -- 73  Spend Qualified Indicator 1 AN
        l_msg.dsp_fin_reason_code  := get_field(74, 2);  -- 74-75 Dispute Financial Reason Code 2 UN
        l_msg.settlement_flag      := get_field(76, 1);  -- 76 Settlement Flag 1 UN
        l_msg.usage_code           := get_field(77, 1);  -- 77 Usage Code 1 UN
        l_msg.trans_identifier     := get_field(78, 15); -- 78-92 Transaction Identifier 15 UN
        l_msg.acq_business_id      := get_field(93, 8);  -- 93-100  Acquirers Business ID  8 UN

        l_msg.orig_trans_curr_code := get_field(113, 3);  --113-115 Original Transaction Currency Code 3 UN
        --101-112 Original Transaction Amount 12 UN
        -- if currency exponent equal to zero then cut-off last two digits from amount in accordance with VISA rules
        l_currency_exponent := com_api_currency_pkg.get_currency_exponent(i_curr_code => l_msg.orig_trans_curr_code);
        if l_currency_exponent = 0 then
            l_msg.orig_trans_amount     := get_field(101, 12 - 2);
        else
            l_msg.orig_trans_amount     := get_field(101, 12);
            if l_currency_exponent > 2 then
                l_msg.orig_trans_amount := l_msg.orig_trans_amount * power(10, l_currency_exponent - 2);
            end if;
        end if;

        l_msg.spec_chargeback_ind  := get_field(116, 1);  --116 Special Chargeback Indicator 1 AN

        l_msg.dest_curr_code     := get_field(129, 3);   -- 129-131   Destination/Source Settlement Currency Code
        if l_msg.dest_curr_code in ('000', '00', '0') then
            l_msg.dest_curr_code := null;
        end if;
        -- 117-28   Destination/Source Settlement Amount 12 UN
        -- if currency exponent equal to zero then cut-off last two digits from amount in accordance with VISA rules
        if l_msg.dest_curr_code is not null then
            l_currency_exponent  := com_api_currency_pkg.get_currency_exponent(i_curr_code => l_msg.dest_curr_code);
            if l_currency_exponent = 0 then
                l_msg.dest_amount     := get_field(117, 12 - 2);
            else
                l_msg.dest_amount     := get_field(117, 12);
                if l_currency_exponent > 2 then
                    l_msg.dest_amount := l_msg.dest_amount * power(10, l_currency_exponent - 2);
                end if;
            end if;
        end if;

        l_msg.src_sttl_amount_sign := get_field(132, 1);

    elsif get_field(3, 1) = '1' then
        --  V.I.P. Full Service Dispute Financial Status Advice, TCR 0 Record
        l_msg.trans_code           := get_field(1, 2);    -- 12 Transaction Code  2 UN
        l_msg.trans_code_qualifier := get_field(3, 1);    -- 3   Transaction Code Qualifier 1 UN
        l_msg.trans_component_seq  := get_field(4, 1);    -- 4   Transaction Component Sequence Number 1 UN
        l_msg.dest_bin             := get_field(5, 6);    -- 5-10 Destination BIN 6 AN
        l_msg.source_bin           := get_field(11, 6);   -- 11-16 Source BIN  6 AN
        l_msg.vcr_record_id        := get_field(17, 3);   -- 17-19 VCR Record Identifier 3 AN
        l_msg.dispute_status       := get_field(20, 2);   -- 20-21 Dispute Status  2 AN
        l_msg.pos_condition_code   := get_field(22, 2);   -- 22-23 POS Condition Code  2 N 
        --l_msg.reserved           := get_field(24, 1);   -- 24 field is reserved for future use 1 AN
        l_msg.orig_recipient_ind   := get_field(25, 1);   -- 25    Originator/Recipient Indicator 1 AN
        l_msg.card_number          := get_field(26, 16);  -- 26-41 Account Number  16  AN
        l_msg.card_number_ext      := get_field(42, 3);   -- 42-44 Account Number Extension 3 UN
        l_msg.acq_inst_code        := get_field(45, 11);  -- 45-55 Acquirer Institution ID Code 11 UN
        l_msg.rrn                  := get_field(56, 12);  -- 56-67 Retrieval Reference Number  12  AN
        l_msg.purchase_date        := get_field(68, 4);   -- 68-71 Purchase Date (MMDD) 4 UN

        l_msg.source_curr_code     := get_field(84, 3);   -- 84-86 Source Currency Code  3 UN
        -- 7283   Source Amount 12 UN
        -- if currency exponent equal to zero then cut-off last two digits from amount in accordance with VISA rules
        l_currency_exponent := com_api_currency_pkg.get_currency_exponent(i_curr_code => l_msg.source_curr_code);
        if l_currency_exponent = 0 then
            l_msg.source_amount     := get_field(72, 12 - 2);
        else
            l_msg.source_amount     := get_field(72, 12);
            if l_currency_exponent > 2 then
                l_msg.source_amount := l_msg.source_amount * power(10, l_currency_exponent - 2);
            end if;
        end if;

        l_msg.merchant_name        := get_field(87, 25);  -- 87-111  Merchant Name 25 AN
        l_msg.merchant_city        := get_field(112, 13); -- 112-124 Merchant City 13  AN
        l_msg.merchant_country     := com_api_country_pkg.get_country_code(
                                          i_visa_country_code => trim(get_field(125, 3))
                                      );                  -- 125-127 Merchant Country Code 3 AN
        l_msg.mcc                  := get_field(128, 4);  -- 128-131 Merchant Category Code  4 UN
        l_msg.merchant_region_code := get_field(132, 3);  -- 132-134 Merchant State/Province Code 3 AN
        l_msg.merchant_postal_code := get_field(135, 5);  -- 135-139 Merchant ZIP Code 5 UN
        l_msg.req_payment_service  := get_field(140, 1);  -- 140     Requested Payment Service 1 AN
        l_msg.auth_code            := get_field(141, 6);  -- 141-146 Authorization Code 6 AN
        l_msg.pos_entry_mode       := get_field(147, 2);  -- 147-148 POS Entry Mode  2 AN
        l_msg.central_proc_date    := get_field(149, 4);  -- 149-152 Central Processing Date (YDDD) 4 UN
        l_msg.card_acceptor_id     := get_field(153, 15); -- 153-167 Card Acceptor ID  15  AN
        l_msg.reimbursement        := get_field(168, 1);  -- 168     Reimbursement Attribute 1 AN

        --V.I.P. Full Service Dispute Financial Status Advice, TCR 1 Record
        l_data := i_tc_buffer(2);
        l_msg.network_code         := get_field(5, 4);    -- 5-8   Network Identification Code 4 UN
        l_msg.dispute_condition    := get_field(9, 3);    -- 9-11  Dispute Condition 3 ANS
        l_msg.vrol_fin_id          := get_field(12, 11);  -- 12-22 VROL Financial ID 11  ANS
        l_msg.vrol_case_number     := get_field(23, 10);  -- 23-32 VROL Case Number  10  UN
        l_msg.vrol_bundle_case_num := get_field(33, 10);  -- 33-42 VROL Bundle Case Number 10  UN
        l_msg.client_case_number   := get_field(43, 20);  -- 43-62 Client Case Number  20  ANS
        --l_msg.reserved           := get_field(63, 4);   -- 63-66 field is reserved for future use 4 AN
        l_msg.clearing_seq_number  := get_field(67, 2);   -- 67-68 Multiple Clearing Sequence Number 2 UN
        l_msg.clearing_seq_count   := get_field(69, 2);   -- 69-70 Multiple Clearing Sequence Count 2 UN
        l_msg.product_id           := get_field(71, 2);   -- 71-72 Product ID  2 AN
        l_msg.spend_qualified_ind  := get_field(73, 1);   -- 73    Spend Qualified Indicator 1 AN 
        l_msg.processing_code      := get_field(74, 2);   -- 74-75 Processing Code 2 UN
        l_msg.settlement_flag      := get_field(76, 1);   -- 76    Settlement Flag 1 UN
        l_msg.usage_code           := get_field(77, 1);   -- 77    Usage Code  1 UN
        l_msg.trans_identifier     := get_field(78, 15);  -- 78-92 Transaction Identifier  15  UN
        l_msg.acq_business_id      := get_field(93, 8);   -- 93-100  Acquirers Business ID  8 UN

        l_msg.orig_trans_curr_code := get_field(113,3);   -- 113-115 Original Transaction Currency Code 3 UN
        --101-112 Original Transaction Amount 12 UN
        -- if currency exponent equal to zero then cut-off last two digits from amount in accordance with VISA rules
        l_currency_exponent := com_api_currency_pkg.get_currency_exponent(i_curr_code => l_msg.orig_trans_curr_code);
        if l_currency_exponent = 0 then
            l_msg.orig_trans_amount     := get_field(101, 12 - 2);
        else
            l_msg.orig_trans_amount     := get_field(101, 12);
            if l_currency_exponent > 2 then
                l_msg.orig_trans_amount := l_msg.orig_trans_amount * power(10, l_currency_exponent - 2);
            end if;
        end if;
        
        l_msg.spec_chargeback_ind  := get_field(116, 1);  -- 116     Special Chargeback Indicator 1 AN
        l_msg.message_reason_code  := get_field(117, 4);  -- 117-120 Message Reason Code 4 N
    end if;
    
    init_fin_record(io_visa => l_visa);
    l_visa.status                 := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;
    l_visa.file_id                := l_msg.file_id;
    l_visa.record_number          := l_msg.record_number;
    l_visa.inst_id                := l_msg.inst_id;
    l_visa.network_id             := i_network_id;
    l_visa.card_number            := l_msg.card_number;
    l_visa.trans_code             := l_msg.trans_code;
    l_visa.trans_code_qualifier   := l_msg.trans_code_qualifier;
    l_visa.usage_code             := l_msg.usage_code;
    l_visa.oper_amount            := l_msg.orig_trans_amount;
    l_visa.oper_currency          := l_msg.orig_trans_curr_code;
    l_visa.arn                    := l_msg.acq_ref_number;
    l_visa.merchant_name          := l_msg.merchant_name;
    l_visa.merchant_city          := l_msg.merchant_city;
    l_visa.merchant_country       := l_msg.merchant_country;
    l_visa.mcc                    := l_msg.mcc;
    l_visa.merchant_postal_code   := l_msg.merchant_postal_code;

    assign_dispute(
        io_visa            => l_visa
      , i_standard_id      => i_standard_id
      , o_iss_inst_id      => l_iss_inst_id
      , o_iss_network_id   => l_iss_network_id
      , o_acq_inst_id      => l_acq_inst_id
      , o_acq_network_id   => l_acq_network_id
      , o_sttl_type        => l_sttl_type
      , o_match_status     => l_match_status
      , i_dispute_status   => l_msg.dispute_status
      , i_need_repeat      => i_need_repeat
    );
    
    l_visa.id := vis_api_fin_message_pkg.put_message(
        i_fin_rec  => l_visa
    );
    
    l_msg.id := l_visa.id;
    
    insert into vis_vcr_advice(
        id
      , file_id
      , record_number
      , inst_id
      , status
      , trans_code
      , trans_code_qualifier
      , trans_component_seq
      , dest_bin
      , source_bin
      , vcr_record_id
      , dispute_status
      , pos_condition_code
      , dispute_trans_code
      , dispute_tc_qualifier
      , orig_recipient_ind
      , card_number_ext
      , acq_ref_number
      , acq_inst_code
      , rrn
      , purchase_date
      , source_amount
      , source_curr_code
      , merchant_name
      , merchant_city
      , merchant_country
      , mcc
      , merchant_region_code
      , merchant_postal_code
      , req_payment_service
      , auth_code
      , pos_entry_mode
      , central_proc_date
      , card_acceptor_id
      , reimbursement
      , network_code
      , dispute_condition
      , vrol_fin_id
      , vrol_case_number
      , vrol_bundle_case_num
      , client_case_number
      , clearing_seq_number
      , clearing_seq_count
      , product_id
      , spend_qualified_ind
      , dsp_fin_reason_code
      , processing_code
      , settlement_flag
      , usage_code
      , trans_identifier
      , acq_business_id
      , orig_trans_amount
      , orig_trans_curr_code
      , spec_chargeback_ind
      , message_reason_code
      , dest_amount
      , dest_curr_code
      , src_sttl_amount_sign
    ) values(
        l_msg.id
      , l_msg.file_id
      , l_msg.record_number
      , l_msg.inst_id
      , l_msg.status
      , l_msg.trans_code
      , l_msg.trans_code_qualifier
      , l_msg.trans_component_seq
      , l_msg.dest_bin
      , l_msg.source_bin
      , l_msg.vcr_record_id
      , l_msg.dispute_status
      , l_msg.pos_condition_code
      , l_msg.dispute_trans_code
      , l_msg.dispute_tc_qualifier
      , l_msg.orig_recipient_ind
      , l_msg.card_number_ext
      , l_msg.acq_ref_number
      , l_msg.acq_inst_code
      , l_msg.rrn
      , l_msg.purchase_date
      , l_msg.source_amount
      , l_msg.source_curr_code
      , l_msg.merchant_name
      , l_msg.merchant_city
      , l_msg.merchant_country
      , l_msg.mcc
      , l_msg.merchant_region_code
      , l_msg.merchant_postal_code
      , l_msg.req_payment_service
      , l_msg.auth_code
      , l_msg.pos_entry_mode
      , l_msg.central_proc_date
      , l_msg.card_acceptor_id
      , l_msg.reimbursement
      , l_msg.network_code
      , l_msg.dispute_condition
      , l_msg.vrol_fin_id
      , l_msg.vrol_case_number
      , l_msg.vrol_bundle_case_num
      , l_msg.client_case_number
      , l_msg.clearing_seq_number
      , l_msg.clearing_seq_count
      , l_msg.product_id
      , l_msg.spend_qualified_ind
      , l_msg.dsp_fin_reason_code
      , l_msg.processing_code
      , l_msg.settlement_flag
      , l_msg.usage_code
      , l_msg.trans_identifier
      , l_msg.acq_business_id
      , l_msg.orig_trans_amount
      , l_msg.orig_trans_curr_code
      , l_msg.spec_chargeback_ind
      , l_msg.message_reason_code
      , l_msg.dest_amount
      , l_msg.dest_curr_code
      , l_msg.src_sttl_amount_sign
    );
    
    if nvl(i_create_operation, com_api_type_pkg.TRUE) = com_api_type_pkg.TRUE then
        vis_api_fin_message_pkg.create_operation(
            i_fin_rec            => l_visa
          , i_standard_id        => i_standard_id
          , i_status             => case when l_visa.is_invalid = com_api_type_pkg.TRUE
                                         then opr_api_const_pkg.OPERATION_STATUS_WRONG_DATA
                                         else null
                                    end 
          , i_create_disp_case   => i_create_disp_case
          , i_incom_sess_file_id => i_incom_sess_file_id
        );
    end if;

end;

procedure process_message_with_dispute(
    i_first_tc                in com_api_type_pkg.t_byte_char
  , i_vcr                     in com_api_type_pkg.t_name
  , i_tc_buffer               in vis_api_type_pkg.t_tc_buffer
  , i_network_id              in com_api_type_pkg.t_tiny_id
  , i_host_id                 in com_api_type_pkg.t_tiny_id
  , i_standard_id             in com_api_type_pkg.t_tiny_id
  , i_standard_version        in com_api_type_pkg.t_tiny_id
  , i_inst_id                 in com_api_type_pkg.t_inst_id
  , i_proc_date               in date
  , i_file_id                 in com_api_type_pkg.t_long_id
  , i_incom_sess_file_id      in com_api_type_pkg.t_long_id
  , i_batch_id                in com_api_type_pkg.t_medium_id
  , i_record_number           in com_api_type_pkg.t_short_id
  , i_proc_bin                in com_api_type_pkg.t_dict_value
  , io_amount_tab             in out nocopy t_amount_count_tab
  , i_create_operation        in com_api_type_pkg.t_boolean
  , i_validate_record         in com_api_type_pkg.t_boolean
  , i_need_repeat             in com_api_type_pkg.t_boolean
  , io_no_original_id_tab     in out nocopy vis_api_type_pkg.t_visa_fin_mes_tab
  , i_create_disp_case        in com_api_type_pkg.t_boolean
  , i_register_loading_event  in com_api_type_pkg.t_boolean
) is
begin
    savepoint sp_message_with_dispute;

    -- process draft transactions
    if i_first_tc in (vis_api_const_pkg.TC_SALES
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
    then
        process_draft(
            i_tc_buffer              => i_tc_buffer
          , i_network_id             => i_network_id
          , i_host_id                => i_host_id
          , i_standard_id            => i_standard_id
          , i_inst_id                => i_inst_id
          , i_proc_date              => i_proc_date
          , i_file_id                => i_file_id
          , i_incom_sess_file_id     => i_incom_sess_file_id
          , i_batch_id               => i_batch_id
          , i_record_number          => i_record_number
          , i_proc_bin               => i_proc_bin
          , io_amount_tab            => io_amount_tab
          , i_create_operation       => i_create_operation
          , i_validate_record        => i_validate_record
          , i_need_repeat            => i_need_repeat
          , io_no_original_id_tab    => io_no_original_id_tab
          , i_create_disp_case       => i_create_disp_case
          , i_register_loading_event => i_register_loading_event
        );

    -- process retrieval requests
    elsif i_first_tc in (vis_api_const_pkg.TC_REQUEST_FOR_PHOTOCOPY) then
        process_retrieval_request(
            i_tc_buffer          => i_tc_buffer
          , i_network_id         => i_network_id
          , i_host_id            => i_host_id
          , i_standard_id        => i_standard_id
          , i_inst_id            => i_inst_id
          , i_file_id            => i_file_id
          , i_incom_sess_file_id => i_incom_sess_file_id
          , i_batch_id           => i_batch_id
          , i_record_number      => i_record_number
          , i_create_operation   => i_create_operation
          , i_validate_record    => i_validate_record
          , i_need_repeat        => i_need_repeat
          , i_create_disp_case   => i_create_disp_case
        );

    -- process TC 33 messages of Visa BASE II VCR Status Advices and Visa V.I.P. Full Service Dispute Financial Status Advice
    elsif i_first_tc in (vis_api_const_pkg.TC_MULTIPURPOSE_MESSAGE)
          and i_vcr = 'VCR'
    then
        process_vcr_advice(
            i_tc_buffer          => i_tc_buffer
          , i_file_id            => i_file_id
          , i_record_number      => i_record_number
          , i_inst_id            => i_inst_id
          , i_network_id         => i_network_id
          , i_standard_id        => i_standard_id
          , i_standard_version   => i_standard_version
          , i_create_operation   => i_create_operation
          , i_incom_sess_file_id => i_incom_sess_file_id
          , i_need_repeat        => i_need_repeat
          , i_create_disp_case   => i_create_disp_case
        );

    end if;

exception
    when com_api_error_pkg.e_need_original_record then
        rollback to savepoint sp_message_with_dispute;

        -- Save unprocessed record into buffer.
        g_no_dispute_id_tab(g_no_dispute_id_tab.count + 1).i_first_tc       := i_first_tc;
        g_no_dispute_id_tab(g_no_dispute_id_tab.count).i_vcr                := i_vcr;
        g_no_dispute_id_tab(g_no_dispute_id_tab.count).i_tc_buffer          := i_tc_buffer;
        g_no_dispute_id_tab(g_no_dispute_id_tab.count).i_network_id         := i_network_id;
        g_no_dispute_id_tab(g_no_dispute_id_tab.count).i_host_id            := i_host_id;

        g_no_dispute_id_tab(g_no_dispute_id_tab.count).i_standard_id        := i_standard_id;
        g_no_dispute_id_tab(g_no_dispute_id_tab.count).i_standard_version   := i_standard_version;
        g_no_dispute_id_tab(g_no_dispute_id_tab.count).i_inst_id            := i_inst_id;
        g_no_dispute_id_tab(g_no_dispute_id_tab.count).i_proc_date          := i_proc_date;

        g_no_dispute_id_tab(g_no_dispute_id_tab.count).i_file_id            := i_file_id;
        g_no_dispute_id_tab(g_no_dispute_id_tab.count).i_incom_sess_file_id := i_incom_sess_file_id;
        g_no_dispute_id_tab(g_no_dispute_id_tab.count).i_batch_id           := i_batch_id;
        g_no_dispute_id_tab(g_no_dispute_id_tab.count).i_record_number      := i_record_number;
        g_no_dispute_id_tab(g_no_dispute_id_tab.count).i_proc_bin           := i_proc_bin;
        g_no_dispute_id_tab(g_no_dispute_id_tab.count).i_create_operation   := i_create_operation;

end process_message_with_dispute;

-- Processing of VISA Incoming Clearing Files
procedure process (
    i_network_id              in com_api_type_pkg.t_tiny_id
  , i_test_option             in varchar2
  , i_dst_inst_id             in com_api_type_pkg.t_inst_id
  , i_create_operation        in com_api_type_pkg.t_boolean
  , i_host_inst_id            in com_api_type_pkg.t_inst_id      default null
  , i_validate_records        in com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
  , i_charset                 in com_api_type_pkg.t_oracle_name  default null
  , i_create_disp_case        in com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
  , i_register_loading_event  in com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
) is
    LOG_PREFIX       constant com_api_type_pkg.t_name    := lower($$PLSQL_UNIT) || '.process: ';
    l_tc                      varchar2(2);
    l_first_tc                varchar2(2);
    l_tcr                     varchar2(1);
    l_first_tcr               varchar2(1);
    l_vcr                     varchar2(3);
    l_tc_buffer               vis_api_type_pkg.t_tc_buffer;
    l_visa_file               vis_api_type_pkg.t_visa_file_rec;
    l_host_id                 com_api_type_pkg.t_tiny_id;
    l_standard_id             com_api_type_pkg.t_tiny_id;
    l_batch_id                com_api_type_pkg.t_medium_id;
    l_record_number           com_api_type_pkg.t_long_id := 0;
    l_record_count            com_api_type_pkg.t_long_id := 0;
    l_errors_count            com_api_type_pkg.t_long_id := 0;
    l_amount_tab              t_amount_count_tab;
    l_create_operation        com_api_type_pkg.t_boolean;
    l_create_disp_case        com_api_type_pkg.t_boolean;
    l_register_loading_event  com_api_type_pkg.t_boolean;
    l_no_original_id_tab      vis_api_type_pkg.t_visa_fin_mes_tab;
    l_operation_id_tab        com_api_type_pkg.t_number_tab;
    l_original_id_tab         com_api_type_pkg.t_number_tab;
    l_standard_version        com_api_type_pkg.t_tiny_id;

    cursor cu_records_count is
        select count(1)
          from prc_file_raw_data a
             , prc_session_file b
         where b.session_id      = prc_api_session_pkg.get_session_id
           and a.session_file_id = b.id;
begin
    vis_api_reject_pkg.g_process_run_date := sysdate;

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'i_network_id [' || i_network_id
                             || '], i_test_option [' || i_test_option
                             || '], i_dst_inst_id [' || i_dst_inst_id
                             || '], i_create_operation [' || i_create_operation
                             || '], i_host_inst_id [' || i_host_inst_id || ']'
    );
    prc_api_stat_pkg.log_start;

    open cu_records_count;
    fetch cu_records_count into l_record_count;
    close cu_records_count;

    prc_api_stat_pkg.log_estimation (
        i_estimated_count     => l_record_count
    );

    -- get network communication standard
    l_host_id     := net_api_network_pkg.get_default_host(
                         i_network_id   => i_network_id
                       , i_host_inst_id => i_host_inst_id
                     );
    l_standard_id := net_api_network_pkg.get_offline_standard(
                         i_host_id      => l_host_id
                     );
    
    l_standard_version := 
        cmn_api_standard_pkg.get_current_version(
            i_standard_id  => l_standard_id 
          , i_entity_type  => net_api_const_pkg.ENTITY_TYPE_HOST
          , i_object_id    => l_host_id
          , i_eff_date     => com_api_sttl_day_pkg.get_sysdate()
        );

    trc_log_pkg.debug(
        i_text => 'l_host_id [' || l_host_id || '], l_standard_id [' || l_standard_id || '], l_standard_version [ ' || l_standard_version || ' ]'
    );

    if l_standard_id != vis_api_const_pkg.VISA_BASEII_STANDARD then
        null;
    end if;

    l_record_count := 0;
    g_errors_count := 0;
    l_amount_tab.delete;
    g_no_dispute_id_tab.delete;
    l_no_original_id_tab.delete;
    l_operation_id_tab.delete;
    l_original_id_tab.delete;

    l_create_operation       := nvl(i_create_operation,       com_api_type_pkg.TRUE);
    l_create_disp_case       := nvl(i_create_disp_case,       com_api_type_pkg.FALSE);
    l_register_loading_event := nvl(i_register_loading_event, com_api_type_pkg.FALSE);

    for p in (
        select id session_file_id
             , record_count
          from prc_session_file
         where session_id = prc_api_session_pkg.get_session_id
         order by id
    ) loop
        trc_log_pkg.debug(
            i_text => 'Processing session_file_id [' || p.session_file_id
                   || '], record_count [' || p.record_count || ']'
        );
        l_errors_count := 0;
        begin
            savepoint sp_visa_incoming_file;

            l_record_number := 1;
            l_tc_buffer.delete;

            -- The deferred operations is processed after each file due file status
            g_no_dispute_id_tab.delete;
            l_no_original_id_tab.delete;

            for r in (
                select record_number
                     , raw_data
                     , substr(next_data, 1, 2) next_tc
                     , substr(next_data, 4, 1) next_tcr
                     , count(*) over() cnt
                     , row_number() over(order by record_number) rn
                     , row_number() over(order by record_number desc) rn_desc
                from (
                      select record_number
                           , raw_data
                           , lead(raw_data) over (order by record_number) next_data
                        from prc_file_raw_data
                       where session_file_id = p.session_file_id
                     )
                order by record_number
            ) loop
                --trc_log_pkg.debug(
                --    i_text => 'record_number [' || r.record_number
                --           || '], next_tc [' || r.next_tc || '], next_tcr [' || r.next_tcr
                --           || '], raw_data [' || r.raw_data || ']'
                --);
                g_error_flag := com_api_type_pkg.FALSE;
                l_tc_buffer(l_tc_buffer.count+1) := r.raw_data;
                l_tc  := substr(r.raw_data, 1, 2);
                l_tcr := substr(r.raw_data, 4, 1);

                if l_batch_id is null and l_tc != vis_api_const_pkg.TC_FILE_TRAILER then
                    l_batch_id := vis_batch_seq.nextval;
                end if;

                if l_visa_file.id is null and l_tc != vis_api_const_pkg.TC_FILE_HEADER then
                    process_without_file_header(
                        i_record_number    => r.cnt
                      , i_network_id       => i_network_id
                      , i_host_id          => l_host_id
                      , i_standard_id      => l_standard_id
                      , i_dst_inst_id      => i_dst_inst_id
                      , i_session_file_id  => p.session_file_id
                      , o_visa_file        => l_visa_file
                    );
                end if;

                -- if next TC record started, then process readed TC records
                if r.next_tc is null or l_tc != r.next_tc or (r.next_tcr < l_tcr or r.next_tcr = l_tcr) then
                    l_record_number := r.record_number;

                    l_first_tc  := substr(l_tc_buffer(1), 1, 2);
                    l_first_tcr := substr(l_tc_buffer(1), 4, 1);
                    -- process currency convertional rate updates

                    --trc_log_pkg.debug('l_first_tc [' || l_first_tc || '], l_first_tcr [' || l_first_tcr || ']');

                    -- process file header record
                    if l_first_tc = vis_api_const_pkg.TC_FILE_HEADER then
                        process_file_header(
                            i_header_data      => l_tc_buffer(1)
                          , i_network_id       => i_network_id
                          , i_host_id          => l_host_id
                          , i_standard_id      => l_standard_id
                          , i_test_option      => i_test_option
                          , i_dst_inst_id      => i_dst_inst_id
                          , i_session_file_id  => p.session_file_id
                          , o_visa_file        => l_visa_file
                          , i_validate_record  => i_validate_records
                        );

                    elsif l_first_tc = vis_api_const_pkg.TC_BATCH_TRAILER then
                        process_batch_trailer(
                            i_tc_buffer => l_tc_buffer
                          , i_file_id   => l_visa_file.id
                          , i_batch_id  => l_batch_id
                          , i_validate_record  => i_validate_records
                        );
                        l_batch_id := null;

                    -- process currency convertional rate updates
                    elsif l_first_tc = vis_api_const_pkg.TC_FILE_TRAILER then
                        process_file_trailer(
                            i_tc_buffer         => l_tc_buffer
                          , io_visa_file        => l_visa_file
                          , i_validate_record   => i_validate_records
                        );

                    -- process returned transactions
                    elsif l_first_tc in (vis_api_const_pkg.TC_RETURNED_CREDIT
                                       , vis_api_const_pkg.TC_RETURNED_DEBIT
                                       , vis_api_const_pkg.TC_RETURNED_NONFINANCIAL)
                    then
                        process_returned(
                            i_tc_buffer       => l_tc_buffer
                          , i_record_number   => l_record_number
                          , i_file_id         => l_visa_file.id
                          , i_batch_id        => l_batch_id
                          , i_validate_record => i_validate_records
                        );

                    -- process rejected transactions (TC 44 Collection Batch Acknowledgment Transactions)
                    elsif l_first_tc = vis_api_const_pkg.TC_REJECTED
                    then
                        process_rejected(
                            i_tc_buffer       => l_tc_buffer
                          , i_record_number   => l_record_number
                          , i_validate_record => i_validate_records
                        );

                    -- process draft transactions
                    elsif l_first_tc in (vis_api_const_pkg.TC_SALES
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
                    then
                        process_message_with_dispute(
                            i_first_tc               => l_first_tc
                          , i_vcr                    => null
                          , i_tc_buffer              => l_tc_buffer
                          , i_network_id             => i_network_id
                          , i_host_id                => l_host_id
                          , i_standard_id            => l_standard_id
                          , i_standard_version       => l_standard_version
                          , i_inst_id                => l_visa_file.inst_id
                          , i_proc_date              => l_visa_file.proc_date
                          , i_file_id                => l_visa_file.id
                          , i_incom_sess_file_id     => p.session_file_id
                          , i_batch_id               => l_batch_id
                          , i_record_number          => l_record_number
                          , i_proc_bin               => l_visa_file.proc_bin
                          , io_amount_tab            => l_amount_tab
                          , i_create_operation       => l_create_operation
                          , i_validate_record        => i_validate_records
                          , i_need_repeat            => com_api_type_pkg.TRUE
                          , io_no_original_id_tab    => l_no_original_id_tab
                          , i_create_disp_case       => l_create_disp_case
                          , i_register_loading_event => l_register_loading_event
                        );

                    -- process money transfer transactions
                    elsif l_first_tc in (vis_api_const_pkg.TC_MONEY_TRANSFER
                                       , vis_api_const_pkg.TC_MONEY_TRANSFER2)
                    then
                        process_money_transfer(
                            i_tc_buffer        => l_tc_buffer
                          , i_file_id          => l_visa_file.id
                          , i_record_number    => l_record_number
                          , i_inst_id          => l_visa_file.inst_id
                          , i_network_id       => i_network_id
                          , i_validate_record  => i_validate_records
                        );

                    -- process fee collections and funds diburstment
                    elsif l_first_tc in (vis_api_const_pkg.TC_FEE_COLLECTION
                                       , vis_api_const_pkg.TC_FUNDS_DISBURSEMENT)
                    then
                        process_fee_funds(
                            i_tc_buffer          => l_tc_buffer
                          , i_network_id         => i_network_id
                          , i_standard_id        => l_standard_id
                          , i_inst_id            => l_visa_file.inst_id
                          , i_file_id            => l_visa_file.id
                          , i_incom_sess_file_id => p.session_file_id
                          , i_batch_id           => l_batch_id
                          , i_record_number      => l_record_number
                          , i_validate_record    => i_validate_records
                          , i_create_operation   => i_create_operation
                          , i_create_disp_case   => l_create_disp_case
                        );

                    -- process retrieval requests
                    elsif l_first_tc in (vis_api_const_pkg.TC_REQUEST_FOR_PHOTOCOPY) then
                        process_message_with_dispute(
                            i_first_tc               => l_first_tc
                          , i_vcr                    => null
                          , i_tc_buffer              => l_tc_buffer
                          , i_network_id             => i_network_id
                          , i_host_id                => l_host_id
                          , i_standard_id            => l_standard_id
                          , i_standard_version       => null
                          , i_inst_id                => l_visa_file.inst_id
                          , i_proc_date              => null
                          , i_file_id                => l_visa_file.id
                          , i_incom_sess_file_id     => p.session_file_id
                          , i_batch_id               => l_batch_id
                          , i_record_number          => l_record_number
                          , i_proc_bin               => null
                          , io_amount_tab            => l_amount_tab
                          , i_create_operation       => l_create_operation
                          , i_validate_record        => i_validate_records
                          , i_need_repeat            => com_api_type_pkg.TRUE
                          , io_no_original_id_tab    => l_no_original_id_tab
                          , i_create_disp_case       => l_create_disp_case
                          , i_register_loading_event => com_api_type_pkg.FALSE
                        );

                    -- process currency convertional rate updates
                    elsif l_first_tc in (vis_api_const_pkg.TC_CURRENCY_RATE_UPDATE) then
                        process_currency_rate (
                            i_tc_buffer        => l_tc_buffer
                          , i_file_id          => l_visa_file.id
                          , i_proc_date        => l_visa_file.proc_date
                          , i_inst_id          => l_visa_file.inst_id
                        );

                    -- process general delivery report
                    elsif l_first_tc in (vis_api_const_pkg.TC_GENERAL_DELIVERY_REPORT) then
                        process_delivery_report(
                            i_tc_buffer        => l_tc_buffer
                          , i_file_id          => l_visa_file.id
                          , i_record_number    => l_record_number
                          , i_inst_id          => l_visa_file.inst_id
                          , i_validate_record  => i_validate_records
                        );

                    -- process member settlement data
                    elsif l_first_tc in (vis_api_const_pkg.TC_MEMBER_SETTLEMENT_DATA) then
                        process_settlement_data(
                            i_tc_buffer      => l_tc_buffer
                          , i_file_id        => l_visa_file.id
                          , i_record_number  => l_record_number
                          , i_inst_id        => l_visa_file.inst_id
                          , i_host_id        => l_host_id
                          , i_standard_id    => l_standard_id
                          , i_register_event => l_register_loading_event
                        );

                    -- process multipurpose messages
                    elsif l_first_tc in (vis_api_const_pkg.TC_MULTIPURPOSE_MESSAGE) then
                        l_vcr                  := substr(l_tc_buffer(1), 17, 3);
                        
                        if l_vcr = 'VCR' then 
                            -- process TC 33 messages of Visa BASE II VCR Status Advices and Visa V.I.P. Full Service Dispute Financial Status Advice
                            process_message_with_dispute(
                                i_first_tc               => l_first_tc
                              , i_vcr                    => l_vcr
                              , i_tc_buffer              => l_tc_buffer
                              , i_network_id             => i_network_id
                              , i_host_id                => null
                              , i_standard_id            => l_standard_id
                              , i_standard_version       => l_standard_version
                              , i_inst_id                => l_visa_file.inst_id
                              , i_proc_date              => null
                              , i_file_id                => l_visa_file.id
                              , i_incom_sess_file_id     => p.session_file_id
                              , i_batch_id               => null
                              , i_record_number          => l_record_number
                              , i_proc_bin               => null
                              , io_amount_tab            => l_amount_tab
                              , i_create_operation       => l_create_operation
                              , i_validate_record        => null
                              , i_need_repeat            => com_api_type_pkg.TRUE
                              , io_no_original_id_tab    => l_no_original_id_tab
                              , i_create_disp_case       => l_create_disp_case
                              , i_register_loading_event => com_api_type_pkg.FALSE
                            );

                        else
                            process_multipurpose(
                                i_tc_buffer        => l_tc_buffer
                              , i_file_id          => l_visa_file.id
                              , i_record_number    => l_record_number
                              , i_inst_id          => l_visa_file.inst_id
                              , i_validate_record  => i_validate_records
                              , i_network_id       => i_network_id
                              , i_host_id          => l_host_id
                              , i_standard_id      => l_standard_id
                            );
                        end if;

                    -- process DCC currencies
                    elsif l_first_tc = vis_api_const_pkg.TC_MULTIPURPOSE_MESSAGE then
                        process_multipurpose_message(l_tc_buffer);

                    end if;

                    -- cleanup buffer before loading next TC record(s)
                    l_tc_buffer.delete;
                end if;

                if g_error_flag = com_api_type_pkg.TRUE then
                    l_errors_count := l_errors_count + 1;
                end if;
                if mod(r.rn, 100) = 0 then
                    prc_api_stat_pkg.log_current(
                        i_current_count  => l_record_count + r.rn
                      , i_excepted_count => g_errors_count + l_errors_count
                    );
                end if;

                if r.rn_desc = 1 then
                    g_errors_count := g_errors_count + l_errors_count;
                    l_errors_count := 0;
                    l_record_count := l_record_count + r.cnt;

                    prc_api_stat_pkg.log_current(
                        i_current_count  => l_record_count
                      , i_excepted_count => g_errors_count
                    );
                end if;
            end loop;

            -- It is case when original dispute record is later than dispute record in the same file.
            if g_no_dispute_id_tab.count > 0 then
                for i in 1 .. g_no_dispute_id_tab.count loop
                    -- process message types with dispute feature
                    process_message_with_dispute(
                        i_first_tc               => g_no_dispute_id_tab(i).i_first_tc
                      , i_vcr                    => g_no_dispute_id_tab(i).i_vcr
                      , i_tc_buffer              => g_no_dispute_id_tab(i).i_tc_buffer
                      , i_network_id             => g_no_dispute_id_tab(i).i_network_id
                      , i_host_id                => g_no_dispute_id_tab(i).i_host_id
                      , i_standard_id            => g_no_dispute_id_tab(i).i_standard_id
                      , i_standard_version       => g_no_dispute_id_tab(i).i_standard_version
                      , i_inst_id                => g_no_dispute_id_tab(i).i_inst_id
                      , i_proc_date              => g_no_dispute_id_tab(i).i_proc_date
                      , i_file_id                => g_no_dispute_id_tab(i).i_file_id
                      , i_incom_sess_file_id     => g_no_dispute_id_tab(i).i_incom_sess_file_id
                      , i_batch_id               => g_no_dispute_id_tab(i).i_batch_id
                      , i_record_number          => g_no_dispute_id_tab(i).i_record_number
                      , i_proc_bin               => g_no_dispute_id_tab(i).i_proc_bin
                      , io_amount_tab            => l_amount_tab
                      , i_create_operation       => g_no_dispute_id_tab(i).i_create_operation
                      , i_validate_record        => i_validate_records
                      , i_need_repeat            => com_api_const_pkg.FALSE
                      , io_no_original_id_tab    => l_no_original_id_tab
                      , i_create_disp_case       => l_create_disp_case
                      , i_register_loading_event => l_register_loading_event
                    );
                end loop;
            end if;

            -- It is case when original record is later than reversal record in the same file.
            -- Post-processing for "original_id" is placed after post-processing for "dispute_id".
            if l_no_original_id_tab.count > 0 then
                for i in 1 .. l_no_original_id_tab.count loop
                    l_operation_id_tab(l_operation_id_tab.count + 1) := l_no_original_id_tab(i).id;
                    l_original_id_tab(l_original_id_tab.count + 1)   := vis_api_fin_message_pkg.get_original_id(
                                                                            i_fin_rec => l_no_original_id_tab(i)
                                                                          , i_fee_rec => null
                                                                        );
                end loop;

                forall i in 1 .. l_operation_id_tab.count
                    update opr_operation
                       set original_id = l_original_id_tab(i)
                     where id          = l_operation_id_tab(i);
            end if;

            prc_api_file_pkg.close_file(
                i_sess_file_id          => p.session_file_id
              , i_status                => prc_api_const_pkg.FILE_STATUS_ACCEPTED
            );
        exception
            when com_api_error_pkg.e_application_error then
                rollback to sp_visa_incoming_file;

                g_errors_count := g_errors_count + p.record_count;
                l_errors_count := 0;
                l_record_count := l_record_count + p.record_count;

                prc_api_stat_pkg.log_current(
                    i_current_count  => l_record_count
                  , i_excepted_count => g_errors_count
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
      , i_excepted_total    => g_errors_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    info_amount (
        i_amount_tab  => l_amount_tab
    );

    trc_log_pkg.debug(LOG_PREFIX || 'END');
exception
    when others then
        if cu_records_count%isopen then
            close cu_records_count;
        end if;

        prc_api_stat_pkg.log_end(
            i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );
        l_amount_tab.delete;
        g_no_dispute_id_tab.delete;
        l_no_original_id_tab.delete;
        l_operation_id_tab.delete;
        l_original_id_tab.delete;

        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        else
            -- Log useful local variables, and therefore log call stack for exception point
            trc_log_pkg.debug(
                i_text       => LOG_PREFIX || 'FAILED with l_record_number [#3], l_tc [#1], l_tcr [#2]'
              , i_env_param1 => l_tc
              , i_env_param2 => l_tcr
              , i_env_param3 => l_record_number
            );
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end process;

-- Processing of VISA Rejected Item Files
procedure process_rejected_item_file (
    i_network_id            in com_api_type_pkg.t_tiny_id
    , i_host_inst_id        in com_api_type_pkg.t_inst_id default null
    , i_validate_records    in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
) is
    LOG_PREFIX        constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_rejected_item_file: ';
    l_host_id                  com_api_type_pkg.t_tiny_id;
    l_standard_id              com_api_type_pkg.t_tiny_id;
    l_record_count             com_api_type_pkg.t_long_id := 0;
    l_errors_count            com_api_type_pkg.t_long_id := 0;

    cursor cu_records_count is
        select count(1)
          from prc_file_raw_data a
             , prc_session_file b
         where b.session_id      = prc_api_session_pkg.get_session_id
           and a.session_file_id = b.id;
begin
    vis_api_reject_pkg.g_process_run_date := sysdate;

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'i_network_id [' || i_network_id
                             || '], i_host_inst_id [' || i_host_inst_id
                             || ']'
    );
    prc_api_stat_pkg.log_start;

    open cu_records_count;
    fetch cu_records_count into l_record_count;
    close cu_records_count;

    prc_api_stat_pkg.log_estimation (
        i_estimated_count => l_record_count
    );

    -- get network communication standard
    l_host_id     := net_api_network_pkg.get_default_host(i_network_id => i_network_id, i_host_inst_id => i_host_inst_id);
    l_standard_id := net_api_network_pkg.get_offline_standard(i_host_id => l_host_id);
    trc_log_pkg.debug(
        i_text => 'l_host_id [' || l_host_id || '], l_standard_id [' || l_standard_id || ']'
    );

    --if l_standard_id != vis_api_const_pkg.VISA_BASEII_STANDARD then
    --    null;
    --end if;

    l_record_count := 0;
    g_errors_count := 0;

    -- loop by files loaded in current session
    for p in (
        select id session_file_id
             , nvl(record_count, 0) as record_count
          from prc_session_file
         where session_id = prc_api_session_pkg.get_session_id
         order by id
    ) loop
        trc_log_pkg.debug(
            i_text => 'Processing session_file_id [' || p.session_file_id
                   || '], record_count [' || p.record_count || ']'
        );
        l_errors_count := 0;
        begin
            savepoint sp_visa_incoming_file;

            -- loop by records in current file
            for r in (
                select record_number
                     , raw_data
                     , count(*) over() cnt
                     , row_number() over(order by record_number) rn
                     , row_number() over(order by record_number desc) rn_desc
                  from prc_file_raw_data
                 where session_file_id = p.session_file_id
                 order by record_number asc
            ) loop
                --trc_log_pkg.debug(
                --    i_text => ' session_file_id [' || p.session_file_id || ']' ||
                --              ', record_number [' || r.record_number || ']' ||
                --              ', raw_data [' || r.raw_data || ']'
                --);
                g_error_flag := com_api_type_pkg.FALSE;

                -- process VISA Rejected Item File record
                process_rejected_item(
                    i_tc_buffer       => r.raw_data
                  , i_record_number   => r.record_number
                  , i_validate_record => i_validate_records
                );

                if g_error_flag = com_api_type_pkg.TRUE then
                    l_errors_count := l_errors_count + 1;
                end if;

                if mod(r.rn, 100) = 0 then
                    prc_api_stat_pkg.log_current(
                        i_current_count  => l_record_count + r.rn
                      , i_excepted_count => g_errors_count + l_errors_count
                    );
                end if;

                if r.rn_desc = 1 then
                    g_errors_count := g_errors_count + l_errors_count;
                    l_errors_count := 0;
                    l_record_count := l_record_count + r.cnt;

                    prc_api_stat_pkg.log_current(
                        i_current_count  => l_record_count
                      , i_excepted_count => g_errors_count
                    );
                end if;
            end loop;

            prc_api_file_pkg.close_file(
                i_sess_file_id => p.session_file_id
              , i_status       => prc_api_const_pkg.FILE_STATUS_ACCEPTED
            );
        exception
            when com_api_error_pkg.e_application_error then
                rollback to sp_visa_incoming_file;

                g_errors_count := g_errors_count + p.record_count;
                l_errors_count := 0;
                l_record_count := l_record_count + p.record_count;

                prc_api_stat_pkg.log_current(
                    i_current_count  => l_record_count
                  , i_excepted_count => g_errors_count
                );

                prc_api_file_pkg.close_file(
                    i_sess_file_id => p.session_file_id
                  , i_status       => prc_api_const_pkg.FILE_STATUS_REJECTED
                );

                raise;
        end;
    end loop;

    prc_api_stat_pkg.log_end(
        i_processed_total => l_record_count
      , i_excepted_total  => g_errors_count
      , i_result_code     => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug(LOG_PREFIX || 'END');
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
        else
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end process_rejected_item_file;

procedure vss_report_uploading(
    i_network_id      in       com_api_type_pkg.t_tiny_id
  , i_inst_id         in       com_api_type_pkg.t_inst_id
  , i_register_event  in       com_api_type_pkg.t_boolean
) is
    LOG_PREFIX        constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.vss_report_uploading ';
    l_host_id                  com_api_type_pkg.t_tiny_id;
    l_standard_id              com_api_type_pkg.t_tiny_id;
    l_record_count             com_api_type_pkg.t_long_id;
    l_errors_count             com_api_type_pkg.t_long_id := 0;
    l_tc_buffer                vis_api_type_pkg.t_tc_buffer;
begin
    -- get network communication standard
    l_host_id := 
        net_api_network_pkg.get_default_host(
            i_network_id   => i_network_id
          , i_host_inst_id => i_inst_id
        );
    l_standard_id := net_api_network_pkg.get_offline_standard(i_host_id => l_host_id);
 
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'i_register_event [' || i_register_event
                             || ']'
    );
    prc_api_stat_pkg.log_start;

    for rec in (
        select d.session_file_id
             , d.raw_data
             , d.record_number
             , record_count
             , count(1) over() cnt
             , row_number() over(order by d.session_file_id, d.record_number) rn
             , row_number() over(order by d.session_file_id desc, d.record_number desc) rn_desc
          from prc_session_file f
             , prc_file_raw_data d
         where f.session_id      = prc_api_session_pkg.get_session_id
           and d.session_file_id = f.id
      order by d.session_file_id
             , d.record_number
    ) loop
        if rec.rn = 1 then
            l_record_count := rec.cnt;

            prc_api_stat_pkg.log_estimation (
                i_estimated_count => l_record_count
            );

        end if;

        l_errors_count := 0;
        begin
            l_tc_buffer.delete;
            l_tc_buffer(1) := rec.raw_data;

--            trc_log_pkg.debug('process line '||rec.rn||': '|| rec.raw_data);
            process_settlement_data(
                i_tc_buffer      => l_tc_buffer
              , i_file_id        => rec.session_file_id
              , i_record_number  => rec.record_number
              , i_inst_id        => i_inst_id
              , i_host_id        => l_host_id
              , i_standard_id    => l_standard_id
              , i_register_event => i_register_event
            );
            
        exception
            when com_api_error_pkg.e_application_error then
                l_errors_count := l_errors_count + 1;
                trc_log_pkg.debug(LOG_PREFIX || sqlerrm);
        end;
           
        if mod(rec.rn, 10) = 0 or rec.rn_desc = 1 then
            prc_api_stat_pkg.log_current(
                i_current_count  => rec.rn
              , i_excepted_count => l_errors_count
            );
         end if;
    end loop;

    if l_record_count is null then
        prc_api_stat_pkg.log_estimation (
            i_estimated_count => 0
        );
    end if;

    prc_api_stat_pkg.log_end(
        i_processed_total => nvl(l_record_count, 0)
      , i_excepted_total  => l_errors_count
      , i_result_code     => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug(LOG_PREFIX || 'END');
exception
    when others then
        prc_api_stat_pkg.log_end(
            i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end;

end vis_prc_incoming_pkg;
/
