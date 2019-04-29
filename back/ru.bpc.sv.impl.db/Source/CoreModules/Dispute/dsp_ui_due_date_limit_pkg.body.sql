create or replace package body dsp_ui_due_date_limit_pkg is
/**************************************************
 *  Dispute due date limits UI <br />
 *  Created by Alalykin A.(alalykin@bpcbt.com) at 02.12.2016 <br />
 *  Module: DSP_UI_DUE_DATE_LIMIT_PKG <br />
 *  @headcom
 ***************************************************/

/*
 * Get a due date limit for a dispute application.
 */
function get_due_date(
    i_message_type          in     com_api_type_pkg.t_dict_value
  , i_oper_date             in     date
  , i_reason_code           in     com_api_type_pkg.t_dict_value
  , i_standard_id           in     com_api_type_pkg.t_tiny_id       default null
  , i_is_manual             in     com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
  , i_usage_code            in     com_api_type_pkg.t_byte_char     default null
) return date
is
    l_days_count                   com_api_type_pkg.t_tiny_id;
begin
    begin
        select max(case i_is_manual 
                       when com_api_const_pkg.FALSE 
                       then 
                           nvl(resolve_due_date, respond_due_date)
                       else 
                           respond_due_date    
                   end)
                   keep (dense_rank first order by
                             case reason_code
                                  when dsp_api_const_pkg.DUE_DATE_REASON_CODE_ANY
                                  then '99999999'
                                  else reason_code
                              end)
          into l_days_count
          from dsp_due_date_limit t
         where (i_standard_id is null or standard_id = i_standard_id)
           and message_type  = i_message_type
           and reason_code  in (i_reason_code, dsp_api_const_pkg.DUE_DATE_REASON_CODE_ANY)
           and is_incoming   = com_api_type_pkg.FALSE
           and (respond_due_date is not null or resolve_due_date is not null)
           and ( (i_usage_code is null and usage_code is null)
              or usage_code   = i_usage_code 
               );
    exception
        when no_data_found then
            null;
    end;

    return case
               when l_days_count is not null
               then trunc(i_oper_date) + l_days_count
               else null
           end;
end get_due_date;

/*
 * Get a due date limit for a dispute application.
 */
function get_due_date(
    i_init_rule             in     com_api_type_pkg.t_tiny_id
  , i_oper_date             in     date
  , i_reason_code           in     com_api_type_pkg.t_dict_value
  , i_usage_code            in     com_api_type_pkg.t_byte_char     default null
) return date
is
    l_date                         date;
    l_msg_type                     com_api_type_pkg.t_dict_value;
    l_scale_type                   com_api_type_pkg.t_dict_value;
    l_standard_id                  com_api_type_pkg.t_tiny_id;
begin
    begin
        select c.msg_type
             , s.scale_type
          into l_msg_type
             , l_scale_type
          from dsp_list_condition c
          join rul_mod            m    on m.id = c.mod_id
          join rul_mod_scale      s    on s.id = m.scale_id
         where c.init_rule = i_init_rule
           and rownum      = 1; -- just case since there is not UK for field init_rule
    exception
        when no_data_found then
            null;
    end;

    if l_msg_type is not null then
        -- l_scale_type/l_standard_id may be empty
        trc_log_pkg.debug(
            i_text       => lower($$PLSQL_UNIT) || '.get_due_date: l_msg_type [#1], l_scale_type [#2]'
          , i_env_param1 => l_msg_type
          , i_env_param2 => l_scale_type
        );

        l_standard_id :=
            case l_scale_type
                when dsp_api_const_pkg.SCALE_TYPE_DSP_VISA       then vis_api_const_pkg.VISA_BASEII_STANDARD
                when dsp_api_const_pkg.SCALE_TYPE_DSP_MASTERCARD then mcw_api_const_pkg.MCW_STANDARD_ID
                when dsp_api_const_pkg.SCALE_TYPE_DSP_BORICA     then bgn_api_const_pkg.BGN_CLEARING_STANDARD
                when dsp_api_const_pkg.SCALE_TYPE_DSP_JCB        then jcb_api_const_pkg.STANDARD_ID
                                                                 else null
            end;

        l_date :=
            get_due_date(
                i_message_type  => l_msg_type
              , i_oper_date     => i_oper_date
              , i_reason_code   => i_reason_code
              , i_standard_id   => l_standard_id
              , i_usage_code    => i_usage_code
            );
    end if;

    return l_date;
end get_due_date;

/*
 * Update value of dispute application element DUE_DATE, switch a notification cycle (optional).
 * @i_dispute_id     - it is used for searching an application if @i_appld_is is not specified
 * @i_expir_notif    - if TRUE then set/switch associated notification cycle
 * @i_due_date       - a base for calculation a new (updated) due date
 */
procedure update_due_date(
    i_dispute_id            in     com_api_type_pkg.t_long_id
  , i_appl_id               in     com_api_type_pkg.t_long_id
  , i_due_date              in     date
  , i_expir_notif           in     com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
  , i_mask_error            in     com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
) is
begin
    dsp_api_due_date_limit_pkg.update_due_date(
        i_dispute_id   => i_dispute_id
      , i_appl_id      => i_appl_id
      , i_due_date     => i_due_date
      , i_expir_notif  => i_expir_notif
      , i_mask_error   => i_mask_error
    );
end update_due_date;

procedure add(
    i_standard_id           in     com_api_type_pkg.t_tiny_id
  , i_message_type          in     com_api_type_pkg.t_dict_value
  , i_is_incoming           in     com_api_type_pkg.t_boolean
  , i_reason_code           in     com_api_type_pkg.t_dict_value
  , i_respond_due_date      in     com_api_type_pkg.t_tiny_id       default null
  , i_resolve_due_date      in     com_api_type_pkg.t_tiny_id       default null
  , i_usage_code            in     com_api_type_pkg.t_boolean       default null
  , o_seqnum                   out com_api_type_pkg.t_seqnum
  , o_id                       out com_api_type_pkg.t_tiny_id
  , i_mask_error            in     com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE 
) is
begin
    trc_log_pkg.debug(
        i_text       => 'dsp_ui_due_date_limit_pkg.add standard_id [#1], message_type [#2], is_incoming [#3], reason_code [#4], respond_due_date [#5], resolve_due_date [#6]'
      , i_env_param1 => i_standard_id
      , i_env_param2 => i_message_type
      , i_env_param3 => i_is_incoming
      , i_env_param4 => i_reason_code
      , i_env_param5 => i_respond_due_date
      , i_env_param6 => i_resolve_due_date
    );
    o_seqnum := 1;

    insert into dsp_due_date_limit(
        id              
      , seqnum          
      , standard_id     
      , message_type    
      , is_incoming     
      , reason_code     
      , respond_due_date
      , resolve_due_date
      , usage_code      
    ) values(
        dsp_due_date_limit_seq.nextval
      , o_seqnum
      , i_standard_id
      , i_message_type
      , i_is_incoming
      , i_reason_code
      , i_respond_due_date
      , i_resolve_due_date
      , i_usage_code
    ) returning id into o_id;
    trc_log_pkg.debug(
        i_text       => 'dsp_ui_due_date_limit_pkg.add created [#1]'
      , i_env_param1 => o_id
    );
exception
    when dup_val_on_index then
        if i_mask_error = com_api_const_pkg.TRUE then
            trc_log_pkg.warn(
                i_text       => 'DSP_DUE_DATE_EXISTS'
              , i_env_param1 => i_standard_id
              , i_env_param2 => i_message_type
              , i_env_param3 => i_is_incoming
              , i_env_param4 => i_reason_code
              , i_env_param5 => i_usage_code
            );
        else
            com_api_error_pkg.raise_error(
                i_error      => 'DSP_DUE_DATE_EXISTS'
              , i_env_param1 => i_standard_id
              , i_env_param2 => i_message_type
              , i_env_param3 => i_is_incoming
              , i_env_param4 => i_reason_code
              , i_env_param5 => i_usage_code
            );
        end if;   
end add;

procedure modify(
    i_id                    in     com_api_type_pkg.t_tiny_id
  , i_standard_id           in     com_api_type_pkg.t_tiny_id
  , i_message_type          in     com_api_type_pkg.t_dict_value
  , i_is_incoming           in     com_api_type_pkg.t_boolean
  , i_reason_code           in     com_api_type_pkg.t_dict_value
  , i_respond_due_date      in     com_api_type_pkg.t_tiny_id       default null
  , i_resolve_due_date      in     com_api_type_pkg.t_tiny_id       default null
  , i_usage_code            in     com_api_type_pkg.t_boolean       default null
  , io_seqnum               in out com_api_type_pkg.t_seqnum
  , i_mask_error            in     com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
) is
begin
    trc_log_pkg.debug(
        i_text       => 'dsp_ui_due_date_limit_pkg.modify ' || i_id || ' with standard_id [#1], message_type [#2], is_incoming [#3], reason_code [#4], respond_due_date [#5], resolve_due_date [#6]'
      , i_env_param1 => i_standard_id
      , i_env_param2 => i_message_type
      , i_env_param3 => i_is_incoming
      , i_env_param4 => i_reason_code
      , i_env_param5 => i_respond_due_date
      , i_env_param6 => i_resolve_due_date
    );
    io_seqnum := io_seqnum + 1;

    update dsp_due_date_limit
       set standard_id      = i_standard_id
         , message_type     = i_message_type
         , is_incoming      = i_is_incoming
         , reason_code      = i_reason_code
         , respond_due_date = i_respond_due_date
         , resolve_due_date = i_resolve_due_date
         , usage_code       = i_usage_code
         , seqnum           = nvl(io_seqnum, seqnum)
     where id = i_id;
    
exception
    when dup_val_on_index then
        if i_mask_error = com_api_const_pkg.TRUE then
            trc_log_pkg.warn(
                i_text       => 'DSP_DUE_DATE_EXISTS'
              , i_env_param1 => i_standard_id
              , i_env_param2 => i_message_type
              , i_env_param3 => i_is_incoming
              , i_env_param4 => i_reason_code
              , i_env_param5 => i_usage_code
            );
        else
            com_api_error_pkg.raise_error(
                i_error      => 'DSP_DUE_DATE_EXISTS'
              , i_env_param1 => i_standard_id
              , i_env_param2 => i_message_type
              , i_env_param3 => i_is_incoming
              , i_env_param4 => i_reason_code
              , i_env_param5 => i_usage_code
            );
        end if;
end modify;

procedure remove(
    i_id                    in     com_api_type_pkg.t_tiny_id  
) is
begin
    trc_log_pkg.debug(
        i_text       => 'dsp_ui_due_date_limit_pkg.remove [#1]'
      , i_env_param1 => i_id
    );

    delete from dsp_due_date_limit
     where id = i_id;

    trc_log_pkg.debug(
        i_text       => 'removed [#1]'
      , i_env_param1 => sql%rowcount
    );
end remove;

end dsp_ui_due_date_limit_pkg;
/
