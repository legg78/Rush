create or replace package body amx_api_add_pkg as

procedure get_incoming_emv_data(
    io_add_chip_rec         in out nocopy amx_api_type_pkg.t_amx_add_chip_rec
  , i_mask_error            in            com_api_type_pkg.t_boolean default com_api_type_pkg.TRUE
  , i_emv_data              in            com_api_type_pkg.t_text
) is
    l_data                  com_api_type_pkg.t_name;
    l_is_binary             com_api_type_pkg.t_boolean := emv_api_tag_pkg.is_binary();
    l_ll_length             pls_integer := 0;
    l_offset                pls_integer := 0;

    function get_field (
        i_start       in pls_integer
        , i_length    in pls_integer
    ) return varchar2 is
    begin
        return trim(substr(i_emv_data, i_start, i_length));
    end;

begin
    trc_log_pkg.debug(
        i_text => lower($$PLSQL_UNIT) || '.get_emv_data: l_is_binary [' || l_is_binary
                                      || '], i_mask_error [' || i_mask_error
                                      || '], i_emv_data [' || i_emv_data || ']'
    );

    io_add_chip_rec.icc_version_name   := 'AGNS';
    io_add_chip_rec.icc_version_number := '0001';
    io_add_chip_rec.emv_9f26           := get_field(9, 16);

    l_ll_length                        := to_number(get_field(25, 2)) * 2;
    io_add_chip_rec.emv_9f10           := get_field(27, l_ll_length);
    l_offset                           := 27 + l_ll_length;
    io_add_chip_rec.emv_9f37           := get_field(l_offset, 8);
    l_offset                           := l_offset + 8;
    io_add_chip_rec.emv_9f36           := get_field(l_offset, 4);
    l_offset                           := l_offset + 4;
    io_add_chip_rec.emv_95             := get_field(l_offset, 10);
    l_offset                           := l_offset + 10;
    io_add_chip_rec.emv_9a             := to_date(get_field(l_offset, 6), 'yymmdd');
    l_offset                           := l_offset + 6;
    io_add_chip_rec.emv_9c             := to_number(get_field(l_offset, 2));
    l_offset                           := l_offset + 2;
    io_add_chip_rec.emv_9f02           := to_number(get_field(l_offset, 12));
    l_offset                           := l_offset + 12;
    io_add_chip_rec.emv_5f2a           := to_number(get_field(l_offset, 4));
    l_offset                           := l_offset + 4;
    io_add_chip_rec.emv_9f1a           := to_number(get_field(l_offset, 4));
    l_offset                           := l_offset + 4;
    io_add_chip_rec.emv_82             := get_field(l_offset, 4);
    l_offset                           := l_offset + 4;
    io_add_chip_rec.emv_9f03           := to_number(get_field(l_offset, 12));
    l_offset                           := l_offset + 12;
    io_add_chip_rec.emv_5f34           := to_number(get_field(l_offset, 2));
    l_offset                           := l_offset + 2;
    io_add_chip_rec.emv_9f27           := get_field(l_offset, 2);

    trc_log_pkg.debug(
        i_text => lower($$PLSQL_UNIT) || '.get_emv_data: l_data [' || l_data || ']'
    );
exception
    when others then
        trc_log_pkg.debug(
            i_text        => lower($$PLSQL_UNIT) || '.get_emv_data FAILED with [#1]; dumping o_emv_tag_tab...'
          , i_env_param1  => sqlerrm
        );
end;

function format_tag_value (
    i_tag_value         in com_api_type_pkg.t_name
  , i_length            in com_api_type_pkg.t_tiny_id
  , i_ll_length         in com_api_type_pkg.t_boolean   default com_api_type_pkg.FALSE
) return com_api_type_pkg.t_name
is
    l_tag_length        pls_integer := 0;
    l_tag_value         com_api_type_pkg.t_name;
begin
    l_tag_value  := i_tag_value;
    l_tag_length := length(l_tag_value);

    if mod(l_tag_length, 2) > 0 then

        l_tag_value  := '0' || l_tag_value;
        l_tag_length := l_tag_length + 1;
    end if;

    if i_ll_length = com_api_type_pkg.TRUE then

        l_tag_value := prs_api_util_pkg.ber_tlv_length(l_tag_value) || l_tag_value;
    else
        l_tag_value := lpad(l_tag_value, i_length*2, '0');
    end if;

    return l_tag_value;
end;

procedure get_outgoing_emv_data(
    io_fin_rec              in out nocopy amx_api_type_pkg.t_amx_add_chip_rec
  , i_mask_error            in            com_api_type_pkg.t_boolean default com_api_type_pkg.TRUE
  , i_emv_data              in            com_api_type_pkg.t_text
  , o_format_data           out           com_api_type_pkg.t_text
) is
    l_is_binary             com_api_type_pkg.t_boolean := emv_api_tag_pkg.is_binary();
    l_emv_data              com_api_type_pkg.t_full_desc;
    l_emv_tag_tab           com_api_type_pkg.t_tag_value_tab;
    l_date                  com_api_type_pkg.t_dict_value;
begin
    trc_log_pkg.debug(
        i_text => lower($$PLSQL_UNIT) || '.get_emv_data: l_is_binary [' || l_is_binary
                                      || '], i_mask_error [' || i_mask_error
                                      || '], i_emv_data [' || i_emv_data || ']'
    );

    emv_api_tag_pkg.parse_emv_data(
        i_emv_data       => i_emv_data
      , i_is_binary      => l_is_binary
      , o_emv_tag_tab    => l_emv_tag_tab
    );

    io_fin_rec.icc_version_name   := 'AGNS';
    l_emv_data := io_fin_rec.icc_version_name;

    io_fin_rec.icc_version_number := '0001';
    l_emv_data := l_emv_data || io_fin_rec.icc_version_number;

    io_fin_rec.emv_9f26 := emv_api_tag_pkg.get_tag_value (
        i_tag            => '9F26'
        , i_emv_tag_tab  => l_emv_tag_tab
        , i_mask_error   => i_mask_error
    );
    l_emv_data := l_emv_data || format_tag_value (io_fin_rec.emv_9f26, 8 ,com_api_type_pkg.FALSE);

    io_fin_rec.emv_9f10 := emv_api_tag_pkg.get_tag_value (
        i_tag            => '9F10'
        , i_emv_tag_tab  => l_emv_tag_tab
        , i_mask_error   => i_mask_error
    );
    l_emv_data := l_emv_data || format_tag_value (io_fin_rec.emv_9f10, 33 ,com_api_type_pkg.TRUE);

    io_fin_rec.emv_9f37 := emv_api_tag_pkg.get_tag_value (
        i_tag            => '9F37'
        , i_emv_tag_tab  => l_emv_tag_tab
        , i_mask_error   => i_mask_error
    );
    l_emv_data := l_emv_data || format_tag_value (io_fin_rec.emv_9f37, 4 ,com_api_type_pkg.FALSE);

    io_fin_rec.emv_9f36 := emv_api_tag_pkg.get_tag_value (
        i_tag            => '9F36'
        , i_emv_tag_tab  => l_emv_tag_tab
        , i_mask_error   => i_mask_error
    );
    l_emv_data := l_emv_data || format_tag_value (io_fin_rec.emv_9f36, 2 ,com_api_type_pkg.FALSE);

    io_fin_rec.emv_95 := emv_api_tag_pkg.get_tag_value (
        i_tag            => '95'
        , i_emv_tag_tab  => l_emv_tag_tab
        , i_mask_error   => i_mask_error
    );
    l_emv_data := l_emv_data || format_tag_value (io_fin_rec.emv_95, 5 ,com_api_type_pkg.FALSE);

    io_fin_rec.emv_9a := to_date(emv_api_tag_pkg.get_tag_value (
        i_tag            => '9A'
        , i_emv_tag_tab  => l_emv_tag_tab
        , i_mask_error   => i_mask_error
    ), amx_api_const_pkg.FORMAT_SHORT_DATE);
    l_date := to_char(io_fin_rec.emv_9a, amx_api_const_pkg.FORMAT_SHORT_DATE);
    l_emv_data := l_emv_data || format_tag_value (l_date, 3 ,com_api_type_pkg.FALSE);

    io_fin_rec.emv_9c := emv_api_tag_pkg.get_tag_value (
        i_tag            => '9C'
        , i_emv_tag_tab  => l_emv_tag_tab
        , i_mask_error   => i_mask_error
    );
    l_emv_data := l_emv_data || format_tag_value (io_fin_rec.emv_9c, 1 ,com_api_type_pkg.FALSE);

    io_fin_rec.emv_9f02 := emv_api_tag_pkg.get_tag_value (
        i_tag            => '9F02'
        , i_emv_tag_tab  => l_emv_tag_tab
        , i_mask_error   => i_mask_error
    );
    l_emv_data := l_emv_data || format_tag_value (io_fin_rec.emv_9f02, 6 ,com_api_type_pkg.FALSE);

    io_fin_rec.emv_5f2a := emv_api_tag_pkg.get_tag_value (
        i_tag            => '5F2A'
        , i_emv_tag_tab  => l_emv_tag_tab
        , i_mask_error   => i_mask_error
    );
    l_emv_data := l_emv_data || format_tag_value (io_fin_rec.emv_5f2a, 2 ,com_api_type_pkg.FALSE);

    io_fin_rec.emv_9f1a := emv_api_tag_pkg.get_tag_value (
        i_tag            => '9F1A'
        , i_emv_tag_tab  => l_emv_tag_tab
        , i_mask_error   => i_mask_error
    );
    l_emv_data := l_emv_data || format_tag_value (io_fin_rec.emv_9f1a, 2 ,com_api_type_pkg.FALSE);

    io_fin_rec.emv_82 := emv_api_tag_pkg.get_tag_value (
        i_tag            => '82'
        , i_emv_tag_tab  => l_emv_tag_tab
        , i_mask_error   => i_mask_error
    );
    l_emv_data := l_emv_data || format_tag_value (io_fin_rec.emv_82, 2 ,com_api_type_pkg.FALSE);

    io_fin_rec.emv_9f03 := nvl(emv_api_tag_pkg.get_tag_value (
        i_tag            => '9F03'
        , i_emv_tag_tab  => l_emv_tag_tab
        , i_mask_error   => i_mask_error
    ), '0');
    l_emv_data := l_emv_data || format_tag_value (io_fin_rec.emv_9f03, 6 ,com_api_type_pkg.FALSE);

    io_fin_rec.emv_5f34 := emv_api_tag_pkg.get_tag_value (
        i_tag            => '5F34'
        , i_emv_tag_tab  => l_emv_tag_tab
        , i_mask_error   => i_mask_error
    );
    l_emv_data := l_emv_data || format_tag_value (io_fin_rec.emv_5f34, 1 ,com_api_type_pkg.FALSE);

    io_fin_rec.emv_9f27 := emv_api_tag_pkg.get_tag_value (
        i_tag            => '9F27'
        , i_emv_tag_tab  => l_emv_tag_tab
        , i_mask_error   => i_mask_error
    );
    l_emv_data := l_emv_data || format_tag_value (io_fin_rec.emv_9f27, 1 ,com_api_type_pkg.FALSE);

    l_emv_data := rpad(l_emv_data, 508, '40'); -- (((256 - 4) * 2) + 4) first char

    o_format_data := l_emv_data;

    trc_log_pkg.debug(
        i_text => 'o_format_data length = ' || length(o_format_data)
    );

exception
    when others then -- removed EMV parsing when loading because it is not necessary
        trc_log_pkg.debug(
            i_text        => lower($$PLSQL_UNIT) || '.get_emv_data FAILED with [#1]; dumping o_emv_tag_tab...'
          , i_env_param1  => sqlerrm
        );
        emv_api_tag_pkg.dump_tag_table(
            i_emv_tag_tab    => l_emv_tag_tab
          , i_is_debug_only  => com_api_type_pkg.FALSE
        );
end;

procedure put_chip_message (
    i_add_chip_rec               in amx_api_type_pkg.t_amx_add_chip_rec
)
is
begin
    insert into amx_add_chip (
          id
        , fin_id
        , file_id
        , icc_data
        , icc_version_name
        , icc_version_number
        , emv_9f26
        , emv_9f10
        , emv_9f37
        , emv_9f36
        , emv_95
        , emv_9a
        , emv_9c
        , emv_9f02
        , emv_5f2a
        , emv_9f1a
        , emv_82
        , emv_9f03
        , emv_5f34
        , emv_9f27
        , message_seq_number
        , transaction_id
        , message_number
    ) values (
          i_add_chip_rec.id
        , i_add_chip_rec.fin_id
        , i_add_chip_rec.file_id
        , i_add_chip_rec.icc_data
        , i_add_chip_rec.icc_version_name
        , i_add_chip_rec.icc_version_number
        , i_add_chip_rec.emv_9f26
        , i_add_chip_rec.emv_9f10
        , i_add_chip_rec.emv_9f37
        , i_add_chip_rec.emv_9f36
        , i_add_chip_rec.emv_95
        , i_add_chip_rec.emv_9a
        , i_add_chip_rec.emv_9c
        , i_add_chip_rec.emv_9f02
        , i_add_chip_rec.emv_5f2a
        , i_add_chip_rec.emv_9f1a
        , i_add_chip_rec.emv_82
        , i_add_chip_rec.emv_9f03
        , i_add_chip_rec.emv_5f34
        , i_add_chip_rec.emv_9f27
        , i_add_chip_rec.message_seq_number
        , i_add_chip_rec.transaction_id
        , i_add_chip_rec.message_number
    );
end;

procedure put_general_message (
    i_add_fin_rec               in amx_api_type_pkg.t_amx_add_rec
)
is
begin
    insert into amx_add (
        id
        , fin_id
        , file_id
        , is_incoming
        , mtid
        , addenda_type
        , format_code
        , message_seq_number
        , transaction_id
        , message_number
        , reject_reason_code
    ) values (
        i_add_fin_rec.id
        , i_add_fin_rec.fin_id
        , i_add_fin_rec.file_id
        , i_add_fin_rec.is_incoming
        , i_add_fin_rec.mtid
        , i_add_fin_rec.addenda_type
        , i_add_fin_rec.format_code
        , i_add_fin_rec.message_seq_number
        , i_add_fin_rec.transaction_id
        , i_add_fin_rec.message_number
        , i_add_fin_rec.reject_reason_code
    );
end;

procedure create_incoming_addenda (
    i_tc_buffer              in com_api_type_pkg.t_raw_data
    , i_file_id              in com_api_type_pkg.t_long_id
    , i_fin_id               in com_api_type_pkg.t_long_id
) is
    l_add_rec                amx_api_type_pkg.t_amx_add_rec;
    l_add_chip_rec           amx_api_type_pkg.t_amx_add_chip_rec;
    l_emv_tag_tab            com_api_type_pkg.t_tag_value_tab;
    l_offset                 pls_integer := 0;

    function get_field (
        i_start       in pls_integer
        , i_length    in pls_integer
    ) return varchar2 is
    begin
        return trim(substr(i_tc_buffer, i_start, i_length));
    end;

begin
    trc_log_pkg.debug(
        i_text => 'Create incoming addenda start'
    );

    l_add_rec.id                   := opr_api_create_pkg.get_id;
    l_add_rec.fin_id               := i_fin_id;
    l_add_rec.file_id              := i_file_id;
    l_add_rec.is_incoming          := com_api_type_pkg.TRUE;
    l_add_rec.mtid                 := amx_api_const_pkg.MTID_ADDENDA;

    l_add_rec.addenda_type         := get_field(5, 2);

    l_offset := get_offset(i_addenda_type => l_add_rec.addenda_type);

    l_add_rec.message_seq_number        := to_number(get_field(938 + l_offset, 3));
    l_add_rec.transaction_id            := get_field(1006 + l_offset, 15);
    l_add_rec.message_number            := to_number(get_field(1032 + l_offset, 8));
    l_add_rec.reject_reason_code        := get_field(1279 + l_offset , 40);

    -- general
    if l_add_rec.addenda_type = amx_api_const_pkg.ADDENDA_TYPE_INDUSTRY then

        l_add_rec.format_code               := get_field(923, 2);

        -- Check format_code fo future use. It can be 01-Airline, 02-Retail, 04-Insurance, 05-Auto Rental, etc.
        -- For every format_code need to create new table to store data.
        -- Currently is supported 20 - General Format only.

        -- Amx_add is used for store general information about other addenda also.
        -- For example, addenda_type = 07. We save into amx_add general information about any addenda: addenda_type, message_seq_number, message_number, transaction_id.
        -- Other information by addenda_type = 07 is stored into amx_add_chip.
        -- It is needed for simply getting addenda messages by fin_message_id. We can get all addenda from one table - amx_add
        -- and then get specific data of addenda by addenda type.

    -- chip addenda
    elsif l_add_rec.addenda_type = amx_api_const_pkg.ADDENDA_TYPE_CHIP then

        l_add_chip_rec.id                   := l_add_rec.id;
        l_add_chip_rec.fin_id               := i_fin_id;
        l_add_chip_rec.file_id              := i_file_id;
        l_add_chip_rec.icc_data             := get_field(586, 512);
        l_add_chip_rec.icc_version_name     := get_field(586, 4);
        l_add_chip_rec.icc_version_number   := substrb(i_tc_buffer, 590, 2);

        l_add_chip_rec.message_seq_number   := l_add_rec.message_seq_number;
        l_add_chip_rec.transaction_id       := l_add_rec.transaction_id;
        l_add_chip_rec.message_number       := l_add_rec.message_number;

        trc_log_pkg.debug(
            i_text => 'icc_version_name [' || l_add_chip_rec.icc_version_name || '], icc_version_number [' || l_add_chip_rec.icc_version_number || ']'
        );

        if l_add_chip_rec.icc_data is not null then

            get_incoming_emv_data(
                io_add_chip_rec  => l_add_chip_rec
              , i_mask_error     => com_api_type_pkg.TRUE
              , i_emv_data       => l_add_chip_rec.icc_data
            );
        end if;

    else
        trc_log_pkg.debug(
            i_text => 'Not supported addenda with addenda_type [' || l_add_rec.addenda_type || ']'
        );

    end if;

    put_general_message (
        i_add_fin_rec    => l_add_rec
    );

    if l_add_rec.addenda_type = amx_api_const_pkg.ADDENDA_TYPE_CHIP then

        put_chip_message (
            i_add_chip_rec  => l_add_chip_rec
        );
    end if;

    trc_log_pkg.debug(
        i_text => 'Create incoming addenda end'
    );

end;

procedure create_outgoing_addenda (
    i_fin_rec                in amx_api_type_pkg.t_amx_fin_mes_rec
    , i_auth_rec             in aut_api_type_pkg.t_auth_rec
    , i_addenda_type         in com_api_type_pkg.t_byte_char
    , i_collection_only      in com_api_type_pkg.t_boolean
    , i_message_seq_number   in com_api_type_pkg.t_tiny_id
)is
    l_add_rec                amx_api_type_pkg.t_amx_add_rec;
    l_add_chip_rec           amx_api_type_pkg.t_amx_add_chip_rec;
begin
    trc_log_pkg.debug(
        i_text => 'Create outgoing addenda start'
    );
    -- set common addenda
    l_add_rec.id            := opr_api_create_pkg.get_id;
    l_add_rec.fin_id        := i_fin_rec.id;
    l_add_rec.is_incoming   := com_api_type_pkg.FALSE;

    if nvl(i_collection_only, com_api_type_pkg.FALSE) = com_api_type_pkg.FALSE then
        l_add_rec.mtid      := amx_api_const_pkg.MTID_ADDENDA;
    else
        l_add_rec.mtid      := amx_api_const_pkg.MTID_DC_ADDENDA;
    end if;

    l_add_rec.message_seq_number := i_message_seq_number;
    l_add_rec.addenda_type       := i_addenda_type;
    l_add_rec.transaction_id     := i_fin_rec.transaction_id;

    if i_addenda_type = amx_api_const_pkg.ADDENDA_TYPE_INDUSTRY then

        l_add_rec.format_code        := i_fin_rec.format_code;

    elsif i_addenda_type = amx_api_const_pkg.ADDENDA_TYPE_CHIP then

        l_add_chip_rec.id             := l_add_rec.id;
        l_add_chip_rec.fin_id         := i_fin_rec.id;
        l_add_chip_rec.message_seq_number := l_add_rec.message_seq_number;
        l_add_chip_rec.transaction_id := l_add_rec.transaction_id;

        get_outgoing_emv_data(
            io_fin_rec    => l_add_chip_rec
          , i_mask_error  => com_api_type_pkg.TRUE
          , i_emv_data    => i_auth_rec.emv_data
          , o_format_data => l_add_chip_rec.icc_data
        );

    end if;

    put_general_message (
        i_add_fin_rec    => l_add_rec
    );

    if l_add_rec.addenda_type = amx_api_const_pkg.ADDENDA_TYPE_CHIP then

        put_chip_message (
            i_add_chip_rec  => l_add_chip_rec
        );
    end if;

    trc_log_pkg.debug(
        i_text => 'Create outgoing addenda end'
    );
end;

procedure enum_messages_for_upload (
    i_fin_id                in            com_api_type_pkg.t_long_id
  , o_amx_add_tab           in out nocopy amx_api_type_pkg.t_amx_add_tab
) is
begin
    select
        a.id
        , a.fin_id
        , a.file_id
        , a.is_incoming
        , a.mtid
        , a.addenda_type
        , a.format_code
        , a.message_seq_number
        , a.transaction_id
        , a.message_number
        , a.reject_reason_code
        , a.reject_id
     bulk collect into o_amx_add_tab
     from amx_add a
    where a.fin_id = i_fin_id
    order by message_seq_number
      for update;
end;

procedure process_addenda (
    i_amx_add_rec           in out nocopy amx_api_type_pkg.t_amx_add_rec
    , i_file_id             in            com_api_type_pkg.t_long_id
    , i_rec_number          in            com_api_type_pkg.t_long_id
    , i_session_file_id     in            com_api_type_pkg.t_long_id
)is
    l_line                   com_api_type_pkg.t_text;
    l_add_chip_rec           amx_api_type_pkg.t_amx_add_chip_rec;
begin
    trc_log_pkg.debug(
        i_text => 'process_addenda start'
    );
    i_amx_add_rec.message_number := i_rec_number;
    i_amx_add_rec.file_id        := i_file_id;

    if i_amx_add_rec.addenda_type = amx_api_const_pkg.ADDENDA_TYPE_INDUSTRY then

        l_line := l_line || i_amx_add_rec.mtid; --1
        l_line := l_line || i_amx_add_rec.addenda_type; --2
        l_line := l_line || rpad(' ', 194, ' ');--3
        l_line := l_line || rpad(' ', 45, ' ');--4
        l_line := l_line || rpad(' ', 45, ' ');--5
        l_line := l_line || rpad(' ', 45, ' ');--6
        l_line := l_line || rpad(' ', 45, ' ');--7
        l_line := l_line || rpad(' ', 45, ' ');--8
        l_line := l_line || ' '; --9
        l_line := l_line || rpad(' ', 496, ' ');--10
        l_line := l_line || i_amx_add_rec.format_code; --11
        l_line := l_line || rpad(' ', 13, ' ');--12
        l_line := l_line || lpad(nvl(i_amx_add_rec.message_seq_number, '0'), 3, '0'); --13
        l_line := l_line || rpad(' ', 65, ' ');--14
        l_line := l_line || lpad(nvl(i_amx_add_rec.transaction_id, '0'), 15, '0'); --15
        l_line := l_line || rpad(' ', 11, ' ');--16
        l_line := l_line || lpad(nvl(i_rec_number, '0'), 8, '0'); --17
        l_line := l_line || rpad(' ', 239, ' ');--18
        l_line := l_line || rpad(nvl(i_amx_add_rec.reject_reason_code, ' '), 40, ' '); --19
        l_line := l_line || rpad(' ', 82, ' ');--20

    elsif i_amx_add_rec.addenda_type = amx_api_const_pkg.ADDENDA_TYPE_CHIP then

        get_chip_addenda(
            i_fin_id          => i_amx_add_rec.id
          , o_add_chip_rec    => l_add_chip_rec
        );
        l_add_chip_rec.message_number := i_rec_number;
        l_add_chip_rec.file_id        := i_file_id;

        l_line := l_line || i_amx_add_rec.mtid; --1
        l_line := l_line || i_amx_add_rec.addenda_type; --2
        l_line := l_line || rpad(' ', 579, ' ');--3
        l_line := l_line || l_add_chip_rec.icc_data;--4
        l_line := l_line || rpad(' ', 96, ' ');--5
        l_line := l_line || lpad(nvl(l_add_chip_rec.message_seq_number, '0'), 3, '0'); --6
        l_line := l_line || rpad(' ', 65, ' ');--7
        l_line := l_line || lpad(nvl(l_add_chip_rec.transaction_id, '0'), 15, '0'); --8
        l_line := l_line || rpad(' ', 11, ' ');--9
        l_line := l_line || lpad(nvl(i_rec_number, '0'), 8, '0'); --10
        l_line := l_line || rpad(' ', 239, ' ');--11
        l_line := l_line || rpad(nvl(i_amx_add_rec.reject_reason_code, ' '), 40, ' '); --12
        l_line := l_line || rpad(' ', 82, ' ');--13

    end if;

    if l_line is not null then
        prc_api_file_pkg.put_line(
            i_raw_data      => l_line
          , i_sess_file_id  => i_session_file_id
        );
    end if;

    trc_log_pkg.debug(
        i_text => 'process_addenda end'
    );

end;

procedure get_chip_addenda(
    i_fin_id            in      com_api_type_pkg.t_long_id
  , o_add_chip_rec         out  amx_api_type_pkg.t_amx_add_chip_rec
) is
begin
    select id
         , fin_id
         , file_id
         , icc_data
         , icc_version_name
         , icc_version_number
         , emv_9f26
         , emv_9f10
         , emv_9f37
         , emv_9f36
         , emv_95
         , emv_9a
         , emv_9c
         , emv_9f02
         , emv_5f2a
         , emv_9f1a
         , emv_82
         , emv_9f03
         , emv_5f34
         , emv_9f27
         , message_seq_number
         , transaction_id
         , message_number
     into o_add_chip_rec
     from amx_add_chip c
    where c.fin_id = i_fin_id;
exception
    when no_data_found then
        trc_log_pkg.warn(
            i_text          => 'FINANCIAL_MESSAGE_NOT_FOUND'
          , i_env_param1    => i_fin_id
        );
    when too_many_rows then
        trc_log_pkg.warn(
            i_text          => 'TOO_MANY_RECORDS_FOUND'
          , i_env_param1    => i_fin_id
        );
    when others then
        raise;
end;

function get_offset(
    i_addenda_type        in com_api_type_pkg.t_byte_char
) return pls_integer
is
    l_offset                 pls_integer := 0;
begin
    l_offset := case i_addenda_type
                    when amx_api_const_pkg.ADDENDA_TYPE_CHIP then 252 --add l_offset after emv-data for correct parsing
                    else 0
                end;

    return l_offset;
end;

end;
/

