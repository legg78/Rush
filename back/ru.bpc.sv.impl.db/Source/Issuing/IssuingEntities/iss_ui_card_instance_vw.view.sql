create or replace force view iss_ui_card_instance_vw as
select i.id
     , i.split_hash
     , i.card_id
     , i.seq_number
     , i.state
     , i.reg_date
     , i.iss_date
     , i.start_date
     , i.expir_date
     , nvl(i.cardholder_name, trim(upper(i.embossed_surname||' '||i.embossed_first_name))) as cardholder_name
     , i.company_name
     , i.pin_request
     , i.pin_mailer_request
     , i.embossing_request
     , i.status
     , i.perso_priority
     , i.perso_method_id
     , i.bin_id
     , i.inst_id
     , i.agent_id
     , i.blank_type_id
     , i.icc_instance_id
     , i.delivery_channel
     , i.preceding_card_instance_id
     , i.reissue_reason
     , i.reissue_date
     , i.session_id
     , i.card_uid
     , i.delivery_ref_number
     , i.delivery_status
     , i.embossed_surname
     , i.embossed_first_name
     , i.embossed_second_name
     , i.embossed_title
     , i.embossed_line_additional
     , i.supplementary_info_1
     , i.cardholder_photo_file_name
     , i.cardholder_sign_file_name
  from iss_card_instance i
/
