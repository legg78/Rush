create or replace package prd_api_type_pkg is
/********************************************************* 
 *  Product types API  <br />
 *  Created by Fomichev A.(fomichev@bpcbt.com)  at 26.01.2011 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: prd_api_type_pkg <br />
 *  @headcom
 **********************************************************/

type t_contract is record(
    id                    com_api_type_pkg.t_medium_id
  , seqnum                com_api_type_pkg.t_seqnum
  , product_id            com_api_type_pkg.t_short_id
  , start_date            date
  , end_date              date
  , contract_number       com_api_type_pkg.t_name
  , contract_type         com_api_type_pkg.t_dict_value
  , inst_id               com_api_type_pkg.t_inst_id
  , agent_id              com_api_type_pkg.t_short_id
  , customer_id           com_api_type_pkg.t_medium_id
  , split_hash            com_api_type_pkg.t_tiny_id
);

type t_customer is record(
    id                    com_api_type_pkg.t_medium_id
  , seqnum                com_api_type_pkg.t_tiny_id
  , entity_type           com_api_type_pkg.t_dict_value
  , object_id             com_api_type_pkg.t_long_id
  , customer_number       com_api_type_pkg.t_name
  , contract_id           com_api_type_pkg.t_medium_id
  , inst_id               com_api_type_pkg.t_tiny_id
  , split_hash            com_api_type_pkg.t_tiny_id
  , category              com_api_type_pkg.t_dict_value
  , relation              com_api_type_pkg.t_dict_value
  , resident              com_api_type_pkg.t_boolean
  , nationality           com_api_type_pkg.t_curr_code
  , credit_rating         com_api_type_pkg.t_dict_value
  , money_laundry_risk    com_api_type_pkg.t_dict_value
  , money_laundry_reason  com_api_type_pkg.t_dict_value
  , status                com_api_type_pkg.t_dict_value
  , ext_entity_type       com_api_type_pkg.t_dict_value
  , ext_object_id         com_api_type_pkg.t_long_id
  , reg_date              date
  , employment_status     com_api_type_pkg.t_dict_value
  , employment_period     com_api_type_pkg.t_dict_value
  , residence_type        com_api_type_pkg.t_dict_value
  , marital_status        com_api_type_pkg.t_dict_value
  , marital_status_date   date
  , income_range          com_api_type_pkg.t_dict_value
  , number_of_children    com_api_type_pkg.t_dict_value
);

type t_attribute is record(
    id                    com_api_type_pkg.t_short_id
  , service_type_id       com_api_type_pkg.t_short_id
  , attr_name             com_api_type_pkg.t_name
  , data_type             com_api_type_pkg.t_dict_value
  , entity_type           com_api_type_pkg.t_dict_value
  , object_type           com_api_type_pkg.t_dict_value
  , definition_level      com_api_type_pkg.t_dict_value
);

type t_product is record(
    id              com_api_type_pkg.t_short_id
  , product_type    com_api_type_pkg.t_dict_value
  , contract_type   com_api_type_pkg.t_dict_value
  , parent_id       com_api_type_pkg.t_short_id
  , seqnum          com_api_type_pkg.t_tiny_id
  , inst_id         com_api_type_pkg.t_inst_id
  , status          com_api_type_pkg.t_dict_value
  , product_number  com_api_type_pkg.t_name
);

type t_object is record(
    object_id       com_api_type_pkg.t_medium_id
  , object_type     com_api_type_pkg.t_dict_value
  , split_hash      com_api_type_pkg.t_tiny_id
  , product_id      com_api_type_pkg.t_short_id
  , contract_id     com_api_type_pkg.t_medium_id
  , contract_type   com_api_type_pkg.t_dict_value
);

type t_service is record(
    id                    com_api_type_pkg.t_short_id
  , seqnum                com_api_type_pkg.t_tiny_id
  , service_type_id       com_api_type_pkg.t_short_id
  , inst_id               com_api_type_pkg.t_inst_id
  , status                com_api_type_pkg.t_dict_value
  , service_number        com_api_type_pkg.t_name
  , split_hash            com_api_type_pkg.t_tiny_id
);

end prd_api_type_pkg;
/
