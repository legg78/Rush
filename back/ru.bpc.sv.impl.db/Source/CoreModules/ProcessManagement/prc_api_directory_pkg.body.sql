create or replace package body prc_api_directory_pkg as
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
) return com_api_type_pkg.t_boolean is
begin
    for rec in (
        select decode(
            a.encryption_type
          , prc_api_const_pkg.DIRECTORY_ENCR, com_api_type_pkg.TRUE
          , prc_api_const_pkg.DIRECTORY_NOTENCR, com_api_type_pkg.FALSE) as res
          from prc_directory_vw a
        where id = i_id)
    loop
        return rec.res;
    end loop;

    com_api_error_pkg.raise_error(
        i_error      => 'DIRECTORY_NOT_FOUND'
      , i_env_param1 => i_id
    );

end get_directory_enc;

end prc_api_directory_pkg;
/
