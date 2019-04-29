create or replace package body app_api_sec_question_pkg as
/*********************************************************
*  API for secure question <br />
*  Created by Kryukov A.(krukov@bpcbt.com)  at 18.10.2010 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: APP_API_SEC_QUESTION_PKG <br />
*  @headcom
**********************************************************/

procedure process_sec_question(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_object_id            in            com_api_type_pkg.t_long_id
  , i_entity_type          in            com_api_type_pkg.t_dict_value
) is
    l_question             com_api_type_pkg.t_dict_value;
    l_answer               com_api_type_pkg.t_name;
    l_seqnum               com_api_type_pkg.t_seqnum := 1;
begin
    trc_log_pkg.debug(
        i_text => 'app_api_sec_question_pkg.process_sec_question: i_appl_data_id=' || i_appl_data_id
    );

    app_api_application_pkg.get_element_value(
        i_element_name          => 'SECRET_QUESTION'
      , i_parent_id             => i_appl_data_id
      , o_element_value         => l_question
      );

    if l_question is null then
        com_api_error_pkg.raise_error(
            i_error             => 'SEC_QUESTION_NOT_DEFINED'
        );
    end if;

    app_api_application_pkg.get_element_value(
        i_element_name          => 'SECRET_ANSWER'
      , i_parent_id             => i_appl_data_id
      , o_element_value         => l_answer
    );

    sec_api_question_pkg.set_security_word(
        i_entity_type => i_entity_type
      , i_object_id   => i_object_id
      , i_word        => l_answer
      , i_question    => l_question
      , io_seqnum     => l_seqnum
    );
exception
    when com_api_error_pkg.e_application_error then
        app_api_error_pkg.intercept_error(
            i_appl_data_id  => i_appl_data_id
          , i_element_name  => 'SECRET_QUESTION'
        );
end process_sec_question;

end app_api_sec_question_pkg;
/
