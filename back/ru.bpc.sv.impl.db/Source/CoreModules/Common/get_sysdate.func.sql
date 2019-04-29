create or replace function get_sysdate return date is
/************************************************************
 * Alias for function .com_api_sttl_day_pkg.get_sysdate <br />
 * Created by Kryukov E.(kryukov@bpc.ru)  at 22.06.2011 <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: COM <br />
 * @headcom
 *************************************************************/
begin
    return com_api_sttl_day_pkg.get_sysdate;
end get_sysdate;
/

