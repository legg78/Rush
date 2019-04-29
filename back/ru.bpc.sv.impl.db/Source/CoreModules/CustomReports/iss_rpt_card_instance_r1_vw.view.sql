create or replace force view iss_rpt_card_instance_r1_vw as
select id
     , split_hash
     , card_id
     , seq_number
     , state
     , com_api_dictionary_pkg.get_article_text(
           i_article => state
       ) state_name
     , reg_date
     , iss_date
     , start_date
     , expir_date
     , cardholder_name
     , company_name
     , pin_request
     , com_api_dictionary_pkg.get_article_text(
           i_article => pin_request
       ) pin_request_name
     , pin_mailer_request
     , com_api_dictionary_pkg.get_article_text(
           i_article => pin_mailer_request
       ) pin_mailer_request_name
     , embossing_request
     , com_api_dictionary_pkg.get_article_text(
           i_article => embossing_request
       ) embossing_request_name
     , status
     , com_api_dictionary_pkg.get_article_text(
           i_article => status
       ) status_name
     , perso_priority
     , com_api_dictionary_pkg.get_article_text(
           i_article => perso_priority
       ) perso_priority_name
     , perso_method_id
     , bin_id
     , inst_id
     , agent_id
     , blank_type_id
     , icc_instance_id
     , delivery_channel
     , com_api_dictionary_pkg.get_article_text(
           i_article => delivery_channel
       ) delivery_channel_name
     , preceding_card_instance_id
     , reissue_reason
     , com_api_dictionary_pkg.get_article_text(
           i_article => reissue_reason
       ) reissue_reason_name
     , reissue_date
     , session_id
     , card_uid
     , delivery_ref_number
     , delivery_status
     , com_api_dictionary_pkg.get_article_text(
           i_article => delivery_status
       ) delivery_status_name
     , embossed_surname
     , embossed_first_name
     , embossed_second_name
     , embossed_title
     , com_api_dictionary_pkg.get_article_text(
           i_article => embossed_title
       ) embossed_title_name
     , embossed_line_additional
     , cardholder_photo_file_name
     , cardholder_sign_file_name
     , supplementary_info_1
  from iss_card_instance
/

