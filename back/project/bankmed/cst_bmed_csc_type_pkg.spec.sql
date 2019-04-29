create or replace package cst_bmed_csc_type_pkg as

    type            t_csc_file_rec is record (
        identifier_header         com_api_type_pkg.t_byte_char   
        , file_label              com_api_type_pkg.t_postal_code
        , file_id                 com_api_type_pkg.t_dict_value
        , identifier_trailer      com_api_type_pkg.t_byte_char   
        , trans_total             com_api_type_pkg.t_medium_id 
        , amount_total            com_api_type_pkg.t_money 
        , reversal_amount_total   com_api_type_pkg.t_money 
    );

    type            t_csc_fin_mes_rec is record (
        id                         com_api_type_pkg.t_long_id
        , is_invalid               com_api_type_pkg.t_boolean 

        , file_id                  com_api_type_pkg.t_dict_value 
        , rec_id                   com_api_type_pkg.t_medium_id  
        , proc_code                com_api_type_pkg.t_auth_code 
        , act_code                 com_api_type_pkg.t_curr_code 
        , date_time_local_tran     com_api_type_pkg.t_cmid
        , retrieval_ref_nbr        com_api_type_pkg.t_cmid
        , system_trace_audit_nbr   com_api_type_pkg.t_cmid
        , card_acpt_term_id        com_api_type_pkg.t_merchant_number 
        , card_acpt_id             com_api_type_pkg.t_merchant_number 
        , card_acpt_addr           com_api_type_pkg.t_attr_name 
        , card_acpt_city           com_api_type_pkg.t_attr_name 
        , card_acpt_country        com_api_type_pkg.t_curr_code 
        , country_acqr_inst        com_api_type_pkg.t_curr_code 
        , inst_id_acqr             com_api_type_pkg.t_cmid 
        , network_id_acqr          com_api_type_pkg.t_curr_code 
        , network_term_id          com_api_type_pkg.t_dict_value 
        , pr_proc_id               com_api_type_pkg.t_auth_code 
        , proc_id_acqr             com_api_type_pkg.t_auth_code 
        , process_id_acqr          com_api_type_pkg.t_auth_code
        , date_recon_acqr          com_api_type_pkg.t_auth_code     
        , pan                      varchar2(28) 
        , inst_id_issr             com_api_type_pkg.t_cmid 
        , pr_rpt_inst_id_issr      com_api_type_pkg.t_cmid 
        , date_recon_issr          com_api_type_pkg.t_auth_code
        , auth_by                  com_api_type_pkg.t_byte_char
        , approval_code            com_api_type_pkg.t_auth_code 
        , country_auth_agent_inst  com_api_type_pkg.t_curr_code
        , rev_by                   com_api_type_pkg.t_byte_char 
        , date_exp                 com_api_type_pkg.t_mcc 
        , date_time_trans_rqst     com_api_type_pkg.t_postal_code 
        , cur_tran                 com_api_type_pkg.t_curr_code 
        , cur_tran_exp             com_api_type_pkg.t_byte_char 
        , amt_tran                 com_api_type_pkg.t_money 
        , amt_rev                  com_api_type_pkg.t_money 
        , amt_tran_fee             com_api_type_pkg.t_money 
        , cur_card_bill            com_api_type_pkg.t_curr_code 
        , cur_bill_exp             com_api_type_pkg.t_byte_char 
        , amt_card_bill            com_api_type_pkg.t_money  
        , amt_rev_bill             com_api_type_pkg.t_money  
        , amt_card_bill_fee        com_api_type_pkg.t_money  
    );
    type            t_csc_fin_mes_tab is table of t_csc_fin_mes_rec index by binary_integer;
    type            t_csc_fin_cur is ref cursor return t_csc_fin_mes_rec;

    type            t_tc_buffer is table of com_api_type_pkg.t_text index by binary_integer;

end;
/
