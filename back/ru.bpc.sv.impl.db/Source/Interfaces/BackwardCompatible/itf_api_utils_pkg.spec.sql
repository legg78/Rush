CREATE OR REPLACE package itf_api_utils_pkg is
/************************************************************
 * Utils <br />
 * Created by Kondratyev A.(kondratyev@bpc.ru)  at 18.06.2013 <br />
 * Last changed by $Author: Kondratyev A. $ <br />
 * $LastChangedDate:: 2013-06-18 11:25:00 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: itf_api_utils_pkg <br />
 * @headcom
 ************************************************************/

xFFFFFFFF     constant integer := 4294967295;
xFFFFFF       constant integer := 16777215;
x10000        constant integer := 65536;
xFF           constant pls_integer := 255;
x100          constant pls_integer := 256;

function crc32(i_raw_data in varchar2, i_crc in integer) return integer;

function crc16(i_raw_data in varchar2, i_crc in integer default 0) return integer;

end;
/
