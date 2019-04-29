create or replace package cst_cfc_prc_incoming_pkg is
/*********************************************************
 *  Processes for data import <br />
 *  Created by Fomichev A.(fomichev@bpcbt.com)  at 27.11.2017 <br />
 *  Last changed by ChauHuynh <br />
 *  $LastChangedDate: 16.12.2017 <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: CST_CFC_PRC_INCOMING_PKG  <br />
 *  @headcom
 **********************************************************/

procedure process_unsuccessfull_trans(
    i_inst_id       in     com_api_type_pkg.t_inst_id
  , i_ntf_scheme_id in     com_api_type_pkg.t_tiny_id
  , i_lang          in     com_api_type_pkg.t_dict_value
);

procedure process_incoming_bucket;

end cst_cfc_prc_incoming_pkg;
/
