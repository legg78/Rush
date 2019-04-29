create or replace package body crd_ui_overdue_pkg as
/*********************************************************
*  User interface crd_overdue_pkg <br />
*  Created by  I. Gogolev(i.gogolev@bpc.ru)  at 07.11.2017 <br />
*  Last changed by $Author: $ <br />
*  $LastChangedDate: $ <br />
*  Revision: $LastChangedRevision: $ <br />
*  Module: crd_ui_overdue_pkg <br />
*  @headcom
**********************************************************/
function check_mad_aging_indebtedness(
    i_account_id        in      com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_boolean
is
begin
    crd_overdue_pkg.check_mad_aging_indebtedness(
        i_account_id => i_account_id
    );
    return com_api_const_pkg.TRUE;
exception
    when others then
        if com_api_error_pkg.is_application_error(code => sqlcode) = com_api_const_pkg.TRUE
            or com_api_error_pkg.is_fatal_error(code => sqlcode) = com_api_const_pkg.TRUE then
            return com_api_const_pkg.FALSE;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;
end check_mad_aging_indebtedness;

end crd_ui_overdue_pkg;
/
