create or replace package body acq_ui_account_scheme_pkg as
/*********************************************************
*  Acquiring - account schemes user interface <br />
*  Created by Fomichev A.(fomichev@bpc.ru)  at 18.11.2010 <br />
*  Last changed by $Author: fomichev $ <br />
*  $LastChangedDate:: 2010-11-29 12:44:14 +0400#$ <br />
*  Revision: $LastChangedRevision: 6774 $ <br />
*  Module: ACQ_UI_ACCOUNT_SCHEME_PKG <br />
*  @headcom
**********************************************************/
procedure add_account_scheme (
    o_id               out  com_api_type_pkg.t_tiny_id
  , o_seqnum           out  com_api_type_pkg.t_seqnum
  , i_inst_id      in       com_api_type_pkg.t_inst_id
  , i_label        in       com_api_type_pkg.t_name
  , i_description  in       com_api_type_pkg.t_full_desc
  , i_lang         in       com_api_type_pkg.t_dict_value  default null
) is
begin
    if com_api_i18n_pkg.text_is_present(i_table_name   => 'acq_account_scheme'
                                      , i_column_name  => 'label'
                                      , i_inst_id       => i_inst_id
                                      , i_text          => i_label
                                      , i_lang          => i_lang
       ) = com_api_type_pkg.TRUE
    then
        com_api_error_pkg.raise_error(
           i_error       => 'DUPLICATE_DESCRIPTION_IN_INSTITUTE'
         , i_env_param1  => 'ACQ_ACCOUNT_SCHEME'
         , i_env_param2  => 'LABEL'
         , i_env_param3  => i_inst_id
         , i_env_param4  => i_label
         , i_env_param5  => i_lang
        );

    else
        o_id     := acq_account_scheme_seq.nextval;
        o_seqnum := 1;

        insert into acq_account_scheme_vw(
            id
          , seqnum
          , inst_id
        ) values (
            o_id
          , o_seqnum
          , i_inst_id
        );

        if i_label is not null then
            com_api_i18n_pkg.add_text(
                i_table_name    => 'acq_account_scheme'
              , i_column_name   => 'label'
              , i_object_id     => o_id
              , i_lang          => i_lang
              , i_text          => i_label
            );
        end if;

        if i_description is not null then
            com_api_i18n_pkg.add_text(
                i_table_name    => 'acq_account_scheme'
              , i_column_name   => 'description'
              , i_object_id     => o_id
              , i_lang          => i_lang
              , i_text          => i_description
            );
        end if;
    end if;
end;

procedure modify_account_scheme(
    i_id           in       com_api_type_pkg.t_tiny_id
  , io_seqnum      in  out  com_api_type_pkg.t_seqnum
  , i_inst_id      in       com_api_type_pkg.t_inst_id
  , i_label        in       com_api_type_pkg.t_name
  , i_description  in       com_api_type_pkg.t_full_desc
  , i_lang         in       com_api_type_pkg.t_dict_value  default null
) is
begin
    update acq_account_scheme_vw
    set inst_id = i_inst_id
      , seqnum  = io_seqnum
    where id    = i_id;

    io_seqnum := io_seqnum + 1;

    if i_label is not null then
        -- New label for the account's scheme have to be unique within the institute <i_inst_id>
        if com_api_i18n_pkg.text_is_present(i_table_name   => 'acq_account_scheme'
                                          , i_column_name  => 'label'
                                          , i_inst_id       => i_inst_id
                                          , i_text          => i_label
                                          , i_lang          => i_lang
           ) = com_api_type_pkg.TRUE
           and i_label !=  com_api_i18n_pkg.get_text(i_table_name   => 'acq_account_scheme'
                                                    , i_column_name => 'label'
                                                    , i_object_id   => i_id
                                                    , i_lang        => i_lang)
        then
            com_api_error_pkg.raise_error(
               i_error       => 'DUPLICATE_DESCRIPTION_IN_INSTITUTE'
             , i_env_param1  => 'ACQ_ACCOUNT_SCHEME'
             , i_env_param2  => 'LABEL'
             , i_env_param3  => i_inst_id
             , i_env_param4  => i_label
             , i_env_param5  => i_lang
            );
        else
            com_api_i18n_pkg.add_text(
                i_table_name    => 'acq_account_scheme'
              , i_column_name   => 'label'
              , i_object_id     => i_id
              , i_lang          => i_lang
              , i_text          => i_label
            );
        end if;
    end if;

    if i_description is not null then
        com_api_i18n_pkg.add_text(
            i_table_name    => 'acq_account_scheme'
          , i_column_name   => 'description'
          , i_object_id     => i_id
          , i_lang          => i_lang
          , i_text          => i_description
        );
    end if;
end;

procedure remove_account_scheme(
    i_id      in       com_api_type_pkg.t_tiny_id
  , i_seqnum  in       com_api_type_pkg.t_seqnum
) is
begin
    -- check if used
    for rec in (
        select
            a.customer_id
            , com_api_i18n_pkg.get_text('acq_account_scheme','label', i_id, get_user_lang) scheme_name
        from
            acq_account_customer_vw a
        where
            a.scheme_id = i_id
        and
            rownum = 1)
    loop
        com_api_error_pkg.raise_error(
            i_error      => 'ACC_SCHEME_ALREADY_USED'
          , i_env_param1 => rec.scheme_name
          , i_env_param2 => rec.customer_id
        );
    end loop;

    -- remove account pattern
    for rec in (
        select
            b.id
          , b.seqnum
        from
            acq_account_pattern_vw b
        where
            b.scheme_id = i_id)
    loop
        acq_ui_account_pattern_pkg.remove_account_pattern(
            i_id     => rec.id
          , i_seqnum => rec.seqnum
        );
    end loop;

    -- remove scheme
    update acq_account_scheme_vw
       set seqnum = i_seqnum
     where id   = i_id;

    delete from acq_account_scheme_vw
    where id   = i_id;

end remove_account_scheme;

end;
/
