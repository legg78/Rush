create or replace package cst_api_name_pkg as
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
) return com_api_type_pkg.t_sign;

function get_next_number(
    i_document_type       in     com_api_type_pkg.t_dict_value
  , i_eff_date            in     date                           default get_sysdate
  , i_inst_id             in     com_api_type_pkg.t_inst_id     default get_def_inst
) return com_api_type_pkg.t_name;

function get_account_number(
    i_customer_number     in     com_api_type_pkg.t_name
  , i_currency            in     com_api_type_pkg.t_curr_code   default '643'
  , i_account_type        in     com_api_type_pkg.t_dict_value  default 'ACTP0120'
  , i_inst_id             in     com_api_type_pkg.t_inst_id
) return com_api_type_pkg.t_account_number;

/**************************************************
 * It gets a "friendly" account's number. For example, instead of "9856576812346708" it should be something like this: "SAV X1234 RUB". 
 *
 * @param   i_account_id        account's ID
 * @param   i_account_number    account's number – it should be used instead of <i_account_id> parameter but only with <i_inst_id> parameter 
 * @param   i_inst_id           institute's ID   – it should be used instead of <i_account_id> parameter but only with <i_account_number> parameter
 * @return  "friendly" account's number 
 ***************************************************/
function get_friendly_account_number(
    i_account_id          in     com_api_type_pkg.t_account_id
  , i_account_number      in     com_api_type_pkg.t_name        default null
  , i_inst_id             in     com_api_type_pkg.t_inst_id     default null
  , i_currency            in     com_api_type_pkg.t_curr_code   default '643'
  , i_account_type        in     com_api_type_pkg.t_dict_value  default 'ACTP0120'
) return com_api_type_pkg.t_account_number;

end;
/
