create or replace package acm_ui_group_pkg as
/*********************************************************
 *  Interface for acm_group  <br />
 *  Created by Sergey Ivanov (sr.ivanov@bpcbt.com)  at 29.10.2018 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: acm_ui_group_pkg <br />
 *  @headcom
 **********************************************************/

procedure add_group(
    o_id               out com_api_type_pkg.t_short_id
  , o_seqnum           out com_api_type_pkg.t_seqnum
  , i_inst_id       in     com_api_type_pkg.t_tiny_id
  , i_creation_date in     date                          default get_sysdate
  , i_name          in     com_api_type_pkg.t_name
  , i_lang          in     com_api_type_pkg.t_dict_value
);

procedure modify_group(
    i_id            in     com_api_type_pkg.t_short_id
  , io_seqnum       in out com_api_type_pkg.t_seqnum
  , i_inst_id       in     com_api_type_pkg.t_tiny_id
  , i_creation_date in     date                          default null
  , i_name          in     com_api_type_pkg.t_name
  , i_lang          in     com_api_type_pkg.t_dict_value
);

procedure attach_user(
    o_id               out com_api_type_pkg.t_short_id
  , i_user_id       in     com_api_type_pkg.t_short_id
  , i_group_id      in     com_api_type_pkg.t_short_id
);

procedure attach_user(
    i_user_id       in     com_api_type_pkg.t_short_id
  , i_group_id      in     com_api_type_pkg.t_short_id
);

procedure detach_user(
    i_id            in     com_api_type_pkg.t_short_id default null
  , i_user_id       in     com_api_type_pkg.t_short_id
  , i_group_id      in     com_api_type_pkg.t_short_id
);

end;
/
