create or replace package cmn_ui_tcp_ip_pkg as
/********************************************************* 
 *  UI for tcp_ip <br />
 *  Created by Filimonov A.(filimonov@bpcbt.com)  at 12.11.2009 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: cmn_ui_tcp_ip_pkg  <br />
 *  @headcom
 **********************************************************/ 

procedure add_tcp_ip (
    i_tcp_ip_id           in     com_api_type_pkg.t_short_id
  , i_remote_address      in     com_api_type_pkg.t_name
  , i_local_port          in     com_api_type_pkg.t_name
  , i_remote_port         in     com_api_type_pkg.t_name
  , i_initiator           in     com_api_type_pkg.t_dict_value
  , i_format              in     com_api_type_pkg.t_name
  , i_keep_alive          in     com_api_type_pkg.t_boolean
  , i_is_enabled          in     com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
  , i_monitor_connection  in     com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
  , i_multiple_connection in     com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
  , o_seqnum                 out com_api_type_pkg.t_seqnum
);

procedure modify_tcp_ip (
    i_tcp_ip_id           in out com_api_type_pkg.t_short_id
  , i_remote_address      in     com_api_type_pkg.t_name
  , i_local_port          in     com_api_type_pkg.t_name
  , i_remote_port         in     com_api_type_pkg.t_name
  , i_initiator           in     com_api_type_pkg.t_dict_value
  , i_format              in     com_api_type_pkg.t_name
  , i_keep_alive          in     com_api_type_pkg.t_boolean
  , i_monitor_connection  in     com_api_type_pkg.t_boolean
  , i_multiple_connection in     com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
  , io_seqnum             in out com_api_type_pkg.t_seqnum
);

procedure remove_tcp_ip (
    i_tcp_ip_id           in     com_api_type_pkg.t_short_id
  , i_seqnum              in     com_api_type_pkg.t_seqnum
);

end;
/
