create or replace package acq_ui_mcc_selection_pkg as
/*********************************************************
 *  UI for MCC selection <br />
 *  Created by Krukov E.(krukov@bpcbt.com)  at 13.12.2011 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: ACQ_UI_MCC_SELECTION_PKG  <br />
 *  @headcom
 **********************************************************/

procedure add (
    o_id                        out com_api_type_pkg.t_medium_id
    , i_oper_type               in com_api_type_pkg.t_dict_value
    , i_priority                in com_api_type_pkg.t_tiny_id
    , i_mcc                     in com_api_type_pkg.t_mcc
    , i_mcc_template_id         in com_api_type_pkg.t_medium_id
    , i_purpose_id              in com_api_type_pkg.t_short_id
    , i_oper_reason             in com_api_type_pkg.t_dict_value
    , i_merchant_name_spec      in clob
    , i_terminal_id             in com_api_type_pkg.t_medium_id
);

procedure modify (
    i_id                        in com_api_type_pkg.t_medium_id
    , i_oper_type               in com_api_type_pkg.t_dict_value
    , i_priority                in com_api_type_pkg.t_tiny_id
    , i_mcc                     in com_api_type_pkg.t_mcc
    , i_mcc_template_id         in com_api_type_pkg.t_medium_id
    , i_purpose_id              in com_api_type_pkg.t_short_id
    , i_oper_reason             in com_api_type_pkg.t_dict_value
    , i_merchant_name_spec      in clob
    , i_terminal_id             in com_api_type_pkg.t_medium_id
);

procedure remove (
    i_id                        in com_api_type_pkg.t_medium_id
);

end;
/
