create or replace package cst_smn_api_calendars_pkg is
/******************************************************************
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
 ******************************************************************/
 subtype t_date_full        is com_api_type_pkg.t_name;
 
 JAL_DAY_FORMAT_CHAR        constant com_api_type_pkg.t_byte_char := 'DD';
 JAL_MONTH_FORMAT_CHAR      constant com_api_type_pkg.t_byte_char := 'MM';
 JAL_YEAR_FORMAT_CHAR       constant com_api_type_pkg.t_byte_char := 'YY';
 JAL_CENTURY_FORMAT_CHAR    constant com_api_type_pkg.t_byte_char := 'CC';
 
 JAL_DEF_DATE_FORMAT        constant t_date_full := 'CCYY/MM/DD';
 
/******************************************************************
 * Two procedures perform convert Gregorian date to Jalali 
 * parts of date and backward
 * @params:
 * gregorian_date - date in Gregorian calendar
 * jalali_dd      - number of day in Jalali calendar (two numeric characters)
 * jalali_mm      - month in Jalali calendar (two numeric characters)
 * jalali_yy      - year in Jalali calendar (two numeric characters)
 * jalali_cc      - century in Jalali calendar (two numeric characters)
 ******************************************************************/
procedure convert_gregorian_to_jalali(
    i_gregorian_date        in  date
  , o_jalali_dd             out com_api_type_pkg.t_byte_char
  , o_jalali_mm             out com_api_type_pkg.t_byte_char
  , o_jalali_yy             out com_api_type_pkg.t_byte_char
  , o_jalali_cc             out com_api_type_pkg.t_byte_char
);

procedure convert_jalali_to_gregorian(
    i_jalali_dd             in  com_api_type_pkg.t_byte_char
  , i_jalali_mm             in  com_api_type_pkg.t_byte_char
  , i_jalali_yy             in  com_api_type_pkg.t_byte_char
  , i_jalali_cc             in  com_api_type_pkg.t_byte_char
  , o_gregorian_date        out date
);

/******************************************************************
 * Function perform convert Gregorian date to string of Jalali 
 * date in format YYMMDD
 * @params:
 * gregorian_date - date in Gregorian calendar
 * DD - number of day in Jalali calendar (two numeric characters)
 * MM - month in Jalali calendar (two numeric characters)
 * YY - year in Jalali calendar (two numeric characters)
 ******************************************************************/
function get_short_jalali_date_str(
    i_gregorian_date        in  com_api_type_pkg.t_date_long
  , i_gregorian_format      in  com_api_type_pkg.t_date_long    default com_api_const_pkg.DATE_FORMAT
) return com_api_type_pkg.t_date_short;

/******************************************************************
 * Function perform convert Gregorian date to string of Jalali 
 * date in pointed format
 * @params:
 * gregorian_date - date in Gregorian calendar
 * DD - number of day in Jalali calendar (two numeric characters)
 * MM - month in Jalali calendar (two numeric characters)
 * YY - year in Jalali calendar (two numeric characters)
 * CC - centure in Jalali calendar (two numeric characters)
 ******************************************************************/
function get_jalali_date_str(
    i_gregorian_date        in  date
  , i_jalali_format         in  t_date_full default JAL_DEF_DATE_FORMAT
) return t_date_full;

/******************************************************************
 * Function perform convert string of Jalali date in pointed format
 * to Gregorian date
 * @params:
 * i_jalali_str     - date in Jalali calendar in string
 * i_jalali_format -  format of the Jalali calendar date
 * requirement - format must have all parts of Jalali date: CC,YY,
 * MM,DD
 ******************************************************************/
function get_gregorian_from_jalali_str(
    i_jalali_str    in  t_date_full
  , i_jalali_format in  t_date_full default JAL_DEF_DATE_FORMAT
) return date;

end cst_smn_api_calendars_pkg;
/
