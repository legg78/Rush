create or replace package rpt_ui_template_pkg as
/*
  Interface for report template definition <br />
  Created by Fomichev A.(fomichev@bpc.ru)  at 20.09.2010 <br />
  Last changed by $Author: Fomichev A. $ <br />
  $LastChangedDate:: 2010-08-20 14:55:00 +0400#$ <br />
  Module: rpt_ui_template_pkg <br />
*/

procedure add_template(
    o_id                   out  com_api_type_pkg.t_short_id
  , o_seqnum               out  com_api_type_pkg.t_tiny_id
  , i_report_id         in      com_api_type_pkg.t_short_id
  , i_template_lang     in      com_api_type_pkg.t_dict_value
  , i_text              in      clob
  , i_base64            in      clob
  , i_report_processor  in      com_api_type_pkg.t_dict_value
  , i_report_format     in      com_api_type_pkg.t_dict_value
  , i_label             in      com_api_type_pkg.t_name
  , i_description       in      com_api_type_pkg.t_full_desc
  , i_lang              in      com_api_type_pkg.t_dict_value   default null
);

procedure modify_template(
    i_id                in      com_api_type_pkg.t_short_id
  , io_seqnum           in out  com_api_type_pkg.t_tiny_id
  , i_report_id         in      com_api_type_pkg.t_short_id
  , i_template_lang     in      com_api_type_pkg.t_dict_value
  , i_text              in      clob
  , i_base64            in      clob
  , i_report_processor  in      com_api_type_pkg.t_dict_value
  , i_report_format     in      com_api_type_pkg.t_dict_value
  , i_label             in      com_api_type_pkg.t_name
  , i_description       in      com_api_type_pkg.t_full_desc
  , i_lang              in      com_api_type_pkg.t_dict_value   default null
);

procedure remove_template(
    i_id      in     com_api_type_pkg.t_short_id
  , i_seqnum  in     com_api_type_pkg.t_tiny_id
);

end;
/
