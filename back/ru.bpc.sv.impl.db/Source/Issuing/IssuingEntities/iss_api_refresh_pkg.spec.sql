create or replace package iss_api_refresh_pkg is
/********************************************************* 
 *  API for Issuing materialized views refreshing <br /> 
 *  Created by Khougaev A.(khougaev@bpcbt.com)  at 15.02.2010 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module: iss_api_refresh_pkg  <br /> 
 *  @headcom 
 **********************************************************/ 

procedure refresh_prod_attr;
    
procedure refresh_prod_fee;
    
procedure refresh_prod_cycle;
    
procedure refresh_prod_limit;
    
procedure refresh_all;

end;
/
