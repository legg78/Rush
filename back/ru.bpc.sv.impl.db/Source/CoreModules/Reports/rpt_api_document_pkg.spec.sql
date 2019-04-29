create or replace package rpt_api_document_pkg as
/*********************************************************
 *  API for report documents <br />
 *  Created by Filimonov A.(filimonov@bpcbt.com)  at 23.04.2012 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Module: RPT_API_DOCUMENT_PKG <br />
 *  @headcom
 **********************************************************/
procedure add_document(
    io_document_id          in out  com_api_type_pkg.t_long_id
  , o_seqnum                   out  com_api_type_pkg.t_seqnum
  , i_content_type          in      com_api_type_pkg.t_dict_value
  , i_document_type         in      com_api_type_pkg.t_dict_value
  , i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_id             in      com_api_type_pkg.t_long_id
  , i_report_id             in      com_api_type_pkg.t_short_id     default null
  , i_template_id           in      com_api_type_pkg.t_short_id     default null
  , i_file_name             in      com_api_type_pkg.t_name         default null
  , i_mime_type             in      com_api_type_pkg.t_dict_value   default null
  , i_save_path             in      com_api_type_pkg.t_full_desc    default null
  , i_document_date         in      date                            default null
  , i_document_number       in      com_api_type_pkg.t_name         default null
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_start_date            in      date                            default null
  , i_end_date              in      date                            default null
  , i_status                in      com_api_type_pkg.t_dict_value   default null
  , i_xml                   in      clob
);

procedure add_document(
    io_document_id          in out  com_api_type_pkg.t_long_id
  , o_seqnum                   out  com_api_type_pkg.t_seqnum
  , i_content_type          in      com_api_type_pkg.t_dict_value
  , i_document_type         in      com_api_type_pkg.t_dict_value
  , i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_id             in      com_api_type_pkg.t_long_id
  , i_report_id             in      com_api_type_pkg.t_short_id     default null
  , i_template_id           in      com_api_type_pkg.t_short_id     default null
  , i_file_name             in      com_api_type_pkg.t_name         default null
  , i_mime_type             in      com_api_type_pkg.t_dict_value   default null
  , i_save_path             in      com_api_type_pkg.t_full_desc    default null
  , i_document_date         in      date                            default null
  , i_document_number       in      com_api_type_pkg.t_name         default null
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_start_date            in      date                            default null
  , i_end_date              in      date                            default null
  , i_status                in      com_api_type_pkg.t_dict_value   default null
  , i_param_tab             in      com_api_type_pkg.t_param_tab
);

procedure add_document(
    io_document_id          in out  com_api_type_pkg.t_long_id
  , o_seqnum                   out  com_api_type_pkg.t_seqnum
  , i_content_type          in      com_api_type_pkg.t_dict_value
  , i_document_type         in      com_api_type_pkg.t_dict_value
  , i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_id             in      com_api_type_pkg.t_long_id
  , i_report_id             in      com_api_type_pkg.t_short_id     default null
  , i_template_id           in      com_api_type_pkg.t_short_id     default null
  , i_file_name             in      com_api_type_pkg.t_name         default null
  , i_mime_type             in      com_api_type_pkg.t_dict_value   default null
  , i_save_path             in      com_api_type_pkg.t_full_desc    default null
  , i_document_date         in      date                            default null
  , i_document_number       in      com_api_type_pkg.t_name         default null
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_start_date            in      date                            default null
  , i_end_date              in      date                            default null
  , i_status                in      com_api_type_pkg.t_dict_value   default null
);

procedure add_document(
    io_document_id          in out  com_api_type_pkg.t_long_id
  , o_seqnum                   out  com_api_type_pkg.t_seqnum
  , i_content_type          in      com_api_type_pkg.t_dict_value
  , i_document_type         in      com_api_type_pkg.t_dict_value
  , i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_id             in      com_api_type_pkg.t_long_id
  , i_report_id             in      com_api_type_pkg.t_short_id     default null
  , i_template_id           in      com_api_type_pkg.t_short_id     default null
  , i_file_name             in      com_api_type_pkg.t_name         default null
  , i_mime_type             in      com_api_type_pkg.t_dict_value   default null
  , i_save_path             in      com_api_type_pkg.t_full_desc    default null
  , i_document_date         in      date                            default null
  , i_document_number       in      com_api_type_pkg.t_name         default null
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_start_date            in      date                            default null
  , i_end_date              in      date                            default null
  , i_status                in      com_api_type_pkg.t_dict_value   default null
  , i_param_map             in      com_param_map_tpt               
);

procedure modify_document(
    i_document_id           in      com_api_type_pkg.t_long_id
  , io_seqnum               in out  com_api_type_pkg.t_seqnum
  , i_content_type          in      com_api_type_pkg.t_dict_value
  , i_report_id             in      com_api_type_pkg.t_short_id     default null
  , i_template_id           in      com_api_type_pkg.t_short_id     default null
  , i_file_name             in      com_api_type_pkg.t_name         default null
  , i_mime_type             in      com_api_type_pkg.t_dict_value   default null
  , i_save_path             in      com_api_type_pkg.t_full_desc    default null
  , i_document_date         in      date                            default null
  , i_document_number       in      com_api_type_pkg.t_name         default null
  , i_document_type         in      com_api_type_pkg.t_dict_value   default null
  , i_start_date            in      date                            default null
  , i_end_date              in      date                            default null
  , i_status                in      com_api_type_pkg.t_dict_value   default null
  , i_content               in      clob                            default null
);

procedure add_document_type(
    o_id                       out  com_api_type_pkg.t_tiny_id
  , i_document_type         in      com_api_type_pkg.t_dict_value
  , i_content_type          in      com_api_type_pkg.t_dict_value
  , i_is_report             in      com_api_type_pkg.t_boolean
);

procedure modify_document_type(
    i_id                    in      com_api_type_pkg.t_tiny_id
  , i_document_type         in      com_api_type_pkg.t_dict_value
  , i_content_type          in      com_api_type_pkg.t_dict_value
  , i_is_report             in      com_api_type_pkg.t_boolean
);

function get_document (
    i_document_id           in com_api_type_pkg.t_short_id
  , i_content_type          in com_api_type_pkg.t_dict_value
) return rpt_api_type_pkg.t_document_rec;

procedure show_document(
    o_xml                  out  clob
  , i_object_id         in      com_api_type_pkg.t_long_id
);

procedure get_content(
    o_xml                  out  clob
  , i_document_id       in      com_api_type_pkg.t_long_id
  , i_content_type      in      com_api_type_pkg.t_dict_value
);

end; 
/
