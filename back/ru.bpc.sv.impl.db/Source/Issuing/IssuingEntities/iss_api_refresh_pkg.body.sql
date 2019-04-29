create or replace package body iss_api_refresh_pkg is 
/********************************************************* 
 *  API for Issuing materialized views refreshing <br /> 
 *  Created by Khougaev A.(khougaev@bpcbt.com)  at 15.02.2010 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module: iss_api_refresh_pkg  <br /> 
 *  @headcom 
 **********************************************************/ 
procedure refresh_prod_attr is
pragma autonomous_transaction;
begin 
    dbms_mview.refresh('iss_prod_attr_mvw');
    commit;
end;
    
procedure refresh_prod_fee is
pragma autonomous_transaction;
begin 
    dbms_mview.refresh('iss_prod_fee_mvw');
    commit;
end;

procedure refresh_prod_cycle is
pragma autonomous_transaction;
begin 
    dbms_mview.refresh('iss_prod_cycle_mvw');
    commit;
end;
    
procedure refresh_prod_limit is
pragma autonomous_transaction;
begin 
    dbms_mview.refresh('iss_prod_limit_mvw');
    commit;
end;
    
procedure refresh_all is
begin
    refresh_prod_attr;
    refresh_prod_fee;
    refresh_prod_cycle;
    refresh_prod_limit;
end;
    
end;
/
