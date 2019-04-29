create or replace package body app_api_appl_object_pkg as

procedure add_object(
    i_appl_id           in      com_api_type_pkg.t_long_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_seqnum            in      com_api_type_pkg.t_tiny_id
) is
begin
    insert into app_object(
        appl_id
      , entity_type
      , object_id
      , seqnum
    ) values (
        i_appl_id     
      , i_entity_type 
      , i_object_id   
      , i_seqnum              
    );
end;

end;
/