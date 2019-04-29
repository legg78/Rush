create or replace package body mcw_prc_mcom_pkg is
/*********************************************************
 *  MasterCard incoming dispute records API  <br />
 *  Created by Kolodkina J. (kolodkina@bpcbt.com)  at 18.03.2019 <br />
 *  Module: MCW_PRC_MCOM_PKG <br />
 *  @headcom
 **********************************************************/

function is_fatal_error(code in number) return boolean is
begin
    if code between -20999 and -20000 then
        return false;
    else
        return true;
    end if;
end;

procedure create_retrieval_request(
    i_network_id        in      com_api_type_pkg.t_tiny_id
  , i_case_rec          in      csm_api_type_pkg.t_csm_case_rec
  , i_de002             in      mcw_api_type_pkg.t_de002
  , i_de004             in      mcw_api_type_pkg.t_de004
  , i_de049             in      mcw_api_type_pkg.t_de049
  , i_de025             in      mcw_api_type_pkg.t_de025
  , i_p0228             in      mcw_api_type_pkg.t_p0228
  , i_is_retrieval      in      com_api_type_pkg.t_boolean
  , i_status            in      mcw_api_type_pkg.t_ext_msg_status
  , i_create_operation  in      com_api_type_pkg.t_boolean      default null
  , i_ext_claim_id      in      mcw_api_type_pkg.t_ext_claim_id
  , i_ext_message_id    in      mcw_api_type_pkg.t_ext_message_id
) is
    LOG_PREFIX                  constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.create_retrieval_request: ';
    l_fin_rec                   mcw_api_type_pkg.t_fin_rec;
    l_stage                     com_api_type_pkg.t_name;
    l_auth                      aut_api_type_pkg.t_auth_rec;
    l_host_id                   com_api_type_pkg.t_tiny_id;
    l_standard_id               com_api_type_pkg.t_tiny_id;
    l_msg_type                  com_api_type_pkg.t_dict_value;
    l_orig_fin_rec              mcw_api_type_pkg.t_fin_rec;
begin 
    trc_log_pkg.debug(i_text => 'Processing retrieval request');

    -- We fill only part of fields, because MasterCom reutrn only them
    l_stage := 'init';
    l_fin_rec.id              := opr_api_create_pkg.get_id;
    l_fin_rec.status          := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;
    l_fin_rec.network_id      := i_network_id;
    l_fin_rec.inst_id         := i_case_rec.inst_id;
    l_fin_rec.is_incoming     := com_api_type_pkg.TRUE;
    l_fin_rec.is_rejected     := com_api_type_pkg.FALSE;
    l_fin_rec.is_reversal     := com_api_type_pkg.FALSE;
    l_fin_rec.is_fpd_matched  := com_api_type_pkg.FALSE;
    l_fin_rec.is_fsum_matched := com_api_type_pkg.FALSE;
    l_fin_rec.ext_claim_id    := i_ext_claim_id;
    l_fin_rec.ext_message_id  := i_ext_message_id;

    l_fin_rec.ext_msg_status  := i_status;

    l_fin_rec.mti   := mcw_api_const_pkg.MSG_TYPE_ADMINISTRATIVE;
    l_fin_rec.de024 := case i_is_retrieval
                          when com_api_type_pkg.TRUE
                          then mcw_api_const_pkg.FUNC_CODE_RETRIEVAL_REQUEST
                          else mcw_api_const_pkg.FUNC_CODE_RETRIEVAL_RQ_ACKNOWL
                       end;
    l_fin_rec.de002 := i_de002;
    l_fin_rec.de004 := i_de004;
    l_fin_rec.de049 := i_de049;
    l_fin_rec.de025 := i_de025;
    l_fin_rec.p0228 := i_p0228;

    mcw_api_fin_pkg.get_fin(
        i_id                => i_case_rec.original_id
      , o_fin_rec           => l_orig_fin_rec
      , i_mask_error        => com_api_type_pkg.FALSE
    );

    l_fin_rec.de003_1       := l_orig_fin_rec.de003_1;
    l_fin_rec.p0375         := l_fin_rec.id;

    l_fin_rec.impact :=
        mcw_utl_pkg.get_message_impact(
            i_mti           => l_fin_rec.mti
            , i_de024       => l_fin_rec.de024
            , i_de003_1     => l_fin_rec.de003_1
            , i_is_reversal => l_fin_rec.is_reversal
            , i_is_incoming => l_fin_rec.is_incoming
        );

    mcw_api_dispute_pkg.assign_dispute_id(
        io_fin_rec      => l_fin_rec
        , o_auth        => l_auth
        , i_need_repeat => com_api_type_pkg.FALSE
    );

    l_stage := 'put_message';
    mcw_api_fin_pkg.put_message(
        i_fin_rec  => l_fin_rec
    );

    l_stage := 'create_operation';
    l_host_id :=
        net_api_network_pkg.get_default_host(
            i_network_id  => l_fin_rec.network_id
        );

    l_standard_id :=
        net_api_network_pkg.get_offline_standard(
            i_host_id       => l_host_id
        );

    if nvl(i_create_operation, com_api_type_pkg.TRUE) = com_api_type_pkg.TRUE then
        mcw_api_fin_pkg.create_operation(
            i_fin_rec              => l_fin_rec
            , i_standard_id        => l_standard_id
            , i_auth               => l_auth
            , o_msg_type           => l_msg_type
        );
    end if;

    -- this will reopen case if it was Closed
    mcw_api_dispute_pkg.change_case_status(
        i_dispute_id     => l_fin_rec.dispute_id
      , i_mti            => l_fin_rec.mti
      , i_de024          => l_fin_rec.de024
      , i_is_reversal    => l_fin_rec.is_reversal
      , i_reason_code    => l_fin_rec.de025
      , i_msg_status     => net_api_const_pkg.CLEARING_MSG_STATUS_LOADED
      , i_msg_type       => l_msg_type
    );

    trc_log_pkg.debug(
        i_text         => 'Incoming retrieval request processed. Assigned id[#1]'
        , i_env_param1 => l_fin_rec.id
    );
exception
    when others then
        -- As far as re-raising error erases information about exception point,
        -- it is necessary to store this information before re-rasing an exception
        trc_log_pkg.debug(i_text => LOG_PREFIX || 'l_stage=' || l_stage || ', sqlerrm=' || sqlerrm );
        raise;

end create_retrieval_request;

procedure create_chargeback(
    i_network_id              in    com_api_type_pkg.t_tiny_id
  , i_case_rec                in    csm_api_type_pkg.t_csm_case_rec
  , i_de002                   in    mcw_api_type_pkg.t_de002
  , i_de004                   in    mcw_api_type_pkg.t_de004
  , i_de049                   in    mcw_api_type_pkg.t_de049
  , i_de025                   in    mcw_api_type_pkg.t_de025
  , i_de072                   in    mcw_api_type_pkg.t_de072
  , i_p0262                   in    mcw_api_type_pkg.t_p0262
  , i_is_partial_chargeback   in    com_api_type_pkg.t_boolean
  , i_chargeback_type         in    com_api_type_pkg.t_card_number
  , i_is_reversal             in    com_api_type_pkg.t_boolean
  , i_status                  in    mcw_api_type_pkg.t_ext_msg_status
  , i_create_operation        in    com_api_type_pkg.t_boolean      default null
  , i_ext_claim_id            in    mcw_api_type_pkg.t_ext_claim_id
  , i_ext_message_id          in    mcw_api_type_pkg.t_ext_message_id  
) is
    LOG_PREFIX                constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.create_chargeback ';
    l_fin_rec                 mcw_api_type_pkg.t_fin_rec;
    l_stage                   varchar2(100);
    l_auth                    aut_api_type_pkg.t_auth_rec;
    l_host_id                 com_api_type_pkg.t_tiny_id;
    l_standard_id             com_api_type_pkg.t_tiny_id;
    l_msg_type                com_api_type_pkg.t_dict_value;
    l_orig_fin_rec            mcw_api_type_pkg.t_fin_rec;
begin
    trc_log_pkg.debug(i_text => 'Processing chargeback');

    -- We fill only part of fields, because MasterCom reutrn only them
    l_stage := 'init';
    l_fin_rec.id              := opr_api_create_pkg.get_id;
    l_fin_rec.status          := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;
    l_fin_rec.network_id      := i_network_id;
    l_fin_rec.inst_id         := i_case_rec.inst_id;
    l_fin_rec.is_incoming     := com_api_type_pkg.TRUE;
    l_fin_rec.is_rejected     := com_api_type_pkg.FALSE;
    l_fin_rec.is_reversal     := i_is_reversal;
    l_fin_rec.is_fpd_matched  := com_api_type_pkg.FALSE;
    l_fin_rec.is_fsum_matched := com_api_type_pkg.FALSE;
    l_fin_rec.ext_claim_id    := i_ext_claim_id;
    l_fin_rec.ext_message_id  := i_ext_message_id;

    l_fin_rec.ext_msg_status  := i_status;

    l_fin_rec.mti   :=  case i_chargeback_type
                            when 'SECOND_PRESENTMENT' then mcw_api_const_pkg.MSG_TYPE_PRESENTMENT
                            else mcw_api_const_pkg.MSG_TYPE_CHARGEBACK
                        end;

    if i_is_partial_chargeback = com_api_type_pkg.TRUE then
        if i_chargeback_type = 'CHARGEBACK' then
            l_fin_rec.de024 := mcw_api_const_pkg.FUNC_CODE_CHARGEBACK1_PART;
        elsif i_chargeback_type = 'ARB_CHARGEBACK' then
            l_fin_rec.de024 := mcw_api_const_pkg.FUNC_CODE_CHARGEBACK2_PART;
        else
            l_fin_rec.de024 := mcw_api_const_pkg.FUNC_CODE_SECOND_PRES_PART;
        end if;
    else
        if i_chargeback_type = 'CHARGEBACK' then
            l_fin_rec.de024 := mcw_api_const_pkg.FUNC_CODE_CHARGEBACK1_FULL;
        elsif i_chargeback_type = 'ARB_CHARGEBACK' then
            l_fin_rec.de024 := mcw_api_const_pkg.FUNC_CODE_CHARGEBACK2_FULL;
        else
            l_fin_rec.de024 := mcw_api_const_pkg.FUNC_CODE_SECOND_PRES_FULL;
        end if;
    end if;

    l_fin_rec.de002 := i_de002;
    l_fin_rec.de004 := i_de004;
    l_fin_rec.de049 := i_de049;
    l_fin_rec.de025 := i_de025;
    l_fin_rec.de072 := i_de072;
    l_fin_rec.p0262 := i_p0262;

    if l_fin_rec.is_reversal = com_api_type_pkg.TRUE then
        l_fin_rec.p0025_1 := mcw_api_const_pkg.REVERSAL_PDS_REVERSAL;
    end if;

    l_fin_rec.de003_1       := l_orig_fin_rec.de003_1;
    l_fin_rec.p0375         := l_fin_rec.id;

    l_fin_rec.impact :=
        mcw_utl_pkg.get_message_impact(
            i_mti           => l_fin_rec.mti
          , i_de024         => l_fin_rec.de024
          , i_de003_1       => l_fin_rec.de003_1
          , i_is_reversal   => l_fin_rec.is_reversal
          , i_is_incoming   => l_fin_rec.is_incoming
        );

    mcw_api_dispute_pkg.assign_dispute_id(
        io_fin_rec      => l_fin_rec
        , o_auth        => l_auth
        , i_need_repeat => com_api_type_pkg.FALSE
    );

    l_stage := 'put_message';
    mcw_api_fin_pkg.put_message(
        i_fin_rec  => l_fin_rec
    );

    l_stage := 'create_operation';
    l_host_id :=
        net_api_network_pkg.get_default_host(
            i_network_id  => l_fin_rec.network_id
        );

    l_standard_id :=
        net_api_network_pkg.get_offline_standard(
            i_host_id       => l_host_id
        );

    if nvl(i_create_operation, com_api_type_pkg.TRUE) = com_api_type_pkg.TRUE then
        mcw_api_fin_pkg.create_operation(
            i_fin_rec              => l_fin_rec
            , i_standard_id        => l_standard_id
            , i_auth               => l_auth
          , o_msg_type             => l_msg_type
        );
    end if;

    -- this will reopen case if it was Closed
    mcw_api_dispute_pkg.change_case_status(
        i_dispute_id     => l_fin_rec.dispute_id
      , i_mti            => l_fin_rec.mti
      , i_de024          => l_fin_rec.de024
      , i_is_reversal    => l_fin_rec.is_reversal
      , i_reason_code    => l_fin_rec.de025
      , i_msg_status     => net_api_const_pkg.CLEARING_MSG_STATUS_LOADED
      , i_msg_type       => l_msg_type
    );

    trc_log_pkg.debug(
        i_text         => 'Incoming chargeback processed. Assigned id[#1]'
        , i_env_param1 => l_fin_rec.id
    );
exception
    when others then
        -- As far as re-raising error erases information about exception point,
        -- it is necessary to store this information before re-rasing an exception
        trc_log_pkg.debug(i_text => LOG_PREFIX || 'l_stage=' || l_stage || ', sqlerrm=' || sqlerrm );
        raise;
end create_chargeback;

procedure create_fee_collection(
    i_network_id        in      com_api_type_pkg.t_tiny_id
  , i_case_rec          in      csm_api_type_pkg.t_csm_case_rec
  , i_de002             in      mcw_api_type_pkg.t_de002
  , i_de004             in      mcw_api_type_pkg.t_de004
  , i_de049             in      mcw_api_type_pkg.t_de049
  , i_de025             in      mcw_api_type_pkg.t_de025
  , i_de072             in      mcw_api_type_pkg.t_de072
  , i_de073             in      mcw_api_type_pkg.t_de073
  , i_de093             in      mcw_api_type_pkg.t_de093
  , i_credit_receiver   in      com_api_type_pkg.t_boolean
  , i_create_operation  in      com_api_type_pkg.t_boolean      default null
) is
    LOG_PREFIX         constant com_api_type_pkg.t_name         := lower($$PLSQL_UNIT) || '.create_fee_collection';
    l_fin_rec                   mcw_api_type_pkg.t_fin_rec;
    l_stage                     com_api_type_pkg.t_name;
    l_auth                      aut_api_type_pkg.t_auth_rec;
    l_host_id                   com_api_type_pkg.t_tiny_id;
    l_standard_id               com_api_type_pkg.t_tiny_id;
    l_msg_type                  com_api_type_pkg.t_dict_value;
begin
    trc_log_pkg.debug(i_text => 'Processing retrieval request');

    -- We fill only part of fields, because MasterCom return only them
    l_stage := 'init';
    l_fin_rec.id              := opr_api_create_pkg.get_id;
    l_fin_rec.status          := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;
    l_fin_rec.network_id      := i_network_id;
    l_fin_rec.inst_id         := i_case_rec.inst_id;
    l_fin_rec.is_incoming     := com_api_type_pkg.TRUE;
    l_fin_rec.is_rejected     := com_api_type_pkg.FALSE;
    l_fin_rec.is_reversal     := com_api_type_pkg.FALSE;
    l_fin_rec.is_fpd_matched  := com_api_type_pkg.FALSE;
    l_fin_rec.is_fsum_matched := com_api_type_pkg.FALSE;

    l_fin_rec.mti   := mcw_api_const_pkg.MSG_TYPE_FEE;
    l_fin_rec.de024 := mcw_api_const_pkg.FUNC_CODE_MEMBER_FEE; --currently all loaded fees will have type 1740/700 - member fee.
    l_fin_rec.de002 := i_de002;
    l_fin_rec.de004 := i_de004;
    l_fin_rec.de049 := i_de049;
    l_fin_rec.de025 := i_de025;

    l_fin_rec.de025 := i_de072;

    l_fin_rec.de073 := i_de073;
    l_fin_rec.de093 := i_de093;

    if i_credit_receiver = com_api_type_pkg.TRUE then
        l_fin_rec.de003_1 := '29';
    else
        l_fin_rec.de003_1 := '19';
    end if;

    l_fin_rec.p0375    := l_fin_rec.id;

    l_fin_rec.impact :=
        mcw_utl_pkg.get_message_impact(
            i_mti          => l_fin_rec.mti
          , i_de024        => l_fin_rec.de024
          , i_de003_1      => l_fin_rec.de003_1
          , i_is_reversal  => l_fin_rec.is_reversal
          , i_is_incoming  => l_fin_rec.is_incoming
        );

    mcw_api_dispute_pkg.assign_dispute_id(
        io_fin_rec     => l_fin_rec
      , o_auth         => l_auth
      , i_need_repeat  => com_api_type_pkg.FALSE
    );

    l_stage := 'put_message';
    mcw_api_fin_pkg.put_message(
        i_fin_rec  => l_fin_rec
    );

    l_stage := 'create_operation';
    l_host_id :=
        net_api_network_pkg.get_default_host(
            i_network_id  => l_fin_rec.network_id
        );

    l_standard_id :=
        net_api_network_pkg.get_offline_standard(
            i_host_id       => l_host_id
        );

    if nvl(i_create_operation, com_api_type_pkg.TRUE) = com_api_type_pkg.TRUE then
        mcw_api_fin_pkg.create_operation(
            i_fin_rec            => l_fin_rec
          , i_standard_id        => l_standard_id
          , i_auth               => l_auth
          , o_msg_type           => l_msg_type
        );
    end if;

    -- this will reopen case if it was Closed
    mcw_api_dispute_pkg.change_case_status(
        i_dispute_id     => l_fin_rec.dispute_id
      , i_mti            => l_fin_rec.mti
      , i_de024          => l_fin_rec.de024
      , i_is_reversal    => l_fin_rec.is_reversal
      , i_reason_code    => l_fin_rec.de025
      , i_msg_status     => net_api_const_pkg.CLEARING_MSG_STATUS_LOADED
      , i_msg_type       => l_msg_type
    );

    trc_log_pkg.debug(
        i_text       => 'Incoming retrieval request processed. Assigned id[#1]'
      , i_env_param1 => l_fin_rec.id
    );
exception
    when others then
        -- As far as re-raising error erases information about exception point,
        -- it is necessary to store this information before re-rasing an exception
        trc_log_pkg.debug(i_text => LOG_PREFIX || 'l_stage=' || l_stage || ', sqlerrm=' || sqlerrm );
        raise;
end create_fee_collection;

procedure load(
    i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_network_id        in      com_api_type_pkg.t_tiny_id
  , i_create_operation  in      com_api_type_pkg.t_boolean      default null
  , i_claim_tab         in      mcw_mcom_claim_tpt
  , i_retrieval_tab     in      mcw_mcom_retrieval_tpt
  , i_chargeback_tab    in      mcw_mcom_chbck_tpt
  , i_fee_tab           in     mcw_mcom_fee_tpt
  , i_attachment_tab    in     mcw_mcom_attachment_tpt
) is
    LOG_PREFIX              constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.load: ';
    l_estimated_count       com_api_type_pkg.t_long_id    := 0;
    l_processed_count       com_api_type_pkg.t_long_id    := 0;
    l_excepted_count        com_api_type_pkg.t_long_id    := 0;
    l_case_id               com_api_type_pkg.t_long_id;
    l_oper_id               com_api_type_pkg.t_long_id;
    l_retrieval_tab_index   com_api_type_pkg.t_long_id    := 1;
    l_chargeback_tab_index  com_api_type_pkg.t_long_id    := 1;
    l_fee_tab_index         com_api_type_pkg.t_long_id    := 1;
    l_attachment_tab_index  com_api_type_pkg.t_long_id    := 1;
    l_fin_id                com_api_type_pkg.t_long_id;
    l_case_rec              csm_api_type_pkg.t_csm_case_rec;
    l_is_retrieval          com_api_type_pkg.t_boolean;
    l_encoded_card_number   com_api_type_pkg.t_card_number;

    procedure process_attachments (
        i_claim_id    in     com_api_type_pkg.t_card_number
      , i_message_id  in     com_api_type_pkg.t_cmid
      , i_fin_id      in     com_api_type_pkg.t_long_id
    ) is
        l_document_id        com_api_type_pkg.t_long_id;
        l_seqnum             com_api_type_pkg.t_seqnum;
    begin        
        while i_attachment_tab(l_attachment_tab_index).claim_id   = i_claim_id
          and i_attachment_tab(l_attachment_tab_index).message_id = i_message_id
        loop
            -- check that attachment exists
            select min(d.id)
              into l_document_id
              from rpt_document d
                 , rpt_document_content c
             where d.object_id   = i_fin_id
               and d.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION -- 'ENTTOPER'
               and d.id          = c.document_id
               and c.file_name   = i_attachment_tab(l_attachment_tab_index).file_name;

            trc_log_pkg.debug(
                i_text          => 'Document Id [#1], file name [#2]'
              , i_env_param1    => l_document_id
              , i_env_param2    => i_attachment_tab(l_attachment_tab_index).file_name
            );

            -- Add or update attachment
            rpt_api_document_pkg.add_document(
                io_document_id   => l_document_id
              , o_seqnum         => l_seqnum
              , i_content_type   => rpt_api_const_pkg.CONTENT_TYPE_DSP_ATTCHT --  'DCCT0011'
              , i_document_type  => rpt_api_const_pkg.ATTACHMENT_TYPE_OTHER_DSP -- 'DSDT0007'
              , i_entity_type    => opr_api_const_pkg.ENTITY_TYPE_OPERATION --'ENTTOPER'
              , i_object_id      => i_fin_id
              , i_file_name      => i_attachment_tab(l_attachment_tab_index).file_name
              , i_save_path      => i_attachment_tab(l_attachment_tab_index).save_path
              , i_inst_id        => l_case_rec.inst_id
              , i_xml            => com_api_hash_pkg.base64_decode(i_attachment_tab(l_attachment_tab_index).file_content)
            );

            l_attachment_tab_index := l_attachment_tab_index + 1;
            exit when l_attachment_tab_index > i_attachment_tab.count;
        end loop;
    end;

begin
    savepoint load_mastercom_claim_start;

    trc_log_pkg.debug(i_text => 'Loading MasterCom claims started');

    trc_log_pkg.debug(
        i_text       => 'Size: i_claim_tab.count [#1], i_retrieval_tab.count [#2], i_chargeback_tab.count [#3], i_fee_tab.count [#4]'
      , i_env_param1 => i_claim_tab.count
      , i_env_param2 => i_retrieval_tab.count
      , i_env_param3 => i_chargeback_tab.count
      , i_env_param4 => i_fee_tab.count
    );

    l_estimated_count := i_claim_tab.count + l_estimated_count;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count => l_estimated_count
      , i_measure         => dsp_api_const_pkg.ENTITY_TYPE_DISPUTE_CASE -- 'ENTT0158'
    );

    trc_log_pkg.debug(
        i_text          => 'l_estimated_count [#1]'
      , i_env_param1    => l_estimated_count
    );

    if l_estimated_count > 0 then

        for i in 1 .. i_claim_tab.count loop

            begin
                savepoint mastercom_start_new_record;

                -- 1. try to find Case by Mcom claim_id.
                trc_log_pkg.debug(
                    i_text          => 'Try to find Case by Mcom claim_id. Claim_id [#1], is_oper[#2]'
                  , i_env_param1    => i_claim_tab(i).claim_id
                  , i_env_param2    => i_claim_tab(i).is_open
                );

                begin

                    select id
                      into l_case_id
                      from csm_case c
                     where c.ext_claim_id   = i_claim_tab(i).claim_id
                       and c.inst_id        = i_inst_id;

                exception
                    when no_data_found then
                        trc_log_pkg.debug(
                            i_text         => 'Case is not found. Try to find disputed operation. claim_id [#1]'
                          , i_env_param1  => i_claim_tab(i).claim_id
                        );
                end;

                -- If case not found and Claim is Open => only in this case we must create new case. 
                -- If Claim is Closed - we do not need create Case.
                if l_case_id is null and i_claim_tab(i).is_open = com_api_const_pkg.TRUE then
                    -- search disputed operation by card number and arn
                    select reverse(iss_api_token_pkg.encode_card_number(i_claim_tab(i).card_number))
                      into l_encoded_card_number
                      from dual;

                    select min(id)
                      into l_oper_id
                      from opr_operation o
                         , opr_card c
                     where o.network_refnum       = i_claim_tab(i).acquirer_ref_num
                       and o.id                   = c.oper_id
                       and reverse(c.card_number) = l_encoded_card_number;
         
                    -- If operation is not found - this is error case.
                    if l_oper_id is null then

                        com_api_error_pkg.raise_error(
                            i_error         => 'OPERATION_NOT_FOUND'
                          , i_env_param1    => i_claim_tab(i).claim_id
                          , i_env_param2    => i_claim_tab(i).acquirer_ref_num
                          , i_env_param3    => iss_api_card_pkg.get_card_mask(
                                                   iss_api_token_pkg.encode_card_number(i_claim_tab(i).card_number)
                                               )
                        );

                    else
                        -- create new case for disputed operation.
                        csm_ui_case_pkg.create_application(
                            i_oper_id               => l_oper_id
                          , i_participant_type      => case i_claim_tab(i).is_issuer
                                                           when com_api_const_pkg.TRUE
                                                           then com_api_const_pkg.PARTICIPANT_ISSUER
                                                           else com_api_const_pkg.PARTICIPANT_ACQUIRER
                                                       end
                          , o_appl_id               => l_case_id
                          , i_ext_claim_id          => i_claim_tab(i).claim_id
                          , i_ext_clearing_trans_id => l_oper_id
                        );

                        -- get created
                        trc_log_pkg.debug(
                            i_text        => 'Case is created. Case_id [#1]'
                          , i_env_param1  => l_case_id
                        );

                        csm_api_case_pkg.get_case(
                            i_case_id   => l_case_id
                          , o_case_rec  => l_case_rec
                        );

                    end if;

                elsif l_case_id is null and i_claim_tab(i).is_open = com_api_const_pkg.FALSE then

                    trc_log_pkg.debug(
                        i_text        => 'Claim is Closed. Do not need to create Case. claim_id [#1], is_open [#2]'
                      , i_env_param1  => i_claim_tab(i).claim_id
                      , i_env_param2  => i_claim_tab(i).is_open
                    );

                else -- Case is not null

                    -- get found case
                    trc_log_pkg.debug(
                        i_text       => 'Case is found. Case_id [#1]'
                      , i_env_param1 => l_case_id
                    );

                    csm_api_case_pkg.get_case(
                        i_case_id   => l_case_id
                      , o_case_rec  => l_case_rec
                    );
                end if;

                -- 2. work with child records of claim.
                if l_case_rec.case_id is not null then

                    -- 2.1 get chargeback of claim. And check then chargeback is exists in BO
                    if i_retrieval_tab.count >= l_retrieval_tab_index then
                        while i_retrieval_tab(l_retrieval_tab_index).claim_id = i_claim_tab(i).claim_id loop

                            -- search retrieval in mcw_fin
                            select min(id)
                              into l_fin_id
                              from mcw_fin f
                             where f.ext_message_id = i_retrieval_tab(l_retrieval_tab_index).request_id
                               and f.ext_claim_id   = i_retrieval_tab(l_retrieval_tab_index).claim_id
                               and f.inst_id        = i_inst_id;

                            if l_fin_id is null then -- need to create new message in mcw_fin

                                if i_retrieval_tab(l_retrieval_tab_index).iss_response_cd is null
                                    and i_retrieval_tab(l_retrieval_tab_index).acq_response_cd is null
                                then
                                    -- create RR
                                    l_is_retrieval := com_api_type_pkg.TRUE;

                                elsif i_retrieval_tab(l_retrieval_tab_index).acq_response_cd is not null then

                                    -- create Acquirer fulfillment request
                                    l_is_retrieval := com_api_type_pkg.FALSE;
                                else
                                    -- Skip. this is Issuer fulfillment. Currently we do not register it, 
                                    -- because we dont know message type of this message.
                                    null;
                                end if;

                                create_retrieval_request(
                                    i_network_id       => i_network_id
                                  , i_case_rec         => l_case_rec
                                  , i_de002            => i_retrieval_tab(l_retrieval_tab_index).card_number
                                  , i_de004            => i_retrieval_tab(l_retrieval_tab_index).amount
                                  , i_de049            => i_retrieval_tab(l_retrieval_tab_index).currency
                                  , i_de025            => i_retrieval_tab(l_retrieval_tab_index).retrieval_reason
                                  , i_p0228            => i_retrieval_tab(l_retrieval_tab_index).doc_needed
                                  , i_is_retrieval     => l_is_retrieval
                                  , i_status           => i_retrieval_tab(l_retrieval_tab_index).ext_msg_status
                                  , i_create_operation => i_create_operation
                                  , i_ext_claim_id     => i_retrieval_tab(l_retrieval_tab_index).claim_id
                                  , i_ext_message_id   => i_retrieval_tab(l_retrieval_tab_index).request_id
                                );

                            end if;

                            --check attachments for this message
                            --2.1.1
                            if i_attachment_tab.count >= l_attachment_tab_index then

                                process_attachments (
                                    i_claim_id      => i_claim_tab(i).claim_id
                                  , i_message_id    => i_retrieval_tab(l_retrieval_tab_index).request_id
                                  , i_fin_id        => l_fin_id
                                );

                            end if;

                            l_retrieval_tab_index := l_retrieval_tab_index + 1;
                            exit when l_retrieval_tab_index > i_retrieval_tab.count;
                        end loop;
                    end if; --end process retrieval

                    -- 2.2 get chargeback of claim. And check then chargeback is exists in BO
                    if i_chargeback_tab.count >= l_chargeback_tab_index then
                        while i_chargeback_tab(l_chargeback_tab_index).claim_id = i_claim_tab(i).claim_id loop

                            -- search retrieval in mcw_fin
                            select min(id)
                              into l_fin_id
                              from mcw_fin f
                             where f.ext_message_id = i_chargeback_tab(l_chargeback_tab_index).chargeback_id
                               and f.ext_claim_id   = i_chargeback_tab(l_chargeback_tab_index).claim_id
                               and f.inst_id        = i_inst_id;

                            if l_fin_id is null then -- need to create new message in mcw_fin.

                                create_chargeback(
                                    i_network_id             => i_network_id
                                  , i_case_rec               => l_case_rec
                                  , i_de002                  => i_claim_tab(i).card_number
                                  , i_de004                  => i_chargeback_tab(l_chargeback_tab_index).amount
                                  , i_de049                  => i_chargeback_tab(l_chargeback_tab_index).currency
                                  , i_de025                  => i_chargeback_tab(l_chargeback_tab_index).reason_code
                                  , i_de072                  => i_chargeback_tab(l_chargeback_tab_index).message_text
                                  , i_p0262                  => i_chargeback_tab(l_chargeback_tab_index).doc_needed
                                  , i_is_partial_chargeback  => i_chargeback_tab(l_chargeback_tab_index).is_partial_chargeback
                                  , i_chargeback_type        => i_chargeback_tab(l_chargeback_tab_index).chargeback_type
                                  , i_is_reversal            => i_chargeback_tab(l_chargeback_tab_index).reversal
                                  , i_status                 => i_chargeback_tab(l_chargeback_tab_index).ext_msg_status
                                  , i_create_operation       => i_create_operation
                                  , i_ext_claim_id           => i_chargeback_tab(l_chargeback_tab_index).claim_id
                                  , i_ext_message_id         => i_chargeback_tab(l_chargeback_tab_index).chargeback_id
                                );
                            end if; --If Chargeback alredy exists - do not do anythig

                            --check attachments for this message
                            --2.2.1
                            if i_attachment_tab.count >= l_attachment_tab_index then

                                process_attachments (
                                    i_claim_id      => i_claim_tab(i).claim_id
                                  , i_message_id    => i_chargeback_tab(l_chargeback_tab_index).chargeback_id
                                  , i_fin_id        => l_fin_id
                                );
                            end if;

                            l_chargeback_tab_index := l_chargeback_tab_index + 1;
                            exit when l_chargeback_tab_index > i_chargeback_tab.count;
                        end loop;
                    end if; --end process chargeback

                    -- 2.3 get fees of claim. And check then fees are exists in BO
                    if i_fee_tab.count >= l_fee_tab_index then
                        while i_fee_tab(l_fee_tab_index).claim_id = i_claim_tab(i).claim_id loop

                            -- search retrieval in mcw_fin
                            select min(id)
                              into l_fin_id
                              from mcw_fin f
                             where f.ext_message_id = i_fee_tab(l_fee_tab_index).fee_id
                               and f.ext_claim_id   = i_fee_tab(l_fee_tab_index).claim_id
                               and f.inst_id        = i_inst_id;

                            if l_fin_id is null then -- need to create new message in mcw_fin.

                                create_fee_collection(
                                    i_network_id         => i_network_id
                                  , i_case_rec           => l_case_rec
                                  , i_de002              => i_fee_tab(l_fee_tab_index).card_number
                                  , i_de004              => i_fee_tab(l_fee_tab_index).fee_amount
                                  , i_de049              => i_fee_tab(l_fee_tab_index).currency
                                  , i_de025              => i_fee_tab(l_fee_tab_index).reason_code
                                  , i_de072              => i_fee_tab(l_fee_tab_index).message
                                  , i_de073              => i_fee_tab(l_fee_tab_index).fee_date
                                  , i_de093              => i_fee_tab(l_fee_tab_index).destination_member
                                  , i_credit_receiver    => i_fee_tab(l_fee_tab_index).credit_receiver
                                  , i_create_operation   => i_create_operation
                                );

                            end if; --If fee alredy exists - do not do anythig

                            l_fee_tab_index := l_fee_tab_index + 1;
                            exit when l_fee_tab_index > i_fee_tab.count;
                        end loop;
                    end if; --end process fees

                    -- 3. check Claim and case Statuses.
                    -- 3.1 If case status is in ('APST0017', 'APST0021'), but Claim.is_open = 1, 
                    -- so case status must be updated
                    -- in loading dispute messages via mcw_api_dispute_pkg.change_case_status.
                    -- 3.2 If Claim.is_open = 0 and case status is not in ('APST0017', 'APST0021')
                    -- then need to update Case status to Closed.
                    if i_claim_tab(i).is_open = com_api_const_pkg.FALSE
                   and l_case_rec.case_status not in (
                        app_api_const_pkg.APPL_STATUS_CLOSED
                      , app_api_const_pkg.APPL_STATUS_CLOSED_WO_INV
                    ) then
                        csm_ui_case_pkg.change_case_status(
                            i_case_id       => l_case_rec.case_id
                          , i_appl_status   => app_api_const_pkg.APPL_STATUS_CLOSED
                        );
                    end if;
                end if;
            exception
                when others then
                    if is_fatal_error(sqlcode) then
                        -- As far as re-raising error erases information about exception point,
                        -- it is necessary to store this information before re-rasing an exception
                        trc_log_pkg.debug(
                            i_text       => LOG_PREFIX || 'FAILED with sqlerrm: ' || sqlerrm
                        );
                        raise;
                    else
                        rollback to savepoint mastercom_start_new_record;

                        l_excepted_count := l_excepted_count + 1;
                    end if;
            end;

            l_processed_count := l_processed_count + 1;

            if mod(l_processed_count, 100) = 0 then
                prc_api_stat_pkg.log_current(
                    i_current_count   => l_processed_count
                  , i_excepted_count  => l_excepted_count
                );
            end if;

        end loop;

    end if; -- estimated_count > 0

    prc_api_stat_pkg.log_end(
        i_excepted_total   => l_excepted_count
      , i_processed_total  => l_processed_count
      , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    com_api_sttl_day_pkg.unset_sysdate;

    trc_log_pkg.debug(
        i_text        => 'Last values: estimated_count [#1], processed_count [#2], excepted_count [#3]'
      , i_env_param1  => l_estimated_count
      , i_env_param2  => l_processed_count
      , i_env_param3  => l_excepted_count
    );

    trc_log_pkg.debug(
        i_text  => 'Loading MasterCom claims finished'
    );
exception
    when others then
        rollback to savepoint load_mastercom_claim_start;

        prc_api_stat_pkg.log_end(
            i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;

        raise;
end load;

end mcw_prc_mcom_pkg;
/
