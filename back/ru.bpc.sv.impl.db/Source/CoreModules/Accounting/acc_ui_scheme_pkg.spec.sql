create or replace package acc_ui_scheme_pkg as
/*********************************************************
*  Account schemes UI  <br />
*  Created by Kryukov E.(krukov@bpcsv.com)  at 28.08.2012 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: ACC_UI_SCHEME_PKG <br />
*  @headcom
**********************************************************/

procedure add(
    o_id                     out com_api_type_pkg.t_tiny_id
  , o_seqnum                 out com_api_type_pkg.t_tiny_id
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_name                in     com_api_type_pkg.t_name
  , i_description         in     com_api_type_pkg.t_short_desc
  , i_lang                in     com_api_type_pkg.t_dict_value
);

procedure modify(
    i_id                  in     com_api_type_pkg.t_tiny_id
  , io_seqnum             in out com_api_type_pkg.t_tiny_id
  , i_name                in     com_api_type_pkg.t_name
  , i_description         in     com_api_type_pkg.t_short_desc
  , i_lang                in     com_api_type_pkg.t_dict_value
);

procedure remove(
    i_id                  in     com_api_type_pkg.t_tiny_id
  , i_seqnum              in     com_api_type_pkg.t_tiny_id
);

procedure add_account(
    o_id                     out com_api_type_pkg.t_medium_id
  , o_seqnum                 out com_api_type_pkg.t_tiny_id
  , i_scheme_id           in     com_api_type_pkg.t_tiny_id
  , i_account_type        in     com_api_type_pkg.t_dict_value
  , i_entity_type         in     com_api_type_pkg.t_dict_value
  , i_object_id           in     com_api_type_pkg.t_long_id
  , i_mod_id              in     com_api_type_pkg.t_tiny_id
  , i_account_id          in     com_api_type_pkg.t_account_id
);

procedure modify_account(
    i_id                  in     com_api_type_pkg.t_medium_id
  , io_seqnum             in out com_api_type_pkg.t_tiny_id
  , i_scheme_id           in     com_api_type_pkg.t_tiny_id
  , i_account_type        in     com_api_type_pkg.t_dict_value
  , i_entity_type         in     com_api_type_pkg.t_dict_value
  , i_object_id           in     com_api_type_pkg.t_long_id
  , i_mod_id              in     com_api_type_pkg.t_tiny_id
  , i_account_id          in     com_api_type_pkg.t_account_id
);

procedure remove_account(
    i_id                  in     com_api_type_pkg.t_medium_id
  , i_seqnum              in     com_api_type_pkg.t_tiny_id
);

end acc_ui_scheme_pkg;
/
