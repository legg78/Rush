create or replace package body crd_cst_interest_pkg as

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
begin
    -- check angorithm
    return 0;
end;

function charge_interest_needed(
  i_debt_id             in      com_api_type_pkg.t_long_id
  , i_oper_id           in      com_api_type_pkg.t_long_id
  , i_account_id        in      com_api_type_pkg.t_account_id
  , i_eff_date          in      date
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
  , i_event_type        in      com_api_type_pkg.t_dict_value
)return com_api_type_pkg.t_boolean
is
    l_last_invoice_id   com_api_type_pkg.t_medium_id;
    l_due_date          date;
    l_grace_date        date;
    l_is_skip_cal       com_api_type_pkg.t_boolean;
begin
    if i_event_type = crd_api_const_pkg.FORCE_INT_CHARGE_CYCLE_TYPE then 
        return com_api_type_pkg.FALSE;
    end if;

    l_last_invoice_id   := crd_invoice_pkg.get_last_invoice_id(
        i_account_id    => i_account_id
      , i_split_hash    => i_split_hash
      , i_mask_error    => com_api_const_pkg.TRUE
    );

    if l_last_invoice_id is not null then
        select due_date
             , grace_date
          into l_due_date
             , l_grace_date
          from crd_invoice
         where id   = l_last_invoice_id;

        select nvl(max(1),0)
          into l_is_skip_cal
          from crd_invoice_debt
         where invoice_id   = l_last_invoice_id
           and debt_id      = i_debt_id
           and rownum       = 1;

        if (i_eff_date > l_due_date and i_eff_date < l_grace_date) and
            l_is_skip_cal = com_api_const_pkg.TRUE
        then
            return com_api_type_pkg.FALSE;
        end if;
    end if;

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
