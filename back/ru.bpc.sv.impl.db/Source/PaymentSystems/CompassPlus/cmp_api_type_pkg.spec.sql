create or replace package cmp_api_type_pkg as

    type            t_cmp_file_rec is record (
        id                    com_api_type_pkg.t_long_id
      , is_incoming           com_api_type_pkg.t_boolean
      , is_rejected           com_api_type_pkg.t_boolean
      , network_id            com_api_type_pkg.t_tiny_id
      , trans_date            date
      , inst_id               com_api_type_pkg.t_inst_id
      , inst_name             com_api_type_pkg.t_name 
      , action_code           com_api_type_pkg.t_boolean     
      , file_number           com_api_type_pkg.t_tiny_id    
      , pack_no               com_api_type_pkg.t_postal_code    
      , version               com_api_type_pkg.t_postal_code    
      , crc                   com_api_type_pkg.t_money
      , encoding              com_api_type_pkg.t_auth_code
      , file_type             com_api_type_pkg.t_postal_code
      , session_file_id       com_api_type_pkg.t_long_id
    );
    type            t_cmp_file_cur is ref cursor return t_cmp_file_rec;
    type            t_cmp_file_tab is table of t_cmp_file_rec index by binary_integer;

    type            t_cmp_fin_mes_rec is record (
        id                         com_api_type_pkg.t_long_id
      , card_id                    com_api_type_pkg.t_medium_id
      , card_hash                  com_api_type_pkg.t_medium_id
      , card_mask                  com_api_type_pkg.t_card_number
      , card_number                com_api_type_pkg.t_card_number ---- for local processing only, not for inserting in CMP_FIN_MESSAGE
      , file_id                    com_api_type_pkg.t_long_id
      , inst_id                    com_api_type_pkg.t_inst_id
      , network_id                 com_api_type_pkg.t_tiny_id
      , host_inst_id               com_api_type_pkg.t_inst_id
      , msg_number                 com_api_type_pkg.t_long_id
      , is_reversal                com_api_type_pkg.t_boolean
      , is_incoming                com_api_type_pkg.t_boolean
      , is_rejected                com_api_type_pkg.t_boolean
      , is_invalid                 com_api_type_pkg.t_boolean
      , tran_code                  com_api_type_pkg.t_mcc
      , conversion_rate            com_api_type_pkg.t_sign
      , ext_stan                   com_api_type_pkg.t_auth_code
      , orig_time                  date                
      , capability                 com_api_type_pkg.t_auth_medium_id    
      , tran_type                  com_api_type_pkg.t_mcc
      , tran_class                 com_api_type_pkg.t_curr_code        
      , term_class                 com_api_type_pkg.t_curr_code        
      , mcc                        com_api_type_pkg.t_mcc
      , arn                        com_api_type_pkg.t_card_number         
      , ext_fid                    com_api_type_pkg.t_cmid        
      , tran_number                com_api_type_pkg.t_rrn         
      , approval_code              com_api_type_pkg.t_dict_value
      , term_name                  com_api_type_pkg.t_auth_long_id
      , term_retailer_name         com_api_type_pkg.t_auth_long_id
      , ext_term_retailer_name     com_api_type_pkg.t_auth_long_id 
      , term_city                  com_api_type_pkg.t_name
      , term_location              com_api_type_pkg.t_oracle_name
      , term_owner                 com_api_type_pkg.t_oracle_name
      , term_country               com_api_type_pkg.t_curr_code 
      , amount                     com_api_type_pkg.t_money
      , reconcil_amount            com_api_type_pkg.t_money        
      , orig_amount                com_api_type_pkg.t_money
      , currency                   com_api_type_pkg.t_curr_code
      , reconcil_currency          com_api_type_pkg.t_curr_code        
      , orig_currency              com_api_type_pkg.t_curr_code
      , pay_amount                 com_api_type_pkg.t_money
      , pay_currency               com_api_type_pkg.t_curr_code
      , term_inst_id               com_api_type_pkg.t_cmid
      , status                     com_api_type_pkg.t_dict_value
      , term_zip                   com_api_type_pkg.t_postal_code
      , exp_date                   com_api_type_pkg.t_mcc
      , network                    com_api_type_pkg.t_byte_char       
      , host_net_id                com_api_type_pkg.t_mcc
      , ext_tran_attr              com_api_type_pkg.t_full_desc
      , term_inst_country          com_api_type_pkg.t_curr_code
      , pos_condition              com_api_type_pkg.t_postal_code
      , pos_entry_mode             com_api_type_pkg.t_curr_code
      , pin_presence               com_api_type_pkg.t_sign
      , term_entry_caps            com_api_type_pkg.t_postal_code
      , host_time                  date      
      , ext_ps_fields              com_api_type_pkg.t_text
      , term_contactless_capable   com_api_type_pkg.t_byte_char 
      , final_rrn                  com_api_type_pkg.t_rrn
      , from_acct_type             com_api_type_pkg.t_byte_char
      , aid                        com_api_type_pkg.t_auth_code
      , orig_fi_name               com_api_type_pkg.t_name
      , dest_fi_name               com_api_type_pkg.t_name
      , clear_date                 date
      , card_member                com_api_type_pkg.t_curr_code
      , icc_term_caps              com_api_type_pkg.t_postal_code
      , icc_tvr                    com_api_type_pkg.t_postal_code
      , icc_random                 com_api_type_pkg.t_dict_value
      , icc_term_sn                com_api_type_pkg.t_dict_value
      , icc_issuer_data            com_api_type_pkg.t_name
      , icc_cryptogram             com_api_type_pkg.t_auth_long_id
      , icc_app_tran_count         com_api_type_pkg.t_postal_code
      , icc_term_tran_count        com_api_type_pkg.t_postal_code
      , icc_app_profile            com_api_type_pkg.t_postal_code
      , icc_iad                    com_api_type_pkg.t_rrn
      , icc_tran_type              com_api_type_pkg.t_byte_char 
      , icc_term_country           com_api_type_pkg.t_postal_code
      , icc_tran_date              date 
      , icc_amount                 com_api_type_pkg.t_cmid
      , icc_currency               com_api_type_pkg.t_postal_code
      , icc_cb_amount              com_api_type_pkg.t_cmid
      , icc_crypt_inform_data      com_api_type_pkg.t_postal_code
      , icc_cvm_res                com_api_type_pkg.t_postal_code
      , icc_card_member            com_api_type_pkg.t_postal_code   
      , icc_respcode               com_api_type_pkg.t_byte_char          
      , emv_data_exists            com_api_type_pkg.t_boolean
      , collect_only_flag          com_api_type_pkg.t_byte_char
      , service_code               com_api_type_pkg.t_curr_name
    );
    type            t_cmp_fin_mes_tab is table of t_cmp_fin_mes_rec index by binary_integer;
    type            t_cmp_fin_cur is ref cursor return t_cmp_fin_mes_rec;

    type            t_tc_buffer is table of com_api_type_pkg.t_text index by binary_integer;
    
end;
/
