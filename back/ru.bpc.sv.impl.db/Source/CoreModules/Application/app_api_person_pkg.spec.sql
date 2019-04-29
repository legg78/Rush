create or replace package app_api_person_pkg as

/*******************************************************************
<pre>
*  API for application's person
*  Created by Filimonov A.(filimonov@bpc.ru)  at 22.09.2009
*  Last changed by $Author$
*  $LastChangedDate::                           $
*  Revision: $LastChangedRevision$
*  Module: APP_API_PERSON_PKG
*  @headcom
</pre>
******************************************************************/


/******************************************************************
<pre>
* Process person data
* creating new person or updating existing
* @param i_appl_data_id         Identifier of record in application data
* @param i_parent_appl_data_id  Identifier of parent record in application data
* @param io_appl_data           Array store whole application data
* @param o_person_id            Person identifier
</pre>
*******************************************************************/
procedure process_person(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , io_person_id           in out nocopy com_api_type_pkg.t_person_id
);

procedure process_dummy_person(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_pool_number          in            com_api_type_pkg.t_short_id
  , io_person_id              out nocopy com_api_type_pkg.t_person_id
);

end app_api_person_pkg;
/
