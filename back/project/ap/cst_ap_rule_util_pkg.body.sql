create or replace package body cst_ap_rule_util_pkg is
/*********************************************************
*  Custom tags parsing  <br />
*  Created by Vasilyeva Y.(vasilieva@bpcsv.com)  at 21.06.2016 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: cst_sat_recon_upload <br />
*  @headcom
**********************************************************/

type t_addl_data is record(
    addl_data_tag        com_api_type_pkg.t_postal_code  -- nuber PDS
  , addl_data_tag_len    com_api_type_pkg.t_long_id      -- length PDS
  , addl_data_Value      com_api_type_pkg.t_param_value   -- vaue PDS
);  
  
type t_addl_data_table   is table of t_addl_data index by binary_integer;

g_addl_data_parsed       t_addl_data_table;
g_addl_data_str          com_api_type_pkg.t_param_value;

procedure parse_auth_addl_data(
    i_addl_data_str            com_api_type_pkg.t_param_value
  , i_addl_data_total_len      com_api_type_pkg.t_long_id
  , i_addl_data_tag_Length     com_api_type_pkg.t_long_id
  , i_addl_data_val_Length     com_api_type_pkg.t_long_id
  , i_addl_data_string_length  com_api_type_pkg.t_long_id    default null
) is
  
  l_cur_addl_data_str com_api_type_pkg.t_param_value; 
  l_cur_position      com_api_type_pkg.t_long_id;     
  l_cur_addl_data     t_addl_data;
begin
    g_addl_data_parsed.delete;
    if i_addl_data_string_length is not null 
        and length(i_addl_data_str) - i_addl_data_total_len <> i_addl_data_string_length then 
        trc_log_pkg.error(
            i_text        => 'Real length of additional dat string is [#1] doesn''t equal potential length [#2]'
          , i_env_param1  => i_addl_data_string_length
          , i_env_param2  => length(i_addl_data_str) - i_addl_data_total_len
        );
    else
        l_cur_addl_data_str := substr(i_addl_data_str, i_addl_data_total_len + 1);
        g_addl_data_str := i_addl_data_str;
        loop
            exit when nvl(length(l_cur_addl_data_str), 0) = 0;
            l_cur_position := 1;
            l_cur_addl_data.addl_data_tag := substr(l_cur_addl_data_str, l_cur_position, i_addl_data_tag_Length);  --cut tag and get tag value
            l_cur_position := i_addl_data_tag_Length + 1;
            l_cur_addl_data.addl_data_tag_len := to_number(substr(l_cur_addl_data_str, l_cur_position, i_addl_data_val_Length));  --get length of PDS value
            l_cur_position := l_cur_position + i_addl_data_val_Length;
            l_cur_addl_data.addl_data_Value := substr(l_cur_addl_data_str, l_cur_position, l_cur_addl_data.addl_data_tag_len);  --get PDS value
            g_addl_data_parsed(nvl(g_addl_data_parsed.last + 1, 1)) := l_cur_addl_data;  --put to collection
            l_cur_addl_data_str := substr(l_cur_addl_data_str, l_cur_position+l_cur_addl_data.addl_data_tag_len); --cut parsed part
        end loop;
    end if;
end;
  
function get_auth_addl_data_val(
    i_addl_data_tag com_api_type_pkg.t_postal_code
) return t_addl_data is
    l_addl_data t_addl_data;
begin
    if g_addl_data_parsed.count>0 then
        for i in g_addl_data_parsed.first..g_addl_data_parsed.last 
        loop
            if g_addl_data_parsed(i).addl_data_tag = i_addl_data_tag then
                l_addl_data := g_addl_data_parsed(i);
                exit;
            end if;
        end loop;
    end if;
    return l_addl_data;
end;
                           
function get_auth_addl_data(
    i_addl_data_str             com_api_type_pkg.t_param_value
  , i_addl_data_tag             com_api_type_pkg.t_postal_code
  , i_addl_data_string_length   com_api_type_pkg.t_long_id    default null
) return varchar2 
is
    l_addl_data_value  t_addl_data;      
begin
    if g_addl_data_str <> i_addl_data_str or g_addl_data_str is null then
        parse_auth_addl_data (
            i_addl_data_str            => i_addl_data_str
          , i_addl_data_total_len      => 3 --length of the string (first 3 symbols)
          , i_addl_data_tag_Length     => 3 --length of tag
          , i_addl_data_val_Length     => 2 --length of the value
          , i_addl_data_string_length  => i_addl_data_string_length
        );
    end if;
    l_addl_data_value := get_auth_addl_data_val(
        i_addl_data_tag => i_addl_data_tag
    );
    return l_addl_data_value.addl_data_Value;
end; 
  

end cst_ap_rule_util_pkg;
/
