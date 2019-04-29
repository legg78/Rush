create or replace package ost_api_agent_pkg as

function get_inst_id(
    i_agent_id          in      com_api_type_pkg.t_agent_id
) return com_api_type_pkg.t_inst_id;

/*
 * Function return agent ID; it uses i_agent_id for searching if is not NULL,
 * otherwise, it uses i_agent_number.
 */
function get_agent_id(
    i_agent_id          in      com_api_type_pkg.t_agent_id
  , i_agent_number      in      com_api_type_pkg.t_name
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_mask_error        in      com_api_type_pkg.t_boolean default com_api_type_pkg.FALSE
) return com_api_type_pkg.t_agent_id;

function generate_agent_number(
    i_agent_id          in      com_api_type_pkg.t_medium_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_eff_date          in      date                            default com_api_sttl_day_pkg.get_sysdate() 
) return com_api_type_pkg.t_name;

procedure check_agent_id(
    i_agent_id          in      com_api_type_pkg.t_agent_id
);

end ost_api_agent_pkg;
/
