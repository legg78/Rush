create or replace package body itf_prc_outgoing_pkg is
/************************************************************
 * Interface for uploading files <br />
 * Created by Kondratyev A.(kondratyev@bpc.ru)  at 05.06.2013 <br />
 * Last changed by $Author: Kondratyev A. $ <br />
 * $LastChangedDate:: 2010-06-05 16:00:00 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: itf_prc_outgoing_pkg <br />
 * @headcom
 ************************************************************/

BULK_LIMIT      constant pls_integer := 400;

procedure process_file_header (
    i_session_file_id      in com_api_type_pkg.t_long_id
  , i_file_header          in itf_api_type_pkg.t_file_header
) is
    l_line                   com_api_type_pkg.t_raw_data;
    lc_eol         constant  varchar2(2) := chr(10);
begin
    l_line := rpad(i_file_header.record_type,8);
    l_line := l_line || lpad(to_char(i_file_header.record_number),12,'0');
    l_line := l_line || lpad(to_char(i_file_header.file_id),18,'0') || ' ';
    l_line := l_line || rpad(i_file_header.file_type,8);
    l_line := l_line || to_char(i_file_header.file_dt,'MMDDYYYYHH24MISS') || ' ';
    l_line := l_line || rpad(i_file_header.inst_id,12);
    l_line := l_line || rpad(nvl(i_file_header.agent_inst_id,' '),12) || ' ';
    l_line := l_line || rpad(nvl(to_char(i_file_header.fe_sett_dt,'MMDDYYYYHH24MISS'),' '),14);
    l_line := l_line || rpad(nvl(to_char(i_file_header.bo_sett_dt,'MMDDYYYYHH24MISS'),' '),14);
    l_line := l_line || rpad(nvl(to_char(i_file_header.bo_sett_day),' '),6) || rpad(' ',377);

    if l_line is not null then
        prc_api_file_pkg.put_line(
            i_raw_data      => l_line
          , i_sess_file_id  => i_session_file_id
        );
        prc_api_file_pkg.put_file(
            i_sess_file_id   => i_session_file_id
          , i_clob_content   => l_line || lc_eol
          , i_add_to         => com_api_const_pkg.TRUE
        );
    end if;
end;

procedure process_ibi_batch_trailer(
    i_session_file_id      in com_api_type_pkg.t_long_id
  , i_ibi_batch_rec        in itf_api_type_pkg.t_ibi_batch_rec
) is
    l_line                   com_api_type_pkg.t_raw_data;
    lc_send_status  constant com_api_type_pkg.t_dict_value := opr_api_const_pkg.OPERATION_STATUS_WAIT_SETTL;
    lc_eol          constant varchar2(2) := chr(10);
begin
    if    i_ibi_batch_rec.record_type = itf_api_const_pkg.RT_IBI03_BATCH_TRAILER then
       l_line := rpad(i_ibi_batch_rec.record_type,8);
       l_line := l_line || lpad(to_char(i_ibi_batch_rec.record_number),12,'0');
       l_line := l_line || rpad(i_ibi_batch_rec.account_number,32);
       l_line := l_line || rpad(i_ibi_batch_rec.account_type,8) || ' ';
       l_line := l_line || lpad(to_char(i_ibi_batch_rec.amount),16,'0');
       l_line := l_line || i_ibi_batch_rec.dc_indicator;
       l_line := l_line || i_ibi_batch_rec.currency_code || ' ';
       l_line := l_line || to_char(i_ibi_batch_rec.pay_date,'MMDDYYYY');
       l_line := l_line || rpad(nvl(to_char(i_ibi_batch_rec.effect_date,'MMDDYYYY'),' '),8) || ' ';
       l_line := l_line || rpad(nvl(i_ibi_batch_rec.trans_type,' '),8) || ' ';
       l_line := l_line || rpad(nvl(i_ibi_batch_rec.user_id,' '),3);
       if i_ibi_batch_rec.pay_id is null then
          l_line := l_line || lpad(' ',16);
       else
          l_line := l_line || rpad(to_char(i_ibi_batch_rec.pay_id),16,'0');
       end if;
       l_line :=  l_line || rpad(nvl(i_ibi_batch_rec.trans_decr,' '),40)
                         || '0' -- not check balance
                         || lpad(' ',329);
    elsif i_ibi_batch_rec.record_type = itf_api_const_pkg.RT_IBI07_BATCH_TRAILER then
       l_line := rpad(i_ibi_batch_rec.record_type,8);
       l_line := l_line || lpad(to_char(i_ibi_batch_rec.record_number),12,'0');
       l_line := l_line || rpad(i_ibi_batch_rec.account_number,32);
       l_line := l_line || rpad(i_ibi_batch_rec.account_type,8) || ' ';
       l_line := l_line || rpad(nvl(i_ibi_batch_rec.acc_stat_new,' '),8);
       l_line := l_line || rpad(nvl(i_ibi_batch_rec.acc_stat_prev,' '),8);
       l_line := l_line || rpad(nvl(i_ibi_batch_rec.acc_stat_chan_res,' '),8) || ' ';
       l_line := l_line || rpad(nvl(to_char(i_ibi_batch_rec.change_date,'MMDDYYYY'),' '),8);
       l_line := l_line || rpad(nvl(to_char(i_ibi_batch_rec.effect_date,'MMDDYYYY'),' '),8) || lpad(' ',395);
    end if;

    if l_line is not null then
        prc_api_file_pkg.put_line(
            i_raw_data      => l_line
          , i_sess_file_id  => i_session_file_id
        );
        prc_api_file_pkg.put_file(
            i_sess_file_id   => i_session_file_id
          , i_clob_content   => l_line || lc_eol
          , i_add_to         => com_api_const_pkg.TRUE
        );
    end if;

    update opr_operation o set o.status = lc_send_status
     where o.id = i_ibi_batch_rec.pay_id;
end;

procedure process_ocp_batch_trailer(
    i_session_file_id      in com_api_type_pkg.t_long_id
  , i_ocp_batch_rec        in itf_api_type_pkg.t_ocp_batch_rec
) is
    l_line                   com_api_type_pkg.t_raw_data;
    lc_eol          constant varchar2(2) := chr(10);
begin
    l_line := rpad(i_ocp_batch_rec.record_type,8);
    l_line := l_line || lpad(to_char(i_ocp_batch_rec.record_number),12,'0');
    l_line := l_line || rpad(i_ocp_batch_rec.account_number,32);
    l_line := l_line || rpad(i_ocp_batch_rec.bo_account_type,8) || ' ';
    l_line := l_line || lpad(to_char(i_ocp_batch_rec.amount),12,'0');
    l_line := l_line || rpad(i_ocp_batch_rec.dc_indicator,2);
    l_line := l_line || rpad(i_ocp_batch_rec.currency_code,3) || ' ';
    l_line := l_line || rpad(to_char(i_ocp_batch_rec.effect_date,'MMDDYYYY'),8) || ' ';
    l_line := l_line || lpad(to_char(i_ocp_batch_rec.trans_id),16,'0') || ' ';
    l_line := l_line || rpad(i_ocp_batch_rec.bo_trans_type,8) || ' ';
    l_line := l_line || rpad(i_ocp_batch_rec.user_id,3) || ' ';
    l_line := l_line || rpad(to_char(i_ocp_batch_rec.cor_account),32);
    l_line := l_line || rpad(i_ocp_batch_rec.fe_trans_type,8) || ' ';
    l_line := l_line || rpad(i_ocp_batch_rec.customs_office,40);
    l_line := l_line || rpad(i_ocp_batch_rec.customs_address,64);
    l_line := l_line || rpad(to_char(i_ocp_batch_rec.trans_date,'MMDDYYYY'),8) || ' ';
    l_line := l_line || rpad(i_ocp_batch_rec.card_number,16) || ' ';
    l_line := l_line || rpad(i_ocp_batch_rec.receipt_number,4) || ' ';
    l_line := l_line || rpad(i_ocp_batch_rec.approval_code,6) || ' ';
    l_line := l_line || rpad(i_ocp_batch_rec.payer_inn,12) || ' ';
    l_line := l_line || rpad(i_ocp_batch_rec.payer_kpp,9) || ' ';
    l_line := l_line || rpad(i_ocp_batch_rec.payer_okpo,10) || ' ';
    l_line := l_line || rpad(i_ocp_batch_rec.declarant_inn,12) || ' ';
    l_line := l_line || rpad(i_ocp_batch_rec.declarant_kpp,9) || ' ';
    l_line := l_line || rpad(i_ocp_batch_rec.declarant_okpo,10) || ' ';
    l_line := l_line || lpad(nvl(to_char(i_ocp_batch_rec.customs_code),'        '),8,'0');
    l_line := l_line || rpad(i_ocp_batch_rec.pay_doc_type,2);
    l_line := l_line || rpad(i_ocp_batch_rec.pay_doc_id,7);
    l_line := l_line || rpad(i_ocp_batch_rec.pay_doc_date,10);
    l_line := l_line || lpad(nvl(to_char(i_ocp_batch_rec.pay_kind),'    '),4,'0');
    l_line := l_line || lpad(nvl(to_char(i_ocp_batch_rec.cbc),'          '),20,'0');
    l_line := l_line || lpad(nvl(to_char(i_ocp_batch_rec.pay_status),'  '),2,'0');
    l_line := l_line || lpad(nvl(to_char(i_ocp_batch_rec.receiver_kpp),'         '),9,'0');
    l_line := l_line || lpad(nvl(to_char(i_ocp_batch_rec.receiver_okato),'           '),11,'0');
    l_line := l_line || rpad(i_ocp_batch_rec.pay_type,2);
    l_line := l_line || rpad(' ',54);

    if l_line is not null then
        prc_api_file_pkg.put_line(
            i_raw_data      => l_line
          , i_sess_file_id  => i_session_file_id
        );
        prc_api_file_pkg.put_file(
            i_sess_file_id   => i_session_file_id
          , i_clob_content   => l_line || lc_eol
          , i_add_to         => com_api_const_pkg.TRUE
        );
    end if;
end;

procedure process_file_trailer (
    i_session_file_id      in com_api_type_pkg.t_long_id
  , i_file_trailer         in itf_api_type_pkg.t_file_trailer
) is
    l_line                   com_api_type_pkg.t_raw_data;
    lc_eol         constant  varchar2(2) := chr(10);
begin
    l_line := rpad(i_file_trailer.record_type,8);
    l_line := l_line || lpad(to_char(i_file_trailer.record_number),12,'0');
    l_line := l_line || i_file_trailer.last_record_flag;
    l_line := l_line || i_file_trailer.crc || rpad(' ',468);

    if l_line is not null then
        prc_api_file_pkg.put_line(
            i_raw_data      => l_line
          , i_sess_file_id  => i_session_file_id
        );
        prc_api_file_pkg.put_file(
            i_sess_file_id   => i_session_file_id
          , i_clob_content   => l_line || lc_eol
          , i_add_to         => com_api_const_pkg.TRUE
        );
    end if;
end;

procedure process (i_inst_id in com_api_type_pkg.t_inst_id)
is
    l_session_file_id             com_api_type_pkg.t_long_id;
    l_params                      com_api_type_pkg.t_param_tab;
    l_count                       com_api_type_pkg.t_long_id;
    lc_oper_status      constant  com_api_type_pkg.t_dict_value := opr_api_const_pkg.OPERATION_STATUS_WAIT_CLEARING;
    l_file_header                 itf_api_type_pkg.t_file_header;
    l_ibi_batch_rec               itf_api_type_pkg.t_ibi_batch_rec;
    l_file_trailer                itf_api_type_pkg.t_file_trailer;
    lc_file_type        constant  com_api_type_pkg.t_dict_value := itf_api_const_pkg.FILE_TYPE_IBI;
    l_crc                         integer;
    l_raw_data                    com_api_type_pkg.t_raw_data;
    l_inst_id                     com_api_type_pkg.t_inst_id;
begin
    savepoint sp_ibi_start_upload;

    trc_log_pkg.debug (i_text => 'IBI Generation start');
    prc_api_stat_pkg.log_start;

    l_inst_id := cst_institute_pkg.get_mps_inst(i_inst_id => nvl(i_inst_id, ost_api_const_pkg.DEFAULT_INST));
    
    select count(1)
      into l_count
      from opr_operation o
         , opr_participant p
     where p.inst_id = i_inst_id
       and o.id = p.oper_id
       and o.oper_amount != 0
       and o.status = lc_oper_status;

    if l_count != 0 then -- Available data to upload
        l_params.delete;
        rul_api_param_pkg.set_param (
              i_name     => 'INST_ID'
            , i_value    => l_inst_id
            , io_params  => l_params
        );
        prc_api_file_pkg.open_file (
              o_sess_file_id  => l_session_file_id
            , i_file_type     => lc_file_type -- IBI file
            , io_params       => l_params
        );

        l_count := 1;

        l_file_header.record_type    := itf_api_const_pkg.RT_FILE_HEADER;
        l_file_header.record_number  := l_count;
        l_file_header.file_id        := l_session_file_id;
        l_file_header.file_type      := itf_api_const_pkg.FT_IBI_FILE_TYPE;
        l_file_header.file_dt        := get_sysdate;
        l_file_header.inst_id        := to_char(l_inst_id);

        process_file_header(
                i_session_file_id => l_session_file_id
              , i_file_header     => l_file_header
        );

        l_count := l_count + 1;

        for v in (select p.account_number
                       , p.account_type
                       , abs(o.oper_amount) amount
                       , decode(o.oper_type, itf_api_const_pkg.OPERATION_TYPE_ACCOUNT_PAYMENT, itf_api_const_pkg.DC_IND_CREDIT
                                           , itf_api_const_pkg.OPERATION_TYPE_ACCOUNT_WITHDR, itf_api_const_pkg.DC_IND_DEBIT
                                           , itf_api_const_pkg.DC_IND_CREDIT) as dc_indicator
                       , o.oper_currency
                       , o.oper_date
                       , o.id as oper_id
                       , o.oper_type
                  from opr_operation o
                     , opr_participant p
                 where o.id = p.oper_id
                   and o.oper_amount != 0
                   and o.status = lc_oper_status
                   and p.inst_id = nvl(i_inst_id, ost_api_const_pkg.DEFAULT_INST)
                   and p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER)
        loop
            l_ibi_batch_rec.record_type       := itf_api_const_pkg.RT_IBI03_BATCH_TRAILER;
            l_ibi_batch_rec.record_number     := l_count;
            l_ibi_batch_rec.account_number    := v.account_number;
            l_ibi_batch_rec.account_type      := ' '; --'4V0201';--v.account_type; 
            l_ibi_batch_rec.amount            := v.amount;
            l_ibi_batch_rec.dc_indicator      := v.dc_indicator;
            l_ibi_batch_rec.currency_code     := v.oper_currency;
            l_ibi_batch_rec.pay_date          := v.oper_date;
            if    v.oper_type = itf_api_const_pkg.OPERATION_TYPE_ACCOUNT_WITHDR then
               l_ibi_batch_rec.trans_type     := itf_api_const_pkg.TT_WITHDRAW;
            elsif v.oper_type = itf_api_const_pkg.OPERATION_TYPE_ACCOUNT_PAYMENT then
               l_ibi_batch_rec.trans_type     := itf_api_const_pkg.TT_PAYMENT;
            end if;
            l_ibi_batch_rec.user_id           := substr(get_user_name,1,3);
            l_ibi_batch_rec.pay_id            := v.oper_id;

      --      if    v.dc_indicator = 'DR' then
      --         l_ibi_batch_rec.trans_decr     := 'Withdrawal from account'
      --      elsif v.dc_indicator = 'CR' then
      --         l_ibi_batch_rec.trans_decr     := 'Payment to account';
      --      end if;

            process_ibi_batch_trailer(
                  i_session_file_id => l_session_file_id
                , i_ibi_batch_rec   => l_ibi_batch_rec
            );
            l_count := l_count + 1;
        end loop;

        l_file_trailer.record_type      := itf_api_const_pkg.RT_FILE_TRAILER;
        l_file_trailer.record_number    := l_count;
        l_file_trailer.last_record_flag := itf_api_const_pkg.LR_FLAG;
        for i in 1..l_count-1 loop
            l_raw_data := prc_api_file_pkg.get_line (
                                   i_sess_file_id  => l_session_file_id
                                 , i_rec_num       => i
                          );
            l_crc := itf_api_utils_pkg.crc32(i_raw_data => l_raw_data, i_crc => l_crc);
        end loop;
        l_file_trailer.crc              := lpad(trim(to_char(l_crc,'XXXXXXXX')),8,'0');

        process_file_trailer(
                i_session_file_id => l_session_file_id
              , i_file_trailer    => l_file_trailer
        );
    end if;

    prc_api_stat_pkg.log_end (
          i_processed_total  => l_count
        , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
    trc_log_pkg.debug (i_text => 'IBI Generation end');
exception
    when others then
        rollback to savepoint sp_ibi_start_upload;

        prc_api_stat_pkg.log_end (
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );
        trc_log_pkg.debug (i_text => 'IBI Generation end with error');
        if com_api_error_pkg.is_fatal_error(SQLCODE) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;
        raise;
end;

procedure process_ocp_file (i_inst_id in com_api_type_pkg.t_inst_id)
is
    l_session_file_id             com_api_type_pkg.t_long_id;
    l_params                      com_api_type_pkg.t_param_tab;
    l_count                       com_api_type_pkg.t_long_id;
    lc_oper_status      constant  com_api_type_pkg.t_dict_value := opr_api_const_pkg.OPERATION_STATUS_PROCESSED;
    l_file_header                 itf_api_type_pkg.t_file_header;
    l_ocp_batch_rec               itf_api_type_pkg.t_ocp_batch_rec;
    l_file_trailer                itf_api_type_pkg.t_file_trailer;
    lc_file_type        constant  com_api_type_pkg.t_dict_value := itf_api_const_pkg.FILE_TYPE_OCP;
    l_crc                         integer;
    l_raw_data                    com_api_type_pkg.t_raw_data;
    l_inst_id                     com_api_type_pkg.t_inst_id;
    l_sysdate                     date;
    l_thread_number               com_api_type_pkg.t_tiny_id;
    l_estimated_count             com_api_type_pkg.t_long_id := 0;
    l_event_id                    com_api_type_pkg.t_long_id;
    l_event_type                  com_api_type_pkg.t_dict_value;
    l_entity_type                 com_api_type_pkg.t_dict_value;

    cursor l_events_count is
        select count(*)
          from evt_event_object_vw o
             , evt_event_vw e
             , evt_subscriber_vw s
         where o.procedure_name = 'ITF_PRC_OUTGOING_PKG.PROCESS_OCP_FILE'
           and o.eff_date <= l_sysdate
           and o.inst_id = nvl(i_inst_id, ost_api_const_pkg.DEFAULT_INST)
           and nvl(o.status, evt_api_const_pkg.EVENT_STATUS_READY) != evt_api_const_pkg.EVENT_STATUS_PROCESSED
           and (o.split_hash in (select split_hash from com_split_map where thread_number = l_thread_number)
             or l_thread_number = -1
           )
           and e.id = o.event_id
           and e.event_type = s.event_type
           and o.procedure_name = s.procedure_name;

    cursor l_events is
        select o.event_id
             , e.event_type
             , o.entity_type
          from evt_event_object_vw o
             , evt_event_vw e
             , evt_subscriber_vw s
         where o.procedure_name = 'ITF_PRC_OUTGOING_PKG.PROCESS_OCP_FILE'
           and o.eff_date <= l_sysdate
           and nvl(o.status, evt_api_const_pkg.EVENT_STATUS_READY) != evt_api_const_pkg.EVENT_STATUS_PROCESSED
           and o.inst_id = nvl(i_inst_id, ost_api_const_pkg.DEFAULT_INST)
           and (o.split_hash in (select split_hash from com_split_map where thread_number = l_thread_number)
             or l_thread_number = -1
           )
           and e.id = o.event_id
           and e.event_type = s.event_type
           and o.procedure_name = s.procedure_name
           and rownum = 1;
begin
    l_thread_number := get_thread_number;
    l_sysdate := com_api_sttl_day_pkg.get_sysdate;
    savepoint sp_ocp_start_upload;

    trc_log_pkg.debug (i_text => 'OCP Generation start');
    prc_api_stat_pkg.log_start;

    l_inst_id := cst_institute_pkg.get_abs_inst(i_inst_id => i_inst_id);

    open l_events_count;
    fetch l_events_count into l_estimated_count;
    close l_events_count;

    prc_api_stat_pkg.log_estimation (
        i_estimated_count  => l_estimated_count
    );

    if l_estimated_count > 0 then
        l_params.delete;
        rul_api_param_pkg.set_param (
            i_name       => 'INST_ID'
          , i_value    => l_inst_id
          , io_params  => l_params
        );
        prc_api_file_pkg.open_file (
            o_sess_file_id  => l_session_file_id
          , i_file_type     => lc_file_type -- OCP file
          , i_file_name     => 'OCP_'||to_char(get_sysdate,'YYYYMMDD')
              ||'_'||to_char(get_sysdate,'HH24MISS')||'_'||to_char(l_inst_id)
          , io_params       => l_params
        );

        l_count := 1;

        l_file_header.record_type    := itf_api_const_pkg.RT_FILE_HEADER;
        l_file_header.record_number  := l_count;
        l_file_header.file_id        := l_session_file_id;
        l_file_header.file_type      := itf_api_const_pkg.FT_OCP_FILE_TYPE;
        l_file_header.file_dt        := get_sysdate;
        l_file_header.inst_id        := to_char(l_inst_id);

        process_file_header(
            i_session_file_id => l_session_file_id
          , i_file_header     => l_file_header
        );

        l_count := l_count + 1;
        
        open l_events;
        fetch l_events 
        into l_event_id, l_event_type, l_entity_type;

        for v in (select p.account_number
                       , p.account_type
                       , o.oper_amount as amount
                       , nvl(po.dc_indicator, itf_api_const_pkg.DC_IND_CREDIT) as dc_indicator
                       , o.oper_currency
                       , o.oper_date
                       , o.host_date
                       , o.id as oper_id
                       , o.oper_type
                       , pmo_api_order_pkg.get_order_data_value(
                                i_order_id    => o.payment_order_id
                              , i_param_name  => 'CBS_TRANSFER_BANK_CORR_ACC'
                         ) as corr_account
                       , pmo_api_order_pkg.get_order_data_value(
                                i_order_id    => o.payment_order_id
                              , i_param_name  => 'CBS_FEE_TYPE'
                         ) as oper_subtype
                       , pmo_api_order_pkg.get_order_data_value(
                                i_order_id    => o.payment_order_id
                              , i_param_name  => 'CBS_TRANSFER_BANK_BRANCH_NAME'
                         ) as customs_name
                       , pmo_api_order_pkg.get_order_data_value(
                                i_order_id    => o.payment_order_id
                              , i_param_name  => 'CBS_TRANSFER_BANK_CITY'
                         ) as customs_address
                       , pmo_api_order_pkg.get_order_data_value(
                                i_order_id    => o.payment_order_id
                              , i_param_name  => 'CBS_CARD_NUMBER'
                         ) as card_number
                       , pmo_api_order_pkg.get_order_data_value(
                                i_order_id    => o.payment_order_id
                              , i_param_name  => 'CBS_TRANSFER_CHECK_NUMBER'
                         ) as receipt_number
                       , pmo_api_order_pkg.get_order_data_value(
                                i_order_id    => o.payment_order_id
                              , i_param_name  => 'CBS_APPROVAL_CODE'
                         ) as approval_code
                       , pmo_api_order_pkg.get_order_data_value(
                                i_order_id    => o.payment_order_id
                              , i_param_name  => 'CBS_PAYER_INN'
                         ) as payer_inn
                       , pmo_api_order_pkg.get_order_data_value(
                                i_order_id    => o.payment_order_id
                              , i_param_name  => 'CBS_PAYER_KPP'
                         ) as payer_kpp
                       , pmo_api_order_pkg.get_order_data_value(
                                i_order_id    => o.payment_order_id
                              , i_param_name  => 'CBS_PAYER_OKPO'
                         ) as payer_okpo
                       , pmo_api_order_pkg.get_order_data_value(
                                i_order_id    => o.payment_order_id
                              , i_param_name  => 'CBS_CUSTOMS_CODE'
                         ) as customs_code
                       , pmo_api_order_pkg.get_order_data_value(
                                i_order_id    => o.payment_order_id
                              , i_param_name  => 'CBS_PAYMENT_DOCUMENT_TYPE'
                         ) as payment_document_type
                         , pmo_api_order_pkg.get_order_data_value(
                                i_order_id    => o.payment_order_id
                              , i_param_name  => 'CBS_PAYMENT_DOCUMENT_ID'
                         ) as payment_document_id
                         , pmo_api_order_pkg.get_order_data_value(
                                i_order_id    => o.payment_order_id
                              , i_param_name  => 'CBS_PAYMENT_DOCUMENT_DATE'
                         ) as payment_document_date
                       , pmo_api_order_pkg.get_order_data_value(
                                i_order_id    => o.payment_order_id
                              , i_param_name  => 'CBS_CODE_BUDGET_CLASSIFICATION'
                         ) as cbc
                       , pmo_api_order_pkg.get_order_data_value(
                                i_order_id    => o.payment_order_id
                              , i_param_name  => 'CBS_PAYMENT_KIND'
                         ) as payment_type
                       , pmo_api_order_pkg.get_order_data_value (
                                 i_order_id   => o.payment_order_id
                               , i_param_name => 'CBS_ORIGINAL_TRANSACTION_ID'
                         ) as original_transaction_id
                       , eo.object_id as event_object_id
                       , eo.inst_id
                       , pmo_api_order_pkg.get_order_data_value(
                               i_order_id    => o.payment_order_id
                             , i_param_name  => 'CBS_PAY_KIND'
                         ) as pay_kind
                    from opr_operation o
                       , opr_participant p
                       , evt_event_object eo
                       , (select po.id
                               , itf_api_const_pkg.DC_IND_DEBIT as dc_indicator from pmo_order po
                           where po.purpose_id = pmo_api_const_pkg.EXTERNAL_INCOMING_PAYMENT) po
                   where o.id = p.oper_id
                     and o.status = lc_oper_status
                     and p.inst_id = i_inst_id
                     and eo.object_id = o.id
                     and eo.event_id  = l_event_id
                     and eo.entity_type = l_entity_type
                     and nvl(eo.status, evt_api_const_pkg.EVENT_STATUS_READY) != evt_api_const_pkg.EVENT_STATUS_PROCESSED
                     and o.payment_order_id = po.id(+)
                     and p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER)
        loop
            l_ocp_batch_rec.record_type       := itf_api_const_pkg.RT_OCP_BATCH_TRAILER;
            l_ocp_batch_rec.record_number     := l_count;
            l_ocp_batch_rec.account_number    := v.account_number;
            l_ocp_batch_rec.bo_account_type   := ' '; --'4V0201';--v.account_type; --
            l_ocp_batch_rec.amount            := v.amount;
            l_ocp_batch_rec.dc_indicator      := v.dc_indicator;
            l_ocp_batch_rec.currency_code     := v.oper_currency;
            l_ocp_batch_rec.effect_date       := v.host_date;
            l_ocp_batch_rec.trans_id          := v.original_transaction_id;
            if    v.oper_type = itf_api_const_pkg.OPERATION_TYPE_CUSTOMS_PAYMENT then
                l_ocp_batch_rec.bo_trans_type := itf_api_const_pkg.TT_BO_CUSTOMS_PAY;
                l_ocp_batch_rec.fe_trans_type := itf_api_const_pkg.TT_FE_TRANSACTION_TYPE;
            elsif v.oper_type = itf_api_const_pkg.OPERATION_TYPE_FEECUST_PAYMENT then
                if v.oper_subtype like 'FEEG%' then
                    l_ocp_batch_rec.bo_trans_type := itf_api_const_pkg.TT_PAY_SCHEME_FEE;
                else
                    l_ocp_batch_rec.bo_trans_type := itf_api_const_pkg.TT_ISSUER_FEE;
                end if;
                l_ocp_batch_rec.fe_trans_type := v.oper_subtype;
            end if;
            l_ocp_batch_rec.user_id           := ' ';
            l_ocp_batch_rec.cor_account       := v.corr_account;
            l_ocp_batch_rec.customs_office    := nvl(v.customs_name,' ');
            l_ocp_batch_rec.customs_address   := nvl(v.customs_address,' ');
            l_ocp_batch_rec.trans_date        := v.oper_date;
            l_ocp_batch_rec.card_number       := nvl(v.card_number,' ');
            l_ocp_batch_rec.receipt_number    := nvl(v.receipt_number,' ');
            l_ocp_batch_rec.approval_code     := nvl(v.approval_code,' ');
            l_ocp_batch_rec.payer_inn         := nvl(v.payer_inn,' ');
            l_ocp_batch_rec.payer_kpp         := nvl(v.payer_kpp,' ');
            l_ocp_batch_rec.payer_okpo        := nvl(v.payer_okpo,' ');
            l_ocp_batch_rec.declarant_inn     := nvl(v.payer_inn,' ');
            l_ocp_batch_rec.declarant_kpp     := nvl(v.payer_kpp,' ');
            l_ocp_batch_rec.declarant_okpo    := nvl(v.payer_okpo,' ');
            l_ocp_batch_rec.customs_code      := nvl(v.customs_code,' ');
            l_ocp_batch_rec.pay_doc_type      := nvl(v.payment_document_type,' ');
            l_ocp_batch_rec.pay_doc_id        := nvl(v.payment_document_id,' ');
            l_ocp_batch_rec.pay_doc_date      := nvl(v.payment_document_date,' ');
            l_ocp_batch_rec.pay_kind          := v.pay_kind;
            l_ocp_batch_rec.cbc               := v.cbc;
            l_ocp_batch_rec.pay_status        := null;
            l_ocp_batch_rec.receiver_kpp      := null;
            l_ocp_batch_rec.receiver_okato    := null;
            l_ocp_batch_rec.pay_type          := '  ';--nvl(v.payment_type,' ');
            l_ocp_batch_rec.pay_details       := ' ';

            process_ocp_batch_trailer(
                i_session_file_id => l_session_file_id
              , i_ocp_batch_rec   => l_ocp_batch_rec
            );
            l_count := l_count + 1;
          evt_api_event_pkg.process_event_object(
              i_event_object_id    => v.event_object_id
          );
        end loop;

        l_file_trailer.record_type      := itf_api_const_pkg.RT_FILE_TRAILER;
        l_file_trailer.record_number    := l_count;
        l_file_trailer.last_record_flag := itf_api_const_pkg.LR_FLAG;
        for i in 1..l_count-1 loop
            l_raw_data := prc_api_file_pkg.get_line (
                              i_sess_file_id  => l_session_file_id
                            , i_rec_num       => i
                          );
            l_crc := itf_api_utils_pkg.crc32(i_raw_data => l_raw_data, i_crc => l_crc);
        end loop;
        l_file_trailer.crc              := lpad(trim(to_char(l_crc,'XXXXXXXX')),8,'0');

        process_file_trailer(
            i_session_file_id => l_session_file_id
          , i_file_trailer    => l_file_trailer
        );

    end if;
    prc_api_stat_pkg.log_end (
        i_processed_total  => l_count
      , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
    trc_log_pkg.debug (i_text => 'OCP Generation end');
exception
    when others then
         rollback to savepoint sp_ocp_start_upload;

         prc_api_stat_pkg.log_end (
             i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
         );
         trc_log_pkg.debug (i_text => 'OCP Generation end with error');
         if com_api_error_pkg.is_fatal_error(SQLCODE) = com_api_const_pkg.TRUE then
             raise;
         elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
             com_api_error_pkg.raise_fatal_error(
                 i_error         => 'UNHANDLED_EXCEPTION'
               , i_env_param1    => sqlerrm
             );
         end if;
         raise;
end;

procedure export_cards_status (
    i_inst_id                 in com_api_type_pkg.t_inst_id
    , i_start_date            in date default null
    , i_end_date              in date default null
    , i_card_status           in com_api_type_pkg.t_dict_value default null
    , i_export_state          in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
) is
    l_start_date              date;
    l_end_date                date;

    cursor l_entrys is
    select
        l.id
        , l.change_date
        , l.event_type
        , lead(l.status) over (partition by l.entity_type, l.object_id order by l.change_date desc) old_status
        , l.status new_status
        , n.card_number
        , i.seq_number
        , i.expir_date

        , row_number() over(order by l.id) rn
        , row_number() over(order by l.id desc) rn_desc
        , count(l.id) over() cnt
    from
        iss_card c
        , iss_card_instance i
        , iss_card_number_vw n
        , evt_status_log l
    where
        i.card_id = c.id
        and n.card_id = c.id
        and l.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
        and l.object_id = i.id
        and l.change_date between l_start_date and l_end_date
        and (l.status = i_card_status or i_card_status is null)
        and (l.status like 'CSTS%' or i_export_state = com_api_const_pkg.TRUE)
    order by
        l.id;

    l_id                      com_api_type_pkg.t_number_tab;
    l_change_date             com_api_type_pkg.t_date_tab;
    l_event_type              com_api_type_pkg.t_dict_tab;
    l_old_status              com_api_type_pkg.t_dict_tab;
    l_new_status              com_api_type_pkg.t_dict_tab;
    l_card_number             com_api_type_pkg.t_card_number_tab;
    l_seq_number              com_api_type_pkg.t_number_tab;
    l_expir_date              com_api_type_pkg.t_date_tab;

    l_record_number           com_api_type_pkg.t_number_tab;
    l_record_number_desc      com_api_type_pkg.t_number_tab;
    l_count                   com_api_type_pkg.t_number_tab;

    l_processed_count         com_api_type_pkg.t_long_id := 0;
    l_session_file_id         com_api_type_pkg.t_long_id;
    l_rec_raw                 com_api_type_pkg.t_raw_tab;
    l_rec_num                 com_api_type_pkg.t_integer_tab;

    l_crc                     integer;

    procedure open_file is
    begin
        /*prc_api_file_pkg.open_file (
            o_sess_file_id  => l_session_file_id
        );*/
        l_session_file_id := 123456;
        dbms_output.put_line('open_file');
    end;

    procedure close_file is
    begin
        /*prc_api_file_pkg.close_file (
            i_sess_file_id  => l_session_file_id
        );*/
        dbms_output.put_line('close_file');
    end;

    procedure put_file is
    begin
        for j in 1 .. l_rec_raw.count loop
            --dbms_output.put_line('record_number:'||l_rec_num(j));
            dbms_output.put_line(l_rec_raw(j));
        end loop;
        /*prc_api_file_pkg.put_bulk (
            i_sess_file_id  => l_session_file_id
            , i_raw_tab     => l_rec_raw
            , i_num_tab     => l_rec_num
        );*/
        l_rec_raw.delete;
        l_rec_num.delete;
    end;

begin
    --prc_api_stat_pkg.log_start;

    l_start_date := trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate),'DD');
    l_end_date := nvl(trunc(i_end_date,'DD'), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND;

    open l_entrys;
    loop
        fetch l_entrys
        bulk collect into
        l_id
        , l_change_date
        , l_event_type
        , l_old_status
        , l_new_status
        , l_card_number
        , l_seq_number
        , l_expir_date
        , l_record_number
        , l_record_number_desc
        , l_count
        limit BULK_LIMIT;

        l_rec_raw.delete;
        l_rec_num.delete;

        for i in 1..l_id.count loop

            if l_record_number(i) = 1 then
                l_processed_count := l_processed_count + 1;

                -- set estimated count
                /*prc_api_stat_pkg.log_estimation (
                    i_estimated_count  => l_count(i)
                );*/

                -- open file
                open_file;

                -- put header
                l_rec_raw(l_rec_raw.count + 1) :=
                -- Record Type
                itf_api_type_pkg.pad_char(itf_api_const_pkg.RT_FILE_HEADER, 8, 8)
                -- Record Number
                || itf_api_type_pkg.pad_number(l_processed_count, 12, 12)
                -- Filler
                || ' '
                -- File Type
                || 'FTYPOSL '
                -- File date
                || itf_api_type_pkg.pad_char(to_char(get_sysdate, 'mmddyyyyyhhmiss'), 14, 14)
                -- Filler
                || ' '
                -- Institution ID
                || itf_api_type_pkg.pad_char(i_inst_id, 4, 4)
                -- Agent Institution ID
                || itf_api_type_pkg.pad_char(' ', 12, 12)
                ;
                l_rec_num(l_rec_num.count + 1) := l_processed_count;

                l_crc := itf_api_utils_pkg.crc32 (
                    i_raw_data  => l_rec_raw(l_rec_raw.count)
                    , i_crc     => l_crc
                );
            end if;

            l_processed_count := l_processed_count + 1;

            l_rec_raw(l_rec_raw.count + 1) :=
            -- Record Type
            itf_api_type_pkg.pad_char(itf_api_const_pkg.RT_OSL_DETAIL, 8, 8)
            -- Record Number
            || itf_api_type_pkg.pad_number(l_processed_count, 12, 12)
            -- Filler
            || ' '
            -- Action log id
            || itf_api_type_pkg.pad_number(l_id(i), 12, 12)
            -- Action date
            || itf_api_type_pkg.pad_char(to_char(l_change_date(i), 'ddmmyyyyhhmiss'), 14, 14)
            -- Action type
            || itf_api_type_pkg.pad_char(l_event_type(i), 8, 8)
            -- Filler
            || ' '
            -- Old card status
            || itf_api_type_pkg.pad_char(l_old_status(i), 8, 8)
            -- New card status
            || itf_api_type_pkg.pad_char(l_new_status(i), 8, 8)
            -- Filler
            || ' '
            -- Card reissue code
            || itf_api_type_pkg.pad_char(' ', 8, 8)
            -- Filler
            || ' '
            -- Old card sequence number
            || itf_api_type_pkg.pad_number(l_seq_number(i), 3, 3)
            -- New card sequence number
            || itf_api_type_pkg.pad_number(l_seq_number(i), 3, 3)
            -- Filler
            || ' '
            -- Old card number
            || itf_api_type_pkg.pad_char(l_card_number(i), 19, 19)
            -- New card number
            || itf_api_type_pkg.pad_char(l_card_number(i), 19, 19)
            -- Filler
            || ' '
            -- Old card expiry date
            || itf_api_type_pkg.pad_char(to_char(l_change_date(i), 'mmyy'), 4, 4)
            -- New card expiry date
            || itf_api_type_pkg.pad_char(to_char(l_change_date(i), 'mmyy'), 4, 4)
            ;
            l_rec_num(l_rec_num.count + 1) := l_processed_count;
            l_crc := itf_api_utils_pkg.crc32 (
                i_raw_data  => l_rec_raw(l_rec_raw.count)
                , i_crc     => l_crc
            );

            if l_record_number_desc(i) = 1 then
                l_processed_count := l_processed_count + 1;

                -- put trailer
                l_rec_raw(l_rec_raw.count + 1) :=
                -- Record Type
                itf_api_type_pkg.pad_char(itf_api_const_pkg.RT_FILE_TRAILER, 8, 8)
                -- Record Number
                || itf_api_type_pkg.pad_number(l_processed_count, 12, 12)
                -- Filler
                || ' '
                -- Hash Totals
                || itf_api_type_pkg.pad_number(trim(to_char(l_crc,'XXXXXXXX')), 8, 8)
                ;
                l_rec_num(l_rec_num.count + 1) := l_processed_count;
            end if;

        end loop;

        -- put file record
        put_file;

        /*prc_api_stat_pkg.log_current (
            i_current_count     => l_processed_count
            , i_excepted_count  => 0
        );*/

        exit when l_entrys%notfound;
    end loop;
    close l_entrys;

    -- close file
    close_file;

    /*if l_processed_count = 0 then
        prc_api_stat_pkg.log_estimation (
            i_estimated_count  => l_processed_count
        );
    end if;
    prc_api_stat_pkg.log_end (
        i_processed_total  => l_processed_count
        , i_result_code    => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );*/
exception
    when others then
        if l_entrys%isopen then
            close l_entrys;
        end if;

        /*prc_api_stat_pkg.log_end (
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );*/

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error (
                i_error         => 'UNHANDLED_EXCEPTION'
                , i_env_param1  => sqlerrm
            );
        end if;

        raise;
end;

end;
/
