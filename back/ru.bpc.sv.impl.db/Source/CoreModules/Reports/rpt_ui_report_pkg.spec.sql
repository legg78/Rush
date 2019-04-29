create or replace package rpt_ui_report_pkg as
/*********************************************************
 *  Interface for reports definition  <br />
 *  Created by Fomichev A.(fomichev@bpcbt.com) at 18.05.2010 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: RPT_UI_REPORT_PKG <br />
 *  @headcom
 **********************************************************/

procedure add_report(
    o_report_id           out  com_api_type_pkg.t_short_id
  , o_seqnum              out  com_api_type_pkg.t_seqnum
  , i_report_name      in      com_api_type_pkg.t_name
  , i_report_desc      in      com_api_type_pkg.t_short_desc
  , i_source           in      clob
  , i_source_type      in      com_api_type_pkg.t_attr_name
  , i_inst_id          in      com_api_type_pkg.t_inst_id
  , i_lang             in      com_api_type_pkg.t_name
  , i_is_deterministic in      com_api_type_pkg.t_boolean
  , i_name_format_id   in      com_api_type_pkg.t_tiny_id
  , i_is_notification  in      com_api_type_pkg.t_boolean default null
  , i_document_type    in      com_api_type_pkg.t_dict_value default null
);

procedure modify_report(
    i_report_id        in     com_api_type_pkg.t_short_id
  , io_seqnum          in out com_api_type_pkg.t_seqnum
  , i_report_name      in     com_api_type_pkg.t_name
  , i_report_desc      in     com_api_type_pkg.t_short_desc
  , i_source           in     clob
  , i_source_type      in     com_api_type_pkg.t_attr_name
  , i_inst_id          in     com_api_type_pkg.t_inst_id
  , i_lang             in     com_api_type_pkg.t_name
  , i_is_deterministic in      com_api_type_pkg.t_boolean
  , i_name_format_id   in      com_api_type_pkg.t_tiny_id
  , i_is_notification  in      com_api_type_pkg.t_boolean default null
  , i_document_type    in      com_api_type_pkg.t_dict_value default null
);

procedure remove_report(
    i_report_id        in      com_api_type_pkg.t_short_id
  , i_seqnum           in      com_api_type_pkg.t_seqnum
);

function get_report_tag(
    i_report_id           in     com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_name;

procedure add_report_object(
    o_report_object_id    out  com_api_type_pkg.t_short_id
  , o_seqnum              out  com_api_type_pkg.t_seqnum
  , i_report_id        in      com_api_type_pkg.t_short_id
  , i_entity_type      in      com_api_type_pkg.t_dict_value
  , i_object_type      in      com_api_type_pkg.t_dict_value
);

procedure modify_report_object(
    i_report_object_id in     com_api_type_pkg.t_short_id
  , io_seqnum          in out com_api_type_pkg.t_seqnum
  , i_report_id        in      com_api_type_pkg.t_short_id
  , i_entity_type      in      com_api_type_pkg.t_dict_value
  , i_object_type      in      com_api_type_pkg.t_dict_value
);

procedure remove_report_object(
    i_report_object_id in      com_api_type_pkg.t_short_id
  , i_seqnum           in      com_api_type_pkg.t_seqnum
);

end;
/
