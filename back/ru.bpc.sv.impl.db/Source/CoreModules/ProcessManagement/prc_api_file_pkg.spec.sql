create or replace package prc_api_file_pkg is
/************************************************************
 * API for process files <br /> 
 * Created by Kryukov E.(krukov@bpc.ru)  at 18.11.2009 <br />
 * Module: prc_api_file_pkg <br />
 * @headcom
 ***********************************************************/

type t_varchar2_tab is table of varchar2(4000);

/*
 * Get default file name
 * @param o_sess_file_id - Session file identifier
 * @param i_file_type    - File type
 * @param i_file_purpose - File data direction
 * @return file name for file
 */
function get_default_file_name(
    i_file_type             in            com_api_type_pkg.t_dict_value  default null
  , i_file_purpose          in            com_api_type_pkg.t_dict_value  default null
  , io_params               in out nocopy com_api_type_pkg.t_param_tab
) return com_api_type_pkg.t_name;

function get_default_file_name_params(
    i_file_type             in             com_api_type_pkg.t_dict_value default null
  , i_file_purpose          in            com_api_type_pkg.t_dict_value  default null
  , io_params               in out nocopy com_api_type_pkg.t_param_tab
) return rul_api_type_pkg.t_param_tab;

/*
 * Set session file identifier
 * @param i_sess_file_id  - Session file identifier
 */
procedure set_session_file_id(
    i_sess_file_id          in      com_api_type_pkg.t_long_id
);

/*
 * Get session file identifier
 * @return Session file identifier
 */
function get_session_file_id return com_api_type_pkg.t_long_id;

/*
 * Open session file
 * @param o_sess_file_id - Session file identifier
 * @param i_file_name    - File name for incoming files
 * @param i_file_type    - File type
 * @param i_file_purpose - File data direction
 * @param i_object_id    - Object identified
 * @param i_entity_type  - Object entity type
 */
procedure open_file (
    o_sess_file_id             out  com_api_type_pkg.t_long_id
  , i_file_name             in      com_api_type_pkg.t_name         default null
  , i_file_type             in      com_api_type_pkg.t_dict_value   default null
  , i_file_purpose          in      com_api_type_pkg.t_dict_value   default null
  , i_no_session_id         in      com_api_type_pkg.t_boolean      default com_api_const_pkg.false
  , i_object_id             in      com_api_type_pkg.t_long_id      default null
  , i_entity_type           in      com_api_type_pkg.t_dict_value   default null
);

/*
 * Open session file
 * @param o_sess_file_id - Session file identifier
 * @param i_file_name    - File name for incoming files
 * @param i_file_type    - File type
 * @param i_file_purpose - File data direction
 * @param io_params      - Params for naming format
 * @param i_object_id    - Object identified
 * @param i_entity_type  - Object entity type
 */
procedure open_file (
    o_sess_file_id             out  com_api_type_pkg.t_long_id
  , i_file_name             in      com_api_type_pkg.t_name         default null
  , i_file_type             in      com_api_type_pkg.t_dict_value   default null
  , i_file_purpose          in      com_api_type_pkg.t_dict_value   default null
  , io_params               in out  com_api_type_pkg.t_param_tab
  , i_object_id             in      com_api_type_pkg.t_long_id      default null
  , i_entity_type           in      com_api_type_pkg.t_dict_value   default null
);

/*
 * Open session file
 * @param o_sess_file_id - Session file identifier
 * @param i_file_name    - File name for incoming files
 * @param i_file_type    - File type
 * @param i_file_purpose - File data direction
 * @param io_params      - Params for naming format
 * @param i_object_id    - Object identified
 * @param i_entity_type  - Object entity type
 */
procedure open_file (
    o_sess_file_id             out  com_api_type_pkg.t_long_id
  , i_file_name             in      com_api_type_pkg.t_name         default null
  , i_file_type             in      com_api_type_pkg.t_dict_value
  , i_file_purpose          in      com_api_type_pkg.t_dict_value   default null
  , io_params               in out  com_api_type_pkg.t_param_tab
  , o_report_id                out  com_api_type_pkg.t_short_id
  , o_report_template_id       out  com_api_type_pkg.t_short_id
  , i_no_session_id         in      com_api_type_pkg.t_boolean      default com_api_const_pkg.false
  , i_object_id             in      com_api_type_pkg.t_long_id      default null
  , i_entity_type           in      com_api_type_pkg.t_dict_value   default null
);

/*
 * Open session file
 * Procedure used in file savers
 *
 * @param o_sess_file_id - Session file identifier
 * @param io_file_name   - File name for incoming files
 * @param i_file_type    - File type
 * @param i_file_purpose - File data direction
 * @param i_object_id    - Object identified
 * @param i_entity_type  - Object entity type
 */
procedure open_file (
    o_sess_file_id             out  com_api_type_pkg.t_long_id
  , io_file_name            in out  com_api_type_pkg.t_name
  , i_file_type             in      com_api_type_pkg.t_dict_value
  , i_file_purpose          in      com_api_type_pkg.t_dict_value   default null
  , i_no_session_id         in      com_api_type_pkg.t_boolean      default com_api_const_pkg.false
  , i_object_id             in      com_api_type_pkg.t_long_id      default null
  , i_entity_type           in      com_api_type_pkg.t_dict_value   default null
);

/*
 * Open session file
 * @param o_sess_file_id - Session file identifier
 * @param i_file_name    - File name for incoming files
 * @param i_file_type    - File type
 * @param i_file_purpose - File data direction
 * @param io_params      - Params for naming format
 * @param i_object_id    - Object identified
 * @param i_entity_type  - Object entity type
 */
procedure open_file (
    o_sess_file_id             out  com_api_type_pkg.t_long_id
  , io_file_name            in out  com_api_type_pkg.t_name
  , i_file_type             in      com_api_type_pkg.t_dict_value
  , i_file_purpose          in      com_api_type_pkg.t_dict_value   default null
  , io_params               in out  com_api_type_pkg.t_param_tab
  , o_report_id                out  com_api_type_pkg.t_short_id
  , o_report_template_id       out  com_api_type_pkg.t_short_id
  , i_no_session_id         in      com_api_type_pkg.t_boolean      default com_api_const_pkg.false
  , i_object_id             in      com_api_type_pkg.t_long_id      default null
  , i_entity_type           in      com_api_type_pkg.t_dict_value   default null
);

/*
 * Close session file
 * @param i_sess_file_id - Session file identifier
 * @param i_status       - File status
 */
procedure close_file(
    i_sess_file_id          in      com_api_type_pkg.t_long_id
  , i_status                in      com_api_type_pkg.t_dict_value
  , i_record_count          in      com_api_type_pkg.t_medium_id   default null
);

/*
 * Remove session file
 * @param i_sess_file_id - Session file identifier
 * @param i_file_type    - File type
 * @param i_file_purpose - File data direction
 */
procedure remove_file(
    i_sess_file_id          in      com_api_type_pkg.t_long_id
  , i_file_type             in      com_api_type_pkg.t_dict_value default null
  , i_file_purpose          in      com_api_type_pkg.t_dict_value default null
);

/*
 * Put file line
 * @param i_sess_file_id - Session file identifier
 * @param i_raw_data     - Raw data line
 */
procedure put_line(
    i_sess_file_id          in      com_api_type_pkg.t_long_id
  , i_raw_data              in      com_api_type_pkg.t_raw_data
);

/*
 * Setup session file name
 * @param i_file_name      - File name for files
 * @param i_sess_file_id   - Session file identifier
 * @param i_file_type      - File type
 * @param i_file_purpose   - file purpose
 */
procedure set_file_name(
    i_file_name             in      com_api_type_pkg.t_name
  , i_sess_file_id          in      com_api_type_pkg.t_long_id
  , i_file_type             in      com_api_type_pkg.t_dict_value default null
  , i_file_purpose          in      com_api_type_pkg.t_dict_value default null
);

/*
 * Bulk insert
 * @param i_sess_file_id  - Session file identifier
 * @param i_raw_tab       - Raw data table
 * @param i_num_tab       - Record count
 */
procedure put_bulk(
    i_sess_file_id          in       com_api_type_pkg.t_long_id
  , i_raw_tab               in       com_api_type_pkg.t_raw_tab
  , i_num_tab               in       com_api_type_pkg.t_integer_tab
);

/*
 * Bulk insert from web
 * @param i_sess_file_id  - Session file identifier
 * @param i_raw_tab       - Raw data table
 * @param i_num_tab       - Record count
 */
procedure put_bulk_web(
    i_sess_file_id          in      com_api_type_pkg.t_long_id
  , i_raw_tab               in      raw_data_tpt
  , i_num_tab               in      num_tab_tpt
);

/*
 * Bulk insert many files
 * @param i_sess_file_tab - Session file's table identifier
 * @param i_raw_tab       - Raw data table
 * @param i_num_tab       - Record count
 */
procedure put_bulk_all(
    i_sess_file_tab         in      com_api_type_pkg.t_number_tab
  , i_raw_tab               in      com_api_type_pkg.t_raw_tab
  , i_num_tab               in      com_api_type_pkg.t_integer_tab
);

/*
 * Get file line
 * @param i_sess_file_id  - Session file identifier
 * @param i_rec_num       - Record number
 * @return Raw data
 */
function get_line(
    i_sess_file_id          in      com_api_type_pkg.t_long_id
  , i_rec_num               in      com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_raw_data;

/*
 * Put whole file source like CLOB.
 * @param i_sess_file_id  - Session file identifier
 * @param i_clob_content  - File contents
 * @param i_add_to        - Append or rewrite contents
*/
procedure put_file(
    i_sess_file_id          in     com_api_type_pkg.t_long_id
  , i_clob_content          in     clob
  , i_add_to                in     com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
);

/*
 * Put whole file source like BLOB
 * @param i_sess_file_id  - Session file identifier
 * @param i_blob_content  - File contents
 * @param i_add_to        - Append or rewrite contents
*/
procedure put_file (
    i_sess_file_id          in     com_api_type_pkg.t_long_id
  , i_blob_content          in     blob
  , i_add_to                in     com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
);

/*
 * Split clob by delimer
 * @param i_clob          - Contents
 * @param i_delim         - Delimer
 */
function split_clob( 
    i_clob                  in     clob
  , i_delim                 in     varchar2 default chr(10)   
) return t_varchar2_tab pipelined;

/*
 * Get constant income files
 * @return string 'INCM'
 */  
function get_file_purpose_in return com_api_type_pkg.t_dict_value;

/*
 * Get constant outgoing files
 * @return string 'OUTG'
 */  
function get_file_purpose_out return com_api_type_pkg.t_dict_value;

/*
 * Get record number in file
 * @return record number
 */
function get_record_number (
  i_sess_file_id            in     com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_medium_id;

function get_next_file(
    i_file_type             in     com_api_type_pkg.t_dict_value
  , i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_file_purpose          in     com_api_type_pkg.t_dict_value   default null
  , i_file_attr             in     com_api_type_pkg.t_short_id     default null  
) return com_api_type_pkg.t_long_id;

/*
 * Set for all ready file without session_id curret session_id
 * @param i_file_type  - File type
*/
procedure mark_ready_file (
     i_file_type             in      com_api_type_pkg.t_dict_value   default null
);

/*
 * Generate response file of process
 * @param i_file_type         - File type
 * @param i_original_file_id  - original file identifier
 * @param i_original_file_name- original file name
 * @param i_start_date        - Start date from parameters of process
 * @param i_end_date          - Start date from parameters of process
 * @param i_error_code        - Error code
*/
procedure generate_response_file (
    i_file_type             in      com_api_type_pkg.t_dict_value   
  , i_original_file_id      in      com_api_type_pkg.t_long_id      default null
  , i_original_file_name    in      com_api_type_pkg.t_name         default null
  , i_start_date            in      date                            default null
  , i_end_date              in      date                            default null
  , i_inst_id               in      com_api_type_pkg.t_inst_id      default null
  , i_error_code            in      com_api_type_pkg.t_name         default null
);

procedure generate_response_file;

/*
 * Save session file.
 *
 * @param i_file_name     - File name for outgoing files
 * @param i_file_type     - File type
 * @param i_file_purpose  - File data direction
 * @param io_params       - Params for naming format
 * @param i_clob_content  - File contents
 * @param i_add_to        - Append or rewrite contents
 * @param i_status        - File status
 * @param i_record_count  - Record count
 */
procedure save_file (
    i_file_name             in      com_api_type_pkg.t_name        default null
  , i_file_type             in      com_api_type_pkg.t_dict_value
  , i_file_purpose          in      com_api_type_pkg.t_dict_value  default null
  , io_params               in out  com_api_type_pkg.t_param_tab
  , o_report_id                out  com_api_type_pkg.t_short_id
  , o_report_template_id       out  com_api_type_pkg.t_short_id
  , i_no_session_id         in      com_api_type_pkg.t_boolean     default com_api_const_pkg.FALSE
  , i_clob_content          in      clob
  , i_add_to                in      com_api_type_pkg.t_boolean     default com_api_const_pkg.FALSE
  , i_status                in      com_api_type_pkg.t_dict_value
  , i_record_count          in      com_api_type_pkg.t_medium_id   default null
);

/*
 * Change status of the session file.
 * @param i_sess_file_id - Session file identifier
 * @param i_status       - File status
 */
procedure change_file_status(
    i_sess_file_id          in      com_api_type_pkg.t_long_id
  , i_status                in      com_api_type_pkg.t_dict_value
);

/*
 * Change attributes of the session file.
 * @param i_sess_file_id - Session file identifier
 * @param i_status       - File status
 * @param i_record_count - Record count
 */
procedure change_session_file(
    i_sess_file_id          in      com_api_type_pkg.t_long_id
  , i_status                in      com_api_type_pkg.t_dict_value  default null
  , i_record_count          in      com_api_type_pkg.t_medium_id   default null
  , i_check_record_count    in      com_api_type_pkg.t_boolean     default com_api_type_pkg.FALSE
);

procedure generate_file_password(
    i_sess_file_id          in      com_api_type_pkg.t_long_id
  , o_file_password            out  com_api_type_pkg.t_dict_value
);

function get_file_password return com_api_type_pkg.t_dict_value;

procedure unset_file_password;

procedure change_file_names_in_thread(
    i_session_id            in      com_api_type_pkg.t_long_id
  , i_thread_number         in      com_api_type_pkg.t_tiny_id
  , i_total_file_count      in      com_api_type_pkg.t_medium_id
);

function get_session_file_id(
    i_session_id            in      com_api_type_pkg.t_long_id
  , i_file_type             in      com_api_type_pkg.t_dict_value    default null
) return com_api_type_pkg.t_long_tab;

function get_xml_content(
    i_sess_file_id          in      com_api_type_pkg.t_long_id
) return xmltype;

end prc_api_file_pkg;
/
