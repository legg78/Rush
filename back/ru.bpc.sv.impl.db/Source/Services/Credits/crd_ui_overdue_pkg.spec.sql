create or replace package crd_ui_overdue_pkg as
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
) return com_api_type_pkg.t_boolean;

end crd_ui_overdue_pkg;
/
