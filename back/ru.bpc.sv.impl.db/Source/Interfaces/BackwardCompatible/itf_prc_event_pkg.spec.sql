create or replace package itf_prc_event_pkg is

procedure process_event_object(
    i_inst_id           in      com_api_type_pkg.t_inst_id      
);

function generate_card_block(
    i_account_id          in      com_api_type_pkg.t_account_id
) return xmltype; 

function generate_account_block(
    i_account_id          in      com_api_type_pkg.t_account_id
) return xmltype; 

function generate_invoice_block(
    i_invoice_id          in      com_api_type_pkg.t_account_id
  , i_account_id          in      com_api_type_pkg.t_account_id  := null
) return xmltype; 

end;
/
