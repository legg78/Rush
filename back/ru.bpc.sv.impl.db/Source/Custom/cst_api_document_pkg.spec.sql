create or replace package cst_api_document_pkg is

procedure add_document (
    io_document_id     in out  com_api_type_pkg.t_long_id
  , o_seqnum              out  com_api_type_pkg.t_seqnum
  , i_content_type     in      com_api_type_pkg.t_dict_value
  , i_document_type    in      com_api_type_pkg.t_dict_value
  , i_entity_type      in      com_api_type_pkg.t_dict_value
  , i_object_id        in      com_api_type_pkg.t_long_id
  , i_report_id        in      com_api_type_pkg.t_short_id     default null
  , i_template_id      in      com_api_type_pkg.t_short_id     default null
  , i_file_name        in      com_api_type_pkg.t_name         default null
  , i_mime_type        in      com_api_type_pkg.t_dict_value   default null
  , i_save_path        in      com_api_type_pkg.t_full_desc    default null
  , i_document_date    in      date                            default null
  , i_document_number  in      com_api_type_pkg.t_name         default null
  , i_inst_id          in      com_api_type_pkg.t_inst_id
  , i_param_map        in      com_param_map_tpt               
);

function get_document_block(
    i_operation_id     in      com_api_type_pkg.t_long_id
  , i_transaction_id   in      com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_lob_data;

end cst_api_document_pkg;
/
