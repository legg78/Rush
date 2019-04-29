create or replace package body acc_ui_scheme_pkg as
/*********************************************************
*  Account schemes UI  <br />
*  Created by Kryukov E.(krukov@bpcsv.com)  at 28.08.2012 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: ACC_UI_SCHEME_PKG <br />
*  @headcom
**********************************************************/

procedure add(
    o_id                     out com_api_type_pkg.t_tiny_id
  , o_seqnum                 out com_api_type_pkg.t_tiny_id
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_name                in     com_api_type_pkg.t_name
  , i_description         in     com_api_type_pkg.t_short_desc
  , i_lang                in     com_api_type_pkg.t_dict_value
) is
begin
    o_id     := acc_scheme_seq.nextval;
    o_seqnum := 1;

    insert into acc_scheme_vw(
        id
      , seqnum
      , inst_id
    ) values (
        o_id
      , o_seqnum
      , i_inst_id
    );

    com_api_i18n_pkg.add_text(
        i_table_name    => 'acc_scheme'
      , i_column_name   => 'name'
      , i_object_id     => o_id
      , i_lang          => i_lang
      , i_text          => i_name
      , i_check_unique  => com_api_type_pkg.TRUE
    );

    com_api_i18n_pkg.add_text(
        i_table_name    => 'acc_scheme'
      , i_column_name   => 'description'
      , i_object_id     => o_id
      , i_lang          => i_lang
      , i_text          => i_description
    );
end add;

procedure modify(
    i_id                  in     com_api_type_pkg.t_tiny_id
  , io_seqnum             in out com_api_type_pkg.t_tiny_id
  , i_name                in     com_api_type_pkg.t_name
  , i_description         in     com_api_type_pkg.t_short_desc
  , i_lang                in     com_api_type_pkg.t_dict_value
) is
begin
    io_seqnum := io_seqnum + 1;

    com_api_i18n_pkg.add_text(
        i_table_name    => 'acc_scheme'
      , i_column_name   => 'name'
      , i_object_id     => i_id
      , i_lang          => i_lang
      , i_text          => i_name
      , i_check_unique  => com_api_type_pkg.TRUE
    );

    com_api_i18n_pkg.add_text(
        i_table_name    => 'acc_scheme'
      , i_column_name   => 'description'
      , i_object_id     => i_id
      , i_lang          => i_lang
      , i_text          => i_description
    );

end modify;

procedure remove(
    i_id                  in    com_api_type_pkg.t_tiny_id
  , i_seqnum              in    com_api_type_pkg.t_tiny_id
) is
begin
    update
        acc_scheme_vw
    set
        seqnum = i_seqnum
    where
        id = i_id;
    
    delete
        acc_scheme_vw
    where
        id = i_id;

    com_api_i18n_pkg.remove_text(
        i_table_name  => 'acc_scheme'
      , i_object_id   => i_id
    );

end remove;

procedure add_account(
    o_id                     out com_api_type_pkg.t_medium_id
  , o_seqnum                 out com_api_type_pkg.t_tiny_id
  , i_scheme_id           in     com_api_type_pkg.t_tiny_id
  , i_account_type        in     com_api_type_pkg.t_dict_value
  , i_entity_type         in     com_api_type_pkg.t_dict_value
  , i_object_id           in     com_api_type_pkg.t_long_id
  , i_mod_id              in     com_api_type_pkg.t_tiny_id
  , i_account_id          in     com_api_type_pkg.t_account_id
) is
begin
    o_id     := acc_scheme_account_seq.nextval;
    o_seqnum := 1;

    insert into acc_scheme_account_vw(
        id
      , seqnum
      , scheme_id
      , account_type
      , entity_type
      , object_id
      , mod_id
      , account_id
    ) values (
        o_id
      , o_seqnum
      , i_scheme_id
      , i_account_type
      , i_entity_type
      , i_object_id
      , i_mod_id
      , i_account_id
    );
    trc_log_pkg.info('Created acc_scheme_account with id = ' || o_id);

end add_account;

procedure modify_account(
    i_id                  in     com_api_type_pkg.t_medium_id
  , io_seqnum             in out com_api_type_pkg.t_tiny_id
  , i_scheme_id           in     com_api_type_pkg.t_tiny_id
  , i_account_type        in     com_api_type_pkg.t_dict_value
  , i_entity_type         in     com_api_type_pkg.t_dict_value
  , i_object_id           in     com_api_type_pkg.t_long_id
  , i_mod_id              in     com_api_type_pkg.t_tiny_id
  , i_account_id          in     com_api_type_pkg.t_account_id
) is
begin
    update
        acc_scheme_account_vw a
    set
        a.seqnum    = io_seqnum
      , a.scheme_id = i_scheme_id
      , a.account_type = i_account_type
      , a.entity_type  = i_entity_type
      , a.object_id    = i_object_id
      , a.mod_id       = i_mod_id
      , a.account_id   = i_account_id
    where
        a.id = i_id;

    io_seqnum := io_seqnum + 1;
    trc_log_pkg.info('Modified acc_scheme_account with id = ' || i_id);
end modify_account;

procedure remove_account(
    i_id                  in     com_api_type_pkg.t_medium_id
  , i_seqnum              in     com_api_type_pkg.t_tiny_id
) is
begin
    update
        acc_scheme_account_vw a
    set
        a.seqnum = i_seqnum
    where
        a.id = i_id;

    delete
        acc_scheme_account_vw a
    where
        a.id = i_id;
    trc_log_pkg.info('Removed acc_scheme_account with id = ' || i_id);
end remove_account;


end acc_ui_scheme_pkg;
/
