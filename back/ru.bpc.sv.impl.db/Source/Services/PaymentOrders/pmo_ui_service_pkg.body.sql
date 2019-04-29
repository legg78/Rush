create or replace package body pmo_ui_service_pkg as
/************************************************************
 * UI for Payment Order services<br />
 * Created by Kryukov E.(krukov@bpc.ru)  at 13.07.2011  <br />
 * Last changed by $Author$  <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: pmo_ui_service_pkg <br />
 * @headcom
 ************************************************************/
procedure add(
    o_id               out com_api_type_pkg.t_short_id
  , o_seqnum           out com_api_type_pkg.t_seqnum
  , i_direction     in     com_api_type_pkg.t_boolean
  , i_label         in     com_api_type_pkg.t_short_desc
  , i_description   in     com_api_type_pkg.t_full_desc
  , i_lang          in     com_api_type_pkg.t_dict_value
  , i_short_name    in     com_api_type_pkg.t_name
  , i_inst_id       in     com_api_type_pkg.t_inst_id   default null
) is
begin
    o_id     := pmo_service_seq.nextval;
    o_seqnum := 1;

    insert into pmo_service_vw(
        id
      , seqnum
      , direction
      , inst_id
    ) values (
        o_id
      , o_seqnum
      , i_direction
      , nvl(i_inst_id, ost_api_const_pkg.DEFAULT_INST)
    );

    com_ui_i18n_pkg.add_text(
        i_table_name   => 'pmo_service'
      , i_column_name  => 'label'
      , i_object_id    => o_id
      , i_text         => i_label
      , i_lang         => i_lang
      , i_check_unique => com_api_type_pkg.TRUE
    );

    com_ui_i18n_pkg.add_text(
        i_table_name   => 'pmo_service'
      , i_column_name  => 'description'
      , i_object_id    => o_id
      , i_text         => i_description
      , i_lang         => i_lang
      , i_check_unique => com_api_type_pkg.FALSE
    );
    
    com_api_i18n_pkg.add_text(
        i_table_name   => 'pmo_service'
      , i_column_name  => 'short_name'
      , i_object_id    => o_id
      , i_text         => i_short_name
      , i_lang         => com_api_const_pkg.LANGUAGE_ENGLISH
      , i_check_unique => com_api_type_pkg.TRUE
    );

end add;

procedure modify(
    i_id            in     com_api_type_pkg.t_short_id
  , io_seqnum       in out com_api_type_pkg.t_seqnum
  , i_direction     in     com_api_type_pkg.t_boolean
  , i_label         in     com_api_type_pkg.t_short_desc
  , i_description   in     com_api_type_pkg.t_full_desc
  , i_lang          in     com_api_type_pkg.t_dict_value
  , i_short_name    in     com_api_type_pkg.t_name
  , i_inst_id       in     com_api_type_pkg.t_inst_id   default null
) is
begin

    update
        pmo_service_vw a
    set
        a.seqnum    = io_seqnum
      , a.direction = i_direction
      , a.inst_id   = nvl(i_inst_id, inst_id)
    where
        a.id = i_id;

    com_ui_i18n_pkg.add_text(
        i_table_name   => 'pmo_service'
      , i_column_name  => 'label'
      , i_object_id    => i_id
      , i_text         => i_label
      , i_lang         => i_lang
      , i_check_unique => com_api_type_pkg.TRUE
    );

    com_ui_i18n_pkg.add_text(
        i_table_name   => 'pmo_service'
      , i_column_name  => 'description'
      , i_object_id    => i_id
      , i_text         => i_description
      , i_lang         => i_lang
      , i_check_unique => com_api_type_pkg.FALSE
    );
    
    com_api_i18n_pkg.add_text(
        i_table_name   => 'pmo_service'
      , i_column_name  => 'short_name'
      , i_object_id    => i_id
      , i_text         => i_short_name
      , i_lang         => com_api_const_pkg.LANGUAGE_ENGLISH
      , i_check_unique => com_api_type_pkg.TRUE
    );

    io_seqnum := io_seqnum + 1;

end modify;

procedure remove(
    i_id            in     com_api_type_pkg.t_short_id
  , i_seqnum        in     com_api_type_pkg.t_seqnum
) is
begin
    update
        pmo_service_vw a
    set
        a.seqnum = i_seqnum
    where
        a.id = i_id;

    delete
        pmo_service_vw a
    where
        a.id = i_id;

    -- remove pmo_purpose
    for rec in (
         select id from pmo_purpose_vw where service_id = i_id
    ) loop
        pmo_ui_purpose_pkg.remove(rec.id);
    end loop;

    com_api_i18n_pkg.remove_text(
        i_table_name => 'pmo_service'
      , i_object_id  => i_id
    );

end remove;

end pmo_ui_service_pkg;
/
