create or replace package acm_ui_filter_pkg as
/*********************************************************
*  UI for access management filters <br />
*  Created by Krukov E.(krukov@bpcsv.com)  at 18.05.2011 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: ACM_UI_FILTER_PKG <br />
*  @headcom
**********************************************************/

procedure add(
    o_id               out com_api_type_pkg.t_short_id
  , o_seqnum           out com_api_type_pkg.t_seqnum
  , i_name          in     com_api_type_pkg.t_name
  , i_lang          in     com_api_type_pkg.t_dict_value
  , i_section_id    in     com_api_type_pkg.t_tiny_id
  , i_inst_id       in     com_api_type_pkg.t_inst_id
  , i_user_id       in     com_api_type_pkg.t_short_id
  , i_display_order in     com_api_type_pkg.t_tiny_id
);

procedure modify(
    i_id            in     com_api_type_pkg.t_short_id
  , io_seqnum       in out com_api_type_pkg.t_seqnum
  , i_name          in     com_api_type_pkg.t_name
  , i_lang          in     com_api_type_pkg.t_dict_value
  , i_display_order in     com_api_type_pkg.t_tiny_id
);

procedure remove(
    i_id            in     com_api_type_pkg.t_short_id
  , i_seqnum        in     com_api_type_pkg.t_seqnum
);

end acm_ui_filter_pkg;
/
