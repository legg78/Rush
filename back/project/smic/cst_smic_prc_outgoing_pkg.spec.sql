create or replace package cst_smic_prc_outgoing_pkg is
/*********************************************************
*  SMIC custom outgoing proceses <br />
*  Created by Gogolev I. (i.gogolev@bpcbt.com) at 01.03.2019 <br />
*  Module: CST_SMIC_PRC_OUTGOING_PKG <br />
*  @headcom
**********************************************************/

procedure uploading_rtgs(
    i_sttl_day                      in  com_api_type_pkg.t_short_id
  , i_account_type                  in  com_api_type_pkg.t_dict_value   default null
);

end cst_smic_prc_outgoing_pkg;
/
