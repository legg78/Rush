CREATE OR REPLACE package net_api_network_pkg as
/**********************************************************
*  API for networks <br />
*  Created by Filimonov A.(filimonov@bpc.ru)  at 14.10.2009 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: NET_API_NETWORK_PKG <br />
*  @headcom
***********************************************************/
function get_offline_standard(
    i_host_id                   in com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_tiny_id;

function get_offline_standard(
    i_network_id                in com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_tiny_id;

function get_inst_id(
    i_network_id                in com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_tiny_id;

function get_default_host (
    i_network_id                in com_api_type_pkg.t_tiny_id
    , i_host_inst_id            in com_api_type_pkg.t_inst_id  default null
) return com_api_type_pkg.t_tiny_id;

function get_member_id(
    i_inst_id                   in com_api_type_pkg.t_inst_id
  , i_network_id                in com_api_type_pkg.t_tiny_id
  , i_participant_type          in com_api_type_pkg.t_dict_value default null
) return com_api_type_pkg.t_tiny_id;

function get_host_id(
    i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_network_id          in     com_api_type_pkg.t_tiny_id
  , i_participant_type    in     com_api_type_pkg.t_dict_value default null
) return com_api_type_pkg.t_tiny_id;

procedure get_host_info(
    i_member_id           in     com_api_type_pkg.t_tiny_id
  , i_participant_type    in     com_api_type_pkg.t_dict_value
  , o_inst_id                out com_api_type_pkg.t_inst_id
  , o_network_id             out com_api_type_pkg.t_tiny_id
);

function get_member_interchange (
    i_mod_id                    in com_api_type_pkg.t_inst_id
) return com_api_type_pkg.t_byte_char;

end;
/