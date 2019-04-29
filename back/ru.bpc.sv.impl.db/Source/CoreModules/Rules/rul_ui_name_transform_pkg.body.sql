create or replace package body rul_ui_name_transform_pkg as
/************************************************************
 * UI for transform function. <br />
 * Created by Kryukov E.(krukov@bpc.ru)  at 24.01.2012 <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: RUL_UI_NAME_TRANSFORM_PKG <br />
 * @headcom
 *************************************************************/
procedure add(
    o_id                     out com_api_type_pkg.t_tiny_id
  , o_seqnum                 out com_api_type_pkg.t_seqnum
  , i_function_name       in     com_api_type_pkg.t_name
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_lang                in     com_api_type_pkg.t_dict_value
  , i_description         in     com_api_type_pkg.t_full_desc
) is
begin
    o_id := rul_name_transform_seq.nextval;
    o_seqnum := 1;

    insert into rul_name_transform_vw(
        id
      , seqnum
      , function_name
      , inst_id
    ) values (
        o_id  
      , o_seqnum
      , i_function_name
      , i_inst_id
    );

    com_api_i18n_pkg.add_text (
        i_table_name    => 'rul_name_transform'
      , i_column_name   => 'description'
      , i_object_id     => o_id
      , i_text          => i_description
      , i_lang          => i_lang
    );

end;

procedure modify(
    i_id                  in     com_api_type_pkg.t_tiny_id
  , io_seqnum             in out com_api_type_pkg.t_seqnum
  , i_function_name       in     com_api_type_pkg.t_name
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_lang                in     com_api_type_pkg.t_dict_value
  , i_description         in     com_api_type_pkg.t_full_desc
) is
begin
    update
        rul_name_transform_vw a
    set
        a.function_name = i_function_name
      , a.seqnum        = io_seqnum
      , a.inst_id       = i_inst_id
    where
        a.id = i_id;

    io_seqnum := io_seqnum + 1;

    com_api_i18n_pkg.add_text (
        i_table_name    => 'rul_name_transform'
      , i_column_name   => 'description'
      , i_object_id     => i_id
      , i_text          => i_description
      , i_lang          => i_lang
    );
end;

procedure remove(
    i_id                  in     com_api_type_pkg.t_tiny_id
  , i_seqnum              in     com_api_type_pkg.t_seqnum
) is
begin
    update
        rul_name_transform_vw a
    set
        a.seqnum = i_seqnum
    where
        a.id = i_id;

    delete
        rul_name_transform_vw a
    where
       a.id = i_id;

    com_api_i18n_pkg.remove_text(
        i_table_name => 'rul_name_transform'
      , i_object_id  => i_id
    );

end;

end rul_ui_name_transform_pkg;
/
