create or replace package prc_api_directory_pkg as
/************************************************************
 * API for directory settings <br />
 * Created by Kryukov E.(krukov@bpc.ru)  at 05.09.2013 <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: PRC_API_DIRECTORY_PKG <br />
 * @headcom
 ***********************************************************/

function get_directory_enc(
    i_id                  in     com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_boolean;

end prc_api_directory_pkg;
/
