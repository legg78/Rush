create or replace package body ntf_ui_template_pkg is
/********************************************************* 
 *  Interface for notification templates  <br /> 
 *  Created by Kopachev D.(kopachev@bpcbt.com)  at 28.07.2010 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module: ntf_ui_template_pkg <br /> 
 *  @headcom 
 **********************************************************/ 
procedure add_template (
    o_id                     out  com_api_type_pkg.t_short_id
  , o_seqnum                 out  com_api_type_pkg.t_seqnum
  , i_notif_id            in      com_api_type_pkg.t_tiny_id
  , i_channel_id          in      com_api_type_pkg.t_tiny_id
  , i_lang                in      com_api_type_pkg.t_dict_value
  , i_report_template_id  in      com_api_type_pkg.t_short_id
) is
begin
    o_id     := ntf_template_seq.nextval; 
    o_seqnum := 1;
        
    insert into ntf_template_vw (
        id
      , seqnum
      , notif_id
      , channel_id
      , lang
      , report_template_id
    ) values (
        o_id
      , o_seqnum
      , i_notif_id
      , i_channel_id
      , i_lang
      , i_report_template_id
    );
        
exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error(
            i_error             => 'NOTIFICATION_TEMPLATE_ALREADY_EXIST'
          , i_env_param1        => i_notif_id
          , i_env_param2        => com_api_i18n_pkg.get_text('ntf_channel', 'name', i_channel_id)
          , i_env_param3        => i_lang
        );
end;

procedure modify_template (
    i_id                  in      com_api_type_pkg.t_short_id
  , io_seqnum             in out  com_api_type_pkg.t_seqnum
  , i_report_template_id  in      com_api_type_pkg.t_short_id
) is
begin
    update ntf_template_vw
       set seqnum             = io_seqnum
         , report_template_id = i_report_template_id
     where id                 = i_id;
            
    io_seqnum := io_seqnum + 1;
end;

procedure remove_template (
    i_id                  in      com_api_type_pkg.t_short_id
  , i_seqnum              in      com_api_type_pkg.t_seqnum
) is
    l_count   com_api_type_pkg.t_long_id;
begin
    select count(1)
      into l_count
      from ntf_template t
         , ntf_scheme_event e
     where t.notif_id = e.notif_id
       and t.channel_id = e.channel_id
       and t.id       = i_id;
       
    if l_count > 0 then
        com_api_error_pkg.raise_error(
            i_error      => 'NTF_TEMPLATE_USED'
          , i_env_param1 => i_id
        );
    end if;     
      
    update ntf_template_vw
       set seqnum = i_seqnum
     where id     = i_id;
            
    delete from ntf_template_vw
     where id     = i_id;
end;

end; 
/
