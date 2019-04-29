create or replace package body sec_api_question_pkg is
/*********************************************************
*  API for secure question <br />
*  Created by Khougaev A.(khougaev@bpcbt.com)  at 29.01.2010 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: SEC_API_QUESTION_PKG <br />
*  @headcom
**********************************************************/

procedure set_security_word (
    i_entity_type         in     com_api_type_pkg.t_dict_value
  , i_object_id           in     com_api_type_pkg.t_long_id
  , i_word                in     com_api_type_pkg.t_name
  , i_question            in     com_api_type_pkg.t_dict_value
  , io_seqnum             in out com_api_type_pkg.t_seqnum
) is
    l_id                    com_api_type_pkg.t_long_id;
begin
    for rec in (
        select
              a.id
            , a.seqnum
        from
            sec_question_vw a
        where
            a.entity_type = i_entity_type
        and
            a.object_id = i_object_id)
    loop
        update
            sec_question_vw a
        set
            a.seqnum = rec.seqnum
          , a.question = i_question
          , a.word_hash = com_api_hash_pkg.get_string_hash(upper(i_word))
        where
            a.id = rec.id;

        update
            sec_word b
        set  word = upper(i_word)
        where question_id = rec.id;

        io_seqnum := rec.seqnum + 1;
        return;
    end loop;

    io_seqnum := 1;
    l_id := sec_question_seq.nextval;

    insert into sec_question_vw (
        id
      , seqnum
      , entity_type
      , object_id
      , question
      , word_hash
    ) values (
        l_id
      , io_seqnum
      , i_entity_type
      , i_object_id
      , i_question
      , com_api_hash_pkg.get_string_hash(upper(i_word))
    );

    insert into sec_word (
        question_id
       , word
    ) values (
        l_id
      , upper(i_word)
    );

end set_security_word;

procedure remove_security_word (
    i_entity_type         in com_api_type_pkg.t_dict_value
  , i_object_id           in com_api_type_pkg.t_long_id
  , i_seqnum              in com_api_type_pkg.t_seqnum
  , i_question            in com_api_type_pkg.t_dict_value
) is
    l_id                    com_api_type_pkg.t_long_id;
begin
    update
        sec_question_vw q
    set
        seqnum = i_seqnum
    where
        entity_type = i_entity_type
    and
        object_id = i_object_id
    and
        question = i_question
    returning
        id
    into
        l_id;

    delete
        sec_word
    where
        question_id = l_id;

    delete from
        sec_question_vw
    where
        id = l_id;

end remove_security_word;
    
function check_security_word (
    i_entity_type         in com_api_type_pkg.t_dict_value
  , i_object_id           in com_api_type_pkg.t_long_id
  , i_word                in com_api_type_pkg.t_name
  , i_question            in com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_boolean
is
    l_word                   com_api_type_pkg.t_name;
begin
    begin
        select
            word
        into
            l_word
        from
            sec_question_word_vw
        where
            entity_type = i_entity_type
        and
            object_id = i_object_id
        and
            question = i_question
        and
            word_hash = com_api_hash_pkg.get_string_hash(upper(i_word));
    exception
        when no_data_found then
            trc_log_pkg.debug(
                i_text       => lower($$PLSQL_UNIT) || '.check_security_word: '
                             || 'i_entity_type [#1], i_object_id [' || i_object_id || '], i_question [#2]'
              , i_env_param1 => i_entity_type
              , i_env_param2 => i_question
            );
    end;

    return case when upper(l_word) = upper(i_word) then com_api_type_pkg.TRUE 
                                                   else com_api_type_pkg.FALSE 
           end; 
end check_security_word; -- 1th

/*
 * Overloaded function for checking secret answer (word) for any secret question. 
 */
function check_security_word (
    i_entity_type         in com_api_type_pkg.t_dict_value
  , i_object_id           in com_api_type_pkg.t_long_id
  , i_word                in com_api_type_pkg.t_name
) return com_api_type_pkg.t_boolean
is
    l_result                 com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE;
begin
    begin
        select com_api_type_pkg.TRUE
          into l_result
          from sec_question
         where entity_type = i_entity_type
           and object_id   = i_object_id
           and word_hash   = com_api_hash_pkg.get_string_hash(upper(i_word))
           and rownum      = 1;
    exception
        when no_data_found then
            null;
        when others then
            trc_log_pkg.debug(
                i_text       => lower($$PLSQL_UNIT) || '.check_security_word[2th] FAILED: entity [#1][#2]'
              , i_env_param1 => i_entity_type
              , i_env_param2 => i_object_id
              --, i_env_param3 => com_api_hash_pkg.get_string_hash(upper(i_word))
            );
            raise;
    end;
    return l_result;
end check_security_word; -- 2th

end sec_api_question_pkg;
/
