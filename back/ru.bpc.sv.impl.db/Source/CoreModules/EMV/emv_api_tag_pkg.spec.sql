create or replace package emv_api_tag_pkg is
/**********************************************************
 * API for EMV tag <br />
 * Created by Kopachev D.(kopachev@bpcbt.com)  at 15.06.2010 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2010-04-08 17:36:45 +0400$ <br />
 * Revision: $LastChangedRevision: 7636 $ <br />
 * Module: EMV_API_TAG_PKG <br />
 * @headcom
 **********************************************************/

/*
 * Get EMV tag value
 * @param i_tag          - Tag name 
 * @param i_value        - Tag value
 * @param i_profile      - Profile of EMV application
 * @param i_perso_rec    - Personalization record
 * @param i_perso_method - Personalization method
 * @param i_perso_data   - Personalization data
 */
    function get_tag_value (
        i_tag                   in com_api_type_pkg.t_tag
        , i_value               in com_api_type_pkg.t_param_value
        , i_profile             in com_api_type_pkg.t_dict_value
        , i_perso_rec           in prs_api_type_pkg.t_perso_rec
        , i_perso_method        in prs_api_type_pkg.t_perso_method_rec
        , i_perso_data          in prs_api_type_pkg.t_perso_data_rec
    ) return com_api_type_pkg.t_param_value;
    
/*
 * Parse EMV data into an associative array.
 * @param i_emv_data    - EMV data
 * @param o_emv_tag_tab - array: tag_value[tag_name]
 * @param i_is_binary   - if this flag is set to TRUE then the parser treats EMV data as a set
                          of HEX digits but not as raw/binary data
 */
    procedure parse_emv_data(
        i_emv_data          in      com_api_type_pkg.t_text
      , o_emv_tag_tab          out  com_api_type_pkg.t_tag_value_tab
      , i_is_binary         in      com_api_type_pkg.t_boolean
      , i_mask_error        in      com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
    );
    
/*
 * Get EMV tag value
 * @param i_emv_data     - EMV data
 * @param i_emv_tag_tab  - array: tag_value[tag_name]
 * @param io_emv_tag_tab - Array tag name - tag value
 * @param i_mask_error   - Mask error
 * @param i_error_value  - Error value
 */
    function get_tag_value(
        i_tag               in      com_api_type_pkg.t_tag
      , i_emv_tag_tab       in      com_api_type_pkg.t_tag_value_tab
      , i_mask_error        in      com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
      , i_error_value       in      com_api_type_pkg.t_param_value  default null
    ) return com_api_type_pkg.t_param_value;

/*
 * This procedure logs a collection <i_emv_tag_tab> into the table TRC_LOG when
 * either a currect logging level is set to DEBUG or flag <i_is_debug_only> is set to FALSE.
 */
    procedure dump_tag_table(
        i_emv_tag_tab       in      com_api_type_pkg.t_tag_value_tab
      , i_is_debug_only     in      com_api_type_pkg.t_boolean          default com_api_type_pkg.TRUE
    );

/*
 * When the parameter is set to TRUE then a string of EMV data is considered as a string of HEX digits.
 * otherwise, it is meant as a raw/binary string,
 * i.e. it may contain HEX digits, numeric symbols or alpha-numeric ones.
 */
    function is_binary return com_api_type_pkg.t_boolean
    result_cache;

/*
 * Function generates a string as a value for DE 55 using an array of EMV tags,
 * the list of required tags is provided (optional) as an incoming parameter;
 * returning value is a HEX-digit string of formatted EMV's data, which is converted to
 * a raw byte string on saving into the table, and on creating field DE55 (or its analog)
 * for outgoing clearing file (by a web saver).
 *
 * When <EMV_TAGS_ARE_BINARY> is TRUE (SVFE2 posting) it means that EMV data in <aut_auth.emv_data>
 * is presented in HEX that should represent (in binary) correct Integrated Circuit Card [ICC] data,
 * so these tags may be used unchanged for DE 55 field (web saver for Mastercard outgoing clearing
 * transcodes HEX string to a binary one and saves it to outgoing file).
 *
 * When <EMV_TAGS_ARE_BINARY> is FALSE (SVFE1 posting) it means that EMV data in <aut_auth.emv_data>
 * is presented in HEX or alpha-numeric format so these tags can't be used unchanged for DE 55 field
 * because in this case DE 55 would be incorrect ICC data. This is why some additional converting
 * is required in according to SVFE1 posting format sepcification.
 *
 * For example, tag 5F2A contains ISO currency code and in according to Mastercard specification
 * for field DE 55 it should consists 5 bytes: 2 byte for tag name, 1 byte for data length, and
 * 2 bytes for currency code itself. For currency code 643 this tag should be the following in
 * HEX-format: 5F2A030283 (0283 is a HEX representation for decimal value 643).
 * otherwise, in case of <EMV_TAGS_ARE_BINARY> is FALSE this tag is presented in <aut_auth.emv_data>
 * as the following string: 5F2A03643 (i.e., '643' here is a symbol notation for decimal integer 643).
 *
 * @param io_emv_tag_tab -
       array: io_emv_tag_tab[tag_name] = tag_value
 * @param i_tag_type_tab -
       collection of pairs [nam1=tag_name, name=tag_data_format] which serves a dual purposes:
       a) it is used as the LIST OF TAGS that should be INCLUDED into outgoing formatted EMV data;
       b) when <EMV_TAGS_ARE_BINARY> is FALSE (SVFE1 posting) it is used for detecting data formats
          of EMV tags to encode them into binary/HEX form from character one (e.g., for casting
          character notation '643' to HEX notaion 0x0283, see example above)
 */
    function format_emv_data(
        io_emv_tag_tab          in out nocopy com_api_type_pkg.t_tag_value_tab
      , i_tag_type_tab          in            emv_api_type_pkg.t_emv_tag_type_tab
    ) return com_api_type_pkg.t_full_desc;

end;
/
