create or replace package ins_api_const_pkg is
/********************************************************* 
 *   constants for INS module (insurance)  <br /> 
 *  Created by Kopachev D.(kopachev@bpcbt.com)  at 26.10.2011 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module: ins_api_const_pkg  <br /> 
 *  @headcom 
 **********************************************************/

    INSURANCE_COMPANY_CONTRACT     constant com_api_type_pkg.t_dict_value := 'CNTPINSR';

    INS_COMPANY_STTL_SERVICE_TYPE  constant com_api_type_pkg.t_long_id    := 10000955;
    INS_CREDIT_SERVICE_TYPE        constant com_api_type_pkg.t_long_id    := 10000956;

    INS_PROCESS_PROCEDURE_NAME     constant com_api_type_pkg.t_name       := 'INS_PRC_PREMIUM_PKG.PROCESS';

    INS_ATTRIBUTE_BASE             constant com_api_type_pkg.t_name       := 'CIN_INSURANCE_BASE';

    INS_BASE_TOTAL_AMOUNT_DUE      constant com_api_type_pkg.t_dict_value := 'INSB0001';
    INS_BASE_CREDIT_LIMIT          constant com_api_type_pkg.t_dict_value := 'INSB0002';
    INS_BASE_UNUSED_CREDIT_LIMIT   constant com_api_type_pkg.t_dict_value := 'INSB0003';

    INS_ATTRIBUTE_FEE              constant com_api_type_pkg.t_dict_value := 'FETP1601';

end;
/
