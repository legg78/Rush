create or replace package rpt_ui_tag_pkg as
/*******************************************************************
*  UI for report tags <br />
*  Created by Kryukov E.(krukov@bpcbt.com)  at 16.12.2011 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: RPT_UI_TAG_PKG <br />
*  @headcom
******************************************************************/

procedure add_tag(

    o_id                     out com_api_type_pkg.t_tiny_id
  , o_seqnum                 out com_api_type_pkg.t_seqnum
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_label               in     com_api_type_pkg.t_name
  , i_description         in     com_api_type_pkg.t_text
  , i_lang                in     com_api_type_pkg.t_dict_value
);

procedure modify_tag(
    i_id                  in     com_api_type_pkg.t_tiny_id
  , io_seqnum             in out com_api_type_pkg.t_seqnum
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_label               in     com_api_type_pkg.t_name
  , i_description         in     com_api_type_pkg.t_text
  , i_lang                in     com_api_type_pkg.t_dict_value
);

procedure remove_tag(
    i_id                  in     com_api_type_pkg.t_tiny_id
  , i_seqnum              in     com_api_type_pkg.t_seqnum
);

procedure add_report_tag(
    i_tag_id              in     com_api_type_pkg.t_tiny_id
  , i_report_id           in     com_api_type_pkg.t_short_id
);

procedure remove_report_tag(
    i_tag_id              in     com_api_type_pkg.t_tiny_id
  , i_report_id           in     com_api_type_pkg.t_short_id
);

end;
/
