create or replace package body pmo_api_algo_proc_pkg is

g_params                com_api_type_pkg.t_param_tab;
g_dpp                   dpp_api_type_pkg.t_dpp_program;
g_instalments           dpp_api_type_pkg.t_dpp_instalment_tab;

procedure clear_shared_data is
begin
    rul_api_param_pkg.clear_params(
        io_params         => g_params
    );
end;

function get_dpp return dpp_api_type_pkg.t_dpp_program is
begin
    if g_dpp.dpp_id is not null then
        return g_dpp;
    else
        trc_log_pkg.debug(i_text => 'get_dpp(): dpp is empty');
        return null;
    end if;
end;

function get_instalments return dpp_api_type_pkg.t_dpp_instalment_tab is
begin
    if g_instalments.count = 0 then
        trc_log_pkg.debug(i_text => 'get_instalments(): instalments is Empty');
    end if;

    return g_instalments;
end;

function get_param_num(
    i_name                in            com_api_type_pkg.t_name
  , i_mask_error          in            com_api_type_pkg.t_boolean    default com_api_type_pkg.FALSE
  , i_error_value         in            com_api_type_pkg.t_name       default null
) return number is
begin
    return rul_api_param_pkg.get_param_num(
               i_name            => i_name
             , io_params         => g_params
             , i_mask_error      => i_mask_error
             , i_error_value     => i_error_value
           );
end;

function get_param_date(
    i_name                in            com_api_type_pkg.t_name
  , i_mask_error          in            com_api_type_pkg.t_boolean    default com_api_type_pkg.FALSE
  , i_error_value         in            com_api_type_pkg.t_name       default null
) return date is
begin
    return rul_api_param_pkg.get_param_date(
               i_name            => i_name
             , io_params         => g_params
             , i_mask_error      => i_mask_error
             , i_error_value     => i_error_value
           );
end;

function get_param_char(
    i_name                in            com_api_type_pkg.t_name
  , i_mask_error          in            com_api_type_pkg.t_boolean    default com_api_type_pkg.FALSE
  , i_error_value         in            com_api_type_pkg.t_name       default null
) return com_api_type_pkg.t_param_value is
begin
    return rul_api_param_pkg.get_param_char(
               i_name            => i_name
             , io_params         => g_params
             , i_mask_error      => i_mask_error
             , i_error_value     => i_error_value
           );
end;

procedure set_param(
    i_name                in            com_api_type_pkg.t_name
  , i_value               in            com_api_type_pkg.t_name
) is
begin
    rul_api_param_pkg.set_param(
        i_name     => i_name
      , io_params  => g_params
      , i_value    => i_value
    );
end;

procedure set_param(
    i_name                in            com_api_type_pkg.t_name
  , i_value               in            number
) is
begin
    rul_api_param_pkg.set_param(
        i_name     => i_name
      , io_params  => g_params
      , i_value    => i_value
    );
end;

procedure set_param(
    i_name                in            com_api_type_pkg.t_name
  , i_value               in            date
) is
begin
    rul_api_param_pkg.set_param(
        i_name     => i_name
      , io_params  => g_params
      , i_value    => i_value
    );
end;

procedure set_dpp(
    i_dpp                 in            dpp_api_type_pkg.t_dpp_program
) is
begin
    if i_dpp.dpp_id is not null then
        g_dpp := i_dpp;
    else
        trc_log_pkg.debug(i_text => 'set_dpp(): dpp is empty');
        g_dpp := null;
    end if;
end;

procedure set_instalments(
    i_instalments         in            dpp_api_type_pkg.t_dpp_instalment_tab
) is
begin
    if i_instalments.count > 0 then
        g_instalments := i_instalments;
    else
        trc_log_pkg.debug(i_text => 'set_instalments(): instalments is Empty');
        g_instalments.delete;
    end if;
end;

procedure process_algorithm(
    io_dpp                    in out        dpp_api_type_pkg.t_dpp_program
  , io_instalments            in out nocopy dpp_api_type_pkg.t_dpp_instalment_tab
  , i_eff_date                in            date
  , i_first_payment_date      in            date
  , i_debt_rest               in            com_api_type_pkg.t_money
) is
begin
    set_dpp(i_dpp => io_dpp);
    set_instalments(i_instalments=> io_instalments);

    set_param(
        i_name   => 'EFF_DATE'
      , i_value  => i_eff_date
    );
    set_param(
        i_name   => 'FIRST_PAYMENT_DATE'
      , i_value  => i_first_payment_date
    );
    set_param(
        i_name   => 'DEBT_REST'
      , i_value  => i_debt_rest
    );

    rul_api_algorithm_pkg.execute_algorithm(i_algorithm => io_dpp.calc_algorithm);

    io_dpp         := get_dpp();
    io_instalments := get_instalments();
end process_algorithm;

/*
 * Calculation order amount. This is user-exit from procedure pmo_api_order_pkg.calc_order_amount
 */
procedure process_amount_algorithm(
    i_amount_algorithm      in      com_api_type_pkg.t_dict_value
  , i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_id             in      com_api_type_pkg.t_long_id
  , i_eff_date              in      date
  , i_template_id           in      com_api_type_pkg.t_long_id
  , i_split_hash            in      com_api_type_pkg.t_tiny_id
  , i_order_id              in      com_api_type_pkg.t_long_id
  , io_amount               in out  com_api_type_pkg.t_amount_rec
) is
    LOG_PREFIX                     constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_amount_algorithm';
begin
    trc_log_pkg.debug(
        i_text => 'process_amount_algorithm start'
    );
    clear_shared_data();

    set_param(
        i_name   => 'ENTITY_TYPE'
      , i_value  => i_entity_type
    );
    set_param(
        i_name   => 'OBJECT_ID'
      , i_value  => i_object_id
    );
    set_param(
        i_name   => 'EFF_DATE'
      , i_value  => i_eff_date
    );
    set_param(
        i_name   => 'TEMPLATE_ID'
      , i_value  => i_template_id
    );
    set_param(
        i_name   => 'SPLIT_HASH'
      , i_value  => i_split_hash
    );
    set_param(
        i_name   => 'ORDER_AMOUNT'
      , i_value  => io_amount.amount
    );
    set_param(
        i_name   => 'CURRENCY'
      , i_value  => io_amount.currency
    );
    set_param(
        i_name   => 'ORDER_ID'
      , i_value  => i_order_id
    );

    rul_api_algorithm_pkg.execute_algorithm(i_algorithm => i_amount_algorithm);

    -- get io_amount from cache parameter
    io_amount.amount := nvl(
                         get_param_num(i_name => 'ORDER_AMOUNT')
                       , io_amount.amount
                     );
    io_amount.currency := nvl(
                         get_param_char(i_name => 'CURRENCY')
                       , io_amount.currency
                     );

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' >> io_amount [#1], currency [#2]'
      , i_env_param1 => io_amount.amount
      , i_env_param2 => io_amount.currency
    );

end process_amount_algorithm;

-- Algorithms procedures
/*
 * Order amount calculation procedure, it is intended to be used as a algorithm procedure
 * with amount calculation algorithm PMO_AMOUNT_ALGO_MERCHANT_SETTL
 */
procedure calc_gross_net_order_amount is
    l_service_id           com_api_type_pkg.t_short_id;
    l_object_id            com_api_type_pkg.t_long_id;
    l_entity_type          com_api_type_pkg.t_dict_value;
    l_eff_date             date;
    l_order_id             com_api_type_pkg.t_long_id;
    l_template_id          com_api_type_pkg.t_long_id;
    l_split_hash           com_api_type_pkg.t_tiny_id;
    l_amount               com_api_type_pkg.t_amount_rec;
    l_sttl_mode            com_api_type_pkg.t_dict_value;
    l_macros_type_array_id com_api_type_pkg.t_long_id;
    l_sttl_threshold       com_api_type_pkg.t_amount_rec;     
    l_product_id           com_api_type_pkg.t_short_id;
    l_pmo_event_date       date;

begin
    l_object_id         := get_param_num(i_name => 'OBJECT_ID');
    l_entity_type       := get_param_char(i_name => 'ENTITY_TYPE');
    l_eff_date          := get_param_date(i_name => 'EFF_DATE');
    l_template_id       := get_param_num(i_name => 'TEMPLATE_ID');
    l_split_hash        := get_param_num(i_name => 'SPLIT_HASH');
    l_amount.amount     := get_param_num(i_name => 'ORDER_AMOUNT');
    l_amount.currency   := get_param_num(i_name => 'CURRENCY');

    -- find prepared order
    begin
        select t.id
          into l_order_id
          from pmo_order t
         where t.status = pmo_api_const_pkg.PMO_STATUS_PREPARATION
           and t.event_date  = l_eff_date
           and t.template_id = l_template_id;

    exception
        when no_data_found then
            trc_log_pkg.debug(
                'Order is not created. No one operation in current period.'
            );
            return;
    end;

    -- get merchant service
    l_service_id :=
        prd_api_service_pkg.get_active_service_id(
            i_entity_type      => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
          , i_object_id        => l_object_id
          , i_attr_name        => acq_api_const_pkg.ACQ_MERCHANT_SETTLEMENT_MODE
          , i_eff_date         => l_eff_date
          , i_mask_error       => com_api_const_pkg.FALSE
        );

    -- get attribute Merchant settlement mode
    l_sttl_mode :=
        prd_api_product_pkg.get_attr_value_char(
            i_entity_type       => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
          , i_object_id         => l_object_id
          , i_attr_name         => acq_api_const_pkg.ACQ_MERCHANT_SETTLEMENT_MODE
          , i_service_id        => l_service_id
          , i_eff_date          => l_eff_date
          , i_split_hash        => l_split_hash
          , i_mask_error        => com_api_const_pkg.FALSE
        );

    -- get attribute Merchant settlement macros types
    l_macros_type_array_id :=
        prd_api_product_pkg.get_attr_value_number(
            i_entity_type       => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
          , i_object_id         => l_object_id
          , i_attr_name         => acq_api_const_pkg.ACQ_MERCHANT_STTL_MACROS_TYPE
          , i_service_id        => l_service_id
          , i_eff_date          => l_eff_date
          , i_split_hash        => l_split_hash
          , i_mask_error        => com_api_const_pkg.FALSE
        );

    begin
        -- check mode and calculate amount by operation which are included into prepared order
        if l_sttl_mode = acq_api_const_pkg.MERCHANT_SETTLEMENT_MODE_NET then
            select sum(m.amount)
                 , m.currency
              into l_amount.amount
                 , l_amount.currency
              from pmo_order_detail d
                 , acc_macros m
             where d.order_id  = l_order_id
               and d.object_id = m.object_id --exclude fee macros types
               and m.macros_type_id not in (select numeric_value from com_array_element where array_id = l_macros_type_array_id)
             group by m.currency;
        else
            -- if SLMD0002 - Gross - then summ all macros amount of operation
            select sum(m.amount)
                 , m.currency
              into l_amount.amount
                 , l_amount.currency
              from pmo_order_detail d
                 , acc_macros m
             where d.order_id  = l_order_id
               and d.object_id = m.object_id --include only macros type with total transaction amount
               and m.macros_type_id in (select numeric_value from com_array_element where array_id = l_macros_type_array_id)
             group by m.currency;
        end if;

    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error         => 'PMO_NO_OPERATIONS_FOUND_OR_ABSENT_MACROS_TYPE'
              , i_env_param1    => l_order_id
            );
    end;

    l_product_id := prd_api_product_pkg.get_product_id(
                        i_entity_type => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                      , i_object_id   => l_object_id
                      , i_eff_date    => l_eff_date
                    );

    prd_api_product_pkg.get_fee_amount(
        i_product_id         => l_product_id
      , i_entity_type        => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
      , i_object_id          => l_object_id
      , i_fee_type           => pmo_api_const_pkg.FEE_TYPE_SETTLEMENT_THRESHOLD
      , i_params             => g_params
      , i_service_id         => l_service_id
      , i_eff_date           => l_eff_date
      , i_base_amount        => 0
      , i_base_currency      => l_amount.currency
      , io_fee_currency      => l_amount.currency
      , o_fee_amount         => l_sttl_threshold.amount
      , i_mask_error         => com_api_const_pkg.TRUE
    );

    if (l_sttl_threshold.amount > l_amount.amount) then            
        l_amount.amount := 0;    
        l_pmo_event_date := fcl_api_cycle_pkg.calc_next_date(
                                i_cycle_type    => pmo_api_const_pkg.PMO_MERCHAND_SETTLEMENT_CYCLE
                              , i_entity_type   => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                              , i_object_id     => l_object_id
                            );
        update pmo_order pmo set pmo.event_date = nvl(l_pmo_event_date, pmo.event_date) where pmo.id = l_order_id;
    end if;

    -- set result amount
    set_param(
        i_name   => 'ORDER_AMOUNT'
      , i_value  => l_amount.amount
    );
    set_param(
        i_name   => 'CURRENCY'
      , i_value  => l_amount.currency
    );

end;

/*
 * Order amount calculation procedure, it is intended to be used as a algorithm procedure.
 * Returns amount as entry amount.
 */

procedure get_entry_order_amount is
    l_object_id            com_api_type_pkg.t_long_id;
    l_entity_type          com_api_type_pkg.t_dict_value;
    l_eff_date             date;
    l_split_hash           com_api_type_pkg.t_tiny_id;
    l_amount               com_api_type_pkg.t_amount_rec;

begin
    l_object_id         := get_param_num(i_name => 'OBJECT_ID');
    l_entity_type       := get_param_char(i_name => 'ENTITY_TYPE');

    l_eff_date          := get_param_date(i_name => 'EFF_DATE');
    l_split_hash        := get_param_num(i_name => 'SPLIT_HASH');
    l_amount.amount     := get_param_num(i_name => 'ORDER_AMOUNT');
    l_amount.currency   := get_param_char(i_name => 'CURRENCY');

    if l_entity_type = acc_api_const_pkg.ENTITY_TYPE_ENTRY then
        select amount
             , currency
          into l_amount.amount
             , l_amount.currency
          from acc_entry
         where id = l_object_id;

        -- set result amount
        set_param(
            i_name   => 'ORDER_AMOUNT'
          , i_value  => l_amount.amount
        );
        set_param(
            i_name   => 'CURRENCY'
          , i_value  => l_amount.currency
        );
    else
        com_api_error_pkg.raise_error (
            i_error         => 'UNSUPPORTED_ENTITY_TYPE'
          , i_env_param1    => l_entity_type
        );
    end if;

    trc_log_pkg.debug(
        i_text       => 'get_entry_order_amount ok'
    );

end get_entry_order_amount;

procedure calc_attached_oper_amount_sum
is
    LOG_PREFIX    constant com_api_type_pkg.t_name    := lower($$PLSQL_UNIT) || '.calc_attached_oper_amount_sum: ';
    l_order_id             com_api_type_pkg.t_long_id;
    l_amount               com_api_type_pkg.t_amount_rec;
    l_part_key             date;
begin

    l_order_id          := get_param_num(i_name => 'ORDER_ID');

    l_part_key          := com_api_id_pkg.get_part_key_from_id(i_id => l_order_id);

    begin
        select sum(o.oper_amount) as amount
             , o.oper_currency
          into l_amount.amount
             , l_amount.currency
          from opr_operation o
             , pmo_order_detail od
         where o.id           = od.object_id
           and od.part_key    = l_part_key
           and od.order_id    = l_order_id
           and od.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
         group by o.oper_currency;

    exception
        when no_data_found then
            trc_log_pkg.info(
                i_text       => LOG_PREFIX || 'No operations found for the order_id [#1]'
              , i_env_param1 => l_order_id
            );

            l_amount.amount    := 0;
            l_amount.currency  := null;

        when too_many_rows then
            trc_log_pkg.error(
                i_text => LOG_PREFIX || 'TOO_MANY_RECORDS_FOUND'
            );
    end;

    set_param(
        i_name  => 'ORDER_AMOUNT'
      , i_value => l_amount.amount
    );
    set_param(
        i_name  => 'CURRENCY'
      , i_value => l_amount.currency
    );
end calc_attached_oper_amount_sum;

procedure calc_order_amount_mad(
    i_account_id            in      com_api_type_pkg.t_account_id
  , i_split_hash            in      com_api_type_pkg.t_tiny_id
  , o_amount                   out  com_api_type_pkg.t_amount_rec
) is
    l_invoice_id            com_api_type_pkg.t_medium_id;
    l_total_payment_amount  com_api_type_pkg.t_money;
begin
    l_invoice_id := crd_invoice_pkg.get_last_invoice_id(
                        i_account_id  => i_account_id
                      , i_split_hash  => i_split_hash
                      , i_mask_error  => com_api_const_pkg.FALSE
                    );

    select i.min_amount_due
         , a.currency
      into o_amount.amount
         , o_amount.currency
      from acc_account a
         , crd_invoice i
     where a.id = i.account_id
       and i.id = l_invoice_id;

    select nvl(sum(amount), 0)
      into l_total_payment_amount
      from crd_payment
     where decode(is_new, 1, account_id, null) = i_account_id
       and is_reversal = com_api_const_pkg.FALSE;

    o_amount.amount := greatest(0, o_amount.amount - l_total_payment_amount);
end;

procedure calc_order_amount_tad(
    i_account_id            in      com_api_type_pkg.t_account_id
  , i_split_hash            in      com_api_type_pkg.t_tiny_id
  , o_amount                   out  com_api_type_pkg.t_amount_rec
) is
    l_invoice_id            com_api_type_pkg.t_medium_id;
    l_total_payment_amount  com_api_type_pkg.t_money;
begin
    l_invoice_id := crd_invoice_pkg.get_last_invoice_id(
                        i_account_id  => i_account_id
                      , i_split_hash  => i_split_hash
                      , i_mask_error  => com_api_const_pkg.FALSE
                    );

    select i.total_amount_due
         , a.currency
      into o_amount.amount
         , o_amount.currency
      from acc_account a
         , crd_invoice i
     where a.id = i.account_id
       and i.id = l_invoice_id;

    select nvl(sum(amount), 0)
      into l_total_payment_amount
      from crd_payment
     where decode(is_new, 1, account_id, null) = i_account_id
       and is_reversal = com_api_const_pkg.FALSE;

    o_amount.amount := greatest(0, o_amount.amount - l_total_payment_amount);
end;

procedure calc_order_amount_tad_ovd_mad(
    i_account_id            in      com_api_type_pkg.t_account_id
  , i_split_hash            in      com_api_type_pkg.t_tiny_id
  , i_eff_date              in      date
  , o_amount                   out  com_api_type_pkg.t_amount_rec
) is
    l_invoice               crd_api_type_pkg.t_invoice_rec;
    l_total_payment_amount  com_api_type_pkg.t_money;
begin
    l_invoice :=
        crd_invoice_pkg.get_last_invoice(
            i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id     => i_account_id
          , i_split_hash    => i_split_hash
          , i_mask_error    => com_api_const_pkg.FALSE
        );

    o_amount.currency :=
        acc_api_account_pkg.get_account(
            i_account_id => i_account_id
          , i_mask_error => com_api_const_pkg.FALSE
        ).currency;

    l_total_payment_amount :=
        crd_payment_pkg.get_total_payment_amount(
            i_account_id    => i_account_id
          , i_split_hash    => i_split_hash
        );

    if (l_invoice.is_mad_paid = com_api_type_pkg.FALSE and (l_invoice.overdue_date <= i_eff_date or l_invoice.aging_period > 0)) then
        -- after overdue - mad
        o_amount.amount := l_invoice.min_amount_due;
    else
        -- before overdue - tad
        o_amount.amount := l_invoice.total_amount_due;
    end if;

    o_amount.amount := greatest(0, o_amount.amount - l_total_payment_amount);
end;

procedure calc_direct_debit_amount(
    i_object_id    in      com_api_type_pkg.t_long_id
  , i_entity_type  in      com_api_type_pkg.t_dict_value
  , i_split_hash   in      com_api_type_pkg.t_tiny_id
  , i_eff_date     in      date
  , o_amount          out  com_api_type_pkg.t_amount_rec
) is
    l_amount_rec           com_api_type_pkg.t_amount_rec;
    l_param_tab            com_api_type_pkg.t_param_tab;
    l_service_id           com_api_type_pkg.t_short_id;
    l_product_id           com_api_type_pkg.t_long_id;
    l_inst_id              com_api_type_pkg.t_inst_id;
    l_currency             com_api_type_pkg.t_curr_code;
    l_fee_id               com_api_type_pkg.t_long_id;
    l_account_id           com_api_type_pkg.t_account_id;
    l_invoice_id           com_api_type_pkg.t_medium_id;
    l_total_payment_amount com_api_type_pkg.t_money;
begin
    trc_log_pkg.debug(
        i_text       => lower($$PLSQL_UNIT) || '.calc_direct_debit_amount start: object_id [#1], split_hash [#2], eff_date [#3]'
      , i_env_param1 => i_object_id
      , i_env_param2 => i_split_hash
      , i_env_param3 => to_char(i_eff_date, 'dd-mm-yyyy hh24:mi:ss')
    );

    if i_entity_type <> acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
        com_api_error_pkg.raise_error(
            i_error       => 'ENTITY_TYPE_NOT_SUPPORTED'
          , i_env_param1  => i_entity_type
        );
    else
        l_account_id := i_object_id;
    end if;

    -- get total amount due
    l_invoice_id := crd_invoice_pkg.get_last_invoice_id(
                        i_account_id  => l_account_id
                      , i_split_hash  => i_split_hash
                      , i_mask_error  => com_api_const_pkg.FALSE
                    );

    begin
        select i.total_amount_due
             , a.currency
          into l_amount_rec.amount
             , l_amount_rec.currency
          from acc_account a
             , crd_invoice i
         where a.id = i.account_id
           and i.id = l_invoice_id;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error       => 'INVOICE_NOT_FOUND'
              , i_env_param1  => l_invoice_id
            );
    end;

    select nvl(sum(amount), 0)
      into l_total_payment_amount
      from crd_payment
     where decode(is_new, 1, account_id, null) = l_account_id
       and is_reversal = com_api_const_pkg.FALSE;

    trc_log_pkg.debug(
        i_text       => 'l_total_payment_amount amount [#1], TAD [#2]'
      , i_env_param1 => l_total_payment_amount
      , i_env_param2 => l_amount_rec.amount
    );

    begin
        select inst_id, currency
          into l_inst_id, l_currency
          from acc_account a
         where id = l_account_id;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error       => 'ACCOUNT_NOT_FOUND'
              , i_env_param1  => l_account_id
            );
    end;

    l_service_id :=
        prd_api_service_pkg.get_active_service_id(
            i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => l_account_id
          , i_attr_name         => null
          , i_service_type_id   => crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID
          , i_split_hash        => i_split_hash
          , i_eff_date          => i_eff_date
          , i_inst_id           => l_inst_id
        );

    l_product_id := prd_api_product_pkg.get_product_id(
        i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
      , i_object_id   => l_account_id
      , i_eff_date    => i_eff_date
      , i_inst_id     => l_inst_id
    );

    l_fee_id :=
        prd_api_product_pkg.get_attr_value_number(
            i_product_id    => l_product_id
          , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id     => l_account_id
          , i_attr_name     => crd_api_const_pkg.DIRECT_DEBIT_AMOUNT
          , i_split_hash    => i_split_hash
          , i_service_id    => l_service_id
          , i_params        => l_param_tab
          , i_eff_date      => i_eff_date
          , i_inst_id       => l_inst_id
        );

    -- calculate amount
    o_amount.amount :=
        fcl_api_fee_pkg.get_fee_amount(
            i_fee_id          => l_fee_id
          , i_base_amount     => l_amount_rec.amount
          , io_base_currency  => l_currency
          , i_eff_date        => i_eff_date
          , i_split_hash      => i_split_hash
        );
    o_amount.currency := l_currency;

    o_amount.amount := greatest(0, o_amount.amount - l_total_payment_amount);

    trc_log_pkg.debug(
        i_text       => 'calc_direct_debit_amount finish: fee amount [#1], fee currency [#2], fee_id [#3], TAD amount [#4], product_id [#5], service_id [#6]'
      , i_env_param1 => o_amount.amount
      , i_env_param2 => o_amount.currency
      , i_env_param3 => l_fee_id
      , i_env_param4 => l_amount_rec.amount
      , i_env_param5 => l_product_id
      , i_env_param6 => l_service_id
    );
end;

procedure calc_original_order_amount(
    i_original_order_rec    in      pmo_api_type_pkg.t_payment_order_rec
  , io_amount               in out  com_api_type_pkg.t_amount_rec
) is
begin
    io_amount.currency   := i_original_order_rec.currency;
    io_amount.amount     := nvl(i_original_order_rec.amount, 0) - nvl(i_original_order_rec.resp_amount, 0);
end calc_original_order_amount;

procedure calc_partial_oper_amount is
    LOG_PREFIX     constant com_api_type_pkg.t_name    := lower($$PLSQL_UNIT) || '.calc_partial_oper_amount: ';
    l_eff_date              date;
    l_order_id              com_api_type_pkg.t_long_id;
    l_template_id           com_api_type_pkg.t_long_id;
    l_split_hash            com_api_type_pkg.t_tiny_id;
    l_amount                com_api_type_pkg.t_amount_rec;
    l_purpose_id            com_api_type_pkg.t_medium_id;
    l_customer_id           com_api_type_pkg.t_medium_id;
begin
    l_eff_date          := get_param_date(i_name => 'EFF_DATE');
    l_template_id       := get_param_num(i_name => 'TEMPLATE_ID');
    l_split_hash        := get_param_num(i_name => 'SPLIT_HASH');

    -- find prepared order
    begin
        select t.id
             , t.purpose_id
             , t.customer_id
          into l_order_id
             , l_purpose_id
             , l_customer_id
          from pmo_order t
         where t.status = pmo_api_const_pkg.PMO_STATUS_PREPARATION
           and t.event_date  = l_eff_date
           and t.template_id = l_template_id;

    exception
        when no_data_found then
            trc_log_pkg.debug(
                LOG_PREFIX || 'Order is not created. No one operation in current period.'
            );
            return;
    end;

    select sum(r.amount)
         , r.currency
      into l_amount.amount
         , l_amount.currency
      from pmo_order_detail d
         , opr_oper_detail o
         , pmo_order r -- detail of operation
     where d.order_id    = l_order_id
       and d.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
       and d.object_id   = o.oper_id
       and o.entity_type = pmo_api_const_pkg.ENTITY_TYPE_PAYMENT_ORDER
       and o.object_id   = r.id
       and r.purpose_id  = l_purpose_id
       and r.customer_id = l_customer_id
       and r.split_hash  = l_split_hash
     group by r.currency;

    set_param(
        i_name   => 'ORDER_AMOUNT'
      , i_value  => l_amount.amount
    );
    set_param(
        i_name   => 'CURRENCY'
      , i_value  => l_amount.currency
    );

end calc_partial_oper_amount;

end;
/
