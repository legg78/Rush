create or replace force view ntf_ui_message_vw as
select 
    n.id
    , n.channel_id
    , get_text (i_table_name    => 'ntf_channel',
                i_column_name   => 'name',
                i_object_id     => n.channel_id,
                i_lang          => n.lang)
             channel_name
    , n.text
    , n.lang
    , n.delivery_address
    , n.delivery_date
    , n.is_delivered
    , n.urgency_level
    , n.inst_id
    , case when n.inst_id = 9999 then
          com_api_label_pkg.get_label_text ('SYS_INST_NAME', com_ui_user_env_pkg.get_user_lang)
      else
          get_text (i_table_name    => 'ost_institution',
                i_column_name   => 'name',
                i_object_id     => n.inst_id,
                i_lang          => n.lang)
      end inst_name
    , n.event_type
    , n.eff_date   
    , n.entity_type
    , n.object_id              
    , n.sms_gate_reference    
    , n.message_status 
    , n.delivery_time      
from 
    ntf_message n
where n.inst_id in (select inst_id from acm_cu_inst_vw)  
/
