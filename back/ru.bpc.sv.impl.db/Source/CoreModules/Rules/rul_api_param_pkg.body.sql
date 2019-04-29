create or replace package body rul_api_param_pkg is
/*********************************************************
 *  Rules - Parameter API  <br />
 *  Created by Khougaev A.(khougaev@bpcbt.com)  at 19.03.2010 <br />
 *  Module: RUL_API_PARAM_PKG <br />
 *  @headcom
 **********************************************************/

subtype t_param_rec is rul_mod_param%rowtype;
type t_param_def_tab is table of t_param_rec index by binary_integer;
type t_param_def_by_name_tab is table of t_param_rec index by com_api_type_pkg.t_name;

g_param_defs  t_param_def_by_name_tab;

procedure clear_params (
    io_params           in out nocopy com_api_type_pkg.t_param_tab
) is
begin
    io_params.delete;
end;

function serialize_params (
    i_params                in com_api_type_pkg.t_param_tab
) return varchar2 is
    result                  com_api_type_pkg.t_text;
    prm                     com_api_type_pkg.t_name;
begin
    prm := i_params.first;
    loop
        exit when prm is null;

        begin
            result := result || '<' || prm || '>=<' || i_params(prm) || '>';
        exception
            when com_api_error_pkg.e_value_error then
                exit;
        end;

        prm := i_params.next(prm);
    end loop;
    return result;
end;

function mask_value (
    i_name              in com_api_type_pkg.t_name
    , i_value           in com_api_type_pkg.t_param_value
) return com_api_type_pkg.t_param_value is
begin
--    trc_log_pkg.debug(
--        i_text          => 'PARAM_NAME = ' || i_name
--    );
    return
        case when i_name in ('CARD_NUMBER') then iss_api_card_pkg.get_card_mask(i_value)
             when i_name in (prs_api_const_pkg.PARAM_PVV
                            , prs_api_const_pkg.PARAM_PVK_INDEX
                            , prs_api_const_pkg.PARAM_CVV
                            , prs_api_const_pkg.PARAM_CVV2
                            , prs_api_const_pkg.PARAM_ICVV
                            , prs_api_const_pkg.PARAM_PIN_BLOCK
                            , prs_api_const_pkg.PARAM_PIN_OFFSET
                            , prs_api_const_pkg.PARAM_SERVICE_CODE
                            , prs_api_const_pkg.PARAM_TRACK1
                            , prs_api_const_pkg.PARAM_TRACK2
                            , prs_api_const_pkg.PARAM_TRACK1_BEGIN
                            , prs_api_const_pkg.PARAM_TRACK1_END
                            , prs_api_const_pkg.PARAM_TRACK1_SEPARATOR
                            , prs_api_const_pkg.PARAM_TRACK2_BEGIN
                            , prs_api_const_pkg.PARAM_TRACK2_END
                            , prs_api_const_pkg.PARAM_TRACK2_SEPARATOR
                            , prs_api_const_pkg.PARAM_ATC_PLACEHOLDER
                            , prs_api_const_pkg.PARAM_CVC3_PLACEHOLDER
                            , prs_api_const_pkg.PARAM_UN_PLACEHOLDER
                            , prs_api_const_pkg.PARAM_EMBOSSING_DATA
                            , prs_api_const_pkg.PARAM_TRACK1_DATA
                            , prs_api_const_pkg.PARAM_TRACK2_DATA
                            , prs_api_const_pkg.PARAM_CHIP_DATA
                            )
                then com_api_hash_pkg.get_param_mask(i_value)
             else i_value
        end;
end;

procedure assert_param_type (
    i_name              in com_api_type_pkg.t_name
    , i_type            in com_api_type_pkg.t_dict_value
) is
    l_name              com_api_type_pkg.t_name := upper(i_name);
begin
    if g_param_defs.exists(l_name) then
        if i_type = g_param_defs(l_name).data_type then
            null;
        else
            trc_log_pkg.debug (
                i_text              => 'Parameter [#1] of different type. Registered as [#2], referenced as [#3]'
                , i_env_param1      => l_name
                , i_env_param2      => g_param_defs(l_name).data_type
                , i_env_param3      => i_type
            );
        end if;
    else
        trc_log_pkg.debug (
            i_text              => 'Parameter [#1] not registered in system'
            , i_env_param1      => l_name
        );
    end if;
end;

function get_param (
    i_name              in com_api_type_pkg.t_name
    , io_params         in com_api_type_pkg.t_param_tab
    , i_mask_error      in com_api_type_pkg.t_boolean
    , i_error_value     in com_api_type_pkg.t_param_value
) return com_api_type_pkg.t_param_value is
    l_name              com_api_type_pkg.t_name := upper(i_name);
begin
    if l_name is null then
        raise no_data_found;
    end if;

    trc_log_pkg.debug(
        i_text          => 'Returning requested value of parameter [#1]=[#2]'
      , i_env_param1    => l_name
      , i_env_param2    => mask_value(i_name => l_name, i_value => io_params(l_name))
    );

    return io_params(l_name);
exception
    when no_data_found then
        if i_mask_error = com_api_type_pkg.TRUE then
            trc_log_pkg.debug(
                i_text          => 'Reference to undefined parameter [#1], returning default value [#2]'
              , i_env_param1    => l_name
              , i_env_param2    => mask_value(i_name => l_name, i_value => i_error_value)
            );

            return i_error_value;
        else
            com_api_error_pkg.raise_error(
                i_error         => 'REFERENCE_TO_UNDEFINED_PARAMETER'
              , i_env_param1    => l_name
            );
        end if;
end;

function get_param_num (
    i_name              in com_api_type_pkg.t_name
    , io_params         in com_api_type_pkg.t_param_tab
    , i_mask_error      in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    , i_error_value     in com_api_type_pkg.t_param_value := null
) return number
is
    l_value             com_api_type_pkg.t_name;
begin
    assert_param_type (
        i_name              => i_name
        , i_type            => com_api_const_pkg.DATA_TYPE_NUMBER
    );

    l_value := get_param(
                   i_name         => i_name
                 , io_params      => io_params
                 , i_mask_error   => i_mask_error
                 , i_error_value  => i_error_value
               );

    return to_number(l_value, com_api_const_pkg.NUMBER_FORMAT);
exception
    when value_error then
        begin
            return to_number(l_value);
        exception
            when value_error then
                com_api_error_pkg.raise_error(
                    i_error         => 'PARAMETER_CONVERSION_ERROR'
                  , i_env_param1    => i_name
                  , i_env_param2    => COM_API_CONST_PKG.DATA_TYPE_NUMBER
                  , i_env_param3    => l_value
                );
        end;
end;

function get_param_date (
    i_name              in com_api_type_pkg.t_name
    , io_params         in com_api_type_pkg.t_param_tab
    , i_mask_error      in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    , i_error_value     in com_api_type_pkg.t_param_value := null
) return date
is
    l_value             com_api_type_pkg.t_name;
begin
    assert_param_type (
        i_name              => i_name
        , i_type            => com_api_const_pkg.DATA_TYPE_DATE
    );

    l_value := get_param(
                   i_name         => i_name
                 , io_params      => io_params
                 , i_mask_error   => i_mask_error
                 , i_error_value  => i_error_value
               );

    return to_date(l_value, com_api_const_pkg.DATE_FORMAT);
exception
    when value_error then
        begin
            return to_date(l_value);
        exception
            when value_error then
                com_api_error_pkg.raise_error(
                    i_error         => 'PARAMETER_CONVERSION_ERROR'
                  , i_env_param1    => i_name
                  , i_env_param2    => COM_API_CONST_PKG.DATA_TYPE_DATE
                  , i_env_param3    => l_value
                );
        end;
end;

function get_param_char (
    i_name              in com_api_type_pkg.t_name
    , io_params         in com_api_type_pkg.t_param_tab
    , i_mask_error      in com_api_type_pkg.t_boolean
    , i_error_value     in com_api_type_pkg.t_param_value
) return com_api_type_pkg.t_param_value
is
    l_value             com_api_type_pkg.t_param_value;
begin
    assert_param_type (
        i_name              => i_name
        , i_type            => com_api_const_pkg.DATA_TYPE_CHAR
    );

    l_value := get_param(
                   i_name         => i_name
                 , io_params      => io_params
                 , i_mask_error   => i_mask_error
                 , i_error_value  => i_error_value
               );

    return l_value;
end;

procedure i_set_param (
    i_name              in com_api_type_pkg.t_name
    , i_value           in com_api_type_pkg.t_param_value
    , io_params         in out nocopy com_api_type_pkg.t_param_tab
) is
begin
    io_params(upper(i_name)) := i_value;

    trc_log_pkg.debug(
        i_text          => 'Parameter [#1] value set to [#2]'
      , i_env_param1    => i_name
      , i_env_param2    => mask_value(i_name => i_name, i_value => i_value)
    );
end;

procedure set_param (
    i_name              in com_api_type_pkg.t_name
    , i_value           in com_api_type_pkg.t_param_value
    , io_params         in out nocopy com_api_type_pkg.t_param_tab
) is
begin
    assert_param_type (
        i_name              => i_name
        , i_type            => com_api_const_pkg.DATA_TYPE_CHAR
    );

    i_set_param (
        i_name              => i_name
        , i_value           => i_value
        , io_params         => io_params
    );
end;

procedure set_param (
    i_name              in com_api_type_pkg.t_name
    , i_value           in number
    , io_params         in out nocopy com_api_type_pkg.t_param_tab
) is
begin
    assert_param_type (
        i_name              => i_name
        , i_type            => com_api_const_pkg.DATA_TYPE_NUMBER
    );

    i_set_param (
        i_name              => i_name
        , i_value           => to_char(i_value, COM_API_CONST_PKG.NUMBER_FORMAT)
        , io_params         => io_params
    );
end;

procedure set_param (
    i_name              in com_api_type_pkg.t_name
    , i_value           in date
    , io_params         in out nocopy com_api_type_pkg.t_param_tab
) is
begin
    assert_param_type (
        i_name              => i_name
        , i_type            => com_api_const_pkg.DATA_TYPE_DATE
    );

    i_set_param (
        i_name              => i_name
        , i_value           => to_char(i_value, COM_API_CONST_PKG.DATE_FORMAT)
        , io_params         => io_params
    );
end;

procedure set_amount (
    i_name              in com_api_type_pkg.t_name
    , i_amount          in com_api_type_pkg.t_money
    , i_currency        in com_api_type_pkg.t_curr_code
    , i_conversion_rate in com_api_type_pkg.t_rate          default null
    , i_rate_type       in com_api_type_pkg.t_dict_value    default null
    , io_amount_tab     in out com_api_type_pkg.t_amount_by_name_tab
) is
begin
    io_amount_tab(i_name).amount := i_amount;
    io_amount_tab(i_name).currency := i_currency;
    io_amount_tab(i_name).conversion_rate := i_conversion_rate;
    io_amount_tab(i_name).rate_type := i_rate_type;

    trc_log_pkg.debug(
        i_text          => 'Amount [#1] value set to [#2][#3]'
      , i_env_param1    => i_name
      , i_env_param2    => i_amount
      , i_env_param3    => i_currency
    );
end;

procedure get_amount (
    i_name                  in      com_api_type_pkg.t_name
  , o_amount                   out  com_api_type_pkg.t_money
  , o_currency                 out  com_api_type_pkg.t_curr_code
  , o_conversion_rate          out  com_api_type_pkg.t_rate
  , o_rate_type                out  com_api_type_pkg.t_dict_value
  , io_amount_tab           in      com_api_type_pkg.t_amount_by_name_tab
  , i_mask_error            in      com_api_type_pkg.t_boolean              := com_api_type_pkg.FALSE
  , i_error_amount          in      com_api_type_pkg.t_money                := null
  , i_error_currency        in      com_api_type_pkg.t_curr_code            := null
) is
    l_name                          com_api_type_pkg.t_name := upper(i_name);
begin
    if l_name is null then
        raise no_data_found;
    end if;

    trc_log_pkg.debug(
        i_text          => 'Returning requested value of amount [#1]=[#2][#3]'
      , i_env_param1    => l_name
      , i_env_param2    => io_amount_tab(l_name).amount
      , i_env_param3    => io_amount_tab(l_name).currency
    );

    o_amount            := io_amount_tab(l_name).amount;
    o_currency          := io_amount_tab(l_name).currency;
    o_conversion_rate   := io_amount_tab(l_name).conversion_rate;
    o_rate_type         := io_amount_tab(l_name).rate_type;
exception
    when no_data_found then
        if i_mask_error = com_api_type_pkg.TRUE then
            trc_log_pkg.debug(
                i_text          => 'Reference to undefined amount [#1], returning default value [#2][#3]'
              , i_env_param1    => l_name
              , i_env_param2    => i_error_amount
              , i_env_param3    => i_error_currency
            );

            o_amount := i_error_amount;
            o_currency := i_error_currency;
        else
            com_api_error_pkg.raise_error(
                i_error         => 'REFERENCE_TO_UNDEFINED_PARAMETER'
              , i_env_param1    => l_name
            );
        end if;
end;

procedure get_amount (
    i_name              in com_api_type_pkg.t_name
    , o_amount          out com_api_type_pkg.t_money
    , o_currency        out com_api_type_pkg.t_curr_code
    , io_amount_tab     in com_api_type_pkg.t_amount_by_name_tab
    , i_mask_error      in com_api_type_pkg.t_boolean
    , i_error_amount    in com_api_type_pkg.t_money
    , i_error_currency  in com_api_type_pkg.t_curr_code
) is
    l_conversion_rate       com_api_type_pkg.t_rate;
    l_rate_type             com_api_type_pkg.t_dict_value;
begin
    get_amount (
        i_name                  => i_name
        , o_amount              => o_amount
        , o_currency            => o_currency
        , o_conversion_rate     => l_conversion_rate
        , o_rate_type           => l_rate_type
        , io_amount_tab         => io_amount_tab
        , i_mask_error          => i_mask_error
        , i_error_amount        => i_error_amount
        , i_error_currency      => i_error_currency
    );
end;

procedure set_account (
    i_name              in     com_api_type_pkg.t_name
  , i_account_rec       in     acc_api_type_pkg.t_account_rec
  , io_account_tab      in out acc_api_type_pkg.t_account_by_name_tab
) is
    l_name              com_api_type_pkg.t_name := upper(i_name);
begin
    io_account_tab(l_name) := i_account_rec;

    trc_log_pkg.debug(
        i_text          => 'Account [#1] set to [#2]'
      , i_env_param1    => i_name
      , i_env_param2    => i_account_rec.account_id
    );
end;

procedure get_account (
    i_name              in     com_api_type_pkg.t_name
  , o_account_rec          out acc_api_type_pkg.t_account_rec
  , io_account_tab      in     acc_api_type_pkg.t_account_by_name_tab
  , i_mask_error        in     com_api_type_pkg.t_boolean             := com_api_type_pkg.FALSE
  , i_error_value       in     com_api_type_pkg.t_account_id          := null
) is
    l_name              com_api_type_pkg.t_name := upper(i_name);
begin
    if l_name is null then
        raise no_data_found;
    end if;

    trc_log_pkg.debug(
        i_text          => 'Returning requested account [#1]=[#2]'
      , i_env_param1    => l_name
      , i_env_param2    => io_account_tab(l_name).account_id
    );

    o_account_rec := io_account_tab(l_name);
exception
    when no_data_found then
        if i_mask_error = com_api_type_pkg.TRUE then
            trc_log_pkg.debug(
                i_text          => 'Reference to undefined account [#1], returning default value [#2]'
              , i_env_param1    => l_name
              , i_env_param2    => i_error_value
            );

            o_account_rec.account_id := i_error_value;
        else
            com_api_error_pkg.raise_error(
                i_error         => 'REFERENCE_TO_UNDEFINED_PARAMETER'
              , i_env_param1    => l_name
            );
        end if;
end;

procedure set_date (
    i_name              in com_api_type_pkg.t_name
    , i_date            in date
    , io_date_tab       in out com_api_type_pkg.t_date_by_name_tab
) is
    l_name              com_api_type_pkg.t_name := upper(i_name);
begin
    io_date_tab(l_name) := i_date;

    trc_log_pkg.debug(
        i_text          => 'Date [#1] set to [#2]'
      , i_env_param1    => i_name
      , i_env_param2    => to_char(i_date, 'dd.mm.yyyy hh24:mi:ss')
    );
end;

procedure get_date (
    i_name              in com_api_type_pkg.t_name
    , o_date            out date
    , io_date_tab       in com_api_type_pkg.t_date_by_name_tab
    , i_mask_error      in com_api_type_pkg.t_boolean
    , i_error_value     in date
) is
    l_name              com_api_type_pkg.t_name := upper(i_name);
begin
    if l_name is null then
        raise no_data_found;
    end if;

    trc_log_pkg.debug(
        i_text          => 'Returning requested date [#1]=[#2]'
      , i_env_param1    => l_name
      , i_env_param2    => to_char(io_date_tab(l_name), 'dd.mm.yyyy hh24:mi:ss')
    );

    o_date := io_date_tab(l_name);
exception
    when no_data_found then
        if i_mask_error = com_api_type_pkg.TRUE then
            trc_log_pkg.debug(
                i_text          => 'Reference to undefined date [#1], returning default value [#2]'
              , i_env_param1    => l_name
              , i_env_param2    => i_error_value
            );

            o_date := i_error_value;
        else
            com_api_error_pkg.raise_error(
                i_error         => 'REFERENCE_TO_UNDEFINED_PARAMETER'
              , i_env_param1    => l_name
            );
        end if;
end;

procedure set_currency (
    i_name              in com_api_type_pkg.t_name
    , i_currency        in com_api_type_pkg.t_curr_code
    , io_currency_tab   in out com_api_type_pkg.t_currency_by_name_tab
) is
    l_name              com_api_type_pkg.t_name := upper(i_name);
begin
    io_currency_tab(l_name) := i_currency;

    trc_log_pkg.debug(
        i_text          => 'Currency [#1] set to [#2]'
      , i_env_param1    => i_name
      , i_env_param2    => i_currency
    );
end;

procedure get_currency (
    i_name              in com_api_type_pkg.t_name
    , o_currency        out com_api_type_pkg.t_curr_code
    , io_currency_tab   in com_api_type_pkg.t_currency_by_name_tab
    , i_mask_error      in com_api_type_pkg.t_boolean
    , i_error_value     in com_api_type_pkg.t_curr_code
) is
    l_name              com_api_type_pkg.t_name := upper(i_name);
begin
    if l_name is null then
        raise no_data_found;
    end if;

    trc_log_pkg.debug(
        i_text          => 'Returning requested currency [#1]=[#2]'
      , i_env_param1    => l_name
      , i_env_param2    => io_currency_tab(l_name)
    );

    o_currency := io_currency_tab(l_name);
exception
    when no_data_found then
        if i_mask_error = com_api_type_pkg.TRUE then
            trc_log_pkg.debug(
                i_text          => 'Reference to undefined currency [#1], returning default value [#2]'
              , i_env_param1    => l_name
              , i_env_param2    => i_error_value
            );

            o_currency := i_error_value;
        else
            com_api_error_pkg.raise_error(
                i_error         => 'REFERENCE_TO_UNDEFINED_PARAMETER'
              , i_env_param1    => l_name
            );
        end if;
end;

procedure init_param_cache is

    cursor l_params_cur is
        select *
        from rul_mod_param;

    l_params_tab           t_param_def_tab;

begin
    g_param_defs.delete;

    open l_params_cur;
    fetch l_params_cur bulk collect into l_params_tab;
    close l_params_cur;

    for i in l_params_tab.first .. l_params_tab.last loop
        g_param_defs(l_params_tab(i).name) := l_params_tab(i);
    end loop;

    for rec in (select f.name
                     , f.data_type
                     , f.entity_type
                     , u.usage
                  from com_flexible_field       f
                     , com_flexible_field_usage u
                 where f.id     = u.field_id
                   and u.usage in (com_api_const_pkg.FLEXIBLE_FIELD_PROC_OPER, com_api_const_pkg.FLEXIBLE_FIELD_PROC_EVNT, com_api_const_pkg.FLEXIBLE_FIELD_PROC_ALL))
    loop
        g_param_defs(rec.name).name      := rec.name;
        g_param_defs(rec.name).data_type := rec.data_type;
        com_api_flexible_data_pkg.set_usage(rec.usage, rec.entity_type);
    end loop;

end init_param_cache;

begin
    init_param_cache;
end;
/
