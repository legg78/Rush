create or replace package body sec_ui_authority_pkg is
/************************************************************
 * User interface for certificate authority centers <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 12.05.2011 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: sec_ui_authority_pkg <br />
 * @headcom
 ************************************************************/

    procedure add_authority (
        o_id                    out com_api_type_pkg.t_tiny_id
        , o_seqnum              out com_api_type_pkg.t_seqnum
        , i_type                in com_api_type_pkg.t_dict_value
        , i_rid                 in sec_api_type_pkg.t_subject_id
        , i_lang                in com_api_type_pkg.t_dict_value
        , i_name                in com_api_type_pkg.t_name
    ) is
    begin
        o_id := sec_authority_seq.nextval;
        o_seqnum := 1;

        insert into sec_authority_vw (
            id
            , seqnum
            , type
            , rid
        ) values (
            o_id
            , o_seqnum
            , i_type
            , i_rid
        );

        com_api_i18n_pkg.add_text (
            i_table_name     => 'sec_authority'
            , i_column_name  => 'name'
            , i_object_id    => o_id
            , i_lang         => i_lang
            , i_text         => i_name
            , i_check_unique => com_api_type_pkg.TRUE
        );
    exception
        when dup_val_on_index then
            com_api_error_pkg.raise_error (
                i_error         => 'DUPLICATE_AUTHORITY'
                , i_env_param1  => i_type
                , i_env_param2  => i_rid
            );
    end;

    procedure modify_authority (
        i_id                    in com_api_type_pkg.t_tiny_id
        , io_seqnum             in out com_api_type_pkg.t_seqnum
        , i_type                in com_api_type_pkg.t_dict_value
        , i_rid                 in sec_api_type_pkg.t_subject_id
        , i_lang                in com_api_type_pkg.t_dict_value
        , i_name                in com_api_type_pkg.t_name
    ) is
    begin
        update
            sec_authority_vw
        set
            seqnum = io_seqnum
            , type = i_type
            , rid = i_rid
        where
            id = i_id;

        io_seqnum := io_seqnum + 1;

        com_api_i18n_pkg.add_text (
            i_table_name     => 'sec_authority'
            , i_column_name  => 'name'
            , i_object_id    => i_id
            , i_lang         => i_lang
            , i_text         => i_name
            , i_check_unique => com_api_type_pkg.TRUE
        );
    exception
        when dup_val_on_index then
            com_api_error_pkg.raise_error (
                i_error         => 'DUPLICATE_AUTHORITY'
                , i_env_param1  => i_type
                , i_env_param2  => i_rid
            );
    end;

    procedure remove_authority (
        i_id                    in com_api_type_pkg.t_tiny_id
        , i_seqnum              in com_api_type_pkg.t_seqnum
    ) is
    begin
        com_api_i18n_pkg.remove_text (
            i_table_name   => 'sec_authority'
            , i_object_id  => i_id
        );

        update
            sec_authority_vw
        set
            seqnum = i_seqnum
        where
            id = i_id;

        delete from
            sec_authority_vw
        where
            id = i_id;
    end;

end;
/
