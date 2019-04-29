create or replace package cst_ap_rcp_load_pkg is
/************************************************************
 * Processes for loading SATIM files <br />
 * Created by Gerbeev I.(gerbeev@bpcbt.com)  at 05.03.2019 <br />
 * Last changed by $Author: $ <br />
 * $LastChangedDate:: #$ <br />
 * Revision: $LastChangedRevision:  $ <br />
 * Module: cst_ap_rcp_load_pkg <br />
 * @headcom
 ***********************************************************/

procedure process_rcp(
    i_inst_id           in      com_api_type_pkg.t_inst_id      default cst_ap_api_const_pkg.AP_INST_ID
);

end cst_ap_rcp_load_pkg;
/
