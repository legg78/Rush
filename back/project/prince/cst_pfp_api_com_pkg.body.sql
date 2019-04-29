create or replace package body cst_pfp_api_com_pkg as

function get_card_id_by_instance_id (
    i_card_instance_id      in     com_api_type_pkg.t_medium_id
) return com_api_type_pkg.t_medium_id
is
    l_card_instance           iss_api_type_pkg.t_card_instance;
begin
    l_card_instance :=
        iss_api_card_instance_pkg.get_instance (
            i_id   => i_card_instance_id
        );

    return l_card_instance.card_id;
end get_card_id_by_instance_id;

end cst_pfp_api_com_pkg;
/
