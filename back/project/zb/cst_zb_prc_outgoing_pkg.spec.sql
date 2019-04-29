create or replace package cst_zb_prc_outgoing_pkg is
/**********************************************************
 * Custom handlers for uploading various data for ZB
 *
 * Created by Gogolev I.(i.gogolev@bpcbt.com) at 28.01.2019<br />
 * <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: CST_ZB_PRC_OUTGOING_PKG
 * @headcom
 **********************************************************/

procedure uploading_merchant_rbfile(
    i_inst_id                   in     com_api_type_pkg.t_inst_id
  , i_full_export               in     com_api_type_pkg.t_boolean      default null
);

end cst_zb_prc_outgoing_pkg;
/
