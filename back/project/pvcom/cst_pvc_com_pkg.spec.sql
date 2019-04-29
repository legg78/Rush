create or replace package cst_pvc_com_pkg as
/*************************************************************
 * Common functions for PVCom bank                            <br />
 * Created by: ChauHuynh (huynh@bpcbt.com) at 24.08.2018    $ <br />
 * Module: CST_PVC_COM_PKG                                    <br />
 * @headcom
 *************************************************************/

function get_main_card_id (
    i_account_id            in  com_api_type_pkg.t_account_id
  , i_split_hash            in  com_api_type_pkg.t_tiny_id     default null
) return com_api_type_pkg.t_medium_id;

function iss_and_acq_agents_are_same (
    i_oper_id               in    com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_boolean;

function check_overlimit (
    i_entity_type           in    com_api_type_pkg.t_dict_value
  , i_object_id             in    com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_boolean;

function check_annual_fee_is_charged (
    i_entity_type           in    com_api_type_pkg.t_dict_value
  , i_object_id             in    com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_boolean;

end cst_pvc_com_pkg;
/
