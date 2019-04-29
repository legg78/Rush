create or replace package net_ui_interface_pkg is
/********************************************************* 
 *  UI for network interface <br /> 
 *  Created by Filimonov A.(filimonov@bpcbt.com)  at 19.07.2010 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module: net_ui_interface_pkg  <br /> 
 *  @headcom 
 **********************************************************/ 
 
/*
 * Register new consumers of network hosts
 * @param o_id                  Consumers of network hosts identificator
 * @param o_seqnum              Sequence number
 * @param i_host_member_id      Network member institution which acts as host
 * @param i_consumer_member_id  Network member institution which connects to host
 * @param i_msp_member_id       Network service provider member
 */  
procedure add (
    o_id                       out  com_api_type_pkg.t_tiny_id
  , o_seqnum                   out  com_api_type_pkg.t_seqnum
  , i_host_member_id        in      com_api_type_pkg.t_tiny_id
  , i_consumer_member_id    in      com_api_type_pkg.t_tiny_id
  , i_msp_member_id         in      com_api_type_pkg.t_tiny_id
);

/*
 * Modify consumers of network hosts
 * @param i_id                  Consumers of network hosts identificator
 * @param io_seqnum             Sequence number
 * @param i_host_member_id      Network member institution which acts as host
 * @param i_consumer_member_id  Network member institution which connects to host
 * @param i_msp_member_id       Network service provider member
 */  
procedure modify (
    i_id                    in      com_api_type_pkg.t_tiny_id
  , io_seqnum               in out  com_api_type_pkg.t_seqnum
  , i_host_member_id        in      com_api_type_pkg.t_tiny_id
  , i_consumer_member_id    in      com_api_type_pkg.t_tiny_id
  , i_msp_member_id         in      com_api_type_pkg.t_tiny_id
);

/*
 * Remove consumers of network hosts
 * @param i_id                  Consumers of network hosts identificator
 * @param i_seqnum              Sequence number
 */  
procedure remove (
    i_id                    in      com_api_type_pkg.t_tiny_id
  , i_seqnum                in      com_api_type_pkg.t_seqnum
);

end; 
/
