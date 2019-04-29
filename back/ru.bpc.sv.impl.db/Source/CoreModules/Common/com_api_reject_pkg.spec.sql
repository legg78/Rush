create or replace package com_api_reject_pkg is
/*********************************************************
*  API for Reject Management module <br />
*  Created by Mashonkin V.(mashonkin@bpcbt.com)  at 17.06.2015 <br />
*  Last changed by $Author: mashonkin $ <br />
*  $LastChangedDate:: 2015-06-17 19:28:48 +0300#$ <br />
*  Revision: $LastChangedRevision: 52735 $ <br />
*  Module: com_api_reject_pkg <br />
*  @headcom
**********************************************************/

    C_REJECT_CODE_INVALID_FORMAT        constant com_api_type_pkg.t_text := '01';
    C_MSG_MANDAT_FIELD_NOT_PRESENT      constant com_api_type_pkg.t_text := 'MANDATORY_FIELD_NOT_PRESENT';
    C_MSG_DICTIONARY_NOT_EXISTS         constant com_api_type_pkg.t_text := 'DICTIONARY_DOES_NOT_EXISTS';
    C_MSG_CODE_NOT_EXISTS_IN_DICT       constant com_api_type_pkg.t_text := 'CODE_NOT_EXISTS_IN_DICT'; 
    C_MSG_CHECK_DICT_FIELD_FAILED       constant com_api_type_pkg.t_text := 'CHECK_DICT_FIELD_FAILED';
    C_DEF_SCHEME                        constant com_api_type_pkg.t_text := 'Servired';

    C_MSG_FIELD_IS_NOT_NUMBER           constant com_api_type_pkg.t_text := 'FIELD_IS_NOT_NUMBER';
    C_MSG_FIELD_IS_NOT_DATE             constant com_api_type_pkg.t_text := 'FIELD_IS_NOT_DATE';
    C_MSG_FIELD_IS_NOT_HEX              constant com_api_type_pkg.t_text := 'FIELD_IS_NOT_HEX';
    C_MSG_FIELD_IS_EMPTY                constant com_api_type_pkg.t_text := 'FIELD_IS_EMPTY';

    C_NETW_VISA                         constant com_api_type_pkg.t_text := 'VISA';
    C_NETW_MASTERCARD                   constant com_api_type_pkg.t_text := 'MASTERCARD';

    REJECT_TYPE_PRIMARY_VALIDATION  constant com_api_type_pkg.t_name := 'RJTP0001';
    REJECT_TYPE_BUSINES_VALIDATION  constant com_api_type_pkg.t_name := 'RJTP0002';
    REJECT_TYPE_REGULATORS_SCHEMES  constant com_api_type_pkg.t_name := 'RJTP0003';
    
    REJECT_RESOLUT_MODE_FORWARD     constant com_api_type_pkg.t_name := 'RJMD0001';
    REJECT_RESOLUT_MODE_CANCELED    constant com_api_type_pkg.t_name := 'RJMD0002';
    REJECT_RESOLUT_MODE_NO_ACTIONS  constant com_api_type_pkg.t_name := 'RJMD0003';
    
    REJECT_STATUS_OPENED            constant com_api_type_pkg.t_name := 'RJST0001';
    REJECT_STATUS_CLOSED            constant com_api_type_pkg.t_name := 'RJST0002';
    REJECT_STATUS_RESOLVED          constant com_api_type_pkg.t_name := 'RJST0003';

    REJECT_CODE_INVALID_FORMAT      constant com_api_type_pkg.t_name := 'RJCD0001';

    EVENT_REGISTER_REJECT           constant com_api_type_pkg.t_name := 'EVNT1916';

    OPER_STATUS_REJECTED            constant com_api_type_pkg.t_name := 'OPST0700';

    function get_iss_network_by_bin (
        i_bin in com_api_type_pkg.t_tiny_id
    ) return com_api_type_pkg.t_tiny_id;


end com_api_reject_pkg;
/