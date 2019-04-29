create or replace package body crd_cst_debt_pkg as
/************************************************************
* Manipulatons with debts and its interests <br />
* Created by Madan B.(madan@bpcbt.com) at 26.03.2014 <br />
* Module: CRD_CST_DEBT_PKG <br />
* @headcom
************************************************************/

/***********************************************************************
 * Loads additional debt's parameters.
 * @param i_debt_id        ID of a debt for a client's account
 * @param i_account_id     ID of a client's account
 * @param i_product_id     ID of a product
 * @param i_service_id     ID of a service
 * @param i_split_hash     Split hash value
 * @param io_param_tab     Parameters of a debt
 *
 ***********************************************************************/
procedure load_debt_param (
    i_debt_id           in            com_api_type_pkg.t_long_id      default null
  , i_account_id        in            com_api_type_pkg.t_long_id
  , i_product_id        in            com_api_type_pkg.t_short_id
  , i_service_id        in            com_api_type_pkg.t_short_id     default null
  , i_split_hash        in            com_api_type_pkg.t_tiny_id      default null
  , io_param_tab        in out nocopy com_api_type_pkg.t_param_tab
) is
    l_invoice                         crd_api_type_pkg.t_invoice_rec;
begin
    l_invoice :=
        crd_invoice_pkg.get_last_invoice(
            i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id    => i_account_id
          , i_split_hash   => i_split_hash
          , i_mask_error   => com_api_const_pkg.TRUE
        );
    rul_api_param_pkg.set_param(
        io_params  => io_param_tab
      , i_name     => 'INVOICE_AGING_PERIOD'
      , i_value    => nvl(l_invoice.aging_period, 0)
    );

    rul_api_param_pkg.set_param(
        io_params  => io_param_tab
      , i_name     => 'ACCOUNT_ID'
      , i_value    => i_account_id
    );
end load_debt_param;

function get_oper_type(
    i_debt_id           in      com_api_type_pkg.t_long_id      default null
    , i_oper_id         in      com_api_type_pkg.t_long_id      default null
    , i_oper_type       in      com_api_type_pkg.t_dict_value
    , i_balance_type    in      com_api_type_pkg.t_dict_value
    , i_macros_type_id  in      com_api_type_pkg.t_tiny_id      default null
) return com_api_type_pkg.t_tiny_id
is
    l_debt_status               com_api_type_pkg.t_dict_value;
begin
    if i_debt_id is not null then
        select status
          into l_debt_status
          from crd_debt_vw
         where id = i_debt_id;

        if l_debt_status != crd_api_const_pkg.DEBT_STATUS_ACTIVE then
            return 3;
        end if;
    end if;

    if i_balance_type in (crd_api_const_pkg.BALANCE_TYPE_INTEREST, crd_api_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST, crd_api_const_pkg.BALANCE_TYPE_INTR_OVERLIMIT) then
        return 2;
    else
        return 1;
    end if;
end;

function get_oper_name(
    i_oper_type       in      com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_name
is
begin
    case i_oper_type
        when 1 then
            return 'CRD_INVOICE_OPERATIONS';
        when 2 then
            return 'CRD_INVOICE_INTEREST';
        when 3 then
            return 'CRD_INVOICE_DISPUTED_OPERATIONS';
    end case;
end;

function get_oper_descr(
    i_debt_id           in      com_api_type_pkg.t_long_id     default null
    , i_oper_id         in      com_api_type_pkg.t_long_id     default null
    , i_oper_type       in      com_api_type_pkg.t_dict_value
    , i_oper_date       in      date
    , i_merchant_city   in      com_api_type_pkg.t_name
    , i_merchant_street in      com_api_type_pkg.t_name
    , i_oper_type_n     in      com_api_type_pkg.t_tiny_id
    , i_lang            in      com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_name
is
    l_oper_type            com_api_type_pkg.t_name;
    l_merchant_address     com_api_type_pkg.t_name;
    l_oper_descr           com_api_type_pkg.t_name;
begin
    if i_oper_type_n in (1, 3) then
        l_oper_type        := com_api_dictionary_pkg.get_article_text(i_oper_type, i_lang);

        select nvl2(i_merchant_city, i_merchant_city || ', ', null) || i_merchant_street
          into l_merchant_address
          from dual;

        select nvl2(l_oper_type, l_oper_type || ' ', null) || nvl2(i_oper_date, i_oper_date || ' ', null) || l_merchant_address
          into l_oper_descr
          from dual;

    elsif i_oper_type_n = 2 then
        l_oper_descr       := com_api_dictionary_pkg.get_article_text(i_oper_type, i_lang);
    end if;

    return l_oper_descr;
end;

/*
* Check if this is the first debt, and if match condition trx_date within defined prior X days
* then register event EVNT1001
*/
procedure debt_postprocess(
    i_debt_id           in      com_api_type_pkg.t_long_id
) is
    l_inst_id                       com_api_type_pkg.t_inst_id;
    l_service_id                    com_api_type_pkg.t_short_id;
    l_account_id                    com_api_type_pkg.t_account_id;
    l_split_hash                    com_api_type_pkg.t_tiny_id;
    l_invoice_id                    com_api_type_pkg.t_medium_id;
    l_new_account_skip_mad_window   com_api_type_pkg.t_tiny_id;
    l_param_tab                     com_api_type_pkg.t_param_tab;
    l_eff_date                      date;
    l_oper_date                     date;
    l_prev_date                     date;
    l_next_date                     date;

begin
    l_eff_date := com_api_sttl_day_pkg.get_sysdate;

    select account_id
         , split_hash
         , service_id
         , inst_id
         , case
               when oper_type in ('OPTP0012', 'OPTP5006') then
                   posting_date
               else
                   oper_date
           end
      into l_account_id
         , l_split_hash
         , l_service_id
         , l_inst_id
         , l_oper_date
      from crd_debt d
     where id = i_debt_id
       and id = (select min(id)
                   from crd_debt
                  where account_id =  d.account_id);

    l_new_account_skip_mad_window :=
        prd_api_product_pkg.get_attr_value_number(
            i_entity_type        => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id          => l_account_id
          , i_attr_name          => crd_api_const_pkg.NEW_ACCOUNT_SKIP_MAD_WINDOW
          , i_service_id         => l_service_id
          , i_eff_date           => l_eff_date
          , i_split_hash         => l_split_hash
          , i_inst_id            => l_inst_id
          , i_use_default_value  => com_api_const_pkg.TRUE
          , i_default_value      => null
        );

    if nvl(l_new_account_skip_mad_window, 0) <= 0 then
        trc_log_pkg.info(
            i_text       => 'CRD_SKIPPING_MAD_IS_NOT_AVAILBLE'
          , i_env_param1 => 'skipping MAD window is not defined'
        );
    else
        fcl_api_cycle_pkg.get_cycle_date(
            i_cycle_type   => crd_api_const_pkg.INVOICING_PERIOD_CYCLE_TYPE
          , i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id    => l_account_id
          , i_split_hash   => l_split_hash
          , i_add_counter  => com_api_const_pkg.FALSE
          , o_prev_date    => l_prev_date
          , o_next_date    => l_next_date
        );
        if (l_next_date - l_oper_date) < l_new_account_skip_mad_window then
            evt_api_event_pkg.register_event(
                i_event_type   => crd_api_const_pkg.CREATE_DEBT_EVENT
              , i_eff_date     => l_eff_date
              , i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id    => l_account_id
              , i_inst_id      => l_inst_id
              , i_split_hash   => l_split_hash
              , i_param_tab    => l_param_tab
            );
        end if;
    end if;

exception
    when no_data_found then
        null;
end;

end;
/
