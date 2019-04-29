create or replace package cst_util_pkg is

/**
*   Function of forming the amount in words
*   At the input, it takes a numeric value of the format 123456789012.12
*   That is, no more than 15 characters in length, together with a separator
*   and fractional part. Fractional part may be absent.
*   At the output of the function, a string is formed with the sum in words.
*/
function get_sum_str(
    i_data in number
) return varchar2;

/**
*   Function of formatting a date with the name of the month in the desired case
*/
function get_formated_date(
    i_date in date default sysdate
) return varchar2;

/**
*   The operation is customs
*/
function is_custom(
    i_oper_id in com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_boolean;

/**
*   The operation is not financial
*/
function is_nonfinancial(
    i_oper_type in com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_boolean;

    -- Cyberplat operation 
function is_cyberplat(
    i_oper_id in     com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_boolean;

-- is tag exists
function is_tag_exists(
    i_oper_id in    com_api_type_pkg.t_long_id
  , i_tag_id  in    com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_boolean;

/**
*   The function checks whether the NSCP-shnoy operation is in terms of emission or acquiring
*/
function is_nspk(
    i_oper_id in com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_boolean;

/**
*   The function of obtaining the serial number of the created file with the transferred type for the current day
*   @param i_inst_id - the institution within which counting is done
*   @param i_file_type - file type
*/
function get_next_file_number(
    i_inst_id   in com_api_type_pkg.t_inst_id
  , i_file_type in com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_tiny_id;

end cst_util_pkg;
/
