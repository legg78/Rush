create or replace package com_ui_person_pkg as
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
);

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
);

procedure remove_person(
    i_person_id         in      com_api_type_pkg.t_medium_id
  , i_seqnum            in      com_api_type_pkg.t_seqnum
);
-- This function returns multi-language person name in a similar to get_text function  
function get_person_name(
    i_person_id         in      com_api_type_pkg.t_medium_id
  , i_lang              in      com_api_type_pkg.t_dict_value       default null
) return com_api_type_pkg.t_text;


function get_first_name(
    i_person_id         in      com_api_type_pkg.t_medium_id
  , i_lang              in      com_api_type_pkg.t_dict_value       default null
) return com_api_type_pkg.t_text;

function get_second_name(
    i_person_id         in      com_api_type_pkg.t_medium_id
  , i_lang              in      com_api_type_pkg.t_dict_value       default null
) return com_api_type_pkg.t_text;

function get_surname(
    i_person_id         in      com_api_type_pkg.t_medium_id
  , i_lang              in      com_api_type_pkg.t_dict_value       default null
) return com_api_type_pkg.t_text;

function get_birthday(
    i_person_id         in      com_api_type_pkg.t_medium_id
) return date;

function get_title(
    i_person_id         in      com_api_type_pkg.t_medium_id
  , i_lang              in      com_api_type_pkg.t_dict_value       default null
) return com_api_type_pkg.t_text;

end;
/
