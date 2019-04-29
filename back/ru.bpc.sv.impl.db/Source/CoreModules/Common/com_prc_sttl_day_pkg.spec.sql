create or replace package com_prc_sttl_day_pkg as
/********************************************************* 
 *  Process for settlement days <br /> 
 *  Created by Filimonov A.(filimonov@bpcbt.com)  at 21.07.2010 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module: com_prc_sttl_day_pkg   <br /> 
 *  @headcom 
 **********************************************************/ 
    procedure switch_sttl_day (
        i_sttl_date                 in date default null
        , i_inst_id                 in com_api_type_pkg.t_inst_id default null
        , i_alg_day                 in com_api_type_pkg.t_dict_value
    );

end;
/
