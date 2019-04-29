create or replace package body com_ui_rate_pair_pkg is
/************************************************************
 * UI for rate pair <br />
 * Created by Khougaev A.(khougaev@bpc.ru)  at 23.04.2010 <br />
 * Last changed by $Author$  <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: COM_UI_RATE_PAIR_PKG <br />
 * @headcom
 ************************************************************/
procedure add (
    o_id                    out com_api_type_pkg.t_tiny_id
    , o_seqnum              out com_api_type_pkg.t_tiny_id
    , i_rate_type           in com_api_type_pkg.t_dict_value
    , i_inst_id             in com_api_type_pkg.t_inst_id
    , i_src_currency        in com_api_type_pkg.t_curr_code
    , i_dst_currency        in com_api_type_pkg.t_curr_code
    , i_base_rate_type      in com_api_type_pkg.t_dict_value
    , i_base_rate_formula   in com_api_type_pkg.t_name
    , i_input_mode          in com_api_type_pkg.t_dict_value
    , i_inverted            in com_api_type_pkg.t_boolean
    , i_src_scale           in number
    , i_dst_scale           in number
    , i_rate_example        in com_api_type_pkg.t_rate
    , i_display_order       in com_api_type_pkg.t_tiny_id
    , i_label               in com_api_type_pkg.t_short_desc
    , i_lang                in com_api_type_pkg.t_dict_value
) is
begin

    if i_src_currency = i_dst_currency then
        com_api_error_pkg.raise_error(
            i_error      => 'RATE_SRC_EQ_DST'
          , i_env_param1 => i_src_currency
        );
    end if;

    -- check pair
    for rec in (select 1 from com_rate_pair_vw a
                where a.rate_type = i_rate_type
                and   a.inst_id = i_inst_id
                and   a.src_currency = i_src_currency
                and   a.dst_currency = i_dst_currency
               )
    loop
        com_api_error_pkg.raise_error(
            i_error      => 'RATE_PAIR_ALREADY_EXISTS'
          , i_env_param1 => i_inst_id
          , i_env_param2 => i_rate_type
          , i_env_param3 => i_src_currency
          , i_env_param4 => i_dst_currency
        );
    end loop;

    o_id := com_rate_pair_seq.nextval;
    o_seqnum := 1;

    insert into com_rate_pair_vw (
        id
        , seqnum
        , rate_type
        , inst_id
        , src_currency
        , dst_currency
        , base_rate_type
        , base_rate_formula
        , input_mode
        , inverted
        , src_scale
        , dst_scale
        , rate_example
        , display_order
    ) values (
        o_id
        , o_seqnum
        , i_rate_type
        , i_inst_id
        , i_src_currency
        , i_dst_currency
        , i_base_rate_type
        , i_base_rate_formula
        , i_input_mode
        , i_inverted
        , i_src_scale
        , i_dst_scale
        , i_rate_example
        , i_display_order
    );

    com_api_i18n_pkg.add_text (
        i_table_name  => 'COM_RATE_PAIR'
      , i_column_name => 'LABEL'
      , i_object_id   => o_id
      , i_text        => i_label
      , i_lang        => i_lang
    );
end add;

procedure modify (
    i_id                    in com_api_type_pkg.t_tiny_id
    , io_seqnum             in out com_api_type_pkg.t_tiny_id
    , i_rate_type           in com_api_type_pkg.t_dict_value
    , i_inst_id             in com_api_type_pkg.t_inst_id
    , i_base_rate_type      in com_api_type_pkg.t_dict_value
    , i_base_rate_formula   in com_api_type_pkg.t_name
    , i_input_mode          in com_api_type_pkg.t_dict_value
    , i_inverted            in com_api_type_pkg.t_boolean
    , i_src_scale           in number
    , i_dst_scale           in number
    , i_rate_example        in com_api_type_pkg.t_rate
    , i_display_order       in com_api_type_pkg.t_tiny_id
    , i_label               in com_api_type_pkg.t_short_desc
    , i_lang                in com_api_type_pkg.t_dict_value
) is
begin
    update
        com_rate_pair_vw
    set
        seqnum = io_seqnum
        , rate_type           = i_rate_type
        , inst_id             = i_inst_id
        , base_rate_type      = i_base_rate_type
        , base_rate_formula   = i_base_rate_formula
        , input_mode          = i_input_mode
        , inverted            = i_inverted
        , src_scale           = i_src_scale
        , dst_scale           = i_dst_scale
        , rate_example        = i_rate_example
        , display_order       = i_display_order
    where
        id = i_id;

    com_api_i18n_pkg.add_text (
        i_table_name  => 'COM_RATE_PAIR'
      , i_column_name => 'LABEL'
      , i_object_id   => i_id
      , i_text        => i_label
      , i_lang        => i_lang
    );

    io_seqnum := io_seqnum + 1;
end;

procedure remove (
    i_id                    in com_api_type_pkg.t_tiny_id
    , i_seqnum              in com_api_type_pkg.t_tiny_id
) is
begin
    update
        com_rate_pair_vw
    set
        seqnum = i_seqnum
    where
        id = i_id;

    delete from
        com_rate_pair_vw
    where
        id = i_id;

    com_api_i18n_pkg.remove_text (
        i_table_name => 'COM_RATE_PAIR'
      , i_object_id  => i_id
    );
end;

end;
/