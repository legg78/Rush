create or replace package mcw_prc_mcom_pkg is
/*********************************************************
 *  MasterCard incoming dispute records API  <br />
 *  Created by Kolodkina J. (kolodkina@bpcbt.com)  at 18.03.2019 <br />
 *  Module: MCW_PRC_MCOM_PKG <br />
 *  @headcom
 **********************************************************/

procedure load(
    i_inst_id           in     com_api_type_pkg.t_inst_id
  , i_network_id        in     com_api_type_pkg.t_tiny_id
  , i_create_operation  in     com_api_type_pkg.t_boolean      default null
  , i_claim_tab         in     mcw_mcom_claim_tpt
  , i_retrieval_tab     in     mcw_mcom_retrieval_tpt
  , i_chargeback_tab    in     mcw_mcom_chbck_tpt
  , i_fee_tab           in     mcw_mcom_fee_tpt
  , i_attachment_tab    in     mcw_mcom_attachment_tpt
);

end mcw_prc_mcom_pkg;
/
