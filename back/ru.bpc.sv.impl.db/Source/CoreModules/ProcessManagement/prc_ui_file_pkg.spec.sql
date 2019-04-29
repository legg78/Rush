create or replace package prc_ui_file_pkg as
/************************************************************
 * The UI for file processes <br />
 * Created by Kryukov E.(krukov@bpc.ru)  at 02.10.2009 <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: PRC_UI_FILE_PKG <br />
 * @headcom
 ************************************************************/

/*
 * Register new file
 */
procedure add_file(
    o_id                     out  com_api_type_pkg.t_tiny_id
  , i_process_id          in      com_api_type_pkg.t_short_id
  , i_file_purpose        in      com_api_type_pkg.t_dict_value
  , i_saver_id            in      com_api_type_pkg.t_tiny_id
  , i_file_nature         in      com_api_type_pkg.t_dict_value := prc_api_const_pkg.FILE_NATURE_PLAINTEXT
  , i_xsd_source          in      clob default null
  , i_file_type           in      com_api_type_pkg.t_dict_value := null
  , i_name                in      com_api_type_pkg.t_name
  , i_description         in      com_api_type_pkg.t_full_desc
  , i_lang                in      com_api_type_pkg.t_dict_value
);

/*
 * Modify file
 */
procedure modify_file(
    i_id                  in      com_api_type_pkg.t_tiny_id
  , i_file_purpose        in      com_api_type_pkg.t_dict_value
  , i_saver_id            in      com_api_type_pkg.t_tiny_id
  , i_file_nature         in      com_api_type_pkg.t_dict_value := prc_api_const_pkg.FILE_NATURE_PLAINTEXT
  , i_xsd_source          in      clob default null
  , i_file_type           in      com_api_type_pkg.t_dict_value := null
  , i_name                in      com_api_type_pkg.t_name
  , i_description         in      com_api_type_pkg.t_full_desc
  , i_lang                in      com_api_type_pkg.t_dict_value
);

/*
 * Remove process file
 * @param i_id File identifier
 */
procedure remove_file (
    i_id                  in      com_api_type_pkg.t_tiny_id
);

/*
 * Add file attribute
 * @param io_id             Record identifier
 */
procedure add_file_attribute(
    o_id                     out  com_api_type_pkg.t_short_id
  , i_file_id             in      com_api_type_pkg.t_tiny_id
  , i_container_id        in      com_api_type_pkg.t_short_id
  , i_characterset        in      com_api_type_pkg.t_attr_name
  , i_file_name_mask      in      com_api_type_pkg.t_name
  , i_name_format_id      in      com_api_type_pkg.t_tiny_id
  , i_upload_empty_file   in      com_api_type_pkg.t_boolean
  , i_xslt_source         in      clob := null
  , i_converter_class     in      com_api_type_pkg.t_name
  , i_is_tar              in      com_api_type_pkg.t_boolean
  , i_is_zip              in      com_api_type_pkg.t_boolean
  , i_inst_id             in      com_api_type_pkg.t_inst_id
  , i_report_id           in      com_api_type_pkg.t_short_id
  , i_report_template_id  in      com_api_type_pkg.t_short_id
  , i_load_priority       in      com_api_type_pkg.t_tiny_id      default null
  , i_sign_transfer_type  in      com_api_type_pkg.t_dict_value   default null
  , i_encrypt_plugin      in      com_api_type_pkg.t_name         default null
  , i_ignore_file_errors  in      com_api_type_pkg.t_boolean      default null
  , i_location_id         in      com_api_type_pkg.t_tiny_id
  , i_parallel_degree     in      com_api_type_pkg.t_tiny_id      default null
  , i_is_file_name_unique in      com_api_type_pkg.t_boolean      default null
  , i_is_file_required    in      com_api_type_pkg.t_boolean      default null
  , i_queue_identifier    in      com_api_type_pkg.t_name         default null
  , i_time_out            in      com_api_type_pkg.t_short_id     default null
  , i_port                in      com_api_type_pkg.t_tag          default null
  , i_line_separator      in      com_api_type_pkg.t_name         default null
  , i_password_protect    in      com_api_type_pkg.t_boolean      default null
  , i_is_cleanup_data     in      com_api_type_pkg.t_boolean      default null
  , i_file_merge_mode     in      com_api_type_pkg.t_dict_value   default null
);

/*
 * Modify file attribute
 * @param io_id             Record identifier
 */
procedure modify_file_attribute(
    i_id                  in      com_api_type_pkg.t_short_id
  , i_characterset        in      com_api_type_pkg.t_attr_name
  , i_file_name_mask      in      com_api_type_pkg.t_name
  , i_name_format_id      in      com_api_type_pkg.t_tiny_id
  , i_upload_empty_file   in      com_api_type_pkg.t_boolean
  , i_xslt_source         in      clob := null
  , i_is_tar              in      com_api_type_pkg.t_boolean
  , i_is_zip              in      com_api_type_pkg.t_boolean
  , i_converter_class     in      com_api_type_pkg.t_name
  , i_report_id           in      com_api_type_pkg.t_short_id
  , i_report_template_id  in      com_api_type_pkg.t_short_id
  , i_load_priority       in      com_api_type_pkg.t_tiny_id      default null
  , i_sign_transfer_type  in      com_api_type_pkg.t_dict_value   default null
  , i_encrypt_plugin      in      com_api_type_pkg.t_name         default null
  , i_ignore_file_errors  in      com_api_type_pkg.t_boolean      default null
  , i_location_id         in      com_api_type_pkg.t_tiny_id
  , i_parallel_degree     in      com_api_type_pkg.t_tiny_id      default null
  , i_is_file_name_unique in      com_api_type_pkg.t_boolean      default null
  , i_is_file_required    in      com_api_type_pkg.t_boolean      default null
  , i_queue_identifier    in      com_api_type_pkg.t_name         default null
  , i_time_out            in      com_api_type_pkg.t_short_id     default null
  , i_port                in      com_api_type_pkg.t_tag          default null
  , i_line_separator      in      com_api_type_pkg.t_name         default null
  , i_password_protect    in      com_api_type_pkg.t_boolean      default null
  , i_is_cleanup_data     in      com_api_type_pkg.t_boolean      default null
  , i_file_merge_mode     in      com_api_type_pkg.t_dict_value   default null
);

/*
 * Remove file attribute
 * @param i_id Identifier attribute
 */
procedure remove_file_attribute(
    i_id                  in      com_api_type_pkg.t_short_id
);

procedure remove_process_file(
    i_process_id          in      com_api_type_pkg.t_short_id
);

/*
 * Setup status session file
 * @param i_sess_file_id - Session file identifier
 * @param i_status       - File status
 */
procedure set_file_status(
    i_sess_file_id        in      com_api_type_pkg.t_long_id
  , i_status              in      com_api_type_pkg.t_dict_value   default null
);

function get_default_file_name(
    i_file_type           in      com_api_type_pkg.t_dict_value default null
  , i_file_purpose        in      com_api_type_pkg.t_dict_value default null
  , i_params              in      com_param_map_tpt
) return com_api_type_pkg.t_name;

procedure add_file_saver (
    o_id                     out  com_api_type_pkg.t_tiny_id
  , o_seqnum                 out  com_api_type_pkg.t_seqnum
  , i_source              in      com_api_type_pkg.t_name
  , i_is_parallel         in      com_api_type_pkg.t_boolean
  , i_post_source         in      com_api_type_pkg.t_name
  , i_name                in      com_api_type_pkg.t_name
  , i_lang                in      com_api_type_pkg.t_dict_value
);

procedure modify_file_saver (
    i_id                  in      com_api_type_pkg.t_tiny_id
  , io_seqnum             in out  com_api_type_pkg.t_seqnum
  , i_source              in      com_api_type_pkg.t_name
  , i_is_parallel         in      com_api_type_pkg.t_boolean
  , i_post_source         in      com_api_type_pkg.t_name
  , i_name                in      com_api_type_pkg.t_name
  , i_lang                in      com_api_type_pkg.t_dict_value
);

procedure remove_file_saver (
    i_id                  in      com_api_type_pkg.t_tiny_id
  , i_seqnum              in      com_api_type_pkg.t_seqnum
);

/*
 * Function removes all session files for defined user's session.
 */
procedure remove_session_file(
    i_session_id          in      com_api_type_pkg.t_long_id
);

end prc_ui_file_pkg;
/
