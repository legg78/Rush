create or replace package body cst_bmed_cbs_files_format_pkg is
/**********************************************************
 * Custom outgoing or input files operations formats for CBS  
 * 
 * Created by Gogolev I.(i.gogolev@bpcbt.com) at 30.01.2017<br />
 * <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: CST_BMED_CBS_FILES_FORMAT_PKG
 * @headcom
 **********************************************************/

CRLF                    constant com_api_type_pkg.t_byte_char     := chr(13)||chr(10);

-- Generate narrative text
function replace_tags_in_label(
    i_label_id                     in com_api_type_pkg.t_short_id
  , i_is_aggregated                in com_api_type_pkg.t_boolean
  , i_sttl_date                    in date
  , i_fee_type                     in com_api_type_pkg.t_dict_value
  , i_count                        in com_api_type_pkg.t_long_id
  , i_card_ending_number           in com_api_type_pkg.t_name            default null
  , i_product_name                 in com_api_type_pkg.t_name            default null
  , i_external_auth_id             in com_api_type_pkg.t_attr_name       default null
  , i_auth_code                    in com_api_type_pkg.t_auth_code       default null
  , i_oper_id                      in com_api_type_pkg.t_long_id         default null
  , i_file_name                    in com_api_type_pkg.t_name            default null
) return com_api_type_pkg.t_text is
    l_lang                       com_api_type_pkg.t_dict_value;
    l_business_day               com_api_type_pkg.t_name;
    l_month_year                 com_api_type_pkg.t_name;
    l_month                      com_api_type_pkg.t_name;
    l_result                     com_api_type_pkg.t_text;
begin
    l_lang   := com_ui_user_env_pkg.get_user_lang;

    l_result := com_api_i18n_pkg.get_text(
                    i_table_name  => 'COM_LABEL'
                  , i_column_name => 'NAME'
                  , i_object_id   => i_label_id
                  , i_lang        => l_lang 
                );

    l_business_day := to_char(i_sttl_date, 'ddmmyy');
    l_result       := replace(l_result,    '<<BUSINESS_DAY>>', l_business_day);

    l_month_year   := to_char(i_sttl_date, 'mmyyyy');
    l_result       := replace(l_result,    '<<MONTH_YEAR>>',   l_month_year);

    l_month        := to_char(i_sttl_date, 'mm');
    l_result       := replace(l_result,    '<<MONTH>>',        l_month);

    if i_count is not null then
        l_result   := replace(l_result,    '<<COUNT>>',        i_count);
    end if;

    if i_card_ending_number is not null
       and i_is_aggregated = com_api_type_pkg.FALSE
    then
        l_result   := replace(l_result,    '<<CARD_ENDING>>',  i_card_ending_number);
    end if;

    if i_fee_type is not null then
        l_result   := replace(l_result,    '<<FEE_TYPE>>',     com_api_dictionary_pkg.get_article_text(i_fee_type, l_lang));
    end if;

    if i_product_name is not null then
        l_result   := replace(l_result,    '<<PRODUCT_NAME>>', i_product_name);
    end if;

    if i_external_auth_id is not null then
        l_result   := replace(l_result,    '<<UTRNNO>>',       substr(i_external_auth_id, -4));
    end if;

    l_result       := replace(l_result,    '<<SYSDATE>>',      to_char(get_sysdate, 'YYMMDD'));

    if i_auth_code is not null then
        l_result   := replace(l_result,    '<<AUTHID>>',       i_auth_code);
    end if;

    if i_oper_id is not null then
        l_result   := replace(l_result,    '<<OPERID>>',       substr(i_oper_id, -10));
    end if;

    if i_file_name is not null then
        l_result   := replace(l_result,    '<<VISA_FILE_NAME>>', i_file_name);
    end if;

    return l_result;
end replace_tags_in_label;

-- Generate row of the CBS outgoing file
function generate_cbs_out_row(
    i_file_type                    in com_api_type_pkg.t_dict_value
  , i_sttl_date                    in date
  , i_account_number               in com_api_type_pkg.t_account_number
  , i_dir_transaction_amount       in com_api_type_pkg.t_byte_char
  , i_transaction_amount           in com_api_type_pkg.t_money
  , i_is_aggregated                in com_api_type_pkg.t_boolean
  , i_record_number                in com_api_type_pkg.t_long_id
  , i_count                        in com_api_type_pkg.t_long_id
  , i_oper_type                    in com_api_type_pkg.t_dict_value      default null
  , i_sttl_type                    in com_api_type_pkg.t_dict_value      default null
  , i_transaction_type             in com_api_type_pkg.t_dict_value      default null
  , i_fee_type                     in com_api_type_pkg.t_dict_value      default null
  , i_oper_id                      in com_api_type_pkg.t_long_id         default null
  , i_posting_date                 in date                               default null
  , i_narrative_text_1             in com_api_type_pkg.t_name            default null
  , i_narrative_text_2             in com_api_type_pkg.t_name            default null
  , i_narrative_text_3             in com_api_type_pkg.t_name            default null
  , i_reference_value              in com_api_type_pkg.t_name            default null
  , i_amount_per_month_acct_curr   in com_api_type_pkg.t_money           default null
  , i_amount_per_month_usd_curr    in com_api_type_pkg.t_money           default null
  , i_amount_per_month_oper_curr   in com_api_type_pkg.t_money           default null
  , i_amount_per_month_lbp_curr    in com_api_type_pkg.t_money           default null
  , i_file_name                    in com_api_type_pkg.t_name            default null
) return com_api_type_pkg.t_name is

    l_posting_date            date := nvl(i_posting_date, i_sttl_date);

    l_narrative_label_id      com_api_type_pkg.t_long_tab;
    l_narrative_label_text    com_api_type_pkg.t_name_tab;
    l_reference_value         com_api_type_pkg.t_name;
    l_result                  com_api_type_pkg.t_name;

    l_row_header              com_api_type_pkg.t_name;
    l_separator               com_api_type_pkg.t_name;
    l_ext_transaction_type    com_api_type_pkg.t_byte_char;
    l_base_equivalent         com_api_type_pkg.t_name;
    l_reference               com_api_type_pkg.t_name;
    l_narrative_1             com_api_type_pkg.t_name;
    l_narrative_2             com_api_type_pkg.t_name;
    l_narrative_3             com_api_type_pkg.t_name;
    l_card_ending_number      com_api_type_pkg.t_name;
    l_product_name            com_api_type_pkg.t_name;
    l_product_id              com_api_type_pkg.t_short_id;
    l_card_number             com_api_type_pkg.t_card_number;
    l_external_auth_id        com_api_type_pkg.t_attr_name;
    l_auth_code               com_api_type_pkg.t_auth_code;
begin
    -- Get narrative templates
    if i_is_aggregated = com_api_type_pkg.FALSE then
        begin
            select narrative_label_1
                 , narrative_label_2
                 , narrative_label_3
                 , reference_value
              into l_narrative_label_id(1)
                 , l_narrative_label_id(2)
                 , l_narrative_label_id(3)
                 , l_reference_value
              from cst_bmed_cbs_narrative
             where file_type         = i_file_type
               and need_aggregate    = com_api_type_pkg.FALSE
               and (oper_type        = i_oper_type        or oper_type        is null)
               and (sttl_type        = i_sttl_type        or sttl_type        is null)
               and (transaction_type = i_transaction_type or transaction_type is null)
               and (fee_type         = i_fee_type         or fee_type         is null or i_fee_type is null);

        exception 
            when no_data_found then
                trc_log_pkg.debug(
                    i_text        => 'Narrative is not found: i_oper_type [#1], i_sttl_type [#2], i_transaction_type [#3], i_fee_type [#4]'
                  , i_env_param1  => i_oper_type
                  , i_env_param2  => i_sttl_type
                  , i_env_param3  => i_transaction_type
                  , i_env_param4  => i_fee_type
                );

                l_narrative_label_id(1) := null;
                l_narrative_label_id(2) := null;
                l_narrative_label_id(3) := null;
                l_reference_value       := null;     
        end;       

        -- Get card ending number
        if i_oper_id is not null then
            select max(oc.card_number)
              into l_card_number
              from opr_card oc
             where oc.oper_id          = i_oper_id
               and oc.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER;

            l_card_ending_number := substr(iss_api_token_pkg.decode_card_number(i_card_number => l_card_number), -4);

            select max(product_id)
              into l_product_id
              from prd_contract    pc
                 , iss_card        ic
                 , iss_card_number cn
             where reverse(cn.card_number) = reverse(l_card_number)
               and ic.id = cn.card_id
               and pc.id = ic.contract_id;

            l_product_name := com_api_i18n_pkg.get_text(
                                  i_table_name  => 'PRD_PRODUCT'
                                , i_column_name => 'LABEL'
                                , i_object_id   => l_product_id
                              );

            select max(a.external_auth_id)
              into l_external_auth_id
              from aut_auth a
             where a.id in (select match_id from opr_operation where id = i_oper_id);

            select max(auth_code)
              into l_auth_code
              from opr_participant
             where oper_id = i_oper_id
               and participant_type = com_api_const_pkg.PARTICIPANT_ISSUER;
        end if;

        trc_log_pkg.debug(
            i_text        => 'Before replace UTRNNO [#1], VISA_FILE_NAME [#2]'
          , i_env_param1  => l_external_auth_id
          , i_env_param2  => i_file_name
        );
        -- Get narrative text
        for i in 1 .. 3 loop
            if l_narrative_label_id(i) is not null then
                l_narrative_label_text(i) := replace_tags_in_label(
                                                 i_label_id           => l_narrative_label_id(i)
                                               , i_is_aggregated      => i_is_aggregated
                                               , i_sttl_date          => i_sttl_date
                                               , i_fee_type           => i_fee_type
                                               , i_count              => i_count
                                               , i_card_ending_number => l_card_ending_number
                                               , i_product_name       => l_product_name
                                               , i_external_auth_id   => l_external_auth_id
                                               , i_auth_code          => l_auth_code
                                               , i_oper_id            => i_oper_id
                                               , i_file_name          => i_file_name
                                             );
            else 
                l_narrative_label_text(i) := null;
            end if;
            trc_log_pkg.debug(
                i_text        => 'After replace narrative_label_text [#1]'
              , i_env_param1  => l_narrative_label_text(i)
            );
        end loop;
        -- Get reference text
        l_reference_value := replace_tags_in_reference(
                                 i_reference   => l_reference_value
                               , i_sysdate     => get_sysdate()
                               , i_auth_code   => l_auth_code
                               , i_oper_id     => i_oper_id
                               , i_file_name   => i_file_name
                             );
        trc_log_pkg.debug(
            i_text        => 'After replace reference_value [#1]'
          , i_env_param1  => l_reference_value
        );

    else
        trc_log_pkg.debug(
            i_text        => 'Before replace VISA_FILE_NAME [#1]'
          , i_env_param1  => i_file_name
        );
        if i_file_name is not null then
            l_narrative_label_text(1)  := replace(i_narrative_text_1, '<<VISA_FILE_NAME>>', i_file_name);
            l_narrative_label_text(2)  := replace(i_narrative_text_2, '<<VISA_FILE_NAME>>', i_file_name);
            l_narrative_label_text(3)  := replace(i_narrative_text_3, '<<VISA_FILE_NAME>>', i_file_name);
        else
            l_narrative_label_text(1)  := i_narrative_text_1;
            l_narrative_label_text(2)  := i_narrative_text_2;
            l_narrative_label_text(3)  := i_narrative_text_3;
        end if;
        -- Get reference text
        l_reference_value := replace_tags_in_reference(
                                 i_reference   => i_reference_value
                               , i_sysdate     => get_sysdate()
                               , i_auth_code   => null
                               , i_oper_id     => null
                               , i_file_name   => i_file_name
                             );
        trc_log_pkg.debug(
            i_text        => 'After replace reference_value [#1]'
          , i_env_param1  => l_reference_value
        );

    end if;

    -- Calculate columns according file type
    if i_file_type    = cst_bmed_api_const_pkg.FREE_GATEWAY_FILE_TYPE then
        l_row_header           := 'GW';
        l_separator            := '|';
        l_ext_transaction_type := '50';
        l_base_equivalent      := i_dir_transaction_amount || lpad(nvl(i_amount_per_month_lbp_curr, 0), 15, '0');
        l_reference            := rpad(nvl(l_reference_value, ' '), 10, ' ');

        l_narrative_label_text(1) := replace(l_narrative_label_text(1), '<<COUNT>>', i_count);
        l_narrative_label_text(2) := replace(l_narrative_label_text(2), '<<COUNT>>', i_count);
        l_narrative_label_text(3) := replace(l_narrative_label_text(3), '<<COUNT>>', i_count);

        l_narrative_label_text(1) := replace(l_narrative_label_text(1), '<<AMOUNT_PER_MONTH_ACCT_CURR>>', i_amount_per_month_acct_curr);
        l_narrative_label_text(2) := replace(l_narrative_label_text(2), '<<AMOUNT_PER_MONTH_ACCT_CURR>>', i_amount_per_month_acct_curr);
        l_narrative_label_text(3) := replace(l_narrative_label_text(3), '<<AMOUNT_PER_MONTH_ACCT_CURR>>', i_amount_per_month_acct_curr);

        l_narrative_label_text(1) := replace(l_narrative_label_text(1), '<<AMOUNT_PER_MONTH_USD_CURR>>', i_amount_per_month_usd_curr);
        l_narrative_label_text(2) := replace(l_narrative_label_text(2), '<<AMOUNT_PER_MONTH_USD_CURR>>', i_amount_per_month_usd_curr);
        l_narrative_label_text(3) := replace(l_narrative_label_text(3), '<<AMOUNT_PER_MONTH_USD_CURR>>', i_amount_per_month_usd_curr);

        l_narrative_label_text(1) := replace(l_narrative_label_text(1), '<<AMOUNT_PER_MONTH_OPER_CURR>>', i_amount_per_month_oper_curr);
        l_narrative_label_text(2) := replace(l_narrative_label_text(2), '<<AMOUNT_PER_MONTH_OPER_CURR>>', i_amount_per_month_oper_curr);
        l_narrative_label_text(3) := replace(l_narrative_label_text(3), '<<AMOUNT_PER_MONTH_OPER_CURR>>', i_amount_per_month_oper_curr);

        l_narrative_1          := rpad(nvl(l_narrative_label_text(1), ' '), 25, ' ');
        l_narrative_2          := rpad(nvl(l_narrative_label_text(2), ' '), 25, ' ');
        l_narrative_3          := rpad(nvl(l_narrative_label_text(3), ' '), 25, ' ');

    elsif i_file_type = cst_bmed_api_const_pkg.MONTHLY_FEE_FILE_TYPE then
        l_row_header           := rpad(' ', 2, ' ');
        l_separator            := ' ';
        l_ext_transaction_type := '30';
        l_base_equivalent      := i_dir_transaction_amount || lpad(nvl(i_amount_per_month_lbp_curr, 0), 15, '0');
        l_reference            := rpad(nvl(l_reference_value,         ' '), 10, ' ');
        l_narrative_1          := rpad(nvl(l_narrative_label_text(1), ' '), 25, ' ');
        l_narrative_2          := rpad('XXXXXX' || l_card_ending_number,    25, ' ');
        l_narrative_3          := rpad(nvl(l_narrative_label_text(3), ' '), 25, ' ');

    elsif i_file_type = cst_bmed_api_const_pkg.RECHARGE_GATEWAY_FILE_TYPE then
        l_row_header           := rpad(' ', 2, ' ');
        l_separator            := ' ';
        l_ext_transaction_type := '36';
        l_base_equivalent      := i_dir_transaction_amount || lpad(nvl(i_amount_per_month_lbp_curr, 0), 15, '0');

        -- Bank insists on keeping it the same logic. Example: 1111111110, 2222222220, etc.
        -- If row number is "1378" then "l_reference" equal to "1378137810".
        l_reference            := lpad('0', 10, trim(to_char(i_record_number)));

        -- Replace the total number of records used to calculate aggregated amount for the record account.
        -- For example: "20ATM Alfa Recharge      "
        l_narrative_label_text(1) := replace(l_narrative_label_text(1), '<<COUNT>>', i_count);

        l_narrative_1          := rpad(nvl(l_narrative_label_text(1), ' '), 25, ' ');
        l_narrative_2          := rpad(nvl(l_narrative_label_text(2), ' '), 25, ' ');
        l_narrative_3          := rpad(nvl(l_narrative_label_text(3), ' '), 25, ' ');

    end if;

    trc_log_pkg.debug(
        i_text        => 'Fill row reference_value [#1], narrative_1 [#2], narrative_2 [#3], narrative_3 [#4]'
      , i_env_param1  => l_reference
      , i_env_param2  => l_narrative_1
      , i_env_param3  => l_narrative_2
      , i_env_param4  => l_narrative_3
    );
    -- Get result row
    l_result :=
        l_row_header
     || l_separator || lpad(i_account_number, 13, '0')
     || l_separator || l_ext_transaction_type
     || l_separator || i_dir_transaction_amount || lpad(i_transaction_amount, 15, '0')
     || l_separator || to_char(l_posting_date, 'ddmmyyyy')
     || l_separator || rpad(' ', 8, ' ')
     || l_separator || l_base_equivalent
     || l_separator || l_reference
     || l_separator || l_narrative_1
     || l_separator || l_narrative_2
     || l_separator || l_narrative_3
     || l_separator || '0' || CRLF
    ;
        
    return l_result;
            
end generate_cbs_out_row;
   
-- Generate full CBS outgoing file
procedure generate_cbs_out_file(
    io_body_tab      in out nocopy cst_bmed_type_pkg.t_cbs_outg_file_body
  , o_file_content      out nocopy clob
) is
begin
    if io_body_tab.count = 0
    then
        o_file_content := empty_clob();
        return;
    end if;
    
    for i in io_body_tab.first .. io_body_tab.last
    loop
        if io_body_tab(i) is not null then        
            if o_file_content is null then
                o_file_content := to_clob(io_body_tab(i));
            else
                dbms_lob.append(o_file_content, to_clob(io_body_tab(i)));
            end if;
        end if;
    end loop;
    
    return;

end generate_cbs_out_file;

-- Generate reference text
function replace_tags_in_reference(
    i_reference                    in com_api_type_pkg.t_name
  , i_sysdate                      in date                               default null
  , i_auth_code                    in com_api_type_pkg.t_auth_code       default null
  , i_oper_id                      in com_api_type_pkg.t_long_id         default null
  , i_file_name                    in com_api_type_pkg.t_name            default null
) return com_api_type_pkg.t_name is
    l_sysdate                    com_api_type_pkg.t_name;
    l_result                     com_api_type_pkg.t_name;
begin
    l_result := i_reference;
    if i_sysdate is not null then
        l_sysdate := to_char(i_sysdate, 'yymmdd');
        l_result  := replace(l_result, '<<SYSDATE>>', l_sysdate);
    end if;
    if i_auth_code is not null then
        l_result  := replace(l_result, '<<AUTHID>>', i_auth_code);
    end if;
    if i_oper_id is not null then
        l_result  := replace(l_result, '<<OPERID>>', substr(to_char(i_oper_id), -10));
    end if;
    if i_file_name is not null then
        l_result   := replace(l_result, '<<VISA_FILE_NAME>>', i_file_name);
    end if;
    
    return substr(l_result, 1, 10);
end replace_tags_in_reference;

end cst_bmed_cbs_files_format_pkg;
/
