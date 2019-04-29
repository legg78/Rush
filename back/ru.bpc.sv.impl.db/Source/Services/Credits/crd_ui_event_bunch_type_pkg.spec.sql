CREATE OR REPLACE package crd_ui_event_bunch_type_pkg is

 /*********************************************************
 *  Interface for Event bunch types  <br />
 *  Created by Fomichev A.(fomichev@bpcbt.com)  at 26.07.2011 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: crd_ui_event_bunch_type_pkg <br />
 *  @headcom
 **********************************************************/

procedure add_event_bunch_type (
    o_id                    out  com_api_type_pkg.t_tiny_id
  , o_seqnum                out  com_api_type_pkg.t_seqnum
  , i_event_type         in      com_api_type_pkg.t_dict_value
  , i_balance_type       in      com_api_type_pkg.t_dict_value
  , i_bunch_type_id      in      com_api_type_pkg.t_tiny_id
  , i_inst_id            in      com_api_type_pkg.t_inst_id
  , i_add_bunch_type_id  in      com_api_type_pkg.t_tiny_id
);

procedure modify_event_bunch_type (
    i_id                 in      com_api_type_pkg.t_tiny_id
  , io_seqnum            in out  com_api_type_pkg.t_seqnum
  , i_event_type         in      com_api_type_pkg.t_dict_value
  , i_balance_type       in      com_api_type_pkg.t_dict_value
  , i_bunch_type_id      in      com_api_type_pkg.t_tiny_id
  , i_inst_id            in      com_api_type_pkg.t_inst_id
  , i_add_bunch_type_id  in      com_api_type_pkg.t_tiny_id
);

procedure remove_event_bunch_type (
    i_id             in      com_api_type_pkg.t_tiny_id
  , i_seqnum         in      com_api_type_pkg.t_seqnum
);

end;
/
