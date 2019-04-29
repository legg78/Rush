create or replace package body pmo_ui_provider_pkg as
/************************************************************
 * UI for Payment Order Providers<br />
 * Created by Kryukov E.(krukov@bpc.ru)  at 14.07.2011  <br />
 * Last changed by $Author$  <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: PMO_UI_PROVIDER_PKG <br />
 * @headcom
 ************************************************************/

procedure add(
    o_id                   out com_api_type_pkg.t_short_id
  , o_seqnum               out com_api_type_pkg.t_seqnum
  , i_region_code       in     com_api_type_pkg.t_region_code
  , i_label             in     com_api_type_pkg.t_short_desc
  , i_description       in     com_api_type_pkg.t_full_desc
  , i_lang              in     com_api_type_pkg.t_dict_value
  , i_short_name        in     com_api_type_pkg.t_name
  , i_provider_number   in     com_api_type_pkg.t_name      default null
  , i_parent_id         in     com_api_type_pkg.t_short_id  default null
  , i_src_provider_id   in     com_api_type_pkg.t_short_id  default null
  , i_logo_path         in     com_api_type_pkg.t_name      default null
  , i_inst_id           in     com_api_type_pkg.t_inst_id   default null
) is
begin
    -- First of all it is necessary to check whether provider group <i_parent_id> is really provider group
    if  i_parent_id is not null
        and
        pmo_api_provider_pkg.is_provider_group(i_id => i_parent_id) = com_api_type_pkg.FALSE
    then
        com_api_error_pkg.raise_error(
            i_error      => 'IS_NOT_PROVIDER_GROUP'
          , i_env_param1 => i_parent_id
        );
    end if;

    o_id := pmo_provider_seq.nextval;
    o_seqnum := 1;

    insert into pmo_provider_vw(
        id
      , seqnum
      , parent_id
      , region_code
      , provider_number
      , logo_path
      , inst_id
    ) values (
        o_id
      , o_seqnum
      , i_parent_id
      , i_region_code
      , i_provider_number
      , i_logo_path
      , nvl(i_inst_id, ost_api_const_pkg.DEFAULT_INST)
    );

    com_api_i18n_pkg.add_text(
        i_table_name   => 'pmo_provider'
      , i_column_name  => 'label'
      , i_object_id    => o_id
      , i_text         => i_label
      , i_lang         => i_lang
      , i_check_unique => com_api_type_pkg.TRUE
    );

    com_api_i18n_pkg.add_text(
        i_table_name   => 'pmo_provider'
      , i_column_name  => 'description'
      , i_object_id    => o_id
      , i_text         => i_description
      , i_lang         => i_lang
      , i_check_unique => com_api_type_pkg.TRUE
    );

    com_api_i18n_pkg.add_text(
        i_table_name   => 'pmo_provider'
      , i_column_name  => 'short_name'
      , i_object_id    => o_id
      , i_text         => i_short_name
      , i_lang         => com_api_const_pkg.LANGUAGE_ENGLISH
      , i_check_unique => com_api_type_pkg.TRUE
    );

    -- Cloning purposes and parameters of source provider to a new one
    if i_src_provider_id is not null then
        if pmo_api_provider_pkg.provider_exists(i_src_provider_id) = com_api_type_pkg.FALSE then
            com_api_error_pkg.raise_error(
                i_error      => 'PROVIDER_DOESNT_EXIST'
              , i_env_param1 => i_src_provider_id
            );
        else
            pmo_api_provider_pkg.clone_purposes_and_params(
                i_src_provider_id => i_src_provider_id
              , i_dst_provider_id => o_id
            );
        end if;
    end if;
end add;

procedure modify(
    i_id                in     com_api_type_pkg.t_short_id
  , io_seqnum           in out com_api_type_pkg.t_seqnum
  , i_region_code       in     com_api_type_pkg.t_region_code
  , i_label             in     com_api_type_pkg.t_short_desc
  , i_description       in     com_api_type_pkg.t_full_desc
  , i_lang              in     com_api_type_pkg.t_dict_value
  , i_short_name        in     com_api_type_pkg.t_name
  , i_provider_number   in     com_api_type_pkg.t_name      default null
  , i_parent_id         in     com_api_type_pkg.t_short_id  default null
  , i_logo_path         in     com_api_type_pkg.t_name      default null
  , i_inst_id           in     com_api_type_pkg.t_inst_id   default null
) is
begin
    -- First of all it is necessary to check whether provider group <i_parent_id> is really provider group
    if  i_parent_id is not null
        and
        pmo_api_provider_pkg.is_provider_group(i_id => i_parent_id) = com_api_type_pkg.FALSE
    then
        com_api_error_pkg.raise_error(
            i_error      => 'IS_NOT_PROVIDER_GROUP'
          , i_env_param1 => i_parent_id
        );
    end if;

    update pmo_provider_vw a
       set seqnum           = io_seqnum
         , region_code      = i_region_code
         , provider_number  = nvl(i_provider_number, provider_number)
         , parent_id        = nvl(i_parent_id, parent_id)
         , logo_path        = nvl(i_logo_path, logo_path)
         , inst_id          = nvl(i_inst_id, inst_id)
     where id               = i_id;

    com_api_i18n_pkg.add_text(
        i_table_name   => 'pmo_provider'
      , i_column_name  => 'label'
      , i_object_id    => i_id
      , i_text         => i_label
      , i_lang         => i_lang
      , i_check_unique => com_api_type_pkg.TRUE
    );

    com_api_i18n_pkg.add_text(
        i_table_name   => 'pmo_provider'
      , i_column_name  => 'description'
      , i_object_id    => i_id
      , i_text         => i_description
      , i_lang         => i_lang
      , i_check_unique => com_api_type_pkg.TRUE
    );

    com_api_i18n_pkg.add_text(
        i_table_name   => 'pmo_provider'
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
    -- remove hosts
    null;

    update pmo_provider_vw
       set seqnum = i_seqnum
     where id     = i_id;

    delete pmo_provider_vw a
     where id     = i_id;

    -- remove pmo_purpose
    for rec in (
        select id from pmo_purpose_vw where provider_id = i_id
    ) loop
        pmo_ui_purpose_pkg.remove(rec.id);
    end loop;

    com_api_i18n_pkg.remove_text(
        i_table_name => 'pmo_provider'
      , i_object_id  => i_id
    );
end remove;

end pmo_ui_provider_pkg;
/
