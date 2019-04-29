create or replace package app_api_note_pkg as
/*********************************************************
 *  Acquiring/issuing application API  <br />
 *  Created by Sergey Ivanov (sr.ivanov@bpcbt.com)  at 16.08.2018 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: app_api_note_pkg <br />
 *  @headcom
 **********************************************************/
procedure process_note(
    i_appl_data_id     in     com_api_type_pkg.t_long_id
  , i_entity_type      in     com_api_type_pkg.t_dict_value
  , i_object_id        in     com_api_type_pkg.t_medium_id
);

end;
/
