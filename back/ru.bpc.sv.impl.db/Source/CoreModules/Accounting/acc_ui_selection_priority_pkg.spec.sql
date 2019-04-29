create or replace package acc_ui_selection_priority_pkg is
/*********************************************************
 *  UI for Account selection priority <br />
 *  Created by Khougaev A.(khougaev@bpcbt.com)  at 20.09.2011 <br />
 *  Module: ACC_UI_SELECTION_PRIORITY_PKG <br />
 *  @headcom
 **********************************************************/

procedure add(
    o_id                  out  com_api_type_pkg.t_tiny_id
  , o_seqnum              out  com_api_type_pkg.t_seqnum
  , i_priority         in      com_api_type_pkg.t_tiny_id
  , i_inst_id          in      com_api_type_pkg.t_dict_value
  , i_oper_type        in      com_api_type_pkg.t_dict_value
  , i_account_type     in      com_api_type_pkg.t_dict_value
  , i_account_status   in      com_api_type_pkg.t_dict_value
  , i_party_type       in      com_api_type_pkg.t_dict_value
  , i_msg_type         in      com_api_type_pkg.t_dict_value
  , i_mod_id           in      com_api_type_pkg.t_dict_value    default null
  , i_account_currency in      com_api_type_pkg.t_curr_code     default null
);

procedure modify(
    i_id               in      com_api_type_pkg.t_tiny_id
  , io_seqnum          in out  com_api_type_pkg.t_seqnum
  , i_priority         in      com_api_type_pkg.t_tiny_id
  , i_inst_id          in      com_api_type_pkg.t_dict_value
  , i_oper_type        in      com_api_type_pkg.t_dict_value
  , i_account_type     in      com_api_type_pkg.t_dict_value
  , i_account_status   in      com_api_type_pkg.t_dict_value
  , i_party_type       in      com_api_type_pkg.t_dict_value
  , i_msg_type         in      com_api_type_pkg.t_dict_value
  , i_mod_id           in      com_api_type_pkg.t_dict_value    default null
  , i_account_currency in      com_api_type_pkg.t_curr_code     default null
);

procedure delete(
    i_id              in      com_api_type_pkg.t_tiny_id
  , i_seqnum          in      com_api_type_pkg.t_seqnum
);

end;
/
