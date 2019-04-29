create or replace package body cst_bmed_cmo_files_format_pkg is
/**********************************************************
 * Custom outgoing or input files formats for CMO-canal operations 
 * 
 * Created by Gogolev I.(i.gogolev@bpcbt.com) at 09.09.2016
 * Last changed by Gogolev I.(i.gogolev@bpcbt.com) at 
 * 09.09.2016 11:13:00
 *
 * Module: CST_BMED_CMO_FILES_FORMAT_PKG
 * @headcom
 **********************************************************/
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
) return cst_bmed_cmo_files_format_pkg.t_cmo_outg_file_hr is

    HEAD                 constant com_api_type_pkg.t_byte_char     := cst_bmed_cmo_files_format_pkg.HEAD_FILE_OUTG_MARK;
    CMO_CANAL            constant com_api_type_pkg.t_module_code   := cst_bmed_cmo_files_format_pkg.CMO_CANAL_MARK;
    SPACE                constant com_api_type_pkg.t_byte_char     := ' ';
      
    l_header    com_api_type_pkg.t_byte_char              := nvl(i_header, HEAD);
    l_date_ch   com_api_type_pkg.t_date_short             := to_char(nvl(i_date, get_sysdate), 'YYYYMMDD');
    l_cmo_canal com_api_type_pkg.t_postal_code            := lpad(nvl(i_cmo_canal, CMO_CANAL), 10, SPACE);
    l_file_ch   com_api_type_pkg.t_mcc                    := lpad(nvl(to_char(i_file_id), '0'), 4, '0');
  
begin
    return l_header||l_date_ch||l_cmo_canal||l_file_ch;
end;

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
) return cst_bmed_cmo_files_format_pkg.t_cmo_outg_file_row is

    I_TAB_BEG                 constant com_api_type_pkg.t_sign      := 1;
    BODY_FILE                 constant com_api_type_pkg.t_byte_char := cst_bmed_cmo_files_format_pkg.BODY_ROW_FILE_OUTG_MARK;
    TRS_TYPE                  constant com_api_type_pkg.t_byte_char := cst_bmed_cmo_files_format_pkg.TRS_TYPE_FILE_OUTG_MARK;
    SPACE                     constant com_api_type_pkg.t_byte_char := ' ';
    ZERO                      constant com_api_type_pkg.t_sign      := 0;
    SIGN_DIR                  constant com_api_type_pkg.t_byte_char := cst_bmed_cmo_files_format_pkg.TRS_DIRECT;
    
    l_body                    com_api_type_pkg.t_byte_char          := nvl(i_body, BODY_FILE);
    l_merchant_id             com_api_type_pkg.t_merchant_number    := lpad(nvl(i_merchant_id, SPACE), 15, SPACE);
    l_merchant_name           com_api_type_pkg.t_name               := rpad(substr(nvl(i_merchant_name, SPACE), 1, 25), 25, SPACE);
    l_terminal_id             com_api_type_pkg.t_terminal_number    := lpad(substr(nvl(i_terminal_id, SPACE), 1, 8), 8, SPACE);
    l_transact_date           com_api_type_pkg.t_date_short         := to_char(nvl(i_transact_date, get_sysdate), 'DDMMYYYY');
    l_card_number             com_api_type_pkg.t_attr_name          := rpad(nvl(i_card_number, SPACE), 25, SPACE);
    l_currency_code           com_api_type_pkg.t_curr_code          := lpad(nvl(i_currency_code, SPACE), 3, SPACE);
    l_dir_transact_amount     com_api_type_pkg.t_byte_char          := nvl(i_dir_transact_amount, SIGN_DIR);
    l_transact_amount         com_api_type_pkg.t_auth_amount        := lpad(to_char(abs(nvl(i_transact_amount, ZERO))), 16, '0');
    l_transact_type           com_api_type_pkg.t_merchant_number    := rpad(nvl(i_transact_type, TRS_TYPE), 15, SPACE);
    l_dir_commis_amount       com_api_type_pkg.t_byte_char          := nvl(i_dir_commis_amount, SIGN_DIR);
    l_commis_amount           com_api_type_pkg.t_attr_name          := lpad(to_char(abs(nvl(i_commis_amount, ZERO))), 25, '0');
    l_auth_number             com_api_type_pkg.t_auth_code          := lpad(nvl(i_auth_number, SPACE), 6, SPACE);
    l_acqu_ref_number         com_api_type_pkg.t_cmid               := lpad(nvl(i_acqu_ref_number, SPACE), 12, SPACE);
    
    l_tab_indx                com_api_type_pkg.t_long_id := I_TAB_BEG;
    
    l_result                  cst_bmed_cmo_files_format_pkg.t_cmo_outg_file_row;
begin
    -- Initial global variables
    if g_cmo_outg_file_prc_data_rec.count_oper is null
    then
        g_cmo_outg_file_prc_data_rec.count_oper := 0;
    end if;
    
    if g_cmo_outg_file_prc_data_rec.total_oper_amount is null
    then
        g_cmo_outg_file_prc_data_rec.total_oper_amount := 0;
    end if;
    
    if g_cmo_outg_file_prc_data_rec.count_not_complete is null
    then
        g_cmo_outg_file_prc_data_rec.count_not_complete := 0;
    end if;
    
    if g_cmo_outg_file_prc_data_rec.evnt_id_tab.count = 0
    then
        g_cmo_outg_file_prc_data_rec.evnt_id_tab(l_tab_indx):= i_evnt_id;
    else
        l_tab_indx := g_cmo_outg_file_prc_data_rec.evnt_id_tab.last + 1;
        g_cmo_outg_file_prc_data_rec.evnt_id_tab(l_tab_indx):= i_evnt_id;
    end if;
    
    -- Getting results
    l_result :=
        l_body||l_merchant_id||l_merchant_name||l_terminal_id||l_transact_date
      ||l_card_number||l_currency_code||l_dir_transact_amount
      ||l_transact_amount||l_transact_type||l_dir_commis_amount||l_commis_amount
      ||l_auth_number||l_acqu_ref_number;
        
    -- Calculation of the statistical data
    g_cmo_outg_file_prc_data_rec.count_oper :=
        g_cmo_outg_file_prc_data_rec.count_oper + 1;
            
    g_cmo_outg_file_prc_data_rec.total_oper_amount :=
        g_cmo_outg_file_prc_data_rec.total_oper_amount + i_transact_amount;
            
    if i_body is null or i_body <> 'D' or i_merchant_id is null or i_merchant_name is null
        or i_terminal_id is null or i_transact_date is null or i_card_number is null
        or i_currency_code is null or i_dir_transact_amount is null or i_transact_amount is null
        or i_transact_type is null or i_transact_type <> 'TX' or i_dir_commis_amount is null
        or i_commis_amount is null or i_auth_number is null or i_acqu_ref_number is null
    then
            
        g_cmo_outg_file_prc_data_rec.count_not_complete :=
            g_cmo_outg_file_prc_data_rec.count_not_complete + 1;
                
    end if;
    
    return l_result;
            
end;
   
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
) return cst_bmed_cmo_files_format_pkg.t_cmo_outg_file_ft is

    FOOTER               constant com_api_type_pkg.t_byte_char     := cst_bmed_cmo_files_format_pkg.FOOTER_FILE_OUTG_MARK;
    SPACE                constant com_api_type_pkg.t_byte_char     := ' ';
  
    l_footer             com_api_type_pkg.t_byte_char              := nvl(i_footer, FOOTER);
    l_total_oper_count   com_api_type_pkg.t_dict_value             := lpad(nvl(to_char(i_total_oper_count), SPACE), 8, SPACE);
    l_total_oper_amount  com_api_type_pkg.t_original_data          := lpad(nvl(to_char(i_total_oper_amount), SPACE), 40, SPACE);
    l_file_ch            com_api_type_pkg.t_mcc                    := lpad(nvl(to_char(i_file_id), 0), 4, '0');
begin
    return l_footer||l_total_oper_count||l_total_oper_amount||l_file_ch;
end;

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
) is
begin
    if i_header is null 
        or i_body_tab.count = 0
        or i_footer is null
    then
        o_file_content := empty_clob();
        return;
    end if;
    
    o_file_content := to_clob(i_header);
    
    for i in i_body_tab.first .. i_body_tab.last
    loop
        dbms_lob.append(o_file_content, to_clob(i_body_tab(i)));
    end loop;
    
    dbms_lob.append(o_file_content, to_clob(i_footer));
    
    return;
exception
    when others then
        raise;
end;

end;
/
