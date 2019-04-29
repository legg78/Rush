create or replace package rul_mod_gen_pkg as
/********************************************************* 
 *  package for modifiers static package generation  <br /> 
 *  Created by Filimonov A.(filimonov@bpcbt.com)  at 07.09.2010 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module: rul_mod_gen_pkg  <br /> 
 *  @headcom 
 **********************************************************/ 

procedure nop;

procedure generate_package(
    i_mod_id                in     com_api_type_pkg.t_tiny_id    default null
  , i_is_modification       in     com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
);

end;
/