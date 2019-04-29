create or replace package body aup_api_check_pkg as
/*********************************************************
 *  API for Authorization online checks <br />
 *  Created by Maslov I  at 06.05.2013 <br />
 *  Last changed by $Author: $ <br />
 *  $LastChangedDate:: #$ <br />
 *  Revision: $LastChangedRevision:  $ <br />
 *  Module: aup_api_check_pkg <br />
 *  @headcom
 **********************************************************/

procedure check_issuing_address(
    i_check_algo        in   com_api_type_pkg.t_dict_value  default null
  , i_card_number       in   com_api_type_pkg.t_card_number
  , i_postal_code       in   com_api_type_pkg.t_postal_code default null
  , i_address           in   com_api_type_pkg.t_name        default null
  , o_resp_code         out  com_api_type_pkg.t_dict_value
) is
    l_postal_code         com_api_type_pkg.t_postal_code; 
    l_address             com_api_type_pkg.t_name;
    l_address_digit       com_api_type_pkg.t_name;
    l_postal_code_digit   com_api_type_pkg.t_postal_code;    
    l_in_address_digit    com_api_type_pkg.t_name;
    l_in_pos_code_digit   com_api_type_pkg.t_postal_code;    
    l_inst_id             com_api_type_pkg.t_inst_id;    
    l_check_algo          com_api_type_pkg.t_dict_value;
    l_count               com_api_type_pkg.t_count := 0;
    l_comp_flag           com_api_type_pkg.t_boolean;
    l_compae_str          com_api_type_pkg.t_name;
    l_compae_str2         com_api_type_pkg.t_name;
    l_card_number         com_api_type_pkg.t_card_number;
begin
    trc_log_pkg.debug(
        i_text => 'aup_api_check_pkg.check_issuing_address start: i_postal_code = ' || i_postal_code || ', i_address = ' || i_address
    );

    if i_address is null then
        com_api_error_pkg.raise_error(
            i_error         => 'ADDRESS_IS_NULL'
        );
    end if;

    if i_postal_code is null then
        com_api_error_pkg.raise_error(
            i_error         => 'POSTAL_CODE_IS_NULL'
        );
    end if;
   
    -- For searching by card number we should get encoded with token card number  
    l_card_number := iss_api_token_pkg.encode_card_number(i_card_number => i_card_number);

    begin    
        --search on cardholder
        select ca.postal_code
             , com_api_address_pkg.get_address_string(i_address_id => ca.id, i_inst_id => h.inst_id)
             , ic.inst_id
             , nvl(set_ui_value_pkg.get_inst_param_v(
                       i_param_name      => 'AUTH_ADDR_CHECK_ALGORITHM'
                     , i_inst_id         => ic.inst_id
                   )
                 , i_check_algo)
          into l_postal_code
             , l_address
             , l_inst_id
             , l_check_algo
          from iss_card_number icn
             , iss_card ic 
             , com_address_object cao
             , com_address ca
             , iss_cardholder h
         where icn.card_id = ic.id
           and reverse(icn.card_number) = reverse(l_card_number)
           and cao.object_id = ic.cardholder_id 
           and cao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER 
           and cao.address_id = ca.id
           and h.id = ic.cardholder_id;

    exception
        when no_data_found then 
            begin
                --search on customer
                select ca.postal_code
                     , com_api_address_pkg.get_address_string(i_address_id => ca.id, i_inst_id => c.inst_id)
                     , ic.inst_id
                     , nvl(set_ui_value_pkg.get_inst_param_v(
                               i_param_name      => 'AUTH_ADDR_CHECK_ALGORITHM'
                             , i_inst_id         => ic.inst_id
                           )
                         , i_check_algo)
                  into l_postal_code
                     , l_address
                     , l_inst_id
                     , l_check_algo
                  from iss_card_number icn
                     , iss_card ic 
                     , com_address_object cao
                     , com_address ca
                     , prd_customer c
                 where icn.card_id = ic.id
                   and reverse(icn.card_number) = reverse(l_card_number)
                   and cao.object_id = ic.customer_id 
                   and cao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CUSTOMER
                   and cao.address_id = ca.id
                   and ic.customer_id = c.id;
                
            exception 
                when no_data_found then                       
                    begin
                        select 1 into l_count
                          from iss_card_number icn
                         where reverse(icn.card_number) = reverse(l_card_number)
                           and rownum = 1;

                        com_api_error_pkg.raise_error(
                            i_error      => 'ADDRESS_NOT_FOUND'
                        );
                    exception
                        when no_data_found then                  
                            com_api_error_pkg.raise_error(
                                i_error      => 'CARD_NOT_FOUND'
                              , i_env_param1 => iss_api_card_pkg.get_card_mask(i_card_number)
                            );
                    end;
            end;
    end;
     
    trc_log_pkg.debug(
        i_text       => 'l_check_algo = ' || l_check_algo
    );    

    -- check address length   
    if length(l_address) > length(i_address) then
        l_address := substr(l_address, 1, length(i_address));
    end if;                
    trc_log_pkg.debug(
        i_text       => 'l_address = ' || l_address || ', i_address = ' || i_address
    );    

    -- check posal_code length   
    if length(l_postal_code) > length(i_postal_code) then
        l_postal_code := substr(l_postal_code, 1, length(i_postal_code));
    end if;                
    trc_log_pkg.debug(
        i_text       => 'l_postal_code = ' || l_postal_code || ', i_postal_code = ' || i_postal_code
    );    

    if l_check_algo = aup_api_const_pkg.AUTH_ADDR_CHECK_ADDR_ZIP then
    
        if  l_postal_code = i_postal_code and l_address = i_address then
        
            o_resp_code := aup_api_const_pkg.AVS_RES_ADDR_MATCH_ZIP_MATCH;            
        else
            o_resp_code := case when(l_postal_code =  i_postal_code and l_address != i_address) then aup_api_const_pkg.AVS_RES_ZIP_MATCH_ADDR_NOT
                                when(l_postal_code != i_postal_code and l_address =  i_address) then aup_api_const_pkg.AVS_RES_ADDR_MATCH_ZIP_NOT
                                when(l_postal_code != i_postal_code and l_address != i_address) then aup_api_const_pkg.AVS_RES_NO_MATCH
                                else aup_api_const_pkg.AVS_RES_NO_MATCH
                           end;
        end if; 
    
    elsif l_check_algo = aup_api_const_pkg.AUTH_ADDR_CHECK_5D_ADDR_ZIP then
    
        -- first 5 digits
        l_address_digit    := substr(regexp_replace(l_address, '[^[:digit:]]', ''), 1, 5);
        l_in_address_digit := substr(regexp_replace(i_address, '[^[:digit:]]', ''), 1, 5);  

        if l_address_digit = l_in_address_digit and l_postal_code = i_postal_code then
        
            o_resp_code := aup_api_const_pkg.AVS_RES_ADDR_MATCH_ZIP_MATCH;
        else
            o_resp_code := case when(l_postal_code =  i_postal_code and l_address_digit != l_in_address_digit) then aup_api_const_pkg.AVS_RES_ZIP_MATCH_ADDR_NOT
                                when(l_postal_code != i_postal_code and l_address_digit =  l_in_address_digit) then aup_api_const_pkg.AVS_RES_ADDR_MATCH_ZIP_NOT
                                when(l_postal_code != i_postal_code and l_address_digit != l_in_address_digit) then aup_api_const_pkg.AVS_RES_NO_MATCH
                                else aup_api_const_pkg.AVS_RES_NO_MATCH
                           end;
        end if;
    
    elsif l_check_algo = aup_api_const_pkg.AUTH_ADDR_CHECK_TO_5D_ADDR_ZIP then

        l_comp_flag := com_api_type_pkg.TRUE; 

        if length(l_address) >= 5 and length(i_address) >= 5 then
        
            for i in 1..5 loop
                if substr(i_address, i, 1) >= '0' and substr(i_address, i, 1) <= '9' then
                    l_compae_str := l_compae_str || substr(i_address, i, 1);
                else
                    exit;    
                end if;    
            end loop;

            for i in 1..5 loop
                if substr(l_address, i, 1) >= '0' and substr(l_address, i, 1) <= '9' then
                    l_compae_str2 := l_compae_str2 || substr(l_address, i, 1);
                else
                    exit;    
                end if;    
            end loop;

            if l_compae_str = l_compae_str2 then
                l_comp_flag := com_api_type_pkg.TRUE;
            else
                l_comp_flag := com_api_type_pkg.FALSE;              
            end if;
      
        else
            l_comp_flag := com_api_type_pkg.FALSE;  
        
        end if;

        if l_comp_flag = com_api_type_pkg.TRUE and l_postal_code = i_postal_code then
            
            o_resp_code := aup_api_const_pkg.AVS_RES_ADDR_MATCH_ZIP_MATCH;
        else
            o_resp_code := case when(l_postal_code =  i_postal_code and l_comp_flag = com_api_type_pkg.FALSE) then aup_api_const_pkg.AVS_RES_ZIP_MATCH_ADDR_NOT
                                when(l_postal_code != i_postal_code and l_comp_flag = com_api_type_pkg.TRUE)  then aup_api_const_pkg.AVS_RES_ADDR_MATCH_ZIP_NOT
                                when(l_postal_code != i_postal_code and l_comp_flag = com_api_type_pkg.FALSE) then aup_api_const_pkg.AVS_RES_NO_MATCH
                                else aup_api_const_pkg.AVS_RES_NO_MATCH
                           end;
        end if;    
        
    elsif l_check_algo = aup_api_const_pkg.AUTH_ADDR_CHECK_5D_ADDR_DG_ZIP then
    
        -- first 5 digits
        l_address_digit    := substr(regexp_replace(l_address, '[^[:digit:]]', ''), 1, 5);
        l_in_address_digit := substr(regexp_replace(i_address, '[^[:digit:]]', ''), 1, 5);  
        
        -- all digits of postal code
        l_postal_code_digit := regexp_replace(l_postal_code, '[^[:digit:]]', '');
        l_in_pos_code_digit := regexp_replace(i_postal_code, '[^[:digit:]]', '');
        
        if l_address_digit = l_in_address_digit and l_postal_code_digit = l_in_pos_code_digit then
        
            o_resp_code := aup_api_const_pkg.AVS_RES_ADDR_MATCH_ZIP_MATCH;
        else
            o_resp_code := case when(l_postal_code_digit =  l_in_pos_code_digit and l_address_digit != l_in_address_digit) then aup_api_const_pkg.AVS_RES_ZIP_MATCH_ADDR_NOT
                                when(l_postal_code_digit != l_in_pos_code_digit and l_address_digit =  l_in_address_digit) then aup_api_const_pkg.AVS_RES_ADDR_MATCH_ZIP_NOT
                                when(l_postal_code_digit != l_in_pos_code_digit and l_address_digit != l_in_address_digit) then aup_api_const_pkg.AVS_RES_NO_MATCH
                                else aup_api_const_pkg.AVS_RES_NO_MATCH
                           end;
        end if;
        
    else
        com_api_error_pkg.raise_error(
            i_error         => 'UNKNOWN_AUTH_ADDR_CHECK_ALGORITHM'
            , i_env_param1  => l_check_algo
           );
    end if;

    trc_log_pkg.debug(
        i_text       => 'aup_api_check_pkg.check_issuing_address end: o_resp_code = ' || o_resp_code
    );
end check_issuing_address;
    
/*
 * Procedure raises an exception if <i_start_date> is greater than <i_end_date>.
 */
procedure check_time_period(
    i_start_date        in     date
  , i_end_date          in     date
) is
begin
    if i_start_date is null or i_start_date > nvl(i_end_date, i_start_date) then
        com_api_error_pkg.raise_error(
            i_error      => 'END_DATE_IS_LESS_THAN_START_DATE'
          , i_env_param1 => com_api_type_pkg.convert_to_char(i_start_date)
          , i_env_param2 => com_api_type_pkg.convert_to_char(i_end_date)
        );
    end if;
end check_time_period;

procedure check_cross_border(
    i_iss_card_number     in     com_api_type_pkg.t_card_number
  , i_acq_card_number     in     com_api_type_pkg.t_card_number       default null
  , i_raise_error         in     com_api_type_pkg.t_boolean           default com_api_const_pkg.TRUE
  , i_acq_inst_id         in     com_api_type_pkg.t_inst_id           default null
  , o_is_cross_border     out    com_api_type_pkg.t_boolean
  , o_application_plugin  out    com_api_type_pkg.t_dict_value
) is

    l_iss_card_country               com_api_type_pkg.t_country_code;
    l_acq_card_country               com_api_type_pkg.t_country_code;
    l_iss_application_plugin         com_api_type_pkg.t_dict_value;
    l_acq_application_plugin         com_api_type_pkg.t_dict_value;

    procedure get_card_country(
        i_card_number         in     com_api_type_pkg.t_card_number
      , i_raise_error         in     com_api_type_pkg.t_boolean     default com_api_const_pkg.TRUE
      , o_card_country           out com_api_type_pkg.t_country_code
      , o_application_plugin     out com_api_type_pkg.t_dict_value
    )is
    
    l_pan_prefix                     com_api_type_pkg.t_card_number;
    l_bin_network_id                 com_api_type_pkg.t_network_id;
    l_default_host_id                com_api_type_pkg.t_tiny_id;
    
    begin
        begin
            select bin.country as card_country
                 , bin.network_id
              into o_card_country
                 , l_bin_network_id
              from (
                    select b.country
                         , b.network_id
                      from iss_bin b
                     where i_card_number like b.bin || '%'
                     order by length(b.bin) desc
                   ) bin
             where rownum = 1;
        exception
            when no_data_found then
                begin
                    l_pan_prefix := substr(i_card_number, 1, 5);

                    select bin.country
                         , bin.network_id
                      into o_card_country
                         , l_bin_network_id
                      from (        
                            select b.country
                                 , b.pan_length
                                 , n.id as network_id
                              from net_bin_range_index i
                                 , net_bin_range b
                                 , net_network n
                                 , net_member m
                             where i.pan_prefix = l_pan_prefix
                               and i_card_number between substr(i.pan_low, 1, length(i_card_number)) and substr(i.pan_high, 1, length(i_card_number)) 
                               and i.pan_low = b.pan_low
                               and i.pan_high = b.pan_high
                               and b.iss_network_id = n.id
                               and b.iss_network_id = m.network_id
                               and b.iss_inst_id = m.inst_id
                             order by n.bin_table_scan_priority
                                    , utl_match.jaro_winkler_similarity(i.pan_low, rpad(i_card_number, length(i.pan_low), '0')) desc
                                    , b.priority
                            ) bin
                      where rownum = 1;
                exception
                    when no_data_found then
                        if i_raise_error = com_api_const_pkg.TRUE then
                            com_api_error_pkg.raise_error (
                                i_error         => 'BIN_NOT_FOUND_BY_CARD_NUMBER'
                                , i_env_param1  => iss_api_card_pkg.get_card_mask(i_card_number)
                                , i_env_param2  => substr(i_card_number, 1, 6)
                            );
                        else
                            o_card_country := null;
                            o_application_plugin := null;
                        end if;
                end;
        end;
        if o_card_country is not null then
            -- Get default online standard
            l_default_host_id := net_api_network_pkg.get_default_host (i_network_id => l_bin_network_id);
            begin
                select s.application_plugin
                  into o_application_plugin
                  from cmn_standard_object so
                     , cmn_standard s
                 where so.object_id = l_default_host_id
                   and so.entity_type = net_api_const_pkg.ENTITY_TYPE_HOST
                   and so.standard_type = cmn_api_const_pkg.STANDART_TYPE_NETW_COMM
                   and so.standard_id = s.id;
            exception
                when no_data_found then
                    if i_raise_error = com_api_const_pkg.TRUE then
                        com_api_error_pkg.raise_error (
                            i_error         => 'COMMUNICATION_STANDARD_APPL_PLUGIN_NOT_DEFINED'
                        );
                    else
                        o_card_country := null;
                        o_application_plugin := null;
                    end if;
            end;
        end if;
    end;
begin
    if i_iss_card_number is not null and i_acq_card_number is not null then  
        -- Get issuer card country
        get_card_country(
            i_card_number        => i_iss_card_number
          , i_raise_error        => i_raise_error
          , o_card_country       => l_iss_card_country
          , o_application_plugin => l_iss_application_plugin
        );
        -- Get acquirer card country
        get_card_country(
            i_card_number        => i_acq_card_number
          , i_raise_error        => i_raise_error
          , o_card_country       => l_acq_card_country
          , o_application_plugin => l_acq_application_plugin
        );
        o_application_plugin := l_acq_application_plugin;

        if l_iss_card_country = l_acq_card_country then
            o_is_cross_border := com_api_const_pkg.FALSE;
        elsif l_iss_card_country != l_acq_card_country then
            o_is_cross_border := com_api_const_pkg.TRUE;
        else
            o_is_cross_border := com_api_const_pkg.FALSE;
        end if;
    
    elsif i_acq_card_number is null and i_acq_inst_id is not null then
        -- Get card country
        get_card_country(
            i_card_number        => i_iss_card_number
          , i_raise_error        => i_raise_error
          , o_card_country       => l_iss_card_country
          , o_application_plugin => l_iss_application_plugin
        );     
        
        --get address acq_inst
        select min(a.country)
          into l_acq_card_country
          from com_address_object o
             , com_address a
         where o.object_id   = i_acq_inst_id
           and o.entity_type = ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
           and a.id = o.address_id;    
        
        if l_acq_card_country is null then
        
            com_api_error_pkg.raise_error(
                i_error         => 'COUNTRY_NOT_FOUND'
                , i_env_param1  => i_acq_inst_id
            );            
        end if;
           
        if l_iss_card_country = l_acq_card_country then
            o_is_cross_border := com_api_const_pkg.FALSE;
        elsif l_iss_card_country != l_acq_card_country then
            o_is_cross_border := com_api_const_pkg.TRUE;
        else
            o_is_cross_border := com_api_const_pkg.FALSE;
        end if;
        
    end if;
    
end check_cross_border;

end;
/