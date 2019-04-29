create or replace package sec_api_question_pkg is
/*********************************************************
*  API for secure question <br />
*  Created by Khougaev A.(khougaev@bpcbt.com)  at 29.01.2010 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: SEC_API_QUESTION_PKG <br />
*  @headcom
**********************************************************/

DEFAULT_SECURITY_QUESTION    constant com_api_type_pkg.t_dict_value := sec_api_const_pkg.DEFAULT_SECURITY_QUESTION;

/*
 * @param i_entity_type
 * @param i_object_id
 * @param i_word
 * @param i_question
 * @param io_seqnum
 */
procedure set_security_word (
    i_entity_type         in     com_api_type_pkg.t_dict_value
  , i_object_id           in     com_api_type_pkg.t_long_id
  , i_word                in     com_api_type_pkg.t_name
  , i_question            in     com_api_type_pkg.t_dict_value := DEFAULT_SECURITY_QUESTION
  , io_seqnum             in out com_api_type_pkg.t_seqnum
);

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
);

/*
 * @param i_entity_type
 * @param i_object_id
 * @param i_word
 * @param i_question
 */
function check_security_word (
    i_entity_type           in com_api_type_pkg.t_dict_value
  , i_object_id             in com_api_type_pkg.t_long_id
  , i_word                  in com_api_type_pkg.t_name
  , i_question              in com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_boolean;

/*
 * Overloaded function for checking secret answer (word) for any secret question. 
 */
function check_security_word (
    i_entity_type           in com_api_type_pkg.t_dict_value
  , i_object_id             in com_api_type_pkg.t_long_id
  , i_word                  in com_api_type_pkg.t_name
) return com_api_type_pkg.t_boolean;

end sec_api_question_pkg;
/
