create or replace package com_api_address_pkg as
/************************************************************
*  API for adresses <br />
*  Created by Khougaev A.(khougaev@bpc.ru)  at 19.03.2010 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: COM_API_ADDRESS_PKG <br />
*  @headcom
*************************************************************/
procedure register_event(
    i_address_id  in     com_api_type_pkg.t_long_id
);

procedure add_address(
    io_address_id       in out  com_api_type_pkg.t_medium_id
  , i_lang              in      com_api_type_pkg.t_dict_value
  , i_country           in      com_api_type_pkg.t_country_code
  , i_region            in      com_api_type_pkg.t_double_name
  , i_city              in      com_api_type_pkg.t_double_name
  , i_street            in      com_api_type_pkg.t_double_name
  , i_house             in      com_api_type_pkg.t_double_name
  , i_apartment         in      com_api_type_pkg.t_double_name
  , i_postal_code       in      varchar2
  , i_region_code       in      com_api_type_pkg.t_dict_value
  , i_latitude          in      com_api_type_pkg.t_geo_coord
  , i_longitude         in      com_api_type_pkg.t_geo_coord
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_place_code        in      com_api_type_pkg.t_name
  , i_comments          in      com_api_type_pkg.t_name             default null
);

procedure modify_address(
    i_address_id        in      com_api_type_pkg.t_medium_id
  , i_country           in      com_api_type_pkg.t_country_code
  , i_region            in      com_api_type_pkg.t_double_name
  , i_city              in      com_api_type_pkg.t_double_name
  , i_street            in      com_api_type_pkg.t_double_name
  , i_house             in      com_api_type_pkg.t_double_name
  , i_apartment         in      com_api_type_pkg.t_double_name
  , i_postal_code       in      varchar2
  , i_region_code       in      com_api_type_pkg.t_dict_value
  , i_latitude          in      com_api_type_pkg.t_geo_coord
  , i_longitude         in      com_api_type_pkg.t_geo_coord
  , i_lang              in      com_api_type_pkg.t_dict_value
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_place_code        in      com_api_type_pkg.t_name
  , i_comments          in      com_api_type_pkg.t_name             default null
);

procedure remove_address(
    i_address_id        in      com_api_type_pkg.t_medium_id
  , i_seqnum            in      com_api_type_pkg.t_seqnum
);

procedure remove_address(
    i_address_id        in      com_api_type_pkg.t_medium_id
);

procedure add_address_object(
    i_address_id        in      com_api_type_pkg.t_medium_id
  , i_address_type      in      com_api_type_pkg.t_dict_value
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , o_address_object_id    out  com_api_type_pkg.t_long_id
);

procedure modify_address_object(
    i_address_object_id in      com_api_type_pkg.t_long_id
  , i_address_id        in      com_api_type_pkg.t_medium_id
  , i_address_type      in      com_api_type_pkg.t_dict_value
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
);

procedure remove_address_object(
    i_address_object_id in      com_api_type_pkg.t_long_id
);

function get_address_string(
    i_address_id        in      com_api_type_pkg.t_medium_id
  , i_lang              in      com_api_type_pkg.t_dict_value       default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id          default null
  , i_enable_empty      in      com_api_type_pkg.t_boolean          default com_api_const_pkg.FALSE
) return varchar2;

function get_address_string(
    i_country           in      com_api_type_pkg.t_country_code     default null
  , i_region            in      com_api_type_pkg.t_double_name      default null
  , i_city              in      com_api_type_pkg.t_double_name      default null
  , i_street            in      com_api_type_pkg.t_double_name      default null
  , i_house             in      com_api_type_pkg.t_double_name      default null
  , i_apartment         in      com_api_type_pkg.t_double_name      default null
  , i_postal_code       in      varchar2                            default null
  , i_region_code       in      com_api_type_pkg.t_dict_value       default null
  , i_comments          in      com_api_type_pkg.t_name             default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_enable_empty      in      com_api_type_pkg.t_boolean          default com_api_const_pkg.FALSE
) return varchar2;

function get_address(
    i_object_id    in     com_api_type_pkg.t_long_id
  , i_entity_type  in     com_api_type_pkg.t_dict_value
  , i_address_type in     com_api_type_pkg.t_dict_value
  , i_lang         in     com_api_type_pkg.t_dict_value := get_user_lang
  , i_mask_error   in     com_api_type_pkg.t_boolean    := com_api_const_pkg.TRUE
) return com_api_type_pkg.t_address_rec;

procedure check_address_object(
    i_address_type      in      com_api_type_pkg.t_dict_value
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
);

end com_api_address_pkg;
/
