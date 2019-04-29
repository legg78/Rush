create or replace package ost_ui_institution_pkg as
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
);

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
);

procedure remove_institution(
    i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_seqnum            in      com_api_type_pkg.t_seqnum
);

function get_default_agent(
    i_inst_id           in      com_api_type_pkg.t_inst_id
) return com_api_type_pkg.t_agent_id;

function get_inst_name(
    i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_lang              in      com_api_type_pkg.t_dict_value       default null
) return com_api_type_pkg.t_name;

procedure add_inst_address(
    i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_address_id        in      varchar2
  , i_address_type      in      com_api_type_pkg.t_dict_value
  , o_address_object_id    out  com_api_type_pkg.t_long_id
);

procedure add_inst_contact(
    i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_contact_id        in      com_api_type_pkg.t_medium_id
  , o_contact_object_id    out  com_api_type_pkg.t_long_id
);

function get_inst_address(
    i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_address_type      in      com_api_type_pkg.t_dict_value  := 'ADTPBSNA'
  , i_lang              in      com_api_type_pkg.t_dict_value       default null
) return com_api_type_pkg.t_full_desc;

function get_inst_city(
    i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_address_type      in      com_api_type_pkg.t_dict_value  := 'ADTPBSNA'
  , i_lang              in      com_api_type_pkg.t_dict_value       default null
  , i_city_alias        in      com_api_type_pkg.t_dict_value       default null
) return com_api_type_pkg.t_name;

procedure add_forbidden_action(
    o_id               out      com_api_type_pkg.t_short_id 
  , i_inst_status   in     com_api_type_pkg.t_dict_value
  , i_data_action   in     com_api_type_pkg.t_dict_value
);

procedure remove_forbidden_action(
    i_id                in       com_api_type_pkg.t_short_id
);

end ost_ui_institution_pkg;
/
