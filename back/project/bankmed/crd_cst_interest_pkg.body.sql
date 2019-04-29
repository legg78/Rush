create or replace package body crd_cst_interest_pkg as

function get_invoice_data(
    i_account_id  in     com_api_type_pkg.t_account_id
  , i_split_hash  in     com_api_type_pkg.t_tiny_id
) return cst_bmed_type_pkg.t_crd_invoice_data result_cache relies_on (crd_invoice) is
    l_crd_invoice_data   cst_bmed_type_pkg.t_crd_invoice_data;
    l_last_invoice       crd_api_type_pkg.t_invoice_rec;
begin

    l_last_invoice := crd_invoice_pkg.get_last_invoice(
        i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
      , i_object_id    => i_account_id
      , i_split_hash   => i_split_hash
      , i_mask_error   => com_api_type_pkg.FALSE
    );

    l_crd_invoice_data.last_invoice_date := l_last_invoice.invoice_date;    
    l_crd_invoice_data.last_due_date     := l_last_invoice.due_date;
    
    fcl_api_cycle_pkg.get_cycle_date(
        i_cycle_type        => crd_api_const_pkg.INVOICING_PERIOD_CYCLE_TYPE
      , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
      , i_object_id         => i_account_id
      , i_split_hash        => i_split_hash
      , o_prev_date         => l_last_invoice.due_date
      , o_next_date         => l_crd_invoice_data.next_invoice_date
    );

  return l_crd_invoice_data;
end;

function get_fee_amount(
    i_fee_id            in      com_api_type_pkg.t_short_id
  , i_base_amount       in      com_api_type_pkg.t_money
  , i_base_count        in      com_api_type_pkg.t_long_id          default 1
  , io_base_currency    in out  com_api_type_pkg.t_curr_code
  , i_entity_type       in      com_api_type_pkg.t_dict_value       default null
  , i_object_id         in      com_api_type_pkg.t_long_id          default null
  , i_eff_date          in      date                                default null
  , i_calc_period       in      com_api_type_pkg.t_tiny_id          default 0
  , i_split_hash        in      com_api_type_pkg.t_tiny_id          default null
  , i_fee_included      in      com_api_type_pkg.t_boolean          default null
  , i_start_date        in      date                                default null
  , i_end_date          in      date                                default null
  , i_alg_calc_intr     in      com_api_type_pkg.t_dict_value
  , i_debt_id           in      com_api_type_pkg.t_long_id
  , i_balance_type      in      com_api_type_pkg.t_dict_value
  , i_debt_intr_id      in      com_api_type_pkg.t_long_id
  , i_service_id        in      com_api_type_pkg.t_short_id
  , i_product_id        in      com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_money is
    l_fee_amount        com_api_type_pkg.t_money := 0;
    l_fee_rate_calc     com_api_type_pkg.t_dict_value;
    l_fee_base_calc     com_api_type_pkg.t_dict_value;
    l_fee_type          com_api_type_pkg.t_dict_value;
    l_currency          com_api_type_pkg.t_curr_code;
    l_limit_type        com_api_type_pkg.t_dict_value;
    l_limit_id          com_api_type_pkg.t_long_id;
    l_inst_id           com_api_type_pkg.t_inst_id;
    l_crd_invoice_data  cst_bmed_type_pkg.t_crd_invoice_data; 
    l_pay_date          date;
    l_pay_amount        com_api_type_pkg.t_money;
    l_percent_rate      com_api_type_pkg.t_money;
begin
    trc_log_pkg.debug('crd_cst_interest_pkg.get_fee_amount: i_fee_id ['||i_fee_id||'] i_start_date ['
        ||to_char(i_start_date, 'dd.mm.yyyy hh24:mi:ss')
        ||'] i_end_date ['||to_char(i_end_date, 'dd.mm.yyyy hh24:mi:ss')||']');

    begin
        select f.fee_type
             , f.currency
             , f.fee_rate_calc
             , f.fee_base_calc
             , t.limit_type
             , f.limit_id
             , f.inst_id
          into l_fee_type
             , l_currency
             , l_fee_rate_calc
             , l_fee_base_calc
             , l_limit_type
             , l_limit_id
             , l_inst_id
          from fcl_fee f
             , fcl_fee_type t
         where f.id       = i_fee_id
           and f.fee_type = t.fee_type;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error         => 'FEE_NOT_FOUND'
              , i_env_param1    => i_fee_id
            );
    end;

    if l_fee_rate_calc != fcl_api_const_pkg.FEE_RATE_FLAT_PERCENTAGE 
   and l_fee_rate_calc != fcl_api_const_pkg.FEE_RATE_FIXED_VALUE then
        com_api_error_pkg.raise_error(
            i_error         => 'CST_INCORRECT_FEE_RATE_CALC'
          , i_env_param1    => l_fee_rate_calc
        );
    end if;
    
    if i_entity_type != acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
        com_api_error_pkg.raise_error(
            i_error      => 'NOT_SUPPORTED_ENTITY_TYPE'
          , i_env_param1 => i_entity_type
        );
    end if;
       
    begin        
        select percent_rate
          into l_percent_rate
          from fcl_fee_tier
         where fee_id = i_fee_id;

    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error        => 'FEE_RATE_NOT_FOUND'
              , i_env_param1   => i_fee_id
              , i_entity_type  => i_entity_type
              , i_object_id    => i_object_id
            );
    end;

    trc_log_pkg.debug(
        'l_fee_rate_calc='||l_fee_rate_calc
    ||', l_fee_base_calc='||l_fee_base_calc
    ||', l_fee_type='||l_fee_type
    ||', l_percent_rate='||l_percent_rate
    );

    l_crd_invoice_data := get_invoice_data(
          i_account_id  => i_object_id
        , i_split_hash  => i_split_hash
      );
    -- check algorithm
    if i_alg_calc_intr = cst_bmed_csc_const_pkg.STMT_BALANCE_WO_PAYMENT_CYCLE then

        select min(dp.eff_date)   keep (dense_rank first order by dp.eff_date) as pay_date
             , min(dp.pay_amount) keep (dense_rank first order by dp.eff_date) as pay_amount
          into l_pay_date
             , l_pay_amount
          from crd_debt_payment dp
         where dp.eff_date >= trunc(l_crd_invoice_data.last_invoice_date) 
           and dp.eff_date <  trunc(l_crd_invoice_data.next_invoice_date)
           and dp.debt_id   = i_debt_id;

         if trunc(l_pay_date) <= trunc(l_crd_invoice_data.last_due_date) then

             l_fee_amount := l_percent_rate / 100 / 30 
                * (i_base_amount * (trunc(l_crd_invoice_data.next_invoice_date) - trunc(l_crd_invoice_data.last_invoice_date))
                 - l_pay_amount *  (trunc(l_crd_invoice_data.next_invoice_date) - trunc(l_pay_date))
                 );

        else

            fcl_api_fee_pkg.get_fee_amount(
                i_fee_id         => i_fee_id
              , i_base_amount    => i_base_amount
              , i_base_currency  => io_base_currency
              , i_entity_type    => i_entity_type
              , i_object_id      => i_object_id
              , i_split_hash     => i_split_hash
              , i_eff_date       => i_eff_date
              , i_start_date     => i_start_date
              , i_end_date       => i_end_date
              , io_fee_currency  => l_currency
              , o_fee_amount     => l_fee_amount
            );
            
        end if;
        
    elsif i_alg_calc_intr = cst_bmed_csc_const_pkg.STMT_BALANCE_WO_FULL_CYCLE then
    
        select min(dp.eff_date) keep (dense_rank first order by dp.eff_date) as pay_date
             , sum(dp.pay_amount) as pay_amount
          into l_pay_date
             , l_pay_amount
          from crd_debt_payment dp
         where dp.eff_date >= trunc(l_crd_invoice_data.last_invoice_date) 
           and dp.eff_date <  trunc(l_crd_invoice_data.last_due_date) + 1
           and dp.debt_id   = i_debt_id;

        l_fee_amount := greatest(l_percent_rate * (i_base_amount - l_pay_amount) / 100, 0);

    else
        com_api_error_pkg.raise_error(
            i_error      => 'CST_UNKNOWN_INTEREST_CALC_ALGORITHM'
          , i_env_param1 => i_alg_calc_intr
        );
    end if;

    return l_fee_amount;
end;

function charge_interest_needed(
    i_debt_id           in      com_api_type_pkg.t_long_id
  , i_oper_id           in      com_api_type_pkg.t_long_id
  , i_account_id        in      com_api_type_pkg.t_account_id
  , i_eff_date          in      date
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
)return com_api_type_pkg.t_boolean
is
begin
    --check debt
    return com_api_type_pkg.TRUE;
end;

function get_fee_desc(
    i_product_id        in      com_api_type_pkg.t_short_id
  , i_alg_calc_intr     in      com_api_type_pkg.t_dict_value   default null
  , i_service_id        in      com_api_type_pkg.t_short_id
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_params            in      com_api_type_pkg.t_param_tab
  , i_fee_id            in      com_api_type_pkg.t_short_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id      default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id      default null
  , i_eff_date          in      date                            default null
) return com_api_type_pkg.t_full_desc is
begin
    return fcl_ui_fee_pkg.get_fee_desc(i_fee_id => i_fee_id);
end;

function get_fee_desc(
    i_debt_intr_id      in      com_api_type_pkg.t_long_id
  , i_fee_id            in      com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_full_desc is
begin
    return fcl_ui_fee_pkg.get_fee_desc(i_fee_id => i_fee_id);
end;

function get_interest_charge_event_type(
    i_account_id        in      com_api_type_pkg.t_account_id
  , i_eff_date          in      date
  , i_period_date       in      date
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
  , i_event_type        in      com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_dict_value
is
begin
    return i_event_type;
end;

end;
/
