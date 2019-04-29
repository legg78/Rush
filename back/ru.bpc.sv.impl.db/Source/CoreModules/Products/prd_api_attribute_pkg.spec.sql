create or replace package prd_api_attribute_pkg as
/*********************************************************
 *  Attributes API <br />
 *  Created by Filimonov A.(filimonov@bpcbt.com) at 23.05.2013 <br />
 *  Last changed by $Author: alalykin $ <br />
 *  $LastChangedDate:: 2016-03-03 18:00:00 +0300#$ <br />
 *  Revision: $LastChangedRevision: 1 $ <br />
 *  Module: PRD_API_ATTRIBUTE_PKG <br />
 *  @headcom
 **********************************************************/ 

procedure get_object_attributes(
    i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_id             in      com_api_type_pkg.t_long_id
  , o_xml                      out  clob
);

function get_attribute(
    i_attr_name             in      com_api_type_pkg.t_name
  , i_mask_error            in      com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
  , i_is_result_cache       in      com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
) return prd_api_type_pkg.t_attribute;

function get_attribute(
    i_attr_id               in      com_api_type_pkg.t_short_id
  , i_mask_error            in      com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
  , i_is_result_cache       in      com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
) return prd_api_type_pkg.t_attribute;

function get_attribute_rec(
    i_attr_name             in      com_api_type_pkg.t_name
) return prd_api_type_pkg.t_attribute result_cache;

function get_attribute_rec(
    i_attr_id               in      com_api_type_pkg.t_short_id
) return prd_api_type_pkg.t_attribute result_cache;

function get_attr_name(
    i_object_type       in      com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_name  result_cache;

end prd_api_attribute_pkg;
/
