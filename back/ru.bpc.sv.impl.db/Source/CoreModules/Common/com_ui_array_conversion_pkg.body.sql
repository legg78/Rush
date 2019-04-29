create or replace package body com_ui_array_conversion_pkg is
/*********************************************************
*  UI for array types<br />
*  Created by Fomichev A.(fomichev@bpc.ru)  at 01.07.2011 <br />
*  Last changed by $Author: fomichev$ <br />
*  $LastChangedDate:: 2011-07-01 13:31:16 +0400#$ <br />
*  Revision: $LastChangedRevision: 10600 $ <br />
*  Module: com_ui_array_type_pkg <br />
*  @headcom
**********************************************************/
procedure add_array_conversion (
    o_id               out  com_api_type_pkg.t_tiny_id
  , o_seqnum           out  com_api_type_pkg.t_seqnum
  , i_in_array_id   in      com_api_type_pkg.t_tiny_id
  , i_in_lov_id     in      com_api_type_pkg.t_tiny_id
  , i_out_array_id  in      com_api_type_pkg.t_tiny_id
  , i_out_lov_id    in      com_api_type_pkg.t_tiny_id
  , i_conv_type     in      com_api_type_pkg.t_dict_value
  , i_lang          in      com_api_type_pkg.t_dict_value
  , i_label         in      com_api_type_pkg.t_name
  , i_description   in      com_api_type_pkg.t_full_desc
) is
begin
    o_id := com_array_conversion_seq.nextval;
    o_seqnum := 1;

    insert into com_array_conversion_vw (
        id
      , seqnum
      , in_array_id
      , in_lov_id
      , out_array_id
      , out_lov_id
      , conv_type
    ) values (
        o_id
      , o_seqnum
      , i_in_array_id
      , i_in_lov_id
      , i_out_array_id
      , i_out_lov_id
      , i_conv_type
    );
    if i_label is not null then
        com_api_i18n_pkg.add_text (
            i_table_name   => 'com_array_conversion'
          , i_column_name  => 'label'
          , i_object_id    => o_id
          , i_lang         => i_lang
          , i_text         => i_label
        );
    end if;

    if i_description is not null then
        com_api_i18n_pkg.add_text (
            i_table_name   => 'com_array_conversion'
          , i_column_name  => 'description'
          , i_object_id    => o_id
          , i_lang         => i_lang
          , i_text         => i_description
        );
    end if;
end;

procedure modify_array_conversion (
    i_id            in      com_api_type_pkg.t_tiny_id
  , io_seqnum       in out  com_api_type_pkg.t_seqnum
  , i_in_array_id   in      com_api_type_pkg.t_short_id
  , i_in_lov_id     in      com_api_type_pkg.t_tiny_id
  , i_out_array_id  in      com_api_type_pkg.t_short_id
  , i_out_lov_id    in      com_api_type_pkg.t_tiny_id
  , i_conv_type     in      com_api_type_pkg.t_dict_value
  , i_lang          in      com_api_type_pkg.t_dict_value
  , i_label         in      com_api_type_pkg.t_name
  , i_description   in      com_api_type_pkg.t_full_desc
) is
begin
    update com_array_conversion_vw
       set seqnum       = io_seqnum
         , in_array_id  = i_in_array_id
         , in_lov_id    = i_in_lov_id
         , out_array_id = i_out_array_id
         , out_lov_id   = i_out_lov_id
         , conv_type    = i_conv_type
     where id           = i_id;

    io_seqnum := io_seqnum + 1;

    if i_label is not null then
        com_api_i18n_pkg.add_text (
            i_table_name   => 'com_array_conversion'
          , i_column_name  => 'label'
          , i_object_id    => i_id
          , i_lang         => i_lang
          , i_text         => i_label
        );
    end if;

    if i_description is not null then
        com_api_i18n_pkg.add_text (
            i_table_name   => 'com_array_conversion'
          , i_column_name  => 'description'
          , i_object_id    => i_id
          , i_lang         => i_lang
          , i_text         => i_description
        );
    end if;

end;

procedure remove_array_conversion (
    i_id            in      com_api_type_pkg.t_tiny_id
  , i_seqnum        in      com_api_type_pkg.t_seqnum
) is
    l_count                 com_api_type_pkg.t_tiny_id;
begin
    -- remove text
    com_api_i18n_pkg.remove_text (
        i_table_name   => 'com_array_conversion'
        , i_object_id  => i_id
    );
    
    update com_array_conversion_vw
       set seqnum = i_seqnum
     where id     = i_id;

    delete from com_array_conversion_vw
     where id = i_id;
end;

end;
/
