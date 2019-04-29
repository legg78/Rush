create or replace package body com_api_const_pkg is
--
-- list of constants
--
-- Created by Khougaev A.(khougaev@bpc.ru)  at 09.10.2009
-- Last changed by $Author$
-- $LastChangedDate::$
-- Revision: $LastChangedRevision$
-- Module: COM
-- @headcom

g_separator  com_api_type_pkg.t_name;

procedure set_separator(
    i_separator  in     com_api_type_pkg.t_name
)is
begin
    g_separator := i_separator;
end;

-- Return const to sql query
function get_separator     return  com_api_type_pkg.t_name is
begin
    return nvl(g_separator, ',');
end;

function get_number_format return com_api_type_pkg.t_name is
begin
    return NUMBER_FORMAT;
end;

function get_date_format return com_api_type_pkg.t_name is
begin
    return DATE_FORMAT;
end;

function get_format(
    i_data_type         in          com_api_type_pkg.t_dict_value
) return  com_api_type_pkg.t_name is
begin
    return
        case i_data_type
            when DATA_TYPE_NUMBER then NUMBER_FORMAT
            when DATA_TYPE_DATE   then DATE_FORMAT
            else null
        end;
end;

function get_number_format_with_sep(
    i_number_type in     com_api_type_pkg.t_dict_value default null
) return com_api_type_pkg.t_name 
is
    l_number_format        com_api_type_pkg.t_name;
    l_number_float_format  com_api_type_pkg.t_name;
    l_number_int_format    com_api_type_pkg.t_name;
begin
    case 
        when set_ui_value_pkg.get_user_param_v(i_param_name => 'DIGIT_GROUP_SEPARATOR') in
             (com_api_const_pkg.DIGIT_SEPARATOR_DOTE_EMPTY 
            , com_api_const_pkg.DIGIT_SEPARATOR_COMMA_EMPTY)
        then
            l_number_format       := com_api_const_pkg.NUMBER_FORMAT_DEFAULT;
            l_number_float_format := com_api_const_pkg.NUMBER_FL_FORMAT_DEFAULT;
            l_number_int_format   := com_api_const_pkg.NUMBER_INT_FORMAT_DEFAULT;
        when set_ui_value_pkg.get_user_param_v(i_param_name => 'DIGIT_GROUP_SEPARATOR') in
             (com_api_const_pkg.DIGIT_SEPARATOR_DOTE_COMMA
            , com_api_const_pkg.DIGIT_SEPARATOR_DOTE_SPACE
            , com_api_const_pkg.DIGIT_SEPARATOR_COMMA_DOTE
            , com_api_const_pkg.DIGIT_SEPARATOR_COMMA_SPACE)
        then
            l_number_format       := com_api_const_pkg.NUMBER_FORMAT_GR_SEPARATOR;
            l_number_float_format := com_api_const_pkg.NUMBER_FL_FORMAT_GR_SEPARATOR;
            l_number_int_format   := com_api_const_pkg.NUMBER_INT_FORMAT_GR_SEPARATOR;
        else
            l_number_format       := com_api_const_pkg.NUMBER_FORMAT_DEFAULT;
            l_number_float_format := com_api_const_pkg.NUMBER_FL_FORMAT_DEFAULT;
            l_number_int_format   := com_api_const_pkg.NUMBER_INT_FORMAT_DEFAULT;
    end case;

    case i_number_type
        when 'float' then return l_number_float_format;
        when 'int'   then return l_number_int_format;
        else return l_number_format;
    end case;
end;

function get_number_f_format_with_sep return com_api_type_pkg.t_name 
is
begin
    return get_number_format_with_sep('float');
end;

function get_number_i_format_with_sep return com_api_type_pkg.t_name 
is
begin
    return get_number_format_with_sep('int');
end;

end com_api_const_pkg;
/
