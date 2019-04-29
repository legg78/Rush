create or replace package cst_bmed_cmo_files_format_pkg is
/**********************************************************
 * Custom outgoing or input files formats for CMO-canal operations 
 * 
 * Created by Gogolev I.(i.gogolev@bpcbt.com) at 09.09.2016
 * Last changed by Gogolev I.(i.gogolev@bpcbt.com) at 
 * 13.09.2016 16:10:00
 *
 * Module: CST_BMED_CMO_FILES_FORMAT_PKG
 * @headcom
 **********************************************************/
 
subtype    t_cmo_outg_file_hr     is varchar2(23);    -- Header of the outgoing file
subtype    t_cmo_outg_file_row    is varchar2(163);   -- Row of the body outgoing file
subtype    t_cmo_outg_file_ft     is varchar2(53);    -- Footer of the outgoing file

type       t_cmo_outg_file_body   is table of t_cmo_outg_file_row index by binary_integer;

type       t_cmo_outg_file_prc_data_rec    is record(
                count_oper                   com_api_type_pkg.t_medium_id
              , total_oper_amount            com_api_type_pkg.t_long_id
              , count_not_complete           com_api_type_pkg.t_medium_id
              , cmo_outg_file_id             com_api_type_pkg.t_byte_id
              , evnt_id_tab                  com_api_type_pkg.t_number_tab
           );

g_cmo_outg_file_prc_data_rec      t_cmo_outg_file_prc_data_rec; -- Intermediate proccesing data for cmo outgoing file

HEAD_FILE_OUTG_MARK               constant com_api_type_pkg.t_byte_char     := 'H';
CMO_CANAL_MARK                    constant com_api_type_pkg.t_module_code   := 'CMO';
BODY_ROW_FILE_OUTG_MARK           constant com_api_type_pkg.t_byte_char     := 'D';
TRS_TYPE_FILE_OUTG_MARK           constant com_api_type_pkg.t_byte_char     := 'TX';
FOOTER_FILE_OUTG_MARK             constant com_api_type_pkg.t_byte_char     := 'F';
TRS_DIRECT                        constant com_api_type_pkg.t_byte_char     := '+';
TRS_REVERSAL                      constant com_api_type_pkg.t_byte_char     := '-';

CONDITION_SEARCH_FEE              constant com_api_type_pkg.t_name          := 'FETP%';

/**********************************************************
 *
 * Generate header of the CMO outgoing file
 *
 *********************************************************/
function gen_header_cmo_out_file(
    i_header                  in com_api_type_pkg.t_byte_char         default cst_bmed_cmo_files_format_pkg.HEAD_FILE_OUTG_MARK
  , i_date                    in date                                 default get_sysdate
  , i_cmo_canal               in com_api_type_pkg.t_module_code       default cst_bmed_cmo_files_format_pkg.CMO_CANAL_MARK
  , i_file_id                 in com_api_type_pkg.t_byte_id           default g_cmo_outg_file_prc_data_rec.cmo_outg_file_id
) return cst_bmed_cmo_files_format_pkg.t_cmo_outg_file_hr;

/**********************************************************
 *
 * Generate row of the body CMO outgoing file
 * Function additionally is calculating the intermediate data
 * and put its into a global variable g_cmo_outg_file_prc_data
 * for further created result file
 *
 *********************************************************/
function gen_body_row_cmo_out_file(
    i_body                    in com_api_type_pkg.t_byte_char         default cst_bmed_cmo_files_format_pkg.BODY_ROW_FILE_OUTG_MARK
  , i_merchant_id             in com_api_type_pkg.t_merchant_number
  , i_merchant_name           in com_api_type_pkg.t_name
  , i_terminal_id             in com_api_type_pkg.t_terminal_number
  , i_transact_date           in date
  , i_card_number             in com_api_type_pkg.t_card_number
  , i_currency_code           in com_api_type_pkg.t_curr_code
  , i_dir_transact_amount     in com_api_type_pkg.t_byte_char
  , i_transact_amount         in com_api_type_pkg.t_medium_id
  , i_transact_type           in com_api_type_pkg.t_byte_char         default cst_bmed_cmo_files_format_pkg.TRS_TYPE_FILE_OUTG_MARK
  , i_dir_commis_amount       in com_api_type_pkg.t_byte_char
  , i_commis_amount           in com_api_type_pkg.t_rate
  , i_auth_number             in com_api_type_pkg.t_auth_code
  , i_acqu_ref_number         in com_api_type_pkg.t_cmid
  , i_evnt_id                 in com_api_type_pkg.t_long_id
) return cst_bmed_cmo_files_format_pkg.t_cmo_outg_file_row;
   
/**********************************************************
 *
 * Generate footer of the CMO outgoing file
 *
 *********************************************************/
function gen_footer_cmo_out_file(
    i_footer                  in com_api_type_pkg.t_byte_char         default cst_bmed_cmo_files_format_pkg.FOOTER_FILE_OUTG_MARK
  , i_total_oper_count        in com_api_type_pkg.t_medium_id         default g_cmo_outg_file_prc_data_rec.count_oper
  , i_total_oper_amount       in com_api_type_pkg.t_long_id           default g_cmo_outg_file_prc_data_rec.total_oper_amount
  , i_file_id                 in com_api_type_pkg.t_byte_id           default g_cmo_outg_file_prc_data_rec.cmo_outg_file_id
) return cst_bmed_cmo_files_format_pkg.t_cmo_outg_file_ft;

/**********************************************************
 *
 * Generate full CMO outgoing file
 *
 *********************************************************/
procedure generate_cmo_outg_file(
    i_header         in cst_bmed_cmo_files_format_pkg.t_cmo_outg_file_hr
  , i_body_tab       in cst_bmed_cmo_files_format_pkg.t_cmo_outg_file_body
  , i_footer         in cst_bmed_cmo_files_format_pkg.t_cmo_outg_file_ft
  , o_file_content   out clob
);

end;
/
