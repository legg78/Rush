create or replace package body cmn_api_standard_pkg as

function get_current_version(
    i_standard_id       in      com_api_type_pkg.t_tiny_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_eff_date          in      date
) return com_api_type_pkg.t_tiny_id
result_cache relies_on (cmn_standard, cmn_standard_version, cmn_standard_version_obj, net_device)
is
    l_version_id        com_api_type_pkg.t_tiny_id;
begin
    if i_entity_type = hsm_api_const_pkg.ENTITY_TYPE_HSM then
        select version_id
          into l_version_id
          from (
            select version_id
              from net_device d,
                   cmn_standard_version_obj ov,
                   cmn_standard_version v,
                   cmn_standard s
             where d.host_member_id(+) = ov.object_id
               and ov.entity_type = hsm_api_const_pkg.ENTITY_TYPE_HSM
               and ov.start_date <= i_eff_date
               and ov.version_id = v.id
               and v.standard_id = s.id
               and s.id          = i_standard_id
             order by start_date desc
          )
          where rownum = 1;
    else
        select version_id
          into l_version_id
          from (
                select d.device_id,
                       ov.object_id host_member_id,
                       version_id
                  from net_device d,
                       cmn_standard_version_obj ov,
                       cmn_standard_version v,
                       cmn_standard s
                 where d.host_member_id(+) = ov.object_id
                   and ov.entity_type = net_api_const_pkg.ENTITY_TYPE_HOST
                   and ov.start_date <= i_eff_date
                   and ov.version_id = v.id
                   and v.standard_id = s.id
                   and s.id          = i_standard_id
                 order by start_date desc
               )
         where rownum = 1
           and i_object_id = decode(i_entity_type, cmn_api_const_pkg.ENTITY_TYPE_CMN_DEVICE, device_id, host_member_id);
    end if;

    trc_log_pkg.debug(
        i_text        => 'cmn_api_standard_pkg.get_current_version(4): i_standard_id [#1], i_entity_type [#2], i_object_id [#3], i_eff_date [#4], version_id [#5]'
      , i_env_param1  => i_standard_id
      , i_env_param2  => i_entity_type
      , i_env_param3  => i_object_id
      , i_env_param4  => to_char(i_eff_date, com_api_const_pkg.DATE_FORMAT)
      , i_env_param5  => l_version_id
    );
    return l_version_id;
exception
    when no_data_found then
        com_api_error_pkg.raise_error(
            i_error         => 'STANDARD_VERSION_NOT_FOUND_FOR_OBJECT'
          , i_env_param1    => i_standard_id
          , i_env_param2    => i_entity_type
          , i_env_param3    => i_object_id
          , i_env_param4    => i_eff_date
        );
end;

function get_current_version(
    i_network_id   in      com_api_type_pkg.t_tiny_id default null
) return com_api_type_pkg.t_tiny_id
result_cache relies_on (cmn_standard, cmn_standard_version, cmn_standard_version_obj, net_device)
is
    l_standard_id        com_api_type_pkg.t_tiny_id;
    l_host_id            com_api_type_pkg.t_tiny_id;
    l_current_version    com_api_type_pkg.t_tiny_id;
    l_network_id         com_api_type_pkg.t_tiny_id;
begin
    l_network_id := coalesce(
                        i_network_id
                      , dsp_api_shared_data_pkg.get_param_num(
                            i_name  => 'NETWORK_ID'
                        )
                    );

    l_host_id     := net_api_network_pkg.get_default_host(i_network_id => l_network_id);

    l_standard_id := net_api_network_pkg.get_offline_standard(
                         i_host_id => l_host_id
                     );

    l_current_version := cmn_api_standard_pkg.get_current_version(
                             i_standard_id  => l_standard_id
                           , i_entity_type  => net_api_const_pkg.ENTITY_TYPE_HOST
                           , i_object_id    => l_host_id
                           , i_eff_date     => com_api_sttl_day_pkg.get_sysdate()
                         );
    trc_log_pkg.debug(
        i_text        => 'cmn_api_standard_pkg.get_current_version(1): i_network_id [#1], l_network_id [#2], l_host_id [#3], l_standard_id [#4], l_current_version [#5]'
      , i_env_param1  => i_network_id
      , i_env_param2  => l_network_id
      , i_env_param3  => l_host_id
      , i_env_param4  => l_standard_id
      , i_env_param5  => l_current_version
    );
    return l_current_version;
end;

procedure get_param_value(
    i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_standard_id       in      com_api_type_pkg.t_tiny_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_param_name        in      com_api_type_pkg.t_name
  , i_data_type         in      com_api_type_pkg.t_oracle_name
  , i_eff_date          in      date                            default null
  , io_param_value_v    in out  com_api_type_pkg.t_name
  , io_param_value_d    in out  date
  , io_param_value_n    in out  number
  , i_param_tab         in      com_api_type_pkg.t_param_tab
) is
    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_param_value';
    l_param_id                  com_api_type_pkg.t_short_id;
    l_data_type                 com_api_type_pkg.t_oracle_name;
    l_eff_date                  date;
    l_version_id                com_api_type_pkg.t_tiny_id;
    l_entity_type               com_api_type_pkg.t_dict_value;
    l_object_id                 com_api_type_pkg.t_long_id;
    l_value                     com_api_type_pkg.t_short_desc;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' << i_inst_id [#1], i_standard_id [#2]'
                                   || ', i_entity_type [#3], i_object_id [#4], i_param_name [#5]'
      , i_env_param1 => i_inst_id
      , i_env_param2 => i_standard_id
      , i_env_param3 => i_entity_type
      , i_env_param4 => i_object_id
      , i_env_param5 => i_param_name
    );

    l_eff_date := coalesce(i_eff_date, get_sysdate);

    begin
        select id
             , data_type
          into l_param_id
             , l_data_type
          from cmn_parameter
         where name        = upper(i_param_name)
           and standard_id = i_standard_id;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error         => 'STANDARD_PARAM_NOT_EXISTS'
              , i_env_param1    => upper(i_param_name)
              , i_env_param2    => i_standard_id
            );
    end;

    if l_data_type != i_data_type then
        com_api_error_pkg.raise_error('INCORRECT_PARAM_VALUE_DATA_TYPE', i_data_type, l_data_type);
    end if;

    l_version_id :=
        get_current_version(
            i_standard_id       => i_standard_id
          , i_entity_type       => i_entity_type
          , i_object_id         => i_object_id
          , i_eff_date          => l_eff_date
        );

    if i_entity_type = net_api_const_pkg.ENTITY_TYPE_HOST then
        l_entity_type := net_api_const_pkg.ENTITY_TYPE_INTERFACE;
        begin
            select i.id
              into l_object_id
              from net_interface i
                 , net_member m
             where m.inst_id = i_inst_id
               and m.id      = i.consumer_member_id
               and i.host_member_id = i_object_id;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error         => 'INTERFACE_NOT_FOUND_FOR_OBJECT'
                  , i_env_param1    => i_entity_type
                  , i_env_param2    => i_object_id
                  , i_env_param3    => i_inst_id
                );
        end;
    else
        l_entity_type := i_entity_type;
        l_object_id   := i_object_id;
    end if;

    for r in (
        select coalesce(p2.param_value, p1.param_value, p.default_value) param_value
             , nvl(p2.mod_id, p1.mod_id) mod_id
          from cmn_parameter_value p1
             , cmn_parameter_value p2
             , cmn_parameter p
             , rul_mod m
         where p.id  = l_param_id
           and p1.param_id(+)  = p.id
           and p1.object_id(+) = l_object_id
           and p1.version_id(+) is null
           and p1.entity_type(+) = l_entity_type
           and p2.param_id(+)  = p.id
           and p2.object_id(+) = case when l_entity_type = CMN_API_CONST_PKG.ENTITY_TYPE_CMN_STANDARD_VERS then l_version_id else l_object_id end
           and p2.version_id(+) = l_version_id
           and p2.entity_type(+) = l_entity_type
           and p2.mod_id            = m.id(+)
         order by nvl2(p2.version_id, 0, 1), nvl2(p2.mod_id, 0, 1), m.priority
    ) loop
        if rul_api_mod_pkg.check_condition(
               i_mod_id        => r.mod_id
             , i_params        => i_param_tab
           ) = com_api_const_pkg.TRUE
        then
            if l_data_type = com_api_const_pkg.DATA_TYPE_CHAR then
                io_param_value_v := r.param_value;
            elsif l_data_type = com_api_const_pkg.DATA_TYPE_NUMBER then
                io_param_value_n := to_number(r.param_value, com_api_const_pkg.NUMBER_FORMAT);
            elsif l_data_type = com_api_const_pkg.DATA_TYPE_DATE then
                io_param_value_d := to_date(r.param_value, com_api_const_pkg.DATE_FORMAT);
            end if;
            l_value := r.param_value;
            exit;
        end if;
    end loop;
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' >> returning value of parameter [#1] = [#2]'
      , i_env_param1 => i_param_name
      , i_env_param2 => nvl(l_value, 'NULL')
    );
end get_param_value;

procedure get_param_value(
    i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_standard_id       in      com_api_type_pkg.t_tiny_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_param_name        in      com_api_type_pkg.t_name
  , i_eff_date          in      date                            default null
  , i_param_tab         in      com_api_type_pkg.t_param_tab
  , o_param_value          out  varchar2
) is
    l_param_value_d     date;
    l_param_value_n     number;
begin
    get_param_value(
        i_inst_id           => i_inst_id
      , i_standard_id       => i_standard_id
      , i_entity_type       => i_entity_type
      , i_object_id         => i_object_id
      , i_param_name        => i_param_name
      , i_data_type         => com_api_const_pkg.DATA_TYPE_CHAR
      , i_eff_date          => i_eff_date
      , io_param_value_v    => o_param_value
      , io_param_value_d    => l_param_value_d
      , io_param_value_n    => l_param_value_n
      , i_param_tab         => i_param_tab
    );
end;

procedure get_param_value(
    i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_standard_id       in      com_api_type_pkg.t_tiny_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_param_name        in      com_api_type_pkg.t_name
  , i_eff_date          in      date                            default null
  , i_param_tab         in      com_api_type_pkg.t_param_tab
  , o_param_value          out  date
) is
    l_param_value_v     com_api_type_pkg.t_name;
    l_param_value_n     number;
begin
    get_param_value(
        i_inst_id           => i_inst_id
      , i_standard_id       => i_standard_id
      , i_entity_type       => i_entity_type
      , i_object_id         => i_object_id
      , i_param_name        => i_param_name
      , i_data_type         => com_api_const_pkg.DATA_TYPE_DATE
      , i_eff_date          => i_eff_date
      , io_param_value_v    => l_param_value_v
      , io_param_value_d    => o_param_value
      , io_param_value_n    => l_param_value_n
      , i_param_tab         => i_param_tab
    );
end;

procedure get_param_value(
    i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_standard_id       in      com_api_type_pkg.t_tiny_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_param_name        in      com_api_type_pkg.t_name
  , i_eff_date          in      date                            default null
  , i_param_tab         in      com_api_type_pkg.t_param_tab
  , o_param_value          out  number
) is
    l_param_value_v     com_api_type_pkg.t_name;
    l_param_value_d     date;
begin
    get_param_value(
        i_inst_id           => i_inst_id
      , i_standard_id       => i_standard_id
      , i_entity_type       => i_entity_type
      , i_object_id         => i_object_id
      , i_param_name        => i_param_name
      , i_data_type         => com_api_const_pkg.DATA_TYPE_NUMBER
      , i_eff_date          => i_eff_date
      , io_param_value_v    => l_param_value_v
      , io_param_value_d    => l_param_value_d
      , io_param_value_n    => o_param_value
      , i_param_tab         => i_param_tab
    );
end;

function get_varchar_value(
    i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_standard_id       in      com_api_type_pkg.t_tiny_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_param_name        in      com_api_type_pkg.t_name
  , i_eff_date          in      date                            default null
  , i_param_tab         in      com_api_type_pkg.t_param_tab
) return varchar2 is
    l_param_value_v     com_api_type_pkg.t_name;
    l_param_value_d     date;
    l_param_value_n     number;
begin
    get_param_value(
        i_inst_id           => i_inst_id
      , i_standard_id       => i_standard_id
      , i_entity_type       => i_entity_type
      , i_object_id         => i_object_id
      , i_param_name        => i_param_name
      , i_data_type         => com_api_const_pkg.DATA_TYPE_CHAR
      , i_eff_date          => i_eff_date
      , io_param_value_v    => l_param_value_v
      , io_param_value_d    => l_param_value_d
      , io_param_value_n    => l_param_value_n
      , i_param_tab         => i_param_tab
    );

    return l_param_value_v;
end;


function get_date_value(
    i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_standard_id       in      com_api_type_pkg.t_tiny_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_param_name        in      com_api_type_pkg.t_name
  , i_eff_date          in      date                            default null
  , i_param_tab         in      com_api_type_pkg.t_param_tab
) return date is
    l_param_value_v     com_api_type_pkg.t_name;
    l_param_value_d     date;
    l_param_value_n     number;
begin
    get_param_value(
        i_inst_id           => i_inst_id
      , i_standard_id       => i_standard_id
      , i_entity_type       => i_entity_type
      , i_object_id         => i_object_id
      , i_param_name        => i_param_name
      , i_data_type         => com_api_const_pkg.DATA_TYPE_DATE
      , i_eff_date          => i_eff_date
      , io_param_value_v    => l_param_value_v
      , io_param_value_d    => l_param_value_d
      , io_param_value_n    => l_param_value_n
      , i_param_tab         => i_param_tab
    );

    return l_param_value_d;
end;

function get_number_value(
    i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_standard_id       in      com_api_type_pkg.t_tiny_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_param_name        in      com_api_type_pkg.t_name
  , i_eff_date          in      date                            default null
  , i_param_tab         in      com_api_type_pkg.t_param_tab
) return number is
    l_param_value_v     com_api_type_pkg.t_name;
    l_param_value_d     date;
    l_param_value_n     number;
begin
    get_param_value(
        i_inst_id           => i_inst_id
      , i_standard_id       => i_standard_id
      , i_entity_type       => i_entity_type
      , i_object_id         => i_object_id
      , i_param_name        => i_param_name
      , i_data_type         => com_api_const_pkg.DATA_TYPE_NUMBER
      , i_eff_date          => i_eff_date
      , io_param_value_v    => l_param_value_v
      , io_param_value_d    => l_param_value_d
      , io_param_value_n    => l_param_value_n
      , i_param_tab         => i_param_tab
    );

    return l_param_value_n;
end;

procedure get_prd_attr_value_number(
    i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_host_id           in      com_api_type_pkg.t_tiny_id
  , i_standard_id       in      com_api_type_pkg.t_tiny_id      default null
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_param_name        in      com_api_type_pkg.t_name
  , i_eff_date          in      date                            default get_sysdate
  , i_param_tab         in      com_api_type_pkg.t_param_tab
  , i_mask_error        in      com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_use_default_value in      com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_default_value     in      number                          default null
  , o_param_value          out  number
)
is
    l_standard_id               com_api_type_pkg.t_tiny_id;
    l_attr_product_name         com_api_type_pkg.t_name;
begin
    trc_log_pkg.debug(
        i_text        => 'cmn_api_standard_pkg.get_prd_attr_value_number: i_host_id [#1], i_entity_type [#2], i_object_id [#3], i_eff_date [#4]'
      , i_env_param1  => i_host_id
      , i_env_param2  => i_entity_type
      , i_env_param3  => i_object_id
      , i_env_param4  => to_char(i_eff_date, com_api_const_pkg.DATE_FORMAT)
    );
    if i_standard_id is null then
        l_standard_id := net_api_network_pkg.get_offline_standard(i_host_id => i_host_id);
    else
        l_standard_id := i_standard_id;
    end if;

    begin
        cmn_api_standard_pkg.get_param_value(
            i_inst_id       => i_inst_id
          , i_standard_id   => l_standard_id
          , i_entity_type   => net_api_const_pkg.ENTITY_TYPE_HOST
          , i_object_id     => i_host_id
          , i_param_name    => i_param_name
          , i_eff_date      => i_eff_date
          , i_param_tab     => i_param_tab
          , o_param_value   => l_attr_product_name
        );
    exception
        when com_api_error_pkg.e_application_error then
            if i_mask_error = com_api_type_pkg.TRUE then
                trc_log_pkg.debug(
                    i_text        => 'Product value [#1] not found by host_id [#2], entity_type [#3], standard_id [#4], eff_date [#5]'
                  , i_env_param1  => i_param_name 
                  , i_env_param2  => i_host_id
                  , i_env_param3  => net_api_const_pkg.ENTITY_TYPE_HOST
                  , i_env_param4  => l_standard_id
                  , i_env_param5  => to_char(i_eff_date, com_api_const_pkg.DATE_FORMAT)
                );
            else
                raise;
            end if;
    end;

    o_param_value :=
        prd_api_product_pkg.get_attr_value_number(
            i_entity_type       => i_entity_type
          , i_object_id         => i_object_id
          , i_attr_name         => l_attr_product_name
          , i_eff_date          => i_eff_date
          , i_inst_id           => i_inst_id
          , i_product_id        => null
          , i_mask_error        => i_mask_error
          , i_use_default_value => i_use_default_value
          , i_default_value     => i_default_value
        );
    if o_param_value is null
        and i_use_default_value = com_api_type_pkg.FALSE
    then
        trc_log_pkg.debug(
            i_text        => 'Product attribute value NOT FOUND by host_id [#1], entity_type [#2], object_id [#3], attr_product_name [#4], eff_date [#5]'
          , i_env_param1  => i_host_id
          , i_env_param2  => i_entity_type
          , i_env_param3  => i_object_id
          , i_env_param4  => l_attr_product_name
          , i_env_param5  => to_char(i_eff_date, com_api_const_pkg.DATE_FORMAT)
        );
    end if;
end;

function find_value_owner(
    i_standard_id       in      com_api_type_pkg.t_tiny_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_param_name        in      com_api_type_pkg.t_name
  , i_value             in      com_api_type_pkg.t_name
  , i_requested_type    in      com_api_type_pkg.t_dict_value
  , i_mask_error        in      com_api_type_pkg.t_boolean      := com_api_type_pkg.FALSE
  , i_masked_level      in      com_api_type_pkg.t_tiny_id      := null
) return com_api_type_pkg.t_inst_id is
    l_result                    com_api_type_pkg.t_inst_id;
    l_data_type                 com_api_type_pkg.t_dict_value;
    l_param_id                  com_api_type_pkg.t_short_id;
begin
    begin
        select id
             , data_type
          into l_param_id
             , l_data_type
          from cmn_parameter
         where name        = upper(i_param_name)
           and standard_id = i_standard_id;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error (
                i_error         => 'STANDARD_PARAM_NOT_EXISTS'
                , i_env_param1  => upper(i_param_name)
                , i_env_param2  => i_standard_id
            );
    end;

    if l_data_type != i_requested_type then
        com_api_error_pkg.raise_error (
            i_error         => 'INCORRECT_PARAM_VALUE_DATA_TYPE'
            , i_env_param1  => i_requested_type
            , i_env_param2  => l_data_type
        );
    end if;

    if i_entity_type = net_api_const_pkg.ENTITY_TYPE_HOST then
        select t.inst_id
          into l_result
          from (
              select m.inst_id
                from net_api_interface_param_val_vw v
                   , net_member m
               where v.standard_id    = i_standard_id
                 and v.host_member_id = i_object_id
                 and v.param_name     = i_param_name
                 and v.param_value    = i_value
                 and m.id             = v.consumer_member_id
               order by decode(v.msp_member_id, null, 0, 1), m.inst_id
          ) t
         where rownum = 1;
    else
        null;
    end if;

    trc_log_pkg.debug (
        i_text          => 'Returning requested value of [#1]=[#2]'
        , i_env_param1  => i_param_name
        , i_env_param2  => l_result
    );
    
    return l_result;
exception
    when no_data_found then
        if i_mask_error       = com_api_type_pkg.TRUE
           and i_masked_level = trc_config_pkg.DEBUG
        then
            trc_log_pkg.debug (
                i_text          => 'Communication parameter value not found: param_name [#1] value [#2] standard_id [#3] entity_type [#4] object_id [#5]'
                , i_env_param1   => i_param_name
                , i_env_param2   => i_value
                , i_env_param3   => i_standard_id
                , i_env_param4   => i_entity_type
                , i_env_param5   => i_object_id
            );
            return null;
        else
            com_api_error_pkg.raise_error (
                i_error          => 'NOT_FOUND_VALUE_OWNER'
                , i_env_param1   => i_param_name
                , i_env_param2   => i_value
                , i_env_param3   => i_standard_id
                , i_env_param4   => i_entity_type
                , i_env_param5   => i_object_id
                , i_mask_error   => i_mask_error
            );
        end if;
    when too_many_rows then
        com_api_error_pkg.raise_error (
            i_error          => 'TOO_MANY_VALUE_OWNERS'
            , i_env_param1   => i_param_name
            , i_env_param2   => i_value
            , i_env_param3   => i_standard_id
            , i_env_param4   => i_entity_type
            , i_env_param5   => i_object_id
        );
end;

function find_value_owner(
    i_standard_id       in      com_api_type_pkg.t_tiny_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_param_name        in      com_api_type_pkg.t_name
  , i_value_char        in      com_api_type_pkg.t_name
  , i_mask_error        in      com_api_type_pkg.t_boolean      := com_api_type_pkg.FALSE
  , i_masked_level      in      com_api_type_pkg.t_tiny_id      := null
) return com_api_type_pkg.t_inst_id is
begin
    return find_value_owner(
        i_standard_id       => i_standard_id
      , i_entity_type       => i_entity_type
      , i_object_id         => i_object_id
      , i_param_name        => i_param_name
      , i_value             => i_value_char
      , i_requested_type    => com_api_const_pkg.DATA_TYPE_CHAR
      , i_mask_error        => i_mask_error
      , i_masked_level      => i_masked_level
    );
end;

function find_value_owner(
    i_standard_id       in      com_api_type_pkg.t_tiny_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_param_name        in      com_api_type_pkg.t_name
  , i_value_number      in      number
  , i_mask_error        in      com_api_type_pkg.t_boolean      := com_api_type_pkg.FALSE
  , i_masked_level      in      com_api_type_pkg.t_tiny_id      := null
) return com_api_type_pkg.t_inst_id is
begin
    return find_value_owner(
        i_standard_id       => i_standard_id
      , i_entity_type       => i_entity_type
      , i_object_id         => i_object_id
      , i_param_name        => i_param_name
      , i_value             => to_char(i_value_number, com_api_const_pkg.NUMBER_FORMAT)
      , i_requested_type    => com_api_const_pkg.DATA_TYPE_NUMBER
      , i_mask_error        => i_mask_error
      , i_masked_level      => i_masked_level
    );
end;

function find_value_owner(
    i_standard_id       in      com_api_type_pkg.t_tiny_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_param_name        in      com_api_type_pkg.t_name
  , i_value_date        in      date
  , i_mask_error        in      com_api_type_pkg.t_boolean      := com_api_type_pkg.FALSE
  , i_masked_level      in      com_api_type_pkg.t_tiny_id      := null
) return com_api_type_pkg.t_inst_id is
begin
    return find_value_owner(
        i_standard_id       => i_standard_id
      , i_entity_type       => i_entity_type
      , i_object_id         => i_object_id
      , i_param_name        => i_param_name
      , i_value             => to_char(i_value_date, com_api_const_pkg.DATE_FORMAT)
      , i_requested_type    => com_api_const_pkg.DATA_TYPE_DATE
      , i_mask_error        => i_mask_error
      , i_masked_level      => i_masked_level
    );
end;

function verify_version (
    i_standard_id       in      com_api_type_pkg.t_tiny_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_version_number    in      com_api_type_pkg.t_name
) return com_api_type_pkg.t_boolean is                            -- 1 - version equal or higher; 0 - version less
    l_result            com_api_type_pkg.t_boolean;
    l_version_order     com_api_type_pkg.t_tiny_id;
    l_version_id        com_api_type_pkg.t_tiny_id;
begin

    begin
        select a.version_order
          into l_version_order
          from cmn_standard_version a
         where a.standard_id    = i_standard_id
           and a.version_number = i_version_number;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error         => 'STANDARD_VERSION_NOT_FOUND'
              , i_env_param1    => i_standard_id
              , i_env_param2    => i_version_number
            );
    end;

    l_version_id :=
        get_current_version(
            i_standard_id       => i_standard_id
          , i_entity_type       => i_entity_type
          , i_object_id         => i_object_id
          , i_eff_date          => com_api_sttl_day_pkg.get_sysdate
        );

    select count(1)
      into l_result
      from cmn_standard_version
     where id = l_version_id
       and version_order >= l_version_order;

    return l_result;
end;

end;
/
