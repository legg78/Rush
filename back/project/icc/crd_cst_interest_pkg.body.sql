create or replace package body crd_cst_interest_pkg as

ALGORITHM_CALC_INTR_ICC     constant com_api_type_pkg.t_dict_value := 'ACIL5002';

procedure get_period_coeff(
    i_start_date            in      date
  , i_end_date              in      date
  , i_eff_date              in      date
  , i_length_type           in      com_api_type_pkg.t_dict_value
  , i_length_type_algorithm in      com_api_type_pkg.t_dict_value
  , o_period_coeff              out number
  , o_period_coeff1             out number
) is
begin
    -- from formula it is n/N 
    if trunc(i_start_date, 'MONTH') < trunc(i_end_date, 'MONTH') then                            
                            
        o_period_coeff  := (last_day(trunc(i_start_date, 'MONTH')) + 1 - com_api_const_pkg.ONE_SECOND - i_start_date)/to_number(to_char(last_day(i_start_date), 'dd'));
        o_period_coeff1 := (i_end_date - trunc(i_end_date, 'MONTH'))/to_number(to_char(last_day(i_end_date), 'dd'));
    else
        o_period_coeff  := (i_end_date - i_start_date)/to_number(to_char(last_day(i_start_date), 'dd'));   
    end if;
    
    --from formula it is 30/360*100
    o_period_coeff := o_period_coeff * 30 /36000;
    
    if o_period_coeff1 is not null then
        o_period_coeff1 := o_period_coeff1 * 30 /36000;
    end if;
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
) return com_api_type_pkg.t_money
is
    l_fee_amount        com_api_type_pkg.t_money := 0;

    l_fee_type          com_api_type_pkg.t_dict_value;
    l_currency          com_api_type_pkg.t_curr_code;
    l_fee_rate_calc     com_api_type_pkg.t_dict_value;
    l_fee_base_calc     com_api_type_pkg.t_dict_value;
    l_limit_type        com_api_type_pkg.t_dict_value;
    l_limit_id          com_api_type_pkg.t_long_id;
    l_inst_id           com_api_type_pkg.t_inst_id;

    l_length_type       com_api_type_pkg.t_dict_value;
    l_length_type_algorithm  com_api_type_pkg.t_dict_value;  
    l_percent_rate      number                   := 1;
    
    l_eff_date          date;
    l_period_coeff      number                   := 1;
    l_period_coeff1     number;
    
begin
    trc_log_pkg.debug('crd_cst_interest_pkg.get_fee_amount: i_fee_id ['||i_fee_id||'] i_start_date ['||to_char(i_start_date, 'dd.mm.yyyy hh24:mi:ss')||'] i_end_date ['||to_char(i_end_date, 'dd.mm.yyyy hh24:mi:ss')||']');

    -- check angorithm
    if i_alg_calc_intr = crd_cst_interest_pkg.ALGORITHM_CALC_INTR_ICC then

        l_eff_date := nvl(i_eff_date, com_api_sttl_day_pkg.get_sysdate);

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
             where f.id = i_fee_id
               and f.fee_type = t.fee_type;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error         => 'FEE_NOT_FOUND'
                  , i_env_param1    => i_fee_id
                );
        end;

        trc_log_pkg.debug('l_fee_rate_calc ['||l_fee_rate_calc||'] l_fee_base_calc ['||l_fee_base_calc||'] l_fee_type ['||l_fee_type||']');

        if l_fee_rate_calc != fcl_api_const_pkg.FEE_RATE_FLAT_PERCENTAGE or l_fee_base_calc != fcl_api_const_pkg.FEE_BASE_INCOMING_AMOUNT then

            com_api_error_pkg.raise_error(
                i_error         => 'CST_ICC_INCONSISTENT_FEE_PROPERTIES'
              , i_env_param1    => i_alg_calc_intr
              , i_env_param2    => fcl_api_const_pkg.FEE_RATE_FLAT_PERCENTAGE
              , i_env_param3    => fcl_api_const_pkg.FEE_BASE_INCOMING_AMOUNT
              , i_env_param4    => l_fee_rate_calc
              , i_env_param5    => l_fee_base_calc
            );
            
        end if;
        
        begin        
            select percent_rate    
                 , length_type 
                 , length_type_algorithm    
              into l_percent_rate        
                 , l_length_type 
                 , l_length_type_algorithm    
              from fcl_fee_tier     
             where fee_id = i_fee_id;
                
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error             => 'FEE_RATE_NOT_FOUND'
                  , i_env_param1        => i_fee_id
                  , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                  , i_object_id         => i_object_id
                );
        end;
        trc_log_pkg.debug('l_percent_rate= ' || l_percent_rate || ', l_length_type= ' || l_length_type || ', l_length_type_algorithm= '||l_length_type_algorithm);         
        
        get_period_coeff(
            i_start_date            => i_start_date
          , i_end_date              => i_end_date
          , i_eff_date              => l_eff_date
          , i_length_type           => l_length_type
          , i_length_type_algorithm => l_length_type_algorithm
          , o_period_coeff          => l_period_coeff
          , o_period_coeff1         => l_period_coeff1
        );
        
        trc_log_pkg.debug('l_period_coeff= ' || l_period_coeff || ', l_period_coeff1= ' || l_period_coeff1 || ', i_base_amount= ' || i_base_amount);                 
        
        l_fee_amount :=
            i_base_amount * l_percent_rate * l_period_coeff;

        if l_period_coeff1 is not null then
            l_fee_amount := l_fee_amount + 
                i_base_amount * l_percent_rate * l_period_coeff1;
        end if;
        
        trc_log_pkg.debug('l_fee_amount= ' || l_fee_amount);                 
        
    end if;

    return l_fee_amount;
    
end;

function charge_interest_needed(
    i_debt_id           in      com_api_type_pkg.t_long_id
  , i_oper_id           in      com_api_type_pkg.t_long_id          default null
  , i_account_id        in      com_api_type_pkg.t_account_id       default null
  , i_eff_date          in      date                                default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id          default null
  , i_split_hash        in      com_api_type_pkg.t_tiny_id          default null
  , i_event_type        in      com_api_type_pkg.t_dict_value       default null
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
