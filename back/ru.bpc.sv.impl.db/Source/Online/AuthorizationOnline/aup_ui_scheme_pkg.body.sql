create or replace package body aup_ui_scheme_pkg as
/********************************************************* 
 *  API for schemes in authorization online processing <br /> 
 *  Created by Filimonov A.(filimonov@bpcbt.com)  at 26.04.2011 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module: aup_ui_scheme_pkg  <br /> 
 *  @headcom 
 **********************************************************/ 
procedure add_scheme(
    o_scheme_id            out  com_api_type_pkg.t_tiny_id
  , o_seqnum               out  com_api_type_pkg.t_seqnum
  , i_scheme_type       in      com_api_type_pkg.t_dict_value
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_resp_code         in      com_api_type_pkg.t_dict_value
  , i_label             in      com_api_type_pkg.t_name
  , i_description       in      com_api_type_pkg.t_full_desc    default null
  , i_lang              in      com_api_type_pkg.t_dict_value   default null
  , i_system_name       in      com_api_type_pkg.t_name
) is
begin
    o_scheme_id := aup_scheme_seq.nextval;
    o_seqnum := 1;
    
    insert into aup_scheme_vw(
        id
      , seqnum
      , scheme_type
      , inst_id
      , scale_id
      , resp_code
      , system_name
    ) values (
        o_scheme_id
      , o_seqnum
      , i_scheme_type
      , i_inst_id
      , 1005
      , i_resp_code
      , i_system_name
    );
    
    com_api_i18n_pkg.add_text(
        i_table_name  => 'aup_scheme'
      , i_column_name => 'label'
      , i_object_id   => o_scheme_id
      , i_lang        => i_lang
      , i_text        => i_label
    );

    com_api_i18n_pkg.add_text(
        i_table_name  => 'aup_scheme'
      , i_column_name => 'description'
      , i_object_id   => o_scheme_id
      , i_lang        => i_lang
      , i_text        => i_description
    );
    
exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error(
            i_error      => 'AUTH_SCHEME_ALREADY_EXISTS'
          , i_env_param1 => i_inst_id
          , i_env_param2 => i_system_name
        );     
end;

procedure modify_scheme(
    i_scheme_id         in      com_api_type_pkg.t_tiny_id
  , io_seqnum           in out  com_api_type_pkg.t_seqnum
  , i_scheme_type       in      com_api_type_pkg.t_dict_value
  , i_resp_code         in      com_api_type_pkg.t_dict_value
  , i_label             in      com_api_type_pkg.t_name
  , i_description       in      com_api_type_pkg.t_full_desc    default null
  , i_lang              in      com_api_type_pkg.t_dict_value   default null
  , i_system_name       in      com_api_type_pkg.t_name
) is
    l_inst_id           com_api_type_pkg.t_tiny_id;
begin
    select inst_id
      into l_inst_id
      from aup_scheme_vw
     where id = i_scheme_id;
     
    update aup_scheme_vw
       set seqnum      = io_seqnum
         , scheme_type = i_scheme_type
         , resp_code   = i_resp_code
         , system_name = i_system_name
     where id          = i_scheme_id;
     
    io_seqnum := io_seqnum + 1;
    
    com_api_i18n_pkg.add_text(
        i_table_name  => 'aup_scheme'
      , i_column_name => 'label'
      , i_object_id   => i_scheme_id
      , i_lang        => i_lang
      , i_text        => i_label
    );

    com_api_i18n_pkg.add_text(
        i_table_name  => 'aup_scheme'
      , i_column_name => 'description'
      , i_object_id   => i_scheme_id
      , i_lang        => i_lang
      , i_text        => i_description
    );

exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error(
            i_error      => 'AUTH_SCHEME_ALREADY_EXISTS'
          , i_env_param1 => l_inst_id
          , i_env_param2 => i_system_name
        );          
end;

procedure remove_scheme(
    i_scheme_id         in      com_api_type_pkg.t_tiny_id
  , i_seqnum            in      com_api_type_pkg.t_seqnum
) is
    l_count             com_api_type_pkg.t_count := 0;
begin

    select count(1)
      into l_count
      from aup_scheme_object_vw
     where scheme_id = i_scheme_id;
     
    if l_count > 0 then
        com_api_error_pkg.raise_error(
            i_error         => 'AUTH_SCHEME_IN_USE'
        );
    end if;
     
    update aup_scheme_vw
       set seqnum      = i_seqnum
     where id          = i_scheme_id;
     
    delete aup_scheme_template_vw
     where scheme_id   = i_scheme_id;

    delete aup_scheme_vw
     where id          = i_scheme_id;
     
    com_api_i18n_pkg.remove_text(
        i_table_name  => 'aup_scheme'
      , i_object_id   => i_scheme_id
    );
   
end;

procedure add_template(
    o_templ_id             out  com_api_type_pkg.t_short_id
  , o_seqnum               out  com_api_type_pkg.t_seqnum
  , i_templ_type        in      com_api_type_pkg.t_dict_value
  , i_resp_code         in      com_api_type_pkg.t_dict_value
  , i_condition         in      com_api_type_pkg.t_text
  , i_lang              in      com_api_type_pkg.t_dict_value
  , i_name              in      com_api_type_pkg.t_name
  , i_description       in      com_api_type_pkg.t_full_desc
) is
    l_mod_id            com_api_type_pkg.t_tiny_id;
    l_seqnum            com_api_type_pkg.t_seqnum;
begin

    rul_ui_mod_pkg.add_mod (
        o_id                => l_mod_id
      , o_seqnum            => l_seqnum
      , i_scale_id          => 1005
      , i_condition         => i_condition
      , i_priority          => null
      , i_lang              => i_lang
      , i_name              => i_name
      , i_description       => i_description
    );

    o_templ_id := aup_auth_template_seq.nextval;
    o_seqnum := 1;
    
    insert into aup_auth_template_vw(
        id
      , seqnum
      , templ_type
      , mod_id
      , resp_code
    ) values (
        o_templ_id
      , o_seqnum
      , i_templ_type
      , l_mod_id
      , i_resp_code
    );
    
end;

procedure modify_template(
    i_templ_id          in      com_api_type_pkg.t_short_id
  , io_seqnum           in out  com_api_type_pkg.t_seqnum
  , i_templ_type        in      com_api_type_pkg.t_dict_value
  , i_resp_code         in      com_api_type_pkg.t_dict_value
  , i_condition         in      com_api_type_pkg.t_text
  , i_lang              in      com_api_type_pkg.t_dict_value
  , i_name              in      com_api_type_pkg.t_name
  , i_description       in      com_api_type_pkg.t_full_desc
) is
    l_mod_id            com_api_type_pkg.t_tiny_id;
    l_seqnum            com_api_type_pkg.t_seqnum;
    l_priority          com_api_type_pkg.t_tiny_id;
begin

    update aup_auth_template_vw
       set seqnum     = io_seqnum
         , templ_type = i_templ_type
         , resp_code  = i_resp_code
     where id         = i_templ_id;

    select b.mod_id
         , a.seqnum
         , a.priority
      into l_mod_id
         , l_seqnum
         , l_priority
      from rul_mod_vw a
         , aup_auth_template_vw b
     where b.mod_id = a.id
       and b.id     = i_templ_id;

    rul_ui_mod_pkg.modify_mod(
        i_id                => l_mod_id
      , io_seqnum           => l_seqnum
      , i_condition         => i_condition
      , i_priority          => l_priority
      , i_lang              => i_lang
      , i_name              => i_name
      , i_description       => i_description
    );

end;

procedure remove_template(
    i_templ_id          in      com_api_type_pkg.t_short_id
  , i_seqnum            in      com_api_type_pkg.t_seqnum
) is
    l_count             com_api_type_pkg.t_count := 0;
    l_mod_id            com_api_type_pkg.t_tiny_id;
    l_seqnum            com_api_type_pkg.t_seqnum;
begin
    select count(1)
      into l_count
      from aup_scheme_template_vw
     where scheme_id = i_templ_id;
     
    if l_count > 0 then
        com_api_error_pkg.raise_error(
            i_error         => 'AUTH_TEMPLATE_IN_USE'
        );
    end if;

    update aup_auth_template_vw
       set seqnum = i_seqnum
     where id     = i_templ_id;

    select b.mod_id
         , a.seqnum
      into l_mod_id
         , l_seqnum
      from rul_mod_vw a
         , aup_auth_template_vw b
     where b.mod_id = a.id
       and b.id     = i_templ_id;

    rul_ui_mod_pkg.remove_mod(
        i_id                => l_mod_id
      , i_seqnum            => l_seqnum
    );
end;

procedure add_scheme_template(
    i_templ_id          in      com_api_type_pkg.t_short_id
  , i_scheme_id         in      com_api_type_pkg.t_tiny_id
) is
begin
    insert into aup_scheme_template_vw(
        scheme_id
      , templ_id
    ) values (
        i_scheme_id
      , i_templ_id
    );
exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error(
            i_error      => 'SCHEME_TEMPLATE_IS_NOT_UNIQUE'
          , i_env_param1 => i_scheme_id
          , i_env_param2 => i_templ_id
        );
end;

procedure remove_scheme_template(
    i_templ_id          in      com_api_type_pkg.t_short_id
  , i_scheme_id         in      com_api_type_pkg.t_tiny_id
) is
begin
    delete from aup_scheme_template_vw
     where scheme_id = i_scheme_id
       and templ_id  = i_templ_id;
end;

procedure add_scheme_object(
    o_scheme_object_id     out  com_api_type_pkg.t_long_id
  , o_seqnum               out  com_api_type_pkg.t_seqnum
  , i_scheme_id         in      com_api_type_pkg.t_tiny_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_start_date        in      date
  , i_end_date          in      date
) is
begin
    -- Check if <i_start_date> is less than <i_end_date>
    aup_api_check_pkg.check_time_period(
        i_start_date => i_start_date
      , i_end_date   => i_end_date
    );

    o_scheme_object_id := com_api_id_pkg.get_id(aup_scheme_object_seq.nextval);
    o_seqnum := 1;
    
    insert into aup_scheme_object_vw(
        id
      , seqnum
      , scheme_id
      , entity_type
      , object_id
      , start_date
      , end_date
    ) values (
        o_scheme_object_id
      , o_seqnum
      , i_scheme_id
      , i_entity_type
      , i_object_id
      , coalesce(i_start_date, com_api_sttl_day_pkg.get_sysdate())
      , i_end_date
    );
exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error(
            i_error      => 'SCHEME_IS_NOT_UNIQUE'
          , i_env_param1 => i_entity_type
          , i_env_param2 => i_object_id
          , i_env_param3 => i_start_date
        );
end;

procedure modify_scheme_object(
    i_scheme_object_id  in      com_api_type_pkg.t_long_id
  , io_seqnum           in out  com_api_type_pkg.t_seqnum
  , i_end_date          in      date
) is
    l_start_date        date;
begin
    begin
        select start_date
          into l_start_date
          from aup_scheme_object_vw
         where id = i_scheme_object_id;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error => 'AUTH_SCHEME_NOT_FOUND'
            );
    end;

    -- Check if <i_start_date> is less than <i_end_date>
    aup_api_check_pkg.check_time_period(
        i_start_date => l_start_date
      , i_end_date   => i_end_date
    );

    update aup_scheme_object_vw
       set seqnum   = io_seqnum
         , end_date = i_end_date
     where id       = i_scheme_object_id;
     
    io_seqnum := io_seqnum + 1;
end;

procedure remove_scheme_object(
    i_scheme_object_id  in      com_api_type_pkg.t_long_id
  , i_seqnum            in      com_api_type_pkg.t_seqnum
) is
begin
    update aup_scheme_object_vw
       set seqnum   = i_seqnum
     where id       = i_scheme_object_id;
    
    delete aup_scheme_object_vw
     where id       = i_scheme_object_id; 
end;

end;
/
