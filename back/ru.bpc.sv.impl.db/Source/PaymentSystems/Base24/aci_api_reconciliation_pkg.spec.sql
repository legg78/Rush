create or replace package aci_api_reconciliation_pkg is
 
    procedure get_reconc_data (
        i_sttl_date             in     date
        , i_inst_id             in     com_api_type_pkg.t_inst_id
        , o_number_credits         out com_api_type_pkg.t_long_id
        , o_rev_number_credits     out com_api_type_pkg.t_long_id
        , o_number_debits          out com_api_type_pkg.t_long_id
        , o_rev_number_debits      out com_api_type_pkg.t_long_id
        , o_number_transfer        out com_api_type_pkg.t_long_id
        , o_rev_number_transfer    out com_api_type_pkg.t_long_id
        , o_number_inquiries       out com_api_type_pkg.t_long_id
        , o_number_auths           out com_api_type_pkg.t_long_id
        , o_amount_credits         out com_api_type_pkg.t_money
        , o_rev_amount_credits     out com_api_type_pkg.t_money
        , o_amount_debits          out com_api_type_pkg.t_money
        , o_rev_amount_debits      out com_api_type_pkg.t_money
        , o_net_sttl_amount        out com_api_type_pkg.t_money
    );
    
    procedure set_reconc_data (
        i_sttl_date             in     date
        , i_inst_id             in     com_api_type_pkg.t_inst_id
        , i_number_credits      in     com_api_type_pkg.t_long_id
        , i_rev_number_credits  in     com_api_type_pkg.t_long_id
        , i_number_debits       in     com_api_type_pkg.t_long_id
        , i_rev_number_debits   in     com_api_type_pkg.t_long_id
        , i_number_transfer     in     com_api_type_pkg.t_long_id
        , i_rev_number_transfer in     com_api_type_pkg.t_long_id
        , i_number_inquiries    in     com_api_type_pkg.t_long_id
        , i_number_auths        in     com_api_type_pkg.t_long_id
        , i_amount_credits      in     com_api_type_pkg.t_money
        , i_rev_amount_credits  in     com_api_type_pkg.t_money
        , i_amount_debits       in     com_api_type_pkg.t_money
        , i_rev_amount_debits   in     com_api_type_pkg.t_money
        , i_net_sttl_amount     in     com_api_type_pkg.t_money
    );
    
end;
/
 