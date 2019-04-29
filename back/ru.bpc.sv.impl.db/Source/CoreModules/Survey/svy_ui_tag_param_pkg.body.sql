create or replace package body svy_ui_tag_param_pkg is

procedure add(
    o_id               out com_api_type_pkg.t_medium_id
  , i_tag_id        in     com_api_type_pkg.t_short_id
  , i_param_id      in     com_api_type_pkg.t_medium_id
) is

begin
    o_id     := svy_tag_param_seq.nextval;

    insert into svy_tag_param_vw (
        id
      , tag_id
      , param_id
    ) values (
        o_id
      , i_tag_id
      , i_param_id
    );
end add;

procedure modify(
    i_id            in     com_api_type_pkg.t_medium_id
  , i_tag_id        in     com_api_type_pkg.t_short_id
  , i_param_id      in     com_api_type_pkg.t_medium_id
) is
begin
    update svy_tag_param_vw
       set tag_id        = i_tag_id
         , param_id      = i_param_id
     where id            = i_id;
end modify;

procedure remove(
    i_id            in     com_api_type_pkg.t_medium_id
) is
begin
    delete svy_tag_param_vw
     where id = i_id;
end remove;

end svy_ui_tag_param_pkg;
/
