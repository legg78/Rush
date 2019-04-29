create or replace package nbc_prc_incoming_pkg as
/*********************************************************
 *  NBC incoming files API  <br />
 *  Created by Kolodkina Y.(kolodkina@bpcbt.com)  at 21.11.2016 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: nbc_prc_incoming_pkg <br />
 *  @headcom
 **********************************************************/

-- Processing of NBC Incoming Clearing Files
procedure process_rf (
    i_network_id            in com_api_type_pkg.t_tiny_id
);

procedure process_df (
    i_network_id            in com_api_type_pkg.t_tiny_id
);

end;
/
