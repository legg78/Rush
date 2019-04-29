create or replace package way_prc_outgoing_pkg as
/*********************************************************
 *  Visa outgoing files API  <br />
 *  Created by Filimonov A.(filimonov@bpcbt.com)  at 21.10.2009 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: way_prc_outgoing_pkg <br />
 *  @headcom
 **********************************************************/

procedure process(
    i_network_id            in com_api_type_pkg.t_tiny_id       default null
  , i_inst_id               in com_api_type_pkg.t_inst_id       default null
  , i_host_inst_id          in com_api_type_pkg.t_inst_id       default null
  , i_start_date            in date                             default null
  , i_end_date              in date                             default null
  , i_include_affiliate     in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE  
);

end way_prc_outgoing_pkg;
/
