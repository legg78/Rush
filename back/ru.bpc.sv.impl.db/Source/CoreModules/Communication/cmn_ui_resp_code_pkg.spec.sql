create or replace package cmn_ui_resp_code_pkg as
/*********************************************************
 *  Communication - response code mapping  <br />
 *  Created by Filimonov A.(filimonov@bpcbt.com)  at 26.03.2010 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: CMN_UI_RESP_CODE_PKG <br />
 *  @headcom
 **********************************************************/
procedure add_resp_code(
    o_resp_code_id         out  com_api_type_pkg.t_short_id
  , o_seqnum               out  com_api_type_pkg.t_seqnum
  , i_standard          in      com_api_type_pkg.t_tiny_id
  , i_resp_code         in      com_api_type_pkg.t_dict_value
  , i_device_code_in    in      com_api_type_pkg.t_dict_value
  , i_device_code_out   in      com_api_type_pkg.t_dict_value
  , i_resp_reason       in      com_api_type_pkg.t_dict_value
);

procedure modify_resp_code(
    i_resp_code_id      in      com_api_type_pkg.t_short_id
  , io_seqnum           in out  com_api_type_pkg.t_seqnum
  , i_device_code_in    in      com_api_type_pkg.t_dict_value
  , i_device_code_out   in      com_api_type_pkg.t_dict_value
  , i_resp_reason       in      com_api_type_pkg.t_dict_value
);

procedure remove_resp_code(
    i_resp_code_id      in      com_api_type_pkg.t_short_id
  , i_seqnum            in      com_api_type_pkg.t_seqnum
);

end;
/
