create or replace package body vis_api_reject_pkg is
/*********************************************************
*  API for VISA rejected operations <br />
*  Created by Mashonkin V.(mashonkin@bpcbt.com)  at 17.06.2015 <br />
*  Last changed by $Author: mashonkin $ <br />
*  $LastChangedDate:: 2015-06-17 19:28:48 +0300#$ <br />
*  Revision: $LastChangedRevision: 52735 $ <br />
*  Module: vis_api_reject_pkg <br />
*  @headcom
**********************************************************/

procedure put_reject (
    i_msg in out vis_reject%ROWTYPE
) is
begin
    insert into vis_reject (
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
        , original_id
        , file_id
        , batch_id
        , record_number
        --, session_file_id
        , reason_code1
        , reason_code2
        , reason_code3
        , reason_code4
        , reason_code5
        , reason_code6
        , reason_code7
        , reason_code8
        , reason_code9
        , reason_code10
    )
    values (
        vis_reject_seq.nextval
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
        , i_msg.original_id
        , i_msg.file_id
        , i_msg.batch_id
        , i_msg.record_number
        --, i_msg.session_file_id
        , i_msg.reason_code1
        , i_msg.reason_code2
        , i_msg.reason_code3
        , i_msg.reason_code4
        , i_msg.reason_code5
        , i_msg.reason_code6
        , i_msg.reason_code7
        , i_msg.reason_code8
        , i_msg.reason_code9
        , i_msg.reason_code10
    )
    returning
        id
    into
        i_msg.id;

end put_reject;

-- save operation rejected data in format 'Operation reject data'
procedure put_reject_data (
    i_reject_rec        in vis_reject%rowtype
    , o_reject_data_id  out com_api_type_pkg.t_long_id
) is
    l_msg               vis_reject_data%rowtype;
    l_collect_only_flag com_api_type_pkg.t_byte_char;
begin

    begin
      select a.oper_type
           , b.card_number
           , v.arn
           , v.collect_only_flag
        into l_msg.operation_type
           , l_msg.card_number
           , l_msg.arn
           , l_collect_only_flag
        from opr_operation a
             , opr_card b
             , vis_fin_message v
       where a.id = b.oper_id
         and a.id = i_reject_rec.original_id
         and v.id = i_reject_rec.original_id;
    exception
        when no_data_found then
            null;
    end;
    --
    l_msg.reject_id           := i_reject_rec.id;
    l_msg.original_id         := i_reject_rec.original_id;
    --(REJECT RECORDS INFORMED BY NATIONAL/INTERNATIONAL SCHEMES
    l_msg.reject_type         := com_api_reject_pkg.REJECT_TYPE_REGULATORS_SCHEMES; -- RJTP0003
    l_msg.process_date        := g_process_run_date;
    l_msg.originator_network  := com_api_reject_pkg.get_iss_network_by_bin(i_bin => i_reject_rec.src_bin);
    l_msg.destination_network := com_api_reject_pkg.get_iss_network_by_bin(i_bin => i_reject_rec.dst_bin);
    l_msg.scheme              := com_api_reject_pkg.C_DEF_SCHEME;
    l_msg.reject_code         := com_api_reject_pkg.REJECT_CODE_INVALID_FORMAT; -- RJCD0001
    l_msg.assigned            := null; --assigned user ?
    l_msg.resolution_mode     := com_api_reject_pkg.REJECT_RESOLUT_MODE_FORWARD; --'RJMD001';  -- FORWARD
    l_msg.resolution_date     := null; -- just created, not resolved
    l_msg.status              := com_api_reject_pkg.REJECT_STATUS_OPENED; --'RJST0001'; -- Opened
    --

    insert into vis_reject_data (
        id
        , reject_id
        , original_id
        , reject_type
        , process_date
        , originator_network
        , destination_network
        , scheme
        , reject_code
        , operation_type
        , assigned
        , card_number
        , arn
        , resolution_mode
        , resolution_date
        , status
    )
    values (
        vis_reject_data_seq.nextval
        , l_msg.reject_id
        , l_msg.original_id
        , l_msg.reject_type
        , l_msg.process_date
        , l_msg.originator_network
        , l_msg.destination_network
        , l_msg.scheme
        , l_msg.reject_code
        , l_msg.operation_type
        , l_msg.assigned
        , l_msg.card_number
        , l_msg.arn
        , l_msg.resolution_mode
        , l_msg.resolution_date
        , l_msg.status
    )
    returning
        id
    into
        o_reject_data_id;

    -- if not Collection only message
    -- creates reversal operation, register reject event, set oper_status = REJECTED (OPST700), register oper stage = REJECTED
    if nvl(l_collect_only_flag, 'V') != 'C' then
        finalize_rejected_oper(
            i_oper_id => l_msg.original_id
        );
    end if;

end put_reject_data;

-- put 'Operation reject data' for further validation of auth messages
procedure put_reject_data_dummy (
    i_oper_id           in com_api_type_pkg.t_long_id
    , o_reject_data_id  out com_api_type_pkg.t_long_id
) is
    l_msg vis_reject_data%rowtype;
begin
    if i_oper_id is not null then
        begin
          select a.oper_type
               , b.card_number
               , v.arn
            into l_msg.operation_type
               , l_msg.card_number
               , l_msg.arn
            from opr_operation a
                 , opr_card b
                 , vis_fin_message v
           where a.id = b.oper_id
             and a.id = i_oper_id
             and v.id = i_oper_id;
        exception
            when no_data_found then
                null;
        end;
    end if;
    --
    l_msg.reject_id           := null; -- vis_rject is empty for auth messages
    l_msg.original_id         := i_oper_id;
    --(REJECT RECORDS INFORMED BY NATIONAL/INTERNATIONAL SCHEMES
    l_msg.reject_type         := com_api_reject_pkg.REJECT_TYPE_PRIMARY_VALIDATION; -- RJTP0001
    l_msg.process_date        := g_process_run_date;
    l_msg.originator_network  := null;
    l_msg.destination_network := null;
    l_msg.scheme              := com_api_reject_pkg.C_DEF_SCHEME;
    l_msg.reject_code         := com_api_reject_pkg.REJECT_CODE_INVALID_FORMAT; -- RJCD0001
    l_msg.assigned            := null; --assigned user ?
    l_msg.resolution_mode     := com_api_reject_pkg.REJECT_RESOLUT_MODE_FORWARD; --'RJMD001';  -- FORWARD
    l_msg.resolution_date     := null; -- just created, not resolved
    l_msg.status              := com_api_reject_pkg.REJECT_STATUS_OPENED; --'RJST0001'; -- Opened
    --

    insert into vis_reject_data (
        id
        , reject_id
        , original_id
        , reject_type
        , process_date
        , originator_network
        , destination_network
        , scheme
        , reject_code
        , operation_type
        , assigned
        , card_number
        , arn
        , resolution_mode
        , resolution_date
        , status
    )
    values (
        vis_reject_data_seq.nextval
        , l_msg.reject_id
        , l_msg.original_id
        , l_msg.reject_type
        , l_msg.process_date
        , l_msg.originator_network
        , l_msg.destination_network
        , l_msg.scheme
        , l_msg.reject_code
        , l_msg.operation_type
        , l_msg.assigned
        , l_msg.card_number
        , l_msg.arn
        , l_msg.resolution_mode
        , l_msg.resolution_date
        , l_msg.status
    )
    returning
        id
    into
        o_reject_data_id;

end put_reject_data_dummy;


    function check_number_field(
        i_field_value       in com_api_type_pkg.t_text
        , i_reject_data_id  in com_api_type_pkg.t_long_id
        , i_start_position  in com_api_type_pkg.t_long_id
        , i_end_position    in com_api_type_pkg.t_long_id
    ) return com_api_type_pkg.t_boolean
    is
        l_number_value com_api_type_pkg.t_long_id;
    begin
        l_number_value := to_number(i_field_value);
        return com_api_const_pkg.TRUE;
    exception
        when others then
            put_reject_code(
                i_reject_data_id  => i_reject_data_id
                , i_reject_code   => com_api_reject_pkg.C_MSG_FIELD_IS_NOT_NUMBER
                , i_description   => sqlerrm
                , i_field         => 'Field ['||i_start_position||';'||i_end_position||'] value ['||i_field_value||']'
            );
        return com_api_const_pkg.FALSE;
    end check_number_field;

    function check_date_field(
        i_field_value       in com_api_type_pkg.t_text
        , i_date_format     in com_api_type_pkg.t_text
        , i_reject_data_id  in com_api_type_pkg.t_long_id
        , i_start_position  in com_api_type_pkg.t_long_id
        , i_end_position    in com_api_type_pkg.t_long_id
    ) return com_api_type_pkg.t_boolean
    is
        l_date_value date;
    begin
        l_date_value := to_date(i_field_value, i_date_format);
        return com_api_const_pkg.TRUE;
    exception
        when others then
            put_reject_code(
                i_reject_data_id  => i_reject_data_id
                , i_reject_code   => com_api_reject_pkg.C_MSG_FIELD_IS_NOT_DATE
                , i_description   => sqlerrm
                , i_field         => 'Field ['||i_start_position||';'||i_end_position||'] value ['||i_field_value||'] format [' ||i_date_format||']'
            );
        return com_api_const_pkg.FALSE;
    end check_date_field;

    function check_hex_field(
        i_field_value       in com_api_type_pkg.t_text
        , i_reject_data_id  in com_api_type_pkg.t_long_id
        , i_start_position  in com_api_type_pkg.t_long_id
        , i_end_position    in com_api_type_pkg.t_long_id
    ) return com_api_type_pkg.t_boolean
    is
        l_hex_value com_api_type_pkg.t_raw_data;
    begin
        l_hex_value := hextoraw(i_field_value);
        return com_api_const_pkg.TRUE;
    exception
        when others then
            put_reject_code(
                i_reject_data_id  => i_reject_data_id
                , i_reject_code   => com_api_reject_pkg.C_MSG_FIELD_IS_NOT_HEX
                , i_description   => sqlerrm --ORA-01465: invalid hex number
                , i_field         => 'Field ['||i_start_position||';'||i_end_position||'] value ['||i_field_value||']'
            );
        return com_api_const_pkg.FALSE;
    end check_hex_field;

-- creates reversal operation, register reject event, set oper_status = REJECTED (OPST700), register oper stage = REJECTED
procedure finalize_rejected_oper (
    i_oper_id in com_api_type_pkg.t_long_id
)
is
begin
    evt_api_event_pkg.register_event (
          i_event_type    =>  com_api_reject_pkg.EVENT_REGISTER_REJECT --EVNT1916
        , i_eff_date      =>  com_api_sttl_day_pkg.get_sysdate
        , i_entity_type   =>  opr_api_const_pkg.ENTITY_TYPE_OPERATION
        , i_object_id     =>  i_oper_id
        , i_inst_id       =>  ost_api_const_pkg.DEFAULT_INST
        , i_split_hash    =>  com_api_hash_pkg.get_split_hash(opr_api_const_pkg.ENTITY_TYPE_OPERATION, i_oper_id)
    );

    opr_ui_operation_pkg.modify_status (
        i_oper_id         => i_oper_id
        , i_oper_status   => com_api_reject_pkg.OPER_STATUS_REJECTED --OPST0700
    );

    insert into opr_oper_stage (
        oper_id
        , proc_stage
        , exec_order
        , status
        , split_hash
    ) values (
        i_oper_id
        , opr_api_const_pkg.PROCESSING_STAGE_REJECTED
        , 1
        , com_api_reject_pkg.OPER_STATUS_REJECTED
        , com_api_hash_pkg.get_split_hash(opr_api_const_pkg.ENTITY_TYPE_OPERATION, i_oper_id)
    );

    -- reversal should be made for every rejected operation during its loading
    create_reversal_operation(
        i_oper_id => i_oper_id
    );
end;

procedure validate_visa_record_auth(
    i_oper_id     in com_api_type_pkg.t_long_id
    , i_visa_data in com_api_type_pkg.t_text
)
is
    l_validation_result     com_api_type_pkg.t_boolean;
    l_reject_data_id        com_api_type_pkg.t_long_id;
begin
    -- save operation rejected data in format 'Operation reject data'
    put_reject_data_dummy(
        i_oper_id           => i_oper_id
        , o_reject_data_id  => l_reject_data_id
    );
    -- validate record and save visa rejected codes
    l_validation_result :=
        validate_visa_record(
           i_reject_data_id => l_reject_data_id
           , i_visa_record  => i_visa_data
        );
    if l_validation_result = com_api_type_pkg.true then
        delete from vis_reject_code
         where reject_data_id = l_reject_data_id;
        --
        delete from vis_reject_data
         where id = l_reject_data_id;
    else
        -- creates reversal operation, register reject event, set oper_status = REJECTED (OPST700), register oper stage = REJECTED
        finalize_rejected_oper(
            i_oper_id => i_oper_id
        );
    end if;
end;

function validate_visa_record (
    i_reject_data_id   in com_api_type_pkg.t_long_id
    , i_visa_record    in com_api_type_pkg.t_text
) return com_api_type_pkg.t_boolean
is
    l_validation_result   com_api_type_pkg.t_boolean := com_api_const_pkg.TRUE;
    l_transaction_code    com_api_type_pkg.t_long_id;
    l_tcr                 com_api_type_pkg.t_one_char;
    l_field_value         com_api_type_pkg.t_text;

    cursor vis_rules_cur (
        i_transaction_code  com_api_type_pkg.t_long_id
        , i_tcr             com_api_type_pkg.t_one_char
    ) is
      select
          start_position
          , end_position
          , upper(trim(data_type)) as data_type
          , data_format
          , upper(trim(mandatory)) as mandatory
          , dictionary
          , lov_id
          , direction
        from vis_validation_rules
       where transaction_code = i_transaction_code
         and tcr              = i_tcr
         and nvl(start_position, 0)  <= nvl(end_position, 0)
       order by start_position;

begin
    l_validation_result := com_api_const_pkg.true;
    --
    if trim(i_visa_record) is null then
        return l_validation_result;
    end if;
    l_transaction_code := to_number(ltrim(substr(i_visa_record, 1, 2), '0'));
    l_tcr              := nvl(substr(i_visa_record, 4, 1), '0');
    --
    for i in vis_rules_cur(
        i_transaction_code => l_transaction_code
        , i_tcr            => l_tcr
    ) loop
        l_field_value := trim(substr(i_visa_record, i.start_position, (i.end_position - i.start_position) + 1));
        --
        if i.mandatory = 'M' and l_field_value is null
        then
            put_reject_code(
                i_reject_data_id => i_reject_data_id
                , i_reject_code  => com_api_reject_pkg.C_MSG_MANDAT_FIELD_NOT_PRESENT
                , i_description  => com_api_reject_pkg.C_MSG_MANDAT_FIELD_NOT_PRESENT
                , i_field        => 'Field ['||i.start_position||';'||i.end_position||'] value ['||l_field_value||']'
            );
            l_validation_result := com_api_const_pkg.false;
        end if;
        --
        if l_field_value is not null then
            case i.data_type
            when 'NUMBER' then
                l_validation_result :=
                    check_number_field(
                        i_field_value       => l_field_value
                        , i_reject_data_id  => i_reject_data_id
                        , i_start_position  => i.start_position
                        , i_end_position    => i.end_position
                    );
            when 'DATE'   then
                l_validation_result :=
                    check_date_field(
                        i_field_value       => l_field_value
                        , i_date_format     => i.data_format
                        , i_reject_data_id  => i_reject_data_id
                        , i_start_position  => i.start_position
                        , i_end_position    => i.end_position
                    );
            when 'HEX'    then
                l_validation_result :=
                    check_hex_field(
                        i_field_value       => l_field_value
                        , i_reject_data_id  => i_reject_data_id
                        , i_start_position  => i.start_position
                        , i_end_position    => i.end_position
                    );
            else
                null;
            end case;
            --
            if i.data_type in ('STRING', 'NUMBER') then
                -- checking of DICTIONARY value (com_dictionary)
                if i.dictionary is not null then
                    l_validation_result :=
                        check_dict_field(
                            i_field_value      => l_field_value
                            , i_dict           => i.dictionary
                            , i_reject_data_id => i_reject_data_id
                            , i_start_position => i.start_position
                            , i_end_position   => i.end_position
                        );
                end if;
                --checking of LOV_ID value (com_lov)
                if i.lov_id is not null then
                    l_validation_result :=
                        com_ui_lov_pkg.check_lov_value(
                            i_lov_id => i.lov_id
                          , i_value  => l_field_value
                        );
                end if;
            end if;

        end if;
    end loop;
    --
    return l_validation_result;
end validate_visa_record;


    function check_dict_field(
        i_field_value       in com_api_type_pkg.t_text
        , i_dict            in com_api_type_pkg.t_dict_value
        , i_reject_data_id  in com_api_type_pkg.t_long_id
        , i_start_position  in com_api_type_pkg.t_long_id
        , i_end_position    in com_api_type_pkg.t_long_id
    ) return com_api_type_pkg.t_boolean
    is
        l_code com_api_type_pkg.t_dict_value;
    begin
        --modifyed copy of com_api_dictionary_pkg.check_article
        begin
            select code
              into l_code
              from com_dictionary
             where dict = 'DICT'
               and code = upper(i_dict);
        exception
            when no_data_found then
                put_reject_code(
                    i_reject_data_id  => i_reject_data_id
                    , i_reject_code   => com_api_reject_pkg.C_MSG_DICTIONARY_NOT_EXISTS
                    , i_description   => sqlerrm
                    , i_field         => 'Field ['||i_start_position||';'||i_end_position||'] value ['||i_field_value||'] dict ['||i_dict||']'
                );
                return com_api_const_pkg.FALSE;
        end;
        -- value can content only dict article or whole name with dict name
        begin
            select code
              into l_code
              from com_dictionary
             where dict = upper(i_dict)
               and code = lpad(nvl(substr(i_field_value, 5), i_field_value), 4 , '0');
        exception
            when no_data_found then
                put_reject_code(
                    i_reject_data_id  => i_reject_data_id
                    , i_reject_code   => com_api_reject_pkg.C_MSG_CODE_NOT_EXISTS_IN_DICT
                    , i_description   => sqlerrm
                    , i_field         => 'Field ['||i_start_position||';'||i_end_position||'] value ['||i_field_value||'] dict ['||i_dict||']'
                );
                return com_api_const_pkg.FALSE;
        end;
        --
        return com_api_const_pkg.TRUE;
    exception
        when others then
            put_reject_code(
                i_reject_data_id  => i_reject_data_id
                , i_reject_code   => com_api_reject_pkg.C_MSG_CHECK_DICT_FIELD_FAILED
                , i_description   => sqlerrm
                , i_field         => 'Field ['||i_start_position||';'||i_end_position||'] value ['||i_field_value||'] dict ['||i_dict||']'
            );
        return com_api_const_pkg.FALSE;
    end check_dict_field;


    -- creates vis_fin_message and vis_card
    procedure create_duplicate_vis_fin (
        i_oper_id         in com_api_type_pkg.t_long_id
      , i_new_oper_id     in com_api_type_pkg.t_long_id
      , i_create_reversal in com_api_type_pkg.t_boolean default com_api_type_pkg.false
    ) is
        l_vis_fin_rec vis_api_type_pkg.t_visa_fin_mes_rec;
        l_id          com_api_type_pkg.t_long_id;

    begin
        trc_log_pkg.debug(
            i_text       => 'create_duplicate_vis_fin: started, original id [#1], new id [#2]'
          , i_env_param1 => i_oper_id
          , i_env_param2 => i_new_oper_id
        );
        select id
             , status
             , is_reversal
             , is_incoming
             , is_returned
             , is_invalid
             , inst_id
             , network_id
             , trans_code
             , trans_code_qualifier
             , card_id
             , card_hash
             , card_mask
             , oper_amount
             , oper_currency
             , oper_date
             , sttl_amount
             , sttl_currency
             , arn
             , acq_business_id
             , merchant_name
             , merchant_city
             , merchant_country
             , merchant_postal_code
             , merchant_region
             , mcc
             , req_pay_service
             , usage_code
             , reason_code
             , settlement_flag
             , auth_char_ind
             , auth_code
             , pos_terminal_cap
             , inter_fee_ind
             , crdh_id_method
             , collect_only_flag
             , pos_entry_mode
             , central_proc_date
             , reimburst_attr
             , iss_workst_bin
             , acq_workst_bin
             , chargeback_ref_num
             , docum_ind
             , member_msg_text
             , spec_cond_ind
             , fee_program_ind
             , issuer_charge
             , merchant_number
             , terminal_number
             , national_reimb_fee
             , electr_comm_ind
             , spec_chargeback_ind
             , interface_trace_num
             , unatt_accept_term_ind
             , prepaid_card_ind
             , service_development
             , avs_resp_code
             , auth_source_code
             , purch_id_format
             , account_selection
             , installment_pay_count
             , purch_id
             , cashback
             , chip_cond_code
             , transaction_id
             , pos_environment
             , transaction_type
             , card_seq_number
             , terminal_profile
             , unpredict_number
             , appl_trans_counter
             , appl_interch_profile
             , cryptogram
             , term_verif_result
             , cryptogram_amount
             , card_expir_date
             , cryptogram_version
             , cvv2_result_code
             , auth_resp_code
             , card_verif_result
             , floor_limit_ind
             , exept_file_ind
             , pcas_ind
             , issuer_appl_data
             , issuer_script_result
             , network_amount
             , network_currency
             , dispute_id
             , file_id
             , batch_id
             , record_number
             , rrn
             , acquirer_bin
             , merchant_street
             , cryptogram_info_data
             , null--, card_number
             , merchant_verif_value
             , host_inst_id
             , proc_bin
             , chargeback_reason_code
             , destination_channel
             , source_channel
             , acq_inst_bin
             , spend_qualified_ind
             , clearing_sequence_num
             , clearing_sequence_count
             , service_code
             , business_format_code
             , token_assurance_level
             , pan_token
             , validation_code
             , payment_forms_num
             , business_format_code_e
             , agent_unique_id
             , additional_auth_method
             , additional_reason_code
             , product_id
             , auth_amount
             , auth_currency
             , form_factor_indicator
             , fast_funds_indicator
             , business_format_code_3
             , business_application_id
             , source_of_funds
             , payment_reversal_code
             , sender_reference_number
             , sender_account_number
             , sender_name
             , sender_address
             , sender_city
             , sender_state
             , sender_country
             , network_code
             , fee_interchange_amount
             , fee_interchange_sign
             , program_id
             , dcc_indicator
          into l_vis_fin_rec.id
             , l_vis_fin_rec.status
             , l_vis_fin_rec.is_reversal
             , l_vis_fin_rec.is_incoming
             , l_vis_fin_rec.is_returned
             , l_vis_fin_rec.is_invalid
             , l_vis_fin_rec.inst_id
             , l_vis_fin_rec.network_id
             , l_vis_fin_rec.trans_code
             , l_vis_fin_rec.trans_code_qualifier
             , l_vis_fin_rec.card_id
             , l_vis_fin_rec.card_hash
             , l_vis_fin_rec.card_mask
             , l_vis_fin_rec.oper_amount
             , l_vis_fin_rec.oper_currency
             , l_vis_fin_rec.oper_date
             , l_vis_fin_rec.sttl_amount
             , l_vis_fin_rec.sttl_currency
             , l_vis_fin_rec.arn
             , l_vis_fin_rec.acq_business_id
             , l_vis_fin_rec.merchant_name
             , l_vis_fin_rec.merchant_city
             , l_vis_fin_rec.merchant_country
             , l_vis_fin_rec.merchant_postal_code
             , l_vis_fin_rec.merchant_region
             , l_vis_fin_rec.mcc
             , l_vis_fin_rec.req_pay_service
             , l_vis_fin_rec.usage_code
             , l_vis_fin_rec.reason_code
             , l_vis_fin_rec.settlement_flag
             , l_vis_fin_rec.auth_char_ind
             , l_vis_fin_rec.auth_code
             , l_vis_fin_rec.pos_terminal_cap
             , l_vis_fin_rec.inter_fee_ind
             , l_vis_fin_rec.crdh_id_method
             , l_vis_fin_rec.collect_only_flag
             , l_vis_fin_rec.pos_entry_mode
             , l_vis_fin_rec.central_proc_date
             , l_vis_fin_rec.reimburst_attr
             , l_vis_fin_rec.iss_workst_bin
             , l_vis_fin_rec.acq_workst_bin
             , l_vis_fin_rec.chargeback_ref_num
             , l_vis_fin_rec.docum_ind
             , l_vis_fin_rec.member_msg_text
             , l_vis_fin_rec.spec_cond_ind
             , l_vis_fin_rec.fee_program_ind
             , l_vis_fin_rec.issuer_charge
             , l_vis_fin_rec.merchant_number
             , l_vis_fin_rec.terminal_number
             , l_vis_fin_rec.national_reimb_fee
             , l_vis_fin_rec.electr_comm_ind
             , l_vis_fin_rec.spec_chargeback_ind
             , l_vis_fin_rec.interface_trace_num
             , l_vis_fin_rec.unatt_accept_term_ind
             , l_vis_fin_rec.prepaid_card_ind
             , l_vis_fin_rec.service_development
             , l_vis_fin_rec.avs_resp_code
             , l_vis_fin_rec.auth_source_code
             , l_vis_fin_rec.purch_id_format
             , l_vis_fin_rec.account_selection
             , l_vis_fin_rec.installment_pay_count
             , l_vis_fin_rec.purch_id
             , l_vis_fin_rec.cashback
             , l_vis_fin_rec.chip_cond_code
             , l_vis_fin_rec.transaction_id
             , l_vis_fin_rec.pos_environment
             , l_vis_fin_rec.transaction_type
             , l_vis_fin_rec.card_seq_number
             , l_vis_fin_rec.terminal_profile
             , l_vis_fin_rec.unpredict_number
             , l_vis_fin_rec.appl_trans_counter
             , l_vis_fin_rec.appl_interch_profile
             , l_vis_fin_rec.cryptogram
             , l_vis_fin_rec.term_verif_result
             , l_vis_fin_rec.cryptogram_amount
             , l_vis_fin_rec.card_expir_date
             , l_vis_fin_rec.cryptogram_version
             , l_vis_fin_rec.cvv2_result_code
             , l_vis_fin_rec.auth_resp_code
             , l_vis_fin_rec.card_verif_result
             , l_vis_fin_rec.floor_limit_ind
             , l_vis_fin_rec.exept_file_ind
             , l_vis_fin_rec.pcas_ind
             , l_vis_fin_rec.issuer_appl_data
             , l_vis_fin_rec.issuer_script_result
             , l_vis_fin_rec.network_amount
             , l_vis_fin_rec.network_currency
             , l_vis_fin_rec.dispute_id
             , l_vis_fin_rec.file_id
             , l_vis_fin_rec.batch_id
             , l_vis_fin_rec.record_number
             , l_vis_fin_rec.rrn
             , l_vis_fin_rec.acquirer_bin
             , l_vis_fin_rec.merchant_street
             , l_vis_fin_rec.cryptogram_info_data
             , l_vis_fin_rec.card_number
             , l_vis_fin_rec.merchant_verif_value
             , l_vis_fin_rec.host_inst_id
             , l_vis_fin_rec.proc_bin
             , l_vis_fin_rec.chargeback_reason_code
             , l_vis_fin_rec.destination_channel
             , l_vis_fin_rec.source_channel
             , l_vis_fin_rec.acq_inst_bin
             , l_vis_fin_rec.spend_qualified_ind
             , l_vis_fin_rec.clearing_sequence_num
             , l_vis_fin_rec.clearing_sequence_count
             , l_vis_fin_rec.service_code
             , l_vis_fin_rec.business_format_code
             , l_vis_fin_rec.token_assurance_level
             , l_vis_fin_rec.pan_token
             , l_vis_fin_rec.validation_code
             , l_vis_fin_rec.payment_forms_num
             , l_vis_fin_rec.business_format_code_e
             , l_vis_fin_rec.agent_unique_id
             , l_vis_fin_rec.additional_auth_method
             , l_vis_fin_rec.additional_reason_code
             , l_vis_fin_rec.product_id
             , l_vis_fin_rec.auth_amount
             , l_vis_fin_rec.auth_currency
             , l_vis_fin_rec.form_factor_indicator
             , l_vis_fin_rec.fast_funds_indicator
             , l_vis_fin_rec.business_format_code_3
             , l_vis_fin_rec.business_application_id
             , l_vis_fin_rec.source_of_funds
             , l_vis_fin_rec.payment_reversal_code
             , l_vis_fin_rec.sender_reference_number
             , l_vis_fin_rec.sender_account_number
             , l_vis_fin_rec.sender_name
             , l_vis_fin_rec.sender_address
             , l_vis_fin_rec.sender_city
             , l_vis_fin_rec.sender_state
             , l_vis_fin_rec.sender_country
             , l_vis_fin_rec.network_code
             , l_vis_fin_rec.interchange_fee_amount
             , l_vis_fin_rec.interchange_fee_sign
             , l_vis_fin_rec.program_id
             , l_vis_fin_rec.dcc_indicator
          from vis_fin_message_vw
         where id = i_oper_id;
        --
        if i_create_reversal = com_api_type_pkg.true then
            l_vis_fin_rec.is_reversal := com_api_type_pkg.true;
        end if;
        --
        l_vis_fin_rec.id := i_new_oper_id; -- replace ID with newly genarated operation
        --
        l_id := vis_api_fin_message_pkg.put_message(
                i_fin_rec => l_vis_fin_rec
            );
        --
        trc_log_pkg.debug(
            i_text       => 'create_duplicate_vis_fin: ended.'
        );
    end create_duplicate_vis_fin;

    -- reversal should be made for every rejected operation during its loading
    procedure create_reversal_operation (
        i_oper_id in com_api_type_pkg.t_long_id
    ) is
        l_vis_cnt          com_api_type_pkg.t_long_id;
        l_mcw_cnt          com_api_type_pkg.t_long_id;
        l_reversal_oper_id com_api_type_pkg.t_long_id;
        l_id               com_api_type_pkg.t_long_id;
    begin
        -- check if dulicate need to be made
        select count(id)
          into l_vis_cnt
          from vis_reject_data
         where original_id = i_oper_id;
        --
        select count(id)
          into l_mcw_cnt
          from mcw_reject_data
         where original_id = i_oper_id;
        -- visa
        if l_vis_cnt = 1 then
            select id
                 , reversal_oper_id
              into l_id
                 , l_reversal_oper_id
              from vis_reject_data
             where original_id = i_oper_id;
            --
            if l_reversal_oper_id is null then
                --
                l_reversal_oper_id :=
                    create_duplicate_operation(
                        i_oper_id           => i_oper_id
                        , i_create_reversal => com_api_type_pkg.true
                    );
                --
                update vis_reject_data
                   set reversal_oper_id = l_reversal_oper_id
                 where id = l_id;
            else
                trc_log_pkg.warn(
                    i_text       => 'create_reversal_operation: vis Reversal [#1] for operation [#2] have been already created.'
                  , i_env_param1 => l_reversal_oper_id
                  , i_env_param2 => i_oper_id
                );
            end if;
        -- mastercard
        elsif l_mcw_cnt = 1 then
            select id
                 , reversal_oper_id
              into l_id
                 , l_reversal_oper_id
              from mcw_reject_data
             where original_id = i_oper_id;
            --
            if l_reversal_oper_id is null then
                --
                l_reversal_oper_id :=
                    create_duplicate_operation(
                        i_oper_id           => i_oper_id
                        , i_create_reversal => com_api_type_pkg.true
                    );
                --
                update mcw_reject_data
                   set reversal_oper_id = l_reversal_oper_id
                 where id = l_id;
            else
                trc_log_pkg.warn(
                    i_text       => 'create_reversal_operation: mcw Reversal [#1] for operation [#2] have been already created.'
                  , i_env_param1 => l_reversal_oper_id
                  , i_env_param2 => i_oper_id
                );
            end if;
        --
        else
            trc_log_pkg.error(
                i_text       => 'create_reversal_operation: Operation [#1] not found in rejected data.'
              , i_env_param1 => i_oper_id
            );
        end if;
    end create_reversal_operation;

    -- duplicate should be made when rejected operation edited first time
    function create_duplicate_operation (
          i_oper_id         in com_api_type_pkg.t_long_id
        , i_create_reversal in com_api_type_pkg.t_boolean default com_api_type_pkg.false
    ) return com_api_type_pkg.t_long_id
    is
        l_oper_rec        opr_operation%rowtype;   --opr_api_type_pkg.t_oper_rec; --hard to match
        l_new_oper_id     com_api_type_pkg.t_long_id := null;
        l_participant     opr_api_type_pkg.t_oper_part_rec;
        l_participant_tab opr_api_type_pkg.t_oper_part_by_type_tab;
        --
    begin
        trc_log_pkg.debug(
            i_text       => 'create_duplicate_operation: started, original id [#1].'
          , i_env_param1 => i_oper_id
        );

        select a.*
          into l_oper_rec
          from opr_operation a
         where a.id = i_oper_id;

        -- get participants
        l_participant_tab.delete;
        for i in (
            select o.participant_type
              from opr_participant o
             where o.oper_id = i_oper_id
        ) loop
            opr_api_operation_pkg.get_participant (
                i_oper_id           => i_oper_id
              , i_participaint_type => i.participant_type
              , o_participant       => l_participant
            );
            l_participant_tab(i.participant_type) := l_participant;
        end loop;

        -- duplicates operation, its participants and opr_card
        opr_api_create_pkg.create_operation(
              io_oper_id                => l_new_oper_id
            , i_session_id              => l_oper_rec.session_id
            , i_is_reversal             =>
                case when i_create_reversal = com_api_type_pkg.true
                        then 1
                     else l_oper_rec.is_reversal
                end
            , i_original_id             =>
                case when i_create_reversal = com_api_type_pkg.true
                        then l_oper_rec.id -- reversal must refer on id of reversed operation
                     else l_oper_rec.original_id
                end
            , i_oper_type               =>
                case
                when i_create_reversal = com_api_type_pkg.true then
                     case
                     when l_oper_rec.oper_type in (--debit oper types - replace on credit
                              opr_api_const_pkg.OPERATION_TYPE_PURCHASE   -- OPTP0000
                            , opr_api_const_pkg.OPERATION_TYPE_ATM_CASH   -- OPTP0001
                            , opr_api_const_pkg.OPERATION_TYPE_CASHBACK   -- OPTP0009
                          )
                          then opr_api_const_pkg.OPERATION_TYPE_REJECT_CREDIT -- OPTP0701
                     when l_oper_rec.oper_type in (--credit oper types - replace on debit
                              opr_api_const_pkg.OPERATION_TYPE_REFUND     -- OPTP0020
                            , opr_api_const_pkg.OPERATION_TYPE_CASHIN     -- OPTP0022
                            , opr_api_const_pkg.OPERATION_TYPE_P2P_CREDIT -- OPTP0026
                         )
                         then opr_api_const_pkg.OPERATION_TYPE_REJECT_DEBIT   -- OPTP0702
                     else l_oper_rec.oper_type
                     end
                else l_oper_rec.oper_type
                end
            , i_oper_reason             => l_oper_rec.oper_reason
            , i_msg_type                => l_oper_rec.msg_type
            , i_status                  => l_oper_rec.status
            , i_status_reason           => l_oper_rec.status_reason
            , i_sttl_type               => l_oper_rec.sttl_type
            , i_terminal_type           => l_oper_rec.terminal_type
            , i_acq_inst_bin            => l_oper_rec.acq_inst_bin
            , i_forw_inst_bin           => l_oper_rec.forw_inst_bin
            , i_merchant_number         => l_oper_rec.merchant_number
            , i_terminal_number         => l_oper_rec.terminal_number
            , i_merchant_name           => l_oper_rec.merchant_name
            , i_merchant_street         => l_oper_rec.merchant_street
            , i_merchant_city           => l_oper_rec.merchant_city
            , i_merchant_region         => l_oper_rec.merchant_region
            , i_merchant_country        => l_oper_rec.merchant_country
            , i_merchant_postcode       => l_oper_rec.merchant_postcode
            , i_mcc                     => l_oper_rec.mcc
            , i_originator_refnum       => l_oper_rec.originator_refnum
            , i_network_refnum          => l_oper_rec.network_refnum
            , i_oper_count              => l_oper_rec.oper_count
            , i_oper_request_amount     => l_oper_rec.oper_request_amount
            , i_oper_amount_algorithm   => l_oper_rec.oper_amount_algorithm
            , i_oper_amount             => l_oper_rec.oper_amount
            , i_oper_currency           => l_oper_rec.oper_currency
            , i_oper_cashback_amount    => l_oper_rec.oper_cashback_amount
            , i_oper_replacement_amount => l_oper_rec.oper_replacement_amount
            , i_oper_surcharge_amount   => l_oper_rec.oper_surcharge_amount
            , i_oper_date               => l_oper_rec.oper_date
            , i_match_status            => l_oper_rec.match_status
            , i_sttl_amount             => l_oper_rec.sttl_amount
            , i_sttl_currency           => l_oper_rec.sttl_currency
            , i_dispute_id              => l_oper_rec.dispute_id
            , i_payment_order_id        => l_oper_rec.payment_order_id
            , i_payment_host_id         => l_oper_rec.payment_host_id
            , i_forced_processing       => l_oper_rec.forced_processing
            , i_proc_mode               => l_oper_rec.proc_mode
            , i_incom_sess_file_id      => l_oper_rec.incom_sess_file_id
            , io_participants           => l_participant_tab
        );
        if i_create_reversal = com_api_type_pkg.false then
            trc_log_pkg.debug(
                i_text       => 'create_duplicate_operation: ended, created NEW operation with id [#1] for original_id [#2].'
              , i_env_param1 => l_new_oper_id
              , i_env_param2 => i_oper_id
            );
        else
            trc_log_pkg.debug(
                i_text       => 'create_duplicate_operation: ended, created REVERSAL operation with id [#1] for original_id [#2].'
              , i_env_param1 => l_new_oper_id
              , i_env_param2 => i_oper_id
            );
        end if;
        -- duplicate network data
            create_duplicate_vis_fin(
                i_oper_id         => i_oper_id
              , i_new_oper_id     => l_new_oper_id
              , i_create_reversal => i_create_reversal
            );

        --
        return l_new_oper_id;
    end create_duplicate_operation;

    procedure put_reject_code(
        i_reject_data_id  in com_api_type_pkg.t_long_id
        , i_reject_code   in com_api_type_pkg.t_text
        , i_description   in com_api_type_pkg.t_text
        , i_field         in com_api_type_pkg.t_text
    ) is
    begin
        insert into vis_reject_code (
            id
            , reject_data_id
            , reject_code
            , description
            , field
        )
        values (
            vis_reject_code_seq.nextval
            , i_reject_data_id
            , i_reject_code
            , i_description
            , i_field
        );
    end put_reject_code;

begin
  null;
end vis_api_reject_pkg;
/
