create or replace package body emv_api_tag_pkg is
/**********************************************************
 * API for EMV tag <br />
 * Created by Kopachev D.(kopachev@bpcbt.com)  at 15.06.2010 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2010-04-08 17:36:45 +0400$ <br />
 * Revision: $LastChangedRevision: 7636 $ <br />
 * Module: EMV_API_TAG_PKG <br />
 * @headcom
 **********************************************************/

    g_tags                      emv_api_type_pkg.t_emv_tag_tab;

    procedure init_tag_cache is
        l_tags                  emv_api_type_pkg.t_emv_tag2_tab;
    begin
        g_tags.delete;

        select
            id
            , tag
            , min_length
            , max_length
            , data_type
            , data_format
            , default_value
            , tag_type
        bulk collect into
            l_tags
        from
            emv_tag_vw;

        for i in 1 .. l_tags.count loop
            g_tags(l_tags(i).tag) := l_tags(i);
        end loop;
        
        l_tags.delete;
    end;
    
    procedure format_tag_value (
        i_tag                   in     com_api_type_pkg.t_tag
        , io_value              in out com_api_type_pkg.t_param_value
    ) is
        l_tag                   com_api_type_pkg.t_tag;

        procedure check_tag_value_length is
            l_length_bytes           pls_integer;
        begin
            l_length_bytes := nvl(length(io_value), 0) / 2;
            if g_tags(l_tag).min_length != 0 then
                if l_length_bytes < g_tags(l_tag).min_length then
                    com_api_error_pkg.raise_error(
                        i_error        => 'EMV_TAG_MISSES_LENGTH'
                        , i_env_param1 => l_tag
                        , i_env_param2 => l_length_bytes
                        , i_env_param3 => g_tags(l_tag).min_length
                    );
                end if;
            end if;
            if g_tags(l_tag).max_length != 0 then
                if l_length_bytes > g_tags(l_tag).max_length then
                    com_api_error_pkg.raise_error(
                        i_error        => 'EMV_TAG_EXCEEDS_LENGTH'
                        , i_env_param1 => l_tag
                        , i_env_param2 => l_length_bytes
                        , i_env_param3 => g_tags(l_tag).max_length
                    );
                end if;
            end if;
        end;
        
        procedure apply_data_format is
            l_min_length           com_api_type_pkg.t_tiny_id;
            l_pos                  com_api_type_pkg.t_tiny_id;
        begin
            if g_tags(l_tag).data_format is null then
                return;
            end if;
            
            l_pos := instr(g_tags(l_tag).data_format, emv_api_const_pkg.FORMAT_RANGE_INDICATOR);
            case
                when g_tags(l_tag).data_format = emv_api_const_pkg.FORMAT_LOWERCASE then
                    io_value := lower(io_value);
                
                when regexp_like(g_tags(l_tag).data_format, '^\d+$') then
                    case g_tags(l_tag).data_type
                        when emv_api_const_pkg.DATA_TYPE_NUMERIC  then
                            io_value := lpad(io_value, to_number(g_tags(l_tag).data_format), '0');
                        else
                            com_api_error_pkg.raise_error (
                                i_error         => 'EMV_TAG_FORMAT_NOT_SUPPORTED'
                                , i_env_param1  => l_tag
                                , i_env_param2  => g_tags(l_tag).data_format
                            );
                    end case;
                
                when l_pos != 0 and regexp_like(replace(g_tags(l_tag).data_format, emv_api_const_pkg.FORMAT_RANGE_INDICATOR), '^\d+$') then
                    l_min_length := to_number(substr(g_tags(l_tag).data_format, 1, l_pos - 1));
                    if nvl(length(io_value), 0) < l_min_length then
                        case g_tags(l_tag).data_type
                            when emv_api_const_pkg.DATA_TYPE_NUMERIC  then
                                io_value := lpad(io_value, l_min_length, '0');
                            else
                                com_api_error_pkg.raise_error (
                                    i_error         => 'EMV_TAG_FORMAT_NOT_SUPPORTED'
                                    , i_env_param1  => l_tag
                                    , i_env_param2  => g_tags(l_tag).data_format
                                );
                        end case;
                    end if;
              
                when g_tags(l_tag).data_type in( emv_api_const_pkg.DATA_TYPE_DATE_NUMERIC, emv_api_const_pkg.DATA_TYPE_DATE_ALPHA_NUM ) then
                    null;
                
                else
                    com_api_error_pkg.raise_error (
                        i_error         => 'EMV_TAG_FORMAT_NOT_SUPPORTED'
                        , i_env_param1  => l_tag
                        , i_env_param2  => g_tags(l_tag).data_format
                    );
            end case;
        end;

        procedure check_alphanum is
        begin
            if not regexp_like(io_value, '^[A-Za-z0-9]+$') then
                com_api_error_pkg.raise_error(
                    i_error        => 'EMV_DATATYPE_MISMATCH'
                    , i_env_param1 => l_tag
                );
            end if;
            if g_tags(l_tag).data_format is not null then
                case g_tags(l_tag).data_format
                    when emv_api_const_pkg.FORMAT_LOWERCASE  then
                        if lower( io_value ) <> io_value then
                            com_api_error_pkg.raise_error(
                                i_error        => 'EMV_TAG_VALUE_NOT_LOWERCASE'
                                , i_env_param1 => l_tag
                                , i_env_param2 => io_value
                            );
                        end if;
                    else
                        com_api_error_pkg.raise_error (
                            i_error         => 'EMV_TAG_FORMAT_NOT_SUPPORTED'
                            , i_env_param1  => l_tag
                            , i_env_param2  => g_tags(l_tag).data_format
                        );
                end case;
            end if;
        end;
        
        procedure check_alphanum_spec is
        begin
            if not regexp_like(io_value, '^[[:punct:]A-Za-z0-9 ]+$') then
                com_api_error_pkg.raise_error(
                    i_error        => 'EMV_DATATYPE_MISMATCH'
                    , i_env_param1 => l_tag
                );
            end if;
            if g_tags(l_tag).data_format is not null then
              com_api_error_pkg.raise_error (
                  i_error         => 'EMV_TAG_FORMAT_NOT_SUPPORTED'
                  , i_env_param1  => l_tag
                  , i_env_param2  => g_tags(l_tag).data_format
              );
            end if;
        end;
        
        procedure check_numeric is
            l_min_length           com_api_type_pkg.t_tiny_id;
            l_max_length           com_api_type_pkg.t_tiny_id;
            l_pos                  com_api_type_pkg.t_tiny_id;
        begin
            if not regexp_like(io_value, '^\d+$') then
                com_api_error_pkg.raise_error(
                    i_error        => 'EMV_DATATYPE_MISMATCH'
                    , i_env_param1 => l_tag
                );
            end if;
            if g_tags(l_tag).data_format is not null then
                if not regexp_like(replace(g_tags(l_tag).data_format, emv_api_const_pkg.FORMAT_RANGE_INDICATOR), '^\d+$') then
                    com_api_error_pkg.raise_error (
                        i_error         => 'EMV_TAG_FORMAT_NOT_SUPPORTED'
                        , i_env_param1  => l_tag
                        , i_env_param2  => g_tags(l_tag).data_format
                    );
                end if;
                l_pos := instr( g_tags(l_tag).data_format, emv_api_const_pkg.FORMAT_RANGE_INDICATOR );
                if l_pos != 0 then
                    l_min_length := to_number(
                        substr(g_tags(l_tag).data_format, 1, l_pos - 1)
                    );
                    l_max_length := to_number(
                        substr(g_tags(l_tag).data_format, l_pos + length(emv_api_const_pkg.FORMAT_RANGE_INDICATOR) )
                    );
                else
                    l_min_length := to_number(g_tags(l_tag).data_format);
                    l_max_length := to_number(g_tags(l_tag).data_format);
                end if;

                if not nvl(length(io_value), 0) between l_min_length and l_max_length then
                    com_api_error_pkg.raise_error (
                        i_error        => 'EMV_TAG_LENGTH_BAD'
                        , i_env_param1 => l_min_length
                        , i_env_param2 => l_max_length
                    );
                end if;
            end if;
        end;
        
        procedure check_binary is
        begin
            if g_tags(l_tag).data_format is not null then
                com_api_error_pkg.raise_error (
                    i_error         => 'EMV_TAG_FORMAT_NOT_SUPPORTED'
                    , i_env_param1  => l_tag
                    , i_env_param2  => g_tags(l_tag).data_format
                );
            end if;
        end;
        
        procedure check_date is
            l_date                 date;
        begin
            if g_tags(l_tag).data_format is null then
                com_api_error_pkg.raise_error (
                    i_error         => 'EMV_TAG_FORMAT_NOT_SUPPORTED'
                    , i_env_param1  => l_tag
                    , i_env_param2  => g_tags(l_tag).data_format
                );
            end if;
            
            if not regexp_like(io_value, '^\d+$') then
                com_api_error_pkg.raise_error (
                    i_error         => 'EMV_DATATYPE_MISMATCH'
                    , i_env_param1  => l_tag
                );
            end if;
      
            begin
               l_date := to_date( io_value, g_tags(l_tag).data_format );
            exception
                when others then
                    com_api_error_pkg.raise_error(
                        i_error        => 'EMV_INCORRECT_DATE_FORMAT'
                        , i_env_param1 => l_tag
                        , i_env_param2 => g_tags(l_tag).data_format
                    );
            end;
        end;
        
    begin
        l_tag := upper(i_tag);
      
        -- get tag properties
        if not g_tags.exists(l_tag) then
            com_api_error_pkg.raise_error(
                i_error        => 'UNKNOWN_EMV_TAG'
                , i_env_param1 => l_tag
            );
        end if;
        
        -- apply format for dynamic tag
        if g_tags(l_tag).tag_type = emv_api_const_pkg.DATA_TYPE_DYNAMIC then        
            apply_data_format;
        end if;
        
        -- check and convert value
        case g_tags(l_tag).data_type
            when emv_api_const_pkg.DATA_TYPE_ALPHA_NUMERIC then
                check_alphanum;
                io_value := prs_api_util_pkg.bin2hex( io_value );
            
            when emv_api_const_pkg.DATA_TYPE_TEXT then
                check_alphanum_spec;
                io_value := prs_api_util_pkg.bin2hex( io_value );
                
            when emv_api_const_pkg.DATA_TYPE_COMP_NUMERIC then
                check_numeric;
                io_value := rul_api_name_pkg.pad_byte_len (
                    i_src           => io_value
                    , i_pad_type    => rul_api_const_pkg.PAD_TYPE_RIGHT
                    , i_pad_string  => 'F'
                    , i_length      => null
                );
                
            when emv_api_const_pkg.DATA_TYPE_DATE_ALPHA_NUM then
                check_date;
                io_value := prs_api_util_pkg.bin2hex( io_value );
                
            when emv_api_const_pkg.DATA_TYPE_DATE_NUMERIC then
                check_date;
            
            when emv_api_const_pkg.DATA_TYPE_BYTE_HEXADEC then
                check_binary;
            
            when emv_api_const_pkg.DATA_TYPE_DECIMAL then
                check_binary;
                io_value := rul_api_name_pkg.pad_byte_len (
                    i_src           => prs_api_util_pkg.dec2hex(to_number(io_value))
                    , i_pad_type    => rul_api_const_pkg.PAD_TYPE_LEFT
                    , i_length      => g_tags(l_tag).min_length
                );
                
            when emv_api_const_pkg.DATA_TYPE_NUMERIC then
                check_numeric;
                io_value := rul_api_name_pkg.pad_byte_len (
                    i_src           => io_value
                    , i_pad_type    => rul_api_const_pkg.PAD_TYPE_LEFT
                    , i_length      => g_tags(l_tag).min_length
                );

            else
                com_api_error_pkg.raise_error(
                    i_error        => 'UNKNOWN_EMV_DATA_TYPE'
                    , i_env_param1 => l_tag
                    , i_env_param2 => g_tags(l_tag).data_type
                );
        end case;
        
        trc_log_pkg.debug (
            i_text         => 'Tag [#1] formatted value [#2]'
            , i_env_param1 => l_tag
            , i_env_param2 => io_value
        );
        
        if prs_api_util_pkg.is_byte_multiple( io_value ) = com_api_type_pkg.FALSE then
            com_api_error_pkg.raise_error(
                i_error        => 'STRING_NOT_BYTE_MULTIPLE'
                , i_env_param1 => l_tag
                , i_env_param2 => io_value
            );
        end if;
    
        check_tag_value_length;
    exception
        when others then
            trc_log_pkg.debug (
                i_text         => 'Error: [#1]'
                , i_env_param1 => sqlerrm
            );
            raise;
    end;
    
    function get_tag_value (
        i_tag                   in com_api_type_pkg.t_tag
        , i_value               in com_api_type_pkg.t_param_value
        , i_profile             in com_api_type_pkg.t_dict_value
        , i_perso_rec           in prs_api_type_pkg.t_perso_rec
        , i_perso_method        in prs_api_type_pkg.t_perso_method_rec
        , i_perso_data          in prs_api_type_pkg.t_perso_data_rec
    ) return com_api_type_pkg.t_param_value is
        l_tag                   com_api_type_pkg.t_tag;
        l_value                 com_api_type_pkg.t_param_value;
        l_empty_kcv             sec_api_type_pkg.t_check_value;
        l_empty_key             sec_api_type_pkg.t_key_value;
        l_icc_module_length     com_api_type_pkg.t_param_value;
    begin
        trc_log_pkg.debug (
            i_text  => 'Get tag value...'
        );
        
        l_tag := upper(i_tag);

        -- get tag properties
        if not g_tags.exists(l_tag) then
            com_api_error_pkg.raise_error(
                i_error        => 'UNKNOWN_EMV_TAG'
                , i_env_param1 => l_tag
            );
        end if;

        -- calculated tag values
        case l_tag
            -- Track 1 Contactless Data
            when '56'  then
                l_value := i_perso_data.track1_contactless;
                        
            -- Track 2 Equivalent Data
            when '57' then
                l_value := rul_api_name_pkg.pad_byte_len (
                    i_src           => i_perso_data.track2_icc
                    , i_pad_type    => rul_api_const_pkg.PAD_TYPE_RIGHT
                    , i_pad_string  => 'F'
                    , i_length      => null
                );

            -- PAN
            when '5A' then
                l_value := i_perso_rec.card_number;
              
            -- Cardholder Name
            when '5F20' then
                if i_profile in (emv_api_const_pkg.PROFILE_PAYWAVE_QVSDC, emv_api_const_pkg.PROFILE_PAYWAVE_MSD) then
                    l_value := ' /';
                else
                    l_value := i_perso_data.name_on_track1;
                end if;
              
            -- Application Expiration Date
            when '5F24' then
                l_value := to_char(last_day(i_perso_rec.expir_date), g_tags(l_tag).data_format);
              
            -- Application Effective Date
            when '5F25' then
                l_value := to_char(trunc(i_perso_rec.iss_date, 'MM'), g_tags(l_tag).data_format);
  
            -- Service Code
            when '5F30' then
                l_value := nvl(i_perso_method.service_code, '000');
              
            -- PAN Sequence Number
            when '5F34' then
                l_value := to_char(i_perso_rec.seq_number);
              
            -- Application Interchange Profile
            when '82' then
                -- check if 7th bit of most significant byte is on
                /*if i_perso_method.dda_required = com_api_type_pkg.true then
                    if prs_api_util_pkg.hex2dec( rawtohex( utl_raw.bit_and( hextoraw( '4000' ), hextoraw( l_value ) ) ) ) = 0 then
                        trc_log_pkg.debug (
                            i_text          => 'value of tag[#1] does not include dda option'
                            , i_env_param1  => l_tag
                        );
                        return null;
                     end if;
                end if;*/
                null;
              
            -- CA Public Key Index
            when '8F' then
                l_value := prs_api_util_pkg.dec2hex (
                    i_dec_number  => i_perso_data.perso_key.rsa_key.authority_key.key_index
                );
              
            -- IPK Certificate
            when '90' then
                l_value := i_perso_data.perso_key.rsa_key.issuer_certificate.certificate;
              
            -- IPK Remainder
            when '92' then
                l_value := i_perso_data.perso_key.rsa_key.issuer_certificate.reminder;
              
            -- Signed Static Application Data (SAD)
            when '93' then
                if i_perso_data.ssad.exists(i_profile) then
                    l_value := i_perso_data.ssad(i_profile);
                end if;

            -- Application File Locator
            when '94' then
                if i_perso_data.afl_data.exists(i_profile) then
                    l_value := i_perso_data.afl_data(i_profile);
                end if;
                
            -- Cardholder Name Extended
            when '9F0B' then
                if length(i_perso_rec.cardholder_name) > prs_api_const_pkg.NAME_TRACK1_MAX_LEN then
                    l_value := substr(i_perso_rec.cardholder_name, 1, 45);
                end if;
              
            -- Issuer Application Data
            when '9F10' then
                l_value := rul_api_name_pkg.pad_byte_len(i_perso_method.imk_index) || '0A' || '03000000';
                l_value := to_char((length(l_value)/2), 'FM0X') || l_value;
              
            -- Track 1 Discretionary Data
            when '9F1F' then
                l_value := i_perso_data.tr1_discr_data_icc;
                
            -- Track 2 Discretionary Data
            when '9F20' then
                l_value := i_perso_data.tr2_discr_data_icc;
              
            -- IPK exponent
            when '9F32' then
                l_value := i_perso_data.perso_key.rsa_key.issuer_key.exponent;

            -- data authentication code - not support
            when '9F45' then
                return null;
              
            -- ICC Public Key Certificate
            when '9F46' then
                if i_perso_data.icc_rsa_keys.certificate.exists(i_profile) then
                    l_value := i_perso_data.icc_rsa_keys.certificate(i_profile);
                end if;
              
            -- ICC Public Key Exponent
            when '9F47' then
                l_value := '03';
              
            -- ICC Public Key Remainder
            when '9F48' then
                if i_perso_data.icc_rsa_keys.reminder.exists(i_profile) then
                    l_value := i_perso_data.icc_rsa_keys.reminder(i_profile);
                end if;
              
            -- Dynamic Data Authentication Data
            when '9F49' then
                null;
              
            -- PCVC3 Track 1
            when '9F62'  then
                l_value := i_perso_data.track1_bitmask_pcvc3;

            -- PUNATC Track 1 (PayPass) / Offline Counter Initial Value (PayWave)
            when '9F63'  then
                if i_perso_rec.emv_scheme_type = emv_api_const_pkg.EMV_SCHEME_MC then
                    l_value := i_perso_data.track1_bitmask_punatc;
                end if;
            
            -- NATC Track 1
            when '9F64'  then
                l_value := prs_api_util_pkg.dec2hex( i_perso_data.track1_natc );
            
            -- PCVC3 Track 2
            when '9F65'  then
                l_value := i_perso_data.track2_bitmask_pcvc3;
            
            -- PUNATC Track 2
            when '9F66'  then
                l_value := i_perso_data.track2_bitmask_punatc;
            
            -- NATC Track 2 (PayPass) / MSD Offset (PayWave)
            when '9F67'  then
                if i_profile in (emv_api_const_pkg.PROFILE_PAYPASS) then
                    l_value := prs_api_util_pkg.dec2hex( i_perso_data.track2_natc );
                else
                    l_value := i_perso_data.dcvv_track2_pos;
                    if i_perso_data.atc_exist = com_api_type_pkg.TRUE then
                        l_value := l_value + 128;
                    end if;
                    l_value := prs_api_util_pkg.dec2hex( l_value );
                end if;

            -- Track 2 Contactless Data (PayPass)
            when '9F6B'  then
                if i_perso_rec.emv_scheme_type = emv_api_const_pkg.EMV_SCHEME_MC then
                    l_value := i_perso_data.track2_contactless;
                end if;

            -- IVCVC3 Track 1
            when 'DC'  then
              l_value := i_perso_data.track1_ivcvc3;
            
            -- IVCVC3 Track 2
            when 'DD'  then
              l_value := i_perso_data.track2_ivcvc3;
              
            -- Personal Identification Number
            when 'DF20' then
                l_value := i_perso_data.tr_pin_block;
              
            -- KEK KCV
            when 'DF51' then
                l_value := i_perso_data.perso_key.des_key.kek.check_value;
              
            -- PEK KCV
            when 'DF52' then
                l_value := i_perso_data.perso_key.des_key.pek_translation.check_value;
            
            -- IMK version
            when 'DF54' then
                l_value := prs_api_util_pkg.dec2hex (
                    i_dec_number  => i_perso_method.imk_index
                );

            -- ICC derived keys
            when 'DF60' then
                l_empty_kcv := '000000';
                l_empty_key := '0000000000000000';

                l_value := -- keys encryption mode
                           '01'
                        -- kcv mode
                        || '02'
                        -- icc dk ac
                        -- icc dk ac, part a
                        || nvl( substr( i_perso_data.icc_derived_keys.idk_ac.key_value, 1, 16 ), l_empty_key )
                        -- kcv for part a of icc dk ac
                        || l_empty_kcv
                        -- icc dk ac, part b
                        || nvl( substr( i_perso_data.icc_derived_keys.idk_ac.key_value, 17, 16 ), l_empty_key )
                        -- kcv for part b of icc dk ac
                        || nvl( substr( i_perso_data.icc_derived_keys.idk_ac.check_value, 1, 6 ), l_empty_kcv )
                        -- icc dk smc
                        -- icc dk smc, part a
                        || nvl( substr( i_perso_data.icc_derived_keys.idk_smc.key_value, 1, 16 ), l_empty_key )
                           -- kcv for part a of icc dk smc
                        || l_empty_kcv
                        -- icc dk smc, part b
                        || nvl( substr( i_perso_data.icc_derived_keys.idk_smc.key_value, 17, 16 ), l_empty_key )
                        -- kcv for part b of icc dk smc
                        || nvl( substr( i_perso_data.icc_derived_keys.idk_smc.check_value, 1, 6 ), l_empty_kcv )
                        -- icc dk smi
                        -- icc dk smi, part a
                        || nvl( substr( i_perso_data.icc_derived_keys.idk_smi.key_value, 1, 16 ), l_empty_key )
                        -- kcv for part a of icc dk smi
                        || l_empty_kcv
                        -- icc dk smi, part b
                        || nvl( substr( i_perso_data.icc_derived_keys.idk_smi.key_value, 17, 16 ), l_empty_key )
                        -- kcv for part b of icc dk smi
                        || nvl( substr( i_perso_data.icc_derived_keys.idk_smi.check_value, 1, 6 ), l_empty_kcv )
                        -- icc dk idn
                        -- icc dk idn, part a
                        || nvl( substr( i_perso_data.icc_derived_keys.idk_idn.key_value, 1, 16 ), l_empty_key )
                        -- kcv for part a of icc dk idn
                        || l_empty_kcv
                        -- icc dk idn, part b
                        || nvl( substr( i_perso_data.icc_derived_keys.idk_idn.key_value, 17, 16 ), l_empty_key )
                        -- kcv for part b of icc dk idn
                        || nvl( substr( i_perso_data.icc_derived_keys.idk_idn.check_value, 1, 6 ), l_empty_kcv )
                        || case when i_perso_rec.emv_scheme_type in (emv_api_const_pkg.PROFILE_PAYPASS, emv_api_const_pkg.PROFILE_PAYWAVE_MSD) then
                               -- icc cvc3 part a
                               nvl( substr( i_perso_data.icc_derived_keys.idk_cvc3.key_value, 1, 16 ), l_empty_kcv )
                               -- kcv for part a of icc cvc3
                               || l_empty_kcv
                               -- icc cvc3, part b
                               || nvl( substr( i_perso_data.icc_derived_keys.idk_cvc3.key_value, 17, 16 ), l_empty_kcv )
                               -- kcv for part b of icc cvc3
                               || nvl( substr( i_perso_data.icc_derived_keys.idk_cvc3.check_value, 1, 6 ), l_empty_kcv )
                           else
                               ''
                           end
                        ;
            
            -- Company Name
            when 'DF70' then
                l_value := i_perso_rec.company_name;
              
            -- INN
            when 'DF71' then
                null;
              
            -- KPP
            when 'DF72' then
                null;
              
            -- OKPO
            when 'DF73' then
                null;
              
            -- Surname
            when 'DF74' then
                l_value := i_perso_rec.surname;
              
            -- First Name
            when 'DF75' then
                l_value := i_perso_rec.first_name;
              
            -- Second Name
            when 'DF76' then
                l_value := i_perso_rec.second_name;
              
            -- Birth Date
            when 'DF77' then
                l_value := to_char(i_perso_rec.birthday, g_tags(i_tag).data_format);

            -- ID Document Type
            when 'DF78' then
                l_value := i_perso_rec.id_type;
              
            -- ID Document Number
            when 'DF79' then
                l_value := i_perso_rec.id_number;
              
            -- ID Document Series
            when 'DF7A' then
                l_value := i_perso_rec.id_series;
                
            -- ID Document Authority
            when 'DF7B' then
                null;
            
            -- prime p encrypted under kekicc
            when 'DF8001' then
                if i_perso_method.icc_sk_format = prs_api_const_pkg.RSA_FORMAT_CHINESE then
                    l_value := i_perso_data.icc_rsa_keys.private_p;
                elsif i_perso_method.icc_sk_format = prs_api_const_pkg.RSA_FORMAT_EXPT_AND_MODULUS then
                    null;
                else
                    com_api_error_pkg.raise_error (
                        i_error         => 'UNKNOWN_PRIVATE_KEY_FORMAT'
                        , i_env_param1  => i_perso_method.icc_sk_format
                    );
                end if;
                
            -- prime q encrypted under kekicc
            when 'DF8002' then
                if i_perso_method.icc_sk_format = prs_api_const_pkg.RSA_FORMAT_CHINESE then
                    l_value := i_perso_data.icc_rsa_keys.private_q;
                end if;

            -- d mod (p-1) encrypted under kekicc
            when 'DF8003' then
                if i_perso_method.icc_sk_format = prs_api_const_pkg.RSA_FORMAT_CHINESE then
                    l_value := i_perso_data.icc_rsa_keys.private_dp;
                end if;
            
            -- d mod (q-1) encrypted under kekicc
            when 'DF8004' then
                if i_perso_method.icc_sk_format = prs_api_const_pkg.RSA_FORMAT_CHINESE then
                    l_value := i_perso_data.icc_rsa_keys.private_dq;
                end if;
            
            -- modular inverse of q encrypted under kekicc
            when 'DF8005' then
                if i_perso_method.icc_sk_format = prs_api_const_pkg.RSA_FORMAT_CHINESE then
                    l_value := i_perso_data.icc_rsa_keys.private_u;
                end if;
            
            -- exponent encrypted under kekicc
            when 'DF8006' then
                if i_perso_method.icc_sk_format = prs_api_const_pkg.RSA_FORMAT_EXPT_AND_MODULUS then
                    l_value := i_perso_data.icc_rsa_keys.private_exponent;
                end if;
            -- exponent encrypted under kekicc
            when 'DF8007' then
                if i_perso_method.icc_sk_format = prs_api_const_pkg.RSA_FORMAT_EXPT_AND_MODULUS then
                    l_value := i_perso_data.icc_rsa_keys.private_modulus;
                end if;

            -- component encryption algorithm
            when 'DF8011' then
                l_value := case i_perso_data.icc_rsa_keys.encryption_mode
                               when sec_api_const_pkg.ENCRYPTION_METHOD_CBC then '83'
                               when sec_api_const_pkg.ENCRYPTION_METHOD_ECB then '03'
                               else '00'
                           end;

            -- clear component format - first byte contains component length
            when 'DF8012' then
                l_value := case i_perso_data.icc_rsa_keys.clear_comp_format
                               when prs_api_const_pkg.CLEAR_COMP_FMT_ASIS then '00'
                               else '01' -- prs_api_const_pkg.CLEAR_COMP_FMT_LENGTH_IN_1BYTE
                           end;
            
            -- clear component padding - round up to 8 bytes length with '00 00 ...'
            when 'DF8013' then
                l_value := i_perso_data.icc_rsa_keys.clear_comp_padding;

            -- derivation data
            when 'DF8014' then
                if i_perso_data.icc_rsa_keys.derivation_data is not null then
                    l_value := prs_api_util_pkg.ber_tlv_length( i_perso_data.icc_rsa_keys.derivation_data )
                            || i_perso_data.icc_rsa_keys.derivation_data
                            ;
                else
                    l_value := '00';
                end if;
            
            -- icc public key modulus length in bytes
            when 'DF8015' then
                l_icc_module_length := rul_api_name_pkg.pad_byte_len( prs_api_util_pkg.dec2hex(i_perso_method.icc_module_length/8) );
                l_value := l_icc_module_length;

            else
                null;

        end case;
        
        -- tag value defined in database
        if g_tags(l_tag).tag_type <> emv_api_const_pkg.DATA_TYPE_DYNAMIC then
            trc_log_pkg.debug (
                i_text          => 'Getting emv template tag [#1] value'
                , i_env_param1  => l_tag
            );
            
            l_value := i_value;
            
            if l_value is null then
                trc_log_pkg.debug (
                    i_text         => 'Getting tag [#1] default value'
                    , i_env_param1 => l_tag
                );
                if g_tags(l_tag).default_value is null then
                    trc_log_pkg.debug (
                        i_text         => 'Tag [#1] value not found'
                        , i_env_param1 => l_tag
                    );
                    return null;
                end if;
                l_value := g_tags(l_tag).default_value;
            end if;
        end if;

        -- format tag value
        format_tag_value (
            i_tag       => l_tag
            , io_value  => l_value
        );

        /*if l_tag not in ('9F0B', '9F45', '9F48') and l_value is null then
            com_api_error_pkg.raise_error (
                i_error         => 'TAG_ERROR_FORMAT_EMV_TEMPLATE'
                , i_env_param1  => l_tag
            );
        end if;*/

        trc_log_pkg.debug (
            i_text          => 'Tag [#1] value [#2] application scheme id[#3]'
            , i_env_param1  => l_tag
            , i_env_param2  => l_value
            , i_env_param3  => i_perso_rec.emv_appl_scheme_id
        );
        
        return l_value;
    end;

    function extract_tag (
        i_tag_lst               in com_api_type_pkg.t_name
        , i_pos                 in pls_integer
    ) return com_api_type_pkg.t_tag is
        l_curr_pos               pls_integer;
        l_length                 pls_integer;
        l_result                 com_api_type_pkg.t_tag;
        l_curr_body              com_api_type_pkg.t_tag;

        procedure inc_pos is
        begin
            if l_curr_pos - i_pos > 4 then
                com_api_error_pkg.raise_error(
                    i_error        => 'TAG_NAMES_LONGER_2_NOT_SUPPORTED'
                    , i_env_param1 => i_tag_lst
                    , i_env_param2 => i_pos
                );
            end if;
            l_curr_pos := l_curr_pos + 2;
        end;
    begin
        l_curr_pos := i_pos;
        l_length := nvl(length(i_tag_lst), 0);

        loop
            exit when l_curr_pos > l_length;

            l_curr_body := substr(i_tag_lst, l_curr_pos, 2);
            if length(l_curr_body) = 2 then

                l_result := l_result || l_curr_body;
                
                -- check for need to process subsequent bytes
                if l_curr_pos = i_pos
                   and rawtohex(
                           utl_raw.bit_and( hextoraw(l_curr_body), hextoraw('1F') )
                       ) <> '1F'
                then
                    return l_curr_body;
                end if;
            
                -- check successful exit condition
                if l_curr_pos <> i_pos
                   and to_number(l_curr_body, 'FM0X') < 128 then
                    exit;
                end if;
                
                inc_pos;
            
            else
                com_api_error_pkg.raise_error(
                    i_error        => 'PROVIDED_TAG_LIST_NOT_BYTE_MULTIPLE'
                    , i_env_param1 => i_tag_lst
                    , i_env_param2 => i_pos
                );
            end if;
        end loop;

        return l_result;
    exception
        when com_api_error_pkg.e_invalid_number then
            com_api_error_pkg.raise_error(
                i_error        => 'TAG_NAMES_CONTAINS_NON_HEX_CHAR'
                , i_env_param1 => i_tag_lst
            );
    end;

/*
 * Parse EMV data into an associative array.
 * @param i_emv_data    - EMV data
 * @param o_emv_tag_tab - array: tag_value[tag_name]
 * @param i_is_binary   - if this flag is set to TRUE then the parser treats EMV data as a set
                          of HEX digits but not as raw/binary data
 */
    procedure parse_emv_data(
        i_emv_data          in      com_api_type_pkg.t_text
      , o_emv_tag_tab          out  com_api_type_pkg.t_tag_value_tab
      , i_is_binary         in      com_api_type_pkg.t_boolean
      , i_mask_error        in      com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
    ) is 
        l_pos               pls_integer;
        l_emv_length        pls_integer;
        l_length_multiplier pls_integer;
        l_tag_name          com_api_type_pkg.t_tag;
        l_tag_value         com_api_type_pkg.t_param_value;
    begin
        if nvl(i_is_binary, com_api_const_pkg.TRUE) = com_api_const_pkg.TRUE then
            l_emv_length := nvl(lengthb(i_emv_data), 0);
            l_length_multiplier := 2;
            l_pos := 1;
        else
            /*l_emv_length := to_number(substrb(i_emv_data, 1, 4));
            
            if nvl(lengthb(i_emv_data), 0) != (l_emv_length + 4) then
                com_api_error_pkg.raise_error(
                    i_error         => 'EMV_DATA_LENGTH_INCORRECT'
                  , i_env_param1    => length(i_emv_data)
                  , i_env_param2    => (l_emv_length + 4)
                  , i_mask_error    => i_mask_error
                );
            end if;
            l_length_multiplier := 1;
            l_pos := 5;*/

            l_emv_length := nvl(lengthb(i_emv_data), 0);
            l_length_multiplier := 1;
            l_pos := 1;
        end if;

        loop
            exit when l_pos >= nvl(lengthb(i_emv_data), 0);
            
            -- get first 2 char of tag name
            l_tag_name := substrb(i_emv_data, l_pos, 2);
            
            -- if tag name length 4 char
            if l_tag_name in ('9F', '7F', '5F', '3F', '1F') then
                l_tag_name := substrb(i_emv_data, l_pos, 4);
                l_pos := l_pos + 2;
            end if;
            l_pos := l_pos + 2;
            
            l_emv_length := nvl(to_number(substrb(i_emv_data, l_pos, 2), 'XX') * l_length_multiplier, 0);
            l_pos := l_pos + 2;
            
            l_tag_value := substrb(i_emv_data, l_pos, l_emv_length);
            l_pos := l_pos + l_emv_length;
            
            o_emv_tag_tab(l_tag_name) := l_tag_value;
            --dbms_output.put_line(l_tag_name ||' = ' || l_tag_value);
        end loop;
    exception
        when com_api_error_pkg.e_invalid_number or com_api_error_pkg.e_value_error then
            trc_log_pkg.debug(
                i_text => lower($$PLSQL_UNIT) || '.parse_emv_data FAILED: '
                       || 'i_is_binary [' || i_is_binary
                       || '], l_emv_length [' || l_emv_length
                       || '], l_length_multiplier [' || l_length_multiplier
                       || '], l_pos [' || l_pos
                       || '], l_tag_name [' || l_tag_name
                       || '], l_tag_value [' || l_tag_value
            );
            com_api_error_pkg.raise_error(
                i_error         => 'TAG_NAMES_CONTAINS_NON_HEX_CHAR'
              , i_env_param1    => i_emv_data
              , i_mask_error    => i_mask_error
            );
    end parse_emv_data;

    function get_tag_value(
        i_tag               in      com_api_type_pkg.t_tag
      , i_emv_tag_tab       in      com_api_type_pkg.t_tag_value_tab
      , i_mask_error        in      com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
      , i_error_value       in      com_api_type_pkg.t_param_value  default null
    ) return com_api_type_pkg.t_param_value is
    begin
        if i_emv_tag_tab.exists(i_tag) then
            return i_emv_tag_tab(i_tag);
        elsif i_mask_error = com_api_const_pkg.TRUE then
            return i_error_value;
        else
            com_api_error_pkg.raise_error(
                i_error         => 'EMV_TAG_NOT_DEFINED'
              , i_env_param1    => i_tag
            );
        end if;
    end;

/*
 * This procedure logs a collection <i_emv_tag_tab> into the table TRC_LOG when
 * either a currect logging level is set to DEBUG or flag <i_is_debug_only> is set to FALSE.
 */
    procedure dump_tag_table(
        i_emv_tag_tab       in      com_api_type_pkg.t_tag_value_tab
      , i_is_debug_only     in      com_api_type_pkg.t_boolean          default com_api_type_pkg.TRUE
    ) is
        LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.dump_tag_table'; 
        l_index                     com_api_type_pkg.t_name;
    begin
        if  i_is_debug_only = com_api_type_pkg.FALSE
            or
            trc_config_pkg.is_debug = com_api_type_pkg.TRUE
        then
            trc_log_pkg.debug(LOG_PREFIX || ': size = [' || i_emv_tag_tab.count() || '] >>');

            l_index := i_emv_tag_tab.first;
            while l_index is not null loop
                trc_log_pkg.debug('[' || l_index || '] = ' || i_emv_tag_tab(l_index));
                l_index := i_emv_tag_tab.next(l_index);
            end loop;

            trc_log_pkg.debug(LOG_PREFIX || ' <<');
        end if;
    end dump_tag_table;

/*
 * When the parameter is set to TRUE then a string of EMV data is considered as a string of HEX digits.
 * otherwise, it is meant as a raw/binary string,
 * i.e. it may contain HEX digits, numeric symbols or alpha-numeric ones.
 */
    function is_binary
    return com_api_type_pkg.t_boolean
    result_cache
    is
    begin
        return nvl(
                   set_ui_value_pkg.get_system_param_n(i_param_name => 'EMV_TAGS_IS_BINARY')
                 , com_api_type_pkg.FALSE
               );
    end;

/*
 * Function generates a string as a value for DE 55 using an array of EMV tags,
 * the list of required tags is provided (optional) as an incoming parameter;
 * returning value is a HEX-digit string of formatted EMV's data, which is converted to
 * a raw byte string on saving into the table, and on creating field DE55 (or its analog)
 * for outgoing clearing file (by a web saver).
 *
 * When <EMV_TAGS_ARE_BINARY> is TRUE (SVFE2 posting) it means that EMV data in <aut_auth.emv_data>
 * is presented in HEX that should represent (in binary) correct Integrated Circuit Card [ICC] data,
 * so these tags may be used unchanged for DE 55 field (web saver for Mastercard outgoing clearing
 * transcodes HEX string to a binary one and saves it to outgoing file).
 *
 * When <EMV_TAGS_ARE_BINARY> is FALSE (SVFE1 posting) it means that EMV data in <aut_auth.emv_data>
 * is presented in HEX or alpha-numeric format so these tags can't be used unchanged for DE 55 field
 * because in this case DE 55 would be incorrect ICC data. This is why some additional converting
 * is required in according to SVFE1 posting format sepcification.
 *
 * For example, tag 5F2A contains ISO currency code and in according to Mastercard specification
 * for field DE 55 it should consists 5 bytes: 2 byte for tag name, 1 byte for data length, and
 * 2 bytes for currency code itself. For currency code 643 this tag should be the following in
 * HEX-format: 5F2A030283 (0283 is a HEX representation for decimal value 643).
 * otherwise, in case of <EMV_TAGS_ARE_BINARY> is FALSE this tag is presented in <aut_auth.emv_data>
 * as the following string: 5F2A03643 (i.e., '643' here is a symbol notation for decimal integer 643).
 *
 * @param io_emv_tag_tab -
 *     array: io_emv_tag_tab[tag_name] = tag_value
 * @param i_tag_type_tab -
 *     collection of pairs [nam1=tag_name, name=tag_data_format] which serves a dual purposes:
 *     a) it is used as the LIST OF TAGS that should be INCLUDED into outgoing formatted EMV data;
 *     b) when <EMV_TAGS_ARE_BINARY> is FALSE (SVFE1 posting) it is used for detecting data formats
 *        of EMV tags to encode them into binary/HEX form from character one (e.g., for casting
 *        character notation '643' to HEX notaion 0x0283, see example above)
 */
    function format_emv_data(
        io_emv_tag_tab          in out nocopy com_api_type_pkg.t_tag_value_tab
      , i_tag_type_tab          in            emv_api_type_pkg.t_emv_tag_type_tab
    ) return com_api_type_pkg.t_full_desc
    is
        LOG_PREFIX     constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.format_emv_data';
        l_emv_data              com_api_type_pkg.t_full_desc;
        l_is_binary             com_api_type_pkg.t_boolean;
        l_tag_name              com_api_type_pkg.t_tag;
        l_tag_value             com_api_type_pkg.t_param_value;
        l_tag_data_format       com_api_type_pkg.t_dict_value;
        l_tag_hex_length        com_api_type_pkg.t_tiny_id;
    begin
        trc_log_pkg.debug(LOG_PREFIX || ' START: io_emv_tag_tab.count() = ' || io_emv_tag_tab.count());

        dump_tag_table(
            i_emv_tag_tab    => io_emv_tag_tab
          , i_is_debug_only  => com_api_type_pkg.TRUE
        );

        if i_tag_type_tab is null or i_tag_type_tab.count() = 0 then
            -- If the list of required tags is empty, all incoming tags are saved into <l_emv_data>
            trc_log_pkg.debug('i_tag_type_tab is EMPTY');
            for tag in io_emv_tag_tab.first() .. io_emv_tag_tab.last() loop
                l_emv_data := l_emv_data
                           || tag
                           || prs_api_util_pkg.ber_tlv_length(io_emv_tag_tab(tag))
                           || io_emv_tag_tab(tag); -- save tag "as is"
            end loop;
        else
            l_is_binary := is_binary();
            trc_log_pkg.debug(
                i_text       => 'l_is_binary = #1, i_tag_type_tab.count() = #2'
              , i_env_param1 => l_is_binary
              , i_env_param2 => i_tag_type_tab.count()
            );
            for i in i_tag_type_tab.first() .. i_tag_type_tab.last() loop
                begin
                    l_tag_name := i_tag_type_tab(i).name1;

                    if io_emv_tag_tab.exists(l_tag_name) then
                        -- Re-encode tag value in according to its data format if it is required
                        l_tag_data_format := substr(i_tag_type_tab(i).name2, 1, 8);
                        l_tag_hex_length  := null;

                        -- All tags should be presented as HEX digits, save it "as is"
                        if l_is_binary = com_api_type_pkg.TRUE then
                            io_emv_tag_tab(l_tag_name) := io_emv_tag_tab(l_tag_name);
                        -- Otherwise,
                        -- a) tag is presented in alpha-numeric (character) form
                        elsif l_tag_data_format = com_api_const_pkg.DATA_TYPE_CHAR then
                            io_emv_tag_tab(l_tag_name) := rawtohex(utl_raw.cast_to_raw(io_emv_tag_tab(l_tag_name)));
                        -- b) tag is presented in numeric decimal form
                        elsif l_tag_data_format = com_api_const_pkg.DATA_TYPE_NUMBER then
                            -- Get tag length if it is defined
                            begin
                                l_tag_hex_length := substr(i_tag_type_tab(i).name2, 9);
                            exception
                                when com_api_error_pkg.e_value_error then
                                    trc_log_pkg.error(
                                        i_text       => 'INCORRECT_LENGTH_OF_EMG_TAG'
                                      , i_env_param1 => i_tag_type_tab(i).name1
                                      , i_env_param2 => i_tag_type_tab(i).name2
                                    );
                                    l_tag_hex_length := prs_api_util_pkg.ber_tlv_length(io_emv_tag_tab(l_tag_name));
                            end;
                            -- String that represents a decimal number is converted to a hexadecimal string
                            begin
                                io_emv_tag_tab(l_tag_name) := lpad(io_emv_tag_tab(l_tag_name), l_tag_hex_length, '0');
--                                io_emv_tag_tab(l_tag_name) := lpad(to_char(to_number(io_emv_tag_tab(l_tag_name))
--                                                                 , rpad('FM', l_tag_hex_length + 2, 'X'))
--                                                                 , l_tag_hex_length, '0');
                            exception
                                when com_api_error_pkg.e_value_error then
                                    com_api_error_pkg.raise_error(
                                        i_error      => 'INCORRECT_VALUE_IN_DECIMAL_EMG_TAG'
                                      , i_env_param1 => i_tag_type_tab(i).name1
                                      , i_env_param2 => i_tag_type_tab(i).name2
                                      , i_env_param3 => io_emv_tag_tab(l_tag_name)
                                    );
                            end;
                        -- c) tag is presented in hexadecimal form, save it "as is"
                        else
                            io_emv_tag_tab(l_tag_name) := io_emv_tag_tab(l_tag_name);
                        end if;

                        l_emv_data := l_emv_data
                                   || l_tag_name
                                   || coalesce(lpad(l_tag_hex_length / 2, 2, '0')
                                             , prs_api_util_pkg.ber_tlv_length(io_emv_tag_tab(l_tag_name)))
                                   || io_emv_tag_tab(l_tag_name);
                    end if;
                exception
                    when others then
                        trc_log_pkg.debug(
                            i_text       => LOG_PREFIX || ' FAILED: i [#1], l_tag_name [#2], l_tag_data_format [#3]'
                                         || ', l_tag_hex_length [#4], io_emv_tag_tab(l_tag_name) [#5], l_emv_data [#6]'
                          , i_env_param1 => i
                          , i_env_param2 => l_tag_name
                          , i_env_param3 => l_tag_data_format
                          , i_env_param4 => l_tag_hex_length
                          , i_env_param5 => io_emv_tag_tab(l_tag_name)
                          , i_env_param6 => l_emv_data
                        );
                        raise;
                end;
            end loop;
        end if;

        trc_log_pkg.debug(LOG_PREFIX || ' FINISH, EMV data: [' || l_emv_data || ']');

        return l_emv_data;
    end format_emv_data;

begin
    init_tag_cache;
end; 
/
