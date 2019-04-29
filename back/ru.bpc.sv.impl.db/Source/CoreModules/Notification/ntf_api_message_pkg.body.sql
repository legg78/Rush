create or replace package body ntf_api_message_pkg is

    function get_id(
        i_eff_date                in date 
    ) 
    return com_api_type_pkg.t_long_id is
    begin
        return com_api_id_pkg.get_id(ntf_message_seq.nextval, i_eff_date);
    end;
    
    procedure create_message (
        o_id                        out com_api_type_pkg.t_long_id
        , i_channel_id              in com_api_type_pkg.t_tiny_id
        , i_text                    in clob
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_delivery_address        in com_api_type_pkg.t_full_desc
        , i_delivery_date           in date
        , i_urgency_level           in com_api_type_pkg.t_tiny_id
        , i_inst_id                 in com_api_type_pkg.t_tiny_id
        , i_event_type              in com_api_type_pkg.t_dict_value    default null
        , i_eff_date                in date                             default null
        , i_entity_type             in com_api_type_pkg.t_dict_value    default null
        , i_object_id               in com_api_type_pkg.t_long_id       default null
        , i_delivery_time           in com_api_type_pkg.t_name          default null
    ) is
        l_sms_gate_reference        com_api_type_pkg.t_long_id;
    begin
        trc_log_pkg.debug (
            i_text  => 'Going to flush notification message'
        );
        
        o_id := get_id(i_eff_date =>  com_api_sttl_day_pkg.get_sysdate);--ntf_message_seq.nextval;
        l_sms_gate_reference := ntf_message_ref_seq.nextval;
        
        insert into ntf_message_vw (
            id
            , channel_id
            , text
            , lang
            , delivery_address
            , delivery_date
            , is_delivered
            , urgency_level
            , inst_id
            , event_type
            , eff_date   
            , entity_type
            , object_id              
            , sms_gate_reference    
            , message_status    
            , message_status_reference    
            , delivery_time
        ) values (
            o_id
            , i_channel_id
            , i_text
            , i_lang
            , i_delivery_address
            , i_delivery_date
            , com_api_type_pkg.FALSE
            , nvl(i_urgency_level, com_api_type_pkg.TRUE)
            , i_inst_id
            , i_event_type
            , com_api_sttl_day_pkg.get_sysdate   
            , i_entity_type
            , i_object_id  
            , l_sms_gate_reference   
            , ntf_api_const_pkg.MSG_STATUS_READY     
            , null
            , nvl(i_delivery_time, '00-24')
        );
        
        trc_log_pkg.debug (
            i_text  => 'Notification message saved'
        );
    end;

end; 
/
