create or replace package body nbf_prc_reconcil_pkg as

cursor cur_fin_messages is
    select x.msg_id
         , to_date(x.oper_date, com_api_const_pkg.XML_DATETIME_FORMAT) as oper_date
         , x.oper_count
         , x.control_sum
         , count(*) over(partition by msg_id) as msg_oper_count
         , c.payment_info_id
         , c.sender_account_number
         , c.sender_account_currency
         , c.amount
         , c.currency
         , c.reciever_account_number
      from prc_session_file s
         , prc_file_attribute a
         , prc_file f
         , xmltable(
               xmlnamespaces(default 'urn:iso:std:iso:20022:tech:xsd:pain.001.001.05')
             , '/Document/CstmrCdtTrfInitn'
               passing s.file_xml_contents
               columns
                   msg_id                    varchar2(35)  path 'GrpHdr/MsgId'
                 , oper_date                 varchar2(19)  path 'GrpHdr/CreDtTm'
                 , oper_count                number        path 'GrpHdr/NbOfTxs'
                 , control_sum               number        path 'GrpHdr/CtrlSum'
                 , PmtInf_blocks             xmltype       path '/CstmrCdtTrfInitn/*'
           ) x
         , xmltable(
               xmlnamespaces(default 'urn:iso:std:iso:20022:tech:xsd:pain.001.001.05')
             , '/PmtInf'
               passing x.PmtInf_blocks
               columns
                   payment_info_id           varchar2(35)  path 'PmtInfId'
                 , end_to_end                varchar2(35)  path 'CdtTrfTxInf/PmtId/EndToEndId'
                 , instr_id                  varchar2(35)  path 'CdtTrfTxInf/PmtId/InstrId'
                 , sender_account_number     varchar2(20)  path 'DbtrAcct/Id/Othr/Id'
                 , sender_account_currency   varchar2(3)   path 'DbtrAcct/Ccy'
                 , amount                    number        path 'CdtTrfTxInf/Amt/InstdAmt'
                 , currency                  varchar2(3)   path 'CdtTrfTxInf/Amt/InstdAmt/@Ccy'
                 , reciever_account_number   varchar2(20)  path 'CdtTrfTxInf/CdtrAcct/Id/Othr/Id'
           ) c
     where s.session_id = prc_api_session_pkg.get_session_id
       and s.file_attr_id = a.id
       and f.id = a.file_id
     order by s.id;
     
subtype t_cursor_result is cur_fin_messages%rowtype;
type t_cursor_result_tab is table of t_cursor_result index by pls_integer;

procedure process_new_file(
    i_network_id           in com_api_type_pkg.t_network_id
  , o_file                out nbf_api_type_pkg.t_file_rec
)
is
    l_process_id              com_api_type_pkg.t_short_id;
begin
    l_process_id            := prc_api_session_pkg.get_process_id;
    
    o_file.id               := nbf_fin_file_seq.nextval;
    o_file.is_incoming      := com_api_const_pkg.TRUE;
    o_file.network_id       := i_network_id;
    o_file.inst_id          := net_api_network_pkg.get_inst_id(i_network_id => i_network_id);

    -- date beg determined as process last run date
    select max(start_time)
      into o_file.date_beg
      from prc_session
     where process_id = l_process_id;
    
    o_file.date_beg         := nvl(o_file.date_beg, com_api_sttl_day_pkg.get_sysdate - 1);
    o_file.date_end         := com_api_sttl_day_pkg.get_sysdate - (interval '1' second);
end;

procedure save_msg(
    i_msg       nbf_api_type_pkg.t_msg_rec
)
is
    l_msg       nbf_api_type_pkg.t_msg_rec;
begin
    l_msg     := i_msg;
    l_msg.id  := coalesce(l_msg.id, com_api_id_pkg.get_id(nbf_fin_message_seq.nextval, com_api_sttl_day_pkg.get_sysdate));
    
    insert into nbf_fin_message(
        id
      , status
      , file_id
      , is_incoming
      , iss_account_id
      , debit_bank_code
      , debit_account_number
      , credit_bank_code
      , credit_account_number
      , amount
      , currency
      , oper_date
      , rrn
      , oper_id
    )
    values(
        l_msg.id
      , l_msg.status
      , l_msg.file_id
      , l_msg.is_incoming
      , l_msg.iss_account_id
      , l_msg.debit_bank_code
      , l_msg.debit_account_number
      , l_msg.credit_bank_code
      , l_msg.credit_account_number
      , l_msg.amount
      , l_msg.currency
      , l_msg.oper_date
      , l_msg.rrn
      , l_msg.oper_id
    );

end;

procedure save_file(
    i_file             nbf_api_type_pkg.t_file_rec
)
is
begin
    insert into nbf_fin_file (
        id
      , is_incoming
      , network_id
      , inst_id
      , records_total
      , date_beg
      , date_end
    )
    values (
        i_file.id
      , i_file.is_incoming
      , i_file.network_id
      , i_file.inst_id
      , i_file.records_total
      , i_file.date_beg
      , i_file.date_end
    );
end;

function is_record_incoming(
    i_debit_bank_code in varchar2
) return com_api_type_pkg.t_boolean is
    l_bank_participant_code  com_api_type_pkg.t_name;
begin
    l_bank_participant_code :=
        set_ui_value_pkg.get_system_param_v(
            i_param_name => nbf_api_const_pkg.PARAM_PARTICIPANT_CODE
        );
        
    if i_debit_bank_code = l_bank_participant_code then
        return com_api_const_pkg.FALSE;
    else
        return com_api_const_pkg.TRUE;
    end if;
end;

procedure process_record(
    i_file              nbf_api_type_pkg.t_file_rec
  , i_cursor_result     t_cursor_result
)
is
    l_msg                    nbf_api_type_pkg.t_msg_rec;
    l_regexp  constant       com_api_type_pkg.t_name := '(\w+)/(\w+)/(\w+)';
begin
    l_msg.status                  := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;
    l_msg.file_id                 := i_file.id;
    l_msg.debit_bank_code         := regexp_substr(i_cursor_result.payment_info_id, l_regexp, 1, 1, 'i', 1);
    l_msg.debit_account_number    := i_cursor_result.sender_account_number;
    l_msg.credit_bank_code        := regexp_substr(i_cursor_result.payment_info_id, l_regexp, 1, 1, 'i', 2);
    l_msg.credit_account_number   := i_cursor_result.reciever_account_number;
    l_msg.amount                  := i_cursor_result.amount;
    l_msg.currency                := i_cursor_result.currency;
    l_msg.oper_date               := i_cursor_result.oper_date;
    l_msg.rrn                     := regexp_substr(i_cursor_result.payment_info_id, l_regexp, 1, 1, 'i', 3);
    l_msg.is_incoming             := is_record_incoming(l_msg.debit_bank_code);
    
    if l_msg.is_incoming = com_api_const_pkg.FALSE then
        l_msg.iss_account_id  :=
            acc_api_account_pkg.get_account_id(
                i_account_number => l_msg.debit_account_number
            );
    else
        l_msg.iss_account_id  :=
            acc_api_account_pkg.get_account_id(
                i_account_number => l_msg.credit_account_number
            );
    end if;
    
    -- consistancy check
    if i_cursor_result.msg_oper_count <> i_cursor_result.oper_count then
        l_msg.status := net_api_const_pkg.CLEARING_MSG_STATUS_INVALID;
    end if;

    save_msg(
        i_msg   => l_msg
    );
end;

procedure reconciliation(
    i_file      nbf_api_type_pkg.t_file_rec
)
is
    l_msg              nbf_api_type_pkg.t_msg_rec;
    l_status           com_api_type_pkg.t_dict_value;
begin
    /*
    Need to compare
    1) operations 613 - fund transfer to external and records nbf_fin_message.is_incoming = 0
    2) operations 609 - fund transfer credit and records nbf_fin_message.is_incoming = 1
    */
    for r in (
        with t as (
            select o.id as oper_id
                 , o.oper_amount
                 , o.oper_currency
                 , o.oper_date
                 , aups.tag_value as src_acc_number
                 , aupd.tag_value as dest_acc_number
                 , aupbs.tag_value as src_bank_code
                 , aupbd.tag_value as dest_bank_code
                 , o.status
                 , o.originator_refnum
                 , o.oper_type
              from opr_operation o
              left join aup_tag_value aups  on aups.auth_id  = o.id and aups.tag_id  = aup_api_const_pkg.TAG_SOURCE_ACC            and aups.seq_number  = 1
              left join aup_tag_value aupd  on aupd.auth_id  = o.id and aupd.tag_id  = aup_api_const_pkg.TAG_DESTINATION_ACC       and aupd.seq_number  = 1
              left join aup_tag_value aupbs on aupbs.auth_id = o.id and aupbs.tag_id = aup_api_const_pkg.TAG_ISSUER_BANK_CODE      and aupbs.seq_number = 1
              left join aup_tag_value aupbd on aupbd.auth_id = o.id and aupbd.tag_id = aup_api_const_pkg.TAG_DESTINATION_BANK_CODE and aupbd.seq_number = 1
             where o.oper_type in (opr_api_const_pkg.OPER_TYPE_FT_TO_EXTERNAL
                                 , opr_api_const_pkg.OPER_TYPE_FT_TO_EXTERNAL_CREDI)
               and o.status = opr_api_const_pkg.OPERATION_STATUS_PROCESSED
               and o.oper_date between i_file.date_beg and i_file.date_end
        )
        , f as (
            select id
                 , status
                 , file_id
                 , is_incoming
                 , iss_account_id
                 , debit_bank_code
                 , debit_account_number
                 , credit_bank_code
                 , credit_account_number
                 , amount
                 , currency
                 , oper_date
                 , rrn
              from nbf_fin_message f
             where f.file_id = i_file.id
               and f.status  = net_api_const_pkg.CLEARING_MSG_STATUS_LOADED
        )
        select f.id
             , f.oper_date
             , f.amount
             , f.currency
             , f.debit_account_number
             , f.credit_account_number
             , f.debit_bank_code
             , f.credit_bank_code
             , f.is_incoming
             , t.oper_id
             , t.oper_date as nbc_oper_date
             , t.oper_amount
             , t.oper_currency
             , t.src_acc_number
             , t.dest_acc_number
             , t.src_bank_code
             , t.dest_bank_code
             , t.oper_type
          from t full join f on (
                f.debit_account_number  = t.src_acc_number
            and f.credit_account_number = t.dest_acc_number
            and f.debit_bank_code       = t.src_bank_code
            and f.credit_bank_code      = t.dest_bank_code
            and f.amount                = t.oper_amount
            and f.currency              = t.oper_currency
            and f.oper_date             = t.oper_date
            and (
                f.is_incoming = com_api_const_pkg.FALSE and t.oper_type = opr_api_const_pkg.OPER_TYPE_FT_TO_EXTERNAL
             or f.is_incoming = com_api_const_pkg.TRUE  and t.oper_type = opr_api_const_pkg.OPER_TYPE_FT_TO_EXTERNAL_CREDI
            )
        )
    )
    loop
        l_msg := null;
        if r.id is null then
            l_msg.status                := net_api_const_pkg.CLEARING_MSG_STAT_MISS_IN_FILE;
            l_msg.file_id               := i_file.id;
            l_msg.is_incoming           := is_record_incoming(r.src_bank_code);
            l_msg.debit_account_number  := r.src_acc_number;
            l_msg.credit_account_number := r.dest_acc_number;
            l_msg.debit_bank_code       := r.src_bank_code;
            l_msg.credit_bank_code      := r.dest_bank_code;
            l_msg.oper_date             := r.oper_date;
            l_msg.amount                := r.oper_amount;
            l_msg.currency              := r.oper_currency;
            save_msg(i_msg => l_msg);
        else
            if r.id is not null and r.oper_id is not null then
                l_status := net_api_const_pkg.CLEARING_MSG_STATUS_MATCHED;
            else
                l_status := net_api_const_pkg.CLEARING_MSG_STAT_MISS_IN_SV;
            end if;

            update nbf_fin_message f
               set f.status     = l_status
                 , f.oper_id    = r.oper_id
             where f.id = r.id;
        end if;
    end loop;
end;

procedure save_output(
    i_file             nbf_api_type_pkg.t_file_rec
)
is
    l_params                  com_api_type_pkg.t_param_tab;
    l_session_file_id         com_api_type_pkg.t_long_id;
    l_line                    com_api_type_pkg.t_text;
    HEADER_LINE      constant com_api_type_pkg.t_text := 'FromAccount,ToAccount,TransferAmount,Currency,Reconciliation type,Transaction date,Transaction Status,Transaction Number';
begin
    prc_api_file_pkg.open_file(
        o_sess_file_id  => l_session_file_id
      , i_file_type     => nbf_api_const_pkg.FILE_TYPE_NBF_RECONCIL_RESULT
      , io_params       => l_params
    );
    
    if i_file.id is not null then
        l_line := HEADER_LINE;
        prc_api_file_pkg.put_line(
            i_raw_data      => l_line
          , i_sess_file_id  => l_session_file_id
        );
            
        for r in (            
            select id
                 , status
                 , file_id
                 , is_incoming
                 , iss_account_id
                 , debit_bank_code
                 , debit_account_number
                 , credit_bank_code
                 , credit_account_number
                 , amount
                 , currency
                 , oper_date
                 , rrn
                 , oper_id
              from nbf_fin_message f
             where file_id = i_file.id
               and status <> net_api_const_pkg.CLEARING_MSG_STATUS_MATCHED
        )
        loop
            l_line := null;
            l_line := l_line || r.debit_account_number || ', ';
            l_line := l_line || r.credit_account_number || ', ';
            l_line := l_line || r.amount || ', ';
            l_line := l_line || r.currency || ', ';
            l_line := l_line || r.status || ', ';
            l_line := l_line || to_char(r.oper_date, com_api_const_pkg.XML_DATETIME_FORMAT) || ', ';
            l_line := l_line || null || ', '; -- todo: transaction status
            l_line := l_line || r.rrn ;
            
            prc_api_file_pkg.put_line(
                i_raw_data      => l_line
              , i_sess_file_id  => l_session_file_id
            );
        end loop;
    else
        l_line := 'The file is empty or invalid';
        
        prc_api_file_pkg.put_line(
            i_raw_data      => l_line
          , i_sess_file_id  => l_session_file_id
        );
    end if;
    
    
    prc_api_file_pkg.close_file(
        i_sess_file_id  => l_session_file_id
      , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
    );
end;

-- Processing of NBC Fast Incoming Clearing Files
procedure process(
    i_network_id            in com_api_type_pkg.t_network_id
) is
    LOG_PREFIX       constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process: ';
    l_cursor_result_tab       t_cursor_result_tab;
    l_record_number           com_api_type_pkg.t_long_id := 0;
    l_file                    nbf_api_type_pkg.t_file_rec;
    
    l_started                 com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE;
    
    BULK_LIMIT       constant integer  := 1000;
begin
    trc_log_pkg.debug(
        i_text          => LOG_PREFIX || 'Processing of NBC Fast Incoming Clearing Files'
    );

    prc_api_stat_pkg.log_start;
    
    open cur_fin_messages;
    loop
        fetch cur_fin_messages bulk collect into l_cursor_result_tab limit BULK_LIMIT;
        for i in 1..l_cursor_result_tab.count
        loop
            l_record_number := l_record_number + 1;
            if l_started = com_api_const_pkg.FALSE then
                process_new_file(
                    i_network_id    => i_network_id
                  , o_file          => l_file
                );
                l_started := com_api_const_pkg.TRUE;
            end if;

            process_record(
                i_file              => l_file
              , i_cursor_result     => l_cursor_result_tab(i)
            );
        end loop;
        exit when cur_fin_messages%notfound;
    end loop;
    close cur_fin_messages;
    
    if l_started = com_api_const_pkg.TRUE then
        save_file(
            i_file  => l_file
        );
    
        reconciliation(
            i_file  => l_file
        );
    
        save_output(
            i_file  => l_file
        );
    else
        -- something went wrong, save error in file
        save_output(
            i_file  => null
        );
    end if;

    -- close all processed files
    for p in (
        select id session_file_id
             , record_count
             , file_name
          from prc_session_file
         where session_id = prc_api_session_pkg.get_session_id
    )
    loop
        prc_api_file_pkg.close_file(
            i_sess_file_id          => p.session_file_id
          , i_status                => prc_api_const_pkg.FILE_STATUS_ACCEPTED
        );
    end loop;

    prc_api_stat_pkg.log_end(
        i_processed_total  => l_file.records_total
      , i_excepted_total   => 0
      , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug(LOG_PREFIX || 'END');
exception
    when others then
        prc_api_stat_pkg.log_end(
            i_result_code      => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'FAILED with l_record_number [#1] l_rec [#2]'
          , i_env_param1 => l_record_number
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
end process;

end;
/
