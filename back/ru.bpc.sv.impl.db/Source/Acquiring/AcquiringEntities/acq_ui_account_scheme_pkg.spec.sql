create or replace package acq_ui_account_scheme_pkg as
/*********************************************************
*  Acquiring - account schemes user interface <br />
*  Created by Fomichev A.(fomichev@bpc.ru)  at 18.11.2010 <br />
*  Module: ACQ_UI_ACCOUNT_SCHEME_PKG <br />
*  @headcom
**********************************************************/

procedure add_account_scheme (
    o_id               out  com_api_type_pkg.t_tiny_id
  , o_seqnum           out  com_api_type_pkg.t_seqnum
  , i_inst_id      in       com_api_type_pkg.t_inst_id
  , i_label        in       com_api_type_pkg.t_name
  , i_description  in       com_api_type_pkg.t_full_desc
  , i_lang         in       com_api_type_pkg.t_dict_value  default null
);

procedure modify_account_scheme(
    i_id           in       com_api_type_pkg.t_tiny_id
  , io_seqnum      in  out  com_api_type_pkg.t_seqnum
  , i_inst_id      in       com_api_type_pkg.t_inst_id
  , i_label        in       com_api_type_pkg.t_name
  , i_description  in       com_api_type_pkg.t_full_desc
  , i_lang         in       com_api_type_pkg.t_dict_value  default null
);

procedure remove_account_scheme(
    i_id      in       com_api_type_pkg.t_tiny_id
  , i_seqnum  in       com_api_type_pkg.t_seqnum
);

end;
/
