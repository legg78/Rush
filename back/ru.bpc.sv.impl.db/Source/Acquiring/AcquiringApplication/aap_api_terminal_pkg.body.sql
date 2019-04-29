create or replace package body aap_api_terminal_pkg as
/*********************************************************
 *  Application Terminals API  <br />
 *  Created by Filimonov A.(filimonov@bpcbt.com)  at 03.09.2009 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: aap_api_terminal_pkg <br />
 *  @headcom
 **********************************************************/
g_cud_codes             aap_api_type_pkg.t_cud_codes;
g_address_error_raised  com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE;
g_template_id           com_api_type_pkg.t_long_id;

procedure get_appl_data(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , o_terminal                out nocopy aap_api_type_pkg.t_terminal
) is
    l_appl_data_id         com_api_type_pkg.t_long_id;
    l_appl_data_rec        app_api_type_pkg.t_appl_data_rec;
begin
    trc_log_pkg.debug('aap_terminal_pkg.get_appl_data START');

    app_api_application_pkg.get_element_value(
        i_element_name   => 'MCC'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_terminal.mcc
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'TERMINAL_NUMBER'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_terminal.terminal_number
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'TERMINAL_TYPE'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_terminal.terminal_type
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'STANDARD_ID'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_terminal.standard_id
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'VERSION_ID'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_terminal.version_id
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'PLASTIC_NUMBER'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_terminal.plastic_number
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'CARD_DATA_INPUT_CAP'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_terminal.card_data_input_cap
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'CRDH_AUTH_CAP'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_terminal.crdh_auth_cap
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'CARD_CAPTURE_CAP'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_terminal.card_capture_cap
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'TERM_OPERATING_ENV'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_terminal.term_operating_env
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'CRDH_DATA_PRESENT'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_terminal.crdh_data_present
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'CARD_DATA_PRESENT'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_terminal.card_data_present
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'CARD_DATA_INPUT_MODE'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_terminal.card_data_input_mode
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'CRDH_AUTH_METHOD'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_terminal.crdh_auth_method
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'CRDH_AUTH_ENTITY'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_terminal.crdh_auth_entity
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'CARD_DATA_OUTPUT_CAP'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_terminal.card_data_output_cap
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'TERM_DATA_OUTPUT_CAP'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_terminal.term_data_output_cap
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'PIN_CAPTURE_CAP'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_terminal.pin_capture_cap
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'PIN_CAPTURE_CAP'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_terminal.pin_capture_cap
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'CAT_LEVEL'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_terminal.cat_level
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'DEVICE_ID'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_terminal.device_id
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'IS_MAC'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_terminal.is_mac
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'GMT_OFFSET'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_terminal.gmt_offset
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'TERMINAL_TEMPLATE'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_terminal.terminal_template
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'TERMINAL_STATUS'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_terminal.status
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'STATUS_REASON'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_terminal.status_reason
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'CASH_DISPENSER_PRESENT'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_terminal.cash_dispenser_present
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'PAYMENT_POSSIBILITY'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_terminal.payment_possibility
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'USE_CARD_POSSIBILITY'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_terminal.use_card_possibility
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'CASH_IN_PRESENT'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_terminal.cash_in_present
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'AVAILABLE_NETWORK'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_terminal.available_network
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'AVAILABLE_OPERATION'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_terminal.available_operation
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'AVAILABLE_CURRENCY'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_terminal.available_currency
    );

    app_api_application_pkg.get_appl_data_id(
        i_element_name   => 'APPLICATION'
      , i_parent_id      => null
      , o_appl_data_id   => l_appl_data_id
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'INSTITUTION_ID'
      , i_parent_id      => l_appl_data_id
      , o_element_value  => o_terminal.inst_id
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'MCC_TEMPLATE_ID'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_terminal.mcc_template_id
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'TERMINAL_PROFILE'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_terminal.terminal_profile
    );
    
    app_api_application_pkg.get_element_value(
        i_element_name   => 'PIN_BLOCK_FORMAT'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_terminal.pin_block_format
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'POS_BATCH_SUPPORT'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_terminal.pos_batch_support
    );

    trc_log_pkg.debug('aap_terminal_pkg.get_appl_data END');

exception
    when com_api_error_pkg.e_value_error or com_api_error_pkg.e_invalid_number then
        l_appl_data_rec := app_api_application_pkg.get_last_appl_data_rec(); -- receive data of last processed element
        app_api_error_pkg.raise_error(
            i_appl_data_id => i_appl_data_id
          , i_error        => 'INCORRECT_ELEMENT_VALUE'
          , i_env_param1   => l_appl_data_rec.element_value
          , i_env_param2   => l_appl_data_rec.element_name
          , i_env_param3   => l_appl_data_rec.data_type
          , i_env_param4   => l_appl_data_rec.parent_id
          , i_env_param5   => l_appl_data_rec.element_type
          , i_env_param6   => l_appl_data_rec.serial_number
          , i_element_name => l_appl_data_rec.element_name
        );
end get_appl_data;

procedure get_product_id(
    i_parent_id            in            com_api_type_pkg.t_short_id
  , o_product_id              out nocopy com_api_type_pkg.t_short_id
) is
    cursor cu_merchants is
    select product_id
    from (select c.product_id, m.id, m.parent_id
          from acq_merchant_vw m, prd_contract_vw c
          where m.contract_id = c.id) x
    where product_id is not null
    connect by prior id = parent_id
    start with id = i_parent_id;
begin
    open cu_merchants;
    fetch cu_merchants into o_product_id;
    close cu_merchants;
end;

procedure set_val(
    i_element_name         in            com_api_type_pkg.t_name
  , io_value               in out nocopy varchar2
  , i_template_value       in            varchar2
  , i_appl_data_id         in            com_api_type_pkg.t_long_id
) is
    l_value_date           date;
    l_value_num            number;
begin
    app_api_application_pkg.set_value(
        i_element_name    => i_element_name
      , io_value_char     => io_value
      , io_value_date     => l_value_date
      , io_value_num      => l_value_num
      , i_template_value  => i_template_value
      , i_appl_data_id    => i_appl_data_id
    );
end;

procedure set_val(
    i_element_name         in            com_api_type_pkg.t_name
  , io_value               in out nocopy date
  , i_template_value       in            date
  , i_appl_data_id         in            com_api_type_pkg.t_long_id
) is
    l_value_char           com_api_type_pkg.t_name;
    l_value_num            number;
begin
    app_api_application_pkg.set_value(
        i_element_name    => i_element_name
      , io_value_date     => io_value
      , io_value_char     => l_value_char
      , io_value_num      => l_value_num
      , i_template_value  => to_char(i_template_value, get_date_format)
      , i_appl_data_id    => i_appl_data_id
    );
end;

procedure set_val(
    i_element_name         in            com_api_type_pkg.t_name
  , io_value               in out nocopy number
  , i_template_value       in            number
  , i_appl_data_id         in            com_api_type_pkg.t_long_id
) is
    l_value_char           com_api_type_pkg.t_name;
    l_value_date           date;
begin
    app_api_application_pkg.set_value(
        i_element_name    => i_element_name
      , io_value_date     => l_value_date
      , io_value_char     => l_value_char
      , io_value_num      => io_value
      , i_template_value  => to_char(i_template_value, get_number_format)
      , i_appl_data_id    => i_appl_data_id
    );
end;    

procedure fill_terminal_from_template(
    io_term                in out nocopy aap_api_type_pkg.t_terminal
  , i_appl_data_id         in            com_api_type_pkg.t_long_id
) is
    l_id                   com_api_type_pkg.t_long_id;
    l_templ                aap_api_type_pkg.t_terminal;
begin
    if io_term.terminal_template is null then
        return;
    end if;

    select t.id
         , t.is_template
         , (select s.standard_id from cmn_standard_object s
             where s.entity_type = acq_api_const_pkg.ENTITY_TYPE_TERMINAL and s.object_id = t.id) standard_id
         , (select s.version_id from cmn_standard_version_obj s
             where s.entity_type = acq_api_const_pkg.ENTITY_TYPE_TERMINAL and s.object_id = t.id) version_id
         , t.terminal_number
         , t.terminal_type
         , t.merchant_id
         , t.plastic_number
         , t.card_data_input_cap
         , t.crdh_auth_cap
         , t.card_capture_cap
         , t.term_operating_env
         , t.crdh_data_present
         , t.card_data_present
         , t.card_data_input_mode
         , t.crdh_auth_method
         , t.crdh_auth_entity
         , t.card_data_output_cap
         , t.term_data_output_cap
         , t.pin_capture_cap
         , t.cat_level
         , t.status
         , t.inst_id
         , t.is_mac
         , t.gmt_offset
         , t.cash_dispenser_present
         , t.payment_possibility
         , t.use_card_possibility
         , t.cash_in_present
         , t.available_network
         , t.available_operation
         , t.available_currency
         , t.mcc_template_id
         , t.terminal_profile
         , t.pin_block_format
    into   g_template_id
         , l_templ.is_template
         , l_templ.standard_id
         , l_templ.version_id
         , l_templ.terminal_number
         , l_templ.terminal_type
         , l_templ.merchant_id
         , l_templ.plastic_number
         , l_templ.card_data_input_cap
         , l_templ.crdh_auth_cap
         , l_templ.card_capture_cap
         , l_templ.term_operating_env
         , l_templ.crdh_data_present
         , l_templ.card_data_present
         , l_templ.card_data_input_mode
         , l_templ.crdh_auth_method
         , l_templ.crdh_auth_entity
         , l_templ.card_data_output_cap
         , l_templ.term_data_output_cap
         , l_templ.pin_capture_cap
         , l_templ.cat_level
         , l_templ.status
         , l_templ.inst_id
         , l_templ.is_mac
         , l_templ.gmt_offset
         , l_templ.cash_dispenser_present
         , l_templ.payment_possibility
         , l_templ.use_card_possibility
         , l_templ.cash_in_present
         , l_templ.available_network
         , l_templ.available_operation
         , l_templ.available_currency
         , l_templ.mcc_template_id
         , l_templ.terminal_profile
         , l_templ.pin_block_format
      from acq_terminal t
     where id            = io_term.terminal_template
       and terminal_type = io_term.terminal_type
       and is_template   = com_api_type_pkg.true;

    io_term.is_template   := com_api_type_pkg.false;
    l_id                  := i_appl_data_id;

    set_val('CARD_DATA_INPUT_CAP',   io_term.card_data_input_cap,   l_templ.card_data_input_cap,   l_id);
    set_val('CRDH_AUTH_CAP',         io_term.crdh_auth_cap,         l_templ.crdh_auth_cap,         l_id);
    set_val('CARD_CAPTURE_CAP',      io_term.card_capture_cap ,     l_templ.card_capture_cap,      l_id);
    set_val('TERM_OPERATING_ENV',    io_term.term_operating_env,    l_templ.term_operating_env,    l_id);
    set_val('CRDH_DATA_PRESENT',     io_term.crdh_data_present,     l_templ.crdh_data_present,     l_id);
    set_val('CARD_DATA_PRESENT',     io_term.card_data_present,     l_templ.card_data_present,     l_id);
    set_val('CARD_DATA_INPUT_MODE',  io_term.card_data_input_mode,  l_templ.card_data_input_mode,  l_id);
    set_val('CRDH_AUTH_METHOD',      io_term.crdh_auth_method,      l_templ.crdh_auth_method,      l_id);
    set_val('CRDH_AUTH_ENTITY',      io_term.crdh_auth_entity,      l_templ.crdh_auth_entity,      l_id);
    set_val('CARD_DATA_OUTPUT_CAP',  io_term.card_data_output_cap,  l_templ.card_data_output_cap,  l_id);
    set_val('TERM_DATA_OUTPUT_CAP',  io_term.term_data_output_cap,  l_templ.term_data_output_cap,  l_id);
    set_val('PIN_CAPTURE_CAP',       io_term.pin_capture_cap,       l_templ.pin_capture_cap,       l_id);
    set_val('CAT_LEVEL',             io_term.cat_level,             l_templ.cat_level,             l_id);
    set_val('IS_MAC',                io_term.is_mac,                l_templ.is_mac,                l_id);
    set_val('TERMINAL_STATUS',       io_term.status,                l_templ.status,                l_id);
    set_val('GMT_OFFSET',            io_term.gmt_offset,            l_templ.gmt_offset,            l_id);
    set_val('STANDARD_ID',           io_term.standard_id,           l_templ.standard_id,           l_id);
    set_val('VERSION_ID',            io_term.version_id,            l_templ.version_id,            l_id);
    set_val('CASH_DISPENSER_PRESENT',io_term.cash_dispenser_present,l_templ.cash_dispenser_present,l_id);
    set_val('PAYMENT_POSSIBILITY',   io_term.payment_possibility,   l_templ.payment_possibility,   l_id);
    set_val('USE_CARD_POSSIBILITY',  io_term.use_card_possibility,  l_templ.use_card_possibility,  l_id);
    set_val('CASH_IN_PRESENT',       io_term.cash_in_present,       l_templ.cash_in_present,       l_id);
    set_val('AVAILABLE_NETWORK',     io_term.available_network,     l_templ.available_network,     l_id);
    set_val('AVAILABLE_OPERATION',   io_term.available_operation,   l_templ.available_operation,   l_id);
    set_val('AVAILABLE_CURRENCY',    io_term.available_currency,    l_templ.available_currency,    l_id);
    set_val('MCC_TEMPLATE_ID',       io_term.mcc_template_id,       l_templ.mcc_template_id,       l_id);
    set_val('TERMINAL_PROFILE',      io_term.terminal_profile,      l_templ.terminal_profile,      l_id);
    set_val('PIN_BLOCK_FORMAT',      io_term.pin_block_format,      l_templ.pin_block_format,      l_id);
    
    trc_log_pkg.debug(
        i_text       => 'l_templ.terminal_profile [' || io_term.terminal_profile || ']'
    );
    trc_log_pkg.debug(
        i_text       => 'io_term.card_data_present [' || io_term.card_data_present || ']'
    );
    
exception
    when no_data_found then
        com_api_error_pkg.raise_error(
            i_error        => 'TEMPLATE_NOT_FOUND'
          , i_env_param1   => io_term.terminal_template
          , i_env_param2   => io_term.terminal_type
        );
end;

function get_terminal_id return com_api_type_pkg.t_short_id is
begin
    return acq_terminal_seq.nextval;
end;

procedure check_imprinter_num(
    i_plastic_number       in            com_api_type_pkg.t_card_number
  , i_inst_id              in            com_api_type_pkg.t_inst_id
  , i_appl_data_id         in            com_api_type_pkg.t_long_id
) is
    l_count             com_api_type_pkg.t_count := 0;
begin
    select count(id)
      into l_count
      from acq_terminal_vw
     where plastic_number = i_plastic_number
       and inst_id        = i_inst_id;

    if l_count > 0 then
        com_api_error_pkg.raise_error(
            i_error             => 'PLASTIC_NUMBER_NOT_UNIQUE'
          , i_env_param1        => i_plastic_number
          , i_env_param2        => i_inst_id
        );
    end if;
end;

procedure process_pos_terminal(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_terminal_id          in            com_api_type_pkg.t_short_id
  , i_pos_batch_method     in            com_api_type_pkg.t_dict_value
  , i_partial_approval     in            com_api_type_pkg.t_short_id
  , i_purchase_amount      in            com_api_type_pkg.t_short_id
  , i_instalment_support   in            com_api_type_pkg.t_boolean         default null
) is
    l_count                 com_api_type_pkg.t_short_id;
    l_pos_batch_id          com_api_type_pkg.t_medium_id;
begin
    trc_log_pkg.debug('process_pos_terminal: id=' || i_terminal_id);

    select count(t.id)
      into l_count
      from pos_terminal t
     where t.id = i_terminal_id;
    
    if l_count = 0 then
        insert into pos_batch(
            id
          , status
          , open_date
          , open_auth_id
        ) values (
            pos_batch_seq.nextval
          , pos_api_const_pkg.POS_BATCH_STATUS_OPENED
          , com_api_sttl_day_pkg.get_sysdate
          , 0
        ) returning id into l_pos_batch_id;
        
        insert into pos_terminal(
            id
          , current_batch_id
          , pos_batch_method
          , partial_approval
          , purchase_amount
          , instalment_support
        ) values (
            i_terminal_id
          , l_pos_batch_id
          , i_pos_batch_method
          , i_partial_approval
          , i_purchase_amount
          , i_instalment_support
        );
        
        trc_log_pkg.debug('insert pos terminal: id=' || i_terminal_id);
    else
        update pos_terminal
           set pos_batch_method   = nvl(i_pos_batch_method, pos_batch_method)
             , partial_approval   = nvl(i_partial_approval, partial_approval)
             , purchase_amount    = nvl(i_purchase_amount, purchase_amount)
             , instalment_support = nvl(i_instalment_support, instalment_support)
         where id = i_terminal_id;
    end if;    
end;

procedure process_atm_dispenser(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_terminal_id          in            com_api_type_pkg.t_short_id
  , i_cassette_count       in            com_api_type_pkg.t_tiny_id
  , i_hopper_count         in            com_api_type_pkg.t_tiny_id
) is
    LOG_PREFIX    constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_atm_dispenser: ';
    type t_disp_tab        is table of aap_api_type_pkg.t_dispenser;
    l_disp                 t_disp_tab := t_disp_tab();
    l_id_tab               com_api_type_pkg.t_number_tab;
    l_fact_cassette_count  com_api_type_pkg.t_count   := 0;
    l_fact_hopper_count    com_api_type_pkg.t_count   := 0;
begin
    trc_log_pkg.debug(LOG_PREFIX || 'START with i_terminal_id [' || i_terminal_id
                                 || '], i_cassette_count [' || i_cassette_count
                                 || '], i_hopper_count [' || i_hopper_count || ']');

    app_api_application_pkg.get_appl_data_id(
        i_element_name  => 'ATM_DISPENSER'
      , i_parent_id     => i_appl_data_id
      , o_appl_data_id  => l_id_tab
    );

    trc_log_pkg.debug('nvl(l_id_tab.count, 0) = '||nvl(l_id_tab.count, 0));

    for i in 1..nvl(l_id_tab.count, 0) loop
        if nvl(l_disp.count,0) < i then l_disp.extend; end if;

        app_api_application_pkg.get_element_value(
            i_element_name   => 'DISP_NUMBER'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_disp(i).disp_number
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'FACE_VALUE'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_disp(i).face_value
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'CURRENCY'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_disp(i).currency
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'DENOMINATION_ID'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_disp(i).denomination_id
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'DISPENSER_TYPE'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_disp(i).dispenser_type
        );
    end loop;

    if nvl(l_disp.count, 0) = 0 then
        for r in (
            select row_number() over(order by id) i
                 , disp_number
                 , face_value
                 , currency
                 , denomination_id
                 , dispenser_type
              from atm_dispenser
             where terminal_id = g_template_id
             order by id
        ) loop
            trc_log_pkg.debug('template found, id='||g_template_id||', i='||r.i||', l_disp.count='||l_disp.count);

            if not l_disp.exists(r.i) then
                app_api_application_pkg.add_element(
                    i_element_name   => 'ATM_DISPENSER'
                  , i_parent_id      => i_appl_data_id
                  , i_element_value  => to_number(null)
                );

                l_id_tab.delete();
                app_api_application_pkg.get_appl_data_id(
                    i_element_name  => 'ATM_DISPENSER'
                  , i_parent_id     => i_appl_data_id
                  , o_appl_data_id  => l_id_tab
                );
                l_disp.extend;
                trc_log_pkg.debug('l_disp.count='||l_disp.count);
            end if;

            set_val('DISP_NUMBER',     l_disp(r.i).disp_number,     r.disp_number,     l_id_tab(r.i));
            set_val('FACE_VALUE',      l_disp(r.i).face_value,      r.face_value,      l_id_tab(r.i));
            set_val('CURRENCY',        l_disp(r.i).currency,        r.currency,        l_id_tab(r.i));
            set_val('DENOMINATION_ID', l_disp(r.i).denomination_id, r.denomination_id, l_id_tab(r.i));
            set_val('DISPENSER_TYPE',  l_disp(r.i).dispenser_type,  r.dispenser_type,  l_id_tab(r.i));
        end loop;
    end if;

    for i in 1..nvl(l_disp.count, 0) loop
        for j in 1..nvl(l_disp.count,0) loop
            if i<>j and l_disp(i).disp_number = l_disp(j).disp_number then
                com_api_error_pkg.raise_error(
                    i_error        => 'DISPENSER_NUMBER_IS_NOT_UNIQUE'
                  , i_env_param1   => l_disp(i).disp_number
                );
            end if;
        end loop;
    end loop;

    for i in 1..nvl(l_disp.count, 0) loop
        case l_disp(i).dispenser_type
        when acq_api_const_pkg.DISPENSER_TYPE_CASSETTE then l_fact_cassette_count := l_fact_cassette_count + 1;
        when acq_api_const_pkg.DISPENSER_TYPE_HOPPER   then l_fact_hopper_count   := l_fact_hopper_count   + 1;
        else null;
        end case;
    end loop;

    if nvl(l_fact_cassette_count, 0) != nvl(i_cassette_count, 0) then
        com_api_error_pkg.raise_error(
            i_error         => 'BAD_CASSETTE_COUNT'
          , i_env_param1    => l_fact_cassette_count
          , i_env_param2    => i_cassette_count
        );
    end if;

    if nvl(l_fact_hopper_count, 0) != nvl(i_hopper_count, 0) then
        com_api_error_pkg.raise_error(
            i_error         => 'BAD_HOPPER_COUNT'
          , i_env_param1    => l_fact_hopper_count
          , i_env_param2    => i_hopper_count
        );
    end if;

    for i in 1..nvl(l_disp.count, 0) loop
        select min(id)
          into l_disp(i).id
          from atm_dispenser
         where terminal_id = i_terminal_id
           and disp_number = l_disp(i).disp_number;

        if l_disp(i).id is null then
            atm_api_dispenser_pkg.add_dispenser(
                o_id              => l_disp(i).id
              , i_terminal_id     => i_terminal_id
              , i_disp_number     => l_disp(i).disp_number
              , i_face_value      => l_disp(i).face_value
              , i_currency        => l_disp(i).currency
              , i_denomination_id => l_disp(i).denomination_id
              , i_dispenser_type  => l_disp(i).dispenser_type
            );
        else
            atm_api_dispenser_pkg.modify_dispenser(
                i_id              => l_disp(i).id
              , i_terminal_id     => i_terminal_id
              , i_disp_number     => l_disp(i).disp_number
              , i_face_value      => l_disp(i).face_value
              , i_currency        => l_disp(i).currency
              , i_denomination_id => l_disp(i).denomination_id
              , i_dispenser_type  => l_disp(i).dispenser_type
            );
        end if;
    end loop;
    
    trc_log_pkg.debug(LOG_PREFIX || 'END');
end;

procedure process_atm_terminal(
    i_parent_appl_data_id  in            com_api_type_pkg.t_long_id
  , i_terminal_id          in            com_api_type_pkg.t_short_id
) is
    l_atm                  aap_api_type_pkg.t_atm_terminal;
    l_count                com_api_type_pkg.t_tiny_id;
    l_old_type             com_api_type_pkg.t_dict_value;
    l_id                   com_api_type_pkg.t_long_id;
begin
    app_api_application_pkg.get_appl_data_id(
        i_element_name  => 'ATM_TERMINAL'
      , i_parent_id     => i_parent_appl_data_id
      , o_appl_data_id  => l_id
    );

    trc_log_pkg.debug('process_atm_terminal, l_id='||l_id);

    if l_id is not null then
        app_api_application_pkg.get_element_value(
            i_element_name   => 'ATM_TYPE'
          , i_parent_id      => l_id
          , o_element_value  => l_atm.atm_type
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'ATM_MODEL'
          , i_parent_id      => l_id
          , o_element_value  => l_atm.atm_model
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'SERIAL_NUMBER'
          , i_parent_id      => l_id
          , o_element_value  => l_atm.serial_number
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'PLACEMENT_TYPE'
          , i_parent_id      => l_id
          , o_element_value  => l_atm.placement_type
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'AVAILABILITY_TYPE'
          , i_parent_id      => l_id
          , o_element_value  => l_atm.availability_type
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'OPERATING_HOURS'
          , i_parent_id      => l_id
          , o_element_value  => l_atm.operating_hours
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'LOCAL_DATE_GAP'
          , i_parent_id      => l_id
          , o_element_value  => l_atm.local_date_gap
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'CASSETTE_COUNT'
          , i_parent_id      => l_id
          , o_element_value  => l_atm.cassette_count
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'HOPPER_COUNT'
          , i_parent_id      => l_id
          , o_element_value  => l_atm.hopper_count
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'KEY_CHANGE_ALGORITHM'
          , i_parent_id      => l_id
          , o_element_value  => l_atm.key_change_algo
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'COUNTER_SYNC_COND'
          , i_parent_id      => l_id
          , o_element_value  => l_atm.counter_sync_cond
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'REJECT_DISP_WARN'
          , i_parent_id      => l_id
          , o_element_value  => l_atm.reject_disp_warn
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'DISP_REST_WARN'
          , i_parent_id      => l_id
          , o_element_value  => l_atm.disp_rest_warn
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'RECEIPT_WARN'
          , i_parent_id      => l_id
          , o_element_value  => l_atm.receipt_warn
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'CARD_CAPTURE_WARN'
          , i_parent_id      => l_id
          , o_element_value  => l_atm.card_capture_warn
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'NOTE_MAX_COUNT'
          , i_parent_id      => l_id
          , o_element_value  => l_atm.note_max_count
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'SCENARIO_ID'
          , i_parent_id      => l_id
          , o_element_value  => l_atm.scenario_id
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'MANUAL_SYNCH'
          , i_parent_id      => l_id
          , o_element_value  => l_atm.manual_synch
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'ESTABL_CONN_SYNCH'
          , i_parent_id      => l_id
          , o_element_value  => l_atm.establ_conn_synch
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'COUNTER_MISMATCH_SYNCH'
          , i_parent_id      => l_id
          , o_element_value  => l_atm.counter_mismatch_synch
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'ONLINE_IN_SYNCH'
          , i_parent_id      => l_id
          , o_element_value  => l_atm.online_in_synch
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'ONLINE_OUT_SYNCH'
          , i_parent_id      => l_id
          , o_element_value  => l_atm.online_out_synch
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'SAFE_CLOSE_SYNCH'
          , i_parent_id      => l_id
          , o_element_value  => l_atm.safe_close_synch
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'DISP_ERROR_SYNCH'
          , i_parent_id      => l_id
          , o_element_value  => l_atm.disp_error_synch
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'PERIODIC_SYNCH'
          , i_parent_id      => l_id
          , o_element_value  => l_atm.periodic_synch
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'PERIODIC_ALL_OPER'
          , i_parent_id      => l_id
          , o_element_value  => l_atm.periodic_all_oper
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'PERIODIC_OPER_COUNT'
          , i_parent_id      => l_id
          , o_element_value  => l_atm.periodic_oper_count
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'REJECT_DISP_MIN_WARN'
          , i_parent_id      => l_id
          , o_element_value  => l_atm.reject_disp_min_warn
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'CASH_IN_MIN_WARN'
          , i_parent_id      => l_id
          , o_element_value  => l_atm.cash_in_min_warn
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'CASH_IN_MAX_WARN'
          , i_parent_id      => l_id
          , o_element_value  => l_atm.cash_in_max_warn
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'CASH_IN_PRESENT'
          , i_parent_id      => i_parent_appl_data_id
          , o_element_value  => l_atm.cash_in_present
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'POWERUP_SERVICE'
          , i_parent_id      => l_id
          , o_element_value  => l_atm.powerup_service
        );
        app_api_application_pkg.get_element_value(
            i_element_name   => 'SUPERVISOR_SERVICE'
          , i_parent_id      => l_id
          , o_element_value  => l_atm.supervisor_service
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'DISPENSE_ALGO'
          , i_parent_id      => l_id
          , o_element_value  => l_atm.dispense_algo
        );
    end if;

    declare
        l_templ    aap_api_type_pkg.t_atm_terminal;
    begin
        select atm_type
             , atm_model
             , serial_number
             , placement_type
             , availability_type
             , operating_hours
             , local_date_gap
             , cassette_count
             , key_change_algo
             , counter_sync_cond
             , reject_disp_warn
             , disp_rest_warn
             , receipt_warn
             , card_capture_warn
             , note_max_count
             , scenario_id
             , hopper_count
             , manual_synch
             , establ_conn_synch
             , counter_mismatch_synch
             , online_in_synch
             , online_out_synch
             , safe_close_synch
             , disp_error_synch
             , periodic_synch
             , periodic_all_oper
             , periodic_oper_count
             , reject_disp_min_warn
             , cash_in_present
             , cash_in_min_warn
             , cash_in_max_warn
             , powerup_service
             , supervisor_service
             , dispense_algo
          into l_templ.atm_type
             , l_templ.atm_model
             , l_templ.serial_number
             , l_templ.placement_type
             , l_templ.availability_type
             , l_templ.operating_hours
             , l_templ.local_date_gap
             , l_templ.cassette_count
             , l_templ.key_change_algo
             , l_templ.counter_sync_cond
             , l_templ.reject_disp_warn
             , l_templ.disp_rest_warn
             , l_templ.receipt_warn
             , l_templ.card_capture_warn
             , l_templ.note_max_count
             , l_templ.scenario_id
             , l_templ.hopper_count
             , l_templ.manual_synch
             , l_templ.establ_conn_synch
             , l_templ.counter_mismatch_synch
             , l_templ.online_in_synch
             , l_templ.online_out_synch
             , l_templ.safe_close_synch
             , l_templ.disp_error_synch
             , l_templ.periodic_synch
             , l_templ.periodic_all_oper
             , l_templ.periodic_oper_count
             , l_templ.reject_disp_min_warn
             , l_templ.cash_in_present
             , l_templ.cash_in_min_warn
             , l_templ.cash_in_max_warn
             , l_templ.powerup_service
             , l_templ.supervisor_service
             , l_templ.dispense_algo
          from atm_terminal
         where id = g_template_id;

        if l_id is null then
            app_api_application_pkg.add_element(
                i_element_name   => 'ATM_TERMINAL'
              , i_parent_id      => i_parent_appl_data_id
              , i_element_value  => to_number(null)
            );
            app_api_application_pkg.get_appl_data_id(
                i_element_name  => 'ATM_TERMINAL'
              , i_parent_id     => i_parent_appl_data_id
              , o_appl_data_id  => l_id
            );
        end if;

        set_val('ATM_TYPE',              l_atm.atm_type,              l_templ.atm_type,              l_id);
        set_val('ATM_MODEL',             l_atm.atm_model,             l_templ.atm_model,             l_id);
        set_val('SERIAL_NUMBER',         l_atm.serial_number,         l_templ.serial_number,         l_id);
        set_val('PLACEMENT_TYPE',        l_atm.placement_type,        l_templ.placement_type,        l_id);
        set_val('AVAILABILITY_TYPE',     l_atm.availability_type,     l_templ.availability_type,     l_id);
        set_val('OPERATING_HOURS',       l_atm.operating_hours,       l_templ.operating_hours,       l_id);
        set_val('LOCAL_DATE_GAP',        l_atm.local_date_gap,        l_templ.local_date_gap,        l_id);
        set_val('CASSETTE_COUNT',        l_atm.cassette_count,        l_templ.cassette_count,        l_id);
        set_val('KEY_CHANGE_ALGORITHM',  l_atm.key_change_algo,       l_templ.key_change_algo,       l_id);
        set_val('COUNTER_SYNC_COND',     l_atm.counter_sync_cond,     l_templ.counter_sync_cond,     l_id);
        set_val('REJECT_DISP_WARN',      l_atm.reject_disp_warn,      l_templ.reject_disp_warn,      l_id);
        set_val('DISP_REST_WARN',        l_atm.disp_rest_warn,        l_templ.disp_rest_warn,        l_id);
        set_val('RECEIPT_WARN',          l_atm.receipt_warn,          l_templ.receipt_warn,          l_id);
        set_val('CARD_CAPTURE_WARN',     l_atm.card_capture_warn,     l_templ.card_capture_warn,     l_id);
        set_val('NOTE_MAX_COUNT',        l_atm.note_max_count  ,      l_templ.note_max_count,        l_id);
        set_val('SCENARIO_ID',           l_atm.scenario_id,           l_templ.scenario_id,           l_id);
        set_val('HOPPER_COUNT',          l_atm.hopper_count,          l_templ.hopper_count,          l_id);
        set_val('MANUAL_SYNCH',          l_atm.manual_synch,          l_templ.manual_synch,          l_id);
        set_val('ESTABL_CONN_SYNCH',     l_atm.establ_conn_synch,     l_templ.establ_conn_synch,     l_id);
        set_val('COUNTER_MISMATCH_SYNCH',l_atm.counter_mismatch_synch,l_templ.counter_mismatch_synch,l_id);
        set_val('ONLINE_IN_SYNCH',       l_atm.online_in_synch,       l_templ.online_in_synch,       l_id);
        set_val('ONLINE_OUT_SYNCH',      l_atm.online_out_synch,      l_templ.online_out_synch,      l_id);
        set_val('SAFE_CLOSE_SYNCH',      l_atm.safe_close_synch,      l_templ.safe_close_synch,      l_id);
        set_val('DISP_ERROR_SYNCH',      l_atm.disp_error_synch,      l_templ.disp_error_synch,      l_id);
        set_val('PERIODIC_SYNCH',        l_atm.periodic_synch,        l_templ.periodic_synch,        l_id);
        set_val('PERIODIC_ALL_OPER',     l_atm.periodic_all_oper,     l_templ.periodic_all_oper,     l_id);
        set_val('PERIODIC_OPER_COUNT',   l_atm.periodic_oper_count,   l_templ.periodic_oper_count,   l_id);
        set_val('REJECT_DISP_MIN_WARN',  l_atm.reject_disp_min_warn,  l_templ.reject_disp_min_warn,  l_id);
        set_val('CASH_IN_MIN_WARN',      l_atm.cash_in_min_warn,      l_templ.cash_in_min_warn,      l_id);
        set_val('CASH_IN_MAX_WARN',      l_atm.cash_in_max_warn,      l_templ.cash_in_max_warn,      l_id);
        set_val('CASH_IN_PRESENT',       l_atm.cash_in_present,       l_templ.cash_in_present,       i_parent_appl_data_id);
        set_val('POWERUP_SERVICE',       l_atm.powerup_service,       l_templ.powerup_service,       l_id);
        set_val('SUPERVISOR_SERVICE',    l_atm.supervisor_service,    l_templ.supervisor_service,    l_id);
        set_val('DISPENSE_ALGO',         l_atm.dispense_algo,         l_templ.dispense_algo,         l_id);

    exception
        when no_data_found then
            null;
    end;

    if l_id is null then
        return;
    end if;

    select count(id) cnt
         , min(atm_type) atm_type
      into l_count
         , l_old_type
      from atm_terminal_vw
     where id = i_terminal_id;

    if l_count = 0 and l_id is not null then
        atm_api_terminal_pkg.add_terminal(
            i_terminal_id            => i_terminal_id
          , i_atm_type               => l_atm.atm_type
          , i_atm_model              => l_atm.atm_model
          , i_serial_number          => l_atm.serial_number
          , i_placement_type         => l_atm.placement_type
          , i_availability_type      => l_atm.availability_type
          , i_operating_hours        => l_atm.operating_hours
          , i_local_date_gap         => l_atm.local_date_gap
          , i_cassette_count         => l_atm.cassette_count
          , i_key_change_algo        => l_atm.key_change_algo
          , i_counter_sync_cond      => l_atm.counter_sync_cond
          , i_reject_disp_warn       => l_atm.reject_disp_warn
          , i_disp_rest_warn         => l_atm.disp_rest_warn
          , i_receipt_warn           => l_atm.receipt_warn
          , i_card_capture_warn      => l_atm.card_capture_warn
          , i_note_max_count         => l_atm.note_max_count
          , i_scenario_id            => l_atm.scenario_id
          , i_hopper_count           => l_atm.hopper_count
          , i_manual_synch           => l_atm.manual_synch
          , i_establ_conn_synch      => l_atm.establ_conn_synch
          , i_counter_mismatch_synch => l_atm.counter_mismatch_synch
          , i_online_in_synch        => l_atm.online_in_synch
          , i_online_out_synch       => l_atm.online_out_synch
          , i_safe_close_synch       => l_atm.safe_close_synch
          , i_disp_error_synch       => l_atm.disp_error_synch
          , i_periodic_synch         => l_atm.periodic_synch
          , i_periodic_all_oper      => l_atm.periodic_all_oper
          , i_periodic_oper_count    => l_atm.periodic_oper_count
          , i_reject_disp_min_warn   => l_atm.reject_disp_min_warn
          , i_cash_in_present        => l_atm.cash_in_present
          , i_cash_in_min_warn       => l_atm.cash_in_min_warn
          , i_cash_in_max_warn       => l_atm.cash_in_max_warn
          , i_powerup_service        => l_atm.powerup_service
          , i_supervisor_service     => l_atm.supervisor_service
          , i_dispense_algo          => l_atm.dispense_algo
        );

        atm_api_terminal_pkg.set_terminal_dynamic(
            i_id                     => i_terminal_id
          , i_coll_id                => null
          , i_coll_oper_count        => 0
          , i_last_oper_id           => null
          , i_last_oper_date         => null
          , i_receipt_loaded         => 0
          , i_receipt_printed        => 0
          , i_receipt_remained       => 0
          , i_card_captured          => 0
          , i_card_reader_status     => null
          , i_rcpt_status            => null
          , i_rcpt_paper_status      => null
          , i_rcpt_ribbon_status     => null
          , i_rcpt_head_status       => null
          , i_rcpt_knife_status      => null
          , i_jrnl_status            => null
          , i_jrnl_paper_status      => null
          , i_jrnl_ribbon_status     => null
          , i_jrnl_head_status       => null
          , i_ejrnl_status           => null
          , i_ejrnl_space_status     => null
          , i_stmt_status            => null
          , i_stmt_paper_status      => null
          , i_stmt_ribbon_stat       => null
          , i_stmt_head_status       => null
          , i_stmt_knife_status      => null
          , i_stmt_capt_bin_status   => null
          , i_tod_clock_status       => null
          , i_depository_status      => null
          , i_night_safe_status      => null
          , i_encryptor_status       => null
          , i_tscreen_keyb_status    => null
          , i_voice_guidance_status  => null
          , i_camera_status          => null
          , i_bunch_acpt_status      => null
          , i_envelope_disp_status   => null
          , i_cheque_module_status   => null
          , i_barcode_reader_status  => null
          , i_coin_disp_status       => null
          , i_dispenser_status       => null
          , i_workflow_status        => null
          , i_service_status         => null
        );
    else
        atm_api_terminal_pkg.modify_terminal(
            i_terminal_id            => i_terminal_id
          , i_atm_model              => l_atm.atm_model
          , i_serial_number          => l_atm.serial_number
          , i_placement_type         => l_atm.placement_type
          , i_availability_type      => l_atm.availability_type
          , i_operating_hours        => l_atm.operating_hours
          , i_cassette_count         => l_atm.cassette_count
          , i_key_change_algo        => l_atm.key_change_algo
          , i_counter_sync_cond      => l_atm.counter_sync_cond
          , i_reject_disp_warn       => l_atm.reject_disp_warn
          , i_disp_rest_warn         => l_atm.disp_rest_warn
          , i_receipt_warn           => l_atm.receipt_warn
          , i_card_capture_warn      => l_atm.card_capture_warn
          , i_note_max_count         => l_atm.note_max_count
          , i_scenario_id            => l_atm.scenario_id
          , i_hopper_count           => l_atm.hopper_count
          , i_manual_synch           => l_atm.manual_synch
          , i_establ_conn_synch      => l_atm.establ_conn_synch
          , i_counter_mismatch_synch => l_atm.counter_mismatch_synch
          , i_online_in_synch        => l_atm.online_in_synch
          , i_online_out_synch       => l_atm.online_out_synch
          , i_safe_close_synch       => l_atm.safe_close_synch
          , i_disp_error_synch       => l_atm.disp_error_synch
          , i_periodic_synch         => l_atm.periodic_synch
          , i_periodic_all_oper      => l_atm.periodic_all_oper
          , i_periodic_oper_count    => l_atm.periodic_oper_count
          , i_reject_disp_min_warn   => l_atm.reject_disp_min_warn
          , i_cash_in_present        => l_atm.cash_in_present
          , i_cash_in_min_warn       => l_atm.cash_in_min_warn
          , i_cash_in_max_warn       => l_atm.cash_in_max_warn
          , i_powerup_service        => l_atm.powerup_service
          , i_supervisor_service     => l_atm.supervisor_service
          , i_appl_flag              => com_api_type_pkg.TRUE
          , i_dispense_algo          => l_atm.dispense_algo
        );
    end if;

    process_atm_dispenser(
        i_appl_data_id   => l_id
      , i_terminal_id    => i_terminal_id
      , i_cassette_count => l_atm.cassette_count
      , i_hopper_count   => l_atm.hopper_count
    );
end;

function get_cud_code(
    i_terminal_number      in            varchar2
) return varchar2 is
    l_terminal_number   com_api_type_pkg.t_short_id;
    l_remainder         pls_integer;
    l_result            com_api_type_pkg.t_name;
begin
    begin
        l_terminal_number := to_number(i_terminal_number);
    exception
        when com_api_error_pkg.e_value_error then
            return null;
    end;

    l_remainder       := mod(l_terminal_number, 26) + 10;
    l_result          := g_cud_codes(l_remainder + 1);
    l_terminal_number := (l_terminal_number - l_remainder + 10) / 26;

    while (l_terminal_number > 0) loop
        l_remainder       := mod(l_terminal_number, 36);
        l_result          := g_cud_codes(l_remainder + 1) || l_result;
        l_terminal_number := (l_terminal_number - l_remainder) / 36;
    end loop;

    return l_result;

end;

procedure process_encryption(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_terminal_id          in            com_api_type_pkg.t_short_id
) is
    l_encryption           aap_api_type_pkg.t_encryption;
    l_params               com_api_type_pkg.t_param_tab;    
begin
    trc_log_pkg.debug('aap_api_terminal_pkg.process_encryption, i_terminal_id='||i_terminal_id);

    app_api_application_pkg.get_element_value(
        i_element_name   => 'ENCRYPTION_KEY_TYPE'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_encryption.key_type
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'ENCRYPTION_KEY_PREFIX'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_encryption.key_prefix
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'ENCRYPTION_KEY_LENGTH'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_encryption.key_length
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'ENCRYPTION_KEY_CHECK_VALUE'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_encryption.check_value
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'ENCRYPTION_KEY'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_encryption.key
    );

    sec_api_des_key_pkg.add_des_key(
        o_key_id           => l_encryption.id
      , i_object_id        => i_terminal_id
      , i_entity_type      => acq_api_const_pkg.ENTITY_TYPE_TERMINAL
      , i_hsm_device_id    => hsm_api_selection_pkg.select_hsm (
                                  i_inst_id => ost_api_const_pkg.DEFAULT_INST
                                , i_action  => hsm_api_const_pkg.ACTION_HSM_PERSONALIZATION
                                , i_params  => l_params           
                              ) --!!!!!
      , i_key_type         => l_encryption.key_type
      , i_key_length       => l_encryption.key_length
      , i_key_prefix       => l_encryption.key_prefix
      , i_key_value        => l_encryption.key
      , i_check_value      => l_encryption.check_value
    );
end;

procedure process_tcp_ip_protocol(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_device_id            in            com_api_type_pkg.t_short_id
) is
    l_tcp_ip_protocol      aap_api_type_pkg.t_tcp_ip_protocol;
    l_tcp_ip_protocol_old  aap_api_type_pkg.t_tcp_ip_protocol;
    l_seqnum               com_api_type_pkg.t_seqnum;
    l_device_id            com_api_type_pkg.t_short_id := i_device_id;
    l_is_enabled           com_api_type_pkg.t_boolean;
begin
    trc_log_pkg.debug('aap_api_terminal_pkg.process_tcp_ip_protocol, i_device_id='||i_device_id);

    app_api_application_pkg.get_element_value(
        i_element_name   => 'REMOTE_ADDRESS'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_tcp_ip_protocol.remote_address
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'LOCAL_PORT'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_tcp_ip_protocol.local_port
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'REMOTE_PORT'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_tcp_ip_protocol.remote_port
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'INITIATOR'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_tcp_ip_protocol.initiator
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'FORMAT'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_tcp_ip_protocol.format
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'KEEP_ALIVE'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_tcp_ip_protocol.keep_alive
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'MONITOR_CONNECTION'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_tcp_ip_protocol.monitor_connection
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'MULTIPLE_CONNECTION'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_tcp_ip_protocol.multiple_connection
    );

    begin
        select seqnum
             , remote_address
             , local_port
             , remote_port
             , initiator
             , format
             , keep_alive
             , monitor_connection
             , multiple_connection
             , is_enabled
          into l_seqnum
             , l_tcp_ip_protocol_old.remote_address
             , l_tcp_ip_protocol_old.local_port
             , l_tcp_ip_protocol_old.remote_port
             , l_tcp_ip_protocol_old.initiator
             , l_tcp_ip_protocol_old.format
             , l_tcp_ip_protocol_old.keep_alive
             , l_tcp_ip_protocol_old.monitor_connection
             , l_tcp_ip_protocol_old.multiple_connection
             , l_is_enabled
          from cmn_ui_tcp_ip_vw
         where id = i_device_id;
         
        if l_is_enabled = com_api_const_pkg.TRUE then
            cmn_ui_device_pkg.set_is_enabled (
                i_device_id       => l_device_id
              , i_is_enabled      => com_api_const_pkg.FALSE
              , io_seqnum         => l_seqnum
            );
        end if;
        
        cmn_ui_tcp_ip_pkg.modify_tcp_ip (
            i_tcp_ip_id           => l_device_id
          , i_remote_address      => coalesce(l_tcp_ip_protocol.remote_address, l_tcp_ip_protocol_old.remote_address)
          , i_local_port          => coalesce(l_tcp_ip_protocol.local_port, l_tcp_ip_protocol_old.local_port)
          , i_remote_port         => coalesce(l_tcp_ip_protocol.remote_port, l_tcp_ip_protocol_old.remote_port)
          , i_initiator           => coalesce(l_tcp_ip_protocol.initiator, l_tcp_ip_protocol_old.initiator)
          , i_format              => coalesce(l_tcp_ip_protocol.format, l_tcp_ip_protocol_old.format)
          , i_keep_alive          => coalesce(l_tcp_ip_protocol.keep_alive, l_tcp_ip_protocol_old.keep_alive)
          , i_monitor_connection  => coalesce(l_tcp_ip_protocol.monitor_connection, l_tcp_ip_protocol_old.monitor_connection)
          , i_multiple_connection => coalesce(l_tcp_ip_protocol.multiple_connection, l_tcp_ip_protocol_old.multiple_connection)
          , io_seqnum             => l_seqnum
        );

        if l_is_enabled = com_api_const_pkg.TRUE then
            cmn_ui_device_pkg.set_is_enabled (
                i_device_id       => l_device_id
              , i_is_enabled      => com_api_const_pkg.TRUE
              , io_seqnum         => l_seqnum
            );
        end if;
    exception
        when no_data_found then
            cmn_ui_tcp_ip_pkg.add_tcp_ip (
                i_tcp_ip_id           => i_device_id
              , i_remote_address      => l_tcp_ip_protocol.remote_address
              , i_local_port          => l_tcp_ip_protocol.local_port
              , i_remote_port         => l_tcp_ip_protocol.remote_port
              , i_initiator           => l_tcp_ip_protocol.initiator
              , i_format              => l_tcp_ip_protocol.format
              , i_keep_alive          => l_tcp_ip_protocol.keep_alive
              , i_is_enabled          => null
              , i_monitor_connection  => l_tcp_ip_protocol.monitor_connection
              , i_multiple_connection => l_tcp_ip_protocol.multiple_connection
              , o_seqnum              => l_seqnum
            );
    end;
end process_tcp_ip_protocol;

procedure change_objects(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_parent_appl_data_id  in            com_api_type_pkg.t_long_id
  , i_merchant_id          in            com_api_type_pkg.t_short_id
  , i_terminal_id          in            com_api_type_pkg.t_short_id
  , i_inst_id              in            com_api_type_pkg.t_inst_id
  , i_contract_id          in            com_api_type_pkg.t_medium_id
) is
    l_id_tab               com_api_type_pkg.t_number_tab;
    l_address_id           com_api_type_pkg.t_long_id;
    l_count                com_api_type_pkg.t_count := 0;
    l_merchant_number      com_api_type_pkg.t_name;
    l_terminal_number      com_api_type_pkg.t_name;
    l_contract_rec         prd_api_type_pkg.t_contract;
begin
    trc_log_pkg.debug('aap_api_terminal_pkg.change_objects: i_terminal_id='||i_terminal_id
                  ||', i_merchant_id='||i_merchant_id);

    --  processing terminal contacts
    l_id_tab.delete;
    app_api_application_pkg.get_appl_data_id(
        i_element_name   => 'CONTACT'
      , i_parent_id      => i_appl_data_id
      , o_appl_data_id   => l_id_tab
    );
    trc_log_pkg.debug('contact tab count='||l_id_tab.count);
    for i in 1..nvl(l_id_tab.count, 0) loop
        --trc_log_pkg.debug('Found terminal contact, id='||l_id_tab(i));
        app_api_contact_pkg.process_contact(
            i_appl_data_id          => l_id_tab(i)
          , i_parent_appl_data_id   => i_appl_data_id
          , i_object_id             => i_terminal_id
          , i_entity_type           => acq_api_const_pkg.ENTITY_TYPE_TERMINAL
        );
    end loop;

    --  processing terminal payment orders
    app_api_application_pkg.get_appl_data_id(
        i_element_name  => 'PAYMENT_ORDER'
      , i_parent_id     => i_appl_data_id
      , o_appl_data_id  => l_id_tab
    );

    if l_id_tab.count > 0 then
        l_contract_rec :=
            prd_api_contract_pkg.get_contract(
                i_contract_id   => i_contract_id
            );

        for i in 1 .. l_id_tab.count loop
            app_api_payment_order_pkg.process_order(
                i_appl_data_id => l_id_tab(i)
              , i_inst_id      => i_inst_id
              , i_entity_type  => acq_api_const_pkg.ENTITY_TYPE_TERMINAL
              , i_object_id    => i_terminal_id
              , i_agent_id     => l_contract_rec.agent_id
              , i_customer_id  => l_contract_rec.customer_id
              , i_contract_id  => i_contract_id
            );
        end loop;
    end if;

    --  processing terminal address
    app_api_application_pkg.get_appl_data_id(
        i_element_name  => 'ADDRESS'
      , i_parent_id     => i_appl_data_id
      , o_appl_data_id  => l_id_tab
    );

    for i in 1.. nvl(l_id_tab.count, 0) loop
        app_api_address_pkg.process_address(
            i_appl_data_id         => l_id_tab(i)
          , i_parent_appl_data_id  => i_appl_data_id
          , i_object_id            => i_terminal_id
          , i_entity_type          => acq_api_const_pkg.ENTITY_TYPE_TERMINAL
          , o_address_id           => l_address_id
        );
    end loop;

    l_address_id := acq_api_terminal_pkg.get_terminal_address_id(i_terminal_id);

    select count(a.id)
      into l_count
      from com_address a
     where a.id    = l_address_id
        and a.lang = com_api_const_pkg.DEFAULT_LANGUAGE;

    if l_count = 0 then
        select min(terminal_number)
          into l_terminal_number
          from acq_terminal
         where id      = i_terminal_id
           and inst_id = i_inst_id;

        select min(merchant_number)
          into l_merchant_number
          from acq_merchant
         where id      = i_merchant_id
           and inst_id = i_inst_id;
        if g_address_error_raised = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_error(
                i_error        => 'BUSINESS_ADDRESS_NOT_DEFINED'
              , i_env_param1   => l_terminal_number
              , i_env_param2   => l_merchant_number
            );
            g_address_error_raised := com_api_const_pkg.TRUE;
        end if;
    end if;

    app_api_flexible_field_pkg.process_flexible_fields(
        i_entity_type   => acq_api_const_pkg.ENTITY_TYPE_TERMINAL
      , i_object_type   => null
      , i_object_id     => i_terminal_id
      , i_inst_id       => i_inst_id
      , i_appl_data_id  => i_appl_data_id
    );

    rul_api_param_pkg.set_param (
        i_value   => l_terminal_number
      , i_name    => 'TERMINAL_NUMBER'
      , io_params => app_api_application_pkg.g_params
    );

    app_api_service_pkg.process_entity_service(
        i_appl_data_id  => i_appl_data_id
      , i_element_name  => 'TERMINAL'
      , i_entity_type   => acq_api_const_pkg.ENTITY_TYPE_TERMINAL
      , i_object_id     => i_terminal_id
      , i_contract_id   => i_contract_id
      , io_params       => app_api_application_pkg.g_params
    );

    if hsm_api_device_pkg.g_use_hsm = com_api_const_pkg.TRUE then
        l_id_tab.delete;
        app_api_application_pkg.get_appl_data_id(
            i_element_name   => 'ENCRYPTION'
          , i_parent_id      => i_appl_data_id
          , o_appl_data_id   => l_id_tab
        );

        for i in 1..l_id_tab.count loop
            process_encryption(
                i_appl_data_id  => l_id_tab(i)
              , i_terminal_id   => i_terminal_id
            );
        end loop;
    end if;

end;

procedure create_terminal(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_parent_appl_data_id  in            com_api_type_pkg.t_long_id
  , i_merchant_id          in            com_api_type_pkg.t_short_id
  , i_contract_id          in            com_api_type_pkg.t_medium_id
  , i_customer_id          in            com_api_type_pkg.t_medium_id
) is
    LOG_PREFIX    constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.create_terminal: ';
    l_terminal             aap_api_type_pkg.t_terminal;
    l_terminal_quantity    com_api_type_pkg.t_tiny_id;
    l_id_tab               com_api_type_pkg.t_number_tab;
    --l_root_merchant      com_api_type_pkg.t_short_id;
    l_split_hash           com_api_type_pkg.t_tiny_id;
    l_param_tab            com_api_type_pkg.t_param_tab;
    --l_address_id         com_api_type_pkg.t_long_id;
    l_pos_batch_method     com_api_type_pkg.t_dict_value;
    l_partial_approval     com_api_type_pkg.t_short_id;
    l_purchase_amount      com_api_type_pkg.t_short_id;   
    l_instalment_support   com_api_type_pkg.t_boolean;
    l_appl_data_id         com_api_type_pkg.t_long_id;
    l_commun_plugin        com_api_type_pkg.t_dict_value;
    l_commun_plugin_old    com_api_type_pkg.t_dict_value;
    l_device_name          com_api_type_pkg.t_multilang_desc_tab;
    l_seqnum               com_api_type_pkg.t_seqnum;
begin
    trc_log_pkg.debug(LOG_PREFIX || 'START with i_merchant_id [' || i_merchant_id || ']');

    get_appl_data(
        i_appl_data_id  => i_appl_data_id
      , o_terminal      => l_terminal
    );

    if l_terminal.terminal_type is null then
        com_api_error_pkg.raise_error(
            i_error     =>  'TERMINAL_TYPE_NOT_DEFINED'
        );
    end if;

    l_terminal.merchant_id :=  i_merchant_id;

    fill_terminal_from_template(
        io_term         => l_terminal
      , i_appl_data_id  => i_appl_data_id
    );
    trc_log_pkg.debug('l_terminal.terminal_profile [' || l_terminal.terminal_profile || ']');
    
    aap_api_merchant_pkg.check_merchant_tree(
        i_parent_id      =>  i_merchant_id
      , i_merchant_type  =>  acq_api_const_pkg.MERCHANT_TYPE_TERMINAL 
      , i_inst_id        =>  l_terminal.inst_id
      , i_appl_data_id   =>  i_appl_data_id
    );    

    app_api_application_pkg.get_element_value(
        i_element_name   => 'TERMINAL_QUANTITY'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_terminal_quantity
    );

    if l_terminal_quantity is null then
        -- As far as tag TERMINAL_QUANTITY is optional we create 1 terminal by default
        l_terminal_quantity := 1;

    elsif l_terminal_quantity < 1 then
        com_api_error_pkg.raise_error(
            i_error       => 'TERMINAL_QUANTITY_LESS_THAN_1'
          , i_env_param1  => l_terminal_quantity
        );
    end if;

    trc_log_pkg.debug(
        i_text       => 'terminal quantity [' || l_terminal_quantity || '], terminal type [#1]'
      , i_env_param1 => l_terminal.terminal_type
    );

    app_api_application_pkg.get_appl_data_id(
        i_element_name  => 'TERMINAL_NUMBER'
      , i_parent_id     => i_appl_data_id
      , o_appl_data_id  => l_id_tab
    );
    if l_id_tab.count > l_terminal_quantity then
        com_api_error_pkg.raise_error(
            i_error       => 'BAD_TERMINAL_NUMBER_COUNT'
          , i_env_param1  => l_id_tab.count
          , i_env_param2  => l_terminal_quantity
        );
    end if;

    for i in 1 .. l_terminal_quantity loop
        app_api_application_pkg.get_element_value(
            i_element_name   => 'PLASTIC_NUMBER'
          , i_parent_id      => i_appl_data_id
          , i_serial_number  => i
          , o_element_value  => l_terminal.plastic_number
        );

        if l_terminal.id is null then
            l_terminal.id := get_terminal_id;
        end if;

        app_api_application_pkg.get_element_value(
            i_element_name   => 'TERMINAL_NUMBER'
          , i_parent_id      => i_appl_data_id
          , i_serial_number  => i
          , o_element_value  => l_terminal.terminal_number
        );

        if l_terminal.terminal_number is null then
            l_terminal.terminal_number := l_terminal.id;
            app_api_application_pkg.add_element(
                i_element_name   => 'TERMINAL_NUMBER'
              , i_parent_id      => i_appl_data_id
              , i_element_value  => l_terminal.terminal_number
            );
        end if;

        if l_terminal.terminal_type = acq_api_const_pkg.TERMINAL_TYPE_IMPRINTER then

            app_api_application_pkg.get_element_value(
                i_element_name   => 'PLASTIC_NUMBER'
              , i_parent_id      => i_appl_data_id
              , i_serial_number  => i
              , o_element_value  => l_terminal.plastic_number
            );

            if l_terminal.plastic_number is null then
                l_terminal.plastic_number := l_terminal.terminal_number;
                app_api_application_pkg.add_element(
                    i_element_name   => 'PLASTIC_NUMBER'
                  , i_parent_id      => i_appl_data_id
                  , i_element_value  => l_terminal.plastic_number
                );
            end if;

            check_imprinter_num(
                i_plastic_number  => l_terminal.plastic_number
              , i_inst_id         => l_terminal.inst_id
              , i_appl_data_id    => i_appl_data_id
            );
        end if;

        if l_terminal.status = acq_api_const_pkg.TERMINAL_STATUS_CLOSED then
            com_api_error_pkg.raise_error(
                i_error      => 'INVALID_TERMINAL_STATUS'
              , i_env_param1 => l_terminal.status
            );
        end if;

        acq_api_terminal_pkg.add_terminal(
            io_terminal_id           => l_terminal.id
          , i_terminal_number        => l_terminal.terminal_number
          , i_merchant_id            => l_terminal.merchant_id
          , i_mcc                    => l_terminal.mcc
          , i_plastic_number         => l_terminal.plastic_number
          , i_contract_id            => i_contract_id
          , i_terminal_type          => l_terminal.terminal_type
          , i_card_data_input_cap    => l_terminal.card_data_input_cap
          , i_crdh_auth_cap          => l_terminal.crdh_auth_cap
          , i_card_capture_cap       => l_terminal.card_capture_cap
          , i_term_operating_env     => l_terminal.term_operating_env
          , i_crdh_data_present      => l_terminal.crdh_data_present
          , i_card_data_present      => l_terminal.card_data_present
          , i_card_data_input_mode   => l_terminal.card_data_input_mode
          , i_crdh_auth_method       => l_terminal.crdh_auth_method
          , i_crdh_auth_entity       => l_terminal.crdh_auth_entity
          , i_card_data_output_cap   => l_terminal.card_data_output_cap
          , i_term_data_output_cap   => l_terminal.term_data_output_cap
          , i_pin_capture_cap        => l_terminal.pin_capture_cap
          , i_cat_level              => l_terminal.cat_level
          , i_status                 => l_terminal.status --acq_api_const_pkg.TERMINAL_STATUS_ACTIVE --l_terminal.status
          , i_inst_id                => l_terminal.inst_id
          , i_device_id              => l_terminal.device_id
          , i_is_mac                 => l_terminal.is_mac
          , i_gmt_offset             => l_terminal.gmt_offset
          , i_standard_id            => l_terminal.standard_id
          , i_version_id             => l_terminal.version_id
          , i_split_hash             => com_api_hash_pkg.get_split_hash(prd_api_const_pkg.ENTITY_TYPE_CONTRACT, i_contract_id)
          , i_cash_dispenser_present => l_terminal.cash_dispenser_present
          , i_payment_possibility    => l_terminal.payment_possibility
          , i_use_card_possibility   => l_terminal.use_card_possibility
          , i_cash_in_present        => l_terminal.cash_in_present
          , i_available_network      => l_terminal.available_network
          , i_available_operation    => l_terminal.available_operation
          , i_available_currency     => l_terminal.available_currency
          , i_mcc_template_id        => l_terminal.mcc_template_id
          , i_terminal_profile       => l_terminal.terminal_profile
          , i_pin_block_format       => l_terminal.pin_block_format
          , i_pos_batch_support      => l_terminal.pos_batch_support
        );

        trc_log_pkg.debug('created terminal identifier: '||l_terminal.id);

        app_api_appl_object_pkg.add_object(
            i_appl_id           => app_api_application_pkg.get_appl_id
          , i_entity_type       => acq_api_const_pkg.ENTITY_TYPE_TERMINAL
          , i_object_id         => l_terminal.id
          , i_seqnum            => 1
        );

        --  add to terminal limits, cycles and services defined by product
        aap_api_product_pkg.process_product(
            i_product_id    => l_terminal.product_id
          , i_object_id     => l_terminal.id
          , i_entity_type   => acq_api_const_pkg.ENTITY_TYPE_TERMINAL
          , i_inst_id       => l_terminal.inst_id
        );

        if l_terminal.terminal_type = acq_api_const_pkg.TERMINAL_TYPE_ATM then
            --  processing ATM terminal parameters
            process_atm_terminal(
                i_parent_appl_data_id => i_appl_data_id
              , i_terminal_id         => l_terminal.id
            );
        elsif l_terminal.terminal_type = acq_api_const_pkg.TERMINAL_TYPE_POS then
            --  processing POS terminal parameters
            app_api_application_pkg.get_element_value(
                i_element_name   => 'POS_BATCH_METHOD'
              , i_parent_id      => i_appl_data_id
              , i_serial_number  => i
              , o_element_value  => l_pos_batch_method
            );
            
            app_api_application_pkg.get_element_value(
                i_element_name   => 'PARTIAL_APPROVAL'
              , i_parent_id      => i_appl_data_id
              , i_serial_number  => i
              , o_element_value  => l_partial_approval
            );
            
            app_api_application_pkg.get_element_value(
                i_element_name   => 'PURCHASE_AMOUNT'
              , i_parent_id      => i_appl_data_id
              , i_serial_number  => i
              , o_element_value  => l_purchase_amount
            );                                    

            app_api_application_pkg.get_element_value(
                i_element_name   => 'INSTALMENT_SUPPORT'
              , i_parent_id      => i_appl_data_id
              , i_serial_number  => i
              , o_element_value  => l_instalment_support
            );

            trc_log_pkg.debug(
                i_text       => 'POS terminal parameters: POS_BATCH_METHOD [#1'  
                             || '], PARTIAL_APPROVAL [' || l_partial_approval
                             || '], PURCHASE_AMOUNT [' || l_purchase_amount || ']'
              , i_env_param1 => l_pos_batch_method
              , i_object_id  => i_appl_data_id
            );

            process_pos_terminal(
                i_appl_data_id       => i_appl_data_id
              , i_terminal_id        => l_terminal.id
              , i_pos_batch_method   => l_pos_batch_method 
              , i_partial_approval   => l_partial_approval
              , i_purchase_amount    => l_purchase_amount
              , i_instalment_support => l_instalment_support 
            );
        end if;
    --  processing TCP/IP protocol parameters
--        app_api_application_pkg.get_appl_data_id(
--            i_element_name          => 'TCP_IP_PROTOCOL'
--          , i_parent_id             => i_appl_data_id
--          , i_appl_data             => io_appl_data
--          , o_appl_data_id          => l_appl_data_id
--        );

--        if l_appl_data_id is not null then
--            trc_log_pkg.debug('Found TCP/IP protocol data');
--
--            process_tcp_ip_protocol(
--                i_appl_data_id          => l_appl_data_id
--              , i_appl_data             => io_appl_data
--              , i_terminal_id           => l_terminal.id
--              , i_cud_code              => get_cud_code(l_terminal.terminal_number)
--            );
--        end if;

    --
    --  processing X25 protocol parameters
    --
--        app_api_application_pkg.get_appl_data_id(
--            i_element_name          => 'X25_PROTOCOL'
--          , i_parent_id             => i_appl_data_id
--          , i_appl_data             => io_appl_data
--          , o_appl_data_id          => l_appl_data_id
--        );

--        if l_appl_data_id is not null then
--            process_x25_protocol(
--                i_appl_data_id          => l_appl_data_id
--              , i_appl_data             => io_appl_data
--              , i_terminal_id           => l_terminal.id
--              , i_cud_code              => get_cud_code(l_terminal.terminal_number)
--            );
--        end if;
        
        if l_terminal.device_id is not null then
            begin
                app_api_application_pkg.get_element_value(
                    i_element_name   => 'COMMUN_PLUGIN'
                  , i_parent_id      => i_appl_data_id
                  , o_element_value  => l_commun_plugin
                );

                select seqnum
                     , communication_plugin
                  into l_seqnum
                     , l_commun_plugin_old
                  from cmn_device_vw
                 where id = l_terminal.device_id;

                update cmn_device_vw
                   set communication_plugin = coalesce(l_commun_plugin, l_commun_plugin_old)
                     , seqnum               = l_seqnum
                 where id                   = l_terminal.device_id;

                l_seqnum := l_seqnum + 1;
                        
                update cmn_tcp_ip
                   set seqnum  = l_seqnum
                 where id      = l_terminal.device_id;

                app_api_application_pkg.get_element_value(
                    i_element_name   => 'DEVICE_NAME'
                  , i_parent_id      => i_appl_data_id
                  , o_element_value  => l_device_name
                );
                
                --  Processing device name
                for i in 1..l_device_name.count loop
                    trc_log_pkg.debug(LOG_PREFIX || 'device name added, value [' || l_device_name(i).value
                                                 || '], lang [' || l_device_name(i).lang || ']');
                    com_api_i18n_pkg.add_text(
                        i_table_name        => 'cmn_device'
                      , i_column_name       => 'label'
                      , i_object_id         => l_terminal.device_id
                      , i_text              => l_device_name(i).value
                      , i_lang              => l_device_name(i).lang
                    );
                end loop;
            exception
                when no_data_found then
                    trc_log_pkg.debug('device not found: '||l_terminal.device_id);
            end;
        end if;

        -- Saving TCP/IP protocol
        app_api_application_pkg.get_appl_data_id(
            i_element_name          => 'TCP_IP_PROTOCOL'
          , i_parent_id             => i_appl_data_id
          , o_appl_data_id          => l_appl_data_id
        );

        if l_appl_data_id is not null and l_terminal.device_id is not null then
            trc_log_pkg.debug('Found TCP/IP protocol data');

            process_tcp_ip_protocol(
                i_appl_data_id          => l_appl_data_id
              , i_device_id             => l_terminal.device_id
            );
        end if;
        
        change_objects(
            i_appl_data_id        => i_appl_data_id
          , i_parent_appl_data_id => i_parent_appl_data_id
          , i_merchant_id         => i_merchant_id
          , i_terminal_id         => l_terminal.id
          , i_inst_id             => l_terminal.inst_id
          , i_contract_id         => i_contract_id
        );

        l_split_hash := com_api_hash_pkg.get_split_hash(
            i_entity_type   =>  com_api_const_pkg.ENTITY_TYPE_CUSTOMER
          , i_object_id     =>  i_customer_id
        );

        com_api_array_pkg.sync_dynamic_array_element(
          i_object_id             => l_terminal.id
          , i_entity_type         => acq_api_const_pkg.ENTITY_TYPE_TERMINAL
          , i_inst_id             => l_terminal.inst_id
          , i_agent_id            => null
        );
        
        l_terminal.id := null;
    end loop;

    trc_log_pkg.debug(LOG_PREFIX || 'END');
end;

procedure change_terminal(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_parent_appl_data_id  in            com_api_type_pkg.t_long_id
  , i_merchant_id          in            com_api_type_pkg.t_short_id
  , i_terminal_id          in            com_api_type_pkg.t_short_id
  , i_contract_id          in            com_api_type_pkg.t_medium_id
) is
    LOG_PREFIX    constant  com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.change_terminal: ';
    l_inst_id               com_api_type_pkg.t_inst_id;
    l_new                   aap_api_type_pkg.t_terminal;
    l_appl_data_id          com_api_type_pkg.t_long_id;
    l_terminal_quantity     com_api_type_pkg.t_tiny_id;
    l_pos_batch_method      com_api_type_pkg.t_dict_value;
    l_partial_approval      com_api_type_pkg.t_short_id;
    l_purchase_amount       com_api_type_pkg.t_short_id;
    l_old_product_id        com_api_type_pkg.t_short_id;
    l_split_hash            com_api_type_pkg.t_tiny_id;
    l_param_tab             com_api_type_pkg.t_param_tab;
    l_plastic_number        com_api_type_pkg.t_card_number;
    l_old_plastic_number    com_api_type_pkg.t_card_number;
    l_instalment_support    com_api_type_pkg.t_boolean;
    l_commun_plugin         com_api_type_pkg.t_dict_value;
    l_commun_plugin_old     com_api_type_pkg.t_dict_value;
    l_device_name           com_api_type_pkg.t_multilang_desc_tab;
    l_seqnum                com_api_type_pkg.t_seqnum;
    l_old_status            com_api_type_pkg.t_dict_value;
begin
    trc_log_pkg.debug(LOG_PREFIX || 'START with i_merchant_id [' || i_merchant_id || ']');

    get_appl_data(
        i_appl_data_id  => i_appl_data_id
      , o_terminal      => l_new
    );

    select nvl(l_new.terminal_type, terminal_type)
         , nvl(l_new.merchant_id, merchant_id)
         , nvl(l_new.device_id, device_id)
         , inst_id
         , (select c.product_id from prd_contract c where c.id = t.contract_id) product_id
         , nvl(l_new.plastic_number, plastic_number)
         , plastic_number
         , status
      into l_new.terminal_type
         , l_new.merchant_id
         , l_new.device_id
         , l_inst_id
         , l_old_product_id
         , l_new.plastic_number
         , l_old_plastic_number
         , l_old_status
      from acq_terminal t
     where id = i_terminal_id;

    l_new.id := i_terminal_id;
    g_template_id := l_new.terminal_template;

    if l_new.product_id is null then
        get_product_id(
            i_parent_id   =>  l_new.merchant_id
          , o_product_id  =>  l_new.product_id
        );
    end if;

    app_api_application_pkg.get_element_value(
        i_element_name   => 'TERMINAL_QUANTITY'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_terminal_quantity
    );

    if l_terminal_quantity is null then
        -- As far as tag TERMINAL_QUANTITY is optional we create 1 terminal by default
        l_terminal_quantity := 1;

    elsif l_terminal_quantity < 1 then
        com_api_error_pkg.raise_error(
            i_error       => 'TERMINAL_QUANTITY_LESS_THAN_1'
          , i_env_param1  => l_terminal_quantity
        );
    end if;

    trc_log_pkg.debug(
        i_text       => 'terminal quantity [' || l_terminal_quantity || '], terminal type [#1]'
      , i_env_param1 => l_new.terminal_type
    );

    for i in 1 .. l_terminal_quantity loop
        app_api_application_pkg.get_element_value(
            i_element_name   => 'PLASTIC_NUMBER'
          , i_parent_id      => i_appl_data_id
          , i_serial_number  => i
          , o_element_value  => l_plastic_number
        );
        l_new.plastic_number := nvl(l_plastic_number, l_new.plastic_number);

        if l_new.id is null then
            l_new.id := get_terminal_id;
        end if;

        app_api_application_pkg.get_element_value(
            i_element_name      => 'TERMINAL_NUMBER'
          , i_parent_id         => i_appl_data_id
          , i_serial_number     => i
          , o_element_value     => l_new.terminal_number
        );

        if l_new.terminal_number is null then
            l_new.terminal_number := l_new.id;
            app_api_application_pkg.add_element(
                i_element_name   => 'TERMINAL_NUMBER'
              , i_parent_id      => i_appl_data_id
              , i_element_value  => l_new.terminal_number
            );
        end if;

        if l_new.terminal_type = acq_api_const_pkg.TERMINAL_TYPE_IMPRINTER then
            app_api_application_pkg.get_element_value(
                i_element_name   =>  'PLASTIC_NUMBER'
              , i_parent_id      =>  i_appl_data_id
              , i_serial_number  =>  i
              , o_element_value  =>  l_plastic_number
            );
            l_new.plastic_number := nvl(l_plastic_number, l_new.plastic_number);

            if l_new.plastic_number is null then
                l_new.plastic_number := l_new.terminal_number;
                app_api_application_pkg.add_element(
                    i_element_name   =>  'PLASTIC_NUMBER'
                  , i_parent_id      =>  i_appl_data_id
                  , i_element_value  =>  l_new.plastic_number
                );
            end if;
            
            if l_plastic_number is not null and l_old_plastic_number != l_new.plastic_number then
                check_imprinter_num(
                    i_plastic_number  =>  l_new.plastic_number
                  , i_inst_id         =>  l_new.inst_id
                  , i_appl_data_id    =>  i_appl_data_id
                );
            end if;
        end if;

        if l_new.status is not null and (l_old_status is null or l_old_status != l_new.status) then
            evt_api_status_pkg.change_status(
                i_initiator      => evt_api_const_pkg.INITIATOR_SYSTEM
              , i_entity_type    => acq_api_const_pkg.ENTITY_TYPE_TERMINAL
              , i_object_id      => l_new.id
              , i_new_status     => l_new.status
              , i_eff_date       => com_api_sttl_day_pkg.get_sysdate()
              , i_reason         => l_new.status_reason
              , o_status         => l_new.status
              , i_raise_error    => com_api_const_pkg.TRUE
              , i_register_event => com_api_const_pkg.TRUE
              , i_params         => app_api_application_pkg.g_params
            );
        end if;

        acq_api_terminal_pkg.modify_terminal(
            i_terminal_id            => i_terminal_id
          , i_terminal_number        => l_new.terminal_number
          , i_merchant_id            => l_new.merchant_id
          , i_mcc                    => l_new.mcc
          , i_plastic_number         => l_new.plastic_number
          , i_contract_id            => i_contract_id
          , i_card_data_input_cap    => l_new.card_data_input_cap
          , i_crdh_auth_cap          => l_new.crdh_auth_cap
          , i_card_capture_cap       => l_new.card_capture_cap
          , i_term_operating_env     => l_new.term_operating_env
          , i_crdh_data_present      => l_new.crdh_data_present
          , i_card_data_present      => l_new.card_data_present
          , i_card_data_input_mode   => l_new.card_data_input_mode
          , i_crdh_auth_method       => l_new.crdh_auth_method
          , i_crdh_auth_entity       => l_new.crdh_auth_entity
          , i_card_data_output_cap   => l_new.card_data_output_cap
          , i_term_data_output_cap   => l_new.term_data_output_cap
          , i_pin_capture_cap        => l_new.pin_capture_cap
          , i_cat_level              => l_new.cat_level
          , i_status                 => l_new.status
          , i_device_id              => l_new.device_id
          , i_is_mac                 => l_new.is_mac
          , i_gmt_offset             => l_new.gmt_offset
          , i_version_id             => l_new.version_id
          , i_cash_dispenser_present => l_new.cash_dispenser_present
          , i_payment_possibility    => l_new.payment_possibility
          , i_use_card_possibility   => l_new.use_card_possibility
          , i_cash_in_present        => l_new.cash_in_present
          , i_available_network      => l_new.available_network
          , i_available_operation    => l_new.available_operation
          , i_available_currency     => l_new.available_currency
          , i_mcc_template_id        => l_new.mcc_template_id
          , i_terminal_profile       => l_new.terminal_profile
          , i_pin_block_format       => l_new.pin_block_format
          , i_pos_batch_support      => l_new.pos_batch_support
        );

        trc_log_pkg.debug('Changed terminal: '||i_terminal_id);

        --  add to terminal limits, cycles and services defined by product
        aap_api_product_pkg.change_product(
            i_old_product_id  =>  l_old_product_id
          , i_new_product_id  =>  l_new.product_id
          , i_object_id       =>  i_terminal_id
          , i_entity_type     =>  acq_api_const_pkg.ENTITY_TYPE_TERMINAL
          , i_inst_id         =>  l_new.inst_id
        );

        trc_log_pkg.debug('l_new.terminal_type: '||l_new.terminal_type);

        if l_new.terminal_type = acq_api_const_pkg.TERMINAL_TYPE_ATM then
        --  processing ATM terminal parameters
            process_atm_terminal(
                i_parent_appl_data_id => i_appl_data_id
              , i_terminal_id         => l_new.id
            );
        elsif l_new.terminal_type = acq_api_const_pkg.TERMINAL_TYPE_POS then
        --  processing POS terminal parameters
            app_api_application_pkg.get_element_value(
                i_element_name   => 'POS_BATCH_METHOD'
              , i_parent_id      => i_appl_data_id
              , i_serial_number  => i
              , o_element_value  => l_pos_batch_method
            );
                
            app_api_application_pkg.get_element_value(
                i_element_name   => 'PARTIAL_APPROVAL'
              , i_parent_id      => i_appl_data_id
              , i_serial_number  => i
              , o_element_value  => l_partial_approval
            );
                
            app_api_application_pkg.get_element_value(
                i_element_name   => 'PURCHASE_AMOUNT'
              , i_parent_id      => i_appl_data_id
              , i_serial_number  => i
              , o_element_value  => l_purchase_amount
            ); 
                
            app_api_application_pkg.get_element_value(
                i_element_name   => 'INSTALMENT_SUPPORT'
              , i_parent_id      => i_appl_data_id
              , i_serial_number  => i
              , o_element_value  => l_instalment_support
            );

            trc_log_pkg.debug('POS terminal parameters: POS_BATCH_METHOD:'||l_pos_batch_method||' PARTIAL_APPROVAL:'||l_partial_approval||' PURCHASE_AMOUNT:'||l_purchase_amount, i_object_id=>l_appl_data_id);

            process_pos_terminal(
                i_appl_data_id       => l_appl_data_id
              , i_terminal_id        => i_terminal_id
              , i_pos_batch_method   => l_pos_batch_method
              , i_partial_approval   => l_partial_approval
              , i_purchase_amount    => l_purchase_amount  
              , i_instalment_support => l_instalment_support
            );
        end if;

    --  processing TCP/IP protocol parameters
--        app_api_application_pkg.get_appl_data_id(
--            i_element_name   => 'TCP_IP_PROTOCOL'
--          , i_parent_id      => i_appl_data_id
--          , i_appl_data      => io_appl_data
--          , o_appl_data_id   => l_appl_data_id
--        );

--        if l_appl_data_id is not null then
--            trc_log_pkg.debug('Found TCP/IP protocol data');
--
--            process_tcp_ip_protocol(
--                i_appl_data_id  => l_appl_data_id
--              , i_appl_data     => io_appl_data
--              , i_terminal_id   => l_terminal.id
--              , i_cud_code      => get_cud_code(l_terminal.terminal_number)
--            );
--        end if;

    --  processing X25 protocol parameters
--        app_api_application_pkg.get_appl_data_id(
--            i_element_name   => 'X25_PROTOCOL'
--          , i_parent_id      => i_appl_data_id
--          , i_appl_data      => io_appl_data
--          , o_appl_data_id   => l_appl_data_id
--        );

--        if l_appl_data_id is not null then
--            process_x25_protocol(
--                i_appl_data_id          => l_appl_data_id
--              , i_appl_data             => io_appl_data
--              , i_terminal_id           => l_terminal.id
--              , i_cud_code              => get_cud_code(l_terminal.terminal_number)
--            );
--        end if;

        if l_new.device_id is not null then
            begin
                app_api_application_pkg.get_element_value(
                    i_element_name   => 'COMMUN_PLUGIN'
                  , i_parent_id      => i_appl_data_id
                  , o_element_value  => l_commun_plugin
                );

                select seqnum
                     , communication_plugin
                  into l_seqnum
                     , l_commun_plugin_old
                  from cmn_device_vw
                 where id = l_new.device_id;

                update cmn_device_vw
                   set communication_plugin = coalesce(l_commun_plugin, l_commun_plugin_old)
                     , seqnum               = l_seqnum
                 where id                   = l_new.device_id;

                l_seqnum := l_seqnum + 1;
                        
                update cmn_tcp_ip
                   set seqnum  = l_seqnum
                 where id      = l_new.device_id;

                app_api_application_pkg.get_element_value(
                    i_element_name   => 'DEVICE_NAME'
                  , i_parent_id      => i_appl_data_id
                  , o_element_value  => l_device_name
                );
                
                --  Processing device name
                for i in 1..l_device_name.count loop
                    trc_log_pkg.debug(LOG_PREFIX || 'device name added, value [' || l_device_name(i).value
                                                 || '], lang [' || l_device_name(i).lang || ']');
                    com_api_i18n_pkg.add_text(
                        i_table_name        => 'cmn_device'
                      , i_column_name       => 'label'
                      , i_object_id         => l_new.device_id
                      , i_text              => l_device_name(i).value
                      , i_lang              => l_device_name(i).lang
                    );
                end loop;
            exception
                when no_data_found then
                    trc_log_pkg.debug('device not found: '||l_new.device_id);
            end;
        end if;

        -- Saving TCP/IP protocol
        app_api_application_pkg.get_appl_data_id(
            i_element_name          => 'TCP_IP_PROTOCOL'
          , i_parent_id             => i_appl_data_id
          , o_appl_data_id          => l_appl_data_id
        );

        if l_appl_data_id is not null and l_new.device_id is not null then
            trc_log_pkg.debug('Found TCP/IP protocol data');

            process_tcp_ip_protocol(
                i_appl_data_id          => l_appl_data_id
              , i_device_id             => l_new.device_id
            );
        end if;
        
        change_objects(
            i_appl_data_id        => i_appl_data_id
          , i_parent_appl_data_id => i_parent_appl_data_id
          , i_merchant_id         => l_new.merchant_id
          , i_terminal_id         => i_terminal_id
          , i_inst_id             => l_inst_id
          , i_contract_id         => i_contract_id
        );
        
        com_api_array_pkg.sync_dynamic_array_element(
            i_object_id           => i_terminal_id
          , i_entity_type         => acq_api_const_pkg.ENTITY_TYPE_TERMINAL
          , i_inst_id             => l_inst_id
          , i_agent_id            => null
        );

        l_split_hash := com_api_hash_pkg.get_split_hash(
            i_entity_type   =>  acq_api_const_pkg.ENTITY_TYPE_TERMINAL
          , i_object_id     =>  i_terminal_id
        );

        evt_api_event_pkg.register_event(
            i_event_type    => acq_api_const_pkg.EVENT_TERMINAL_CHANGE
          , i_eff_date      => com_api_sttl_day_pkg.get_sysdate
          , i_entity_type   => acq_api_const_pkg.ENTITY_TYPE_TERMINAL
          , i_object_id     => i_terminal_id
          , i_inst_id       => l_new.inst_id
          , i_param_tab     => l_param_tab
          , i_split_hash    => l_split_hash
        );

    end loop;    

    trc_log_pkg.debug(LOG_PREFIX || 'END');
end;

procedure close_terminal(
    i_terminal_id          in            com_api_type_pkg.t_short_id
  , i_inst_id              in            com_api_type_pkg.t_tiny_id
) is
    l_split_hash           com_api_type_pkg.t_tiny_id;
    l_param_tab            com_api_type_pkg.t_param_tab;
begin
    trc_log_pkg.debug(
        i_text          => 'aap_api_terminal_pkg.close_terminal START: i_terminal_id [#1]'
      , i_env_param1    => i_terminal_id
    );

    evt_api_shared_data_pkg.set_param(
        i_name      => 'OBJECT_ID'
      , i_value     => i_terminal_id
    );
    evt_api_shared_data_pkg.set_param(
        i_name      => 'INST_ID'
      , i_value     => i_inst_id
    );

    acq_api_terminal_pkg.close_terminal; -- it uses cache evt_api_shared_data_pkg
    
    com_api_array_pkg.sync_dynamic_array_element(
        i_object_id           => i_terminal_id
      , i_entity_type         => acq_api_const_pkg.ENTITY_TYPE_TERMINAL
      , i_inst_id             => i_inst_id
      , i_agent_id            => null
    );

    l_split_hash := com_api_hash_pkg.get_split_hash(
        i_entity_type   =>  acq_api_const_pkg.ENTITY_TYPE_TERMINAL
      , i_object_id     =>  i_terminal_id
    );

    evt_api_event_pkg.register_event(
        i_event_type    => acq_api_const_pkg.EVENT_TERMINAL_CLOSE
      , i_eff_date      => com_api_sttl_day_pkg.get_sysdate
      , i_entity_type   => acq_api_const_pkg.ENTITY_TYPE_TERMINAL
      , i_object_id     => i_terminal_id
      , i_inst_id       => i_inst_id
      , i_param_tab     => l_param_tab
      , i_split_hash    => l_split_hash
    );

    trc_log_pkg.debug(
        i_text          => 'aap_api_terminal_pkg.close_terminal: END'
    );
end;

procedure process_terminal(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_parent_appl_data_id  in            com_api_type_pkg.t_long_id
  , i_merchant_id          in            com_api_type_pkg.t_short_id
  , i_inst_id              in            com_api_type_pkg.t_tiny_id
  , i_contract_id          in            com_api_type_pkg.t_medium_id
  , i_customer_id          in            com_api_type_pkg.t_medium_id
) is
    l_command              com_api_type_pkg.t_dict_value;
    l_terminal_id          com_api_type_pkg.t_short_id;
    l_terminal_number      com_api_type_pkg.t_name;
    l_terminal_status      com_api_type_pkg.t_dict_value;
    l_count                com_api_type_pkg.t_count := 0;
    l_seqnum               com_api_type_pkg.t_tiny_id;
begin
    trc_log_pkg.debug(
        i_text          => 'aap_api_terminal_pkg.process_terminal: i_merchant_id [#1], i_inst_id [#2], i_contract_id [#3], i_customer_id [#4]'
      , i_env_param1    => i_merchant_id
      , i_env_param2    => i_inst_id
      , i_env_param3    => i_contract_id
      , i_env_param4    => i_customer_id
    );

    cst_api_application_pkg.process_terminal_before (
        i_appl_data_id         => i_appl_data_id
      , i_parent_appl_data_id  => i_parent_appl_data_id
      , i_merchant_id          => i_merchant_id
      , i_inst_id              => i_inst_id
      , i_contract_id          => i_contract_id
      , i_customer_id          => i_customer_id
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'COMMAND'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_command
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'TERMINAL_NUMBER'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_terminal_number
    );

    if l_terminal_number is not null then
        select min(id)
             , min(status)
             , count(id)
          into l_terminal_id
             , l_terminal_status
             , l_count
          from acq_terminal t
         where t.terminal_number = l_terminal_number
           and t.inst_id         = i_inst_id
           and t.status         != acq_api_const_pkg.TERMINAL_STATUS_CLOSED;
    else
        l_count := 0;
    end if;

    trc_log_pkg.debug(
        i_text          => 'l_command [#1], l_terminal_number [#2], l_terminal_id [#3], l_terminal_status [#4], l_count [#5]'
      , i_env_param1    => l_command
      , i_env_param2    => l_terminal_number
      , i_env_param3    => l_terminal_id
      , i_env_param4    => l_terminal_status
      , i_env_param5    => l_count
    );

    if l_count = 0 then
        --terminal not found
        if l_command = app_api_const_pkg.COMMAND_PROCEED_OR_REMOVE then
            null;

        elsif l_command in (
            app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
          , app_api_const_pkg.COMMAND_EXCEPT_OR_REMOVE
          , app_api_const_pkg.COMMAND_EXCEPT_OR_PROCEED
        ) then
            com_api_error_pkg.raise_error(
                i_error         => 'TERMINAL_NOT_FOUND'
              , i_env_param1    => l_terminal_number
            );

        elsif l_command in (
            app_api_const_pkg.COMMAND_CREATE_OR_PROCEED
          , app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
          , app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT
        ) then
            create_terminal(
                i_appl_data_id         => i_appl_data_id
              , i_parent_appl_data_id  => i_parent_appl_data_id
              , i_merchant_id          => i_merchant_id
              , i_contract_id          => i_contract_id
              , i_customer_id          => i_customer_id
            );

        else
            create_terminal(
                i_appl_data_id         => i_appl_data_id
              , i_parent_appl_data_id  => i_parent_appl_data_id
              , i_merchant_id          => i_merchant_id
              , i_contract_id          => i_contract_id
              , i_customer_id          => i_customer_id
            );

        end if;

    else
        --terminal found
        if l_command = app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT then
            com_api_error_pkg.raise_error(
                i_error         => 'TERMINAL_ALREADY_EXIST'
              , i_env_param1    => l_terminal_number
            );

        elsif l_terminal_status = acq_api_const_pkg.TERMINAL_STATUS_CLOSED then
            com_api_error_pkg.raise_error(
                i_error         =>  'CANNOT_CHANGE_CLOSED_TERMINAL'
              , i_env_param1    =>  l_terminal_id
            );

        elsif l_command in (
            app_api_const_pkg.COMMAND_CREATE_OR_PROCEED
          , app_api_const_pkg.COMMAND_EXCEPT_OR_PROCEED
        ) then
            change_objects(
                i_appl_data_id         => i_appl_data_id
              , i_parent_appl_data_id  => i_parent_appl_data_id
              , i_merchant_id          => i_merchant_id
              , i_terminal_id          => l_terminal_id
              , i_inst_id              => i_inst_id
              , i_contract_id          => i_contract_id
            );

        elsif l_command in (
            app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
          , app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
        ) then
            change_terminal(
                i_appl_data_id         => i_appl_data_id
              , i_parent_appl_data_id  => i_parent_appl_data_id
              , i_merchant_id          => i_merchant_id
              , i_terminal_id          => l_terminal_id
              , i_contract_id          => i_contract_id
            );

        elsif l_command in (
            app_api_const_pkg.COMMAND_EXCEPT_OR_REMOVE
          , app_api_const_pkg.COMMAND_PROCEED_OR_REMOVE
        ) then
            close_terminal(
                i_terminal_id   => l_terminal_id
              , i_inst_id       => i_inst_id
            );

        else
            change_terminal(
                i_appl_data_id         => i_appl_data_id
              , i_parent_appl_data_id  => i_parent_appl_data_id
              , i_merchant_id          => i_merchant_id
              , i_terminal_id          => l_terminal_id
              , i_contract_id          => i_contract_id
            );
        end if;

    end if;

    cst_api_application_pkg.process_terminal_after (
        i_appl_data_id         => i_appl_data_id
      , i_parent_appl_data_id  => i_parent_appl_data_id
      , i_merchant_id          => i_merchant_id
      , i_inst_id              => i_inst_id
      , i_contract_id          => i_contract_id
      , i_customer_id          => i_customer_id
    );

    if l_terminal_id is not null then
        select seqnum
          into l_seqnum
          from acq_terminal
         where id = l_terminal_id;
         
        app_api_appl_object_pkg.add_object(
            i_appl_id           => app_api_application_pkg.get_appl_id
          , i_entity_type       => acq_api_const_pkg.ENTITY_TYPE_TERMINAL
          , i_object_id         => l_terminal_id
          , i_seqnum            => l_seqnum
        );
    else -- For new terminal
        select min(id)
          into l_terminal_id
          from acq_terminal t
         where t.terminal_number = l_terminal_number
           and t.contract_id     = nvl(i_contract_id, t.contract_id)
           and t.merchant_id     = nvl(i_merchant_id, t.merchant_id)
           and (t.status        != acq_api_const_pkg.TERMINAL_STATUS_CLOSED 
                   or t.status  is null);
    end if;

    app_api_note_pkg.process_note(
        i_appl_data_id => i_appl_data_id
      , i_entity_type  => acq_api_const_pkg.ENTITY_TYPE_TERMINAL
      , i_object_id    => l_terminal_id
    );

exception
    when com_api_error_pkg.e_application_error then
        app_api_error_pkg.intercept_error(
            i_appl_data_id  => i_appl_data_id
          , i_element_name  => 'TERMINAL'
        );
end;

begin
    g_cud_codes.delete;

    g_cud_codes(1)  := '0';
    g_cud_codes(2)  := '1';
    g_cud_codes(3)  := '2';
    g_cud_codes(4)  := '3';
    g_cud_codes(5)  := '4';
    g_cud_codes(6)  := '5';
    g_cud_codes(7)  := '6';
    g_cud_codes(8)  := '7';
    g_cud_codes(9)  := '8';
    g_cud_codes(10) := '9';
    g_cud_codes(11) := 'A';
    g_cud_codes(12) := 'B';
    g_cud_codes(13) := 'C';
    g_cud_codes(14) := 'D';
    g_cud_codes(15) := 'E';
    g_cud_codes(16) := 'F';
    g_cud_codes(17) := 'G';
    g_cud_codes(18) := 'H';
    g_cud_codes(19) := 'I';
    g_cud_codes(20) := 'J';
    g_cud_codes(21) := 'K';
    g_cud_codes(22) := 'L';
    g_cud_codes(23) := 'M';
    g_cud_codes(24) := 'N';
    g_cud_codes(25) := 'O';
    g_cud_codes(26) := 'P';
    g_cud_codes(27) := 'Q';
    g_cud_codes(28) := 'R';
    g_cud_codes(29) := 'S';
    g_cud_codes(30) := 'T';
    g_cud_codes(31) := 'U';
    g_cud_codes(32) := 'V';
    g_cud_codes(33) := 'W';
    g_cud_codes(34) := 'X';
    g_cud_codes(35) := 'Y';
    g_cud_codes(36) := 'Z';

end;
/
