create or replace package rul_api_name_pkg as
/*********************************************************
*  Naming service <br />
*  Created by Kryukov E.(krukov@bpc.ru)  at 01.04.2010 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate:: 2010-04-08 17:36:45 +0400$ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: RUL_API_NAME_PKG <br />
*  @headcom
**********************************************************/

function pad_byte_len (
    i_src          in     com_api_type_pkg.t_param_value
  , i_pad_type     in     com_api_type_pkg.t_dict_value := 'PADTLEFT'
  , i_pad_string   in     com_api_type_pkg.t_dict_value := '0'
  , i_length       in     com_api_type_pkg.t_tiny_id := null
) return com_api_type_pkg.t_lob_data;

function get_name (
    i_format_id           in com_api_type_pkg.t_tiny_id
  , i_param_tab           in com_api_type_pkg.t_param_tab
  , i_double_check_value  in com_api_type_pkg.t_name := null
  , i_enable_empty        in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_name;
    
function get_name (
    i_inst_id             in com_api_type_pkg.t_inst_id
  , i_entity_type         in com_api_type_pkg.t_dict_value
  , i_param_tab           in com_api_type_pkg.t_param_tab 
  , i_double_check_value  in com_api_type_pkg.t_name := null
) return com_api_type_pkg.t_name;

function get_params_name (
    i_format_id             in com_api_type_pkg.t_tiny_id
  , i_param_tab           in com_api_type_pkg.t_param_tab
) return rul_api_type_pkg.t_param_tab;

function get_params_name (
    i_format_id           in     com_api_type_pkg.t_tiny_id
  , i_param_tab           in     com_api_type_pkg.t_param_tab
  , i_index_range_id      in     com_api_type_pkg.t_short_id
  , i_entity_type         in     com_api_type_pkg.t_dict_value
) return rul_api_type_pkg.t_param_tab;
  
function check_name (
    i_format_id           in     com_api_type_pkg.t_tiny_id
  , i_name                in     com_api_type_pkg.t_name
  , i_param_tab           in     com_api_type_pkg.t_param_tab
  , i_entity_type         in     com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_boolean;

function check_name (
    i_inst_id               in com_api_type_pkg.t_inst_id
    , i_entity_type         in com_api_type_pkg.t_dict_value
    , i_name                in com_api_type_pkg.t_name
    , i_param_tab           in com_api_type_pkg.t_param_tab
    , i_null_format_allowed in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
) return com_api_type_pkg.t_boolean;

function get_format_id (
      i_inst_id         in com_api_type_pkg.t_inst_id
    , i_entity_type     in com_api_type_pkg.t_dict_value
    , i_raise_error     in com_api_type_pkg.t_boolean := com_api_type_pkg.TRUE
) return com_api_type_pkg.t_tiny_id;

function range_nextval(
    i_id          in com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_large_id;

end rul_api_name_pkg;
/
