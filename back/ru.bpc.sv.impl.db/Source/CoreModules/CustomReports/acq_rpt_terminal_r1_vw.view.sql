create or replace force view acq_rpt_terminal_r1_vw as
select id
     , seqnum
     , is_template
     , terminal_number
     , terminal_type
     , com_api_dictionary_pkg.get_article_text(
           i_article => terminal_type
       ) terminal_type_name
     , merchant_id
     , mcc
     , plastic_number
     , card_data_input_cap
     , com_api_dictionary_pkg.get_article_text(
           i_article => card_data_input_cap
       ) card_data_input_cap_name
     , crdh_auth_cap
     , com_api_dictionary_pkg.get_article_text(
           i_article => crdh_auth_cap
       ) crdh_auth_cap_name
     , card_capture_cap
     , com_api_dictionary_pkg.get_article_text(
           i_article => card_capture_cap
       ) card_capture_cap_name
     , term_operating_env
     , com_api_dictionary_pkg.get_article_text(
           i_article => term_operating_env
       ) term_operating_env_name
     , crdh_data_present
     , com_api_dictionary_pkg.get_article_text(
           i_article => crdh_data_present
       ) crdh_data_present_name
     , card_data_present
     , com_api_dictionary_pkg.get_article_text(
           i_article => card_data_present
       ) card_data_present_name
     , card_data_input_mode
     , com_api_dictionary_pkg.get_article_text(
           i_article => card_data_input_mode
       ) card_data_input_mode_name
     , crdh_auth_method
     , com_api_dictionary_pkg.get_article_text(
           i_article => crdh_auth_method
       ) crdh_auth_method_name
     , crdh_auth_entity
     , com_api_dictionary_pkg.get_article_text(
           i_article => crdh_auth_entity
       ) crdh_auth_entity_name
     , card_data_output_cap
     , com_api_dictionary_pkg.get_article_text(
           i_article => card_data_output_cap
       ) card_data_output_cap_name
     , term_data_output_cap
     , com_api_dictionary_pkg.get_article_text(
           i_article => term_data_output_cap
       ) term_data_output_cap_name
     , pin_capture_cap
     , com_api_dictionary_pkg.get_article_text(
           i_article => pin_capture_cap
       ) pin_capture_cap_name
     , cat_level
     , com_api_dictionary_pkg.get_article_text(
           i_article => cat_level
       ) cat_level_name
     , gmt_offset
     , is_mac
     , device_id
     , status
     , com_api_dictionary_pkg.get_article_text(
           i_article => status
       ) status_name
     , contract_id
     , inst_id
     , split_hash
     , cash_dispenser_present
     , payment_possibility
     , use_card_possibility
     , cash_in_present
     , available_network
     , available_operation
     , available_currency
     , mcc_template_id
     , terminal_profile
     , pin_block_format
     , com_api_dictionary_pkg.get_article_text(
           i_article => pin_block_format
       ) pin_block_format_name
     , pos_batch_support
  from acq_terminal
/

