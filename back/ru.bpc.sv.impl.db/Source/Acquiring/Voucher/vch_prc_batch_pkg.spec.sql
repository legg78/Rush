create or replace package vch_prc_batch_pkg as
/*********************************************************
*  API for voucher batches processing  <br />
*  Created by Fomichev A.(fomichev@bpcbt.com)  at 21.03.2012 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::       $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: vch_prc_batch_pkg<br />
*  @headcom
**********************************************************/
procedure create_operations(
    i_inst_id  in   com_api_type_pkg.t_inst_id
);

end;
/
