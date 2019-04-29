create or replace force view acq_ui_terminal_templ_vw as
select a.id
     , a.is_template
     , (select s.standard_id from cmn_standard_object s
         where s.entity_type = 'ENTTTRMN' and s.object_id = a.id) standard_id
     , a.terminal_type
     , a.card_data_input_cap
     , a.crdh_auth_cap
     , a.card_capture_cap
     , a.term_operating_env
     , a.crdh_data_present
     , a.card_data_present
     , a.card_data_input_mode
     , a.crdh_auth_method
     , a.crdh_auth_entity
     , a.card_data_output_cap
     , a.term_data_output_cap
     , a.pin_capture_cap
     , a.cat_level
     , a.status
     , (select c.product_id from prd_contract c where c.id = a.contract_id) product_id
     , a.contract_id
     , a.inst_id
     , a.seqnum
     , a.is_mac
     , a.gmt_offset
     , a.device_id
     , get_text('acq_terminal', 'name', a.id, b.lang) name
     , get_text('acq_terminal', 'description', a.id, b.lang) description
     , b.lang
     , a.cash_dispenser_present
     , a.payment_possibility
     , a.use_card_possibility
     , a.cash_in_present
     , a.available_network
     , (select x.label from com_ui_array_vw x where x.id = a.available_network and x.lang= b.lang) available_network_name
     , a.available_operation
     , (select x.label from com_ui_array_vw x where x.id = a.available_operation and x.lang= b.lang) available_operation_name
     , a.available_currency
     , (select x.label from com_ui_array_vw x where x.id = a.available_currency and x.lang= b.lang) available_currency_name
     , a.mcc_template_id
     , a.terminal_profile
     , a.pin_block_format
     , a.pos_batch_support
  from acq_terminal a
     , com_language_vw b
 where a.inst_id in (select inst_id from acm_cu_inst_vw)
   and is_template = 1
/
