create or replace package body mcw_prc_fraud_pkg is

    BULK_LIMIT      constant integer := 400;

    function pad_number (
        i_data              in varchar2
        , i_min_length      in integer
        , i_max_length      in integer
    ) return varchar2 is
    begin
        case
            when nvl(length(i_data), 0) < i_min_length then return lpad(nvl(i_data, '0'), i_min_length, '0');
            when nvl(length(i_data), 0) > i_max_length then return substr(i_data, - i_max_length);
            else return i_data;
        end case;
    end;

    function pad_char (
        i_data              in varchar2
        , i_min_length      in integer
        , i_max_length      in integer
    ) return varchar2 is
    begin
        case
            when nvl(length(i_data), 0) < i_min_length then return rpad(nvl(i_data, ' '), i_min_length, ' ');
            when nvl(length(i_data), 0) > i_max_length then return substr(i_data, 1, i_max_length);
            else return i_data;
        end case;
    end;

    procedure upload_fraud(
        i_inst_id   in  com_api_type_pkg.t_inst_id       default null
    ) is
        MC_FRAUD_TYPE_DICT  constant  com_api_type_pkg.t_dict_value := 'MFTC';

        cursor l_entrys is
        select
            id
            , c01, c02, c03, c04, c05, c06, c07, c08_10, c09
            , c11, c12, c13, c14, c15, c16, c17, c18, c19
            , c20, c21, c22, c23, c24, c25, c26, c27, c28, c29
            , c30, c31, c32, c33, c34, c35, c36, c37, c39
            , c44, c45, c46, c47, c48
            , count(c02)   over() count_all
            , count(id)    over(partition by c02) count_c02
            , row_number() over(order by c02,c01,id) record_number_all
            , row_number() over(partition by c02 order by c02,c01,id) record_number_c02
            , 0 record_error_flag
          from mcw_fraud
         where status = net_api_const_pkg.CLEARING_MSG_STATUS_READY  --'CLMS0010'
           and is_incoming = 0
           and (inst_id = i_inst_id
                or i_inst_id is null
               )
          order by
                c02
              , c01;

        l_id                    com_api_type_pkg.t_long_tab;
        l_c01                   com_api_type_pkg.t_dict_tab;
        l_c02                   com_api_type_pkg.t_name_tab;
        l_c03                   com_api_type_pkg.t_number_tab;
        l_c04                   com_api_type_pkg.t_name_tab;
        l_c05                   com_api_type_pkg.t_name_tab;
        l_c06                   com_api_type_pkg.t_date_tab;
        l_c07                   com_api_type_pkg.t_name_tab;
        l_c08_10                com_api_type_pkg.t_date_tab;
        l_c09                   com_api_type_pkg.t_number_tab;
        l_c11                   com_api_type_pkg.t_number_tab;
        l_c12                   com_api_type_pkg.t_curr_code_tab;
        l_c13                   com_api_type_pkg.t_number_tab;
        l_c14                   com_api_type_pkg.t_number_tab;
        l_c15                   com_api_type_pkg.t_curr_code_tab;
        l_c16                   com_api_type_pkg.t_number_tab;
        l_c17                   com_api_type_pkg.t_name_tab;
        l_c18                   com_api_type_pkg.t_name_tab;
        l_c19                   com_api_type_pkg.t_name_tab;
        l_c20                   com_api_type_pkg.t_name_tab;
        l_c21                   com_api_type_pkg.t_name_tab;
        l_c22                   com_api_type_pkg.t_name_tab;
        l_c23                   com_api_type_pkg.t_name_tab;
        l_c24                   com_api_type_pkg.t_name_tab;
        l_c25                   com_api_type_pkg.t_name_tab;
        l_c26                   com_api_type_pkg.t_name_tab;
        l_c27                   com_api_type_pkg.t_name_tab;
        l_c28                   com_api_type_pkg.t_dict_tab;
        l_c29                   com_api_type_pkg.t_dict_tab;
        l_c30                   com_api_type_pkg.t_dict_tab;
        l_c31                   com_api_type_pkg.t_dict_tab;
        l_c32                   com_api_type_pkg.t_date_tab;
        l_c33                   com_api_type_pkg.t_name_tab;
        l_c34                   com_api_type_pkg.t_name_tab;
        l_c35                   com_api_type_pkg.t_name_tab;
        l_c36                   com_api_type_pkg.t_name_tab;
        l_c37                   com_api_type_pkg.t_name_tab;
        l_c39                   com_api_type_pkg.t_name_tab;
        l_c44                   com_api_type_pkg.t_dict_tab;
        l_c45                   com_api_type_pkg.t_name_tab;
        l_c46                   com_api_type_pkg.t_name_tab;
        l_c47                   com_api_type_pkg.t_name_tab;
        l_c48                   com_api_type_pkg.t_name_tab;

        l_count_all             com_api_type_pkg.t_number_tab;
        l_count_c02             com_api_type_pkg.t_number_tab;
        l_record_number_all     com_api_type_pkg.t_number_tab;
        l_record_number_c02     com_api_type_pkg.t_number_tab;

        l_rec_error             com_api_type_pkg.t_boolean_tab;

        l_current_count         com_api_type_pkg.t_long_id := 0;
        l_processed_count       com_api_type_pkg.t_long_id := 0;
        l_session_file_id       com_api_type_pkg.t_long_id;
        l_rec_raw               com_api_type_pkg.t_raw_tab;
        l_rec_num               com_api_type_pkg.t_integer_tab;

        l_sysdate               date := get_sysdate;
        l_sysdate_char          com_api_type_pkg.t_name := to_char(get_sysdate,'YYYYMMDD');
        l_head_str              com_api_type_pkg.t_name;
        l_c02_count             com_api_type_pkg.t_tiny_id := 0;

        l_total_records         com_api_type_pkg.t_tiny_id := 0;
        l_ok_records            com_api_type_pkg.t_tiny_id := 0;
        l_error_records         com_api_type_pkg.t_tiny_id := 0;

        l_seq                   com_api_type_pkg.t_tiny_id;
        l_header_flag           com_api_type_pkg.t_boolean := 0;

        procedure open_file is
        begin
            prc_api_file_pkg.open_file (
                o_sess_file_id  => l_session_file_id
            );
        end;

        procedure put_file is
        begin
            prc_api_file_pkg.put_bulk (
                i_sess_file_id  => l_session_file_id
                , i_raw_tab     => l_rec_raw
                , i_num_tab     => l_rec_num
            );
            l_rec_raw.delete;
            l_rec_num.delete;
        end;

        procedure close_file (
            i_status                in com_api_type_pkg.t_dict_value
        ) is
        begin
            if l_session_file_id is null then
                return;
            end if;
            
            prc_api_file_pkg.close_file (
                i_sess_file_id  => l_session_file_id
              , i_status        => i_status
            );
        end;

        function get_iss_cntrl_num_seq (
            i_iss_cntrl_num         in com_api_type_pkg.t_name
        ) return com_api_type_pkg.t_tiny_id is
            l_seq_number            com_api_type_pkg.t_tiny_id;
        begin
           update
               mcw_fraud_seq
           set
               seq_number = seq_number + 1
           where
               iss_control_number = i_iss_cntrl_num
               and call_date = trunc(l_sysdate)
           returning
               seq_number
           into
               l_seq_number;
               
            if sql%rowcount = 0 then
                l_seq_number := 1;
                insert into mcw_fraud_seq (
                   iss_control_number
                   , call_date
                   , seq_number
                ) values (
                   i_iss_cntrl_num
                   , trunc(l_sysdate)
                   , l_seq_number
                );
            end if;
            
            return l_seq_number;
        end ;

        function make_record (
            i                       in pls_integer
        ) return com_api_type_pkg.t_raw_data is
            l_rec_type              com_api_type_pkg.t_dict_value;
            l_result                com_api_type_pkg.t_raw_data;
        begin
            l_rec_type := substr(l_c01(i), 5, 3);
            l_result :=
               -- 01:  record type
               pad_char(l_rec_type, 3, 3)
               -- 02: issuer customer number
            || pad_number (l_c02(i), 7, 7)
               -- 03: audit control number is unique by table constraint
            || case when l_rec_type = 'FDN'
                      then pad_char(' ', 15, 15)
                      else pad_char(substr(to_char(l_c03(i)), 2, 15), 15, 15)
               end
               -- 04: acquirer customer number
            || case when l_rec_type in ('FDD', 'FDE', 'FDN') then pad_number('0', 7, 7)
                    when l_rec_type in ('FDA', 'FDC') then pad_number(l_c04(i), 7, 7)
               end
               -- 05: acquirers reference number
            || case when l_rec_type in ('FDD', 'FDE', 'FDN') then pad_number('0', 23, 23)
                    when l_rec_type in ('FDA', 'FDC') then pad_char(l_c05(i), 23, 23)
               end
               -- 06: fraud posted date
            || pad_number(to_char (l_c06(i), 'yyyymmdd'), 8, 8)
               -- 07: cardholder number
            || case when l_rec_type in ('FDD', 'FDE', 'FDN') then pad_number('0', 19, 19)
                    when l_rec_type in ('FDA', 'FDC') then pad_char(l_c07(i), 19, 19)
               end
               -- 08: transaction date
            || case when l_c08_10(i) is null then pad_number('0', 8, 8)
                    when l_rec_type in ('FDD', 'FDE', 'FDN') then pad_number('0', 8, 8)
                    when l_rec_type in ('FDA', 'FDC') then pad_number(to_char(l_c08_10(i), 'YYYYMMDD'), 8, 8)
               end
              -- 09: filler
            || pad_char(' ', 9, 9)
              -- 10: transaction time
            || case when l_c08_10(i) is null then pad_number('0', 6, 6)
                    when l_rec_type in ('FDD', 'FDE', 'FDN') then pad_number('0', 6, 6)
                    when l_rec_type in ('FDA', 'FDC') then pad_number(to_char(l_c08_10(i), 'HH24MISS'), 6, 6)
               end
              -- 11: transaction amount in currency of transaction
            || case when l_c11(i) is null then pad_char(' ', 10, 10)
                    when l_rec_type in ('FDD', 'FDE', 'FDN') then pad_number('0', 10, 10)
                    when l_rec_type in ('FDA', 'FDC') then  pad_number( nvl(l_c11(i),0), 10, 10)
               end
              -- 12: transaction currency code
            ||  case when l_rec_type in ('FDD', 'FDE', 'FDN') then '000'
                     when l_rec_type in ('FDA', 'FDC') then  pad_number( nvl(l_c12(i),'0'), 3, 3)
                end
              -- 13: transaction currency exponent
            || case when l_rec_type in ('FDD', 'FDE', 'FDN') then '0'
                    when l_rec_type in ('FDA', 'FDC') then  nvl( l_c13(i),'0' )
               end
              -- 14: amount cardholder
            || case when l_c11(i) is null then pad_char(' ', 10, 10)
                    when l_rec_type in ('FDD', 'FDE', 'FDN') then pad_number('0', 10, 10)
                    when l_rec_type in ('FDA', 'FDC') then  pad_number( nvl(l_c14(i),0), 10, 10)
               end
              -- 15: cardholder billing currency code
            || case when l_rec_type in ('FDD', 'FDE', 'FDN') then '000'
                    when l_rec_type in ('FDA', 'FDC') then  pad_number( nvl(l_c15(i),'0'), 3, 3)
               end
              -- 16: cardholder billing currency exponent
            || case when l_rec_type in ('FDD', 'FDE', 'FDN') then '0'
                    when l_rec_type in ('FDA', 'FDC') then   nvl( l_c16(i),'0' )
               end
              -- 17: card type
            || case when l_c17(i) is null then '000'
                    else pad_char(l_c17(i), 3, 3 )
               end
              -- 18: merchant name
            || case when l_rec_type in ('FDD', 'FDE', 'FDN') then pad_char(' ', 22, 22)
                    when l_rec_type in ('FDA', 'FDC') then  pad_char(l_c18(i), 22, 22 )
               end
              -- 19: merchant number
            || case when l_rec_type in ('FDD', 'FDE', 'FDN') then pad_char(' ', 15, 15)
                    when l_rec_type in ('FDA', 'FDC') then  pad_char(l_c19(i), 15, 15 )
               end
              -- 20: merchant city
            || case when l_rec_type in ('FDD', 'FDE', 'FDN') then pad_char(' ', 13, 13)
                    when l_rec_type in ('FDA', 'FDC') then  pad_char(l_c20(i), 13, 13 )
               end
              -- 21:  merchant state/province
            || case when l_rec_type in ('FDD', 'FDE', 'FDN') then pad_char(' ', 3, 3)
                    when l_rec_type in ('FDA', 'FDC') then  pad_char(l_c21(i), 3, 3 )
               end
              -- 22: merchant country
            || case when l_rec_type in ('FDD', 'FDE', 'FDN') then pad_char(' ', 3, 3)
                    when l_rec_type in ('FDA', 'FDC') then  pad_char(l_c22(i), 3, 3 )
               end
              -- 23: merchant postal code
            || pad_char (l_c23(i), 10, 10)
              -- 24: merchant category code
            || case when l_rec_type in ('FDD', 'FDE', 'FDN') then '0000'
                    when l_rec_type in ('FDA', 'FDC') then  pad_char(l_c24(i), 4, 4 )
               end
              -- 25:
            || case when l_rec_type in ('FDD', 'FDE', 'FDN') then pad_char(' ', 6, 6)
                    when l_rec_type in ('FDA', 'FDC') then  pad_char(l_c25(i), 6, 6 )
               end
              -- 26: pos entry mode
            || case when l_rec_type in ('FDD', 'FDE', 'FDN') then '  '
                    when l_rec_type in ('FDA') then  pad_number(l_c26(i), 2, 2 )
                    when l_rec_type in ('FDC') then  '  '
               end
              -- 27: terminal number
            || case when l_rec_type in ('FDD', 'FDE', 'FDN') then pad_char(' ', 8, 8)
                    when l_rec_type in ('FDA', 'FDC') then  pad_number(l_c27(i), 8, 8 )
               end
              -- 28: fraud type code
            || case when l_rec_type in ('FDD', 'FDE', 'FDN') then '00'    --? '  '
                    when l_rec_type in ('FDA') then pad_char(nvl(substr(l_c28(i), 7, 2), '  '), 2, 2)
                    when l_rec_type in ('FDC') then pad_char(nvl( substr(l_c28(i), 7, 2), '  '), 2, 2)
               end
              -- 29: sub fraud type
            || case when l_rec_type in ('FDD', 'FDE', 'FDN') then ' '
                    when l_rec_type in ('FDA', 'FDC') then nvl(substr(l_c29(i), 8, 1), ' ')
               end
              -- 30: chargeback indicator
            || case when l_rec_type in ('FDD', 'FDE', 'FDN') then ' '
                    when l_rec_type in ('FDA', 'FDC') then nvl(substr(l_c30(i), 8, 1),' ')
              end
              -- 31: filler
            || nvl( substr(l_c30(i), 8, 1), ' ')
              -- 32: settlement date
            || case when l_c32(i) is null then pad_number('0', 8, 8)
                    when l_rec_type in ('FDD', 'FDE', 'FDN') then pad_number('0', 8, 8)
                    when l_rec_type in ('FDA', 'FDC') then pad_number(to_char(l_c32(i), 'YYYYMMDD'), 8, 8)
               end
              -- 33: authorization response code
            || case when l_rec_type in ('FDD', 'FDE', 'FDN') then '  '
                    when l_rec_type in ('FDA', 'FDC') then  pad_char(l_c33(i), 2, 2 )
               end
              -- 34: delete duplicated flag
            || case when l_rec_type in ('FDD', 'FDN') then ' '
                    when l_rec_type in ('FDE') then  nvl(substr(l_c34(i), 8, 1), ' ')
                    when l_rec_type in ('FDC') then  ' '
                    when l_rec_type in ('FDA') then  nvl(substr(l_c34(i), 8, 1),' ')
               end
               -- for l_rec_type 'FDA'
            || case when l_rec_type in ('FDA') then pad_char(l_c35(i), 3, 3 ) end   -- 35: first reported date
            || case when l_rec_type in ('FDA') then pad_char(l_c36(i), 1, 1 ) end   -- 36: addendum indicator
            || case when l_rec_type in ('FDA') then pad_char(l_c37(i), 8, 8 ) end   -- 37: date cardholder reported fraud
            || case when l_rec_type in ('FDA') then ' ' end                         -- 38: filler
            || case when l_rec_type in ('FDA') then pad_char(l_c39(i), 1, 1 ) end   -- 39: cvc indicator
            || case when l_rec_type in ('FDA') then ' ' end                         -- 40: account closed indicator
            || case when l_rec_type in ('FDA') then pad_char(' ', 12, 12) end       -- 41: cash back amount
            || case when l_rec_type in ('FDA') then pad_char(' ', 3, 3) end         -- 42: cash back amount currency code
            || case when l_rec_type in ('FDA') then ' ' end                         -- 43: cash back currency exponent

            || case when l_rec_type in ('FDA') then pad_char(substr(l_c44(i), 8, 1), 1, 1) end      -- 44: acount device type
            || case when l_rec_type in ('FDA') then pad_char(substr(l_c45(i), 1, 1), 1, 1) end      -- 45: electronic commerce indicator
            || case when l_rec_type in ('FDA') then pad_char(substr(l_c46(i), 1, 1), 1, 1) end      -- 46: AVS response code
            || case when l_rec_type in ('FDA') then pad_char(substr(l_c47(i), 1, 1), 1, 1) end      -- 47: card present
            || case when l_rec_type in ('FDA') then pad_char(substr(l_c48(i), 1, 1), 1, 1) end      -- 48: terminal operating environment
            ;

            return pad_char(l_result, 275, 275 );
        end;

        function check_error_record (
            i                       in pls_integer
        ) return com_api_type_pkg.t_count is
            l_rec_type              com_api_type_pkg.t_dict_value;
            l_error_count           com_api_type_pkg.t_count := 0;
            l_error_text            com_api_type_pkg.t_text;
            
            procedure put_error (
                i_str               in varchar2
            ) is
            begin
                l_error_count := l_error_count + 1;
                if l_error_text is null then
                    l_error_text := i_str;
                else
                    l_error_text := l_error_text || ', ' || i_str;
                end if;
            end;
        begin
            l_rec_type  := substr(l_c01(i), 5, 3);
            
            -- date_time
            if l_rec_type = 'FDA' and l_c08_10(i) is null then
                put_error ('empty c08_10');
            end if;
            -- currency exponent
            if ( (l_rec_type = 'FDA') or (l_rec_type = 'FDC' and l_c13(i) is not null) ) and ( l_c13(i) not in (0,1,2,3,4,5) ) then
                put_error ('wrong c13');
            end if;
            if ( (l_rec_type = 'FDA') or (l_rec_type = 'FDC' and l_c16(i) is not null) ) and ( l_c16(i) not in (0,1,2,3,4,5) ) then
                put_error ('wrong c16'); end if;
            -- card_type
            if l_rec_type in ('FDA','FDC') and l_c17(i) in ('MCO','PRO','PVL') then
                put_error ('wrong c17');
            end if;
            -- mcc
            if l_rec_type in ('FDA','FDC') and l_c24(i) is null then
                put_error ('empty c24');
            end if;
            -- fraud type
            if ( (l_rec_type = 'FDA') or (l_rec_type = 'FDC' and l_c28(i) is not null) ) 
                --and ( substr(l_c28(i), 7, 2) not in ('00','01','02','03','04','05','06','07','51') )
                and com_api_dictionary_pkg.check_article(
                        i_dict => MC_FRAUD_TYPE_DICT
                      , i_code => MC_FRAUD_TYPE_DICT || lpad(substr(l_c28(i), 7, 2), 4, '0')
                    ) = com_api_type_pkg.FALSE
            then
                put_error ('wrong c28');
            end if;
            -- sub fraud type
            if ( l_rec_type = 'FDA' and  substr(l_c29(i), 8, 1) not in ('K', 'N', 'P', 'U')
                 or l_rec_type = 'FDC' and  substr(l_c29(i), 8, 1) not in ('K', 'N', 'P', ' ') 
            ) then
                put_error ('wrong c29');
            end if;
            -- chargeback indicator
            if ( l_rec_type = 'FDA' and  substr(l_c30(i), 8, 1) not in ('0', '1')
                 or l_rec_type = 'FDC' and  substr(l_c30(i), 8, 1) not in ('0', '1', ' ') 
            ) then
                put_error ('wrong c30');
            end if;
            -- settlement date
            if l_rec_type = 'FDA' and l_c32(i) is null then
                put_error ('empty c32');
            end if;
            -- delete duplicated flag
            if l_rec_type = 'FDE' and l_c34(i) not in ('Y', 'N') then
                put_error ('wrong c34'); 
            end if;
            -- acount device type
            if l_rec_type = 'FDA' and l_c44(i) is null then
                put_error ('empty c44');
            end if;

            if l_error_count != 0 then
                trc_log_pkg.error (
                    i_text          => 'MC fraud outgoing error: c03[#1], error_count [#2], error_text [#3]'
                    , i_env_param1  => l_c03(i)
                    , i_env_param2  => l_error_count
                    , i_env_param3  => l_error_text
                );
            end if;
            return l_error_count;
        end;

    begin
        prc_api_stat_pkg.log_start;

        open l_entrys;
        loop
            fetch l_entrys
            bulk collect into
            l_id
            , l_c01, l_c02, l_c03, l_c04, l_c05, l_c06, l_c07, l_c08_10, l_c09
            , l_c11, l_c12, l_c13, l_c14, l_c15, l_c16, l_c17, l_c18, l_c19
            , l_c20, l_c21, l_c22, l_c23, l_c24, l_c25, l_c26, l_c27, l_c28, l_c29
            , l_c30, l_c31, l_c32, l_c33, l_c34, l_c35, l_c36, l_c37, l_c39
            , l_c44, l_c45, l_c46, l_c47, l_c48
            , l_count_all
            , l_count_c02
            , l_record_number_all
            , l_record_number_c02
            , l_rec_error
            limit BULK_LIMIT;

            l_rec_raw.delete;
            l_rec_num.delete;

            for i in 1..l_c02.count loop

                if l_record_number_all(i) = 1 then
                    -- set estimated count
                    prc_api_stat_pkg.log_estimation (
                        i_estimated_count  => l_count_all(i)
                    );
                    -- open file
                    open_file;
                end if;

                if check_error_record(i) > 0 then
                    l_rec_error(i)  := 1;
                    l_error_records := l_error_records + 1;
                else
                    -- put header
                    if ( l_record_number_c02(i) = 1 ) or
                       ( l_record_number_c02(i) <> 1 and l_header_flag = 0 ) then
                        l_processed_count := l_processed_count + 1;

                        l_seq := get_iss_cntrl_num_seq ( i_iss_cntrl_num => l_c02(i) );

                        l_head_str := pad_number(l_c02(i), 7, 7)         -- Issuer Customer number
                                   || pad_number(l_c02(i), 7, 7)         -- transmission id (3 next component)
                                   || l_sysdate_char
                                   || pad_number(to_char(l_seq), 2, 2);

                        l_rec_raw(l_rec_raw.count + 1) := 'FDH'          -- Record Type
                                                       || l_head_str;    -- Issuer Customer number + transmission id

                        l_rec_raw(l_rec_raw.count) := pad_char(l_rec_raw(l_rec_raw.count), 275, 275 );
                        l_rec_num(l_rec_num.count + 1) := l_processed_count;

                        l_c02_count   := 0;                              -- record count for trailer
                        l_header_flag := 1;                              -- put header flag
                    end if;

                    l_processed_count              := l_processed_count + 1;
                    l_rec_raw(l_rec_raw.count + 1) := make_record(i);
                    l_rec_num(l_rec_num.count + 1) := l_processed_count;

                    l_ok_records := l_ok_records + 1;
                    l_c02_count  := l_c02_count + 1;
                end if;

                l_total_records := l_total_records + 1;

                -- put trailer
                if l_record_number_c02(i) = l_count_c02(i) and l_header_flag = 1 then
                    l_processed_count := l_processed_count + 1;

                    l_rec_raw(l_rec_raw.count + 1) := 'FDT'                            -- Record Type
                                                   || l_head_str                       -- Issuer Customer number + transmission id
                                                   || pad_number(l_c02_count, 10, 10)  -- total records
                                                   || pad_number(l_c02_count, 8, 8) ;  -- number of fraud records

                    l_rec_raw(l_rec_raw.count) := pad_char(l_rec_raw(l_rec_raw.count), 275, 275 );
                    l_rec_num(l_rec_num.count + 1) := l_processed_count;
                    l_c02_count   := 0;                              -- record count for trailer
                    l_header_flag := 0;                              -- put header flag
                end if;
            end loop;

            l_current_count := l_current_count + l_id.count;

            -- put file record
            put_file;

            forall i in 1..l_id.count
                update
                    mcw_fraud
                set
                    status = case when l_rec_error(i) = 0
                                  then net_api_const_pkg.CLEARING_MSG_STATUS_UPLOADED  --'CLMS0020'
                                  else net_api_const_pkg.CLEARING_MSG_STATUS_INVALID   --'CLMS0080'
                             end,
                    file_id = case when l_rec_error(i) = 0
                                  then l_session_file_id
                                  else file_id
                    end
                where
                    id = l_id(i);

            prc_api_stat_pkg.log_current (
                i_current_count     => l_ok_records
                , i_excepted_count  => l_error_records
            );

            exit when l_entrys%notfound;
        end loop;
        close l_entrys;

        -- close file
        close_file (
            i_status  => prc_api_const_pkg.FILE_STATUS_ACCEPTED
        );

        trc_log_pkg.info (  --trc_log_pkg.debug (
            i_text          => 'MC fraud outgoing file - total records [#1], processed records [#2], error records [#3]'
            , i_env_param1  => l_total_records
            , i_env_param2  => l_ok_records
            , i_env_param3  => l_error_records
        );

        if l_current_count = 0 then
            prc_api_stat_pkg.log_estimation (
                i_estimated_count  => l_current_count
            );
        end if;

        prc_api_stat_pkg.log_end (
            i_processed_total  => l_ok_records
            , i_excepted_total => l_error_records
            , i_result_code    => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        );
    exception
        when others then
            if l_entrys%isopen then
                close l_entrys;
            end if;

            prc_api_stat_pkg.log_end (
                i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
            );

            close_file (
                i_status => prc_api_const_pkg.FILE_STATUS_REJECTED
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
    end;

end;
/
