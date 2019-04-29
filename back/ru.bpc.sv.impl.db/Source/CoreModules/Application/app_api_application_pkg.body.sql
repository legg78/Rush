create or replace package body app_api_application_pkg as
/*********************************************************
*  API for application <br />
*  Created by Filimonov A.(filimonov@bpc.ru)  at 09.09.2009 <br />
*  Module: app_api_application_pkg <br />
*  @headcom
**********************************************************/

g_appl_id                  com_api_type_pkg.t_long_id;
g_appl_flow_id             com_api_type_pkg.t_tiny_id;
g_last_appl_data_rec       app_api_type_pkg.t_appl_data_rec; -- is used to provide information for logging

-- It's the tag values of the current application by the parent id, serial number and element name.
type t_app_element_rec is record (
    appl_data_id           com_api_type_pkg.t_long_id
  , element_id             com_api_type_pkg.t_short_id
  , lang                   com_api_type_pkg.t_dict_value
  , data_type              com_api_type_pkg.t_dict_value
  , element_type           com_api_type_pkg.t_dict_value
  , element_value          com_api_type_pkg.t_full_desc
);
type t_app_element_tab     is table of t_app_element_rec index by com_api_type_pkg.t_name;
g_app_element_tab          t_app_element_tab;

-- It's the "serial number" list of the current application by the parent id and element name.
type t_serial_number_arr   is table of com_api_type_pkg.t_tiny_id  index by pls_integer;
type t_serial_number_tab   is table of t_serial_number_arr         index by com_api_type_pkg.t_name;
g_serial_number_tab        t_serial_number_tab;

-- It's the array with the index keys by id.
type t_index_by_id_tab     is table of com_api_type_pkg.t_full_desc index by com_api_type_pkg.t_name;
g_index_by_id_tab          t_index_by_id_tab;

-- Get index key of Cache table with application tags for current application.
function get_appl_data_index(
    i_parent_id            in            com_api_type_pkg.t_long_id
  , i_serial_number        in            com_api_type_pkg.t_tiny_id
  , i_element_name         in            com_api_type_pkg.t_name
) return com_api_type_pkg.t_name is
    l_index                              com_api_type_pkg.t_name;
begin
    l_index := to_char(i_parent_id)||'.'||to_char(i_serial_number)||'.'||upper(i_element_name);
    return l_index;
end get_appl_data_index;

-- Get index key of the "serial number" Cache table for current application.
function get_list_index(
    i_parent_id            in            com_api_type_pkg.t_long_id
  , i_element_name         in            com_api_type_pkg.t_name
) return com_api_type_pkg.t_name is
    l_index                              com_api_type_pkg.t_name;
begin
    l_index := to_char(i_parent_id)||'.'||upper(i_element_name);
    return l_index;
end get_list_index;

-- Get the "serial number" array for the parent element and the selected element name.
procedure get_serial_number_array(
    i_parent_id            in            com_api_type_pkg.t_long_id
  , i_element_name         in            com_api_type_pkg.t_name
  , o_serial_number_tab   out            com_api_type_pkg.t_long_tab
) is
    l_list_index          com_api_type_pkg.t_name;
begin
    l_list_index := get_list_index(
        i_parent_id      => i_parent_id
      , i_element_name   => i_element_name
    );

    if g_serial_number_tab.exists(l_list_index) then
        for i in 1 .. g_serial_number_tab(l_list_index).count loop
            o_serial_number_tab(i) := g_serial_number_tab(l_list_index)(i);
        end loop;
    end if;
end get_serial_number_array;

-- Add elemenet into Cache table with application tags for current application.
procedure add_element_to_cache(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_element_id           in            com_api_type_pkg.t_short_id
  , i_parent_id            in            com_api_type_pkg.t_long_id
  , i_serial_number        in            com_api_type_pkg.t_tiny_id
  , i_element_value        in            com_api_type_pkg.t_full_desc
  , i_lang                 in            com_api_type_pkg.t_dict_value
  , i_element_name         in            com_api_type_pkg.t_name
  , i_data_type            in            com_api_type_pkg.t_dict_value
  , i_element_type         in            com_api_type_pkg.t_dict_value
) is
    l_index_key                          com_api_type_pkg.t_name;
    l_counter_index                      com_api_type_pkg.t_name;
begin
    -- Get index key of current element of current application.
    l_index_key := get_appl_data_index(
        i_parent_id      => i_parent_id
      , i_serial_number  => i_serial_number
      , i_element_name   => i_element_name
    );

    -- Save index key by id in the special array.
    g_index_by_id_tab(to_char(i_appl_data_id)) := l_index_key;

    -- Update counter of elements for the parent element and the current element name.
    l_counter_index := get_list_index(
        i_parent_id      => i_parent_id
      , i_element_name   => i_element_name
    );

    if g_serial_number_tab.exists(l_counter_index) then
        g_serial_number_tab(l_counter_index)(g_serial_number_tab(l_counter_index).count + 1) := i_serial_number;
    else
        g_serial_number_tab(l_counter_index)(1) := i_serial_number;
    end if;

    -- Fill Cache table with data of the current application.
    g_app_element_tab(l_index_key).appl_data_id      := i_appl_data_id;
    g_app_element_tab(l_index_key).element_id        := i_element_id;
    g_app_element_tab(l_index_key).lang              := i_lang;
    g_app_element_tab(l_index_key).data_type         := i_data_type;
    g_app_element_tab(l_index_key).element_type      := i_element_type;

    if g_app_element_tab(l_index_key).element_id = app_api_const_pkg.ELEMENT_CARDHOLDER_NAME and i_element_value = ' ' then
        g_app_element_tab(l_index_key).element_value     := i_element_value;        -- make without trim for Cardholder name equal " "
    else
        g_app_element_tab(l_index_key).element_value     := trim(i_element_value);  -- make trim for all char values
    end if;
    if upper(i_element_name) like '%CARD_NUMBER' then
        g_app_element_tab(l_index_key).element_value := iss_api_token_pkg.decode_card_number(i_card_number => g_app_element_tab(l_index_key).element_value);
    end if;

end add_element_to_cache;

function get_appl_data_rec(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_element_id           in            com_api_type_pkg.t_short_id
  , i_parent_id            in            com_api_type_pkg.t_long_id
  , i_serial_number        in            com_api_type_pkg.t_tiny_id
  , i_element_value        in            com_api_type_pkg.t_full_desc
  , i_lang                 in            com_api_type_pkg.t_dict_value
  , i_element_name         in            com_api_type_pkg.t_name
  , i_data_type            in            com_api_type_pkg.t_dict_value
  , i_element_type         in            com_api_type_pkg.t_dict_value
) return app_api_type_pkg.t_appl_data_rec is
    l_appl_data_rec                      app_api_type_pkg.t_appl_data_rec;
begin
    l_appl_data_rec.appl_data_id   := i_appl_data_id;
    l_appl_data_rec.element_id     := i_element_id;
    l_appl_data_rec.parent_id      := i_parent_id;
    l_appl_data_rec.serial_number  := i_serial_number;
    l_appl_data_rec.element_value  := i_element_value;
    l_appl_data_rec.lang           := i_lang;
    l_appl_data_rec.element_name   := i_element_name;
    l_appl_data_rec.data_type      := i_data_type;
    l_appl_data_rec.element_type   := i_element_type;

    return l_appl_data_rec;
end get_appl_data_rec;

procedure parse_index_key(
    i_index_key            in            com_api_type_pkg.t_name
  , o_parent_id           out            com_api_type_pkg.t_long_id
  , o_serial_number       out            com_api_type_pkg.t_tiny_id
  , o_element_name        out            com_api_type_pkg.t_name
) is
begin
    o_parent_id     := substr(i_index_key, 1, instr(i_index_key, '.') - 1);
    o_serial_number := substr(i_index_key, instr(i_index_key, '.') + 1, instr(i_index_key, '.', -1) - instr(i_index_key, '.') - 1);
    o_element_name  := substr(i_index_key, instr(i_index_key, '.', -1) + 1);
end ;

-- Get value of the "Agent_id" parameter.
function get_app_agent_id return com_api_type_pkg.t_short_id is
    l_agent_id             com_api_type_pkg.t_short_id;
begin
    l_agent_id := rul_api_param_pkg.get_param_num(
        i_name    => 'AGENT_ID'
      , io_params => g_params
    );
    return l_agent_id;
end;

-- Get type of the current application.
function get_appl_type return com_api_type_pkg.t_dict_value is
    l_root_id              com_api_type_pkg.t_long_id;
    l_appl_type            com_api_type_pkg.t_dict_value;
begin
    get_appl_data_id(
        i_element_name   => 'APPLICATION'
      , i_parent_id      => null
      , o_appl_data_id   => l_root_id
    );
    get_element_value(
        i_element_name   => 'APPLICATION_TYPE'
      , i_parent_id      => l_root_id
      , o_element_value  => l_appl_type
    );

    return l_appl_type;
end;

-- Get the application data id of the "Customer" tag for current tag and parent_id
function get_customer_appl_data_id(
    i_element_name         in            com_api_type_pkg.t_name             default null
  , i_parent_id            in            com_api_type_pkg.t_long_id          default null
) return com_api_type_pkg.t_long_id is
    l_root_id              com_api_type_pkg.t_long_id;
    l_customer_data_id     com_api_type_pkg.t_long_id;
begin
    get_appl_data_id(
        i_element_name   => nvl(i_element_name,'APPLICATION')
      , i_parent_id      => i_parent_id
      , o_appl_data_id   => l_root_id
    );
    get_appl_data_id(
        i_element_name   => 'CUSTOMER'
      , i_parent_id      => l_root_id
      , o_appl_data_id   => l_customer_data_id
    );

    return l_customer_data_id;
end;

function get_prioritized_flag return com_api_type_pkg.t_boolean is
    l_root_id              com_api_type_pkg.t_long_id;
    l_prioritized_flag     com_api_type_pkg.t_boolean;
begin
    get_appl_data_id(
        i_element_name   => 'APPLICATION'
      , i_parent_id      => null
      , o_appl_data_id   => l_root_id
    );

    get_element_value(
        i_element_name   => 'APPL_PRIORITIZED'
      , i_parent_id      => l_root_id
      , o_element_value  => l_prioritized_flag
    );

    return l_prioritized_flag;
end;

-- Get application description.
function get_appl_description(
    i_appl_id              in            com_api_type_pkg.t_long_id
  , i_flow_id              in            com_api_type_pkg.t_tiny_id
  , i_lang                 in            com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_full_desc is
    l_desc_tab             com_api_type_pkg.t_desc_tab;
    l_description          com_api_type_pkg.t_full_desc;
begin
    l_description :=
        cst_api_application_pkg.get_appl_description(
            i_appl_id  => i_appl_id
          , i_flow_id  => i_flow_id
          , i_lang     => i_lang
        );

    if l_description is null then

        select d.element_value
          bulk collect into l_desc_tab
          from app_data d
         where d.appl_id     = i_appl_id
           and d.element_id+0 in (app_api_const_pkg.ELEMENT_CUSTOMER_NUMBER
                                , app_api_const_pkg.ELEMENT_CONTRACT_NUMBER
                                , app_api_const_pkg.ELEMENT_COMPANY_NAME
                                , app_api_const_pkg.ELEMENT_PERSON_NAME
                                , app_api_const_pkg.ELEMENT_USER_NAME)
         order by decode(d.element_id, app_api_const_pkg.ELEMENT_CUSTOMER_NUMBER, 1
                                     , app_api_const_pkg.ELEMENT_CONTRACT_NUMBER, 2
                                     , app_api_const_pkg.ELEMENT_COMPANY_NAME,    3
                                     , app_api_const_pkg.ELEMENT_PERSON_NAME,     4
                                     , app_api_const_pkg.ELEMENT_USER_NAME,       5);

        if l_desc_tab.count > 0 then
            -- It is instead of function "listagg" for decrease CPU load.
            for i in 1 .. l_desc_tab.count loop
                if l_description is not null then
                    l_description := l_description || ' | ';
                end if;
                l_description := l_description || l_desc_tab(i);
            end loop;
        end if;

    end if;

    return l_description;

exception
    when others then
        trc_log_pkg.debug (
            i_text          => 'i_appl_id [' || i_appl_id || '], i_flow_id [' || i_flow_id || '], i_lang [' || i_lang || ']'
        );

        com_api_error_pkg.raise_fatal_error(
            i_error       => 'UNHANDLED_EXCEPTION'
          , i_env_param1  => sqlerrm
        );
end;


-- It generates and returns a new ID for inserting into APP_DATA.
function get_appl_data_id(
    i_appl_id              in            com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_long_id
is
begin
    return com_api_id_pkg.get_id(
               i_seq  => app_data_seq.nextval
             , i_date => to_date(substr(to_char(i_appl_id), 1, 6), 'yymmdd')
           );
end;

-- Get element data by the "parent_id", "serial_number", "element_name" values of current application.
procedure get_element_data(
    i_parent_id            in            com_api_type_pkg.t_long_id
  , i_serial_number        in            com_api_type_pkg.t_tiny_id
  , i_element_name         in            com_api_type_pkg.t_name
  , i_data_type            in            com_api_type_pkg.t_dict_value
  , o_element_value_v         out nocopy com_api_type_pkg.t_full_desc
  , o_element_value_n         out nocopy number
  , o_element_value_d         out nocopy date
  , o_lang                    out nocopy com_api_type_pkg.t_dict_value
  , o_appl_data_id            out nocopy com_api_type_pkg.t_long_id
) is
    l_index                              com_api_type_pkg.t_name;
    l_curr_element_value                 com_api_type_pkg.t_full_desc;
begin
    --trc_log_pkg.debug('app_api_application_pkg.get_element_data, i_element_name="'||i_element_name||'", i_data_type="'||i_data_type||'"');

    l_index := get_appl_data_index(
        i_parent_id      => i_parent_id
      , i_serial_number  => i_serial_number
      , i_element_name   => i_element_name
    );

    begin
        o_appl_data_id := g_app_element_tab(l_index).appl_data_id;

        -- Save last tag's info for logging when error is encountered.
        g_last_appl_data_rec := get_appl_data_rec(
            i_appl_data_id         => g_app_element_tab(l_index).appl_data_id
          , i_element_id           => g_app_element_tab(l_index).element_id
          , i_parent_id            => i_parent_id
          , i_serial_number        => i_serial_number
          , i_element_value        => g_app_element_tab(l_index).element_value
          , i_lang                 => g_app_element_tab(l_index).lang
          , i_element_name         => i_element_name
          , i_data_type            => g_app_element_tab(l_index).data_type
          , i_element_type         => g_app_element_tab(l_index).element_type
        );

        if i_data_type is not null and g_app_element_tab(l_index).data_type != i_data_type then
            com_api_error_pkg.raise_error(
                i_error         => 'INCORRECT_ELEMENT_DATA_TYPE'
              , i_env_param1    => upper(i_element_name)
              , i_env_param2    => i_data_type
              , i_env_param3    => g_app_element_tab(l_index).data_type
            );
        end if;

        l_curr_element_value  := g_app_element_tab(l_index).element_value;

        if g_app_element_tab(l_index).data_type    = com_api_const_pkg.DATA_TYPE_CHAR then
            o_element_value_v := l_curr_element_value;
            o_lang            := g_app_element_tab(l_index).lang;

        elsif g_app_element_tab(l_index).data_type = com_api_const_pkg.DATA_TYPE_NUMBER then
            o_element_value_n := to_number(l_curr_element_value, com_api_const_pkg.NUMBER_FORMAT);

        elsif g_app_element_tab(l_index).data_type = com_api_const_pkg.DATA_TYPE_DATE then
            o_element_value_d := to_date(l_curr_element_value, com_api_const_pkg.DATE_FORMAT);

        elsif g_app_element_tab(l_index).data_type is null then
            o_lang            := g_app_element_tab(l_index).lang;

        end if;

    exception when no_data_found then
        -- Application does not contain this element.
        null;

    end;

exception
    when com_api_error_pkg.e_value_error or com_api_error_pkg.e_invalid_number then
        app_api_error_pkg.raise_error(
            i_appl_data_id => o_appl_data_id
          , i_error        => 'INCORRECT_ELEMENT_VALUE'
          , i_env_param1   => l_curr_element_value
          , i_env_param2   => i_element_name
          , i_env_param3   => i_data_type
          , i_env_param4   => i_parent_id
          , i_element_name => i_element_name
          , i_parent_id    => i_parent_id
        );
    when com_api_error_pkg.e_application_error or com_api_error_pkg.e_fatal_error then
        trc_log_pkg.debug(
            i_text       => lower($$PLSQL_UNIT) || '.get_element_data FAILED: i_element_name [#1], i_parent_id [#2], '
                                                || 'l_curr_appl_data_id [#3], i_data_type [#4], io_serial_number [#5]'
          , i_env_param1 => i_element_name
          , i_env_param2 => i_parent_id
          , i_env_param3 => o_appl_data_id
          , i_env_param4 => i_data_type
          , i_env_param5 => i_serial_number
        );
        raise;
    when others then
        com_api_error_pkg.raise_fatal_error(
            i_error       => 'UNHANDLED_EXCEPTION'
          , i_env_param1  => sqlerrm
        );
end get_element_data;

procedure get_element_value(
    i_element_name         in            com_api_type_pkg.t_name
  , i_parent_id            in            com_api_type_pkg.t_long_id
  , i_serial_number        in            com_api_type_pkg.t_tiny_id          default 1
  , i_current_value        in            com_api_type_pkg.t_full_desc        default null
  , o_element_value           out nocopy com_api_type_pkg.t_full_desc
) is
    l_data_type            com_api_type_pkg.t_dict_value := com_api_const_pkg.DATA_TYPE_CHAR;
    l_element_value_n      number;
    l_element_value_d      date;
    l_lang                 com_api_type_pkg.t_dict_value;
    l_appl_data_id         com_api_type_pkg.t_long_id;
begin
    --trc_log_pkg.debug('get_element_value(1): start');

    get_element_data(
        i_parent_id             => i_parent_id
      , i_serial_number         => i_serial_number
      , i_element_name          => i_element_name
      , i_data_type             => l_data_type
      , o_element_value_v       => o_element_value
      , o_element_value_n       => l_element_value_n
      , o_element_value_d       => l_element_value_d
      , o_lang                  => l_lang
      , o_appl_data_id          => l_appl_data_id
    );
    -- save the current value if application doesn't have the element
    if i_current_value is not null and l_appl_data_id is null then
        o_element_value := i_current_value;
    end if;
exception
    when com_api_error_pkg.e_value_error or com_api_error_pkg.e_invalid_number then
        app_api_error_pkg.raise_error(
            i_appl_data_id => l_appl_data_id
          , i_error        => 'INCORRECT_ELEMENT_VALUE'
          , i_env_param1   => o_element_value
          , i_env_param2   => i_element_name
          , i_env_param3   => l_data_type
          , i_env_param4   => i_parent_id
          , i_element_name => i_element_name
          , i_parent_id    => i_parent_id
        );
end get_element_value;

function get_element_value_v(
    i_element_name            in            com_api_type_pkg.t_name
  , i_parent_id               in            com_api_type_pkg.t_long_id
  , i_serial_number           in            com_api_type_pkg.t_tiny_id       default 1
) return com_api_type_pkg.t_full_desc
is
    l_result    com_api_type_pkg.t_full_desc;
begin

    get_element_value(
        i_element_name          => i_element_name
      , i_parent_id             => i_parent_id
      , i_serial_number         => i_serial_number
      , o_element_value         => l_result
    );

    return l_result;
exception
    when others then
        raise;
end get_element_value_v;

procedure get_element_value(
    i_element_name         in            com_api_type_pkg.t_name
  , i_parent_id            in            com_api_type_pkg.t_long_id
  , i_serial_number        in            com_api_type_pkg.t_tiny_id          default 1
  , i_current_value        in            com_api_type_pkg.t_multilang_desc   default null
  , o_element_value           out nocopy com_api_type_pkg.t_multilang_desc
) is
    l_data_type            com_api_type_pkg.t_dict_value := com_api_const_pkg.DATA_TYPE_CHAR;
    l_element_value_n      number;
    l_element_value_d      date;
    l_appl_data_id         com_api_type_pkg.t_long_id;
begin
    --trc_log_pkg.debug('get_element_value(2): start');

    get_element_data(
        i_parent_id             => i_parent_id
      , i_serial_number         => i_serial_number
      , i_element_name          => i_element_name
      , i_data_type             => l_data_type
      , o_element_value_v       => o_element_value.value
      , o_element_value_n       => l_element_value_n
      , o_element_value_d       => l_element_value_d
      , o_lang                  => o_element_value.lang
      , o_appl_data_id          => l_appl_data_id
    );
    -- save the current value if application doesn't have the element
    if i_current_value.value is not null and l_appl_data_id is null then
        o_element_value := i_current_value;
    end if;
exception
    when com_api_error_pkg.e_value_error or com_api_error_pkg.e_invalid_number then
        app_api_error_pkg.raise_error(
            i_appl_data_id => l_appl_data_id
          , i_error        => 'INCORRECT_ELEMENT_VALUE'
          , i_env_param1   => o_element_value.value
          , i_env_param2   => i_element_name
          , i_env_param3   => l_data_type
          , i_env_param4   => i_parent_id
          , i_element_name => i_element_name
          , i_parent_id    => i_parent_id
        );
end get_element_value;

procedure get_element_value(
    i_element_name         in            com_api_type_pkg.t_name
  , i_parent_id            in            com_api_type_pkg.t_long_id
  , i_serial_number        in            com_api_type_pkg.t_tiny_id          default 1
  , i_current_value        in            number                              default null
  , o_element_value           out nocopy number
) is
    l_data_type            com_api_type_pkg.t_dict_value := com_api_const_pkg.DATA_TYPE_NUMBER;
    l_element_value_v      com_api_type_pkg.t_full_desc;
    l_element_value_d      date;
    l_lang                 com_api_type_pkg.t_dict_value;
    l_appl_data_id         com_api_type_pkg.t_long_id;
begin
    --trc_log_pkg.debug('get_element_value(3): start');

    get_element_data(
        i_parent_id             => i_parent_id
      , i_serial_number         => i_serial_number
      , i_element_name          => i_element_name
      , i_data_type             => l_data_type
      , o_element_value_v       => l_element_value_v
      , o_element_value_n       => o_element_value
      , o_element_value_d       => l_element_value_d
      , o_lang                  => l_lang
      , o_appl_data_id          => l_appl_data_id
    );
    -- save the current value if application doesn't have the element
    if i_current_value is not null and l_appl_data_id is null then
        o_element_value := i_current_value;
    end if;
exception
    when com_api_error_pkg.e_value_error or com_api_error_pkg.e_invalid_number then
        app_api_error_pkg.raise_error(
            i_appl_data_id => l_appl_data_id
          , i_error        => 'INCORRECT_ELEMENT_VALUE'
          , i_env_param1   => o_element_value
          , i_env_param2   => i_element_name
          , i_env_param3   => l_data_type
          , i_env_param4   => i_parent_id
          , i_element_name => i_element_name
          , i_parent_id    => i_parent_id
        );
end get_element_value;

function get_element_value_n(
    i_element_name            in            com_api_type_pkg.t_name
  , i_parent_id               in            com_api_type_pkg.t_long_id
  , i_serial_number           in            com_api_type_pkg.t_tiny_id       default 1
) return number
is
    l_result    number;
begin

    get_element_value(
        i_element_name          => i_element_name
      , i_parent_id             => i_parent_id
      , i_serial_number         => i_serial_number
      , o_element_value         => l_result
    );

    return l_result;
exception
    when others then
        raise;
end get_element_value_n;

procedure get_element_value(
    i_element_name         in            com_api_type_pkg.t_name
  , i_parent_id            in            com_api_type_pkg.t_long_id
  , i_serial_number        in            com_api_type_pkg.t_tiny_id          default 1
  , i_current_value        in            date                                default null
  , o_element_value           out nocopy date
) is
    l_data_type            com_api_type_pkg.t_dict_value := com_api_const_pkg.DATA_TYPE_DATE;
    l_element_value_v      com_api_type_pkg.t_full_desc;
    l_element_value_n      number;
    l_lang                 com_api_type_pkg.t_dict_value;
    l_appl_data_id         com_api_type_pkg.t_long_id;
begin
    --trc_log_pkg.debug('get_element_value(4): start');

    get_element_data(
        i_parent_id             => i_parent_id
      , i_serial_number         => i_serial_number
      , i_element_name          => i_element_name
      , i_data_type             => l_data_type
      , o_element_value_v       => l_element_value_v
      , o_element_value_n       => l_element_value_n
      , o_element_value_d       => o_element_value
      , o_lang                  => l_lang
      , o_appl_data_id          => l_appl_data_id
    );
    -- save the current value if application doesn't have the element
    if i_current_value is not null and l_appl_data_id is null then
        o_element_value := i_current_value;
    end if;
exception
    when com_api_error_pkg.e_value_error or com_api_error_pkg.e_invalid_number then
        app_api_error_pkg.raise_error(
            i_appl_data_id => l_appl_data_id
          , i_error        => 'INCORRECT_ELEMENT_VALUE'
          , i_env_param1   => to_char(o_element_value, com_api_const_pkg.LOG_DATE_FORMAT)
          , i_env_param2   => i_element_name
          , i_env_param3   => l_data_type
          , i_env_param4   => i_parent_id
          , i_element_name => i_element_name
          , i_parent_id    => i_parent_id
        );
end get_element_value;

function get_element_value_d(
    i_element_name            in            com_api_type_pkg.t_name
  , i_parent_id               in            com_api_type_pkg.t_long_id
  , i_serial_number           in            com_api_type_pkg.t_tiny_id       default 1
) return date
is
    l_result    date;
begin

    get_element_value(
        i_element_name          => i_element_name
      , i_parent_id             => i_parent_id
      , i_serial_number         => i_serial_number
      , o_element_value         => l_result
    );

    return l_result;
exception
    when others then
        raise;
end get_element_value_d;

procedure get_element_value(
    i_element_name         in            com_api_type_pkg.t_name
  , i_parent_id            in            com_api_type_pkg.t_long_id
  , o_element_value           out nocopy com_api_type_pkg.t_desc_tab
) is
    l_data_type            com_api_type_pkg.t_dict_value := com_api_const_pkg.DATA_TYPE_CHAR;
    l_element_value_n      number;
    l_element_value_d      date;
    l_lang                 com_api_type_pkg.t_dict_value;
    l_appl_data_id         com_api_type_pkg.t_long_id;
    l_serial_number_tab    com_api_type_pkg.t_long_tab;
begin
    get_serial_number_array(
        i_parent_id         => i_parent_id
      , i_element_name      => i_element_name
      , o_serial_number_tab => l_serial_number_tab
    );

    for i in 1 .. l_serial_number_tab.count loop
        get_element_data(
            i_parent_id             => i_parent_id
          , i_serial_number         => l_serial_number_tab(i)
          , i_element_name          => i_element_name
          , i_data_type             => l_data_type
          , o_element_value_v       => o_element_value(i)
          , o_element_value_n       => l_element_value_n
          , o_element_value_d       => l_element_value_d
          , o_lang                  => l_lang
          , o_appl_data_id          => l_appl_data_id
        );
    end loop;
end get_element_value;

procedure get_element_value(
    i_element_name         in            com_api_type_pkg.t_name
  , i_parent_id            in            com_api_type_pkg.t_long_id
  , o_element_value           out nocopy com_api_type_pkg.t_multilang_desc_tab
) is
    l_data_type            com_api_type_pkg.t_dict_value := com_api_const_pkg.DATA_TYPE_CHAR;
    l_element_value_n      number;
    l_element_value_d      date;
    l_appl_data_id         com_api_type_pkg.t_long_id;
    l_current_i            com_api_type_pkg.t_tiny_id;
    l_serial_number_tab    com_api_type_pkg.t_long_tab;
begin
    --trc_log_pkg.debug('get_element_value(5): start');

    get_serial_number_array(
        i_parent_id         => i_parent_id
      , i_element_name      => i_element_name
      , o_serial_number_tab => l_serial_number_tab
    );

    for i in 1 .. l_serial_number_tab.count loop
        l_current_i := i;

        get_element_data(
            i_parent_id             => i_parent_id
          , i_serial_number         => l_serial_number_tab(i)
          , i_element_name          => i_element_name
          , i_data_type             => l_data_type
          , o_element_value_v       => o_element_value(i).value
          , o_element_value_n       => l_element_value_n
          , o_element_value_d       => l_element_value_d
          , o_lang                  => o_element_value(i).lang
          , o_appl_data_id          => l_appl_data_id
        );
    end loop;
exception
    when com_api_error_pkg.e_value_error or com_api_error_pkg.e_invalid_number then
        app_api_error_pkg.raise_error(
            i_appl_data_id => l_appl_data_id
          , i_error        => 'INCORRECT_ELEMENT_VALUE'
          , i_env_param1   => case when o_element_value.exists(l_current_i) then o_element_value(l_current_i).value else null end
          , i_env_param2   => i_element_name
          , i_env_param3   => l_data_type
          , i_env_param4   => i_parent_id
          , i_element_name => i_element_name
          , i_parent_id    => i_parent_id
        );
end get_element_value;

procedure get_element_value(
    i_element_name         in            com_api_type_pkg.t_name
  , i_parent_id            in            com_api_type_pkg.t_long_id
  , o_element_value           out nocopy com_api_type_pkg.t_number_tab
) is
    l_data_type            com_api_type_pkg.t_dict_value := com_api_const_pkg.DATA_TYPE_NUMBER;
    l_element_value_v      com_api_type_pkg.t_full_desc;
    l_element_value_d      date;
    l_lang                 com_api_type_pkg.t_dict_value;
    l_appl_data_id         com_api_type_pkg.t_long_id;
    l_serial_number_tab    com_api_type_pkg.t_long_tab;
begin
    get_serial_number_array(
        i_parent_id         => i_parent_id
      , i_element_name      => i_element_name
      , o_serial_number_tab => l_serial_number_tab
    );

    for i in 1 .. l_serial_number_tab.count loop
        get_element_data(
            i_parent_id             => i_parent_id
          , i_serial_number         => l_serial_number_tab(i)
          , i_element_name          => i_element_name
          , i_data_type             => l_data_type
          , o_element_value_v       => l_element_value_v
          , o_element_value_n       => o_element_value(i)
          , o_element_value_d       => l_element_value_d
          , o_lang                  => l_lang
          , o_appl_data_id          => l_appl_data_id
        );
    end loop;
end;

procedure get_element_value(
    i_element_name         in            com_api_type_pkg.t_name
  , i_parent_id            in            com_api_type_pkg.t_long_id
  , o_element_value           out nocopy num_tab_tpt
) is
    l_data_type            com_api_type_pkg.t_dict_value := com_api_const_pkg.DATA_TYPE_NUMBER;
    l_element_value_v      com_api_type_pkg.t_full_desc;
    l_element_value_d      date;
    l_element_value_n      number;
    l_lang                 com_api_type_pkg.t_dict_value;
    l_appl_data_id         com_api_type_pkg.t_long_id;
    l_serial_number_tab    com_api_type_pkg.t_long_tab;
begin
    get_serial_number_array(
        i_parent_id         => i_parent_id
      , i_element_name      => i_element_name
      , o_serial_number_tab => l_serial_number_tab
    );

    if o_element_value is null then
        o_element_value := new num_tab_tpt();
    end if;

    for i in 1 .. l_serial_number_tab.count loop
        get_element_data(
            i_parent_id             => i_parent_id
          , i_serial_number         => l_serial_number_tab(i)
          , i_element_name          => i_element_name
          , i_data_type             => l_data_type
          , o_element_value_v       => l_element_value_v
          , o_element_value_n       => l_element_value_n
          , o_element_value_d       => l_element_value_d
          , o_lang                  => l_lang
          , o_appl_data_id          => l_appl_data_id
        );
        o_element_value.extend(1);
        o_element_value(o_element_value.count) := l_element_value_n;
    end loop;
end;

procedure get_appl_id_value(
    i_element_name         in            com_api_type_pkg.t_name
  , i_parent_id            in            com_api_type_pkg.t_long_id
  , o_element_value           out nocopy com_api_type_pkg.t_number_tab
  , o_appl_data_id            out nocopy com_api_type_pkg.t_number_tab
) is
    l_data_type            com_api_type_pkg.t_dict_value := com_api_const_pkg.DATA_TYPE_NUMBER;
    l_element_value_v      com_api_type_pkg.t_full_desc;
    l_element_value_d      date;
    l_lang                 com_api_type_pkg.t_dict_value;
    l_serial_number_tab    com_api_type_pkg.t_long_tab;
begin
    get_serial_number_array(
        i_parent_id         => i_parent_id
      , i_element_name      => i_element_name
      , o_serial_number_tab => l_serial_number_tab
    );

    for i in 1 .. l_serial_number_tab.count loop
        get_element_data(
            i_parent_id             => i_parent_id
          , i_serial_number         => l_serial_number_tab(i)
          , i_element_name          => i_element_name
          , i_data_type             => l_data_type
          , o_element_value_v       => l_element_value_v
          , o_element_value_n       => o_element_value(i)
          , o_element_value_d       => l_element_value_d
          , o_lang                  => l_lang
          , o_appl_data_id          => o_appl_data_id(i)
        );
    end loop;
end;

procedure get_element_value(
    i_element_name         in            com_api_type_pkg.t_name
  , i_parent_id            in            com_api_type_pkg.t_long_id
  , o_element_value           out nocopy com_api_type_pkg.t_date_tab
) is
    l_data_type         com_api_type_pkg.t_dict_value := com_api_const_pkg.DATA_TYPE_DATE;
    l_element_value_v      com_api_type_pkg.t_full_desc;
    l_element_value_n      number;
    l_lang                 com_api_type_pkg.t_dict_value;
    l_appl_data_id         com_api_type_pkg.t_long_id;
    l_serial_number_tab    com_api_type_pkg.t_long_tab;
begin
    get_serial_number_array(
        i_parent_id         => i_parent_id
      , i_element_name      => i_element_name
      , o_serial_number_tab => l_serial_number_tab
    );

    for i in 1 .. l_serial_number_tab.count loop
        get_element_data(
            i_parent_id             => i_parent_id
          , i_serial_number         => l_serial_number_tab(i)
          , i_element_name          => i_element_name
          , i_data_type             => l_data_type
          , o_element_value_v       => l_element_value_v
          , o_element_value_n       => l_element_value_n
          , o_element_value_d       => o_element_value(i)
          , o_lang                  => l_lang
          , o_appl_data_id          => l_appl_data_id
        );
    end loop;
end;

procedure get_appl_data_id(
    i_element_name         in            com_api_type_pkg.t_name
  , i_parent_id            in            com_api_type_pkg.t_long_id
  , i_serial_number        in            com_api_type_pkg.t_tiny_id          default 1
  , o_appl_data_id            out nocopy com_api_type_pkg.t_long_id
) is
    l_element_value_v      com_api_type_pkg.t_full_desc;
    l_element_value_n      number;
    l_element_value_d      date;
    l_lang                 com_api_type_pkg.t_dict_value;
begin
    get_element_data(
        i_parent_id             => i_parent_id
      , i_serial_number         => i_serial_number
      , i_element_name          => i_element_name
      , i_data_type             => null
      , o_element_value_v       => l_element_value_v
      , o_element_value_n       => l_element_value_n
      , o_element_value_d       => l_element_value_d
      , o_lang                  => l_lang
      , o_appl_data_id          => o_appl_data_id
    );
end;

procedure get_appl_data_id(
    i_element_name         in            com_api_type_pkg.t_name
  , i_parent_id            in            com_api_type_pkg.t_long_id
  , o_appl_data_id            out nocopy com_api_type_pkg.t_number_tab
) is
    l_element_value_v      com_api_type_pkg.t_full_desc;
    l_element_value_n      number;
    l_element_value_d      date;
    l_lang                 com_api_type_pkg.t_dict_value;
    l_serial_number_tab    com_api_type_pkg.t_long_tab;
begin
    get_serial_number_array(
        i_parent_id         => i_parent_id
      , i_element_name      => i_element_name
      , o_serial_number_tab => l_serial_number_tab
    );

    for i in 1 .. l_serial_number_tab.count loop
        get_element_data(
            i_parent_id             => i_parent_id
          , i_serial_number         => l_serial_number_tab(i)
          , i_element_name          => i_element_name
          , i_data_type             => null
          , o_element_value_v       => l_element_value_v
          , o_element_value_n       => l_element_value_n
          , o_element_value_d       => l_element_value_d
          , o_lang                  => l_lang
          , o_appl_data_id          => o_appl_data_id(i)
        );
    end loop;
end;

procedure get_appl_data_id(
    i_element_name         in            com_api_type_pkg.t_name
  , i_parent_id            in            com_api_type_pkg.t_long_id
  , o_appl_data_id            out nocopy com_api_type_pkg.t_number_tab
  , o_appl_data_lang          out nocopy com_api_type_pkg.t_dict_tab
) is
    l_element_value_v      com_api_type_pkg.t_full_desc;
    l_element_value_n      number;
    l_element_value_d      date;
    l_serial_number_tab    com_api_type_pkg.t_long_tab;
begin
    get_serial_number_array(
        i_parent_id         => i_parent_id
      , i_element_name      => i_element_name
      , o_serial_number_tab => l_serial_number_tab
    );

    for i in 1 .. l_serial_number_tab.count loop
        get_element_data(
            i_parent_id             => i_parent_id
          , i_serial_number         => l_serial_number_tab(i)
          , i_element_name          => i_element_name
          , i_data_type             => null
          , o_element_value_v       => l_element_value_v
          , o_element_value_n       => l_element_value_n
          , o_element_value_d       => l_element_value_d
          , o_lang                  => o_appl_data_lang(i)
          , o_appl_data_id          => o_appl_data_id(i)
        );
    end loop;
end;

procedure add_element(
    i_element_name         in            com_api_type_pkg.t_name
  , i_parent_id            in            com_api_type_pkg.t_long_id
  , i_data_type            in            com_api_type_pkg.t_dict_value
  , i_element_value_c      in            varchar2                            default null
  , i_element_value_n      in            number                              default null
  , i_element_value_d      in            date                                default null
  , i_lang                 in            com_api_type_pkg.t_dict_value       default null
  , o_appl_data_id            out nocopy com_api_type_pkg.t_long_id
) is
    l_parent_element_id    com_api_type_pkg.t_short_id;
    l_element_id           com_api_type_pkg.t_short_id;
    l_serial_number        com_api_type_pkg.t_tiny_id;
    l_max_count            com_api_type_pkg.t_tiny_id;
    l_element_value        com_api_type_pkg.t_full_desc;
    l_data_type            com_api_type_pkg.t_dict_value;
    l_element_type         com_api_type_pkg.t_dict_value;
    l_appl_id              com_api_type_pkg.t_long_id;
    l_element_name         com_api_type_pkg.t_name;
    l_split_hash           com_api_type_pkg.t_tiny_id;
begin
    trc_log_pkg.debug('add_element [' || i_element_name || ']');
    begin
        select id
             , data_type
             , element_type
          into l_element_id
             , l_data_type
             , l_element_type
          from app_element_all_vw
         where name = upper(i_element_name);
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error         => 'ELEMENT_NOT_FOUND'
              , i_env_param1    => upper(i_element_name)
            );
    end;

    if  l_element_type != app_api_const_pkg.APPL_ELEMENT_TYPE_COMPLEX
        and
        l_data_type != i_data_type
    then
        com_api_error_pkg.raise_error(
            i_error         => 'INCORRECT_ELEMENT_DATA_TYPE'
          , i_env_param1    => upper(i_element_name)
          , i_env_param2    => i_data_type
          , i_env_param3    => l_data_type
        );
    end if;

    begin
        select a.element_id, a.appl_id, b.name
          into l_parent_element_id, l_appl_id, l_element_name
          from app_data a
             , app_element_all_vw b
         where a.id = i_parent_id
           and a.element_id = b.id;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error         => 'PARENT_ELEMENT_NOT_FOUND'
              , i_env_param1    => upper(i_element_name)
              , i_env_param2    => i_parent_id
            );
    end;

    l_split_hash := com_api_hash_pkg.get_split_hash(app_api_const_pkg.ENTITY_TYPE_APPLICATION, l_appl_id);

    begin
        select max_count
          into l_max_count
          from app_structure a
             , app_application b
         where b.id                = l_appl_id
           and a.appl_type         = b.appl_type
           and a.parent_element_id = l_parent_element_id
           and a.element_id        = l_element_id;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error         => 'IMPOSSIBLE_ATTACH_ELEMENT'
              , i_env_param1    => upper(i_element_name)
              , i_env_param2    => upper(l_element_name)
            );
    end;

    select nvl(max(serial_number), 0)
      into l_serial_number
      from app_data
     where parent_id  = i_parent_id
       and appl_id    = l_appl_id
       and element_id = l_element_id;

    if l_serial_number >= l_max_count then
        com_api_error_pkg.raise_error(
            i_error         => 'ELEMENT_MAX_COUNT_ACHIEVED'
          , i_env_param1    => l_max_count
          , i_env_param2    => upper(i_element_name)
          , i_env_param3    => upper(l_element_name)
        );
    end if;

    if l_data_type = com_api_const_pkg.DATA_TYPE_CHAR then
        l_element_value := i_element_value_c;
    elsif l_data_type = com_api_const_pkg.DATA_TYPE_NUMBER then
        l_element_value := to_char(i_element_value_n, com_api_const_pkg.NUMBER_FORMAT);
    elsif l_data_type = com_api_const_pkg.DATA_TYPE_DATE then
        l_element_value := to_char(i_element_value_d, com_api_const_pkg.DATE_FORMAT);
    end if;

    insert into app_data(
        id
      , appl_id
      , split_hash
      , parent_id
      , element_id
      , element_value
      , serial_number
      , is_auto
      , lang
    ) values (
        get_appl_data_id(i_appl_id => l_appl_id)
      , l_appl_id
      , l_split_hash
      , i_parent_id
      , l_element_id
      , case
            when upper(i_element_name) like '%CARD_NUMBER'
            then iss_api_token_pkg.encode_card_number(i_card_number => l_element_value)
            else l_element_value
        end
      , l_serial_number + 1
      , com_api_type_pkg.TRUE
      , i_lang
    ) returning id, serial_number into o_appl_data_id, l_serial_number;

    add_element_to_cache(
        i_appl_data_id    => o_appl_data_id
      , i_element_id      => l_element_id
      , i_parent_id       => i_parent_id
      , i_serial_number   => l_serial_number
      , i_element_value   => l_element_value
      , i_lang            => i_lang
      , i_element_name    => upper(i_element_name)
      , i_data_type       => l_data_type
      , i_element_type    => l_element_type
    );
end;

procedure add_element(
    i_element_name         in            com_api_type_pkg.t_name
  , i_parent_id            in            com_api_type_pkg.t_long_id
  , i_element_value        in            com_api_type_pkg.t_full_desc
  , i_lang                 in            com_api_type_pkg.t_dict_value       default null
) is
    l_appl_data_id         com_api_type_pkg.t_long_id;
begin
    add_element(
        i_element_name      => i_element_name
      , i_parent_id         => i_parent_id
      , i_data_type         => com_api_const_pkg.DATA_TYPE_CHAR
      , i_element_value_c   => i_element_value
      , i_lang              => i_lang
      , o_appl_data_id      => l_appl_data_id
    );
end;

procedure add_element(
    i_element_name         in            com_api_type_pkg.t_name
  , i_parent_id            in            com_api_type_pkg.t_long_id
  , i_element_value        in            com_api_type_pkg.t_full_desc
  , i_lang                 in            com_api_type_pkg.t_dict_value       default null
  , o_appl_data_id            out nocopy com_api_type_pkg.t_long_id
) is
begin
    add_element(
        i_element_name      => i_element_name
      , i_parent_id         => i_parent_id
      , i_data_type         => com_api_const_pkg.DATA_TYPE_CHAR
      , i_element_value_c   => i_element_value
      , i_lang              => i_lang
      , o_appl_data_id      => o_appl_data_id
    );
end;

procedure add_element(
    i_element_name         in            com_api_type_pkg.t_name
  , i_parent_id            in            com_api_type_pkg.t_long_id
  , i_element_value        in            number
) is
    l_appl_data_id         com_api_type_pkg.t_long_id;
begin
    add_element(
        i_element_name      => i_element_name
      , i_parent_id         => i_parent_id
      , i_data_type         => com_api_const_pkg.DATA_TYPE_NUMBER
      , i_element_value_n   => i_element_value
      , o_appl_data_id      => l_appl_data_id
    );
end;

procedure add_element(
    i_element_name         in            com_api_type_pkg.t_name
  , i_parent_id            in            com_api_type_pkg.t_long_id
  , i_element_value        in            date
) is
    l_appl_data_id         com_api_type_pkg.t_long_id;
begin
    add_element(
        i_element_name      => i_element_name
      , i_parent_id         => i_parent_id
      , i_data_type         => com_api_const_pkg.DATA_TYPE_DATE
      , i_element_value_d   => i_element_value
      , o_appl_data_id      => l_appl_data_id
    );
end;

procedure modify_element(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_data_type            in            com_api_type_pkg.t_dict_value
  , i_element_value_c      in            com_api_type_pkg.t_full_desc    default null
  , i_element_value_n      in            number                          default null
  , i_element_value_d      in            date                            default null
) is
    l_element_value        com_api_type_pkg.t_full_desc;
    l_data_type            com_api_type_pkg.t_dict_value;
    l_element_type         com_api_type_pkg.t_dict_value;
    l_element_name         com_api_type_pkg.t_name;
    l_parent_id            com_api_type_pkg.t_long_id;
    l_serial_number        com_api_type_pkg.t_tiny_id;
    l_index_key            com_api_type_pkg.t_name;
begin
    begin
        select a.data_type
             , a.element_type
             , a.name
          into l_data_type
             , l_element_type
             , l_element_name
          from app_element a
             , app_data b
         where b.id = i_appl_data_id
           and a.id = b.element_id;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error         => 'ELEMENT_NOT_FOUND'
              , i_env_param1    => i_appl_data_id
            );
    end;

    if l_data_type != i_data_type then
        com_api_error_pkg.raise_error(
            i_error         => 'INCORRECT_ELEMENT_DATA_TYPE'
          , i_env_param1    => upper(l_element_name)
          , i_env_param2    => i_data_type
          , i_env_param3    => l_data_type
        );
    end if;

    if l_data_type = com_api_const_pkg.DATA_TYPE_CHAR then
        l_element_value := i_element_value_c;
    elsif l_data_type = com_api_const_pkg.DATA_TYPE_NUMBER then
        l_element_value := to_char(i_element_value_n, com_api_const_pkg.NUMBER_FORMAT);
    elsif l_data_type = com_api_const_pkg.DATA_TYPE_DATE then
        l_element_value := to_char(i_element_value_d, com_api_const_pkg.DATE_FORMAT);
    end if;

    update app_data
       set element_value = case
                               when upper(l_element_name) like '%CARD_NUMBER'
                               then iss_api_token_pkg.encode_card_number(i_card_number => l_element_value)
                               else l_element_value
                           end
         , is_auto       = com_api_type_pkg.TRUE
     where id            = i_appl_data_id
     returning parent_id, serial_number into l_parent_id, l_serial_number;

    -- Get index key of current element of current application.
    l_index_key := get_appl_data_index(
        i_parent_id      => l_parent_id
      , i_serial_number  => l_serial_number
      , i_element_name   => l_element_name
    );

    -- Change element value.
    g_app_element_tab(l_index_key).element_value := l_element_value;
end;

procedure modify_element(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_element_value        in            com_api_type_pkg.t_full_desc
) is
begin
    modify_element(
        i_appl_data_id      => i_appl_data_id
      , i_data_type         => com_api_const_pkg.DATA_TYPE_CHAR
      , i_element_value_c   => i_element_value
    );
end;

procedure modify_element(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_element_value        in            number
) is
begin
    modify_element(
        i_appl_data_id      => i_appl_data_id
      , i_data_type         => com_api_const_pkg.DATA_TYPE_NUMBER
      , i_element_value_n   => i_element_value
    );
end;

procedure modify_element(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_element_value        in            date
) is
begin
    modify_element(
        i_appl_data_id      => i_appl_data_id
      , i_data_type         => com_api_const_pkg.DATA_TYPE_DATE
      , i_element_value_d   => i_element_value
    );
end;

procedure merge_element(
    i_element_name         in            com_api_type_pkg.t_name
  , i_parent_id            in            com_api_type_pkg.t_long_id
  , i_element_value        in            com_api_type_pkg.t_full_desc
  , i_lang                 in            com_api_type_pkg.t_dict_value       default null
) is
    l_appl_data_id         com_api_type_pkg.t_long_id;
begin
    app_api_application_pkg.get_appl_data_id(
        i_element_name      => i_element_name
      , i_parent_id         => i_parent_id
      , o_appl_data_id      => l_appl_data_id
    );
    if l_appl_data_id is null then
        add_element(
            i_element_name      => i_element_name
          , i_parent_id         => i_parent_id
          , i_element_value     => i_element_value
          , i_lang              => i_lang
        );

        get_appl_data_id(
            i_element_name      => i_element_name
          , i_parent_id         => i_parent_id
          , o_appl_data_id      => l_appl_data_id
        );
        trc_log_pkg.debug(
            i_text       => 'Element [#1] added, l_appl_data_id [#2]'
          , i_env_param1 => i_element_name
          , i_env_param2 => l_appl_data_id
        );
    else
        modify_element(
            i_appl_data_id      => l_appl_data_id
          , i_element_value     => i_element_value
        );

        trc_log_pkg.debug(
            i_text       => 'Element [#1] modified, l_appl_data_id [#2]'
          , i_env_param1 => i_element_name
          , i_env_param2 => l_appl_data_id
        );
    end if;
end;

procedure merge_element(
    i_element_name         in            com_api_type_pkg.t_name
  , i_parent_id            in            com_api_type_pkg.t_long_id
  , i_element_value        in            number
) is
    l_appl_data_id         com_api_type_pkg.t_long_id;
begin
    app_api_application_pkg.get_appl_data_id(
        i_element_name      => i_element_name
      , i_parent_id         => i_parent_id
      , o_appl_data_id      => l_appl_data_id
    );
    if l_appl_data_id is null then
        add_element(
            i_element_name      => i_element_name
          , i_parent_id         => i_parent_id
          , i_element_value     => i_element_value
        );

        get_appl_data_id(
            i_element_name      => i_element_name
          , i_parent_id         => i_parent_id
          , o_appl_data_id      => l_appl_data_id
        );
        trc_log_pkg.debug(
            i_text       => 'Element [#1] added, l_appl_data_id [#2]'
          , i_env_param1 => i_element_name
          , i_env_param2 => l_appl_data_id
        );
    else
        modify_element(
            i_appl_data_id      => l_appl_data_id
          , i_element_value     => i_element_value
        );

        trc_log_pkg.debug(
            i_text       => 'Element [#1] modified, l_appl_data_id [#2]'
          , i_env_param1 => i_element_name
          , i_env_param2 => l_appl_data_id
        );
    end if;
end;

procedure merge_element(
    i_element_name         in            com_api_type_pkg.t_name
  , i_parent_id            in            com_api_type_pkg.t_long_id
  , i_element_value        in            date
) is
    l_appl_data_id         com_api_type_pkg.t_long_id;
begin
    app_api_application_pkg.get_appl_data_id(
        i_element_name      => i_element_name
      , i_parent_id         => i_parent_id
      , o_appl_data_id      => l_appl_data_id
    );
    if l_appl_data_id is null then
        add_element(
            i_element_name      => i_element_name
          , i_parent_id         => i_parent_id
          , i_element_value     => i_element_value
        );

        get_appl_data_id(
            i_element_name      => i_element_name
          , i_parent_id         => i_parent_id
          , o_appl_data_id      => l_appl_data_id
        );
        trc_log_pkg.debug(
            i_text       => 'Element [#1] added, l_appl_data_id [#2]'
          , i_env_param1 => i_element_name
          , i_env_param2 => l_appl_data_id
        );
    else
        modify_element(
            i_appl_data_id      => l_appl_data_id
          , i_element_value     => i_element_value
        );

        trc_log_pkg.debug(
            i_text       => 'Element [#1] modified, l_appl_data_id [#2]'
          , i_env_param1 => i_element_name
          , i_env_param2 => l_appl_data_id
        );
    end if;
end;

procedure remove_element(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
) is
    l_element_name         com_api_type_pkg.t_name;
    l_parent_id            com_api_type_pkg.t_long_id;
    l_serial_number        com_api_type_pkg.t_tiny_id;
    l_index_key            com_api_type_pkg.t_name;
begin
    begin
        select a.name
             , b.parent_id
             , b.serial_number
          into l_element_name
             , l_parent_id
             , l_serial_number
          from app_element a
             , app_data b
         where b.id = i_appl_data_id
           and a.id = b.element_id;
    exception
        when no_data_found then
            -- hide exception to support backward capability
            null;
    end;

    if l_element_name is not null then
        -- Get index key of current element of current application.
        l_index_key :=
            get_appl_data_index(
                i_parent_id      => l_parent_id
              , i_serial_number  => l_serial_number
              , i_element_name   => l_element_name
            );

        delete from app_data where id = i_appl_data_id;

        if g_app_element_tab.exists(l_index_key) then
            g_app_element_tab.delete(l_index_key);
        end if;
    end if;
end;

procedure get_appl_data(
    i_appl_id              in            com_api_type_pkg.t_long_id
) is
    l_count                              com_api_type_pkg.t_long_id := 0;
begin
    trc_log_pkg.debug('get_appl_data [' || i_appl_id||']');

    g_app_element_tab.delete;
    g_serial_number_tab.delete;

    for r in (
        select a.id
             , a.element_id
             , a.parent_id
             , a.serial_number
             , a.element_value
             , a.lang
             , e.name element_name
             , e.data_type
             , e.element_type
          from app_data a
             , app_element_all_vw e
         where a.appl_id = i_appl_id
           and e.id      = a.element_id
         order by a.id   -- need that current id is processed after than his parent id.
    ) loop
        add_element_to_cache(
            i_appl_data_id    => r.id
          , i_element_id      => r.element_id
          , i_parent_id       => r.parent_id
          , i_serial_number   => r.serial_number
          , i_element_value   => r.element_value
          , i_lang            => r.lang
          , i_element_name    => r.element_name
          , i_data_type       => r.data_type
          , i_element_type    => r.element_type
        );
        l_count := l_count + 1;
    end loop;

    trc_log_pkg.debug('get_appl_data: loaded ' || l_count ||' records');
end get_appl_data;

function get_appl_data_rec(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
) return app_api_type_pkg.t_appl_data_rec
is
    l_index_key            com_api_type_pkg.t_name;
    l_parent_id         com_api_type_pkg.t_long_id;
    l_serial_number        com_api_type_pkg.t_tiny_id;
    l_element_name         com_api_type_pkg.t_name;
    l_rec                  app_api_type_pkg.t_appl_data_rec;
begin
    l_index_key := g_index_by_id_tab(to_char(i_appl_data_id));

    parse_index_key(
        i_index_key            => l_index_key
      , o_parent_id            => l_parent_id
      , o_serial_number        => l_serial_number
      , o_element_name         => l_element_name
    );

    l_rec := get_appl_data_rec(
        i_appl_data_id         => g_app_element_tab(l_index_key).appl_data_id
      , i_element_id           => g_app_element_tab(l_index_key).element_id
      , i_parent_id            => l_parent_id
      , i_serial_number        => l_serial_number
      , i_element_value        => g_app_element_tab(l_index_key).element_value
      , i_lang                 => g_app_element_tab(l_index_key).lang
      , i_element_name         => l_element_name
      , i_data_type            => g_app_element_tab(l_index_key).data_type
      , i_element_type         => g_app_element_tab(l_index_key).element_type
    );

    return l_rec;
end get_appl_data_rec;

procedure get_element_name(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , o_element_name            out nocopy com_api_type_pkg.t_name
) is
    l_index_key            com_api_type_pkg.t_name;
    l_parent_id         com_api_type_pkg.t_long_id;
    l_serial_number        com_api_type_pkg.t_tiny_id;
begin
    l_index_key := g_index_by_id_tab(to_char(i_appl_data_id));

    parse_index_key(
        i_index_key            => l_index_key
      , o_parent_id            => l_parent_id
      , o_serial_number        => l_serial_number
      , o_element_name         => o_element_name
    );
end;

function get_xml(
    i_appl_id              in            com_api_type_pkg.t_long_id
  , i_add_header           in            com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
  , i_export_clear_pan     in            com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
  , i_add_xmlns            in            com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
) return clob is
    CRLF                      constant com_api_type_pkg.t_tag        := chr(13)||chr(10);
    TAB                       constant com_api_type_pkg.t_tag        := chr(9);
    CDATA_DOCUMENT_CONTENTS   constant com_api_type_pkg.t_name       := 'document_contents';
    CDATA_CUSTOMER_EDS        constant com_api_type_pkg.t_name       := 'customer_eds';
    CDATA_SUPERVISOR_EDS      constant com_api_type_pkg.t_name       := 'supervisor_eds';
    CDATA_PERSON_NAME         constant com_api_type_pkg.t_name       := 'PERSON_NAME';
    AMPERSAND                 constant com_api_type_pkg.t_name       := chr(38);

    cursor appl_data_cur(
        cp_appl_id       in com_api_type_pkg.t_long_id
      , cp_inst_id       in com_api_type_pkg.t_inst_id
    ) is
    select
        level            as element_level
      , element_type     as element_type
      , name             as element_name
      , element_value    as element_value
      , case
            when name = 'application' and i_add_xmlns = com_api_const_pkg.TRUE then
                'xmlns="' || app_api_const_pkg.APPL_XMLNS || '"'
            when name in ('service_object', 'document_object', 'account_object') then
                'id="' || id || '" ref_id="' || element_value || '"'
            when element_type = app_api_const_pkg.APPL_ELEMENT_TYPE_COMPLEX
             and element_value is null
             and lang is not null
            then
                'id="' || id || '" language="' || lang || '"'
            when element_type = app_api_const_pkg.APPL_ELEMENT_TYPE_COMPLEX
             and element_value is null
            then
                'id="' || id || '"'
            when element_type = app_api_const_pkg.APPL_ELEMENT_TYPE_COMPLEX
             and element_value is not null
             and name != 'application'
            then
                'id="' || id || '" value="' || element_value || '"'
            else
                null
        end as attribute_value
    from (
        select d.id
             , d.parent_id
             , case e.data_type
                   when com_api_const_pkg.DATA_TYPE_DATE then
                       case
                           when e.name in ('START_DATE', 'END_DATE')
                            and s.parent_element_id in (
                                    select x.id
                                      from app_element x
                                     where name in ('ATTRIBUTE_LIMIT', 'CONTACT_DATA')
                                )
                           then to_char(to_date(d.element_value, com_api_const_pkg.DATE_FORMAT)
                                      , com_api_const_pkg.XML_DATETIME_FORMAT)
                           else to_char(to_date(d.element_value, com_api_const_pkg.DATE_FORMAT)
                                      , com_api_const_pkg.XML_DATE_FORMAT)
                       end
                   when com_api_const_pkg.DATA_TYPE_NUMBER then
                       to_char(to_number(d.element_value, com_api_const_pkg.NUMBER_FORMAT))
                   else
                       case when e.name = 'APPLICATION_STATUS'
                            then a.appl_status
                            when e.name like '%CARD_NUMBER'
                            then
                            case
                                when set_ui_value_pkg.get_inst_param_n(
                                         i_param_name => 'MASKING_CARD_IN_RESPONSE_ON_APPLICATION'
                                       , i_inst_id    => cp_inst_id
                                     ) = com_api_const_pkg.TRUE
                                then
                                    iss_api_card_pkg.get_card_mask(i_card_number => d.element_value)
                                when i_export_clear_pan = com_api_type_pkg.FALSE then
                                    d.element_value -- export a token instead of a PAN
                                else
                                    iss_api_token_pkg.decode_card_number(i_card_number => d.element_value)
                            end
                            else d.element_value
                       end
               end as element_value
             , case when e.name = CDATA_PERSON_NAME
                    then d.lang -- add language only for PERSON_NAME
                    else null
               end as lang
             , lower(e.name) as name
             , e.element_type
             , e.data_type
             , s.display_order
          from app_data d
             , app_element_all_vw e
             , app_application a
             , app_structure s
             , app_data d2
         where not (e.element_type = app_api_const_pkg.APPL_ELEMENT_TYPE_SIMPLE and d.element_value is null)
           and d.element_id  = e.id
           and d.appl_id     = a.id
           and a.id          = cp_appl_id
           and d2.id         = d.parent_id
           and e.id          = s.element_id
           and a.appl_type   = s.appl_type
           and d2.element_id = s.parent_element_id
        union all
        select d.id
             , d.parent_id
             , d.element_value as element_value
             , null as lang
             , lower(e.name)   as name
             , e.element_type
             , e.data_type
             , s.display_order
          from app_data d
             , app_element_all_vw e
             , app_application a
             , app_structure s
         where not (e.element_type = app_api_const_pkg.APPL_ELEMENT_TYPE_SIMPLE and d.element_value is null)
           and d.element_id = e.id
           and d.appl_id    = a.id
           and a.id         = cp_appl_id
           and e.id         = s.element_id
           and a.appl_type  = s.appl_type
           and d.parent_id is null
           and s.parent_element_id is null
        union all
        select 0 id
             , a.id as parent_id
             , a.element_value as element_value
             , null as lang
             , lower(b.name) as name
             , b.element_type
             , b.data_type
             , b.display_order
         from (select d.id
                    , d.element_value
                    , d.appl_id
                    , d.element_id
                 from app_data d
                    , app_structure s
                    , app_element_all_vw e
                where d.element_id = e.id
                  and e.name       = 'DOCUMENT'
                  and s.element_id = d.element_id
                  and d.appl_id    = cp_appl_id
               ) a
            , (select e.name
                    , e.element_type
                    , e.data_type
                    , s.display_order
                    , parent_element_id
                 from app_structure s
                    , app_element_all_vw e
                where e.name in (upper(CDATA_DOCUMENT_CONTENTS)
                               , upper(CDATA_CUSTOMER_EDS)
                               , upper(CDATA_SUPERVISOR_EDS))
                  and s.element_id = e.id
               ) b
           where a.element_id = b.parent_element_id
    )
    connect by prior id = parent_id
      start with parent_id is null
      order siblings by display_order
    ;

    type t_app_tab            is table of appl_data_cur%rowtype index by pls_integer;
    l_app_tab                 t_app_tab;

    l_clob                    clob;

    type t_node_list          is table of com_api_type_pkg.t_name index by pls_integer;
    l_node_list               t_node_list;

    function xml_element(
        i_tag              in com_api_type_pkg.t_text
      , i_data             in com_api_type_pkg.t_text
      , i_level            in com_api_type_pkg.t_tiny_id
      , i_attribute_value  in com_api_type_pkg.t_text
    ) return com_api_type_pkg.t_text is
    begin
        return lpad(TAB, (i_level-1), TAB)
            || case
                   when i_data is null then
                       '<' || i_tag || '/>'
                   else
                       '<' || i_tag
                    || case when i_attribute_value is not null then ' ' || i_attribute_value end
                    || '>'
                       -- Replace macrosymbols with AMPERSAND: <>"' ->  amp;lt;gt;quot;apos;
                       -- do not use xmlelement
                    || replace(
                           replace(
                               replace(
                                   replace(
                                       replace(i_data, AMPERSAND, AMPERSAND||'amp;')
                                     , '<', AMPERSAND||'lt;'
                                   )
                                 , '>', AMPERSAND||'gt;'
                               )
                             , '"', AMPERSAND||'quot;'
                           )
                         , '''', AMPERSAND||'apos;'
                       )
                    || '</' || i_tag || '>'
               end;
    end xml_element;

    function open_xml_node(
        i_tag          in com_api_type_pkg.t_text
      , i_level        in com_api_type_pkg.t_tiny_id
      , i_attribute_value  in com_api_type_pkg.t_text
    ) return com_api_type_pkg.t_text is
    begin
        return lpad(TAB, (i_level-1), TAB)
            || '<' || i_tag
            || case
                   when i_attribute_value is not null then
                       ' ' || i_attribute_value
                   else
                       null
               end
            || '>'
        ;
    end open_xml_node;

    function close_xml_node(
        i_tag          in com_api_type_pkg.t_text
      , i_level        in com_api_type_pkg.t_tiny_id
    ) return com_api_type_pkg.t_text is
    begin
        return lpad(TAB, (i_level-1), TAB)
            || '</' || i_tag || '>'
        ;
    end close_xml_node;

    function special_cdata(
        i_tag              in com_api_type_pkg.t_text
      , i_element_value    in com_api_type_pkg.t_text
      , i_level            in com_api_type_pkg.t_tiny_id
    ) return clob is
        l_clob       clob;
    begin
        l_clob:= empty_clob();
        case
            when i_tag = CDATA_DOCUMENT_CONTENTS then
                select lpad(TAB, (i_level-1), TAB)
                    || xmlelement(evalname i_tag, xmlcdata(x.document_content)).getclobval()
                    || CRLF
                  into l_clob
                  from rpt_document_content x
                 where x.document_id  = to_number(i_element_value, com_api_const_pkg.NUMBER_FORMAT)
                   and x.content_type = rpt_api_const_pkg.CONTENT_TYPE_CUST_SIGN
                ;
            when i_tag = CDATA_CUSTOMER_EDS then
                select lpad(TAB, (i_level-1), TAB)
                    || xmlelement(evalname i_tag, xmlcdata(x.document_content)).getclobval()
                    || CRLF
                  into l_clob
                  from rpt_document_content x
                 where x.document_id  = to_number(i_element_value, com_api_const_pkg.NUMBER_FORMAT)
                   and x.content_type = rpt_api_const_pkg.CONTENT_TYPE_SUPERV_SIGN
                ;
            when i_tag = CDATA_SUPERVISOR_EDS then
                select lpad(TAB, (i_level-1), TAB)
                    || xmlelement(evalname i_tag, xmlcdata(com_api_hash_pkg.base64_encode(x.document_content))).getclobval()
                    || CRLF
                  into l_clob
                  from rpt_document_content x
                 where x.document_id  = to_number(i_element_value, com_api_const_pkg.NUMBER_FORMAT)
                   and x.content_type = rpt_api_const_pkg.CONTENT_TYPE_CUST_ORDER
                ;
            else
                null;
        end case;

        return l_clob;

    exception
        when no_data_found then
            return l_clob;
    end special_cdata;

    procedure close_nodes(
        i_level            in com_api_type_pkg.t_tiny_id
    ) is
    begin
        while l_node_list.last >= i_level loop
            l_clob := l_clob
                   || close_xml_node(
                          i_tag   => l_node_list(l_node_list.last)
                        , i_level => l_node_list.last
                      )
                   || CRLF;
            l_node_list.delete(l_node_list.last);
        end loop;
    end close_nodes;

begin
    l_clob:= empty_clob();

    if i_add_header = com_api_const_pkg.TRUE then
        l_clob:= com_api_const_pkg.XML_HEADER || CRLF;
    end if;

    open appl_data_cur(
             cp_appl_id  => i_appl_id
           , cp_inst_id  => get_application(i_appl_id => i_appl_id).inst_id
         );

    fetch appl_data_cur bulk collect into l_app_tab;

    for i in 1 .. l_app_tab.count loop
        if l_app_tab(i).element_level <= l_node_list.last then
            -- close all open nodes down to current level
            close_nodes(l_app_tab(i).element_level);
        end if;

        case
            when l_app_tab(i).element_type = app_api_const_pkg.APPL_ELEMENT_TYPE_COMPLEX then
                -- open new complex node
                l_clob := l_clob
                       || open_xml_node(
                              i_tag              => l_app_tab(i).element_name
                            , i_level            => l_app_tab(i).element_level
                            , i_attribute_value  => l_app_tab(i).attribute_value
                          )
                       || CRLF
                ;
                l_node_list(l_app_tab(i).element_level):= l_app_tab(i).element_name;
            when l_app_tab(i).element_type = app_api_const_pkg.APPL_ELEMENT_TYPE_SIMPLE
             and l_app_tab(i).element_name in (CDATA_DOCUMENT_CONTENTS, CDATA_CUSTOMER_EDS, CDATA_SUPERVISOR_EDS)
            then
                -- special processing for documnets binary contents
                dbms_lob.append(
                    dest_lob => l_clob
                  , src_lob  => special_cdata(
                                    i_tag              => l_app_tab(i).element_name
                                  , i_element_value    => l_app_tab(i).element_value
                                  , i_level            => l_app_tab(i).element_level
                                )
                );
            when l_app_tab(i).element_type = app_api_const_pkg.APPL_ELEMENT_TYPE_SIMPLE then
                l_clob := l_clob
                       || xml_element(
                              i_tag              => l_app_tab(i).element_name
                            , i_data             => l_app_tab(i).element_value
                            , i_level            => l_app_tab(i).element_level
                            , i_attribute_value  => l_app_tab(i).attribute_value
                          )
                       || CRLF
                ;
        end case;
    end loop;

    close appl_data_cur;

    if l_node_list.last > 0 then
        close_nodes(i_level => 0);
    elsif l_node_list.last is null and i_add_header = com_api_const_pkg.TRUE then
        -- cleanup clob because of no data
        l_clob:= null;
    end if;

    return l_clob;

exception
    when com_api_error_pkg.e_application_error or com_api_error_pkg.e_fatal_error then
        raise;
    when others then
        if appl_data_cur%isopen then
            close appl_data_cur;
        end if;

        com_api_error_pkg.raise_fatal_error(
            i_error         => 'UNHANDLED_EXCEPTION'
          , i_env_param1    => sqlerrm
        );
end get_xml;

function get_xml_with_id(
    i_appl_id              in            com_api_type_pkg.t_long_id
) return clob is
    l_context         number;
    l_xml             xmltype;
    l_clob            clob;
begin
    l_context:= dbms_xmlgen.newContextFromHierarchy(
'select
    level lvl
  , case when name=''application''
         then xmlelement(evalname name, xmlattributes(''' || app_api_const_pkg.APPL_XMLNS || ''' as "xmlns"  ))
         when name in( ''document_contents'', ''customer_eds'', ''supervisor_eds'')
         then xmlelement(evalname name, xmlattributes(id as "dataId"), XMLCdata(element_value))
         when name in (''service_object'', ''document_object'', ''account_object'')
         then xmlelement(evalname name, xmlattributes(id as "dataId", cast(element_value as varchar2(2000)) as "ref_id" ))
         when element_type = ''COMPLEX''
         then xmlelement(evalname name, xmlattributes(id as "dataId", cast(element_value as varchar2(2000)) as "value" ))
         else xmlelement(evalname name, xmlattributes(id as "dataId"), element_value)
    end element_data
from (
    select
        d.id
      , d.parent_id
      , to_clob(
        case
            when e.data_type = ''DTTPDATE'' then
                case when e.name in(''START_DATE'', ''END_DATE'')
                      and s.parent_element_id in (select x.id from app_element x where name in (''ATTRIBUTE_LIMIT'', ''CONTACT_DATA''))
                     then to_char(to_date(d.element_value, ''yyyymmddhh24miss''), '''||com_api_const_pkg.XML_DATETIME_FORMAT||''')
                     else to_char(to_date(d.element_value, ''yyyymmddhh24miss''), ''yyyy-mm-dd'')
                end
            when e.data_type = ''DTTPNMBR'' then
                to_char(to_number(d.element_value, ''FM000000000000000000.0000''))
            when e.name like ''%CARD_NUMBER'' then
                iss_api_token_pkg.decode_card_number(i_card_number => d.element_value)
            else
                d.element_value
        end
        ) as element_value
      , lower(e.name) as name
      , e.element_type
      , e.data_type
      , s.display_order
    from app_data d
       , app_element_all_vw e
       , app_application a
       , app_structure s
       , app_data d2
    where not (e.element_type = ''SIMPLE'' and d.element_value is null)
      and d.element_id  = e.id
      and d.appl_id     = a.id
      and a.id          = '||i_appl_id||'
      and d2.id         = d.parent_id
      and e.id          = s.element_id
      and a.appl_type   = s.appl_type
      and d2.element_id = s.parent_element_id
    UNION ALL
    select
        d.id
      , d.parent_id
      , to_clob(d.element_value) element_value
      , lower(e.name) as name
      , e.element_type
      , e.data_type
      , s.display_order
    from app_data d
       , app_element_all_vw e
       , app_application a
       , app_structure s
    where not (e.element_type = ''SIMPLE'' and d.element_value is null)
      and d.element_id = e.id
      and d.appl_id    = a.id
      and a.id         = '||i_appl_id||'
      and e.id         = s.element_id
      and a.appl_type  = s.appl_type
      and d.parent_id is null
      and s.parent_element_id is null
    UNION ALL
    select
        0 id
      , a.id as parent_id
      , decode(b.name, ''CUSTOMER_EDS''
                     , (select x.document_content from rpt_document_content x where x.document_id = a.doc_id and x.content_type = ''DCCT0002'')
                     ,  ''SUPERVISOR_EDS''
                     , (select x.document_content from rpt_document_content x where x.document_id = a.doc_id and x.content_type = ''DCCT0008'')
                     , ''DOCUMENT_CONTENTS''
                     , com_api_hash_pkg.base64_encode(
                           (select x.document_content from rpt_document_content x where x.document_id = a.doc_id and x.content_type = ''DCCT0001'')
                       )
                     , null
              ) element_value
      , lower(b.name) as name
      , b.element_type
      , b.data_type
      , b.display_order
    from (select d.id
               , to_number(d.element_value, get_number_format) doc_id
               , d.appl_id
               , d.element_id
            from app_data d
               , app_structure s
               , app_element_all_vw e
           where d.element_id = e.id
             and e.name       = ''DOCUMENT''
             and s.element_id = d.element_id
             and d.appl_id    ='||i_appl_id||'
         ) a
       , (select e.name
               , e.element_type
               , e.data_type
               , s.display_order
               , parent_element_id
            from app_structure s
               , app_element_all_vw e
           where e.name in (''DOCUMENT_CONTENTS'', ''CUSTOMER_EDS'', ''SUPERVISOR_EDS'')
             and s.element_id = e.id
          ) b
    where a.element_id = b.parent_element_id
)
connect by prior id = parent_id
  start with parent_id is null
  order siblings by display_order'
    );

    dbms_xmlgen.getXMlType(l_context, l_xml);

    l_clob := l_xml.getClobVal();

    l_clob := com_api_const_pkg.XML_HEADER || substr(l_clob, instr(l_clob,'?>')+2 );

    dbms_xmlgen.closeContext(l_context);

    return l_clob;
exception
    when others then
        trc_log_pkg.debug('get_xml_with_id, appl_id='||i_appl_id||': error '||sqlerrm);
        return null;
end;

procedure set_value(
    i_element_name         in            com_api_type_pkg.t_name
  , io_value_char          in out nocopy varchar2
  , io_value_num           in out nocopy number
  , io_value_date          in out nocopy date
  , i_template_value       in            varchar2
  , i_appl_data_id         in            com_api_type_pkg.t_long_id
) is
    l_element_id           com_api_type_pkg.t_long_id;
    l_data_id              com_api_type_pkg.t_long_id;
    l_type                 com_api_type_pkg.t_name;
begin
    begin
        select id
             , data_type
          into l_element_id
             , l_type
          from app_element
         where name = upper(i_element_name);
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error => 'ELEMENT_NOT_FOUND'
              , i_env_param1 => i_element_name
            );
    end;

    select min(id)
      into l_data_id
      from app_data
     where element_id  = l_element_id
   connect by prior id = parent_id
     start with id     = i_appl_data_id;

--    trc_log_pkg.debug('add_element:'||i_element_name||',i_appl_data_id='||i_appl_data_id
--                    ||',element_id='||l_element_id||', data_id='||l_data_id||', io_value_char='||io_value_char
--                    ||',type='||l_type );

    if l_type = com_api_const_pkg.DATA_TYPE_CHAR then
        if io_value_char is null then
            io_value_char := i_template_value;
        end if;

        if l_data_id is null then
            add_element(
                i_element_name   => i_element_name
              , i_parent_id      => i_appl_data_id
              , i_element_value  => io_value_char
            );
        end if;
    elsif l_type = com_api_const_pkg.DATA_TYPE_DATE then
        if io_value_date is null then
            io_value_date := to_date(i_template_value, get_date_format);
        end if;

        if l_data_id is null then
            add_element(
                i_element_name   => i_element_name
              , i_parent_id      => i_appl_data_id
              , i_element_value  => io_value_date
            );
        end if;
    elsif l_type = com_api_const_pkg.DATA_TYPE_NUMBER then
        if io_value_num is null then
            io_value_num  := to_number(i_template_value, get_number_format);
        end if;

        if l_data_id is null then
            add_element(
                i_element_name   => i_element_name
              , i_parent_id      => i_appl_data_id
              , i_element_value  => io_value_num
            );
        end if;
    else
        com_api_error_pkg.raise_error(
            i_error         => 'INCORRECT_ELEMENT_DATA_TYPE'
          , i_env_param1    => upper(i_element_name)
          , i_env_param2    => com_api_const_pkg.DATA_TYPE_CHAR
          , i_env_param3    => l_type
        );
    end if;
end;

procedure set_appl_id(
    i_appl_id              in            com_api_type_pkg.t_long_id
) is
begin
    g_appl_id      := i_appl_id;
    g_appl_flow_id := null;
end;

function get_appl_id return com_api_type_pkg.t_long_id is
begin
    return g_appl_id;
end;

/*
 * It is used to get last processed record t_appl_data_rec in basis procedure get_element_data().
 * It may be useful for logging error data when error raises inside typical procedures get_appl_data()
 * and can not be located inside get_element_data() or get_element_value() procedures. For example
 * it may be type mismatch when an outgoing value is assigned to an outgoing variable.
 */
function get_last_appl_data_rec return app_api_type_pkg.t_appl_data_rec
is
begin
    trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.get_last_appl_data_rec()');
    return g_last_appl_data_rec;
end;

/*
 * Procedure clones entire block as a branch of an application's tree,
 * i.e. it recursively runs over a branch that is specified by its root note.
 * @param i_root_appl_id     - a root node of a branch in entire application's tree
 * @param i_dest_appl_id     - a parent node for a new cloned branch
 * @param i_skipped_elements - a list of elements that should be skipped on copying
 * @param i_serial_number    - a serial number for a new root node
 * @param o_new_appl_id      - an ID of a new root node
 */
procedure clone_block(
    i_root_appl_id         in            com_api_type_pkg.t_long_id
  , i_dest_appl_id         in            com_api_type_pkg.t_long_id
  , i_skipped_elements     in            com_api_type_pkg.t_param_tab
  , i_serial_number        in            com_api_type_pkg.t_tiny_id
  , o_new_appl_id             out        com_api_type_pkg.t_long_id
) is
    LOG_PREFIX    constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.clone_block: ';
    l_appl_id              com_api_type_pkg.t_long_id;
    l_split_hash           com_api_type_pkg.t_tiny_id;
    l_error_index          pls_integer;

    type r_app_data is record (
        id                 com_api_type_pkg.t_long_id
      , appl_id            com_api_type_pkg.t_long_id
      , element_id         com_api_type_pkg.t_short_id
      , parent_id          com_api_type_pkg.t_long_id
      , serial_number      com_api_type_pkg.t_tiny_id
      , element_value      com_api_type_pkg.t_full_desc
      , is_auto            com_api_type_pkg.t_boolean
      , lang               com_api_type_pkg.t_dict_value
      , split_hash         com_api_type_pkg.t_tiny_id
    );
    type t_app_data is table of r_app_data index by binary_integer;
    l_branch               t_app_data; -- a new branch that is inserted into APP_DATA

    -- Procedure for traversing a branch using deep-first algorithm
    procedure traverse_branch(
        i_old_root_id   in            com_api_type_pkg.t_long_id
      , i_new_root_id   in            com_api_type_pkg.t_long_id
      , i_root_tag_only in            com_api_type_pkg.t_boolean
    ) is
        l_index                       pls_integer;
        l_appl_data_id                com_api_type_pkg.t_long_id;
        l_index_key                   com_api_type_pkg.t_name;
        l_parent_id                   com_api_type_pkg.t_long_id;
        l_serial_number               com_api_type_pkg.t_tiny_id;
        l_element_name                com_api_type_pkg.t_name;
    begin
        --trc_log_pkg.debug(
        --   i_text => 'traverse_branch: i_level [' || i_level
        --          || '], i_root_id [' || i_root_id
        --          || '], i_new_root_id [' || i_new_root_id
        --          || '], io_tree.count() = ' || io_branch.count()
        --);

        l_index_key := g_app_element_tab.first;
        loop
            exit when l_index_key is null;

            parse_index_key(
                i_index_key           => l_index_key
              , o_parent_id           => l_parent_id
              , o_serial_number       => l_serial_number
              , o_element_name        => l_element_name
            );

            if (
                   (i_root_tag_only = com_api_type_pkg.TRUE  and g_app_element_tab(l_index_key).appl_data_id = i_old_root_id)
                   or
                   (i_root_tag_only = com_api_type_pkg.FALSE and l_parent_id = i_old_root_id)
               )
               and not i_skipped_elements.exists(l_element_name)
            then
                -- Copy (clone) node in both collections io_branch and io_tree
                l_appl_data_id                  := get_appl_data_id(i_appl_id => l_appl_id);
                l_index                         := l_branch.count + 1;
                l_branch(l_index).id            := l_appl_data_id;
                l_branch(l_index).appl_id       := l_appl_id;
                l_branch(l_index).element_id    := g_app_element_tab(l_index_key).element_id;
                l_branch(l_index).parent_id     := i_new_root_id;
                l_branch(l_index).serial_number := l_serial_number;
                l_branch(l_index).element_value := g_app_element_tab(l_index_key).element_value;
                l_branch(l_index).is_auto       := com_api_type_pkg.TRUE;
                l_branch(l_index).lang          := g_app_element_tab(l_index_key).lang;
                l_branch(l_index).split_hash    := l_split_hash;

                -- It need before the "add_element_to_cache" method.
                if i_root_tag_only = com_api_type_pkg.TRUE then
                    l_branch(l_index).serial_number := i_serial_number;
                end if;

                add_element_to_cache(
                    i_appl_data_id    => l_appl_data_id
                  , i_element_id      => l_branch(l_index).element_id
                  , i_parent_id       => l_branch(l_index).parent_id
                  , i_serial_number   => l_branch(l_index).serial_number
                  , i_element_value   => l_branch(l_index).element_value
                  , i_lang            => l_branch(l_index).lang
                  , i_element_name    => l_element_name
                  , i_data_type       => g_app_element_tab(l_index_key).data_type
                  , i_element_type    => g_app_element_tab(l_index_key).element_type
                );

                if i_root_tag_only = com_api_type_pkg.TRUE then
                    o_new_appl_id := l_branch(l_index).id;
                    exit;

                else
                    -- Array of indexes <l_level_indexes> is used to prevent 2 scans
                    -- of tree <io_tree> instead of one, because we desire save a current
                    -- root element first, and only then its descendants
                    traverse_branch(
                        i_old_root_id   => g_app_element_tab(l_index_key).appl_data_id
                      , i_new_root_id   => l_appl_data_id
                      , i_root_tag_only => com_api_type_pkg.FALSE
                    );

                end if;
            end if;

            l_index_key := g_app_element_tab.next(l_index_key);
        end loop;
    end;

begin
    trc_log_pkg.debug(
       i_text => LOG_PREFIX || 'START, i_root_appl_id [' || i_root_appl_id
              || '], i_dest_appl_id [' || i_dest_appl_id
              || '], i_serial_number [' || i_serial_number
              || '], i_skipped_elements.count() = ' || i_skipped_elements.count()
    );

    if  i_root_appl_id is not null
        and i_dest_appl_id is not null
        and g_app_element_tab.first is not null    --and l_appl_data.count() > 0
    then

        begin
            select distinct appl_id
              into l_appl_id
              from app_data
             where id in (i_dest_appl_id, i_root_appl_id)
               and appl_id is not null;
        exception
            when no_data_found then
                trc_log_pkg.debug('Data elements aren''t found or don''t contain application ID');
                raise;
            when too_many_rows then
                trc_log_pkg.debug('Data elements relate to different applications');
                raise;
        end;
        l_split_hash := com_api_hash_pkg.get_split_hash(
                            i_entity_type => app_api_const_pkg.ENTITY_TYPE_APPLICATION
                          , i_object_id   => l_appl_id
                        );

        -- Copy root tag only
        traverse_branch(
            i_old_root_id   => i_root_appl_id
          , i_new_root_id   => i_dest_appl_id
          , i_root_tag_only => com_api_type_pkg.TRUE
        );

        -- Copy subtree of the root tag.
        -- Traverse an application's tree from a root node <i_root_appl_id>
        -- and create a new collection that contains a branch.
        -- Also appl_data_id and parent_id fields of every record (node) in a
        -- new branch are updated with new IDs
        if o_new_appl_id is not null then
            traverse_branch(
                i_old_root_id   => i_root_appl_id
              , i_new_root_id   => o_new_appl_id
              , i_root_tag_only => com_api_type_pkg.FALSE
            );
        --else
        --    dbms_output.put_line('o_new_appl_id='||o_new_appl_id);
        end if;

        /**************
        declare
            l_element_name  com_api_type_pkg.t_name;
        begin
            for i in l_branch.first .. l_branch.last loop

                select e.name
                  into l_element_name
                  from app_element_all_vw e
                 where e.id = l_branch(i).element_id;

                dbms_output.put_line('i='||i
                                     ||', element_name='  || l_element_name
                                     ||', id='            || to_char(l_branch(i).id)
                                     ||', appl_id='       || to_char(l_branch(i).appl_id)
                                     ||', element_id='    || to_char(l_branch(i).element_id)
                                     ||', parent_id='     || to_char(l_branch(i).parent_id)
                                     ||', serial_number=' || l_branch(i).serial_number
                                     ||', element_value=' || l_branch(i).element_value
                                     ||', is_auto='       || l_branch(i).is_auto
                                     ||', lang='          || l_branch(i).lang
                                     ||', split_hash='    || l_branch(i).split_hash
                );
            end loop;
        end;
        **************/

        -- Add a new cloned branch to an application's tree as a child of
        -- node <i_dest_appl_id>, serial number or a root node should be updated
        begin
            forall i in l_branch.first .. l_branch.last
                insert into app_data (
                    id
                  , appl_id
                  , element_id
                  , parent_id
                  , serial_number
                  , element_value
                  , is_auto
                  , lang
                  , split_hash
                ) values (
                    l_branch(i).id
                  , l_branch(i).appl_id
                  , l_branch(i).element_id
                  , l_branch(i).parent_id
                  , l_branch(i).serial_number
                  , l_branch(i).element_value
                  , l_branch(i).is_auto
                  , l_branch(i).lang
                  , l_branch(i).split_hash
                );
        exception
            when others then
                l_error_index := sql%bulk_exceptions(1).error_index;
                trc_log_pkg.debug(
                    i_text       => 'inserting in APP_DATA failed: iteration [#1], error code [#2], {id [#3], parent_id [#4]}'
                  , i_env_param1 => l_error_index
                  , i_env_param2 => sqlerrm(-sql%bulk_exceptions(1).error_code)
                  , i_env_param3 => l_branch(l_error_index).id
                  , i_env_param4 => l_branch(l_error_index).parent_id
                );
                raise;
        end;
    end if;

    trc_log_pkg.debug(LOG_PREFIX || 'END');
exception
    when others then
        trc_log_pkg.debug(
           i_text => LOG_PREFIX || 'FAILED, l_appl_id [' || l_appl_id
                  || '], l_split_hash [' || l_split_hash
                  || '], l_branch.count() = ' || l_branch.count()
        );
        raise;
end clone_block;

/*
 * Function searches and returns value of APPLICATION_FLOW_ID in provided application data.
 */
function get_appl_flow return com_api_type_pkg.t_tiny_id
is
    l_root_id              com_api_type_pkg.t_long_id;
begin
    if g_appl_flow_id is null then
        -- Global variable g_appl_flow_id is updated to NULL on setting variable g_appl_id
        app_api_application_pkg.get_appl_data_id(
            i_element_name   => 'APPLICATION'
          , i_parent_id      => null
          , o_appl_data_id   => l_root_id
        );
        app_api_application_pkg.get_element_value(
            i_element_name  => 'APPLICATION_FLOW_ID'
          , i_parent_id     => l_root_id
          , o_element_value => g_appl_flow_id
        );
    end if;

    return g_appl_flow_id;
end get_appl_flow;

function get_application(
    i_appl_id             in     com_api_type_pkg.t_long_id
  , i_raise_error         in     com_api_type_pkg.t_boolean           default com_api_const_pkg.FALSE
) return app_api_type_pkg.t_application_rec
is
    l_application          app_api_type_pkg.t_application_rec;
begin
    begin
        select id
             , appl_type
             , appl_number
             , appl_status
             , flow_id
             , reject_code
             , agent_id
             , inst_id
             , session_file_id
             , file_rec_num
             , resp_session_file_id
             , product_id
             , split_hash
             , seqnum
             , user_id
             , is_visible
             , appl_prioritized
             , execution_mode
          into l_application
          from app_application
         where id = i_appl_id;

    exception
        when no_data_found then
            if i_raise_error = com_api_const_pkg.TRUE then
                com_api_error_pkg.raise_error (
                    i_error       => 'APPLICATION_NOT_FOUND'
                  , i_env_param1  => i_appl_id
                );
            end if;
    end;

    return l_application;
end get_application;

procedure calculate_new_card_count(
    i_card_count          in     com_api_type_pkg.t_long_id
  , i_batch_card_count    in     com_api_type_pkg.t_long_id
  , o_application_count      out com_api_type_pkg.t_long_id
  , o_non_last_card_count    out com_api_type_pkg.t_long_id
  , o_last_card_count        out com_api_type_pkg.t_long_id
) is
begin
    if i_batch_card_count is null then
        o_non_last_card_count := app_api_const_pkg.MAX_SEQ_NUMBER;
    else
        o_non_last_card_count := floor(app_api_const_pkg.MAX_SEQ_NUMBER / i_batch_card_count) * i_batch_card_count;
    end if;

    o_application_count       := floor(i_card_count  / o_non_last_card_count);

    if floor(i_card_count / o_non_last_card_count) != ceil(i_card_count / o_non_last_card_count) then
        o_last_card_count     := i_card_count - o_application_count * o_non_last_card_count;
        o_application_count   := o_application_count + 1;
    end if;
end calculate_new_card_count;

end app_api_application_pkg;
/
