create or replace package body mcw_api_add_pkg is

    procedure enum_messages_for_upload (
        i_fin_id                in            com_api_type_pkg.t_long_id
      , o_add_tab               in out nocopy mcw_api_type_pkg.t_add_tab
    ) is
    begin
        select rowid
             , id
             , fin_id
             , file_id
             , is_incoming
             , mti
             , de024
             , de032
             , de033
             , de063
             , de071
             , de093
             , de094
             , de100
             , p0501_1
             , p0501_2
             , p0501_3
             , p0501_4
             , p0715
          bulk collect into
               o_add_tab
          from mcw_add
         where fin_id = i_fin_id
      order by p0501_3
             , id
           for update;

    end enum_messages_for_upload;

    function format_p0501(
        i_p0501_1               in mcw_api_type_pkg.t_p0501_1
      , i_p0501_2               in mcw_api_type_pkg.t_p0501_2
      , i_p0501_3               in mcw_api_type_pkg.t_p0501_3
      , i_p0501_4               in mcw_api_type_pkg.t_p0501_4
    ) return mcw_api_type_pkg.t_pds_body is
    begin
        if (
            i_p0501_1 is null or
            i_p0501_2 is null or
            i_p0501_3 is null or
            i_p0501_4 is null
        ) then
            return null;
        else
            return (
                mcw_utl_pkg.pad_number(i_p0501_1, 2, 2)
                || mcw_utl_pkg.pad_number(i_p0501_2, 3, 3)
                || mcw_utl_pkg.pad_number(i_p0501_3, 3, 3)
                || mcw_utl_pkg.pad_number(i_p0501_4, 8, 8)
            );
        end if;

    end format_p0501;

    procedure pack_message (
        i_add_rec               in mcw_api_type_pkg.t_add_rec
      , i_file_id               in com_api_type_pkg.t_short_id
      , i_de071                 in mcw_api_type_pkg.t_de071
      , i_fin_de071             in mcw_api_type_pkg.t_de071
      , o_raw_data              out varchar2
      , i_charset               in com_api_type_pkg.t_oracle_name := null
    ) is
        l_pds_tab                mcw_api_type_pkg.t_pds_tab;
    begin
        mcw_api_pds_pkg.read_pds (
            i_msg_id        => i_add_rec.id
            , o_pds_tab     => l_pds_tab
        );

        mcw_api_pds_pkg.set_pds_body (
            io_pds_tab       => l_pds_tab
            , i_pds_tag      => 501
            , i_pds_body     => format_p0501(
                                    i_p0501_1 => i_add_rec.p0501_1
                                  , i_p0501_2 => i_add_rec.p0501_2
                                  , i_p0501_3 => i_add_rec.p0501_3
                                  , i_p0501_4 => i_fin_de071
                                )
        );

        mcw_api_msg_pkg.pack_message (
            i_mti            => i_add_rec.mti
            , i_de024        => i_add_rec.de024
            , i_de032        => i_add_rec.de032
            , i_de033        => i_add_rec.de033
            , i_de063        => i_add_rec.de063
            , i_de071        => i_de071
            , i_de094        => i_add_rec.de094
            , i_pds_tab      => l_pds_tab
            , o_raw_data     => o_raw_data
            , i_charset      => i_charset
        );

    end pack_message;

    procedure mark_uploaded (
        i_rowid                 in com_api_type_pkg.t_rowid_tab
      , i_file_id               in com_api_type_pkg.t_number_tab
      , i_de071                 in com_api_type_pkg.t_number_tab
      , i_fin_de071             in com_api_type_pkg.t_number_tab
    ) is
    begin
        forall i in 1 .. i_rowid.count
            update mcw_add
               set de071   = i_de071(i)
                 , p0501_4 = i_fin_de071(i)
                 , file_id = i_file_id(i)
             where rowid   = i_rowid(i);

    end mark_uploaded;

    procedure put_message (
        i_add_rec               in mcw_api_type_pkg.t_add_rec
    ) is
    begin
        insert into mcw_add (
            id
          , fin_id
          , file_id
          , is_incoming
          , mti
          , de024
          , de071
          , de032
          , de033
          , de063
          , de093
          , de094
          , de100
          , p0501_1
          , p0501_2
          , p0501_3
          , p0501_4
          , p0715
        ) values (
            i_add_rec.id
          , i_add_rec.fin_id
          , i_add_rec.file_id
          , i_add_rec.is_incoming
          , i_add_rec.mti
          , i_add_rec.de024
          , i_add_rec.de071
          , i_add_rec.de032
          , i_add_rec.de033
          , i_add_rec.de063
          , i_add_rec.de093
          , i_add_rec.de094
          , i_add_rec.de100
          , i_add_rec.p0501_1
          , i_add_rec.p0501_2
          , i_add_rec.p0501_3
          , i_add_rec.p0501_4
          , i_add_rec.p0715
        );

    end put_message;

    procedure create_incoming_addendum (
        i_mes_rec     in    mcw_api_type_pkg.t_mes_rec
      , i_file_id     in    com_api_type_pkg.t_short_id
      , i_fin_id      in    com_api_type_pkg.t_long_id
      , i_network_id  in    com_api_type_pkg.t_tiny_id
    ) is
        l_add_rec           mcw_api_type_pkg.t_add_rec;
        l_pds_tab           mcw_api_type_pkg.t_pds_tab;
        l_pds_body          mcw_api_type_pkg.t_pds_body;

        l_stage                  varchar2(100);
    begin
        l_add_rec := null;
        -- init
        l_stage := 'init';

        l_add_rec.id := opr_api_create_pkg.get_id;
        l_add_rec.fin_id := i_fin_id;
        l_add_rec.file_id := i_file_id;
        l_add_rec.is_incoming := com_api_type_pkg.TRUE;

        l_stage := 'mti & de24 - de100';
        l_add_rec.mti := i_mes_rec.mti;
        l_add_rec.de024 := i_mes_rec.de024;
        l_add_rec.de032 := i_mes_rec.de032;
        l_add_rec.de033 := i_mes_rec.de033;
        l_add_rec.de063 := i_mes_rec.de063;
        l_add_rec.de071 := i_mes_rec.de071;
        l_add_rec.de093 := i_mes_rec.de093;
        l_add_rec.de094 := i_mes_rec.de094;
        l_add_rec.de100 := i_mes_rec.de100;

        l_stage := 'extract_pds';
        mcw_api_pds_pkg.extract_pds (
            de048        => i_mes_rec.de048
            , de062      => i_mes_rec.de062
            , de123      => i_mes_rec.de123
            , de124      => i_mes_rec.de124
            , de125      => i_mes_rec.de125
            , pds_tab    => l_pds_tab
        );

        l_stage := 'get_pds_body';
        l_pds_body := mcw_api_pds_pkg.get_pds_body (
            i_pds_tab          => l_pds_tab
            , i_pds_tag        => mcw_api_const_pkg.PDS_TAG_0501
        );
        l_stage := 'parse_p0501';
        mcw_api_pds_pkg.parse_p0501 (
            i_p0501          => l_pds_body
            , o_p0501_1      => l_add_rec.p0501_1
            , o_p0501_2      => l_add_rec.p0501_2
            , o_p0501_3      => l_add_rec.p0501_3
            , o_p0501_4      => l_add_rec.p0501_4
        );

        l_stage := 'get_pds_body';
        l_pds_body := mcw_api_pds_pkg.get_pds_body (
            i_pds_tab          => l_pds_tab
            , i_pds_tag        => mcw_api_const_pkg.PDS_TAG_0715
        );
        l_stage := 'parse_p0715';
        mcw_api_pds_pkg.parse_p0715(
            i_p0715    => l_pds_body
          , o_p0715    => l_add_rec.p0715
        );

        l_stage := 'put_message';
        put_message (
            i_add_rec    => l_add_rec
        );

        l_stage := 'save_pds';
        mcw_api_pds_pkg.save_pds (
            i_msg_id     => l_add_rec.id
            , i_pds_tab  => l_pds_tab
        );

    exception
        when others then
            trc_log_pkg.debug(
                i_text => 'Error generating IPM addendum on stage ' || l_stage || ': ' || sqlerrm
            );
            raise;

    end create_incoming_addendum;

    procedure create_outgoing_addendum (
        i_fin_rec                in mcw_api_type_pkg.t_fin_rec
    ) is
        l_add_rec                mcw_api_type_pkg.t_add_rec;
        l_pds_tab                mcw_api_type_pkg.t_pds_tab;
        l_sender                 com_api_type_pkg.t_full_desc;
        l_payer                  com_api_type_pkg.t_full_desc;
        l_name                   com_api_type_pkg.t_full_desc;
        l_stage                  varchar2(100);
    begin
        l_add_rec := null;

        l_stage := 'init';
        -- init
        l_add_rec.id := opr_api_create_pkg.get_id;
        l_add_rec.fin_id := i_fin_rec.id;
        l_add_rec.file_id := null;
        l_add_rec.is_incoming := i_fin_rec.is_incoming;

        l_stage := 'mti & de24 - de100';
        l_add_rec.mti := mcw_api_const_pkg.MSG_TYPE_ADMINISTRATIVE;
        l_add_rec.de024 := mcw_api_const_pkg.FUNC_CODE_ADDENDUM;
        l_add_rec.de032 := i_fin_rec.de032;
        l_add_rec.de033 := i_fin_rec.de033;
        l_add_rec.de063 := i_fin_rec.de063;
        l_add_rec.de071 := null;
        l_add_rec.de093 := i_fin_rec.de093;
        l_add_rec.de094 := i_fin_rec.de094;
        l_add_rec.de100 := i_fin_rec.de100;

        l_stage := 'p0501';
        l_add_rec.p0501_1 := '10';
        l_add_rec.p0501_2 := '000';
        l_add_rec.p0501_3 := '001';
        l_add_rec.p0501_4 := 0;

        l_stage := 'put_message';
        put_message (
            i_add_rec    => l_add_rec
        );

        l_stage := 'set_pds';
        mcw_api_pds_pkg.set_pds_body (
            io_pds_tab   => l_pds_tab
            , i_pds_tag  => mcw_api_const_pkg.PDS_TAG_0501
            , i_pds_body => format_p0501(l_add_rec.p0501_1, l_add_rec.p0501_2, l_add_rec.p0501_3, l_add_rec.p0501_4)
        );
        
        if i_fin_rec.de003_1 = mcw_api_const_pkg.PROC_CODE_PAYMENT then
            -- Next PDS's should be present on appropriate conditions 
            if i_fin_rec.p0043 in ('C06', 'C07', 'C52', 'C53', 'C54', 'C55', 'C56') then
                l_sender := rpad(nvl(substr(trim(aup_api_tag_pkg.get_tag_value(
                                                     i_auth_id => i_fin_rec.id
                                                   , i_tag_id  => aup_api_const_pkg.TAG_CUSTOMER_NAME
                                                 )
                                            ), 1, 25), 'UNKNOWN'), 25);
                l_sender := l_sender
                         || rpad(nvl(substr(trim(aup_api_tag_pkg.get_tag_value(
                                                     i_auth_id => i_fin_rec.id
                                                   , i_tag_id  => aup_api_const_pkg.TAG_SENDER_STREET
                                                 )
                                            ), 1, 30), 'UNKNOWN'), 30);
                l_sender := l_sender
                         || rpad(nvl(substr(trim(aup_api_tag_pkg.get_tag_value(
                                                     i_auth_id => i_fin_rec.id
                                                   , i_tag_id  => aup_api_const_pkg.TAG_SENDER_CITY
                                                 )
                                            ), 1, 25), 'UNKNOWN'), 25);
                l_sender := l_sender
                         || rpad(nvl(substr(trim(aup_api_tag_pkg.get_tag_value(
                                                     i_auth_id => i_fin_rec.id
                                                   , i_tag_id  => aup_api_const_pkg.TAG_STATE_PROVINCE_CODE
                                                 )
                                            ), 1, 3), ' '), 3);
                l_sender := l_sender
                         || rpad(nvl(substr(trim(aup_api_tag_pkg.get_tag_value(
                                                     i_auth_id => i_fin_rec.id
                                                   , i_tag_id  => aup_api_const_pkg.TAG_SENDER_COUNTRY
                                                 )
                                            ), 1, 3), ' '), 3);
                l_sender := l_sender
                         || rpad(nvl(substr(trim(aup_api_tag_pkg.get_tag_value(
                                                 i_auth_id => i_fin_rec.id
                                               , i_tag_id  => aup_api_const_pkg.TAG_SENDER_POSTCODE
                                             )
                                            ), 1, 10), 'UNKNOWN'), 10);
                l_sender := l_sender || rpad(' ', 8);

                mcw_api_pds_pkg.set_pds_body (
                    io_pds_tab   => l_pds_tab
                    , i_pds_tag  => 0670
                    , i_pds_body => substr(l_sender, 1, 104)
                );
                
                l_name := initcap(
                              trim(
                                  aup_api_tag_pkg.get_tag_value(
                                      i_auth_id => i_fin_rec.id
                                    , i_tag_id  => aup_api_const_pkg.TAG_PERSON_NAME
                                  )
                              )
                          );

                -- Payer First Name
                l_payer := mcw_utl_pkg.pad_char(nvl(trim(substr(l_name, instr(l_name, ',') + 1)), 'UNKNOWN'), 35, 35);
                -- Payer Last Name
                l_payer := l_payer
                        || mcw_utl_pkg.pad_char(nvl(trim(substr(l_name, 1, instr(l_name, ',') - 1)), 'UNKNOWN'), 35, 35);
                -- Payer Address
                l_payer := l_payer
                        || mcw_utl_pkg.pad_char(nvl(trim(aup_api_tag_pkg.get_tag_value(
                                                             i_auth_id => i_fin_rec.id
                                                           , i_tag_id  => 8742
                                                         )), ' '), 30, 30);
                -- Payer City
                l_payer := l_payer
                        || mcw_utl_pkg.pad_char(nvl(trim(aup_api_tag_pkg.get_tag_value(
                                                             i_auth_id => i_fin_rec.id
                                                           , i_tag_id  => 8737
                                                         )), ' '), 25, 25);
                -- Payer State/Province Code
                l_payer := l_payer
                        || mcw_utl_pkg.pad_char(nvl(trim(aup_api_tag_pkg.get_tag_value(
                                                             i_auth_id => i_fin_rec.id
                                                           , i_tag_id  => 8737
                                                         )), ' '), 3, 3);
                -- Payer Country Code
                l_payer := l_payer
                        || mcw_utl_pkg.pad_char(nvl(trim(aup_api_tag_pkg.get_tag_value(
                                                             i_auth_id => i_fin_rec.id
                                                           , i_tag_id  => 8738
                                                         )), ' '), 3, 3);
                -- Payer Postal Code
                l_payer := l_payer
                        || mcw_utl_pkg.pad_char(nvl(trim(aup_api_tag_pkg.get_tag_value(
                                                             i_auth_id => i_fin_rec.id
                                                           , i_tag_id  => 8739
                                                         )), ' '), 10, 10);
                -- Payer Date of Birth
                l_payer := l_payer
                    || mcw_utl_pkg.pad_char(nvl(substr(trim(aup_api_tag_pkg.get_tag_value(
                                                                i_auth_id => i_fin_rec.id
                                                              , i_tag_id  => 8740
                                                            )
                                                       ), 1, 8), ' '), 8, 8);
                -- Payer Phone Number
                l_payer := l_payer
                        || mcw_utl_pkg.pad_char(nvl(trim(aup_api_tag_pkg.get_tag_value(
                                                             i_auth_id => i_fin_rec.id
                                                           , i_tag_id  => 8741
                                                         )), ' '), 20, 20);

                mcw_api_pds_pkg.set_pds_body (
                    io_pds_tab   => l_pds_tab
                    , i_pds_tag  => 0765
                    , i_pds_body => substr(l_payer, 1, 169)
                );
            end if;

            if i_fin_rec.p0043 in ('C07', 'C52', 'C53', 'C54', 'C55', 'C56') then
                mcw_api_pds_pkg.set_pds_body (
                    io_pds_tab   => l_pds_tab
                    , i_pds_tag  => 0671
                    , i_pds_body => to_number(to_char(i_fin_rec.de012, 'YYMMDD'))
                );
                mcw_api_pds_pkg.set_pds_body (
                    io_pds_tab   => l_pds_tab
                    , i_pds_tag  => 0674
                    , i_pds_body => to_char(i_fin_rec.id)
                );
            end if;
        end if;

        l_stage := 'save_pds';
        mcw_api_pds_pkg.save_pds (
            i_msg_id     => l_add_rec.id
            , i_pds_tab  => l_pds_tab
        );

    exception
        when others then
            trc_log_pkg.debug(
                i_text  => 'Error generating IPM addendum on stage ' || l_stage || ': ' || sqlerrm
            );
            raise;
    end create_outgoing_addendum;

end mcw_api_add_pkg;
/
