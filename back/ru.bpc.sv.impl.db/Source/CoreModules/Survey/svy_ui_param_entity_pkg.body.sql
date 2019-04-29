create or replace package body svy_ui_param_entity_pkg is

procedure add(
    o_id               out com_api_type_pkg.t_medium_id
  , o_seqnum           out com_api_type_pkg.t_tiny_id
  , i_entity_type   in     com_api_type_pkg.t_dict_value
  , i_param_id      in     com_api_type_pkg.t_medium_id
) is

begin
    o_id     := svy_param_entity_seq.nextval;
    o_seqnum := 1;

    insert into svy_parameter_entity (
        id
      , seqnum
      , entity_type
      , param_id
    ) values (
        o_id
      , o_seqnum
      , i_entity_type
      , i_param_id
    );

exception
  when dup_val_on_index then
      com_api_error_pkg.raise_error(
          i_error      => 'DUPLICATE_SURVEY_PARAMETER_ENTITY_TYPE'
        , i_env_param1 => i_param_id
        , i_env_param2 => i_entity_type
      );
end add;

procedure modify(
    i_id            in     com_api_type_pkg.t_medium_id
  , io_seqnum       in out com_api_type_pkg.t_tiny_id
  , i_entity_type   in     com_api_type_pkg.t_dict_value
  , i_param_id      in     com_api_type_pkg.t_medium_id
) is
begin
    update svy_parameter_entity
       set seqnum        = io_seqnum
         , entity_type   = i_entity_type
         , param_id      = i_param_id
     where id            = i_id;

    io_seqnum := io_seqnum + 1;

exception
  when dup_val_on_index then
      com_api_error_pkg.raise_error(
          i_error      => 'DUPLICATE_SURVEY_PARAMETER_ENTITY_TYPE'
        , i_env_param1 => i_param_id
        , i_env_param2 => i_entity_type
      );
end modify;

procedure remove(
    i_id            in     com_api_type_pkg.t_medium_id
) is
begin
    delete svy_parameter_entity
     where id = i_id;
end remove;

end svy_ui_param_entity_pkg;
/
