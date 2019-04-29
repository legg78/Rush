create or replace package com_ui_id_type_pkg as
/************************************************************
 * Provides an interface for managing document types. <br />
 * Created by Kryukov E.(krukov@bpc.ru)  at 13.05.2011 <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: COM_UI_ID_TYPE_PKG <br />
 * @headcom
 *************************************************************/

procedure add(
    o_id              out com_api_type_pkg.t_tiny_id
  , o_seqnum          out com_api_type_pkg.t_seqnum
  , i_entity_type  in     com_api_type_pkg.t_dict_value
  , i_inst_id      in     com_api_type_pkg.t_inst_id
  , i_id_type      in     com_api_type_pkg.t_dict_value
);

procedure modify(
    i_id           in     com_api_type_pkg.t_tiny_id
  , io_seqnum      in out com_api_type_pkg.t_seqnum
  , i_entity_type  in     com_api_type_pkg.t_dict_value
  , i_id_type      in     com_api_type_pkg.t_dict_value
);

procedure remove(
    i_id           in     com_api_type_pkg.t_tiny_id
  , i_seqnum       in     com_api_type_pkg.t_seqnum
);

end com_ui_id_type_pkg;
/
