create or replace package body svy_api_parameter_value_pkg as

procedure set_parameter_value(
    i_param_name            in  com_api_type_pkg.t_name
  , i_entity_type           in  com_api_type_pkg.t_dict_value
  , i_questionary_id        in  com_api_type_pkg.t_long_id
  , i_seq_number            in  com_api_type_pkg.t_tiny_id
  , i_seqnum                in  com_api_type_pkg.t_tiny_id      default 1
  , i_param_value_c         in  varchar2                        default null
  , i_param_value_n         in  number                          default null
  , i_param_value_d         in  date                            default null
) is
    l_parameter_id              com_api_type_pkg.t_short_id;
    l_data_type                 com_api_type_pkg.t_oracle_name;
    l_data_type_2               com_api_type_pkg.t_oracle_name;
    l_param_value               com_api_type_pkg.t_name;
begin
    begin
        select p.id
             , p.data_type
          into l_parameter_id
             , l_data_type
          from svy_parameter p
             , svy_parameter_entity e
         where p.param_name      = upper(i_param_name)
           and p.id              = e.param_id
           and e.entity_type     = i_entity_type;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error         => 'PARAMETER_NOT_FOUND'
              , i_env_param1    => upper(i_param_name)
            );
    end;

    if i_param_value_c is not null then
        l_data_type_2 := com_api_const_pkg.DATA_TYPE_CHAR;
    elsif i_param_value_n is not null then
        l_data_type_2 := com_api_const_pkg.DATA_TYPE_NUMBER;
    elsif i_param_value_d is not null then
        l_data_type_2 := com_api_const_pkg.DATA_TYPE_DATE;
    end if;

    if l_data_type != l_data_type_2 then
        com_api_error_pkg.raise_error(
            i_error         => 'INCORRECT_PARAM_VALUE_DATA_TYPE'
        );
    end if;

    if l_data_type = com_api_const_pkg.DATA_TYPE_CHAR then
        l_param_value := i_param_value_c;
    elsif l_data_type = com_api_const_pkg.DATA_TYPE_NUMBER then
        l_param_value := to_char(i_param_value_n, com_api_const_pkg.NUMBER_FORMAT);
    elsif l_data_type = com_api_const_pkg.DATA_TYPE_DATE then
        l_param_value := to_char(i_param_value_d, com_api_const_pkg.DATE_FORMAT);
    end if;

    merge into svy_qstn_parameter_value v
    using (select i_seqnum         as seqnum
                , i_questionary_id as questionary_id
                , l_parameter_id   as param_id
                , l_param_value    as param_value
                , i_seq_number     as seq_number
             from dual) b
       on (v.param_id = b.param_id and v.questionary_id = b.questionary_id and v.seqnum = b.seqnum and v.seq_number = b.seq_number)
     when matched then
          update set v.param_value = b.param_value
     when not matched then
        insert (
            id
          , seqnum
          , questionary_id
          , param_id
          , param_value
          , seq_number
        ) values (
            svy_qstn_parameter_value_seq.nextval
          , b.seqnum
          , b.questionary_id
          , b.param_id
          , b.param_value
          , b.seq_number
        );

end set_parameter_value;

procedure set_parameter_value(
    i_param_name        in      com_api_type_pkg.t_name
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_questionary_id    in      com_api_type_pkg.t_long_id
  , i_seq_number        in      com_api_type_pkg.t_tiny_id          default null
  , i_seqnum            in      com_api_type_pkg.t_tiny_id          default 1
  , i_param_value       in      varchar2
) is
begin
    set_parameter_value(
        i_param_name        => i_param_name
      , i_entity_type       => i_entity_type
      , i_questionary_id    => i_questionary_id
      , i_seq_number        => i_seq_number
      , i_seqnum            => i_seqnum
      , i_param_value_c     => i_param_value
    );
end set_parameter_value;

procedure set_parameter_value(
    i_param_name        in      com_api_type_pkg.t_name
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_questionary_id    in      com_api_type_pkg.t_long_id
  , i_seq_number        in      com_api_type_pkg.t_tiny_id          default null
  , i_seqnum            in      com_api_type_pkg.t_tiny_id          default 1
  , i_param_value       in      number
) is
begin
    set_parameter_value(
        i_param_name        => i_param_name
      , i_entity_type       => i_entity_type
      , i_questionary_id    => i_questionary_id
      , i_seq_number        => i_seq_number
      , i_seqnum            => i_seqnum
      , i_param_value_n     => i_param_value
    );
end set_parameter_value;

procedure set_parameter_value(
    i_param_name        in      com_api_type_pkg.t_name
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_questionary_id    in      com_api_type_pkg.t_long_id
  , i_seq_number        in      com_api_type_pkg.t_tiny_id          default null
  , i_seqnum            in      com_api_type_pkg.t_tiny_id          default 1
  , i_param_value       in      date
) is
begin
    set_parameter_value(
        i_param_name        => i_param_name
      , i_entity_type       => i_entity_type
      , i_questionary_id    => i_questionary_id
      , i_seq_number        => i_seq_number
      , i_seqnum            => i_seqnum
      , i_param_value_d     => i_param_value
    );
end set_parameter_value;

function get_parameter_value(
    i_param_name           in com_api_type_pkg.t_oracle_name
  , i_is_system_param      in com_api_type_pkg.t_boolean           default com_api_const_pkg.FALSE
  , i_table_name           in com_api_type_pkg.t_attr_name         default null
  , i_questionary_id       in com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_name is
    l_param_value             com_api_type_pkg.t_name;
begin
    if i_param_name is null or i_questionary_id is null then
        return null;
    end if;

    select min(v.param_value)
      into l_param_value
      from svy_parameter p
         , svy_qstn_parameter_value v
     where v.param_id(+)       = p.id
       and v.questionary_id(+) = i_questionary_id
       and p.param_name        = upper(i_param_name)
       and p.is_system_param   = i_is_system_param
       and p.table_name        = nvl(upper(i_table_name), table_name);

    return l_param_value;
exception
    when no_data_found then
        return null;
end get_parameter_value;

end svy_api_parameter_value_pkg;
/
