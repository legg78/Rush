create or replace package body com_ui_array_type_pkg is
/*********************************************************
*  UI for array types<br />
*  Created by Fomichev A.(fomichev@bpc.ru)  at 01.07.2011 <br />
*  Last changed by $Author: fomichev$ <br />
*  $LastChangedDate:: 2011-07-01 13:31:16 +0400#$ <br />
*  Revision: $LastChangedRevision: 10600 $ <br />
*  Module: com_ui_array_type_pkg <br />
*  @headcom
**********************************************************/
procedure add_array_type (
    o_id                out  com_api_type_pkg.t_tiny_id
  , o_seqnum            out  com_api_type_pkg.t_seqnum
  , i_name           in      com_api_type_pkg.t_name
  , i_is_unique      in      com_api_type_pkg.t_boolean
  , i_lov_id         in      com_api_type_pkg.t_tiny_id
  , i_entity_type    in      com_api_type_pkg.t_dict_value
  , i_data_type      in      com_api_type_pkg.t_dict_value
  , i_inst_id        in      com_api_type_pkg.t_inst_id
  , i_lang           in      com_api_type_pkg.t_dict_value
  , i_label          in      com_api_type_pkg.t_name
  , i_description    in      com_api_type_pkg.t_full_desc
  , i_scale_type     in      com_api_type_pkg.t_dict_value
  , i_class_name     in      com_api_type_pkg.t_name
) is
begin
    o_id := com_array_type_seq.nextval;
    o_seqnum := 1;

    insert into com_array_type_vw (
        id
      , seqnum
      , name
      , is_unique
      , lov_id
      , entity_type
      , data_type
      , inst_id
      , scale_type
      , class_name
    ) values (
        o_id
      , o_seqnum
      , i_name
      , i_is_unique
      , i_lov_id
      , i_entity_type
      , i_data_type
      , i_inst_id
      , i_scale_type
      , i_class_name
    );

    if i_label is not null then
        com_api_i18n_pkg.add_text (
            i_table_name   => 'com_array_type'
          , i_column_name  => 'label'
          , i_object_id    => o_id
          , i_lang         => i_lang
          , i_text         => i_label
        );
    end if;

    if i_description is not null then
        com_api_i18n_pkg.add_text (
            i_table_name   => 'com_array_type'
          , i_column_name  => 'description'
          , i_object_id    => o_id
          , i_lang         => i_lang
          , i_text         => i_description
        );
    end if;
end;

procedure modify_array_type (
    i_id             in      com_api_type_pkg.t_tiny_id
  , io_seqnum        in out  com_api_type_pkg.t_seqnum
  , i_name           in      com_api_type_pkg.t_name
  , i_is_unique      in      com_api_type_pkg.t_boolean
  , i_lov_id         in      com_api_type_pkg.t_tiny_id
  , i_entity_type    in      com_api_type_pkg.t_dict_value
  , i_data_type      in      com_api_type_pkg.t_dict_value
  , i_inst_id        in      com_api_type_pkg.t_inst_id
  , i_lang           in      com_api_type_pkg.t_dict_value
  , i_label          in      com_api_type_pkg.t_name
  , i_description    in      com_api_type_pkg.t_full_desc
  , i_scale_type     in      com_api_type_pkg.t_dict_value
  , i_class_name     in      com_api_type_pkg.t_name
) is
begin
    update com_array_type_vw
       set seqnum       = io_seqnum
         , name         = i_name
         , is_unique    = i_is_unique
         , lov_id       = i_lov_id
         , entity_type  = i_entity_type
         , data_type    = i_data_type
         , inst_id      = i_inst_id
         , scale_type   = i_scale_type
         , class_name   = i_class_name
     where id           = i_id;

    io_seqnum := io_seqnum + 1;

    if i_label is not null then
        com_api_i18n_pkg.add_text (
            i_table_name   => 'com_array_type'
          , i_column_name  => 'label'
          , i_object_id    => i_id
          , i_lang         => i_lang
          , i_text         => i_label
        );
    end if;

    if i_description is not null then
        com_api_i18n_pkg.add_text (
            i_table_name   => 'com_array_type'
          , i_column_name  => 'description'
          , i_object_id    => i_id
          , i_lang         => i_lang
          , i_text         => i_description
        );
    end if;
end;

procedure remove_array_type (
    i_id      in      com_api_type_pkg.t_tiny_id
  , i_seqnum  in      com_api_type_pkg.t_seqnum
) is
    l_count                 com_api_type_pkg.t_tiny_id;
begin
    select count(*)
      into l_count
      from com_array_vw
     where array_type_id = i_id;

    if l_count > 0 then
        com_api_error_pkg.raise_error (
            i_error         => 'ARRAY_TYPE_IS_ALREADY_USED'
          , i_env_param1  => i_id
        );
    end if;

    -- remove text
    com_api_i18n_pkg.remove_text (
        i_table_name   => 'com_array_type'
        , i_object_id  => i_id
    );

    update com_array_type_vw
       set seqnum = i_seqnum
     where id = i_id;

    delete from com_array_type_vw
     where id = i_id;
end;

end;
/
