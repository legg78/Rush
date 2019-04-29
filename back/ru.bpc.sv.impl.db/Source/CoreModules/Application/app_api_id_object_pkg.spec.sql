create or replace package app_api_id_object_pkg as
/*********************************************************
*  Application - process ID <br />
*  Created by Kryukov E.(krukov@bpc.ru)  at 21.03.2011 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: APP_API_ID_OBJECT_PKG <br />
*  @headcom
**********************************************************/

/*
 * 
 * @param i_appl_data_id
 * @param i_inst_id
 * @param io_appl_data
 * @param o_company_id  
 */

procedure process_id_object(
    i_appl_data_id  in      com_api_type_pkg.t_long_id
  , i_entity_type   in      com_api_type_pkg.t_dict_value
  , i_object_id     in      com_api_type_pkg.t_long_id
  , o_id               out  com_api_type_pkg.t_long_id
);

end app_api_id_object_pkg;
/
