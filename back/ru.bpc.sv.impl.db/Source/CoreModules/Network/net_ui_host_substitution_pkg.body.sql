create or replace package body net_ui_host_substitution_pkg is

procedure add(
        o_id                        out     com_api_type_pkg.t_medium_id
      , o_seqnum                    out     com_api_type_pkg.t_inst_id
      , i_oper_type                 in      com_api_type_pkg.t_dict_value
      , i_terminal_type             in      com_api_type_pkg.t_dict_value
      , i_pan_low                   in      com_api_type_pkg.t_bin
      , i_pan_high                  in      com_api_type_pkg.t_bin
      , i_acq_inst_id               in      com_api_type_pkg.t_mcc
      , i_acq_network_id            in      com_api_type_pkg.t_mcc
      , i_card_inst_id              in      com_api_type_pkg.t_mcc
      , i_card_network_id           in      com_api_type_pkg.t_mcc
      , i_iss_inst_id               in      com_api_type_pkg.t_mcc
      , i_iss_network_id            in      com_api_type_pkg.t_mcc
      , i_priority                  in      com_api_type_pkg.t_inst_id
      , i_substitution_inst_id      in      com_api_type_pkg.t_mcc
      , i_substitution_network_id   in      com_api_type_pkg.t_mcc
      , i_msg_type                  in      com_api_type_pkg.t_dict_value
      , i_oper_reason               in      com_api_type_pkg.t_dict_value
      , i_oper_currency             in      com_api_type_pkg.t_curr_code
      , i_merchant_array_id         in      com_api_type_pkg.t_dict_value
      , i_terminal_array_id         in      com_api_type_pkg.t_dict_value      
      , i_card_country              in      com_api_type_pkg.t_country_code  default null
)is
begin
    o_id := net_host_substitution_seq.nextval;
    o_seqnum := 1;

    insert into net_host_substitution_vw (
         id                   
         , seqnum
         , oper_type
         , terminal_type
         , pan_low
         , pan_high
         , acq_inst_id
         , acq_network_id
         , card_inst_id
         , card_network_id  
         , iss_inst_id  
         , iss_network_id      
         , priority       
         , substitution_inst_id     
         , substitution_network_id   
         , msg_type
         , oper_reason
         , oper_currency
         , merchant_array_id
         , terminal_array_id
         , card_country      
    ) values (
         o_id
         , o_seqnum
         , i_oper_type
         , i_terminal_type 
         , i_pan_low       
         , i_pan_high      
         , i_acq_inst_id   
         , i_acq_network_id
         , i_card_inst_id  
         , i_card_network_id
         , i_iss_inst_id    
         , i_iss_network_id 
         , i_priority       
         , i_substitution_inst_id 
         , i_substitution_network_id
         , i_msg_type               
         , i_oper_reason            
         , i_oper_currency          
         , i_merchant_array_id      
         , i_terminal_array_id     
         , i_card_country   
    );
end;
    
procedure modify(
        i_id                        in      com_api_type_pkg.t_medium_id
      , io_seqnum                   in out  com_api_type_pkg.t_inst_id
      , i_oper_type                 in      com_api_type_pkg.t_dict_value
      , i_terminal_type             in      com_api_type_pkg.t_dict_value
      , i_pan_low                   in      com_api_type_pkg.t_bin
      , i_pan_high                  in      com_api_type_pkg.t_bin
      , i_acq_inst_id               in      com_api_type_pkg.t_mcc
      , i_acq_network_id            in      com_api_type_pkg.t_mcc
      , i_card_inst_id              in      com_api_type_pkg.t_mcc
      , i_card_network_id           in      com_api_type_pkg.t_mcc
      , i_iss_inst_id               in      com_api_type_pkg.t_mcc
      , i_iss_network_id            in      com_api_type_pkg.t_mcc
      , i_priority                  in      com_api_type_pkg.t_inst_id
      , i_substitution_inst_id      in      com_api_type_pkg.t_mcc
      , i_substitution_network_id   in      com_api_type_pkg.t_mcc
      , i_msg_type                  in      com_api_type_pkg.t_dict_value
      , i_oper_reason               in      com_api_type_pkg.t_dict_value
      , i_oper_currency             in      com_api_type_pkg.t_curr_code
      , i_merchant_array_id         in      com_api_type_pkg.t_dict_value
      , i_terminal_array_id         in      com_api_type_pkg.t_dict_value   
      , i_card_country              in      com_api_type_pkg.t_country_code  default null   
)is
begin
   update
        net_host_substitution_vw
    set
        seqnum                    = io_seqnum
        , oper_type               = i_oper_type
        , terminal_type           = i_terminal_type
        , pan_low                 = i_pan_low
        , pan_high                = i_pan_high
        , acq_inst_id             = i_acq_inst_id
        , acq_network_id          = i_acq_network_id
        , card_inst_id            = i_card_inst_id
        , card_network_id         = i_card_network_id
        , iss_inst_id             = i_iss_inst_id
        , iss_network_id          = i_iss_network_id
        , priority                = i_priority
        , substitution_inst_id    = i_substitution_inst_id
        , substitution_network_id = i_substitution_network_id
        , msg_type                = i_msg_type
        , oper_reason             = i_oper_reason
        , oper_currency           = i_oper_currency
        , merchant_array_id       = i_merchant_array_id
        , terminal_array_id       = i_terminal_array_id
        , card_country            = i_card_country  
    where
        id = i_id;

    io_seqnum := io_seqnum + 1;
end;

procedure remove (
    i_id                           in com_api_type_pkg.t_medium_id
    , i_seqnum                     in com_api_type_pkg.t_inst_id
)is
begin
    update
        net_host_substitution_vw
    set
        seqnum = i_seqnum
    where
        id = i_id;

    delete from
        net_host_substitution_vw
    where
        id = i_id;
end;

end;
/
