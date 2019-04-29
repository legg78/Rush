create or replace package cst_bmed_prc_outgoing_cbs_pkg is
/**********************************************************
 * Custom handlers for loading/uploading operations from/in to CBS
 *
 * Created by Gogolev I.(i.gogolev@bpcbt.com) at 30.01.2017<br />
 * <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: CST_BMED_PRC_OUTGOING_CBS_PKG
 * @headcom
 **********************************************************/

procedure unloading_cbs_file(
    i_file_type                 in     com_api_type_pkg.t_dict_value
  , i_inst_id                   in     com_api_type_pkg.t_inst_id
  , i_date_type                 in     com_api_type_pkg.t_dict_value
  , i_start_date                in     date                            default null
  , i_end_date                  in     date                            default null
  , i_shift_from                in     com_api_type_pkg.t_tiny_id      default 0
  , i_shift_to                  in     com_api_type_pkg.t_tiny_id      default 0
  , i_sttl_day                  in     com_api_type_pkg.t_medium_id    default null
  , i_array_settl_type_id       in     com_api_type_pkg.t_medium_id    default null
  , i_array_operations_type_id  in     com_api_type_pkg.t_medium_id    default null
  , i_array_trans_type_id       in     com_api_type_pkg.t_medium_id    default null
  , i_full_export               in     com_api_type_pkg.t_boolean      default null
);

end cst_bmed_prc_outgoing_cbs_pkg;
/
