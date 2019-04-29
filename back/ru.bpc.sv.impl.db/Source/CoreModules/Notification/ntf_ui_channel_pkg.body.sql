create or replace package body ntf_ui_channel_pkg is
/********************************************************* 
 *  UI for notification channels <br /> 
 *  Created by Kopachev D.(kopachev@bpcbt.com)  at 16.09.2010 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module: ntf_ui_channel_pkg <br /> 
 *  @headcom 
 **********************************************************/ 
procedure add_channel (
    o_id                  out  com_api_type_pkg.t_tiny_id
  , i_address_pattern  in      com_api_type_pkg.t_name
  , i_mess_max_length  in      com_api_type_pkg.t_tiny_id
  , i_address_source   in      com_api_type_pkg.t_full_desc
  , i_lang             in      com_api_type_pkg.t_dict_value
  , i_name             in      com_api_type_pkg.t_name
  , i_description      in      com_api_type_pkg.t_full_desc
) is
begin
    o_id := ntf_channel_seq.nextval;
    insert into ntf_channel_vw (
        id
      , address_pattern
      , mess_max_length
      , address_source
    ) values (
        o_id
      , i_address_pattern
      , i_mess_max_length
      , i_address_source
    );
        
    com_api_i18n_pkg.add_text(
        i_table_name   =>  'ntf_channel' 
      , i_column_name  =>  'name' 
      , i_object_id    =>   o_id
      , i_lang         =>  i_lang
      , i_text         =>  i_name
    );
        
    com_api_i18n_pkg.add_text(
        i_table_name   => 'ntf_channel' 
      , i_column_name  => 'description' 
      , i_object_id    => o_id
      , i_lang         => i_lang
      , i_text         => i_description
    );
end;

procedure modify_channel (
    i_id               in     com_api_type_pkg.t_tiny_id
  , i_address_pattern  in     com_api_type_pkg.t_name
  , i_mess_max_length  in     com_api_type_pkg.t_tiny_id
  , i_address_source   in     com_api_type_pkg.t_full_desc
  , i_lang             in     com_api_type_pkg.t_dict_value
  , i_name             in     com_api_type_pkg.t_name
  , i_description      in     com_api_type_pkg.t_full_desc
) is
begin
    update ntf_channel_vw
       set address_pattern = i_address_pattern
         , mess_max_length = i_mess_max_length
         , address_source  = i_address_source
     where id              = i_id;
            
    com_api_i18n_pkg.add_text(
        i_table_name   => 'ntf_channel' 
      , i_column_name  => 'name' 
      , i_object_id    => i_id
      , i_lang         => i_lang
      , i_text         => i_name
    );
    com_api_i18n_pkg.add_text(
        i_table_name   => 'ntf_channel' 
      , i_column_name  => 'description' 
      , i_object_id    => i_id
      , i_lang         => i_lang
      , i_text         => i_description
    );
end;

procedure remove_channel (
    i_id               in        com_api_type_pkg.t_tiny_id
) is
    l_count    com_api_type_pkg.t_long_id;
begin
    select count(1)
      into l_count
      from(select id from ntf_custom_event_vw where channel_id = i_id
           union all
           select id from ntf_message_vw where channel_id = i_id
           union all
           select id from ntf_scheme_event_vw where channel_id = i_id
           union all
           select id from ntf_template_vw where channel_id = i_id);

    if l_count > 0 then
        com_api_error_pkg.raise_error(
            i_error      => 'NOTIFICATION_CHANNEL_ALREADY_USED'
          , i_env_param1 => i_id
        );
    
    end if;

    com_api_i18n_pkg.remove_text(
        i_table_name  => 'ntf_channel' 
      , i_object_id   => i_id
    );
        
    delete from ntf_channel_vw
     where id = i_id;
end;

end; 
/
