create or replace package body sec_api_passwd_pkg as
/*********************************************************
*  API for generate passwords <br />
*  Created by Kryukov E.(krukov@bpcbt.com)  at 18.02.2013 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: SEC_API_PASSWD_PKG <br />
*  @headcom
**********************************************************/

function generate_otp(
    i_passwd_type         in     com_api_type_pkg.t_dict_value
  , i_length              in     com_api_type_pkg.t_tiny_id    
) return com_api_type_pkg.t_name is
    l_result              com_api_type_pkg.t_name;
begin
    if i_passwd_type = sec_api_const_pkg.PASSWORD_TYPE_ALPHANUM then
        l_result := dbms_random.string('x', i_length);
    elsif i_passwd_type = sec_api_const_pkg.PASSWORD_TYPE_DIGITS then
        l_result := to_char(floor(dbms_random.value(0, power(10, i_length))), 'TM9');
    end if;
    
    return l_result;
end generate_otp;

function generate_otp(
    i_inst_id           in      com_api_type_pkg.t_inst_id
) return com_api_type_pkg.t_name is
    l_passwd_type       com_api_type_pkg.t_dict_value;
    l_length            com_api_type_pkg.t_tiny_id;
    
begin
    l_passwd_type := 
        set_ui_value_pkg.get_inst_param_v(
            i_param_name    => 'PASSWORD_ALGORITHM_TYPE'
          , i_inst_id       => i_inst_id
        );    

    l_length := 
        set_ui_value_pkg.get_inst_param_n(
            i_param_name    => 'PASSWORD_LENGTH'
          , i_inst_id       => i_inst_id
        );    

    return generate_otp(
        i_passwd_type   => l_passwd_type
      , i_length        => l_length  
    );

end generate_otp;

procedure send_onetime_password(
    i_event_type        in      com_api_type_pkg.t_dict_value
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , o_otp                   out com_api_type_pkg.t_name
) is
    l_inst_id           com_api_type_pkg.t_inst_id;
begin

    if i_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD then
        select inst_id
          into l_inst_id
          from iss_card
         where id = i_object_id;
    end if;
    
    ntf_api_notification_pkg.make_notification (
        i_inst_id            => l_inst_id
      , i_event_type         => i_event_type
      , i_entity_type        => i_entity_type
      , i_object_id          => i_object_id
      , i_eff_date           => com_api_sttl_day_pkg.get_sysdate
    );
    
    o_otp := sec_api_notification_pkg.get_otp;
    
    sec_api_notification_pkg.unset_otp;

end;

procedure get_onetime_password(
    i_event_type          in     com_api_type_pkg.t_dict_value
  , i_address             in     com_api_type_pkg.t_full_desc
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_lang                in     com_api_type_pkg.t_dict_value
  , i_otp                 in     com_api_type_pkg.t_name        default null
) is
    l_id                         com_api_type_pkg.t_long_id;
    l_text                       clob;
    l_data_source                clob;
    l_report_id                  com_api_type_pkg.t_short_id;
    l_notif_id                   com_api_type_pkg.t_tiny_id;
    l_template_id                com_api_type_pkg.t_short_id;
    l_params                     com_api_type_pkg.t_param_tab;
    l_resultset                  sys_refcursor;
    l_result                     com_api_type_pkg.t_count := 0;
begin
    select
        min(a.id)
      , min(a.report_id)
      , count(id)
    into
        l_notif_id
      , l_report_id
      , l_result
    from
        ntf_notification_vw a 
    where
        a.event_type = i_event_type
        and a.inst_id = i_inst_id;

    if l_result = 0 then
        com_api_error_pkg.raise_error(
            i_error      => 'NOTIFICATION_NOT_FOUND'
          , i_env_param1 => i_event_type
          , i_env_param2 => i_inst_id);
    end if;

    select
        min(b.report_template_id)
      , count(b.id)
    into
        l_template_id
      , l_result
    from
        ntf_template b
    where
        b.notif_id = l_notif_id
        and b.channel_id = ntf_api_const_pkg.CHANNEL_SMS
        and b.lang = i_lang;

    if l_result = 0 then
        com_api_error_pkg.raise_error(
            i_error      => 'NOTIFICATION_TEMPLATE_NOT_FOUND'
          , i_env_param1 => l_notif_id
          , i_env_param2 => ntf_api_const_pkg.CHANNEL_SMS
          , i_env_param3 => i_lang
        );
    end if;

    select
        a.data_source
    into
        l_data_source
    from
        rpt_report_vw a
    where
        a.id = l_report_id;

     if i_otp is null then
        sec_api_notification_pkg.set_otp(
            i_otp   => generate_otp(i_inst_id)
        );
    else
        sec_api_notification_pkg.set_otp(
            i_otp   => i_otp
        );
    end if;
    
    rul_api_param_pkg.set_param (
        i_name       => 'I_EVENT_TYPE'
        , i_value    => i_event_type
        , io_params  => l_params
    );
    rul_api_param_pkg.set_param (
        i_name       => 'I_LANG'
        , i_value    => i_lang
        , io_params  => l_params
    );
    rul_api_param_pkg.set_param (
        i_name       => 'I_EFF_DATE'
        , i_value    => get_sysdate
        , io_params  => l_params
    );
    rul_api_param_pkg.set_param (
        i_name       => 'I_INST_ID'
        , i_value    => i_inst_id
        , io_params  => l_params
    );

    rpt_api_run_pkg.process_report(
        i_report_id    => l_report_id
      , i_template_id  => l_template_id
      , i_parameters   => l_params
      , i_source_type  => rpt_api_const_pkg.REPORT_SOURCE_XML
      , io_data_source => l_data_source
      , i_lang         => i_lang
      , o_xml          => l_text
      , o_resultset    => l_resultset
    );

    ntf_api_message_pkg.create_message(
        o_id               => l_id
      , i_channel_id       => ntf_api_const_pkg.CHANNEL_SMS
      , i_text             => l_text
      , i_lang             => i_lang
      , i_delivery_address => i_address
      , i_inst_id          => i_inst_id
    );

    trc_log_pkg.debug('saved ntf message with id '|| l_id);
    
    sec_api_notification_pkg.unset_otp;

end get_onetime_password;

procedure send_onetime_password(
    i_card_number          in    com_api_type_pkg.t_card_number
  , i_otp                  in    com_api_type_pkg.t_name
  , o_delivery_address     out   com_api_type_pkg.t_full_desc
)is
    l_inst_id           com_api_type_pkg.t_inst_id;
    l_card_id           com_api_type_pkg.t_medium_id;

begin
    sec_api_notification_pkg.set_otp(i_otp => i_otp);
    
    l_card_id := iss_api_card_pkg.get_card_id(i_card_number => i_card_number);
    
    select inst_id
      into l_inst_id
      from iss_card
     where id = l_card_id;
    
    ntf_api_notification_pkg.make_notification (
        i_inst_id            => l_inst_id
      , i_event_type         => 'EVNT0260'
      , i_entity_type        => iss_api_const_pkg.ENTITY_TYPE_CARD
      , i_object_id          => l_card_id
      , i_eff_date           => com_api_sttl_day_pkg.get_sysdate
    );    
    
    o_delivery_address := ntf_api_notification_pkg.get_gl_delivery_address();
    
end send_onetime_password;


end sec_api_passwd_pkg;
/
