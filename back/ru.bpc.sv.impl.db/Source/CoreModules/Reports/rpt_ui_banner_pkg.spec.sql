create or replace package rpt_ui_banner_pkg as
/*
  Interface for report banner definition <br />
  Created by Fomichev A.(fomichev@bpc.ru)  at 20.09.2010 <br />
  Last changed by $Author: Fomichev A. $ <br />
  $LastChangedDate:: 2010-08-20 11:44:00 +0400#$ <br />
  Module: rpt_ui_banner_pkg <br />
*/

procedure add_banner(
    o_id               out  com_api_type_pkg.t_short_id
  , o_seqnum           out  com_api_type_pkg.t_tiny_id
  , i_status        in      com_api_type_pkg.t_dict_value
  , i_filename      in      com_api_type_pkg.t_name
  , i_inst_id       in      com_api_type_pkg.t_inst_id
  , i_label         in      com_api_type_pkg.t_name
  , i_description   in      com_api_type_pkg.t_full_desc
  , i_lang          in      com_api_type_pkg.t_dict_value   default null
);


procedure modify_banner(
    i_id            in      com_api_type_pkg.t_short_id
  , io_seqnum       in out  com_api_type_pkg.t_tiny_id
  , i_status        in      com_api_type_pkg.t_dict_value
  , i_filename      in      com_api_type_pkg.t_dict_value
  , i_label         in      com_api_type_pkg.t_name
  , i_description   in      com_api_type_pkg.t_full_desc
  , i_lang          in      com_api_type_pkg.t_dict_value   default null
);

procedure remove_banner(
    i_id            in     com_api_type_pkg.t_short_id
  , i_seqnum        in     com_api_type_pkg.t_tiny_id
);

end;
/
