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
begin
    null;
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

procedure debt_postprocess(
    i_debt_id           in      com_api_type_pkg.t_long_id
) is
    l_inst_id                   com_api_type_pkg.t_inst_id;
    l_service_id                com_api_type_pkg.t_short_id;
    l_card_id                   com_api_type_pkg.t_medium_id;
    l_split_hash                com_api_type_pkg.t_tiny_id;
    l_invoice_id                com_api_type_pkg.t_medium_id;
    l_lty_first_trans_allowance com_api_type_pkg.t_tiny_id;
    l_param_tab                 com_api_type_pkg.t_param_tab;
    l_eff_date                  date;
    l_posting_date              date;
    l_iss_date                  date;
    l_next_date                 date;

begin
    l_eff_date := com_api_sttl_day_pkg.get_sysdate;

    select i.card_id
         , i.split_hash
         , i.inst_id
         , d.posting_date
         , i.iss_date
      into l_card_id
         , l_split_hash
         , l_inst_id
         , l_posting_date
         , l_iss_date
      from crd_debt d
         , iss_card_instance i
     where d.id         = i_debt_id
       and d.card_id    = i.card_id
       and d.id         = (select min(id)
                             from crd_debt
                            where account_id = d.account_id
                              and oper_type  = opr_api_const_pkg.OPERATION_TYPE_PURCHASE);

    if l_iss_date is not null then
        l_lty_first_trans_allowance :=
            prd_api_product_pkg.get_attr_value_number(
                i_entity_type        => iss_api_const_pkg.ENTITY_TYPE_CARD
              , i_object_id          => l_card_id
              , i_attr_name          => 'LTY_FIRST_TRANS_DAYS_ALLOWANCE'
              , i_service_id         => cst_cab_api_const_pkg.CARD_LOYALTY_SERVICE
              , i_eff_date           => l_eff_date
              , i_split_hash         => l_split_hash
              , i_inst_id            => l_inst_id
              , i_use_default_value  => com_api_const_pkg.TRUE
              , i_default_value      => null
            );

        trc_log_pkg.debug(i_text => 'debt_postprocess: l_lty_first_trans_allowance [#1], l_posting_date [#2], l_iss_date [#3]'
          , i_env_param1 => l_lty_first_trans_allowance
          , i_env_param2 => l_posting_date
          , i_env_param3 => l_iss_date
        );

        if nvl(l_lty_first_trans_allowance, 0) <= 0 then
            trc_log_pkg.info(
                i_text       => 'LTY_WELCOME_IS_NOT_AVAILBLE'
              , i_env_param1 => 'eligible period has not defined'
            );
        else
            if (l_posting_date - l_iss_date) <= l_lty_first_trans_allowance then
                evt_api_event_pkg.register_event(
                    i_event_type   => crd_api_const_pkg.CREATE_DEBT_EVENT
                  , i_eff_date     => l_eff_date
                  , i_entity_type  => iss_api_const_pkg.ENTITY_TYPE_CARD
                  , i_object_id    => l_card_id
                  , i_inst_id      => l_inst_id
                  , i_split_hash   => l_split_hash
                  , i_param_tab    => l_param_tab
                );
            end if;
        end if;
    end if;
exception
    when no_data_found then
        null;
end;

end;
/
