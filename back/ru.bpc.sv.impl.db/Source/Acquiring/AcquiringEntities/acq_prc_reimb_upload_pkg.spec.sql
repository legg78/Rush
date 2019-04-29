create or replace package acq_prc_reimb_upload_pkg as
/*******************************************************************
*  Process upload  <br />
*  Created by Filimonov A.(filimonov@bpcbt.com)  at 12.01.2010 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: ACQ_PRC_REIMB_UPLOAD_PKG <br />
*  @headcom
******************************************************************/
procedure process(
    i_inst_id           in      com_api_type_pkg.t_inst_id
);

end acq_prc_reimb_upload_pkg;
/
