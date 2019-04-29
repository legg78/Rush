create or replace package cst_ap_tp_load_pkg is
/************************************************************
 * Processes for loading TP files <br />
 * Created by Vasilyeva Y.(vasilieva@bpcbt.com)  at 25.02.2019 <br />
 * Last changed by $Author: Vasilyeva Y. $ <br />
 * $LastChangedDate:: #$ <br />
 * Revision: $LastChangedRevision:  $ <br />
 * Module: cst_smt_prc_incoming_pkg <br />
 * @headcom
 ***********************************************************/
procedure process_tp;

procedure put_auth_data(
    i_auth_data    in aut_api_type_pkg.t_auth_rec
);

end cst_ap_tp_load_pkg;
/
