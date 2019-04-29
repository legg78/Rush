create or replace package adt_api_trail_pkg as

/*********************************************************
 *  Audit trail API  <br />
 *  Created by Filimonov A.(filimonov@bpcbt.com)  at 30.07.2009 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: adt_api_trail_pkg <br />
 *  @headcom
 **********************************************************/
g_trail_id              com_api_type_pkg.t_long_id;

procedure check_value(
    i_trail_id              in      com_api_type_pkg.t_long_id
  , i_column_name           in      com_api_type_pkg.t_oracle_name
  , i_old_value             in      com_api_type_pkg.t_name
  , i_new_value             in      com_api_type_pkg.t_name
  , io_changed_count        in out  pls_integer
);

procedure check_value(
    i_trail_id              in      com_api_type_pkg.t_long_id
  , i_column_name           in      com_api_type_pkg.t_oracle_name
  , i_old_value             in      number
  , i_new_value             in      number
  , io_changed_count        in out  pls_integer
);

procedure check_value(
    i_trail_id              in      com_api_type_pkg.t_long_id
  , i_column_name           in      com_api_type_pkg.t_oracle_name
  , i_old_value             in      date
  , i_new_value             in      date
  , io_changed_count        in out  pls_integer
);

procedure check_value(
    i_trail_id              in      com_api_type_pkg.t_long_id
  , i_column_name           in      com_api_type_pkg.t_oracle_name
  , i_old_value             in      clob
  , i_new_value             in      clob
  , io_changed_count        in out  pls_integer
);

procedure check_value(
    i_trail_id              in      com_api_type_pkg.t_long_id
  , i_column_name           in      com_api_type_pkg.t_oracle_name
  , i_old_value             in      timestamp
  , i_new_value             in      timestamp
  , io_changed_count        in out  pls_integer
);


function get_trail_id return com_api_type_pkg.t_long_id;

procedure put_audit_trail(
    i_trail_id              in      com_api_type_pkg.t_long_id
  , i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_id             in      com_api_type_pkg.t_long_id
  , i_action_type           in      com_api_type_pkg.t_dict_value
  , i_priv_id               in      com_api_type_pkg.t_short_id       default null
  , i_session_id            in      com_api_type_pkg.t_long_id        default null
  , i_status                in      com_api_type_pkg.t_dict_value     default null
);

procedure add_audit_trail(
    i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_id             in      com_api_type_pkg.t_long_id
  , i_action_type           in      com_api_type_pkg.t_dict_value
  , i_user_id               in      com_api_type_pkg.t_short_id
  , i_priv_id               in      com_api_type_pkg.t_short_id       default null
  , i_session_id            in      com_api_type_pkg.t_long_id        default null
  , i_status                in      com_api_type_pkg.t_dict_value     default null
);

procedure modify_com_18n(
    i_trail_id              in      com_api_type_pkg.t_long_id
  , i_table_name            in      com_api_type_pkg.t_oracle_name
  , i_column_name           in      com_api_type_pkg.t_oracle_name
  , i_object_id             in      com_api_type_pkg.t_long_id
  , i_old_value             in      com_api_type_pkg.t_text
  , i_new_value             in      com_api_type_pkg.t_text
  , i_action_type           in      com_api_type_pkg.t_dict_value   
  , i_lang                  in      com_api_type_pkg.t_dict_value   
);

function get_detail_id return com_api_type_pkg.t_long_id;

end;
/
