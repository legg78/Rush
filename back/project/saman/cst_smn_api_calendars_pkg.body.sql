create or replace package body cst_smn_api_calendars_pkg is
/**********************************************************
 * Specific operations with Gregorian and Jalali calendars
 *
 * Created by Gogolev I.(i.gogolev@bpcbt.com) at 22.02.2018<br />
 * <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: CST_SMN_API_CALENDARS_PKG
 * @headcom
 **********************************************************/
type t_byte_var_tab     is table of com_api_type_pkg.t_byte_id;

AGGR_DAYS_IN_YEAR           constant t_byte_var_tab := t_byte_var_tab(0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334);
AGGR_DAYS_IN_LEAP_YEAR      constant t_byte_var_tab := t_byte_var_tab(0, 31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335);
FARVARDIN_DAY_DIFF          constant com_api_type_pkg.t_tiny_id := 79;
AGGR_JAL_DAYS_IN_YEAR       constant t_byte_var_tab := t_byte_var_tab(31, 62, 93, 124, 155, 186, 216, 246, 276, 306, 336, 365);

function year_is_leap(
    i_year      in  com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_boolean is
    l_result    com_api_type_pkg.t_boolean;
begin
    if (mod(i_year, 100) <> 0 and mod(i_year, 4) = 0) 
        or (mod(i_year, 100) = 0 and mod(i_year, 400) = 0)
    then
        l_result := com_api_const_pkg.TRUE;
    else
        l_result := com_api_const_pkg.FALSE;
    end if;
    
    return l_result;
end year_is_leap;

procedure convert_gregorian_to_jalali(
    i_gregorian_date        in  date
  , o_jalali_dd             out com_api_type_pkg.t_byte_char
  , o_jalali_mm             out com_api_type_pkg.t_byte_char
  , o_jalali_yy             out com_api_type_pkg.t_byte_char
  , o_jalali_cc             out com_api_type_pkg.t_byte_char
) is    
    l_gregorian_yyyy    com_api_type_pkg.t_tiny_id;
    l_gregorian_mm      com_api_type_pkg.t_tiny_id;
    l_gregorian_dd      com_api_type_pkg.t_tiny_id;
    
    l_day_count         com_api_type_pkg.t_tiny_id;
    l_dey_day_diff      com_api_type_pkg.t_tiny_id;
begin
    if i_gregorian_date is not null then
        l_gregorian_yyyy := to_char(i_gregorian_date, 'yyyy');
        l_gregorian_mm   := to_char(i_gregorian_date, 'mm');
        l_gregorian_dd   := to_char(i_gregorian_date, 'dd');

        if year_is_leap(i_year => l_gregorian_yyyy) = com_api_const_pkg.TRUE then
            l_day_count := AGGR_DAYS_IN_LEAP_YEAR(l_gregorian_mm) + l_gregorian_dd;
        else
            l_day_count := AGGR_DAYS_IN_YEAR(l_gregorian_mm) + l_gregorian_dd;
        end if;
        
        if year_is_leap(i_year => l_gregorian_yyyy - 1) = com_api_const_pkg.TRUE then
            l_dey_day_diff := 11;
        else
            l_dey_day_diff := 10;
        end if;
        
        if l_day_count > FARVARDIN_DAY_DIFF then
            l_day_count := l_day_count - FARVARDIN_DAY_DIFF;
            if l_day_count <= 186 then
                case mod(l_day_count, 31)
                    when 0
                        then
                            o_jalali_mm := lpad(to_char(l_day_count / 31), 2, '0');
                            o_jalali_dd := 31;
                    else
                        o_jalali_mm := lpad(to_char(floor(l_day_count / 31) + 1), 2, '0');
                        o_jalali_dd := lpad(to_char(mod(l_day_count, 31)), 2, '0');
                end case;
            else
                l_day_count := l_day_count - 186;
                case mod(l_day_count, 30)
                    when 0
                        then
                            o_jalali_mm := lpad(to_char((l_day_count / 30) + 6), 2, '0');
                            o_jalali_dd := 30;
                    else
                        o_jalali_mm := lpad(to_char(floor(l_day_count / 30) + 7), 2, '0');
                        o_jalali_dd := lpad(to_char(mod(l_day_count, 30)), 2, '0');
                end case;
            end if;
            o_jalali_cc := lpad(substr((l_gregorian_yyyy - 621), 1, 2), 2, '0');
            o_jalali_yy := lpad(substr((l_gregorian_yyyy - 621), 3, 2), 2, '0');
        else
            l_day_count := l_day_count + l_dey_day_diff;

            case mod(l_day_count, 30)
                when 0
                    then
                o_jalali_mm := lpad(to_char((l_day_count / 30) + 9), 2, '0');
                o_jalali_dd :=  30;
                else
                o_jalali_mm := lpad(to_char(floor(l_day_count / 30) + 10), 2, '0');
                o_jalali_dd := lpad(to_char(mod(l_day_count, 30)), 2, '0');
            end case;
            o_jalali_cc := lpad(substr((l_gregorian_yyyy - 622), 1, 2), 2, '0');
            o_jalali_yy := lpad(substr((l_gregorian_yyyy - 622), 3, 2), 2, '0');
        end if;
    end if;

end convert_gregorian_to_jalali;

procedure convert_jalali_to_gregorian(
    i_jalali_dd             in  com_api_type_pkg.t_byte_char
  , i_jalali_mm             in  com_api_type_pkg.t_byte_char
  , i_jalali_yy             in  com_api_type_pkg.t_byte_char
  , i_jalali_cc             in  com_api_type_pkg.t_byte_char
  , o_gregorian_date        out date
) is   
    l_gregor_month_days         t_byte_var_tab := t_byte_var_tab(31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
    
    l_gregorian_yyyy    com_api_type_pkg.t_attr_name;
    l_gregorian_mm      com_api_type_pkg.t_attr_name;
    l_gregorian_dd      com_api_type_pkg.t_attr_name;
    
    l_day_count         com_api_type_pkg.t_tiny_id;
    l_jalali_dd         com_api_type_pkg.t_tiny_id;
    l_jalali_mm         com_api_type_pkg.t_tiny_id;
    l_jalali_yyyy       com_api_type_pkg.t_tiny_id;
    
    l_yyyy              com_api_type_pkg.t_tiny_id;
    l_mm                com_api_type_pkg.t_tiny_id;
begin
    if i_jalali_dd is not null
        and i_jalali_mm is not null
        and i_jalali_yy is not null
        and i_jalali_cc is not null
    then
        l_jalali_dd   := to_number(i_jalali_dd);
        l_jalali_mm   := to_number(i_jalali_mm);
        l_jalali_yyyy := to_number(i_jalali_cc||i_jalali_yy);
        l_day_count := l_jalali_dd;
        if  l_jalali_mm > 1 then
            l_day_count := l_day_count + AGGR_JAL_DAYS_IN_YEAR(l_jalali_mm - 1);
        end if;
        l_yyyy := l_jalali_yyyy + 621;
        l_day_count := l_day_count + 79;
        if year_is_leap(i_year => l_yyyy) = com_api_const_pkg.TRUE then
            l_gregor_month_days(2) := 29;
            if l_day_count > 366 then
                l_day_count := l_day_count - 366;
                l_yyyy := l_yyyy + 1;
            end if;
        elsif  l_day_count > 365 then
            l_day_count := l_day_count - 365;
            l_yyyy := l_yyyy + 1;
        end if;
        l_mm := 1;
        while l_mm <= l_gregor_month_days.count and l_day_count > l_gregor_month_days(l_mm)
        loop
            l_day_count := l_day_count - l_gregor_month_days(l_mm);
            l_mm := l_mm + 1;
        end loop;
        l_gregorian_yyyy := to_char(l_yyyy);
        l_gregorian_mm   := lpad(to_char(l_mm), 2, '0');
        l_gregorian_dd   := lpad(to_char(l_day_count), 2, '0');
        
        o_gregorian_date := to_date(l_gregorian_yyyy || '-' || l_gregorian_mm || '-' || l_gregorian_dd, 'yyyy-mm-dd');
    end if;
    
end convert_jalali_to_gregorian;

function get_short_jalali_date_str(
    i_gregorian_date        in  com_api_type_pkg.t_date_long
  , i_gregorian_format      in  com_api_type_pkg.t_date_long    default com_api_const_pkg.DATE_FORMAT
) return com_api_type_pkg.t_date_short
is
    l_jalali_dd     com_api_type_pkg.t_byte_char;
    l_jalali_mm     com_api_type_pkg.t_byte_char;
    l_jalali_yy     com_api_type_pkg.t_byte_char;
    l_jalali_cc     com_api_type_pkg.t_byte_char;
    
    l_gregorian_date    date;
begin
    l_gregorian_date := to_date(i_gregorian_date, nvl(i_gregorian_format, com_api_const_pkg.DATE_FORMAT));
    convert_gregorian_to_jalali(
        i_gregorian_date => l_gregorian_date
      , o_jalali_dd      => l_jalali_dd
      , o_jalali_mm      => l_jalali_mm
      , o_jalali_yy      => l_jalali_yy
      , o_jalali_cc      => l_jalali_cc
    );
    return l_jalali_yy||l_jalali_mm||l_jalali_dd;
end get_short_jalali_date_str;

function get_jalali_date_str(
    i_gregorian_date        in  date
  , i_jalali_format         in  t_date_full default JAL_DEF_DATE_FORMAT
) return t_date_full
is
    LOG_PREFIX      constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_jalali_date_str: ';
    
    l_jalali_dd     com_api_type_pkg.t_byte_char;
    l_jalali_mm     com_api_type_pkg.t_byte_char;
    l_jalali_yy     com_api_type_pkg.t_byte_char;
    l_jalali_cc     com_api_type_pkg.t_byte_char;
    
    l_jalali_date       t_date_full;
    l_jalali_format     t_date_full := nvl(i_jalali_format, JAL_DEF_DATE_FORMAT);
begin
    convert_gregorian_to_jalali(
        i_gregorian_date => i_gregorian_date
      , o_jalali_dd      => l_jalali_dd
      , o_jalali_mm      => l_jalali_mm
      , o_jalali_yy      => l_jalali_yy
      , o_jalali_cc      => l_jalali_cc
    );
    
    if l_jalali_dd is not null
        and l_jalali_mm is not null
        and l_jalali_yy is not null
        and l_jalali_cc is not null
    then
        l_jalali_date := replace(
                             replace(
                                 replace(
                                     replace(
                                         l_jalali_format
                                       , JAL_CENTURY_FORMAT_CHAR
                                       , l_jalali_cc
                                     )
                                   , JAL_YEAR_FORMAT_CHAR
                                   , l_jalali_yy
                                 )
                               , JAL_MONTH_FORMAT_CHAR
                               , l_jalali_mm
                             )
                           , JAL_DAY_FORMAT_CHAR
                           , l_jalali_dd
                         )
        ;
    else
        trc_log_pkg.debug(
            i_text        => LOG_PREFIX || 'Invalid Gregorian date - date [#1]'
          , i_env_param1  => i_gregorian_date
        );
    end if;
    if regexp_like(l_jalali_date, '[a-zA-Z]')
        or not regexp_like(l_jalali_date, '[0-9]')
        or regexp_like(l_jalali_date, '[^0-9:/.-]')
    then
        trc_log_pkg.debug(
            i_text        => LOG_PREFIX || 'Invalid Jalali date format - date [#1] format [#2]'
          , i_env_param1  => l_jalali_date
          , i_env_param2  => l_jalali_format
        );
        l_jalali_date := null;
    end if;
    return l_jalali_date;
end get_jalali_date_str;

function get_gregorian_from_jalali_str(
    i_jalali_str    in  t_date_full
  , i_jalali_format in  t_date_full default JAL_DEF_DATE_FORMAT
) return date
is
    LOG_PREFIX      constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_gregorian_from_jalali_str: ';
    
    l_jalali_dd     com_api_type_pkg.t_byte_char;
    l_jalali_mm     com_api_type_pkg.t_byte_char;
    l_jalali_yy     com_api_type_pkg.t_byte_char;
    l_jalali_cc     com_api_type_pkg.t_byte_char;
    
    l_gregorian_date    date;
    l_pos               com_api_type_pkg.t_byte_id := 1;
begin
    while l_pos < length(i_jalali_str) and l_pos < length(i_jalali_format)
    loop
        case upper(substr(i_jalali_format, l_pos, 2))
            when JAL_DAY_FORMAT_CHAR
                then l_jalali_dd := substr(i_jalali_str, l_pos, 2);
            when JAL_MONTH_FORMAT_CHAR
                then l_jalali_mm := substr(i_jalali_str, l_pos, 2);
            when JAL_YEAR_FORMAT_CHAR
                then l_jalali_yy := substr(i_jalali_str, l_pos, 2);
            when JAL_CENTURY_FORMAT_CHAR
                then l_jalali_cc := substr(i_jalali_str, l_pos, 2);
            else
                null;
        end case;
        l_pos := l_pos + 2;
        if regexp_like(substr(i_jalali_format, l_pos, 1), '[^a-zA-Z]') 
            and regexp_like(substr(i_jalali_str, l_pos, 1), '[^0-9]') 
            and substr(i_jalali_format, l_pos, 1) = substr(i_jalali_str, l_pos, 1) then
            l_pos := l_pos + 1;
        end if;
    end loop;
    if l_jalali_dd is not null
        and l_jalali_mm is not null
        and l_jalali_yy is not null
        and l_jalali_cc is not null
    then
        convert_jalali_to_gregorian(
            i_jalali_dd      => l_jalali_dd
          , i_jalali_mm      => l_jalali_mm
          , i_jalali_yy      => l_jalali_yy
          , i_jalali_cc      => l_jalali_cc
          , o_gregorian_date => l_gregorian_date
        );
    else
        trc_log_pkg.debug(
            i_text        => LOG_PREFIX || 'Invalid Jalali date format - date [#1] format [#2]'
          , i_env_param1  => i_jalali_str
          , i_env_param2  => i_jalali_format
        );
    end if;
    return l_gregorian_date;
end get_gregorian_from_jalali_str;

end cst_smn_api_calendars_pkg;
/
