create or replace package prd_ui_service_pkg is
/*********************************************************
*  UI for services  <br />
*  Created by Kopachev D.(kopachev@bpcbt.com)  at 15.11.2010 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: PRD_UI_SERVICE_PKG <br />
*  headcom
**********************************************************/
procedure check_min_count(
    i_service_id            in      com_api_type_pkg.t_short_id
  , i_contract_id           in      com_api_type_pkg.t_medium_id
);

procedure check_max_count(
    i_service_id            in      com_api_type_pkg.t_short_id
  , i_contract_id           in      com_api_type_pkg.t_medium_id
);

procedure check_services_intersect(
    i_service_id            in      com_api_type_pkg.t_tiny_id
  , i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_id             in      com_api_type_pkg.t_long_id
);

function check_conditional_service(
    i_service_id            in      com_api_type_pkg.t_short_id
  , i_product_id            in      com_api_type_pkg.t_short_id
  , i_service_count         in      com_api_type_pkg.t_count
) return com_api_type_pkg.t_boolean;

procedure add_service (
    o_id                       out  com_api_type_pkg.t_short_id
  , o_seqnum                   out  com_api_type_pkg.t_seqnum
  , i_service_type_id       in      com_api_type_pkg.t_tiny_id
  , i_template_appl_id      in      com_api_type_pkg.t_long_id
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_status                in      com_api_type_pkg.t_dict_value
  , i_lang                  in      com_api_type_pkg.t_dict_value
  , i_label                 in      com_api_type_pkg.t_name
  , i_description           in      com_api_type_pkg.t_full_desc
  , i_service_number        in      com_api_type_pkg.t_name          default null
  , i_split_hash            in      com_api_type_pkg.t_tiny_id       default null
);

procedure modify_service (
    i_id                    in      com_api_type_pkg.t_short_id
  , io_seqnum               in out  com_api_type_pkg.t_seqnum
  , i_service_type_id       in      com_api_type_pkg.t_tiny_id
  , i_template_appl_id      in      com_api_type_pkg.t_long_id
  , i_status                in      com_api_type_pkg.t_dict_value
  , i_lang                  in      com_api_type_pkg.t_dict_value
  , i_label                 in      com_api_type_pkg.t_name
  , i_description           in      com_api_type_pkg.t_full_desc
  , i_service_number        in      com_api_type_pkg.t_name         default null
);

procedure remove_service (
    i_id                    in      com_api_type_pkg.t_short_id
  , i_seqnum                in      com_api_type_pkg.t_seqnum
);

procedure set_service_object (
    i_service_id            in      com_api_type_pkg.t_short_id
  , i_contract_id           in      com_api_type_pkg.t_medium_id
  , i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_id             in      com_api_type_pkg.t_long_id
  , i_start_date            in      date
  , i_end_date              in      date
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_params                in      com_api_type_pkg.t_param_tab
);

procedure set_service_object (
    i_service_id            in      com_api_type_pkg.t_short_id
  , i_contract_id           in      com_api_type_pkg.t_medium_id
  , i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_id             in      com_api_type_pkg.t_long_id
  , i_start_date            in      date
  , i_end_date              in      date
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_params                in      com_api_type_pkg.t_param_tab
  , i_need_postponed_event  in      com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , o_postponed_event          out  evt_api_type_pkg.t_postponed_event
);

/*
 * Procedure adds new visible flag (or modifies existing one) for an attribute 
 * if it differs from default value in PRD_ATTRIBUTE(_VW)  
 */
procedure set_service_attribute(
    i_service_id            in     com_api_type_pkg.t_short_id
  , i_attribute_id          in     com_api_type_pkg.t_short_id
  , i_is_visible            in     com_api_type_pkg.t_boolean
);

end prd_ui_service_pkg;
/
