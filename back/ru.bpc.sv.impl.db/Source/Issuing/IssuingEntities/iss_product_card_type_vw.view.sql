create or replace force view iss_product_card_type_vw as
select
    n.id
    , n.seqnum
    , n.product_id
    , n.card_type_id
    , n.seq_number_low
    , n.seq_number_high
    , n.bin_id
    , n.index_range_id
    , n.number_format_id
    , n.pin_request
    , n.pin_mailer_request
    , n.embossing_request
    , n.blank_type_id
    , n.status
    , n.perso_priority
    , n.reiss_command
    , n.reiss_start_date_rule
    , n.reiss_expir_date_rule
    , n.reiss_card_type_id
    , n.reiss_contract_id
    , n.state
    , n.emv_appl_scheme_id
    , n.perso_method_id
    , n.service_id
    , n.reiss_product_id  
    , n.reiss_bin_id
    , n.uid_format_id  
from 
    iss_product_card_type n
/
