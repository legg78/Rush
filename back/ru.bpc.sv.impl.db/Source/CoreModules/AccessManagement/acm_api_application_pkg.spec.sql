create or replace package acm_api_application_pkg as
/********************************************************* 
 *  User management applications API  <br /> 
 *  Created by Alalykin A.(alalykin@bpcbt.com) at 12.11.2015 <br /> 
 *  Last changed by $Author: alalykin $ <br /> 
 *  $LastChangedDate:: 2015-11-12 10:00:00 +0300#$ <br /> 
 *  Revision: $LastChangedRevision: 1 $ <br /> 
 *  Module: ACM_API_APPLICATION_PKG <br /> 
 *  @headcom 
 **********************************************************/ 

procedure process_application(
    i_appl_id       in            com_api_type_pkg.t_long_id
);

procedure attach_user_to_application(
    i_appl_id       in            com_api_type_pkg.t_long_id
  , i_user_id       in            com_api_type_pkg.t_short_id
);

end acm_api_application_pkg;
/
