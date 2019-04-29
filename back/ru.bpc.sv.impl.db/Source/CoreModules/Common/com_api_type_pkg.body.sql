create or replace package body com_api_type_pkg is
/****************************************************************
* The common types and constants                           <br />
* Created by Filimonov A.(filimonov@bpc.ru)  at 08.07.2009 <br />
* Module: COM_API_TYPE_PKG                                 <br />
* @headcom                                                 <br />
*****************************************************************/

function boolean_not (
    i_argument          in     t_boolean
) return t_boolean is
begin
    return
        case i_argument
            when com_api_type_pkg.TRUE  then com_api_type_pkg.FALSE
            when com_api_type_pkg.FALSE then com_api_type_pkg.TRUE
        end;
end;

function invert_sign (
    i_argument          in     t_sign
) return t_sign is
begin
    return
        case i_argument
            when CREDIT then DEBIT
            when DEBIT  then CREDIT
                        else i_argument
        end;
end;

function convert_to_char (
    n                   in     number
) return varchar2 is
    l_result    t_name;
begin
    l_result := to_char(n, com_api_const_pkg.NUMBER_FORMAT);

    if l_result like '#%' then
        com_api_error_pkg.raise_error (
            i_error         => 'BAD_NUMBER'
            , i_env_param1  => n
        );
    else
        return l_result;
    end if;
end;

function convert_to_char (
    d                   in     date
) return varchar2 is
begin
    return to_char(d, com_api_const_pkg.DATE_FORMAT);
end;

function convert_to_char(
    i_data_type         in     t_dict_value
  , i_value_char        in     varchar2
  , i_value_num         in     number
  , i_value_date        in     date
) return varchar2
is
begin
    return
        case i_data_type
            when com_api_const_pkg.DATA_TYPE_NUMBER then convert_to_char(i_value_num)
            when com_api_const_pkg.DATA_TYPE_DATE   then convert_to_char(i_value_date)
                                                    else i_value_char
        end;
end convert_to_char;

function convert_to_number (
    s                   in     varchar2
  , i_mask_error        in     t_boolean                  default com_api_type_pkg.FALSE
  , i_format            in     varchar2                   default null
) return number is
begin
    if i_format is not null then
        return to_number(s, i_format);
    else
        return to_number(s, com_api_const_pkg.NUMBER_FORMAT);
    end if;
exception
    when com_api_error_pkg.e_invalid_number or com_api_error_pkg.e_value_error then
        if i_mask_error = com_api_type_pkg.TRUE then
            trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.convert_to_number FAILED for [' || s || ']');
            return null;
        else
            raise;
        end if;
end;

function convert_to_date (
    s                   in     varchar2
) return date is
begin
    return to_date(s, com_api_const_pkg.DATE_FORMAT);
end;

procedure nop is
begin
    null;
end;

function to_bool(
    i_statement         in     boolean
) return t_boolean is
begin
    return
        case
            when i_statement
            then com_api_const_pkg.TRUE
            else com_api_const_pkg.FALSE
        end;
end;

function get_number_value(
    i_data_type         in      t_dict_value
  , i_value             in      t_name
  , i_format            in      t_name          default null
) return number is
begin

    if i_data_type = com_api_const_pkg.DATA_TYPE_NUMBER then
        return convert_to_number(
                   s           => i_value
                 , i_format    => i_format
               );
    else
        return to_number(null);
    end if;

exception
    when com_api_error_pkg.e_invalid_number or com_api_error_pkg.e_value_error then
        return to_number(null);
end;

function get_char_value(
    i_data_type         in      t_dict_value
  , i_value             in      t_name
) return t_name is
begin

    if i_data_type = com_api_const_pkg.DATA_TYPE_CHAR then
        return i_value;
    else
        return to_char(null);
    end if;

end;

function get_date_value(
    i_data_type         in      t_dict_value
  , i_value             in      t_name
) return date is
begin

    if i_data_type = com_api_const_pkg.DATA_TYPE_DATE then
        return convert_to_date(i_value);
    else
        return to_date(null);
    end if;

exception
    when others then
        return to_date(null);
end;

function get_lov_value(
    i_data_type         in      t_dict_value
  , i_value             in      t_name
  , i_lov_id            in      t_tiny_id
) return t_text is
    l_sql_source        t_text;
    l_appearance        t_dict_value;
    l_result            t_text;
begin

    if i_lov_id is not null and i_value is not null then
        begin
            select nvl2(
                      dict
                    , 'select distinct dict||code code, get_text(''com_dictionary'', ''name'', id ) name from com_dictionary where dict = '''||dict||''''
                    , nvl(lov_query, 'select to_char(null) code, to_char(null) name from dual where 1=0')
                   )
                 , appearance
              into l_sql_source
                 , l_appearance
              from com_lov_vw
             where id = i_lov_id;
        exception
            when no_data_found then
                null;
        end;

        case nvl(l_appearance, com_api_const_pkg.LOV_APPEARANCE_DEFAULT)
            when com_api_const_pkg.LOV_APPEARANCE_NAME then l_sql_source := 'select name from (' || l_sql_source || ') i';
            when com_api_const_pkg.LOV_APPEARANCE_CODE then l_sql_source := 'select code name from (' || l_sql_source || ') i';
            when com_api_const_pkg.LOV_APPEARANCE_CODE_NAME then l_sql_source := 'select code || '' - '' || name name from (' || l_sql_source || ') i';
            when com_api_const_pkg.LOV_APPEARANCE_NAME_CODE then l_sql_source := 'select name || '' - '' || code name from (' || l_sql_source || ') i';
        end case;

        if i_data_type = com_api_const_pkg.DATA_TYPE_CHAR then
            l_sql_source :=  l_sql_source || ' where i.code=''' || i_value || ''' and rownum = 1';
        elsif i_data_type = com_api_const_pkg.DATA_TYPE_NUMBER then
            l_sql_source :=  l_sql_source || ' where i.code=' || i_value || ' and rownum = 1';
        else
            l_sql_source := null;
        end if;

        if l_sql_source is not null then
            begin
                execute immediate l_sql_source into l_result;
            exception
                when no_data_found then
                    null;
                when others then
                    com_api_error_pkg.raise_error(
                        i_error       => 'EXEC_LOV_QUERY_ERROR'
                      , i_env_param1  => substr(l_sql_source, 1, 2000)
                      , i_env_param2  => substr(SQLERRM, 1, 200)
                    );
            end;
        end if;
    end if;

    return l_result;
end;

function num2str(
    i_source            in      t_money
  , i_lang              in      t_dict_value
  , i_currency          in      t_curr_code
) return t_name is
    l_result         t_name;
begin
    if i_source < 1 then
        l_result := get_label_text('NUM2STR_0',upper(i_lang)) || ltrim(to_char(i_source
                   ,'9,9,,9,,,,,,9,9,,9,,,,,9,9,,9,,,,9,9,,9,,,.99')) || 'k';
    else
        l_result := ltrim(to_char(i_source
                   ,'9,9,,9,,,,,,9,9,,9,,,,,9,9,,9,,,,9,9,,9,,,.99')) || 'k';
    end if;

    l_result := replace(l_result
                     ,',,,,,,'
                     ,'eM');
    l_result := replace(l_result
                     ,',,,,,'
                     ,'em');
    l_result := replace(l_result
                     ,',,,,'
                     ,'et');

    l_result := replace(l_result
                     ,',,,'
                     ,'e');
    l_result := replace(l_result
                     ,',,'
                     ,'d');
    l_result := replace(l_result
                     ,','
                     ,'c');

    l_result := replace(l_result
                     ,'0c0d0et'
                     ,'');
    l_result := replace(l_result
                     ,'0c0d0em'
                     ,'');
    l_result := replace(l_result
                     ,'0c0d0eM'
                     ,'');

    l_result := replace(l_result
                     ,'0c'
                     ,'');
    l_result := replace(l_result
                     ,'1c'
                     ,get_label_text('NUM2STR_100', upper(i_lang)));
    l_result := replace( l_result
                     ,'2c'
                     ,get_label_text('NUM2STR_200', upper(i_lang)));
    l_result := replace( l_result
                     ,'3c'
                     ,get_label_text('NUM2STR_300', upper(i_lang)));
    l_result := replace( l_result
                     ,'4c'
                     ,get_label_text('NUM2STR_400', upper(i_lang)));
    l_result := replace( l_result
                     ,'5c'
                     ,get_label_text('NUM2STR_500', upper(i_lang)));
    l_result := replace( l_result
                     ,'6c'
                     ,get_label_text('NUM2STR_600', upper(i_lang)));
    l_result := replace( l_result
                     ,'7c'
                     ,get_label_text('NUM2STR_700', upper(i_lang)));
    l_result := replace( l_result
                     ,'8c'
                     ,get_label_text('NUM2STR_800', upper(i_lang)));
    l_result := replace( l_result
                     ,'9c'
                     ,get_label_text('NUM2STR_900', upper(i_lang)));

    l_result := replace( l_result
                     ,'1d0e'
                     ,get_label_text('NUM2STR_10', upper(i_lang)));
    l_result := replace( l_result
                     ,'1d1e'
                     ,get_label_text('NUM2STR_11', upper(i_lang)));
    l_result := replace( l_result
                     ,'1d2e'
                     ,get_label_text('NUM2STR_12', upper(i_lang)));
    l_result := replace( l_result
                     ,'1d3e'
                     ,get_label_text('NUM2STR_13', upper(i_lang)));
    l_result := replace( l_result
                     ,'1d4e'
                     ,get_label_text('NUM2STR_14', upper(i_lang)));
    l_result := replace( l_result
                     ,'1d5e'
                     ,get_label_text('NUM2STR_15', upper(i_lang)));
    l_result := replace( l_result
                     ,'1d6e'
                     ,get_label_text('NUM2STR_16', upper(i_lang)));
    l_result := replace( l_result
                     ,'1d7e'
                     ,get_label_text('NUM2STR_17', upper(i_lang)));
    l_result := replace( l_result
                     ,'1d8e'
                     ,get_label_text('NUM2STR_18', upper(i_lang)));
    l_result := replace( l_result
                     ,'1d9e'
                     ,get_label_text('NUM2STR_19', upper(i_lang)));
    l_result := replace( l_result
                     ,'0d'
                     ,'');
    l_result := replace( l_result
                     ,'2d'
                     ,get_label_text('NUM2STR_20', upper(i_lang)));
    l_result := replace( l_result
                     ,'3d'
                     ,get_label_text('NUM2STR_30', upper(i_lang)));
    l_result := replace( l_result
                     ,'4d'
                     ,get_label_text('NUM2STR_40', upper(i_lang)));
    l_result := replace( l_result
                     ,'5d'
                     ,get_label_text('NUM2STR_50', upper(i_lang)));
    l_result := replace( l_result
                     ,'6d'
                     ,get_label_text('NUM2STR_60', upper(i_lang)));
    l_result := replace( l_result
                     ,'7d'
                     ,get_label_text('NUM2STR_70', upper(i_lang)));
    l_result := replace( l_result
                     ,'8d'
                     ,get_label_text('NUM2STR_80', upper(i_lang)));
    l_result := replace( l_result
                     ,'9d'
                     ,get_label_text('NUM2STR_90', upper(i_lang)));

    l_result := replace( l_result
                     ,'0e'
                     ,'');
    l_result := replace( l_result
                     ,'5e'
                     ,get_label_text('NUM2STR_5', upper(i_lang)));
    l_result := replace( l_result
                     ,'6e'
                     ,get_label_text('NUM2STR_6', upper(i_lang)));
    l_result := replace( l_result
                     ,'7e'
                     ,get_label_text('NUM2STR_7', upper(i_lang)));
    l_result := replace( l_result
                     ,'8e'
                     ,get_label_text('NUM2STR_8', upper(i_lang)));
    l_result := replace( l_result
                     ,'9e'
                     ,get_label_text('NUM2STR_9', upper(i_lang)));
    --
    l_result := replace( l_result
                     ,'1e.'
                     ,get_label_text('NUM2STR_1', upper(i_lang)));
    l_result := replace( l_result
                     ,'2e.'
                     ,get_label_text('NUM2STR_2', upper(i_lang)));
    l_result := replace( l_result
                     ,'3e.'
                     ,get_label_text('NUM2STR_3', upper(i_lang)));
    l_result := replace( l_result
                     ,'4e.'
                     ,get_label_text('NUM2STR_4', upper(i_lang)));
    l_result := replace( l_result
                     ,'1et'
                     ,get_label_text('NUM2STR_1000', upper(i_lang)));
    l_result := replace( l_result
                     ,'2et'
                     ,get_label_text('NUM2STR_2000', upper(i_lang)));
    l_result := replace( l_result
                     ,'3et'
                     ,get_label_text('NUM2STR_3000', upper(i_lang)));
    l_result := replace( l_result
                     ,'4et'
                     ,get_label_text('NUM2STR_4000', upper(i_lang)));
    l_result := replace( l_result
                     ,'1em'
                     ,get_label_text('NUM2STR_1M', upper(i_lang)));
    l_result := replace( l_result
                     ,'2em'
                     ,get_label_text('NUM2STR_2M', upper(i_lang)));
    l_result := replace( l_result
                     ,'3em'
                     ,get_label_text('NUM2STR_3M', upper(i_lang)));
    l_result := replace( l_result
                     ,'4em'
                     ,get_label_text('NUM2STR_4M', upper(i_lang)));
    l_result := replace( l_result
                     ,'1eM'
                     ,get_label_text('NUM2STR_1B', upper(i_lang)));
    l_result := replace( l_result
                     ,'2eM'
                     ,get_label_text('NUM2STR_2B', upper(i_lang)));
    l_result := replace( l_result
                     ,'3eM'
                     ,get_label_text('NUM2STR_3B', upper(i_lang)));
    l_result := replace( l_result
                     ,'4eM'
                     ,get_label_text('NUM2STR_4B', upper(i_lang)));

    l_result := replace( l_result
                     ,'11k'
                     ,get_label_text('NUM2STR_011', upper(i_lang)));
    l_result := replace( l_result
                     ,'12k'
                     ,get_label_text('NUM2STR_012', upper(i_lang)));
    l_result := replace( l_result
                     ,'13k'
                     ,get_label_text('NUM2STR_013', upper(i_lang)));
    l_result := replace( l_result
                     ,'14k'
                     ,get_label_text('NUM2STR_014', upper(i_lang)));
    l_result := replace( l_result
                     ,'1k'
                     ,get_label_text('NUM2STR_01', upper(i_lang)));
    l_result := replace( l_result
                     ,'2k'
                     ,get_label_text('NUM2STR_02', upper(i_lang)));
    l_result := replace( l_result
                     ,'3k'
                     ,get_label_text('NUM2STR_03', upper(i_lang)));
    l_result := replace( l_result
                     ,'4k'
                     ,get_label_text('NUM2STR_04', upper(i_lang)));

    l_result := replace( l_result
                     ,'.'
                     ,get_label_text('NUM2STR_END1', upper(i_lang)));
    l_result := replace( l_result
                     ,'t'
                     ,get_label_text('NUM2STR_END2', upper(i_lang)));
    l_result := replace( l_result
                     ,'m'
                     ,get_label_text('NUM2STR_END3', upper(i_lang)));
    l_result := replace( l_result
                     ,'M'
                     ,get_label_text('NUM2STR_END4', upper(i_lang)));
    l_result := replace( l_result
                     ,'k'
                     ,get_label_text('NUM2STR_END0', upper(i_lang)));

        -- Get currency form
    for i in 1..6
    loop
        l_result := replace(l_result, '[#' || to_char(i) || ']', get_label_text(i_currency || '_WORDFORM_' || to_char(i)));
    end loop;

    return upper(substr(l_result, 1,1)) || substr(l_result,2);

end num2str;

function pad_number (
    i_data              in     varchar2
  , i_min_length        in     integer
  , i_max_length        in     integer
) return varchar2 is
begin
    case
        when nvl(length(i_data), 0) < i_min_length then return lpad(nvl(i_data, '0'), i_min_length, '0');
        when nvl(length(i_data), 0) > i_max_length then return substr(i_data, - i_max_length);
        else return i_data;
    end case;
end;

function pad_char (
    i_data              in     varchar2
  , i_min_length        in     integer
  , i_max_length        in     integer
) return varchar2 is
begin
    case
        when nvl(length(i_data), 0) < i_min_length then return rpad(nvl(i_data, ' '), i_min_length, ' ');
        when nvl(length(i_data), 0) > i_max_length then return substr(i_data, 1, i_max_length);
        else return i_data;
    end case;
end;

function reverse_value(
    i_value             in     t_name
) return t_name is
    l_result                   t_name;
    l_length                   binary_integer := length(i_value);
begin
    for i in 1 .. l_length loop
        l_result := l_result || substr(i_value, -i, 1);
    end loop;
    return l_result;
end;

-- Get the "long_id" array from the input string.
procedure get_array_from_string(
    i_string            in     t_full_desc
  , o_array                out t_long_tab
) is
    l_string                   t_full_desc;
    l_value                    t_long_id;
    l_pos                      t_tiny_id;
    l_index                    t_tiny_id    := 0;
begin
   l_string  := i_string;
   while length(l_string) > 0 loop
       l_pos := instr(l_string, ',');
       if l_pos > 0  then
           l_value  := substr(l_string, 1, l_pos - 1);
           l_string := substr(l_string, l_pos + 1, length(l_string) - l_pos);
       else
           l_value  := l_string;
           l_string := '';
       end if;

       l_index          := l_index + 1;
       o_array(l_index) := l_value;
   end loop;
end get_array_from_string;

-- Get the "full_desc" array from the input string.
procedure get_array_from_string(
    i_string            in     t_full_desc
  , o_array                out t_desc_tab
) is
    l_string                   t_full_desc;
    l_value                    t_full_desc;
    l_pos                      t_tiny_id;
    l_index                    t_tiny_id    := 0;
begin
   l_string  := i_string;
   while length(l_string) > 0 loop
       l_pos := instr(l_string, ',');
       if l_pos > 0  then
           l_value  := substr(l_string, 1, l_pos - 1);
           l_string := substr(l_string, l_pos + 1, length(l_string) - l_pos);
       else
           l_value  := l_string;
           l_string := '';
       end if;

       l_index          := l_index + 1;
       o_array(l_index) := l_value;
   end loop;
end get_array_from_string;

end com_api_type_pkg;
/
