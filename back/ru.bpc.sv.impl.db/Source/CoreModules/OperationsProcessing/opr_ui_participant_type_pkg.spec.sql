create or replace package opr_ui_participant_type_pkg as
/*********************************************************
 *  UI for participant type processing <br />
 *  Created by Necheukhin I.(necheukhin@bpcbt.com)  at 11.12.2012 <br />
 *  Last changed by $Author: necheukhin $ <br />
 *  $LastChangedDate:: 2012-12-11 1#$ <br />
 *  Module: OPR_UI_PARTICIPANT_TYPE_PKG <br />
 *  @headcom
 **********************************************************/

procedure  add_participant_type (
    o_id                        out     com_api_type_pkg.t_tiny_id
    , i_oper_type           in          com_api_type_pkg.t_dict_value
    , i_participant_type    in          com_api_type_pkg.t_dict_value
);
  
procedure remove_participant_type (
    i_id    in  com_api_type_pkg.t_tiny_id
);
  
procedure remove_participant_type (
    i_oper_type             in  com_api_type_pkg.t_dict_value
    , i_participant_type    in  com_api_type_pkg.t_dict_value
);
    
end;
/