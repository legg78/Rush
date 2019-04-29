create or replace package prd_api_customer_pkg is
/*********************************************************
*  API for customers <br />
*  Created by Kopachev D.(kopachev@bpcsv.com)  at 17.11.2010 <br />
*  Module: PRD_API_CUSTOMER_PKG <br />
*  @headcom
**********************************************************/

procedure set_last_modify(
    i_customer_id          in     com_api_type_pkg.t_medium_id
);

/* Create customer
 * @param o_id
 * @param o_seqnum
 * @param i_entity_type
 * @param i_object_id
 * @param io_customer_number
 * @param i_inst_id
 * @param i_category
 * @param i_relation
 * @param i_resident
 * @param i_nationality
 * @param i_credit_rating
 * @param i_money_laundry_risk
 * @param i_money_laundry_reason
 * @param i_status
 * @param i_ext_entity_type
 * @param i_ext_object_id
 */
procedure add_customer (
    o_id                      out com_api_type_pkg.t_medium_id
  , o_seqnum                  out com_api_type_pkg.t_seqnum
  , i_entity_type          in     com_api_type_pkg.t_dict_value
  , i_object_id            in     com_api_type_pkg.t_long_id
  , io_customer_number     in out com_api_type_pkg.t_name
  , i_inst_id              in     com_api_type_pkg.t_inst_id
  , i_category             in     com_api_type_pkg.t_dict_value
  , i_relation             in     com_api_type_pkg.t_dict_value
  , i_resident             in     com_api_type_pkg.t_boolean
  , i_nationality          in     com_api_type_pkg.t_curr_code
  , i_credit_rating        in     com_api_type_pkg.t_dict_value
  , i_money_laundry_risk   in     com_api_type_pkg.t_dict_value
  , i_money_laundry_reason in     com_api_type_pkg.t_dict_value
  , i_status               in     com_api_type_pkg.t_dict_value := null
  , i_ext_entity_type      in     com_api_type_pkg.t_dict_value := null
  , i_ext_object_id        in     com_api_type_pkg.t_long_id    := null
  , i_product_type         in     com_api_type_pkg.t_dict_value := null
  , i_employment_status    in     com_api_type_pkg.t_dict_value := null
  , i_employment_period    in     com_api_type_pkg.t_dict_value := null
  , i_residence_type       in     com_api_type_pkg.t_dict_value := null
  , i_marital_status       in     com_api_type_pkg.t_dict_value := null
  , i_marital_status_date  in     date                          := null
  , i_income_range         in     com_api_type_pkg.t_dict_value := null
  , i_number_of_children   in     com_api_type_pkg.t_dict_value := null
);

/* Modify customer
 * @param i_id
 * @param io_seqnum
 * @param i_entity_type
 * @param i_object_id
 * @param i_customer_number
 * @param i_category
 * @param i_relation
 * @param i_resident
 * @param i_nationality
 * @param i_credit_rating
 * @param i_money_laundry_risk
 * @param i_money_laundry_reason
 * @param i_status
 */
procedure modify_customer (
    i_id                   in     com_api_type_pkg.t_medium_id
  , io_seqnum              in out com_api_type_pkg.t_seqnum
  , i_object_id            in     com_api_type_pkg.t_long_id
  , i_customer_number      in     com_api_type_pkg.t_name
  , i_category             in     com_api_type_pkg.t_dict_value
  , i_relation             in     com_api_type_pkg.t_dict_value
  , i_resident             in     com_api_type_pkg.t_boolean
  , i_nationality          in     com_api_type_pkg.t_curr_code
  , i_credit_rating        in     com_api_type_pkg.t_dict_value
  , i_money_laundry_risk   in     com_api_type_pkg.t_dict_value
  , i_money_laundry_reason in     com_api_type_pkg.t_dict_value
  , i_status               in     com_api_type_pkg.t_dict_value := null
  , i_ext_entity_type      in     com_api_type_pkg.t_dict_value := null
  , i_ext_object_id        in     com_api_type_pkg.t_long_id    := null
  , i_product_type         in     com_api_type_pkg.t_dict_value := null
  , i_employment_status    in     com_api_type_pkg.t_dict_value := null
  , i_employment_period    in     com_api_type_pkg.t_dict_value := null
  , i_residence_type       in     com_api_type_pkg.t_dict_value := null
  , i_marital_status       in     com_api_type_pkg.t_dict_value := null
  , i_marital_status_date  in     date                          := null
  , i_income_range         in     com_api_type_pkg.t_dict_value := null
  , i_number_of_children   in     com_api_type_pkg.t_dict_value := null
);

/* Remove customer
 * @param i_id
 * @param i_seqnum
 */
procedure remove_customer (
    i_id                  in com_api_type_pkg.t_medium_id
  , i_seqnum              in com_api_type_pkg.t_seqnum
);

/*
 * Set customer status
 * @param i_id     Customer identifier
 * @param i_status Customer status
 */
procedure set_customer_status (
    i_id                   in     com_api_type_pkg.t_medium_id
  , i_status               in     com_api_type_pkg.t_dict_value
);

/* Remove customer
 * @param i_id
 * @param i_seqnum
 * @param i_contract_id
 */
procedure set_main_contract (
    i_id                  in com_api_type_pkg.t_medium_id
  , i_seqnum              in com_api_type_pkg.t_seqnum
  , i_contract_id         in com_api_type_pkg.t_medium_id
);

procedure get_customer_object (
    i_customer_id         in     com_api_type_pkg.t_medium_id
  , o_object_id              out com_api_type_pkg.t_long_id
  , o_entity_type            out com_api_type_pkg.t_dict_value
  , i_mask_error          in     com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
);

procedure find_customer (
    i_client_id_type      in      com_api_type_pkg.t_dict_value
  , i_client_id_value     in      com_api_type_pkg.t_full_desc
  , i_inst_id             in      com_api_type_pkg.t_inst_id
  , i_raise_error         in      com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
  , i_error_value         in      com_api_type_pkg.t_medium_id  default null
  , o_customer_id            out  com_api_type_pkg.t_medium_id
  , o_split_hash             out  com_api_type_pkg.t_tiny_id
  , o_inst_id                out  com_api_type_pkg.t_inst_id
  , o_iss_network_id         out  com_api_type_pkg.t_network_id
);

procedure get_customer_data (
    i_customer_id         in      com_api_type_pkg.t_medium_id
  , i_lang                in      com_api_type_pkg.t_dict_value
  , o_category               out  com_api_type_pkg.t_dict_value
  , o_person_first_name      out  com_api_type_pkg.t_name
  , o_person_second_name     out  com_api_type_pkg.t_name
  , o_person_surname         out  com_api_type_pkg.t_name
  , o_person_gender          out  com_api_type_pkg.t_dict_value
  , o_customer_number        out  com_api_type_pkg.t_name
);

procedure load_customer_data (
    i_customer_id         in            com_api_type_pkg.t_medium_id
  , i_lang                in            com_api_type_pkg.t_dict_value
  , io_params             in out nocopy com_api_type_pkg.t_param_tab
);

function get_customer_number(
    i_customer_id           in     com_api_type_pkg.t_medium_id
  , i_inst_id               in     com_api_type_pkg.t_inst_id    default null
  , i_mask_error            in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
) return  com_api_type_pkg.t_name;

function get_customer_id(
    i_customer_number       in     com_api_type_pkg.t_name
  , i_inst_id               in     com_api_type_pkg.t_inst_id    default null
  , i_mask_error            in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
) return  com_api_type_pkg.t_medium_id;

function get_customer_id(
    i_ext_entity_type       in     com_api_type_pkg.t_dict_value
  , i_ext_object_id         in     com_api_type_pkg.t_long_id
  , i_inst_id               in     com_api_type_pkg.t_inst_id
) return com_api_type_pkg.t_medium_id;

function get_customer_id(
    i_entity_type           in     com_api_type_pkg.t_dict_value
  , i_object_id             in     com_api_type_pkg.t_long_id
  , i_inst_id               in     com_api_type_pkg.t_inst_id    default null
  , i_mask_error            in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_medium_id;

procedure find_customer(
    i_acq_inst_id           in     com_api_type_pkg.t_inst_id
  , i_host_id               in     com_api_type_pkg.t_tiny_id
  , o_customer_id              out com_api_type_pkg.t_medium_id
);

procedure find_customer(
    i_acq_inst_id           in     com_api_type_pkg.t_inst_id
  , i_payment_order_id      in     com_api_type_pkg.t_tiny_id
  , o_customer_id              out com_api_type_pkg.t_medium_id
);

/*
 * It closes customer (marks it as inactive) and all its entities and services.
 */
procedure close_customer(
    i_customer_id           in     com_api_type_pkg.t_medium_id
  , i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_end_date              in     date
  , i_params                in     com_api_type_pkg.t_param_tab
);

/*
 * It rises an error if customer is already associated with another agent or vice versa.
 */
procedure check_association(
    i_customer_id           in     com_api_type_pkg.t_medium_id
  , i_ext_entity_type       in     com_api_type_pkg.t_dict_value
  , i_ext_object_id         in     com_api_type_pkg.t_long_id
);

procedure find_customer(
    i_purpose_id                    com_api_type_pkg.t_long_id
  , o_customer_id              out  com_api_type_pkg.t_medium_id
  , o_split_hash               out  com_api_type_pkg.t_tiny_id
  , o_inst_id                  out  com_api_type_pkg.t_inst_id
  , o_iss_network_id           out  com_api_type_pkg.t_network_id
);

function get_customer_aging(
    i_customer_id           in     com_api_type_pkg.t_medium_id
) return com_api_type_pkg.t_tiny_id;

function get_customer_data(
    i_customer_id         in      com_api_type_pkg.t_medium_id
  , i_inst_id             in      com_api_type_pkg.t_inst_id     default null
  , i_mask_error          in      com_api_type_pkg.t_boolean     default com_api_const_pkg.TRUE
) return prd_api_type_pkg.t_customer;

end;
/
