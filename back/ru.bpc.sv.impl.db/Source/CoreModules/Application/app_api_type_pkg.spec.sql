create or replace package app_api_type_pkg as
/********************************************************* 
 *  Acquiring application API  <br /> 
 *  Created by Filimonov A.(filimonov@bpcbt.com)  at 08.04.2010 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module: app_api_type_pkg <br /> 
 *  @headcom 
 **********************************************************/

type t_app_error_rec is record(
    appl_data_id             com_api_type_pkg.t_long_id
  , parent_id                com_api_type_pkg.t_long_id
  , error_code               com_api_type_pkg.t_name
  , error_message            com_api_type_pkg.t_text
  , error_details            com_api_type_pkg.t_text
  , element_name             com_api_type_pkg.t_name
);

type t_app_error_tab is table of t_app_error_rec index by binary_integer;

type t_application_rec is record(
    id                       com_api_type_pkg.t_long_id
  , appl_type                com_api_type_pkg.t_dict_value
  , appl_number              com_api_type_pkg.t_name
  , appl_status              com_api_type_pkg.t_dict_value
  , flow_id                  com_api_type_pkg.t_tiny_id
  , reject_code              com_api_type_pkg.t_dict_value
  , agent_id                 com_api_type_pkg.t_agent_id
  , inst_id                  com_api_type_pkg.t_inst_id
  , file_id                  com_api_type_pkg.t_long_id
  , file_rec_num             com_api_type_pkg.t_short_id
  , resp_file_id             com_api_type_pkg.t_long_id
  , product_id               com_api_type_pkg.t_short_id
  , split_hash               com_api_type_pkg.t_tiny_id
  , seqnum                   com_api_type_pkg.t_tiny_id
  , user_id                  com_api_type_pkg.t_short_id
  , is_visible               com_api_type_pkg.t_boolean
  , appl_prioritized         com_api_type_pkg.t_boolean
  , execution_mode           com_api_type_pkg.t_dict_value
);

type t_appl_data_rec is record(
    appl_data_id             com_api_type_pkg.t_long_id
  , element_id               com_api_type_pkg.t_short_id
  , parent_id                com_api_type_pkg.t_long_id
  , serial_number            com_api_type_pkg.t_tiny_id
  , element_value            com_api_type_pkg.t_full_desc
  , lang                     com_api_type_pkg.t_dict_value
  , element_name             com_api_type_pkg.t_name
  , data_type                com_api_type_pkg.t_dict_value
  , element_type             com_api_type_pkg.t_dict_value
);

type t_appl_data_tab is table of t_appl_data_rec index by binary_integer;

type t_contact is record(
    id                       com_api_type_pkg.t_medium_id
  , preferred_lang           com_api_type_pkg.t_dict_value
  , job_title                com_api_type_pkg.t_dict_value
  , person_id                com_api_type_pkg.t_person_id
  , contact_type             com_api_type_pkg.t_dict_value
  , inst_id                  com_api_type_pkg.t_inst_id
);

type t_address is record(
    id                       com_api_type_pkg.t_medium_id
  , lang                     com_api_type_pkg.t_dict_value
  , address_type             com_api_type_pkg.t_dict_value
  , country                  com_api_type_pkg.t_country_code
  , region                   com_api_type_pkg.t_double_name
  , city                     com_api_type_pkg.t_double_name
  , street                   com_api_type_pkg.t_double_name
  , house                    com_api_type_pkg.t_double_name
  , apartment                com_api_type_pkg.t_double_name
  , postal_code              varchar2(10)
  , region_code              com_api_type_pkg.t_dict_value
  , inst_id                  com_api_type_pkg.t_inst_id
  , latitude                 com_api_type_pkg.t_geo_coord 
  , longitude                com_api_type_pkg.t_geo_coord
  , place_code               com_api_type_pkg.t_name
  , comments                 com_api_type_pkg.t_name
);

type t_document_rec is record(
    id                       com_api_type_pkg.t_long_id
  , document_type            com_api_type_pkg.t_dict_value
  , file_name                com_api_type_pkg.t_name
  , mime_type                com_api_type_pkg.t_dict_value
  , document_object          com_api_type_pkg.t_long_id
  , document_date            date
  , document_number          com_api_type_pkg.t_name
  , document_name            com_api_type_pkg.t_name
  , user_eds                 com_api_type_pkg.t_name
  , user_name                com_api_type_pkg.t_name
  , user_id                  com_api_type_pkg.t_short_id
  , save_path                com_api_type_pkg.t_full_desc
  , inst_id                  com_api_type_pkg.t_inst_id
);

end app_api_type_pkg;
/
