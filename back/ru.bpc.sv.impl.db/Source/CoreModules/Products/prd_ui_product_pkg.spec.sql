create or replace package prd_ui_product_pkg is
/*********************************************************
*  UI for products <br />
*  Created by Filimonov a.(filimonov@bpcsv.com)  at 13.11.2010 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: PRD_UI_PRODUCT_PKG <br />
*  headcom
**********************************************************/

procedure add_product (
    o_id                    out com_api_type_pkg.t_short_id
    , o_seqnum              out com_api_type_pkg.t_seqnum
    , i_product_type        in com_api_type_pkg.t_dict_value
    , i_contract_type       in com_api_type_pkg.t_dict_value
    , i_parent_id           in com_api_type_pkg.t_short_id
    , i_inst_id             in com_api_type_pkg.t_inst_id
    , i_lang                in com_api_type_pkg.t_dict_value
    , i_label               in com_api_type_pkg.t_name
    , i_description         in com_api_type_pkg.t_full_desc
    , i_status              in com_api_type_pkg.t_dict_value
    , i_product_number      in com_api_type_pkg.t_name          default null
    , i_split_hash          in com_api_type_pkg.t_tiny_id       default null
);

procedure modify_product (
    i_id                    in com_api_type_pkg.t_short_id
    , io_seqnum             in out com_api_type_pkg.t_seqnum
    , i_lang                in com_api_type_pkg.t_dict_value
    , i_label               in com_api_type_pkg.t_name
    , i_description         in com_api_type_pkg.t_full_desc
    , i_status              in com_api_type_pkg.t_dict_value
    , i_product_number      in com_api_type_pkg.t_name          default null
);

procedure remove_product (
    i_id                    in com_api_type_pkg.t_short_id
    , i_seqnum              in com_api_type_pkg.t_seqnum
);

procedure add_product_service (
    o_id                    out com_api_type_pkg.t_short_id
    , o_seqnum              out com_api_type_pkg.t_seqnum
    , i_parent_id           in com_api_type_pkg.t_short_id
    , i_service_id          in com_api_type_pkg.t_short_id
    , i_product_id          in com_api_type_pkg.t_short_id
    , i_min_count           in com_api_type_pkg.t_tiny_id
    , i_max_count           in com_api_type_pkg.t_tiny_id
    , i_conditional_group   in com_api_type_pkg.t_dict_value default null
);

procedure modify_product_service (
    i_id                    in com_api_type_pkg.t_short_id
    , io_seqnum             in out com_api_type_pkg.t_seqnum
    , i_product_id          in com_api_type_pkg.t_short_id
    , i_min_count           in com_api_type_pkg.t_tiny_id
    , i_max_count           in com_api_type_pkg.t_tiny_id
    , i_conditional_group   in com_api_type_pkg.t_dict_value default null
);

procedure remove_product_service (
    i_id                    in com_api_type_pkg.t_short_id
    , i_seqnum              in com_api_type_pkg.t_seqnum
    , i_product_id          in com_api_type_pkg.t_short_id
);

function get_product_name (
    i_product_id  in     com_api_type_pkg.t_short_id
) return     com_api_type_pkg.t_name;

procedure compare_products(
    i_product_id1    in     com_api_type_pkg.t_short_id
    , i_product_id2  in     com_api_type_pkg.t_short_id
    , o_ref_cursor   out    sys_refcursor
);

end prd_ui_product_pkg;
/
