create or replace package com_ui_array_element_pkg is
/*********************************************************
*  UI for array elements <br />
*  Created by Fomichev A.(fomichev@bpc.ru)  at 01.07.2011 <br />
*  Last changed by $Author: fomichev$ <br />
*  $LastChangedDate:: 2011-07-01 13:31:16 +0400#$ <br />
*  Revision: $LastChangedRevision: 10600 $ <br />
*  Module: com_ui_array_element_pkg <br />
*  @headcom
**********************************************************/
procedure add_array_element (
    o_id                 out  com_api_type_pkg.t_short_id
  , o_seqnum             out  com_api_type_pkg.t_seqnum
  , i_array_id        in      com_api_type_pkg.t_short_id
  , i_data_type       in      com_api_type_pkg.t_dict_value
  , i_value_char      in      com_api_type_pkg.t_name
  , i_value_number    in      number
  , i_value_date      in      date
  , i_element_number  in      com_api_type_pkg.t_tiny_id        default null
  , i_lang            in      com_api_type_pkg.t_dict_value
  , i_label           in      com_api_type_pkg.t_name           
  , i_description     in      com_api_type_pkg.t_full_desc      default null
);

procedure modify_array_element (
    i_id              in      com_api_type_pkg.t_short_id
  , io_seqnum         in out  com_api_type_pkg.t_seqnum
  , i_array_id        in      com_api_type_pkg.t_short_id
  , i_data_type       in      com_api_type_pkg.t_dict_value
  , i_value_char      in      com_api_type_pkg.t_name
  , i_value_number    in      number
  , i_value_date      in      date
  , i_element_number  in      com_api_type_pkg.t_tiny_id
  , i_lang            in      com_api_type_pkg.t_dict_value
  , i_label           in      com_api_type_pkg.t_name
  , i_description     in      com_api_type_pkg.t_full_desc
);

procedure remove_array_element (
    i_id             in com_api_type_pkg.t_short_id
  , i_seqnum         in com_api_type_pkg.t_seqnum
);

end;
/
