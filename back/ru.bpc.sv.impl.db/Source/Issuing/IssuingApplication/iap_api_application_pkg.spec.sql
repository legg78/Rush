create or replace package iap_api_application_pkg as
/**********************************************************
*  API for issuer application <br />
*  Created by Kryukov E.(krukov@bpc.ru)  at 26.02.2010 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: IAP_API_APPLICATION_PKG <br />
*  @headcom
***********************************************************/

/*
 * Processing of issuers applications
 * @param i_appl_id     Application identifier
 * @param io_appl_data  The table of application data
 */
procedure process_application(
    i_appl_id              in            com_api_type_pkg.t_long_id default null
);

/*
 * Processing of rejected applications
 * @param i_appl_id     Application identifier
 */
procedure process_rejected_application(
    i_appl_id              in            com_api_type_pkg.t_long_id
);

end iap_api_application_pkg;
/
