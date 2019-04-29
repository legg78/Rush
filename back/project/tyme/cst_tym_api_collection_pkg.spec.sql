create or replace package cst_tym_api_collection_pkg is
/*********************************************************
 *  Custom accounts in collection export API <br />
 *  Created by Gerbeev I.(gerbeevbpcbt.com)  at 15.06.2018 <br />
 *  Last changed by $Author: gerbeev $ <br />
 *  $LastChangedDate:: 2018-06-15 12:00:00 +0400#$ <br />
 *  Revision: $LastChangedRevision: 00000 $ <br />
 *  Module: cst_tym_api_collection_pkg <br />
 *  @headcom
 **********************************************************/

procedure export_accounts(
    i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_ids_type          in      com_api_type_pkg.t_dict_value
  , i_account_type      in      com_api_type_pkg.t_dict_value   default acc_api_const_pkg.ACCOUNT_TYPE_CREDIT
  , i_account_status    in      com_api_type_pkg.t_dict_value   default null
  , i_min_aging_period  in      com_api_type_pkg.t_short_id     default null
);

end cst_tym_api_collection_pkg;
/
