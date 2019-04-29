create or replace force view acq_ui_terminal_vw as
select a.id
  , a.seqnum
  , a.is_template
  , a.terminal_number
  , a.terminal_type
  , a.merchant_id
  , nvl(a.mcc, (select min(m.mcc) from acq_merchant m where m.id = a.merchant_id)) mcc
  , a.plastic_number
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
  , a.gmt_offset
  , a.is_mac
  , a.device_id
  , a.status
  , a.contract_id
  , a.inst_id
  , a.split_hash
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
  , get_text('acq_terminal', 'description', a.id, b.lang) description
  , b.lang
  , c.product_id
  , s.id                standard_id
  , get_text (
      i_table_name => 'cmn_standard'
      , i_column_name => 'label'
      , i_object_id => s.standard_id
      , i_lang => b.lang
    ) as standard_name
  , a.mcc_template_id
  , a.terminal_profile
  , a.pin_block_format
  , a.pos_batch_support
from acq_terminal a
   , com_language_vw b
   , prd_contract c
   , cmn_standard_object s
where a.inst_id in (select inst_id from acm_cu_inst_vw)
    and a.contract_id      = c.id(+)
    and a.id               = s.object_id(+)
    and s.entity_type(+)   = 'ENTTTRMN'
    and s.standard_type(+) = 'STDT0002'
/
