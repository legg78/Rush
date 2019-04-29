create or replace package body ost_ui_agent_pkg as
/*********************************************************
 * Provides an user interface for managing agents. <br>
 * Created by Filimonov A.(filimonov@bpc.ru)  at 21.09.2009  <br>
 * Last changed by $Author$ <br>
 * $LastChangedDate::                           $  <br>
 * Revision: $LastChangedRevision$ <br>
 * Module: OST_UI_AGENT_PKG <br>
 * @headcom
 **********************************************************/

procedure add_agent(
    o_agent_id             out  com_api_type_pkg.t_agent_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_agent_type        in      com_api_type_pkg.t_dict_value
  , i_name              in      com_api_type_pkg.t_short_desc
  , i_description       in      com_api_type_pkg.t_full_desc        default null
  , i_lang              in      com_api_type_pkg.t_dict_value       default null
  , i_parent_agent_id   in      com_api_type_pkg.t_agent_id
  , i_is_default        in      com_api_type_pkg.t_boolean          default com_api_type_pkg.FALSE
  , i_agent_number      in      com_api_type_pkg.t_name             default null
  , i_refresh_matview   in      com_api_type_pkg.t_boolean          default null
) is
    l_agent_id          com_api_type_pkg.t_agent_id;
    l_user_id           com_api_type_pkg.t_agent_id;    
    l_is_default        com_api_type_pkg.t_boolean := i_is_default;
    l_parent_agent_type com_api_type_pkg.t_dict_value;
    l_count             pls_integer;
    l_is_entirely       com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE;
    l_agent_user_id     com_api_type_pkg.t_agent_id;
    l_agent_number      com_api_type_pkg.t_name;
    
begin
    if l_is_default = com_api_type_pkg.TRUE then
        begin
            select id
              into l_agent_id
              from ost_agent_vw
             where inst_id = i_inst_id
               and is_default = com_api_type_pkg.TRUE;

            update ost_agent_vw
               set is_default = com_api_type_pkg.FALSE
             where id = l_agent_id;
        exception
            when no_data_found then
                null;
        end;
    else
        select count(1)
          into l_count
          from ost_agent_vw
         where inst_id = i_inst_id;

        if l_count = 0 then
            l_is_default := com_api_type_pkg.TRUE;
        end if;
    end if;

    if i_parent_agent_id is not null then
        begin
            select agent_type
              into l_parent_agent_type
              from ost_agent_vw
             where id = i_parent_agent_id;

        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error             => 'PARENT_AGENT_NOT_FOUND'
                  , i_env_param1        => i_parent_agent_id
                );
        end;
    end if;

    select count(1)
      into l_count
      from ost_agent_type_tree_vw a
     where a.agent_type = i_agent_type
       and ((a.parent_agent_type is null and l_parent_agent_type is null)
             or a.parent_agent_type = l_parent_agent_type);

    if l_count = 0 then
        com_api_error_pkg.raise_error(
            i_error             => 'AGENT_TYPE_INCONSISTENT_WITH_PARENT_AGENT'
          , i_env_param1        => i_agent_type
          , i_env_param2        => l_parent_agent_type
        );
    end if;

    o_agent_id := ost_agent_seq.nextval;
    
    if i_name is not null then
    
        select count(1)
          into l_count 
          from ost_ui_agent_vw
         where id     != o_agent_id
           and inst_id = i_inst_id
           and name    = i_name;
           
        if l_count > 0 then 
            com_api_error_pkg.raise_error(
               i_error       =>  'DESCRIPTION_IS_NOT_UNIQUE' 
             , i_env_param1  => upper('ost_agent')
             , i_env_param2  => upper('name')
             , i_env_param3  => i_name
            );
        end if;
            
        com_api_i18n_pkg.add_text(
            i_table_name    => 'ost_agent'
          , i_column_name   => 'name'
          , i_object_id     => o_agent_id
          , i_lang          => i_lang
          , i_text          => i_name
        );
    end if;

    if i_description is not null then
        com_api_i18n_pkg.add_text(
            i_table_name    => 'ost_agent'
          , i_column_name   => 'description'
          , i_object_id     => o_agent_id
          , i_lang          => i_lang
          , i_text          => i_description
        );
    end if;    

    if i_agent_number is not null then
        l_agent_number := i_agent_number;
    else
        trc_log_pkg.debug(
            i_text       => 'Generating agent_number, o_agent_id [#1], i_inst_id [#2]'
          , i_env_param1 => o_agent_id
          , i_env_param2 => i_inst_id
        );

        l_agent_number:= ost_api_agent_pkg.generate_agent_number(
                               i_agent_id          => o_agent_id 
                             , i_inst_id           => i_inst_id
                             , i_eff_date          => com_api_sttl_day_pkg.get_sysdate()
                           );
    end if;
    
    insert into ost_agent_vw(
        id
      , parent_id
      , agent_type
      , inst_id
      , is_default
      , seqnum
      , agent_number
    ) values (
        o_agent_id
      , i_parent_agent_id
      , i_agent_type
      , i_inst_id
      , l_is_default
      , 1
      , l_agent_number
    );

    begin
        select is_entirely
          into l_is_entirely  
          from acm_user_inst
         where user_id = get_user_id
           and inst_id = i_inst_id;
    exception
        when no_data_found then
            l_is_entirely := com_api_type_pkg.TRUE;           
    end;
    
    if l_is_entirely = com_api_type_pkg.FALSE then
        acm_ui_user_pkg.add_agent_to_user (
            i_user_id     => get_user_id
          , i_agent_id    => o_agent_id
          , i_is_def      => com_api_type_pkg.FALSE
          , io_id         => l_agent_user_id
          , i_force       => com_api_type_pkg.FALSE
        );    
    end if;
      
    if nvl(i_refresh_matview, com_api_type_pkg.TRUE) = com_api_type_pkg.TRUE then
        commit;
        acm_ui_user_pkg.refresh_mview;
    end if;
exception
    when dup_val_on_index then
            com_api_error_pkg.raise_error(
               i_error       => 'DUPLICATE_AGENT_NUMBER'
             , i_env_param1  => i_agent_number
             , i_env_param2  => i_inst_id
            );
    when others then
        trc_log_pkg.debug (
                    i_text          => sqlerrm || ' i_inst_id=' || i_inst_id
                );
        raise;                
end;

procedure modify_agent(
    i_agent_id        in      com_api_type_pkg.t_agent_id
  , i_name            in      com_api_type_pkg.t_short_desc       default null
  , i_description     in      com_api_type_pkg.t_full_desc        default null
  , i_lang            in      com_api_type_pkg.t_dict_value       default null
  , i_parent_agent_id in      com_api_type_pkg.t_agent_id
  , i_is_default      in      com_api_type_pkg.t_boolean
  , i_seqnum          in      com_api_type_pkg.t_seqnum
  , i_agent_number    in      com_api_type_pkg.t_name             default null
  , i_refresh_matview in      com_api_type_pkg.t_boolean          default null
) is
    l_agent_id          com_api_type_pkg.t_agent_id;
    l_is_default        com_api_type_pkg.t_boolean := i_is_default;
    l_agent_type        com_api_type_pkg.t_dict_value;
    l_parent_agent_type com_api_type_pkg.t_dict_value;
    l_inst_id           com_api_type_pkg.t_inst_id;
    l_count             pls_integer;
begin

    begin
        select agent_type
             , inst_id
          into l_agent_type
             , l_inst_id
          from ost_agent_vw
         where id = i_agent_id;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error             => 'AGENT_NOT_FOUND'
              , i_env_param1        => i_agent_id
            );
    end;

    if i_parent_agent_id is not null then
        begin
            select agent_type
              into l_parent_agent_type
              from ost_agent_vw
             where id = i_parent_agent_id;

        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error             => 'PARENT_AGENT_NOT_FOUND'
                  , i_env_param1        => i_parent_agent_id
                );
        end;
    end if;

    select count(1)
      into l_count
      from ost_agent_type_tree_vw a
     where a.agent_type = l_agent_type
       and ((a.parent_agent_type is null and l_parent_agent_type is null)
             or a.parent_agent_type = l_parent_agent_type);

    if l_count = 0 then
        com_api_error_pkg.raise_error(
            i_error             => 'AGENT_TYPE_INCONSISTENT_WITH_PARENT_AGENT'
          , i_env_param1        => l_agent_type
          , i_env_param2        => l_parent_agent_type
        );
    end if;

    if l_is_default = com_api_type_pkg.TRUE then
        begin
            select id
              into l_agent_id
              from ost_agent_vw
             where inst_id = l_inst_id
               and is_default = com_api_type_pkg.TRUE;

            if l_agent_id != i_agent_id then
                update ost_agent_vw
                   set is_default = com_api_type_pkg.FALSE
                 where id = l_agent_id;
            end if;
        exception
            when no_data_found then
                null;
        end;
    else
        select count(1)
          into l_count
          from ost_agent_vw
         where inst_id = l_inst_id;

        if l_count = 1 then
            l_is_default := com_api_type_pkg.TRUE;
        end if;
    end if;

    update ost_agent_vw
       set parent_id    = i_parent_agent_id
         , is_default   = l_is_default
         , seqnum       = i_seqnum
         , agent_number = coalesce(i_agent_number, agent_number)
     where id         = i_agent_id;

    if i_name is not null then
        select count(1)
          into l_count 
          from ost_ui_agent_vw
         where id     != i_agent_id
           and inst_id = l_inst_id
           and name    = i_name;
           
        if l_count > 0 then 
            com_api_error_pkg.raise_error(
               i_error       =>  'DESCRIPTION_IS_NOT_UNIQUE'
             , i_env_param1  => upper('ost_agent')
             , i_env_param2  => upper('name')
             , i_env_param3  => i_name
            );
        end if;
            
        com_api_i18n_pkg.add_text(
            i_table_name    => 'ost_agent'
          , i_column_name   => 'name'
          , i_object_id     => i_agent_id
          , i_lang          => i_lang
          , i_text          => i_name
        );
    end if;

    if i_description is not null then
        com_api_i18n_pkg.add_text(
            i_table_name    => 'ost_agent'
          , i_column_name   => 'description'
          , i_object_id     => i_agent_id
          , i_lang          => i_lang
          , i_text          => i_description
        );
    end if;

    if nvl(i_refresh_matview, com_api_type_pkg.TRUE) = com_api_type_pkg.TRUE then
        commit;
        acm_ui_user_pkg.refresh_mview;
    end if;
exception
    when dup_val_on_index then
            com_api_error_pkg.raise_error(
               i_error       => 'DUPLICATE_AGENT_NUMBER'
             , i_env_param1  => i_agent_number
             , i_env_param2  => l_inst_id
            );
end;

procedure remove_agent(
    i_agent_id in com_api_type_pkg.t_agent_id
  , i_seqnum   in com_api_type_pkg.t_seqnum
) is
    l_count             pls_integer;
    l_inst_id           com_api_type_pkg.t_inst_id;
    l_id                com_api_type_pkg.t_medium_id;
begin

    select is_default
         , inst_id
      into l_count
         , l_inst_id 
      from ost_agent_vw
     where id = i_agent_id;
    
    if l_count > 0 then
        com_api_error_pkg.raise_error(
            i_error             => 'AGENT_IS_SET_AS_DEFAULT'
          , i_env_param1        => i_agent_id
          , i_env_param2        => get_agent_name(i_agent_id, get_user_lang)
          , i_env_param3        => l_inst_id
        );
    end if;

    select count(1)
      into l_count 
      from ost_agent_vw
     where parent_id = i_agent_id;
     
    if l_count > 0 then
        com_api_error_pkg.raise_error(
            i_error             => 'AGENT_HAS_SUBORDINATE_AGENT'
        );
    end if;
    
    
    select count(1)
      into l_count
      from acc_account_vw
     where agent_id = i_agent_id;

    if l_count > 0 then
        com_api_error_pkg.raise_error(
            i_error      => 'AGENT_HAS_ACCOUNT'
          , i_env_param1 => i_agent_id
        );
    end if;

    update ost_agent_vw
       set seqnum = i_seqnum
     where id     = i_agent_id;
    
    delete from ost_agent_vw
     where id = i_agent_id;

    com_api_i18n_pkg.remove_text(
        i_table_name    => 'ost_agent'
      , i_object_id     => i_agent_id
    );

 
    select count(1), max(address_id)
      into l_count, l_id
      from com_address_object_vw 
     where object_id= i_agent_id
       and entity_type = ost_api_const_pkg.ENTITY_TYPE_AGENT;

   
    if l_count > 0 then
       if l_count=1 then
          com_api_address_pkg.remove_address(i_address_id => l_id);
       end if;

       delete com_address_object_vw
        where object_id = i_agent_id
          and entity_type = ost_api_const_pkg.ENTITY_TYPE_AGENT;

    end if;

    select count(1), max(contact_id)
      into l_count, l_id
      from com_contact_object_vw 
     where object_id = i_agent_id
       and entity_type = ost_api_const_pkg.ENTITY_TYPE_AGENT;

    if l_count > 0 then
       if l_count = 1 then
           com_api_contact_pkg.remove_contact(i_contact_id => l_id);

       end if;
       
       delete com_contact_object_vw
        where object_id = i_agent_id
          and entity_type = ost_api_const_pkg.ENTITY_TYPE_AGENT;
    end if;      

    select count(1)
      into l_count
      from ntb_note_vw 
     where object_id= i_agent_id
      and entity_type = ost_api_const_pkg.ENTITY_TYPE_AGENT;

    
    if l_count > 0 then
        for note in (select id from ntb_note_vw 
                              where object_id= i_agent_id
                                and entity_type = ost_api_const_pkg.ENTITY_TYPE_AGENT )
            loop
                delete from ntb_note_vw
                  where id = note.id;
              
                 com_api_i18n_pkg.remove_text(
                  i_table_name        => 'ntb_note'
                  , i_object_id       => note.id);
                  
            end loop;                                
        
    end if;
    
    acm_ui_user_pkg.refresh_mview;    
       
end;

function get_agent_name(
    i_agent_id in com_api_type_pkg.t_agent_id
  , i_lang     in com_api_type_pkg.t_dict_value default null
) return com_api_type_pkg.t_name
  result_cache
is
begin
    return
        com_api_i18n_pkg.get_text(
            i_table_name    => 'ost_agent'
          , i_column_name   => 'name'
          , i_object_id     => i_agent_id
          , i_lang          => i_lang
        );
end;

function get_agent_number(
    i_agent_id          in      com_api_type_pkg.t_agent_id
) return com_api_type_pkg.t_name
is
l_result            com_api_type_pkg.t_name;
begin
    select agent_number 
      into l_result
      from ost_agent
     where id = i_agent_id;
     
     return l_result;
exception
    when no_data_found then 
        trc_log_pkg.debug (
                    i_text          => sqlerrm
        );
        return null;                  
end;

end;
/
