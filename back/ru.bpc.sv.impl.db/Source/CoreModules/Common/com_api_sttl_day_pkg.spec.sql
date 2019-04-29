create or replace package com_api_sttl_day_pkg as
/************************************************************
 * API for settlement days <br />
 * Created by Filimonov A.(filimonov@bpcbt.com)  at 30.07.2009 <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: com_api_sttl_day_pkg <br />
 * @headcom
 ***********************************************************/

    function get_sysdate return date;

    procedure set_sysdate(
        i_sysdate           in      date := null
    );

    procedure unset_sysdate;
    
    function get_next_sttl_date (
        i_sttl_date                 in date default null
        , i_inst_id                 in com_api_type_pkg.t_inst_id default null
        , i_alg_day                 in com_api_type_pkg.t_dict_value
    ) return date;
    
    procedure set_sttl_day (
        i_sttl_date           in date default null
        , i_inst_id           in com_api_type_pkg.t_inst_id default null
        , o_sttl_day          out com_api_type_pkg.t_tiny_id
    );

    procedure switch_sttl_day (
        i_sttl_date           in date default null
        , i_inst_id           in com_api_type_pkg.t_inst_id default null
        , i_alg_day           in com_api_type_pkg.t_dict_value default null
        , o_sttl_day          out com_api_type_pkg.t_tiny_id
    );
    
    procedure cache_sttl_days;
    
    procedure free_cache_sttl_days;

    function get_open_sttl_day (
        i_inst_id               in com_api_type_pkg.t_inst_id
        , i_force_read          in com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE
    ) return com_api_type_pkg.t_tiny_id;

    function get_open_sttl_date (
        i_inst_id               in com_api_type_pkg.t_inst_id
        , i_force_read          in com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE
    ) return date;

    function get_sttl_day_open_date (
        i_sttl_date             in date
      , i_inst_id               in com_api_type_pkg.t_inst_id
    ) return date;

    function get_calc_date( 
        i_inst_id               in com_api_type_pkg.t_inst_id     default null
      , i_date_type             in com_api_type_pkg.t_dict_value  default null
    ) return date;
    
    function map_date_type_dict_to_dict(
        i_date_type        in  com_api_type_pkg.t_dict_value
      , i_dict_map         in  com_api_type_pkg.t_dict_value
      , i_mask_error       in  com_api_type_pkg.t_boolean          default com_api_const_pkg.FALSE
    ) return com_api_type_pkg.t_dict_value;
    
end;
/
