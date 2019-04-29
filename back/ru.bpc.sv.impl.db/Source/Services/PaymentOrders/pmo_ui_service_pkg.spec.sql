create or replace package pmo_ui_service_pkg as
/************************************************************
 * UI for Payment Order services <br />
 * Created by Kryukov E.(krukov@bpc.ru)  at 13.07.2011  <br />
 * Last changed by $Author$  <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: pmo_ui_service_pkg <br />
 * @headcom
 ************************************************************/
procedure add(
    o_id               out com_api_type_pkg.t_short_id
  , o_seqnum           out com_api_type_pkg.t_seqnum
  , i_direction     in     com_api_type_pkg.t_boolean
  , i_label         in     com_api_type_pkg.t_short_desc
  , i_description   in     com_api_type_pkg.t_full_desc
  , i_lang          in     com_api_type_pkg.t_dict_value
  , i_short_name    in     com_api_type_pkg.t_name
  , i_inst_id       in     com_api_type_pkg.t_inst_id   default null
);

procedure modify(
    i_id            in     com_api_type_pkg.t_short_id
  , io_seqnum       in out com_api_type_pkg.t_seqnum
  , i_direction     in     com_api_type_pkg.t_boolean
  , i_label         in     com_api_type_pkg.t_short_desc
  , i_description   in     com_api_type_pkg.t_full_desc
  , i_lang          in     com_api_type_pkg.t_dict_value
  , i_short_name    in     com_api_type_pkg.t_name
  , i_inst_id       in     com_api_type_pkg.t_inst_id   default null
);

procedure remove(
    i_id            in     com_api_type_pkg.t_short_id
  , i_seqnum        in     com_api_type_pkg.t_seqnum
);

end pmo_ui_service_pkg;
/
