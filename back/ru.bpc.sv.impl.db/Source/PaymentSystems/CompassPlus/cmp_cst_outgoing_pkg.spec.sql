create or replace package cmp_cst_outgoing_pkg as
/*********************************************************
 *  The package with user-exits for VISA outgoing processing <br />
 *
 *  Created by Madan B. (madan@bpcbt.com) at 24.11.2014 <br />
 *  Last changed by $Author: madan $ <br />
 *  $LastChangedDate: 2014-11-24 16:28:00 +0400#$ <br />
 *  Revision: $LastChangedRevision: 1 $ <br />
 *  Module: vis_cst_outgoing_pkg <br />
 *  @headcom
 **********************************************************/

/**********************************************************
 * Custom processing for outgoing financial message.
 *
 * @param io_fin_rec      Financial message record
 *
 **********************************************************/
procedure process_presentment(
    io_fin_rec                 in out nocopy cmp_api_type_pkg.t_cmp_fin_mes_rec    
  , i_network_id               in com_api_type_pkg.t_tiny_id
  , i_host_id                  in com_api_type_pkg.t_tiny_id
  , i_inst_id                  in com_api_type_pkg.t_inst_id
  , i_standard_id              in com_api_type_pkg.t_inst_id
);

end;
/
