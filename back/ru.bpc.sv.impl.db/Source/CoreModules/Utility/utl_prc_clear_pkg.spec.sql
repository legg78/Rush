create or replace package utl_prc_clear_pkg as
/**********************************************************
 * Deploy utilites<br/>
 * Created by Mashonkin V.(mashonkin@bpcbt.com)  at 11.06.2014<br/>
 * Last changed by $Author:  $<br/>
 * $LastChangedDate:: 2014-06-11 15:58:30 +0400 $<br/>
 * Revision: $LastChangedRevision: 40134 $<br/>
 * Module: UTL_PRC_CLEAR_PKG
 * @headcom
 **********************************************************/

C_CONFIRMATION_TEXT      constant  com_api_type_pkg.t_text  := 'i confirm deletion of all customer data';

-- Clear all data from non-config user tables
procedure clear_user_tables(
    i_test_option    in  com_api_type_pkg.t_dict_value default 'CLRM000T'
  , i_approvement    in  com_api_type_pkg.t_text
);

end utl_prc_clear_pkg;
/
