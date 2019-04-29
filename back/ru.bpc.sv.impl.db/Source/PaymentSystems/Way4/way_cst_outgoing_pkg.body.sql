create or replace package body way_cst_outgoing_pkg as
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
 * @param io_fin_message      Financial message record
 * @param i_network_id        Network ID
 * @param i_host_id           Host ID
 * @param i_inst_id           Institute ID
 * @param i_standard_id       Standard ID
 *
 **********************************************************/
procedure process_fin_message (
    io_fin_message  in out nocopy vis_api_type_pkg.t_visa_fin_mes_fraud_rec
  , i_network_id               in com_api_type_pkg.t_tiny_id
  , i_host_id                  in com_api_type_pkg.t_tiny_id
  , i_inst_id                  in com_api_type_pkg.t_inst_id
  , i_standard_id              in com_api_type_pkg.t_inst_id
)
is
begin
    null;
end process_fin_message;

end way_cst_outgoing_pkg;
/
