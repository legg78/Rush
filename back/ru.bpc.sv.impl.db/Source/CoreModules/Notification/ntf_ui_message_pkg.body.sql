create or replace package body ntf_ui_message_pkg as

procedure remove_message(
    i_message_id_tab    in      num_tab_tpt
) is
begin
    if 1=1 then
        forall i in 1..i_message_id_tab.count
            update ntf_message
               set is_delivered = com_api_const_pkg.TRUE
             where id = i_message_id_tab(i);
    else
        forall i in 1..i_message_id_tab.count
            delete ntf_message
             where id = i_message_id_tab(i);
    end if;
end;

procedure remove_message(
    i_message_id        in      com_api_type_pkg.t_long_id
) is
begin
    if 1=1 then
        update ntf_message
           set is_delivered = com_api_const_pkg.TRUE
         where id = i_message_id;
    else
        delete ntf_message
         where id = i_message_id;
    end if;
end;

procedure get_undelivered_messages(
    i_channel_id        in      com_api_type_pkg.t_tiny_id  default null
  , i_max_count         in      com_api_type_pkg.t_long_id  default null
  , i_urgency_level     in      com_api_type_pkg.t_tiny_id  default null
  , o_messages          out     com_api_type_pkg.t_ref_cur
) is
    l_message_id_tab             num_tab_tpt := num_tab_tpt();
    l_rowid                      com_api_type_pkg.t_rowid_tab;
    l_urgency_level              com_api_type_pkg.t_tiny_id;
    l_max_count                  com_api_type_pkg.t_long_id;
    l_sysdate                    date;
        
    cursor cur is 
        select rowid row_id
             , id
          from ntf_message
         where l_urgency_level = decode(message_status, 'SGMSRDY', urgency_level, null)
           and (channel_id     = i_channel_id or i_channel_id is null)
           and rownum          <= l_max_count 
           and to_char(get_sysdate,'hh24') >= substr(delivery_time, 1, 2) 
           and to_char(get_sysdate,'hh24') <= substr(delivery_time, 4, 2) 
           and nvl(delivery_date, l_sysdate) <= l_sysdate
           for update of message_status nowait;

begin
    l_urgency_level := nvl(i_urgency_level, 1);
    l_max_count     := nvl(i_max_count, 400);
    l_sysdate       := get_sysdate;
                
    open cur;
    l_message_id_tab.extend(l_max_count);
    
    fetch cur bulk collect into
        l_rowid                     
        , l_message_id_tab;

    trc_log_pkg.debug (
        i_text       => 'fetched: [#1] rows'
      , i_env_param1 => l_rowid.count
    );
        
    forall i in 1..l_rowid.count            
        update ntf_message
           set message_status = ntf_api_const_pkg.MSG_STATUS_SENT
           --set is_delivered = com_api_const_pkg.TRUE
         where rowid = l_rowid(i);  
    
    close cur;

    commit;

    open o_messages for
        select case when length(to_char(id)) > 8 
                    then substr(to_char(id), -8) 
                    else to_char(id) 
               end id
             , channel_id
             , text
             , lang
             , delivery_address
             , delivery_date
             , is_delivered
             , urgency_level
             , sms_gate_reference
             , message_status
             , inst_id
          from ntf_message a
             , table(cast(l_message_id_tab as num_tab_tpt)) b
         where a.id = b.column_value
         order by id;

exception
    when com_api_error_pkg.e_resource_busy then
        null;     

end;

/*
 * Procedure marks a notification message unprocessed.
 */
procedure mark_message_unprocessed(
    i_message_id        in      com_api_type_pkg.t_long_id
  , i_message_status    in      com_api_type_pkg.t_dict_value    
  , i_mask_error        in      com_api_type_pkg.t_boolean  default com_api_type_pkg.FALSE
) is
begin
    update ntf_message_vw
       set message_status = i_message_status
     where id = i_message_id;

    if sql%rowcount = 0
       and nvl(i_mask_error, com_api_type_pkg.FALSE) = com_api_type_pkg.FALSE
    then
        com_api_error_pkg.raise_error(
            i_error      => 'NOTIFICATION_MESSAGE_IS_NOT_FOUND'
          , i_env_param1 => i_message_id
        );
    end if;
end;

/*
 * Procedure set a notification message status. Feedback from sms-gate.
 */
procedure update_message_status(
    i_sms_gate_reference       in      com_api_type_pkg.t_short_id      default null 
  , i_message_status           in      com_api_type_pkg.t_dict_value    
  , i_message_status_reference in      com_api_type_pkg.t_name          default null 
  , i_mask_error               in      com_api_type_pkg.t_boolean       default com_api_type_pkg.FALSE
  , i_delivery_date            in      date                             default null     
)is
begin
    if i_sms_gate_reference is not null then

        update ntf_message_vw
           set message_status_reference = i_message_status_reference
             , message_status = nvl(i_message_status, message_status)
             , delivery_date  = case when i_delivery_date is not null then i_delivery_date
                                     else decode(i_message_status, ntf_api_const_pkg.MSG_STATUS_DELIVERED, get_sysdate, null)
                                end     
         where sms_gate_reference = i_sms_gate_reference;
    
    else
        update ntf_message_vw
           set message_status = i_message_status
             , delivery_date  = decode(i_message_status, ntf_api_const_pkg.MSG_STATUS_DELIVERED, get_sysdate, null)                                     
         where message_status_reference = i_message_status_reference;
    
    end if;
    
    if sql%rowcount = 0
       and nvl(i_mask_error, com_api_type_pkg.FALSE) = com_api_type_pkg.FALSE
    then
        com_api_error_pkg.raise_error(
            i_error      => 'NOTIFICATION_MESSAGE_IS_NOT_FOUND'
          , i_env_param1 => i_sms_gate_reference
        );
    end if;

end;

procedure update_message_status(
    i_message_id_tab           in      com_api_type_pkg.t_long_tab
  , i_message_status           in      com_api_type_pkg.t_dict_value 
  , i_mask_error               in      com_api_type_pkg.t_boolean       default com_api_type_pkg.FALSE
) is
begin
    forall i in 1 .. i_message_id_tab.count
        update ntf_message_vw
           set message_status = i_message_status
         where id = i_message_id_tab(i);

    if sql%rowcount = 0
       and nvl(i_mask_error, com_api_type_pkg.FALSE) = com_api_type_pkg.FALSE
    then
        com_api_error_pkg.raise_error(
            i_error      => 'NOTIFICATION_MESSAGE_IS_NOT_FOUND'
        );
    end if;
end update_message_status;

end;
/
