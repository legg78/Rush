create or replace package body iss_ui_bin_pkg is
/**********************************************************
*  UI for bin table <br />
*  Created by Kopachev D.(kopachev@bpc.ru)  at 09.08.2010 <br />
*  Last changed by $Author: krukov $ <br />
*  $LastChangedDate:: 2011-03-01 14:46:54 +0300#$ <br />
*  Revision: $LastChangedRevision: 8281 $ <br />
*  Module: iss_ui_bin_pkg <br />
*  @headcom
***********************************************************/
procedure add_iss_bin(
    o_id                  out  com_api_type_pkg.t_short_id
  , o_seqnum              out  com_api_type_pkg.t_seqnum
  , i_bin              in      com_api_type_pkg.t_card_number
  , i_inst_id          in      com_api_type_pkg.t_inst_id
  , i_network_id       in      com_api_type_pkg.t_tiny_id
  , i_bin_currency     in      com_api_type_pkg.t_curr_code
  , i_sttl_currency    in      com_api_type_pkg.t_curr_code
  , i_pan_length       in      com_api_type_pkg.t_tiny_id
  , i_card_type_id     in      com_api_type_pkg.t_tiny_id
  , i_country          in      com_api_type_pkg.t_country_code
  , i_lang             in      com_api_type_pkg.t_dict_value
  , i_description      in      com_api_type_pkg.t_full_desc
) is
begin
    if i_pan_length < iss_api_const_pkg.MINIMAL_CARD_NUMBER_LENGTH then
        com_api_error_pkg.raise_error(
            i_error      => 'TOO_SHORT_PAN_LENGTH_FOR_BIN'
          , i_env_param1 => i_pan_length
          , i_env_param2 => iss_api_const_pkg.MINIMAL_CARD_NUMBER_LENGTH
          , i_env_param3 => i_bin
        );
    end if;

    o_id := iss_bin_seq.nextval;
    
    o_seqnum := 1;
    
    begin
        insert into iss_bin_vw (
            id
          , seqnum
          , bin
          , inst_id
          , network_id
          , bin_currency
          , sttl_currency
          , pan_length
          , card_type_id
          , country
        ) values (
            o_id
          , o_seqnum
          , trim(i_bin)
          , i_inst_id
          , i_network_id
          , i_bin_currency
          , i_sttl_currency
          , i_pan_length
          , i_card_type_id
          , i_country
        );
    exception
        when dup_val_on_index then
            com_api_error_pkg.raise_error (
                i_error        => 'ISSUING_BIN_ALREADY_EXISTS'
              , i_env_param1   => trim(i_bin) 
            );
    end;

    com_api_i18n_pkg.add_text(
        i_table_name    => 'iss_bin' 
      , i_column_name   => 'description' 
      , i_object_id     => o_id
      , i_lang          => i_lang
      , i_text          => i_description
      , i_check_unique  => com_api_const_pkg.TRUE
    );
end;

procedure modify_iss_bin(
    i_id               in      com_api_type_pkg.t_tiny_id
  , io_seqnum          in out  com_api_type_pkg.t_seqnum
  , i_bin              in      com_api_type_pkg.t_card_number
  , i_inst_id          in      com_api_type_pkg.t_inst_id
  , i_network_id       in      com_api_type_pkg.t_tiny_id
  , i_bin_currency     in      com_api_type_pkg.t_curr_code
  , i_sttl_currency    in      com_api_type_pkg.t_curr_code
  , i_pan_length       in      com_api_type_pkg.t_tiny_id
  , i_card_type_id     in      com_api_type_pkg.t_tiny_id
  , i_country          in      com_api_type_pkg.t_country_code
  , i_lang             in      com_api_type_pkg.t_dict_value
  , i_description      in      com_api_type_pkg.t_full_desc
) is
    l_count            pls_integer;
    l_old_bin          iss_api_type_pkg.t_bin_rec;
begin
    if i_pan_length < iss_api_const_pkg.MINIMAL_CARD_NUMBER_LENGTH then
        com_api_error_pkg.raise_error(
            i_error      => 'TOO_SHORT_PAN_LENGTH_FOR_BIN'
          , i_env_param1 => i_pan_length
          , i_env_param2 => iss_api_const_pkg.MINIMAL_CARD_NUMBER_LENGTH
          , i_env_param3 => i_bin
        );
    end if;

    select count(*)
      into l_count
      from iss_product_card_type_vw
     where bin_id = i_id;

    l_old_bin := iss_api_bin_pkg.get_bin(i_bin_id => i_id);

    if l_count > 0 
       and (l_old_bin.bin != i_bin 
            or l_old_bin.inst_id != i_inst_id
            or l_old_bin.network_id != i_network_id
            or l_old_bin.sttl_currency != i_sttl_currency
            or l_old_bin.pan_length != i_pan_length
            or l_old_bin.card_type_id != i_card_type_id
            or l_old_bin.country != i_country) then
        com_api_error_pkg.raise_error (
            i_error      => 'ISSUING_BIN_ALREADY_USED'
          , i_env_param1 => i_id 
          , i_env_param2 => l_old_bin.bin
        );
    elsif l_count = 0 then
        begin
            update iss_bin_vw
               set seqnum          = io_seqnum
                 , bin             = trim(i_bin)
                 , inst_id         = i_inst_id
                 , network_id      = i_network_id
                 , bin_currency    = i_bin_currency
                 , sttl_currency   = i_sttl_currency
                 , pan_length      = i_pan_length
                 , card_type_id    = i_card_type_id
                 , country         = i_country
             where id              = i_id;
        exception
            when dup_val_on_index then
                com_api_error_pkg.raise_error (
                    i_error        => 'ISSUING_BIN_ALREADY_EXISTS'
                  , i_env_param1   => trim(i_bin) 
                );
        end;        
        io_seqnum := io_seqnum + 1;
    end if;

    com_api_i18n_pkg.add_text(
        i_table_name    => 'iss_bin' 
      , i_column_name   => 'description' 
      , i_object_id     => i_id
      , i_lang          => i_lang
      , i_text          => i_description
      , i_check_unique  => com_api_const_pkg.TRUE
    );
end;

procedure remove_iss_bin (
    i_id               in      com_api_type_pkg.t_tiny_id
  , i_seqnum           in      com_api_type_pkg.t_seqnum
) is
    l_check_cnt    number;
begin
    select count(*)
      into l_check_cnt
      from iss_product_card_type_vw
     where bin_id = i_id;
            
    if l_check_cnt > 0 then
        com_api_error_pkg.raise_error (
            i_error      => 'ISSUING_BIN_ALREADY_USED'
          , i_env_param1 => i_id 
          , i_env_param2 => null
        );
    else
        com_api_i18n_pkg.remove_text(
            i_table_name => 'iss_bin' 
          , i_object_id  => i_id
        );
          
        update iss_bin_vw
           set seqnum = i_seqnum
         where id     = i_id;
                
        delete from iss_bin_vw
         where id     = i_id;
    end if;
end;

function get_iss_bin(
    i_id               in     com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_bin
is
    l_bin                     com_api_type_pkg.t_bin;
begin
    begin
        select b.bin
          into l_bin 
          from iss_bin_vw b
         where b.id = i_id;
    exception
        when no_data_found then
            l_bin := null;
    end;
    return l_bin;
end;

end; 
/
