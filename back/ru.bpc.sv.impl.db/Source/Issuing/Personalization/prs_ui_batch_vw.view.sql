create or replace force view prs_ui_batch_vw as
select 
    n.id
    , n.seqnum
    , n.inst_id
    , n.agent_id
    , n.product_id
    , n.card_type_id
    , n.blank_type_id
    , n.card_count
    , n.hsm_device_id
    , n.status
    , n.status_date
    , n.sort_id
    , n.perso_priority
    , n.batch_name
    , l.lang
    , count(distinct c.card_instance_id) card_count_actual
    , count(decode(c.pin_request, 'PNRQGENR', 1)) pin_request_cnt
    , count(decode(c.pin_mailer_request, 'PMRQPRNT', 1)) pin_mailer_request_cnt
    , count(decode(c.embossing_request, 'EMRQEMBS', 1)) embossing_request_cnt
    , prs_api_card_pkg.enum_sort_condition(n.sort_id) sort_condition
    , get_text (
        i_table_name    => 'prs_sort'
        , i_column_name => 'label'
        , i_object_id   => n.sort_id
        , i_lang        => l.lang
      ) sort_label
    , n.reissue_reason
from 
    prs_batch n
    , prs_batch_card c
    , com_language_vw l
where
    n.inst_id in (select inst_id from acm_cu_inst_vw)
    and n.id = c.batch_id(+)
group by
    n.id
    , n.seqnum
    , n.inst_id
    , n.agent_id
    , n.product_id
    , n.card_type_id
    , n.blank_type_id
    , n.card_count
    , n.hsm_device_id
    , n.status
    , n.status_date
    , n.sort_id
    , n.perso_priority
    , l.lang
    , prs_api_card_pkg.enum_sort_condition(n.sort_id)
    , n.batch_name
    , n.reissue_reason
/
