create or replace package body acq_prc_reimb_upload_pkg as

procedure process(
    i_inst_id           in      com_api_type_pkg.t_inst_id
) is
    l_channel_id            com_api_type_pkg.t_tiny_id;
    l_file_id               com_api_type_pkg.t_short_id;

    l_batch_id_tab          com_api_type_pkg.t_number_tab;
    l_session_file_id_tab   com_api_type_pkg.t_number_tab;
    l_status_tab            com_api_type_pkg.t_dict_tab;
    l_currency_tab          com_api_type_pkg.t_curr_code_tab;
    l_channel_id_tab        com_api_type_pkg.t_tiny_tab;
    l_payment_mode_tab      com_api_type_pkg.t_dict_tab;
    l_channel_number_tab    com_api_type_pkg.t_name_tab;

    l_xml_batch_tab         com_api_type_pkg.t_XMLType_tab;

    l_file_source           clob;

    l_record_count          pls_integer := 0;
    l_exception_count       pls_integer := 0;

    l_xml_header            com_api_type_pkg.t_raw_data;

    cursor cu_count_batch is
        select count(1)
          from acq_reimb_batch a
         where a.inst_id = i_inst_id
           and decode(a.status, 'REBSAWUP', a.reimb_date, null) <= com_api_sttl_day_pkg.get_sysdate()
           and status = 'REBSAWUP';

    cursor cu_upload_batch is
        select a.id
             , a.channel_id
             , c.payment_mode
             , c.channel_number
             , c.currency
             , xmlelement("ReimbBatch"
                 , xmlelement("BatchID", a.id)
                 , xmlelement("OperationDate", a.oper_date)
                 , xmlelement("PostingDate", a.posting_date)
                 , xmlelement("SettlementDay", a.sttl_day)
                 , xmlelement("ReimbDate", a.reimb_date)
                 , xmlelement("MerchantID", a.merchant_id)
                 , xmlelement("AccountID", a.account_id)
                 , xmlelement("ChequeNumber", a.cheque_number)
                 , xmlelement("GrossAmount", a.gross_amount)
                 , xmlelement("ServiceCharge", a.service_charge)
                 , xmlelement("TaxAmount", a.tax_amount)
                 , xmlelement("NetAmount", a.net_amount)
                 , xmlelement("OperationCount", a.oper_count)
                 , xmlelement("InstitutionID", a.inst_id)
                 , xmlelement("OperationList", (
                    select
                         XMLAgg(
                             xmlelement("Operation"
                               , xmlelement("OperationID", b.id)
                               , xmlelement("CardNumber", b.card_number)
                               , xmlelement("AuthCode", b.auth_code)
                               , xmlelement("RefNum", b.refnum)
                               , xmlelement("GrossAmount", b.gross_amount)
                               , xmlelement("ServiceCharge", b.service_charge)
                               , xmlelement("TaxAmount", b.tax_amount)
                               , xmlelement("NetAmount", b.net_amount)
                             )
                         )
                      from acq_reimb_oper_vw    b
                     where b.batch_id = a.id)
                  )
             ) "BATCH"
          from acq_reimb_batch   a
             , acq_reimb_channel c
         where a.inst_id = i_inst_id
           and decode(a.status, 'REBSAWUP', a.reimb_date, null) <= com_api_sttl_day_pkg.get_sysdate()
           and status = 'REBSAWUP'
           and a.channel_id = c.id
         order by a.channel_id
                , a.reimb_date
                , a.id;

begin

    prc_api_stat_pkg.log_start;

    open cu_count_batch;
    fetch cu_count_batch into l_record_count;
    close cu_count_batch;

    prc_api_stat_pkg.log_estimation (
        i_estimated_count     => l_record_count
    );

    dbms_lob.createtemporary(l_file_source, true);

    open cu_upload_batch;

    loop
        fetch cu_upload_batch bulk collect into
            l_batch_id_tab
          , l_channel_id_tab
          , l_payment_mode_tab
          , l_channel_number_tab
          , l_currency_tab
          , l_xml_batch_tab
        limit 1000;

        for i in 1..l_channel_id_tab.count loop
            if l_channel_id is null or l_channel_id != l_channel_id_tab(i) then
                if l_file_id is not null then
                    dbms_lob.append(l_file_source, '</ReimbChannel>');

                    update prc_session_file_vw
                       set file_contents = l_file_source
                     where id         = l_file_id;

                    prc_api_file_pkg.close_file(
                        i_sess_file_id  => l_file_id
                      , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
                    );

                    l_file_id        := null;
                    l_file_source    := null;
                end if;

--                begin
                    prc_api_file_pkg.open_file(
                        o_sess_file_id      => l_file_id
                    );
--                exception
--                    when others then
--                        null;
--                end;

                l_xml_header := com_api_const_pkg.XML_HEADER||
                    '<ReimbChannel>'||
                    '<InstitutionID>'||i_inst_id||'</InstitutionID>'||
                    '<ChannelNumber>'||l_channel_number_tab(i)||'</ChannelNumber>'||
                    '<PaymentMode>'||l_payment_mode_tab(i)||'</PaymentMode>'||
                    '<Currency>'||l_currency_tab(i)||'</Currency>'||
                    '<UploadDate>'||to_char(com_api_sttl_day_pkg.get_sysdate(), 'yyyy-mm-dd')||'</UploadDate>'||
                    '<OperationCount>'||0||'</OperationCount>'||
                    '<TotalAmount>'||0||'</TotalAmount>';

                dbms_lob.write(l_file_source, length(l_xml_header), 1, l_xml_header);

                l_channel_id := l_channel_id_tab(i);
            end if;

            if l_file_id is null then
                l_status_tab(i) := acq_api_const_pkg.REIMB_BATCH_STATUS_UPLERR;
                l_exception_count := l_exception_count + 1;
            else
                dbms_lob.append(l_file_source, l_xml_batch_tab(i).getClobVal());

                l_status_tab(i) := acq_api_const_pkg.REIMB_BATCH_STATUS_UPLOADED;
                l_record_count := l_record_count + 1;

            end if;

            l_session_file_id_tab(i) := l_file_id;

        end loop;

        forall i in 1..l_batch_id_tab.count
            update acq_reimb_batch
               set status          = l_status_tab(i)
                 , session_file_id = l_session_file_id_tab(i)
             where id              = l_batch_id_tab(i);

        prc_api_stat_pkg.log_current (
            i_current_count       => l_record_count
          , i_excepted_count      => l_exception_count
        );

        exit when cu_upload_batch%notfound;
    end loop;

    if l_file_id is not null then
        dbms_lob.append(l_file_source, '</ReimbChannel>');

        update prc_session_file_vw
           set file_contents = l_file_source
         where id         = l_file_id;

        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
        );

        l_file_id        := null;
    end if;


    close cu_upload_batch;

     dbms_lob.freetemporary(l_file_source);

    prc_api_stat_pkg.log_end(
        i_result_code        => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

exception
    when others then
        if cu_upload_batch%isopen then
            close cu_upload_batch;
        end if;

        if dbms_lob.isopen(l_file_source) = 1 then
            dbms_lob.freetemporary(l_file_source);
        end if;

        prc_api_stat_pkg.log_end (
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if l_file_id is not null then
            prc_api_file_pkg.close_file (
                i_sess_file_id  => l_file_id
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
