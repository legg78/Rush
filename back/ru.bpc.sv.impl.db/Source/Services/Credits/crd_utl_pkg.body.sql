create or replace package body crd_utl_pkg as

procedure generate_irr_payments(
    i_account_id            in     com_api_type_pkg.t_account_id
  , i_invoice_id            in     com_api_type_pkg.t_medium_id
  , i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_product_id            in     com_api_type_pkg.t_short_id
  , i_service_id            in     com_api_type_pkg.t_short_id
  , i_eff_date              in     date                            default null
  , i_split_hash            in     com_api_type_pkg.t_tiny_id      default null
  , i_mandatory_amount_due  in     com_api_type_pkg.t_money
  , i_interest_amount       in     com_api_type_pkg.t_money
  , i_total_amount_due      in     com_api_type_pkg.t_money
  , o_payment_tab              out com_api_type_pkg.t_money_tab
) is
    l_minimum_amount_due           com_api_type_pkg.t_money := 0;
    l_total_amount_due             com_api_type_pkg.t_money := 0;
    l_principal_amount             com_api_type_pkg.t_money := 0;
    l_starting_amount              com_api_type_pkg.t_money := 0;
    l_fee_amount                   com_api_type_pkg.t_money := 0;
    l_interest_amount              com_api_type_pkg.t_money := 0;
    l_card_service_id              com_api_type_pkg.t_medium_id;
    l_fee_id                       com_api_type_pkg.t_short_id;
    l_eff_date                     date;
    l_start_date                   date;
    l_end_date                     date;
    l_param_tab                    com_api_type_pkg.t_param_tab;
    l_currency                     com_api_type_pkg.t_curr_code;
    l_index                        pls_integer := 0;
    l_card_id                      com_api_type_pkg.t_medium_id;
    l_debt_id                      com_api_type_pkg.t_long_id;
    l_product_id                   com_api_type_pkg.t_short_id;
    
    l_split_hash                   com_api_type_pkg.t_tiny_id;
    l_inst_id                      com_api_type_pkg.t_inst_id;
begin
    trc_log_pkg.debug(
        i_text       => 'crd_utl_pkg.generate_irr_payments. i_account_id [#1], i_product_id [#2], i_service_id [#3], i_mandatory_amount_due [#4], i_interest_amount [#5], i_total_amount_due [#6]'
      , i_env_param1 => i_account_id
      , i_env_param2 => i_product_id
      , i_env_param3 => i_service_id
      , i_env_param4 => i_mandatory_amount_due
      , i_env_param5 => i_interest_amount
      , i_env_param6 => i_total_amount_due
    );
    l_eff_date := coalesce(i_eff_date, com_api_sttl_day_pkg.get_sysdate);
    begin
        select coalesce(i_inst_id, inst_id)
             , coalesce(i_split_hash, split_hash)
          into l_inst_id
             , l_split_hash
          from acc_account
         where id = i_account_id;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error             => 'ACCOUNT_NOT_FOUND'
              , i_env_param1        => i_account_id
            );
    end;

    -- get dates for calculating interest
    fcl_api_cycle_pkg.get_cycle_date(
        i_cycle_type        => crd_api_const_pkg.INVOICING_PERIOD_CYCLE_TYPE
      , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
      , i_object_id         => i_account_id
      , i_split_hash        => l_split_hash
      , o_prev_date         => l_start_date
      , o_next_date         => l_end_date
    );
    -- get minimum MAD for future use
    l_fee_id :=
        prd_api_product_pkg.get_fee_id (
            i_product_id    => i_product_id
          , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id     => i_account_id
          , i_fee_type      => crd_api_const_pkg.MINIMUM_MAD_FEE_TYPE
          , i_service_id    => i_service_id
          , i_params        => l_param_tab
          , i_eff_date      => l_eff_date
        );

    if l_fee_id is null then
        com_api_error_pkg.raise_error(
            i_error         => 'FEE_NOT_DEFINED'
          , i_env_param1    => crd_api_const_pkg.MINIMUM_MAD_FEE_TYPE
          , i_env_param2    => i_product_id
          , i_env_param3    => i_account_id
          , i_env_param4    => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_env_param5    => l_eff_date
        );
    end if;
    
    l_minimum_amount_due := round(
        fcl_api_fee_pkg.get_fee_amount(
            i_fee_id            => l_fee_id
          , i_base_amount       => i_total_amount_due
          , io_base_currency    => l_currency
          , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => i_account_id
          , i_eff_date          => l_eff_date
        )
    );

    l_principal_amount := i_mandatory_amount_due - i_interest_amount;    
    l_total_amount_due := i_total_amount_due - l_principal_amount;

    begin
        select t.debt_id     
             , t.card_id         
          into l_debt_id
             , l_card_id
          from (select d.id debt_id
                     , decode(d.oper_type, opr_api_const_pkg.OPERATION_TYPE_PURCHASE, 0, 1) oper_type
                     , row_number() over (partition by  decode(d.oper_type, opr_api_const_pkg.OPERATION_TYPE_PURCHASE, 0, 1) order by debt_id desc) rn
                     , d.card_id
                  from crd_invoice_debt i
                     , crd_debt d
                 where i.invoice_id    = i_invoice_id
                   and i.debt_id       = d.id    
                   and i.split_hash    = l_split_hash
               ) t
         where rn = 1;       
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error         => 'INVOICE_NOT_FOUND'
              , i_env_param1    => i_invoice_id
              , i_env_param2    => l_split_hash
            );
    end;

    l_card_service_id :=
        prd_api_service_pkg.get_active_service_id(
            i_entity_type    => iss_api_const_pkg.ENTITY_TYPE_CARD
          , i_object_id      => l_card_id
          , i_attr_type      => mcw_api_const_pkg.ANNUAL_CARD_FEE
          , i_eff_date       => l_eff_date
        );
        
    l_fee_id :=
        prd_api_product_pkg.get_fee_id (
            i_product_id    => i_product_id
          , i_entity_type   => iss_api_const_pkg.ENTITY_TYPE_CARD
          , i_object_id     => l_card_id
          , i_fee_type      => mcw_api_const_pkg.ANNUAL_CARD_FEE
          , i_service_id    => l_card_service_id
          , i_params        => l_param_tab
          , i_eff_date      => l_eff_date
          , i_split_hash    => l_split_hash
          , i_inst_id       => l_inst_id
        );

    if l_fee_id is null then
        com_api_error_pkg.raise_error(
            i_error         => 'FEE_NOT_DEFINED'
          , i_env_param1    => mcw_api_const_pkg.ANNUAL_CARD_FEE
          , i_env_param2    => i_product_id
          , i_env_param3    => l_card_id
          , i_env_param4    => iss_api_const_pkg.ENTITY_TYPE_CARD
          , i_env_param5    => l_eff_date
        );
    end if;

    fcl_api_fee_pkg.get_fee_amount(
        i_fee_id            => l_fee_id
      , i_base_amount       => 0
      , i_base_currency     => l_currency
      , i_entity_type       => iss_api_const_pkg.ENTITY_TYPE_CARD
      , i_object_id         => l_card_id
      , i_eff_date          => l_eff_date
      , i_split_hash        => l_split_hash
      , io_fee_currency     => l_currency
      , o_fee_amount        => l_fee_amount
    );

    l_starting_amount := l_total_amount_due - l_fee_amount;     
    l_index := o_payment_tab.count() + 1;
    o_payment_tab(l_index) := -1 * l_starting_amount;         
    l_index := o_payment_tab.count() + 1;
    o_payment_tab(l_index) := i_mandatory_amount_due;         

    crd_debt_pkg.load_debt_param(
        i_debt_id       => l_debt_id
      , io_param_tab    => l_param_tab
      , o_product_id    => l_product_id
      , i_split_hash    => l_split_hash
    );

    rul_api_param_pkg.set_param(
        i_value         => acc_api_const_pkg.BALANCE_TYPE_OVERDRAFT
      , i_name          => 'BALANCE_TYPE'
      , io_params       => l_param_tab
    );
    
    l_fee_id :=
        prd_api_product_pkg.get_fee_id (
            i_product_id    => l_product_id
          , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id     => i_account_id
          , i_fee_type      => crd_api_const_pkg.INTEREST_RATE_FEE_TYPE
          , i_split_hash    => l_split_hash
          , i_service_id    => i_service_id
          , i_params        => l_param_tab
          , i_eff_date      => l_eff_date
          , i_inst_id       => l_inst_id
        );

    if l_fee_id is null then
        com_api_error_pkg.raise_error(
            i_error         => 'FEE_NOT_DEFINED'
          , i_env_param1    => crd_api_const_pkg.INTEREST_RATE_FEE_TYPE
          , i_env_param2    => l_product_id
          , i_env_param3    => i_account_id
          , i_env_param4    => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_env_param5    => l_eff_date
        );
    end if;
    
    for i in 1..11 loop
         
        -- calc interests from new TAD
        fcl_api_fee_pkg.get_fee_amount(
            i_fee_id            => l_fee_id
          , i_base_amount       => l_total_amount_due -- from TAD
          , i_base_currency     => l_currency
          , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => i_account_id
          , i_split_hash        => l_split_hash
          , i_eff_date          => l_eff_date
          , i_start_date        => l_start_date
          , i_end_date          => l_end_date
          , io_fee_currency     => l_currency
          , o_fee_amount        => l_interest_amount
        );

        if i = 11 then
            l_minimum_amount_due := l_total_amount_due + l_interest_amount;   --last payment is TAD + interest
            l_principal_amount := l_total_amount_due;                         --last principal payment = TAD  
        else
            l_principal_amount := l_minimum_amount_due - l_interest_amount;   --others principal payments = minimum MAD - interest 
        end if;
        
        -- calculate new TAD
        l_total_amount_due := l_total_amount_due - l_principal_amount;
         
        -- save minimum MAD into tab
        l_index := o_payment_tab.count() + 1;
        o_payment_tab(l_index) := l_minimum_amount_due; 
    end loop; 
end;

function calculate_irr(
    i_account_id            in     com_api_type_pkg.t_account_id
  , i_invoice_id            in     com_api_type_pkg.t_medium_id
  , i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_product_id            in     com_api_type_pkg.t_short_id
  , i_service_id            in     com_api_type_pkg.t_short_id
  , i_eff_date              in     date                            default null
  , i_split_hash            in     com_api_type_pkg.t_tiny_id      default null
  , i_mandatory_amount_due  in     com_api_type_pkg.t_money
  , i_interest_amount       in     com_api_type_pkg.t_money
  , i_total_amount_due      in     com_api_type_pkg.t_money
) return com_api_type_pkg.t_money
is
    l_payment_tab                  com_api_type_pkg.t_money_tab;
    l_payment                      com_api_type_pkg.t_money := 0;
    l_irr                          number := 0;
    l_irr_min                      number := 0;
    l_irr_max                      number := 0;
    l_npv                          number := 1;
    l_npv_max                      number := 0;
    l_npv_min                      number := 0;

    function get_npv(
        i_rate              in     number
      , i_months            in     com_api_type_pkg.t_tiny_id
    ) return number
    is
        l_npv number := 0;
    begin
        for i in 2..i_months loop
            l_npv := l_npv + l_payment_tab(i) / power((1 + i_rate), (i - 1));
        end loop;
        return l_npv;
    end;
    function get_irr(
        i_npv_max           in     number
      , i_npv_min           in     number
      , i_irr_max           in     number
      , i_irr_min           in     number
    ) return number
    is
        l_irr number := 0;
    begin
        l_irr := i_irr_min + (i_irr_max - i_irr_min) * i_npv_max / (i_npv_max - i_npv_min);
        return l_irr;
    end;
begin
    trc_log_pkg.debug(
        i_text       => 'crd_utl_pkg.calculate_irr. i_account_id [#1], i_product_id [#2], i_service_id [#3], i_mandatory_amount_due [#4], i_interest_amount [#5], i_total_amount_due [#6]'
      , i_env_param1 => i_account_id
      , i_env_param2 => i_product_id
      , i_env_param3 => i_service_id
      , i_env_param4 => i_mandatory_amount_due
      , i_env_param5 => i_interest_amount
      , i_env_param6 => i_total_amount_due
    );
    
    generate_irr_payments(
        i_account_id            => i_account_id
      , i_invoice_id            => i_invoice_id
      , i_inst_id               => i_inst_id
      , i_product_id            => i_product_id
      , i_service_id            => i_service_id
      , i_eff_date              => i_eff_date
      , i_split_hash            => i_split_hash
      , i_mandatory_amount_due  => i_mandatory_amount_due
      , i_interest_amount       => i_interest_amount
      , i_total_amount_due      => i_total_amount_due
      , o_payment_tab           => l_payment_tab
    );
    
    if l_payment_tab.count > 0 then
        for i in 2..l_payment_tab.count loop
            l_payment := l_payment + l_payment_tab(i);
        end loop;
        
        if l_payment > abs(l_payment_tab(1)) then
            while round(abs(l_npv) * power(10, 8), 1) > 0
            loop
                l_npv := get_npv(i_rate   => l_irr
                               , i_months => l_payment_tab.count) + l_payment_tab(1);

                if l_npv_min < 0 and l_npv < 0 and abs(l_npv) > abs(l_npv_min) then
                    l_irr := l_irr_max;
                    exit;
                end if;

                if l_npv > 0 then
                    l_npv_max := l_npv;
                elsif l_npv < 0 then
                    l_npv_min := l_npv;
                else
                    exit;
                end if;

                if l_irr_max = 0 then
                    if l_npv_min < 0 then
                        l_irr_max := l_irr;
                    else
                        l_irr_min := l_irr;
                        l_irr := l_irr + com_api_const_pkg.ONE_PERCENT;
                    end if;
                else
                    if l_npv_max > 0 and l_npv_min < 0 then
                        l_irr_max := l_irr;
                        l_irr := get_irr(l_npv_max, l_npv_min, l_irr_max, l_irr_min);
                    elsif l_npv_min = 0 then
                        l_irr := l_irr + com_api_const_pkg.ONE_PERCENT;
                    end if;
                end if;
            end loop;
        end if;
        
    end if;
    
    return round(l_irr, 4);
end calculate_irr;

function calculate_apr(
    i_irr                   in     com_api_type_pkg.t_money
) return com_api_type_pkg.t_money
is
    l_apr                          com_api_type_pkg.t_money;
begin
    trc_log_pkg.debug(
        i_text       => 'crd_utl_pkg.calculate_apr. i_irr [#1] %'
      , i_env_param1 => i_irr * 100
    );
    l_apr := power(1 + i_irr, 12) - 1;
    return l_apr;
end calculate_apr;


function get_credit_accounts(
    i_customer_id           in     com_api_type_pkg.t_medium_id
  , i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_split_hash            in     com_api_type_pkg.t_tiny_id
  , i_eff_date              in     date                             default null
  , i_excluded_account_id   in     com_api_type_pkg.t_account_id    default null
) return acc_api_type_pkg.t_account_tab
is
    cursor l_cur_accounts(
        p_customer_id           in com_api_type_pkg.t_medium_id
      , p_inst_id               in com_api_type_pkg.t_inst_id
      , p_split_hash            in com_api_type_pkg.t_tiny_id
      , p_eff_date              in date
      , p_excluded_account_id   in com_api_type_pkg.t_account_id
    ) is
    select a.id
         , a.split_hash
         , a.account_type
         , a.account_number
         , null as friendly_name
         , a.currency
         , a.inst_id
         , a.agent_id
         , a.status
         , null as status_reason
         , a.contract_id
         , a.customer_id
         , a.scheme_id
         , null mod_id
      from acc_account a
         , prd_service s
         , prd_service_object so
     where so.entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
       and s.service_type_id = crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID
       and so.object_id   = a.id
       and so.service_id  = s.id
       and a.customer_id  = p_customer_id
       and a.split_hash   = p_split_hash
       and a.inst_id      = p_inst_id
       and a.id          != nvl(p_excluded_account_id, -1)
       and p_eff_date     between nvl(so.start_date, p_eff_date)
                              and nvl(so.end_date, p_eff_date);

    LOG_PREFIX          constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_credit_accounts: ';
    l_accounts_tab               acc_api_type_pkg.t_account_tab;
begin
    open
        l_cur_accounts(
            i_customer_id
          , i_inst_id
          , i_split_hash
          , coalesce(i_eff_date, com_api_sttl_day_pkg.get_calc_date(i_inst_id => i_inst_id))
          , i_excluded_account_id
        );

    fetch l_cur_accounts bulk collect into l_accounts_tab;

    close l_cur_accounts;

    return l_accounts_tab;
exception
    when others then
        if l_cur_accounts%isopen then
            close l_cur_accounts;
        end if;

        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'FAILED with i_customer_id [#1], i_inst_id [#2], i_split_hash [#3]'
          , i_env_param1 => i_customer_id
          , i_env_param2 => i_inst_id
          , i_env_param3 => i_split_hash
        );
        raise;
end get_credit_accounts;

procedure get_mad_payment_data(
    i_invoice_id            in     com_api_type_pkg.t_long_id
  , o_mad_payment_date         out date
  , o_mad_payment_sum          out com_api_type_pkg.t_money
) is
    LOG_PREFIX            constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_mad_payment_data';
    l_min_amount_due               com_api_type_pkg.t_money;
    l_payment_amount               com_api_type_pkg.t_money;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' << i_invoice_id [#1]'
      , i_env_param1 => i_invoice_id
    );

    if i_invoice_id is not null then
        l_payment_amount := 0;

        l_min_amount_due := crd_invoice_pkg.get_invoice(i_invoice_id => i_invoice_id).min_amount_due;

        for r in (select decode(p.is_reversal, 1, -1, 1) * nvl(p.amount, 0) as pay_amount
                       , p.posting_date
                    from crd_payment p
                       , crd_invoice_payment ip
                   where ip.invoice_id = i_invoice_id
                     and p.id          = ip.pay_id
                     and (p.is_reversal = com_api_const_pkg.FALSE
                          or
                          (p.is_reversal = com_api_const_pkg.TRUE
                           and
                           exists(select 1
                                    from crd_payment p2
                                       , crd_invoice_payment ip2
                                   where ip2.invoice_id = i_invoice_id
                                     and p2.id          = ip2.pay_id
                                     and p2.oper_id     = p.original_oper_id
                                     and p2.is_reversal = com_api_const_pkg.FALSE
                           )
                          )
                         )
        )
        loop
            l_payment_amount := l_payment_amount + r.pay_amount;
            if l_payment_amount >= l_min_amount_due then
                o_mad_payment_date := r.posting_date;
                o_mad_payment_sum  := l_payment_amount;
                exit;
            end if;
        end loop;
    end if;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' >> o_mad_payment_date [#1], o_mad_payment_sum [#2]'
      , i_env_param1 => o_mad_payment_date
      , i_env_param2 => o_mad_payment_sum
    );
end get_mad_payment_data;

end;
/
