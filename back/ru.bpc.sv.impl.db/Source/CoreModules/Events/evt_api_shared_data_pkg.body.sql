create or replace package body evt_api_shared_data_pkg is
/*********************************************************
 *  API for shared data of events <br />
 *  Created by Filimonov A.(filimonov@bpcbt.com)  at 10.05.2011 <br />
 *  Module: EVT_API_SHARED_DATA_PKG  <br />
 *  @headcom
 **********************************************************/

procedure clear_shared_data is
begin
    rul_api_param_pkg.clear_params (
        io_params           => g_params
    );
end;

function get_param_num (
    i_name              in com_api_type_pkg.t_name
    , i_mask_error      in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    , i_error_value     in com_api_type_pkg.t_name := null
) return number is
begin
    return rul_api_param_pkg.get_param_num (
        i_name              => i_name
        , io_params         => g_params
        , i_mask_error      => i_mask_error
        , i_error_value     => i_error_value
    );
end;

function get_param_date (
    i_name              in com_api_type_pkg.t_name
    , i_mask_error      in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    , i_error_value     in com_api_type_pkg.t_name := null
) return date is
begin
    return rul_api_param_pkg.get_param_date (
        i_name              => i_name
        , io_params         => g_params
        , i_mask_error      => i_mask_error
        , i_error_value     => i_error_value
    );
end;

function get_param_char (
    i_name              in com_api_type_pkg.t_name
    , i_mask_error      in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    , i_error_value     in com_api_type_pkg.t_name := null
) return com_api_type_pkg.t_name is
begin
    return rul_api_param_pkg.get_param_char (
        i_name              => i_name
        , io_params         => g_params
        , i_mask_error      => i_mask_error
        , i_error_value     => i_error_value
    );
end;

procedure set_param (
    i_name              in com_api_type_pkg.t_name
    , i_value           in com_api_type_pkg.t_name
) is
begin
    rul_api_param_pkg.set_param (
        i_name              => i_name
        , io_params         => g_params
        , i_value           => i_value
    );
end;

procedure set_param (
    i_name              in com_api_type_pkg.t_name
    , i_value           in number
) is
begin
    rul_api_param_pkg.set_param (
        i_name              => i_name
        , io_params         => g_params
        , i_value           => i_value
    );
end;

procedure set_param (
    i_name              in com_api_type_pkg.t_name
    , i_value           in date
) is
begin
    rul_api_param_pkg.set_param (
        i_name              => i_name
        , io_params         => g_params
        , i_value           => i_value
    );
end;

procedure set_amount (
    i_name              in com_api_type_pkg.t_name
    , i_amount          in com_api_type_pkg.t_money
    , i_currency        in com_api_type_pkg.t_curr_code
) is
begin
    rul_api_param_pkg.set_amount (
        i_name              => i_name
        , i_amount          => i_amount
        , i_currency        => i_currency
        , io_amount_tab     => g_amounts
    );
end;

procedure get_amount (
    i_name              in com_api_type_pkg.t_name
    , o_amount          out com_api_type_pkg.t_money
    , o_currency        out com_api_type_pkg.t_curr_code
    , i_mask_error      in com_api_type_pkg.t_boolean
    , i_error_amount    in com_api_type_pkg.t_money
    , i_error_currency  in com_api_type_pkg.t_curr_code
) is
begin
    rul_api_param_pkg.get_amount (
        i_name              => i_name
        , o_amount          => o_amount
        , o_currency        => o_currency
        , io_amount_tab     => g_amounts
        , i_mask_error      => i_mask_error
        , i_error_amount    => i_error_amount
        , i_error_currency  => i_error_currency
    );
end;

procedure set_account (
    i_name              in com_api_type_pkg.t_name
  , i_account_rec       in acc_api_type_pkg.t_account_rec
) is
begin
    rul_api_param_pkg.set_account (
        i_name              => i_name
      , i_account_rec       => i_account_rec
      , io_account_tab      => g_accounts
    );
end;

procedure get_account (
    i_name              in     com_api_type_pkg.t_name
  , o_account_rec          out acc_api_type_pkg.t_account_rec
  , i_mask_error        in     com_api_type_pkg.t_boolean     := com_api_type_pkg.FALSE
  , i_error_value       in     com_api_type_pkg.t_account_id  := null
) is
begin
    rul_api_param_pkg.get_account (
        i_name              => i_name
      , o_account_rec       => o_account_rec
      , io_account_tab      => g_accounts
      , i_mask_error        => i_mask_error
      , i_error_value       => i_error_value
    );
end;

procedure set_date (
    i_name              in com_api_type_pkg.t_name
    , i_date            in date
) is
begin
    rul_api_param_pkg.set_date (
        i_name              => i_name
        , i_date            => i_date
        , io_date_tab       => g_dates
    );
end;

procedure get_date (
    i_name              in com_api_type_pkg.t_name
    , o_date            out date
    , i_mask_error      in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    , i_error_value     in date := null
) is
begin
    rul_api_param_pkg.get_date (
        i_name              => i_name
        , o_date            => o_date
        , io_date_tab       => g_dates
        , i_mask_error      => i_mask_error
        , i_error_value     => i_error_value
    );
end;

procedure set_currency (
    i_name              in com_api_type_pkg.t_name
    , i_currency        in com_api_type_pkg.t_curr_code
) is
begin
    rul_api_param_pkg.set_currency (
        i_name              => i_name
        , i_currency        => i_currency
        , io_currency_tab   => g_currencies
    );
end;

procedure get_currency (
    i_name              in com_api_type_pkg.t_name
    , o_currency        out com_api_type_pkg.t_curr_code
    , i_mask_error      in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    , i_error_value     in com_api_type_pkg.t_curr_code := null
) is
begin
    rul_api_param_pkg.get_currency (
        i_name              => i_name
        , o_currency        => o_currency
        , io_currency_tab   => g_currencies
        , i_mask_error      => i_mask_error
        , i_error_value     => i_error_value
    );
end;

procedure load_event_params is
    l_entity_type   com_api_type_pkg.t_dict_value;
    l_object_id     com_api_type_pkg.t_long_id;
begin
    l_entity_type := get_param_char(i_name => 'ENTITY_TYPE');

    l_object_id   := get_param_num(i_name => 'OBJECT_ID');

    if l_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD then
        rul_api_shared_data_pkg.load_card_params(
            i_card_id     => l_object_id
          , io_params     => g_params
        );
    elsif l_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
        rul_api_shared_data_pkg.load_account_params(
            i_account_id  => l_object_id
          , io_params     => g_params
        );
    elsif l_entity_type = acq_api_const_pkg.ENTITY_TYPE_TERMINAL then
        rul_api_shared_data_pkg.load_terminal_params(
            i_terminal_id => l_object_id
          , io_params     => g_params
        );
    elsif l_entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT then
        rul_api_shared_data_pkg.load_merchant_params(
            i_merchant_id => l_object_id
          , io_params     => g_params
        );
    elsif l_entity_type = prd_api_const_pkg.ENTITY_TYPE_CUSTOMER then
        rul_api_shared_data_pkg.load_customer_params(
            i_customer_id => l_object_id
          , io_params     => g_params
        );
    end if;

    rul_api_shared_data_pkg.load_flexible_fields(
        i_entity_type => l_entity_type
      , i_object_id   => l_object_id
      , i_usage       => com_api_const_pkg.FLEXIBLE_FIELD_PROC_EVNT
      , io_params     => g_params
    );

    evt_cst_shared_data_pkg.collect_event_params(
        io_params => g_params
    );
end;

procedure load_event_customer_params is
    l_entity_type   com_api_type_pkg.t_dict_value;
    l_object_id     com_api_type_pkg.t_dict_value;
    l_customer_id   com_api_type_pkg.t_medium_id;
begin
    l_entity_type := get_param_char(i_name => 'ENTITY_TYPE');

    l_object_id   := get_param_num(i_name => 'OBJECT_ID');

    if l_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD then
        select customer_id
          into l_customer_id
          from iss_card
         where id = l_object_id;
    elsif l_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
        select customer_id
          into l_customer_id
          from acc_account
         where id = l_object_id;
    elsif l_entity_type = acq_api_const_pkg.ENTITY_TYPE_TERMINAL then
        select c.customer_id
          into l_customer_id
          from acq_terminal t
             , prd_contract c
         where t.id = l_object_id
           and t.contract_id = c.id;
    elsif l_entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT then
        select c.customer_id
          into l_customer_id
          from acq_merchant m
             , prd_contract c
         where m.id = l_object_id
           and c.id = m.contract_id;
    elsif l_entity_type = prd_api_const_pkg.ENTITY_TYPE_CONTRACT then
        select customer_id
          into l_customer_id
          from prd_contract
         where id = l_object_id;
    end if;

    if l_customer_id is not null then
        rul_api_shared_data_pkg.load_customer_params(
            i_customer_id  => l_customer_id
          , io_params      => g_params
        );
    end if;
end;

procedure load_event_contract_params is
    l_entity_type   com_api_type_pkg.t_dict_value;
    l_object_id     com_api_type_pkg.t_dict_value;
    l_contract_id   com_api_type_pkg.t_medium_id;
begin
    l_entity_type := get_param_char(i_name => 'ENTITY_TYPE');

    l_object_id   := get_param_num(i_name => 'OBJECT_ID');

    if l_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD then
        select contract_id
          into l_contract_id
          from iss_card
         where id = l_object_id;
    elsif l_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
        select contract_id
          into l_contract_id
          from acc_account
         where id = l_object_id;
    elsif l_entity_type = acq_api_const_pkg.ENTITY_TYPE_TERMINAL then
        select contract_id
          into l_contract_id
          from acq_terminal t
         where t.id = l_object_id;
    elsif l_entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT then
        select contract_id
          into l_contract_id
          from acq_merchant
         where id = l_object_id;
    end if;

    if l_contract_id is not null then
        rul_api_shared_data_pkg.load_contract_params(
            i_contract_id => l_contract_id
          , io_params     => g_params
         );
    end if;
end;

end;
/
