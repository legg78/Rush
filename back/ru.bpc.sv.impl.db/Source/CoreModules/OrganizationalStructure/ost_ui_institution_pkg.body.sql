create or replace package body ost_ui_institution_pkg as
/*********************************************************
*  UI for institution <br />
*  Created by Filimonov A.(filimonov@bpcbt.com)  at 09.09.2009 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: OST_UI_INSTITUTION_PKG <br />
*  @headcom
**********************************************************/
procedure add_institution(
    i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_name              in      com_api_type_pkg.t_name
  , i_parent_inst_id    in      com_api_type_pkg.t_inst_id
  , i_inst_type         in      com_api_type_pkg.t_dict_value
  , i_network_id        in      com_api_type_pkg.t_inst_id      default null
  , i_description       in      com_api_type_pkg.t_full_desc    default null
  , i_lang              in      com_api_type_pkg.t_dict_value   default null
  , i_refresh_matview   in      com_api_type_pkg.t_boolean      default null
  , i_participant_type  in      com_api_type_pkg.t_dict_value   default null
  , i_inst_number       in      com_api_type_pkg.t_mcc          default null
  , i_status            in      com_api_type_pkg.t_dict_value   default null
  , o_seqnum               out  com_api_type_pkg.t_seqnum
) is
    l_count           com_api_type_pkg.t_long_id;
    l_id              com_api_type_pkg.t_long_id;
    l_seqnum          com_api_type_pkg.t_seqnum;
begin
    if i_inst_id = ost_api_const_pkg.DEFAULT_INST 
    or i_inst_number = to_char(ost_api_const_pkg.DEFAULT_INST, com_api_const_pkg.XML_NUMBER_FORMAT) then
        com_api_error_pkg.raise_error(
            i_error => 'NOT_ADD_DEF_INST'
        );
    end if;

    select count(1)
      into l_count
      from ost_institution_vw
     where institution_number = i_inst_number;

    if l_count > 0 then
        com_api_error_pkg.raise_error(
            i_error      => 'DUPLICATE_INST_NUMBER'
          , i_env_param1 => i_inst_number
        );
    end if;

    o_seqnum := 1;

    begin
        insert into ost_institution_vw(
            id
          , parent_id
          , network_id
          , inst_type
          , institution_number
          , seqnum
          , status
        ) values (
            i_inst_id
          , i_parent_inst_id
          , i_network_id
          , i_inst_type
          , nvl(i_inst_number, i_inst_id)
          , o_seqnum
          , i_status
        );
    exception
        when dup_val_on_index then
            com_api_error_pkg.raise_error(
                i_error         => 'DUPLICATE_INSTITUTION_ID'
              , i_env_param1    => i_inst_id
            );
    end;

    if i_network_id is not null then
        select count(1)
          into l_count
          from net_member_vw
         where inst_id    = i_inst_id
           and network_id = i_network_id;

        if l_count = 0 then
            if i_participant_type is not null then
                net_ui_member_pkg.add_host(
                    o_id                   => l_id
                  , o_seqnum               => l_seqnum
                  , i_inst_id              => i_inst_id
                  , i_network_id           => i_network_id
                  , i_online_standard_id   => null
                  , i_offline_standard_id  => null
                  , i_participant_type     => i_participant_type
                  , i_status               => null
                  , i_lang                 => i_lang
                  , i_description          => i_description
                );
            else
                net_ui_member_pkg.add(
                    o_id                   => l_id
                  , o_seqnum               => l_seqnum
                  , i_inst_id              => i_inst_id
                  , i_network_id           => i_network_id
                );
            end if;
        end if;
    end if;

    if i_name is not null then
        com_api_i18n_pkg.add_text(
            i_table_name    => 'ost_institution'
          , i_column_name   => 'name'
          , i_object_id     => i_inst_id
          , i_lang          => i_lang
          , i_text          => i_name
          , i_check_unique  => com_api_type_pkg.TRUE
        );
    end if;

    if i_description is not null then
        com_api_i18n_pkg.add_text(
            i_table_name    => 'ost_institution'
          , i_column_name   => 'description'
          , i_object_id     => i_inst_id
          , i_lang          => i_lang
          , i_text          => i_description
        );
    end if;
    
    if nvl(i_refresh_matview, com_api_type_pkg.TRUE) = com_api_type_pkg.TRUE then
        commit;
        acm_ui_user_pkg.refresh_mview;
    end if;
end;

procedure modify_institution(
    i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_name              in      com_api_type_pkg.t_name
  , i_parent_inst_id    in      com_api_type_pkg.t_inst_id
  , i_inst_type         in      com_api_type_pkg.t_dict_value
  , i_network_id        in      com_api_type_pkg.t_inst_id      default null 
  , i_description       in      com_api_type_pkg.t_full_desc    default null
  , i_lang              in      com_api_type_pkg.t_dict_value   default null
  , i_refresh_matview   in      com_api_type_pkg.t_boolean      default null
  , i_participant_type  in      com_api_type_pkg.t_dict_value   default null
  , i_inst_number       in      com_api_type_pkg.t_mcc          default null
  , i_status            in      com_api_type_pkg.t_dict_value   default null
  , io_seqnum           in out  com_api_type_pkg.t_seqnum
) is
    l_count           com_api_type_pkg.t_long_id;
    l_id              com_api_type_pkg.t_long_id;
    l_seqnum          com_api_type_pkg.t_seqnum;
begin
    if i_inst_number = to_char(ost_api_const_pkg.DEFAULT_INST, com_api_const_pkg.XML_NUMBER_FORMAT) then
        com_api_error_pkg.raise_error(
            i_error => 'NOT_ADD_DEF_INST'
        );
    end if;

    begin
        update ost_institution_vw
           set parent_id          = i_parent_inst_id
             , network_id         = i_network_id
             , inst_type          = i_inst_type
             , seqnum             = io_seqnum
             , institution_number = nvl(i_inst_number, institution_number)
             , status             = nvl(i_status, status)
         where id                 = i_inst_id;
    exception
        when dup_val_on_index then
            com_api_error_pkg.raise_error(
                i_error      => 'DUPLICATE_INST_NUMBER'
              , i_env_param1 => i_inst_number
            );
    end;

    if i_network_id is not null then
        select count(1)
          into l_count
          from net_member_vw
         where inst_id    = i_inst_id
           and network_id = i_network_id
           and (i_participant_type is null
                or i_participant_type is not null
                    and participant_type is not null
               );

        if l_count = 0 then
            if i_participant_type is not null then
                net_ui_member_pkg.add_host(
                    o_id                   => l_id
                  , o_seqnum               => l_seqnum
                  , i_inst_id              => i_inst_id
                  , i_network_id           => i_network_id
                  , i_online_standard_id   => null
                  , i_offline_standard_id  => null
                  , i_participant_type     => i_participant_type
                  , i_status               => null
                  , i_lang                 => i_lang
                  , i_description          => i_description
                );
            else
                net_ui_member_pkg.add(
                    o_id                   => l_id
                  , o_seqnum               => l_seqnum
                  , i_inst_id              => i_inst_id
                  , i_network_id           => i_network_id
                );
            end if;
        end if;
    end if;

    io_seqnum := io_seqnum + 1;

    if i_name is not null then
        com_api_i18n_pkg.add_text(
            i_table_name    => 'ost_institution'
          , i_column_name   => 'name'
          , i_object_id     => i_inst_id
          , i_lang          => i_lang
          , i_text          => i_name
          , i_check_unique  => com_api_type_pkg.TRUE
        );
    end if;

    if i_description is not null then
        com_api_i18n_pkg.add_text(
            i_table_name    => 'ost_institution'
          , i_column_name   => 'description'
          , i_object_id     => i_inst_id
          , i_lang          => i_lang
          , i_text          => i_description
        );
    end if;

    if nvl(i_refresh_matview, com_api_type_pkg.FALSE) = com_api_type_pkg.TRUE then
        commit;
        acm_ui_user_pkg.refresh_mview;
    end if;
end;

procedure remove_institution(
    i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_seqnum            in      com_api_type_pkg.t_seqnum
) is
    l_count   com_api_type_pkg.t_short_id;
    l_id      com_api_type_pkg.t_medium_id;    
begin
    select sum(cnt)
      into l_count
      from (
        select count(id) cnt from com_contact_object cco1
         where entity_type = ost_api_const_pkg.ENTITY_TYPE_INSTITUTION and object_id = i_inst_id
           and (select count(1) from com_contact_object cco2 where cco2.id= cco1.id )>1
         union all
        select count(id) cnt from com_address_object cao1
         where entity_type = ost_api_const_pkg.ENTITY_TYPE_INSTITUTION and object_id = i_inst_id
           and (select count(1) from com_address_object cao2 where cao2.id= cao1.id )>1
         union all
        select count(id) cnt from prd_attribute_value
         where entity_type = ost_api_const_pkg.ENTITY_TYPE_INSTITUTION and object_id = i_inst_id
         union all
        select count(id) cnt from acc_account     where inst_id   = i_inst_id union all
        select count(id) cnt from ost_agent       where inst_id   = i_inst_id union all
        select count(id) cnt from ost_institution where parent_id = i_inst_id union all
        select count(id) cnt from acm_user_inst   where inst_id   = i_inst_id union all
        select count(id) cnt from acm_user        where inst_id   = i_inst_id union all
        select count(id) cnt from net_member      where inst_id   = i_inst_id

    );

    if l_count > 0 then
        com_api_error_pkg.raise_error(
            i_error       => 'CANNOT_DELETE_INSTITUTION'
          , i_env_param1  => ost_ui_institution_pkg.get_inst_name(i_inst_id, com_ui_user_env_pkg.get_user_lang)
        );
    end if;

    update ost_institution_vw
       set seqnum = i_seqnum
     where id     = i_inst_id;

    delete from ost_institution_vw where id = i_inst_id;

    com_api_i18n_pkg.remove_text(
        i_table_name    => 'ost_institution'
      , i_object_id     => i_inst_id
    );

    select count(1), max(address_id)
      into l_count, l_id
      from com_address_object_vw 
     where object_id= i_inst_id
       and entity_type = ost_api_const_pkg.ENTITY_TYPE_INSTITUTION;

   
    if l_count > 0 then
       if l_count=1 then
          com_api_address_pkg.remove_address(i_address_id => l_id);
       end if;

       delete com_address_object_vw
        where object_id = i_inst_id
          and entity_type = ost_api_const_pkg.ENTITY_TYPE_INSTITUTION;

    end if;

    select count(1), max(contact_id)
      into l_count, l_id
      from com_contact_object_vw 
     where object_id = i_inst_id
       and entity_type = ost_api_const_pkg.ENTITY_TYPE_INSTITUTION;

    if l_count > 0 then
       if l_count = 1 then
           com_api_contact_pkg.remove_contact(i_contact_id => l_id);

       end if;
       
       delete com_contact_object_vw
        where object_id = i_inst_id
          and entity_type = ost_api_const_pkg.ENTITY_TYPE_INSTITUTION;
    end if;      

    select count(1)
      into l_count
      from ntb_note_vw 
     where object_id= i_inst_id
      and entity_type = ost_api_const_pkg.ENTITY_TYPE_INSTITUTION;

    
    if l_count > 0 then
        for note in (select id from ntb_note_vw 
                              where object_id= i_inst_id
                                and entity_type = ost_api_const_pkg.ENTITY_TYPE_INSTITUTION )
            loop
                delete from ntb_note_vw
                  where id = note.id;
              
                 com_api_i18n_pkg.remove_text(
                  i_table_name        => 'ntb_note'
                  , i_object_id       => note.id);
                  
            end loop;                                
        
    end if; 
    
    acm_ui_user_pkg.refresh_mview;
exception
    when no_data_found then
        null;
end;

function get_default_agent(
    i_inst_id           in      com_api_type_pkg.t_inst_id
) return com_api_type_pkg.t_agent_id is
    l_agent_id          com_api_type_pkg.t_agent_id;
begin
    select id
      into l_agent_id
      from ost_agent_vw
     where inst_id = i_inst_id
       and is_default = com_api_type_pkg.TRUE;

    return l_agent_id;
exception
    when no_data_found then
        com_api_error_pkg.raise_error(
            i_error      => 'DEF_AGENT_NOT_FOUND'
          , i_env_param1 => i_inst_id
        );
    when com_api_error_pkg.e_application_error then
        raise;
    when com_api_error_pkg.e_fatal_error then
        raise;
    when others then
        com_api_error_pkg.raise_fatal_error(
            i_error      => 'UNHANDLED_EXCEPTION'
          , i_env_param1 => sqlerrm
        );
end get_default_agent;

function get_inst_name(
    i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_lang              in      com_api_type_pkg.t_dict_value       default null
) return com_api_type_pkg.t_name is
begin
    if i_inst_id = ost_api_const_pkg.DEFAULT_INST then
        return  
            com_api_label_pkg.get_label_text(
                i_name => 'SYS_INST_NAME'
            );  
    else
        return
            com_api_i18n_pkg.get_text(
                i_table_name    => 'ost_institution'
              , i_column_name   => 'name'
              , i_object_id     => i_inst_id
              , i_lang          => i_lang
            );
    end if;
end;

procedure add_inst_address(
    i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_address_id        in      varchar2
  , i_address_type      in      com_api_type_pkg.t_dict_value
  , o_address_object_id    out  com_api_type_pkg.t_long_id
) is
begin
    com_ui_address_pkg.add_address_object(
        i_address_id        => i_address_id
      , i_address_type      => i_address_type
      , i_entity_type       => ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
      , i_object_id         => i_inst_id
      , o_address_object_id => o_address_object_id
    );
end;

procedure add_inst_contact(
    i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_contact_id        in      com_api_type_pkg.t_medium_id
  , o_contact_object_id    out  com_api_type_pkg.t_long_id
) is
begin
    com_ui_contact_pkg.add_contact_object(
        i_contact_id        => i_contact_id
      , i_entity_type       => ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
      , i_contact_type      => 'CNTTPRMC'
      , i_object_id         => i_inst_id
      , o_contact_object_id => o_contact_object_id
    );
end;

function get_inst_address(
    i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_address_type      in      com_api_type_pkg.t_dict_value  := 'ADTPBSNA'
  , i_lang              in      com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_full_desc is
l_result com_api_type_pkg.t_full_desc;
begin
    select com_api_address_pkg.get_address_string(o.address_id, i_lang)
      into l_result
      from com_ui_address_object_vw o
     where o.entity_type  = ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
       and o.object_id    = i_inst_id
       and o.address_type = i_address_type;   

    return l_result;
end;

function get_inst_city(
    i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_address_type      in      com_api_type_pkg.t_dict_value
  , i_lang              in      com_api_type_pkg.t_dict_value
  , i_city_alias        in      com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_name is
    l_result com_api_type_pkg.t_name;
begin
    select nvl2(i_city_alias, i_city_alias || ' ' || city, city)
      into l_result
      from (
            select a.city
              from ost_inst_address_vw  a
             where a.address_type = i_address_type
               and a.inst_id = i_inst_id
             order by decode(a.lang, nvl(i_lang, com_ui_user_env_pkg.get_user_lang), 1, com_api_const_pkg.LANGUAGE_ENGLISH, 2, 3)
            )
     where rownum = 1;
  
    return l_result;
exception
    when no_data_found then
        return null;
end;

procedure add_forbidden_action(
    o_id               out      com_api_type_pkg.t_short_id 
  , i_inst_status   in     com_api_type_pkg.t_dict_value
  , i_data_action   in     com_api_type_pkg.t_dict_value
) is
begin
    o_id := ost_forbidden_action_seq.nextval;
    insert into ost_forbidden_action_vw(
        id
      , inst_status
      , data_action
    ) values(
        o_id
      , i_inst_status
      , i_data_action
    );
    
    exception
        when dup_val_on_index then
            com_api_error_pkg.raise_error(
                i_error        => 'DUPLICATE_DESCRIPTION'
              , i_env_param1   => 'Forbidden action'
              , i_env_param2   => ' data action ['
                               || i_data_action||' ' || get_article_text(i_data_action) 
                               || '] and status '
              , i_env_param3   => i_inst_status
            );
end;

procedure remove_forbidden_action(
    i_id            in     com_api_type_pkg.t_short_id
) is
begin
    delete from ost_forbidden_action_vw
     where id = i_id;
end;

end;
/
