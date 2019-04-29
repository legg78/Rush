create or replace package h2h_prc_outgoing_pkg as
/*********************************************************
 *  H2H outgoing clearing <br />
 *  Created by Gerbeev I.(gerbeev@bpcbt.com)  at 22.06.2018 <br />
 *  Module: H2H_PRC_OUTGOING_PKG <br />
 *  @headcom
 **********************************************************/

/*
 * Unloading (export) of an outgoing H2H clearing file.
 * @param i_inst_id - it defines for which institution an outgoing file(s) is(are) created;
 *     the process gets a value of H2H standard parameter H2H_INST_CODE by the host
 *     of the institution (i_inst_id), then it unloads H2H messages by creating a separate
 *     outgoing file for every forwarding institution (h2h_fin_message.forw_inst_code)
 */
procedure process(
    i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_network_id        in      com_api_type_pkg.t_network_id
);

end;
/
