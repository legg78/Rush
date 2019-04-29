create or replace package adt_ui_entity_pkg as

procedure modify_status(
    i_entity_type       in      com_api_type_pkg.t_dict_value
  , io_audit_status     in out  com_api_type_pkg.t_boolean
);

end;
/