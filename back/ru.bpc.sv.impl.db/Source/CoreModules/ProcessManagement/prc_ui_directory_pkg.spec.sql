create or replace package prc_ui_directory_pkg as
/************************************************************
 * UI for directory settings <br />
 * Created by Kryukov E.(krukov@bpc.ru)  at 30.08.2013 <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: PRC_UI_DIRECTORY_PKG <br />
 * @headcom
 ***********************************************************/
 
procedure add_directory(
    o_id                     out com_api_type_pkg.t_tiny_id
  , o_seqnum                 out com_api_type_pkg.t_seqnum
  , i_name                in     com_api_type_pkg.t_name
  , i_encryption_type     in     com_api_type_pkg.t_dict_value
  , i_directory_path      in     com_api_type_pkg.t_name
  , i_lang                in     com_api_type_pkg.t_dict_value
);

procedure modify_directory(
    i_id                  in     com_api_type_pkg.t_tiny_id
  , io_seqnum             in out com_api_type_pkg.t_seqnum
  , i_name                in     com_api_type_pkg.t_name
  , i_encryption_type     in     com_api_type_pkg.t_dict_value
  , i_directory_path      in     com_api_type_pkg.t_name
  , i_lang                in     com_api_type_pkg.t_dict_value
);

procedure remove_directory(
    i_id                  in     com_api_type_pkg.t_tiny_id
  , i_seqnum              in     com_api_type_pkg.t_seqnum
);

end prc_ui_directory_pkg;
/
