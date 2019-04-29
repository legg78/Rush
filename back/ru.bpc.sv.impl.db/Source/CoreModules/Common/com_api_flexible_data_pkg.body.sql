create or replace package body com_api_flexible_data_pkg as

g_usage  com_api_type_pkg.t_number_by_name_tab;

procedure set_flexible_value(
    i_field_name        in      com_api_type_pkg.t_name
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_data_type         in      com_api_type_pkg.t_dict_value
  , i_seq_number        in      com_api_type_pkg.t_tiny_id      default 1
  , i_field_value_c     in      varchar2                        default null
  , i_field_value_n     in      number                          default null
  , i_field_value_d     in      date                            default null
) is
    l_field                     com_api_type_pkg.t_flexible_field;
    l_data_type                 com_api_type_pkg.t_oracle_name;
    l_field_value               com_api_type_pkg.t_name;
    l_param_tab                 com_api_type_pkg.t_param_tab;
begin
    l_field :=
        get_flexible_field(
            i_field_name   => i_field_name
          , i_entity_type  => i_entity_type
        );

    l_data_type :=
        case
            when i_field_value_c is not null  then com_api_const_pkg.DATA_TYPE_CHAR
            when i_field_value_n is not null  then com_api_const_pkg.DATA_TYPE_NUMBER
            when i_field_value_d is not null  then com_api_const_pkg.DATA_TYPE_DATE
        end;

    if l_field.data_type != l_data_type then
        com_api_error_pkg.raise_error(
            i_error         => 'INCORRECT_FLEXIBLE_FIELD_DATA_TYPE'
          , i_env_param1    => upper(i_field_name)
          , i_env_param2    => l_data_type
          , i_env_param3    => l_field.data_type
        );
    end if;

    l_field_value :=
        case l_field.data_type
            when com_api_const_pkg.DATA_TYPE_CHAR    then i_field_value_c
            when com_api_const_pkg.DATA_TYPE_NUMBER  then to_char(i_field_value_n, l_field.data_format)
            when com_api_const_pkg.DATA_TYPE_DATE    then to_char(i_field_value_d, l_field.data_format)
        end;

    merge into com_flexible_data a
    using (select l_field.id    as field_id
                , i_object_id   as object_id
                , i_seq_number  as seq_number
                , l_field_value as field_value
             from dual
          ) b
       on (a.field_id = b.field_id and a.object_id = b.object_id and a.seq_number = b.seq_number)
     when matched then
          update set a.field_value = b.field_value
     when not matched then
        insert (
            id
          , field_id
          , seq_number
          , object_id
          , field_value
        ) values (
            com_flexible_data_seq.nextval
          , b.field_id
          , b.seq_number
          , b.object_id
          , b.field_value
        );

    if i_entity_type in (prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
                       , com_api_const_pkg.ENTITY_TYPE_PERSON
                       , com_api_const_pkg.ENTITY_TYPE_COMPANY)
    then
        for rec in (
            select c.id customer_id
                 , c.inst_id
                 , c.split_hash
              from prd_customer c
             where i_entity_type = prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
               and c.id          = i_object_id
             union
            select c.id customer_id
                 , c.inst_id
                 , c.split_hash
              from prd_customer c
                 , com_person p
             where c.entity_type = i_entity_type
               and i_entity_type = com_api_const_pkg.ENTITY_TYPE_PERSON
               and c.object_id   = i_object_id
               and p.id          = c.object_id
             union
            select c.id customer_id
                 , c.inst_id
                 , c.split_hash
              from prd_customer c
                 , com_company x
             where c.entity_type = i_entity_type
               and i_entity_type = com_api_const_pkg.ENTITY_TYPE_COMPANY
               and c.object_id   = i_object_id
               and x.id          = c.object_id
        ) loop
            evt_api_event_pkg.register_event(
                i_event_type      => prd_api_const_pkg.EVENT_CUSTOMER_MODIFY
              , i_eff_date        => get_sysdate
              , i_entity_type     => prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
              , i_object_id       => rec.customer_id
              , i_inst_id         => rec.inst_id
              , i_split_hash      => rec.split_hash
              , i_param_tab       => l_param_tab
            );
        end loop;
    end if;
end set_flexible_value;

procedure set_flexible_value(
    i_field_name        in      com_api_type_pkg.t_name
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_seq_number        in      com_api_type_pkg.t_tiny_id          default 1
  , i_field_value       in      varchar2
) is
begin
    set_flexible_value(
        i_field_name        => i_field_name
      , i_entity_type       => i_entity_type
      , i_object_id         => i_object_id
      , i_data_type         => com_api_const_pkg.DATA_TYPE_CHAR
      , i_seq_number        => i_seq_number
      , i_field_value_c     => i_field_value
    );
end;

procedure set_flexible_value(
    i_field_name        in      com_api_type_pkg.t_name
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_seq_number        in      com_api_type_pkg.t_tiny_id          default 1
  , i_field_value       in      number
) is
begin
    set_flexible_value(
        i_field_name        => i_field_name
      , i_entity_type       => i_entity_type
      , i_object_id         => i_object_id
      , i_data_type         => com_api_const_pkg.DATA_TYPE_NUMBER
      , i_seq_number        => i_seq_number
      , i_field_value_n     => i_field_value
    );
end;

procedure set_flexible_value(
    i_field_name        in      com_api_type_pkg.t_name
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_seq_number        in      com_api_type_pkg.t_tiny_id          default 1
  , i_field_value       in      date
) is
begin
    set_flexible_value(
        i_field_name        => i_field_name
      , i_entity_type       => i_entity_type
      , i_object_id         => i_object_id
      , i_data_type         => com_api_const_pkg.DATA_TYPE_DATE
      , i_seq_number        => i_seq_number
      , i_field_value_d     => i_field_value
    );
end;

function get_flexible_value(
    i_field_name        in      com_api_type_pkg.t_name
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_name
is
    l_result                    com_api_type_pkg.t_name;
begin
    if i_field_name is not null and i_entity_type is not null and i_object_id is not null then
        select min(nvl(d.field_value, f.default_value))
          into l_result
          from com_flexible_field f
             , com_flexible_data d
         where d.field_id(+)  = f.id
           and d.object_id(+) = i_object_id
           and f.name         = upper(i_field_name)
           and f.entity_type  = i_entity_type;
    end if;

    return l_result;
end;

procedure get_flexible_value(
    i_field_name        in      com_api_type_pkg.t_name
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , o_data_format          out  com_api_type_pkg.t_name
  , o_field_value          out  com_api_type_pkg.t_name
) is
begin
    if i_field_name is not null and i_entity_type is not null and i_object_id is not null then
        select min(nvl(d.field_value, f.default_value))
             , min(f.data_format)
          into o_field_value
             , o_data_format
          from com_flexible_field f
             , com_flexible_data d
         where d.field_id(+)  = f.id
           and d.object_id(+) = i_object_id
           and f.name         = upper(i_field_name)
           and f.entity_type  = i_entity_type;
    end if;
end get_flexible_value;

function get_flexible_value_number(
    i_field_name        in      com_api_type_pkg.t_name
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
) return number
is
    l_field_value               com_api_type_pkg.t_name;
    l_data_format               com_api_type_pkg.t_name;
begin
    get_flexible_value(
        i_field_name     => i_field_name
      , i_entity_type    => i_entity_type
      , i_object_id      => i_object_id
      , o_data_format    => l_data_format
      , o_field_value    => l_field_value
    );
    return to_number(l_field_value, nvl(l_data_format, com_api_const_pkg.NUMBER_FORMAT));
exception
    when com_api_error_pkg.e_invalid_number or com_api_error_pkg.e_value_error then
        com_api_error_pkg.raise_error(
            i_error      => 'FLEXIBLE_FIELD_VALUE_OF_WRONG_DATA_TYPE'
          , i_env_param1 => i_field_name
          , i_env_param2 => i_entity_type
          , i_env_param3 => i_object_id
          , i_env_param4 => nvl(l_data_format, com_api_const_pkg.NUMBER_FORMAT)
          , i_env_param5 => l_field_value
        );
end get_flexible_value_number;

function get_flexible_value_date(
    i_field_name        in      com_api_type_pkg.t_name
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
) return date
is
    l_field_value               com_api_type_pkg.t_name;
    l_data_format               com_api_type_pkg.t_name;
begin
    get_flexible_value(
        i_field_name     => i_field_name
      , i_entity_type    => i_entity_type
      , i_object_id      => i_object_id
      , o_data_format    => l_data_format
      , o_field_value    => l_field_value
    );
    return to_date(l_field_value, nvl(l_data_format, com_api_const_pkg.DATE_FORMAT));
exception
    -- No one application-level exception (e_applicaition_error) is possible here,
    -- handling of the few exceptions that may be raised due to an incorrect date
    when others then
        com_api_error_pkg.raise_error(
            i_error      => 'FLEXIBLE_FIELD_VALUE_OF_WRONG_DATA_TYPE'
          , i_env_param1 => i_field_name
          , i_env_param2 => i_entity_type
          , i_env_param3 => i_object_id
          , i_env_param4 => nvl(l_data_format, com_api_const_pkg.DATE_FORMAT)
          , i_env_param5 => l_field_value
        );
end get_flexible_value_date;

function get_flexible_field_label(
    i_field_name        in      com_api_type_pkg.t_name
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_lang              in      com_api_type_pkg.t_dict_value       default null
) return com_api_type_pkg.t_name
is
    l_result                    com_api_type_pkg.t_name;
begin
    select com_api_i18n_pkg.get_text(
               i_table_name  => 'COM_FLEXIBLE_FIELD'
             , i_column_name => 'LABEL'
             , i_object_id   => f.id
             , i_lang        => i_lang
           )
      into l_result
      from com_flexible_field f
     where f.name         = upper(i_field_name)
       and f.entity_type  = i_entity_type;

    return l_result;

exception
    when no_data_found then
        com_api_error_pkg.raise_error(
            i_error       => 'FLEXIBLE_FIELD_NOT_FOUND'
          , i_env_param1  => i_field_name
          , i_entity_type => i_entity_type
        );
end get_flexible_field_label;

function get_flexible_field(
    i_field_name        in      com_api_type_pkg.t_name
  , i_entity_type       in      com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_flexible_field
is
    l_result                    com_api_type_pkg.t_flexible_field;
begin
    select f.id
         , f.entity_type
         , f.object_type
         , f.name
         , f.data_type
         , f.data_format
         , f.lov_id
         , f.is_user_defined
         , f.inst_id
         , f.default_value
      into l_result.id
         , l_result.entity_type
         , l_result.object_type
         , l_result.name
         , l_result.data_type
         , l_result.data_format
         , l_result.lov_id
         , l_result.is_user_defined
         , l_result.inst_id
         , l_result.default_value
      from com_flexible_field f
     where f.name         = upper(i_field_name)
       and f.entity_type  = i_entity_type;

    return l_result;

exception
    when no_data_found then
        com_api_error_pkg.raise_error(
            i_error       => 'FLEXIBLE_FIELD_NOT_FOUND'
          , i_env_param1  => upper(i_field_name)
          , i_entity_type => i_entity_type
        );
end get_flexible_field;

procedure set_usage(
    i_usage             in      com_api_type_pkg.t_dict_value
  , i_entity_type       in      com_api_type_pkg.t_dict_value
) is
begin
    if i_usage is not null then
        g_usage(i_usage || i_entity_type) := com_api_const_pkg.TRUE;
    end if;
end set_usage;

function get_usage(
    i_usage             in      com_api_type_pkg.t_dict_value
  , i_entity_type       in      com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_boolean
is
    function get_usage(i_key  in  com_api_type_pkg.t_name) return boolean is
    begin
        return g_usage.exists(i_key) and g_usage(i_key) = com_api_const_pkg.TRUE;
    end;
begin
    return
        case
            when i_usage is not null
             and (get_usage(i_usage || i_entity_type)
                  or
                  get_usage(com_api_const_pkg.FLEXIBLE_FIELD_PROC_ALL || i_entity_type))
            then com_api_const_pkg.TRUE
            else com_api_const_pkg.FALSE
        end;
end get_usage;

function generate_xml(
    i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_standard_id       in      com_api_type_pkg.t_tiny_id
  , i_object_id         in      com_api_type_pkg.t_long_id
) return xmltype
is
    l_xml_data                  xmltype;
begin

    select xmlagg(
               xmlelement("flexible_data"
                 , xmlelement("field_name", ff.name)
                 , xmlelement("field_value"
                     , case ff.data_type
                           when com_api_const_pkg.DATA_TYPE_NUMBER then
                               to_char(
                                   to_number(
                                       fd.field_value
                                     , nvl(ff.data_format, com_api_const_pkg.NUMBER_FORMAT)
                                   )
                                 , com_api_const_pkg.XML_NUMBER_FORMAT
                               )
                           when com_api_const_pkg.DATA_TYPE_DATE   then
                               to_char(
                                   to_date(
                                       fd.field_value
                                     , nvl(ff.data_format, com_api_const_pkg.DATE_FORMAT)
                                   )
                                 , com_api_const_pkg.XML_DATE_FORMAT
                               )
                           else
                               fd.field_value
                       end
                   )
               )
           )
      into l_xml_data
      from com_flexible_data  fd
         , com_flexible_field ff
         , com_flexible_field_standard s
     where fd.object_id   = i_object_id
       and ff.id          = fd.field_id
       and ff.entity_type = i_entity_type
       and s.field_id     = ff.id
       and s.standard_id  = i_standard_id;

    return l_xml_data;

end generate_xml;

-- This method is used in CREF/DBAL processes.
procedure generate_xml(
    i_entity_type       in            com_api_type_pkg.t_dict_value
  , i_standard_id       in            com_api_type_pkg.t_tiny_id
  , i_object_id         in            com_api_type_pkg.t_long_id
  , o_xml_block            out nocopy com_api_type_pkg.t_lob_data
) is
    l_method_name                     com_api_type_pkg.t_name := 'generate_flexible_data';
    l_label_name                      com_api_type_pkg.t_name := 'xml_block';
    l_name_tab                        com_api_type_pkg.t_name_tab;
    l_data_type_tab                   com_api_type_pkg.t_dict_tab;
    l_field_value_tab                 com_api_type_pkg.t_name_tab;
    l_data_format_tab                 com_api_type_pkg.t_name_tab;
begin
    prc_api_performance_pkg.start_performance_metric(
        i_method_name => l_method_name
      , i_label_name  => l_label_name
    );

    select ff.name
         , ff.data_type
         , fd.field_value
         , ff.data_format
      bulk collect
      into l_name_tab
         , l_data_type_tab
         , l_field_value_tab
         , l_data_format_tab
      from com_flexible_data  fd
         , com_flexible_field ff
         , com_flexible_field_standard s
     where fd.object_id   = i_object_id
       and ff.id          = fd.field_id
       and ff.entity_type = i_entity_type
       and s.field_id     = ff.id
       and s.standard_id  = i_standard_id;

    for i in 1 .. l_name_tab.count loop
        o_xml_block := o_xml_block
                    || '<flexible_data>'
                    || '<field_name>' || l_name_tab(i) || '</field_name>'
                    || '<field_value>'
                    || case l_data_type_tab(i)
                           when com_api_const_pkg.DATA_TYPE_NUMBER then
                               to_char(
                                   to_number(
                                       l_field_value_tab(i)
                                     , nvl(l_data_format_tab(i), com_api_const_pkg.NUMBER_FORMAT)
                                   )
                                 , com_api_const_pkg.XML_NUMBER_FORMAT
                               )
                           when com_api_const_pkg.DATA_TYPE_DATE   then
                               to_char(
                                   to_date(
                                       l_field_value_tab(i)
                                     , nvl(l_data_format_tab(i), com_api_const_pkg.DATE_FORMAT)
                                   )
                                 , com_api_const_pkg.XML_DATE_FORMAT
                               )
                           else
                               l_field_value_tab(i)
                       end
                    || '</field_value>'
                    || '</flexible_data>';
    end loop;

    prc_api_performance_pkg.finish_performance_metric(
        i_method_name => l_method_name
      , i_label_name  => l_label_name
    );
end generate_xml;

/*
 * Return a map structure (associative array) where a flexible field name is the key and its ID is a value.
 */
function get_flexible_fields_map(
    i_entity_type       in            com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_short_map
result_cache relies_on (com_flexible_field)
is
    l_flex_fields_map                 com_api_type_pkg.t_short_map;
begin
    for r in (
        select id, name
          from com_flexible_field
         where entity_type = i_entity_type
    ) loop
        l_flex_fields_map(r.name) := r.id;
    end loop;

    return l_flex_fields_map;
end;

procedure save_data(
    io_flex_data_tab    in out nocopy com_api_type_pkg.t_flexible_data_tab
  , i_entity_type       in            com_api_type_pkg.t_dict_value
  , i_object_id         in            com_api_type_pkg.t_long_id
) is
    LOG_PREFIX               constant com_api_type_pkg.t_name     := lower($$PLSQL_UNIT) || '.save_data';
    l_flex_fields_map                 com_api_type_pkg.t_short_map;
begin
    trc_log_pkg.debug(
        i_text        => LOG_PREFIX || ' << i_entity_type [#1], i_object_id [#2]'
      , i_env_param1  => i_entity_type
      , i_env_param2  => i_object_id
    );
    l_flex_fields_map := get_flexible_fields_map(i_entity_type => i_entity_type);

    for i in 1 .. io_flex_data_tab.count() loop
        if l_flex_fields_map.exists(io_flex_data_tab(i).field_name) then
            set_flexible_value(
                i_field_name  => io_flex_data_tab(i).field_name
              , i_entity_type => i_entity_type
              , i_object_id   => i_object_id
              , i_field_value => io_flex_data_tab(i).field_value
            );
            trc_log_pkg.debug(
                i_text        => '[#1] = [#2]'
              , i_env_param1  => io_flex_data_tab(i).field_name
              , i_env_param2  => io_flex_data_tab(i).field_value
            );
        else
            com_api_error_pkg.raise_error(
                i_error       => 'FLEXIBLE_FIELD_NOT_FOUND'
              , i_env_param1  => io_flex_data_tab(i).field_name
              , i_entity_type => i_entity_type
            );
        end if;
    end loop;

    trc_log_pkg.debug(
        i_text        => LOG_PREFIX || ' >> #1 flexible field values were inserted'
      , i_env_param1  => io_flex_data_tab.count()
    );
end save_data;

end com_api_flexible_data_pkg;
/
