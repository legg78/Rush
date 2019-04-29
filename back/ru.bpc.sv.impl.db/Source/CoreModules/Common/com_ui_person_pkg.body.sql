create or replace package body com_ui_person_pkg as
/*********************************************************
*  UI for person <br />
*  Created by Filimonov A.(filimonov@bpcbt.com)  at 05.11.2011 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: COM_UI_PERSON_PKG <br />
*  @headcom
**********************************************************/
procedure add_person(
    o_person_id            out  com_api_type_pkg.t_medium_id
  , i_lang              in      com_api_type_pkg.t_dict_value
  , i_title             in      com_api_type_pkg.t_dict_value
  , i_first_name        in      com_api_type_pkg.t_name
  , i_second_name       in      com_api_type_pkg.t_name
  , i_surname           in      com_api_type_pkg.t_name
  , i_suffix            in      com_api_type_pkg.t_dict_value
  , i_gender            in      com_api_type_pkg.t_dict_value
  , i_birthday          in      date
  , i_place_of_birth    in      com_api_type_pkg.t_name
) is
begin
    com_api_person_pkg.add_person(
        io_person_id        => o_person_id
      , i_lang              => i_lang
      , i_person_title      => i_title
      , i_first_name        => i_first_name
      , i_second_name       => i_second_name
      , i_surname           => i_surname
      , i_suffix            => i_suffix
      , i_gender            => i_gender
      , i_birthday          => i_birthday
      , i_place_of_birth    => i_place_of_birth
      , i_inst_id           => ost_api_institution_pkg.get_sandbox
    );
end;

procedure modify_person(
    i_person_id         in      com_api_type_pkg.t_medium_id
  , i_title             in      com_api_type_pkg.t_dict_value
  , i_first_name        in      com_api_type_pkg.t_name
  , i_second_name       in      com_api_type_pkg.t_name
  , i_surname           in      com_api_type_pkg.t_name
  , i_suffix            in      com_api_type_pkg.t_dict_value
  , i_gender            in      com_api_type_pkg.t_dict_value
  , i_birthday          in      date
  , i_place_of_birth    in      com_api_type_pkg.t_name
  , i_seqnum            in      com_api_type_pkg.t_seqnum
  , i_lang              in      com_api_type_pkg.t_dict_value       default null
) is
begin
    com_api_person_pkg.modify_person(
        i_person_id         => i_person_id
      , i_person_title      => i_title
      , i_first_name        => i_first_name
      , i_second_name       => i_second_name
      , i_surname           => i_surname
      , i_suffix            => i_suffix
      , i_gender            => i_gender
      , i_birthday          => i_birthday
      , i_place_of_birth    => i_place_of_birth
      , i_seqnum            => i_seqnum
      , i_lang              => i_lang
      , i_inst_id           => ost_api_institution_pkg.get_sandbox
    );
end;

procedure remove_person(
    i_person_id         in      com_api_type_pkg.t_medium_id
  , i_seqnum            in      com_api_type_pkg.t_seqnum
) is
    l_count             com_api_type_pkg.t_medium_id;
begin
    select count(*) 
      into l_count  
      from acm_user 
    where person_id = i_person_id;
    
    if l_count > 0 then
        com_api_error_pkg.raise_error(
            i_error      => 'PERSON_ALREADY_USED_IN_USER'
          , i_env_param1 =>  i_person_id
        );    
    end if; 
        
    com_api_person_pkg.remove_person(
        i_person_id         => i_person_id
      , i_seqnum            => i_seqnum
    );
end;

function get_person_name(
    i_person_id         in      com_api_type_pkg.t_medium_id
  , i_lang              in      com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_text is
    l_result            com_api_type_pkg.t_text;
    l_lang              com_api_type_pkg.t_dict_value;
begin
    if i_person_id is null then
        return null;
    end if;

    l_lang := nvl(i_lang, com_ui_user_env_pkg.get_user_lang);

    select name 
      into l_result
      from (
            select surname || ' ' || first_name || nvl2(second_name,  ' ' || second_name, null) name
              from com_person_vw
             where id = i_person_id
             order by decode(lang, l_lang, 1, com_api_const_pkg.LANGUAGE_ENGLISH, 2, 3)
            )
     where rownum = 1;

    return l_result;
exception
    when no_data_found then
        return null;
end;


function get_first_name(
    i_person_id         in      com_api_type_pkg.t_medium_id
  , i_lang              in      com_api_type_pkg.t_dict_value       default null
) return com_api_type_pkg.t_text
is 
    l_result            com_api_type_pkg.t_text;
    l_lang              com_api_type_pkg.t_dict_value;
begin
    if i_person_id is null then
        return null;
    end if;

    l_lang := nvl(i_lang, com_ui_user_env_pkg.get_user_lang);

    select name 
      into l_result
      from (
            select first_name name
              from com_person_vw
             where id = i_person_id
             order by decode(lang, l_lang, 1, com_api_const_pkg.LANGUAGE_ENGLISH, 2, 3)
            )
     where rownum = 1;

    return l_result;
exception
    when no_data_found then
        return null;
end;

function get_second_name(
    i_person_id         in      com_api_type_pkg.t_medium_id
  , i_lang              in      com_api_type_pkg.t_dict_value       default null
) return com_api_type_pkg.t_text
is
    l_result            com_api_type_pkg.t_text;
    l_lang              com_api_type_pkg.t_dict_value;
begin
    if i_person_id is null then
        return null;
    end if;

    l_lang := nvl(i_lang, com_ui_user_env_pkg.get_user_lang);

    select name 
      into l_result
      from (
            select nvl2(second_name,  ' ' || second_name, null) name
              from com_person_vw
             where id = i_person_id
             order by decode(lang, l_lang, 1, com_api_const_pkg.LANGUAGE_ENGLISH, 2, 3)
            )
     where rownum = 1;

    return l_result;
exception
    when no_data_found then
        return null;
end;

function get_surname(
    i_person_id         in      com_api_type_pkg.t_medium_id
  , i_lang              in      com_api_type_pkg.t_dict_value       default null
) return com_api_type_pkg.t_text
is
    l_result            com_api_type_pkg.t_text;
    l_lang              com_api_type_pkg.t_dict_value;
begin
    if i_person_id is null then
        return null;
    end if;

    l_lang := nvl(i_lang, com_ui_user_env_pkg.get_user_lang);

    select name 
      into l_result
      from (
            select surname name
              from com_person_vw
             where id = i_person_id
             order by decode(lang, l_lang, 1, com_api_const_pkg.LANGUAGE_ENGLISH, 2, 3)
            )
     where rownum = 1;

    return l_result;
exception
    when no_data_found then
        return null;
end;

function get_birthday(
    i_person_id         in      com_api_type_pkg.t_medium_id
) return date
is
    l_result            date;
begin
    if i_person_id is null then
        return null;
    end if;

    select p.birthday
      into l_result
      from com_person p
     where id = i_person_id;

    return l_result;
exception
    when no_data_found then
        return null;
end;

function get_title(
    i_person_id         in      com_api_type_pkg.t_medium_id
  , i_lang              in      com_api_type_pkg.t_dict_value       default null
) return com_api_type_pkg.t_text
is
    l_result            com_api_type_pkg.t_text;
    l_lang              com_api_type_pkg.t_dict_value;
begin
    if i_person_id is null then
        return null;
    end if;

    l_lang := nvl(i_lang, com_ui_user_env_pkg.get_user_lang);

    select com_api_dictionary_pkg.get_article_text(title)
      into l_result
      from (
            select title
              from com_person_vw
             where id = i_person_id
             order by decode(lang, l_lang, 1, com_api_const_pkg.LANGUAGE_ENGLISH, 2, 3)
            )
     where rownum = 1;

    return l_result;
exception
    when no_data_found then
        return null;
end;

end;
/
