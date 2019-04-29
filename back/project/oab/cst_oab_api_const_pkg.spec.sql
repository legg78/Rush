create or replace package cst_oab_api_const_pkg as
/*********************************************************
*  OAB custom API constants <br />
*  Created by Gogolev I. (i.gogolev@bpcbt.com) at 04.09.2018 <br />
*  Module: CST_OAB_API_CONST_PKG <br />
*  @headcom
**********************************************************/
CRLF                            constant com_api_type_pkg.t_name := chr(13) || chr(10);

SEPARATE_CHAR_DEFAULT           constant com_api_type_pkg.t_byte_char := ',';

NUM_HEADER_RECORDS_DEF          constant com_api_type_pkg.t_byte_id   := 6;
NUM_FIELD_OMANNET_FILE_IN       constant com_api_type_pkg.t_byte_id   := 29;
REQUEST_DATE_FORMAT             constant com_api_type_pkg.t_name      := 'ddmmyyyyhh24miss';
AMOUNT_FORMAT_OMANNET_FILE      constant com_api_type_pkg.t_name      := 'FM999999999999990.009';

end cst_oab_api_const_pkg;
/
