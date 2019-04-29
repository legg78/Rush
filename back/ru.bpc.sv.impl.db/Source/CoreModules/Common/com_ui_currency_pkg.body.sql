create or replace package body com_ui_currency_pkg is

    procedure add_currency (
        o_id                        out com_api_type_pkg.t_tiny_id
        , o_seqnum                  out com_api_type_pkg.t_seqnum
        , i_code                    in com_api_type_pkg.t_curr_code
        , i_name                    in com_api_type_pkg.t_curr_name
        , i_exponent                in com_api_type_pkg.t_tiny_id
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_currency_name           in com_api_type_pkg.t_name
    ) is
    begin
        o_id := com_currency_seq.nextval;
        o_seqnum := 1;

        insert into com_currency_vw (
            id
            , seqnum
            , code
            , name
            , exponent
        ) values (
            o_id
            , o_seqnum
            , i_code
            , i_name
            , i_exponent
        );

        com_api_i18n_pkg.add_text (
            i_table_name     => 'com_currency'
            , i_column_name  => 'name'
            , i_object_id    => o_id
            , i_lang         => i_lang
            , i_text         => i_currency_name
            , i_check_unique  => com_api_type_pkg.TRUE
        );
    exception
        when dup_val_on_index then
            com_api_error_pkg.raise_error(
                i_error      => 'DUPLICATE_CURRENCY'
              , i_env_param1 => i_code
              , i_env_param2 => i_name
            );
    end;

    procedure modify_currency (
        i_id                        in com_api_type_pkg.t_tiny_id
        , io_seqnum                 in out com_api_type_pkg.t_seqnum
        , i_code                    in com_api_type_pkg.t_curr_code
        , i_name                    in com_api_type_pkg.t_curr_name
        , i_exponent                in com_api_type_pkg.t_tiny_id
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_currency_name           in com_api_type_pkg.t_name
    ) is
    begin
        update
            com_currency_vw
        set
            seqnum = io_seqnum
            , code = i_code
            , name = i_name
            , exponent = i_exponent
        where
            id = i_id;

        io_seqnum := io_seqnum + 1;

        com_api_i18n_pkg.add_text (
            i_table_name     => 'com_currency'
            , i_column_name  => 'name'
            , i_object_id    => i_id
            , i_lang         => i_lang
            , i_text         => i_currency_name
            , i_check_unique  => com_api_type_pkg.TRUE
        );

    exception
        when dup_val_on_index then
            com_api_error_pkg.raise_error(
                i_error      => 'DUPLICATE_CURRENCY'
              , i_env_param1 => i_code
              , i_env_param2 => i_name
            );
    end;

    procedure remove_currency (
        i_id                        in com_api_type_pkg.t_tiny_id
        , i_seqnum                  in com_api_type_pkg.t_seqnum
    ) is
    begin
        com_api_i18n_pkg.remove_text (
            i_table_name  => 'com_currency'
           , i_object_id  => i_id
        );

        update
            com_currency_vw
        set
            seqnum = i_seqnum
        where
            id = i_id;

        delete from
            com_currency_vw
        where
            id = i_id;
    end;

end;
/
