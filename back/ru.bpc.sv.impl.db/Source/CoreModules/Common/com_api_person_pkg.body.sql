create or replace package body com_api_person_pkg as
/*********************************************************
*  API for entity Person <br />
*  Created by Filimonov A.(filimonov@bpc.ru)  at 22.09.2009 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: COM_API_PERSON_PKG <br />
*  @headcom
**********************************************************/
procedure register_customer_event(
    i_person_id  in     com_api_type_pkg.t_long_id
) is
    l_param_tab         com_api_type_pkg.t_param_tab;
    l_count             com_api_type_pkg.t_sign       := 0;
begin
    for rec in (
        select c.id
             , c.inst_id
             , c.split_hash
          from prd_customer c
         where c.entity_type = com_api_const_pkg.ENTITY_TYPE_PERSON
           and c.object_id   = i_person_id
    ) loop
        if l_count = 0 then
            l_count := 1;
        end if;

        evt_api_event_pkg.register_event(
            i_event_type      => prd_api_const_pkg.EVENT_CUSTOMER_MODIFY
          , i_eff_date        => get_sysdate
          , i_entity_type     => prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
          , i_object_id       => rec.id
          , i_inst_id         => rec.inst_id
          , i_split_hash      => rec.split_hash
          , i_param_tab       => l_param_tab
        );
    end loop;

    if l_count = 0 then
        for rec in (
            select h.id
                 , h.inst_id
              from iss_cardholder h
             where h.person_id = i_person_id
        ) loop
            evt_api_event_pkg.register_event(
                i_event_type      => iss_api_const_pkg.EVENT_TYPE_CARDHOLDER_MODIFY
              , i_eff_date        => get_sysdate
              , i_entity_type     => iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
              , i_object_id       => rec.id
              , i_inst_id         => rec.inst_id
              , i_split_hash      => null
              , i_param_tab       => l_param_tab
            );
        end loop;
    end if;
end register_customer_event;

procedure add_person(
    io_person_id        in out  com_api_type_pkg.t_medium_id
  , i_lang              in      com_api_type_pkg.t_dict_value
  , i_person_title      in      com_api_type_pkg.t_dict_value
  , i_first_name        in      com_api_type_pkg.t_name
  , i_second_name       in      com_api_type_pkg.t_name
  , i_surname           in      com_api_type_pkg.t_name
  , i_suffix            in      com_api_type_pkg.t_dict_value
  , i_gender            in      com_api_type_pkg.t_dict_value
  , i_birthday          in      date
  , i_place_of_birth    in      com_api_type_pkg.t_name
  , i_inst_id           in      com_api_type_pkg.t_inst_id
) is
begin

    if io_person_id is null then
        io_person_id := com_person_seq.nextval;
    end if;

    insert into com_person_vw(
        id
      , lang
      , title
      , first_name
      , second_name
      , surname
      , suffix
      , gender
      , birthday
      , place_of_birth
      , seqnum
      , inst_id
    ) values (
        io_person_id
      , nvl(i_lang, com_ui_user_env_pkg.get_user_lang)
      , i_person_title
      , i_first_name
      , i_second_name
      , i_surname
      , i_suffix
      , i_gender
      , i_birthday
      , i_place_of_birth
      , 1
      , get_sandbox(i_inst_id)
    );

end;

procedure modify_person(
    i_person_id         in      com_api_type_pkg.t_medium_id
  , i_person_title      in      com_api_type_pkg.t_dict_value
  , i_first_name        in      com_api_type_pkg.t_name
  , i_second_name       in      com_api_type_pkg.t_name
  , i_surname           in      com_api_type_pkg.t_name
  , i_suffix            in      com_api_type_pkg.t_dict_value
  , i_gender            in      com_api_type_pkg.t_dict_value
  , i_birthday          in      date
  , i_place_of_birth    in      com_api_type_pkg.t_name
  , i_seqnum            in      com_api_type_pkg.t_seqnum
  , i_lang              in      com_api_type_pkg.t_dict_value       default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id
) is
    l_seqnum            com_api_type_pkg.t_seqnum;
    l_lang              com_api_type_pkg.t_dict_value;
begin
    l_lang := coalesce(i_lang, com_ui_user_env_pkg.get_user_lang);
    trc_log_pkg.debug('com_api_person_pkg.modify_person, id='||i_person_id||', lang='||l_lang
                  ||', i_birthday='||i_birthday||', i_suffix='||i_suffix||', i_gender='||i_gender||', i_person_title='||i_person_title
    );
    trc_log_pkg.debug('com_api_person_pkg.modify_person, first_name='||i_first_name
                  ||', second_name='||i_second_name || ' , i_surname='||i_surname );
    begin
        select seqnum
          into l_seqnum
          from com_person_vw
         where id           = i_person_id
           and lang         = l_lang;

        update com_person_vw
           set first_name     = nvl(decode(lang, l_lang, i_first_name, first_name), first_name)
             , second_name    = decode(lang, l_lang, i_second_name, second_name)
             , surname        = nvl(decode(lang, l_lang, i_surname, surname), surname)
             , title          = i_person_title
             , suffix         = nvl(i_suffix, suffix)
             , gender         = nvl(i_gender, gender)
             , birthday       = nvl(i_birthday, birthday)
             , place_of_birth = nvl(i_place_of_birth, place_of_birth)
             , seqnum         = nvl(i_seqnum, seqnum + 1)
         where id             = i_person_id;

        trc_log_pkg.debug('com_api_person_pkg.modify_person: updated '||sql%rowcount||' record(s)');
    exception
        when no_data_found then
            update com_person_vw
               set title          = nvl(i_person_title, title)
                 , suffix         = nvl(i_suffix, suffix)
                 , gender         = nvl(i_gender, gender)
                 , birthday       = nvl(i_birthday, birthday)
                 , place_of_birth = nvl(i_place_of_birth, place_of_birth)
                 , seqnum         = nvl(i_seqnum, seqnum + 1)
             where id             = i_person_id;

            insert into com_person_vw(
                id
              , lang
              , title
              , first_name
              , second_name
              , surname
              , suffix
              , gender
              , birthday
              , place_of_birth
              , seqnum
              , inst_id
            ) values (
                i_person_id
              , l_lang
              , i_person_title
              , i_first_name
              , i_second_name
              , i_surname
              , i_suffix
              , i_gender
              , i_birthday
              , i_place_of_birth
              , nvl(l_seqnum, 0) + 1
              , get_sandbox(i_inst_id)
            );
    end;
    register_customer_event(i_person_id => i_person_id);
end;

procedure remove_person(
    i_person_id         in      com_api_type_pkg.t_medium_id
  , i_seqnum            in      com_api_type_pkg.t_seqnum
) is
begin
    update com_person_vw
       set seqnum      = i_seqnum
     where id          = i_person_id;

    delete from  com_person_vw
     where id          = i_person_id;

    register_customer_event( i_person_id  => i_person_id);
end;

procedure get_person_id(
    i_person        in     com_api_type_pkg.t_person
  , i_identity_card in     com_api_type_pkg.t_identity_card
  , o_person_id        out com_api_type_pkg.t_medium_id
) is
begin

    if i_identity_card.id_type is not null
       and i_identity_card.id_number is not null
    then
        begin
            select object_id
              into o_person_id
              from com_id_object
             where id_type     = i_identity_card.id_type
               and id_number   = i_identity_card.id_number
               and (id_series  = i_identity_card.id_series or (id_series is null and i_identity_card.id_series is null))
               and entity_type = com_api_const_pkg.ENTITY_TYPE_PERSON
               and inst_id     = ost_api_institution_pkg.get_sandbox(i_identity_card.inst_id);
        exception
            when too_many_rows then
                com_api_error_pkg.raise_error(
                    i_error      => 'TOO_MANY_IDS_FOUND'
                  , i_env_param1 =>  i_identity_card.id_type
                  , i_env_param2 =>  i_identity_card.id_number
                  , i_env_param3 =>  i_identity_card.id_series
                );
            when no_data_found then
                null;
        end;
    else
        begin
            select id
              into o_person_id
              from com_person
             where lower(first_name)   = lower(i_person.first_name)
               and lower(surname)      = lower(i_person.surname)
               and (lower(second_name) = lower(i_person.second_name) or (second_name is null and i_person.second_name is null))
               and (trunc(birthday)    = trunc(i_person.birthday) or (birthday is null and i_person.birthday is null))
               and (lower(place_of_birth) = lower(i_person.place_of_birth) or (place_of_birth is null and i_person.place_of_birth is null))
               and inst_id             = ost_api_institution_pkg.get_sandbox(i_person.inst_id)
               and lang                = i_person.lang;
        exception
            when too_many_rows then
                com_api_error_pkg.raise_error(
                    i_error      => 'TOO_MANY_PERSONS_FOUND'
                  , i_env_param1 =>  i_person.surname
                  , i_env_param2 =>  i_person.first_name
                  , i_env_param3 =>  i_person.second_name
                  , i_env_param4 =>  i_person.birthday
                  , i_env_param5 =>  i_person.place_of_birth
                );
            when no_data_found then
                null;
        end;
    end if;

end;

function get_person_age(
    i_birthday          in      date
) return com_api_type_pkg.t_byte_id
is
begin
    
    return trunc(months_between(trunc(get_sysdate()), trunc(i_birthday)) / com_api_const_pkg.YEAR_IN_MONTHS);

end get_person_age;

function get_person(
    i_person_id         in  com_api_type_pkg.t_medium_id
  , i_mask_error        in  com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
) return com_api_type_pkg.t_person
is
    l_result            com_api_type_pkg.t_person;
begin
    select p.id
         , p.lang
         , p.title
         , p.first_name
         , p.second_name
         , p.surname
         , p.suffix
         , p.gender
         , p.birthday
         , p.place_of_birth
         , p.inst_id
      into l_result
      from com_person p
     where p.id = i_person_id;

    return l_result;
exception
    when no_data_found then
        if i_mask_error = com_api_type_pkg.FALSE then
            com_api_error_pkg.raise_error(
                i_error      => 'PERSON_NOT_FOUND'
              , i_env_param1 => i_person_id
            );
        end if;
        return l_result;
end get_person;

end com_api_person_pkg;
/
