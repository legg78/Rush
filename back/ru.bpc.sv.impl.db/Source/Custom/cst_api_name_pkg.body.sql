create or replace package body cst_api_name_pkg as
/************************************************************
 * Custom naming function. <br />
 * Created by Kryukov E.(krukov@bpc.ru)  at 31.01.2012 <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: CST_API_NAME_PKG <br />
 * @headcom
 *************************************************************/

function decode_customer_type(
    i_customer_id         in     com_api_type_pkg.t_medium_id
) return com_api_type_pkg.t_sign is
    l_result              com_api_type_pkg.t_sign := 0;
begin
    return l_result;
end decode_customer_type;

function get_next_number(
    i_document_type       in     com_api_type_pkg.t_dict_value
  , i_eff_date            in     date default get_sysdate
  , i_inst_id             in     com_api_type_pkg.t_inst_id default get_def_inst
) return com_api_type_pkg.t_name is
    pragma    autonomous_transaction;
    l_count               com_api_type_pkg.t_medium_id;
begin
    return l_count;
end get_next_number;

function get_account_number(
    i_customer_number     in     com_api_type_pkg.t_name
  , i_currency            in     com_api_type_pkg.t_curr_code   default '643'
  , i_account_type        in     com_api_type_pkg.t_dict_value  default 'ACTP0120'
  , i_inst_id             in     com_api_type_pkg.t_inst_id
) return com_api_type_pkg.t_account_number is
   l_result               com_api_type_pkg.t_name;
begin
    return l_result;
end;

function get_friendly_account_number(
    i_account_id          in     com_api_type_pkg.t_account_id
  , i_account_number      in     com_api_type_pkg.t_name        default null
  , i_inst_id             in     com_api_type_pkg.t_inst_id     default null
  , i_currency            in     com_api_type_pkg.t_curr_code   default '643'
  , i_account_type        in     com_api_type_pkg.t_dict_value  default 'ACTP0120'
) return com_api_type_pkg.t_account_number is
    l_friendly_number     com_api_type_pkg.t_account_number;
begin
    l_friendly_number := nvl(i_account_number, to_char(i_account_id) || 'FRIENDLY'); -- it's a dummy
    return l_friendly_number;    
end;

end cst_api_name_pkg;
/
