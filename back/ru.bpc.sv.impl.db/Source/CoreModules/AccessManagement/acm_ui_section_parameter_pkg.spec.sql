create or replace package acm_ui_section_parameter_pkg as
/*********************************************************
*  UI for section parameters  <br />
*  Created by Krukov E.(krukov@bpcsv.com)  at 15.06.2011 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: ACM_UI_SECTION_PARAMETER_PKG <br />
*  @headcom
**********************************************************/

procedure add(
    o_id                 out com_api_type_pkg.t_short_id
  , o_seqnum             out com_api_type_pkg.t_seqnum
  , i_section_id      in     com_api_type_pkg.t_tiny_id
  , i_name            in     com_api_type_pkg.t_name
  , i_data_type       in     com_api_type_pkg.t_dict_value
  , i_lov_id          in     com_api_type_pkg.t_tiny_id
  , i_label           in     com_api_type_pkg.t_name
  , i_description     in     com_api_type_pkg.t_full_desc
  , i_lang            in     com_api_type_pkg.t_dict_value
);

procedure modify(
    i_id              in     com_api_type_pkg.t_short_id
  , io_seqnum         in out com_api_type_pkg.t_seqnum
  , i_section_id      in     com_api_type_pkg.t_tiny_id
  , i_name            in     com_api_type_pkg.t_name
  , i_data_type       in     com_api_type_pkg.t_dict_value
  , i_lov_id          in     com_api_type_pkg.t_tiny_id
  , i_label           in     com_api_type_pkg.t_name
  , i_description     in     com_api_type_pkg.t_full_desc
  , i_lang            in     com_api_type_pkg.t_dict_value
);

procedure remove(
    i_id              in     com_api_type_pkg.t_short_id
  , i_seqnum          in     com_api_type_pkg.t_seqnum
);

end acm_ui_section_parameter_pkg;
/
