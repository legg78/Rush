create or replace package acc_ui_macros_bunch_type_pkg is
/************************************************************
 * UI for relationship table between macros type and bunch type <br />
 * Created by Kondratyev  A.  (kondratyev@bpcbt.com)  at 25.10.2017 <br />
 * Last changed by $Author: kondratyev$ <br />
 * $LastChangedDate::                           $<br />
 * Revision: $LastChangedRevision$ <br />
 * Module: acc_ui_macros_bunch_type_pkg <br />
 * @headcom
 *************************************************************/

procedure add (
    o_id                    out  com_api_type_pkg.t_tiny_id
  , o_seqnum                out  com_api_type_pkg.t_seqnum
  , i_macros_type_id     in      com_api_type_pkg.t_tiny_id
  , i_bunch_type_id      in      com_api_type_pkg.t_tiny_id
  , i_inst_id            in      com_api_type_pkg.t_inst_id
);
    
procedure modify (
    i_id          in      com_api_type_pkg.t_tiny_id
  , io_seqnum     in out  com_api_type_pkg.t_seqnum
  , i_macros_type_id     in      com_api_type_pkg.t_tiny_id
  , i_bunch_type_id      in      com_api_type_pkg.t_tiny_id
  , i_inst_id            in      com_api_type_pkg.t_inst_id
);
    
procedure remove (
    i_id          in      com_api_type_pkg.t_tiny_id
  , i_seqnum      in      com_api_type_pkg.t_seqnum
);

end;
/
