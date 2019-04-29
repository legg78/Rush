create or replace package cst_woo_prc_operation_pkg as
/*********************************************************
*  Processes for specific pre/post-processing operations <br />
*  Created by  A. Alalykin (alalykin@bpcbt.com) at 11.04.2017 <br />
*  Module: CST_WOO_PRC_OPERATION_PKG <br />
*  @headcom
**********************************************************/

/*
 * If current system date is in the problem range (see (2)) then the procedure postpones
 * processing of operations by changing their status <Awaiting closure invoice>, these
 * operations should satisfy the following conditions:
 * 1) have active credit service;
 * 2) operation dates are in the range since prev_date(CYTP1006) till next_date(CYTP1001).
 * Operations are unblocked for normal processing after date next_date(CYTP1001)+1 by
 * procedure unblock_credit_operations.
 * @param i_invoicing_lag - lag of ending CYTP1001 (Invoicing period)
                            compared to CYTP1006 (Forced interest charge period)
 */
procedure freeze_credit_operations(
    i_invoicing_lag    in     com_api_type_pkg.t_tiny_id
);

/*
 * The procedure unblocks operations that were previously postponed by procedure freeze_credit_operations
 * based on events in evt_event_object (where current system date is equal to events' eff_date).
 */
procedure unblock_credit_operations;

end;
/
