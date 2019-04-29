create or replace package body cst_prc_export_pkg is
/************************************************************
 * Export operation process (L/W/B file) <br />
 * Created by Sidorik R.(sidorik@bpc.ru)  at 10.11.2017 <br />
 * Last changed by $Author: sidorik $ <br />
 * $LastChangedDate:: 2017-11-10 12:45:00 +0400#$ <br />
 * Revision: $LastChangedRevision: 2018-09-05 11:02:00 $ <br />
 * Module: CST_PRC_EXPORT_PKG <br />
 * @headcom
 *************************************************************/

MAX_LWB_RECORDS             constant integer := 200000;
BULK_LIMIT                  constant integer := 1000;
ARR_CONV_ID_TRAN_TYPE_ORIG  constant integer := 5001;
ARR_CONV_ID_TRAN_TYPE_REV   constant integer := 5002;
ARR_CONV_PROC_CODE          constant integer := 5003;
ARR_CREDIT_OPER             constant integer := 10000011;
FLEX_FIELD_UPLOAD_OPERATION constant com_api_type_pkg.t_name := 'UPLOAD_OPERATION';

function conv_array_elem_v(
    i_array_conversion_id in    com_api_type_pkg.t_short_id     default null
  , i_elem_value        in      com_api_type_pkg.t_name
  , i_mask_error        in      com_api_type_pkg.t_boolean := com_api_type_pkg.TRUE
  , i_error_value       in      com_api_type_pkg.t_name := null
) return com_api_type_pkg.t_name is
    l_result            com_api_type_pkg.t_name;
begin
    select e.out_element_value
      into l_result
      from com_array_conversion c
         , com_array_conv_elem  e
     where c.id               = i_array_conversion_id
       and e.conv_id          = c.id
       and e.in_element_value = i_elem_value
       and rownum             = 1;

    return l_result;

exception
    when no_data_found then
        if i_mask_error = com_api_type_pkg.TRUE then
            trc_log_pkg.debug (
                i_text          => 'Conversion array [#1] element [#2] not found, returning default value [#2]'
                , i_env_param1  => i_array_conversion_id
                , i_env_param2  => i_elem_value
                , i_env_param3  => i_error_value
            );
            return i_error_value;
        else
            com_api_error_pkg.raise_error (
                i_error         => 'CONVERSION_ARRAY_ELEMENT_NOT_FOUND'
                , i_env_param1  => i_array_conversion_id
                , i_env_param2  => i_elem_value
                , i_env_param3  => i_error_value
            );
        end if;
end;

--------------------------------------------
--
function s(
    i_len              in pls_integer
  , i_string           in varchar2
) return varchar2 is
begin
    if i_string is null then
        return rpad( ' ', i_len, ' ');
    else
        return rpad(i_string, i_len +   lengthb(i_string)-length(i_string)  , ' ');
    end if;
exception
    when others then
        trc_log_pkg.fatal(
            i_text       => 'Error [#1] in function [#2] with i_len [#3] and i_string [#4]'
          , i_env_param1 => SQLCODE||' - '||SQLERRM
          , i_env_param2 => 'cst_prc_export_pkg.s'
          , i_env_param3 => i_len
          , i_env_param4 => i_string
           );
        raise;
end;

function n(
    i_len              in pls_integer
  , i_num              in number
  , i_justify          in char default 'E' -- L - left(fill with spaces) , R - right(fill with spaces), E - right(fill with zeroes)
  , i_default          in number default null
) return varchar2 is
    l_num     number;
    l_default number;
begin
    l_num     := to_number(i_num);
    l_default := to_number(i_default);

    if nvl(l_num, l_default) is null then
        return rpad( ' ', i_len, ' ');
    else
        case i_justify
            when 'L' then
                return rpad(nvl(l_num, l_default), i_len, ' ');
            when 'R' then
                return lpad(nvl(l_num, l_default), i_len, ' ');
            else--when 'E' then
                return lpad(nvl(l_num, l_default), i_len, '0');
        end case;

    end if;

exception
    when others then
        trc_log_pkg.fatal(
            i_text       => 'Error [#1] in function [#2] with i_len [#3], i_num [#4], i_justify [#5] and i_default [#6]'
          , i_env_param1 => SQLCODE||' - '||SQLERRM
          , i_env_param2 => 'cst_prc_export_pkg.n'
          , i_env_param3 => i_len
          , i_env_param4 => i_num
          , i_env_param5 => i_justify
          , i_env_param6 => i_default
           );
         raise;
end;

function d(
    i_len              in pls_integer
  , i_date             in date
  , i_format           in varchar2
) return varchar2 is
begin
    if i_date is null then
        return rpad( ' ', i_len, ' ');
    else
        return rpad(to_char(i_date, i_format), i_len, ' ');
    end if;
exception
    when others then
        trc_log_pkg.fatal(
            i_text       => 'Error [#1] in function [#2] with i_len [#3], i_date [#4] and i_format [#5]'
          , i_env_param1 => SQLCODE||' - '||SQLERRM
          , i_env_param2 => 'cst_prc_export_pkg.d'
          , i_env_param3 => i_len
          , i_env_param4 => i_date
          , i_env_param5 => i_format
           );
         raise;
end;

procedure  check_empty_field(
    io_empty_fields   in out varchar2,
    i_field_name      in varchar2,
    i_field_value     in varchar2
) is
begin
    if i_field_value is null then
        io_empty_fields := io_empty_fields||i_field_name||';';
    end if;
end;
--
--------------------------------------------

procedure calculate_control_sum(
    i_impact              in com_api_type_pkg.t_sign
  , i_pr_amount           in number
  , io_tran_sum           in out nocopy number
  , io_control_sum        in out nocopy number
) is
begin

    io_tran_sum:=
        nvl(io_tran_sum, 0)
      + nvl(i_pr_amount, 0)
      * case i_impact
            when com_api_const_pkg.CREDIT then -1
            when com_api_const_pkg.DEBIT  then  1
            when com_api_const_pkg.NONE   then  0
        end;
    io_control_sum:= nvl(io_control_sum, 0) + i_pr_amount;

end;
--------------------------------------------

function cut_file_extension(
    i_file_name           in com_api_type_pkg.t_name
) return com_api_type_pkg.t_name is
begin
    return nvl(substr(i_file_name, 1, instr(i_file_name, '.', -1) - 1), i_file_name);
end;

function get_card_type(
    i_card_network_id       in com_api_type_pkg.t_network_id
) return com_api_type_pkg.t_name is
    l_result                com_api_type_pkg.t_name;
begin
    if i_card_network_id = 1002 then
        l_result:= 'EC';
    elsif i_card_network_id = 1003 then
        l_result:= 'VI';
    elsif i_card_network_id = 5001 then
        l_result:= 'PR';
    else
        l_result:= null;
    end if;

    return l_result;
end;

function get_msg_impact(
    i_oper_type            in com_api_type_pkg.t_dict_value
  , i_is_reversal          in com_api_type_pkg.t_boolean
) return com_api_type_pkg.t_sign
is
    result com_api_type_pkg.t_sign;
begin
    if com_api_array_pkg.is_element_in_array(
           i_array_id => ARR_CREDIT_OPER,--10000011
           i_elem_value => i_oper_type
       ) = com_api_type_pkg.TRUE
    then
        result := com_api_const_pkg.CREDIT;
    else
        result := com_api_const_pkg.DEBIT;
    end if;

    if i_is_reversal = com_api_type_pkg.TRUE then
        if result = com_api_const_pkg.DEBIT then
            result := com_api_const_pkg.CREDIT;
        else
            result := com_api_const_pkg.DEBIT;
        end if;
    end if;

    return result;

end;

function get_tran_type(
    i_oper_type            in com_api_type_pkg.t_dict_value
  , i_is_reversal          in com_api_type_pkg.t_boolean
) return com_api_type_pkg.t_dict_value is
begin
    return
        conv_array_elem_v(
            i_array_conversion_id => case when i_is_reversal = com_api_type_pkg.TRUE
                                          then ARR_CONV_ID_TRAN_TYPE_REV--5002
                                          else ARR_CONV_ID_TRAN_TYPE_ORIG--5001
                                     end
          , i_elem_value          => i_oper_type
          , i_mask_error          => com_api_type_pkg.TRUE
          , i_error_value         => null
        );
end;

function get_proc_code(
    i_oper_type              in com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_dict_value
is
begin
    return
        conv_array_elem_v(
            i_array_conversion_id => ARR_CONV_PROC_CODE--5003
          , i_elem_value          => i_oper_type
          , i_mask_error          => com_api_type_pkg.TRUE
          , i_error_value         => null
        );
end;

function get_pos_data_code(
    i_card_data_input_cap    in com_api_type_pkg.t_dict_value,
    i_crdh_auth_cap          in com_api_type_pkg.t_dict_value,
    i_card_capture_cap       in com_api_type_pkg.t_dict_value,
    i_terminal_operating_env in com_api_type_pkg.t_dict_value,
    i_crdh_presence          in com_api_type_pkg.t_dict_value,
    i_card_presence          in com_api_type_pkg.t_dict_value,
    i_card_data_input_mode   in com_api_type_pkg.t_dict_value,
    i_crdh_auth_method       in com_api_type_pkg.t_dict_value,
    i_crdh_auth_entity       in com_api_type_pkg.t_dict_value,
    i_card_data_output_cap   in com_api_type_pkg.t_dict_value,
    i_terminal_output_cap    in com_api_type_pkg.t_dict_value,
    i_pin_capture_cap        in com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_name
is
    l_result                com_api_type_pkg.t_name;
begin
    l_result:= case i_card_data_input_cap
                   when 'F2210000' then '0'
                   when 'F2210001' then '1'
                   when 'F2210002' then '2'
                   when 'F2210003' then '3'
                   when 'F2210004' then '4'
                   when 'F2210005' then '5'
                   when 'F2210006' then '6'
                   when 'F221000A' then 'A'
                   when 'F221000B' then 'B'
                   when 'F221000C' then 'C'
                   when 'F221000D' then 'D'
                   when 'F221000E' then 'E'
                   when 'F221000M' then 'M'
                   when 'F221000S' then 'S'
                   when 'F221000V' then 'V'
                   else '0'
               end
            || case i_crdh_auth_cap
                   when 'F2220000' then '0'
                   when 'F2220001' then '1'
                   when 'F2220002' then '2'
                   when 'F2220003' then '5'
                   when 'F2210009' then '9'  -- What is needed:  F2210009 vs F2220009 ?
                   -- else nvl(substr(i_card_data_input_cap, -1),'9')  -- What is needed: i_card_data_input_cap vs i_crdh_auth_cap ?
                   else
                       case
                           when i_card_data_input_cap is null
                           then '9'
                           else
                               case i_card_data_input_cap
                                   when 'F2210000' then '0'
                                   when 'F2210001' then '1'
                                   when 'F2210002' then '2'
                                   when 'F2210003' then '3'
                                   when 'F2210004' then '4'
                                   when 'F2210005' then '5'
                                   when 'F2210006' then '6'
                                   when 'F221000A' then 'A'
                                   when 'F221000B' then 'B'
                                   when 'F221000C' then 'C'
                                   when 'F221000D' then 'D'
                                   when 'F221000E' then 'E'
                                   when 'F221000M' then 'M'
                                   when 'F221000S' then 'S'
                                   when 'F221000V' then 'V'
                                   else '0'
                               end
                           end
               end
            || case i_card_capture_cap
                   when 'F2230000' then '0'
                   when 'F2230001' then '1'
                   when 'F2230002' then '9'
                   else
                       case
                           when i_card_capture_cap is null
                           then '9'
                           else
                               case i_card_capture_cap
                                   when 'F2230000' then '0'
                                   when 'F2230001' then '1'
                                   when 'F2230002' then '2'
                                   else '2'
                               end
                            end
               end
            || case i_terminal_operating_env
                   when 'F2240000' then '0'
                   when 'F2240001' then '1'
                   when 'F2240002' then '2'
                   when 'F2240003' then '3'
                   when 'F2240004' then '4'
                   when 'F2240005' then '5'
                   when 'F2240006' then '6'
                   when 'F2240007' then '7'
                   when 'F2240009' then '9'
                   when 'F224000A' then 'A'
                   when 'F224000B' then 'B'
                   when 'F224000U' then 'U'
                   else '9'
               end
            || case i_crdh_presence
                   when 'F2250000' then '0'
                   when 'F2250001' then '1'
                   when 'F2250002' then '2'
                   when 'F2250003' then '3'
                   when 'F2250004' then '4'
                   when 'F2250005' then '5'
                   when 'F2250009' then '9'
                   else '9'
               end
            || case i_card_presence
                   when 'F2260000' then '0'
                   when 'F2260001' then '1'
                   when 'F2260009' then '9'
                   else '9'
               end
            || case i_card_data_input_mode
                   when 'F2270000' then '0'
                   when 'F2270001' then '1'
                   when 'F2270002' then '2'
                   when 'F2270003' then '3'
                   when 'F2270005' then '5'
                   when 'F2270006' then '6'
                   when 'F2270007' then '7'
                   when 'F2270008' then '8'
                   when 'F2270009' then '9'
                   when 'F227000A' then 'A'
                   when 'F227000B' then 'B'
                   when 'F227000C' then 'C'
                   when 'F227000D' then 'D'
                   when 'F227000E' then 'E'
                   when 'F227000F' then 'F'
                   when 'F227000M' then 'M'
                   when 'F227000N' then 'N'
                   when 'F227000P' then 'P'
                   when 'F227000R' then 'R'
                   when 'F227000S' then 'S'
                   when 'F227000W' then 'W'
                   else '0'
               end
            || case i_crdh_auth_method
                   when 'F2280000' then '0'
                   when 'F2280001' then '1'
                   when 'F2280002' then '2'
                   when 'F2280005' then '5'
                   when 'F2280006' then '6'
                   when 'F2280009' then '9'
                   when 'F228000S' then 'S'
                   when 'F228000W' then 'W'
                   when 'F228000X' then 'X'
                   else '9'
                end
            || case i_crdh_auth_entity
                   when 'F2290000' then '0'
                   when 'F2290001' then '1'
                   when 'F2290002' then '2'
                   when 'F2290003' then '3'
                   when 'F2290004' then '4'
                   when 'F2290005' then '5'
                   when 'F2290006' then '6'
                   when 'F2290009' then '9'
                   else '9'
               end
            || case i_card_data_output_cap
                   when 'F22A0000' then '0'
                   when 'F22A0001' then '1'
                   when 'F22A0002' then '2'
                   when 'F22A0003' then '3'
                   when 'F22A000S' then 'S'
                   else '0'
               end
            || case i_terminal_output_cap
                   when 'F22B0000' then '0'
                   when 'F22B0001' then '1'
                   when 'F22B0002' then '2'
                   when 'F22B0003' then '3'
                   when 'F22B0004' then '4'
                   else '0'
               end
            || case i_pin_capture_cap
                   when 'F22C000A' then 'A'
                   when 'F22C000B' then 'B'
                   when 'F22C000C' then 'C'
                   when 'F22C000S' then 'S'
                   when 'F22C0000' then '0'
                   when 'F22C0001' then '1'
                   when 'F22C0002' then '2'
                   when 'F22C0003' then '3'
                   when 'F22C0004' then '4'
                   when 'F22C0005' then '5'
                   when 'F22C0006' then '6'
                   when 'F22C0007' then '7'
                   when 'F22C0008' then '8'
                   when 'F22C0009' then '9'
                   else '1'
               end;

    return l_result;
end;

function get_tran_info(
    i_card_presence          in com_api_type_pkg.t_dict_value,
    i_card_data_input_mode   in com_api_type_pkg.t_dict_value,
    i_crdh_auth_method       in com_api_type_pkg.t_dict_value,
    i_card_seq_number        in opr_participant.card_seq_number%type
) return com_api_type_pkg.t_name
is
    l_result                com_api_type_pkg.t_name;
begin
    l_result:= case i_card_presence
                   when 'F2260000' then '0'
                   when 'F2260001' then '1'
                   when 'F2260009' then '9'
                   else '9'
               end
            || case i_card_data_input_mode
                   when 'F2270000' then '0'
                   when 'F2270001' then '1'
                   when 'F2270002' then '2'
                   when 'F2270003' then '3'
                   when 'F2270005' then '5'
                   when 'F2270006' then '6'
                   when 'F2270007' then '7'
                   when 'F2270008' then '8'
                   when 'F2270009' then '9'
                   when 'F227000A' then 'A'
                   when 'F227000B' then 'B'
                   when 'F227000C' then 'C'
                   when 'F227000D' then 'D'
                   when 'F227000E' then 'E'
                   when 'F227000F' then 'F'
                   when 'F227000M' then 'M'
                   when 'F227000N' then 'N'
                   when 'F227000P' then 'P'
                   when 'F227000R' then 'R'
                   when 'F227000S' then 'S'
                   when 'F227000W' then 'W'
                   else '0'
               end
            || case i_crdh_auth_method
                   when 'F2280000' then '0'
                   when 'F2280001' then '1'
                   when 'F2280002' then '2'
                   when 'F2280005' then '5'
                   when 'F2280006' then '6'
                   when 'F2280009' then '9'
                   when 'F228000S' then 'S'
                   when 'F228000W' then 'W'
                   when 'F228000X' then 'X'
                   else '9'
               end
            || lpad(nvl(i_card_seq_number,'0'), 3, '0');

    return l_result;
end;

function get_amount(
    i_amount_type            in com_api_type_pkg.t_dict_value,
    i_inst_id                in com_api_type_pkg.t_inst_id,
    i_file_type              in com_api_type_pkg.t_dict_value,
    i_sttl_type              in com_api_type_pkg.t_dict_value,
    i_card_network_id        in com_api_type_pkg.t_network_id,
    i_card_country           in com_api_type_pkg.t_country_code,
    i_oper_currency          in com_api_type_pkg.t_curr_code,
    i_oper_amount            in com_api_type_pkg.t_money,
    i_sttl_currency          in com_api_type_pkg.t_curr_code,
    i_sttl_amount            in com_api_type_pkg.t_money,
    i_bill_currency          in com_api_type_pkg.t_curr_code,
    i_bill_amount            in com_api_type_pkg.t_money,
    i_acct_currency          in com_api_type_pkg.t_curr_code,
    i_acct_amount            in com_api_type_pkg.t_money
) return com_api_type_pkg.t_money
is
    l_result  com_api_type_pkg.t_money;
begin
    case
        -------------------------- OPER
        when (i_file_type in ('B','L') and i_amount_type in ('I','PR') )
          or (i_file_type in ('L') and i_amount_type in ('SB') )
          or (i_file_type in ('B') and i_amount_type in ('SB') and i_sttl_type <> 'STTT0010' )
          or (i_file_type in ('B') and i_amount_type in ('SB') and nvl(i_acct_currency, i_oper_currency) = i_oper_currency )
          or (i_file_type in ('W') and i_amount_type in ('SB','PR') and i_card_network_id = 1003 and i_oper_currency = '978')
        then
            l_result := i_oper_amount;
        -------------------------- ACCT
        when (i_file_type in ('B') and i_amount_type in ('SB') and i_sttl_type = 'STTT0010' and nvl(i_acct_currency, i_oper_currency) <> i_oper_currency)
        then
            l_result := i_acct_amount;
        -------------------------- STTL
        when (i_file_type in ('W') and i_amount_type in ('SB','PR') and i_card_network_id = 1002 )
          or (i_file_type in ('W') and i_amount_type in ('SB','PR') and i_card_network_id = 1003 and i_oper_currency <> '978' )
          or (i_file_type in ('W') and i_amount_type in ('I') and i_card_network_id = 1003 )
        then
            l_result := i_sttl_amount;
        -------------------------- BILL
        when (i_file_type in ('W') and i_amount_type in ('I') and i_card_network_id = 1002 )
        then
            l_result := i_bill_amount;
        else
            l_result := null;
    end case;
    return round(l_result);
end;

function get_currency(
    i_amount_type            in com_api_type_pkg.t_dict_value,
    i_inst_id                in com_api_type_pkg.t_inst_id,
    i_file_type              in com_api_type_pkg.t_dict_value,
    i_sttl_type              in com_api_type_pkg.t_dict_value,
    i_card_network_id        in com_api_type_pkg.t_network_id,
    i_card_country           in com_api_type_pkg.t_country_code,
    i_oper_currency          in com_api_type_pkg.t_curr_code,
    i_oper_amount            in com_api_type_pkg.t_money,
    i_sttl_currency          in com_api_type_pkg.t_curr_code,
    i_sttl_amount            in com_api_type_pkg.t_money,
    i_bill_currency          in com_api_type_pkg.t_curr_code,
    i_bill_amount            in com_api_type_pkg.t_money,
    i_acct_currency          in com_api_type_pkg.t_curr_code,
    i_acct_amount            in com_api_type_pkg.t_money
) return com_api_type_pkg.t_curr_code
is
    l_result  com_api_type_pkg.t_curr_code;
begin
    case
        -------------------------- OPER
        when (i_file_type in ('B','L') and i_amount_type in ('I','PR') )
          or (i_file_type in ('L') and i_amount_type in ('SB') )
          or (i_file_type in ('B') and i_amount_type in ('SB') and i_sttl_type <> 'STTT0010' )
          or (i_file_type in ('B') and i_amount_type in ('SB') and nvl(i_acct_currency, i_oper_currency) = i_oper_currency )
          or (i_file_type in ('W') and i_amount_type in ('SB','PR') and i_card_network_id = 1003 and i_oper_currency = '978')
        then
            l_result := i_oper_currency;
        -------------------------- ACCT
        when (i_file_type in ('B') and i_amount_type in ('SB') and i_sttl_type = 'STTT0010' and nvl(i_acct_currency, i_oper_currency) <> i_oper_currency)
        then
            l_result := i_acct_currency;
        -------------------------- STTL
        when (i_file_type in ('W') and i_amount_type in ('SB','PR') and i_card_network_id = 1002 )
          or (i_file_type in ('W') and i_amount_type in ('SB','PR') and i_card_network_id = 1003 and i_oper_currency <> '978' )
          or (i_file_type in ('W') and i_amount_type in ('I') and i_card_network_id = 1003 )
        then
            l_result := i_sttl_currency;
        -------------------------- BILL
        when (i_file_type in ('W') and i_amount_type in ('I') and i_card_network_id = 1002 )
        then
            l_result := i_bill_currency;
        else
            l_result := null;
    end case;
    return l_result;
end;

--------------------------------------------

function get_inst_param(
    i_param_name            in com_api_type_pkg.t_name
  , i_inst_id               in com_api_type_pkg.t_inst_id
  , i_default_value         in com_api_type_pkg.t_param_value
) return com_api_type_pkg.t_param_value
is
begin
    return nvl(com_api_flexible_data_pkg.get_flexible_value (
                            i_field_name   => i_param_name
                          , i_entity_type  => ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
                          , i_object_id    => i_inst_id
              ), i_default_value
           );
end;

procedure upload_operation (
    i_inst_id               in     com_api_type_pkg.t_inst_id        default null
  , i_full_export           in     com_api_type_pkg.t_boolean        default com_api_type_pkg.FALSE
  , i_start_date            in     date                              default null
  , i_end_date              in     date                              default null
  , i_file_type             in     char                              default 'L'--L/W/B
  , i_card_network_id       in     com_api_type_pkg.t_network_id     default null
) is
    LOG_PREFIX         constant com_api_type_pkg.t_name := i_file_type||'-file: ';
    C_PROC_NAME        constant com_api_type_pkg.t_name := 'CST_PRC_EXPORT_PKG.UPLOAD_OPERATION_'||i_file_type;
    l_sysdate              date;
    l_start_date           date;
    l_end_date             date;
    l_file_type            com_api_type_pkg.t_dict_value;
    l_container_id         com_api_type_pkg.t_long_id := prc_api_session_pkg.get_container_id;
    l_full_export          com_api_type_pkg.t_boolean;
    l_session_file_id      com_api_type_pkg.t_long_id;
    l_session_file_list    com_api_type_pkg.t_text;
    l_params               com_api_type_pkg.t_param_tab;
    l_estimated_count      com_api_type_pkg.t_long_id := 0;
    l_processed_count      com_api_type_pkg.t_long_id := 0;
    l_processed_count_all  com_api_type_pkg.t_long_id := 0;
    l_total_sum            com_api_type_pkg.t_long_id := 0;
    l_control_sum          com_api_type_pkg.t_long_id := 0;
    l_rec_number           com_api_type_pkg.t_short_id;
    l_line                 com_api_type_pkg.t_raw_data;
    l_file_name            com_api_type_pkg.t_text;
    l_file_name_short      com_api_type_pkg.t_text;
    l_evt_objects_tab      num_tab_tpt := num_tab_tpt();
    l_oper_ids_tab         num_tab_tpt := num_tab_tpt();
    l_oper_tab             num_tab_tpt := num_tab_tpt();
    --
    l_rec_centr            com_api_type_pkg.t_param_value;
    l_send_centr           com_api_type_pkg.t_param_value;
    l_version              com_api_type_pkg.t_param_value;
    l_business_bins        com_api_type_pkg.t_param_value;
    l_acq_bank             com_api_type_pkg.t_param_value;
    l_acq_branch           com_api_type_pkg.t_param_value;
    l_member               com_api_type_pkg.t_param_value;
    l_clearing_group       com_api_type_pkg.t_param_value;
    l_oper_id              opr_operation.id%type;

    l_card_network_id      com_api_type_pkg.t_tiny_id;
    l_impact               com_api_type_pkg.t_sign;
    l_file_counter         number;
    l_empty_fields         com_api_type_pkg.t_text;

    function lf_get_estimated_count(
        ilf_card_network_id  in com_api_type_pkg.t_network_id
       ,ilf_is_business_bins in com_api_type_pkg.t_boolean
    ) return com_api_type_pkg.t_long_id
    is
    begin
        -- Select IDs of all event objects need to proceed
        select
            id                 as evt_id
          , object_id          as evt_obj_id
        bulk collect into
            l_evt_objects_tab
          , l_oper_ids_tab
        from (
              select v.id
                   , v.object_id
                   , row_number() over (order by v.id) rn
              from
                  (
                      select eo.object_id, eo.inst_id, eo.eff_date, eo.event_id, eo.id, eo.split_hash
                        from evt_event_object eo
                       where l_full_export = com_api_type_pkg.FALSE
                         and decode(eo.status, 'EVST0001', eo.procedure_name, null) = C_PROC_NAME
                         and eo.split_hash in (select split_hash from com_api_split_map_vw)
                         and eo.eff_date between l_start_date and l_end_date
                         and eo.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                         and instr( ','||nvl(l_session_file_list,'L')||','
                                  , ','||nvl(to_char(eo.proc_session_id),'F')||','
                                  ) =0
                      union all
                      select eo.object_id, eo.inst_id, eo.eff_date, eo.event_id, eo.id, eo.split_hash
                        from evt_event_object eo
                       where l_full_export = com_api_type_pkg.TRUE
                         and (   decode(eo.status, 'EVST0001', eo.procedure_name, null) = C_PROC_NAME
                              or decode(eo.status, 'EVST0002', eo.procedure_name, null) = C_PROC_NAME
                             )
                         and eo.split_hash in (select split_hash from com_api_split_map_vw)
                         and eo.eff_date between l_start_date and l_end_date
                         and eo.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                         and instr( ','||nvl(l_session_file_list,'L')||','
                                  , ','||nvl(to_char(eo.proc_session_id),'F')||','
                                  ) =0
                  ) v
                , evt_event e
                , opr_operation o
                  left join opr_card c on c.oper_id = o.id
                  left join opr_participant p on p.oper_id = o.id and p.participant_type = 'PRTYISS' and p.client_id_type = 'CITPCARD'
                  left join acq_terminal t on t.terminal_number = o.terminal_number
              where
                  e.id = v.event_id
                  and (v.inst_id = i_inst_id
                      or i_inst_id is null
                      or i_inst_id = ost_api_const_pkg.DEFAULT_INST
                  )
                  and o.id    = v.object_id
                  and o.host_date between l_start_date and l_end_date
                  ----
                  and (p.card_network_id = ilf_card_network_id or ilf_card_network_id is null)
                  and (ilf_is_business_bins is null
                      or (ilf_is_business_bins = 1 and instr(','||l_business_bins||','  ,  ','||substr(c.card_number,1,6)||',')<>0)
                      or (ilf_is_business_bins = 0 and instr(','||l_business_bins||','  ,  ','||substr(c.card_number,1,6)||',')=0)
                      )
                  and nvl(to_number(com_api_flexible_data_pkg.get_flexible_value (
                                        i_field_name   => FLEX_FIELD_UPLOAD_OPERATION
                                      , i_entity_type  => acq_api_const_pkg.ENTITY_TYPE_TERMINAL--ENTTTRMN
                                      , i_object_id    => t.id
                          ), com_api_const_pkg.NUMBER_FORMAT), com_api_type_pkg.TRUE) = com_api_type_pkg.TRUE
        )
        where rn <= MAX_LWB_RECORDS
        ;

        -- Distinct operation count
        select distinct column_value
          bulk collect into l_oper_tab
          from table(cast(l_oper_ids_tab as num_tab_tpt));
        -- Return estimated count
        return l_oper_tab.count;
    end;

    procedure lp_generate_file_header
    is
        l_card_id              com_api_type_pkg.t_name;
        l_file_version         com_api_type_pkg.t_name;
    begin
        l_rec_number    := 1;
        l_card_id       := get_card_type(
                               i_card_network_id       => l_card_network_id
                           );
        l_file_version  := lpad(replace(l_version, '.', null), 4, 0);
        l_line := '00'                           -- Mtid
          ||n(  2, l_rec_centr, 'E', 0)          -- Rec_centr
          ||n(  2, l_send_centr, 'E', 0)         -- Sender_centr
          ||s(  8, l_file_name_short)            -- file_name
          ||s(  8, l_card_id)                    -- card_id
          ||s(  4, l_file_version )              -- file_version
        ;
        prc_api_file_pkg.put_line (
            i_sess_file_id => l_session_file_id
          , i_raw_data     => l_line
        );
    end;

    procedure lp_generate_file_trailer
    is
    begin
        l_rec_number := l_rec_number + 1;
        l_line := '99'                           -- Mtid
          ||n(  2, l_rec_centr, 'E', 0)          -- Rec_centr
          ||n(  2, l_send_centr, 'E', 0)         -- Sender_centr
          ||s(  8, l_file_name_short)            -- file_name
          ||n(  8, l_rec_number, 'R', 0)         -- Number of records in the file
          ||s(  1, case
                       when l_total_sum < 0 then '-'
                                         else '+'
                   end
             )                                    -- sign
          ||n( 14, abs(l_total_sum), 'R', 0)      -- Transaction amount
          ||n( 14, l_control_sum, 'R', 0)         -- Control amount
        ;
        prc_api_file_pkg.put_line (
            i_sess_file_id  => l_session_file_id
          , i_raw_data => l_line
        );
    end;

    procedure lp_generate_operations
    is
        l_tran_type      com_api_type_pkg.t_dict_value;
        l_proc_code      com_api_type_pkg.t_dict_value;
        l_msg_type       com_api_type_pkg.t_name;
        l_org_msg_type   com_api_type_pkg.t_name;
        l_country        com_api_type_pkg.t_name;
        l_rec_centr_o    com_api_type_pkg.t_param_value;
        l_iss_cmi        com_api_type_pkg.t_param_value;
        l_send_cmi       com_api_type_pkg.t_param_value;
        l_settl_cmi      com_api_type_pkg.t_param_value;
    begin
        l_rec_centr_o := l_rec_centr;
        for fin_rec in (
            select t.*
                 , op_curr.name      currency        --26   Currency   158   3
                 , op_curr.exponent  ccy_exp         --27   Ccy_exp    161   1
                 , sb_curr.name      sb_ccy          --31   Sbnk_ccy   196   3
                 , sb_curr.exponent  sb_ccyexp       --32   Sb_ccyexp  199   1
                 , i_curr.name       i_ccy           --38   Ibnk_ccy   256   3
                 , i_curr.exponent   i_ccyexp        --39   I_ccyexp   259   1
                 , pr_curr.name      pr_ccy          --63   Prnk_ccy   490   3
                 , pr_curr.exponent  pr_ccyexp       --64   Pr_ccyexp  493   1
            from (
                select o.id
                     , o.merchant_number  merchant
                     , o.terminal_number  batch_nr          --12   Batch_nr  46   7
                     , a.system_trace_audit_number slip_nr  --13   Slip_nr   53   7
                     , c.card_number      card
                     , p.card_expir_date  exp_date
                     , nvl(ao.host_date, o.host_date) tran_date_time
                     , o.oper_type
                     , o.is_reversal
                     , p.auth_code        appr_code         --19   Appr_code   99   6
                     , 1                  appr_src          --20   Appr_src   105   1
                     , a.system_trace_audit_number stan     --21   Stan       106   6   System Trace Audit Number
                     , o.originator_refnum rrn              --22   Ref_number 112   12  Retrieval Reference Number
                     ----------------------------------------------------------------
                     ----tr_amount
                     , round(o.oper_amount) amount          --23   Amount     124   12  Transaction amount
                     , null cashback                        --24   Cash_back  136   12  Cashback
                     , 0 fee                                --25   Fee        148   10  Interchange Fee
                     , o.oper_currency ccy_n
                     ----------------------------------------------------------------
                     ----sb_amount
                     , cst_prc_export_pkg.get_amount(
                           'SB',
                           i_inst_id,
                           i_file_type,
                           o.sttl_type,
                           p.card_network_id,
                           p.card_country,
                           o.oper_currency,
                           o.oper_amount,
                           o.sttl_currency,
                           o.sttl_amount,
                           m.de051,
                           m.de006,
                           aa.currency,
                           p.account_amount
                     ) as sb_amount                         --28   Sb_amount    162   12   Settlement
                     , round(o.oper_cashback_amount) sb_cashback  --29   Sb_cshback   174   12   Cashback
                     , null sb_fee                                --30   Sb_fee       186   10
                     , cst_prc_export_pkg.get_currency(
                           'SB',
                           i_inst_id,
                           i_file_type,
                           o.sttl_type,
                           p.card_network_id,
                           p.card_country,
                           o.oper_currency,
                           o.oper_amount,
                           o.sttl_currency,
                           o.sttl_amount,
                           m.de051,
                           m.de006,
                           aa.currency,
                           p.account_amount
                     ) as sb_ccy_n
                     , null sb_cnvrate               --33   Sb_cnvrate   200   14
                     , null sb_cnvdate               --34   Sb_cnvdate   214   8
                     ----------------------------------------------------------------
                     ----i_amount
                     , cst_prc_export_pkg.get_amount(
                           'I',
                           i_inst_id,
                           i_file_type,
                           o.sttl_type,
                           p.card_network_id,
                           p.card_country,
                           o.oper_currency,
                           o.oper_amount,
                           o.sttl_currency,
                           o.sttl_amount,
                           m.de051,
                           m.de006,
                           aa.currency,
                           p.account_amount
                     ) as i_amount                   --35   I_amount    222   12
                     , null i_cshback                --36   I_cshback   234   12
                     , null i_fee                    --37   I_fee       246   10
                     , cst_prc_export_pkg.get_currency(
                           'I',
                           i_inst_id,
                           i_file_type,
                           o.sttl_type,
                           p.card_network_id,
                           p.card_country,
                           o.oper_currency,
                           o.oper_amount,
                           o.sttl_currency,
                           o.sttl_amount,
                           m.de051,
                           m.de006,
                           aa.currency,
                           p.account_amount
                     ) as i_ccy_n
                     , null i_cnvrate                --40   I_cnvrate   260   14
                     , null i_cnvdate                --41   I_cnvdate   274   8
                     ----------------------------------------------------------------
                     , regexp_replace(nvl(ao.terminal_number, o.terminal_number)
                               ||' '||nvl(ao.merchant_name, o.merchant_name),  '[^a-zA-Z0-9-]')
                       as  abvr_name                 --42   Abvr_name   282   27
                     , regexp_replace(nvl(ao.merchant_city, o.merchant_city),  '[^a-zA-Z0-9-]')
                       as city                       --43   City        309   15
                     , o.merchant_country country    --44   Country     324   3
                     ----------------------------------------------------------------
                     , cst_prc_export_pkg.get_pos_data_code(
                            coalesce(a.card_data_input_cap,    m.de022_1,  v.pos_terminal_cap ),
                            coalesce(a.crdh_auth_cap,          m.de022_2                      ),
                            coalesce(a.card_capture_cap,       m.de022_3                      ),
                            coalesce(a.terminal_operating_env, m.de022_4                      ),
                            coalesce(a.crdh_presence,          m.de022_5                      ),
                            coalesce(a.card_presence,          m.de022_6                      ),
                            coalesce(a.card_data_input_mode,   m.de022_7,  decode(v.pos_entry_mode,
                                                                               '90', 'B',
                                                                               '05', 'C',
                                                                               '01', '6',
                                                                               '07', 'M',
                                                                               '91', 'A',
                                                                               '02', '2',
                                                                               '10', 'E',
                                                                               '03', '3',
                                                                                     null
                                                                           )),
                            coalesce(a.crdh_auth_method,       m.de022_8,  trim(v.crdh_id_method) ),
                            coalesce(a.crdh_auth_entity,       m.de022_9                      ),
                            coalesce(a.card_data_output_cap,   m.de022_10                     ),
                            coalesce(a.terminal_output_cap,    m.de022_11                     ),
                            coalesce(a.pin_capture_cap,        m.de022_12                     )
                       ) as pos_data_code            --45   Pos_data_code    12   Point of Service Data Code
                     ----------------------------------------------------------------
                     , o.mcc mcc_code                --46   MCC_code    339   4   ISO Merchant service code
                     , case o.terminal_type
                           when 'TRMT0002' then 'A'
                           when 'TRMT0003' then 'P'
                           when 'TRMT0004' then 'P'
                           when 'TRMT0001' then 'N'
                                           else 'P'
                       end terminal_type             --47   Terminal    343   1   (A – ATM, P- POS, N – imprinter)
                     , o.terminal_number batch_id    --48   Batch_id    344   11
                     , null settl_nr                 --49   Settl_nr    355   11
                     , nvl(o.sttl_date, o.host_date) settl_date        --50   Settl_date  366   8
                     , nvl(v.arn, m.de031) acqref_nr --51   Acqref_nr   374   23   Acquiring Reference data (ISO-8583)
                     , o.terminal_number terminal_id --57   Term_nr     434   8
                     ----------------------------------------------------------------
                     , cst_prc_export_pkg.get_tran_info(
                            coalesce(a.card_presence,          m.de022_6                      ),
                            coalesce(a.card_data_input_mode,   m.de022_7,  decode(v.pos_entry_mode,
                                                                               '90', 'B',
                                                                               '05', 'C',
                                                                               '01', '6',
                                                                               '07', 'M',
                                                                               '91', 'A',
                                                                               '02', '2',
                                                                               '10', 'E',
                                                                               '03', '3',
                                                                                     null
                                                                           )),
                            coalesce(a.crdh_auth_method,       m.de022_8,  v.crdh_id_method   ),
                            p.card_seq_number
                       ) as tran_info                --59   Tran_info         6    Additional transaction information
                     ----------------------------------------------------------------
                     ----pr_amount
                     , cst_prc_export_pkg.get_amount(
                           'PR',
                           i_inst_id,
                           i_file_type,
                           o.sttl_type,
                           p.card_network_id,
                           p.card_country,
                           o.oper_currency,
                           o.oper_amount,
                           o.sttl_currency,
                           o.sttl_amount,
                           m.de051,
                           m.de006,
                           aa.currency,
                           p.account_amount
                     ) as pr_amount                   --60   Pr_amount    456   12
                     , null pr_cshback                --61   Pr_cshback   468   12
                     , null pr_fee                    --62   Pr_fee       480   10
                     , cst_prc_export_pkg.get_currency(
                           'PR',
                           i_inst_id,
                           i_file_type,
                           o.sttl_type,
                           p.card_network_id,
                           p.card_country,
                           o.oper_currency,
                           o.oper_amount,
                           o.sttl_currency,
                           o.sttl_amount,
                           m.de051,
                           m.de006,
                           aa.currency,
                           p.account_amount
                     ) as pr_ccy_n
                     , null pr_cnvrate                --65   Pr_cnvrate   494   14
                     , null pr_cnvdate                --66   Pr_cnvdate   508   8
                     ----------------------------------------------------------------
                     , case when p.card_network_id = 1003 then--Visa
                           (select max(vb.region)
                              from vis_bin_range vb
                             where substr(c.card_number, 1, 9) between vb.pan_low and vb.pan_high
                           )
                       end as region               --67   Region       516   1   Iss region - only for VISA
                     , null card_type              --68   Card_Type    517   1   VISA Card Type - only for VISA cards
                     , null proc_class             --69   Proc_Class   518   4   Processing Class – only for MC cards --ECRD
                     , p.card_seq_number seq_nr    --70   Seq_nr       522   3   Card sequence number (ISO 8583 field 023) --000
                     , 'D' msg_category            --74   Msg_category 535   1   Single/Dual --D
                     , null moto_ind
                     , null susp_status            -- Suspected status of transaction
                     , null transact_row           -- RTPS transaction reference (N11 )
                     , null authoriz_row           -- RTPS authorization reference (N11 )
                     , null fld_043                -- Card acceptor name / location
                     , null fld_098                -- Payee  - girocode + account no
                     , null fld_102                -- Account identification 1
                     , null fld_103                -- Account identification 2
                     , null fld_104                -- Transaction description - contains receiver name
                     , null fld_039                -- Response code - authorization response code
                     , null fld_sh6                -- Transaction Fee Rule
                     , null batch_date             -- Batch date
                     , round(nvl(o.oper_surcharge_amount,0)) +
                           case when i_file_type = 'B'
                                then 0
                                else round(nvl(fee.amount,0))
                           end
                       as tr_fee                   -- 88 On-line commission
                     , a.service_code              -- Service Code
                     , null fld_123_1              -- CVC2 result code
                     , null epi_42_48              -- Electronic Commerce Security Level Indicator/UCAF Status
                     , null fld_003                -- Full processing code
                     , null msc                    -- Merchant Service Charge
                     , null account_nr             -- Merchant Account Number
                     , null epi_42_48_full         -- Full Electronic Commerce Security Level Indicator/UCAF Status
                     , o.id other_code             -- Departments other_code
                     , null fld_015                -- FLD_015 YYYYMMDD
                     , null fld_095                -- Issuer Reference Data (TLV - Tag 4 ASCII symbols, fin_rec.Length 3 DEC symbols, fin_rec.Value; Sample - 0003002AB1111004XXXX )
                     , null audit_date             -- Audit date and time (YYYYMMDDHH24MISS ) from FLD_031
                     , null other_fee1             -- Another acquirer surcharge 1 from FLD_046
                     , null other_fee2             -- Another acquirer surcharge 2 from FLD_046
                     , null other_fee3             -- Another acquirer surcharge 3 from FLD_046
                     , null other_fee4             -- Another acquirer surcharge 4 from FLD_046
                     , null other_fee5             -- Another acquirer surcharge 5 from FLD_046
                     , null fld_030a               -- Original transaction amount in minor currency units
                     ----------------------------------------------------------------
                     , o.sttl_type
                     , o.acq_inst_bin
                     , o.forw_inst_bin
                     , p.card_network_id
                     , term.id    as term_id
                     , a.id       as auth_id
                  from
                        opr_operation o
                      left join opr_card c on c.oper_id = o.id
                      left join opr_participant p on p.oper_id = o.id and p.participant_type = 'PRTYISS' and p.client_id_type = 'CITPCARD'
                      left join acc_account aa on aa.id = p.account_id and aa.currency = p.account_currency
                      left join aut_auth a1 on a1.id = o.id
                      left join aut_auth a2 on a2.id = o.match_id
                      left join aut_auth a on a.id = nvl(a1.id, a2.id)
                      left join opr_operation ao on ao.id = a.id
                      left join opr_additional_amount fee  on fee.oper_id = a.id and fee.amount_type='AMPR0020'
                      left join mcw_fin m on m.id = o.id
                      left join vis_fin_message v on v.id = o.id
                      left join acq_terminal term on term.terminal_number=o.terminal_number
                  where
                        o.id in (select column_value from table(cast(l_oper_tab as num_tab_tpt)))
            ) t
            left join com_currency op_curr on op_curr.code = t.ccy_n
            left join com_currency sb_curr on sb_curr.code = t.sb_ccy_n
            left join com_currency i_curr on i_curr.code = t.i_ccy_n
            left join com_currency pr_curr on pr_curr.code = t.pr_ccy_n
        ) loop
            l_rec_number := l_rec_number + 1;
            l_oper_id := fin_rec.id;

            trc_log_pkg.debug(
               i_text          => 'Upload OPERATION_ID [#1]'
               , i_env_param1  => fin_rec.id
               , i_entity_type => 'ENTTOPER'
               , i_object_id   => fin_rec.id);

            --rec_centr
            if i_file_type = 'B' then
                l_rec_centr_o :=
                    case when fin_rec.sttl_type = opr_api_const_pkg.SETTLEMENT_USONUS then '07'
                         else '92'
                    end;
            end if;
            --send_cmi
            l_send_cmi :=
                nvl(
                case when fin_rec.card_network_id = 1002 then fin_rec.acq_inst_bin
                     when fin_rec.card_network_id = 1003 then fin_rec.acq_inst_bin
                     when fin_rec.card_network_id = 5001 and i_file_type in ('W') then nvl(fin_rec.forw_inst_bin,'80400099')
                     else nvl(fin_rec.acq_inst_bin, '80400024')
                end
                ,'00000000');
            l_send_cmi := case when substr(l_send_cmi,1,1) = '0' then lpad(l_send_cmi,8,'0') else rpad(l_send_cmi,8,'0') end;
            --iss_cmi
            l_iss_cmi :=
                nvl(
                case when i_file_type in ('B','L') then
                    case when fin_rec.card_network_id = 1002 and fin_rec.sttl_type = opr_api_const_pkg.SETTLEMENT_USONUS then nvl(fin_rec.forw_inst_bin, l_send_cmi)
                         when fin_rec.card_network_id = 1003 and fin_rec.sttl_type = opr_api_const_pkg.SETTLEMENT_USONUS then nvl(fin_rec.forw_inst_bin, '41256300')
                         when fin_rec.card_network_id = 5001 and fin_rec.sttl_type = opr_api_const_pkg.SETTLEMENT_USONUS then nvl(fin_rec.forw_inst_bin, l_send_cmi)
                         when fin_rec.card_network_id = 1002 and fin_rec.sttl_type <>opr_api_const_pkg.SETTLEMENT_USONUS then nvl(fin_rec.forw_inst_bin, substr(fin_rec.card,1,8))
                         when fin_rec.card_network_id = 1003 and fin_rec.sttl_type <>opr_api_const_pkg.SETTLEMENT_USONUS then nvl(fin_rec.forw_inst_bin, substr(fin_rec.card,1,8))
                         when fin_rec.card_network_id = 5001 and fin_rec.sttl_type <>opr_api_const_pkg.SETTLEMENT_USONUS then nvl(fin_rec.forw_inst_bin, '80499999')
                         else fin_rec.forw_inst_bin
                    end
                else
                    case when fin_rec.card_network_id = 1002 then nvl(fin_rec.forw_inst_bin,'00011931')
                         when fin_rec.card_network_id = 1003 then nvl(fin_rec.forw_inst_bin,'00000000')
                         when fin_rec.card_network_id = 5001 then nvl(fin_rec.forw_inst_bin,'80400024')
                         else '00000000'
                    end
                end
                ,'00000000');
            l_iss_cmi := case when substr(l_iss_cmi,1,1) = '0' then lpad(l_iss_cmi,8,'0') else rpad(l_iss_cmi,8,'0') end;
            --settl_cmi
            l_settl_cmi :=
                case when i_file_type in ('L','B') and fin_rec.card_network_id <> 5001 then '80400000'
                     when i_file_type in ('L','B') and fin_rec.card_network_id  = 5001 then '80400024'
                     when i_file_type in ('W') then lpad(fin_rec.sb_ccy_n,3,'0')||'99999'
                     else '00000000'
                end;

            l_msg_type := '0100';
            l_org_msg_type := case when fin_rec.is_reversal = com_api_type_pkg.TRUE then '0100' else null end;
            l_proc_code := get_proc_code(
                               i_oper_type   => fin_rec.oper_type
                           );
            l_impact := get_msg_impact(
                            i_oper_type     => fin_rec.oper_type
                          , i_is_reversal   => fin_rec.is_reversal
                        );
            l_tran_type := get_tran_type(
                                i_oper_type     => fin_rec.oper_type
                              , i_is_reversal   => fin_rec.is_reversal
                            );
            l_country := nvl( com_api_country_pkg.get_country_name(
                                  i_code => fin_rec.country
                                , i_raise_error => 0
                         ), fin_rec.country);
            --check mandatory
            l_empty_fields := null;
            case when i_file_type in ('L','W') then
                check_empty_field(l_empty_fields, '6.Settl_CMI',  l_settl_cmi);
                check_empty_field(l_empty_fields, '14.Card',      fin_rec.card);
                check_empty_field(l_empty_fields, '16.Date',      fin_rec.tran_date_time);
                check_empty_field(l_empty_fields, '18.Tran_type', l_tran_type);
                check_empty_field(l_empty_fields, '23.Amount',    fin_rec.amount);
                check_empty_field(l_empty_fields, '26.Currency',  fin_rec.currency);
                check_empty_field(l_empty_fields, '27.Ccy_exp',   fin_rec.ccy_exp);
                check_empty_field(l_empty_fields, '35.I_amount',  fin_rec.i_amount);
                check_empty_field(l_empty_fields, '38.Ibnk_ccy',  fin_rec.i_ccy);
                check_empty_field(l_empty_fields, '39.I_ccyexp',  fin_rec.i_ccyexp);
                check_empty_field(l_empty_fields, '46.MCC_code',  fin_rec.mcc_code);
                check_empty_field(l_empty_fields, '60.Pr_amount', fin_rec.pr_amount);
                check_empty_field(l_empty_fields, '63.Prnk_ccy',  fin_rec.pr_ccy);
                check_empty_field(l_empty_fields, '64.Pr_ccyexp', fin_rec.pr_ccyexp);
                check_empty_field(l_empty_fields, '73.Proc_code', l_proc_code);
            else
                l_empty_fields := null;
            end case;
            if l_empty_fields is not null then
                trc_log_pkg.warn(
                    i_text       => 'id_oper [#1], absent mandatory fields [#2]'
                  , i_env_param1 => fin_rec.id
                  , i_env_param2 => l_empty_fields
                );
                com_api_error_pkg.raise_error(
                    i_error      => 'ABSENT_MANDATORY_ELEMENT'
                  , i_env_param1 => l_empty_fields
                );
            end if;
            ----------------------------------------------------------------
            ----------------------------------------------------------------
            --
            l_line:=
                s(  2, '10' )                                    -- Message type (mtid)
              ||n(  2, l_rec_centr_o, 'E', 0 )                   -- Receiver center code
              ||n(  2, l_send_centr, 'E', 0 )                    -- Sender center code
              ||s(  8, l_iss_cmi )                               -- Issuer bank's CMI
              ||s(  8, l_send_cmi )                              -- Acquirer bank's CMI
              ||s(  8, l_settl_cmi )                             -- CMI of settlement bank of the Issuer bank's center
              ||n(  2, l_acq_bank, 'E' )                         -- Acquirer bank
              ||n(  3, l_acq_branch, 'E' )                       -- Acquirer bank branch
              ||n(  1, l_member, 'E' )                           -- Acquirer bank member indicator
              ||s(  2, l_clearing_group )                        -- Local clearing group
              ;
            l_line:= l_line
              ||s(  7, fin_rec.merchant )                        -- Card acceptor - merchant code
              ||s(  7, fin_rec.batch_nr)                         -- Batch No. (last 7 symbols from batch_id )
              ||s(  7, fin_rec.slip_nr)                          -- Transaction No. (must be unique in one batch )
              ||s( 19, fin_rec.card )                            -- Card No.
              ||d(  4, fin_rec.exp_date, 'YYMM' )                -- Card expiry date YYMM
              ||d(  8, fin_rec.tran_date_time, 'YYYYMMDD' )      -- Transaction date
              ||d(  6, fin_rec.tran_date_time, 'HH24MISS' )      -- Transaction time
              ||s(  2, l_tran_type )                             -- Transaction type
              ||s(  6, fin_rec.appr_code )                       -- Authorization code
              ;
            l_line:= l_line
              ||s(  1, fin_rec.appr_src )                        -- Source of authorization code
              ||s(  6, fin_rec.stan )                            -- System Trace Audit Number
              ||s( 12, fin_rec.rrn )                             -- Retrieval Reference Number
              ;
            l_line:= l_line
              ||n( 12, fin_rec.amount )                          -- Transaction amount in minor currency units
              ||n( 12, fin_rec.cashback )                        -- Cash back = 0
              ||n( 10, fin_rec.fee, 'R' )                        -- Processing fee
              ||s(  3, fin_rec.currency )                        -- Transaction currency code - symbolic
              ||n(  1, fin_rec.ccy_exp )                         -- Number of decimals in transaction currency
              ||n( 12, fin_rec.sb_amount )                       -- Transaction amount in inter-center settlement currency
              ||n( 12, fin_rec.sb_cashback )                     -- Cash back in inter-center settlement currency
              ||n( 10, fin_rec.sb_fee, 'R' )                     -- Processing fee in inter-center settlement currency
              ||s(  3, fin_rec.sb_ccy )                          -- Inter-center settlement currency
              ||n(  1, fin_rec.sb_ccyexp )                       -- Number of decimal fractions in inter-center settlement currency
              ||n( 14, fin_rec.sb_cnvrate )                      -- Conversion rate from transaction currency to inter-center settlement currency
              ||d(  8, fin_rec.sb_cnvdate, 'YYYYMMDD' )          -- Conversion date
              ||n( 12, fin_rec.i_amount )                        -- Transaction amount in issuer bank's currency
              ||n( 12, fin_rec.i_cshback )                       -- Cash back in issuer bank's currency
              ||n( 10, fin_rec.i_fee )                           -- Processing fee in issuer bank's currency
              ||s(  3, fin_rec.i_ccy )                           -- Issuer bank's currency code
              ||n(  1, fin_rec.i_ccyexp )                        -- Number of decimal fractions in issuer bank's currency
              ||n( 14, fin_rec.i_cnvrate )                       -- Conversion rate from sender's processing center currency to issuer bank's currency
              ||d(  8, fin_rec.i_cnvdate, 'YYYYMMDD' )           -- Conversion date
              ||s( 27, fin_rec.abvr_name )                       -- Merchant name
              ||s( 15, fin_rec.city )                            -- Merchant city
              ||s(  3, l_country )                               -- Merchant country code
              ||s( 12, fin_rec.pos_data_code )                   -- Point of Service Data Code
              ||n(  4, fin_rec.mcc_code )                        -- Merchant category code
              ||s(  1, fin_rec.terminal_type )                   -- Terminal type (A - ATM, fin_rec.P - POS, fin_rec.N - imprinter, fin_rec.space - use MCC instead to determine terminal type )
              ||s( 11, fin_rec.batch_id )                        -- Batch identifier
              ||s( 11, fin_rec.settl_nr )                        -- Settlement identifier
              ||d(  8, fin_rec.settl_date, 'YYYYMMDD' )          -- 50 Settlement date
              ||s( 23, fin_rec.acqref_nr )                       -- 51 Acq Reference number
              ||n( 18, l_session_file_id, 'L' )                  -- File identifier
              ||n(  8, l_rec_number )                            -- The sequence number of the record within the file
              ||d(  8, l_sysdate, 'YYYYMMDD' )                   -- File date
              ||s(  1, null )                                    -- Processing algorithm (1 - DOMESTIC, fin_rec.2 - ECMC, fin_rec.3 - VISA )
              ||s(  2, null )                                    -- Reserved
              ||s(  8, fin_rec.terminal_id )                     -- Terminal identifier
              ||n(  8, 0 )                                       -- EUROPAY fee
              ;
            l_line:= l_line
              ||s(  6, fin_rec.tran_info )                       -- 59 Additional transaction information:
              ||n( 12, fin_rec.pr_amount )                       -- 60 Pr_amount 456 12 -  Transaction amount in acquirer bank's center currency
              ||n( 12, fin_rec.pr_cshback )                      -- Cash back in acquirer bank's center currency
              ||n( 10, fin_rec.pr_fee )                          -- Processing fee in acquirer bank's center currency
              ||s(  3, fin_rec.pr_ccy )                          -- Code of acquirer bank's center currency
              ||n(  1, fin_rec.pr_ccyexp )                       -- Number of decimal fractions in the currency
              ||n( 14, fin_rec.pr_cnvrate )                      -- Conversion rate from transaction currency to acquirer bank's center currency
              ||d(  8, fin_rec.pr_cnvdate, 'YYYYMMDD' )          -- Conversion date
              ||s(  1, fin_rec.region )                          -- 67 VISA region of reporting BIN
              ||s(  1, fin_rec.card_type )                       -- VISA Card Type
              ||s(  4, fin_rec.proc_class )                      -- O ECMC Processing Class
              ||n(  3, fin_rec.seq_nr )                          -- Card Sequence No.
              ||s(  4, l_msg_type )                              -- Transaction message type
              ||s(  4, l_org_msg_type )                          -- The type of original transaction
              ||s(  2, l_proc_code )                             -- Processing code
              ||s(  1, fin_rec.msg_category )                    -- Single/Dual
              ||s( 15, fin_rec.merchant )                        -- Full merchant code
              ;
            if l_version >= '2.02' then
              l_line:= l_line
              ||s(  1, fin_rec.moto_ind )                         -- Mail/Telephone or Electronic Commerce Indicator
              ||s(  1, fin_rec.susp_status )                      -- Suspected status of transaction
              ||n( 11, fin_rec.transact_row, 'R' )                -- RTPS transaction reference (N11 )
              ||n( 11, fin_rec.authoriz_row, 'R' )                -- RTPS authorization reference (N11 )
              ||s( 99, fin_rec.fld_043 )                          -- Card acceptor name / location
              ||s( 25, fin_rec.fld_098 )                          -- Payee  - girocode + account no
              ||s( 28, fin_rec.fld_102 )                          -- Account identification 1
              ||s( 28, fin_rec.fld_103 )                          -- Account identification 2
              ||s(100, fin_rec.fld_104 )                          -- Transaction description - contains receiver name
              ||s(  3, fin_rec.fld_039 )                          -- Response code - authorization response code
              ;
            end if;
            if l_version >= '3.10' then
              l_line:= l_line
              ||s(  4, fin_rec.fld_sh6 )                          -- Transaction Fee Rule
              ;
            end if;
            if l_version >= '3.11' then
              l_line:= l_line
              ||s(  8, fin_rec.batch_date )                       -- Batch date
              ;
            end if;
            if l_version >= '3.12' then
              l_line:= l_line
              ||n( 10, fin_rec.tr_fee )                           -- 88 On-line commission
              ;
            end if;
            if l_version >= '3.13' then
              l_line:= l_line
              ||s(  3, fin_rec.service_code )                     -- Service Code
              ||s(  1, fin_rec.fld_123_1 )                        -- CVC2 result code
              ||s(  1, fin_rec.epi_42_48 )                        -- Electronic Commerce Security Level Indicator/UCAF Status
              ||s(  6, fin_rec.fld_003 )                          -- Full processing code
              ||n( 10, fin_rec.msc, 'R' )                         -- Merchant Service Charge
              ;
            end if;
            if l_version >= '3.17' then
              l_line:= l_line
              ||s( 35, fin_rec.account_nr )                       -- Merchant Account Number
              ||s(  3, fin_rec.epi_42_48_full )                   -- Full Electronic Commerce Security Level Indicator/UCAF Status
              ;
            end if;
            if l_version >= '3.19' then
              l_line:= l_line
              ||s( 20, fin_rec.other_code )                       -- Departments other_code
              ||d(  8, fin_rec.fld_015, 'YYYYMMDD' )              -- FLD_015
              ;
            end if;
            if l_version >= '3.21' then
              l_line:= l_line
              ||s( 99, fin_rec.fld_095 )                          -- Issuer Reference Data (TLV - Tag 4 ASCII symbols, fin_rec.Length 3 DEC symbols, fin_rec.Value; Sample - 0003002AB1111004XXXX )
              ||d( 14, fin_rec.audit_date, 'YYYYMMDDHH24MISS' )   -- Audit date and time (YYYYMMDDHH24MISS ) from FLD_031
              ||n( 10, fin_rec.other_fee1, 'R' )                  -- Another acquirer surcharge 1 from FLD_046
              ||n( 10, fin_rec.other_fee2, 'R' )                  -- Another acquirer surcharge 2 from FLD_046
              ||n( 10, fin_rec.other_fee3, 'R' )                  -- Another acquirer surcharge 3 from FLD_046
              ||n( 10, fin_rec.other_fee4, 'R' )                  -- Another acquirer surcharge 4 from FLD_046
              ||n( 10, fin_rec.other_fee5, 'R' )                  -- Another acquirer surcharge 5 from FLD_046
              ||n( 12, fin_rec.fld_030a )                         -- Original transaction amount in minor currency units
              ;
            end if;
            --
            ----------------------------------------------------------------
            ----------------------------------------------------------------

            -- protocol allows to trim spaces at the end of line
            l_line:= trim(l_line);

            trc_log_pkg.debug(
               i_text          => 'The opertaion [#1] was uploaded with row [#2]'
               , i_env_param1  => fin_rec.id
               , i_env_param2  => l_line
               , i_entity_type => 'ENTTOPER'
               , i_object_id   => fin_rec.id);

            calculate_control_sum(
                i_impact       => l_impact
              , i_pr_amount    => fin_rec.pr_amount
              , io_tran_sum    => l_total_sum
              , io_control_sum => l_control_sum
            );

            prc_api_file_pkg.put_line (
                i_sess_file_id  => l_session_file_id
              , i_raw_data => l_line
            );
            l_processed_count := l_processed_count + 1;
            if mod(l_processed_count, BULK_LIMIT) = 0 then
                prc_api_stat_pkg.log_current (
                    i_current_count     => l_rec_number
                    , i_excepted_count  => 0
                );
            end if;
        end loop;
    end;
begin
    prc_api_stat_pkg.log_start;
    trc_log_pkg.debug (i_text  => LOG_PREFIX || 'start');
    --parameters
    select min(file_type)
      into l_file_type
      from prc_file_attribute a
         , prc_file f
     where a.container_id = l_container_id
       and a.file_id      = f.id
       and file_purpose   = prc_api_const_pkg.FILE_PURPOSE_OUT;

    if l_file_type is null then
        com_api_error_pkg.raise_error(
            i_error      => 'FILE_TYPE_NOT_FOUND'
          , i_env_param1 => prc_api_session_pkg.get_process_id
        );
    end if;

    l_sysdate     := com_api_sttl_day_pkg.get_sysdate;
    l_start_date := nvl(i_start_date, date '0001-01-01');
    l_end_date := nvl(i_end_date, trunc(l_sysdate) + 1 - com_api_const_pkg.ONE_SECOND);
    l_full_export := nvl(i_full_export, com_api_type_pkg.FALSE);

    l_version       := get_inst_param('FILE_LWB_VERSION',        i_inst_id, '3.23');
    l_business_bins := get_inst_param('FILE_L_BUSINESS_BINS',    i_inst_id, '535196');

    trc_log_pkg.info(
        i_text => LOG_PREFIX || 'inst_id=[#1], full_export=[#2], start_date=[#3], end_date=[#4], card_network_id=[#5]'
      , i_env_param1 => i_inst_id
      , i_env_param2 => l_full_export
      , i_env_param3 => to_char(l_start_date, com_api_const_pkg.XML_DATE_FORMAT)
      , i_env_param4 => to_char(l_end_date,   com_api_const_pkg.XML_DATE_FORMAT)
      , i_env_param5 => i_card_network_id
    );

    for cur_network in (
        select * from (
            select 1002 as card_network_id, 'MC' file_ext, null is_business_bins from dual where i_file_type in ('W','B') union all
            select 1002 as card_network_id, 'MC' file_ext, 0 is_business_bins from dual where i_file_type in ('L') union all
            select 1002 as card_network_id, 'MCB' file_ext, 1 is_business_bins from dual where i_file_type in ('L') union all
            select 1003 as card_network_id, 'VI' file_ext, null is_business_bins from dual where i_file_type in ('L','W','B') union all
            select 5001 as card_network_id, 'PR' file_ext, null is_business_bins from dual where i_file_type in ('L','W','B')
        ) where card_network_id = i_card_network_id or i_card_network_id is null
    )
    loop
        loop--MAX_LWB_RECORDS
        -- make estimated count
        l_estimated_count := lf_get_estimated_count(ilf_card_network_id  => cur_network.card_network_id
                                                   ,ilf_is_business_bins => cur_network.is_business_bins
                                                   );
        prc_api_stat_pkg.log_estimation (
            i_estimated_count  => l_estimated_count
        );

        if l_estimated_count > 0 then
            trc_log_pkg.info (
                i_text       => LOG_PREFIX || 'operations to go count - network [#1], business [#2]: [#3]'
              , i_env_param1 => cur_network.card_network_id
              , i_env_param2 => cur_network.is_business_bins
              , i_env_param3 => l_estimated_count
            );
            l_estimated_count := 0;
            l_processed_count := 0;
            l_total_sum       := 0;
            l_control_sum     := 0;

            select (count(*) + 1) as next_file_counter
              into l_file_counter
              from prc_session s
              join prc_session_file sf on sf.session_id = s.id
             where s.process_id in (50000001, 50000002, 50000003)
               and s.id between com_api_id_pkg.get_from_id(l_sysdate) and com_api_id_pkg.get_till_id(l_sysdate)
               and instr(sf.file_name, cur_network.file_ext) > 0;

            l_file_name_short := i_file_type||'00'||to_char(l_sysdate, 'yddd')||substr(l_file_counter,-1);
            l_file_name := l_file_name_short||'.'||cur_network.file_ext;

            --register_session_file
            l_params.delete;
            prc_api_file_pkg.open_file (
                o_sess_file_id  => l_session_file_id
              , i_file_name     => l_file_name
              , i_file_type     => l_file_type
              , i_file_purpose  => prc_api_const_pkg.FILE_PURPOSE_OUT
              , io_params       => l_params
            );

            case when i_file_type = 'L' then
                l_rec_centr     := '07';
                l_send_centr    := '07';
                l_acq_bank      := '';
                l_acq_branch    := '';
                l_member        := '';
                l_clearing_group:= '';
            when i_file_type = 'W' then
                l_rec_centr     := '00';
                l_send_centr    := '00';
                l_acq_bank      := '';
                l_acq_branch    := '';
                l_member        := '';
                l_clearing_group:= '';
            when i_file_type = 'B' then
                l_rec_centr     := '00';
                l_send_centr    := '07';
                l_acq_bank      := '24';
                l_acq_branch    := '00';
                l_member        := '';
                l_clearing_group:= '';
            end case;

            l_card_network_id := cur_network.card_network_id;
            --header ---------------------
            lp_generate_file_header;
            --rows -----------------------
            lp_generate_operations;
            --trailer --------------------
            lp_generate_file_trailer;
            --close file -----------------
            prc_api_file_pkg.close_file (
                i_sess_file_id  => l_session_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
              , i_record_count  => l_processed_count
            );
            l_session_file_list := l_session_file_list||','||l_session_file_id;

            -- Mark processed event object
            if l_evt_objects_tab.count > 0 then
                forall i in l_evt_objects_tab.first .. l_evt_objects_tab.last
                    update evt_event_object
                       set status = evt_api_const_pkg.EVENT_STATUS_PROCESSED
                           , proc_session_id = l_session_file_id
                     where id = l_evt_objects_tab(i);
            end if;
            ------

            trc_log_pkg.debug (
                i_text       => LOG_PREFIX ||'[#1] event objects marked as PROCESSED.'
              , i_env_param1 => l_evt_objects_tab.count
            );
            l_processed_count_all := l_processed_count_all + l_processed_count;
        else
            exit;
        end if;
    end loop;

    end loop;

    --finish
    trc_log_pkg.debug (LOG_PREFIX || 'was successfully completed.');
    prc_api_stat_pkg.log_end(
        i_result_code        => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
       ,i_processed_total    => l_processed_count_all
    );

exception
    when others then
        prc_api_stat_pkg.log_end (
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if l_session_file_id is not null then
            prc_api_file_pkg.close_file (
                i_sess_file_id  => l_session_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
            );
        end if;

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
              , i_env_param2    => l_oper_id
            );
        end if;

        raise;
end upload_operation;

procedure upload_operation_l (
    i_inst_id               in     com_api_type_pkg.t_inst_id        default null
  , i_full_export           in     com_api_type_pkg.t_boolean        default com_api_type_pkg.FALSE
  , i_start_date            in     date                              default null
  , i_end_date              in     date                              default null
  , i_card_network_id       in     com_api_type_pkg.t_network_id     default null
) is
begin
    cst_prc_export_pkg.upload_operation(
        i_inst_id     => i_inst_id
       ,i_full_export => i_full_export
       ,i_start_date  => i_start_date
       ,i_end_date    => i_end_date
       ,i_file_type   => 'L'
       ,i_card_network_id => i_card_network_id
    );
end upload_operation_l;

procedure upload_operation_w (
    i_inst_id               in     com_api_type_pkg.t_inst_id        default null
  , i_full_export           in     com_api_type_pkg.t_boolean        default com_api_type_pkg.FALSE
  , i_start_date            in     date                              default null
  , i_end_date              in     date                              default null
  , i_card_network_id       in     com_api_type_pkg.t_network_id     default null
) is
begin
    cst_prc_export_pkg.upload_operation(
        i_inst_id     => i_inst_id
       ,i_full_export => i_full_export
       ,i_start_date  => i_start_date
       ,i_end_date    => i_end_date
       ,i_file_type   => 'W'
       ,i_card_network_id => i_card_network_id
    );
end upload_operation_w;

procedure upload_operation_b (
    i_inst_id               in     com_api_type_pkg.t_inst_id        default null
  , i_full_export           in     com_api_type_pkg.t_boolean        default com_api_type_pkg.FALSE
  , i_start_date            in     date                              default null
  , i_end_date              in     date                              default null
  , i_card_network_id       in     com_api_type_pkg.t_network_id     default null
) is
begin
    cst_prc_export_pkg.upload_operation(
        i_inst_id     => i_inst_id
       ,i_full_export => i_full_export
       ,i_start_date  => i_start_date
       ,i_end_date    => i_end_date
       ,i_file_type   => 'B'
       ,i_card_network_id => i_card_network_id
    );
end upload_operation_b;

end;
/
