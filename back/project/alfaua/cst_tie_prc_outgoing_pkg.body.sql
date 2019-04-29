create or replace package body cst_tie_prc_outgoing_pkg is

BULK_LIMIT           constant integer := 1000;
MAX_BATCH_LIMIT      constant integer := 99999999 - 5;

function s(
    i_tag_name         in varchar2
  , i_string           in varchar2
) return varchar2 is
begin
    if trim(i_string) is not null then
        return '<'||i_tag_name||'>'||trim(i_string)||'</'||i_tag_name||'>';
    else
        return '';
    end if;
end;

function n(
    i_tag_name         in varchar2
  , i_num              in integer
) return varchar2 is
begin
    if i_num is not null then
        return '<'||i_tag_name||'>'||to_char(i_num)||'</'||i_tag_name||'>';
    else
        return '';
    end if;
end;

function d(
    i_tag_name         in varchar2
  , i_date             in date
  , i_format           in varchar2
) return varchar2 is
begin
    if i_date is not null then
        return '<'||i_tag_name||'>'||to_char(i_date, i_format)||'</'||i_tag_name||'>';
    else
        return '';
    end if;
end;

procedure clear_global_data(
    io_file_rec             in out nocopy cst_tie_api_type_pkg.t_file_rec
) is
begin
    io_file_rec.raw_data.delete;
    io_file_rec.record_number.delete;
end;

procedure flush_file (
    io_file_rec             in out nocopy cst_tie_api_type_pkg.t_file_rec
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
  , io_file_rec             in out nocopy cst_tie_api_type_pkg.t_file_rec
) is
    i                       binary_integer;
begin
    if i_line is not null then
        i := io_file_rec.record_number.count + 1;

        io_file_rec.raw_data(i) := i_line;
        io_file_rec.record_number(i) := i;

        if i >= BULK_LIMIT then
            flush_file(io_file_rec);
        end if;
    end if;
end;

procedure generate_file_header(
    o_raw_data             out com_api_type_pkg.t_raw_data
  , io_file_rec             in out nocopy cst_tie_api_type_pkg.t_file_rec
  , i_file_name             in com_api_type_pkg.t_name
  , i_version               in com_api_type_pkg.t_name
  , i_network_id            in com_api_type_pkg.t_tiny_id
  , i_inst_id               in com_api_type_pkg.t_inst_id
) is
begin
    io_file_rec.id              := cst_tie_file_seq.nextval;
    io_file_rec.is_incoming     := com_api_const_pkg.FALSE;
    io_file_rec.network_id      := i_network_id;
    io_file_rec.file_name       := i_file_name;
    io_file_rec.file_version    := substr(i_version,1,4);
    io_file_rec.inst_id         := i_inst_id;
    io_file_rec.records_count   := 0;
    io_file_rec.file_date_time  := sysdate;
    select nvl(max(ext_file_id)+1,1)
      into io_file_rec.ext_file_id
      from cst_tie_file f where f.is_incoming=com_api_const_pkg.FALSE;

    o_raw_data := '<?xml version="1.0" encoding="UTF-8"?>'
                ||'<File>'
                ||'<Header>'
                ||'<FormatVersion>'||i_version||'</FormatVersion>'
                ||'<FileOriginator>ALFA</FileOriginator>'
                ||'<FileDestination>NBU</FileDestination>'
                ||'<FileId>'||io_file_rec.ext_file_id||'</FileId>'
                ||'<FileDateTime>'||to_char(io_file_rec.file_date_time,'yyyymmddhh24miss')||'</FileDateTime>'
                ||'</Header>'
                ||'<Transactions>'
    ;
end;

procedure generate_file_trailer(
    o_raw_data             out com_api_type_pkg.t_raw_data
  , io_file_rec             in out nocopy cst_tie_api_type_pkg.t_file_rec
) is
begin
    o_raw_data:='</Transactions></File>';
end;

procedure register_file(
    i_file_rec             in cst_tie_api_type_pkg.t_file_rec
) is
begin
    insert into cst_tie_file(
        id
      , is_incoming
      , network_id
      , file_name
      , file_version
      , ext_file_id
      , inst_id
      , records_count
      , session_file_id
    )
    values(
        i_file_rec.id
      , i_file_rec.is_incoming
      , i_file_rec.network_id
      , i_file_rec.file_name
      , i_file_rec.file_version
      , i_file_rec.ext_file_id
      , i_file_rec.inst_id
      , i_file_rec.records_count
      , i_file_rec.session_file_id
    );
end;

procedure generate_presentment(
    o_raw_data             out com_api_type_pkg.t_raw_data
  , i_fin_rec               in cst_tie_api_type_pkg.t_fin_rec
  , io_file_rec             in out nocopy cst_tie_api_type_pkg.t_file_rec
  , i_version               in com_api_type_pkg.t_name
) is
begin
    o_raw_data:='<Transaction>'
        ||n('AccntTypeFrom', i_fin_rec.accnt_type_from)
        ||n('AccntTypeTo', i_fin_rec.accnt_type_to)
        ||n('ApprCode', i_fin_rec.appr_code)
        ||s('AcqId', i_fin_rec.acq_id)
        ||s('Arn', i_fin_rec.arn)
        ||s('BatchNr', i_fin_rec.batch_nr)
        ||n('BillAmnt', i_fin_rec.bill_amnt)
        ||n('BillCcy', i_fin_rec.bill_ccy)
        ||s('BusinessApplicationId', i_fin_rec.business_application_id)
        ||s('CardCaptureCap', i_fin_rec.card_capture_cap)
        ||s('CardDataInputCap', i_fin_rec.card_data_input_cap)
        ||s('CardDataInputMode', i_fin_rec.card_data_input_mode)
        ||s('CardDataOutputCap', i_fin_rec.card_data_output_cap)
        ||s('CardPresence', i_fin_rec.card_presence)
        ||n('CardSeqNr', i_fin_rec.card_seq_nr)
        ||n('CashbackAmnt', i_fin_rec.cashback_amnt)
        ||s('CatLevel', i_fin_rec.cat_level)
        ||n('ChbRefData', i_fin_rec.chb_ref_data)
        ||s('CrdhAuthCap', i_fin_rec.crdh_auth_cap)
        ||s('CrdhAuthEntity', i_fin_rec.crdh_auth_entity)
        ||s('CrdhAuthMethod', i_fin_rec.crdh_auth_method)
        ||s('CrdhPresence', i_fin_rec.crdh_presence)
        ||s('Cvv2Result', i_fin_rec.cvv2_result)
        ||d('CardExpDate', i_fin_rec.card_exp_date, 'MMYY')
        ||n('DocInd', i_fin_rec.doc_ind)
        ||s('EcommSecLevel', i_fin_rec.ecomm_sec_level)
        ||n('FwdInstId', i_fin_rec.fwd_inst_id)
        ||n('Mcc', i_fin_rec.mcc)
        ||s('MerchantId', i_fin_rec.merchant_id)
        ||s('MerchantName', i_fin_rec.merchant_name)
        ||s('MerchantAddr', i_fin_rec.merchant_addr)
        ||s('MerchantCountry', i_fin_rec.merchant_country)
        ||s('MerchantCity', i_fin_rec.merchant_city)
        ||s('MerchantPostalCode', i_fin_rec.merchant_postal_code)
        ||n('MsgFunctCode', i_fin_rec.msg_funct_code)
        ||n('MsgReasonCode', i_fin_rec.msg_reason_code)
        ||n('Mti', i_fin_rec.mti)
        ||s('OperEnv', i_fin_rec.oper_env)
        ||s('OrigReasonCode', i_fin_rec.orig_reason_code)
        ||s('Pan', i_fin_rec.pan)
        ||s('PinCaptureCap', i_fin_rec.pin_capture_cap)
        ||d('ProcDate', i_fin_rec.proc_date,'YYYYMMDD')
        ||s('ReceiverAn', i_fin_rec.receiver_an)
        ||s('ReceiverAnTypeId', i_fin_rec.receiver_an_type_id)
        ||s('ReceiverInstCode', i_fin_rec.receiver_inst_code)
        ||n('RespCode', i_fin_rec.resp_code)
        ||s('Rrn', i_fin_rec.rrn)
        ||s('SenderRn', i_fin_rec.sender_rn)
        ||s('SenderAn', i_fin_rec.sender_an)
        ||s('SenderAnTypeId', i_fin_rec.sender_an_type_id)
        ||s('SenderName', i_fin_rec.sender_name)
        ||s('SenderAddr', i_fin_rec.sender_addr)
        ||s('SenderCity', i_fin_rec.sender_city)
        ||s('SenderInstCode', i_fin_rec.sender_inst_code)
        ||s('SenderState', i_fin_rec.sender_state)
        ||s('SenderCountry', i_fin_rec.sender_country)
        ||n('SettlAmnt', i_fin_rec.settl_amnt)
        ||n('SettlCcy', i_fin_rec.settl_ccy)
        ||d('SettlDate', i_fin_rec.settl_date,'YYYYMMDD')
        ||n('Stan', i_fin_rec.stan)
        ||n('CardSvcCode', i_fin_rec.card_svc_code)
        ||s('TermDataOutputCap', i_fin_rec.term_data_output_cap)
        ||s('TermId', i_fin_rec.term_id)
        ||n('TranAmnt', i_fin_rec.tran_amnt)
        ||n('TranCcy', i_fin_rec.tran_ccy)
        ||d('TranDateTime', i_fin_rec.tran_date_time,'YYYYMMDDHH24MISS')
        ||s('TranOriginator', i_fin_rec.tran_originator)
        ||s('TranDestination', i_fin_rec.tran_destination)
        ||s('TranType', i_fin_rec.tran_type)
        ||s('Tid', i_fin_rec.tid)
        ||s('TidOriginator', i_fin_rec.tid_originator)
        ||n('MultipleClearingRec', i_fin_rec.multiple_clearing_rec)
        ||s('ValidationCode', i_fin_rec.validation_code)
        ||n('WalletId', i_fin_rec.wallet_id)
        ||s('PTTI', i_fin_rec.ptti)
        ||n('PaymentFacilitatorID', i_fin_rec.payment_facilitator_id)
        ||n('IndependentSalesOrgID', i_fin_rec.independent_sales_org_id)
        ||s('AdditionalMerchantInfo', i_fin_rec.additional_merchant_info)
        ||s('Emv5F2A', i_fin_rec.emv5f2a)
        ||s('Emv5F34', i_fin_rec.emv5f34)
        ||s('Emv71', i_fin_rec.emv71)
        ||s('Emv72', i_fin_rec.emv72)
        ||s('Emv82', i_fin_rec.emv82)
        ||s('Emv84', i_fin_rec.emv84)
        ||s('Emv91', i_fin_rec.emv91)
        ||s('Emv95', i_fin_rec.emv95)
        ||s('Emv9A', i_fin_rec.emv9a)
        ||s('Emv9C', i_fin_rec.emv9c)
        ||s('Emv9F02', i_fin_rec.emv9f02)
        ||s('Emv9F03', i_fin_rec.emv9f03)
        ||s('Emv9F09', i_fin_rec.emv9f09)
        ||s('Emv9F10', i_fin_rec.emv9f10)
        ||s('Emv9F1A', i_fin_rec.emv9f1a)
        ||s('Emv9F1E', i_fin_rec.emv9f1e)
        ||s('Emv9F26', i_fin_rec.emv9f26)
        ||s('Emv9F27', i_fin_rec.emv9f27)
        ||s('Emv9F33', i_fin_rec.emv9f33)
        ||s('Emv9F34', i_fin_rec.emv9f34)
        ||s('Emv9F35', i_fin_rec.emv9f35)
        ||s('Emv9F36', i_fin_rec.emv9f36)
        ||s('Emv9F37', i_fin_rec.emv9f37)
        ||s('Emv9F41', i_fin_rec.emv9f41)
        ||s('Emv9F53', i_fin_rec.emv9f53)
        ||s('Emv9F6E', i_fin_rec.emv9f6e)
        ||s('MsgNr', i_fin_rec.id)
        ||s('PaymentNarrative', i_fin_rec.payment_narrative)
    ||'</Transaction>'
    ;
    io_file_rec.records_count:= io_file_rec.records_count + 1;
end;

procedure process(
    i_network_id          in com_api_type_pkg.t_tiny_id default '5001'
  , i_inst_id             in com_api_type_pkg.t_inst_id default '1001'
  , i_start_date          in date default null
  , i_end_date            in date default null
  , i_card_network_id     in com_api_type_pkg.t_tiny_id default null
) is
    l_file_name               com_api_type_pkg.t_name;
    l_estimated_count         com_api_type_pkg.t_count             := 0;
    l_excepted_count          com_api_type_pkg.t_count             := 0;
    l_processed_count         com_api_type_pkg.t_count             := 0;
    l_host_id                 com_api_type_pkg.t_tiny_id;
    l_standard_id             com_api_type_pkg.t_tiny_id;
    l_standard_version_id     com_api_type_pkg.t_tiny_id;
    l_standard_version_name   com_api_type_pkg.t_name;
    l_fin_cur                 cst_tie_api_type_pkg.t_fin_cur;
    l_fin_tab                 cst_tie_api_type_pkg.t_fin_tab;
    i                         pls_integer;
    l_param_tab               com_api_type_pkg.t_param_tab;
    l_raw_data                com_api_type_pkg.t_raw_data;
    l_file_rec                cst_tie_api_type_pkg.t_file_rec;

    procedure register_session_file (
        o_session_file_id    out com_api_type_pkg.t_long_id
      , o_file_name          out com_api_type_pkg.t_name
    ) is
        l_container_id           com_api_type_pkg.t_long_id := prc_api_session_pkg.get_container_id;
        l_file_type              com_api_type_pkg.t_dict_value;
    begin
        --parameters
        select min(file_type)
          into l_file_type
          from prc_file_attribute a
             , prc_file f
         where a.container_id = l_container_id
           and a.file_id      = f.id
           and file_purpose   = prc_api_const_pkg.FILE_PURPOSE_OUT;
        ----
        l_param_tab.delete;
        prc_api_file_pkg.open_file(
            o_sess_file_id   => o_session_file_id
            , i_file_type    => l_file_type
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
      , io_file_rec    in out nocopy cst_tie_api_type_pkg.t_file_rec
    ) is
        i         pls_integer;
    begin
       i:= nvl(io_file_rec.rowid_tab.last, 0) + 1;
       io_file_rec.rowid_tab( i )    := i_rowid;
       io_file_rec.id_tab( i )       := i_id;
    end;

    procedure mark_uploaded_msg(
        io_file_rec    in out nocopy cst_tie_api_type_pkg.t_file_rec
    ) is
    begin
       if io_file_rec.rowid_tab.first is not null then
           forall i in io_file_rec.rowid_tab.first..io_file_rec.rowid_tab.last
               update cst_tie_fin
               set status = net_api_const_pkg.CLEARING_MSG_STATUS_UPLOADED
                 , is_rejected = com_api_type_pkg.FALSE
                 , file_id     = io_file_rec.session_file_id
                 , msg_nr      = io_file_rec.id_tab(i)
               where rowid = io_file_rec.rowid_tab(i)
           ;

           opr_api_clearing_pkg.mark_uploaded (
               i_id_tab            => io_file_rec.id_tab
           );

           io_file_rec.rowid_tab.delete;
           io_file_rec.id_tab.delete;
       end if;
    end;

begin
    trc_log_pkg.debug (
        i_text  => 'Tieto outgoing clearing start'
    );

    savepoint tieto_start_cearing_upload;

    prc_api_stat_pkg.log_start;

    l_host_id := net_api_network_pkg.get_default_host(i_network_id);
    l_standard_id := net_api_network_pkg.get_offline_standard(
        i_host_id       => l_host_id
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
        cst_tie_api_fin_pkg.estimate_messages_for_upload(
            i_network_id    => i_network_id
          , i_inst_id       => i_inst_id
          , i_start_date    => trunc(i_start_date)
          , i_end_date      => trunc(i_end_date)
        );

    prc_api_stat_pkg.log_estimation(
        i_estimated_count => l_estimated_count
    );

    cst_tie_api_fin_pkg.enum_messages_for_upload(
        i_network_id    => i_network_id
      , i_inst_id       => i_inst_id
      , i_start_date    => trunc(i_start_date)
      , i_end_date      => trunc(i_end_date)
      , o_fin_cur       => l_fin_cur
    );
    ------------

    loop
        fetch l_fin_cur bulk collect into l_fin_tab;

        i:= l_fin_tab.first;
        while i is not null loop
            if l_file_rec.session_file_id is null then
                register_session_file(
                    o_session_file_id     => l_file_rec.session_file_id
                  , o_file_name           => l_file_name
                );
                generate_file_header(
                    o_raw_data              => l_raw_data
                  , io_file_rec             => l_file_rec
                  , i_file_name             => l_file_name
                  , i_version               => l_standard_version_name
                  , i_network_id            => i_network_id
                  , i_inst_id               => i_inst_id
                );

                put_line (
                    i_line                  => l_raw_data
                  , io_file_rec             => l_file_rec
                );
            end if;

            generate_presentment(
                o_raw_data              => l_raw_data
              , i_fin_rec               => l_fin_tab(i)
              , io_file_rec             => l_file_rec
              , i_version               => l_standard_version_name
            );
            put_line (
                i_line                  => l_raw_data
              , io_file_rec             => l_file_rec
            );
            register_uploaded_msg(
                i_rowid        => l_fin_tab(i).row_id
              , i_id           => l_fin_tab(i).id
              , io_file_rec    => l_file_rec
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

    if l_file_rec.session_file_id is not null then
        generate_file_trailer(
            o_raw_data              => l_raw_data
          , io_file_rec             => l_file_rec
        );
        put_line (
            i_line                  => l_raw_data
          , io_file_rec             => l_file_rec
        );
        register_file(
            i_file_rec              => l_file_rec
        );
        flush_file(
            io_file_rec             => l_file_rec
        );
        mark_uploaded_msg(
            io_file_rec             => l_file_rec
        );
    end if;

    prc_api_stat_pkg.log_end (
        i_excepted_total    => l_excepted_count
      , i_processed_total   => l_processed_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug (
        i_text  => 'Tieto outgoing clearing finished successfully'
    );

exception
    when others then
        rollback to savepoint tieto_start_cearing_upload;
        if l_fin_cur%isopen then
            close l_fin_cur;
        end if;

        clear_global_data(
            io_file_rec             => l_file_rec
        );

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
end cst_tie_prc_outgoing_pkg;
/
