create or replace package body aci_api_token_pkg is
/************************************************************
 * Base24 token API <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 18.03.2014 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: aci_api_token_pkg <br />
 * @headcom
 ************************************************************/

    procedure set_tokens (
        i_raw_data                in com_api_type_pkg.t_raw_data
        , o_token_tab             out aci_api_type_pkg.t_token_tab
    ) is
        l_raw_data                com_api_type_pkg.t_raw_data;
        l_token_rec               aci_api_type_pkg.t_token_rec;
        l_length                  number := null;
        l_stage                   com_api_type_pkg.t_name;
    begin
        l_stage := 'set tokens';
        
        l_raw_data := trim(i_raw_data);
                    
        l_length := instr(l_raw_data, '!', 1);
        if l_length = 0 then
            return;
        end if;
        
        l_raw_data := substr(l_raw_data, l_length);
        loop
            exit when nvl(length(l_raw_data), 0) = 0;
            
            l_token_rec := null;
            
            l_stage := 'get token name';
            l_token_rec.name := aci_api_util_pkg.get_field_char (
                i_raw_data     => l_raw_data
                , i_start_pos  => 3
                , i_length     => 2
            );
            l_stage := 'get token length';
            l_length := aci_api_util_pkg.get_field_number (
                i_raw_data     => l_raw_data
                , i_start_pos  => 5
                , i_length     => 5
            );
            l_stage := 'get token value';
            l_token_rec.value := aci_api_util_pkg.get_field_char (
                i_raw_data     => l_raw_data
                , i_start_pos  => 11
                , i_length     => l_length
            );
            
            o_token_tab(o_token_tab.count+1) := l_token_rec;
            
            l_raw_data := substr(l_raw_data, 11 + l_length);
        end loop;
    exception
        when others then
            trc_log_pkg.debug (
                i_text          => 'Error processing tokens on stage [#1] :[#2]'
                , i_env_param1  => l_stage
                , i_env_param2  => sqlerrm
            );
            raise;
    end;
    
    procedure put_tokens (
        i_id                      in com_api_type_pkg.t_long_id
        , i_token_tab            in aci_api_type_pkg.t_token_tab
    ) is
    begin
        forall i in 1 .. i_token_tab.count
            insert into aci_token (
                id
                , name
                , value
            ) values (
                i_id
                , i_token_tab(i).name
                , i_token_tab(i).value
            );
    exception
        when others then
            trc_log_pkg.debug (
                i_text          => 'Save tokens [#1]'
                , i_env_param1  => sqlerrm
            );
            raise;
    end;
    
    procedure collect_tokens (
        i_id                     in com_api_type_pkg.t_long_id
        , o_token_tab            out aci_api_type_pkg.t_token_tab
    ) is
    begin
        select
            id
            , name
            , value
        bulk collect into
            o_token_tab
        from
            aci_token
        where
            id = i_id;
    exception
        when others then
            trc_log_pkg.debug (
                i_text          => 'Collect tokens [#1]'
                , i_env_param1  => sqlerrm
            );
            raise;
    end;
    
    procedure create_tokens (
        i_id                      in com_api_type_pkg.t_long_id
        , i_raw_data              in com_api_type_pkg.t_raw_data
        , o_token_tab             out aci_api_type_pkg.t_token_tab
    ) is
    begin
        -- set tokens
        set_tokens (
            i_raw_data     => i_raw_data
            , o_token_tab  => o_token_tab
        );

        -- put tokens
        put_tokens (
            i_id           => i_id
            , i_token_tab  => o_token_tab
        );
    end;
    
    function format_emv_data (
        i_token_tab               in aci_api_type_pkg.t_token_tab
    ) return com_api_type_pkg.t_text is
        l_result                  com_api_type_pkg.t_text;
        
        l_value                   com_api_type_pkg.t_param_value;
        
        l_pos                     binary_integer;
        
        l_bitmask                 binary_integer := 0;
        
        l_tag_b2                  aci_api_type_pkg.t_tag_tab;
        l_tag_b3                  aci_api_type_pkg.t_tag_tab;
        
        l_stage                   com_api_type_pkg.t_name;
        
        function bit_and (
            bit             in binary_integer
        ) return binary_integer is
        begin
            return bitand(l_bitmask, power(2, 16 - bit));
        end;
  
        procedure init_tags is
        begin
            l_tag_b2(1).length := 4;   l_tag_b2(1).tag := '';
            l_tag_b2(2).length := 2;   l_tag_b2(2).tag := '9F27';
            l_tag_b2(3).length := 10;  l_tag_b2(3).tag := '95';
            l_tag_b2(4).length := 16;  l_tag_b2(4).tag := '9F26';
            l_tag_b2(5).length := 12;  l_tag_b2(5).tag := '9F02';
            l_tag_b2(6).length := 12;  l_tag_b2(6).tag := '9F03';
            l_tag_b2(7).length := 4;   l_tag_b2(7).tag := '82';
            l_tag_b2(8).length := 4;   l_tag_b2(8).tag := '9F36';
            l_tag_b2(9).length := 3;   l_tag_b2(9).tag := '9F1A';
            l_tag_b2(10).length := 3;  l_tag_b2(10).tag := '5F2A';
            l_tag_b2(11).length := 6;  l_tag_b2(11).tag := '9A';
            l_tag_b2(12).length := 2;  l_tag_b2(12).tag := '9C';
            l_tag_b2(13).length := 8;  l_tag_b2(13).tag := '9F37';
            l_tag_b2(14).length := 0;  l_tag_b2(14).tag := '';
            l_tag_b2(15).length := 0;  l_tag_b2(15).tag := '';
            l_tag_b2(16).length := 64; l_tag_b2(16).tag := '9F10';
            
            l_tag_b3(1).length := 8;  l_tag_b3(1).tag := '9F1E';
            l_tag_b3(2).length := 8;  l_tag_b3(2).tag := '9F33';
            l_tag_b3(3).length := 4;  l_tag_b3(3).tag := '';
            l_tag_b3(4).length := 8;  l_tag_b3(4).tag := '';
            l_tag_b3(5).length := 2;  l_tag_b3(5).tag := '9F35';
            l_tag_b3(6).length := 4;  l_tag_b3(6).tag := '9F09';
            l_tag_b3(7).length := 6;  l_tag_b3(7).tag := '9F34';
            l_tag_b3(8).length := 32; l_tag_b3(8).tag := '84';
        end;
    begin
        l_stage := 'init tags';
        init_tags;
        
        for i in 1..i_token_tab.count loop
            
            case i_token_tab(i).name
            when 'B2' then
                l_stage := 'process B2 token';
                l_pos := 1;
                l_stage := 'bitmask';
                l_bitmask := utl_raw.cast_to_binary_integer(substr(i_token_tab(i).value, l_pos, 4));
                l_pos := l_pos + 4;
            
                for j in 1..l_tag_b2.count loop
                    if bit_and(j) > 0 then
                        if j = 16 then
                            l_tag_b2(j).length := to_number(substr(i_token_tab(i).value, l_pos, 4),'XXXX') * 2;
                            l_pos := l_pos + 4;
                        end if;
                        l_stage := 'B2 token: tag value';
                        l_value := substr(i_token_tab(i).value, l_pos, l_tag_b2(j).length);
                        l_stage := 'B2 token: check multiple';
                        if prs_api_util_pkg.is_byte_multiple( l_value ) = com_api_type_pkg.FALSE then
                            l_value := '0' || l_value;
                        end if;
                        l_stage := 'B2 token: set tag and value';
                        if l_tag_b2(j).tag is not null then
                            l_result := l_result || l_tag_b2(j).tag || prs_api_util_pkg.ber_tlv_length(l_value) || l_value;
                        end if;
                    end if;
                    l_stage := 'B2 token: next pos';
                    l_pos := l_pos + l_tag_b2(j).length;
                end loop;

            when 'B3' then
                l_stage := 'process B3 token';
                l_pos := 1;
                l_stage := 'B3 token: bitmask';
                l_bitmask := utl_raw.cast_to_binary_integer(substr(i_token_tab(i).value, l_pos, 4));
                l_pos := l_pos + 4;
                
                for j in 1..l_tag_b3.count loop
                    if bit_and(j) > 0 or l_tag_b3(j).tag = '9F09' then
                        if j = 8 then
                            l_pos := l_pos + 4;
                        end if;
                        l_stage := 'B3 token: tag value';
                        l_value := substr(i_token_tab(i).value, l_pos, l_tag_b3(j).length);
                        if l_tag_b3(j).tag = '9F09' and l_value is null then
                            null;
                        else
                            if l_tag_b3(j).tag = '9F33' then
                                l_value := substr(l_value, 1, 6);
                            end if;
                            l_stage := 'B3 token: check multiple';
                            if prs_api_util_pkg.is_byte_multiple( l_value ) = com_api_type_pkg.FALSE then
                                l_value := '0' || l_value;
                            end if;
                            l_stage := 'B3 token: set tag and value';
                            if l_tag_b3(j).tag is not null then
                                l_result := l_result || l_tag_b3(j).tag || prs_api_util_pkg.ber_tlv_length(l_value) || l_value;
                            end if;
                        end if;
                    end if;
                    l_stage := 'B3 token: next pos';
                    l_pos := l_pos + l_tag_b3(j).length;
                end loop;

            else
                null;
            end case;
        end loop;
        
        if l_result is not null then
            l_result := l_result || '9F53' || prs_api_util_pkg.ber_tlv_length('5A') || '5A';
        end if;
        
        return l_result;
    exception
        when others then
            trc_log_pkg.debug (
                i_text          => 'Error format emv data on stage [#1] :[#2]'
                , i_env_param1  => l_stage
                , i_env_param2  => sqlerrm
            );
            raise;
    end;
    
    procedure get_c_params (
        i_token_tab               in aci_api_type_pkg.t_token_tab
        , io_crdh_presence        in out com_api_type_pkg.t_dict_value
        , io_card_presence        in out com_api_type_pkg.t_dict_value
        , io_cvv2_presence        in out com_api_type_pkg.t_dict_value
        , io_ucaf_indicator       in out com_api_type_pkg.t_dict_value
        , io_cat_level            in out com_api_type_pkg.t_dict_value
        , io_card_data_input_cap  in out com_api_type_pkg.t_dict_value
        , io_ecommerce_indicator  in out com_api_type_pkg.t_dict_value
    ) is
        l_value                   com_api_type_pkg.t_param_value;
        l_stage                   com_api_type_pkg.t_name;
    begin
        for i in 1..i_token_tab.count loop
            case i_token_tab(i).name
            when 'C0' then
                l_value := aci_api_util_pkg.get_field_char (
                    i_raw_data     => i_token_tab(i).value
                    , i_start_pos  => 22
                    , i_length     => 1
                );
                io_cvv2_presence := 'CV2P000' ||
                case
                when l_value in ('0', '3') then '2'
                when l_value in ('1') then '1'
                when l_value in ('2') then '3'
                when l_value in ('9') then '4'
                else '0'
                end;
                
                l_value := aci_api_util_pkg.get_field_char (
                    i_raw_data     => i_token_tab(i).value
                    , i_start_pos  => 24
                    , i_length     => 1
                );
                io_ucaf_indicator := 'CV2P000' || l_value;
                
                io_ecommerce_indicator := aci_api_util_pkg.get_field_char (
                    i_raw_data     => i_token_tab(i).value
                    , i_start_pos  => 19
                    , i_length     => 1
                );
                
            when 'C4' then
                
                l_value := substr(i_token_tab(i).value, 4, 1);
                if l_value is not null then
                    io_crdh_presence := 'F225000' ||
                    case
                    when l_value in ('0', '1', '2', '3', '4', '5') then l_value
                    else '9'
                    end;
                end if;
                
                l_value := substr(i_token_tab(i).value, 5, 1);
                if l_value is not null then
                    io_card_presence := 'F226000' ||
                    case
                    when l_value in ('0', '1') then l_value
                    else '9'
                    end;
                end if;
                
                l_value := substr(i_token_tab(i).value, 10, 1);
                if l_value is not null then
                    io_cat_level := 'F22D000' || l_value;
                end if;
                
                l_value := substr(i_token_tab(i).value, 11, 1);
                io_card_data_input_cap := case
                                              when l_value in ('0') then 'F2210000'
                                              when l_value in ('1') then 'F2210001'
                                              when l_value in ('2') then 'F2210002'
                                              when l_value in ('3') then 'F221000M'
                                              when l_value in ('4') then 'F221000A'
                                              when l_value in ('5') then 'F221000D'
                                              when l_value in ('6') then 'F2210006'
                                              when l_value in ('7') then 'F221000B'
                                              when l_value in ('8') then 'F221000C'
                                              when l_value in ('9') then 'F2210005'
                                              else io_card_data_input_cap
                                          end;
                
            else
                null;
            end case;
        end loop;
    exception
        when others then
            trc_log_pkg.debug (
                i_text          => 'Error get params from tokens c0, c4 on stage [#1] :[#2]'
                , i_env_param1  => l_stage
                , i_env_param2  => sqlerrm
            );
            raise;
    end;
    
    procedure get_b4_params (
        i_token_tab               in aci_api_type_pkg.t_token_tab
        , i_pin_present           in com_api_type_pkg.t_boolean
        , i_cat_level             in com_api_type_pkg.t_dict_value
        , i_iss_inst_id           in com_api_type_pkg.t_dict_value
        , io_pos_entry_mode       in out com_api_type_pkg.t_country_code
        , o_crdh_auth_method      out com_api_type_pkg.t_dict_value
        , o_crdh_auth_entity      out com_api_type_pkg.t_dict_value
        , o_card_seq_number       out com_api_type_pkg.t_tiny_id
    ) is
        l_value                   com_api_type_pkg.t_param_value;
        l_stage                   com_api_type_pkg.t_name;
    begin
        for i in 1..i_token_tab.count loop
            case i_token_tab(i).name
            when 'B4' then
                
                if io_pos_entry_mode is null then
                    io_pos_entry_mode := aci_api_util_pkg.get_field_char (
                        i_raw_data     => i_token_tab(i).value
                        , i_start_pos  => 1
                        , i_length     => 3
                    );
                end if;
                
                l_value := aci_api_util_pkg.get_field_char (
                    i_raw_data     => i_token_tab(i).value
                    , i_start_pos  => 9
                    , i_length     => 2
                );
                l_value := substr(lpad(aci_api_util_pkg.dec2bin(prs_api_util_pkg.hex2dec(l_value)), 8, '0'), 3);
                case
                when substr(io_pos_entry_mode, 1, 2) in ('02', '90', '91') then
                    if i_pin_present = com_api_type_pkg.TRUE then
                        o_crdh_auth_method := 'F2280001';
                        o_crdh_auth_entity := 'F2290003';
                    elsif i_cat_level in ('F22D0002', 'F22D0003', 'F22D0004') then
                        o_crdh_auth_method := 'F2280000';
                        o_crdh_auth_entity := 'F2290000';
                    else
                        o_crdh_auth_method := 'F2280005';
                        o_crdh_auth_entity := 'F2290004';
                    end if;
                when substr(io_pos_entry_mode, 1, 2) in ('05') then
                    if i_pin_present = com_api_type_pkg.TRUE and (l_value in ('000010') or l_value is null) then
                        o_crdh_auth_method := 'F2280001';
                        o_crdh_auth_entity := 'F2290003';
                    elsif i_pin_present = com_api_type_pkg.TRUE and l_value in ('000001', '000011', '000100', '000101') then
                        o_crdh_auth_method := 'F2280001';
                        o_crdh_auth_entity := 'F2290001';
                    elsif i_pin_present = com_api_type_pkg.FALSE and (l_value in ('011110') or l_value is null) then
                        o_crdh_auth_method := 'F2280005';
                        o_crdh_auth_entity := 'F2290004';
                    elsif i_pin_present = com_api_type_pkg.FALSE and l_value in ('111111') then
                        o_crdh_auth_method := 'F2280000';
                        o_crdh_auth_entity := 'F2290000';
                    else
                        o_crdh_auth_method := 'F2280009';
                        o_crdh_auth_entity := 'F2290009';
                    end if;
                when substr(io_pos_entry_mode, 1, 2) in ('07') then
                    if i_pin_present = com_api_type_pkg.TRUE and l_value in ('000010') then
                        o_crdh_auth_method := 'F2280001';
                        o_crdh_auth_entity := 'F2290003';
                    elsif i_pin_present = com_api_type_pkg.FALSE and l_value in ('011110', '111111') then
                        o_crdh_auth_method := 'F2280005';
                        o_crdh_auth_entity := 'F2290004';
                    elsif i_pin_present = com_api_type_pkg.FALSE and l_value in ('011111') then
                        o_crdh_auth_method := 'F2280000';
                        o_crdh_auth_entity := 'F2290000';
                    else
                        o_crdh_auth_method := 'F2280009';
                        o_crdh_auth_entity := 'F2290009';
                    end if;
                else
                    o_crdh_auth_method := 'F2280009';
                    o_crdh_auth_entity := 'F2290009';
                end case;
                
                o_card_seq_number := aci_api_util_pkg.get_field_number (
                    i_raw_data     => i_token_tab(i).value
                    , i_start_pos  => 7
                    , i_length     => 2
                );
                if nvl(o_card_seq_number, 0) = 0 and i_iss_inst_id not in (aci_api_const_pkg.INTERFACE_BNET) then
                    o_card_seq_number := null;
                end if;
               
            else
                null;
            end case;
        end loop;
    exception
        when others then
            trc_log_pkg.debug (
                i_text          => 'Error get params from tokens b4 on stage [#1] :[#2]'
                , i_env_param1  => l_stage
                , i_env_param2  => sqlerrm
            );
            raise;
    end;
    
    procedure get_be_params (
        i_token_tab               in aci_api_type_pkg.t_token_tab
        , o_oper_amount           out com_api_type_pkg.t_money
        , o_oper_currency         out com_api_type_pkg.t_curr_code
        , o_oper_cashback_amount  out com_api_type_pkg.t_money
    ) is
        l_stage                   com_api_type_pkg.t_name;
    begin
        for i in 1..i_token_tab.count loop
            case i_token_tab(i).name
            when 'BE' then
                
                o_oper_amount := aci_api_util_pkg.get_field_number (
                    i_raw_data     => i_token_tab(i).value
                    , i_start_pos  => 1
                    , i_length     => 19
                );
                o_oper_cashback_amount := aci_api_util_pkg.get_field_number (
                    i_raw_data     => i_token_tab(i).value
                    , i_start_pos  => 20
                    , i_length     => 19
                );
                o_oper_currency := aci_api_util_pkg.get_field_char (
                    i_raw_data     => i_token_tab(i).value
                    , i_start_pos  => 39
                    , i_length     => 3
                );
               
            else
                null;
            end case;
        end loop;
    exception
        when others then
            trc_log_pkg.debug (
                i_text          => 'Error get params from tokens be on stage [#1] :[#2]'
                , i_env_param1  => l_stage
                , i_env_param2  => sqlerrm
            );
            raise;
    end;
    
    procedure get_b1_params (
        i_token_tab               in aci_api_type_pkg.t_token_tab
        , o_pos_entry_mode        out com_api_type_pkg.t_curr_code
        , o_cvr                   out com_api_type_pkg.t_name
        , o_ecom_sec_lvl_ind      out com_api_type_pkg.t_curr_code
        , o_trace                 out com_api_type_pkg.t_auth_code
        , o_interface             out com_api_type_pkg.t_name
        , io_resp_code            in out com_api_type_pkg.t_byte_char
    ) is
        l_version_id              com_api_type_pkg.t_byte_char;
        l_stage                   com_api_type_pkg.t_name;
    begin
        for i in 1..i_token_tab.count loop
            case i_token_tab(i).name
            when 'B1' then
                
                l_stage := 'get interface';
                o_interface := aci_api_util_pkg.get_field_char (
                    i_raw_data     => i_token_tab(i).value
                    , i_start_pos  => 5
                    , i_length     => 4
                );
                case o_interface
                when aci_api_const_pkg.INTERFACE_BNET then
                    l_stage := 'get version';
                    l_version_id := aci_api_util_pkg.get_field_char (
                        i_raw_data     => i_token_tab(i).value
                        , i_start_pos  => 9
                        , i_length     => 2
                    );
                    l_stage := 'get pos_entry_mode';
                    o_pos_entry_mode := aci_api_util_pkg.get_field_char (
                        i_raw_data     => i_token_tab(i).value
                        , i_start_pos  => 24
                        , i_length     => 3
                    );
                    o_cvr := aci_api_util_pkg.get_field_char (
                        i_raw_data     => i_token_tab(i).value
                        , i_start_pos  => 29
                        , i_length     => 1
                    );
                    o_ecom_sec_lvl_ind := aci_api_util_pkg.get_field_char (
                        i_raw_data     => i_token_tab(i).value
                        , i_start_pos  => 81
                        , i_length     => 3
                    );
                    if io_resp_code is null then
                        io_resp_code := aci_api_util_pkg.get_field_char (
                            i_raw_data     => i_token_tab(i).value
                            , i_start_pos  => 27
                            , i_length     => 2
                        );
                    end if;
                    
                when aci_api_const_pkg.INTERFACE_VISA then
                    l_stage := 'get version';
                    l_version_id := aci_api_util_pkg.get_field_char (
                        i_raw_data     => i_token_tab(i).value
                        , i_start_pos  => 9
                        , i_length     => 2
                    );
                    l_stage := 'get pos_entry_mode';
                    o_pos_entry_mode := aci_api_util_pkg.get_field_char (
                        i_raw_data     => i_token_tab(i).value
                        , i_start_pos  => 41
                        , i_length     => 3
                    );
                    o_cvr := aci_api_util_pkg.get_field_char (
                        i_raw_data     => i_token_tab(i).value
                        , i_start_pos  => 56
                        , i_length     => 2
                    );
                    o_trace := aci_api_util_pkg.get_field_char (
                        i_raw_data     => i_token_tab(i).value
                        , i_start_pos  => 91
                        , i_length     => 6
                    );
                    if io_resp_code is null then
                        io_resp_code := aci_api_util_pkg.get_field_char (
                            i_raw_data     => i_token_tab(i).value
                            , i_start_pos  => 45
                            , i_length     => 2
                        );
                    end if;
                    
                else
                    null;
                end case;
               
            else
                null;
            end case;
        end loop;
    exception
        when others then
            trc_log_pkg.debug (
                i_text          => 'Error get params from tokens b1 on stage [#1] :[#2]'
                , i_env_param1  => l_stage
                , i_env_param2  => sqlerrm
            );
            raise;
    end;
    
    procedure get_17_params (
        i_token_tab               in aci_api_type_pkg.t_token_tab
        , o_srv_indicator         out com_api_type_pkg.t_byte_char
        , o_transaction_id        out com_api_type_pkg.t_auth_long_id
        , o_validation_code       out com_api_type_pkg.t_mcc
    ) is
        l_stage                   com_api_type_pkg.t_name;
    begin
        for i in 1..i_token_tab.count loop
            case i_token_tab(i).name
            when '17' then
                
                l_stage := 'get srv_indicator';
                o_srv_indicator := aci_api_util_pkg.get_field_char (
                    i_raw_data     => i_token_tab(i).value
                    , i_start_pos  => 1
                    , i_length     => 1
                );
                
                l_stage := 'get transaction_id';
                o_transaction_id := aci_api_util_pkg.get_field_char (
                    i_raw_data     => i_token_tab(i).value
                    , i_start_pos  => 2
                    , i_length     => 15
                );
               
                l_stage := 'get validation_code';
                o_validation_code := aci_api_util_pkg.get_field_char (
                    i_raw_data     => i_token_tab(i).value
                    , i_start_pos  => 17
                    , i_length     => 4
                );
               
            else
                null;
            end case;
        end loop;
    exception
        when others then
            trc_log_pkg.debug (
                i_text          => 'Error get params from tokens 17 on stage [#1] :[#2]'
                , i_env_param1  => l_stage
                , i_env_param2  => sqlerrm
            );
            raise;
    end;
    
    procedure get_20_params (
        i_token_tab               in aci_api_type_pkg.t_token_tab
        , o_network_refnum        out com_api_type_pkg.t_rrn
    ) is
        l_stage                   com_api_type_pkg.t_name;
    begin
        for i in 1..i_token_tab.count loop
            case i_token_tab(i).name
            when '20' then
                
                l_stage := 'get network_refnum';
                o_network_refnum := aci_api_util_pkg.get_field_char (
                    i_raw_data     => i_token_tab(i).value
                    , i_start_pos  => 2
                    , i_length     => 15
                );
                
            when 'A6' then
                
                l_stage := 'get network_refnum';
                o_network_refnum := aci_api_util_pkg.get_field_char (
                    i_raw_data     => i_token_tab(i).value
                    , i_start_pos  => 2
                    , i_length     => 15
                );
                
            else
                null;
            end case;
        end loop;
    exception
        when others then
            trc_log_pkg.debug (
                i_text          => 'Error get params from tokens 20 on stage [#1] :[#2]'
                , i_env_param1  => l_stage
                , i_env_param2  => sqlerrm
            );
            raise;
    end;
    
    procedure get_ch_params (
        i_token_tab               in aci_api_type_pkg.t_token_tab
        , io_cvv2_result          in out com_api_type_pkg.t_dict_value
    ) is
        l_value                   com_api_type_pkg.t_param_value;
        l_stage                   com_api_type_pkg.t_name;
    begin
        for i in 1..i_token_tab.count loop
            case i_token_tab(i).name
            when 'CH' then
                
                l_stage := 'get cvv2_result';
                l_value := aci_api_util_pkg.get_field_char (
                    i_raw_data     => i_token_tab(i).value
                    , i_start_pos  => 2
                    , i_length     => 1
                );
                
                if l_value is not null then
                    io_cvv2_result := 'CV2R000' ||
                    case
                    when l_value in ('N', '0', 'O', 'P') then '3'
                    when l_value in ('C', 'D', 'R') then '2'
                    when l_value in ('Y') then '1'
                    when l_value in ('U') then '5'
                    else '3'
                    end;
                end if;
                
            else
                null;
            end case;
        end loop;
    exception
        when others then
            trc_log_pkg.debug (
                i_text          => 'Error get params from tokens ch on stage [#1] :[#2]'
                , i_env_param1  => l_stage
                , i_env_param2  => sqlerrm
            );
            raise;
    end;
    
    procedure get_06_params (
        i_token_tab               in aci_api_type_pkg.t_token_tab
        , o_pin_offset            out com_api_type_pkg.t_tiny_id
    ) is
        l_stage                   com_api_type_pkg.t_name;
    begin
        for i in 1..i_token_tab.count loop
            case i_token_tab(i).name
            when '06' then

                l_stage := 'get PIN offset';
                o_pin_offset := aci_api_util_pkg.get_field_number (
                    i_raw_data     => i_token_tab(i).value
                    , i_start_pos  => 2
                    , i_length     => 16
                );

            else
                null;
            end case;
        end loop;
    exception
        when others then
            trc_log_pkg.debug (
                i_text          => 'Error get params from tokens 06 on stage [#1] :[#2]'
                , i_env_param1  => l_stage
                , i_env_param2  => sqlerrm
            );
            raise;
    end;

end;
/
