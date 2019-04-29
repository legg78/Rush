create or replace package body din_prc_import_pkg as
/*********************************************************
*  Diners Club importing of financial messages (incoming clearing) <br />
*  Created by Alalykin A.(alalykin@bpcbt.com) at 25.05.2016 <br />
*  Module: DIN_PRC_IMPORT_PKG <br />
*  @headcom
**********************************************************/

BULK_LIMIT                     constant com_api_type_pkg.t_count := 100;

ADD_ATM_DATETIME_LENGTH        com_api_type_pkg.t_count := 0; -- computed constant

g_fields_by_funcd_tab          din_api_type_pkg.t_fields_by_funcd_tab;
g_message_category_tab         din_api_type_pkg.t_message_category_tab;

procedure make_estimation
is
    l_files_count              com_api_type_pkg.t_count := 0;
    l_records_count            com_api_type_pkg.t_count := 0;
begin
    select count(*)
         , count(distinct session_file_id)
      into l_records_count
         , l_files_count
      from prc_session_file s
      join prc_file_raw_data d     on d.session_file_id = s.id
      join prc_file_attribute a    on a.id              = s.file_attr_id
      join prc_file f              on f.id              = a.file_id
     where s.session_id   = prc_api_session_pkg.get_session_id()
       and f.file_purpose = prc_api_const_pkg.FILE_PURPOSE_IN;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count => l_records_count
    );

    trc_log_pkg.debug(
        i_text       => 'Total files to process [#1], total records [#2]'
      , i_env_param1 => l_files_count
      , i_env_param2 => l_records_count
    );
end make_estimation;

/*
 * Function returns an array of parsed fields that are indexed from zero.
 */
function parse_line(
    i_line                     in            com_api_type_pkg.t_full_desc
) return com_api_type_pkg.t_name_tab
is
    l_fields                   com_api_type_pkg.t_name_tab;
    l_from                     com_api_type_pkg.t_count := 0;
    l_to                       com_api_type_pkg.t_count := 0;
begin
    trc_log_pkg.debug(
        i_text => lower($$PLSQL_UNIT) || '.parse_line << i_line [' || i_line || '], length(i_line) [' || length(i_line) || ']'
    );
    while l_to <= nvl(length(i_line), 0) loop
        l_to := instr(i_line, din_api_const_pkg.DELIMITER, l_from + 1);
        if l_to = 0 or l_to = l_from then
            l_to := length(i_line) + 1;
        end if;
        --trc_log_pkg.debug('l_from [' || l_from || '], l_to [' || l_to || ']');
        l_fields(l_fields.count()) := substr(i_line, l_from + 1, l_to - l_from - 1);
        l_from := l_to;
    end loop;

    if l_fields(0) != din_api_const_pkg.TRANSACTION_CODE_INCOMING then
        com_api_error_pkg.raise_error(
            i_error      => 'DIN_INCORRECT_TRANSACTION_CODE'
          , i_env_param1 => l_fields(0)
          , i_env_param2 => din_api_const_pkg.TRANSACTION_CODE_INCOMING
          , i_env_param3 => i_line
        );
    end if;

    trc_log_pkg.debug(
        i_text => lower($$PLSQL_UNIT) || '.parse_line >> l_fields.count() = ' || l_fields.count()
    );

    return l_fields;
end parse_line;

/*
 * Function returns count of non-empty elements of a passed array.
 */
function non_empty_count(
    i_fields                   in            com_api_type_pkg.t_name_tab
  , i_from                     in            com_api_type_pkg.t_count
) return com_api_type_pkg.t_count
is
    l_count                    com_api_type_pkg.t_count := 0;
begin
    if i_fields.count() >= 0 and i_fields.last() >= i_from then
        for i in i_from .. i_fields.last() loop
            if i_fields.exists(i) then
                l_count := l_count + case when trim(i_fields(i)) is not null then 1 else 0 end;
            end if;
        end loop;
    end if;

    trc_log_pkg.debug(
        i_text       => lower($$PLSQL_UNIT) || '.non_empty_count >> i_fields.count() = #1, l_count = #2'
      , i_env_param1 => i_fields.count()
      , i_env_param2 => l_count
    );

    return l_count;
end non_empty_count;

function get_multiplier(
    i_curr_code                in            com_api_type_pkg.t_curr_code
) return com_api_type_pkg.t_money
result_cache relies_on (com_currency)
is
begin
    return
        case
            when i_curr_code is null
            then 1
            else power(10, com_api_currency_pkg.get_currency_exponent(i_curr_code => i_curr_code))
        end;
end get_multiplier;

function get_message_category(
    i_function_code            in            din_api_type_pkg.t_function_code
) return com_api_type_pkg.t_dict_value
result_cache relies_on (din_message_type)
is
begin
    return
        case
            when g_message_category_tab.exists(i_function_code)
            then g_message_category_tab(i_function_code)
            else null
        end;
end get_message_category;

/*
 * Procedure checks incoming fields for compliance to a function code;
 * if there is a field that is mandatory but isn't present in <i_fields> then the exception is raised,
 * also empty values are added for all optional fields that are missed in <i_fields>.
 */
procedure check_fields(
    io_fields                  in out nocopy com_api_type_pkg.t_name_tab
  , i_function_code            in            din_api_type_pkg.t_function_code
) is
begin
    -- Every message contains the same first 5 fields that are mandatory.
    -- Moreover, first 7 fields are the same and mandatory for detail messages (XD)
    -- and all addendums (specific detail messages).
    for i in 0 .. case
                      when get_message_category(i_function_code) in (
                               din_api_const_pkg.MSG_CATEGORY_DETAIL_MESSAGE
                             , din_api_const_pkg.MSG_CATEGORY_ADDENDUM
                           )
                      then 6
                      else 4
                  end
    loop
        if trim(io_fields(i)) is null then
            -- Name of the missed field is taken from the list of fields of XD message
            -- because the reference doesn't contain these fields for addendums
            com_api_error_pkg.raise_error(
                i_error      => 'DIN_MANDATORY_FIELD_IS_MISSED'
              , i_env_param1 => get_message_category(i_function_code)
              , i_env_param2 => i_function_code
              , i_env_param3 => i
              , i_env_param4 => g_fields_by_funcd_tab(din_api_const_pkg.FUNCTION_CODE_DETAIL_MESSAGE)(i).field_name
              , i_env_param5 => g_fields_by_funcd_tab(din_api_const_pkg.FUNCTION_CODE_DETAIL_MESSAGE)(i).description
            );
        end if;
    end loop;

    -- All other fields are checked in according to the reference
    if g_fields_by_funcd_tab.exists(i_function_code) then
        -- Firstly, check count of fields
        if io_fields.last() > g_fields_by_funcd_tab(i_function_code).last() then
            com_api_error_pkg.raise_error(
                i_error      => 'DIN_INCORRECT_COUNT_OF_FIELDS'
              , i_env_param1 => get_message_category(i_function_code)
              , i_env_param2 => i_function_code
              , i_env_param3 => io_fields.last()
              , i_env_param4 => g_fields_by_funcd_tab(i_function_code).last()
            );
        end if;

        for i in g_fields_by_funcd_tab(i_function_code).first()
              .. g_fields_by_funcd_tab(i_function_code).last()
        loop
            -- Empty fields mustn't be present in the array of fields
            if not io_fields.exists(i) then
                io_fields(i) := null;
            end if;

            if  trim(io_fields(i)) is null
                and
                g_fields_by_funcd_tab(i_function_code)(i).is_mandatory = com_api_type_pkg.TRUE
            then
                com_api_error_pkg.raise_error(
                    i_error      => 'DIN_MANDATORY_FIELD_IS_MISSED'
                  , i_env_param1 => get_message_category(i_function_code)
                  , i_env_param2 => i_function_code
                  , i_env_param3 => i
                  , i_env_param4 => g_fields_by_funcd_tab(i_function_code)(i).field_name
                  , i_env_param5 => g_fields_by_funcd_tab(i_function_code)(i).description
                );
            end if;
        end loop;
    end if;
end check_fields;

procedure process_recap_header(
    i_fields                   in            com_api_type_pkg.t_name_tab
  , i_file_id                  in            com_api_type_pkg.t_long_id
  , i_record_number            in            com_api_type_pkg.t_short_id
  , o_recap_rec                   out        din_api_type_pkg.t_recap_rec
) is
begin
    o_recap_rec.file_id               := i_file_id;
    o_recap_rec.record_number         := i_record_number;

    o_recap_rec.id                    := din_recap_seq.nextval;
    o_recap_rec.sending_institution   := i_fields(2);
    o_recap_rec.recap_number          := i_fields(3);
    o_recap_rec.receiving_institution := i_fields(4);
    o_recap_rec.currency              := com_api_currency_pkg.get_currency_code(
                                             i_curr_name => i_fields(5)
                                         );
    o_recap_rec.recap_date            := to_date(i_fields(6), din_api_const_pkg.REVERSE_DATE_FORMAT);
end process_recap_header;

procedure process_recap_trailer(
    i_fields                   in            com_api_type_pkg.t_name_tab
  , io_recap_rec               in out nocopy din_api_type_pkg.t_recap_rec
) is
begin
--    io_recap_rec.alt_rate_type                com_api_type_pkg.t_dict_value
    io_recap_rec.program_transaction_amount := i_fields(9);
    io_recap_rec.credit_count     := i_fields(5);
    io_recap_rec.credit_amount    := i_fields(6)  * get_multiplier(i_curr_code => io_recap_rec.currency);
    io_recap_rec.debit_count      := i_fields(7);
    io_recap_rec.debit_amount     := i_fields(8)  * get_multiplier(i_curr_code => io_recap_rec.currency);
    io_recap_rec.net_amount       := i_fields(10) * get_multiplier(i_curr_code => io_recap_rec.currency);
    io_recap_rec.alt_currency     := com_api_currency_pkg.get_currency_code(i_curr_name => i_fields(11));
    io_recap_rec.alt_gross_amount := i_fields(12) * get_multiplier(i_curr_code => io_recap_rec.alt_currency);
    io_recap_rec.alt_net_amount   := i_fields(13) * get_multiplier(i_curr_code => io_recap_rec.alt_currency);
    io_recap_rec.new_recap_number := i_fields(14);
    io_recap_rec.proc_date        := to_date(substr(i_fields(15), 1, 6), din_api_const_pkg.REVERSE_DATE_FORMAT);
    io_recap_rec.sttl_date        := to_date(substr(i_fields(15), 7),    din_api_const_pkg.REVERSE_DATE_FORMAT);

    din_api_fin_message_pkg.save_recap(
        i_recap_rec => io_recap_rec
    );
end process_recap_trailer;

procedure process_batch_header(
    i_fields                   in            com_api_type_pkg.t_name_tab
  , i_record_number            in            com_api_type_pkg.t_short_id
  , i_recap_rec                in            din_api_type_pkg.t_recap_rec
  , o_batch_rec                   out        din_api_type_pkg.t_batch_rec
) is
begin
    o_batch_rec.id                    := din_batch_seq.nextval;
    o_batch_rec.recap_id              := i_recap_rec.id;
    o_batch_rec.record_number         := i_record_number;

    /*TODO*/ --i_recap_rec.recap_number vs. i_fields(3) == CHECK
    /*TODO*/ --i_recap_rec.recap_date vs. i_fields(6) == CHECK
    o_batch_rec.sending_institution   := i_fields(2);
    o_batch_rec.receiving_institution := i_fields(4);
    o_batch_rec.batch_number          := i_fields(5);
end process_batch_header;

procedure process_batch_trailer(
    i_fields                   in            com_api_type_pkg.t_name_tab
  , i_recap_rec                in            din_api_type_pkg.t_recap_rec
  , io_batch_rec               in out nocopy din_api_type_pkg.t_batch_rec
) is
begin
    io_batch_rec.credit_count  := i_fields(6);
    io_batch_rec.credit_amount := i_fields(7) * get_multiplier(i_curr_code => i_recap_rec.currency);
    io_batch_rec.debit_count   := i_fields(8);
    io_batch_rec.debit_amount  := i_fields(9) * get_multiplier(i_curr_code => i_recap_rec.currency);

    din_api_fin_message_pkg.save_batch(
        i_batch_rec => io_batch_rec
    );
end process_batch_trailer;

procedure process_fin_message(
    i_fields                   in            com_api_type_pkg.t_name_tab
  , i_create_operation         in            com_api_type_pkg.t_boolean
  , i_host_id                  in            com_api_type_pkg.t_tiny_id
  , i_standard_id              in            com_api_type_pkg.t_tiny_id
  , i_file_rec                 in            din_api_type_pkg.t_file_rec
  , i_record_number            in            com_api_type_pkg.t_short_id
  , i_recap_rec                in            din_api_type_pkg.t_recap_rec
  , io_batch_rec               in out nocopy din_api_type_pkg.t_batch_rec
  , o_fin_rec                     out        din_api_type_pkg.t_fin_message_rec
  , o_operation                   out        opr_api_type_pkg.t_oper_rec
  , o_iss_part                    out        opr_api_type_pkg.t_oper_part_rec
  , o_acq_part                    out        opr_api_type_pkg.t_oper_part_rec
) is
    LOG_PREFIX        constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_fin_message()';
    l_card_rec                 iss_api_type_pkg.t_card_rec;
    l_bin_currency             com_api_type_pkg.t_curr_code;
    l_sttl_currency            com_api_type_pkg.t_curr_code;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' << function_code [#1]'
      , i_env_param1 => i_fields(1)
    );

    o_fin_rec.is_incoming                 := com_api_type_pkg.TRUE;
    /*TODO: accomulate credit/debit count/amount into io_batch_rec and then check these values on batch trailer processing*/
    o_fin_rec.id                          := opr_api_create_pkg.get_id();
    o_fin_rec.status                      := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;
    o_fin_rec.file_id                     := i_file_rec.id;
    o_fin_rec.record_number               := i_record_number;
    o_fin_rec.batch_id                    := io_batch_rec.id;
    o_fin_rec.sequential_number           := i_fields(6);
    o_fin_rec.network_id                  := i_file_rec.network_id;
    o_fin_rec.inst_id                     := i_recap_rec.inst_id;
    o_fin_rec.sending_institution         := i_fields(2);
    o_fin_rec.receiving_institution       := i_fields(4);
    o_fin_rec.dispute_id                  := null;
    o_fin_rec.originator_refnum           := i_fields(17);
    o_fin_rec.network_refnum              := i_fields(43);
    o_fin_rec.card_id                     := iss_api_card_pkg.get_card(
                                                 i_card_number => i_fields(7)
                                               , i_mask_error  => com_api_const_pkg.FALSE
                                             ).id;
    o_fin_rec.card_number                 := i_fields(7);
    o_fin_rec.type_of_charge              := i_fields(16);
    o_fin_rec.charge_type                 := i_fields(11);
    o_fin_rec.date_type                   := i_fields(10);
    o_fin_rec.charge_date                 := to_date(i_fields(9), din_api_const_pkg.DATE_FORMAT);
    o_fin_rec.sttl_date                   := null; -- It is filled by an ATM addendum
    o_fin_rec.host_date                   := null; -- It is filled by an ATM addendum
    o_fin_rec.auth_code                   := i_fields(18);
    o_fin_rec.action_code                 := i_fields(15);
    o_fin_rec.oper_currency               := i_recap_rec.currency;
    o_fin_rec.oper_amount                 := i_fields(8)  * get_multiplier(
                                                                i_curr_code => o_fin_rec.oper_currency
                                                            );
    o_fin_rec.sttl_currency               := com_api_currency_pkg.get_currency_code(
                                                 i_curr_name => i_fields(20)
                                             );
    o_fin_rec.sttl_amount                 := i_fields(21) * get_multiplier(
                                                                i_curr_code => o_fin_rec.sttl_currency
                                                            );
    o_fin_rec.mcc                         := i_fields(28);
    o_fin_rec.merchant_number             := i_fields(19);
    o_fin_rec.merchant_name               := i_fields(12);
    o_fin_rec.merchant_city               := i_fields(13);
    o_fin_rec.merchant_country            := i_fields(14);
    o_fin_rec.merchant_state              := i_fields(24);
    o_fin_rec.merchant_street             := i_fields(23);
    o_fin_rec.merchant_postcode           := i_fields(25);
    o_fin_rec.merchant_phone              := i_fields(26);
    o_fin_rec.merchant_international_code := i_fields(22);
    o_fin_rec.terminal_number             := null; -- It is filled by an ATM addendum
    o_fin_rec.program_transaction_amount  := null; -- This value is taken from a recap
    o_fin_rec.alt_currency                := null; -- This value is taken from a recap
    o_fin_rec.alt_rate_type               := null;
    o_fin_rec.tax_amount1                 := i_fields(29);
    o_fin_rec.tax_amount2                 := i_fields(30);
    o_fin_rec.original_document_number    := i_fields(31);
    o_fin_rec.crdh_presence               := i_fields(38);
    o_fin_rec.card_presence               := i_fields(39);
    o_fin_rec.card_data_input_mode        := i_fields(40);
    o_fin_rec.card_data_input_capability  := i_fields(44);

    if  cmn_api_standard_pkg.get_current_version(
            i_standard_id  => i_standard_id
          , i_entity_type  => net_api_const_pkg.ENTITY_TYPE_HOST
          , i_object_id    => i_host_id
          , i_eff_date     => com_api_sttl_day_pkg.get_sysdate()
        ) >= din_api_const_pkg.DIN_CLEARING_STANDARD_17_1
    then
        o_fin_rec.card_type                   := i_fields(48);
        o_fin_rec.payment_token               := i_fields(49);
        o_fin_rec.token_requestor_id          := i_fields(50);
        o_fin_rec.token_assurance_level       := i_fields(51);
    end if;

    o_fin_rec.is_invalid                  := com_api_type_pkg.FALSE;

    -- Mapping Diners Club financial message parameters to SV2 operation parameters
    din_api_fin_message_pkg.get_operation_parameters(
        i_type_of_charge  => o_fin_rec.type_of_charge
      , i_mcc             => o_fin_rec.mcc
      , o_is_reversal     => o_fin_rec.is_reversal
      , o_oper_type       => o_operation.oper_type
      , o_terminal_type   => o_operation.terminal_type
    );

    if i_create_operation = com_api_type_pkg.TRUE then
        -- For the case of reversal we search for an original operation
        if o_fin_rec.is_reversal = com_api_type_pkg.TRUE then
            o_operation.original_id := din_api_fin_message_pkg.get_original_fin_message(
                                           i_fin_rec    => o_fin_rec
                                         , i_mask_error => com_api_type_pkg.FALSE
                                       ).id;
        end if;

        o_operation.msg_type :=
            net_api_map_pkg.get_msg_type(
                i_network_msg_type => din_api_const_pkg.FUNCTION_CODE_DETAIL_MESSAGE
              , i_standard_id      => i_standard_id
              , i_mask_error       => com_api_type_pkg.FALSE
            );

        o_operation.acq_inst_bin := null; /*TODO*/

        iss_api_bin_pkg.get_bin_info(
            i_card_number      => o_fin_rec.card_number
          , o_iss_inst_id      => o_iss_part.inst_id
          , o_iss_network_id   => o_iss_part.network_id
          , o_card_inst_id     => o_iss_part.card_inst_id
          , o_card_network_id  => o_iss_part.card_network_id
          , o_card_type        => o_iss_part.card_type_id
          , o_card_country     => o_iss_part.card_country
          , o_bin_currency     => l_bin_currency  -- not used
          , o_sttl_currency    => l_sttl_currency -- not used
        );

        begin
            o_acq_part.inst_id :=
                cmn_api_standard_pkg.find_value_owner(
                    i_standard_id => i_standard_id
                  , i_entity_type => net_api_const_pkg.ENTITY_TYPE_HOST
                  , i_object_id   => i_host_id
                  , i_param_name  => din_api_const_pkg.PARAM_NAME_ACQ_AGENT_CODE
                  , i_value_char  => o_fin_rec.sending_institution
                  , i_mask_error  => com_api_const_pkg.TRUE
                );
            o_acq_part.network_id :=
                ost_api_institution_pkg.get_inst_network(
                    i_inst_id     => o_acq_part.inst_id
                );
        exception
            when com_api_error_pkg.e_application_error then
                if com_api_error_pkg.get_last_error = 'NOT_FOUND_VALUE_OWNER' then
                    o_acq_part.inst_id := null;
                else
                    raise;
                end if;
        end;

        if o_acq_part.inst_id is null then
            o_acq_part.network_id := o_fin_rec.network_id;
            o_acq_part.inst_id    := net_api_network_pkg.get_inst_id(
                                         i_network_id => o_acq_part.network_id
                                     );
        end if;

        net_api_sttl_pkg.get_sttl_type(
            i_iss_inst_id      => o_iss_part.inst_id
          , i_acq_inst_id      => o_acq_part.inst_id
          , i_card_inst_id     => o_iss_part.card_inst_id
          , i_iss_network_id   => o_iss_part.network_id
          , i_acq_network_id   => o_acq_part.network_id
          , i_card_network_id  => o_iss_part.card_network_id
          , i_acq_inst_bin     => o_operation.acq_inst_bin
          , o_sttl_type        => o_operation.sttl_type
          , o_match_status     => o_operation.match_status
          , i_oper_type        => o_operation.oper_type
        );

        o_iss_part.card_id                := o_fin_rec.card_id;
        o_iss_part.client_id_type         := opr_api_const_pkg.CLIENT_ID_TYPE_CARD_ID;
        o_iss_part.client_id_value        := o_fin_rec.card_id;
        o_iss_part.card_number            := o_fin_rec.card_number;
        o_iss_part.card_mask              := iss_api_card_pkg.get_card_mask(
                                                 i_card_number => o_iss_part.card_number
                                             );
        o_iss_part.card_hash              := com_api_hash_pkg.get_card_hash(
                                                 i_card_number => o_iss_part.card_number
                                             );
        l_card_rec                        := iss_api_card_pkg.get_card(
                                                 i_card_number => o_fin_rec.card_number
                                               , i_mask_error  => com_api_type_pkg.TRUE
                                             );
        o_iss_part.card_type_id           := nvl(o_iss_part.card_type_id, l_card_rec.card_type_id);
        o_iss_part.card_country           := nvl(o_iss_part.card_country, l_card_rec.country);
        o_iss_part.customer_id            := l_card_rec.customer_id;
        o_iss_part.split_hash             :=
            case
                when o_iss_part.customer_id is not null then
                    com_api_hash_pkg.get_split_hash(
                        i_entity_type => com_api_const_pkg.ENTITY_TYPE_CUSTOMER
                      , i_object_id   => o_iss_part.customer_id
                    )
                when o_iss_part.card_number is not null then
                    com_api_hash_pkg.get_split_hash(
                        i_value       => o_iss_part.card_number
                    )
            end;
        o_iss_part.auth_code              := o_fin_rec.auth_code;

        o_operation.id                    := o_fin_rec.id;
        o_operation.is_reversal           := o_fin_rec.is_reversal;
        o_operation.session_id            := prc_api_session_pkg.get_session_id();
        o_operation.oper_reason           := null;
        o_operation.status                := opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY;
        o_operation.status_reason         := null;
        o_operation.merchant_number       := o_fin_rec.merchant_number;
        o_operation.merchant_name         := o_fin_rec.merchant_name;
        o_operation.merchant_street       := o_fin_rec.merchant_street;
        o_operation.merchant_city         := o_fin_rec.merchant_city;
        o_operation.merchant_region       := null;
        o_operation.merchant_country      := o_fin_rec.merchant_country;
        o_operation.merchant_postcode     := o_fin_rec.merchant_postcode;
        o_operation.mcc                   := o_fin_rec.mcc;
        o_operation.originator_refnum     := o_fin_rec.originator_refnum;
        o_operation.network_refnum        := o_fin_rec.network_refnum;
        o_operation.oper_count            := null;
        o_operation.oper_amount           := o_fin_rec.oper_amount;
        o_operation.oper_currency         := o_fin_rec.oper_currency;
        o_operation.oper_date             := o_fin_rec.charge_date;
        o_operation.sttl_amount           := o_fin_rec.sttl_amount;
        o_operation.sttl_currency         := o_fin_rec.sttl_currency;
        o_operation.dispute_id            := null;
        o_operation.incom_sess_file_id    := o_fin_rec.file_id;  -- equal to prc_session_file.id
    end if;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' >> o_fin_rec.id [#1]'
      , i_env_param1 => o_fin_rec.id
    );
exception
    when others then
        if  com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE
            or
            com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE
        then
            o_fin_rec.is_invalid := com_api_type_pkg.TRUE;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end process_fin_message;

procedure process_addendum(
    i_fields                   in            com_api_type_pkg.t_name_tab
  , i_create_operation         in            com_api_type_pkg.t_boolean
  , i_file_id                  in            com_api_type_pkg.t_long_id
  , i_record_number            in            com_api_type_pkg.t_short_id
  , i_fin_id                   in            com_api_type_pkg.t_long_id
  , io_addendum_tab            in out nocopy din_api_type_pkg.t_addendum_tab
  , io_addendum_value_tab      in out nocopy din_api_type_pkg.t_addendum_value_tab
  , io_operation               in out nocopy opr_api_type_pkg.t_oper_rec
) is
    LOG_PREFIX        constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_addendum()';
    DATETIME_FORMAT   constant com_api_type_pkg.t_oracle_name :=
        din_api_const_pkg.DATE_FORMAT || din_api_const_pkg.TIME_FORMAT;
    l_index                    com_api_type_pkg.t_count := 0;
    l_sttl_date                com_api_type_pkg.t_oracle_name;
    l_host_date                com_api_type_pkg.t_oracle_name;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' << i_fields.count() = #1'
      , i_env_param1 => i_fields.count()
    );

    if not g_fields_by_funcd_tab.exists(i_fields(1)) then
        com_api_error_pkg.raise_error(
            i_error      => 'DIN_UNKNOWN_FUNCTION_CODE'
          , i_env_param1 => i_fields(1)
        );

    elsif g_fields_by_funcd_tab(i_fields(1)).first() > i_fields.last() then
        -- Addendum doesn''t contain any valuable fields, so there is nothing to save
        trc_log_pkg.debug(
            i_text       => 'EXIT: g_fields_by_funcd_tab(''#1'').first() [#2] > i_fields.last() [#3]'
          , i_env_param1 => i_fields(1)
          , i_env_param2 => g_fields_by_funcd_tab(i_fields(1)).first()
          , i_env_param3 => i_fields.last()
        );

    else
        l_index :=
            din_api_fin_message_pkg.add_addendum(
                io_addendum_tab       => io_addendum_tab
              , i_fin_id              => i_fin_id
              , i_function_code       => i_fields(1)
            );
        trc_log_pkg.debug('addendum with FUNCD [' || i_fields(1) || '] added, l_index [' || l_index || ']');

        io_addendum_tab(l_index).file_id       := i_file_id;
        io_addendum_tab(l_index).record_number := i_record_number;

        l_index :=
            din_api_fin_message_pkg.init_addendum_values(
                io_addendum_value_tab => io_addendum_value_tab
              , i_addendum_id         => io_addendum_tab(l_index).id
              , i_count               => non_empty_count(
                                             i_fields => i_fields
                                           , i_from   => g_fields_by_funcd_tab(i_fields(1)).first()
                                         )
            );
        trc_log_pkg.debug('addendum values starting index [' || l_index || ']');

        for i in g_fields_by_funcd_tab(i_fields(1)).first() .. i_fields.last() loop
            if  i_fields.exists(i)
                and
                trim(i_fields(i)) is not null
            then
                io_addendum_value_tab(l_index).field_name  := g_fields_by_funcd_tab(i_fields(1))(i).field_name;
                io_addendum_value_tab(l_index).field_value := i_fields(i);

                --trc_log_pkg.debug('i_fields(' || i || ') [' || i_fields(i) || ']');

                if i_fields(1) = din_api_const_pkg.FUNCTION_CODE_ADD_ATM then
                    case io_addendum_value_tab(l_index).field_name
                        when din_api_const_pkg.FIELD_ATM_ID_NUMBER then
                            begin
                                io_operation.terminal_number := to_number(i_fields(i));
                            exception
                                when com_api_error_pkg.e_value_error then
                                    com_api_error_pkg.raise_error(
                                        i_error      => 'DIN_INVALID_ATMID'
                                      , i_env_param1 => i_fields(i)
                                    );
                            end;

                        when din_api_const_pkg.FIELD_ACQUIRER_DATE then
                            l_sttl_date := i_fields(i) || l_sttl_date;

                        when din_api_const_pkg.FIELD_ACQUIRER_TIME then
                            l_sttl_date := l_sttl_date || i_fields(i);

                        when din_api_const_pkg.FIELD_LOCAL_TERMINAL_DATE then
                            l_host_date := i_fields(i) || l_host_date;

                        when din_api_const_pkg.FIELD_LOCAL_TERMINAL_TIME then
                            l_host_date := l_host_date || i_fields(i);

                        else
                            null;
                    end case;
                end if;

                trc_log_pkg.debug(
                    i_text       => 'l_sttl_date [#1], l_host_date [#2]'
                  , i_env_param1 => l_sttl_date
                  , i_env_param2 => l_host_date
                );

                l_index := l_index + 1;
            end if;
        end loop;

        if length(l_sttl_date) = ADD_ATM_DATETIME_LENGTH then
            io_operation.sttl_date := to_date(l_sttl_date, DATETIME_FORMAT);
            --trc_log_pkg.debug(
            --    i_text       => 'io_operation.sttl_date [#1]'
            --  , i_env_param1 => to_char(io_operation.sttl_date, DATETIME_FORMAT)
            --);
        end if;

        if length(l_host_date) = ADD_ATM_DATETIME_LENGTH then
            io_operation.host_date := to_date(l_host_date, DATETIME_FORMAT);
            --trc_log_pkg.debug(
            --    i_text       => 'io_operation.host_date [#1]'
            --  , i_env_param1 => to_char(io_operation.host_date, DATETIME_FORMAT)
            --);
        end if;

        trc_log_pkg.debug('addendum values ending index [' || (l_index - 1) || ']');
    end if;

    trc_log_pkg.debug(LOG_PREFIX || ' >>');
end process_addendum;

procedure process(
    i_network_id               in            com_api_type_pkg.t_network_id    default null
  , i_create_operation         in            com_api_type_pkg.t_boolean
) is
    LOG_PREFIX        constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process()';
    l_standard_id              com_api_type_pkg.t_tiny_id;
    l_host_id                  com_api_type_pkg.t_tiny_id;
    l_create_operation         com_api_type_pkg.t_boolean;
    l_fields                   com_api_type_pkg.t_name_tab;
    l_file_rec                 din_api_type_pkg.t_file_rec;
    l_recap_rec                din_api_type_pkg.t_recap_rec;
    l_batch_rec                din_api_type_pkg.t_batch_rec;
    l_fin_tab                  din_api_type_pkg.t_fin_message_tab;
    l_addendum_tab             din_api_type_pkg.t_addendum_tab;
    l_addendum_value_tab       din_api_type_pkg.t_addendum_value_tab;
    l_operation                opr_api_type_pkg.t_oper_rec;
    l_iss_part                 opr_api_type_pkg.t_oper_part_rec;
    l_acq_part                 opr_api_type_pkg.t_oper_part_rec;
    l_prev_function_code       din_api_type_pkg.t_function_code;
    l_processed_count          com_api_type_pkg.t_count := 0;
    l_excepted_count           com_api_type_pkg.t_count := 0;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' << i_network_id [#1], i_create_operation [#2]'
      , i_env_param1 => i_network_id
      , i_env_param2 => i_create_operation
    );

    prc_api_stat_pkg.log_start();

    make_estimation();

    l_create_operation     := nvl(i_create_operation, com_api_type_pkg.TRUE);

    l_file_rec.is_incoming := com_api_type_pkg.TRUE;
    l_file_rec.network_id  := nvl(i_network_id, din_api_const_pkg.DIN_NETWORK_ID);
    l_file_rec.inst_id     := null; -- A file may contain recaps for different institutions (agent codes)
    l_file_rec.file_date   := com_api_sttl_day_pkg.get_sysdate();
    l_file_rec.is_rejected := null; -- reserved

    -- Get network communication standard
    l_host_id     := net_api_network_pkg.get_default_host(i_network_id => l_file_rec.network_id);
    l_standard_id := net_api_network_pkg.get_offline_standard(i_host_id => l_host_id);

    trc_log_pkg.debug(
        i_text       => 'l_host_id [#1], l_standard_id [#2]'
      , i_env_param1 => l_host_id
      , i_env_param2 => l_standard_id
    );

    -- All fields that were added by Mandatory changes should NOT be mandatory for older standard versions
    if cmn_api_standard_pkg.get_current_version(
           i_standard_id  => l_standard_id
         , i_entity_type  => net_api_const_pkg.ENTITY_TYPE_HOST
         , i_object_id    => l_host_id
         , i_eff_date     => com_api_sttl_day_pkg.get_sysdate()
       ) < din_api_const_pkg.DIN_CLEARING_STANDARD_17_1
    then
        g_fields_by_funcd_tab(din_api_const_pkg.FUNCTION_CODE_DETAIL_MESSAGE)(48).is_mandatory := com_api_const_pkg.FALSE;
    end if;

    for f in (
        select id as session_file_id
          from prc_session_file
         where session_id = prc_api_session_pkg.get_session_id()
      order by id
    ) loop
        trc_log_pkg.debug(
            i_text       => 'Processing session_file_id [#1]'
          , i_env_param1 => f.session_file_id
        );

        l_excepted_count := 0;

        l_file_rec.id          := f.session_file_id;
        l_file_rec.recap_total := 0;

        savepoint sp_current_file;

        for r in (
            select record_number
                 , raw_data
                 , lead(raw_data) over (order by record_number)    as next_raw_data
                 , count(*) over()                                 as cnt
                 , row_number() over (order by record_number)      as rn 
                 , row_number() over (order by record_number desc) as rn_desc
              from prc_file_raw_data t
             where t.session_file_id = f.session_file_id
          order by record_number
        ) loop
            l_fields := parse_line(i_line => r.raw_data);

            check_fields(
                io_fields       => l_fields
              , i_function_code => l_fields(1)
            );

            if      l_create_operation = com_api_type_pkg.TRUE
                and l_operation.id is not null
                and (r.rn = r.cnt -- last record of the file
                     or
                     l_fields(1) in (din_api_const_pkg.FUNCTION_CODE_BATCH_TRAILER
                                   , din_api_const_pkg.FUNCTION_CODE_DETAIL_MESSAGE))
            then
                opr_api_create_pkg.create_operation(
                    i_oper     => l_operation
                  , i_iss_part => l_iss_part
                  , i_acq_part => l_acq_part
                );
                l_operation.id := null;
            end if;

            case
            when l_fields(1) = din_api_const_pkg.FUNCTION_CODE_RECAP_HEADER then
                process_recap_header(
                    i_fields              => l_fields
                  , i_file_id             => f.session_file_id
                  , i_record_number       => r.record_number
                  , o_recap_rec           => l_recap_rec
                );
                -- Define and check internal SmartVista instituion
                l_recap_rec.inst_id := din_api_fin_message_pkg.get_inst_id(
                                           i_agent_code  => l_recap_rec.receiving_institution
                                         , i_network_id  => l_file_rec.network_id
                                         , i_standard_id => l_standard_id
                                       );

            when l_fields(1) = din_api_const_pkg.FUNCTION_CODE_RECAP_TRAILER then
                process_recap_trailer(
                    i_fields              => l_fields
                  , io_recap_rec          => l_recap_rec
                );

            when l_fields(1) = din_api_const_pkg.FUNCTION_CODE_BATCH_HEADER then
                process_batch_header(
                    i_fields              => l_fields
                  , i_record_number       => r.record_number
                  , i_recap_rec           => l_recap_rec
                  , o_batch_rec           => l_batch_rec
                );

            when l_fields(1) = din_api_const_pkg.FUNCTION_CODE_BATCH_TRAILER then
                process_batch_trailer(
                    i_fields              => l_fields
                  , i_recap_rec           => l_recap_rec
                  , io_batch_rec          => l_batch_rec
                );

            when l_fields(1) = din_api_const_pkg.FUNCTION_CODE_DETAIL_MESSAGE then
                process_fin_message(
                    i_fields              => l_fields
                  , i_create_operation    => l_create_operation
                  , i_host_id             => l_host_id
                  , i_standard_id         => l_standard_id
                  , i_file_rec            => l_file_rec
                  , i_record_number       => r.record_number
                  , i_recap_rec           => l_recap_rec
                  , io_batch_rec          => l_batch_rec
                  , o_fin_rec             => l_fin_tab(l_fin_tab.count())
                  , o_operation           => l_operation
                  , o_iss_part            => l_iss_part
                  , o_acq_part            => l_acq_part
                );
                l_excepted_count := l_excepted_count + l_fin_tab(l_fin_tab.count()-1).is_invalid;

            when get_message_category(l_fields(1)) = din_api_const_pkg.MSG_CATEGORY_ADDENDUM then
                process_addendum(
                    i_fields              => l_fields
                  , i_create_operation    => l_create_operation
                  , i_file_id             => f.session_file_id
                  , i_record_number       => r.record_number
                  , i_fin_id              => l_fin_tab(l_fin_tab.count()-1).id
                  , io_addendum_tab       => l_addendum_tab
                  , io_addendum_value_tab => l_addendum_value_tab
                  , io_operation          => l_operation
                );

            else
                com_api_error_pkg.raise_error(
                    i_error      => 'DIN_UNKNOWN_FUNCTION_CODE'
                  , i_env_param1 => l_fields(1)
                );
            end case;

            if  l_fin_tab.count() >= BULK_LIMIT
                or
                r.rn = r.cnt -- last iteration
            then
                din_api_fin_message_pkg.save_messages(
                    io_fin_tab           => l_fin_tab
                );
                din_api_fin_message_pkg.save_addendums(
                    io_addendum_tab      => l_addendum_tab
                  , i_addendum_value_tab => l_addendum_value_tab
                );
                l_fin_tab.delete();
                l_addendum_tab.delete();
                l_addendum_value_tab.delete();
            end if;

            l_prev_function_code   := l_fields(1);
            l_file_rec.recap_total := l_file_rec.recap_total + 1;
        end loop; -- for r, prc_file_raw_data

        din_api_fin_message_pkg.save_file(
            i_file_rec       => l_file_rec
        );

        l_processed_count := l_processed_count + l_file_rec.recap_total;

        prc_api_stat_pkg.log_current(
            i_current_count  => l_processed_count
          , i_excepted_count => l_excepted_count
        );
    end loop; -- for f, prc_session_file

    prc_api_stat_pkg.log_end(
        i_result_code     => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
      , i_processed_total => l_processed_count
    );

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' >> l_processed_count [#1]'
      , i_env_param1 => l_processed_count
    );
exception
    when others then
        prc_api_stat_pkg.log_end(
            i_result_code => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if  com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE
            or
            com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE
        then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end process;

procedure load_fields(
    o_fields_by_funcd_tab         out        din_api_type_pkg.t_fields_by_funcd_tab
) is
    LOG_PREFIX        constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.load_fields()';
    l_field_tab                din_api_type_pkg.t_message_field_tab;
    l_function_code            din_api_type_pkg.t_function_code;
begin
    trc_log_pkg.debug(LOG_PREFIX || ' <<');

    din_api_fin_message_pkg.load_fields_reference(
        i_function_code      => null -- all function codes
      , o_message_field_tab  => l_field_tab
    );
    trc_log_pkg.debug('l_field_tab.count() = ' || l_field_tab.count());

    -- Re-save data to make possible indirect addressing
    for i in 1 .. l_field_tab.count() loop
        -- Array l_field_tab is ordered by function_code and field_number
        o_fields_by_funcd_tab(l_field_tab(i).function_code)(l_field_tab(i).field_number) := l_field_tab(i);

        if  l_function_code != l_field_tab(i).function_code
            or
            i = l_field_tab.last()
        then
            trc_log_pkg.debug(
                i_text       => 'o_fields_by_funcd_tab(''#1'').count() = #2'
              , i_env_param1 => l_function_code
              , i_env_param2 => o_fields_by_funcd_tab(l_function_code).count()
            );
        end if;

        l_function_code := l_field_tab(i).function_code;
    end loop;

    trc_log_pkg.debug(LOG_PREFIX || ' >>');
end load_fields;

begin
    trc_log_pkg.debug(lower($$PLSQL_UNIT) || '~initialization <<');

    -- Load the referene of message categories
    g_message_category_tab.delete();
    for r in (
        select * from din_message_type
    ) loop
        g_message_category_tab(r.function_code) := r.message_category;
    end loop;

    -- Load the reference of fields
    load_fields(
        o_fields_by_funcd_tab => g_fields_by_funcd_tab
    );

    ADD_ATM_DATETIME_LENGTH :=
        g_fields_by_funcd_tab(din_api_const_pkg.FUNCTION_CODE_ADD_ATM)(8).field_length
        +
        g_fields_by_funcd_tab(din_api_const_pkg.FUNCTION_CODE_ADD_ATM)(9).field_length;

    trc_log_pkg.debug(
        i_text       => lower($$PLSQL_UNIT) || '~initialization >> g_message_category_tab.count() = #1'
      , i_env_param1 => g_message_category_tab.count()
    );
end;
/
