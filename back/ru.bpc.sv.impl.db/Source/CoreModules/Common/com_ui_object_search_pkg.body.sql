create or replace package body com_ui_object_search_pkg as
/*********************************************************
 *  Object search in the Web forms <br />
 *  Created by Truschelev O. (truschelev@bpcbt.com) at 19.12.2016 <br />
 *  Last changed by $Author: truschelev $ <br />
 *  $LastChangedDate: 2016-12-19 19:30:00 +0400#$ <br />
 *  Remcwion: $LastChangedVersion: 1 $ <br />
 *  Module: com_ui_object_search_pkg <br />
 *  @headcom
 **********************************************************/

g_mcc_name_tab              com_api_type_pkg.t_param_tab;
g_inst_name_tab             com_api_type_pkg.t_name_tab;
g_network_name_tab          com_api_type_pkg.t_name_tab;
g_dictionary_name_tab       com_api_type_pkg.t_param_tab;
g_start_timestamp           timestamp;

function get_mcc_name(
    i_mcc               in  com_api_type_pkg.t_mcc
) return                    com_api_type_pkg.t_name
is
    l_mcc_id                com_api_type_pkg.t_short_id;
    l_mcc_name              com_api_type_pkg.t_name;
begin
    if i_mcc is not null then
        if not g_mcc_name_tab.exists(i_mcc) then
            begin
                select id
                  into l_mcc_id
                  from com_mcc
                 where mcc = i_mcc;

                g_mcc_name_tab(i_mcc) := com_api_i18n_pkg.get_text('com_mcc', 'name', l_mcc_id);
            exception when no_data_found then
                g_mcc_name_tab(i_mcc) := null;
            end;
        end if;
        l_mcc_name := g_mcc_name_tab(i_mcc);
    end if;
    return l_mcc_name;
end get_mcc_name;

function get_inst_name(
    i_inst_id           in  com_api_type_pkg.t_inst_id
) return                    com_api_type_pkg.t_name
is
    l_inst_name             com_api_type_pkg.t_name;
begin
    if i_inst_id is not null then
        if not g_inst_name_tab.exists(i_inst_id) then
            g_inst_name_tab(i_inst_id) := com_api_i18n_pkg.get_text('ost_institution', 'name', i_inst_id);
        end if;
        l_inst_name := g_inst_name_tab(i_inst_id);
    end if;
    return l_inst_name;
end get_inst_name;

function get_network_name(
    i_network_id        in  com_api_type_pkg.t_network_id
) return                    com_api_type_pkg.t_name
is
    l_network_name          com_api_type_pkg.t_name;
begin
    if i_network_id is not null then
        if not g_network_name_tab.exists(i_network_id) then
            g_network_name_tab(i_network_id) := com_api_i18n_pkg.get_text('net_network', 'name', i_network_id);
        end if;
        l_network_name := g_network_name_tab(i_network_id);
    end if;
    return l_network_name;
end get_network_name;

function get_dictionary_name(
    i_dictionary_code   in  com_api_type_pkg.t_dict_value
) return                    com_api_type_pkg.t_name
is
    l_dictionary_name       com_api_type_pkg.t_name;
begin
    if i_dictionary_code is not null then
        if not g_dictionary_name_tab.exists(i_dictionary_code) then
            g_dictionary_name_tab(i_dictionary_code) := com_api_dictionary_pkg.get_article_text(i_dictionary_code);
        end if;
        l_dictionary_name := g_dictionary_name_tab(i_dictionary_code);
    end if;
    return l_dictionary_name;
end get_dictionary_name;

function get_sorting_clause(
    i_sorting_tab       in  com_param_map_tpt
  , i_use_id_sorting    in  com_api_type_pkg.t_boolean  default com_api_type_pkg.FALSE
) return                    com_api_type_pkg.t_name
is
    l_result                com_api_type_pkg.t_name;
    l_found_id              com_api_type_pkg.t_boolean  := com_api_type_pkg.FALSE;
    l_count                 com_api_type_pkg.t_short_id := 0;
begin
    if i_sorting_tab is not null then
        l_count := i_sorting_tab.count;
    end if;

    for i in 1 .. l_count loop
        if i_sorting_tab(i).name is not null then
            if l_result is not null then
                l_result := l_result || ', ';
            end if;
            if i_sorting_tab(i).char_value is not null then
                l_result := l_result || i_sorting_tab(i).name || ' ' || i_sorting_tab(i).char_value;
            else
                l_result := l_result || i_sorting_tab(i).name;
            end if;

            if upper(i_sorting_tab(i).name) = 'ID' then
                l_found_id := com_api_type_pkg.TRUE;
            end if;
        end if;
    end loop;

    -- Always add sorting by opr_operation.id
    if i_use_id_sorting = com_api_type_pkg.TRUE then
        l_result := ' order by ' ||
                    case when l_count = 0
                         then 'id desc'
                         when l_found_id = com_api_type_pkg.FALSE
                         then l_result || ', id desc'
                         else l_result
                    end;

    elsif l_count > 0 then
        l_result := ' order by ' || l_result;

    end if;

    trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.get_sorting_clause [' || l_result || ']');
    return l_result;
end get_sorting_clause;

function check_changed_param(
    i_old_param_tab     in  com_param_map_tpt
  , i_new_param_tab     in  com_param_map_tpt
) return                    com_api_type_pkg.t_boolean
is
    l_result                com_api_type_pkg.t_boolean  := com_api_type_pkg.FALSE;
begin
    if i_old_param_tab.count != i_new_param_tab.count then
        l_result := com_api_type_pkg.TRUE;
    else
        for i in 1 .. i_new_param_tab.count loop
            if not (
                upper(i_old_param_tab(i).name)           = upper(i_new_param_tab(i).name)
                and (
                        (i_old_param_tab(i).char_value   = i_new_param_tab(i).char_value)
                        or
                        (i_old_param_tab(i).char_value is null and i_new_param_tab(i).char_value is null)
                )
                and (
                        (i_old_param_tab(i).number_value = i_new_param_tab(i).number_value)
                        or
                        (i_old_param_tab(i).number_value is null and i_new_param_tab(i).number_value is null)
                )
                and (
                        (i_old_param_tab(i).date_value   = i_new_param_tab(i).date_value)
                        or
                        (i_old_param_tab(i).date_value is null and i_new_param_tab(i).date_value is null)
                )
            )
            then
                l_result := com_api_type_pkg.TRUE;
                exit;
            end if;
        end loop;
    end if;

    return l_result;
end check_changed_param;

function is_used_sorting(
    i_is_first_call     in     com_api_type_pkg.t_boolean
  , i_sorting_count     in     com_api_type_pkg.t_tiny_id
  , i_row_count         in     com_api_type_pkg.t_long_id
  , i_mask_error        in     com_api_type_pkg.t_boolean  default com_api_type_pkg.FALSE
) return com_api_type_pkg.t_boolean
is
    l_max_count         com_api_type_pkg.t_long_id;
    l_result            com_api_type_pkg.t_boolean  := com_api_type_pkg.TRUE;
begin
    l_max_count := nvl(set_ui_value_pkg.get_system_param_n(i_param_name => 'MAX_COUNT_WHEN_FORM_USES_SORTING'), 1000);

    trc_log_pkg.debug(
        i_text       => 'is_used_sorting: i_is_first_call [#1], i_sorting_count [#2], i_mask_error [#3], i_row_count [#4], l_max_count [#5]'
      , i_env_param1 => i_is_first_call
      , i_env_param2 => i_sorting_count
      , i_env_param3 => i_mask_error
      , i_env_param4 => i_row_count
      , i_env_param5 => l_max_count
    );

    if i_is_first_call = com_api_type_pkg.TRUE then
        l_result := com_api_type_pkg.FALSE;

    elsif nvl(i_sorting_count, 0) > 0
          and nvl(i_row_count, 0) > l_max_count
    then
        l_result := com_api_type_pkg.FALSE;

        if nvl(i_mask_error, com_api_type_pkg.FALSE) = com_api_type_pkg.FALSE then
            com_api_error_pkg.raise_error(
                i_error      => 'INVALID_ROW_COUNT_FOR_SORTING'
              , i_env_param1 => i_row_count
              , i_env_param2 => l_max_count
            );
        else
            trc_log_pkg.info(
                i_text       => 'INVALID_ROW_COUNT_FOR_SORTING'
              , i_env_param1 => i_row_count
              , i_env_param2 => l_max_count
            );
        end if;
    end if;

    return l_result;
end is_used_sorting;

procedure start_search(
    i_is_first_call     in     com_api_type_pkg.t_boolean
) is
begin
    trc_log_pkg.debug(
        i_text       => 'Start: i_is_first_call [#1]'
      , i_env_param1 => i_is_first_call
    );

    g_start_timestamp := systimestamp;
end start_search;

procedure finish_search(
    i_is_first_call     in     com_api_type_pkg.t_boolean
  , i_row_count         in     com_api_type_pkg.t_long_id
  , i_sql_statement     in     com_api_type_pkg.t_sql_statement
  , i_is_failed         in     com_api_type_pkg.t_boolean       default com_api_type_pkg.FALSE
  , i_sqlerrm_text      in     com_api_type_pkg.t_full_desc     default null
) is
    l_finish_timestamp         timestamp;
    l_description              com_api_type_pkg.t_name;
begin
    l_finish_timestamp := systimestamp;

    trc_log_pkg.debug('query[part 1]: ' || substr(i_sql_statement, 1, 3900));

    if substr(i_sql_statement, 3901, 3900) is not null then
        trc_log_pkg.debug('query[part 2]: ' || substr(i_sql_statement, 3901, 3900));
    end if;

    if i_is_failed = com_api_type_pkg.TRUE then
        l_description := 'FAILED:';
    else
        l_description := 'Finished:';
    end if;

    trc_log_pkg.debug(
        i_text       => l_description || ' i_is_first_call [#1], Step 1 [#2] seconds, i_row_count [#3], sqlerrm [#4]'
      , i_env_param1 => i_is_first_call
      , i_env_param2 => to_char((l_finish_timestamp - g_start_timestamp))
      , i_env_param3 => i_row_count
      , i_env_param4 => i_sqlerrm_text
    );

    g_start_timestamp := null;

end finish_search;

function get_char_value(
    i_param_tab         in out nocopy com_param_map_tpt
  , i_param_name        in     com_api_type_pkg.t_name
) return com_api_type_pkg.t_name is
begin
    if i_param_tab is not null then
        for i in 1 .. i_param_tab.count loop
            if i_param_tab(i).name = i_param_name then
                return i_param_tab(i).char_value;
            end if;
        end loop;
    end if;
    
    return null;
end get_char_value;

function get_date_value(
    i_param_tab         in out nocopy com_param_map_tpt
  , i_param_name        in     com_api_type_pkg.t_name
) return date is
begin
    if i_param_tab is not null then
        for i in 1 .. i_param_tab.count loop
            if i_param_tab(i).name = i_param_name then
                return i_param_tab(i).date_value;
            end if;
        end loop;
    end if;
    
    return null;
end get_date_value;

function get_number_value(
    i_param_tab         in out nocopy com_param_map_tpt
  , i_param_name        in     com_api_type_pkg.t_name
) return number is
begin
    if i_param_tab is not null then
        for i in 1 .. i_param_tab.count loop
            if i_param_tab(i).name = i_param_name then
                return i_param_tab(i).number_value;
            end if;
        end loop;
    end if;
    
    return null;
end get_number_value;

end com_ui_object_search_pkg;
/
