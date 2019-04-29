create or replace package body itf_prc_entry_pkg is

    BULK_LIMIT      constant integer := 500;

    function get_reletad_id(i_id            in com_api_type_pkg.t_long_id
                            , i_original_id in com_api_type_pkg.t_long_id
                            , i_is_reversal in com_api_type_pkg.t_boolean) 
        return com_api_type_pkg.t_long_id  is
        l_id com_api_type_pkg.t_long_id;
    begin
        select max(o.id) into l_id
          from
              evt_event_object v
              , acc_entry e
              , acc_account  a
              , acc_macros m
              , opr_operation_participant_vw o
         where decode(v.status, 'EVST0001', v.procedure_name, null) = 'ITF_PRC_ENTRY_PKG.UPLOAD_ENTRY_OBI'  -- using index evt_event_object_status
           and v.entity_type  = acc_api_const_pkg.ENTITY_TYPE_ENTRY
           and v.object_id    = e.id
           and e.balance_type = acc_api_const_pkg.BALANCE_TYPE_LEDGER
           and e.account_id   = a.id
           and e.macros_id    = m.id
           and m.object_id    = o.id
           and m.entity_type  = opr_api_const_pkg.ENTITY_TYPE_OPERATION
           and ((i_original_id is not null and o.id = i_original_id and i_is_reversal = 1) or (i_original_id is null and o.original_id = i_id and o.is_reversal = 1)); 
      
        return l_id;
    end;
    
    procedure upload_entry_obi (
        i_inst_id                 in com_api_type_pkg.t_inst_id
        , i_agent_id              in com_api_type_pkg.t_agent_id
        , i_transaction_type      in com_api_type_pkg.t_dict_value := null
        , i_start_date            in date := null
        , i_end_date              in date := null
        , i_shift_from            in com_api_type_pkg.t_tiny_id := 0
        , i_shift_to              in com_api_type_pkg.t_tiny_id := 0
    ) is
        --
        cursor l_entrys(
            p_inst_id          com_api_type_pkg.t_inst_id,
            p_agent_id         com_api_type_pkg.t_agent_id,
            p_transaction_type com_api_type_pkg.t_dict_value,
            p_start_date       date,
            p_end_date         date
        ) is
        select
            v.id
            , a.account_number
            , a.account_type
            , e.amount
            , (case when e.balance_impact = com_api_const_pkg.DEBIT then 'DR' else 'CR' end)
            , e.currency
            , e.posting_date
            , e.id
            , e.transaction_type
            , get_user_name
            --, a2.account_number
            , (case when o.oper_type in
                        (opr_api_const_pkg.OPERATION_TYPE_ISSUER_FEE
                         , opr_api_const_pkg.OPERATION_TYPE_ACQUIRER_FEE)
                        and o.oper_reason is not null 
                    then o.oper_reason
                    else o.oper_type
              end) oper_type
            , (o.merchant_name
                ||'\'||o.merchant_postcode
                ||'\'||o.merchant_street
                ||'\'||o.merchant_city
                ||'\'||o.merchant_region
                ||'\'||o.merchant_country) as transaction_place
            , o.card_number optional_1
            , o.mcc optional_2
            , o.auth_code optional_3
            , o.host_date optional_4
            , o.oper_amount optional_5
            , (case when o.sttl_amount is null and o.sttl_currency is null then o.oper_amount else o.sttl_amount end) as optional_6
            , o.oper_currency optional_7
            , (case when o.sttl_currency is null and o.sttl_amount is null then o.oper_currency else o.sttl_currency end) as optional_8
            , o.id as oper_id
            , o.terminal_number
            , o.merchant_number
            , o.originator_refnum  as retrieval_refnum
            , a.contract_id
            , ( select case when balance > 0 then 1 else 0 end
                  from acc_balance b
                 where b.account_id = a.id
                   and b.balance_type = crd_api_const_pkg.BALANCE_TYPE_ASSIGNED_EXCEED) as contract_indicator
            --, null acq_bin
            , a2.account_number
            , a2.currency
            --, '' fo_trans_number
            --, '' service_id
            --, '' ext_trans_number
            , o.card_network_id as card_network
            , o.sttl_type as settlement_type
            --
            , row_number() over(order by e.id) as rn
            , row_number() over(order by e.id desc) as rn_desc
            , count(e.id) over() as cnt
            , itf_prc_entry_pkg.get_reletad_id(o.id, o.original_id, o.is_reversal) as refer_opr
        from
            evt_event_object v
            , acc_entry e
            , acc_account  a
            , acc_macros m
            , opr_operation_participant_vw o
            , acc_entry e2
            , acc_account a2
        where 1=1
          and decode(v.status, 'EVST0001', v.procedure_name, null) = 'ITF_PRC_ENTRY_PKG.UPLOAD_ENTRY_OBI'  -- using index evt_event_object_status
          and v.entity_type  = acc_api_const_pkg.ENTITY_TYPE_ENTRY
          and v.eff_date     >= nvl(p_start_date, v.eff_date) 
          and v.eff_date     <= p_end_date
          and v.inst_id      = p_inst_id
          and v.object_id    = e.id
          and e.balance_type = acc_api_const_pkg.BALANCE_TYPE_LEDGER
          and e.account_id   = a.id
          and e.macros_id    = m.id
          and m.object_id    = o.id
          and m.entity_type  = opr_api_const_pkg.ENTITY_TYPE_OPERATION
          and e2.transaction_id(+) = e.transaction_id
          and e2.id(+)       != e.id
          and a2.id(+)       = e2.account_id
          and (a.agent_id    = p_agent_id or p_agent_id is null)
          and substr(e.transaction_type, 5) like nvl(p_transaction_type, '%')
        order by
            e.id;
        --
        l_event_object_id         com_api_type_pkg.t_number_tab;
        l_entry_id                com_api_type_pkg.t_number_tab;
        l_account_number          com_api_type_pkg.t_account_number_tab;
        l_account_type            com_api_type_pkg.t_dict_tab;
        l_amount                  com_api_type_pkg.t_number_tab;
        l_balance_impact          com_api_type_pkg.t_dict_tab;
        l_currency                com_api_type_pkg.t_curr_code_tab;
        l_posting_date            com_api_type_pkg.t_date_tab;
        l_user_id                 com_api_type_pkg.t_name_tab;
        l_transaction_type        com_api_type_pkg.t_name_tab;
        l_oper_type               com_api_type_pkg.t_dict_tab;
        l_transaction_place       com_api_type_pkg.t_name_tab;
        l_optional_1              com_api_type_pkg.t_name_tab;
        l_optional_2              com_api_type_pkg.t_name_tab;
        l_optional_3              com_api_type_pkg.t_name_tab;
        l_optional_4              com_api_type_pkg.t_date_tab;
        l_optional_5              com_api_type_pkg.t_name_tab;
        l_optional_6              com_api_type_pkg.t_name_tab;
        l_optional_7              com_api_type_pkg.t_name_tab;
        l_optional_8              com_api_type_pkg.t_name_tab;
        l_oper_id                 com_api_type_pkg.t_number_tab;
        l_terminal_number         com_api_type_pkg.t_name_tab;
        l_merchant_number         com_api_type_pkg.t_name_tab;
        l_retrieval_refnum        com_api_type_pkg.t_name_tab;
        l_contract_id             com_api_type_pkg.t_name_tab;
        l_contract_indicator      com_api_type_pkg.t_boolean_tab;
        l_account_number2         com_api_type_pkg.t_account_number_tab;
        l_account_currency2       com_api_type_pkg.t_curr_code_tab;
        l_card_network            com_api_type_pkg.t_number_tab;
        l_sttl_type               com_api_type_pkg.t_dict_tab;
        l_refer_id                com_api_type_pkg.t_number_tab;

        l_record_number           com_api_type_pkg.t_number_tab;
        l_record_number_desc      com_api_type_pkg.t_number_tab;
        l_count                   com_api_type_pkg.t_number_tab;

        l_current_count           com_api_type_pkg.t_long_id := 0;
        l_processed_count         com_api_type_pkg.t_long_id := 0;
        l_session_file_id         com_api_type_pkg.t_long_id;
        l_rec_raw                 com_api_type_pkg.t_raw_tab;
        l_rec_num                 com_api_type_pkg.t_integer_tab;
        l_is_trailer_save         com_api_type_pkg.t_boolean :=  com_api_type_pkg.FALSE;
        --
        l_start_date              date;
        l_end_date                date;
        l_crc                     integer;
        --
        procedure open_file is
        begin
            --
            prc_api_file_pkg.open_file (
                o_sess_file_id  => l_session_file_id
            );
            --l_session_file_id := 123456;
            --dbms_output.put_line('open_file l_session_file_id = ' || l_session_file_id ||' l_file_name = ' || l_file_name);
        end open_file;
        --
        procedure put_file is
        begin
            /*for j in 1 .. l_rec_raw.count loop
                dbms_output.put_line('rec_num: '||l_rec_num(j) || ' rec_row: ' || l_rec_raw(j));
            end loop;*/
            --
            prc_api_file_pkg.put_bulk (
                i_sess_file_id  => l_session_file_id
                , i_raw_tab     => l_rec_raw
                , i_num_tab     => l_rec_num
            );
            --
            l_rec_raw.delete;
            l_rec_num.delete;
        end put_file;
        --
    begin
        prc_api_stat_pkg.log_start;
        --
        l_start_date := trunc(i_start_date);
        if nvl(i_shift_from, 0) != 0 then
            l_start_date := trunc(nvl(l_start_date, get_sysdate)) + nvl(i_shift_from, 0);
        end if;
        l_end_date := trunc(nvl(i_end_date, get_sysdate)) + 1 - com_api_const_pkg.ONE_SECOND;
        l_end_date := l_end_date + nvl(i_shift_to, 0);
        --
        trc_log_pkg.debug('start_date[' ||com_api_type_pkg.convert_to_char(l_start_date) || '] l_end_date[' || 
                          com_api_type_pkg.convert_to_char(l_end_date)||']');
        trc_log_pkg.debug('i_shift_from[' ||i_shift_from || '] i_shift_to[' || i_shift_to||']');
        -- 1 open main cursor
        open l_entrys(i_inst_id, i_agent_id, i_transaction_type, l_start_date, l_end_date);
        --
        loop
            fetch l_entrys
            bulk collect into
                l_event_object_id
                , l_account_number
                , l_account_type
                , l_amount
                , l_balance_impact
                , l_currency
                , l_posting_date
                , l_entry_id
                , l_transaction_type
                , l_user_id
                , l_oper_type
                , l_transaction_place
                , l_optional_1
                , l_optional_2
                , l_optional_3
                , l_optional_4
                , l_optional_5
                , l_optional_6
                , l_optional_7
                , l_optional_8
                , l_oper_id
                , l_terminal_number
                , l_merchant_number
                , l_retrieval_refnum
                , l_contract_id
                , l_contract_indicator
                , l_account_number2
                , l_account_currency2
                , l_card_network
                , l_sttl_type
                , l_record_number
                , l_record_number_desc
                , l_count
                , l_refer_id
            limit BULK_LIMIT;
            --
            l_rec_raw.delete; -- records content tab
            l_rec_num.delete; -- records counter tab
            -- 2 - forming collection of rows
            for i in 1..l_entry_id.count loop
                
                if l_refer_id(i) is not null then
                    continue;
                end if;
            
                -- 2.1 if first record (open_file, put first_row = RCTP01)
                if l_session_file_id is null then
                    --
                    l_processed_count := l_processed_count + 1;
                    -- set estimated count
                    prc_api_stat_pkg.log_estimation (
                        i_estimated_count  => l_count(i)
                      , i_measure          => acc_api_const_pkg.ENTITY_TYPE_ENTRY
                    );
                    -- 2.1.1 open file (register file_name in prc_session_file table)
                    open_file;
                    -- 2.1.2 put header = RCTP01
                    l_rec_raw(l_rec_raw.count + 1) :=
                        itf_api_type_pkg.pad_char(itf_api_const_pkg.RT_FILE_HEADER, 8, 8) || -- Record Type
                        itf_api_type_pkg.pad_number(l_processed_count, 12, 12) || -- Record Number
                        itf_api_type_pkg.pad_number(to_char(l_session_file_id), 18, 18) || -- Original File ID
                        ' ' || -- Filler
                        'FTYPOBI ' || -- File Type (8 char)
                        itf_api_type_pkg.pad_char(to_char(get_sysdate, 'MMDDYYYYY'), 8, 8) || -- Date
                        itf_api_type_pkg.pad_char(to_char(get_sysdate, 'HH24MISS'), 6, 6)  || -- Time
                        ' ' ||-- Filler
                        itf_api_type_pkg.pad_char(i_inst_id, 12, 12)  || -- Institution ID
                        itf_api_type_pkg.pad_char(i_agent_id, 12, 12) || -- Agent Institution ID
                        ' ' || -- Filler
                        itf_api_type_pkg.pad_char(' ', 8, 8) || -- FE Settlement Date
                        itf_api_type_pkg.pad_char(' ', 6, 6) || -- FE Settlement Time
                        itf_api_type_pkg.pad_char(to_char(l_start_date, 'YYYYMMDD'), 8, 8) || -- BO Settlement Day Start Date
                        itf_api_type_pkg.pad_char(to_char(l_start_date, 'HH24MISS'), 6, 6) || -- BO Settlement Day Start Time
                        itf_api_type_pkg.pad_char(' ', 6, 6) || -- BO Settlement Day Number
                        itf_api_type_pkg.pad_char(' ', 377, 377);-- Filler
                    --
                    l_rec_num(l_rec_num.count + 1) := l_processed_count;
                    --
                    l_crc := itf_api_utils_pkg.crc32 (
                        i_raw_data  => l_rec_raw(l_rec_raw.count)
                        , i_crc     => l_crc
                    );
                end if;
                
                -- 2.2 transaction records goes to RCTP10
                l_processed_count := l_processed_count + 1;
                l_rec_raw(l_rec_raw.count + 1) :=
                    itf_api_type_pkg.pad_char(itf_api_const_pkg.RT_OCP_BATCH_TRAILER, 8, 8)|| -- Record Type
                    itf_api_type_pkg.pad_number(l_processed_count, 12, 12)   || -- Record Number
                    itf_api_type_pkg.pad_char(l_account_number(i), 32, 32)   || -- Account Number
                    itf_api_type_pkg.pad_char(l_account_type(i), 8, 8)       || -- BO Account type
                    ' ' || -- Filler
                    itf_api_type_pkg.pad_number(l_amount(i), 12, 12)         || -- Amount
                    itf_api_type_pkg.pad_char(l_balance_impact(i), 2, 2)     || -- Debit/Credit Indicator
                    itf_api_type_pkg.pad_char(l_currency(i), 3, 3)           || -- Currency Code
                    ' ' || -- Filler
                    itf_api_type_pkg.pad_char(to_char(l_posting_date(i), 'MMDDYYYY'), 8, 8) || -- Effective Date
                    ' ' || -- Filler
                    itf_api_type_pkg.pad_number(l_entry_id(i), 16, 16)       || -- Reference
                    ' ' || -- Filler
                    itf_api_type_pkg.pad_char(l_transaction_type(i), 8, 8)   || -- BO Transaction Type
                    ' ' || -- Filler
                    itf_api_type_pkg.pad_char(l_user_id(i), 3, 3)            || -- User ID
                    ' ' || -- Filler
                    itf_api_type_pkg.pad_char(l_account_number2(i), 32, 32)  || -- Corresponding Account
                    itf_api_type_pkg.pad_char(l_oper_type(i), 8, 8)          || -- FE Trasaction Type
                    ' ' || -- Filler
                    itf_api_type_pkg.pad_char(l_transaction_place(i), 40, 40) || -- Transaction Place
                    itf_api_type_pkg.pad_char(l_optional_1(i), 32, 32)       || -- Optional #1
                    itf_api_type_pkg.pad_char(l_optional_2(i), 32, 32)       || -- Optional #2
                    itf_api_type_pkg.pad_char(l_optional_3(i), 32, 32)       || -- Optional #3
                    itf_api_type_pkg.pad_char(to_char(l_optional_4(i), com_api_const_pkg.DATE_FORMAT), 32, 32) || -- Optional #4
                    itf_api_type_pkg.pad_char(l_optional_5(i), 32, 32)       || -- Optional #5
                    itf_api_type_pkg.pad_char(l_optional_6(i), 32, 32)       || -- Optional #6
                    itf_api_type_pkg.pad_char(l_optional_7(i), 32, 32)       || -- Optional #7
                    itf_api_type_pkg.pad_char(l_optional_8(i), 32, 32)       || -- Optional #8
                    itf_api_type_pkg.pad_number(l_oper_id(i), 12, 12)        || -- Transaction group ID
                    itf_api_type_pkg.pad_char( (case when length(l_terminal_number(i)) >= 8 
                                                   then substr(l_terminal_number(i), -8) 
                                                   else l_terminal_number(i) 
                                                end), 8, 8)    || -- ISO Terminal ID
                    itf_api_type_pkg.pad_char(l_merchant_number(i), 15, 15)  || -- ISO Merchant ID
                    itf_api_type_pkg.pad_char(' ', 8, 8) || -- Filler
                    itf_api_type_pkg.pad_char(l_retrieval_refnum(i), 12, 12) || -- Retrieval Reference Number
                    itf_api_type_pkg.pad_char(' ', 6, 6) || -- System Trace Audit Number
                    ' ' || -- Filler
                    itf_api_type_pkg.pad_char(l_contract_id(i), 6, 6) || -- Card Contract ID
                    itf_api_type_pkg.pad_char(l_contract_indicator(i), 1, 1) || -- Debit/Credit Contract Indicator
                    itf_api_type_pkg.pad_char(' ', 2, 2) || -- Internal Card Type
                    itf_api_type_pkg.pad_char(' ', 6, 6) || -- Acquirer Bin
                    itf_api_type_pkg.pad_char(l_account_number2(i), 32, 32) || -- Account Number 2
                    itf_api_type_pkg.pad_char(l_account_currency2(i), 3, 3) || -- Currency Code Account Number 2
                    ' ' || -- Filler
                    itf_api_type_pkg.pad_number('0', 12, 12) || -- FE Unique Transaction Number
                    itf_api_type_pkg.pad_number('0', 8, 8) || -- Service ID
                    itf_api_type_pkg.pad_char(l_oper_id(i), 30, 30) || -- External Transaction Number
                    itf_api_type_pkg.pad_char(substr(l_card_network(i), -3), 3, 3) || -- Card Network
                    itf_api_type_pkg.pad_char(l_sttl_type(i), 8, 8) || -- Settlement Type
                    itf_api_type_pkg.pad_number('0', 12, 12); -- Installments count
                --
                l_rec_num(l_rec_num.count + 1) := l_processed_count;
                --
                l_crc := itf_api_utils_pkg.crc32 (
                    i_raw_data  => l_rec_raw(l_rec_raw.count)
                    , i_crc     => l_crc
                );
                -- 2.3 if last record (put last_row = RCTP02)
                if l_record_number_desc(i) = 1 then
                    --
                    l_processed_count := l_processed_count + 1;
                    -- put trailer
                    l_rec_raw(l_rec_raw.count + 1) :=
                        itf_api_type_pkg.pad_char(itf_api_const_pkg.RT_FILE_TRAILER, 8, 8) || -- Record Type
                        itf_api_type_pkg.pad_number(l_processed_count, 12, 12) || -- Record Number
                        itf_api_const_pkg.LR_FLAG || -- Last Record Flag
                        itf_api_type_pkg.pad_number(trim(to_char(l_crc,'XXXXXXXX')), 8, 8) || -- Hash Totals
                        itf_api_type_pkg.pad_char(' ', 468, 468);-- Filler
                    l_rec_num(l_rec_num.count + 1) := l_processed_count;
                    
                    l_is_trailer_save := com_api_type_pkg.TRUE;
                end if;
            end loop;                        
            --
            l_current_count := l_current_count + l_entry_id.count;
            --
            -- 3 saving fetched records to prc_file_row_data 
            put_file;
            
            -- 4 clearig account events (changes status of event to processed)
            evt_api_event_pkg.process_event_object(
                i_event_object_id_tab => l_event_object_id
            );
            --
            prc_api_stat_pkg.log_current (
                i_current_count     => l_current_count
                , i_excepted_count  => 0
            );
            --
            exit when l_entrys%notfound;
        end loop;
        
        -- put trailer
        if l_is_trailer_save = com_api_type_pkg.FALSE then
            
            l_processed_count := l_processed_count + 1;
            l_rec_raw(l_rec_raw.count + 1) :=
                itf_api_type_pkg.pad_char(itf_api_const_pkg.RT_FILE_TRAILER, 8, 8) || -- Record Type
                itf_api_type_pkg.pad_number(l_processed_count, 12, 12) || -- Record Number
                itf_api_const_pkg.LR_FLAG || -- Last Record Flag
                itf_api_type_pkg.pad_number(trim(to_char(l_crc,'XXXXXXXX')), 8, 8) || -- Hash Totals
                itf_api_type_pkg.pad_char(' ', 468, 468);-- Filler
            l_rec_num(l_rec_num.count + 1) := l_processed_count;    
                
        end if;
        
        -- 6 close main cursor
        close l_entrys;
        -- 5 close file
        if l_session_file_id is not null then
            prc_api_file_pkg.close_file (
                i_sess_file_id  => l_session_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
            );
        end if;
        --
        if l_current_count = 0 then
            prc_api_stat_pkg.log_estimation (
                i_estimated_count  => l_current_count
              , i_measure          => acc_api_const_pkg.ENTITY_TYPE_ENTRY
            );
        end if;
        prc_api_stat_pkg.log_end (
            i_processed_total  => l_current_count
            , i_result_code    => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        );
    exception
        when others then
            if l_entrys%isopen then
                close l_entrys;
            end if;
            --
            prc_api_stat_pkg.log_end (
                i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
            );
            --
            if l_session_file_id is not null then
                prc_api_file_pkg.close_file (
                    i_sess_file_id  => l_session_file_id
                  , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
                );
            end if;
            --
            if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE then
                com_api_error_pkg.raise_fatal_error (
                    i_error         => 'UNHANDLED_EXCEPTION'
                    , i_env_param1  => sqlerrm
                );
            end if;
            --
            raise;
    end upload_entry_obi;
    
begin
    null;
end itf_prc_entry_pkg;
/
