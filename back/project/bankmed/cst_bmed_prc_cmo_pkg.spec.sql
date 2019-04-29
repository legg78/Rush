create or replace package cst_bmed_prc_cmo_pkg is
/**********************************************************
 * Custom handlers for CMO-canal operations 
 * 
 * Created by Gogolev I.(i.gogolev@bpcbt.com) at 07.09.2016
 * Last changed by Gogolev I.(i.gogolev@bpcbt.com) at 
 * 07.09.2016 13:40:00
 *
 * Module: CST_BMED_PRC_CMO_PKG
 * @headcom
 **********************************************************/

/**********************************************************
 *
 * Unload data of the operations in CMO-canal
 * into outgoing file with the speciphic format
 * 
 * @param i_network_id - ID of the network CMO-canal
 *
 *********************************************************/
procedure unloading_cmo_file(
    i_network_id in com_api_type_pkg.t_network_id
);
    
end;
/
