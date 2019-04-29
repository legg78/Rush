create or replace force view prs_method_vw as
select 
    n.id
    , n.inst_id
    , n.seqnum
    , n.pvv_store_method
    , n.pin_store_method
    , n.pin_verify_method
    , n.cvv_required
    , n.icvv_required
    , n.pvk_index
    , n.key_schema_id
    , n.service_code
    , n.dda_required
    , n.imk_index
    , n.private_key_component
    , n.private_key_format
    , n.module_length
    , n.max_script
    , n.is_active
    , n.decimalisation_table
    , n.exp_date_format
    , n.pin_length
    , n.cvv2_required
from 
    prs_method n
/
