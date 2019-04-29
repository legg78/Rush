create or replace package com_ui_address_pkg as
/********************************************************* 
 *  UI for Address <br /> 
 *  Created by Filimonov A.(filimonov@bpcbt.com)  at 14.10.2009 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module: acom_ui_address_pkg  <br /> 
 *  @headcom 
 **********************************************************/ 
procedure add_address (
    o_address_id       out com_api_type_pkg.t_medium_id
  , o_seqnum           out com_api_type_pkg.t_seqnum
  , i_lang          in     com_api_type_pkg.t_dict_value
  , i_country       in     com_api_type_pkg.t_country_code
  , i_region        in     com_api_type_pkg.t_double_name
  , i_city          in     com_api_type_pkg.t_double_name
  , i_street        in     com_api_type_pkg.t_double_name
  , i_house         in     com_api_type_pkg.t_double_name
  , i_apartment     in     com_api_type_pkg.t_double_name
  , i_postal_code   in     varchar2
  , i_region_code   in     com_api_type_pkg.t_dict_value
  , i_latitude      in     com_api_type_pkg.t_geo_coord
  , i_longitude     in     com_api_type_pkg.t_geo_coord
  , i_inst_id       in     com_api_type_pkg.t_inst_id := null
  , i_place_code    in     com_api_type_pkg.t_name
);

procedure modify_address (
    i_address_id    in     com_api_type_pkg.t_medium_id
  , io_seqnum       in out com_api_type_pkg.t_seqnum
  , i_lang          in     com_api_type_pkg.t_dict_value
  , i_country       in     com_api_type_pkg.t_country_code
  , i_region        in     com_api_type_pkg.t_double_name
  , i_city          in     com_api_type_pkg.t_double_name
  , i_street        in     com_api_type_pkg.t_double_name
  , i_house         in     com_api_type_pkg.t_double_name
  , i_apartment     in     com_api_type_pkg.t_double_name
  , i_postal_code   in     varchar2
  , i_region_code   in     com_api_type_pkg.t_dict_value
  , i_latitude      in     com_api_type_pkg.t_geo_coord
  , i_longitude     in     com_api_type_pkg.t_geo_coord
  , i_inst_id       in     com_api_type_pkg.t_inst_id := null
  , i_place_code    in     com_api_type_pkg.t_name
);

procedure remove_address (
    i_address_id           in     com_api_type_pkg.t_medium_id
  , i_seqnum               in     com_api_type_pkg.t_seqnum
);

procedure add_address_object (
    i_address_id           in     com_api_type_pkg.t_medium_id
    , i_address_type       in     com_api_type_pkg.t_dict_value
    , i_entity_type        in     com_api_type_pkg.t_dict_value
    , i_object_id          in     com_api_type_pkg.t_long_id
    , o_address_object_id     out com_api_type_pkg.t_long_id
);

procedure remove_address_object (
    i_address_object_id    in     com_api_type_pkg.t_long_id
);

procedure check_address_object(
    i_address_type      in      com_api_type_pkg.t_dict_value
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
);

procedure add_address_relation(
    o_address_id              out com_api_type_pkg.t_medium_id
  , o_seqnum                  out com_api_type_pkg.t_seqnum
  , o_address_object_id       out com_api_type_pkg.t_long_id
  , i_lang                 in     com_api_type_pkg.t_dict_value
  , i_country              in     com_api_type_pkg.t_country_code
  , i_region               in     com_api_type_pkg.t_double_name
  , i_city                 in     com_api_type_pkg.t_double_name
  , i_street               in     com_api_type_pkg.t_double_name
  , i_house                in     com_api_type_pkg.t_double_name
  , i_apartment            in     com_api_type_pkg.t_double_name
  , i_postal_code          in     varchar2
  , i_region_code          in     com_api_type_pkg.t_dict_value
  , i_latitude             in     com_api_type_pkg.t_geo_coord
  , i_longitude            in     com_api_type_pkg.t_geo_coord
  , i_inst_id              in     com_api_type_pkg.t_inst_id := null
  , i_place_code           in     com_api_type_pkg.t_name
  , i_address_type         in     com_api_type_pkg.t_dict_value
  , i_entity_type          in     com_api_type_pkg.t_dict_value
  , i_object_id            in     com_api_type_pkg.t_long_id
);

end com_ui_address_pkg;
/
