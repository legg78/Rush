create or replace package body sec_ui_question_pkg is
/*********************************************************
*  UI for secure question <br />
*  Created by Kryukov A.(kryukov@bpcbt.com)  at 21.12.2010 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: SEC_UI_QUESTION_PKG <br />
*  @headcom
**********************************************************/

procedure add_security_word (
    i_entity_type         in     com_api_type_pkg.t_dict_value
  , i_object_id           in     com_api_type_pkg.t_long_id
  , i_word                in     com_api_type_pkg.t_name
  , i_question            in     com_api_type_pkg.t_dict_value := DEFAULT_SECURITY_QUESTION
  , io_seqnum             in out com_api_type_pkg.t_seqnum
) is 
begin

    sec_api_question_pkg.set_security_word(
        i_entity_type => i_entity_type
      , i_object_id   => i_object_id
      , i_word        => i_word
      , i_question    => i_question
      , io_seqnum     => io_seqnum
    );

end add_security_word;

/*
 * @param i_entity_type
 * @param i_object_id
 * @param i_seqnum
 * @param i_question
 */
procedure remove_security_word (
    i_entity_type           in com_api_type_pkg.t_dict_value
  , i_object_id             in com_api_type_pkg.t_long_id
  , i_seqnum                in com_api_type_pkg.t_seqnum
  , i_question              in com_api_type_pkg.t_dict_value := DEFAULT_SECURITY_QUESTION
) is 
begin

    sec_api_question_pkg.remove_security_word(
        i_entity_type => i_entity_type
      , i_object_id   => i_object_id
      , i_seqnum      => i_seqnum
      , i_question    => i_question
    );

end remove_security_word;

function check_security_word (
    i_entity_type           in com_api_type_pkg.t_dict_value
  , i_object_id             in com_api_type_pkg.t_long_id
  , i_word                  in com_api_type_pkg.t_name
  , i_question              in com_api_type_pkg.t_dict_value := DEFAULT_SECURITY_QUESTION
) return com_api_type_pkg.t_boolean is

    l_result com_api_type_pkg.t_boolean;

begin

    return sec_api_question_pkg.check_security_word(
               i_entity_type => i_entity_type
             , i_object_id   => i_object_id
             , i_word        => i_word
             , i_question    => i_question
           );

end check_security_word;

end sec_ui_question_pkg;
/
