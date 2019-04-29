create or replace package body din_api_fin_message_pkg as
/*********************************************************
*  API for Diners Club financial messages <br />
*  Created by Alalykin A.(a lalykin@bpcbt.com) at 30.04.2016 <br />
*  Last changed by $Author: alalykin $ <br />
*  $LastChangedDate:: 2016-04-30 18:08:00 +0300#$ <br />
*  Revision: $LastChangedRevision: 1 $ <br />
*  Module: DIN_API_FIN_MESSAGE_PKG <br />
*  @headcom
**********************************************************/

CRLF                    constant com_api_type_pkg.t_name := chr(13) || chr(10);

G_COLUMN_LIST           constant com_api_type_pkg.t_text :=
    ' f.id'
|| ', f.status'
|| ', f.file_id'
|| ', f.record_number'
|| ', f.batch_id'
|| ', f.sequential_number'
|| ', f.is_incoming'
|| ', f.is_rejected'
|| ', f.is_reversal'
|| ', f.is_invalid'
|| ', f.network_id'
|| ', f.inst_id'
|| ', f.sending_institution'
|| ', f.receiving_institution'
|| ', f.dispute_id'
|| ', f.originator_refnum'
|| ', f.network_refnum'
|| ', f.card_id'
|| ', iss_api_token_pkg.decode_card_number(i_card_number => c.card_number) as card_number'
|| ', f.type_of_charge'
|| ', f.charge_type'
|| ', f.date_type'
|| ', f.charge_date'
|| ', f.sttl_date'
|| ', f.host_date'
|| ', f.auth_code'
|| ', f.action_code'
|| ', f.oper_amount'
|| ', f.oper_currency'
|| ', f.sttl_amount'
|| ', f.sttl_currency'
|| ', f.mcc'
|| ', f.merchant_number'
|| ', f.merchant_name'
|| ', f.merchant_city'
|| ', f.merchant_country'
|| ', f.merchant_state'
|| ', f.merchant_street'
|| ', f.merchant_postal_code'
|| ', f.merchant_phone'
|| ', f.merchant_international_code'
|| ', f.terminal_number'
|| ', f.program_transaction_amount'
|| ', f.alt_currency'
|| ', f.alt_rate_type'
|| ', f.tax_amount1'
|| ', f.tax_amount2'
|| ', f.original_document_number'
|| ', f.crdh_presence'
|| ', f.card_presence'
|| ', f.card_data_input_mode'
|| ', f.card_data_input_capability'
|| ', f.card_type'
|| ', f.payment_token'
|| ', f.token_requestor_id'
|| ', f.token_assurance_level'
;

l_data_format                    com_api_type_pkg.t_oracle_name; -- for initialization section

g_addendum_chip_data             din_api_type_pkg.t_message_field_tab;
g_emv_tags_list                  emv_api_type_pkg.t_emv_tag_type_tab;

/*
 * Function returns TRUE if a transaction associated with incoming financial message
 * contains EMV data (i.e. is it an ICC transaction), overwise it returns null.
 */
function is_icc_transaction(
    io_fin_rec            in out nocopy din_api_type_pkg.t_fin_message_rec
) return com_api_type_pkg.t_boolean
is
    l_is_icc_transaction                com_api_type_pkg.t_boolean;
begin
    if io_fin_rec.card_data_input_capability in ('5', '9')
       and io_fin_rec.card_data_input_mode in ('5', 'S', '9')
    then
        l_is_icc_transaction := com_api_type_pkg.TRUE;
    end if;

    trc_log_pkg.debug(
        i_text        => 'card_data_input_capability [#1], card_data_input_mode [#2], l_is_icc_transaction [#3]'
      , i_env_param1  => io_fin_rec.card_data_input_capability
      , i_env_param2  => io_fin_rec.card_data_input_mode
      , i_env_param3  => l_is_icc_transaction
    );

    return l_is_icc_transaction;
end is_icc_transaction;

procedure save_file(
    i_file_rec            in            din_api_type_pkg.t_file_rec
) is
    LOG_PREFIX                 constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.save_file';
begin
    trc_log_pkg.debug(LOG_PREFIX || ' Start i_file_rec.id [' || i_file_rec.id || ']');

    insert into din_file(
        id
      , is_incoming
      , network_id
      , inst_id
      , recap_total
      , file_date
      , is_rejected
    ) values (
        i_file_rec.id
      , i_file_rec.is_incoming
      , i_file_rec.network_id
      , i_file_rec.inst_id
      , i_file_rec.recap_total
      , i_file_rec.file_date
      , i_file_rec.is_rejected
    );

    trc_log_pkg.debug(LOG_PREFIX || ' Finish');
end save_file;

procedure save_recap(
    i_recap_rec           in            din_api_type_pkg.t_recap_rec
) is
begin
    insert into din_recap(
        id
      , file_id
      , record_number
      , inst_id
      , sending_institution
      , recap_number
      , receiving_institution
      , currency
      , recap_date
      , credit_count
      , credit_amount
      , debit_count
      , debit_amount
      , program_transaction_amount
      , net_amount
      , alt_currency
      , alt_gross_amount
      , alt_net_amount
      , new_recap_number
      , proc_date
      , sttl_date
      , is_rejected
    ) values (
        i_recap_rec.id
      , i_recap_rec.file_id
      , i_recap_rec.record_number
      , i_recap_rec.inst_id
      , i_recap_rec.sending_institution
      , i_recap_rec.recap_number
      , i_recap_rec.receiving_institution
      , i_recap_rec.currency
      , i_recap_rec.recap_date
      , i_recap_rec.credit_count
      , i_recap_rec.credit_amount
      , i_recap_rec.debit_count
      , i_recap_rec.debit_amount
      , i_recap_rec.program_transaction_amount
      , i_recap_rec.net_amount
      , i_recap_rec.alt_currency
      , i_recap_rec.alt_gross_amount
      , i_recap_rec.alt_net_amount
      , i_recap_rec.new_recap_number
      , i_recap_rec.proc_date
      , i_recap_rec.sttl_date
      , i_recap_rec.is_rejected
    );
end save_recap;

procedure save_batch(
    i_batch_rec           in            din_api_type_pkg.t_batch_rec
) is
begin
    insert into din_batch(
        id
      , recap_id
      , record_number
      , batch_number
      , credit_count
      , credit_amount
      , debit_count
      , debit_amount
      , is_rejected
    ) values (
        i_batch_rec.id
      , i_batch_rec.recap_id
      , i_batch_rec.record_number
      , i_batch_rec.batch_number
      , i_batch_rec.credit_count
      , i_batch_rec.credit_amount
      , i_batch_rec.debit_count
      , i_batch_rec.debit_amount
      , i_batch_rec.is_rejected
    );
end save_batch;

/*
 * Procedure loads fields of Diners Club records by a specified function code (FUNCD).
 */
procedure load_fields_reference(
    i_function_code       in            din_api_type_pkg.t_function_code
  , o_message_field_tab      out        din_api_type_pkg.t_message_field_tab
) is
begin
    select function_code
         , field_name
         , field_number
         , format
         , field_length
         , is_mandatory
         , default_value
         , emv_tag
         , description
      bulk collect into
           o_message_field_tab
      from din_message_field
     where function_code = i_function_code
        or i_function_code is null
     order by
           function_code
         , field_number;

    trc_log_pkg.debug(
        i_text       => lower($$PLSQL_UNIT) || '.load_fields_reference  Finish '
                     || 'o_message_field_tab.count() = #2, i_function_code [#1]'
      , i_env_param1 => i_function_code
      , i_env_param2 => o_message_field_tab.count()
    );
end load_fields_reference;

function get_addendum_id return com_api_type_pkg.t_long_id
is
begin
    return com_api_id_pkg.get_id(i_seq => din_addendum_seq.nextval);
end;

/*
 * Function adds a new addendum to a collection
 * and returns an index to it (a pointer).
 */
function add_addendum(
    io_addendum_tab       in out nocopy din_api_type_pkg.t_addendum_tab
  , i_fin_id              in            com_api_type_pkg.t_long_id
  , i_function_code       in            din_api_type_pkg.t_function_code
) return com_api_type_pkg.t_count
is
    l_index               com_api_type_pkg.t_count := 0;
begin
    l_index := nvl(io_addendum_tab.count(), 0) + 1;
    io_addendum_tab(l_index).id            := get_addendum_id();
    io_addendum_tab(l_index).function_code := i_function_code;
    io_addendum_tab(l_index).fin_id        := i_fin_id;

    --trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.add_addendum() Finish l_index = ' || l_index);
    return l_index;
end add_addendum;

/*
 * Function adds requested amount of addendum values to a collection,
 * initializes them with IDs and parent addendum ID,
 * and returns index to the first element (addendum value) of new ones.
 */
function init_addendum_values(
    io_addendum_value_tab in out nocopy din_api_type_pkg.t_addendum_value_tab
  , i_addendum_id         in            com_api_type_pkg.t_long_id
  , i_count               in            com_api_type_pkg.t_count
) return com_api_type_pkg.t_count
is
    l_base_index          com_api_type_pkg.t_count := 0;
begin
    l_base_index := nvl(io_addendum_value_tab.count(), 0);
    for i in 1 .. i_count loop
        io_addendum_value_tab(l_base_index + i).id          := get_addendum_id();
        io_addendum_value_tab(l_base_index + i).addendum_id := i_addendum_id;
    end loop;

    --trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.init_addendum_values() Finish l_base_index = ' || l_base_index);

    return l_base_index + 1;
end init_addendum_values;

function get_fin_message(
    i_id                  in            com_api_type_pkg.t_long_id
  , i_mask_error          in            com_api_type_pkg.t_boolean
) return din_api_type_pkg.t_fin_message_rec
is
    l_fin_cur             sys_refcursor;
    l_statement           com_api_type_pkg.t_text;
    l_fin_rec             din_api_type_pkg.t_fin_message_rec;
begin
    l_statement :=
'select ' || G_COLUMN_LIST || '
  from din_fin_message f
  left join din_card c    on c.id = f.id
 where f.id = :i_id';

    open l_fin_cur for l_statement using i_id;
    fetch l_fin_cur into l_fin_rec;
    close l_fin_cur;

    if l_fin_rec.id is null then
        if i_mask_error = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_error(
                i_error      => 'DIN_FIN_MESSAGE_NOT_FOUND'
              , i_env_param1 => i_id
            );
        else
            trc_log_pkg.warn(
                i_text       => 'DIN_FIN_MESSAGE_NOT_FOUND'
              , i_env_param1 => i_id
            );
        end if;
    end if;

    return l_fin_rec;

exception
    when others then
        if l_fin_cur%isopen then
            close l_fin_cur;
        end if;
        raise;
end get_fin_message;

function get_original_fin_message(
    i_fin_rec             in            din_api_type_pkg.t_fin_message_rec
  , i_mask_error          in            com_api_type_pkg.t_boolean
) return din_api_type_pkg.t_fin_message_rec
is
    l_fin_cur             sys_refcursor;
    l_statement           com_api_type_pkg.t_text;
    l_fin_rec             din_api_type_pkg.t_fin_message_rec;
begin
    l_statement :=
'select ' || G_COLUMN_LIST || '
   from din_fin_message f
   join din_card c           on c.id = f.id
  where c.card_number    = iss_api_token_pkg.encode_card_number(
                               i_card_number => :i_card_number
                           )
    and f.id            != :i_id
    and f.network_refnum = :i_network_refnum
    and f.is_reversal    = :i_is_reversal
  order by
        f.id desc';

    open l_fin_cur for l_statement
    using i_fin_rec.card_number
        , i_fin_rec.id
        , i_fin_rec.network_refnum
        , com_api_type_pkg.FALSE -- is_reversal
    ;
    fetch l_fin_cur into l_fin_rec;
    close l_fin_cur;

    if l_fin_rec.id is null then
        if i_mask_error = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_error(
                i_error      => 'DIN_ORIGINAL_FIN_MESSAGE_NOT_FOUND_BY_REFNUM'
              , i_env_param1 => i_fin_rec.id
              , i_env_param2 => i_fin_rec.card_number
              , i_env_param3 => i_fin_rec.network_refnum
            );
        else
            trc_log_pkg.warn(
                i_text       => 'DIN_ORIGINAL_FIN_MESSAGE_NOT_FOUND_BY_REFNUM'
              , i_env_param1 => i_fin_rec.id
              , i_env_param2 => i_fin_rec.card_number
              , i_env_param3 => i_fin_rec.network_refnum
            );
        end if;
    end if;

    return l_fin_rec;

exception
    when others then
        if l_fin_cur%isopen then
            close l_fin_cur;
        end if;
        raise;
end get_original_fin_message;

/*
 * Function finds appropriate type of charge by SV2 operation type, reversal flag, terminal type,
 * and MCC (mapping for outgoing clearing).
 */
function get_type_of_charge(
    i_oper_type           in            com_api_type_pkg.t_dict_value
  , i_is_reversal         in            com_api_type_pkg.t_boolean
  , i_terminal_type       in            com_api_type_pkg.t_dict_value
  , i_mcc                 in            com_api_type_pkg.t_mcc
  , i_is_icc_transaction  in            com_api_type_pkg.t_boolean
) return din_api_type_pkg.t_type_of_charge
result_cache relies_on (din_type_of_charge_map)
is
    LOG_PREFIX          constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_type_of_charge ';
    l_type_of_charge             din_api_type_pkg.t_type_of_charge;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' Start i_oper_type [#1], i_is_reversal [#2]'
                                   ||   ', i_terminal_type [#3], i_mcc [#4]'
      , i_env_param1 => i_oper_type
      , i_env_param2 => i_is_reversal
      , i_env_param3 => i_terminal_type
      , i_env_param4 => i_mcc
    );

    select distinct
           -- If there are more than 1 records that may be used for <i_mcc> then consider
           -- that an exact value is not shorter than a mask (e.g., '6011' is longer than '60%')
           first_value(type_of_charge) over (order by length(mcc) desc)
      into l_type_of_charge
      from din_type_of_charge_map
     where is_incoming   = com_api_type_pkg.FALSE
       and oper_type     = i_oper_type
       and is_reversal   = i_is_reversal
       and terminal_type = i_terminal_type
       and i_mcc like mcc
       and (i_is_icc_transaction is null or is_icc_transaction = i_is_icc_transaction);

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' Finish type_of_charge [#1]'
      , i_env_param1 => l_type_of_charge
    );

    return l_type_of_charge;

exception
    when no_data_found then
        com_api_error_pkg.raise_error(
            i_error      => 'DIN_TYPE_OF_CHARGE_IS_NOT_DEFINED'
          , i_env_param1 => i_oper_type
          , i_env_param2 => i_is_reversal
          , i_env_param3 => i_terminal_type
          , i_env_param4 => i_mcc
        );
end get_type_of_charge;

/*
 * Function returns TRUE if incoming charge type is in the range of cash (or cash equivalent) charge types.
 */
function is_cash_charge_type(
    i_charge_type         in            din_api_type_pkg.t_charge_type
) return com_api_type_pkg.t_boolean
result_cache
is
begin
    return
        case
            -- Every charge type is a string representation of 3-digit number without leading zeros,
            -- there is no need to cast them to number (lexicographic order is implied)
            when i_charge_type >= din_api_const_pkg.CHTYP_CASHES_RANGE_START
             and i_charge_type <= din_api_const_pkg.CHTYP_CASHES_RANGE_END
            then com_api_const_pkg.TRUE
            else com_api_const_pkg.FALSE
        end;
end is_cash_charge_type;

/*
 * Procedure finds appropriate SV2 operation type, reversal flag, terminal type by provided values
 * of type of charge and MCC (mapping for incoming clearing).
 */
procedure get_operation_parameters(
    i_type_of_charge      in            din_api_type_pkg.t_type_of_charge
  , i_mcc                 in            com_api_type_pkg.t_mcc
  , o_is_reversal            out        com_api_type_pkg.t_boolean
  , o_oper_type              out        com_api_type_pkg.t_dict_value
  , o_terminal_type          out        com_api_type_pkg.t_dict_value
) is
    LOG_PREFIX   constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_operation_parameters ';
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' Start i_type_of_charge [#1], i_mcc [#2]'
      , i_env_param1 => i_type_of_charge
      , i_env_param2 => i_mcc
    );

    select distinct
           -- If there are more than 1 records that may be used for <i_mcc> then consider
           -- that an exact value is not shorter than a mask (e.g., '6011' is longer than '60%')
           first_value(is_reversal)   over (order by length(mcc) desc)
         , first_value(oper_type)     over (order by length(mcc) desc)
         , first_value(terminal_type) over (order by length(mcc) desc)
      into o_is_reversal
         , o_oper_type
         , o_terminal_type
      from din_type_of_charge_map
     where is_incoming    = com_api_type_pkg.TRUE
       and type_of_charge = i_type_of_charge
       and i_mcc like mcc;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' Finish o_is_reversal [#1], o_oper_type [#2], o_terminal_type [#3]'
      , i_env_param1 => o_is_reversal
      , i_env_param2 => o_oper_type
      , i_env_param3 => o_terminal_type
    );

exception
    when no_data_found then
        com_api_error_pkg.raise_error(
            i_error      => 'DIN_OPER_PARAMETERS_ARE_NOT_DEFINED'
          , i_env_param1 => i_type_of_charge
          , i_env_param2 => i_mcc
        );
end get_operation_parameters;

/*
 * It determines an impact (debit/credit) for a type of charge.
 */
function get_impact(
    i_type_of_charge      in            din_api_type_pkg.t_type_of_charge
) return com_api_type_pkg.t_sign
result_cache relies_on (din_type_of_charge_ref)
is
    LOG_PREFIX   constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_impact ';
    l_impact              com_api_type_pkg.t_sign;
begin
    select impact
      into l_impact
      from din_type_of_charge_ref
     where type_of_charge = i_type_of_charge;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' Finish impact [#1]'
      , i_env_param1 => l_impact
    );

    if l_impact not in (com_api_const_pkg.DEBIT, com_api_const_pkg.CREDIT) then
        raise no_data_found;
    end if;

    return l_impact;

exception
    when no_data_found then
        com_api_error_pkg.raise_error(
            i_error      => 'DIN_NO_IMPACT_FOR_TYPE_OF_CHARGE'
          , i_env_param1 => i_type_of_charge
        );
end get_impact;

/*
 * Function searches corresponding value for a SmartVista PoS article and returns corresponding
 * value for Diners Club, if it isn't found then empty value is returned (error is not raised).
 */
function get_pos_data(
    i_pos_dict_code       in            com_api_type_pkg.t_dict_value
  , i_pos_article         in            com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_byte_char
result_cache relies_on (din_pos_data)
is
    l_pos_article         com_api_type_pkg.t_byte_char;
begin
    begin
        select pos_value
          into l_pos_article
          from din_pos_data
         where pos_article = i_pos_article;
    exception
        when no_data_found then
            trc_log_pkg.error(
                i_text       => 'DIN_POS_ARTICLE_IS_NOT_MAPPED'
              , i_env_param1 => i_pos_article
            );
    end;

    return l_pos_article;
end get_pos_data;

/*
 * It returns agent code / issuer institution code by PAN using the reference table DIN_BIN.
 */
function get_agent_code(
    i_card_number         in            com_api_type_pkg.t_card_number
) return din_api_type_pkg.t_institution_code
is
    l_agent_code          din_api_type_pkg.t_institution_code;
begin
    select agent_code
      into l_agent_code
      from din_bin
     where i_card_number between start_bin and end_bin;

    return l_agent_code;

exception
    when too_many_rows then
        com_api_error_pkg.raise_error(
            i_error      => 'DIN_BIN_RANGE_IS_NOT_UNIQUE'
          , i_env_param1 => iss_api_card_pkg.get_card_mask(i_card_number => i_card_number)
        );
    when no_data_found then
        com_api_error_pkg.raise_error(
            i_error      => 'DIN_BIN_RANGE_IS_NOT_DEFINED'
          , i_env_param1 => iss_api_card_pkg.get_card_mask(i_card_number => i_card_number)
        );
end get_agent_code;

/*
 * Function defines internal SmartVista institution ID by provided Diners Club agent code.
 */
function get_inst_id(
    i_agent_code          in            din_api_type_pkg.t_institution_code
  , i_network_id          in            com_api_type_pkg.t_network_id
  , i_standard_id         in            com_api_type_pkg.t_tiny_id             default null
) return com_api_type_pkg.t_inst_id
is
    cursor l_cursor is
        select m.inst_id
             , i.host_member_id
          from net_interface i
          join net_member m       on m.id = i.consumer_member_id
         where m.network_id = i_network_id;

    l_rec                 l_cursor%rowtype;
    l_param_tab           com_api_type_pkg.t_param_tab;
    l_agent_code          com_api_type_pkg.t_name;
    l_inst_id             com_api_type_pkg.t_inst_id;
    l_is_found            boolean := false;
begin
    open l_cursor;

    loop
        fetch l_cursor into l_rec;

        exit when l_is_found or l_cursor%notfound;

        begin
            cmn_api_standard_pkg.get_param_value(
                i_inst_id      => l_rec.inst_id
              , i_standard_id  => nvl(i_standard_id, din_api_const_pkg.DIN_CLEARING_STANDARD)
              , i_entity_type  => net_api_const_pkg.ENTITY_TYPE_HOST
              , i_object_id    => l_rec.host_member_id
              , i_param_name   => din_api_const_pkg.PARAM_NAME_ACQ_AGENT_CODE
              , o_param_value  => l_agent_code
              , i_param_tab    => l_param_tab
            );
        exception
            when com_api_error_pkg.e_application_error then
                null;
        end;

        if trim(l_agent_code) = trim(i_agent_code) then
            l_inst_id  := l_rec.inst_id;
            l_is_found := true;
        end if;
    end loop;

    close l_cursor;

    if l_inst_id is null then
        com_api_error_pkg.raise_error(
            i_error      => 'DIN_UNKNOWN_AGENT_CODE'
          , i_env_param1 => i_agent_code
          , i_env_param2 => i_network_id
          , i_env_param3 => i_standard_id
        );
    end if;

    return l_inst_id;

exception
    when others then
        if l_cursor%isopen then
            close l_cursor;
        end if;

        raise;
end get_inst_id;

procedure save_messages(
    io_fin_tab            in out nocopy din_api_type_pkg.t_fin_message_tab
) is
begin
    trc_log_pkg.debug(
        i_text       => lower($$PLSQL_UNIT) || '.save_message Start io_fin_tab.count() = #1'
      , i_env_param1 => io_fin_tab.count()
    );

    if io_fin_tab.count() > 0 then
        for i in io_fin_tab.first .. io_fin_tab.last loop
            if io_fin_tab(i).id is null then
                io_fin_tab(i).id := opr_api_create_pkg.get_id();
            end if;
        end loop;
    end if;

    forall i in io_fin_tab.first .. io_fin_tab.last
        insert into din_fin_message(
            id
          , status
          , file_id
          , record_number
          , batch_id
          , sequential_number
          , is_incoming
          , is_rejected
          , is_reversal
          , is_invalid
          , network_id
          , inst_id
          , sending_institution
          , receiving_institution
          , dispute_id
          , originator_refnum
          , network_refnum
          , card_id
          , type_of_charge
          , charge_type
          , date_type
          , charge_date
          , sttl_date
          , host_date
          , auth_code
          , action_code
          , oper_amount
          , oper_currency
          , sttl_amount
          , sttl_currency
          , mcc
          , merchant_number
          , merchant_name
          , merchant_city
          , merchant_country
          , merchant_state
          , merchant_street
          , merchant_postal_code
          , merchant_phone
          , merchant_international_code
          , terminal_number
          , program_transaction_amount
          , alt_currency
          , alt_rate_type
          , tax_amount1
          , tax_amount2
          , original_document_number
          , crdh_presence
          , card_presence
          , card_data_input_mode
          , card_data_input_capability
          , card_type
          , payment_token
          , token_requestor_id
          , token_assurance_level
        ) values (
            io_fin_tab(i).id
          , io_fin_tab(i).status
          , io_fin_tab(i).file_id
          , io_fin_tab(i).record_number
          , io_fin_tab(i).batch_id
          , io_fin_tab(i).sequential_number
          , io_fin_tab(i).is_incoming
          , io_fin_tab(i).is_rejected
          , io_fin_tab(i).is_reversal
          , io_fin_tab(i).is_invalid
          , io_fin_tab(i).network_id
          , io_fin_tab(i).inst_id
          , io_fin_tab(i).sending_institution
          , io_fin_tab(i).receiving_institution
          , io_fin_tab(i).dispute_id
          , io_fin_tab(i).originator_refnum
          , io_fin_tab(i).network_refnum
          , io_fin_tab(i).card_id
          , io_fin_tab(i).type_of_charge
          , io_fin_tab(i).charge_type
          , io_fin_tab(i).date_type
          , io_fin_tab(i).charge_date
          , io_fin_tab(i).sttl_date
          , io_fin_tab(i).host_date
          , io_fin_tab(i).auth_code
          , io_fin_tab(i).action_code
          , io_fin_tab(i).oper_amount
          , io_fin_tab(i).oper_currency
          , io_fin_tab(i).sttl_amount
          , io_fin_tab(i).sttl_currency
          , io_fin_tab(i).mcc
          , io_fin_tab(i).merchant_number
          , io_fin_tab(i).merchant_name
          , io_fin_tab(i).merchant_city
          , io_fin_tab(i).merchant_country
          , io_fin_tab(i).merchant_state
          , io_fin_tab(i).merchant_street
          , io_fin_tab(i).merchant_postcode
          , io_fin_tab(i).merchant_phone
          , io_fin_tab(i).merchant_international_code
          , io_fin_tab(i).terminal_number
          , io_fin_tab(i).program_transaction_amount
          , io_fin_tab(i).alt_currency
          , io_fin_tab(i).alt_rate_type
          , io_fin_tab(i).tax_amount1
          , io_fin_tab(i).tax_amount2
          , io_fin_tab(i).original_document_number
          , io_fin_tab(i).crdh_presence
          , io_fin_tab(i).card_presence
          , io_fin_tab(i).card_data_input_mode
          , io_fin_tab(i).card_data_input_capability
          , io_fin_tab(i).card_type
          , io_fin_tab(i).payment_token
          , io_fin_tab(i).token_requestor_id
          , io_fin_tab(i).token_assurance_level
        );

    forall i in io_fin_tab.first .. io_fin_tab.last
        insert into din_card(
            id
          , card_number
        ) values (
            io_fin_tab(i).id
          , iss_api_token_pkg.encode_card_number(i_card_number => io_fin_tab(i).card_number)
        );

    trc_log_pkg.debug(
        i_text       => lower($$PLSQL_UNIT) || '.save_message Finish financial messages were created [#1]'
      , i_env_param1 => io_fin_tab.count()
    );
end save_messages; -- t_fin_message_tab

function save_message(
    i_fin_rec             in            din_api_type_pkg.t_fin_message_rec
) return com_api_type_pkg.t_long_id
is
    l_fin_tab                           din_api_type_pkg.t_fin_message_tab;
begin
    l_fin_tab(1) := i_fin_rec;

    save_messages(io_fin_tab => l_fin_tab);

    return l_fin_tab(1).id;
end save_message; -- t_fin_message_rec

procedure create_addendums(
    io_fin_rec            in out nocopy din_api_type_pkg.t_fin_message_rec
  , i_auth_rec            in            aut_api_type_pkg.t_auth_rec
  , o_addendum_tab           out        din_api_type_pkg.t_addendum_tab
  , o_addendum_value_tab     out        din_api_type_pkg.t_addendum_value_tab
) is
    l_addendum_index                    com_api_type_pkg.t_count := 0;
    l_value_index                       com_api_type_pkg.t_count := 0;
    l_index                             com_api_type_pkg.t_count := 0;
    l_emv_tag_tab                       com_api_type_pkg.t_tag_value_tab;
    l_emv_data                          com_api_type_pkg.t_full_desc;
    l_is_icc_transaction                com_api_type_pkg.t_boolean;
begin
    -- ATM Additional Detail Record
    if  io_fin_rec.charge_type in (
            din_api_const_pkg.CHTYP_ATM_CASH_ADV_WITHOUT_FEE
          , din_api_const_pkg.CHTYP_ATM_CASH_ADV_INCLD_FEE
          , din_api_const_pkg.CHTYP_ATM_SRV_FEE_FOR_CASH_ADV
        )
    then
        l_addendum_index := add_addendum(
                                io_addendum_tab       => o_addendum_tab
                              , i_fin_id              => io_fin_rec.id
                              , i_function_code       => din_api_const_pkg.FUNCTION_CODE_ADD_ATM
                            );

        l_value_index    := init_addendum_values(
                                io_addendum_value_tab => o_addendum_value_tab
                              , i_addendum_id         => o_addendum_tab(l_addendum_index).id
                              , i_count               => 5
                            );
        -- SCGMT
        o_addendum_value_tab(l_value_index + 0).field_name  := din_api_const_pkg.FIELD_ACQUIRER_TIME;
        o_addendum_value_tab(l_value_index + 0).field_value := to_char(i_auth_rec.sttl_date
                                                                     , din_api_const_pkg.TIME_FORMAT);
        -- SCDAT
        o_addendum_value_tab(l_value_index + 1).field_name  := din_api_const_pkg.FIELD_ACQUIRER_DATE;
        o_addendum_value_tab(l_value_index + 1).field_value := to_char(i_auth_rec.sttl_date
                                                                     , din_api_const_pkg.DATE_FORMAT);
        -- LCTIM
        o_addendum_value_tab(l_value_index + 2).field_name  := din_api_const_pkg.FIELD_LOCAL_TERMINAL_TIME;
        o_addendum_value_tab(l_value_index + 2).field_value := to_char(i_auth_rec.host_date
                                                                     , din_api_const_pkg.TIME_FORMAT);
        -- LCDAT
        o_addendum_value_tab(l_value_index + 3).field_name  := din_api_const_pkg.FIELD_LOCAL_TERMINAL_DATE;
        o_addendum_value_tab(l_value_index + 3).field_value := to_char(i_auth_rec.host_date
                                                             , din_api_const_pkg.DATE_FORMAT);

        -- Fields in <io_fin_rec> are filled for displaying on GUI only
        io_fin_rec.sttl_date := i_auth_rec.sttl_date; -- SCGMT/SCDAT
        io_fin_rec.host_date := i_auth_rec.host_date; -- LCTIM/LCDAT

        -- ATMID, it should be numeric (8 digits)
        begin
            o_addendum_value_tab(l_value_index + 4).field_name  := din_api_const_pkg.FIELD_ATM_ID_NUMBER;
            if length(i_auth_rec.terminal_number) > 8 then
                o_addendum_value_tab(l_value_index + 4).field_value := to_number(substr(i_auth_rec.terminal_number, -8));
            else
                o_addendum_value_tab(l_value_index + 4).field_value := to_number(i_auth_rec.terminal_number);
            end if;

            io_fin_rec.terminal_number := o_addendum_value_tab(l_value_index + 4).field_value;
        exception
            when com_api_error_pkg.e_value_error then
                com_api_error_pkg.raise_error(
                    i_error      => 'DIN_INVALID_ATMID'
                  , i_env_param1 => i_auth_rec.terminal_number
                );
        end;
    end if;

    -- Check if associated transaction contains EMV data (i.e. is it an ICC transaction?)
    l_is_icc_transaction := is_icc_transaction(
                                io_fin_rec => io_fin_rec
                            );

    -- Chip card additional detail record
    if l_is_icc_transaction = com_api_type_pkg.TRUE then
        emv_api_tag_pkg.parse_emv_data(
            i_emv_data      => i_auth_rec.emv_data
          , i_is_binary     => emv_api_tag_pkg.is_binary()
          , o_emv_tag_tab   => l_emv_tag_tab
        );

        -- Format EMV tags in according to data in DIN_ADDENDUM_FIELD
        l_emv_data := -- this value isn't actually used, only <l_emv_tag_tab> matters
            emv_api_tag_pkg.format_emv_data(
                io_emv_tag_tab  => l_emv_tag_tab
              , i_tag_type_tab  => g_emv_tags_list
            );

        emv_api_tag_pkg.dump_tag_table(
            i_emv_tag_tab    => l_emv_tag_tab
          , i_is_debug_only  => com_api_type_pkg.TRUE
        );

        l_addendum_index := add_addendum(
                                io_addendum_tab       => o_addendum_tab
                              , i_fin_id              => io_fin_rec.id
                              , i_function_code       => din_api_const_pkg.FUNCTION_CODE_ADD_CHIP_CARD
                            );

        l_value_index    := init_addendum_values(
                                io_addendum_value_tab => o_addendum_value_tab
                              , i_addendum_id         => o_addendum_tab(l_addendum_index).id
                              , i_count               => g_addendum_chip_data.count()
                            );

        for i in 1 .. g_addendum_chip_data.count() loop
            l_index := l_value_index + i - 1;

            o_addendum_value_tab(l_index).field_name := g_addendum_chip_data(i).field_name;

            --trc_log_pkg.debug(
            --    i_text       => 'g_addendum_chip_data(#1) = {field_name [#2], field_length [#3], emv_tag [#4]'
            --  , i_env_param1 => i
            --  , i_env_param2 => g_addendum_chip_data(i).field_name
            --  , i_env_param3 => g_addendum_chip_data(i).field_length
            --  , i_env_param4 => g_addendum_chip_data(i).emv_tag
            --);

            if l_emv_tag_tab.exists(g_addendum_chip_data(i).emv_tag) then
                o_addendum_value_tab(l_index).field_value :=
                    l_emv_tag_tab(g_addendum_chip_data(i).emv_tag);
            end if;

            -- Empty EMV tags are presented as strings of spaces, every tag has a fixed length,
            -- so that an entire Chip card addendum has the fixed length too
            o_addendum_value_tab(l_index).field_value :=
                rpad(
                    coalesce(
                        o_addendum_value_tab(l_index).field_value
                      , g_addendum_chip_data(i).default_value
                      , ' '
                    )
                  , g_addendum_chip_data(i).field_length
                  , ' '
                );

            --trc_log_pkg.debug(
            --    i_text       => 'o_addendum_value_tab(#1) = {field_name [#2], field_value [#3]'
            --  , i_env_param1 => i
            --  , i_env_param2 => o_addendum_value_tab(i).field_name
            --  , i_env_param3 => o_addendum_value_tab(i).field_value
            --);
        end loop;
    end if;
end create_addendums;

procedure save_addendums(
    io_addendum_tab       in out nocopy din_api_type_pkg.t_addendum_tab
  , i_addendum_value_tab  in            din_api_type_pkg.t_addendum_value_tab
) is
    LOG_PREFIX            constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.save_addendums';
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' Start io_addendum_tab.count() = #1'
                                   || ', i_addendum_value_tab.count() = #2'
      , i_env_param1 => io_addendum_tab.count()
      , i_env_param2 => i_addendum_value_tab.count()
    );

    if io_addendum_tab is not null and io_addendum_tab.count() > 0 then
        for i in io_addendum_tab.first .. io_addendum_tab.count loop
            if io_addendum_tab(i).id is null then -- Reassurance because <io_addendum_tab(i).id> is not NULL
                io_addendum_tab(i).id := get_addendum_id();
            end if;
        end loop;

        forall i in io_addendum_tab.first .. io_addendum_tab.count
            insert into din_addendum(
                id
              , function_code
              , fin_id
              , file_id
              , record_number
            ) values (
                io_addendum_tab(i).id
              , io_addendum_tab(i).function_code
              , io_addendum_tab(i).fin_id
              , io_addendum_tab(i).file_id
              , io_addendum_tab(i).record_number
            );
    end if;

    if i_addendum_value_tab is not null and i_addendum_value_tab.count() > 0 then
        forall i in i_addendum_value_tab.first .. i_addendum_value_tab.last
            insert into din_addendum_value(
                id
              , addendum_id
              , field_name
              , field_value
            ) values (
                i_addendum_value_tab(i).id
              , i_addendum_value_tab(i).addendum_id
              , i_addendum_value_tab(i).field_name
              , i_addendum_value_tab(i).field_value
            );
    end if;

    trc_log_pkg.debug(LOG_PREFIX || ' Finish');
end save_addendums;

procedure create_from_auth(
    i_auth_rec            in     aut_api_type_pkg.t_auth_rec
  , i_inst_id             in     com_api_type_pkg.t_inst_id       default null
  , i_network_id          in     com_api_type_pkg.t_tiny_id       default null
  , i_message_status      in     com_api_type_pkg.t_dict_value    default null
  , io_fin_message_id     in out com_api_type_pkg.t_long_id
) is
    LOG_PREFIX          constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.create_from_auth';
    l_standard_id                com_api_type_pkg.t_tiny_id;
    l_host_id                    com_api_type_pkg.t_tiny_id;
    l_tcc                        com_api_type_pkg.t_mcc;
    l_cab_type                   com_api_type_pkg.t_mcc;
    l_fin_rec                    din_api_type_pkg.t_fin_message_rec;
    l_param_tab                  com_api_type_pkg.t_param_tab;
    l_addendum_tab               din_api_type_pkg.t_addendum_tab;
    l_addendum_value_tab         din_api_type_pkg.t_addendum_value_tab;
    l_is_icc_transaction         com_api_type_pkg.t_boolean;
    l_tag_id                     com_api_type_pkg.t_short_id;
    l_original_auth_id           com_api_type_pkg.t_long_id;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' Start i_auth_rec.id [#1], i_inst_id [#2], i_network_id [#3]'
                                   || ', i_message_status [#4], io_fin_message_id [#5]'
      , i_env_param1 => i_auth_rec.id
      , i_env_param2 => i_inst_id
      , i_env_param3 => i_network_id
      , i_env_param4 => i_message_status
      , i_env_param5 => io_fin_message_id
    );

    if io_fin_message_id is null then
        -- It usuallly contains opr_api_shared_data_pkg.g_auth.id
        io_fin_message_id := opr_api_create_pkg.get_id();
    end if;

    l_fin_rec.id                := io_fin_message_id;
    l_fin_rec.status            := nvl(i_message_status, net_api_const_pkg.CLEARING_MSG_STATUS_READY);
    l_fin_rec.is_reversal       := i_auth_rec.is_reversal;
    l_fin_rec.is_incoming       := com_api_type_pkg.FALSE;
    l_fin_rec.is_rejected       := null;
    l_fin_rec.inst_id           := nvl(i_inst_id,    i_auth_rec.acq_inst_id);
    l_fin_rec.network_id        := nvl(i_network_id, i_auth_rec.iss_network_id);

    l_fin_rec.originator_refnum := substr(i_auth_rec.originator_refnum, -8);
    l_fin_rec.auth_code         := i_auth_rec.auth_code;

    l_fin_rec.card_id           := i_auth_rec.card_id;
    l_fin_rec.card_number       :=
        coalesce(
            i_auth_rec.card_number
          , iss_api_card_pkg.get_card_number(i_card_id => i_auth_rec.card_id)
        );

    l_fin_rec.mcc               := i_auth_rec.mcc;
    l_fin_rec.merchant_number   := i_auth_rec.merchant_number;
    l_fin_rec.merchant_country  := i_auth_rec.merchant_country;
    l_fin_rec.merchant_postcode := i_auth_rec.merchant_postcode;
    l_fin_rec.merchant_name     := substr(i_auth_rec.merchant_name, 1, 36);
    l_fin_rec.merchant_city     := substr(i_auth_rec.merchant_city, 1, 26);
    l_fin_rec.merchant_street   := substr(i_auth_rec.merchant_street, 1, 35);
    l_fin_rec.terminal_number   := i_auth_rec.terminal_number;

    -- Get network host and communication standard
    l_host_id     := net_api_network_pkg.get_default_host(i_network_id => l_fin_rec.network_id);
    l_standard_id := net_api_network_pkg.get_offline_standard(i_network_id => l_fin_rec.network_id);

    trc_log_pkg.debug(
        i_text       => 'network_id [#1], l_host_id [#2], l_standard_id [#3]'
      , i_env_param1 => l_fin_rec.network_id
      , i_env_param2 => l_host_id
      , i_env_param3 => l_standard_id
    );

    rul_api_shared_data_pkg.load_oper_params(
        i_oper_id  => i_auth_rec.id
      , io_params  => l_param_tab
    );

    -- Get Diners Club acquirer (sending) institution (agent code)
    l_fin_rec.sending_institution :=
        cmn_api_standard_pkg.get_varchar_value(
            i_inst_id     => l_fin_rec.inst_id
          , i_standard_id => l_standard_id
          , i_entity_type => net_api_const_pkg.ENTITY_TYPE_HOST
          , i_object_id   => l_host_id
          , i_param_name  => din_api_const_pkg.PARAM_NAME_ACQ_AGENT_CODE
          , i_param_tab   => l_param_tab
        );
    trc_log_pkg.debug('sending_institution [' || l_fin_rec.sending_institution || ']');

    if l_fin_rec.sending_institution is null then
        com_api_error_pkg.raise_error(
            i_error      => 'DIN_ACQ_AGENT_CODE_IS_NOT_DEFINED'
          , i_env_param1 => l_fin_rec.inst_id
          , i_env_param2 => l_standard_id
          , i_env_param3 => l_host_id
        );
    end if;

    -- Get Diners Club receiving institution (agent code) from the BIN reference (DIN_BIN) by a PAN
    l_fin_rec.receiving_institution := get_agent_code(i_card_number => l_fin_rec.card_number);

    l_fin_rec.oper_amount       := i_auth_rec.oper_amount;
    l_fin_rec.oper_currency     := i_auth_rec.oper_currency;
    -- It is not needed/possible to send amount in issuer currency in outgoing clearing (acquirer site)
    l_fin_rec.sttl_amount       := null;
    l_fin_rec.sttl_currency     := null;

    -- Mapping Point of Service data (DE 22) to Diners Club values
    l_fin_rec.crdh_presence :=
        get_pos_data(
            i_pos_dict_code => acq_api_const_pkg.DICT_CARDHOLDER_PRESENCE_DATA
          , i_pos_article   => i_auth_rec.crdh_presence
        );

    l_fin_rec.card_presence :=
        get_pos_data(
            i_pos_dict_code => acq_api_const_pkg.DICT_CARD_PRESENCE_DATA
          , i_pos_article   => i_auth_rec.card_presence
        );

    l_fin_rec.card_data_input_mode :=
        get_pos_data(
            i_pos_dict_code => acq_api_const_pkg.DICT_CARD_DATA_INPUT_MODE
          , i_pos_article   => i_auth_rec.card_data_input_mode
        );

    l_fin_rec.card_data_input_capability :=
        get_pos_data(
            i_pos_dict_code => acq_api_const_pkg.DICT_CARD_DATA_INPUT_CAP
          , i_pos_article   => i_auth_rec.card_data_input_cap
        );

    -- For fallback
    if      l_fin_rec.card_data_input_mode       = '2'
        and l_fin_rec.card_data_input_capability = '9'
        and substr(i_auth_rec.service_code, 1, 1) in ('2', '6')
    then
        l_fin_rec.card_data_input_mode := '9';
    end if;

    -- Check if associated transaction contain EMV data (i.e. is it an ICC transaction?)
    l_is_icc_transaction := is_icc_transaction(
                                io_fin_rec => l_fin_rec
                            );

    -- Type of charge (TYPCH) is associated with operation type, terminal type, MCC, and reversal flag
    l_fin_rec.type_of_charge := get_type_of_charge(
                                    i_oper_type          => i_auth_rec.oper_type
                                  , i_is_reversal        => i_auth_rec.is_reversal
                                  , i_terminal_type      => i_auth_rec.terminal_type
                                  , i_mcc                => i_auth_rec.mcc
                                  , i_is_icc_transaction => l_is_icc_transaction
                                );
    trc_log_pkg.debug('type_of_charge [' || l_fin_rec.type_of_charge || ']');

    if get_impact(i_type_of_charge => l_fin_rec.type_of_charge) = com_api_const_pkg.CREDIT then
        -- Field auth_code should be empty for credit types of charge with the exception of "TJ"
        if l_fin_rec.type_of_charge != din_api_const_pkg.TYPCH_ACQUIRED_INTERNET_CREDIT then
            l_fin_rec.auth_code := null;
        end if;
        l_fin_rec.network_refnum := null;
    else
        l_fin_rec.network_refnum := substr(
                                        lpad(
                                            nvl(i_auth_rec.network_refnum, i_auth_rec.originator_refnum)
                                          , 15, '0'
                                        )
                                      , -15
                                    );
    end if;

    trc_log_pkg.debug(
        i_text       => 'network_refnum [#1], auth_code [#2]'
      , i_env_param1 => l_fin_rec.network_refnum
      , i_env_param2 => l_fin_rec.auth_code
    );

    if l_fin_rec.action_code is null then
        l_tag_id              := aup_api_tag_pkg.find_tag_by_reference('DF8634');
        l_fin_rec.action_code := aup_api_tag_pkg.get_tag_value(
                                     i_auth_id => i_auth_rec.id
                                   , i_tag_id  => l_tag_id
                                 );
        if l_fin_rec.action_code is null then
            -- Get original auth_id if a fin. message is created by POS batch
            select min(a.id)
              into l_original_auth_id
              from aut_auth a
             where a.id = i_auth_rec.original_id;

            trc_log_pkg.debug('original_auth_id [' || l_original_auth_id || ']');

            l_fin_rec.action_code := aup_api_tag_pkg.get_tag_value(
                                         i_auth_id => l_original_auth_id
                                       , i_tag_id  => l_tag_id
                                     );
        end if;
    end if;
    trc_log_pkg.debug('action_code [' || l_fin_rec.action_code || ']');

    l_fin_rec.action_code := lpad(nvl(l_fin_rec.action_code, ''), 3, '0');
    trc_log_pkg.debug('formatted action_code [' || l_fin_rec.action_code || ']');

    com_api_mcc_pkg.get_mcc_info(
        i_mcc         => i_auth_rec.mcc
      , o_tcc         => l_tcc      -- not used
      , o_diners_code => l_fin_rec.charge_type
      , o_mc_cab_type => l_cab_type -- not used
    );
    trc_log_pkg.debug('charge_type [' || l_fin_rec.charge_type || ']');

    -- Consider that a date is always provided by a merchant
    l_fin_rec.date_type         := din_api_const_pkg.DATE_TYPE_MERCHANT_PROVIDED;
    l_fin_rec.charge_date       := i_auth_rec.oper_date;

    -- Next 3 parameters are used for creating a trailer for a recap

    l_fin_rec.program_transaction_amount :=
        nvl(
            cmn_api_standard_pkg.get_number_value(
                i_inst_id     => l_fin_rec.inst_id
              , i_standard_id => l_standard_id
              , i_entity_type => net_api_const_pkg.ENTITY_TYPE_HOST
              , i_object_id   => l_host_id
              , i_param_name  => din_api_const_pkg.PARAM_NAME_PROGRAM_TRNSC_AMNT
              , i_param_tab   => l_param_tab
            )
          , din_api_const_pkg.DEFAULT_PROGRAM_TRNSC_AMOUNT
        );
    if  l_fin_rec.program_transaction_amount < din_api_const_pkg.MIN_PROGRAM_TRNSC_AMOUNT
        or
        l_fin_rec.program_transaction_amount > din_api_const_pkg.MAX_PROGRAM_TRNSC_AMOUNT
    then
        com_api_error_pkg.raise_error(
            i_error      => 'DIN_INVALID_PROGRAM_TRANSACTION_AMOUNT'
          , i_env_param1 => l_fin_rec.inst_id
          , i_env_param2 => l_standard_id
          , i_env_param3 => l_host_id
          , i_env_param4 => l_fin_rec.program_transaction_amount
          , i_env_param5 => din_api_const_pkg.MIN_PROGRAM_TRNSC_AMOUNT
          , i_env_param6 => din_api_const_pkg.MAX_PROGRAM_TRNSC_AMOUNT
        );
    end if;

    l_fin_rec.alt_currency :=
        cmn_api_standard_pkg.get_varchar_value(
            i_inst_id     => l_fin_rec.inst_id
          , i_standard_id => l_standard_id
          , i_entity_type => net_api_const_pkg.ENTITY_TYPE_HOST
          , i_object_id   => l_host_id
          , i_param_name  => din_api_const_pkg.PARAM_NAME_ALTERNATE_CURRENCY
          , i_param_tab   => l_param_tab
        );

    l_fin_rec.alt_rate_type :=
        cmn_api_standard_pkg.get_varchar_value(
            i_inst_id     => l_fin_rec.inst_id
          , i_standard_id => l_standard_id
          , i_entity_type => net_api_const_pkg.ENTITY_TYPE_HOST
          , i_object_id   => l_host_id
          , i_param_name  => din_api_const_pkg.PARAM_NAME_ALTERNATE_RATE_TYPE
          , i_param_tab   => l_param_tab
        );

    if l_fin_rec.alt_currency is not null and l_fin_rec.alt_rate_type is null then
        com_api_error_pkg.raise_error(
            i_error      => 'DIN_RATE_TYPE_IS_NOT_DEFINED'
          , i_env_param1 => l_fin_rec.alt_currency
          , i_env_param2 => l_fin_rec.inst_id
          , i_env_param3 => l_standard_id
          , i_env_param4 => l_host_id
        );
    end if;

    -- If operation is being processed is a reversal and its original operation
    -- hasn't still been processed then both of them should be marked as pending
    if i_auth_rec.is_reversal = com_api_type_pkg.TRUE then
        update din_fin_message
           set status = case status
                            when net_api_const_pkg.CLEARING_MSG_STATUS_READY
                            then net_api_const_pkg.CLEARING_MSG_STATUS_PENDING
                            else status
                        end
         where id = i_auth_rec.original_id
        returning
               case status
                   when net_api_const_pkg.CLEARING_MSG_STATUS_PENDING
                   then net_api_const_pkg.CLEARING_MSG_STATUS_PENDING
                   else net_api_const_pkg.CLEARING_MSG_STATUS_READY
               end
          into l_fin_rec.status;

        if sql%rowcount = 0 then
            com_api_error_pkg.raise_error(
                i_error      => 'DIN_ORIGINAL_FIN_MESSAGE_NOT_FOUND'
              , i_env_param1 => i_auth_rec.id
              , i_env_param2 => i_auth_rec.original_id
            );
        else
            trc_log_pkg.debug(
                i_text       => 'new status for the reversal is [#1]'
              , i_env_param1 => l_fin_rec.status
             );
        end if;
    end if;

    l_fin_rec.id := save_message(i_fin_rec => l_fin_rec);

    create_addendums(
        io_fin_rec           => l_fin_rec
      , i_auth_rec           => i_auth_rec
      , o_addendum_tab       => l_addendum_tab
      , o_addendum_value_tab => l_addendum_value_tab
    );

    save_addendums(
        io_addendum_tab      => l_addendum_tab
      , i_addendum_value_tab => l_addendum_value_tab
    );

    trc_log_pkg.debug(LOG_PREFIX || ' Finish');
end create_from_auth;

function estimate_messages_for_export(
    i_network_id          in     com_api_type_pkg.t_tiny_id
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_start_date          in     date
  , i_end_date            in     date
  , i_include_affiliate   in     com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_count
is
    l_result                     com_api_type_pkg.t_count := 0;
    l_host_id                    com_api_type_pkg.t_tiny_id;
    l_standard_id                com_api_type_pkg.t_tiny_id;
begin
    l_host_id     := net_api_network_pkg.get_default_host(i_network_id => i_network_id);
    l_standard_id := net_api_network_pkg.get_offline_standard(i_host_id => l_host_id);

    if i_include_affiliate = com_api_const_pkg.TRUE then
        select /*+ INDEX(f, din_fin_message_CLMS0010_ndx)*/
               count(f.id)
          into l_result
          from din_fin_message f
             , opr_operation o 
             , (select distinct v.param_value cmid
                  from cmn_parameter p
                     , net_api_interface_param_val_vw v
                     , net_member m
                     , net_interface i
                 where p.name           = din_api_const_pkg.PARAM_NAME_ACQ_AGENT_CODE
                   and p.standard_id    = l_standard_id
                   and p.id             = v.param_id
                   and m.id             = v.consumer_member_id
                   and v.host_member_id = l_host_id
                   and m.id             = i.consumer_member_id
                   and v.interface_id   = i.id
                   and (i.msp_member_id in (select id
                                              from net_member
                                             where network_id = i_network_id
                                               and inst_id    = i_inst_id
                                           )
                        or m.inst_id = i_inst_id
                       )
               ) cmid
         where o.id = f.id
           and decode(f.status, 'CLMS0010', 'CLMS0010', null) = 'CLMS0010'
           and decode(f.status, 'CLMS0010', f.sending_institution, null) = cmid.cmid
           and f.is_incoming = com_api_type_pkg.FALSE
           and f.network_id  = i_network_id
           and (
               i_start_date is null and i_end_date is null
            or     f.is_reversal = com_api_const_pkg.FALSE
               and f.charge_date >= coalesce(i_start_date, trunc(f.charge_date))
               and f.charge_date <  coalesce(i_end_date,   trunc(f.charge_date)) + 1
            or     f.is_reversal = com_api_const_pkg.TRUE
               and o.host_date   >= coalesce(i_start_date, trunc(o.oper_date))
               and o.host_date   <  coalesce(i_end_date,   trunc(o.oper_date)) + 1
           );
    else
        select /*+ INDEX(f, din_fin_message_CLMS0010_ndx)*/
               count(f.id)
          into l_result
          from din_fin_message f
          join opr_operation o    on o.id = f.id
         where decode(f.status, 'CLMS0010', 'CLMS0010', null) = 'CLMS0010'
           and f.is_incoming = com_api_type_pkg.FALSE
           and f.network_id  = i_network_id
           and f.inst_id     = i_inst_id
           and (
               i_start_date is null and i_end_date is null
            or     f.is_reversal = com_api_const_pkg.FALSE
               and f.charge_date >= coalesce(i_start_date, trunc(f.charge_date))
               and f.charge_date <  coalesce(i_end_date,   trunc(f.charge_date)) + 1
            or     f.is_reversal = com_api_const_pkg.TRUE
               and o.host_date   >= coalesce(i_start_date, trunc(o.oper_date))
               and o.host_date   <  coalesce(i_end_date,   trunc(o.oper_date)) + 1
           );
    end if;

    return l_result;
end estimate_messages_for_export;

procedure enum_messages_for_export(
    o_fin_cur                out sys_refcursor
  , i_network_id          in     com_api_type_pkg.t_tiny_id
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_start_date          in     date
  , i_end_date            in     date
  , i_include_affiliate   in     com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
) is
    LOG_PREFIX          constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.enum_messages_for_export';
    DATE_PLACEHOLDER    constant com_api_type_pkg.t_name := '##DATE##';
    l_host_id                    com_api_type_pkg.t_tiny_id;
    l_standard_id                com_api_type_pkg.t_tiny_id;

    -- Financial messages should be ordered by:
    -- a) program transaction amount (DRATE);
    -- b) sending (SFTER) and receiving (DFTER) institutions;
    -- c) by recap currecny (CURKY) and alternate recap currecny (ACRKY).
    -- But ACRKY is defined for the host (i.e. for SFTER), so messages are ordered by ACRKY implicitly.
    l_sql_statement              com_api_type_pkg.t_text := '
select /*+ INDEX(f, din_fin_message_CLMS0010_ndx)*/ ' || G_COLUMN_LIST || '
  from din_fin_message f
  join opr_operation o      on o.id = f.id
  left join din_card c      on c.id = f.id
 where decode(f.status, ''CLMS0010'', ''CLMS0010'', null) = ''CLMS0010''
   and f.is_incoming = :is_incoming
   and f.network_id  = :i_network_id
   and f.inst_id     = :i_inst_id
' || DATE_PLACEHOLDER || '
 order by
       f.program_transaction_amount
     , f.sending_institution
     , f.receiving_institution
     , f.oper_currency
     , f.charge_type';

    l_sql_statement_inc_aff      com_api_type_pkg.t_text := '
select /*+ INDEX(f, din_fin_message_CLMS0010_ndx)*/ ' || G_COLUMN_LIST || '
  from din_fin_message f
     , opr_operation o
     , (select distinct v.param_value cmid
         from cmn_parameter p
            , net_api_interface_param_val_vw v
            , net_member m
            , net_interface i
        where p.name           = :l_param_name
          and p.standard_id    = :l_standard_id
          and p.id             = v.param_id
          and m.id             = v.consumer_member_id
          and v.host_member_id = :l_host_id
          and m.id             = i.consumer_member_id
          and v.interface_id   = i.id
          and (i.msp_member_id in (select id
                                     from net_member
                                    where network_id = :i_network_id
                                      and inst_id    = :i_inst_id
                                  )
               or m.inst_id = :i_inst_id
              )
       ) cmid
     , din_card c
 where decode(f.status, ''' || net_api_const_pkg.CLEARING_MSG_STATUS_READY || ''', ''' || net_api_const_pkg.CLEARING_MSG_STATUS_READY || ''', null) = ''' || net_api_const_pkg.CLEARING_MSG_STATUS_READY || '''
   and decode(f.status, ''' || net_api_const_pkg.CLEARING_MSG_STATUS_READY || ''', f.sending_institution, null) = cmid.cmid
   and o.id = f.id
   and f.id = c.id (+)
   and f.is_incoming = :is_incoming
   and f.network_id  = :i_network_id
' || DATE_PLACEHOLDER || '
 order by
       f.program_transaction_amount
     , f.sending_institution
     , f.receiving_institution
     , f.oper_currency
     , f.charge_type';

DATE_CONDITION      constant com_api_type_pkg.t_text :=
   ' and (
          f.is_reversal = ' || com_api_const_pkg.FALSE || '
      and f.charge_date >= coalesce(:i_start_date, trunc(f.charge_date))
      and f.charge_date <  coalesce(:i_end_date,   trunc(f.charge_date)) + 1
       or f.is_reversal = ' || com_api_const_pkg.TRUE || '
      and o.host_date >= coalesce(:i_start_date, trunc(o.host_date))
      and o.host_date <  coalesce(:i_end_date,   trunc(o.host_date)) + 1
     )';
begin
    if i_include_affiliate = com_api_const_pkg.TRUE then
        l_host_id     := net_api_network_pkg.get_default_host(i_network_id);
        l_standard_id := net_api_network_pkg.get_offline_standard(
                             i_host_id => l_host_id
                         );
        l_sql_statement_inc_aff :=
            replace(
                l_sql_statement_inc_aff
              , DATE_PLACEHOLDER
              , case
                    when i_start_date is not null or i_end_date is not null
                    then DATE_CONDITION
                    else null
                end
            );
        if i_start_date is not null or i_end_date is not null then
            open o_fin_cur for l_sql_statement_inc_aff
            using din_api_const_pkg.PARAM_NAME_ACQ_AGENT_CODE
                , l_standard_id
                , l_host_id
                , i_network_id
                , i_inst_id
                , i_inst_id
                , com_api_type_pkg.FALSE
                , i_network_id
                , i_start_date
                , i_end_date
                , i_start_date
                , i_end_date;
        else
            open o_fin_cur for l_sql_statement_inc_aff
            using din_api_const_pkg.PARAM_NAME_ACQ_AGENT_CODE
                , l_standard_id
                , l_host_id
                , i_network_id
                , i_inst_id
                , i_inst_id
                , com_api_type_pkg.FALSE
                , i_network_id;
        end if;
    else
        l_sql_statement :=
            replace(
                l_sql_statement
              , DATE_PLACEHOLDER
              , case
                    when i_start_date is not null or i_end_date is not null
                    then DATE_CONDITION
                    else null
                end
            );
        if i_start_date is not null or i_end_date is not null then
            open o_fin_cur for l_sql_statement
            using com_api_type_pkg.FALSE
                , i_network_id
                , i_inst_id
                , i_start_date
                , i_end_date
                , i_start_date
                , i_end_date;
        else
            open o_fin_cur for l_sql_statement
            using com_api_type_pkg.FALSE
                , i_network_id
                , i_inst_id;
        end if;
    end if;

    trc_log_pkg.debug(LOG_PREFIX || ': l_sql_statement:' || CRLF || l_sql_statement);
exception
    when others then
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || ' FAILED: sqlerrm [#1], l_sql_statement:' || CRLF || '#2'
          , i_env_param1 => sqlerrm
          , i_env_param2 => l_sql_statement
        );
        raise;
end enum_messages_for_export;

function get_addendum_value(
    i_fin_id              in            com_api_type_pkg.t_long_id
  , i_function_code       in            din_api_type_pkg.t_function_code
) return din_api_type_pkg.t_addendum_values_tab
is
    l_addendum_values_tab           din_api_type_pkg.t_addendum_values_tab;
begin
    for i in (select av.field_name
                   , av.field_value
                from din_addendum a
                   , din_addendum_value av
               where a.id               = av.addendum_id
                 and a.fin_id           = i_fin_id
                 and a.function_code    = i_function_code
    ) loop
        l_addendum_values_tab(i.field_name) := i.field_value;
    end loop;

    return l_addendum_values_tab;
end get_addendum_value;

begin
    trc_log_pkg.debug(lower($$PLSQL_UNIT) || '~initialization Start');

    load_fields_reference(
        i_function_code      => din_api_const_pkg.FUNCTION_CODE_ADD_CHIP_CARD
      , o_message_field_tab  => g_addendum_chip_data
    );

    g_emv_tags_list := emv_api_type_pkg.t_emv_tag_type_tab();
    g_emv_tags_list.extend(g_addendum_chip_data.count());

    for i in 1 .. g_addendum_chip_data.count() loop
        -- List of EMV tags that should be retrieved from auth EMV data for saving to
        -- Chip card addendum, every tag is associated with data type (empty data type
        -- is thought as HEX), for numeric tags lengths are also defined
        l_data_format := case g_addendum_chip_data(i).format
                             when 'N'    then com_api_const_pkg.DATA_TYPE_NUMBER
                                           || g_addendum_chip_data(i).field_length
                             when 'CHAR' then com_api_const_pkg.DATA_TYPE_CHAR
                             when 'AN'   then com_api_const_pkg.DATA_TYPE_CHAR
                             when 'HEX'  then ''
                         end;

        --trc_log_pkg.debug('l_data_format [' || l_data_format || ']');

        g_emv_tags_list(i) := com_name_pair_tpr(g_addendum_chip_data(i).emv_tag, l_data_format);
    end loop;

    trc_log_pkg.debug(
        i_text       => lower($$PLSQL_UNIT) || '~initialization Finish g_emv_tags_list.count() = #1'
      , i_env_param1 => g_emv_tags_list.count()
    );
end;
/
