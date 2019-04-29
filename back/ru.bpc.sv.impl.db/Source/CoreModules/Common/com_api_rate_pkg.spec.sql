create or replace package com_api_rate_pkg is
/*********************************************************
*  API for rates <br />
*  Created by Khougaev A.(khougaev@bpcbt.com)  at 04.12.2009 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: COM_API_RATE_PKG <br />
*  @headcom
**********************************************************/
RATE_STATUS_VALID           constant com_api_type_pkg.t_dict_value := 'RTSTVALD';
RATE_STATUS_INVALID         constant com_api_type_pkg.t_dict_value := 'RTSTINVL';

function convert_amount (
    i_src_amount            in number
    , i_src_currency        in com_api_type_pkg.t_curr_code
    , i_dst_currency        in com_api_type_pkg.t_curr_code
    , i_rate_type           in com_api_type_pkg.t_dict_value
    , i_inst_id             in com_api_type_pkg.t_inst_id
    , i_eff_date            in date
    , i_mask_exception      in com_api_type_pkg.t_boolean    default com_api_type_pkg.FALSE
    , i_exception_value     in number                        default null
    , i_conversion_type     in com_api_type_pkg.t_dict_value default com_api_const_pkg.CONVERSION_TYPE_SELLING
) return com_api_type_pkg.t_money;
    
function convert_amount (
    i_src_amount            in number
    , i_src_currency        in com_api_type_pkg.t_curr_code
    , i_dst_currency        in com_api_type_pkg.t_curr_code
    , i_rate_type           in com_api_type_pkg.t_dict_value
    , i_inst_id             in com_api_type_pkg.t_inst_id
    , i_eff_date            in date
    , i_mask_exception      in com_api_type_pkg.t_boolean    default com_api_type_pkg.FALSE
    , i_exception_value     in number := null
    , i_conversion_type     in com_api_type_pkg.t_dict_value default com_api_const_pkg.CONVERSION_TYPE_SELLING
    , o_conversion_rate     out com_api_type_pkg.t_rate
) return com_api_type_pkg.t_money;

function get_rate (
    i_src_currency          in com_api_type_pkg.t_curr_code
    , i_dst_currency        in com_api_type_pkg.t_curr_code
    , i_rate_type           in com_api_type_pkg.t_dict_value
    , i_inst_id             in com_api_type_pkg.t_inst_id
    , i_eff_date            in date
    , i_conversion_type     in com_api_type_pkg.t_dict_value default com_api_const_pkg.CONVERSION_TYPE_SELLING
    , i_mask_exception      in com_api_type_pkg.t_boolean    default com_api_type_pkg.FALSE
    , i_exception_value     in number                        default null
) return number;

procedure set_rate (
    o_id                    out com_api_type_pkg.t_short_id
    , o_seqnum              out com_api_type_pkg.t_tiny_id
    , o_count               out number
    , i_src_currency        in com_api_type_pkg.t_curr_code
    , i_dst_currency        in com_api_type_pkg.t_curr_code
    , i_rate_type           in com_api_type_pkg.t_dict_value
    , i_inst_id             in com_api_type_pkg.t_inst_id
    , i_eff_date            in date
    , i_rate                in number
    , i_inverted            in com_api_type_pkg.t_boolean
    , i_src_scale           in number
    , i_dst_scale           in number
    , i_exp_date            in date
);
    
function check_rate (
    i_src_currency          in com_api_type_pkg.t_curr_code
    , i_dst_currency        in com_api_type_pkg.t_curr_code
    , i_rate_type           in com_api_type_pkg.t_dict_value
    , i_inst_id             in com_api_type_pkg.t_inst_id
    , i_eff_date            in date
    , i_rate                in number
    , i_inverted            in com_api_type_pkg.t_boolean
    , i_src_scale           in number
    , i_dst_scale           in number
    , o_message             out com_api_type_pkg.t_text
) return com_api_type_pkg.t_boolean;

function get_inst_rate_type (
    i_rate_type             in com_api_type_pkg.t_dict_value
    , i_inst_id             in com_api_type_pkg.t_inst_id
    , i_mask_exception      in com_api_type_pkg.t_boolean    default com_api_type_pkg.FALSE
) return com_rate_type%rowtype;

end;
/
