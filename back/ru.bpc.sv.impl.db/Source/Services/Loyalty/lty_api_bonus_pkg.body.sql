create or replace package body lty_api_bonus_pkg as
/*********************************************************
 *  API for loyalty bonus <br />
 *  Created by Kopachev D.(kopachev@bpc.ru)  at 18.11.2009 <br />
 *  Module: lty_api_bonus_pkg <br />
 *  @headcom
 **********************************************************/

function get_service_type_id(
    i_entity_type  in com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_short_id is
begin
    if i_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD then
        return lty_api_const_pkg.LOYALTY_SERVICE_TYPE_ID;
    elsif i_entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT then
        return lty_api_const_pkg.LOYALTY_SERVICE_MRCH_TYPE_ID;
    elsif i_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
        return lty_api_const_pkg.LOYALTY_SERVICE_ACC_TYPE_ID;
    elsif i_entity_type = com_api_const_pkg.ENTITY_TYPE_CUSTOMER then
        return lty_api_const_pkg.LOYALTY_SERVICE_CUST_TYPE_ID;
    else
        com_api_error_pkg.raise_error(
            i_error       => 'UNKNOWN_ENTITY_TYPE'
          , i_env_param1  => i_entity_type
        );
    end if;
end;

function get_fee_type(
    i_entity_type  in com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_dict_value is
begin
    if i_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD then
        return lty_api_const_pkg.LOYALTY_FEE_TYPE;
    elsif i_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
        return lty_api_const_pkg.LOYALTY_ACCOUNT_FEE_TYPE;
    elsif i_entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT then
        return lty_api_const_pkg.LOYALTY_MERCHANT_FEE_TYPE;
    elsif i_entity_type = com_api_const_pkg.ENTITY_TYPE_CUSTOMER then
        return lty_api_const_pkg.LOYALTY_CUSTOMER_FEE_TYPE;
    end if;
end;

function get_start_cycle_type(
    i_entity_type  in com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_dict_value is
begin
    if i_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD then
        return lty_api_const_pkg.LOYALTY_START_CYCLE_TYPE;
    elsif i_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
        return lty_api_const_pkg.LOYALTY_ACC_START_CYCLE_TYPE;
    elsif i_entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT then
        return lty_api_const_pkg.LOYALTY_MRCH_START_CYCLE_TYPE;
    elsif i_entity_type = com_api_const_pkg.ENTITY_TYPE_CUSTOMER then
        return lty_api_const_pkg.LOYALTY_CUST_START_CYCLE_TYPE;
    end if;
end;

function get_expire_cycle_type(
    i_entity_type  in com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_dict_value is
begin
    if i_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD then
        return lty_api_const_pkg.LOYALTY_EXPIRE_CYCLE_TYPE;
    elsif i_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
        return lty_api_const_pkg.LOYALTY_ACC_EXPIRE_CYCLE_TYPE;
    elsif i_entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT then
        return lty_api_const_pkg.LOYALTY_MRCH_EXPIRE_CYCLE_TYPE;
    elsif i_entity_type = com_api_const_pkg.ENTITY_TYPE_CUSTOMER then
        return lty_api_const_pkg.LOYALTY_CUST_EXPIRE_CYCLE_TYPE;
    end if;
end;

function decode_attr_name(
    i_attr_name    in com_api_type_pkg.t_name
  , i_entity_type  in com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_name is
begin
    if i_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD then
        return i_attr_name;
    else
        return i_attr_name || '_' || i_entity_type;
    end if;
end;

procedure get_card_id(
    i_entity_type      in      com_api_type_pkg.t_dict_value
  , i_object_id        in      com_api_type_pkg.t_long_id
  , o_card_id          out     com_api_type_pkg.t_medium_id
) as
begin
    if i_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
        select min(c.id)
          into o_card_id
          from acc_account_object o
             , iss_card c
         where o.account_id  = i_object_id
           and o.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
           and c.id          = o.object_id;

    elsif i_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD then
        select id
          into o_card_id
          from iss_card
         where id = i_object_id;

    elsif i_entity_type = com_api_const_pkg.ENTITY_TYPE_CUSTOMER then
        select min(c.id)
          into o_card_id
          from acc_account acc
             , acc_account_object o
             , iss_card c
         where acc.customer_id = i_object_id
           and o.account_id    = acc.id
           and o.entity_type   = iss_api_const_pkg.ENTITY_TYPE_CARD
           and c.id            = o.object_id;
    end if;
end;

procedure get_input_object_service(
    io_entity_type     in out com_api_type_pkg.t_dict_value
  , io_object_id       in out com_api_type_pkg.t_long_id
  , i_eff_date         in     date
  , i_inst_id          in     com_api_type_pkg.t_inst_id default null
  , i_param_tab        in     com_api_type_pkg.t_param_tab
  , i_mask_error       in     com_api_type_pkg.t_boolean     default com_api_const_pkg.FALSE
  , o_account             out acc_api_type_pkg.t_account_rec
  , o_service_id          out com_api_type_pkg.t_short_id
  , o_product_id          out com_api_type_pkg.t_short_id
  , o_object_is_lty_acc   out com_api_type_pkg.t_boolean
)
as
    l_lty_entity_type    com_api_type_pkg.t_dict_value;
    l_lty_object_id      com_api_type_pkg.t_long_id;
    l_lty_account_type   com_api_type_pkg.t_dict_value;
    l_inst_id            com_api_type_pkg.t_inst_id;
begin
    trc_log_pkg.debug(
        i_text       => 'get_input_object_service: , i_entity_type [#1], i_object_id [#2]'
                     || '], i_mask_error [' || i_mask_error || ']'
      , i_env_param1 => io_entity_type
      , i_env_param2 => io_object_id 
    );
    
    o_object_is_lty_acc := com_api_const_pkg.FALSE;
    l_inst_id  := coalesce(i_inst_id
                         , ost_api_institution_pkg.get_object_inst_id(
                               i_entity_type => io_entity_type
                             , i_object_id   => io_object_id
                             , i_mask_errors => com_api_type_pkg.TRUE
                           )
                  );

    -- in case of account - there are additional checks of lty account type
    if io_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then

        -- service can be attached to something else than i_entity_type, read comment bellow for details
        o_account :=
            acc_api_account_pkg.get_account(
                i_account_id     => io_object_id
              , i_account_number => null
              , i_inst_id        => null
              , i_mask_error     => com_api_const_pkg.FALSE
            );
        
        begin
            select o.service_id
                 , o.entity_type
                 , o.object_id
              into o_service_id
                 , l_lty_entity_type
                 , l_lty_object_id
              from prd_contract c
                 , prd_service s
                 , prd_service_object o
            where o.contract_id     = o_account.contract_id
              and o.service_id      = s.id
              and s.service_type_id in (lty_api_const_pkg.LOYALTY_SERVICE_TYPE_ID
                                      , lty_api_const_pkg.LOYALTY_SERVICE_ACC_TYPE_ID
                                      , lty_api_const_pkg.LOYALTY_SERVICE_MRCH_TYPE_ID)
              and o.contract_id     = c.id
              and (i_eff_date >= o.start_date or o.start_date is null)
              and (i_eff_date <= o.end_date   or o.end_date   is null)
              and rownum = 1;
        exception
            when no_data_found then
                if i_mask_error = com_api_const_pkg.TRUE then
                    trc_log_pkg.debug('get_input_object_service: unable to find loyalty service for contract [' ||
                                      o_account.contract_id || '], exit from procedure');
                    return;
                else
                    com_api_error_pkg.raise_error(
                        i_error       => 'PRD_NO_ACTIVE_SERVICE'
                      , i_env_param1  => io_entity_type
                      , i_env_param2  => io_object_id
                      , i_env_param4  => i_eff_date
                      , i_entity_type => io_entity_type
                      , i_object_id   => io_object_id
                    );
                end if;
        end;

        o_product_id := prd_api_product_pkg.get_product_id(
            i_entity_type  => l_lty_entity_type
          , i_object_id    => l_lty_object_id
        );

        l_lty_account_type := prd_api_product_pkg.get_attr_value_char(
            i_product_id   => o_product_id
          , i_entity_type  => io_entity_type
          , i_object_id    => io_object_id
          , i_attr_name    => decode_attr_name(
                                  i_attr_name    => lty_api_const_pkg.LOYALTY_ATTR_ACC_TYPE
                                , i_entity_type  => l_lty_entity_type
                              )
          , i_params       => i_param_tab
          , i_service_id   => o_service_id
          , i_eff_date     => i_eff_date
          , i_inst_id      => l_inst_id
        );

        trc_log_pkg.debug(
            i_text => 'get_input_object_service: service_id [' || o_service_id ||
                      '], lty_account_type [' || l_lty_account_type ||
                      '], lty_entity_type [' || l_lty_entity_type ||
                      '], lty_object_id [' || l_lty_object_id || ']'
        );

        -- in case of account it is possible to use procedure create_bonus/spend_bonus in two different ways:
        -- 1st - account is NOT lty account of customer and service is attached to this account - we calculate bonus from oper_amount
        -- 2nd - account IS lty account of customer, service attached to something else (to card for example) and oper_amount is amount to be created as bonus
        -- in 2nd case we don't need to get service from object and to calculate bonus amount
        if l_lty_account_type != o_account.account_type or l_lty_account_type is null then
            o_object_is_lty_acc := com_api_const_pkg.FALSE;
        else
            o_object_is_lty_acc := com_api_const_pkg.TRUE;
            
            -- determine service object more precisely
            select o.object_id, o.entity_type
              into io_object_id, io_entity_type
              from acc_account_object o
             where o.account_id = io_object_id;

            trc_log_pkg.debug('get_input_object_service: actual l_object_id [' || io_object_id ||
                              '], l_entity_type [' || io_entity_type || ']');
        end if;
    end if;
    
    trc_log_pkg.debug('get_input_object_service: object_is_lty_acc [' || o_object_is_lty_acc || ']');

    if o_object_is_lty_acc = com_api_const_pkg.FALSE then
        get_lty_account_info(
            i_entity_type      => io_entity_type
          , i_object_id        => io_object_id
          , i_inst_id          => l_inst_id
          , i_eff_date         => i_eff_date
          , i_mask_error       => i_mask_error
          , o_account          => o_account
          , o_service_id       => o_service_id
          , o_product_id       => o_product_id
        );
    end if;
    
    trc_log_pkg.debug(
        i_text =>  'get_input_object_service: FINISHED; account_id [' || o_account.account_id ||
                   '], currency [' || o_account.currency || ']' ||
                   '], service_id [' || o_service_id || ']' ||
                   '], product_id [' || o_product_id || ']'
    );
end;

procedure check_balance_min_threshold(
    i_entity_type             com_api_type_pkg.t_dict_value
  , i_object_id               com_api_type_pkg.t_long_id
  , i_split_hash              com_api_type_pkg.t_tiny_id
  , i_account                 acc_api_type_pkg.t_account_rec
  , i_product_id              com_api_type_pkg.t_long_id
  , i_service_id              com_api_type_pkg.t_short_id
  , i_eff_date                date
  , i_inst_id                 com_api_type_pkg.t_inst_id
) as
    l_fee_id                  com_api_type_pkg.t_short_id;
    l_fee_amount              com_api_type_pkg.t_money;
    l_balance_amount          com_api_type_pkg.t_money;
    l_currency                com_api_type_pkg.t_curr_code;
begin
    -- check is only for merchants
    if i_entity_type  <> acq_api_const_pkg.ENTITY_TYPE_MERCHANT then
        return;
    end if;
    
    trc_log_pkg.debug(
        i_text       => 'Checking Minimal threshold for redemption: '
                     || 'l_entity_type [#1], l_object_id [#2], l_eff_date [#3], o_product_id [#4], l_service_id [#5]'
      , i_env_param1 => i_entity_type
      , i_env_param2 => i_object_id
      , i_env_param3 => to_char(i_eff_date, com_api_const_pkg.LOG_DATE_FORMAT)
      , i_env_param4 => i_product_id
      , i_env_param5 => i_service_id
    );
    
    l_currency := i_account.currency;
    
    -- Check that Minimal threshold for redemption is defined
    begin
        l_fee_id :=
            prd_api_product_pkg.get_fee_id(
                i_product_id      => i_product_id
              , i_entity_type     => i_entity_type
              , i_object_id       => i_object_id
              , i_fee_type        => lty_api_const_pkg.LOYALTY_REDEM_MIN_THR_FEE_TYPE
              , i_params          => opr_api_shared_data_pkg.g_params
              , i_service_id      => i_service_id
              , i_eff_date        => i_eff_date
              , i_split_hash      => i_split_hash
              , i_inst_id         => i_inst_id
              , i_mask_error      => com_api_const_pkg.TRUE
            );
            
        trc_log_pkg.debug(
            i_text       => 'l_fee_id [' || l_fee_id || ']'
        );
        
        if l_fee_id is not null then
            l_fee_amount :=
                fcl_api_fee_pkg.get_fee_amount(
                    i_fee_id          => l_fee_id
                  , i_base_amount     => 0
                  , io_base_currency  => l_currency
                  , i_entity_type     => i_entity_type
                  , i_object_id       => i_object_id
                  , i_eff_date        => i_eff_date
                  , i_split_hash      => i_split_hash
                );
           trc_log_pkg.debug(
               i_text       => 'l_fee_amount [' || l_fee_amount || ']'
           );
        end if;
    exception
        when com_api_error_pkg.e_application_error then
            null;
    end;

    if l_fee_amount is not null then
        -- Stop operation processing if current loyalty points balance is less than a value of min threshold attribute
        l_balance_amount := acc_api_balance_pkg.get_aval_balance_amount_only(i_account_id => i_account.account_id);

        trc_log_pkg.debug(
            i_text       => 'l_balance_amount [' || l_balance_amount || ']'
        );

        if l_balance_amount < l_fee_amount then
            com_api_error_pkg.raise_error(
                i_error      => 'BALANCE_MIN_THRESHOLD_VIOLATED'
              , i_env_param1 => l_balance_amount
              , i_env_param2 => l_fee_amount
            );
        end if;
    end if;
end;

procedure create_bonus(
    i_entity_type      in     com_api_type_pkg.t_dict_value
  , i_object_id        in     com_api_type_pkg.t_long_id
  , i_posting_date     in     date
  , i_start_date       in     date
  , i_expire_date      in     date
  , i_oper_entity_type in     com_api_type_pkg.t_dict_value
  , i_oper_id          in     com_api_type_pkg.t_long_id
  , i_oper_date        in     date
  , i_macros_type      in     com_api_type_pkg.t_long_id
  , i_fee_type         in     com_api_type_pkg.t_dict_value
  , i_amount           in     com_api_type_pkg.t_money
  , i_account          in     acc_api_type_pkg.t_account_rec
  , i_card_id          in     com_api_type_pkg.t_medium_id
  , i_fee_id           in     com_api_type_pkg.t_short_id
  , i_service_id       in     com_api_type_pkg.t_short_id
  , i_product_id       in     com_api_type_pkg.t_short_id
  , i_inst_id          in     com_api_type_pkg.t_inst_id
  , i_spent_amount     in     com_api_type_pkg.t_money         default 0
  , i_param_tab        in     com_api_type_pkg.t_param_tab
  , o_macros_id        out    com_api_type_pkg.t_long_id
) is
    l_bunch_id                com_api_type_pkg.t_long_id;
begin
    acc_api_entry_pkg.put_macros (
        o_macros_id       => o_macros_id
      , o_bunch_id        => l_bunch_id
      , i_entity_type     => i_oper_entity_type
      , i_object_id       => i_oper_id
      , i_macros_type_id  => i_macros_type
      , i_amount          => i_amount
      , i_currency        => i_account.currency
      , i_account_type    => i_account.account_type
      , i_account_id      => i_account.account_id
      , i_posting_date    => i_start_date
      , i_fee_id          => i_fee_id
      , i_param_tab       => i_param_tab
    );
    acc_api_entry_pkg.flush_job;

    trc_log_pkg.debug('create_bonus: macros_id [' || o_macros_id || ']');

    if o_macros_id is not null then
        insert into lty_bonus_vw(
            id
          , account_id
          , card_id
          , product_id
          , service_id
          , oper_date
          , posting_date
          , start_date
          , expire_date
          , amount
          , spent_amount
          , status
          , inst_id
          , split_hash
          , entity_type
          , object_id
          , fee_type
        ) values (
            o_macros_id
          , i_account.account_id
          , i_card_id
          , i_product_id
          , i_service_id
          , i_oper_date
          , i_posting_date
          , i_start_date
          , i_expire_date
          , i_amount
          , i_spent_amount
          , lty_api_const_pkg.BONUS_TRANSACTION_ACTIVE
          , i_inst_id
          , i_account.split_hash
          , i_entity_type
          , i_object_id
          , i_fee_type
        );
    end if;
end;

procedure create_bonus(
    i_entity_type      in     com_api_type_pkg.t_dict_value
  , i_object_id        in     com_api_type_pkg.t_long_id
  , i_oper_entity_type in     com_api_type_pkg.t_dict_value
  , i_oper_id          in     com_api_type_pkg.t_long_id
  , i_oper_date        in     date
  , i_oper_amount      in     com_api_type_pkg.t_money
  , i_oper_currency    in     com_api_type_pkg.t_curr_code
  , i_macros_type      in     com_api_type_pkg.t_long_id
  , i_split_hash       in     com_api_type_pkg.t_tiny_id
  , i_inst_id          in     com_api_type_pkg.t_inst_id
  , i_rate_type        in     com_api_type_pkg.t_dict_value
  , i_conversion_type  in     com_api_type_pkg.t_dict_value    default null
  , i_fee_type         in     com_api_type_pkg.t_dict_value    default null
  , i_param_tab        in     com_api_type_pkg.t_param_tab
  , i_test_mode        in     com_api_type_pkg.t_dict_value    default null
  , o_result_amount       out com_api_type_pkg.t_amount_rec
  , o_result_account      out acc_api_type_pkg.t_account_rec
  , o_start_date          out date
  , o_expire_date         out date
) is
    l_account            acc_api_type_pkg.t_account_rec;
    l_service_id         com_api_type_pkg.t_short_id;
    l_card_id            com_api_type_pkg.t_medium_id;
    l_product_id         com_api_type_pkg.t_short_id;
    l_fee_id             com_api_type_pkg.t_short_id;
    l_fee_type           com_api_type_pkg.t_dict_value;
    l_amount             com_api_type_pkg.t_money;
    l_cycle_id           com_api_type_pkg.t_short_id;
    l_macros_id          com_api_type_pkg.t_long_id;
    l_customer_id        com_api_type_pkg.t_long_id;
    l_params             com_api_type_pkg.t_param_tab := i_param_tab;
    l_amount_rec         com_api_type_pkg.t_amount_rec;
    l_entity_type        com_api_type_pkg.t_dict_value;
    l_object_id          com_api_type_pkg.t_long_id;
    l_object_is_lty_acc  com_api_type_pkg.t_boolean;
    l_birthday           date;
    l_birthday_fee_id    com_api_type_pkg.t_short_id;
    l_reg_date           date;
    l_anniv_fee_id       com_api_type_pkg.t_short_id;
    l_mask_error_fee     com_api_type_pkg.t_boolean;
begin
    trc_log_pkg.debug(
        i_text       => 'create_bonus: START, i_entity_type [#1], i_object_id [' || i_object_id
                     || '], i_oper_amount [' || round(i_oper_amount, 4) || '], i_oper_currency [#2]'
                     || ', i_split_hash [' || i_split_hash || ']'
                     || ', i_fee_type [' || i_fee_type || ']'
      , i_env_param1 => i_entity_type
      , i_env_param2 => i_oper_currency
    );

    l_entity_type := i_entity_type;
    l_object_id   := i_object_id;
    
    get_input_object_service(
        io_entity_type      => l_entity_type
      , io_object_id        => l_object_id
      , i_eff_date          => i_oper_date
      , i_inst_id           => i_inst_id
      , i_param_tab         => l_params
      , i_mask_error        => com_api_const_pkg.TRUE
      , o_account           => l_account
      , o_service_id        => l_service_id
      , o_product_id        => l_product_id
      , o_object_is_lty_acc => l_object_is_lty_acc
    );
    
    if l_service_id is null then
        trc_log_pkg.debug('create_bonus: unable to find loyalty service for entity [' || l_entity_type || '] [' ||
                          l_object_id || '], exit from procedure');
        return;
    end if;
    
    -- for backward compatibility - fill card_id
    get_card_id(
        i_entity_type  => l_entity_type
      , i_object_id    => l_object_id
      , o_card_id      => l_card_id
    );
    l_customer_id := l_account.customer_id;
    
    l_fee_type := coalesce(
                      i_fee_type
                    , get_fee_type(i_entity_type => l_entity_type)
                  );

    -- Set fee type value for using in calculation of start/end date
    rul_api_param_pkg.set_param(
        io_params   => l_params
      , i_name      => 'FEE_TYPE'
      , i_value     => l_fee_type
    );

    if l_object_is_lty_acc = com_api_const_pkg.FALSE then
        if i_oper_currency = l_account.currency then
            l_amount := i_oper_amount;
        else
            l_amount :=
                com_api_rate_pkg.convert_amount(
                    i_src_amount      => i_oper_amount
                  , i_src_currency    => i_oper_currency
                  , i_dst_currency    => l_account.currency
                  , i_rate_type       => i_rate_type
                  , i_inst_id         => i_inst_id
                  , i_eff_date        => i_oper_date
                  , i_conversion_type => i_conversion_type
                );
        end if;

        rul_api_param_pkg.set_param(
           io_params   => l_params
         , i_name      => 'OPER_AMOUNT'
         , i_value     => l_amount
        );

        if i_test_mode in (fcl_api_const_pkg.ATTR_MISS_IGNORE, fcl_api_const_pkg.ATTR_MISS_ZERO_VALUE) then
            l_mask_error_fee := com_api_const_pkg.TRUE;
        else
            l_mask_error_fee := com_api_const_pkg.FALSE;
        end if;

        begin
            l_fee_id := prd_api_product_pkg.get_fee_id(
                i_product_id   => l_product_id
              , i_entity_type  => l_entity_type
              , i_object_id    => l_object_id
              , i_fee_type     => l_fee_type
              , i_params       => l_params
              , i_service_id   => l_service_id
              , i_eff_date     => i_oper_date
              , i_inst_id      => i_inst_id
              , i_mask_error   => l_mask_error_fee
            );
        exception
            when com_api_error_pkg.e_application_error then
                if com_api_error_pkg.get_last_error in ('PRD_NO_ACTIVE_SERVICE', 'LIMIT_NOT_DEFINED', 'FEE_NOT_DEFINED') then
                    if i_test_mode in (fcl_api_const_pkg.ATTR_MISS_IGNORE, fcl_api_const_pkg.ATTR_MISS_ZERO_VALUE) then
                        return;
                    else
                        raise;
                    end if;
                end if;
        end;
        
        trc_log_pkg.debug('create_bonus: fee_id [' || l_fee_id || '], converted amount [' || l_amount || ']');

        l_amount := fcl_api_fee_pkg.get_fee_amount(
            i_fee_id          => l_fee_id
          , i_base_amount     => l_amount
          , io_base_currency  => l_account.currency
          , i_entity_type     => l_entity_type
          , i_object_id       => l_object_id
          , i_eff_date        => i_oper_date
          , i_split_hash      => i_split_hash
        );
        trc_log_pkg.debug('create_bonus: get_fee_amount returns [' || l_amount || ']');

        -- Check "Birthday's loyalty points by transaction" for a card
        if l_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD then
            begin
                l_birthday_fee_id := 
                    prd_api_product_pkg.get_fee_id(
                        i_product_id   => l_product_id
                      , i_entity_type  => l_entity_type
                      , i_object_id    => l_object_id
                      , i_fee_type     => lty_api_const_pkg.LOYALTY_BIRTHDAY_TRAN_FEE_TYPE
                      , i_params       => l_params
                      , i_service_id   => l_service_id
                      , i_eff_date     => i_oper_date
                      , i_inst_id      => i_inst_id
                      , i_mask_error   => com_api_const_pkg.TRUE
                    );
            exception
                when com_api_error_pkg.e_application_error then
                    l_birthday_fee_id := null;
            end;

            if l_birthday_fee_id is not null then
                select max(p.birthday)
                  into l_birthday
                  from prd_customer c
                     , com_person p
                 where c.id = l_customer_id
                   and c.entity_type = com_api_const_pkg.ENTITY_TYPE_PERSON
                   and p.id = c.object_id;

                if l_birthday is not null and to_char(l_birthday, 'mmdd') = to_char(i_oper_date, 'mmdd') then
                    trc_log_pkg.debug('create_bonus: fee_id [' || l_birthday_fee_id || '], converted amount [' || l_amount || ']');

                    l_amount := fcl_api_fee_pkg.get_fee_amount(
                                    i_fee_id          => l_birthday_fee_id
                                  , i_base_amount     => l_amount
                                  , io_base_currency  => l_account.currency
                                  , i_entity_type     => l_entity_type
                                  , i_object_id       => l_object_id
                                  , i_eff_date        => i_oper_date
                                  , i_split_hash      => i_split_hash
                                );

                    trc_log_pkg.debug('create_bonus: get_fee_amount returns [' || l_amount || ']');
                end if;
            end if;
        end if;

        -- Check "anniversary's loyalty points by transaction" for account
        if i_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
            begin
                l_anniv_fee_id := prd_api_product_pkg.get_fee_id(
                                      i_product_id   => l_product_id
                                    , i_entity_type  => l_entity_type
                                    , i_object_id    => l_object_id
                                    , i_fee_type     => lty_api_const_pkg.LOYALTY_ANNIV_BONUS_FEE_TYPE
                                    , i_params       => l_params
                                    , i_service_id   => l_service_id
                                    , i_eff_date     => i_oper_date
                                    , i_inst_id      => i_inst_id
                                    , i_mask_error   => com_api_const_pkg.TRUE
                                  );
            exception
                when com_api_error_pkg.e_application_error then
                    l_anniv_fee_id := null;
            end;
            if l_anniv_fee_id is not null then
                l_reg_date := acc_api_account_pkg.get_account_reg_date(
                                  i_account_id => i_object_id
                                , i_split_hash => i_split_hash
                              );
        
                if l_reg_date is not null and to_char(l_reg_date, 'mmdd') = to_char(i_oper_date, 'mmdd') 
                    and trunc(l_reg_date) != trunc(i_oper_date) then
                    trc_log_pkg.debug('create_anniv_bonus: fee_id [' || l_anniv_fee_id || '], converted amount [' || i_oper_amount || ']');
                    l_amount := fcl_api_fee_pkg.get_fee_amount(
                                    i_fee_id          => l_anniv_fee_id
                                  , i_base_amount     => l_amount
                                  , io_base_currency  => l_account.currency
                                  , i_entity_type     => i_entity_type
                                  , i_object_id       => i_object_id
                                  , i_eff_date        => i_oper_date
                                  , i_split_hash      => i_split_hash
                                );
                                
                    trc_log_pkg.debug('create_anniv_bonus: get_fee_amount returns [' || l_amount || ']');
        
                end if;
            end if;
        end if;
        
        l_amount := round(l_amount);

    else
        -- case when object is lty-account - amount is bonus points
        l_amount := i_oper_amount;
    end if;

    if l_amount > 0 then
        -- calculating start of bonus period
        l_cycle_id := prd_api_product_pkg.get_cycle_id(
            i_product_id   => l_product_id
          , i_entity_type  => l_entity_type
          , i_object_id    => l_object_id
          , i_cycle_type   => get_start_cycle_type(
                                  i_entity_type => l_entity_type
                              )
          , i_params       => l_params
          , i_service_id   => l_service_id
          , i_eff_date     => i_oper_date
          , i_inst_id      => i_inst_id
        );

        if l_cycle_id is not null then
            fcl_api_cycle_pkg.calc_next_date(
                i_cycle_id    => l_cycle_id
              , i_start_date  => i_oper_date
              , i_forward     => com_api_const_pkg.TRUE
              , o_next_date   => o_start_date
            );
        end if;
        trc_log_pkg.debug(
            i_text       => 'create_bonus: start_cycle_id [' || l_cycle_id || '], start_date [#1]'
          , i_env_param1 => to_char(o_start_date, com_api_const_pkg.DATE_FORMAT)
        );

        -- calculating end of bonus period
        l_cycle_id := prd_api_product_pkg.get_cycle_id(
            i_product_id   => l_product_id
          , i_entity_type  => l_entity_type
          , i_object_id    => l_object_id
          , i_cycle_type   => get_expire_cycle_type(
                                  i_entity_type => l_entity_type
                              )
          , i_params       => l_params
          , i_service_id   => l_service_id
          , i_eff_date     => i_oper_date
          , i_inst_id      => i_inst_id
        );

        if l_cycle_id is not null then
            fcl_api_cycle_pkg.calc_next_date(
                i_cycle_id    => l_cycle_id
              , i_start_date  => i_oper_date
              , i_forward     => com_api_const_pkg.TRUE
              , o_next_date   => o_expire_date
            );
        end if;

        trc_log_pkg.debug(
            i_text       => 'create_bonus: expire_cycle_id [' || l_cycle_id || '], expire_date [#1]'
          , i_env_param1 => to_char(o_expire_date, com_api_const_pkg.DATE_FORMAT)
        );

        create_bonus(
            i_entity_type      => l_entity_type
          , i_object_id        => l_object_id
          , i_posting_date     => o_start_date
          , i_start_date       => o_start_date
          , i_expire_date      => o_expire_date
          , i_oper_entity_type => i_oper_entity_type
          , i_oper_id          => i_oper_id
          , i_oper_date        => i_oper_date
          , i_macros_type      => i_macros_type
          , i_fee_type         => l_fee_type
          , i_amount           => l_amount
          , i_account          => l_account
          , i_card_id          => l_card_id
          , i_fee_id           => l_fee_id
          , i_service_id       => l_service_id
          , i_product_id       => l_product_id
          , i_inst_id          => i_inst_id
          , i_spent_amount     => 0
          , i_param_tab        => l_params
          , o_macros_id        => l_macros_id
        );
    end if;

    o_result_account      := l_account;

    l_amount_rec.amount   := l_amount;
    l_amount_rec.currency := l_account.currency;

    o_result_amount       := l_amount_rec;

    evt_api_event_pkg.register_event(
        i_event_type        => lty_api_const_pkg.BONUS_CREATION_EVENT
      , i_eff_date          => i_oper_date
      , i_entity_type       => lty_api_const_pkg.ENTITY_TYPE_BONUS
      , i_object_id         => l_macros_id
      , i_inst_id           => i_inst_id
      , i_split_hash        => l_account.split_hash
      , i_param_tab         => l_params
    );

    trc_log_pkg.debug('create_bonus: FINISHED');
end;

procedure spend_bonus(
    i_macros_type      in     com_api_type_pkg.t_long_id
  , i_account          in     acc_api_type_pkg.t_account_rec
  , i_service_id       in     com_api_type_pkg.t_short_id
  , i_fee_type         in     com_api_type_pkg.t_dict_value
  , i_eff_date         in     date
  , i_amount           in     com_api_type_pkg.t_money
  , i_currency         in     com_api_type_pkg.t_curr_code
  , i_inst_id          in     com_api_type_pkg.t_inst_id
  , i_oper_id          in     com_api_type_pkg.t_long_id
  , i_rate_type        in     com_api_type_pkg.t_dict_value
  , i_conversion_type  in     com_api_type_pkg.t_dict_value    default null
  , i_param_tab        in     com_api_type_pkg.t_param_tab
  , i_original_id      in     com_api_type_pkg.t_long_id       default null
  , o_spend_bonus_tab  out    lty_api_type_pkg.t_bonus_tab
  , o_macros_id        out    com_api_type_pkg.t_long_id
) as 
    
    l_result_amount     com_api_type_pkg.t_money;
    l_result_status     com_api_type_pkg.t_dict_value;
    l_spend_amount_in   com_api_type_pkg.t_money;
    l_spend_amount_out  com_api_type_pkg.t_money;
    l_spend_amount_rest com_api_type_pkg.t_money;
    l_bunch_id          com_api_type_pkg.t_long_id;
    l_rec_spend_amount  com_api_type_pkg.t_money;
begin
    -- convert amount if required
    if i_currency = i_account.currency then
        l_spend_amount_in := i_amount;
    else
        l_spend_amount_in :=
            com_api_rate_pkg.convert_amount(
                i_src_amount      => i_amount
              , i_src_currency    => i_currency
              , i_dst_currency    => i_account.currency
              , i_rate_type       => i_rate_type
              , i_inst_id         => i_inst_id
              , i_eff_date        => i_eff_date
              , i_conversion_type => i_conversion_type
            );
    end if;
    
    trc_log_pkg.debug(
        i_text       => 'spend_bonus: l_spend_amount_in [' || l_spend_amount_in || ']'
    );

    l_spend_amount_rest := l_spend_amount_in;

    for rec in (
        select b.id
             , b.amount
             , nvl(b.spent_amount, 0) as spent_amount
             , b.status
             , b.expire_date
             , b.start_date
             , b.fee_type
             , decode(m.object_id, nvl(i_original_id, 0), 0, 1) as priority
               -- Specific/promotion fees should be prioritized
             , case when b.fee_type != i_fee_type then 0 else 1 end as priority_fee_type
             , b.amount - nvl(spent_amount,0) as amount_rest
          from lty_bonus b
             , acc_macros m
         where b.status         = lty_api_const_pkg.BONUS_TRANSACTION_ACTIVE
           and b.inst_id        = i_inst_id
           and b.split_hash     = i_account.split_hash
           and b.start_date    <= i_eff_date
           and b.account_id     = i_account.account_id
           and b.service_id     = i_service_id
           and m.id(+)          = b.id
           and m.entity_type(+) = opr_api_const_pkg.ENTITY_TYPE_OPERATION
         order by priority
                , priority_fee_type
                , expire_date
                , start_date
    ) loop
        l_rec_spend_amount := least(rec.amount_rest, l_spend_amount_rest);

        o_spend_bonus_tab(o_spend_bonus_tab.count + 1).id      := rec.id;
        o_spend_bonus_tab(o_spend_bonus_tab.count).amount      := l_rec_spend_amount;
        o_spend_bonus_tab(o_spend_bonus_tab.count).start_date  := rec.start_date;
        o_spend_bonus_tab(o_spend_bonus_tab.count).expire_date := rec.expire_date;
        o_spend_bonus_tab(o_spend_bonus_tab.count).fee_type    := rec.fee_type;
        
        update lty_bonus b
           set b.spent_amount = b.spent_amount + l_rec_spend_amount
             , b.status = case when (b.spent_amount + l_rec_spend_amount) = b.amount
                               then lty_api_const_pkg.BONUS_TRANSACTION_SPENT
                               else status
                          end
         where b.id = rec.id
         returning b.spent_amount,  b.status
              into l_result_amount, l_result_status;

        l_spend_amount_rest := l_spend_amount_rest - l_rec_spend_amount;

        trc_log_pkg.debug(
            i_text       => 'spend_bonus: bonus ID [' || rec.id || '] updated: '
                         || 'spent_amount [' || l_result_amount
                         || '], status [#1], l_spend_amount_rest [' || l_spend_amount_rest 
                         || '], l_rec_spend_amount [ ' || l_rec_spend_amount ||' ]'
                         
          , i_env_param1 => l_result_status
        );

        exit when l_spend_amount_rest <= 0;
    end loop;

    l_spend_amount_out := l_spend_amount_in - greatest(l_spend_amount_rest, 0);
                                      
    trc_log_pkg.debug(
        i_text       => 'spend_bonus: count [' || o_spend_bonus_tab.count || ']; amount for put_macros() is l_spend_amount_out [' || l_spend_amount_out || ']'
    );
    
    acc_api_entry_pkg.put_macros(
        o_macros_id       => o_macros_id
      , o_bunch_id        => l_bunch_id
      , i_entity_type     => opr_api_const_pkg.ENTITY_TYPE_OPERATION
      , i_object_id       => i_oper_id
      , i_macros_type_id  => i_macros_type
      , i_amount          => l_spend_amount_out
      , i_currency        => i_account.currency
      , i_account_type    => i_account.account_type
      , i_account_id      => i_account.account_id
      , i_posting_date    => i_eff_date
      , i_param_tab       => i_param_tab
    );
    acc_api_entry_pkg.flush_job;

    trc_log_pkg.debug(
        i_text       => 'spend_bonus: put_macros() completed with macros_id ['
                     || o_macros_id || '], l_bunch_id [' || l_bunch_id || ']'
    );
end;

procedure spend_bonus(
    i_entity_type      in     com_api_type_pkg.t_dict_value
  , i_object_id        in     com_api_type_pkg.t_long_id
  , i_oper_date        in     date
  , i_oper_amount      in     com_api_type_pkg.t_money
  , i_oper_currency    in     com_api_type_pkg.t_curr_code
  , i_split_hash       in     com_api_type_pkg.t_tiny_id
  , i_inst_id          in     com_api_type_pkg.t_inst_id
  , i_oper_id          in     com_api_type_pkg.t_long_id
  , i_original_id      in     com_api_type_pkg.t_long_id       default null
  , i_macros_type      in     com_api_type_pkg.t_long_id
  , i_rate_type        in     com_api_type_pkg.t_dict_value
  , i_conversion_type  in     com_api_type_pkg.t_dict_value    default null
  , i_param_tab        in     com_api_type_pkg.t_param_tab
) is
    l_params            com_api_type_pkg.t_param_tab := i_param_tab;
    l_service_id        com_api_type_pkg.t_short_id;
    l_product_id        com_api_type_pkg.t_short_id;
    l_account           acc_api_type_pkg.t_account_rec;
    l_macros_id         com_api_type_pkg.t_long_id;
    l_object_is_lty_acc com_api_type_pkg.t_boolean;
    l_fee_type          com_api_type_pkg.t_dict_value;
    l_spend_bonus_tab   lty_api_type_pkg.t_bonus_tab;
    l_entity_type       com_api_type_pkg.t_dict_value := i_entity_type;
    l_object_id         com_api_type_pkg.t_long_id := i_object_id;
begin
    trc_log_pkg.debug(
        i_text       => 'spend_bonus: STARTED, i_entity_type [#1], i_object_id [' || i_object_id
                     || '], i_oper_date [' || com_api_type_pkg.convert_to_char(i_oper_date)
                     || '], i_oper_currency [' || i_oper_currency
                     || '], i_oper_amount [' || i_oper_amount
                     || '], i_split_hash [' || i_split_hash
                     || '], i_inst_id [' || i_inst_id
                     || '], i_oper_id [' || i_oper_id
                     || '], i_original_id [' || i_original_id
                     || '], i_macros_type_id [' || i_macros_type
                     || '], i_rate_type [#2], i_conversion_type [#3]'
      , i_env_param1 => i_entity_type
      , i_env_param2 => i_rate_type
      , i_env_param3 => i_conversion_type
    );

    get_input_object_service(
        io_entity_type      => l_entity_type
      , io_object_id        => l_object_id
      , i_eff_date          => i_oper_date
      , i_inst_id           => i_inst_id
      , i_param_tab         => l_params
      , i_mask_error        => com_api_const_pkg.TRUE
      , o_account           => l_account
      , o_service_id        => l_service_id
      , o_product_id        => l_product_id
      , o_object_is_lty_acc => l_object_is_lty_acc
    );
    
    if l_service_id is null then
        trc_log_pkg.debug('spend_bonus: unable to find loyalty service for entity [' || l_entity_type || '] [' ||
                          l_object_id || '], exit from procedure');
        return;
    end if;

    check_balance_min_threshold(
        i_entity_type        => i_entity_type
      , i_object_id          => i_object_id
      , i_split_hash         => i_split_hash
      , i_account            => l_account
      , i_product_id         => l_product_id
      , i_service_id         => l_service_id
      , i_eff_date           => i_oper_date
      , i_inst_id            => i_inst_id
    );

    l_fee_type := get_fee_type(i_entity_type => i_entity_type);

    spend_bonus(
        i_macros_type      => i_macros_type
      , i_account          => l_account
      , i_service_id       => l_service_id
      , i_fee_type         => l_fee_type
      , i_eff_date         => i_oper_date
      , i_amount           => i_oper_amount
      , i_currency         => i_oper_currency
      , i_inst_id          => i_inst_id
      , i_oper_id          => i_oper_id
      , i_rate_type        => i_rate_type
      , i_conversion_type  => i_conversion_type
      , i_param_tab        => l_params
      , i_original_id      => i_original_id
      , o_spend_bonus_tab  => l_spend_bonus_tab
      , o_macros_id        => l_macros_id
    );

    evt_api_event_pkg.register_event(
        i_event_type        => lty_api_const_pkg.BONUS_SPEND_EVENT
      , i_eff_date          => i_oper_date
      , i_entity_type       => lty_api_const_pkg.ENTITY_TYPE_BONUS
      , i_object_id         => l_macros_id
      , i_inst_id           => i_inst_id
      , i_split_hash        => l_account.split_hash
      , i_param_tab         => l_params
    );

    trc_log_pkg.debug('spend_bonus: FINISHED');

exception
    when com_api_error_pkg.e_resource_busy then
        com_api_error_pkg.raise_error(
            i_error      => 'CANNOT_SPEND_BONUS'
          , i_env_param1 => i_entity_type
          , i_env_param2 => i_object_id
          , i_env_param3 => i_oper_date
        );
    when others then
        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE
            or
           com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE
        then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;
end;

procedure get_lty_account_info(
    i_entity_type      in     com_api_type_pkg.t_dict_value
  , i_object_id        in     com_api_type_pkg.t_long_id
  , i_inst_id          in     com_api_type_pkg.t_inst_id
  , i_eff_date         in     date
  , i_mask_error       in     com_api_type_pkg.t_boolean     default com_api_const_pkg.FALSE
  , o_account             out acc_api_type_pkg.t_account_rec
  , o_service_id          out com_api_type_pkg.t_short_id
  , o_product_id          out com_api_type_pkg.t_short_id
) is
    l_account_type            com_api_type_pkg.t_dict_value;
    l_account_curr            com_api_type_pkg.t_curr_code;
    l_params                  com_api_type_pkg.t_param_tab;
begin
    o_service_id := prd_api_service_pkg.get_active_service_id(
        i_entity_type      => i_entity_type
      , i_object_id        => i_object_id
      , i_attr_name        => null
      , i_service_type_id  => get_service_type_id(
                                  i_entity_type  =>  i_entity_type
                              )
      , i_eff_date         => i_eff_date
      , i_mask_error       => i_mask_error
      , i_inst_id          => i_inst_id
    );

    if o_service_id is not null then
        o_product_id := prd_api_product_pkg.get_product_id(
            i_entity_type  => i_entity_type
          , i_object_id    => i_object_id
        );

        trc_log_pkg.debug('get_lty_account_info: service_id [' || o_service_id || '], product_id [' || o_product_id || ']');

        l_account_type := prd_api_product_pkg.get_attr_value_char(
            i_product_id   => o_product_id
          , i_entity_type  => i_entity_type
          , i_object_id    => i_object_id
          , i_attr_name    => decode_attr_name(
                                  i_attr_name   => lty_api_const_pkg.LOYALTY_ATTR_ACC_TYPE
                                , i_entity_type => i_entity_type
                              )
          , i_params       => l_params
          , i_service_id   => o_service_id
          , i_eff_date     => i_eff_date
          , i_inst_id      => i_inst_id
        );

        l_account_curr := prd_api_product_pkg.get_attr_value_char(
            i_product_id   => o_product_id
          , i_entity_type  => i_entity_type
          , i_object_id    => i_object_id
          , i_attr_name    => decode_attr_name(
                                  i_attr_name    => lty_api_const_pkg.LOYALTY_ATTR_ACC_CURR
                                , i_entity_type  => i_entity_type
                              )
          , i_params       => l_params
          , i_service_id   => o_service_id
          , i_eff_date     => i_eff_date
          , i_inst_id      => i_inst_id
        );

        trc_log_pkg.debug(
            i_text       => 'get_lty_account_info: account_type [#1], account_currency [#2]'
          , i_env_param1 => l_account_type
          , i_env_param2 => l_account_curr
        );

        o_account := acc_api_account_pkg.get_account(
            i_entity_type   => i_entity_type
          , i_object_id     => i_object_id
          , i_account_type  => l_account_type
          , i_currency      => l_account_curr
          , i_mask_error    => i_mask_error
        );

        trc_log_pkg.debug('get_lty_account_info: accound_id [' || o_account.account_id || ']');
    end if;
end get_lty_account_info;

procedure get_lty_account(
    i_entity_type      in     com_api_type_pkg.t_dict_value
  , i_object_id        in     com_api_type_pkg.t_long_id
  , i_inst_id          in     com_api_type_pkg.t_inst_id
  , i_eff_date         in     date
  , i_mask_error       in     com_api_type_pkg.t_boolean     default com_api_const_pkg.FALSE
  , o_account             out acc_api_type_pkg.t_account_rec
) is
    l_product_id              com_api_type_pkg.t_short_id;
    l_service_id              com_api_type_pkg.t_short_id;
begin
    get_lty_account_info(
        i_entity_type  => i_entity_type
      , i_object_id    => i_object_id
      , i_inst_id      => i_inst_id
      , i_eff_date     => i_eff_date
      , i_mask_error   => i_mask_error
      , o_account      => o_account
      , o_service_id   => l_service_id
      , o_product_id   => l_product_id
    );
end get_lty_account;

procedure move_bonus(
    i_src_account            in     acc_api_type_pkg.t_account_rec
  , i_dst_account            in     acc_api_type_pkg.t_account_rec
  , i_oper_id                in     com_api_type_pkg.t_long_id
  , i_oper_date              in     date
  , i_oper_amount            in     com_api_type_pkg.t_money
  , i_oper_currency          in     com_api_type_pkg.t_curr_code
  , i_debit_macros_type      in     com_api_type_pkg.t_long_id
  , i_credit_macros_type     in     com_api_type_pkg.t_long_id
  , i_rate_type              in     com_api_type_pkg.t_dict_value
  , i_conversion_type        in     com_api_type_pkg.t_dict_value    default null
  , i_param_tab              in     com_api_type_pkg.t_param_tab
)
as
    l_src_entity_type        com_api_type_pkg.t_dict_value;
    l_src_object_id          com_api_type_pkg.t_long_id;
    l_src_account            acc_api_type_pkg.t_account_rec;
    l_src_service_id         com_api_type_pkg.t_short_id;
    l_src_product_id         com_api_type_pkg.t_short_id;
    l_src_object_is_lty_acc  com_api_type_pkg.t_boolean;
    l_src_macros_id          com_api_type_pkg.t_long_id;
    
    l_dst_entity_type        com_api_type_pkg.t_dict_value;
    l_dst_object_id          com_api_type_pkg.t_long_id;
    l_dst_account            acc_api_type_pkg.t_account_rec;
    l_dst_service_id         com_api_type_pkg.t_short_id;
    l_dst_product_id         com_api_type_pkg.t_short_id;
    l_dst_object_is_lty_acc  com_api_type_pkg.t_boolean;
    l_dst_macros_id          com_api_type_pkg.t_long_id;
    l_dst_amount             com_api_type_pkg.t_money;

    l_spend_bonus_tab        lty_api_type_pkg.t_bonus_tab;
    l_fee_type               com_api_type_pkg.t_dict_value;
begin
    trc_log_pkg.debug(
        i_text       => 'move_bonus: STARTED, i_src_account.id [#1], i_dst_account.id [#2], i_oper_amount [#3], i_oper_currency [#4]' ||
                        ', i_debit_macros_type [#5], i_credit_macros_type [#5]'
      , i_env_param1 => i_src_account.account_id
      , i_env_param2 => i_dst_account.account_id
      , i_env_param3 => i_oper_amount
      , i_env_param4 => i_oper_currency
      , i_env_param5 => i_debit_macros_type
      , i_env_param6 => i_credit_macros_type
    );

    l_src_entity_type    := acc_api_const_pkg.ENTITY_TYPE_ACCOUNT;
    l_src_object_id      := i_src_account.account_id;
    
    l_dst_entity_type    := acc_api_const_pkg.ENTITY_TYPE_ACCOUNT;
    l_dst_object_id      := i_dst_account.account_id;
    
    l_src_account        := i_src_account;
    l_dst_account        := i_dst_account;
    
    get_input_object_service(
        io_entity_type      => l_src_entity_type
      , io_object_id        => l_src_object_id
      , i_eff_date          => i_oper_date
      , i_param_tab         => i_param_tab
      , i_mask_error        => com_api_const_pkg.FALSE
      , o_account           => l_src_account
      , o_service_id        => l_src_service_id
      , o_product_id        => l_src_product_id
      , o_object_is_lty_acc => l_src_object_is_lty_acc
    );
    
    if l_src_object_is_lty_acc = com_api_const_pkg.FALSE then
        com_api_error_pkg.raise_error(
            i_error       => 'BONUS_ACCOUNT_NOT_FOUND'
          , i_env_param1  => l_src_entity_type
          , i_env_param2  => l_src_object_id
        );
    end if;
    
    get_input_object_service(
        io_entity_type      => l_dst_entity_type
      , io_object_id        => l_dst_object_id
      , i_eff_date          => i_oper_date
      , i_param_tab         => i_param_tab
      , i_mask_error        => com_api_const_pkg.FALSE
      , o_account           => l_dst_account
      , o_service_id        => l_dst_service_id
      , o_product_id        => l_dst_product_id
      , o_object_is_lty_acc => l_dst_object_is_lty_acc
    );

    if l_dst_object_is_lty_acc = com_api_const_pkg.FALSE then
        com_api_error_pkg.raise_error(
            i_error       => 'BONUS_ACCOUNT_NOT_FOUND'
          , i_env_param1  => l_dst_entity_type
          , i_env_param2  => l_dst_object_id
        );
    end if;
    
    l_fee_type := get_fee_type(i_entity_type => l_src_entity_type);

    spend_bonus(
        i_macros_type      => i_debit_macros_type
      , i_account          => l_src_account
      , i_service_id       => l_src_service_id
      , i_fee_type         => l_fee_type
      , i_eff_date         => i_oper_date
      , i_amount           => i_oper_amount
      , i_currency         => i_oper_currency
      , i_inst_id          => l_src_account.inst_id
      , i_oper_id          => i_oper_id
      , i_rate_type        => i_rate_type
      , i_conversion_type  => i_conversion_type
      , i_param_tab        => i_param_tab
      , o_spend_bonus_tab  => l_spend_bonus_tab
      , o_macros_id        => l_src_macros_id
    );
    
    if l_spend_bonus_tab.count > 0 then
        for i in l_spend_bonus_tab.first .. l_spend_bonus_tab.last loop
            -- convert amount if required
            if l_dst_account.currency = l_src_account.currency then
                l_dst_amount := l_spend_bonus_tab(i).amount;
            else
                l_dst_amount :=
                    com_api_rate_pkg.convert_amount(
                        i_src_amount      => l_spend_bonus_tab(i).amount
                      , i_src_currency    => l_src_account.currency
                      , i_dst_currency    => l_dst_account.currency
                      , i_rate_type       => i_rate_type
                      , i_inst_id         => l_dst_account.inst_id
                      , i_eff_date        => i_oper_date
                      , i_conversion_type => i_conversion_type
                    );
            end if;
            
            create_bonus(
                i_entity_type      => l_dst_entity_type
              , i_object_id        => l_dst_object_id
              , i_posting_date     => i_oper_date
              , i_start_date       => l_spend_bonus_tab(i).start_date
              , i_expire_date      => l_spend_bonus_tab(i).expire_date
              , i_oper_entity_type => opr_api_const_pkg.ENTITY_TYPE_OPERATION
              , i_oper_id          => i_oper_id
              , i_oper_date        => i_oper_date
              , i_macros_type      => i_credit_macros_type
              , i_fee_type         => l_spend_bonus_tab(i).fee_type
              , i_amount           => l_dst_amount
              , i_account          => l_dst_account
              , i_card_id          => null
              , i_fee_id           => null
              , i_service_id       => l_dst_service_id
              , i_product_id       => l_dst_product_id
              , i_inst_id          => l_dst_account.inst_id
              , i_spent_amount     => 0
              , i_param_tab        => i_param_tab
              , o_macros_id        => l_dst_macros_id
            );
        end loop;
    end if;

    evt_api_event_pkg.register_event(
        i_event_type        => lty_api_const_pkg.BONUS_MOVE_EVENT
      , i_eff_date          => i_oper_date
      , i_entity_type       => lty_api_const_pkg.ENTITY_TYPE_BONUS
      , i_object_id         => l_src_macros_id
      , i_inst_id           => i_src_account.inst_id
      , i_split_hash        => i_src_account.split_hash
      , i_param_tab         => i_param_tab
    );
    
    trc_log_pkg.debug('move_bonus: FINISHED');
end;

end;
/
