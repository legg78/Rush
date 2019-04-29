create or replace package body acc_ui_entry_tpl_pkg is
/********************************************************* 
 *  Interface for entry transaction templates <br /> 
 *  Created by Khougaev A.(khougaev@bpcbt.com)  at 20.11.2009 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module: acc_ui_entry_tpl_pkg <br /> 
 *  @headcom 
 **********************************************************/ 
    function check_default_rec(i_id        in com_api_type_pkg.t_short_id)
             return com_api_type_pkg.t_boolean
    is
        l_result com_api_type_pkg.t_boolean := 0;
    begin
        select count(*) into l_result  
          from acc_entry_tpl_vw
         where (bunch_type_id, transaction_num, balance_impact) in
            (select bunch_type_id, transaction_num, balance_impact from acc_entry_tpl_vw where id = i_id)
            and mod_id is null
            and rownum<=1;
            
        return l_result;
    end;             

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
        , i_mod_id              in com_api_type_pkg.t_tiny_id
    ) is
    begin
        o_id := acc_entry_tpl_seq.nextval;
        o_seqnum := 1;
        insert into acc_entry_tpl_vw (
            id
            , seqnum
            , bunch_type_id
            , transaction_type
            , transaction_num
            , negative_allowed
            , account_name
            , amount_name
            , date_name
            , posting_method
            , balance_type
            , balance_impact
            , dest_entity_type
            , dest_account_type
            , mod_id
        ) values (
            o_id
            , o_seqnum
            , i_bunch_type_id
            , i_transaction_type
            , i_transaction_num
            , i_negative_allowed
            , i_account_name
            , i_amount_name
            , i_date_name
            , i_posting_method
            , i_balance_type
            , i_balance_impact
            , i_dest_entity_type
            , i_dest_account_type
            , i_mod_id
        );
        
        if check_default_rec( i_id =>  o_id) = com_api_const_pkg.false then
            com_api_error_pkg.raise_error(
                 i_error      => 'NO_DEFAULT_ENTITY'
                 , i_env_param1 => i_bunch_type_id
                 , i_env_param2 => i_transaction_num
                 , i_env_param3 => i_balance_impact
            );
        end if;         

    exception
        when dup_val_on_index then
            com_api_error_pkg.raise_error(
                i_error      => 'DUPLICATE_ENTRY_TEMPLATE' 
              , i_env_param1 => i_bunch_type_id
              , i_env_param2 => i_transaction_num
              , i_env_param3 => i_balance_impact
            );
    end;
    
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
        , i_mod_id              in com_api_type_pkg.t_tiny_id        
    ) is
    begin
        update acc_entry_tpl_vw
           set seqnum            = io_seqnum
             , bunch_type_id     = i_bunch_type_id
             , transaction_type  = i_transaction_type
             , transaction_num   = i_transaction_num
             , negative_allowed  = i_negative_allowed
             , account_name      = i_account_name
             , amount_name       = i_amount_name
             , date_name         = i_date_name
             , posting_method    = i_posting_method
             , balance_type      = i_balance_type
             , balance_impact    = i_balance_impact
             , dest_entity_type  = i_dest_entity_type
             
         where (bunch_type_id, transaction_num, balance_impact) in
               (select bunch_type_id, transaction_num, balance_impact from acc_entry_tpl_vw where id = i_id);
        
        io_seqnum := io_seqnum + 1;

        update acc_entry_tpl_vw
           set mod_id            = i_mod_id
               , dest_account_type = i_dest_account_type
         where id = i_id;        

        if check_default_rec( i_id =>  i_id) = com_api_const_pkg.false then
            com_api_error_pkg.raise_error(
                 i_error      => 'NO_DEFAULT_ENTITY'
                 , i_env_param1 => i_bunch_type_id
                 , i_env_param2 => i_transaction_num
                 , i_env_param3 => i_balance_impact
            );
        end if;
        
    exception
        when dup_val_on_index then
            com_api_error_pkg.raise_error(
                i_error      => 'DUPLICATE_ENTRY_TEMPLATE' 
              , i_env_param1 => i_bunch_type_id
              , i_env_param2 => i_transaction_num
              , i_env_param3 => i_balance_impact
            );
    end;
    
    procedure remove (
        i_id                    in com_api_type_pkg.t_short_id
        , i_seqnum              in com_api_type_pkg.t_seqnum
    ) is
      l_mod_id   com_api_type_pkg.t_tiny_id;   
    begin
        select max(mod_id) into l_mod_id
          from acc_entry_tpl_vw
         where id = i_id;
    
        if l_mod_id is not null then
                update
                    acc_entry_tpl_vw
                set
                    seqnum = i_seqnum
                where
                    id = i_id;
                   
                delete from
                    acc_entry_tpl_vw
                where
                    id = i_id;
            else
                update
                    acc_entry_tpl_vw
                set
                    seqnum = i_seqnum
                where (bunch_type_id, transaction_num, balance_impact) in
                    (select bunch_type_id, transaction_num, balance_impact from acc_entry_tpl_vw where id = i_id);
                   
                delete from
                    acc_entry_tpl_vw
                where (bunch_type_id, transaction_num, balance_impact) in
                    (select bunch_type_id, transaction_num, balance_impact from acc_entry_tpl_vw where id = i_id);           
        end if;
    end;
    
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
        , i_debit_mod_id               in com_api_type_pkg.t_tiny_id
        , i_credit_mod_id              in com_api_type_pkg.t_tiny_id
    ) is
    begin
        -- add debit entry template
        add (
            o_id                  => o_debit_id
            , o_seqnum            => o_debit_seqnum
            , i_bunch_type_id     => i_bunch_type_id
            , i_transaction_type  => i_transaction_type
            , i_transaction_num   => i_transaction_num
            , i_negative_allowed  => i_negative_allowed
            , i_account_name      => i_debit_account_name
            , i_amount_name       => i_debit_amount_name
            , i_date_name         => i_date_name
            , i_posting_method    => i_debit_posting_method
            , i_balance_type      => i_debit_balance_type
            , i_balance_impact    => com_api_type_pkg.DEBIT
            , i_dest_entity_type  => i_debit_dest_entity_type
            , i_dest_account_type => i_debit_dest_account_type
            , i_mod_id            => i_debit_mod_id
        );

        -- add credit entry template
        add (
            o_id                  => o_credit_id
            , o_seqnum            => o_credit_seqnum
            , i_bunch_type_id     => i_bunch_type_id
            , i_transaction_type  => i_transaction_type
            , i_transaction_num   => i_transaction_num
            , i_negative_allowed  => i_negative_allowed
            , i_account_name      => i_credit_account_name
            , i_amount_name       => i_credit_amount_name
            , i_date_name         => i_date_name
            , i_posting_method    => i_credit_posting_method
            , i_balance_type      => i_credit_balance_type
            , i_balance_impact    => com_api_type_pkg.CREDIT
            , i_dest_entity_type  => i_credit_dest_entity_type
            , i_dest_account_type => i_credit_dest_account_type
            , i_mod_id            => i_credit_mod_id
        );
    exception
        when dup_val_on_index then
            com_api_error_pkg.raise_error (
                i_error => 'DUPLICATE_ENTRY_TEMPLATE'
            );
    end;

end;
/