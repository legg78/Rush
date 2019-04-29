create or replace package ost_api_institution_pkg as
/*********************************************************
 *  API for institution <br />
 *  Created by Filimonov A.(filimonov@bpcbt.com) at 09.09.2009 <br />
 *  Last changed by $Author: alalykin $ <br />
 *  $LastChangedDate:: 2016-02-02 14:00:00 +0300#$ <br />
 *  Revision: $LastChangedRevision: 1 $ <br />
 *  Module: OST_API_INSTITUTION_PKG <br />
 *  @headcom
 **********************************************************/

function get_network_inst_id(
    i_network_id        in      com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_inst_id;

function get_inst_network (
    i_inst_id           in      com_api_type_pkg.t_inst_id
) return com_api_type_pkg.t_tiny_id;

function get_default_agent(
    i_inst_id           in      com_api_type_pkg.t_inst_id
) return com_api_type_pkg.t_agent_id;

function get_parent_inst_id(
    i_inst_id           in      com_api_type_pkg.t_inst_id
) return com_api_type_pkg.t_inst_id;

--function get_root_inst_id(
--    i_inst_id           in      com_api_type_pkg.t_inst_id
--) return com_api_type_pkg.t_inst_id;

function get_object_inst_id(
    i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_mask_errors       in      com_api_type_pkg.t_boolean     default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_inst_id;

function get_sandbox(
    i_inst_id           in      com_api_type_pkg.t_inst_id := null
) return com_api_type_pkg.t_inst_id;

/*
 * Procedure checks if specified institution exists in the system, and raises an error if it is not.
 */
procedure check_institution(
    i_inst_id           in      com_api_type_pkg.t_inst_id
);

-- Check that current user has access to specified institution, and raises an error if it is not.
procedure check_inst_id(
    i_inst_id           in      com_api_type_pkg.t_inst_id
);

-- Get institution number by id
function get_inst_number(
    i_inst_id           in      com_api_type_pkg.t_inst_id
)return com_api_type_pkg.t_mcc
result_cache;

-- Check if this operation is allowed for the indicated status of the institution
procedure check_status(
    i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_data_action       in      com_api_type_pkg.t_dict_value
);

-- Check if this operation is allowed for the indicated status of the institution
function check_status(
    i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_data_action       in      com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_boolean
result_cache;

end ost_api_institution_pkg;
/
