create or replace package body trc_text_pkg as
/*************************************************************
 * API for text of logging messages <br />
 * Created by Truschelev O.(truschelev@bpcbt.com)  at 03.03.2016
 * Module: TRC_TEXT_PKG
 * @headcom
**************************************************************/

SIZEOF_T_FULL_DESC     constant pls_integer := 2000;  -- sizeof(com_api_type_pkg.t_full_desc)
SIZEOF_T_TEXT          constant pls_integer := 4000;  -- sizeof(com_api_type_pkg.t_text)
MIN_LENGTH_DICT_VALUE  constant pls_integer := 5;
MAX_LENGTH_DICT_VALUE  constant pls_integer := 8;


function get_desc(
    i_env_param         in     com_api_type_pkg.t_full_desc
) return com_api_type_pkg.t_full_desc
is
    l_result            com_api_type_pkg.t_full_desc;
begin
    if i_env_param is not null then
        -- Article's text should be retrieved from a dictionary only if input parameter <i_env_param>
        -- has length between 5 and 8
        if length(i_env_param) between MIN_LENGTH_DICT_VALUE and MAX_LENGTH_DICT_VALUE then
            l_result := com_api_dictionary_pkg.get_article_text(i_env_param);

            if l_result is not null and l_result != i_env_param then
                l_result := substrb(i_env_param || ' ' || l_result, 1, SIZEOF_T_FULL_DESC);
            end if;
        else
            l_result := i_env_param;
        end if;
    end if;
    return l_result;
end get_desc;

procedure get_text(
    i_level             in     com_api_type_pkg.t_tiny_id
  , io_text             in out com_api_type_pkg.t_text
  , i_env_param1        in     com_api_type_pkg.t_full_desc        default null
  , i_env_param2        in     com_api_type_pkg.t_name             default null
  , i_env_param3        in     com_api_type_pkg.t_name             default null
  , i_env_param4        in     com_api_type_pkg.t_name             default null
  , i_env_param5        in     com_api_type_pkg.t_name             default null
  , i_env_param6        in     com_api_type_pkg.t_name             default null
  , i_get_text          in     com_api_type_pkg.t_boolean          default com_api_type_pkg.FALSE
  , o_label_id             out com_api_type_pkg.t_short_id
  , o_param_text           out com_api_type_pkg.t_text
) is
begin
    if i_level != trc_config_pkg.DEBUG then
        begin
            select a.id
              into o_label_id
              from com_label a
             where upper(a.name) = upper(io_text);
        exception
            when no_data_found then
                null;
        end;
    end if;

    if o_label_id is not null then
        o_param_text := '"' || nvl(replace(i_env_param1, '"'), 'NULL') || '"';
        o_param_text := o_param_text || '; "' || nvl(replace(i_env_param2, '"'), 'NULL') || '"';
        o_param_text := o_param_text || '; "' || nvl(replace(i_env_param3, '"'), 'NULL') || '"';
        o_param_text := o_param_text || '; "' || nvl(replace(i_env_param4, '"'), 'NULL') || '"';
        o_param_text := o_param_text || '; "' || nvl(replace(i_env_param5, '"'), 'NULL') || '"';
        o_param_text := o_param_text || '; "' || nvl(replace(i_env_param6, '"'), 'NULL') || '"';

        if i_get_text = com_api_type_pkg.TRUE then
            begin
                io_text := com_api_i18n_pkg.get_text('com_label', 'name', o_label_id);

                io_text := replace(io_text, '#1', nvl(get_desc(i_env_param1), 'NULL'));
                io_text := replace(io_text, '#2', nvl(get_desc(i_env_param2), 'NULL'));
                io_text := replace(io_text, '#3', nvl(get_desc(i_env_param3), 'NULL'));
                io_text := replace(io_text, '#4', nvl(get_desc(i_env_param4), 'NULL'));
                io_text := replace(io_text, '#5', nvl(get_desc(i_env_param5), 'NULL'));
                io_text := replace(io_text, '#6', nvl(get_desc(i_env_param6), 'NULL'));
            exception
                when no_data_found then
                    -- It never executes because functions com_api_i18n_pkg.get_text()
                    -- and get_desc() don't throw no_data_found exception
                    io_text := substrb('Unknown message: "'||io_text||'". '||o_param_text, 1, SIZEOF_T_TEXT);
                when com_api_error_pkg.e_value_error then
                    null; -- string overflow shouldn't crash a process, to loose some logging information is acceptable
            end;
        end if;
    else
        begin
            io_text := replace(io_text, '#1', nvl(get_desc(i_env_param1), 'NULL'));
            io_text := replace(io_text, '#2', nvl(get_desc(i_env_param2), 'NULL'));
            io_text := replace(io_text, '#3', nvl(get_desc(i_env_param3), 'NULL'));
            io_text := replace(io_text, '#4', nvl(get_desc(i_env_param4), 'NULL'));
            io_text := replace(io_text, '#5', nvl(get_desc(i_env_param5), 'NULL'));
            io_text := replace(io_text, '#6', nvl(get_desc(i_env_param6), 'NULL'));
        exception
            when com_api_error_pkg.e_value_error then
                null; -- string overflow shouldn't crash a process, to loose some logging information is acceptable
        end;
    end if;

    -- If length of string passed in <io_text> exceeds SIZEOF_T_TEXT then overflow will not be registered,
    -- and an exception will not be thrown, but some error will occur on inserting into TRC_LOG (e.g. ORA-01461)
    io_text := substrb(io_text, 1, SIZEOF_T_TEXT);

    if o_param_text is null then
        o_param_text := io_text;
    end if;
end get_text;

end;
/
