create or replace package body pmo_ui_parameter_pkg as
/************************************************************
 * UI for Payment Order parameters <br />
 * Created by Kryukov E.(krukov@bpc.ru)  at 13.07.2011  <br />
 * Last changed by $Author$  <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: PMO_UI_PARAMETER_PKG <br />
 * @headcom
 ************************************************************/

procedure add(
    o_id                   out com_api_type_pkg.t_short_id
  , o_seqnum               out com_api_type_pkg.t_seqnum
  , i_param_name        in     com_api_type_pkg.t_name
  , i_data_type         in     com_api_type_pkg.t_dict_value
  , i_lov_id            in     com_api_type_pkg.t_tiny_id
  , i_pattern           in     com_api_type_pkg.t_name
  , i_tag_id            in     com_api_type_pkg.t_medium_id
  , i_param_function    in     com_api_type_pkg.t_full_desc
  , i_label             in     com_api_type_pkg.t_short_desc
  , i_description       in     com_api_type_pkg.t_full_desc
  , i_lang              in     com_api_type_pkg.t_dict_value
) is
begin
    if i_pattern is not null and i_param_function is not null then
        com_api_error_pkg.raise_error(
            i_error             => 'PMO_INCOMPATIBLE_PARAMETERS'
          , i_env_param1        => i_pattern
          , i_env_param2        => i_param_function
        );
    end if;

    o_id     := pmo_parameter_seq.nextval;
    o_seqnum := 1;
    insert into pmo_parameter_vw(
        id
      , seqnum
      , param_name
      , data_type
      , lov_id
      , pattern
      , tag_id
      , param_function
    ) values (
        o_id
      , o_seqnum
      , i_param_name
      , i_data_type
      , i_lov_id
      , i_pattern
      , i_tag_id
      , i_param_function
    );

    com_api_i18n_pkg.add_text(
        i_table_name   => 'pmo_parameter'
      , i_column_name  => 'label'
      , i_object_id    => o_id
      , i_text         => i_label
      , i_lang         => i_lang
      , i_check_unique => com_api_type_pkg.TRUE
    );

    com_api_i18n_pkg.add_text(
        i_table_name   => 'pmo_parameter'
      , i_column_name  => 'description'
      , i_object_id    => o_id
      , i_text         => i_description
      , i_lang         => i_lang
      , i_check_unique => com_api_type_pkg.TRUE
    );

end add;

procedure modify(
    i_id                in     com_api_type_pkg.t_short_id
  , io_seqnum           in out com_api_type_pkg.t_seqnum
  , i_param_name        in     com_api_type_pkg.t_name
  , i_data_type         in     com_api_type_pkg.t_dict_value
  , i_lov_id            in     com_api_type_pkg.t_tiny_id
  , i_pattern           in     com_api_type_pkg.t_name
  , i_tag_id            in     com_api_type_pkg.t_medium_id
  , i_param_function    in     com_api_type_pkg.t_full_desc
  , i_label             in     com_api_type_pkg.t_short_desc
  , i_description       in     com_api_type_pkg.t_full_desc
  , i_lang              in     com_api_type_pkg.t_dict_value
) is
begin
    if i_pattern is not null and i_param_function is not null then
        com_api_error_pkg.raise_error(
            i_error             => 'PMO_INCOMPATIBLE_PARAMETERS'
          , i_env_param1        => i_pattern
          , i_env_param2        => i_param_function
        );
    end if;

    update
        pmo_parameter_vw a
    set
        a.seqnum            = io_seqnum
      , a.param_name        = i_param_name
      , a.data_type         = i_data_type
      , a.lov_id            = i_lov_id
      , a.pattern           = i_pattern
      , a.tag_id            = i_tag_id
      , a.param_function    = i_param_function
    where
        a.id = i_id;

    com_api_i18n_pkg.add_text(
        i_table_name   => 'pmo_parameter'
      , i_column_name  => 'label'
      , i_object_id    => i_id
      , i_text         => i_label
      , i_lang         => i_lang
      , i_check_unique => com_api_type_pkg.TRUE
    );
    com_api_i18n_pkg.add_text(
        i_table_name   => 'pmo_parameter'
      , i_column_name  => 'description'
      , i_object_id    => i_id
      , i_text         => i_description
      , i_lang         => i_lang
      , i_check_unique => com_api_type_pkg.TRUE
    );

    io_seqnum := io_seqnum + 1;

end modify;

procedure remove(
    i_id                in     com_api_type_pkg.t_short_id
  , i_seqnum            in     com_api_type_pkg.t_seqnum
) is
begin
    for rec in (select
                    b.param_id
                from
                    pmo_purpose_parameter_vw b
                where
                    b.param_id = i_id)
    loop
        com_api_error_pkg.raise_error(
            i_error => 'PARAMETER_ALREADY_USED'
          , i_env_param1 => rec.param_id
        );
    end loop;
    update
        pmo_parameter_vw a
    set
        a.seqnum = i_seqnum
    where
        a.id = i_id;

    delete
        pmo_parameter_vw a
    where
        a.id = i_id;

    com_api_i18n_pkg.remove_text(
        i_table_name => 'pmo_parameter'
      , i_object_id  => i_id
    );
end remove;

end pmo_ui_parameter_pkg;
/

