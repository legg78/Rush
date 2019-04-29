create or replace package aup_api_process_pkg as
/************************************************************
 * Authorization Online Process<br />
 * Created by Khougaev A.(khougaev@bpc.ru)  at 02.09.2010  <br />
 * Last changed by $Author$  <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: AUT_API_PROCESS_PKG <br />
 * @headcom
 ************************************************************/
function auth_process (
    i_id                        in com_api_type_pkg.t_long_id
    , i_stage                   in com_api_type_pkg.t_dict_value := opr_api_const_pkg.PROCESSING_STAGE_COMMON
    , o_amounts                 out com_api_type_pkg.t_amount_by_name_tab
    , o_accounts                out acc_api_type_pkg.t_account_by_name_tab
    , o_tags                    out com_api_type_pkg.t_desc_tab
) return com_api_type_pkg.t_dict_value;

function unhold (
    i_id                        in com_api_type_pkg.t_long_id
    , i_reason                  in com_api_type_pkg.t_dict_value := null
) return com_api_type_pkg.t_dict_value;

procedure save_amounts (
    i_auth_id                   in com_api_type_pkg.t_long_id
    , i_amounts                 in com_api_type_pkg.t_raw_data
);

procedure get_amounts (
    i_auth_id                   in  com_api_type_pkg.t_long_id
    , o_amounts                 out com_api_type_pkg.t_raw_data
);

/*
 * Function returns string with serialized amount record that should be used
 * for saving in <aut_auth.amounts> field (this field contains amount as raw data).
 */
function serialize_auth_amount(
    i_amount_type               in     com_api_type_pkg.t_dict_value
  , i_amount_rec                in     com_api_type_pkg.t_amount_rec
) return com_api_type_pkg.t_name;

end;
/
