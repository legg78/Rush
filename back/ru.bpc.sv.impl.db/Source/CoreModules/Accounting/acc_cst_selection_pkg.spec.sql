create or replace package acc_cst_selection_pkg is
/*********************************************************
 *  The package with user-exits for custom address elements <br />
 *  Created by Alalykin A. (alalykin@bpcbt.com) at 10.04.2017 <br />
 *  Module: ACC_CST_SELECTION_PKG <br />
 *  @headcom
 **********************************************************/

/*
 * Modify (extend) parameter list for using in modifiers on selecting account in acc_api_selection_pkg.get_account().
 */
procedure modify_params(
    io_params                   in out nocopy com_api_type_pkg.t_param_tab
);

end;
/
