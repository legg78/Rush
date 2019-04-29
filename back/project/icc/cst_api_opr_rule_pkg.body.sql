create or replace package body cst_api_opr_rule_pkg is
/*********************************************************
 *  Custom processing API for ICC <br />
 **********************************************************/

procedure get_amount_value is
    l_amount                        com_api_type_pkg.t_amount_rec;
    l_macros_type                   com_api_type_pkg.t_tiny_id;
    l_macros_amount                 com_api_type_pkg.t_money;
    l_macros_currency               com_api_type_pkg.t_curr_code;
begin
    opr_api_shared_data_pkg.get_amount(
        i_name      => opr_api_shared_data_pkg.get_param_char('AMOUNT_NAME')
      , o_amount    => l_amount.amount
      , o_currency  => l_amount.currency
    );

    l_macros_type := opr_api_shared_data_pkg.get_param_num(
                         i_name         => 'MACROS_TYPE'
                       , i_mask_error   => com_api_type_pkg.TRUE
                       , i_error_value  => null
                     );

    if l_macros_type is not null then
        select amount
             , currency
          into l_macros_amount
             , l_macros_currency
          from acc_macros
         where entity_type      = opr_api_const_pkg.ENTITY_TYPE_OPERATION
           and object_id        = opr_api_shared_data_pkg.g_operation.original_id
           and macros_type_id   = l_macros_type;

        opr_api_shared_data_pkg.set_param(
            i_name      => 'FX_AMT_VALUE'
          , i_value     => l_macros_amount
        );

        opr_api_shared_data_pkg.set_amount(
            i_name      => opr_api_shared_data_pkg.get_param_char('AMOUNT_NAME')
          , i_amount    => l_macros_amount
          , i_currency  => l_macros_currency
        );
    else
        opr_api_shared_data_pkg.set_param(
            i_name      => 'FX_AMT_VALUE'
          , i_value     => l_amount.amount
        );
    end if;

exception
    when no_data_found then
        opr_api_shared_data_pkg.set_param(
            i_name      => 'FX_AMT_VALUE'
          , i_value     => 0
        );

        opr_api_shared_data_pkg.set_amount(
            i_name      => opr_api_shared_data_pkg.get_param_char('AMOUNT_NAME')
          , i_amount    => 0
          , i_currency  => null
        );
    when too_many_rows then
        opr_api_shared_data_pkg.set_param (
            i_name      => 'FX_AMT_VALUE'
          , i_value     => l_amount.amount
        );

        opr_api_shared_data_pkg.set_amount(
            i_name      => opr_api_shared_data_pkg.get_param_char('AMOUNT_NAME')
          , i_amount    => 0
          , i_currency  => null
        );
end;

procedure check_card_activated is
    l_entity_type                   com_api_type_pkg.t_name;
    l_account_name                  com_api_type_pkg.t_name;
    l_party_type                    com_api_type_pkg.t_name;
    l_object_id                     com_api_type_pkg.t_long_id;
    l_inst_id                       com_api_type_pkg.t_inst_id;
    l_oper_reason                   com_api_type_pkg.t_dict_value;
    l_seq_number                    com_api_type_pkg.t_tiny_id;
    l_number_of_activations         number(8);
    l_expir_date                    date;
begin
    l_entity_type  := iss_api_const_pkg.ENTITY_TYPE_CARD;
    l_account_name := opr_api_shared_data_pkg.get_param_char(i_name => 'ACCOUNT_NAME', i_mask_error => com_api_type_pkg.TRUE);
    l_party_type   := 'PRTYISS';
    
    l_oper_reason := coalesce(
                         opr_api_shared_data_pkg.get_operation().oper_reason
                       , opr_api_shared_data_pkg.get_param_char('OPER_REASON')
                     );

    l_object_id := opr_api_shared_data_pkg.get_object_id(
                       io_entity_type   => l_entity_type
                     , i_account_name   => l_account_name
                     , i_party_type     => l_party_type
                     , o_inst_id        => l_inst_id
                   );

    l_seq_number := opr_api_shared_data_pkg.get_participant(l_party_type).card_seq_number;
    l_expir_date := opr_api_shared_data_pkg.get_participant(l_party_type).card_expir_date;

    
    l_object_id := iss_api_card_instance_pkg.get_card_instance_id(
                       i_card_id     => l_object_id
                     , i_seq_number  => l_seq_number
                     , i_expir_date  => l_expir_date
                     , i_state       => iss_api_const_pkg.CARD_STATE_ACTIVE
                     , i_raise_error => com_api_type_pkg.TRUE
                   );

    select count(status)
      into l_number_of_activations
      from evt_status_log
     where object_id    = l_object_id
       and status       = 'CSTS0000';

    trc_log_pkg.debug(
        i_text          => 'Number of activations: [#1] '
      , i_env_param1    => l_number_of_activations
    );

    if l_number_of_activations = 0 then
        opr_api_shared_data_pkg.set_param(
            i_name      => 'IS_ACTIVATED'
          , i_value     => com_api_type_pkg.FALSE
        );
    else
        opr_api_shared_data_pkg.set_param(
            i_name      => 'IS_ACTIVATED'
          , i_value     => com_api_type_pkg.TRUE
        );
    end if;

    trc_log_pkg.debug(
        i_text          => 'IS ACTIVATED TP: [#1] '
      , i_env_param1    => opr_api_shared_data_pkg.get_param_num('IS_ACTIVATED')
    );
end check_card_activated;

procedure limit_fee_amount is
    l_source_amount                 com_api_type_pkg.t_amount_rec;
    l_source_amount_name            com_api_type_pkg.t_name;
    l_result_amount_name            com_api_type_pkg.t_name;
    l_entity_type                   com_api_type_pkg.t_name;
    l_object_id                     com_api_type_pkg.t_long_id;
    l_attribute_id                  com_api_type_pkg.t_long_id;
    l_attribute_value               com_api_type_pkg.t_long_id;
    l_count_limit                   com_api_type_pkg.t_long_id;
    l_sum_limit                     com_api_type_pkg.t_long_id;
    l_limit_currency                com_api_type_pkg.t_curr_code;
    l_end_date_count                com_api_type_pkg.t_long_id;
    l_time_diff                     com_api_type_pkg.t_long_id;    
    l_event_date                    com_api_type_pkg.t_date_long;
begin
    l_entity_type := evt_api_shared_data_pkg.get_param_char('ENTITY_TYPE');

    trc_log_pkg.debug(
        i_text          => 'Entity type: [#1] '
      , i_env_param1    => l_entity_type 
    );

    l_attribute_id := evt_api_shared_data_pkg.get_param_num('PRODUCT_ATTRIBUTE');

    l_attribute_value := evt_api_shared_data_pkg.get_param_num('ATTRIBUTE_VALUE');

    l_event_date := evt_api_shared_data_pkg.get_param_num('EVENT_DATE');

    trc_log_pkg.debug(
        i_text          => 'Attribute ID: [#1] Attribute value: [#2]'
      , i_env_param1    => l_attribute_id
      , i_env_param2    => l_attribute_value
    );

    l_object_id := evt_api_shared_data_pkg.get_param_num('OBJECT_ID');

    trc_log_pkg.debug(
        i_text          => 'Object ID: [#1] '
      , i_env_param1    => l_object_id 
    );

    -- this goes as input param of the rule
    l_source_amount_name := evt_api_shared_data_pkg.get_param_char('AMOUNT_NAME');

    evt_api_shared_data_pkg.get_amount(
        i_name          => l_source_amount_name
      , o_amount        => l_source_amount.amount 
      , o_currency      => l_source_amount.currency 
    );

    -- this goes as output param of the rule
    l_result_amount_name := evt_api_shared_data_pkg.get_param_char('RESULT_AMOUNT_NAME');
    
    evt_api_shared_data_pkg.set_amount(
        i_name      => l_result_amount_name
      , i_amount    => 0
      , i_currency  => l_source_amount.currency
    );

    -- ignore period change
    select extract(day from diff) * 24 * 60 * 60 * 1000
         + extract(hour from diff) * 60 * 60 * 1000
         + extract(minute from diff) * 60 * 1000
         + round(extract(second from diff) * 1000)
      into l_time_diff 
      from (select systimestamp - register_timestamp diff
              from prd_attribute_value
             where attr_value   = l_attribute_value
               and object_id    = l_object_id
               and attr_id      = l_attribute_id
           );

    trc_log_pkg.debug(
        i_text          => ' time difference: [#1] '
      , i_env_param1    => l_time_diff 
    );
    
    if l_time_diff < 1000 then

        -- get 1 into_l_end_date to ignore end_date
        select count(end_date)
          into l_end_date_count
          from prd_attribute_value
         where attr_value   = l_attribute_value
           and object_id    = l_object_id
           and attr_id      = l_attribute_id
           and end_date     = to_date(l_event_date, 'YYYYMMDDHH24MISS');

        trc_log_pkg.debug(
            i_text          => 'End_date: [#1] '
          , i_env_param1    => l_end_date_count 
        );
       
        -- ignore end date
        if l_end_date_count <> 1 then
    
            select count_limit
                 , sum_limit
                 , currency
              into l_count_limit
                 , l_sum_limit
                 , l_limit_currency
              from fcl_limit
             where id = l_attribute_value;    

            trc_log_pkg.debug(
                i_text          => 'Limit: [#1] [#2]'
              , i_env_param1    => l_count_limit
              , i_env_param2    => l_sum_limit
            );

            if l_count_limit <> 0 and l_sum_limit <> 0 then
                evt_api_shared_data_pkg.set_amount(
                    i_name      => l_result_amount_name
                  , i_amount    => l_source_amount.amount
                  , i_currency  => l_source_amount.currency
                );
            end if;
        end if;  
    end if;    

exception
    when no_data_found then
        com_api_error_pkg.raise_error(
            i_error         => 'LIMIT_VALUE_NOT_FOUND'
          , i_env_param1    => l_attribute_id
        );
end;

end cst_api_opr_rule_pkg;
/