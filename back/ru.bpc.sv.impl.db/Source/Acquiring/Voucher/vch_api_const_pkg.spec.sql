create or replace package vch_api_const_pkg is
/*********************************************************
 *  Constants for accounts <br />
 *  Created by Fomichev A.(fomichev@bpcbt.com)  at 19.03.2012 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: vch_api_const_pkg  <br />
 *  @headcom
 **********************************************************/

BATCH_STATUS_KEY        constant com_api_type_pkg.t_dict_value := 'VCBS';

BATCH_STATUS_CREATED    constant com_api_type_pkg.t_dict_value := 'VCBS0001';
BATCH_STATUS_COMPLETED  constant com_api_type_pkg.t_dict_value := 'VCBS0002';
BATCH_STATUS_WAITING    constant com_api_type_pkg.t_dict_value := 'VCBS0003';
BATCH_STATUS_RETURNED   constant com_api_type_pkg.t_dict_value := 'VCBS0004';
BATCH_STATUS_PROCESSED  constant com_api_type_pkg.t_dict_value := 'VCBS0005';
BATCH_STATUS_ERROR      constant com_api_type_pkg.t_dict_value := 'VCBS0006';

REASON_STATUS_KEY       constant com_api_type_pkg.t_dict_value := 'VCSR';

end; 
/
