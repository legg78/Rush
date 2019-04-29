create or replace package acq_api_merchant_pkg as
/*********************************************************
 *  API for merchants in ACQ application <br />
 *  Created by Filimonov A.(filimonov@bpcbt.com)  at 22.09.2009 <br />
 *  Module: acq_api_merchant_pkg  <br />
 *  @headcom
 **********************************************************/

function get_arn(
    i_prefix            in      varchar2        default '7'
  , i_acquirer_bin      in      varchar2
  , i_proc_date         in      date            default null
) return varchar2;

procedure add_merchant(
    o_merchant_id       in out  com_api_type_pkg.t_short_id
  , i_merchant_number   in      com_api_type_pkg.t_merchant_number
  , i_merchant_name     in      com_api_type_pkg.t_name
  , i_merchant_type     in      com_api_type_pkg.t_dict_value
  , i_parent_id         in      com_api_type_pkg.t_short_id
  , i_mcc               in      varchar2
  , i_status            in      com_api_type_pkg.t_dict_value
  , i_contract_id       in      com_api_type_pkg.t_medium_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_description       in      com_api_type_pkg.t_full_desc    default null
  , i_lang              in      com_api_type_pkg.t_dict_value   default null
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
  , i_partner_id_code   in      com_api_type_pkg.t_auth_code    default null
  , i_risk_indicator    in      com_api_type_pkg.t_dict_value   default null
  , i_mc_assigned_id    in      com_api_type_pkg.t_tag          default null
);

procedure modify_merchant(
    i_merchant_id       in      com_api_type_pkg.t_short_id
  , i_merchant_number   in      com_api_type_pkg.t_merchant_number
  , i_merchant_name     in      com_api_type_pkg.t_name
  , i_parent_id         in      com_api_type_pkg.t_short_id
  , i_mcc               in      com_api_type_pkg.t_mcc
  , i_status            in      com_api_type_pkg.t_dict_value
  , i_contract_id       in      com_api_type_pkg.t_medium_id
  , i_description       in      com_api_type_pkg.t_full_desc    default null
  , i_lang              in      com_api_type_pkg.t_dict_value   default null
  , i_partner_id_code   in      com_api_type_pkg.t_auth_code    default null
  , i_risk_indicator    in      com_api_type_pkg.t_dict_value   default null
  , i_mc_assigned_id    in      com_api_type_pkg.t_tag          default null
);

procedure remove_merchant(
    i_merchant_id       in      com_api_type_pkg.t_short_id
);

procedure get_merchant (
    i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_merchant_number   in      varchar2
  , o_merchant_id          out  com_api_type_pkg.t_short_id
  , o_split_hash           out  com_api_type_pkg.t_tiny_id
);

procedure get_merchant (
    i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_merchant_number   in      varchar2
  , o_customer_id          out  com_api_type_pkg.t_medium_id
  , o_merchant_id          out  com_api_type_pkg.t_short_id
  , o_split_hash           out  com_api_type_pkg.t_tiny_id
);

procedure get_merchant(
    i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_merchant_name     in      com_api_type_pkg.t_name
  , o_merchant_id          out  com_api_type_pkg.t_short_id
);

function get_merchant(
    i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_merchant_number   in      com_api_type_pkg.t_merchant_number
  , i_mask_error        in      com_api_type_pkg.t_boolean            default com_api_const_pkg.FALSE
) return acq_api_type_pkg.t_merchant;

function get_merchant(
    i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_partner_id_code   in      com_api_type_pkg.t_auth_code
  , i_mask_error        in      com_api_type_pkg.t_boolean            default com_api_const_pkg.FALSE
) return acq_api_type_pkg.t_merchant;

function get_merchant_name(
    i_merchant_id       in      com_api_type_pkg.t_short_id
  , i_mask_error        in      com_api_type_pkg.t_boolean
) return com_api_type_pkg.t_name;

function get_merchant_number(
    i_merchant_id       in      com_api_type_pkg.t_short_id
  , i_mask_error        in      com_api_type_pkg.t_boolean            default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_name;

function get_root_merchant_id(
    i_merchant_id       in      com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_short_id;

function get_product_id(
    i_merchant_id       in      com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_short_id;

function get_inst_id(
    i_merchant_id       in      com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_inst_id;

function get_merchant_contract(
    i_merchant_id       in      com_api_type_pkg.t_short_id
) return prd_api_type_pkg.t_contract;

function get_merchant_risk_indicator(
    i_merchant_id       in      com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_dict_value;

procedure manage_status_events(
    i_merchant_id       in      com_api_type_pkg.t_short_id
  , i_status            in      com_api_type_pkg.t_dict_value
);

procedure change_status_event;

procedure set_status(
    i_merchant_id       in      com_api_type_pkg.t_short_id
  , i_status            in      com_api_type_pkg.t_dict_value
);

procedure suspend_merchant;

procedure close_merchant(
    i_mask_error        in      com_api_type_pkg.t_boolean default com_api_type_pkg.TRUE
);

function get_merchant_account_id(
    i_merchant_id       in      com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_medium_id;

function get_merchant_address_id(
    i_merchant_id       in      com_api_type_pkg.t_short_id
  , i_lang              in      com_api_type_pkg.t_dict_value default null
) return com_api_type_pkg.t_long_id;

procedure get_merchant(
    i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_merchant_card_number  in     com_api_type_pkg.t_card_number
  , o_merchant_id              out com_api_type_pkg.t_short_id
);

end;
/
