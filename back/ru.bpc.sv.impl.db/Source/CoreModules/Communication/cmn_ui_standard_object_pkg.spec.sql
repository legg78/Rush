create or replace package cmn_ui_standard_object_pkg is
/********************************************************* 
 *  UI for standard objects <br /> 
 *  Created by Filimonov A.(filimonov@bpcbt.com)  at 14.03.2012 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module: cmn_ui_standard_object_pkg  <br /> 
 *  @headcom 
 **********************************************************/ 
procedure add_standard_object (
    i_entity_type       in com_api_type_pkg.t_dict_value
    , i_object_id       in com_api_type_pkg.t_long_id
    , i_standard_id     in com_api_type_pkg.t_tiny_id
); 

procedure remove_standard_object (
    i_id                in com_api_type_pkg.t_short_id
);
    
procedure remove_standard_object (
    i_entity_type       in com_api_type_pkg.t_dict_value
    , i_object_id       in com_api_type_pkg.t_long_id
);

procedure remove_standard_object (
    i_entity_type       in com_api_type_pkg.t_dict_value
    , i_object_id       in com_api_type_pkg.t_long_id
    , i_standard_type   in com_api_type_pkg.t_dict_value
);

procedure add_standard_version_object (
    o_id                out com_api_type_pkg.t_short_id
    , i_entity_type     in com_api_type_pkg.t_dict_value
    , i_object_id       in com_api_type_pkg.t_long_id
    , i_version_id      in com_api_type_pkg.t_tiny_id
    , i_start_date      in date
); 

procedure modify_standard_version_object (
    i_id                in com_api_type_pkg.t_short_id
    , i_start_date      in date
);

procedure remove_standard_version_object (
    i_id                in com_api_type_pkg.t_short_id
);

end;
/
