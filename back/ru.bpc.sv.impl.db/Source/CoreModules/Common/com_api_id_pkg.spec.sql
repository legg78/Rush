create or replace package com_api_id_pkg is

/********************************************************* 
 *  Common api for IDs and doubles checking  <br /> 
 *  Created by Khougaev A. (khougaev@bpcbt.com)  at 31.05.2010 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module: com_api_id_pkg <br /> 
 *  @headcom 
 **********************************************************/ 

DAY_ROUNDING      constant  pls_integer                := -10;
DAY_TILL_ID       constant  com_api_type_pkg.t_long_id := 9999999999;
TILL_ID_OFFSET    constant  com_api_type_pkg.t_tiny_id := 3;  -- days
 
function get_id (
    i_seq           in      com_api_type_pkg.t_long_id
  , i_date          in      date                               default null
) return com_api_type_pkg.t_long_id;

function get_id (
    i_seq           in      com_api_type_pkg.t_long_id
  , i_object_id     in      com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_long_id;

function get_from_id(
    i_date          in      date                               default null
) return com_api_type_pkg.t_long_id;

function get_till_id(
    i_date          in      date                               default null
) return com_api_type_pkg.t_long_id;

function get_from_id(
    i_object_id     in      com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_long_id deterministic;

function get_till_id(
    i_object_id     in      com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_long_id deterministic;

function get_from_id_num(
    i_object_id     in      com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_long_id deterministic;

function get_till_id_num(
    i_object_id     in      com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_long_id deterministic;

procedure check_doubles;

function get_sequence_nextval (
    i_sequence_name in      com_api_type_pkg.t_name
) return com_api_type_pkg.t_long_id;

function get_part_key_from_id(
    i_id              in      com_api_type_pkg.t_long_id
) return date;

end;
/
