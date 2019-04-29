create or replace package com_api_hash_pkg is
/********************************************************* 
 *  API for hash and base64<br /> 
 *  Created by Khougaev A.(khougaev@bpcbt.com)  at 25.01.2010 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module:  com_api_hash_pkg  <br /> 
 *  @headcom 
 **********************************************************/ 
 
function get_split_hash (
    i_value         in     varchar2
) return com_api_type_pkg.t_tiny_id;
        
function get_split_hash (
    i_entity_type   in     com_api_type_pkg.t_dict_value
  , i_object_id     in     com_api_type_pkg.t_long_id
  , i_mask_error    in     com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_tiny_id;
        
function get_card_hash (
    i_card_number   in     com_api_type_pkg.t_card_number
) return com_api_type_pkg.t_long_id;

function get_string_hash (
    i_string        in     varchar2
) return com_api_type_pkg.t_long_id;

function base64_encode(
    i_clob          in     clob
) return clob;

function base64_decode(
    i_clob          in     clob
) return clob;

function get_param_mask (
    i_value         in     com_api_type_pkg.t_param_value
) return com_api_type_pkg.t_param_value;

function check_current_thread_number(
    i_split_hash    in     com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_boolean;
 
procedure reload_settings;

end com_api_hash_pkg;
/
