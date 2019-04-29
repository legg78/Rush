create or replace package body app_ui_flow_filter_pkg as
/*******************************************************************
*  API for application's flow <br />
*  Created by Fomichev A.(fomichev@bpc.ru)  at 03.08.2010 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: app_api_flow_pkg <br />
*  @headcom
******************************************************************/

procedure add(
    o_id                     out  com_api_type_pkg.t_short_id
  , o_seqnum                 out  com_api_type_pkg.t_tiny_id
  , i_stage_id            in      com_api_type_pkg.t_short_id
  , i_struct_id           in      com_api_type_pkg.t_short_id
  , i_min_count           in      com_api_type_pkg.t_tiny_id
  , i_max_count           in      com_api_type_pkg.t_tiny_id
  , i_is_visible          in      com_api_type_pkg.t_boolean 
  , i_is_updatable        in      com_api_type_pkg.t_boolean
  , i_is_insertable       in      com_api_type_pkg.t_boolean
  , i_default_value_char  in      com_api_type_pkg.t_name
  , i_default_value_num   in      com_api_type_pkg.t_rate
  , i_default_value_date  in      date
) is
   l_default_value        com_api_type_pkg.t_name;
   l_data_type            com_api_type_pkg.t_dict_value;
begin
    select coalesce(e.data_type, f.data_type) data_type
      into l_data_type
      from app_structure s
         , app_element e
         , com_flexible_field f
     where s.element_id = e.id(+)
       and s.element_id = f.id(+)
       and s.id         = i_struct_id;

    l_default_value := com_api_type_pkg.convert_to_char(
                           i_data_type  => l_data_type
                         , i_value_char => i_default_value_char
                         , i_value_num  => i_default_value_num
                         , i_value_date => i_default_value_date
                       );

    select app_flow_filter_seq.nextval, 1
      into o_id, o_seqnum
      from dual;

    insert into app_flow_filter_vw (
        id
      , seqnum
      , stage_id
      , struct_id
      , min_count
      , max_count
      , is_visible
      , is_updatable
      , is_insertable
      , default_value
    ) values (
        o_id
      , o_seqnum
      , i_stage_id
      , i_struct_id
      , i_min_count
      , i_max_count
      , i_is_visible
      , i_is_updatable
      , i_is_insertable
      , l_default_value
    );
end;

procedure modify(
    i_id                  in      com_api_type_pkg.t_short_id
  , io_seqnum             in out  com_api_type_pkg.t_tiny_id
  , i_stage_id            in      com_api_type_pkg.t_short_id
  , i_struct_id           in      com_api_type_pkg.t_short_id
  , i_min_count           in      com_api_type_pkg.t_tiny_id
  , i_max_count           in      com_api_type_pkg.t_tiny_id
  , i_is_visible          in      com_api_type_pkg.t_boolean 
  , i_is_updatable        in      com_api_type_pkg.t_boolean
  , i_is_insertable       in      com_api_type_pkg.t_boolean
  , i_default_value_char  in      com_api_type_pkg.t_name
  , i_default_value_num   in      com_api_type_pkg.t_rate
  , i_default_value_date  in      date
) is
   l_default_value        com_api_type_pkg.t_name;
   l_data_type            com_api_type_pkg.t_dict_value;
begin
    select coalesce(e.data_type, f.data_type) data_type
      into l_data_type
      from app_structure s
         , app_element e
         , com_flexible_field f
     where s.element_id = e.id(+)
       and s.element_id = f.id(+)
       and s.id         = i_struct_id;

    l_default_value := com_api_type_pkg.convert_to_char(
                           i_data_type  => l_data_type
                         , i_value_char => i_default_value_char
                         , i_value_num  => i_default_value_num
                         , i_value_date => i_default_value_date
                       );

    update app_flow_filter_vw
       set seqnum         =  io_seqnum
         , stage_id       =  i_stage_id
         , struct_id      =  i_struct_id
         , min_count      =  i_min_count
         , max_count      =  i_max_count
         , is_visible     =  i_is_visible
         , is_updatable   =  i_is_updatable
         , is_insertable  =  i_is_insertable
         , default_value  =  l_default_value
     where id             = i_id
       and struct_id      = i_struct_id;

    io_seqnum  :=  io_seqnum + 1;
end;

procedure remove( 
    i_id      in  com_api_type_pkg.t_short_id
  , i_seqnum  in  com_api_type_pkg.t_tiny_id
) is
begin
    update app_flow_filter_vw
       set seqnum  = i_seqnum
     where id      = i_id;

    delete from app_flow_filter_vw
     where id = i_id;
end;

end;
/
