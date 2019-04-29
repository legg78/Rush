create or replace package acc_ui_entry_tpl_pkg is
/********************************************************* 
 *  Interface for entry transaction templates <br /> 
 *  Created by Khougaev A.(khougaev@bpcbt.com)  at 20.11.2009 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module: acc_ui_entry_tpl_pkg <br /> 
 *  @headcom 
 **********************************************************/
    procedure add (
        o_id                    out com_api_type_pkg.t_short_id
        , o_seqnum              out com_api_type_pkg.t_seqnum
        , i_bunch_type_id       in com_api_type_pkg.t_tiny_id
        , i_transaction_type    in com_api_type_pkg.t_dict_value
        , i_transaction_num     in com_api_type_pkg.t_tiny_id
        , i_negative_allowed    in com_api_type_pkg.t_boolean
        , i_account_name        in com_api_type_pkg.t_oracle_name
        , i_amount_name         in com_api_type_pkg.t_oracle_name
        , i_date_name           in com_api_type_pkg.t_oracle_name
        , i_posting_method      in com_api_type_pkg.t_dict_value
        , i_balance_type        in com_api_type_pkg.t_dict_value
        , i_balance_impact      in com_api_type_pkg.t_sign
        , i_dest_entity_type    in com_api_type_pkg.t_dict_value
        , i_dest_account_type   in com_api_type_pkg.t_dict_value
        , i_mod_id              in com_api_type_pkg.t_tiny_id default null
    );
    
    procedure modify (
        i_id                    in com_api_type_pkg.t_short_id
        , io_seqnum             in out com_api_type_pkg.t_seqnum
        , i_bunch_type_id       in com_api_type_pkg.t_tiny_id
        , i_transaction_type    in com_api_type_pkg.t_dict_value
        , i_transaction_num     in com_api_type_pkg.t_tiny_id
        , i_negative_allowed    in com_api_type_pkg.t_boolean
        , i_account_name        in com_api_type_pkg.t_oracle_name
        , i_amount_name         in com_api_type_pkg.t_oracle_name
        , i_date_name           in com_api_type_pkg.t_oracle_name
        , i_posting_method      in com_api_type_pkg.t_dict_value
        , i_balance_type        in com_api_type_pkg.t_dict_value
        , i_balance_impact      in com_api_type_pkg.t_sign
        , i_dest_entity_type    in com_api_type_pkg.t_dict_value
        , i_dest_account_type   in com_api_type_pkg.t_dict_value
        , i_mod_id              in com_api_type_pkg.t_tiny_id default null
    );
    
    procedure remove (
        i_id                    in com_api_type_pkg.t_short_id
        , i_seqnum              in com_api_type_pkg.t_seqnum
    );
    
    procedure add_pair (
        o_debit_id                     out com_api_type_pkg.t_short_id
        , o_debit_seqnum               out com_api_type_pkg.t_seqnum
        , o_credit_id                  out com_api_type_pkg.t_short_id
        , o_credit_seqnum              out com_api_type_pkg.t_seqnum
        , i_bunch_type_id              in com_api_type_pkg.t_tiny_id
        , i_transaction_type           in com_api_type_pkg.t_dict_value
        , i_transaction_num            in com_api_type_pkg.t_tiny_id
        , i_negative_allowed           in com_api_type_pkg.t_boolean
        , i_date_name                  in com_api_type_pkg.t_oracle_name
        , i_debit_amount_name          in com_api_type_pkg.t_oracle_name
        , i_debit_account_name         in com_api_type_pkg.t_oracle_name
        , i_debit_posting_method       in com_api_type_pkg.t_dict_value
        , i_debit_balance_type         in com_api_type_pkg.t_dict_value
        , i_debit_dest_entity_type     in com_api_type_pkg.t_dict_value
        , i_debit_dest_account_type    in com_api_type_pkg.t_dict_value
        , i_credit_amount_name         in com_api_type_pkg.t_oracle_name
        , i_credit_account_name        in com_api_type_pkg.t_oracle_name
        , i_credit_posting_method      in com_api_type_pkg.t_dict_value
        , i_credit_balance_type        in com_api_type_pkg.t_dict_value
        , i_credit_dest_entity_type    in com_api_type_pkg.t_dict_value
        , i_credit_dest_account_type   in com_api_type_pkg.t_dict_value
        , i_debit_mod_id               in com_api_type_pkg.t_tiny_id default null
        , i_credit_mod_id              in com_api_type_pkg.t_tiny_id default null
    );

end;
/