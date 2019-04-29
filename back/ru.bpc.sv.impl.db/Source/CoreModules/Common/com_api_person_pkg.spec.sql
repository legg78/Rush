create or replace package com_api_person_pkg as
/*********************************************************
*  API for entity Person <br />
*  Created by Filimonov A.(filimonov@bpc.ru)  at 22.09.2009 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: COM_API_PERSON_PKG <br />
*  @headcom
**********************************************************/ 

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
);

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
);

procedure remove_person(
    i_person_id         in      com_api_type_pkg.t_medium_id
  , i_seqnum            in      com_api_type_pkg.t_seqnum
);

procedure get_person_id(
    i_person        in     com_api_type_pkg.t_person
  , i_identity_card in     com_api_type_pkg.t_identity_card
  , o_person_id        out com_api_type_pkg.t_medium_id
);

function get_person_age(
    i_birthday          in      date
) return com_api_type_pkg.t_byte_id;

function get_person(
    i_person_id         in  com_api_type_pkg.t_medium_id
  , i_mask_error        in  com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
) return com_api_type_pkg.t_person;

end com_api_person_pkg;
/
