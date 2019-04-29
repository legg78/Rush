create or replace force view opr_rpt_operation_r1_vw as
select id
     , session_id
     , is_reversal
     , original_id
     , oper_type
     , com_api_dictionary_pkg.get_article_text(
           i_article => oper_type
       ) oper_type_name
     , oper_reason
     , com_api_dictionary_pkg.get_article_text(
           i_article => oper_reason
       ) oper_reason_name
     , msg_type
     , com_api_dictionary_pkg.get_article_text(
           i_article => msg_type
       ) msg_type_nmae
     , status
     , com_api_dictionary_pkg.get_article_text(
           i_article => status
       ) status_name
     , status_reason
     , com_api_dictionary_pkg.get_article_text(
           i_article => status_reason
       ) status_reason_name
     , sttl_type
     , com_api_dictionary_pkg.get_article_text(
           i_article => sttl_type 
       ) sttl_type_name
     , terminal_type
     , com_api_dictionary_pkg.get_article_text(
           i_article => terminal_type
       ) terminal_type_name
     , acq_inst_bin
     , forw_inst_bin
     , merchant_number
     , terminal_number
     , merchant_name
     , merchant_street
     , merchant_city
     , merchant_region
     , merchant_country
     , case when merchant_country is null then null
            else com_api_country_pkg.get_country_name(
                     i_code => merchant_country
                 ) end merchant_country_name
     , merchant_postcode
     , mcc
     , originator_refnum
     , network_refnum
     , oper_count
     , oper_request_amount
     , oper_amount_algorithm
     , com_api_dictionary_pkg.get_article_text(
           i_article => oper_amount_algorithm
       ) oper_amount_algorithm_name
     , oper_amount
     , oper_currency
     , oper_cashback_amount
     , oper_replacement_amount
     , oper_surcharge_amount
     , oper_date
     , host_date
     , unhold_date
     , match_status
     , com_api_dictionary_pkg.get_article_text(
           i_article => match_status
       ) match_status_name
     , sttl_amount
     , sttl_currency
     , dispute_id
     , payment_order_id
     , payment_host_id
     , forced_processing
     , match_id
     , proc_mode
     , com_api_dictionary_pkg.get_article_text(
           i_article => proc_mode
       ) proc_mode_name
     , clearing_sequence_num
     , clearing_sequence_count
     , incom_sess_file_id
     , fee_amount
     , fee_currency
     , sttl_date
     , acq_sttl_date
  from opr_operation
/

