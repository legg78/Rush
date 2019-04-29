create or replace package cst_ap_prc_outgoing_pkg is
/**********************************************************
 * Custom handlers for uploading various data
 * 
 * Created by Gogolev I.(i.gogolev@bpcbt.com) at 21.03.2019 <br />
 * <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: CST_AP_PRC_OUTGOING_PKG
 * @headcom
 **********************************************************/

procedure uploading_cbs_file(
    i_inst_id               in  com_api_type_pkg.t_inst_id
  , i_full_export           in  com_api_type_pkg.t_boolean          default com_api_type_pkg.FALSE
  , i_date_type             in  com_api_type_pkg.t_dict_value
  , i_eff_date              in  date
  , i_array_settl_type_id   in  com_api_type_pkg.t_medium_id        default null
);
    
end cst_ap_prc_outgoing_pkg;
/
