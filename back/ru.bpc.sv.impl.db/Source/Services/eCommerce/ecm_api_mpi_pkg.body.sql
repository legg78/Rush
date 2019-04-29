create or replace package body ecm_api_mpi_pkg as


procedure get_merchant_mpi_data(
    i_merchant_id            in      com_api_type_pkg.t_short_id
  , i_host_id                in      com_api_type_pkg.t_tiny_id
  , o_acquirer_pw               out  com_api_type_pkg.t_name
  , o_acquirer_bin              out  com_api_type_pkg.t_name
  , o_directory_url             out  com_api_type_pkg.t_name
  , o_merchant_country          out  com_api_type_pkg.t_country_code
  , o_merchant_number           out  com_api_type_pkg.t_merchant_number
  , o_merchant_name             out  com_api_type_pkg.t_name
  , o_merchant_url              out  com_api_type_pkg.t_name
  , o_directory_secondary_url   out  com_api_type_pkg.t_name
) is
    l_inst_id           com_api_type_pkg.t_inst_id;
    l_standard_id       com_api_type_pkg.t_tiny_id;
    l_param_tab         com_api_type_pkg.t_param_tab;
begin
    select a.merchant_name
         , b.internet_store_url
         , d.country
         , a.inst_id
         , a.merchant_number
      into o_merchant_name
         , o_merchant_url
         , o_merchant_country
         , l_inst_id
         , o_merchant_number
      from acq_merchant a
         , ecm_merchant b
         , com_address_object c
         , com_address d
     where a.id = i_merchant_id
       and b.id = a.id
       and c.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
       and c.object_id   = a.id
       and c.address_type = 'ADTPBSNA'
       and d.id = c.address_id
       and d.lang = com_api_const_pkg.LANGUAGE_ENGLISH;
       
    select standard_id
      into l_standard_id 
      from cmn_standard_object
     where entity_type   = net_api_const_pkg.ENTITY_TYPE_HOST
       and object_id     = i_host_id
       and standard_type = cmn_api_const_pkg.STANDART_TYPE_NETW_COMM;

    o_acquirer_pw :=
        cmn_api_standard_pkg.get_varchar_value(
            i_inst_id       => l_inst_id
          , i_standard_id   => l_standard_id
          , i_object_id     => i_host_id
          , i_entity_type   => net_api_const_pkg.ENTITY_TYPE_HOST
          , i_param_name    => 'ACQUIRER_PASSWORD'
          , i_param_tab     => l_param_tab
        );

    o_acquirer_bin :=
        cmn_api_standard_pkg.get_varchar_value(
            i_inst_id       => l_inst_id
          , i_standard_id   => l_standard_id
          , i_object_id     => i_host_id
          , i_entity_type   => net_api_const_pkg.ENTITY_TYPE_HOST
          , i_param_name    => 'ACQ_BIN'
          , i_param_tab     => l_param_tab
        );

    o_directory_url :=
        cmn_api_standard_pkg.get_varchar_value(
            i_inst_id       => l_inst_id
          , i_standard_id   => l_standard_id
          , i_object_id     => i_host_id
          , i_entity_type   => net_api_const_pkg.ENTITY_TYPE_HOST
          , i_param_name    => 'DIRECTORY_URL'
          , i_param_tab     => l_param_tab
        );
        
    o_directory_secondary_url :=
        cmn_api_standard_pkg.get_varchar_value(
            i_inst_id       => l_inst_id
          , i_standard_id   => l_standard_id
          , i_object_id     => i_host_id
          , i_entity_type   => net_api_const_pkg.ENTITY_TYPE_HOST
          , i_param_name    => 'DIRECTORY_SECONDARY_URL'
          , i_param_tab     => l_param_tab
        );
end;

procedure validate_card_number(
    i_card_number       in      com_api_type_pkg.t_card_number
  , o_card_network_id      out  com_api_type_pkg.t_tiny_id
  , o_is_valid             out  com_api_type_pkg.t_boolean
) is
    l_card_inst_id      com_api_type_pkg.t_inst_id;
    l_card_type         com_api_type_pkg.t_tiny_id;
    l_card_country      com_api_type_pkg.t_curr_code;
    l_iss_inst_id       com_api_type_pkg.t_inst_id;
    l_iss_network_id    com_api_type_pkg.t_tiny_id;
    l_iss_host_id       com_api_type_pkg.t_tiny_id;
    l_pan_length        com_api_type_pkg.t_tiny_id;

begin

     
    if regexp_like(i_card_number, '^\d{13,19}$') and 
       com_api_checksum_pkg.get_luhn_checksum(substr(i_card_number, 1, length(i_card_number)-1)) = substr(i_card_number, -1) 
    then
        o_is_valid := com_api_const_pkg.TRUE;
    else
        o_is_valid := com_api_const_pkg.FALSE;
    end if;
    
    if o_is_valid = com_api_const_pkg.TRUE then
        begin
            net_api_bin_pkg.get_bin_info (
                i_card_number           => i_card_number
              , o_card_inst_id          => l_card_inst_id
              , o_card_network_id       => o_card_network_id
              , o_card_type_id          => l_card_type
              , o_card_country          => l_card_country
              , o_iss_inst_id           => l_iss_inst_id
              , o_iss_network_id        => l_iss_network_id
              , o_iss_host_id           => l_iss_host_id
              , o_pan_length            => l_pan_length
            );
            
            if length(i_card_number) != l_pan_length then
                o_card_network_id := null;
                o_is_valid := com_api_const_pkg.FALSE;
            end if;
        exception
            when no_data_found then
                o_is_valid := com_api_const_pkg.FALSE;
        end;
    end if;
    
end;

procedure get_root_certificate (
      i_host_id         in      com_api_type_pkg.t_tiny_id  
    , o_public_key          out com_api_type_pkg.t_key
) is
    l_key_rec                   sec_api_type_pkg.t_rsa_key_rec;
begin
    l_key_rec := sec_api_rsa_key_pkg.get_rsa_key (
                    i_id            =>  null
                  , i_object_id     =>  i_host_id  
                  , i_entity_type   =>  net_api_const_pkg.ENTITY_TYPE_HOST
                  , i_key_type      =>  sec_api_const_pkg.SECURITY_RSA_IPS_ROOT_CERT
                 );
                 
    o_public_key := l_key_rec.public_key;                 
end;

end;
/
