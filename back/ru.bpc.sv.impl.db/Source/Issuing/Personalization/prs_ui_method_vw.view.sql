create or replace force view prs_ui_method_vw as
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
    , n.decimalisation_table
    , n.exp_date_format
    , n.pin_length
    , get_text (
        i_table_name    => 'prs_method'
        , i_column_name => 'description'
        , i_object_id   => n.id
        , i_lang        => l.lang
      ) description
    , l.lang
    , n.cvv2_required
from 
    prs_method n
    , com_language_vw l
where
    n.inst_id in (select inst_id from acm_cu_inst_vw)
/
