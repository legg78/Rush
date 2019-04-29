create or replace package cst_smt_prc_outgoing_pkg is
/************************************************************
 * Processes for unloading files <br />
 * Created by Gogolev I.(i.gogolev@bpcbt.com)  at 06.12.2018 <br />
 * Last changed by $Author: Gogolev I. $ <br />
 * $LastChangedDate:: #$ <br />
 * Revision: $LastChangedRevision:  $ <br />
 * Module: cst_smt_prc_outgoing_pkg <br />
 * @headcom
 ***********************************************************/
procedure process_msstrxn(
    i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_network_id            in     com_api_type_pkg.t_network_id
  , i_participant_type      in     com_api_type_pkg.t_dict_value     default com_api_const_pkg.PARTICIPANT_ISSUER
);

procedure process_ptlf(
    i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_network_id            in     com_api_type_pkg.t_network_id
  , i_participant_type      in     com_api_type_pkg.t_dict_value     default com_api_const_pkg.PARTICIPANT_ISSUER
);

procedure process_tlf(
    i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_network_id            in     com_api_type_pkg.t_network_id
  , i_participant_type      in     com_api_type_pkg.t_dict_value     default com_api_const_pkg.PARTICIPANT_ISSUER
);

end;
/
