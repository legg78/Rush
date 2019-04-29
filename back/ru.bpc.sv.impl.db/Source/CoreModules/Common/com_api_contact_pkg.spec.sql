create or replace package com_api_contact_pkg as
/********************************************************* 
 *  API for contacts  <br /> 
 *  Created by Filimonov A.(filimonov@bpcbt.com)  at 11.12.2009 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module: com_api_contact_pkg <br /> 
 *  @headcom 
 **********************************************************/
 
procedure add_contact(
    o_id                   out  com_api_type_pkg.t_medium_id
  , i_preferred_lang    in      com_api_type_pkg.t_dict_value
  , i_job_title         in      com_api_type_pkg.t_dict_value
  , i_person_id         in      com_api_type_pkg.t_name
  , i_inst_id           in      com_api_type_pkg.t_inst_id
);

procedure modify_contact(
    i_id                in      com_api_type_pkg.t_medium_id
  , i_preferred_lang    in      com_api_type_pkg.t_dict_value
  , i_job_title         in      com_api_type_pkg.t_dict_value
  , i_person_id         in      com_api_type_pkg.t_name
);

procedure remove_contact(
    i_contact_id        in      com_api_type_pkg.t_long_id
);

procedure add_contact_data(
    i_contact_id        in      com_api_type_pkg.t_medium_id
  , i_commun_method     in      com_api_type_pkg.t_dict_value
  , i_commun_address    in      com_api_type_pkg.t_full_desc
  , i_start_date        in      date := null
  , i_end_date          in      date := null
);

procedure modify_contact_data(
    i_contact_id        in      com_api_type_pkg.t_medium_id
  , i_commun_method     in      com_api_type_pkg.t_dict_value
  , i_commun_address    in      com_api_type_pkg.t_full_desc
  , i_start_date        in      date := null
  , i_end_date          in      date := null
);

/*
 * Procedure updates contact data for some entity object;
 * if incoming contact ID belongs to another entity object then it isn't changed,
 * but a new contact with data is created for an incoming entity object. 
 */
procedure modify_contact_data(
    i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_contact_id        in      com_api_type_pkg.t_medium_id
  , i_commun_method     in      com_api_type_pkg.t_dict_value
  , i_commun_address    in      com_api_type_pkg.t_full_desc
  , i_start_date        in      date
  , i_end_date          in      date
);

procedure remove_contact_data(
    i_contact_data_id   in      com_api_type_pkg.t_long_id
);

procedure add_contact_object(
    i_contact_id        in      com_api_type_pkg.t_medium_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_contact_type      in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , o_contact_object_id    out  com_api_type_pkg.t_long_id
);

procedure remove_contact_object(
    i_contact_object_id in      com_api_type_pkg.t_long_id
);

function get_contact_string(
    i_contact_id        in      com_api_type_pkg.t_medium_id
  , i_commun_method     in      com_api_type_pkg.t_dict_value
  , i_start_date        in      date
) return com_api_type_pkg.t_full_desc;

function get_contact_data(
    i_object_id             in com_api_type_pkg.t_long_id
  , i_entity_type           in com_api_type_pkg.t_dict_value
  , i_contact_type          in com_api_type_pkg.t_dict_value
  , i_eff_date              in date                             default null
) return com_api_type_pkg.t_param_tab;

function get_contact_data_rec(
    i_object_id         in  com_api_type_pkg.t_long_id
  , i_entity_type       in  com_api_type_pkg.t_dict_value
  , i_contact_type      in  com_api_type_pkg.t_dict_value
  , i_eff_date          in  date                           default null
  , i_mask_error        in  com_api_type_pkg.t_boolean     default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_contact_data_rec;

end;
/
