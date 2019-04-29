create or replace force view atm_ui_template_vw as
select
    t.id
    , t.atm_type
    , get_article_text(i_article => t.atm_type, i_lang => l.lang) as atm_type_name
    , t.atm_model
    , t.serial_number
    , t.placement_type
    , get_article_text(i_article => t.placement_type, i_lang => l.lang) as placement_type_name
    , t.availability_type
    , get_article_text(i_article => t.availability_type, i_lang => l.lang) as availability_type_name
    , t.operating_hours
    , t.local_date_gap
    , t.cassette_count
    , t.key_change_algo
    , get_article_text(i_article => t.key_change_algo, i_lang => l.lang) as key_change_algo_name
    , t.dispense_algo
    , get_article_text(i_article => t.dispense_algo, i_lang => l.lang) as dispense_algo_name
    , t.counter_sync_cond
    , t.reject_disp_warn     -- Reject dispenser's overflow limit
    , t.reject_disp_min_warn -- Reject dispenser's warning limit
    , t.disp_rest_warn
    , t.receipt_warn
    , t.card_capture_warn
    , t.note_max_count
    , t.scenario_id
    , t.hopper_count
    , t.manual_synch
    , t.establ_conn_synch
    , t.counter_mismatch_synch
    , t.online_in_synch
    , t.online_out_synch
    , t.safe_close_synch
    , t.disp_error_synch
    , t.periodic_synch
    , t.periodic_all_oper
    , t.periodic_oper_count
    , a.inst_id
    , t.cash_in_present
    , t.cash_in_min_warn
    , t.cash_in_max_warn
    , l.lang
    , t.powerup_service
    , t.supervisor_service
from
    atm_terminal t
    , acq_terminal a
    , com_language_vw l
where      
    t.id = a.id
    and a.is_template = 1
/