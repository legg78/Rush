create or replace package body cst_ow_pkg is

c_CRLF              constant com_api_type_pkg.t_name := chr(13) || chr(10);

procedure upload_m_batch_file(
    i_inst_id           in com_api_type_pkg.t_inst_id
  , i_masking_card      in com_api_type_pkg.t_boolean
) is
    l_file_name             com_api_type_pkg.t_attr_name;
    l_session_file_id       com_api_type_pkg.t_long_id;
    l_params                com_api_type_pkg.t_param_tab;
    l_line                  com_api_type_pkg.t_text;
    l_daily_file_number     com_api_type_pkg.t_tiny_id;
    l_line_number           com_api_type_pkg.t_long_id;
    l_event_object_id       com_api_type_pkg.t_number_tab;
    l_bulk_limit            pls_integer := 10000;
    l_inst_ow               com_api_type_pkg.t_inst_id;
    l_sttl_curr             com_api_type_pkg.t_curr_code;
    l_sttl_amount           com_api_type_pkg.t_money;
    l_specific_merch_num    com_api_type_pkg.t_merchant_number;
    l_row_total_count      number := 0;
    l_max_oper_id           com_api_type_pkg.t_long_id;
    l_min_oper_id           com_api_type_pkg.t_long_id;
    l_max_event_id          com_api_type_pkg.t_long_id;
    l_min_event_id          com_api_type_pkg.t_long_id;

    cursor l_events is
        select t.event_id from cst_m_fil_row_tmp t;

    procedure insert_tmp_row_data(
        i_inst_id  in com_api_type_pkg.t_inst_id
    ) is
        cursor tmp_row_data(
            i_inst_id  in com_api_type_pkg.t_inst_id
        ) is
            select /*+ leading(eo oo) */
                   substr(oo.id, 7) as transaction_number
                 , to_char(oo.id) as reg_number_doc
                 , oo.terminal_number as contract_number
                 , decode(i_masking_card,'0',oc.card_number, iss_api_card_pkg.get_card_mask(oc.card_number)) as card_number
                 , to_char(oo.host_date, 'YYYYMMDD') as trans_date
                 , to_char(oo.host_date, 'HH24MISS') as trans_time
                 , decode(e.amount, 0, ' ',
                                    decode(e.balance_impact, -1, 'D', 1, 'C', ' ')) as transaction_direction
                 , oo.oper_currency
                 , decode(e.amount, 0, ' ', get_currency(i_cur => a.currency, i_inst_id => i_inst_id)) as account_currency
                 , oo.oper_amount
                 , decode(e.amount, 0, ' ', e.amount) as account_amount
                 , case when oo.oper_surcharge_amount is not null then 'C'
                        else ''
                   end as fee_direction
                 , oo.oper_surcharge_amount as fee_amount
                 , 'P' as account_type
                 , to_char(opi.card_expir_date, 'yymm') expir_date
                 , case when oo.oper_type = opr_api_const_pkg.OPERATION_TYPE_SRV_PRV_PAYMENT
                        then nvl(get_payment_purpose(atv_p.tag_value), 'PAYMENT') || '_' || oo.terminal_number
                        else substr(oo.merchant_name, 1, 30)
                   end as trans_detail
                 , '' auth_reg_number
                 , opi.auth_code as auth_code
                 , case when oo.oper_type = opr_api_const_pkg.MESSAGE_TYPE_AUTHORIZATION then round(decode(e.amount, 0, null, e.amount/100))
                        when oo.oper_type = opr_api_const_pkg.MESSAGE_TYPE_COMPLETION then null
                   end as auth_amount
                 , to_char(e.sttl_date,'YYYYMMDD') as sttl_date
                 , oo.mcc as mcc
                 , get_contra_entry_channel_ow(
                       i_inst_id    => l_inst_ow
                     , i_sttl_type  => oo.sttl_type
                     , i_oper_id    => oo.id
                     , i_network_id => opa.network_id
                   ) as contra_entry_channel
                 , '' as arn
                 , oo.oper_currency as recon_curr
                 , oo.oper_request_amount as request_amount
                 , substr(to_char(oo.id), length(to_char(oo.id)) - 9) as iss_reference_number
                 , to_char(e.posting_date,'YYYYMMDD') as value_date
                 , to_char(e.posting_date,'YYYYMMDD') as gl_date
                 , (select /*+ index(c ATM_COLLECTION_TERM_ID_NDX)*/
                           max(collection_number)
                      from atm_collection c
                     where c.terminal_id = opa.terminal_id
                       and c.start_date <= oo.oper_date
                   ) as collection_number
                 , case when oo.terminal_type in (acq_api_const_pkg.TERMINAL_TYPE_POS
                                                , acq_api_const_pkg.TERMINAL_TYPE_EPOS
                                                , acq_api_const_pkg.TERMINAL_TYPE_MOBILE_POS) then 'PO  '
                        when oo.terminal_type in (acq_api_const_pkg.TERMINAL_TYPE_ATM) then 'AT  '
                        else '    '
                   end as contract_type
                 , substr(oo.merchant_name, 1, 32) as contract_name
                 , substr(oo.merchant_street, 1, 30) as merchant_location
                 , cn.name as merchant_country
                 , substr(oo.merchant_city, 1, 16) as merchant_city
                 , substr(oo.merchant_number, 1, 15) as merchant_number
                 , get_trans_type_ow(
                       i_inst_id       => l_inst_ow
                     , i_oper_type     => oo.oper_type
                     , i_msgt_type     => oo.msg_type
                     , i_card_type_id  => opi.card_type_id
                     , i_is_reversal   => oo.is_reversal
                     , i_terminal_type => oo.terminal_type
                     , i_sttl_type     => oo.sttl_type
                     , i_id            => oo.id
                   ) as transaction_type
                 , eo.id as event_id
                 , oo.msg_type
                 , opi.card_type_id
                 , substr(get_trans_type_ow(
                              i_inst_id       => l_inst_ow
                            , i_oper_type     => oo.oper_type
                            , i_msgt_type     => oo.msg_type
                            , i_card_type_id  => opi.card_type_id
                            , i_is_reversal   => oo.is_reversal
                            , i_terminal_type => oo.terminal_type
                            , i_sttl_type     => oo.sttl_type
                            , i_id            => oo.id), -2) as contra_entry
                 , case when oo.sttl_type = opr_api_const_pkg.SETTLEMENT_USONUS
                        then decode(i_masking_card, '0', oc.card_number, iss_api_card_pkg.get_card_mask(i_card_number => oc.card_number))
                        when opi.inst_id in ('9008', '9949') then '001-NSPK_VISA_DOM_ISS' --NSPK VISA
                        when opi.inst_id in ('9009', '9948', '9959') then '001-NSPK_RUSSIA_ACQ' --NSPK Master
                        when opi.inst_id in ('9001', '9954') then '001-EUROPE_ACQ_SAMEA_ISS' --Master
                        when opi.inst_id in ('9002', '9944') then '001-VISA_ISS' --VISA
                   end as contra_entry_number
                 , oo.sttl_type
                 , oo.sttl_currency
                 , oo.sttl_amount
                 , case oo.is_reversal
                        when 1 then substr(oo.original_id, -10)
                        else null
                   end as orig_number_dog
                 , case when oo_p2p.id is not null then get_contra_entry_channel_ow(
                                                            i_inst_id    => l_inst_ow
                                                          , i_sttl_type  => oo_p2p.sttl_type
                                                          , i_oper_id    => oo_p2p.id
                                                          , i_network_id => opa_p2p.network_id
                                                        )
                        else null
                   end as p2p_channel
                 , case when oo_p2p.id is not null then substr(get_trans_type_ow(
                                                                   i_inst_id       => l_inst_ow
                                                                 , i_oper_type     => oo_p2p.oper_type
                                                                 , i_msgt_type     => oo_p2p.msg_type
                                                                 , i_card_type_id  => opi_p2p.card_type_id
                                                                 , i_is_reversal   => oo_p2p.is_reversal
                                                                 , i_terminal_type => oo_p2p.terminal_type
                                                                 , i_sttl_type     => oo_p2p.sttl_type
                                                                 , i_id            => oo_p2p.id
                                                               ), -2)
                        else null
                   end as p2p_card_type
              from evt_event_object eo
              join opr_operation oo on oo.id = eo.object_id
                                   and oo.status = opr_api_const_pkg.OPERATION_STATUS_PROCESSED
                                   and oo.id between l_min_oper_id and l_max_oper_id
              join opr_card oc on oc.oper_id = oo.id
              join opr_participant opa on opa.oper_id = oo.id
                                      and opa.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
                                      and opa.inst_id = i_inst_id
              join opr_participant opi on opi.oper_id = oo.id
                                      and opi.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
              join acc_macros m on m.object_id = oo.id
                               and m.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
              join acc_entry e on e.macros_id = m.id
                              and e.balance_type = acc_api_const_pkg.BALANCE_TYPE_LEDGER
              join acc_account a on a.id = e.account_id
                                and a.account_type = acc_api_const_pkg.ACCOUNT_TYPE_MERCHANT
              left join com_country cn on cn.code = oo.merchant_country
              left join aut_auth auth on auth.id = oo.id
              left join aut_auth auth_p2p on auth_p2p.external_orig_id = auth.external_orig_id
                                         and auth_p2p.external_orig_id <> auth_p2p.external_auth_id
                                         and auth_p2p.id <> oo.id
              left join opr_operation oo_p2p on oo_p2p.id = auth_p2p.id
                                            and oo_p2p.oper_type in (opr_api_const_pkg.OPERATION_TYPE_P2P_DEBIT
                                                                   , opr_api_const_pkg.OPERATION_TYPE_P2P_CREDIT)
              left join opr_participant opa_p2p on opa_p2p.oper_id = oo_p2p.id
                                               and opa_p2p.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
              left join opr_participant opi_p2p on opi_p2p.oper_id = oo_p2p.id
                                               and opi_p2p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
              left join aup_tag_value atv_p on atv_p.auth_id in (oo.id, oo.match_id)
                                           and atv_p.tag_id = 8730
                                           and atv_p.seq_number = 1
             where decode(eo.status, 'EVST0001', eo.procedure_name, null) = 'CST_OW_PKG.UPLOAD_M_FILE'
               and eo.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
               and eo.id between l_min_event_id and l_max_event_id
               and eo.inst_id = i_inst_id;

        type t_tmp_row_data is table of tmp_row_data%rowtype;
        l_tmp_row_data t_tmp_row_data;

    begin

        open tmp_row_data(i_inst_id => i_inst_id);
        loop
            fetch tmp_row_data bulk collect
            into l_tmp_row_data
            limit l_bulk_limit;

            forall i in 1 .. l_tmp_row_data.count
                insert into cst_m_fil_row_tmp values l_tmp_row_data (i);

            exit when tmp_row_data%notfound;
        end loop;

        -- save total sum
        insert into cst_m_fil_row_total_tmp
        select qq.contract_type
             , qq.contract_number
             , qq.contract_name
             , qq.merchant_location
             , qq.merchant_country
             , qq.merchant_city
             , qq.merchant_number
             , qq.contra_entry
             , qq.transaction_type
             , qq.oper_currency
             , count(qq.reg_number_doc) count_in_pkg
             , sum(qq.oper_amount) sum_amount
             , sum(qq.fee_amount) sum_fee_amount
             , grouping('FT') as batch_flag
             , row_number() over (partition by 1 order by 1) - 1 as count_batch
          from cst_m_fil_row_tmp qq
         group by grouping sets('FT', (qq.contract_type
                                     , qq.contract_number
                                     , qq.transaction_type
                                     , qq.oper_currency
                                     , qq.contract_name
                                     , qq.merchant_location
                                     , qq.merchant_country
                                     , qq.merchant_city
                                     , qq.merchant_number
                                     , qq.contra_entry
                                     )
                                );
    end insert_tmp_row_data;

    function create_file_name(
        i_inst_id in com_api_type_pkg.t_inst_id
    ) return varchar2 is
        l_file_date date;
    begin
        l_daily_file_number := cst_util_pkg.get_next_file_number(
                                   i_inst_id => i_inst_id
                                 , i_file_type => 'FLTPOWMB'
                               );

        if i_inst_id = 2003 then
            l_file_date := get_sysdate;
        else
            l_file_date := get_sysdate - 1;
        end if;

        -- file name
        l_file_name := 'M' || to_char(i_inst_id) || '__' ||
                       l_daily_file_number || '.' ||
                       to_char(l_file_date, 'DDD');
        return l_file_name;
    end create_file_name;

    procedure create_file_header(
        i_inst_id in com_api_type_pkg.t_inst_id
    ) is
    begin
        l_line_number := 1; -- start row counter
        -- create header
        l_line := 'FH' || lpad(l_line_number, 6, 0) /*f2*/
                  || 'MRCH.TRN.B' /*f3*/
                  || '001' /*f4*/ --number version
                  || rpad(to_char(mapping_inst_for_upload_abs (i_inst_id)),6,' ') /*f5*/
                  || to_char(get_sysdate, 'yyyymmdd') /*f6*/
                  || to_char(get_sysdate, 'hh24miss') /*f7*/
                  || '000' /*f8*/
                  || l_daily_file_number /*f9*/
                  || to_char(get_sysdate, 'yyyymmdd') /*f10*/
                  || rpad(' ', 412) /*f11*/
                  || '*';

        process_file_header(
            i_session_file_id => l_session_file_id
          , i_file_header     => l_line
          , i_end_symbol      => c_CRLF);

        l_line_number := l_line_number + 1; -- to switch row counter
    end create_file_header;

    procedure get_sttl_currency_amount(
        i_sttl_type          in com_api_type_pkg.t_dict_value
      , i_oper_currency      in com_api_type_pkg.t_curr_code
      , i_oper_amount        in com_api_type_pkg.t_money
    ) is
    begin
        l_sttl_curr := null;
        l_sttl_amount := null;
        if i_sttl_type = opr_api_const_pkg.SETTLEMENT_USONUS then
            l_sttl_curr := i_oper_currency;
        end if;

        if l_sttl_curr = i_oper_currency then
            l_sttl_amount := i_oper_amount;
        else
            l_sttl_curr := i_oper_currency;
            l_sttl_amount := round(com_api_rate_pkg.convert_amount(
                                       i_src_amount      => i_oper_amount
                                     , i_src_currency    => i_oper_currency
                                     , i_dst_currency    => l_sttl_curr
                                     , i_rate_type       => 'RTTPCUST'
                                     , i_inst_id         => i_inst_id
                                     , i_eff_date        => get_sysdate
                                     , i_mask_exception  => com_api_type_pkg.FALSE
                                     , i_exception_value => null
                                     , i_conversion_type => com_api_const_pkg.CONVERSION_TYPE_SELLING
                                   )
                             );
        end if;
        l_sttl_curr := get_currency(
                           i_cur     => l_sttl_curr
                         , i_inst_id => i_inst_id
                       );

    end get_sttl_currency_amount;

    procedure create_file_trailer is
        l_row_total cst_m_fil_row_total_tmp%rowtype;
    begin
        select t.*
          into l_row_total
          from cst_m_fil_row_total_tmp t
         where t.batch_flag = 0;

        -- create file trailer
        l_line := 'FT' || lpad(l_line_number, 6, 0) /*f2*/
                  || lpad(l_row_total.count_batch, 6, 0) /*f3*/
                  || lpad(l_row_total.sum_amount, 18, 0) /*f4*/
                  || lpad(nvl(l_row_total.sum_fee_amount,0), 18, 0) /*f5*/
                  || rpad(' ', 415, ' ') /*f6*/
                  || '*';

        --write file trailer
        process_file_trailer (
             i_session_file_id  => l_session_file_id
           , i_file_trailer     => l_line
           , i_end_symbol       => c_CRLF
        );
    exception
        when no_data_found then
            trc_log_pkg.debug(i_text => 'Trailer is not found.');
    end create_file_trailer;

    procedure write_transaction_data(
        i_contract_number   in com_api_type_pkg.t_mcc
      , i_oper_currency     in com_api_type_pkg.t_curr_code
      , i_trans_type        in com_api_type_pkg.t_dict_value
      , i_contract_name     in com_api_type_pkg.t_param_value
      , i_merchant_number   in com_api_type_pkg.t_param_value
      , i_merchant_city     in com_api_type_pkg.t_param_value
      , i_merchant_location in com_api_type_pkg.t_param_value
    ) is
    begin
        for trans_data in (select *
                             from cst_m_fil_row_tmp t
                            where t.contract_number = i_contract_number
                              and t.oper_currency = i_oper_currency
                              and t.transaction_type = i_trans_type
                              and t.contract_name = i_contract_name
                              and t.merchant_number = i_merchant_number
                              and t.merchant_city = i_merchant_city
                              and t.merchant_location = i_merchant_location)
        loop
            if trans_data.sttl_currency is null then
                get_sttl_currency_amount(
                    i_sttl_type     => trans_data.sttl_type
                  , i_oper_currency => trans_data.oper_currency
                  , i_oper_amount   => trans_data.oper_amount
                );
            else
                l_sttl_curr := get_currency(
                                   i_cur     => trans_data.sttl_currency
                                 , i_inst_id => i_inst_id
                               );
                l_sttl_amount := trans_data.sttl_amount;
            end if;

            l_line := 'RD'
                      || lpad(l_line_number, 6, 0)                                                  -- 3-8 (6) Row Number
                      || trans_data.transaction_number                                              -- 9-18 (10) Transaction Number
                      || rpad(nvl(trans_data.reg_number_doc, ' '), 30, ' ')                         -- 19-48 (30) Source Registration Number
                      || rpad(nvl(trans_data.orig_number_dog,' '), 34, ' ')                         -- 49-82 (34) Reserved
                      || rpad(nvl(trans_data.contra_entry_number, ' '), 24, ' ')                    -- 83-106 (24) Contra Entry Contract Number
                      || rpad(' ', 32, ' ')                                                         -- 107-138 (32) Reserved
                      || rpad(trans_data.card_number, 24, ' ')                                      -- 139-163 (24) Original Contra Entry Number
                      || trans_data.trans_date                                                      -- 163-170 (8) Transaction Date YYYYMMDD
                      || trans_data.trans_time                                                      -- 171-176 (6) Transaction Time, HHMISS
                      || trans_data.transaction_direction                                           -- 177-177 (1) Transaction Direction
                      || get_currency(i_cur => trans_data.oper_currency, i_inst_id => i_inst_id)    -- 178-180 (3) Settlement Currency
                      || get_currency(i_cur => trans_data.account_currency, i_inst_id => i_inst_id) -- 181-183 (3) Account Currency
                      || lpad(trans_data.oper_amount, 15, 0)                                        -- 184-198 (15) Transaction Amount
                      || lpad(trans_data.oper_amount, 15, 0)                                        -- 199-213 (15) Settlement Amount
                      || lpad(trans_data.account_amount, 15, 0)                                     -- 214-228 (15) Account Amount
                      || nvl(trans_data.fee_direction, ' ')                                         -- 229-229 (1) Fee Direction
                      || lpad(nvl(trans_data.fee_amount, 0), 15, 0)                                 -- 230-244 (15) Fee Amount
                      || rpad(trans_data.account_type, 3, ' ')                                      -- 245-247 (3) Account Type
                      || nvl(trans_data.p2p_channel, ' ')                                           -- 248-248 (1) P2P Reference Contra Entry Channel
                      || nvl(trans_data.p2p_card_type, '  ')                                        -- 249-250 (2) P2P Reference Card Type
                      || rpad(nvl(trans_data.expir_date, ' '), 4, ' ')                              -- 251-254 (4) Card Expire, YYMM
                      || rpad(' ', 50, ' ')                                                         -- 255-304 (50) Reserved
                      || rpad(nvl(trans_data.trans_detail, ' '), 30, ' ')                           -- 305-334 (30) Transaction Details
                      || rpad(' ', 10, ' ')                                                         -- 335-344 (10) Authorization Registration
                      || rpad(nvl(trans_data.auth_code, ' '), 6, ' ')                               -- 345-350 (6) Authorization Approval Code
                      || lpad(nvl(trans_data.auth_amount, 0), 15, 0)                                -- 351-365 (15) Authorization Account Amount
                      || rpad(nvl(trans_data.sttl_date, ' '), 8, ' ')                               -- 366-373 (8) Settlement Date, YYYYMMDD
                      || trans_data.mcc                                                             -- 374-377 (4) Merchant Category Code
                      || trans_data.contra_entry_channel                                            -- 378-378 (1) Contra Entry Channel
                      || rpad(nvl(trans_data.arn, ' '), 23, ' ')                                    -- 379-401 (23) Acquirer Reference Number
                      || lpad(l_sttl_curr, 3, 0)                                                    -- 402-404 (3) Reconciliation Currency
                      || lpad(l_sttl_amount, 15, 0)                                                 -- 405-419 (15) Reconciliation Amount
                      || rpad(nvl(trans_data.iss_reference_number, ' '), 10, ' ')                   -- 420-429 (10) Issuer Reference Number
                      || trans_data.value_date                                                      -- 430-437 (8) Posting Date, YYYYMMDD
                      || rpad(nvl(trans_data.gl_date, ' '), 8, ' ')                                 -- 438-445 (8) GL Date, YYYYMMDD
                      || lpad(nvl(trans_data.collection_number, 0), 10, 0)                          -- 446-449 (10) ATM Collection Number
                      || rpad(' ', 10, ' ')                                                         -- 450-465 (36) Reserved
                      || '*';                                                                       -- 466-466 (1) Terminal Symbol

            check_format_row_m_ow(i_row => l_line);

            --write data
            prc_api_file_pkg.put_line(
                i_raw_data         => l_line
              , i_sess_file_id     => l_session_file_id
            );
            prc_api_file_pkg.put_file(
                i_sess_file_id     => l_session_file_id
              , i_clob_content     => l_line || c_CRLF
              , i_add_to           => com_api_const_pkg.TRUE
            );
            log_upload_oper(
                i_oper_id          => trans_data.reg_number_doc
              , i_session_file_id  => l_session_file_id
              , i_upload_oper_id   => trans_data.reg_number_doc
              , i_file_type        => 'FLTPOWMB'
            );
            l_line_number := l_line_number + 1; -- to switch row counter

        end loop;
    end write_transaction_data;

begin
    l_inst_ow := get_inst_for_settings(i_inst_id => i_inst_id);

    savepoint m_start_upload;

    select min(eo.object_id)
         , max(eo.object_id)
         , min(eo.id)
         , max(eo.id)
      into l_min_oper_id
         , l_max_oper_id
         , l_min_event_id
         , l_max_event_id
      from evt_event_object eo
     where decode(eo.status, 'EVST0001', eo.procedure_name, null) = 'CST_OW_PKG.UPLOAD_M_FILE'
       and eo.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
       and eo.inst_id = i_inst_id;

    trc_log_pkg.debug(i_text => 'OpenWay C-file generation start');

    prc_api_stat_pkg.log_start;

    if check_to_upload_m_file(i_inst_id => i_inst_id) = com_api_type_pkg.TRUE then
        -- get file_name
        l_file_name := create_file_name(i_inst_id => i_inst_id);

        prc_api_file_pkg.open_file(
            o_sess_file_id => l_session_file_id
          , i_file_name    => l_file_name
          , i_file_type    => 'FLTPOWMB'
          , io_params      => l_params);

        trc_log_pkg.debug(i_text => 'OpenWay M-file generation start. File type: FLTPOWMB');

        -- insert into temp table that contains transaction data and total sum
        insert_tmp_row_data(i_inst_id => i_inst_id);

        create_file_header(i_inst_id => i_inst_id);

        -- write batch
        for batch in (
            select t.*
                 , rownum rn
              from cst_m_fil_row_total_tmp t
             where t.batch_flag = 1
        ) loop

            if i_inst_id = 2005 then
                l_specific_merch_num := batch.contract_number;
            else
                l_specific_merch_num := batch.merchant_number;
            end if;

            -- create batch header
            l_line := 'BH' || lpad(l_line_number, 6, 0) /*f2*/
                || rpad(' ', 20, ' ') /*f3*/
                || batch.contract_type /*f4*/
                || rpad(batch.contract_number, 24, ' ') /*f5*/
                || lpad(' ', 32, ' ') /*f6*/
                || rpad(nvl(batch.contract_name, ' '), 32, ' ') /*f7*/
                || rpad(nvl(batch.merchant_location, ' '), 30, ' ') /*f8*/
                || rpad(nvl(batch.merchant_country, ' '), 3, ' ') /*f9*/
                || rpad(nvl(batch.merchant_city, ' '), 16, ' ') /*f10*/
                || rpad(nvl(l_specific_merch_num, ' '), 15, ' ') /*f11*/
                || rpad(' ', 36, ' ') /*f12*/
                || rpad(nvl(batch.contra_entry, ' '), 4, ' ') /*f13*/
                || rpad(nvl(batch.transaction_type, ' '), 8, ' ') /*f14*/
                || lpad(nvl(get_currency(i_cur => batch.oper_currency, i_inst_id => i_inst_id), 0), 3, 0) /*f15*/
                || to_char(get_sysdate, 'yyyymmdd') /*f16*/
                || rpad(nvl(com_api_dictionary_pkg.get_article_text(i_article => batch.transaction_type,
                                                                    i_lang    => 'LANGENG') || case substr(batch.transaction_type, 1, 1) when 'i' then ' (rev)' end,
                            ' '),
                        100,
                        ' ') /*f17*/
                || rpad(' ', 30, ' ') /*f18*/
                || rpad(' ', 92, ' ') /*f19*/
                || '*'; /*f20*/


            -- write batch header
            prc_api_file_pkg.put_line(
                i_raw_data     => l_line
              , i_sess_file_id => l_session_file_id
            );
            prc_api_file_pkg.put_file(
                i_sess_file_id => l_session_file_id
              , i_clob_content => l_line || c_CRLF
              , i_add_to       => com_api_const_pkg.TRUE
            );
            l_line_number := l_line_number + 1; -- to switch row counter

            write_transaction_data(
                i_contract_number   => batch.contract_number
              , i_oper_currency     => batch.oper_currency
              , i_trans_type        => batch.transaction_type
              , i_contract_name     => batch.contract_name
              , i_merchant_number   => batch.merchant_number
              , i_merchant_city     => batch.merchant_city
              , i_merchant_location => batch.merchant_location
            );

            -- create batch trailer
            l_line := 'BT' || lpad(l_line_number, 6, 0) /*f2*/
                || lpad(batch.count, 6, 0) /*f3*/
                || lpad(batch.sum_amount, 18, 0) /*f4*/
                || lpad(nvl(batch.sum_fee_amount,0), 18, 0) /*f5*/
                || rpad(' ', 415, ' ') /*f6*/
                || '*'; /*f7*/

            l_row_total_count := batch.count;

            -- write batch trailer
            prc_api_file_pkg.put_line(
                i_raw_data     => l_line
              , i_sess_file_id => l_session_file_id
            );
            prc_api_file_pkg.put_file(
                i_sess_file_id => l_session_file_id
              , i_clob_content => l_line || c_CRLF
              , i_add_to       => com_api_const_pkg.TRUE
            );
            l_line_number := l_line_number + 1; --to switch row counter
        end loop;

        create_file_trailer;

        open l_events;
        loop
            fetch l_events bulk collect
            into l_event_object_id limit l_bulk_limit;

            evt_api_event_pkg.process_event_object(i_event_object_id_tab => l_event_object_id);

            exit when l_events%notfound;
        end loop;
        close l_events;

        update evt_event_object eo
           set eo.status = evt_api_const_pkg.EVENT_STATUS_DO_NOT_PROCES
             , proc_session_id = get_session_id
         where decode(eo.status, 'EVST0001', eo.procedure_name, null) = 'CST_OW_PKG.UPLOAD_M_FILE'
           and eo.id <= l_max_event_id
           and eo.inst_id = i_inst_id
           and not exists (select 1
                             from opr_operation op
                            where op.id = eo.object_id
                              and op.status = opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY);

    end if;

    prc_api_stat_pkg.log_end(
        i_processed_total => l_row_total_count
      , i_result_code     => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug(i_text => 'OpenWay M-batch-file generation end');

exception
    when others then
        rollback to savepoint m_start_upload;

        prc_api_stat_pkg.log_end(i_result_code => prc_api_const_pkg.PROCESS_RESULT_FAILED);

        trc_log_pkg.debug(i_text => 'OpenWay M-batch-file generation end with error');

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm);
        end if;
        raise;
end upload_m_batch_file;

procedure upload_c_file_ow(
    i_inst_id           in com_api_type_pkg.t_inst_id
) is
    l_count                 com_api_type_pkg.t_long_id := 0;
    l_oper_min              com_api_type_pkg.t_long_id;
    l_oper_max              com_api_type_pkg.t_long_id;
    l_file_name             com_api_type_pkg.t_attr_name;
    l_session_file_id       com_api_type_pkg.t_long_id;
    l_params                com_api_type_pkg.t_param_tab;
    l_line                  com_api_type_pkg.t_text;
    l_daily_file_number     com_api_type_pkg.t_tiny_id;
    l_line_number           com_api_type_pkg.t_long_id;
    l_event_object_id       com_api_type_pkg.t_number_tab;
    l_fee_amount            com_api_type_pkg.t_money;
    l_fee_direction         com_api_type_pkg.t_byte_char;
    l_fee_amount_custom     com_api_type_pkg.t_money;
    l_fee_direction_custom  com_api_type_pkg.t_byte_char;
    i                       com_api_type_pkg.t_long_id := 0;
    l_totalcount            com_api_type_pkg.t_long_id;
    l_totalamt              com_api_type_pkg.t_long_id;
    l_inst_ow               com_api_type_pkg.t_inst_id;
    l_sttl_curr             com_api_type_pkg.t_curr_code;
    l_sttl_amount           com_api_type_pkg.t_money;
    l_specific_merch_num    com_api_type_pkg.t_merchant_number;
    l_min_evt_id            com_api_type_pkg.t_long_id;
    l_max_evt_id            com_api_type_pkg.t_long_id;

    function create_file_name(
        i_inst_id in com_api_type_pkg.t_inst_id
    ) return varchar2 is
    begin
        l_daily_file_number := cst_util_pkg.get_next_file_number(
            i_inst_id   => i_inst_id
          , i_file_type => 'FLTPOWCS'
        );
        -- file name
        l_file_name := 'C' || to_char(i_inst_id) || '__' ||
                       l_daily_file_number || '.' ||
                       to_char(get_sysdate - 1, 'DDD');
        return l_file_name;
    end create_file_name;

    procedure create_file_header(
        i_inst_id in com_api_type_pkg.t_inst_id
    ) is
    begin
        l_line_number := 1; -- start row counter
        -- create header
        l_line := 'FH' || lpad(l_line_number, 6, 0) /*f2*/
                  || 'CARD.TRAN ' /*f3*/
                  || '014' /*f4*/ -- number version
                  || rpad(to_char(mapping_inst_for_upload_abs(i_inst_id => i_inst_id)), 6, ' ') /*f5*/
                  || to_char(get_sysdate, 'yyyymmdd') /*f6*/
                  || to_char(get_sysdate, 'hh24miss') /*f7*/
                  || '000' /*f8*/
                  || l_daily_file_number /*f9*/
                  || to_char(get_sysdate, 'yyyymmdd') /*f10*/
                  || rpad(' ', 594) /*f11*/
                  || '*';
        process_file_header(
            i_session_file_id => l_session_file_id
          , i_file_header     => l_line
          , i_end_symbol      => c_CRLF
        );

        l_line_number := l_line_number + 1; --to switch row counter
    end create_file_header;

    procedure create_file_trailer is
    begin
        -- create file trailer
        l_line := 'FT' || lpad(l_line_number, 6, 0) /*f2*/
                  || lpad(l_totalcount, 6, 0) /*f3*/
                  || lpad(l_totalamt, 18, 0) /*f4*/
                  || rpad(' ', 615, ' ') /*f5*/
                  || '*';

        -- write file trailer
        process_file_trailer (
             i_session_file_id  => l_session_file_id
           , i_file_trailer     => l_line
           , i_end_symbol       => c_CRLF
        );
    end create_file_trailer;

    procedure get_fee_amount(
        i_oper_id in com_api_type_pkg.t_long_id
      , i_is_reversal in com_api_type_pkg.t_boolean
    ) is
    begin
        select max(fee_direction)
             , sum(fee_amount) as fee_amount
          into l_fee_direction
             , l_fee_amount
          from (
              select decode(e.amount, 0, ' ',
                                              decode((case when i_is_reversal = com_api_type_pkg.TRUE then -1
                                                           else 1
                                                      end) * e.balance_impact, -1, 'D'
                                                                             ,  1, 'C'
                                                                                      , ' ')
                     ) as fee_direction
                   , e.amount + nvl((select e1.amount
                                       from acc_entry e1
                                      where e1.macros_id = m.id
                                        and e1.balance_type = acc_api_const_pkg.BALANCE_TYPE_USED_EXCEED_LIMIT), 0) as fee_amount
                from acc_entry e
                   , acc_macros m
                   , acc_account a
               where e.macros_id = m.id
                 and m.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                 and m.object_id = i_oper_id
                 and e.account_id = a.id
                 and e.balance_type = acc_api_const_pkg.BALANCE_TYPE_LEDGER
                 and a.account_type = acc_api_const_pkg.ACCOUNT_TYPE_CARD
                 and exists
                     (select 1
                        from com_array_conv_elem e
                           , com_array_type cat
                           , com_array a
                           , com_array_conversion c
                       where e.conv_id = c.id
                         and cat.name = 'OPERATION_TYPES'
                         and cat.id = a.array_type_id
                         and c.out_array_id = a.id
                         and com_api_i18n_pkg.get_text(
                                 i_table_name  => 'COM_ARRAY'
                               , i_column_name => 'LABEL'
                               , i_object_id   => a.id
                             ) = 'UCS Commission types'
                         and e.in_element_value = m.amount_purpose
                     )
                 and e.amount + nvl((select e1.amount
                                       from acc_entry e1
                                      where e1.macros_id = m.id
                                        and e1.balance_type = acc_api_const_pkg.BALANCE_TYPE_USED_EXCEED_LIMIT), 0) != 0

              union

              select decode(e.amount, 0, ' ',
                                              decode((case when i_is_reversal = com_api_type_pkg.TRUE then -1
                                                           else 1
                                                      end) * e.balance_impact,  1, 'D'
                                                                             , -1, 'C'
                                                                                      , ' ')
                     ) as fee_direction
                   , e.amount
                from acc_entry e
                   , acc_macros m
                   , acc_account a
               where e.macros_id = m.id
                 and m.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                 and m.object_id = i_oper_id
                 and e.account_id = a.id
                 and e.balance_type = acc_api_const_pkg.BALANCE_TYPE_USED_EXCEED_LIMIT
                 and a.account_type = acc_api_const_pkg.ACCOUNT_TYPE_CARD
                 and not exists
                     (select 1
                        from acc_entry e1
                       where e1.macros_id = m.id
                         and e1.balance_type = acc_api_const_pkg.BALANCE_TYPE_LEDGER)
                 and exists
                     (select 1
                        from com_array_conv_elem e
                           , com_array_type cat
                           , com_array a
                           , com_array_conversion c
                       where e.conv_id = c.id
                         and cat.name = 'OPERATION_TYPES'
                         and cat.id = a.array_type_id
                         and c.out_array_id = a.id
                         and com_api_i18n_pkg.get_text(
                                 i_table_name  => 'COM_ARRAY'
                               , i_column_name => 'LABEL'
                               , i_object_id   => a.id
                             ) = 'UCS Commission types'
                         and e.in_element_value = m.amount_purpose
                     )
                 and e.amount != 0
          ) fee;
    end get_fee_amount;

    procedure get_sttl_currency_amount(
        i_sttl_type          in com_api_type_pkg.t_dict_value
      , i_card_instance_id   in com_api_type_pkg.t_medium_id
      , i_oper_currency      in com_api_type_pkg.t_curr_code
      , i_oper_amount        in com_api_type_pkg.t_money
    ) is
    begin
        l_sttl_curr := null;
        l_sttl_amount := null;

        if i_sttl_type = opr_api_const_pkg.SETTLEMENT_USONUS then
            l_sttl_curr := i_oper_currency;
        else
            begin
                select decode(i_oper_currency, '643', b.bin_currency, b.sttl_currency)
                  into l_sttl_curr
                  from iss_card_instance icn
                     , iss_bin b
                 where icn.bin_id = b.id
                   and icn.id = i_card_instance_id;
            exception
                when no_data_found then
                    l_sttl_curr:=i_oper_currency;
            end;
        end if;

        if l_sttl_curr != i_oper_currency then
            l_sttl_amount := i_oper_amount;
        else
            l_sttl_amount := round(
                com_api_rate_pkg.convert_amount(
                    i_src_amount      => i_oper_amount
                  , i_src_currency    => i_oper_currency
                  , i_dst_currency    => l_sttl_curr
                  , i_rate_type       => 'RTTPCUST'
                  , i_inst_id         => i_inst_id
                  , i_eff_date        => get_sysdate
                  , i_mask_exception  => com_api_type_pkg.FALSE
                  , i_exception_value => null
                  , i_conversion_type => com_api_const_pkg.CONVERSION_TYPE_SELLING
                )
            );
        end if;

        l_sttl_curr := get_currency(
            i_cur => l_sttl_curr
          , i_inst_id => i_inst_id
        );
    end get_sttl_currency_amount;

    procedure write_transaction_data(
        i_inst_id       in com_api_type_pkg.t_inst_id
      , i_oper_min      in com_api_type_pkg.t_long_id
      , i_oper_max      in com_api_type_pkg.t_long_id
      , i_event_min     in com_api_type_pkg.t_long_id
      , i_event_max     in com_api_type_pkg.t_long_id
    ) is
    begin
        l_totalcount := 0;
        l_totalamt := 0;

        for trans_data in (
            -- transaction entry on Ledger balance
            select /*+ LEADING(eo oo) INDEX(eo EVT_EVENT_OBJECT_PK) */
                   distinct -- <-- because account_amount
                   substr(oo.id, -10) as transaction_number
                 , to_char(oo.id) as reg_number_doc
                 , oc.card_number as  contract_number
                 , oc.card_number as card_number
                 , to_char(nvl(o_auth.host_date, oo.host_date), 'YYYYMMDD') as trans_date
                 , to_char(nvl(o_auth.host_date, oo.host_date), 'HH24MISS') as trans_time
                 , case
                        when oo.oper_amount = 0 then ' '
                        when e.amount = 0 then ' '
                        when oo.is_reversal = com_api_type_pkg.FALSE then decode(e.balance_impact, 1, 'C', 'D')
                        when oo.is_reversal = com_api_type_pkg.TRUE then decode(e.balance_impact, 1, 'D', 'C')
                        else ' '
                   end transaction_direction
                 , oo.oper_currency as oper_currency
                 , oo.sttl_currency as sttl_currency
                 , a.currency as account_currency
                 , oo.oper_amount
                 , oo.sttl_amount
                 , sum(decode(oo.oper_amount, 0, 0, (e.amount + nvl(ee.amount, 0)))) over (partition by oo.id) as account_amount -- sum with exceed limit
                 , '' as fee_direction
                 , '' as fee_amount
                 , 'P' as account_type
                 , to_char(op.card_expir_date, 'yymm') expir_date
                 , case
                        when oo.oper_type = opr_api_const_pkg.OPERATION_TYPE_SRV_PRV_PAYMENT
                            then nvl(get_payment_purpose(atv_p.tag_value), 'PAYMENT') || '_' || oo.terminal_number
                        else substr(oo.merchant_name, 1, 30)
                   end as trans_detail
                 , '' auth_reg_number
                 , op.auth_code as auth_code
                 , round(case
                              when oo.oper_type = 'MSGTAUTH' then decode(e.amount, 0, ' ', e.amount)
                              when oo.oper_type = 'MSGTCMPL' then ''
                         end / nvl(power(10, cc.exponent), 1)
                       , 2) as auth_amount
                 , to_char(e.sttl_date, 'YYYYMMDD') as sttl_date
                 , oo.mcc as mcc
                 , get_contra_entry_channel_ow(
                       i_inst_id    => l_inst_ow
                     , i_sttl_type  => oo.sttl_type
                     , i_oper_id    => oo.id
                     , i_network_id => op.network_id) as contra_entry_channel
                 , '' as arn
                 , oo.oper_request_amount as request_amount
                 , substr(to_char(oo.id), length(to_char(oo.id)) - 9) as iss_reference_number
                 , to_char(e.posting_date, 'YYYYMMDD') as value_date
                 , to_char(e.posting_date, 'YYYYMMDD') as gl_date
                 , (select /*+ INDEX(c ATM_COLLECTION_TERM_ID_NDX)*/
                           max(collection_number)
                      from atm_collection c
                     where c.terminal_id = op.terminal_id
                       and c.start_date <= oo.oper_date
                   ) as collection_number
                 , case when oo.terminal_type in (acq_api_const_pkg.TERMINAL_TYPE_POS
                                                , acq_api_const_pkg.TERMINAL_TYPE_EPOS
                                                , acq_api_const_pkg.TERMINAL_TYPE_MOBILE_POS) then 'PO  '
                        when oo.terminal_type in (acq_api_const_pkg.TERMINAL_TYPE_ATM) then 'AT  '
                        else '    '
                   end as contra_entry_contract_type
                 , oo.merchant_name as contract_name
                 , oo.merchant_street as merchant_location
                 , nvl(cn.name, cn.code) as merchant_country
                 , oo.merchant_city as merchant_city
                 , oo.merchant_number
                 , get_trans_type_ow(
                       i_inst_id       => l_inst_ow
                     , i_oper_type     => oo.oper_type
                     , i_msgt_type     => oo.msg_type
                     , i_card_type_id  => op.card_type_id
                     , i_is_reversal   => oo.is_reversal
                     , i_terminal_type => oo.terminal_type
                     , i_sttl_type     => oo.sttl_type
                     , i_id            => oo.id
                   ) as transaction_type
                 , eo.id as event_id
                 , oo.msg_type
                 , op.card_type_id
                 , substr(get_trans_type_ow(
                              i_inst_id       => l_inst_ow
                            , i_oper_type     => oo.oper_type
                            , i_msgt_type     => oo.msg_type
                            , i_card_type_id  => op.card_type_id
                            , i_is_reversal   => oo.is_reversal
                            , i_terminal_type => oo.terminal_type
                            , i_sttl_type     => oo.sttl_type
                            , i_id            => oo.id
                          )
                     , -2) as contra_entry
                 , oo.terminal_number as contra_entry_number
                 , oo.is_reversal
                 , nvl(substr(oo.network_refnum, length(oo.network_refnum) - 11)
                     , nvl(substr(oo.originator_refnum, length(oo.originator_refnum) - 11), ' ')) as retrieval_reference_number
                 , ' ' as transaction_condition
                 , ' ' as dev_fin_cycle_number
                 , decode(oo.is_reversal, 0, 'O', 'R') as document_type
                 , decode(oo.is_reversal, 0, ' ', substr(to_char(oo.original_id), - 10)) as primary_document
                 , ' ' as sourse_id_spec
                 , '00' as target_id_spec
                 , op.card_instance_id
                 , oo.sttl_type
              from opr_operation oo
              join evt_event_object eo on eo.object_id = oo.id
                                      and eo.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                                      and decode(eo.status, 'EVST0001', eo.procedure_name, null) = 'CST_OW_PKG.UPLOAD_C_FILE'
                                      and eo.id between i_event_min and i_event_max
              join opr_participant op on op.oper_id = oo.id
                                     and op.inst_id = i_inst_id
                                     and op.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
              join opr_card oc on oc.oper_id = oo.id
              join acc_macros m on m.object_id = oo.id
                               and m.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
              join acc_entry e on e.macros_id = m.id
                              and e.balance_type = acc_api_const_pkg.BALANCE_TYPE_LEDGER
              join acc_account a on a.id = e.account_id
                                and a.account_type = acc_api_const_pkg.ACCOUNT_TYPE_CARD
              left join com_country cn on cn.code = oo.merchant_country
              join com_ui_currency_vw cc on cc.code = oo.oper_currency
                                        and cc.lang = com_api_const_pkg.LANGUAGE_ENGLISH
              left join acc_entry ee on ee.macros_id = m.id
                                    and ee.balance_type = acc_api_const_pkg.BALANCE_TYPE_USED_EXCEED_LIMIT
              left join opr_operation o_auth on o_auth.id = oo.match_id
                                            and o_auth.msg_type = opr_api_const_pkg.MESSAGE_TYPE_AUTHORIZATION
              left join aup_tag_value atv_p on atv_p.auth_id in (oo.id, o_auth.id)
                                           and atv_p.tag_id = 8730
                                           and atv_p.seq_number = 1
             where oo.id between i_oper_min and i_oper_max
               and oo.status = opr_api_const_pkg.OPERATION_STATUS_PROCESSED
               and (
                   not exists
                       (select 1
                          from com_array_conv_elem e
                             , com_array_type cat
                             , com_array a
                             , com_array_conversion c
                         where e.conv_id = c.id
                           and cat.name = 'OPERATION_TYPES'
                           and cat.id = a.array_type_id
                           and c.out_array_id = a.id
                           and com_api_i18n_pkg.get_text(
                                   i_table_name  => 'COM_ARRAY'
                                 , i_column_name => 'LABEL'
                                 , i_object_id   => a.id
                               ) = 'UCS Commission types'
                           and e.in_element_value = m.amount_purpose
                        )
                   or oo.oper_amount = 0
               )

            union all

            -- transaction entry on exceed limit
            select /*+ LEADING(eo oo) INDEX(eo EVT_EVENT_OBJECT_PK) */
                   distinct -- <-- because account_amount
                   substr(oo.id, -10) as transaction_number
                 , to_char(oo.id) as reg_number_doc
                 , oc.card_number as contract_number
                 , oc.card_number as card_number
                 , to_char(nvl(o_auth.host_date, oo.host_date), 'YYYYMMDD') as trans_date
                 , to_char(nvl(o_auth.host_date, oo.host_date), 'HH24MISS') as trans_time
                 , case
                        when oo.oper_amount = 0 then ' '
                        when e.amount = 0 then ' '
                        when oo.is_reversal = com_api_type_pkg.FALSE then decode(e.balance_impact, 1, 'C', 'D')
                        when oo.is_reversal = com_api_type_pkg.TRUE then decode(e.balance_impact, 1, 'D', 'C')
                        else ' '
                   end transaction_direction
                 , oo.oper_currency as oper_currency
                 , oo.sttl_currency as sttl_currency
                 , a.currency as account_currency
                 , oo.oper_amount
                 , oo.sttl_amount
                 , sum(decode(oo.oper_amount, 0, 0, e.amount)) over (partition by oo.id) as account_amount -- sum with exceed limit
                 , '' as fee_direction
                 , '' as fee_amount
                 , 'P' as account_type
                 , to_char(op.card_expir_date, 'yymm') expir_date
                 , case
                        when oo.oper_type = opr_api_const_pkg.OPERATION_TYPE_SRV_PRV_PAYMENT
                            then nvl(get_payment_purpose(atv_p.tag_value), 'PAYMENT') || '_' || oo.terminal_number
                        else substr(oo.merchant_name, 1, 30)
                   end as trans_detail
                 , '' auth_reg_number
                 , op.auth_code as auth_code
                 , round(case
                              when oo.oper_type = 'MSGTAUTH' then decode(e.amount, 0, ' ', e.amount)
                              when oo.oper_type = 'MSGTCMPL' then ''
                         end / nvl(power(10, cc.exponent), 1)
                     , 2) as auth_amount
                 , to_char(e.sttl_date, 'YYYYMMDD') as sttl_date
                 , oo.mcc as mcc
                 , get_contra_entry_channel_ow(
                       i_inst_id    => l_inst_ow
                     , i_sttl_type  => oo.sttl_type
                     , i_oper_id    => oo.id
                     , i_network_id => op.network_id
                   ) as contra_entry_channel
                 , '' as arn
                 , oo.oper_request_amount as request_amount
                 , substr(to_char(oo.id), length(to_char(oo.id)) - 9) as iss_reference_number
                 , to_char(e.posting_date, 'YYYYMMDD') as value_date
                 , to_char(e.posting_date, 'YYYYMMDD') as gl_date
                 , (select /*+ INDEX(c ATM_COLLECTION_TERM_ID_NDX) */
                           max(collection_number)
                      from atm_collection c
                     where c.terminal_id = op.terminal_id
                       and c.start_date <= oo.oper_date
                   ) as collection_number
                 , case when oo.terminal_type in (acq_api_const_pkg.TERMINAL_TYPE_POS
                                                , acq_api_const_pkg.TERMINAL_TYPE_EPOS
                                                , acq_api_const_pkg.TERMINAL_TYPE_MOBILE_POS) then 'PO  '
                        when oo.terminal_type in (acq_api_const_pkg.TERMINAL_TYPE_ATM) then 'AT  '
                        else '    '
                   end as contra_entry_contract_type
                 , oo.merchant_name as contract_name
                 , oo.merchant_street as merchant_location
                 , nvl(cn.name, cn.code) as merchant_country
                 , oo.merchant_city as merchant_city
                 , oo.merchant_number
                 , get_trans_type_ow(
                       i_inst_id       => l_inst_ow
                     , i_oper_type     => oo.oper_type
                     , i_msgt_type     => oo.msg_type
                     , i_card_type_id  => op.card_type_id
                     , i_is_reversal   => oo.is_reversal
                     , i_terminal_type => oo.terminal_type
                     , i_sttl_type     => oo.sttl_type
                     , i_id            => oo.id
                   ) as transaction_type
                 , eo.id as event_id
                 , oo.msg_type
                 , op.card_type_id
                 , substr(get_trans_type_ow(
                              i_inst_id       => l_inst_ow
                            , i_oper_type     => oo.oper_type
                            , i_msgt_type     => oo.msg_type
                            , i_card_type_id  => op.card_type_id
                            , i_is_reversal   => oo.is_reversal
                            , i_terminal_type => oo.terminal_type
                            , i_sttl_type     => oo.sttl_type
                            , i_id            => oo.id
                          )
                     , -2) as contra_entry
                 , oo.terminal_number as contra_entry_number
                 , oo.is_reversal
                 , nvl(substr(oo.network_refnum, length(oo.network_refnum) - 11)
                     , nvl(substr(oo.originator_refnum, length(oo.originator_refnum) - 11), ' ')) as retrieval_reference_number
                 , ' ' as transaction_condition
                 , ' ' as dev_fin_cycle_number
                 , decode(oo.is_reversal, 0, 'O', 'R') as document_type
                 , decode(oo.is_reversal, 0, ' ', substr(to_char(oo.original_id), -10)) as primary_document
                 , ' ' as sourse_id_spec
                 , '00' as target_id_spec
                 , op.card_instance_id
                 , oo.sttl_type
              from opr_operation oo
              join evt_event_object eo on eo.object_id = oo.id
                                      and eo.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                                      and decode(eo.status, 'EVST0001', eo.procedure_name, null) = 'CST_OW_PKG.UPLOAD_C_FILE'
                                      and eo.id between i_event_min and i_event_max
              join opr_participant op on op.oper_id = oo.id
                                     and op.inst_id = i_inst_id
                                     and op.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
              join opr_card oc on oc.oper_id = oo.id
              join acc_macros m on m.object_id = oo.id
                               and m.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
              join acc_entry e on e.macros_id = m.id
                              and e.balance_type = acc_api_const_pkg.BALANCE_TYPE_USED_EXCEED_LIMIT
              join acc_account a on a.id = e.account_id
                                and a.account_type = acc_api_const_pkg.ACCOUNT_TYPE_CARD
              left join com_country cn on cn.code = oo.merchant_country
              join com_ui_currency_vw cc on cc.code = oo.oper_currency
                                        and cc.lang = com_api_const_pkg.LANGUAGE_ENGLISH
              left join opr_operation o_auth on o_auth.id = oo.match_id
                                            and o_auth.msg_type = opr_api_const_pkg.MESSAGE_TYPE_AUTHORIZATION
              left join aup_tag_value atv_p on atv_p.auth_id = oo.id
                                           and atv_p.tag_id = 8730
                                           and atv_p.seq_number = 1
             where oo.id between i_oper_min and i_oper_max
               and oo.status = opr_api_const_pkg.OPERATION_STATUS_PROCESSED
               and not exists
                   (select 1
                      from acc_entry e1
                     where e1.macros_id = m.id
                       and e1.balance_type = acc_api_const_pkg.BALANCE_TYPE_LEDGER
                   )
               and (
                   not exists
                       (select 1
                          from com_array_conv_elem e
                             , com_array_type cat
                             , com_array a
                             , com_array_conversion c
                         where e.conv_id = c.id
                           and cat.name = 'OPERATION_TYPES'
                           and cat.id = a.array_type_id
                           and c.out_array_id = a.id
                           and com_api_i18n_pkg.get_text(
                                    i_table_name  => 'COM_ARRAY'
                                  , i_column_name => 'LABEL'
                                  , i_object_id   => a.id
                               ) = 'UCS Commission types'
                           and e.in_element_value = m.amount_purpose
                       )
                   or oo.oper_amount = 0
               )
        ) loop
            i := i + 1;
            l_event_object_id(i) := trans_data.event_id;
            get_fee_amount(
                i_oper_id       => trans_data.reg_number_doc
              , i_is_reversal   => trans_data.is_reversal
            );
            l_fee_amount_custom := 0;
            l_fee_direction_custom := ' ';

            if trans_data.sttl_currency is null then
                get_sttl_currency_amount(
                    i_sttl_type         => trans_data.sttl_type
                  , i_card_instance_id  => trans_data.card_instance_id
                  , i_oper_currency     => trans_data.oper_currency
                  , i_oper_amount       => trans_data.oper_amount
                );
            else
                l_sttl_curr := get_currency(
                                   i_cur     => trans_data.sttl_currency
                                 , i_inst_id => i_inst_id
                               );
                l_sttl_amount := trans_data.sttl_amount;
            end if;

            l_totalcount := l_totalcount + 1;
            l_totalamt   := l_totalamt   + to_number(nvl(trim(trans_data.account_amount), 0));

            if i_inst_id in (2005, 2011, 2012) and trans_data.sttl_type = opr_api_const_pkg.SETTLEMENT_USONUS then
                l_specific_merch_num := trans_data.contra_entry_number;
            else
                l_specific_merch_num := trans_data.merchant_number;
            end if;

            l_line := 'RD'
                || lpad(l_line_number, 6, 0)                                                    -- 3-8 (6) Row Number
                || trans_data.transaction_number                                                -- 9-18 (10) Transaction Number
                || lpad(trans_data.reg_number_doc, 30, 0)                                       -- 19-48 (30) Registration Document Number
                || rpad(trans_data.transaction_type, 8, ' ')                                    -- 49-56 (8) Transaction Type
                || rpad(' ', 10, ' ')                                                           -- 57-66 (10) Reserved
                || rpad(nvl(substr(trans_data.transaction_type, -2, 2), ' '), 4, ' ')           -- 67-70 (4) Contract Type
                || rpad(nvl(trans_data.contract_number, ' '), 24, ' ')                          -- 71-94 (24) Contract Number
                || rpad(' ', 32, ' ')                                                           -- 95-126 (32) RBS Contract Number
                || rpad(trans_data.card_number, 24,' ')                                         -- 127-150 (24) Original Entry Number
                || rpad(' ', 10, ' ')                                                           -- 151-160 (10) Reserved
                || rpad(nvl(trans_data.contra_entry_contract_type, ' '), 4, ' ')                -- 161-164 (4) Contra Entry Contract Type
                || rpad(nvl(trans_data.contra_entry_number, ' '), 24, ' ')                      -- 165-188 (24) Contra Entry Contract Number
                || rpad(' ', 32, ' ')                                                           -- 189-220 (32) Reserved
                || rpad(nvl(trans_data.merchant_number, ' '), 24, ' ')                          -- 221-244 (24) Original Contra Entry Number
                || trans_data.trans_date                                                        -- 245-252 (8) Transaction Date, YYYYMMDD
                || trans_data.trans_time                                                        -- 253-258 (6) Transaction Time, HHMISS
                || trans_data.transaction_direction                                             -- 259-259 (1) Transaction Direction
                || get_currency(i_cur => trans_data.oper_currency, i_inst_id => i_inst_id)      -- 260-262 (3) Transaction Currency
                || l_sttl_curr                                                                  -- 263-265 (3) Settlement Currency
                || get_currency(i_cur => trans_data.account_currency, i_inst_id => i_inst_id)   -- 266-268 (3) Account Currency
                || lpad(trans_data.oper_amount, 15, 0)                                          -- 269-283 (15) Transaction Amount
                || lpad(l_sttl_amount, 15, 0)                                                   -- 284-298 (15) Settlement Amount
                || lpad(trans_data.account_amount, 15, 0)                                       -- 299-313 (15) Account Amount
                || nvl(l_fee_direction, ' ')                                                    -- 314-314 (1) Fee Direction
                || lpad(nvl(l_fee_amount, 0), 15, 0)                                            -- 315-329 (15) Fee Amount
                || rpad(trans_data.account_type, 3, ' ')                                        -- 330-332 (3) Account Type
                || rpad(' ', 3, ' ')                                                            -- 333-335 (3) Reserved
                || rpad(nvl(trans_data.expir_date, ' '), 4, ' ')                                -- 336-339 (4) Card Expiry Date, YYMM
                || rpad(nvl(l_specific_merch_num,' '), 15, ' ')                                 -- 340-354 (15) Merchant ID
                || rpad(nvl(trans_data.merchant_country, ' '), 3, ' ')                          -- 355-357 (3) Transaction Country
                || rpad(nvl(trans_data.merchant_city,' '), 16, ' ')                             -- 358-373 (16) Transaction City
                || rpad(nvl(trans_data.trans_detail, ' '), 30, ' ')                             -- 374-403 (30) Transaction Details
                || rpad(nvl(trans_data.sttl_date, ' '), 8, ' ')                                 -- 404-411 (8) Value Date, YYYYMMDD
                || rpad(' ', 10, ' ')                                                           -- 412-421 (10) Authorization Registration Number
                || rpad(nvl(trans_data.auth_code, ' '), 6, ' ')                                 -- 422-427 (6) Authorization Approval Code
                || lpad(nvl(trans_data.auth_amount, 0), 15, 0)                                  -- 428-442 (15) Authorization Account Amount
                || rpad(nvl(trans_data.sttl_date, ' '), 8, ' ')                                 -- 443-450 (8) Settlement Date, YYYYMMDD
                || trans_data.mcc                                                               -- 451-454 (4) Merchant Category Code
                || trans_data.contra_entry_channel                                              -- 455-455 (1) Contra Entry Channel
                || rpad(nvl(trans_data.arn, ' '), 23, ' ')                                      -- 456-478 (23) Acquirer Reference Number
                || lpad(0, 3, 0)                                                                -- 479-481 (3) Reconciliation Currency
                || lpad(0, 15, 0)                                                               -- 482-496 (15) Reconciliation Amount
                || rpad(nvl(trans_data.iss_reference_number, ' '), 10, ' ')                     -- 497-506 (10) Issuer Reference Number
                || rpad(nvl(trans_data.retrieval_reference_number, ' '), 12, ' ')               -- 507-518 (12) Retrieval Reference Number
                || rpad(nvl(trans_data.transaction_condition, ' '), 4, ' ')                     -- 519-522 (4) Transaction Condition
                || rpad(l_fee_direction_custom, 1, ' ')                                         -- 523-523 (1) Custom Fee Direction
                || rpad(l_fee_amount_custom, 15, ' ')                                           -- 524-538 (15) Custom Fee Amount
                || rpad(nvl(trans_data.gl_date, ' '), 8, ' ')                                   -- 539-546 (8) GL Date, YYYYMMDD
                || rpad(nvl(trans_data.dev_fin_cycle_number, ' '), 10, ' ')                     -- 547-556 (10) Device Financial Cycle Number
                || rpad(nvl(trans_data.document_type, ' '), 1, ' ')                             -- 557-557 (1) Document Type
                || rpad(nvl(trans_data.primary_document, ' '), 10, ' ')                         -- 558-569 (10) Primary Document
                || rpad(nvl(trans_data.sourse_id_spec, ' '), 2, ' ')                            -- 568-569 (2) Source Identification Specification
                || rpad(nvl(trans_data.target_id_spec, ' '), 2, ' ')                            -- 570-571 (2) Target Identification Specification
                || rpad(' ', 76, ' ')                                                           -- 572-647 (76) Reserved
                || '*';                                                                         -- 648-648 (1) Terminal Symbol

            check_format_row(i_row =>  l_line);

            -- write data
            prc_api_file_pkg.put_line(
                i_raw_data     => l_line
              , i_sess_file_id => l_session_file_id
            );
            prc_api_file_pkg.put_file(
                i_sess_file_id => l_session_file_id
              , i_clob_content => l_line || c_CRLF
              , i_add_to       => com_api_const_pkg.TRUE
            );
            log_upload_oper(
                i_oper_id         => trans_data.reg_number_doc
              , i_session_file_id => l_session_file_id
              , i_upload_oper_id  => trans_data.reg_number_doc
              , i_file_type       => 'FLTPOWCS'
            );

            l_line_number := l_line_number + 1; -- to switch row counter
        end loop;

        update evt_event_object eo
           set eo.status = evt_api_const_pkg.EVENT_STATUS_DO_NOT_PROCES
             , proc_session_id = get_session_id
         where decode(eo.status, 'EVST0001', eo.procedure_name, null) = 'CST_OW_PKG.UPLOAD_C_FILE'
           and eo.id <= i_event_max
           and eo.inst_id = i_inst_id;

    end write_transaction_data;

begin
    savepoint c_start_batch_upload;

    select min(eo.object_id)
         , max(eo.object_id)
         , min(eo.id)
         , max(eo.id)
      into l_oper_min
         , l_oper_max
         , l_min_evt_id
         , l_max_evt_id
      from evt_event_object eo
     where decode(eo.status, 'EVST0001', eo.procedure_name, null) = 'CST_OW_PKG.UPLOAD_C_FILE'
       and eo.inst_id = i_inst_id
       and eo.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION;

    trc_log_pkg.debug(i_text => 'OpenWay C-file generation start');
    prc_api_stat_pkg.log_start;

    if check_to_upload_c_file(i_inst_id => i_inst_id) = com_api_type_pkg.TRUE then
        -- get file_name
        l_file_name := create_file_name(i_inst_id => i_inst_id);

        prc_api_file_pkg.open_file(
            o_sess_file_id => l_session_file_id
          , i_file_name    => l_file_name
          , i_file_type    => 'FLTPOWCS' -- OpenWay c-file standart
          , io_params      => l_params
        );

        trc_log_pkg.debug(i_text => 'OpenWay C-file generation start. File type: FLTPOWCS');

        create_file_header(i_inst_id => i_inst_id);

        l_inst_ow := get_inst_for_settings(i_inst_id => i_inst_id);

        write_transaction_data(
            i_inst_id   => i_inst_id
          , i_oper_min  => l_oper_min
          , i_oper_max  => l_oper_max
          , i_event_min => l_min_evt_id
          , i_event_max => l_max_evt_id
        );

        trc_log_pkg.debug(i_text => 'Write transaction data ended');

        create_file_trailer;
        trc_log_pkg.debug(i_text => 'Write file trailer ended');

        evt_api_event_pkg.process_event_object(i_event_object_id_tab => l_event_object_id);
        trc_log_pkg.debug(i_text => 'process_event_object ended');

    end if;

    prc_api_stat_pkg.log_end(
        i_processed_total => l_count
      , i_result_code     => prc_api_const_pkg.process_result_success
    );

    trc_log_pkg.debug(i_text => 'OpenWay C-file generation end');
exception
    when others then
        rollback to savepoint c_start_batch_upload;

        prc_api_stat_pkg.log_end(i_result_code => prc_api_const_pkg.process_result_failed);
        trc_log_pkg.debug(i_text => 'OpenWay C-file generation end with error');

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;

        raise;
end upload_c_file_ow;

function get_currency(
    i_cur               in com_api_type_pkg.t_curr_code
  , i_inst_id           in com_api_type_pkg.t_inst_id
) return com_api_type_pkg.t_curr_code is
    l_cur           com_api_type_pkg.t_curr_code;
begin
   if i_cur = '643' then
      select '810'
        into l_cur
        from com_array_element
       where array_id = -50000015 --array of instututions with russian currency=810
         and element_value = to_char(i_inst_id);
   else
      l_cur := i_cur;
   end if;

   return l_cur;
exception
   when no_data_found then
      l_cur := i_cur;
      return l_cur;
end get_currency;

function get_contra_entry_channel_ow(
    i_inst_id           in com_api_type_pkg.t_inst_id
  , i_sttl_type         in com_api_type_pkg.t_dict_value
  , i_oper_id           in com_api_type_pkg.t_long_id
  , i_network_id        in com_api_type_pkg.t_inst_id
) return com_api_type_pkg.t_byte_char is
    l_acq_inst             com_api_type_pkg.t_inst_id;
    l_iss_inst             com_api_type_pkg.t_inst_id;
    l_contra_entry_channel com_api_type_pkg.t_byte_char;
begin
    l_contra_entry_channel := ' ';
    if i_inst_id = '2003' then
        l_contra_entry_channel := case when i_sttl_type = opr_api_const_pkg.SETTLEMENT_USONUS
                                        and cst_util_pkg.is_nspk(i_oper_id => i_oper_id) = 1 then '1'
                                       when cst_util_pkg.is_nspk(i_oper_id => i_oper_id) = 1 then 'N'
                                       when i_network_id in (1003, 5004, 5005) then 'V'
                                       when i_network_id = '1002' then 'M'
                                       else ' '
                                  end;
    else
        select p.inst_id
          into l_acq_inst
          from opr_participant p
         where p.oper_id = i_oper_id
           and p.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER;

        select p.inst_id
          into l_iss_inst
          from opr_participant p
         where p.oper_id = i_oper_id
           and p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER;

        l_contra_entry_channel := case when i_sttl_type = opr_api_const_pkg.SETTLEMENT_USONUS then 'A'
                                       when i_sttl_type = opr_api_const_pkg.SETTLEMENT_USONUS_INTERINST then '4'
                                       when (i_sttl_type = opr_api_const_pkg.SETTLEMENT_USONTHEM and l_acq_inst = 2006) or
                                            (i_sttl_type = opr_api_const_pkg.SETTLEMENT_THEMONUS and l_iss_inst = 2006) then 'O'
                                       when (i_sttl_type = opr_api_const_pkg.SETTLEMENT_USONTHEM and l_acq_inst = 9944) or
                                            (i_sttl_type = opr_api_const_pkg.SETTLEMENT_THEMONUS and l_iss_inst = 9944) then 'V'
                                       when (i_sttl_type = opr_api_const_pkg.SETTLEMENT_USONTHEM and l_acq_inst in (9001, 9954)) or
                                            (i_sttl_type = opr_api_const_pkg.SETTLEMENT_THEMONUS and l_iss_inst in (9001, 9954)) then 'E'
                                       when (i_sttl_type = opr_api_const_pkg.SETTLEMENT_USONTHEM and l_acq_inst = 9949) or
                                            (i_sttl_type = opr_api_const_pkg.SETTLEMENT_THEMONUS and l_iss_inst = 9949) then 'N'
                                       when (i_sttl_type = opr_api_const_pkg.SETTLEMENT_USONTHEM and l_acq_inst in (9009, 9959)) or
                                            (i_sttl_type = opr_api_const_pkg.SETTLEMENT_THEMONUS and l_iss_inst in (9009, 9959)) then 'S'
                                       when i_sttl_type = opr_api_const_pkg.SETTLEMENT_THEMONUS and l_iss_inst in (9969) then 'W'
                                       else ' '
                                  end;

    end if;
    return l_contra_entry_channel;
end get_contra_entry_channel_ow;

function get_trans_type_ow(
    i_inst_id           in com_api_type_pkg.t_inst_id
  , i_oper_type         in com_api_type_pkg.t_dict_value
  , i_msgt_type         in com_api_type_pkg.t_dict_value
  , i_card_type_id      in com_api_type_pkg.t_inst_id
  , i_is_reversal       in com_api_type_pkg.t_boolean
  , i_terminal_type     in com_api_type_pkg.t_dict_value
  , i_sttl_type         in com_api_type_pkg.t_dict_value
  , i_id                in com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_dict_value is
    l_trans_type    com_api_type_pkg.t_dict_value;
    l_network_id    com_api_type_pkg.t_inst_id;
    l_card_feature  com_api_type_pkg.t_dict_value;
    c_any_value     constant com_api_type_pkg.t_byte_char := '*';
    l_terminal_type com_api_type_pkg.t_dict_value;
begin
    l_terminal_type := i_terminal_type;
    trc_log_pkg.debug(
        i_text => 'i_inst_id=' || i_inst_id ||
                  ', i_oper_type=' || i_oper_type ||
                  ', i_msgt_type=' || i_msgt_type ||
                  ', i_card_type_id=' || i_card_type_id ||
                  ', i_is_reversal=' || i_is_reversal ||
                  ', i_terminal_type=' || i_terminal_type ||
                  ', i_sttl_type=' || i_sttl_type
    );

    begin
        select ct.network_id
             , nvl(cf.card_feature, c_any_value)
          into l_network_id
             , l_card_feature
          from net_card_type ct, net_card_type_feature cf
         where ct.id = i_card_type_id
           and ct.id = cf.card_type_id(+)
           and cf.card_feature in ('CFCHELEC', 'CFCHSTDR');
    exception
        when no_data_found then
            null;
    end;

    trc_log_pkg.debug(
        i_text => 'l_network_id=' || l_network_id
    );

    if i_msgt_type != opr_api_const_pkg.MESSAGE_TYPE_CHARGEBACK then
        select e.out_element_value
          into l_trans_type
          from com_array_conv_elem e
             , com_array a
             , com_array_conversion c
         where e.conv_id = c.id
           and c.out_array_id = a.id
           and c.id = -5001 -- Conversion to OpenWay Transaction types
           and (e.in_element_value = i_inst_id || '/' || i_oper_type || '/' || i_msgt_type || '/' || l_card_feature || '/' || l_network_id || '/' || i_is_reversal || '/' || l_terminal_type || '/' || i_sttl_type or
                e.in_element_value = i_inst_id || '/' || c_any_value || '/' || i_msgt_type || '/' || l_card_feature || '/' || l_network_id || '/' || i_is_reversal || '/' || l_terminal_type || '/' || i_sttl_type or
                e.in_element_value = i_inst_id || '/' || i_oper_type || '/' || c_any_value || '/' || l_card_feature || '/' || l_network_id || '/' || i_is_reversal || '/' || l_terminal_type || '/' || i_sttl_type or
                e.in_element_value = i_inst_id || '/' || i_oper_type || '/' || i_msgt_type || '/' || c_any_value    || '/' || l_network_id || '/' || i_is_reversal || '/' || l_terminal_type || '/' || i_sttl_type or
                e.in_element_value = i_inst_id || '/' || i_oper_type || '/' || i_msgt_type || '/' || l_card_feature || '/' || l_network_id || '/' || i_is_reversal || '/' || c_any_value     || '/' || i_sttl_type or
                e.in_element_value = i_inst_id || '/' || i_oper_type || '/' || i_msgt_type || '/' || l_card_feature || '/' || l_network_id || '/' || i_is_reversal || '/' || l_terminal_type || '/' || c_any_value or
                e.in_element_value = i_inst_id || '/' || c_any_value || '/' || c_any_value || '/' || l_card_feature || '/' || l_network_id || '/' || i_is_reversal || '/' || l_terminal_type || '/' || i_sttl_type or
                e.in_element_value = i_inst_id || '/' || i_oper_type || '/' || c_any_value || '/' || l_card_feature || '/' || l_network_id || '/' || i_is_reversal || '/' || c_any_value     || '/' || i_sttl_type or
                e.in_element_value = i_inst_id || '/' || i_oper_type || '/' || c_any_value || '/' || l_card_feature || '/' || l_network_id || '/' || i_is_reversal || '/' || c_any_value     || '/' || c_any_value or
                e.in_element_value = i_inst_id || '/' || i_oper_type || '/' || i_msgt_type || '/' || l_card_feature || '/' || l_network_id || '/' || i_is_reversal || '/' || c_any_value     || '/' || c_any_value
               );
    else
        select e.out_element_value
          into l_trans_type
          from com_array_conv_elem e
             , com_array a
             , com_array_conversion c
         where e.conv_id = c.id
           and c.out_array_id = a.id
           and c.id = -5001 -- Conversion to OpenWay Transaction types'
           and (e.in_element_value = i_inst_id || '/' || i_oper_type || '/' || i_msgt_type || '/' || l_card_feature || '/' || l_network_id || '/' || i_is_reversal || '/' || l_terminal_type || '/' || i_sttl_type or
                e.in_element_value = i_inst_id || '/' || c_any_value || '/' || i_msgt_type || '/' || l_card_feature || '/' || l_network_id || '/' || i_is_reversal || '/' || l_terminal_type || '/' || i_sttl_type or
                e.in_element_value = i_inst_id || '/' || i_oper_type || '/' || i_msgt_type || '/' || c_any_value    || '/' || l_network_id || '/' || i_is_reversal || '/' || l_terminal_type || '/' || i_sttl_type or
                e.in_element_value = i_inst_id || '/' || i_oper_type || '/' || i_msgt_type || '/' || l_card_feature || '/' || l_network_id || '/' || i_is_reversal || '/' || c_any_value     || '/' || i_sttl_type or
                e.in_element_value = i_inst_id || '/' || i_oper_type || '/' || i_msgt_type || '/' || l_card_feature || '/' || l_network_id || '/' || i_is_reversal || '/' || l_terminal_type || '/' || c_any_value or
                e.in_element_value = i_inst_id || '/' || c_any_value || '/' || i_msgt_type || '/' || l_card_feature || '/' || l_network_id || '/' || i_is_reversal || '/' || c_any_value     || '/' || i_sttl_type
               );

    end if;
    return l_trans_type;
exception
    when no_data_found then
        trc_log_pkg.error(
            i_text => 'Mapping [' || i_inst_id || '/' || i_oper_type || '/' || i_msgt_type || '/' || l_card_feature || '/' || l_network_id || '/' || i_is_reversal || '/' || l_terminal_type || '/' || i_sttl_type ||
                      '] is not found for operation_id=' || i_id
        );
        com_api_error_pkg.raise_error(
            i_error        => 'UNHANDLED_EXCEPTION'
          , i_env_param1   => SQLERRM
        );
end get_trans_type_ow;

function get_payment_purpose(
    i_tag_value         in varchar2
) return varchar2 is
    l_tag_value varchar2(4000);

    function i_get_payment_purpose(
        i_tag_value     in varchar2
    ) return varchar2 is
        l_tab       itf_api_type_pkg.tag_value_tab;
        l_inner_tab itf_api_type_pkg.tag_value_tab;
        l_tmp_val1  varchar2(4000);
        l_tmp_val2  varchar2(4000);
    begin
        itf_api_tlv_pkg.get_tlv_tab(
            i_string   => i_tag_value
          , o_tags_tab => l_tab
        );

        for i in 1 .. l_tab.count loop
            itf_api_tlv_pkg.get_tlv_tab(
                i_string   => l_tab(i).value
              , o_tags_tab => l_inner_tab
            );

            l_tmp_val1 := '';
            l_tmp_val2 := '';

            for j in 1 .. l_inner_tab.count loop
                if l_inner_tab(j).tag = 'DF842A' then
                    l_tmp_val1 := l_inner_tab(j).value;
                elsif l_inner_tab(j).tag = 'DF842C' then
                    l_tmp_val2 := l_inner_tab(j).value;
                end if;
            end loop;

            if l_tmp_val1 = '200' then
                return l_tmp_val2;
            end if;
        end loop;
        return 'no_tag';
    end i_get_payment_purpose;
begin

    l_tag_value := i_get_payment_purpose(i_tag_value);

    return com_api_array_pkg.conv_array_elem_v(
               i_array_type_id => -5011
             , i_array_id      => -50000013
             , i_inst_id       => 9999
             , i_elem_value    => l_tag_value
             , i_mask_error    => 1
             , i_error_value   => l_tag_value
           );

end get_payment_purpose;

function mapping_inst_for_upload_abs(
    i_inst_id           in com_api_type_pkg.t_inst_id)
return com_api_type_pkg.t_inst_id is
    l_inst_id   com_api_type_pkg.t_inst_id;
begin
    select max(out_element_value)
      into l_inst_id
      from com_array_conv_elem
     where conv_id = -5003 -- Mapping institution to upload
       and in_element_value = i_inst_id;

    l_inst_id := nvl (l_inst_id, i_inst_id);
    return l_inst_id;
end mapping_inst_for_upload_abs;

procedure process_file_header (
    i_session_file_id   in com_api_type_pkg.t_long_id
  , i_file_header       in com_api_type_pkg.t_raw_data
  , i_end_symbol        in com_api_type_pkg.t_byte_char := chr(10)
) is
begin
    prc_api_file_pkg.put_line(
        i_raw_data      => i_file_header
      , i_sess_file_id  => i_session_file_id
    );
    prc_api_file_pkg.put_file(
        i_sess_file_id   => i_session_file_id
      , i_clob_content   => i_file_header || i_end_symbol
      , i_add_to         => com_api_const_pkg.TRUE
    );
end process_file_header;

procedure process_file_trailer(
    i_session_file_id   in com_api_type_pkg.t_long_id
  , i_file_trailer      in com_api_type_pkg.t_raw_data
  , i_end_symbol        in com_api_type_pkg.t_byte_char := chr(10)
) is
begin
    prc_api_file_pkg.put_line(
        i_raw_data      => i_file_trailer
      , i_sess_file_id  => i_session_file_id
    );
    prc_api_file_pkg.put_file(
        i_sess_file_id   => i_session_file_id
      , i_clob_content   => i_file_trailer || i_end_symbol
      , i_add_to         => com_api_const_pkg.TRUE
    );
end;

procedure check_format_row_m_ow(
    i_row               in com_api_type_pkg.t_raw_data
) is
    l_length_row    com_api_type_pkg.t_short_id := length (i_row);
    l_end_row       com_api_type_pkg.t_byte_char := substr (i_row, 466, 1);
    length_row      com_api_type_pkg.t_short_id := 466;
begin
    if l_length_row != length_row or l_end_row != '*' then
        trc_log_pkg.error(
            i_text         => 'INVALID_FORMAT_ROW: [#1]'
          , i_env_param1   => i_row
        );

        com_api_error_pkg.raise_error(
            i_error        => 'UNHANDLED_EXCEPTION'
          , i_env_param1   => sqlerrm
        );
    end if;
end check_format_row_m_ow;

procedure log_upload_oper(
    i_oper_id           in com_api_type_pkg.t_long_id
  , i_session_file_id   in com_api_type_pkg.t_long_id
  , i_upload_oper_id    in com_api_type_pkg.t_long_id
  , i_file_type         in com_api_type_pkg.t_dict_value
) is
begin
    insert into cst_oper_file (
        id
      , oper_id
      , session_file_id
      , upload_oper_id
      , file_type
    ) values (
        cst_oper_file_seq.nextval
      , i_oper_id
      , i_session_file_id
      , i_upload_oper_id
      , i_file_type
    );
exception
    when dup_val_on_index then
        null;
end log_upload_oper;

function get_inst_for_settings(
    i_inst_id           in com_api_type_pkg.t_inst_id
) return com_api_type_pkg.t_inst_id is
    l_inst_ow       com_api_type_pkg.t_inst_id;
begin
    select max(d.field_value)
      into l_inst_ow
      from com_flexible_data d
         , com_flexible_field f
     where d.object_id = i_inst_id
       and d.field_id = f.id
       and f.name = 'INST_FOR_OW_FILES';   -- flexible field for institution for OW-files

    return nvl(l_inst_ow, i_inst_id);
end get_inst_for_settings;

function check_to_upload_m_file(
    i_inst_id           in com_api_type_pkg.t_inst_id
) return com_api_type_pkg.t_boolean is
    l_count         com_api_type_pkg.t_long_id;
begin
    select count(*)
      into l_count
      from opr_operation oo
         , opr_participant op
     where oo.status = opr_api_const_pkg.OPERATION_STATUS_PROCESSED
       and op.oper_id = oo.id
       and op.inst_id = i_inst_id
       and op.participant_type = COM_API_CONST_PKG.PARTICIPANT_ACQUIRER
       and exists (select 1
                     from evt_event_object eo
                    where eo.object_id = oo.id
                      and decode(eo.status, 'EVST0001', eo.procedure_name, null) = 'CST_OW_PKG.UPLOAD_M_FILE'
                      and eo.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION)
       and exists (select 1
                     from acc_entry e
                        , acc_macros m
                    where e.macros_id = m.id
                      and m.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                      and m.object_id = oo.id
                      and e.balance_type in (acc_api_const_pkg.BALANCE_TYPE_LEDGER
                                           , acc_api_const_pkg.BALANCE_TYPE_USED_EXCEED_LIMIT)
                  )
       and rownum < 2;
 return l_count;

end check_to_upload_m_file;

procedure check_format_row(
    i_row               in com_api_type_pkg.t_raw_data
) is
    l_is_reversal       com_api_type_pkg.t_byte_char := substr(i_row, 557, 1);
    l_length_row        com_api_type_pkg.t_short_id := length(i_row);
    l_end_row           com_api_type_pkg.t_byte_char := substr(i_row, 648, 1);
    length_row          com_api_type_pkg.t_short_id := 648;
begin
    if l_is_reversal not in ('O', 'R') or l_length_row != length_row or l_end_row != '*' then
        trc_log_pkg.error(
            i_text         => 'INVALID_FORMAT_ROW: [#1]'
          , i_env_param1   => i_row);

        com_api_error_pkg.raise_error(
            i_error        => 'UNHANDLED_EXCEPTION'
          , i_env_param1   => sqlerrm
        );
    end if;
end check_format_row;

function check_to_upload_c_file(
    i_inst_id           in com_api_type_pkg.t_inst_id
) return com_api_type_pkg.t_boolean is
    l_count             com_api_type_pkg.t_long_id;
begin
    select count(*)
      into l_count
      from opr_operation oo
     where oo.status = opr_api_const_pkg.OPERATION_STATUS_PROCESSED
       and exists (select 1
                     from evt_event_object eo
                    where eo.object_id = oo.id
                      and decode(eo.status, 'EVST0001', eo.procedure_name, null) = 'CST_OW_PKG.UPLOAD_C_FILE'
                      and eo.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                      and eo.inst_id = i_inst_id
                      )
       and exists (select 1
                     from acc_entry e
                        , acc_macros m
                    where e.macros_id = m.id
                      and m.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                      and m.object_id = oo.id
                      and e.balance_type in (acc_api_const_pkg.BALANCE_TYPE_LEDGER
                                           , acc_api_const_pkg.BALANCE_TYPE_USED_EXCEED_LIMIT)
                  )
       and rownum < 2;

    return l_count;
end check_to_upload_c_file;

end cst_ow_pkg;
/
