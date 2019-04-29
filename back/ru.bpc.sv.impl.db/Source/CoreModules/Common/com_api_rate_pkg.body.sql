create or replace package body com_api_rate_pkg is
/*********************************************************
*  API for rates <br />
*  Created by Khougaev A.(khougaev@bpcbt.com)  at 04.12.2009 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: COM_API_RATE_PKG <br />
*  @headcom
**********************************************************/
function get_inst_rate_type (
    i_rate_type             in com_api_type_pkg.t_dict_value
    , i_inst_id             in com_api_type_pkg.t_inst_id
    , i_mask_exception      in com_api_type_pkg.t_boolean        default com_api_type_pkg.FALSE
) return com_rate_type%rowtype is
    l_result                com_rate_type%rowtype;
begin
    select
        t.*
    into
        l_result
    from
        com_rate_type t
    where
        t.inst_id = i_inst_id
        and t.rate_type = i_rate_type;

    return l_result;
exception
    when no_data_found then
        com_api_error_pkg.raise_error(
            i_error             => 'RATE_TYPE_NOT_FOUND'
            , i_env_param1      => i_rate_type
            , i_env_param2      => i_inst_id
            , i_mask_error      => i_mask_exception
        );
end;

function fetch_rate (
    i_src_currency          in com_api_type_pkg.t_curr_code
    , i_dst_currency        in com_api_type_pkg.t_curr_code
    , i_rate_type           in com_api_type_pkg.t_dict_value
    , i_inst_id             in com_api_type_pkg.t_inst_id
    , i_eff_date            in date
    , i_check_exp_date      in com_api_type_pkg.t_boolean        default com_api_type_pkg.TRUE
) return number is
    l_result                number;
begin
    if i_check_exp_date = com_api_type_pkg.TRUE then
        select
            eff_rate
        into
            l_result
        from (
            select
                eff_rate
            from
                com_rate
            where
                src_currency = i_src_currency
                and dst_currency = i_dst_currency
                and rate_type = i_rate_type
                and inst_id = i_inst_id
                and eff_date <= i_eff_date
                and nvl(exp_date, i_eff_date) >= i_eff_date
                and status = RATE_STATUS_VALID
            order by
                eff_date desc
                , reg_date desc
        )
        where rownum = 1;
    else
        select
            eff_rate
        into
            l_result
        from (
            select
                eff_rate
            from
                com_rate
            where
                src_currency = i_src_currency
                and dst_currency = i_dst_currency
                and rate_type = i_rate_type
                and inst_id = i_inst_id
                and eff_date <= i_eff_date
                and status = RATE_STATUS_VALID
            order by
                eff_date desc
                , reg_date desc
        )
        where rownum = 1;
    end if;

    trc_log_pkg.debug (
        i_text          => 'Fetched rate [#1] from [#2] to [#3] of type [#4] for [#5] on [#6]'
        , i_env_param1  => l_result
        , i_env_param2  => i_src_currency
        , i_env_param3  => i_dst_currency
        , i_env_param4  => i_inst_id
        , i_env_param5  => i_rate_type
        , i_env_param6  => i_eff_date
    );

    return l_result;
exception
    when no_data_found then
        trc_log_pkg.debug(
            i_text              => 'CURRENCY_RATE_NOT_FOUND'
            , i_env_param1      => i_src_currency
            , i_env_param2      => i_dst_currency
            , i_env_param3      => i_rate_type
            , i_env_param4      => i_inst_id
            , i_env_param5      => i_eff_date
        );
        raise;
end;

function fetch_rate (
    i_src_currency          in com_api_type_pkg.t_curr_code
    , i_base_currency       in com_api_type_pkg.t_curr_code
    , i_dst_currency        in com_api_type_pkg.t_curr_code
    , i_rate_type           in com_api_type_pkg.t_dict_value
    , i_inst_id             in com_api_type_pkg.t_inst_id
    , i_eff_date            in date
) return number is
begin
    return (
        fetch_rate (
            i_src_currency          => i_src_currency
            , i_dst_currency        => i_base_currency
            , i_rate_type           => i_rate_type
            , i_inst_id             => i_inst_id
            , i_eff_date            => i_eff_date
        ) *
        fetch_rate (
            i_src_currency          => i_base_currency
            , i_dst_currency        => i_dst_currency
            , i_rate_type           => i_rate_type
            , i_inst_id             => i_inst_id
            , i_eff_date            => i_eff_date
        )
    );
end;

function get_rate (
    i_src_currency              in com_api_type_pkg.t_curr_code
    , i_dst_currency            in com_api_type_pkg.t_curr_code
    , i_rate_type               in com_api_type_pkg.t_dict_value
    , i_inst_id                 in com_api_type_pkg.t_inst_id
    , i_eff_date                in date
    , i_use_cross_rate          in com_api_type_pkg.t_boolean
    , i_use_base_rate           in com_api_type_pkg.t_boolean
    , i_base_currency           in com_api_type_pkg.t_curr_code
    , i_conversion_type         in com_api_type_pkg.t_dict_value
    , i_mask_exception          in com_api_type_pkg.t_boolean    default com_api_type_pkg.FALSE
) return number is
    l_result                    number;
    l_src_currency              com_api_type_pkg.t_curr_code;
    l_dst_currency              com_api_type_pkg.t_curr_code;
begin
    l_result := null;

    if i_src_currency = i_dst_currency then
        return 1;
    else
        if i_conversion_type = com_api_const_pkg.CONVERSION_TYPE_SELLING then
            l_src_currency := i_dst_currency;
            l_dst_currency := i_src_currency;
        else
            l_src_currency := i_src_currency;
            l_dst_currency := i_dst_currency;
        end if;
         
        trc_log_pkg.debug (
            i_text          => 'Rate will be searched for src=[#1] dst=[#2] because of conversion [#3]'
            , i_env_param1  => l_src_currency
            , i_env_param2  => l_dst_currency
            , i_env_param3  => i_conversion_type
        );

        if (
            i_use_cross_rate = com_api_type_pkg.TRUE
            or (
                i_use_base_rate = com_api_type_pkg.TRUE
                and i_base_currency in (l_src_currency, l_dst_currency)
            )
        ) then
            begin
                trc_log_pkg.debug (
                    i_text          => 'Going to find direct rate for src=[#1] dst=[#2]'
                    , i_env_param1  => l_src_currency
                    , i_env_param2  => l_dst_currency
                );

                l_result := fetch_rate (
                    i_src_currency          => l_src_currency
                    , i_dst_currency        => l_dst_currency
                    , i_rate_type           => i_rate_type
                    , i_inst_id             => i_inst_id
                    , i_eff_date            => i_eff_date
                );

                if i_conversion_type = com_api_const_pkg.CONVERSION_TYPE_SELLING then
                    l_result := 1/l_result;
                end if;
                
                trc_log_pkg.debug (
                    i_text          => 'Effective rate is [#1]'
                    , i_env_param1  => l_result
                );

                return l_result;
            exception
                when no_data_found then
                    null;
            end;
        end if;

        if (
            i_use_base_rate = com_api_type_pkg.TRUE
            and i_base_currency not in (l_src_currency, l_dst_currency)
        ) then
            begin
                trc_log_pkg.debug (
                    i_text          => 'Going to find rate for src=[#1] dst=[#2] via base currency [#3]'
                    , i_env_param1  => l_src_currency
                    , i_env_param2  => l_dst_currency
                    , i_env_param3  => i_base_currency
                );

                l_result := fetch_rate (
                    i_src_currency          => l_src_currency
                    , i_dst_currency        => l_dst_currency
                    , i_base_currency       => i_base_currency
                    , i_rate_type           => i_rate_type
                    , i_inst_id             => i_inst_id
                    , i_eff_date            => i_eff_date
                );

                if i_conversion_type = com_api_const_pkg.CONVERSION_TYPE_SELLING then
                    l_result := 1/l_result;
                end if;

                trc_log_pkg.debug (
                    i_text          => 'Effective rate is [#1]'
                    , i_env_param1  => l_result
                );

                return l_result;
            exception
                when no_data_found then
                    null;
            end;
        end if;

        com_api_error_pkg.raise_error(
            i_error             => 'CURRENCY_RATE_NOT_FOUND'
            , i_env_param1      => case when i_conversion_type = com_api_const_pkg.CONVERSION_TYPE_SELLING then l_dst_currency else l_src_currency end
            , i_env_param2      => case when i_conversion_type = com_api_const_pkg.CONVERSION_TYPE_SELLING then l_src_currency else l_dst_currency end
            , i_env_param3      => i_rate_type
            , i_env_param4      => i_inst_id
            , i_env_param5      => i_eff_date
            , i_mask_error      => i_mask_exception
        );
    end if;
exception
    when others then
        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        else
            com_api_error_pkg.raise_error(
                i_error           => 'UNHANDLED_EXCEPTION'
              , i_env_param1      => l_src_currency
              , i_env_param2      => l_dst_currency
              , i_env_param3      => i_rate_type
              , i_env_param4      => i_inst_id
              , i_env_param5      => i_eff_date
              , i_env_param6      => sqlerrm
              , i_mask_error      => i_mask_exception
            );
        end if;
end;

function get_rate (
    i_src_currency              in com_api_type_pkg.t_curr_code
    , i_dst_currency            in com_api_type_pkg.t_curr_code
    , i_rate_type               in com_api_type_pkg.t_dict_value
    , i_inst_id                 in com_api_type_pkg.t_inst_id
    , i_eff_date                in date
    , i_conversion_type         in com_api_type_pkg.t_dict_value default com_api_const_pkg.CONVERSION_TYPE_SELLING
    , i_mask_exception          in com_api_type_pkg.t_boolean
    , i_exception_value         in number
) return number is
    l_rate_attrs                com_rate_type%rowtype;
begin
    if i_src_currency = i_dst_currency then
        return 1;
    else
        l_rate_attrs := get_inst_rate_type (
            i_inst_id       => i_inst_id
            , i_rate_type   => i_rate_type
            , i_mask_exception  => i_mask_exception
        );

        return get_rate (
                   i_src_currency            => i_src_currency
                 , i_dst_currency            => i_dst_currency
                 , i_rate_type               => i_rate_type
                 , i_inst_id                 => i_inst_id
                 , i_eff_date                => i_eff_date
                 , i_use_cross_rate          => l_rate_attrs.use_cross_rate
                 , i_use_base_rate           => l_rate_attrs.use_base_rate
                 , i_base_currency           => l_rate_attrs.base_currency
                 , i_conversion_type         => i_conversion_type
                 , i_mask_exception          => i_mask_exception
               );
    end if;
exception
    when others then
        if i_mask_exception = com_api_type_pkg.TRUE then
            trc_log_pkg.warn(
                i_text              => 'RATE_ERROR_MASKED'
                , i_env_param1      => i_src_currency
                , i_env_param2      => i_dst_currency
                , i_env_param3      => i_rate_type
                , i_env_param4      => i_inst_id
                , i_env_param5      => i_eff_date
                , i_env_param6      => sqlerrm
            );

            return i_exception_value;
        else
            raise;
        end if;
end;

function convert_amount (
    i_src_amount            in number
    , i_src_currency        in com_api_type_pkg.t_curr_code
    , i_dst_currency        in com_api_type_pkg.t_curr_code
    , i_rate_type           in com_api_type_pkg.t_dict_value
    , i_inst_id             in com_api_type_pkg.t_inst_id
    , i_eff_date            in date
    , i_mask_exception      in com_api_type_pkg.t_boolean
    , i_exception_value     in number
    , i_conversion_type     in com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_money is
    l_conversion_rate       com_api_type_pkg.t_rate;
begin
    return 
    com_api_rate_pkg.convert_amount (
        i_src_amount            => i_src_amount
        , i_src_currency        => i_src_currency
        , i_dst_currency        => i_dst_currency
        , i_rate_type           => i_rate_type
        , i_inst_id             => i_inst_id
        , i_eff_date            => i_eff_date
        , i_mask_exception      => i_mask_exception
        , i_exception_value     => i_exception_value
        , i_conversion_type     => i_conversion_type
        , o_conversion_rate     => l_conversion_rate
    );
end;

function convert_amount (
    i_src_amount            in number
    , i_src_currency        in com_api_type_pkg.t_curr_code
    , i_dst_currency        in com_api_type_pkg.t_curr_code
    , i_rate_type           in com_api_type_pkg.t_dict_value
    , i_inst_id             in com_api_type_pkg.t_inst_id
    , i_eff_date            in date
    , i_mask_exception      in com_api_type_pkg.t_boolean
    , i_exception_value     in number
    , i_conversion_type     in com_api_type_pkg.t_dict_value
    , o_conversion_rate     out com_api_type_pkg.t_rate
) return com_api_type_pkg.t_money is
    l_rate_attrs            com_rate_type%rowtype;
    l_result                com_api_type_pkg.t_money;
begin
    trc_log_pkg.debug(
        i_text              => 'Going to convert [#1]->[#2] as [#3] for [#4] on [#5]. Type is [#6]'
        , i_env_param1      => i_src_currency
        , i_env_param2      => i_dst_currency
        , i_env_param3      => i_rate_type
        , i_env_param4      => i_inst_id
        , i_env_param5      => i_eff_date
        , i_env_param6      => i_conversion_type
    );

    if i_src_amount = 0 then
        l_result := 0;
    elsif i_src_currency = i_dst_currency then
        l_result := i_src_amount;
    else
        l_rate_attrs := get_inst_rate_type (
            i_inst_id       => i_inst_id
            , i_rate_type   => i_rate_type
            , i_mask_exception  => i_mask_exception
        );

        o_conversion_rate := 
            get_rate (
                i_src_currency          => i_src_currency
                , i_dst_currency        => i_dst_currency
                , i_rate_type           => i_rate_type
                , i_inst_id             => i_inst_id
                , i_eff_date            => i_eff_date
                , i_use_cross_rate      => l_rate_attrs.use_cross_rate
                , i_use_base_rate       => l_rate_attrs.use_base_rate
                , i_base_currency       => l_rate_attrs.base_currency
                , i_conversion_type     => i_conversion_type
                , i_mask_exception      => i_mask_exception
            );

        if l_rate_attrs.rounding_accuracy is not null then
            l_result := round (i_src_amount * o_conversion_rate, l_rate_attrs.rounding_accuracy);
        else
            l_result := i_src_amount * o_conversion_rate;
        end if;
    end if;
    
    trc_log_pkg.debug(
        i_text              => 'Converted [#1][#2] -> [#3][#4]'
        , i_env_param1      => i_src_amount
        , i_env_param2      => i_src_currency
        , i_env_param3      => l_result
        , i_env_param4      => i_dst_currency
    );

    return l_result;
exception
    when others then
        if i_mask_exception = com_api_type_pkg.TRUE then
            trc_log_pkg.debug(
                i_text              => 'Masked conversion error [#1][#2][#3][#4][#5][#6]'
                , i_env_param1      => i_src_currency
                , i_env_param2      => i_dst_currency
                , i_env_param3      => i_rate_type
                , i_env_param4      => i_inst_id
                , i_env_param5      => i_eff_date
                , i_env_param6      => sqlerrm
            );

            return i_exception_value;

        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;

        else
            com_api_error_pkg.raise_fatal_error(
                i_error             => 'UNHANDLED_EXCEPTION'
                , i_env_param1      => i_src_currency
                , i_env_param2      => i_dst_currency
                , i_env_param3      => i_rate_type
                , i_env_param4      => i_inst_id
                , i_env_param5      => i_eff_date
                , i_env_param6      => SQLERRM
            );
        end if;
end;

function check_rate (
    i_src_currency          in com_api_type_pkg.t_curr_code
    , i_dst_currency        in com_api_type_pkg.t_curr_code
    , i_rate_type           in com_api_type_pkg.t_dict_value
    , i_inst_id             in com_api_type_pkg.t_inst_id
    , i_eff_date            in date
    , i_rate                in number
    , i_inverted            in com_api_type_pkg.t_boolean
    , i_src_scale           in number
    , i_dst_scale           in number
    , o_message             out com_api_type_pkg.t_text
) return com_api_type_pkg.t_boolean is
    l_rate_attrs            com_rate_type%rowtype;
    l_prev_rate             number;
    l_eff_rate              number;
    l_src_exponent_scale    number;
    l_dst_exponent_scale    number;
begin
    if i_src_currency = i_dst_currency then
        null;
    else
        l_rate_attrs := get_inst_rate_type (
            i_inst_id       => i_inst_id
            , i_rate_type   => i_rate_type
        );

        if l_rate_attrs.warning_level is not null then
            begin
                l_prev_rate := fetch_rate (
                    i_src_currency      => i_src_currency
                    , i_dst_currency    => i_dst_currency
                    , i_rate_type       => i_rate_type
                    , i_inst_id         => i_inst_id
                    , i_eff_date        => i_eff_date
                    , i_check_exp_date  => com_api_type_pkg.FALSE
                );

                if l_rate_attrs.adjust_exponent = com_api_type_pkg.TRUE then
                    l_src_exponent_scale := power(10, com_api_currency_pkg.get_currency_exponent(i_src_currency));
                    l_dst_exponent_scale := power(10, com_api_currency_pkg.get_currency_exponent(i_dst_currency));
                else
                    l_src_exponent_scale := 1;
                    l_dst_exponent_scale := 1;
                end if;

                case
                    when i_inverted = com_api_type_pkg.FALSE then l_eff_rate := i_rate * i_dst_scale * l_dst_exponent_scale / i_src_scale / l_src_exponent_scale;
                    when i_inverted = com_api_type_pkg.TRUE then l_eff_rate := i_dst_scale * l_dst_exponent_scale / i_rate / i_src_scale / l_src_exponent_scale;
                end case;

                if abs(1-l_eff_rate/l_prev_rate) * 100 >= l_rate_attrs.warning_level then
                    trc_log_pkg.warn (
                        i_text              => 'RATE_VALUE_EXCEEDS_THRESHOLD'
                        , i_env_param1      => i_inst_id 
                        , i_env_param2      => i_rate_type
                        , i_env_param3      => i_src_currency || '->' || i_dst_currency
                        , i_env_param4      => i_eff_date
                        , i_env_param5      => l_eff_rate
                        , i_env_param6      => l_prev_rate
                        , o_text            => o_message
                    );

                    return com_api_type_pkg.FALSE;
                end if;
            exception
                when no_data_found then
                    return com_api_type_pkg.TRUE;
            end;
        end if;
    end if;

    return com_api_type_pkg.TRUE;
end;

procedure insert_rate (
    o_id                    out com_api_type_pkg.t_short_id
    , o_seqnum              out com_api_type_pkg.t_tiny_id
    , i_src_currency        in com_api_type_pkg.t_curr_code
    , i_dst_currency        in com_api_type_pkg.t_curr_code
    , i_rate_type           in com_api_type_pkg.t_dict_value
    , i_inst_id             in com_api_type_pkg.t_inst_id
    , i_eff_date            in date
    , i_rate                in number
    , i_inverted            in com_api_type_pkg.t_boolean
    , i_src_scale           in number
    , i_dst_scale           in number
    , i_exp_date            in date
    , i_status              com_api_type_pkg.t_dict_value
    , i_initiate_rate_id    in com_api_type_pkg.t_short_id       default null
) is
    l_rate_attrs            com_rate_type%rowtype;
    l_src_exponent_scale    number;
    l_dst_exponent_scale    number;
begin
    l_rate_attrs := get_inst_rate_type (
        i_inst_id       => i_inst_id
        , i_rate_type   => i_rate_type
    );

    if l_rate_attrs.adjust_exponent = com_api_type_pkg.TRUE then
        l_src_exponent_scale := power(10, com_api_currency_pkg.get_currency_exponent(i_src_currency));
        l_dst_exponent_scale := power(10, com_api_currency_pkg.get_currency_exponent(i_dst_currency));
    else
        l_src_exponent_scale := 1;
        l_dst_exponent_scale := 1;
    end if;

    o_id := com_rate_seq.nextval;
    o_seqnum := 1;
        
    if i_src_currency != i_dst_currency and (i_rate is null or nvl(i_rate,0) <=0 ) then
        com_api_error_pkg.raise_error(
            i_error       => 'CURRENCY_RATE_NOT_FOUND'
          , i_env_param1  => i_src_currency
          , i_env_param2  => i_dst_currency
          , i_env_param3  => i_rate_type
          , i_env_param4  => i_inst_id
          , i_env_param5  => i_eff_date
        );
    end if;

    insert into com_rate_vw (
        id
        , seqnum
        , inst_id
        , eff_date
        , reg_date
        , rate_type
        , src_scale
        , src_currency
        , src_exponent_scale
        , dst_scale
        , dst_currency
        , dst_exponent_scale
        , status
        , exp_date
        , inverted
        , rate
        , eff_rate
        , initiate_rate_id
    ) values (
        o_id
        , o_seqnum
        , i_inst_id
        , i_eff_date
        , systimestamp
        , i_rate_type
        , i_src_scale
        , i_src_currency
        , l_src_exponent_scale
        , i_dst_scale
        , i_dst_currency
        , l_dst_exponent_scale
        , i_status
        , nvl(i_exp_date, i_eff_date + l_rate_attrs.exp_period)
        , nvl(i_inverted, com_api_type_pkg.FALSE)
        , i_rate
        , case
              when i_inverted = com_api_type_pkg.TRUE then i_dst_scale * l_dst_exponent_scale / i_rate / i_src_scale / l_src_exponent_scale
              else i_rate * i_dst_scale * l_dst_exponent_scale / i_src_scale / l_src_exponent_scale
          end
        , nvl(i_initiate_rate_id, o_id)
    );
    
    evt_api_event_pkg.register_event(
        i_event_type        => com_api_const_pkg.EVENT_TYPE_CURRENCY_RATE
      , i_eff_date          => get_sysdate
      , i_entity_type       => com_api_const_pkg.ENTITY_TYPE_CURRENCY_RATE
      , i_object_id         => o_id
      , i_inst_id           => i_inst_id
      , i_split_hash        => null
    );
end;

procedure populate_dependent_rate (
    i_src_currency          in com_api_type_pkg.t_curr_code
    , i_dst_currency        in com_api_type_pkg.t_curr_code
    , i_rate_type           in com_api_type_pkg.t_dict_value
    , i_inst_id             in com_api_type_pkg.t_inst_id
    , i_eff_date            in date
    , i_rate                in number
    , i_inverted            in com_api_type_pkg.t_boolean
    , i_src_scale           in number
    , i_dst_scale           in number
    , i_exp_date            in date
    , i_initiate_rate_id    in com_api_type_pkg.t_short_id
) is

    cursor dependent_rate_cur is
        select
            *
        from
            com_rate_pair
        where
            inst_id = i_inst_id
            and base_rate_type = i_rate_type
            and src_currency = i_src_currency
            and dst_currency = i_dst_currency;

    l_status                com_api_type_pkg.t_dict_value := RATE_STATUS_VALID;
    l_rate                  number;
    l_stmt                  com_api_type_pkg.t_text;
    l_id                    com_api_type_pkg.t_short_id;
    l_seqnum                com_api_type_pkg.t_tiny_id;

begin
    for rate in dependent_rate_cur loop

        begin
            l_stmt := 'select ' || replace(rate.base_rate_formula, ':' || nvl(rate.base_rate_mnemonic, rate.base_rate_type), to_char(i_rate, 'FM9999999999999999990.9999999999999999999999')) || ' from dual';

            execute immediate
                l_stmt
            into
                l_rate;
        exception
            when others then
                com_api_error_pkg.raise_error(
                    i_error             => 'ERROR_EXECUTION_RATE_STATEMENT'
                    , i_env_param1      => rate.rate_type
                    , i_env_param2      => i_rate_type
                    , i_env_param3      => i_inst_id
                    , i_env_param4      => i_src_currency || '->' || i_dst_currency
                    , i_env_param5      => l_stmt
                    , i_env_param6      => sqlerrm
                );
        end;

        insert_rate (
            o_id                    => l_id
            , o_seqnum              => l_seqnum
            , i_src_currency        => i_src_currency
            , i_dst_currency        => i_dst_currency
            , i_rate_type           => rate.rate_type
            , i_inst_id             => i_inst_id
            , i_eff_date            => i_eff_date
            , i_rate                => l_rate
            , i_inverted            => i_inverted
            , i_src_scale           => i_src_scale
            , i_dst_scale           => i_dst_scale
            , i_exp_date            => i_exp_date
            , i_status              => l_status
            , i_initiate_rate_id    => i_initiate_rate_id
        );
    end loop;
end;

procedure set_rate (
    o_id                    out com_api_type_pkg.t_short_id
    , o_seqnum              out com_api_type_pkg.t_tiny_id
    , o_count               out number
    , i_src_currency        in com_api_type_pkg.t_curr_code
    , i_dst_currency        in com_api_type_pkg.t_curr_code
    , i_rate_type           in com_api_type_pkg.t_dict_value
    , i_inst_id             in com_api_type_pkg.t_inst_id
    , i_eff_date            in date
    , i_rate                in number
    , i_inverted            in com_api_type_pkg.t_boolean
    , i_src_scale           in number
    , i_dst_scale           in number
    , i_exp_date            in date
) is
    l_rate_attrs            com_rate_type%rowtype;
    l_status                com_api_type_pkg.t_dict_value := RATE_STATUS_VALID;
    l_id                    com_api_type_pkg.t_short_id;
    l_seqnum                com_api_type_pkg.t_tiny_id;
begin
    if i_src_currency = i_dst_currency then
        com_api_error_pkg.raise_error(
            i_error      => 'RATE_SRC_EQ_DST'
          , i_env_param1 => i_src_currency
        );
    end if;

    l_rate_attrs := get_inst_rate_type (
        i_inst_id       => i_inst_id
        , i_rate_type   => i_rate_type
    );

    insert_rate (
        o_id                    => o_id
        , o_seqnum              => o_seqnum
        , i_src_currency        => i_src_currency
        , i_dst_currency        => i_dst_currency
        , i_rate_type           => i_rate_type
        , i_inst_id             => i_inst_id
        , i_eff_date            => i_eff_date
        , i_rate                => i_rate
        , i_inverted            => i_inverted
        , i_src_scale           => i_src_scale
        , i_dst_scale           => i_dst_scale
        , i_exp_date            => i_exp_date
        , i_status              => l_status
    );

    populate_dependent_rate (
        i_src_currency          => i_src_currency
        , i_dst_currency        => i_dst_currency
        , i_rate_type           => i_rate_type
        , i_inst_id             => i_inst_id
        , i_eff_date            => i_eff_date
        , i_rate                => i_rate
        , i_inverted            => i_inverted
        , i_src_scale           => i_src_scale
        , i_dst_scale           => i_dst_scale
        , i_exp_date            => i_exp_date
        , i_initiate_rate_id    => o_id
    );

    if l_rate_attrs.is_reversible = com_api_type_pkg.TRUE then
        insert_rate (
            o_id                    => l_id
            , o_seqnum              => l_seqnum
            , i_src_currency        => i_dst_currency
            , i_dst_currency        => i_src_currency
            , i_rate_type           => i_rate_type
            , i_inst_id             => i_inst_id
            , i_eff_date            => i_eff_date
            , i_rate                => i_rate
            , i_inverted            => com_api_type_pkg.boolean_not(i_inverted)
            , i_src_scale           => i_dst_scale
            , i_dst_scale           => i_src_scale
            , i_exp_date            => i_exp_date
            , i_status              => l_status
            , i_initiate_rate_id    => o_id
        );

        populate_dependent_rate (
            i_src_currency          => i_dst_currency
            , i_dst_currency        => i_src_currency
            , i_rate_type           => i_rate_type
            , i_inst_id             => i_inst_id
            , i_eff_date            => i_eff_date
            , i_rate                => i_rate
            , i_inverted            => com_api_type_pkg.boolean_not(i_inverted)
            , i_src_scale           => i_dst_scale
            , i_dst_scale           => i_src_scale
            , i_exp_date            => i_exp_date
            , i_initiate_rate_id    => o_id
        );
    end if;
    
    select 
        count(*)
    into
        o_count
    from
        com_rate
    where
        initiate_rate_id = o_id;
end;

end;
/
