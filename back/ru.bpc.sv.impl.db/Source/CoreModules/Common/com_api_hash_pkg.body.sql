create or replace package body com_api_hash_pkg is
/*********************************************************
 *  API for hash and base64<br />
 *  Created by Khougaev A.(khougaev@bpcbt.com)  at 25.01.2010 <br />
 *  Last changed by $Author$ <br />    
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module:  com_api_hash_pkg  <br />
 *  @headcom
 **********************************************************/

g_parallel_degree                   com_api_type_pkg.t_tiny_id := com_api_const_pkg.DEFAULT_SPLIT_HASH;
g_split_degree                      com_api_type_pkg.t_tiny_id := com_api_const_pkg.DEFAULT_SPLIT_HASH;

g_entity_type                       com_api_type_pkg.t_dict_value;
g_object_id                         com_api_type_pkg.t_long_id;
g_split_hash                        com_api_type_pkg.t_tiny_id;
g_current_split_hash_tab            com_api_type_pkg.t_tiny_tab;

MAX_HASH_NUMBER            constant number := power(2, 30);


function get_split_hash (
    i_value         in varchar2
) return com_api_type_pkg.t_tiny_id is
begin
    case
        when g_split_degree > 1 then return dbms_utility.get_hash_value(i_value, 1, g_split_degree);
        else return com_api_const_pkg.DEFAULT_SPLIT_HASH;
    end case;
end;

function get_split_hash (
    i_entity_type   in      com_api_type_pkg.t_dict_value
  , i_object_id     in      com_api_type_pkg.t_long_id
  , i_mask_error    in      com_api_type_pkg.t_boolean     default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_tiny_id is
    l_result        com_api_type_pkg.t_tiny_id;
    l_table_name    com_api_type_pkg.t_oracle_name;
begin
    if g_entity_type is not null and g_object_id is not null and g_split_hash is not null then
        if g_entity_type = i_entity_type and g_object_id = i_object_id then
            return g_split_hash;
        end if;
    end if;

    if g_split_degree > 1 then
        l_table_name := utl_deploy_pkg.get_entity_table(i_entity_type => i_entity_type);
        if l_table_name is null then
            com_api_error_pkg.raise_error(
                i_error         => 'ENTITY_TYPE_NOT_FOUND'
              , i_env_param1    => i_entity_type
              , i_mask_error    => i_mask_error
            );
        end if;

        if utl_deploy_pkg.check_column(i_table_name => l_table_name) = com_api_type_pkg.TRUE then

            begin
                execute immediate
                    'select split_hash from '||l_table_name||' where id = :p_id'
                    into l_result
                    using i_object_id;
            exception
                when no_data_found then
                    com_api_error_pkg.raise_error(
                        i_error         => 'OBJECT_NOT_FOUND'
                      , i_env_param1    => i_entity_type
                      , i_env_param2    => i_object_id
                      , i_mask_error    => i_mask_error
                    );
            end;
        else
            l_result := get_split_hash(i_value => i_object_id);
        end if;
    else
        l_result := com_api_const_pkg.DEFAULT_SPLIT_HASH;
    end if;

    g_entity_type := i_entity_type;
    g_object_id   := i_object_id;
    g_split_hash  := l_result;

    return l_result;
end;

function get_card_hash (
    i_card_number   in com_api_type_pkg.t_card_number
) return com_api_type_pkg.t_long_id is
begin
    return get_string_hash(i_card_number);
end;

function get_string_hash (
    i_string        in varchar2
) return com_api_type_pkg.t_long_id is
begin
    return dbms_utility.get_hash_value(i_string, 1, MAX_HASH_NUMBER);
end;

function get_param_mask (
    i_value           in com_api_type_pkg.t_param_value
) return com_api_type_pkg.t_param_value is
begin
    return regexp_replace(i_value,'[0-9]|[A-Z]|[?:;,%^=$]', '*');
end;

function base64_encode(
    i_clob          in     clob
) return clob is
    l_clob   clob;
    l_len    number;
    l_pos    number := 1;
    l_buffer varchar2(32767);
    l_amount number := 32767;
begin
    l_len := dbms_lob.getlength(i_clob);
    dbms_lob.createtemporary(l_clob, true);

    while l_pos <= l_len loop
        dbms_lob.read (i_clob, l_amount, l_pos, l_buffer);
        l_buffer := utl_encode.text_encode(l_buffer, encoding => utl_encode.base64);
        l_pos := l_pos + l_amount;
        dbms_lob.writeappend(l_clob, length(l_buffer), l_buffer);
    end loop;

    return l_clob;
end;

function base64_decode(
    i_clob          in     clob
) return clob is
    l_clob   clob;
    l_len    number;
    l_pos    number := 1;
    l_buffer varchar2(32767);
    l_amount number := 32767;
begin
    l_len := dbms_lob.getlength(i_clob);
    dbms_lob.createtemporary(l_clob, true);

    while l_pos <= l_len loop
        dbms_lob.read (i_clob, l_amount, l_pos, l_buffer);
        l_buffer := utl_encode.text_decode(l_buffer, encoding => utl_encode.base64);
        l_pos := l_pos + l_amount;
        dbms_lob.writeappend(l_clob, length(l_buffer), l_buffer);
    end loop;

    return l_clob;
end;

function check_current_thread_number(
    i_split_hash    in     com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_boolean
is
    l_thread_number_tab    com_api_type_pkg.t_tiny_tab;
    l_split_hash_tab       com_api_type_pkg.t_tiny_tab;
    l_thread_number        com_api_type_pkg.t_tiny_id;
    l_result               com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE;
begin
    l_thread_number := get_thread_number;

    if l_thread_number = prc_api_const_pkg.DEFAULT_THREAD then
        l_result := com_api_const_pkg.TRUE;
    else
        if g_current_split_hash_tab.count = 0 then
            select m.thread_number
                 , m.split_hash
              bulk collect
              into l_thread_number_tab
                 , l_split_hash_tab
              from com_split_map m;

            for i in 1 .. l_split_hash_tab.count loop
                g_current_split_hash_tab(l_split_hash_tab(i)) := l_thread_number_tab(i);
            end loop;
        end if;

        if g_current_split_hash_tab(i_split_hash) = l_thread_number then
            l_result := com_api_const_pkg.TRUE;
        end if;
    end if;

    return l_result;
end check_current_thread_number;

procedure reload_settings is
begin
    g_parallel_degree := nvl(set_ui_value_pkg.get_system_param_n(i_param_name => 'PARALLEL_DEGREE'), com_api_const_pkg.DEFAULT_SPLIT_HASH);
    g_split_degree    := nvl(set_ui_value_pkg.get_system_param_n(i_param_name => 'SPLIT_DEGREE'),    com_api_const_pkg.DEFAULT_SPLIT_HASH);
end;

begin
    reload_settings;
end com_api_hash_pkg;
/
