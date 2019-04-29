create or replace package body cst_icc_overdue_pkg as
/*********************************************************
*  API for overdue <br />
*  Created by  Y. Kolodkina(kolodkina@bpcbt.com)  at 18.10.2016 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: cst_icc_overdue_pkg <br />
*  @headcom
**********************************************************/

function check_account_in_overdue(
    i_account_id        in      com_api_type_pkg.t_account_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
)return com_api_type_pkg.t_boolean
is 
    l_invoice_id        com_api_type_pkg.t_medium_id;
    l_aging_period      com_api_type_pkg.t_tiny_id;
    l_is_mad_paid       com_api_type_pkg.t_boolean;
begin    
    l_invoice_id := 
        crd_invoice_pkg.get_last_invoice_id(
            i_account_id   => i_account_id
          , i_split_hash   => i_split_hash
          , i_mask_error   => com_api_const_pkg.TRUE
        );
    trc_log_pkg.debug (i_text        => 'l_invoice_id [' || l_invoice_id || ']');
        
    -- cann't be in overdue 
    if l_invoice_id is null then
    
        return com_api_const_pkg.TRUE;
        
    else
        select aging_period
             , is_mad_paid
          into l_aging_period
             , l_is_mad_paid
          from crd_invoice
         where id = l_invoice_id;                    
        
        if l_aging_period > 0 and l_is_mad_paid = com_api_const_pkg.FALSE then
    
            return com_api_const_pkg.FALSE;
        
        else 
        
            return com_api_const_pkg.TRUE;        
        end if;
    end if;
    
end;

end;
/
