create or replace package mcw_prc_abu_pkg as
/************************************************************
 * Export ABU for Master Card <br />
 * Created by Shalnov N. (shalnov@bpcbt.com)  at 28.02.2017 <br />
 * Last changed by $Author: shalnov $ <br />
 * $LastChangedDate:: 2017-02-08 20:52:00 +0300#$ <br />
 * Revision: $LastChangedRevision: 60179 $ <br />
 * Module: MCW_PRC_ABU_PKG <br />
 * @headcom
 ***********************************************************/
-- this function is used in rule procedure, do not delete it.
function get_network_by_type(
    i_card_type_id      in     com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_tiny_id  deterministic;

/*
 * MasterCard ABU. Unloading Issuer Account Change Data File (R274)
 * @param i_inst_id       В–     institution id 
 * @param i_full_export       В– information about all infos will be unloaded.
 */
procedure export_format_r274( 
    i_inst_id           in     com_api_type_pkg.t_inst_id
  , i_full_export       in     com_api_type_pkg.t_boolean        default com_api_type_pkg.FALSE
);

/*
 * MasterCard ABU. import of Issuer Account Change Confirmation File (T275)
 */
procedure import_format_t275;

/*
 * MasterCard ABU. unloading  Acquirer Merchant Registration File (R625) 
 * @param i_inst_id       institution id 
 * @param i_full_export   information about all infos will be unloaded.
 */
procedure export_format_r625(
    i_inst_id  in      com_api_type_pkg.t_inst_id
);

/*
 * MasterCard ABU. loading Merchant Registration Confirmation File (T626)
 * @param i_inst_id     institution id 
 * @param i_full_export information about all infos will be unloaded.
 */
procedure import_format_t626;

end;
/
