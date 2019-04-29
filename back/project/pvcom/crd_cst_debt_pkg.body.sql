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
    l_oper_reason       com_api_type_pkg.t_dict_value;
begin
    select oper_reason
      into l_oper_reason
      from crd_debt d
         , opr_operation o
     where d.id         = i_debt_id
       and d.oper_id    = o.id
       and rownum       = 1;

    rul_api_param_pkg.set_param(
        io_params   => io_param_tab
      , i_name      => 'OPER_REASON'
      , i_value     => l_oper_reason
    );

    rul_api_param_pkg.set_param(
        io_params  => io_param_tab
      , i_name     => 'ACCOUNT_ID'
      , i_value    => i_account_id
    );
exception
    when no_data_found then
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
begin
    trc_log_pkg.debug(
        i_text          => 'crd_cst_debt_pkg.debt_postprocess dummy'
    );
end;

end;
/
