create or replace package vis_api_transaction_pkg as
/*********************************************************
 *  API for getting transactions for VISA financail messages <br />
 *  Created by Alalykin A.(alalykin@bpcbt.com) at 29.03.2017 <br />
 *  Module: VIS_API_TRANSACTION_PKG <br />
 *  @headcom
 **********************************************************/

/*
 * Procedure returns a cursor with unheld entries of uploading incoming VISA messages (after operations matching).
 */
procedure get_unheld_transactions(
    i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_agent_id              in     com_api_type_pkg.t_agent_id
  , i_start_date            in     date
  , i_end_date              in     date
  , o_ref_cur                  out com_api_type_pkg.t_ref_cur
);

/*
 * Procedure returns a cursor with deducted entries of uploading incoming VISA messages (after operations matching).
 */
procedure get_deducted_transactions(
    i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_agent_id              in     com_api_type_pkg.t_agent_id
  , i_start_date            in     date
  , i_end_date              in     date
  , o_ref_cur                  out com_api_type_pkg.t_ref_cur
);

/*
 * Procedure returns a cursor for a list of transactions without settlement from Visa.
 */
procedure get_transactions_without_sttl(
    i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_agent_id              in     com_api_type_pkg.t_agent_id
  , i_start_date            in     date
  , i_end_date              in     date
  , o_ref_cur                  out com_api_type_pkg.t_ref_cur
);

/*
 * Procedure returns a cursor for a list of settlement Visa messages without authorizations from SVFE.
 */
procedure get_transactions_without_auth(
    i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_agent_id              in     com_api_type_pkg.t_agent_id
  , i_start_date            in     date
  , i_end_date              in     date
  , o_ref_cur                  out com_api_type_pkg.t_ref_cur
);

end;
/
