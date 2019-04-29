create or replace package prd_api_contract_pkg is
/*********************************************************
*  API for contracts <br />
*  Created by Kopachev D.(kopachev@bpc.ru)  at 15.11.2010 <br />
*  Last changed by $Author: khougaev $ <br />
*  $LastChangedDate: 2010-04-27 17:29:49 +0400#$ <br />
*  Revision: $LastChangedRevision: 8079 $ <br />
*  Module: PRD_API_CONTRACT_PKG <br />
*  @headcom
**********************************************************/
procedure add_contract (
    o_id                       out com_api_type_pkg.t_medium_id
    , o_seqnum                 out com_api_type_pkg.t_seqnum
    , i_product_id          in     com_api_type_pkg.t_short_id
    , i_start_date          in     date
    , i_end_date            in     date
    , io_contract_number    in out com_api_type_pkg.t_name
    , i_contract_type       in     com_api_type_pkg.t_dict_value
    , i_inst_id             in     com_api_type_pkg.t_inst_id
    , i_agent_id            in     com_api_type_pkg.t_agent_id
    , i_customer_id         in     com_api_type_pkg.t_medium_id
    , i_lang                in     com_api_type_pkg.t_dict_value
    , i_label               in     com_api_type_pkg.t_name
    , i_description         in     com_api_type_pkg.t_full_desc
);

procedure modify_contract (
    i_id                    in     com_api_type_pkg.t_medium_id
    , io_seqnum             in out com_api_type_pkg.t_seqnum
    , i_product_id          in     com_api_type_pkg.t_short_id
    , i_end_date            in     date
    , i_contract_number     in     com_api_type_pkg.t_name       default null
    , i_agent_id            in     com_api_type_pkg.t_agent_id   default null
    , i_lang                in     com_api_type_pkg.t_dict_value
    , i_label               in     com_api_type_pkg.t_name
    , i_description         in     com_api_type_pkg.t_full_desc
);

procedure remove_contract (
    i_id                    in     com_api_type_pkg.t_medium_id
    , i_seqnum              in     com_api_type_pkg.t_seqnum
);

function get_contract_number(
    i_contract_id           in     com_api_type_pkg.t_medium_id
) return com_api_type_pkg.t_name;

/*
 * Function return contract record by i_contract_id or i_contract_number with i_inst_id (to guarantee uniqueness).
 * @param i_contract_id     for searching by primary key
 * @param i_contract_number for searching by number, it must be used together with i_inst_id parameter
 */
function get_contract(
    i_contract_id           in     com_api_type_pkg.t_medium_id
  , i_contract_number       in     com_api_type_pkg.t_name       default null
  , i_inst_id               in     com_api_type_pkg.t_inst_id    default null
  , i_raise_error           in     com_api_type_pkg.t_boolean    default com_api_type_pkg.FALSE
) return prd_api_type_pkg.t_contract;

/*
 * Procedure closes contract and all linked entities and services.
 */
procedure close_contract(
    i_contract_id   in      com_api_type_pkg.t_medium_id
  , i_inst_id       in      com_api_type_pkg.t_inst_id
  , i_end_date      in      date
  , i_params        in      com_api_type_pkg.t_param_tab
);

end prd_api_contract_pkg;
/
