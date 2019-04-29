create or replace package body prc_ui_directory_pkg as
/************************************************************
 * UI for directory settings <br />
 * Created by Kryukov E.(krukov@bpc.ru)  at 30.08.2013 <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: PRC_UI_DIRECTORY_PKG <br />
 * @headcom
 ***********************************************************/
 
procedure add_directory(
    o_id                     out com_api_type_pkg.t_tiny_id
  , o_seqnum                 out com_api_type_pkg.t_seqnum
  , i_name                in     com_api_type_pkg.t_name
  , i_encryption_type     in     com_api_type_pkg.t_dict_value
  , i_directory_path      in     com_api_type_pkg.t_name
  , i_lang                in     com_api_type_pkg.t_dict_value
) is
begin
    o_seqnum := 1;
    o_id := prc_directory_seq.nextval;

    insert into prc_directory_vw(
        id
      , seqnum
      , encryption_type
      , directory_path
    ) values (
        o_id
      , o_seqnum
      , i_encryption_type
      , i_directory_path
    );

    com_api_i18n_pkg.add_text (
        i_table_name   => 'prc_directory'
      , i_column_name  => 'name'
      , i_object_id    => o_id
      , i_lang         => i_lang
      , i_text         => i_name
        );

end add_directory;


procedure modify_directory(
    i_id                  in     com_api_type_pkg.t_tiny_id
  , io_seqnum             in out com_api_type_pkg.t_seqnum
  , i_name                in     com_api_type_pkg.t_name
  , i_encryption_type     in     com_api_type_pkg.t_dict_value
  , i_directory_path      in     com_api_type_pkg.t_name
  , i_lang                in     com_api_type_pkg.t_dict_value
) is
begin
    update prc_directory_vw a
       set a.encryption_type = i_encryption_type
         , a.directory_path  = i_directory_path
         , a.seqnum          = io_seqnum
     where a.id = i_id;

    io_seqnum := io_seqnum + 1;

    if i_name is not null then
        com_api_i18n_pkg.add_text (
            i_table_name   => 'prc_directory'
          , i_column_name  => 'name'
          , i_object_id    => i_id
          , i_lang         => i_lang
          , i_text         => i_name
        );
    end if;

end modify_directory;


procedure remove_directory(
    i_id                  in     com_api_type_pkg.t_tiny_id
  , i_seqnum              in     com_api_type_pkg.t_seqnum
) is
begin
    update
        prc_directory_vw a
    set
        a.seqnum = i_seqnum
    where
        a.id = i_id;

    delete
        prc_directory_vw
    where
        id = i_id;

    com_api_i18n_pkg.remove_text(
        i_table_name => 'prc_directory'
      , i_object_id  => i_id
    );

end remove_directory;


end prc_ui_directory_pkg;
/
