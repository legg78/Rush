create or replace package acc_ui_balance_type_pkg as
/*******************************************************************
*  Account balance type UI  <br />
*  Created by Khougaev A.(khougaev@bpcsv.com)  at 06.11.2009 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: ACC_UI_BALANCE_TYPE_PKG <br />
*  @headcom
********************************************************************/
procedure add (
    o_id                     out com_api_type_pkg.t_tiny_id
  , o_seqnum                 out com_api_type_pkg.t_seqnum
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_account_type        in     com_api_type_pkg.t_dict_value
  , i_balance_type        in     com_api_type_pkg.t_dict_value
  , i_currency            in     com_api_type_pkg.t_curr_code
  , i_rate_type           in     com_api_type_pkg.t_dict_value
  , i_aval_impact         in     com_api_type_pkg.t_boolean
  , i_status              in     com_api_type_pkg.t_dict_value
  , i_number_format_id    in     com_api_type_pkg.t_tiny_id
  , i_number_prefix       in     com_api_type_pkg.t_name
  , i_update_macros_type  in     com_api_type_pkg.t_tiny_id := null
  , i_balance_algorithm   in     com_api_type_pkg.t_dict_value default null
);

procedure modify (
    i_id                  in     com_api_type_pkg.t_tiny_id
  , io_seqnum             in out com_api_type_pkg.t_seqnum
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_account_type        in     com_api_type_pkg.t_dict_value
  , i_balance_type        in     com_api_type_pkg.t_dict_value
  , i_currency            in     com_api_type_pkg.t_curr_code
  , i_rate_type           in     com_api_type_pkg.t_dict_value
  , i_aval_impact         in     com_api_type_pkg.t_boolean
  , i_status              in     com_api_type_pkg.t_dict_value
  , i_number_format_id    in     com_api_type_pkg.t_tiny_id
  , i_number_prefix       in     com_api_type_pkg.t_name
  , i_update_macros_type  in     com_api_type_pkg.t_tiny_id := null
  , i_balance_algorithm   in     com_api_type_pkg.t_dict_value default null
);
    
procedure remove (
    i_id                  in     com_api_type_pkg.t_tiny_id
  , i_seqnum              in     com_api_type_pkg.t_seqnum
);

end;
/
