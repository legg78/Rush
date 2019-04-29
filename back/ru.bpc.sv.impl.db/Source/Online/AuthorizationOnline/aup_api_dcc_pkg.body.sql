create or replace package body aup_api_dcc_pkg is
/****************************************************************************
 *  The package for processing authorizations with DCC functionality <br />
 *
 *  Created by B. Madan (madan@bpcbt.com) at 31.12.2014 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate$ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: aup_api_dcc_pkg <br />
 *  @headcom
 ****************************************************************************/

/****************************************************************************
 *
 * The function returns the currency of the card's account.
 *
 * @param i_card_number  Card number (Primary Account Number)
 * @return Currency of the card's account
 *
 ****************************************************************************/
function get_currency_by_card_number (
    i_card_number  in  com_api_type_pkg.t_card_number
) return
    com_api_type_pkg.t_curr_code
is
    l_currency     com_api_type_pkg.t_curr_code;
    l_pan_prefix   com_api_type_pkg.t_card_number;

begin
    trc_log_pkg.debug (
        i_text       => 'get_currency_by_card_number: card number [#1]'
      , i_env_param1 => iss_api_card_pkg.get_card_mask(i_card_number)
    );

    -- Trying to get currency via VISA account billing currency file
    select
        max(currency) keep (dense_rank last order by load_date)
    into
        l_currency
    from
        vis_acc_billing_currency
    where
        i_card_number between low_range and high_range;

    if l_currency is not null then
        trc_log_pkg.debug (
            i_text       => 'Currency has been successfully determinated via VISA account billing currency file, currency code [#1]'
          , i_env_param1 => l_currency
        );
    else
        -- Get currency using BIN ranges
        begin
            l_pan_prefix := substr(i_card_number, 1, net_api_bin_pkg.BIN_INDEX_LENGTH);
            select
                curr_code
            into
                l_currency
            from (
                select
                    nvl(b.account_currency, c.curr_code) as curr_code
                from
                    net_bin_range_index i
                  , net_bin_range b
                  , net_network n
                  , com_country c
                where
                    i.pan_prefix = l_pan_prefix and
                    i_card_number between substr(i.pan_low, 1, length(i_card_number)) and substr(i.pan_high, 1, length(i_card_number)) and
                    i.pan_low = b.pan_low and
                    i.pan_high = b.pan_high and
                    b.iss_network_id = n.id and
                    c.code = b.country
                order by
                    net_cst_bin_pkg.bin_table_scan_priority (
                        i_network_id  => n.id
                    )
                  , net_cst_bin_pkg.extra_scan_priority (
                        i_card_number => i_card_number
                      , i_network_id  => n.id
                    )
                  , net_cst_bin_pkg.advances_scan_priority (
                        i_card_number => i_card_number
                      , i_pan_low     => i.pan_low
                      , i_network_id  => n.id
                    )
                  , n.bin_table_scan_priority
                  , utl_match.jaro_winkler_similarity(i.pan_low, rpad(i_card_number, length(i.pan_low), '0')) desc
                  , b.priority
            ) where
                rownum = 1;
            trc_log_pkg.debug (
                i_text       => 'Currency has been successfully determinated through bin ranges, currency code [#1]'
              , i_env_param1 => l_currency
            );
        exception
            when no_data_found then
                trc_log_pkg.debug (i_text => 'Currency was not found through bin ranges...');
        end;
    end if;

    return l_currency;
end get_currency_by_card_number;

/****************************************************************************
 *
 * The function checks for DCC is possible for the operation on the terminal.
 * If it is possible then the function returns DCC conversion parameters.
 *
 * @param i_terminal_id         Terminal's ID
 * @param i_card_number         Card number (Primary Account Number)
 * @param i_amount              Amount of the operation
 * @param i_currency            Currency of the operation
 * @param o_conversion_amount   Resulted amount in conversion currency
 * @param o_conversion_currency Currency for conversion
 * @param o_conversion_rate     Rate used for conversion
 * @param o_conversion_fee      Fee for using of DCC
 * @return TRUE or FALSE depending on the DCC checks result
 *
 ****************************************************************************/
function is_dcc_possible (
    i_terminal_id           in com_api_type_pkg.t_short_id
  , i_card_number           in com_api_type_pkg.t_card_number
  , i_amount                in com_api_type_pkg.t_money
  , i_currency              in com_api_type_pkg.t_curr_code
  , o_conversion_amount    out com_api_type_pkg.t_money
  , o_conversion_currency  out com_api_type_pkg.t_curr_code
  , o_conversion_rate      out com_api_type_pkg.t_rate
  , o_conversion_fee       out com_api_type_pkg.t_money
) return
    com_api_type_pkg.t_boolean
is
    l_no_dcc_msg_text   constant com_api_type_pkg.t_text       := 'DCC is not available. [#1]';
    l_attr_dcc_conv_fee constant com_api_type_pkg.t_name       := 'ACQ_DCC_CONVERSION_FEE';
    l_dcc_conv_fee_type constant com_api_type_pkg.t_dict_value := 'FETP0219';

    l_service_id                 com_api_type_pkg.t_short_id;
    l_split_hash                 com_api_type_pkg.t_tiny_id;
    l_eff_date                   date;
    l_inst_id                    com_api_type_pkg.t_inst_id;
    l_product_id                 com_api_type_pkg.t_short_id;
    l_params                     com_api_type_pkg.t_param_tab;
    l_conversion_fee_id          com_api_type_pkg.t_short_id;
    l_conversion_fee_amount      com_api_type_pkg.t_money;
    l_currency                   com_api_type_pkg.t_curr_code := i_currency;
    l_amount                     com_api_type_pkg.t_money     := i_amount;
    l_conv_currency              com_api_type_pkg.t_curr_code;
    l_conv_amount                com_api_type_pkg.t_money;
    l_conv_rate                  com_api_type_pkg.t_money;
    l_src_exponent               com_api_type_pkg.t_tiny_id;
    l_dst_exponent               com_api_type_pkg.t_tiny_id;
    
begin
    trc_log_pkg.set_object (
        i_entity_type => acq_api_const_pkg.ENTITY_TYPE_TERMINAL
      , i_object_id   => i_terminal_id
    );
    
    trc_log_pkg.debug (
        i_text       => 'Check for DCC availability: i_terminal_id [#1], i_card_number [#2], i_amount [#3], i_currency [#4]'
      , i_env_param1 => i_terminal_id
      , i_env_param2 => i_card_number
      , i_env_param3 => i_amount
      , i_env_param4 => i_currency
    );

    l_split_hash := com_api_hash_pkg.get_split_hash(acq_api_const_pkg.ENTITY_TYPE_TERMINAL, i_terminal_id);
    l_inst_id := ost_api_institution_pkg.get_object_inst_id (
                     i_entity_type => acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                   , i_object_id   => i_terminal_id
                   , i_mask_errors => com_api_type_pkg.TRUE
                 );
    if l_inst_id is null then
        trc_log_pkg.debug (
            i_text       => l_no_dcc_msg_text
          , i_env_param1 => 'Institute for terminal can not be detected.'
        );
        trc_log_pkg.clear_object;
        return com_api_const_pkg.FALSE;
    end if;
    l_eff_date := com_api_sttl_day_pkg.get_calc_date(i_inst_id => l_inst_id);
    trc_log_pkg.debug (
        i_text       => 'l_inst_id [#1], l_eff_date [#2], l_split_hash [#3]'
      , i_env_param1 => l_inst_id
      , i_env_param2 => to_char(l_eff_date, 'dd.mm.yyyy hh24:mi:ss')
      , i_env_param3 => l_split_hash
    );

    -- Check amount and currency (nor equals to zero or null)
    if nvl(l_amount, 0) = 0 or l_currency is null then
        trc_log_pkg.debug (
            i_text       => l_no_dcc_msg_text
          , i_env_param1 => 'Illegal amount or currency used.'
        );
        trc_log_pkg.clear_object;
        return com_api_const_pkg.FALSE;
    end if;

    -- Check for existence of DCC service for terminal
    l_service_id := prd_api_service_pkg.get_active_service_id (
        i_entity_type => acq_api_const_pkg.ENTITY_TYPE_TERMINAL
      , i_object_id   => i_terminal_id
      , i_attr_name   => l_attr_dcc_conv_fee
      , i_eff_date    => l_eff_date
      , i_split_hash  => l_split_hash
      , i_mask_error  => com_api_type_pkg.TRUE
    );
    if l_service_id is null then
        trc_log_pkg.debug (
            i_text       => l_no_dcc_msg_text
          , i_env_param1 => 'No appropriate service on terminal.'
        );
        trc_log_pkg.clear_object;
        return com_api_const_pkg.FALSE;
    end if;
    trc_log_pkg.debug (
        i_text       => 'DCC service found. Service ID [#1]'
      , i_env_param1 => l_service_id
    );

    -- Get conversion fee
    l_product_id := prd_api_product_pkg.get_product_id (
        i_entity_type => acq_api_const_pkg.ENTITY_TYPE_TERMINAL
      , i_object_id   => i_terminal_id
      , i_eff_date    => l_eff_date
      , i_inst_id     => l_inst_id
    );
    begin
        l_conversion_fee_id := prd_api_product_pkg.get_fee_id (
            i_product_id  => l_product_id
          , i_entity_type => acq_api_const_pkg.ENTITY_TYPE_TERMINAL
          , i_object_id   => i_terminal_id
          , i_fee_type    => l_dcc_conv_fee_type
          , i_params      => l_params
          , i_service_id  => l_service_id
          , i_eff_date    => l_eff_date
          , i_split_hash  => l_split_hash
          , i_inst_id     => l_inst_id
        );
        trc_log_pkg.debug (
            i_text       => 'DCC conversion fee ID [#1]'
          , i_env_param1 => l_conversion_fee_id
        );
        l_conversion_fee_amount := nvl(fcl_api_fee_pkg.get_fee_amount (
            i_fee_id         => l_conversion_fee_id
          , i_base_amount    => l_amount
          , io_base_currency => l_currency
          , i_entity_type    => acq_api_const_pkg.ENTITY_TYPE_TERMINAL
          , i_object_id      => i_terminal_id
          , i_eff_date       => l_eff_date
          , i_split_hash     => l_split_hash
        ), 0);
    exception
        when others then
            if com_api_error_pkg.is_application_error(sqlcode) = com_api_type_pkg.TRUE then
                if com_api_error_pkg.get_last_error = 'FEE_NOT_DEFINED' then
                    trc_log_pkg.debug (
                        i_text       => l_no_dcc_msg_text
                      , i_env_param1 => 'Conversion fee not defined.'
                    );
                    l_conversion_fee_amount := 0;
                else
                    raise;
                end if;
            else
                raise;
            end if;
    end;
    l_amount := l_amount + l_conversion_fee_amount;
    trc_log_pkg.debug (
        i_text       => 'conversion fee amount [#1], overall amount [#2]'
      , i_env_param1 => l_conversion_fee_amount
      , i_env_param2 => l_amount
    );

    -- Get cardholder's currency
    l_conv_currency := get_currency_by_card_number(i_card_number);
    if l_conv_currency is null then
        trc_log_pkg.debug (
            i_text       => l_no_dcc_msg_text
          , i_env_param1 => 'Unable to determine the cardholder''s currency.'
        );
        trc_log_pkg.clear_object;
        return com_api_const_pkg.FALSE;
    end if;
    if l_conv_currency = i_currency then
        trc_log_pkg.debug (
            i_text       => l_no_dcc_msg_text
          , i_env_param1 => 'Cardholder''s currency and operation''s currency are the same.'
        );
        trc_log_pkg.clear_object;
        return com_api_const_pkg.FALSE;
    end if;

    -- Get DCC conversion rate
    l_conv_rate := com_api_rate_pkg.get_rate (
        i_src_currency    => l_currency
      , i_dst_currency    => l_conv_currency
      , i_rate_type       => aup_api_const_pkg.DCC_RATE_TYPE
      , i_inst_id         => l_inst_id
      , i_eff_date        => l_eff_date
      , i_mask_exception  => com_api_type_pkg.TRUE
      , i_exception_value => null
    );
    if l_conv_rate is null then
        trc_log_pkg.debug (
            i_text       => l_no_dcc_msg_text
          , i_env_param1 => 'Unable to determine the conversion rate.'
        );
        trc_log_pkg.clear_object;
        return com_api_const_pkg.FALSE;
    end if;
    trc_log_pkg.debug (
        i_text       => 'conversion rate [#1]'
      , i_env_param1 => l_conv_rate
    );

    -- Convert the amount to the cardholder's currency
    l_conv_amount := com_api_rate_pkg.convert_amount (
        i_src_amount      => l_amount
      , i_src_currency    => l_currency
      , i_dst_currency    => l_conv_currency
      , i_rate_type       => aup_api_const_pkg.DCC_RATE_TYPE
      , i_inst_id         => l_inst_id
      , i_eff_date        => l_eff_date
      , i_mask_exception  => com_api_type_pkg.TRUE
      , i_exception_value => null
      , i_conversion_type => com_api_const_pkg.CONVERSION_TYPE_SELLING
    );
    if l_conv_amount is null then
        trc_log_pkg.debug (
            i_text       => l_no_dcc_msg_text
          , i_env_param1 => 'Unable to convert operation amount to cardholder''s currency.'
        );
        trc_log_pkg.clear_object;
        return com_api_const_pkg.FALSE;
    end if;
    trc_log_pkg.debug (
        i_text       => 'operation amount in the cardholder''s currency = [#1]'
      , i_env_param1 => l_conv_amount
    );

    -- Convert amounts to the sums represented in copecks
    l_src_exponent := com_api_currency_pkg.get_currency_exponent(i_currency);
    if l_src_exponent is null then
        trc_log_pkg.debug (
            i_text       => l_no_dcc_msg_text
          , i_env_param1 => 'Unable to get exponent for source currency with code ' || i_currency || '.'
        );
        trc_log_pkg.clear_object;
        return com_api_const_pkg.FALSE;
    end if;
    l_dst_exponent := com_api_currency_pkg.get_currency_exponent(l_conv_currency);
    if l_dst_exponent is null then
        trc_log_pkg.debug (
            i_text       => l_no_dcc_msg_text
          , i_env_param1 => 'Unable to get exponent for destination currency with code ' || l_conv_currency || '.'
        );
        trc_log_pkg.clear_object;
        return com_api_const_pkg.FALSE;
    end if;
    l_conversion_fee_amount := round(l_conversion_fee_amount * power(10, l_src_exponent));
    l_conv_amount := round(l_conv_amount * power(10, l_dst_exponent));

    -- Successful, DCC conversion is available
    o_conversion_amount   := l_conv_amount;
    o_conversion_currency := l_conv_currency;
    o_conversion_rate     := l_conv_rate * 10000;  -- Mult to 10000 because FE needs integral value
    o_conversion_fee      := l_conversion_fee_amount;
    trc_log_pkg.debug(i_text => 'DCC conversion is available!');

    trc_log_pkg.clear_object;
    return com_api_const_pkg.TRUE;
end;

end aup_api_dcc_pkg;
/
