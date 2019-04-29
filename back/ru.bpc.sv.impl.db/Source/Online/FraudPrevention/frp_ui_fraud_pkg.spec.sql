create or replace package frp_ui_fraud_pkg as
/*************************************************************
*
*   User Interface procedures for FRP fraud
*
* Created by Kondratyev A.(fomichev@bpc.ru)  at 10.06.2014
* Last changed by $Author: kondratyev $
* $LastChangedDate:: 2014-06-10 12:40:00 +0400#$
* Revision: $LastChangedRevision: 3500 $
* Module: FRP_UI_FRAUD_PKG
* @headcom
*
*************************************************************/

procedure modify_fraud(
    i_id           in      com_api_type_pkg.t_long_id
  , io_seqnum      in out  com_api_type_pkg.t_seqnum
  , i_resolution   in      com_api_type_pkg.t_dict_value
);

end;
/