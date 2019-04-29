create or replace package body atm_ui_scenario_encoding_pkg as

procedure add_encoding (
    o_id                      out com_api_type_pkg.t_tiny_id
  , o_seqnum                  out com_api_type_pkg.t_seqnum
  , i_atm_scenario_id     in      com_api_type_pkg.t_tiny_id
  , i_lang                in      com_api_type_pkg.t_dict_value
  , i_reciept_encoding    in      com_api_type_pkg.t_name
  , i_screen_encoding     in      com_api_type_pkg.t_name
) is
begin
    o_id := atm_scenario_encoding_seq.nextval;
    o_seqnum := 1;
     
    insert into atm_scenario_encoding_vw (
        id              
      , seqnum          
      , atm_scenario_id 
      , lang            
      , reciept_encoding
      , screen_encoding
    ) values (
        o_id
      , o_seqnum
      , i_atm_scenario_id  
      , i_lang             
      , i_reciept_encoding 
      , i_screen_encoding  
    );
            
end;

procedure modify_encoding (
    i_id                  in      com_api_type_pkg.t_tiny_id
  , io_seqnum             in out  com_api_type_pkg.t_seqnum
  , i_atm_scenario_id     in      com_api_type_pkg.t_tiny_id
  , i_lang                in      com_api_type_pkg.t_dict_value
  , i_reciept_encoding    in      com_api_type_pkg.t_name      
  , i_screen_encoding     in      com_api_type_pkg.t_name    
) is
begin
    update
        atm_scenario_encoding_vw
    set
        seqnum = io_seqnum            
      , atm_scenario_id = i_atm_scenario_id  
      , lang = i_lang  
      , reciept_encoding = i_reciept_encoding  
      , screen_encoding = i_screen_encoding
    where 
        id = i_id;
        
    io_seqnum := io_seqnum + 1;
end;
    
procedure remove_encoding (
    i_id                  in      com_api_type_pkg.t_tiny_id
  , i_seqnum              in      com_api_type_pkg.t_seqnum  
) is
begin
    update 
        atm_scenario_encoding_vw
    set
        seqnum = i_seqnum
    where
        id = i_id;
    
    delete from
        atm_scenario_encoding_vw
    where
        id = i_id;    
end;

end atm_ui_scenario_encoding_pkg;
/