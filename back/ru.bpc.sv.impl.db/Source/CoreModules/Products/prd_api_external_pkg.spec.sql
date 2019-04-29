create or replace package prd_api_external_pkg is
/*************************************************************
*  API for products external integration <br />
*  Created by Gerbeev I. (gerbeev@bpcbt.com)  at 18.05.2018 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: PRD_API_EXTERNAL_PKG  <br />
*  @headcom
**************************************************************/

procedure add_customer(
    o_id                       out com_api_type_pkg.t_medium_id
  , o_seqnum                   out com_api_type_pkg.t_seqnum
  , i_entity_type           in     com_api_type_pkg.t_dict_value
  , i_object_id             in     com_api_type_pkg.t_long_id
  , io_customer_number      in out com_api_type_pkg.t_name
  , i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_category              in     com_api_type_pkg.t_dict_value
  , i_relation              in     com_api_type_pkg.t_dict_value
  , i_resident              in     com_api_type_pkg.t_boolean
  , i_nationality           in     com_api_type_pkg.t_curr_code
  , i_credit_rating         in     com_api_type_pkg.t_dict_value
  , i_money_laundry_risk    in     com_api_type_pkg.t_dict_value
  , i_money_laundry_reason  in     com_api_type_pkg.t_dict_value
  , i_status                in     com_api_type_pkg.t_dict_value := null
  , i_ext_entity_type       in     com_api_type_pkg.t_dict_value := null
  , i_ext_object_id         in     com_api_type_pkg.t_long_id    := null
  , i_product_type          in     com_api_type_pkg.t_dict_value := null
  , i_employment_status     in     com_api_type_pkg.t_dict_value := null
  , i_employment_period     in     com_api_type_pkg.t_dict_value := null
  , i_residence_type        in     com_api_type_pkg.t_dict_value := null
  , i_marital_status        in     com_api_type_pkg.t_dict_value := null
  , i_marital_status_date   in     date                          := null
  , i_income_range          in     com_api_type_pkg.t_dict_value := null
  , i_number_of_children    in     com_api_type_pkg.t_dict_value := null
);

procedure add_contract(
    o_id                       out com_api_type_pkg.t_medium_id
  , o_seqnum                   out com_api_type_pkg.t_seqnum
  , i_product_id            in     com_api_type_pkg.t_short_id
  , i_start_date            in     date
  , i_end_date              in     date
  , io_contract_number      in out com_api_type_pkg.t_name
  , i_contract_type         in     com_api_type_pkg.t_dict_value
  , i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_agent_id              in     com_api_type_pkg.t_agent_id
  , i_customer_id           in     com_api_type_pkg.t_medium_id
  , i_lang                  in     com_api_type_pkg.t_dict_value
  , i_label                 in     com_api_type_pkg.t_name
  , i_description           in     com_api_type_pkg.t_full_desc
);

procedure set_service_object(
    i_service_id            in     com_api_type_pkg.t_short_id
  , i_contract_id           in     com_api_type_pkg.t_medium_id
  , i_entity_type           in     com_api_type_pkg.t_dict_value
  , i_object_id             in     com_api_type_pkg.t_long_id
  , i_start_date            in     date
  , i_end_date              in     date
  , i_inst_id               in     com_api_type_pkg.t_inst_id
);

end prd_api_external_pkg;
/
