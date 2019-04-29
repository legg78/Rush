create or replace package cmn_ui_key_type_pkg is
/*********************************************************
 *  Communication UI key types <br />
 *  Created by Kopachev D. (kopachev@bpcbt.com)  at 14.07.2011 <br />
 *  Last changed by $Author: fomichev $ <br />
 *  $LastChangedDate:: 2011-08-05 10:31:14 +0400#$ <br />
 *  Revision: $LastChangedRevision: 11190 $ <br />
 *  Module: CMN_UI_KEY_TYPE_PKG <br />
 *  @headcom
 **********************************************************/ 
procedure add_key_type (
    o_id                        out com_api_type_pkg.t_short_id
    , o_seqnum                  out com_api_type_pkg.t_seqnum
    , i_standard_id             in com_api_type_pkg.t_tiny_id
    , i_key_type                in com_api_type_pkg.t_dict_value
    , i_standard_key_type       in com_api_type_pkg.t_dict_value
);
    
procedure modify_key_type (
    i_id                        in com_api_type_pkg.t_short_id
    , io_seqnum                 in out com_api_type_pkg.t_seqnum
    , i_standard_id             in com_api_type_pkg.t_tiny_id
    , i_key_type                in com_api_type_pkg.t_dict_value
    , i_standard_key_type       in com_api_type_pkg.t_dict_value
);

procedure remove_key_type (
    i_id                        in com_api_type_pkg.t_short_id
    , i_seqnum                  in com_api_type_pkg.t_seqnum
);

function get_key_type(
    i_standard_id              in com_api_type_pkg.t_tiny_id
  , i_standard_key_type        in com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_dict_value;

function get_standard_key_type (
    i_standard_id              in com_api_type_pkg.t_tiny_id
    , i_key_type               in com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_dict_value;

end;
/
