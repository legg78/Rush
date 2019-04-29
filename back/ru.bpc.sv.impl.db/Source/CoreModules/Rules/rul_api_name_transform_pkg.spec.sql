create or replace package rul_api_name_transform_pkg as
/************************************************************
 * Transform function. <br />
 * Created by Kryukov E.(krukov@bpc.ru)  at 24.01.2012 <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: RUL_API_NAME_TRANSFORM_PKG <br />
 * @headcom
 *************************************************************/

    g_param_tab                  com_api_type_pkg.t_param_tab;

procedure set_param(
    i_param_tab           in     com_api_type_pkg.t_param_tab
);

function get_next_account return com_api_type_pkg.t_sign;

function get_next_file    return com_api_type_pkg.t_long_id;

function get_next_card_seq_number return com_api_type_pkg.t_card_number;

end rul_api_name_transform_pkg;
/
