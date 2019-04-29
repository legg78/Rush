create or replace package cst_pfp_api_com_pkg as

function get_card_id_by_instance_id (
    i_card_instance_id      in     com_api_type_pkg.t_medium_id
) return com_api_type_pkg.t_medium_id;

end cst_pfp_api_com_pkg;
/
