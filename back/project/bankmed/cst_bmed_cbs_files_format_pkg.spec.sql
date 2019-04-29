create or replace package cst_bmed_cbs_files_format_pkg is
/**********************************************************
 * Custom outgoing or input files operations formats for CBS  
 * 
 * Created by Gogolev I.(i.gogolev@bpcbt.com) at 30.01.2017<br />
 * <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: CST_BMED_CBS_FILES_FORMAT_PKG
 * @headcom
 **********************************************************/

-- Generate narrative text
function replace_tags_in_label(
    i_label_id                     in com_api_type_pkg.t_short_id
  , i_is_aggregated                in com_api_type_pkg.t_boolean
  , i_sttl_date                    in date
  , i_fee_type                     in com_api_type_pkg.t_dict_value
  , i_count                        in com_api_type_pkg.t_long_id
  , i_card_ending_number           in com_api_type_pkg.t_name            default null
  , i_product_name                 in com_api_type_pkg.t_name            default null
  , i_external_auth_id             in com_api_type_pkg.t_attr_name       default null
  , i_auth_code                    in com_api_type_pkg.t_auth_code       default null
  , i_oper_id                      in com_api_type_pkg.t_long_id         default null
  , i_file_name                    in com_api_type_pkg.t_name            default null
) return com_api_type_pkg.t_text;

-- Generate row of the CBS outgoing file
function generate_cbs_out_row(
    i_file_type                    in com_api_type_pkg.t_dict_value
  , i_sttl_date                    in date
  , i_account_number               in com_api_type_pkg.t_account_number
  , i_dir_transaction_amount       in com_api_type_pkg.t_byte_char
  , i_transaction_amount           in com_api_type_pkg.t_money
  , i_is_aggregated                in com_api_type_pkg.t_boolean
  , i_record_number                in com_api_type_pkg.t_long_id
  , i_count                        in com_api_type_pkg.t_long_id
  , i_oper_type                    in com_api_type_pkg.t_dict_value      default null
  , i_sttl_type                    in com_api_type_pkg.t_dict_value      default null
  , i_transaction_type             in com_api_type_pkg.t_dict_value      default null
  , i_fee_type                     in com_api_type_pkg.t_dict_value      default null
  , i_oper_id                      in com_api_type_pkg.t_long_id         default null
  , i_posting_date                 in date                               default null
  , i_narrative_text_1             in com_api_type_pkg.t_name            default null
  , i_narrative_text_2             in com_api_type_pkg.t_name            default null
  , i_narrative_text_3             in com_api_type_pkg.t_name            default null
  , i_reference_value              in com_api_type_pkg.t_name            default null
  , i_amount_per_month_acct_curr   in com_api_type_pkg.t_money           default null
  , i_amount_per_month_usd_curr    in com_api_type_pkg.t_money           default null
  , i_amount_per_month_oper_curr   in com_api_type_pkg.t_money           default null
  , i_amount_per_month_lbp_curr    in com_api_type_pkg.t_money           default null
  , i_file_name                    in com_api_type_pkg.t_name            default null
) return com_api_type_pkg.t_name;
   
-- Generate full CBS outgoing file
procedure generate_cbs_out_file(
    io_body_tab                    in out nocopy cst_bmed_type_pkg.t_cbs_outg_file_body
  , o_file_content                    out nocopy clob
);

-- Generate reference text
function replace_tags_in_reference(
    i_reference                    in com_api_type_pkg.t_name
  , i_sysdate                      in date                               default null
  , i_auth_code                    in com_api_type_pkg.t_auth_code       default null
  , i_oper_id                      in com_api_type_pkg.t_long_id         default null
  , i_file_name                    in com_api_type_pkg.t_name            default null
) return com_api_type_pkg.t_name;

end cst_bmed_cbs_files_format_pkg;
/
