create or replace package acc_ui_bunch_type_pkg is
/************************************************************
 * UI for bunch types <br />
 * Created by Khougaev  A.  (khougaev@bpcbt.com)  at 20.11.2009 <br />
 * Last changed by $Author: fomichev$ <br />
 * $LastChangedDate::                           $<br />
 * Revision: $LastChangedRevision$ <br />
 * Module: acc_ui_bunch_type_pkg <br />
 * @headcom
 *************************************************************/

procedure add (
    o_id             out  com_api_type_pkg.t_tiny_id
  , o_seqnum         out  com_api_type_pkg.t_seqnum
  , i_short_desc  in      com_api_type_pkg.t_short_desc
  , i_full_desc   in      com_api_type_pkg.t_full_desc  := null
  , i_details     in      com_api_type_pkg.t_full_desc  := null
  , i_lang        in      com_api_type_pkg.t_dict_value := null
  , i_inst_id     in      com_api_type_pkg.t_inst_id    := null
);
    
procedure modify (
    i_id          in      com_api_type_pkg.t_tiny_id
  , io_seqnum     in out  com_api_type_pkg.t_seqnum
  , i_short_desc  in      com_api_type_pkg.t_short_desc
  , i_full_desc   in      com_api_type_pkg.t_full_desc  := null
  , i_details     in      com_api_type_pkg.t_full_desc  := null
  , i_lang        in      com_api_type_pkg.t_dict_value := null
);
    
procedure remove (
    i_id          in      com_api_type_pkg.t_tiny_id
  , i_seqnum      in      com_api_type_pkg.t_seqnum
);

end;
/