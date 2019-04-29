create or replace package vis_cst_incoming_pkg as
/*********************************************************
 *  The package with user-exits for processing of VISA incoming clearing <br />
 *
 *  Created by A. Alalykin (alalykin@bpcbt.com) at 28.07.2015 <br />
 *  Last changed by $Author: alalykin $ <br />
 *  $LastChangedDate: 2015-07-28 17:00:00 +0400#$ <br />
 *  Revision: $LastChangedRevision: 1 $ <br />
 *  Module: vis_cst_incoming_pkg <br />
 *  @headcom
 **********************************************************/ 

/*
 * Custom processing of settlement data (TC 46).
 */
procedure process_settlement_data(
    i_sttl_data          in            vis_api_type_pkg.t_settlement_data_rec
  , i_host_id            in            com_api_type_pkg.t_tiny_id
  , i_standard_id        in            com_api_type_pkg.t_tiny_id
);

/*
 * Custom processing of assign_dispute.
 */
procedure assign_dispute(
    io_visa              in out nocopy vis_api_type_pkg.t_visa_fin_mes_rec
  , o_iss_inst_id           out        com_api_type_pkg.t_inst_id
  , o_iss_network_id        out        com_api_type_pkg.t_tiny_id
  , o_acq_inst_id           out        com_api_type_pkg.t_inst_id
  , o_acq_network_id        out        com_api_type_pkg.t_tiny_id
  , o_sttl_type             out        com_api_type_pkg.t_dict_value
  , o_match_status          out        com_api_type_pkg.t_dict_value
);

/*
 * Custom preprocessing collections with data about operation and its participants.
 */
procedure before_creating_operation(
    io_oper              in out nocopy opr_api_type_pkg.t_oper_rec
  , io_iss_part          in out nocopy opr_api_type_pkg.t_oper_part_rec
  , io_acq_part          in out nocopy opr_api_type_pkg.t_oper_part_rec
);

/*
 * Custom preprocessing financial message collection.
 */
procedure process_fin_message(
    io_fin_rec           in out nocopy vis_api_type_pkg.t_visa_fin_mes_rec
);

end;
/
