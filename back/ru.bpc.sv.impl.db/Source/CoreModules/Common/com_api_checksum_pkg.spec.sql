create or replace package com_api_checksum_pkg as
/***********************************************************
*  Checksum alghoritms <br />
*  Created by Filimonov A.(filimonov@bpc.ru)  at 21.09.2009 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: COM_API_CHECKSUM_PKG <br />
*  @headcom
*************************************************************/
function get_luhn_checksum(
    i_number             in      com_api_type_pkg.t_name
) return varchar2;

function get_mod11_checksum(
    i_number             in      com_api_type_pkg.t_name
) return varchar2;

function get_cbrf_checksum(
    i_bik                in      com_api_type_pkg.t_name
  , i_number             in      com_api_type_pkg.t_name
) return varchar2;

procedure check_cbrf_checksum(
    i_bik                in      com_api_type_pkg.t_name
  , i_number             in      com_api_type_pkg.t_name
);

end com_api_checksum_pkg;
/
