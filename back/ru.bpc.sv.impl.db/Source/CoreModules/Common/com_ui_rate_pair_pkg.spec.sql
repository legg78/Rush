create or replace package com_ui_rate_pair_pkg is
/************************************************************
 * UI for rate pair <br />
 * Created by Khougaev A.(khougaev@bpc.ru)  at 23.04.2010  <br />
 * Last changed by $Author$  <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: COM_UI_RATE_PAIR_PKG <br />
 * @headcom
 ************************************************************/
procedure add (
    o_id                    out com_api_type_pkg.t_tiny_id
    , o_seqnum              out com_api_type_pkg.t_tiny_id
    , i_rate_type           in com_api_type_pkg.t_dict_value
    , i_inst_id             in com_api_type_pkg.t_inst_id
    , i_src_currency        in com_api_type_pkg.t_curr_code
    , i_dst_currency        in com_api_type_pkg.t_curr_code
    , i_base_rate_type      in com_api_type_pkg.t_dict_value
    , i_base_rate_formula   in com_api_type_pkg.t_name
    , i_input_mode          in com_api_type_pkg.t_dict_value
    , i_inverted            in com_api_type_pkg.t_boolean
    , i_src_scale           in number
    , i_dst_scale           in number
    , i_rate_example        in com_api_type_pkg.t_rate
    , i_display_order       in com_api_type_pkg.t_tiny_id
    , i_label               in com_api_type_pkg.t_short_desc
    , i_lang                in com_api_type_pkg.t_dict_value
);

procedure modify (
    i_id                    in com_api_type_pkg.t_tiny_id
    , io_seqnum             in out com_api_type_pkg.t_tiny_id
    , i_rate_type           in com_api_type_pkg.t_dict_value
    , i_inst_id             in com_api_type_pkg.t_inst_id
    , i_base_rate_type      in com_api_type_pkg.t_dict_value
    , i_base_rate_formula   in com_api_type_pkg.t_name
    , i_input_mode          in com_api_type_pkg.t_dict_value
    , i_inverted            in com_api_type_pkg.t_boolean
    , i_src_scale           in number
    , i_dst_scale           in number
    , i_rate_example        in com_api_type_pkg.t_rate
    , i_display_order       in com_api_type_pkg.t_tiny_id
    , i_label               in com_api_type_pkg.t_short_desc
    , i_lang                in com_api_type_pkg.t_dict_value
);

procedure remove (
    i_id                    in com_api_type_pkg.t_tiny_id
    , i_seqnum              in com_api_type_pkg.t_tiny_id
);

end;
/