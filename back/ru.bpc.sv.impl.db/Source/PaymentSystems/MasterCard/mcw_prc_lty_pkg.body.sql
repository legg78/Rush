create or replace package body mcw_prc_lty_pkg is
/*********************************************************
*  API for MasterCard World Reward Program <br />
*  Created by Gerbeev I.(gerbeev@bpc.ru) at 31.10.2018 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate:: $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: MCW_PRC_LTY_PKG <br />
*  @headcom
**********************************************************/

    BULK_LIMIT                          constant com_api_type_pkg.t_count       := 1000;
    SPACE                               constant com_api_type_pkg.t_byte_char   := ' ';
    PROCEDURE_NAME_EXPORT               constant com_api_type_pkg.t_short_desc  := 'MCW_PRC_LTY_PKG.EXPORT';
    RECORD_TYPE_HEADER                  constant com_api_type_pkg.t_byte_char   := '10';
    RECORD_TYPE_CUSTOMER                constant com_api_type_pkg.t_byte_char   := '15';
    RECORD_TYPE_CUSTOMER_ACCOUNT        constant com_api_type_pkg.t_byte_char   := '20';
    RECORD_TYPE_LOST_STOLEN             constant com_api_type_pkg.t_byte_char   := '40';
    RECORD_TYPE_TRAILER                 constant com_api_type_pkg.t_byte_char   := '90';
    ACTION_CODE_UPD_BANK_ACC_NUM        constant com_api_type_pkg.t_byte_char   := 'A';

    INTERFACE_LANGUAGE_LOV_ID           constant com_api_type_pkg.t_tiny_id     := 5;
    LANGUAGE_LOCALE_ARRAY_TYPE          constant com_api_type_pkg.t_tiny_id     := 1078;
    LANGUAGE_LOCALE_ARRAY_ID            constant com_api_type_pkg.t_short_id    := 10000109;

    CARD_STATUS_GOOD_STANDING           constant com_api_type_pkg.t_dict_value  := '001';

    type t_object_rec is record(
        object_id       com_api_type_pkg.t_long_id
      , entity_type     com_api_type_pkg.t_dict_value
      , event_type      com_api_type_pkg.t_param_tab
    );

    type t_object_tab is table of t_object_rec index by com_api_type_pkg.t_name;

    type t_file_rec is record(
        record_date                 com_api_type_pkg.t_name
      , record_time                 com_api_type_pkg.t_name
      , file_name                   com_api_type_pkg.t_name
      , member_ica                  com_api_type_pkg.t_name
      , language_code               com_api_type_pkg.t_name
      , cardholder_number           com_api_type_pkg.t_name
      , cardholder_title            com_api_type_pkg.t_name
      , cardholder_first_name       com_api_type_pkg.t_name
      , cardholder_second_name      com_api_type_pkg.t_name
      , cardholder_surname          com_api_type_pkg.t_name
      , cardholder_suffix           com_api_type_pkg.t_name
      , cardholder_birthday         com_api_type_pkg.t_name
      , cardholder_gender           com_api_type_pkg.t_name
      , cardholder_phone            com_api_type_pkg.t_name
      , cardholder_email            com_api_type_pkg.t_name
      , cardholder_mobile           com_api_type_pkg.t_name
      , cardholder_address_line1    com_api_type_pkg.t_name
      , cardholder_address_line2    com_api_type_pkg.t_name
      , cardholder_address_line3    com_api_type_pkg.t_name
      , cardholder_city             com_api_type_pkg.t_name
      , cardholder_province_code    com_api_type_pkg.t_name
      , cardholder_postal_code      com_api_type_pkg.t_name
      , cardholder_country_code     com_api_type_pkg.t_name
      , accrue_points_sw            com_api_type_pkg.t_name
      , card_number                 com_api_type_pkg.t_name
      , bank_product_code           com_api_type_pkg.t_name
      , program_identifier          com_api_type_pkg.t_name
      , card_status                 com_api_type_pkg.t_name
      , enrollment_date             com_api_type_pkg.t_name
      , account_opened_date         com_api_type_pkg.t_name
      , new_card_number             com_api_type_pkg.t_name
      , action_code                 com_api_type_pkg.t_name
      , new_card_status             com_api_type_pkg.t_name
      , record_count                com_api_type_pkg.t_name
    );

    type t_card_instance_rec is record(
        card_instance_id        com_api_type_pkg.t_medium_id
      , person_id               com_api_type_pkg.t_medium_id
      , cardholder_number       com_api_type_pkg.t_name
      , cardholder_id           com_api_type_pkg.t_medium_id
      , customer_id             com_api_type_pkg.t_medium_id
      , account_opened_date     date
      , prec_card_instance_id   com_api_type_pkg.t_medium_id
      , card_id                 com_api_type_pkg.t_medium_id
      , card_status             com_api_type_pkg.t_dict_value
      , prec_card_id            com_api_type_pkg.t_medium_id
      , prec_card_status        com_api_type_pkg.t_dict_value
    );

    type t_card_instance_tab is table of t_card_instance_rec index by binary_integer;

function get_cst_date(
    i_date          in  date default null
) return date
is
begin
    return cast(nvl(i_date, com_api_sttl_day_pkg.get_sysdate) as timestamp) at time zone 'CST';
end get_cst_date;

procedure save_file(
    i_event_object_id_tab   in      com_api_type_pkg.t_number_tab
  , i_raw_tab               in      com_api_type_pkg.t_raw_tab
  , i_num_tab               in      com_api_type_pkg.t_integer_tab
  , i_file_name             in      com_api_type_pkg.t_full_desc
  , i_processed_count       in      com_api_type_pkg.t_long_id := 0
  , io_params               in out  com_api_type_pkg.t_param_tab
) is
    l_session_file_id       com_api_type_pkg.t_long_id;
begin
    prc_api_file_pkg.open_file(
        o_sess_file_id  => l_session_file_id
      , i_file_name     => i_file_name
      , i_file_purpose  => prc_api_const_pkg.FILE_PURPOSE_OUT
      , io_params       => io_params
    );

    prc_api_file_pkg.put_bulk(
        i_sess_file_id  => l_session_file_id
        , i_raw_tab     => i_raw_tab
        , i_num_tab     => i_num_tab
    );

    prc_api_file_pkg.close_file(
        i_sess_file_id  => l_session_file_id
      , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
      , i_record_count  => i_processed_count
    );

    evt_api_event_pkg.process_event_object(
        i_event_object_id_tab => i_event_object_id_tab
    );

    prc_api_stat_pkg.log_end(
        i_processed_total  => i_processed_count
      , i_excepted_total   => 0
      , i_rejected_total   => 0
      , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

end save_file;

procedure put_value(
    io_raw_line     in out  com_api_type_pkg.t_raw_data
  , i_value         in      com_api_type_pkg.t_full_desc
  , i_begin         in      com_api_type_pkg.t_tiny_id
  , i_end           in      com_api_type_pkg.t_tiny_id
  , i_length        in      com_api_type_pkg.t_tiny_id
  , i_field_name    in      com_api_type_pkg.t_name     := null
  , i_right_pad     in      com_api_type_pkg.t_boolean  := com_api_const_pkg.TRUE
) is
    l_value                 com_api_type_pkg.t_full_desc;
begin
    if i_right_pad = com_api_const_pkg.TRUE then
        l_value := rpad(nvl(i_value, SPACE), i_length, SPACE);
    else
        l_value := lpad(nvl(i_value, SPACE), i_length, SPACE);
    end if;

    if length(i_value) > i_length then
        com_api_error_pkg.raise_error(
            i_error             => 'VALUE_EXCEEDED_ALLOWED_MAXIMUM'
          , i_env_param1        => length(i_value)
          , i_env_param2        => i_length
          , i_env_param3        => i_field_name
        );
    end if;

    io_raw_line := substr(io_raw_line, 1, i_begin) || l_value || substr(io_raw_line, i_end);
end put_value;

procedure format_header_10(
    i_file_rec      in      t_file_rec
  , io_raw_tab      in out  com_api_type_pkg.t_raw_tab
  , io_num_tab      in out  com_api_type_pkg.t_integer_tab
) is
    l_raw_line     com_api_type_pkg.t_raw_data;
begin
    put_value(
        io_raw_line     => l_raw_line
      , i_value         => RECORD_TYPE_HEADER
      , i_begin         => 1
      , i_end           => 2
      , i_length        => 2
      , i_field_name    => '10-1 Record Type'
    );
    put_value(
        io_raw_line     => l_raw_line
      , i_value         => i_file_rec.record_date
      , i_begin         => 3
      , i_end           => 10
      , i_length        => 8
      , i_field_name    => '10-2 Record Date'
    );
    put_value(
        io_raw_line     => l_raw_line
      , i_value         => i_file_rec.record_time
      , i_begin         => 11
      , i_end           => 16
      , i_length        => 6
      , i_field_name    => '10-3 Record Time'
    );
    put_value(
        io_raw_line     => l_raw_line
      , i_value         => i_file_rec.member_ica
      , i_begin         => 17
      , i_end           => 22
      , i_length        => 6
      , i_field_name    => '10-4 Member ICA'
    );
    put_value(
        io_raw_line     => l_raw_line
      , i_value         => i_file_rec.file_name
      , i_begin         => 23
      , i_end           => 52
      , i_length        => 30
      , i_field_name    => '10-5 File Name'
    );
    put_value(
        io_raw_line     => l_raw_line
      , i_value         => null
      , i_begin         => 53
      , i_end           => 82
      , i_length        => 30
      , i_field_name    => '10-6 Original File Name'
    );
    put_value(
        io_raw_line     => l_raw_line
      , i_value         => null
      , i_begin         => 83
      , i_end           => 96
      , i_length        => 14
      , i_field_name    => '10-7 Original Date'
      , i_right_pad     => com_api_const_pkg.FALSE
    );
    put_value(
        io_raw_line     => l_raw_line
      , i_value         => null
      , i_begin         => 97
      , i_end           => 146
      , i_length        => 50
      , i_field_name    => '10-8 MRS Reserved'
    );
    put_value(
        io_raw_line     => l_raw_line
      , i_value         => null
      , i_begin         => 147
      , i_end           => 850
      , i_length        => 704
      , i_field_name    => '10-9 Filler'
    );

    io_raw_tab(io_raw_tab.count + 1) := l_raw_line;
    io_num_tab(io_num_tab.count + 1) := io_num_tab.count + 1;

end format_header_10;

procedure format_customer_15(
    i_file_rec      in      t_file_rec
  , io_raw_tab      in out  com_api_type_pkg.t_raw_tab
  , io_num_tab      in out  com_api_type_pkg.t_integer_tab
) is
    l_raw_line     com_api_type_pkg.t_raw_data;
begin
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => RECORD_TYPE_CUSTOMER
      , i_begin      => 1
      , i_end        => 2
      , i_length     => 2
      , i_field_name => '15-1 Record Type'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => i_file_rec.record_date
      , i_begin      => 3
      , i_end        => 10
      , i_length     => 8
      , i_field_name => '15-2 Record Date'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => i_file_rec.member_ica
      , i_begin      => 11
      , i_end        => 16
      , i_length     => 6
      , i_field_name => '15-3 Member ICA'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => i_file_rec.cardholder_number
      , i_begin      => 17
      , i_end        => 46
      , i_length     => 30
      , i_field_name => '15-4 Bank Customer Number'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => i_file_rec.cardholder_title
      , i_begin      => 47
      , i_end        => 50
      , i_length     => 4
      , i_field_name => '15-5 Primary Account Holder Prefix'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => i_file_rec.cardholder_first_name
      , i_begin      => 51
      , i_end        => 75
      , i_length     => 25
      , i_field_name => '15-6 Primary Account Holder First Name'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => i_file_rec.cardholder_second_name
      , i_begin      => 76
      , i_end        => 100
      , i_length     => 25
      , i_field_name => '15-7 Primary Account Holder Middle Name'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => i_file_rec.cardholder_surname
      , i_begin      => 101
      , i_end        => 125
      , i_length     => 25
      , i_field_name => '15-8 Primary Account Holder Last Name'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => i_file_rec.cardholder_suffix
      , i_begin      => 126
      , i_end        => 129
      , i_length     => 4
      , i_field_name => '15-9 Primary Account Holder Suffix'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => null
      , i_begin      => 130
      , i_end        => 144
      , i_length     => 15
      , i_field_name => '15-10 Generic Identification Field'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => null
      , i_begin      => 145
      , i_end        => 169
      , i_length     => 25
      , i_field_name => '15-11 Generic Identification Field Description'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => null
      , i_begin      => 170
      , i_end        => 180
      , i_length     => 11
      , i_field_name => '15-12 Primary Account Holder SSN'
      , i_right_pad     => com_api_const_pkg.FALSE
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => null
      , i_begin      => 181
      , i_end        => 210
      , i_length     => 30
      , i_field_name => '15-13 Primary Account Holder Mothers Maiden Name'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => i_file_rec.cardholder_birthday
      , i_begin      => 211
      , i_end        => 218
      , i_length     => 8
      , i_field_name => '15-14 Primary Account Holder Birth Date'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => i_file_rec.cardholder_address_line1
      , i_begin      => 219
      , i_end        => 298
      , i_length     => 80
      , i_field_name => '15-15 Account Holder Address Line1'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => i_file_rec.cardholder_address_line2
      , i_begin      => 299
      , i_end        => 378
      , i_length     => 80
      , i_field_name => '15-16 Account Holder Address Line2'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => i_file_rec.cardholder_address_line3
      , i_begin      => 379
      , i_end        => 458
      , i_length     => 80
      , i_field_name => '15-17 Account Holder Address Line3'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => i_file_rec.cardholder_city
      , i_begin      => 459
      , i_end        => 488
      , i_length     => 30
      , i_field_name => '15-18 City Name'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => i_file_rec.cardholder_province_code
      , i_begin      => 489
      , i_end        => 490
      , i_length     => 2
      , i_field_name => '15-19 State Province Code'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => i_file_rec.cardholder_postal_code
      , i_begin      => 491
      , i_end        => 504
      , i_length     => 14
      , i_field_name => '15-20 Postal Code'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => i_file_rec.cardholder_country_code
      , i_begin      => 505
      , i_end        => 507
      , i_length     => 3
      , i_field_name => '15-21 Country Code'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => i_file_rec.cardholder_phone
      , i_begin      => 508
      , i_end        => 532
      , i_length     => 25
      , i_field_name => '15-22 Home Phone Number'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => null
      , i_begin      => 533
      , i_end        => 557
      , i_length     => 25
      , i_field_name => '15-23 Business Phone Number'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => null
      , i_begin      => 558
      , i_end        => 582
      , i_length     => 25
      , i_field_name => '15-24 Fax Phone Number'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => null
      , i_begin      => 583
      , i_end        => 583
      , i_length     => 1
      , i_field_name => '15-25 VIP Indicator'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => i_file_rec.language_code
      , i_begin      => 584
      , i_end        => 588
      , i_length     => 5
      , i_field_name => '15-26 Language Code'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => null
      , i_begin      => 589
      , i_end        => 628
      , i_length     => 40
      , i_field_name => '15-27 Customer User Defined Field 1'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => null
      , i_begin      => 629
      , i_end        => 668
      , i_length     => 40
      , i_field_name => '15-28 Customer User Defined Field 2'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => i_file_rec.cardholder_email
      , i_begin      => 669
      , i_end        => 788
      , i_length     => 120
      , i_field_name => '15-29 Email Address'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => null
      , i_begin      => 789
      , i_end        => 789
      , i_length     => 1
      , i_field_name => '15-30 Employee Sw'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => null
      , i_begin      => 790
      , i_end        => 790
      , i_length     => 1
      , i_field_name => '15-31 Accept Email Message Switch'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => null
      , i_begin      => 791
      , i_end        => 791
      , i_length     => 1
      , i_field_name => '15-32 Accept SMS Message Switch'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => i_file_rec.cardholder_mobile
      , i_begin      => 792
      , i_end        => 816
      , i_length     => 25
      , i_field_name => '15-33 Mobile Phone Number'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => null
      , i_begin      => 817
      , i_end        => 817
      , i_length     => 1
      , i_field_name => '15-34 Accept Promo Switch'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => i_file_rec.cardholder_gender
      , i_begin      => 818
      , i_end        => 820
      , i_length     => 3
      , i_field_name => '15-35 Gender'
      , i_right_pad     => com_api_const_pkg.FALSE
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => null
      , i_begin      => 821
      , i_end        => 850
      , i_length     => 30
      , i_field_name => '15-36 Filler'
    );

    io_raw_tab(io_raw_tab.count + 1) := l_raw_line;
    io_num_tab(io_num_tab.count + 1) := io_num_tab.count + 1;

end format_customer_15;

procedure format_customer_account_20(
    i_file_rec      in      t_file_rec
  , io_raw_tab      in out  com_api_type_pkg.t_raw_tab
  , io_num_tab      in out  com_api_type_pkg.t_integer_tab
) is
    l_raw_line     com_api_type_pkg.t_raw_data;
begin
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => RECORD_TYPE_CUSTOMER_ACCOUNT
      , i_begin      => 1
      , i_end        => 2
      , i_length     => 2
      , i_field_name => '20-1 Record Type'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => i_file_rec.record_date
      , i_begin      => 3
      , i_end        => 10
      , i_length     => 8
      , i_field_name => '20-2 Record Date'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => i_file_rec.member_ica
      , i_begin      => 11
      , i_end        => 16
      , i_length     => 6
      , i_field_name => '20-3 Member ICA'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => i_file_rec.cardholder_number
      , i_begin      => 17
      , i_end        => 46
      , i_length     => 30
      , i_field_name => '20-4 Bank Customer Number'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => i_file_rec.card_number
      , i_begin      => 47
      , i_end        => 76
      , i_length     => 30
      , i_field_name => '20-5 Bank Account Number'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => i_file_rec.bank_product_code
      , i_begin      => 77
      , i_end        => 96
      , i_length     => 20
      , i_field_name => '20-6 Bank Product Code'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => null
      , i_begin      => 97
      , i_end        => 100
      , i_length     => 4
      , i_field_name => '20-7 Secondary Account Holder Prefix'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => null
      , i_begin      => 101
      , i_end        => 125
      , i_length     => 25
      , i_field_name => '20-8 Secondary Account Holder First Name'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => null
      , i_begin      => 126
      , i_end        => 148
      , i_length     => 23
      , i_field_name => '20-9 Secondary Account Holder Middle Name'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => null
      , i_begin      => 149
      , i_end        => 173
      , i_length     => 25
      , i_field_name => '20-10 Secondary Account Holder Last Name'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => null
      , i_begin      => 174
      , i_end        => 177
      , i_length     => 4
      , i_field_name => '20-11 Secondary Account Holder Suffix'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => i_file_rec.card_status
      , i_begin      => 178
      , i_end        => 180
      , i_length     => 3
      , i_field_name => '20-12 Account Status Code'
      , i_right_pad     => com_api_const_pkg.FALSE
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => null
      , i_begin      => 181
      , i_end        => 220
      , i_length     => 40
      , i_field_name => '20-13 Account User Defined Field 1'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => null
      , i_begin      => 221
      , i_end        => 260
      , i_length     => 40
      , i_field_name => '20-14 Account User Defined Field 2'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => null
      , i_begin      => 261
      , i_end        => 300
      , i_length     => 40
      , i_field_name => '20-15 Account User Defined Field 3'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => null
      , i_begin      => 301
      , i_end        => 340
      , i_length     => 40
      , i_field_name => '20-16 Account User Defined Field 4'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => null
      , i_begin      => 341
      , i_end        => 480
      , i_length     => 140
      , i_field_name => '20-17 Household Eligibility Token'
      , i_right_pad  => com_api_const_pkg.FALSE
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => i_file_rec.enrollment_date
      , i_begin      => 481
      , i_end        => 488
      , i_length     => 8
      , i_field_name => '20-18 Enrollment Date'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => null
      , i_begin      => 489
      , i_end        => 507
      , i_length     => 19
      , i_field_name => '20-19 DDA Account Number'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => i_file_rec.accrue_points_sw
      , i_begin      => 508
      , i_end        => 508
      , i_length     => 1
      , i_field_name => '20-20 Accrue Points Sw'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => null
      , i_begin      => 509
      , i_end        => 528
      , i_length     => 20
      , i_field_name => '20-21 Reporting Category'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => null
      , i_begin      => 529
      , i_end        => 539
      , i_length     => 11
      , i_field_name => '20-22 Secondary Account Holder SSN'
      , i_right_pad     => com_api_const_pkg.FALSE
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => null
      , i_begin      => 540
      , i_end        => 540
      , i_length     => 1
      , i_field_name => '20-23 Receive Statements'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => i_file_rec.program_identifier
      , i_begin      => 541
      , i_end        => 558
      , i_length     => 18
      , i_field_name => '20-24 Program Identifier'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => null
      , i_begin      => 559
      , i_end        => 577
      , i_length     => 19
      , i_field_name => '20-25 Ghost Account Number'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => null
      , i_begin      => 578
      , i_end        => 597
      , i_length     => 20
      , i_field_name => '20-26 Account User Defined Field 5'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => null
      , i_begin      => 598
      , i_end        => 617
      , i_length     => 20
      , i_field_name => '20-27 Account User Defined Field 6'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => null
      , i_begin      => 618
      , i_end        => 637
      , i_length     => 20
      , i_field_name => '20-28 Account User Defined Field 7'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => null
      , i_begin      => 638
      , i_end        => 657
      , i_length     => 20
      , i_field_name => '20-29 Account User Defined Field 8'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => null
      , i_begin      => 658
      , i_end        => 697
      , i_length     => 40
      , i_field_name => '20-30 Partner ID'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => null
      , i_begin      => 698
      , i_end        => 698
      , i_length     => 1
      , i_field_name => '20-31 Primary Account Sw'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => i_file_rec.account_opened_date
      , i_begin      => 699
      , i_end        => 706
      , i_length     => 8
      , i_field_name => '20-32 Account Opened Date'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => null
      , i_begin      => 707
      , i_end        => 850
      , i_length     => 144
      , i_field_name => '20-33 Filler'
    );

    io_raw_tab(io_raw_tab.count + 1) := l_raw_line;
    io_num_tab(io_num_tab.count + 1) := io_num_tab.count + 1;

end format_customer_account_20;

procedure format_lost_stolen_40(
    i_file_rec      in      t_file_rec
  , io_raw_tab      in out  com_api_type_pkg.t_raw_tab
  , io_num_tab      in out  com_api_type_pkg.t_integer_tab
) is
    l_raw_line     com_api_type_pkg.t_raw_data;
begin
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => RECORD_TYPE_LOST_STOLEN
      , i_begin      => 1
      , i_end        => 2
      , i_length     => 2
      , i_field_name => '40-1 Record Type'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => i_file_rec.record_date
      , i_begin      => 3
      , i_end        => 10
      , i_length     => 8
      , i_field_name => '40-2 Record Date'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => i_file_rec.member_ica
      , i_begin      => 11
      , i_end        => 16
      , i_length     => 6
      , i_field_name => '40-3 Member ICA'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => i_file_rec.cardholder_number
      , i_begin      => 17
      , i_end        => 46
      , i_length     => 30
      , i_field_name => '40-4 Bank Customer Number'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => i_file_rec.card_number
      , i_begin      => 47
      , i_end        => 76
      , i_length     => 30
      , i_field_name => '40-5 Bank Account Number'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => i_file_rec.bank_product_code
      , i_begin      => 77
      , i_end        => 96
      , i_length     => 20
      , i_field_name => '40-6 Bank Product Code'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => i_file_rec.new_card_number
      , i_begin      => 97
      , i_end        => 126
      , i_length     => 30
      , i_field_name => '40-7 New Number'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => i_file_rec.action_code
      , i_begin      => 127
      , i_end        => 127
      , i_length     => 1
      , i_field_name => '40-8 Action Code'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => i_file_rec.new_card_status
      , i_begin      => 128
      , i_end        => 130
      , i_length     => 3
      , i_field_name => '40-9 Account Status Code'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => null
      , i_begin      => 131
      , i_end        => 180
      , i_length     => 50
      , i_field_name => '40-10 MRS Reserved'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => null
      , i_begin      => 181
      , i_end        => 850
      , i_length     => 670
      , i_field_name => '40-11 Filler'
    );

    io_raw_tab(io_raw_tab.count + 1) := l_raw_line;
    io_num_tab(io_num_tab.count + 1) := io_num_tab.count + 1;

end format_lost_stolen_40;

procedure format_trailer_90(
    i_file_rec      in      t_file_rec
  , io_raw_tab      in out  com_api_type_pkg.t_raw_tab
  , io_num_tab      in out  com_api_type_pkg.t_integer_tab
) is
    l_raw_line      com_api_type_pkg.t_raw_data;
begin
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => RECORD_TYPE_TRAILER
      , i_begin      => 1
      , i_end        => 2
      , i_length     => 2
      , i_field_name => '90-1 Record Type'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => i_file_rec.record_date
      , i_begin      => 3
      , i_end        => 10
      , i_length     => 8
      , i_field_name => '90-2 Record Date'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => i_file_rec.record_time
      , i_begin      => 11
      , i_end        => 16
      , i_length     => 6
      , i_field_name => '90-3 Record Time'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => i_file_rec.member_ica
      , i_begin      => 17
      , i_end        => 22
      , i_length     => 6
      , i_field_name => '90-4 Member ICA'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => i_file_rec.file_name
      , i_begin      => 23
      , i_end        => 52
      , i_length     => 30
      , i_field_name => '90-5 File Name'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => lpad(to_char(io_num_tab.count + 1), 9, '0')
      , i_begin      => 53
      , i_end        => 61
      , i_length     => 9
      , i_field_name => '90-6 Record Count'
      , i_right_pad     => com_api_const_pkg.FALSE
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => null
      , i_begin      => 62
      , i_end        => 69
      , i_length     => 8
      , i_field_name => '90-7 Adjustment Record Count'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => null
      , i_begin      => 70
      , i_end        => 84
      , i_length     => 15
      , i_field_name => '90-8 Adjustment Record Amount'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => null
      , i_begin      => 85
      , i_end        => 92
      , i_length     => 8
      , i_field_name => '90-9 Transaction Detail Record Count'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => null
      , i_begin      => 93
      , i_end        => 107
      , i_length     => 15
      , i_field_name => '90-10 Transaction Detail Record Amount'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => null
      , i_begin      => 108
      , i_end        => 157
      , i_length     => 50
      , i_field_name => '90-11 MRS Reserved'
    );
    put_value(
        io_raw_line  => l_raw_line
      , i_value      => null
      , i_begin      => 158
      , i_end        => 850
      , i_length     => 693
      , i_field_name => '90-12 Filler'
    );

    io_raw_tab(io_raw_tab.count + 1) := l_raw_line;
    io_num_tab(io_num_tab.count + 1) := io_num_tab.count + 1;

end format_trailer_90;

procedure prepare_header(
    i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_eff_date          in      date
  , io_file_rec         in out  t_file_rec
) is
    l_network_id            com_api_type_pkg.t_tiny_id      := mcw_api_const_pkg.MCW_NETWORK_ID;
    l_host_id               com_api_type_pkg.t_tiny_id;
    l_standard_id           com_api_type_pkg.t_tiny_id;
    l_param_tab             com_api_type_pkg.t_param_tab;
    l_cmid                  com_api_type_pkg.t_cmid;

begin
    io_file_rec.record_date :=
        to_char(
            get_cst_date(i_eff_date)
          , mcw_api_const_pkg.REWARD_SERVICE_OUT_DATE_FORMAT
        );

    io_file_rec.record_time :=
        to_char(
            get_cst_date(i_eff_date)
          , mcw_api_const_pkg.REWARD_SERVICE_OUT_TIME_FORMAT
        );

    l_network_id := mcw_api_const_pkg.MCW_NETWORK_ID;

    l_host_id :=
        net_api_network_pkg.get_default_host(
            i_network_id => l_network_id
        );

    l_standard_id :=
        net_api_network_pkg.get_offline_standard(
            i_host_id => l_host_id
        );

    trc_log_pkg.debug(
        'l_network_id = ' || l_network_id
        || ', l_host_id = ' || l_host_id
        || ', l_standard_id = ' || l_standard_id
    );

    l_cmid :=
        cmn_api_standard_pkg.get_varchar_value(
            i_inst_id     => i_inst_id
          , i_standard_id => l_standard_id
          , i_object_id   => l_host_id
          , i_entity_type => net_api_const_pkg.ENTITY_TYPE_HOST
          , i_param_name  => mcw_api_const_pkg.CMID
          , i_param_tab   => l_param_tab
        );

    io_file_rec.member_ica   := l_cmid;

end prepare_header;

procedure prepare_data(
    i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_lang              in      com_api_type_pkg.t_dict_value
  , i_eff_date          in      date
  , i_cursor_rec        in      t_card_instance_rec
  , io_file_rec         in out  t_file_rec
) is
    LOG_PREFIX         constant com_api_type_pkg.t_name     := lower($$PLSQL_UNIT) || '.prepare_data: ';
    l_person                    com_api_type_pkg.t_person;
    l_product_id                com_api_type_pkg.t_short_id;
    l_service_id                com_api_type_pkg.t_short_id;
    l_split_hash                com_api_type_pkg.t_tiny_id;
    l_service_start_date        date;
    l_person_address            com_api_type_pkg.t_address_rec;
    l_contact_data_tab          com_api_type_pkg.t_param_tab;
    l_params                    com_api_type_pkg.t_param_tab;
begin
        trc_log_pkg.debug(LOG_PREFIX
            || chr(10) || ' person_id = ' || i_cursor_rec.person_id
            || chr(10) || ' cardholder_number = ' ||  i_cursor_rec.cardholder_number
            || chr(10) || ' customer_id = ' ||  i_cursor_rec.customer_id
            || chr(10) || ' account_opened_date = ' ||  i_cursor_rec.account_opened_date
            || chr(10) || ' preceding_card_instance_id = ' ||  i_cursor_rec.prec_card_instance_id
            || chr(10) || ' card_id = ' ||  i_cursor_rec.card_id
            || chr(10) || ' card_status; = ' ||  i_cursor_rec.card_status
            || chr(10) || ' preceding_card_id = ' ||  i_cursor_rec.prec_card_id
            || chr(10) || ' preceding_card_status; = ' ||  i_cursor_rec.prec_card_status
        );

        io_file_rec.language_code :=
            com_api_array_pkg.conv_array_elem_v(
                i_lov_id            => INTERFACE_LANGUAGE_LOV_ID
              , i_array_type_id     => LANGUAGE_LOCALE_ARRAY_TYPE
              , i_array_id          => LANGUAGE_LOCALE_ARRAY_ID
              , i_inst_id           => i_inst_id
              , i_elem_value        => i_lang
            );

        l_person :=
            com_api_person_pkg.get_person(
                i_person_id         => i_cursor_rec.person_id
              , i_mask_error        => com_api_type_pkg.FALSE
            );

        io_file_rec.cardholder_number        := substr(lpad(i_cursor_rec.cardholder_number, greatest(length(i_cursor_rec.cardholder_number), 30), '0'), -30);
        io_file_rec.cardholder_title         := get_article_text(l_person.person_title);
        io_file_rec.cardholder_first_name    := l_person.first_name;
        io_file_rec.cardholder_second_name   := l_person.second_name;
        io_file_rec.cardholder_surname       := l_person.surname;
        io_file_rec.cardholder_suffix        := get_article_text(l_person.suffix);
        io_file_rec.cardholder_birthday      :=
            to_char(
                get_cst_date(l_person.birthday)
              , mcw_api_const_pkg.REWARD_SERVICE_OUT_DATE_FORMAT
            );
        io_file_rec.cardholder_gender :=
            case l_person.gender
                when com_api_const_pkg.PERSON_GENDER_MALE then '1'
                when com_api_const_pkg.PERSON_GENDER_FEMALE then '2'
            end;

        l_contact_data_tab :=
            com_api_contact_pkg.get_contact_data(
                i_object_id     => i_cursor_rec.customer_id
              , i_entity_type   => com_api_const_pkg.ENTITY_TYPE_CUSTOMER
              , i_contact_type  => com_api_const_pkg.CONTACT_TYPE_PRIMARY
              , i_eff_date      => i_eff_date
            );

        if l_contact_data_tab.count > 0 then
            if l_contact_data_tab.exists(com_api_const_pkg.COMMUNICATION_METHOD_PHONE) then
                io_file_rec.cardholder_phone := l_contact_data_tab(com_api_const_pkg.COMMUNICATION_METHOD_PHONE);
            end if;
            if l_contact_data_tab.exists(com_api_const_pkg.COMMUNICATION_METHOD_EMAIL) then
                io_file_rec.cardholder_email := l_contact_data_tab(com_api_const_pkg.COMMUNICATION_METHOD_EMAIL);
            end if;
            if l_contact_data_tab.exists(com_api_const_pkg.COMMUNICATION_METHOD_MOBILE) then
                io_file_rec.cardholder_mobile := l_contact_data_tab(com_api_const_pkg.COMMUNICATION_METHOD_MOBILE);
            end if;
        end if;


        l_person_address :=
            com_api_address_pkg.get_address(
                i_object_id    => i_cursor_rec.customer_id
              , i_entity_type  => com_api_const_pkg.ENTITY_TYPE_CUSTOMER
              , i_address_type => com_api_const_pkg.ADDRESS_TYPE_HOME
              , i_lang         => i_lang
              , i_mask_error   => com_api_const_pkg.TRUE
            );

        if l_person_address.id is not null then
            io_file_rec.cardholder_address_line1 :=
                com_api_address_pkg.get_address_string(
                    i_address_id => l_person_address.id
                  , i_inst_id    => i_inst_id
                );
            io_file_rec.cardholder_address_line2    := null;
            io_file_rec.cardholder_address_line3    := null;

            io_file_rec.cardholder_postal_code      := l_person_address.postal_code;
            io_file_rec.cardholder_city             := l_person_address.city;
            io_file_rec.cardholder_country_code     := l_person_address.country;
            io_file_rec.cardholder_province_code    := l_person_address.region_code;
        end if;

        io_file_rec.accrue_points_sw :=
            case
                when io_file_rec.card_status = CARD_STATUS_GOOD_STANDING then
                    'Y'
                else
                    null
            end;

        io_file_rec.card_number :=
            iss_api_card_pkg.get_card_number(
                i_card_id           => i_cursor_rec.card_id
              , i_inst_id           => i_inst_id
            );

        io_file_rec.card_status :=
            com_api_array_pkg.conv_array_elem_v(
                i_lov_id            => mcw_api_const_pkg.REWARD_CARD_STATUS_LOV_ID
              , i_array_type_id     => mcw_api_const_pkg.REWARD_CARD_STATUS_ARRAY_TYPE
              , i_array_id          => mcw_api_const_pkg.REWARD_CARD_STATUS_ARRAY_ID
              , i_inst_id           => i_inst_id
              , i_elem_value        => i_cursor_rec.card_status
            );

        io_file_rec.action_code         := ACTION_CODE_UPD_BANK_ACC_NUM;

        io_file_rec.new_card_number     := null;
        io_file_rec.new_card_status     := null;

        if i_cursor_rec.prec_card_id is not null then
            io_file_rec.new_card_number := io_file_rec.card_number;
            io_file_rec.card_number     :=
                iss_api_card_pkg.get_card_number(
                    i_card_id           => i_cursor_rec.prec_card_id
                  , i_inst_id           => i_inst_id
                );

            io_file_rec.new_card_status := io_file_rec.card_status;
            io_file_rec.card_status     :=
                com_api_array_pkg.conv_array_elem_v(
                    i_lov_id            => mcw_api_const_pkg.REWARD_CARD_STATUS_LOV_ID
                  , i_array_type_id     => mcw_api_const_pkg.REWARD_CARD_STATUS_ARRAY_TYPE
                  , i_array_id          => mcw_api_const_pkg.REWARD_CARD_STATUS_ARRAY_ID
                  , i_inst_id           => i_inst_id
                  , i_elem_value        => i_cursor_rec.prec_card_status
                );
        end if;

        l_product_id :=
            prd_api_product_pkg.get_product_id(
                i_entity_type       => iss_api_const_pkg.ENTITY_TYPE_CARD
              , i_object_id         => i_cursor_rec.card_id
              , i_eff_date          => i_eff_date
              , i_inst_id           => i_inst_id
            );

        l_split_hash :=
            com_api_hash_pkg.get_split_hash(
                i_entity_type => iss_api_const_pkg.ENTITY_TYPE_CARD
              , i_object_id   => i_cursor_rec.card_id
            );

        l_service_id :=
            prd_api_service_pkg.get_active_service_id(
                i_entity_type      => iss_api_const_pkg.ENTITY_TYPE_CARD
              , i_object_id        => i_cursor_rec.card_id
              , i_attr_name        => null
              , i_service_type_id  => mcw_api_const_pkg.REWARD_SERVICE_TYPE_ID
              , i_mask_error       => com_api_const_pkg.TRUE
              , i_split_hash       => l_split_hash
              , i_eff_date         => i_eff_date
            );

        if l_service_id is null then
            com_api_error_pkg.raise_error(
                i_error      => 'PRD_NO_ACTIVE_SERVICE'
              , i_env_param1 => iss_api_const_pkg.ENTITY_TYPE_CARD
              , i_env_param2 => i_cursor_rec.card_id
              , i_env_param3 => null
              , i_env_param4 => i_eff_date
            );
        else
            io_file_rec.bank_product_code :=
                prd_api_product_pkg.get_attr_value_char(
                    i_product_id        => l_product_id
                  , i_entity_type       => iss_api_const_pkg.ENTITY_TYPE_CARD
                  , i_object_id         => i_cursor_rec.card_id
                  , i_attr_name         => mcw_api_const_pkg.ATTR_BANK_PRODUCT_CODE
                  , i_params            => l_params
                  , i_service_id        => l_service_id
                  , i_eff_date          => i_eff_date
                  , i_split_hash        => l_split_hash
                  , i_inst_id           => i_inst_id
                  , i_use_default_value => com_api_const_pkg.TRUE
                );

            io_file_rec.program_identifier :=
                prd_api_product_pkg.get_attr_value_char(
                    i_product_id        => l_product_id
                  , i_entity_type       => iss_api_const_pkg.ENTITY_TYPE_CARD
                  , i_object_id         => i_cursor_rec.card_id
                  , i_attr_name         => mcw_api_const_pkg.ATTR_PROGRAM_IDENTIFIER
                  , i_params            => l_params
                  , i_service_id        => l_service_id
                  , i_eff_date          => i_eff_date
                  , i_split_hash        => l_split_hash
                  , i_inst_id           => i_inst_id
                  , i_use_default_value => com_api_const_pkg.TRUE
                );
        end if;

        begin
            select p.start_date
              into l_service_start_date
              from prd_service_object p
             where p.service_id  = l_service_id
               and p.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
               and p.object_id   = i_cursor_rec.card_id;
        exception
            when no_data_found then
                null;
        end;

        io_file_rec.enrollment_date         := to_char(get_cst_date(l_service_start_date), mcw_api_const_pkg.REWARD_SERVICE_OUT_DATE_FORMAT);
        io_file_rec.account_opened_date     := to_char(get_cst_date(i_cursor_rec.account_opened_date), mcw_api_const_pkg.REWARD_SERVICE_OUT_DATE_FORMAT);

exception
    when others then
        trc_log_pkg.debug(
            i_text        => LOG_PREFIX || 'Failed.'
        );
        raise;
end prepare_data;

procedure collect_data(
    i_object_id         in      com_api_type_pkg.t_long_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_event_type        in      com_api_type_pkg.t_dict_value
  , io_object_tab       in out  t_object_tab
) is
begin
    if not io_object_tab.exists(i_object_id) then
        io_object_tab(i_object_id).object_id                    := i_object_id;
        io_object_tab(i_object_id).entity_type                  := i_entity_type;
        io_object_tab(i_object_id).event_type(i_event_type)     := null;
    else
        io_object_tab(i_object_id).event_type(i_event_type)     := null;
    end if;
end collect_data;

procedure export(
    i_inst_id           in  com_api_type_pkg.t_inst_id
  , i_lang              in  com_api_type_pkg.t_dict_value   default null
) is
    LOG_PREFIX     constant com_api_type_pkg.t_name         := lower($$PLSQL_UNIT) || '.export: ';
    l_estimated_count       com_api_type_pkg.t_long_id      := 0;
    l_processed_count       com_api_type_pkg.t_long_id      := 0;
    l_container_id          com_api_type_pkg.t_long_id;
    l_process_id            com_api_type_pkg.t_short_id;
    l_session_id            com_api_type_pkg.t_long_id;
    l_eff_date              date;
    l_lang                  com_api_type_pkg.t_dict_value;
    l_format_id             com_api_type_pkg.t_inst_id;
    l_file_name             com_api_type_pkg.t_name;
    l_file_rec              t_file_rec;
    l_object_id_tab         com_api_type_pkg.t_number_tab;
    l_entity_type_tab       com_api_type_pkg.t_dict_tab;
    l_event_type_tab        com_api_type_pkg.t_dict_tab;
    l_object_tab            t_object_tab;
    l_event_object_id_tab   com_api_type_pkg.t_number_tab;
    l_raw_tab               com_api_type_pkg.t_raw_tab;
    l_num_tab               com_api_type_pkg.t_integer_tab;
    l_ls_raw_tab            com_api_type_pkg.t_raw_tab;
    l_ls_num_tab            com_api_type_pkg.t_integer_tab;
    l_data_raw_tab          com_api_type_pkg.t_raw_tab;
    l_data_num_tab          com_api_type_pkg.t_integer_tab;
    l_params                com_api_type_pkg.t_param_tab;
    l_card_instance_tab     t_card_instance_tab;
    l_card_instance_id_tab  num_tab_tpt                     := new num_tab_tpt();
    l_cardholder_id_tab     com_api_type_pkg.t_number_tab;

    cursor cu_event_object(
        i_inst_id           in com_api_type_pkg.t_inst_id
      , i_eff_date          in date
    ) is
        select eo.id            as event_object_id
             , eo.object_id     as object_id
             , eo.entity_type   as entity_type
             , e.event_type     as event_type
          from evt_event_object eo
             , evt_event e
         where decode(eo.status, 'EVST0001', eo.procedure_name, null) = PROCEDURE_NAME_EXPORT
           and eo.eff_date     <= i_eff_date
           and eo.event_id      = e.id
           and eo.inst_id       = i_inst_id;

    cursor cu_card_instance(
        i_card_instance_id_tab      in  num_tab_tpt
    ) is
        select ci.id                            as card_instance_id
             , ch.person_id                     as person_id
             , ch.id                            as cardholder_number
             , ch.id                            as cardholder_id
             , c.customer_id                    as customer_id
             , c.reg_date                       as account_opened_date
             , ci.preceding_card_instance_id    as preceding_card_instance_id
             , ci.card_id                       as card_id
             , ci.status                        as card_status
             , pci.card_id                      as preceding_card_id
             , pci.status                       as preceding_card_statis
          from iss_card_instance ci
             , iss_card c
             , iss_cardholder ch
             , iss_card_instance pci
             , iss_card pc
         where ci.card_id   = c.id
           and ci.id        in (select column_value from table(cast(i_card_instance_id_tab as num_tab_tpt)))
           and ch.id        = c.cardholder_id
           and pci.id(+)    = ci.preceding_card_instance_id
           and pc.id(+)     = pci.card_id
         order by ch.id asc;

begin
    prc_api_stat_pkg.log_start;

    l_eff_date              := com_api_sttl_day_pkg.get_sysdate;
    l_lang                  := nvl(i_lang, get_user_lang);
    l_container_id          := prc_api_session_pkg.get_container_id;
    l_process_id            := prc_api_session_pkg.get_process_id;
    l_session_id            := prc_api_session_pkg.get_session_id;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'Started. i_inst_id [#1], i_lang [#2], l_container_id [#4], l_process_id [#5], l_session_id [#6]'
      , i_env_param1 => i_inst_id
      , i_env_param2 => l_lang
      , i_env_param4 => l_container_id
      , i_env_param5 => l_process_id
      , i_env_param6 => l_session_id
    );

    open cu_event_object(
        i_inst_id           => i_inst_id
      , i_eff_date          => l_eff_date
    );

    loop
        fetch cu_event_object bulk collect
        into l_event_object_id_tab
           , l_object_id_tab
           , l_entity_type_tab
           , l_event_type_tab
        limit BULK_LIMIT;

        for i in 1 .. l_event_object_id_tab.count loop
            if l_entity_type_tab(i) = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE then
                l_card_instance_id_tab.extend;
                l_card_instance_id_tab(l_card_instance_id_tab.count) := l_object_id_tab(i);

                collect_data(
                    i_object_id         => l_card_instance_id_tab(l_card_instance_id_tab.count)
                  , i_entity_type       => l_entity_type_tab(i)
                  , i_event_type        => l_event_type_tab(i)
                  , io_object_tab       => l_object_tab
                );

            elsif l_entity_type_tab(i) = iss_api_const_pkg.ENTITY_TYPE_CARD then
                l_card_instance_id_tab.extend;
                l_card_instance_id_tab(l_card_instance_id_tab.count) := iss_api_card_instance_pkg.get_card_instance_id(i_card_id => l_object_id_tab(i));

                collect_data(
                    i_object_id         => l_card_instance_id_tab(l_card_instance_id_tab.count)
                  , i_entity_type       => l_entity_type_tab(i)
                  , i_event_type        => l_event_type_tab(i)
                  , io_object_tab       => l_object_tab
                );

            elsif l_entity_type_tab(i) = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER then
                for cu_ci in (
                        select ci.id as card_instance_id
                          from iss_card_instance ci
                             , iss_card c
                             , iss_cardholder ch
                         where ci.card_id       = c.id
                           and ch.id            = c.cardholder_id
                           and c.cardholder_id  = l_object_id_tab(i)
                           and prd_api_service_pkg.get_active_service_id(
                                   i_entity_type        => iss_api_const_pkg.ENTITY_TYPE_CARD
                                 , i_object_id          => c.id
                                 , i_attr_name          => null
                                 , i_service_type_id    => mcw_api_const_pkg.REWARD_SERVICE_TYPE_ID
                                 , i_mask_error         => com_api_const_pkg.TRUE
                                 , i_eff_date           => l_eff_date
                               ) is not null
                           and rownum = 1
                ) loop
                    l_card_instance_id_tab.extend;
                    l_card_instance_id_tab(l_card_instance_id_tab.count) := cu_ci.card_instance_id;

                    collect_data(
                        i_object_id         => l_card_instance_id_tab(l_card_instance_id_tab.count)
                      , i_entity_type       => l_entity_type_tab(i)
                      , i_event_type        => l_event_type_tab(i)
                      , io_object_tab       => l_object_tab
                    );

                end loop;
            else
                com_api_error_pkg.raise_error(
                    i_error       => 'ENTITY_TYPE_NOT_SUPPORTED'
                  , i_env_param1  => l_entity_type_tab(i)
                );
            end if;

        end loop;

        exit when cu_event_object%notfound;
    end loop;

    close cu_event_object;

    if l_object_tab.count > 0 then

        l_file_rec.record_count := l_object_tab.count;
        l_estimated_count       := l_file_rec.record_count;

        prc_api_stat_pkg.log_estimation(
            i_estimated_count   => l_estimated_count
        );

        begin
            select a.name_format_id
              into l_format_id
              from prc_file_attribute a
             where a.container_id = l_container_id;
        exception
            when no_data_found then
                null;
        end;

        rul_api_param_pkg.set_param(
            i_name    => 'INST_ID'
          , i_value   => i_inst_id
          , io_params => l_params
        );

        rul_api_param_pkg.set_param (
            i_name     => 'SYS_DATE'
          , i_value    => l_eff_date
          , io_params  => l_params
        );

        l_file_name :=
            rul_api_name_pkg.get_name(
                i_format_id     => l_format_id
              , i_param_tab     => l_params
            );

        if length(l_file_name) > 30 then
            com_api_error_pkg.raise_error(
                i_error         => 'VALUE_EXCEEDED_ALLOWED_MAXIMUM'
              , i_env_param1    => length(l_file_name)
              , i_env_param2    => 30
            );
        end if;

        l_file_rec.file_name    := l_file_name;

        prepare_header(
            i_inst_id           => i_inst_id
          , i_eff_date          => l_eff_date
          , io_file_rec         => l_file_rec
        );

        format_header_10(
            i_file_rec  => l_file_rec
          , io_raw_tab  => l_raw_tab
          , io_num_tab  => l_num_tab
        );

        open cu_card_instance(
            i_card_instance_id_tab  => l_card_instance_id_tab
        );

        loop
            fetch cu_card_instance bulk collect
             into l_card_instance_tab
             limit BULK_LIMIT;

            for i in 1 .. l_card_instance_tab.count loop
                prepare_data(
                    i_inst_id           => i_inst_id
                  , i_lang              => l_lang
                  , i_eff_date          => l_eff_date
                  , i_cursor_rec        => l_card_instance_tab(i)
                  , io_file_rec         => l_file_rec
                );

                if (    l_object_tab(l_card_instance_tab(i).card_instance_id).event_type.exists(mcw_api_const_pkg.EVENT_TYPE_WORLD_REWARD_ACTIV)
                    or  l_object_tab(l_card_instance_tab(i).card_instance_id).event_type.exists(iss_api_const_pkg.EVENT_TYPE_CARD_ISSUANCE)
                    or  l_object_tab(l_card_instance_tab(i).card_instance_id).event_type.exists(iss_api_const_pkg.EVENT_TYPE_CUSTOMER_CREATION)
                   )
                   and l_file_rec.new_card_number is not null
                then
                    format_lost_stolen_40(
                        i_file_rec  => l_file_rec
                      , io_raw_tab  => l_ls_raw_tab
                      , io_num_tab  => l_ls_num_tab
                    );
                end if;

                if (    l_object_tab(l_card_instance_tab(i).card_instance_id).event_type.exists(mcw_api_const_pkg.EVENT_TYPE_WORLD_REWARD_ACTIV)
                    or  l_object_tab(l_card_instance_tab(i).card_instance_id).event_type.exists(iss_api_const_pkg.EVENT_TYPE_CARDHOLDER_MODIFY)
                   )
                   and not l_cardholder_id_tab.exists(l_card_instance_tab(i).cardholder_id)
                   and l_file_rec.new_card_number is null
                then
                    l_cardholder_id_tab(l_card_instance_tab(i).cardholder_id)   := null;

                    format_customer_15(
                        i_file_rec  => l_file_rec
                      , io_raw_tab  => l_data_raw_tab
                      , io_num_tab  => l_data_num_tab
                    );
                end if;

                if      l_file_rec.new_card_number is null
                    and not l_object_tab(l_card_instance_tab(i).card_instance_id).entity_type = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                then
                    format_customer_account_20(
                        i_file_rec  => l_file_rec
                      , io_raw_tab  => l_data_raw_tab
                      , io_num_tab  => l_data_num_tab
                    );
                end if;
            end loop;

            exit when cu_card_instance%notfound;
        end loop;

        for i in 1 .. l_ls_raw_tab.count loop
            l_raw_tab(l_raw_tab.count + 1) := l_ls_raw_tab(i);
            l_num_tab(l_num_tab.count + 1) := l_num_tab.count + 1;
        end loop;

        for i in 1 .. l_data_raw_tab.count loop
            l_raw_tab(l_raw_tab.count + 1) := l_data_raw_tab(i);
            l_num_tab(l_num_tab.count + 1) := l_num_tab.count + 1;
        end loop;

        format_trailer_90(
            i_file_rec  => l_file_rec
          , io_raw_tab  => l_raw_tab
          , io_num_tab  => l_num_tab
        );

        l_processed_count := l_num_tab.count;

        save_file(
            i_event_object_id_tab   => l_event_object_id_tab
          , i_raw_tab               => l_raw_tab
          , i_num_tab               => l_num_tab
          , i_file_name             => l_file_rec.file_name
          , i_processed_count       => l_processed_count
          , io_params               => l_params
        );
    else
        prc_api_stat_pkg.log_end(
            i_processed_total  => 0
          , i_excepted_total   => 0
          , i_rejected_total   => 0
          , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        );
    end if;

    trc_log_pkg.debug(
        i_text        => LOG_PREFIX || 'Finished.'
    );
exception
    when others then
        trc_log_pkg.debug(
            i_text        => LOG_PREFIX || 'Failed.'
        );

        if cu_event_object%isopen then
            close cu_event_object;
        end if;

        prc_api_stat_pkg.log_end(
            i_processed_total   => l_processed_count
          , i_excepted_total    => 0
          , i_rejected_total    => 0
          , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;

        raise;
end export;

end mcw_prc_lty_pkg;
/
