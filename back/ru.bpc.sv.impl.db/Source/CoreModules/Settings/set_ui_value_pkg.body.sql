create or replace package body set_ui_value_pkg as

DATE_FORMAT     com_api_type_pkg.t_name := 'dd.mm.yyyy hh24:mi:ss';
--NUMBER_FORMAT   com_api_type_pkg.t_name := '999999999999999990.9999';

g_oracle_user                   com_api_type_pkg.t_name;

function get_parameter_rec(
    i_param_name        in      com_api_type_pkg.t_name
  , i_param_level       in      com_api_type_pkg.t_dict_value
) return t_parameter_rec
result_cache
relies_on (set_parameter)
is
    l_parameter_rec     t_parameter_rec;
    l_param_name        com_api_type_pkg.t_name        := upper(i_param_name);
    l_param_level       com_api_type_pkg.t_dict_value  := upper(i_param_level);
begin
    select id
         , data_type
         , default_value
         , case when lowest_level = SYST_LEVEL then 0
                when lowest_level = INST_LEVEL then 1
                when lowest_level = AGNT_LEVEL then 2
                when lowest_level = USER_LEVEL then 3
                else 4
           end lower_weight
         , case when l_param_level = SYST_LEVEL then 0
                when l_param_level = INST_LEVEL then 1
                when l_param_level = AGNT_LEVEL then 2
                when l_param_level = USER_LEVEL then 3
                else 4
           end curr_weight
      into l_parameter_rec
      from set_parameter
     where name = l_param_name;

    return l_parameter_rec;

exception
    when no_data_found then
        return null;
end get_parameter_rec;

function get_value_rec(
    i_param_id          in      com_api_type_pkg.t_short_id
  , i_param_level       in      com_api_type_pkg.t_dict_value
  , i_level_value       in      com_api_type_pkg.t_name
) return t_value_rec
result_cache
relies_on (set_parameter_value)
is
    l_parameter_value   t_value_rec;
    l_level_value       com_api_type_pkg.t_name := coalesce(i_level_value, '0');
begin
    select param_id
         , param_value
      into l_parameter_value
      from set_parameter_value
     where param_id    = i_param_id
       and param_level = i_param_level
       and level_value = l_level_value;

    return l_parameter_value;

exception
    when no_data_found then
        return null;
end get_value_rec;

procedure check_reload(
    i_param_name        in      com_api_type_pkg.t_name
) is
begin
    if i_param_name in ('PARALLEL_DEGREE', 'SPLIT_DEGREE') then
        com_api_hash_pkg.reload_settings;
    elsif i_param_name in ('BEGIN_VISIBLE_CHAR', 'END_VISIBLE_CHAR') then
        iss_api_card_pkg.reload_settings;
    elsif i_param_name in ('USE_HSM') then
        hsm_api_device_pkg.reload_settings;
    end if;
end;

procedure set_param_value(
    i_param_name        in      com_api_type_pkg.t_name
  , i_param_level       in      com_api_type_pkg.t_dict_value    default SYST_LEVEL
  , i_level_value       in      com_api_type_pkg.t_name          default null
  , i_param_value_v     in      varchar2                         default null
  , i_param_value_d     in      date                             default null
  , i_param_value_n     in      number                           default null
) is
    l_param_id          com_api_type_pkg.t_short_id;
    l_lower_weight      pls_integer;
    l_curr_weight       pls_integer;
    l_data_type         com_api_type_pkg.t_dict_value;
    l_data_type_2       com_api_type_pkg.t_dict_value;
    l_param_value       com_api_type_pkg.t_name;
begin
    begin
        select id
             , case when lowest_level = SYST_LEVEL then 0
                    when lowest_level = INST_LEVEL then 1
                    when lowest_level = AGNT_LEVEL then 2
                    when lowest_level = USER_LEVEL then 3
                    else 4
               end lower_weight
             , case when upper(i_param_level) = SYST_LEVEL then 0
                    when upper(i_param_level) = INST_LEVEL then 1
                    when upper(i_param_level) = AGNT_LEVEL then 2
                    when upper(i_param_level) = USER_LEVEL then 3
                    else 4
               end curr_weight
             , data_type
          into l_param_id
             , l_lower_weight
             , l_curr_weight
             , l_data_type
          from set_parameter
         where name = upper(i_param_name);
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error      => 'PARAM_NOT_EXISTS'
              , i_env_param1 => upper(i_param_name)
            );
    end;

    if i_param_value_v is not null then
        l_data_type_2 := com_api_const_pkg.DATA_TYPE_CHAR;
    elsif i_param_value_n is not null then
        l_data_type_2 := com_api_const_pkg.DATA_TYPE_NUMBER;
    elsif i_param_value_d is not null then
        l_data_type_2 := com_api_const_pkg.DATA_TYPE_DATE;
    elsif i_param_value_v is null and i_param_value_n is null and i_param_value_d is null then
        -- need to remove old value if it exists
        delete from set_parameter_value_vw
         where param_id    = l_param_id
           and param_level = i_param_level
           and level_value = nvl(i_level_value, '0');
        
        trc_log_pkg.debug('deleted rows [' || sql%rowcount|| ']');
    end if;

    if l_data_type != l_data_type_2 then
        com_api_error_pkg.raise_error(
            i_error      => 'INCORRECT_PARAM_VALUE_DATA_TYPE'
          , i_env_param1 => l_data_type_2
          , i_env_param2 => l_data_type
        );
    end if;

    if l_lower_weight < l_curr_weight then
        com_api_error_pkg.raise_error(
            i_error      => 'NOT_ALLOWED_DEFINE_VALUE_ON_LEVEL'
          , i_env_param1 => upper(i_param_name)
          , i_env_param2 => i_param_level
        );
    end if;

    if l_data_type = com_api_const_pkg.DATA_TYPE_CHAR then
        l_param_value := i_param_value_v;
    elsif l_data_type = com_api_const_pkg.DATA_TYPE_NUMBER then
        l_param_value := to_char(i_param_value_n, com_api_const_pkg.NUMBER_FORMAT);
    elsif l_data_type = com_api_const_pkg.DATA_TYPE_DATE then
        l_param_value := to_char(i_param_value_d, com_api_const_pkg.DATE_FORMAT);
    end if;

    update set_parameter_value_vw
       set param_value = l_param_value
     where param_id    = l_param_id
       and param_level = i_param_level
       and level_value = coalesce(i_level_value, '0');

    if sql%rowcount = 0 then
        insert into set_parameter_value_vw (
            id
          , param_id
          , param_level
          , level_value
          , param_value
        )
        values (
            set_parameter_value_seq.nextval
          , l_param_id
          , i_param_level
          , coalesce(i_level_value, '0')
          , l_param_value
        );
    end if;

    check_reload(
        i_param_name        => i_param_name
    );
end;

procedure set_system_param_v(
    i_param_name        in      com_api_type_pkg.t_name
  , i_param_value       in      varchar2
) is
begin
    set_param_value(
        i_param_name        => i_param_name
      , i_param_value_v     => i_param_value
    );
end;

procedure set_inst_param_v(
    i_param_name        in      com_api_type_pkg.t_name
  , i_param_value       in      varchar2
  , i_inst_id           in      com_api_type_pkg.t_inst_id          default null
) is
begin
    set_param_value(
        i_param_name        => i_param_name
      , i_param_level       => INST_LEVEL
      , i_level_value       => coalesce(i_inst_id, com_ui_user_env_pkg.get_user_inst)
      , i_param_value_v     => i_param_value
    );
end;

procedure set_agent_param_v(
    i_param_name        in      com_api_type_pkg.t_name
  , i_param_value       in      varchar2
  , i_agent_id          in      com_api_type_pkg.t_agent_id         default null
) is
begin
    set_param_value(
        i_param_name        => i_param_name
      , i_param_level       => AGNT_LEVEL
      , i_level_value       => coalesce(i_agent_id, com_ui_user_env_pkg.get_user_agent)
      , i_param_value_v     => i_param_value
    );
end;

procedure set_user_param_v(
    i_param_name        in      com_api_type_pkg.t_name
  , i_param_value       in      varchar2
  , i_user_id           in      com_api_type_pkg.t_name             default null
) is
begin
    set_param_value(
        i_param_name        => i_param_name
      , i_param_level       => USER_LEVEL
      , i_level_value       => coalesce(i_user_id, sys_context('USERENV', 'CLIENT_IDENTIFIER'), g_oracle_user)
      , i_param_value_v     => i_param_value
    );
end;

procedure set_system_param_d(
    i_param_name        in      com_api_type_pkg.t_name
  , i_param_value       in      date
) is
begin
    set_param_value(
        i_param_name        => i_param_name
      , i_param_value_d     => i_param_value
    );
end;

procedure set_inst_param_d(
    i_param_name        in      com_api_type_pkg.t_name
  , i_param_value       in      date
  , i_inst_id           in      com_api_type_pkg.t_inst_id          default null
) is
begin
    set_param_value(
        i_param_name        => i_param_name
      , i_param_level       => INST_LEVEL
      , i_level_value       => coalesce(i_inst_id, com_ui_user_env_pkg.get_user_inst)
      , i_param_value_d     => i_param_value
    );
end;

procedure set_agent_param_d(
    i_param_name        in      com_api_type_pkg.t_name
  , i_param_value       in      date
  , i_agent_id          in      com_api_type_pkg.t_agent_id         default null
) is
begin
    set_param_value(
        i_param_name        => i_param_name
      , i_param_level       => AGNT_LEVEL
      , i_level_value       => coalesce(i_agent_id, com_ui_user_env_pkg.get_user_agent)
      , i_param_value_d     => i_param_value
    );
end;

procedure set_user_param_d(
    i_param_name        in      com_api_type_pkg.t_name
  , i_param_value       in      date
  , i_user_id           in      com_api_type_pkg.t_name             default null
) is
begin
    set_param_value(
        i_param_name        => i_param_name
      , i_param_level       => USER_LEVEL
      , i_level_value       => coalesce(i_user_id, sys_context('USERENV', 'CLIENT_IDENTIFIER'), g_oracle_user)
      , i_param_value_d     => i_param_value
    );
end;

procedure set_system_param_n(
    i_param_name        in      com_api_type_pkg.t_name
  , i_param_value       in      number
) is
begin
    set_param_value(
        i_param_name        => i_param_name
      , i_param_value_n     => i_param_value
    );
end;

procedure set_inst_param_n(
    i_param_name        in      com_api_type_pkg.t_name
  , i_param_value       in      number
  , i_inst_id           in      com_api_type_pkg.t_inst_id          default null
) is
begin
    set_param_value(
        i_param_name        => i_param_name
      , i_param_level       => INST_LEVEL
      , i_level_value       => coalesce(i_inst_id, com_ui_user_env_pkg.get_user_inst)
      , i_param_value_n     => i_param_value
    );
end;

procedure set_agent_param_n(
    i_param_name        in      com_api_type_pkg.t_name
  , i_param_value       in      number
  , i_agent_id          in      com_api_type_pkg.t_agent_id         default null
) is
begin
    set_param_value(
        i_param_name        => i_param_name
      , i_param_level       => AGNT_LEVEL
      , i_level_value       => coalesce(i_agent_id, com_ui_user_env_pkg.get_user_agent)
      , i_param_value_n     => i_param_value
    );
end;

procedure set_user_param_n(
    i_param_name        in      com_api_type_pkg.t_name
  , i_param_value       in      number
  , i_user_id           in      com_api_type_pkg.t_name             default null
) is
begin
    set_param_value(
        i_param_name        => i_param_name
      , i_param_level       => USER_LEVEL
      , i_level_value       => coalesce(i_user_id, sys_context('USERENV', 'CLIENT_IDENTIFIER'), g_oracle_user)
      , i_param_value_n     => i_param_value
    );
end;

procedure get_param_value(
    i_param_name        in      com_api_type_pkg.t_name
  , i_param_level       in      com_api_type_pkg.t_dict_value       default SYST_LEVEL
  , i_level_value       in      com_api_type_pkg.t_name             default null
  , i_data_type         in      com_api_type_pkg.t_oracle_name
  , io_param_value_v    in out  varchar2
  , io_param_value_d    in out  date
  , io_param_value_n    in out  number
) is
    l_param_level       com_api_type_pkg.t_dict_value               := i_param_level;
    l_level_value       com_api_type_pkg.t_name                     := i_level_value;
    l_parameter_rec     t_parameter_rec;
    l_parameter_value   t_value_rec;
begin
    l_parameter_rec :=  get_parameter_rec(
                            i_param_name   => i_param_name
                          , i_param_level  => i_param_level
                        );

    if l_parameter_rec.param_id is null then
        com_api_error_pkg.raise_error(
            i_error      => 'PARAM_NOT_EXISTS'
          , i_env_param1 => upper(i_param_name)
        );
    end if;

    if l_parameter_rec.data_type != i_data_type then
        com_api_error_pkg.raise_error(
            i_error      => 'INCORRECT_PARAM_VALUE_DATA_TYPE'
          , i_env_param1 => i_data_type
          , i_env_param2 => l_parameter_rec.data_type
        );
    end if;

    loop
        if l_parameter_rec.curr_weight > l_parameter_rec.lower_weight then
            l_parameter_value := null;
        else
            l_parameter_value := get_value_rec(
                                     i_param_id       => l_parameter_rec.param_id
                                   , i_param_level    => l_param_level
                                   , i_level_value    => coalesce(l_level_value, '0')
                                 );
        end if;

        if l_parameter_value.param_id is not null then
            begin
                if l_parameter_rec.data_type    = com_api_const_pkg.DATA_TYPE_CHAR then
                    io_param_value_v           := l_parameter_value.param_value;

                elsif l_parameter_rec.data_type = com_api_const_pkg.DATA_TYPE_NUMBER then
                    io_param_value_n           := to_number(l_parameter_value.param_value, com_api_const_pkg.NUMBER_FORMAT);

                elsif l_parameter_rec.data_type = com_api_const_pkg.DATA_TYPE_DATE then
                    io_param_value_d           := to_date(l_parameter_value.param_value, com_api_const_pkg.DATE_FORMAT);

                end if;

                exit;
            exception when com_api_error_pkg.e_value_error or com_api_error_pkg.e_invalid_number then
                com_api_error_pkg.raise_error(
                    i_error      => 'WRONG_PARAM_VALUE_FORMAT'
                  , i_env_param1 => i_param_name
                  , i_env_param2 => i_data_type
                  , i_env_param3 => l_parameter_value.param_value
                );
            end;
        else
            if l_param_level = USER_LEVEL then
                l_param_level                   := AGNT_LEVEL;
                l_level_value                   := acm_api_user_pkg.get_user_agent_id(
                                                       i_user_name => l_level_value
                                                   );
                if l_level_value is null then
                    l_param_level               := SYST_LEVEL;
                    l_level_value               := '0';
                    l_parameter_rec.curr_weight := 0;
                else
                    l_parameter_rec.curr_weight := 2;
                end if;

            elsif l_param_level = AGNT_LEVEL then
                l_param_level                   := INST_LEVEL;
                l_level_value                   := ost_api_agent_pkg.get_inst_id(
                                                       i_agent_id => l_level_value
                                                   );
                l_parameter_rec.curr_weight     := 1;

            elsif l_param_level = INST_LEVEL then
                l_level_value                   := ost_api_institution_pkg.get_parent_inst_id(
                                                       i_inst_id => l_level_value
                                                   );
                if l_level_value is null then
                    l_param_level               := SYST_LEVEL;
                    l_level_value               := '0';
                    l_parameter_rec.curr_weight := 0;
                end if;

            else
                --com_api_error_pkg.raise_error('PARAM_VALUE_NOT_DEFINED', upper(i_param_name));
                begin
                    if l_parameter_rec.data_type    = com_api_const_pkg.DATA_TYPE_CHAR then
                        io_param_value_v           := l_parameter_rec.default_value;

                    elsif l_parameter_rec.data_type = com_api_const_pkg.DATA_TYPE_NUMBER then
                        io_param_value_n           := to_number(l_parameter_rec.default_value, com_api_const_pkg.NUMBER_FORMAT);

                    elsif l_parameter_rec.data_type = com_api_const_pkg.DATA_TYPE_DATE then
                        io_param_value_d           := to_date(l_parameter_rec.default_value, com_api_const_pkg.DATE_FORMAT);

                    end if;
                exception
                    when com_api_error_pkg.e_value_error or com_api_error_pkg.e_invalid_number then
                        com_api_error_pkg.raise_error(
                            i_error      => 'WRONG_PARAM_VALUE_FORMAT'
                          , i_env_param1 => i_param_name
                          , i_env_param2 => i_data_type
                          , i_env_param3 => l_parameter_rec.default_value
                        );
                end;
                exit;
            end if;
        end if;
    end loop;
exception
    when com_api_error_pkg.e_application_error then
        raise;
    when others then
        trc_log_pkg.debug(
            i_text       => lower($$PLSQL_UNIT) || '.get_param_value FAILED: '
                         || 'i_param_name ['     || i_param_name                           || '], '
                         || 'i_param_level ['    || i_param_level                          || '], '
                         || 'i_data_type ['      || i_data_type                            || '], '
                         || 'l_data_type ['      || l_parameter_rec.data_type              || '], '
                         || 'i_level_value ['    || i_level_value                          || '], '
                         || 'l_default_value ['  || l_parameter_rec.default_value          || '], '
                         || 'io_param_value_v [' || io_param_value_v                       || '], '
                         || 'io_param_value_d [' || to_char(io_param_value_d, DATE_FORMAT) || '], '
                         || 'io_param_value_n [' || io_param_value_n                       || ']'
        );
        raise;
end;

function get_system_param_v(
    i_param_name        in      com_api_type_pkg.t_name
  , i_data_type         in      com_api_type_pkg.t_dict_value       default null
) return varchar2
is
    l_data_type         com_api_type_pkg.t_oracle_name := com_api_const_pkg.DATA_TYPE_CHAR;
    l_param_value_v     com_api_type_pkg.t_name;
    l_param_value_d     date;
    l_param_value_n     number;
begin
    if i_data_type != l_data_type then
        return null;
    end if;

    get_param_value(
        i_param_name        => i_param_name
      , i_data_type         => l_data_type
      , io_param_value_v    => l_param_value_v
      , io_param_value_d    => l_param_value_d
      , io_param_value_n    => l_param_value_n
    );

    return l_param_value_v;
end;

function get_inst_param_v(
    i_param_name        in      com_api_type_pkg.t_name
  , i_inst_id           in      com_api_type_pkg.t_inst_id          default null
  , i_data_type         in      com_api_type_pkg.t_dict_value       default null
) return varchar2
is
    l_data_type         com_api_type_pkg.t_oracle_name := com_api_const_pkg.DATA_TYPE_CHAR;
    l_param_value_v     com_api_type_pkg.t_name;
    l_param_value_d     date;
    l_param_value_n     number;
begin
    if i_data_type != l_data_type then
        return null;
    end if;

    get_param_value(
        i_param_name        => i_param_name
      , i_param_level       => INST_LEVEL
      , i_level_value       => coalesce(i_inst_id, com_ui_user_env_pkg.get_user_inst)
      , i_data_type         => l_data_type
      , io_param_value_v    => l_param_value_v
      , io_param_value_d    => l_param_value_d
      , io_param_value_n    => l_param_value_n
    );

    return l_param_value_v;
end;

function get_agent_param_v(
    i_param_name        in      com_api_type_pkg.t_name
  , i_agent_id          in      com_api_type_pkg.t_agent_id         default null
  , i_data_type         in      com_api_type_pkg.t_dict_value       default null
) return varchar2
is
    l_data_type         com_api_type_pkg.t_oracle_name := com_api_const_pkg.DATA_TYPE_CHAR;
    l_param_value_v     com_api_type_pkg.t_name;
    l_param_value_d     date;
    l_param_value_n     number;
begin
    if i_data_type != l_data_type then
        return null;
    end if;

    get_param_value(
        i_param_name        => i_param_name
      , i_param_level       => AGNT_LEVEL
      , i_level_value       => coalesce(i_agent_id, com_ui_user_env_pkg.get_user_agent)
      , i_data_type         => l_data_type
      , io_param_value_v    => l_param_value_v
      , io_param_value_d    => l_param_value_d
      , io_param_value_n    => l_param_value_n
    );

    return l_param_value_v;
end;

function get_user_param_v(
    i_param_name        in      com_api_type_pkg.t_name
  , i_user_id           in      com_api_type_pkg.t_name             default null
  , i_data_type         in      com_api_type_pkg.t_dict_value       default null
) return varchar2
is
    l_data_type         com_api_type_pkg.t_oracle_name := com_api_const_pkg.DATA_TYPE_CHAR;
    l_param_value_v     com_api_type_pkg.t_name;
    l_param_value_d     date;
    l_param_value_n     number;
begin
    if i_data_type != l_data_type then
        return null;
    end if;

    get_param_value(
        i_param_name        => i_param_name
      , i_param_level       => USER_LEVEL
      , i_level_value       => coalesce(i_user_id, sys_context('USERENV', 'CLIENT_IDENTIFIER'), g_oracle_user)
      , i_data_type         => l_data_type
      , io_param_value_v    => l_param_value_v
      , io_param_value_d    => l_param_value_d
      , io_param_value_n    => l_param_value_n
    );

    return l_param_value_v;
end;

function get_system_param_d(
    i_param_name        in      com_api_type_pkg.t_name
  , i_data_type         in      com_api_type_pkg.t_dict_value       default null
) return date
is
    l_data_type         com_api_type_pkg.t_oracle_name := com_api_const_pkg.DATA_TYPE_DATE;
    l_param_value_v     com_api_type_pkg.t_name;
    l_param_value_d     date;
    l_param_value_n     number;
begin
    if i_data_type != l_data_type then
        return null;
    end if;

    get_param_value(
        i_param_name        => i_param_name
      , i_data_type         => l_data_type
      , io_param_value_v    => l_param_value_v
      , io_param_value_d    => l_param_value_d
      , io_param_value_n    => l_param_value_n
    );

    return l_param_value_d;
end;

function get_inst_param_d(
    i_param_name        in      com_api_type_pkg.t_name
  , i_inst_id           in      com_api_type_pkg.t_inst_id          default null
  , i_data_type         in      com_api_type_pkg.t_dict_value       default null
) return date
is
    l_data_type         com_api_type_pkg.t_oracle_name := com_api_const_pkg.DATA_TYPE_DATE;
    l_param_value_v     com_api_type_pkg.t_name;
    l_param_value_d     date;
    l_param_value_n     number;
begin
    if i_data_type != l_data_type then
        return null;
    end if;

    get_param_value(
        i_param_name        => i_param_name
      , i_param_level       => INST_LEVEL
      , i_level_value       => coalesce(i_inst_id, com_ui_user_env_pkg.get_user_inst)
      , i_data_type         => l_data_type
      , io_param_value_v    => l_param_value_v
      , io_param_value_d    => l_param_value_d
      , io_param_value_n    => l_param_value_n
    );

    return l_param_value_d;
end;

function get_agent_param_d(
    i_param_name        in      com_api_type_pkg.t_name
  , i_agent_id          in      com_api_type_pkg.t_agent_id         default null
  , i_data_type         in      com_api_type_pkg.t_dict_value       default null
) return date
is
    l_data_type         com_api_type_pkg.t_oracle_name := com_api_const_pkg.DATA_TYPE_DATE;
    l_param_value_v     com_api_type_pkg.t_name;
    l_param_value_d     date;
    l_param_value_n     number;
begin
    if i_data_type != l_data_type then
        return null;
    end if;

    get_param_value(
        i_param_name        => i_param_name
      , i_param_level       => AGNT_LEVEL
      , i_level_value       => coalesce(i_agent_id, com_ui_user_env_pkg.get_user_agent)
      , i_data_type         => l_data_type
      , io_param_value_v    => l_param_value_v
      , io_param_value_d    => l_param_value_d
      , io_param_value_n    => l_param_value_n
    );

    return l_param_value_d;
end;

function get_user_param_d(
    i_param_name        in      com_api_type_pkg.t_name
  , i_user_id           in      com_api_type_pkg.t_name             default null
  , i_data_type         in      com_api_type_pkg.t_dict_value       default null
) return date
is
    l_data_type         com_api_type_pkg.t_oracle_name := com_api_const_pkg.DATA_TYPE_DATE;
    l_param_value_v     com_api_type_pkg.t_name;
    l_param_value_d     date;
    l_param_value_n     number;
begin
    if i_data_type != l_data_type then
        return null;
    end if;

    get_param_value(
        i_param_name        => i_param_name
      , i_param_level       => USER_LEVEL
      , i_level_value       => coalesce(i_user_id, sys_context('USERENV', 'CLIENT_IDENTIFIER'), g_oracle_user)
      , i_data_type         => l_data_type
      , io_param_value_v    => l_param_value_v
      , io_param_value_d    => l_param_value_d
      , io_param_value_n    => l_param_value_n
    );

    return l_param_value_d;
end;

function get_system_param_n(
    i_param_name        in      com_api_type_pkg.t_name
  , i_data_type         in      com_api_type_pkg.t_dict_value       default null
) return number
is
    l_data_type         com_api_type_pkg.t_oracle_name := com_api_const_pkg.DATA_TYPE_NUMBER;
    l_param_value_v     com_api_type_pkg.t_name;
    l_param_value_d     date;
    l_param_value_n     number;
begin
    if i_data_type != l_data_type then
        return null;
    end if;

    get_param_value(
        i_param_name        => i_param_name
      , i_data_type         => l_data_type
      , io_param_value_v    => l_param_value_v
      , io_param_value_d    => l_param_value_d
      , io_param_value_n    => l_param_value_n
    );

    return l_param_value_n;
end;

function get_inst_param_n(
    i_param_name        in      com_api_type_pkg.t_name
  , i_inst_id           in      com_api_type_pkg.t_inst_id          default null
  , i_data_type         in      com_api_type_pkg.t_dict_value       default null
) return number
is
    l_data_type         com_api_type_pkg.t_oracle_name := com_api_const_pkg.DATA_TYPE_NUMBER;
    l_param_value_v     com_api_type_pkg.t_name;
    l_param_value_d     date;
    l_param_value_n     number;
begin
    if i_data_type != l_data_type then
        return null;
    end if;

    get_param_value(
        i_param_name        => i_param_name
      , i_param_level       => INST_LEVEL
      , i_level_value       => coalesce(i_inst_id, com_ui_user_env_pkg.get_user_inst)
      , i_data_type         => l_data_type
      , io_param_value_v    => l_param_value_v
      , io_param_value_d    => l_param_value_d
      , io_param_value_n    => l_param_value_n
    );

    return l_param_value_n;
end;

function get_agent_param_n(
    i_param_name        in      com_api_type_pkg.t_name
  , i_agent_id          in      com_api_type_pkg.t_agent_id         default null
  , i_data_type         in      com_api_type_pkg.t_dict_value       default null
) return number
is
    l_data_type         com_api_type_pkg.t_oracle_name := com_api_const_pkg.DATA_TYPE_NUMBER;
    l_param_value_v     com_api_type_pkg.t_name;
    l_param_value_d     date;
    l_param_value_n     number;
begin
    if i_data_type != l_data_type then
        return null;
    end if;

    get_param_value(
        i_param_name        => i_param_name
      , i_param_level       => AGNT_LEVEL
      , i_level_value       => coalesce(i_agent_id, com_ui_user_env_pkg.get_user_agent)
      , i_data_type         => l_data_type
      , io_param_value_v    => l_param_value_v
      , io_param_value_d    => l_param_value_d
      , io_param_value_n    => l_param_value_n
    );

    return l_param_value_n;
end;

function get_user_param_n(
    i_param_name        in      com_api_type_pkg.t_name
  , i_user_id           in      com_api_type_pkg.t_name             default null
  , i_data_type         in      com_api_type_pkg.t_dict_value       default null
) return number
is
    l_data_type         com_api_type_pkg.t_oracle_name := com_api_const_pkg.DATA_TYPE_NUMBER;
    l_param_value_v     com_api_type_pkg.t_name;
    l_param_value_d     date;
    l_param_value_n     number;
begin

    if i_data_type != l_data_type then
        return null;
    end if;

    get_param_value(
        i_param_name        => i_param_name
      , i_param_level       => USER_LEVEL
      , i_level_value       => coalesce(i_user_id, sys_context('USERENV', 'CLIENT_IDENTIFIER'), g_oracle_user)
      , i_data_type         => l_data_type
      , io_param_value_v    => l_param_value_v
      , io_param_value_d    => l_param_value_d
      , io_param_value_n    => l_param_value_n
    );

    return l_param_value_n;
end;

procedure set_default_value(
    i_param_name        in      com_api_type_pkg.t_name
  , i_param_level       in      com_api_type_pkg.t_dict_value       default SYST_LEVEL
  , i_level_value       in      com_api_type_pkg.t_name             default null
) is
    l_param_id      com_api_type_pkg.t_short_id;
    l_default_value com_api_type_pkg.t_name;
begin
    begin
        select id, default_value
          into l_param_id, l_default_value
          from set_parameter
         where name = upper(i_param_name);
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error      => 'PARAM_NOT_EXISTS'
              , i_env_param1 => upper(i_param_name)
            );
    end;

    if i_param_level = SYST_LEVEL then
        update set_parameter_value_vw
           set param_value  = l_default_value
         where param_id     = l_param_id
           and param_level  = i_param_level
           and level_value  = '0';
    else
        delete from set_parameter_value_vw
         where param_id     = l_param_id
           and param_level  = i_param_level
           and level_value  = i_level_value;
    end if;
end;

procedure set_system_default_value(
    i_param_name        in      com_api_type_pkg.t_name
) is
begin
    set_default_value(
        i_param_name        => i_param_name
    );
end;

procedure set_inst_default_value(
    i_param_name        in      com_api_type_pkg.t_name
  , i_inst_id           in      com_api_type_pkg.t_inst_id          default null
) is
begin
    set_default_value(
        i_param_name        => i_param_name
      , i_param_level       => INST_LEVEL
      , i_level_value       => coalesce(i_inst_id, com_ui_user_env_pkg.get_user_inst)
    );
end;

procedure set_agent_default_value(
    i_param_name        in      com_api_type_pkg.t_name
  , i_agent_id          in      com_api_type_pkg.t_agent_id         default null
) is
begin
    set_default_value(
        i_param_name        => i_param_name
      , i_param_level       => AGNT_LEVEL
      , i_level_value       => coalesce(i_agent_id, com_ui_user_env_pkg.get_user_agent)
    );
end;

procedure set_user_default_value(
    i_param_name        in      com_api_type_pkg.t_name
  , i_user_id           in      com_api_type_pkg.t_name             default null
) is
begin
    set_default_value(
        i_param_name        => i_param_name
      , i_param_level       => USER_LEVEL
      , i_level_value       => coalesce(i_user_id, sys_context('USERENV', 'CLIENT_IDENTIFIER'), g_oracle_user)
    );
end;

procedure get_param_values(
    i_param_name        in      com_api_type_pkg.t_name
  , io_value_cursor     in out  com_api_type_pkg.t_ref_cur
) is
    l_lov_id            com_api_type_pkg.t_short_id;
begin
    begin
        select lov_id
          into l_lov_id
          from set_parameter
         where name = upper(i_param_name);
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error      => 'PARAM_NOT_EXISTS'
              , i_env_param1 => upper(i_param_name)
            );
    end;

    com_ui_lov_pkg.get_lov(
        o_ref_cur       => io_value_cursor
      , i_lov_id        => l_lov_id
    );
end;

procedure get_inst_by_param_n(
    i_param_name        in      com_api_type_pkg.t_name
  , o_inst_id              out  com_api_type_pkg.t_boolean_tab
) is
    l_id             com_api_type_pkg.t_short_id;
    l_default_value  com_api_type_pkg.t_name;
    l_system_value   com_api_type_pkg.t_name;
    l_param_name     com_api_type_pkg.t_name;
begin
    l_param_name := upper(i_param_name);

    begin
        select id, default_value
          into l_id, l_default_value
          from set_parameter
         where name         = l_param_name
           and lowest_level = set_ui_value_pkg.INST_LEVEL;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error      => 'PARAM_NOT_EXISTS'
              , i_env_param1 => l_param_name
            );
    end;

    for rec in (select param_value
                  from set_parameter_value v
                 where v.param_id    = l_id
                   and v.param_level = set_ui_value_pkg.SYST_LEVEL)
    loop
        l_system_value := rec.param_value;
    end loop;

    for rec in (select i.id as inst_id
                     , to_number(coalesce(v.param_value, l_system_value, l_default_value), com_api_const_pkg.NUMBER_FORMAT) as cbs_settlment_flag
                  from ost_institution i
                  left outer join set_parameter_value v
                    on i.id          = v.level_value
                   and v.param_id    = l_id
                   and v.param_level = set_ui_value_pkg.INST_LEVEL)
    loop
        o_inst_id(rec.inst_id) := rec.cbs_settlment_flag;
    end loop;

end get_inst_by_param_n;

begin
    -- get oracle user
    g_oracle_user := user;
end;
/
