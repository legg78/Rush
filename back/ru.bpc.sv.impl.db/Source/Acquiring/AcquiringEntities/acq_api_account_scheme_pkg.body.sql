create or replace package body acq_api_account_scheme_pkg as
/*********************************************************
 *  API for Address in application <br />
 *  Created by Filimonov A.(filimonov@bpcbt.com)  at 17.11.2010 <br />
 *  Module: acq_api_account_scheme_pkg <br />
 *  @headcom
 **********************************************************/

procedure get_acq_account(
    i_merchant_id       in      com_api_type_pkg.t_short_id
  , i_terminal_id       in      com_api_type_pkg.t_short_id
  , i_currency          in      com_api_type_pkg.t_curr_code
  , i_oper_type         in      com_api_type_pkg.t_dict_value
  , i_reason            in      com_api_type_pkg.t_dict_value
  , i_sttl_type         in      com_api_type_pkg.t_dict_value
  , i_terminal_type     in      com_api_type_pkg.t_dict_value
  , i_oper_sign         in      com_api_type_pkg.t_sign
  , i_scheme_id         in      com_api_type_pkg.t_tiny_id        default null
  , o_account              out  acc_api_type_pkg.t_account_rec
) is
    cursor cu_account_scheme is
        select c.merchant_type
             , c.account_type
             , c.account_currency
          from acq_merchant a
             , acq_account_customer b
             , acq_account_pattern c
             , prd_contract d
         where a.id             = i_merchant_id
           and d.id             = a.contract_id
           and b.customer_id    = d.customer_id
           and c.scheme_id      = b.scheme_id
           and (c.currency      = i_currency      or c.currency      is null)
           and (i_oper_type     like c.oper_type)
           and (c.sttl_type     = i_sttl_type     or c.sttl_type     is null)
           and (i_terminal_type like nvl(c.terminal_type, '%') or (nvl(c.terminal_type, '%') = '%' and i_terminal_type is null))
           and (c.oper_sign     = i_oper_sign     or c.oper_sign     is null)
         order by c.priority;

    cursor cu_account_scheme_id is
        select c.merchant_type
             , c.account_type
             , c.account_currency
          from acq_account_pattern c
         where c.scheme_id = i_scheme_id;

    l_merchant_type     com_api_type_pkg.t_dict_value;
    l_entity_type       com_api_type_pkg.t_dict_value;
    l_object_id         com_api_type_pkg.t_long_id;

    cursor cu_merchant is
        select id
          from acq_merchant
         where (
                   merchant_type = l_merchant_type
                   or l_merchant_type in (acq_api_const_pkg.CURRENT_MERCHANT, acq_api_const_pkg.ANY_MERCHANT)
               )
        connect by id = prior parent_id
        start with id = i_merchant_id;

    cursor cu_account is
        select a.account_id
             , b.split_hash
             , b.account_number
             , b.currency
             , b.inst_id
             , b.agent_id
             , b.status
             , b.contract_id
             , b.customer_id
             , b.scheme_id
          from acc_account_object a
             , acc_account b
         where a.entity_type  = l_entity_type
           and a.object_id    = l_object_id
           and a.account_id   = b.id
           and b.currency     = case when coalesce(o_account.currency, '%') = '%' then i_currency else o_account.currency end
           and b.account_type like o_account.account_type
           and b.status      != acc_api_const_pkg.ACCOUNT_STATUS_CLOSED
         order by usage_order;

begin
    if i_scheme_id is null then
        open cu_account_scheme;
        fetch cu_account_scheme into l_merchant_type, o_account.account_type, o_account.currency;
        if cu_account_scheme%notfound then
            close cu_account_scheme;
            com_api_error_pkg.raise_error(
                i_error         => 'ACCOUNT_SCHEME_NOT_FOUND'
              , i_env_param1    => i_merchant_id
              , i_env_param2    => i_currency
              , i_env_param3    => i_oper_type
              , i_env_param4    => i_reason
              , i_env_param5    => i_sttl_type
              , i_env_param6    => i_terminal_type
            );
        end if;
        close cu_account_scheme;

    else
        open cu_account_scheme_id;
        fetch cu_account_scheme_id into l_merchant_type, o_account.account_type, o_account.currency;
        if cu_account_scheme_id%notfound then
            close cu_account_scheme_id;
            com_api_error_pkg.raise_error(
                i_error       => 'ACCOUNT_SCHEME_NOT_FOUND'
              , i_env_param1  => i_scheme_id
            );
        end if;
        close cu_account_scheme_id;

    end if;

    if acq_api_const_pkg.MERCHANT_TYPE_TERMINAL = l_merchant_type then
        l_entity_type := acq_api_const_pkg.ENTITY_TYPE_TERMINAL;
        l_object_id   := i_terminal_id;
    else
        l_entity_type := acq_api_const_pkg.ENTITY_TYPE_MERCHANT;
        open cu_merchant;
        fetch cu_merchant into l_object_id;
        close cu_merchant;

        if l_object_id is null then
            com_api_error_pkg.raise_error(
                i_error       => 'ACCOUNT_SCHEME_MERCHANT_NOT_FOUND'
              , i_env_param1  => i_merchant_id
              , i_env_param2  => l_merchant_type
            );
        end if;
    end if;

    open cu_account;
    fetch cu_account
     into o_account.account_id
        , o_account.split_hash
        , o_account.account_number
        , o_account.currency
        , o_account.inst_id
        , o_account.agent_id
        , o_account.status
        , o_account.contract_id
        , o_account.customer_id
        , o_account.scheme_id;
    close cu_account;

    if o_account.account_id is null then
        com_api_error_pkg.raise_error(
            i_error       => 'ACCOUNT_SCHEME_ACCOUNT_NOT_FOUND'
          , i_env_param1  => l_object_id
          , i_env_param2  => l_merchant_type
          , i_env_param3  => o_account.account_type
          , i_env_param4  => nvl(o_account.currency, i_currency)
        );
    end if;
exception
    when com_api_error_pkg.e_application_error then
        raise;
    when others then
        if cu_account_scheme%isopen then
            close cu_account_scheme;
        end if;
        if cu_account_scheme_id%isopen then
            close cu_account_scheme_id;
        end if;
        if cu_merchant%isopen then
            close cu_merchant;
        end if;
        if cu_account%isopen then
            close cu_account;
        end if;

        raise;
end;

end;
/
