create or replace package cst_tie_api_const_pkg is

-- Purpose : Tieto Financial message constants

MTI_PRESENTMENT              constant cst_tie_api_type_pkg.t_mti default '1240'; -- Presentment transaction record
MTI_RETRIEVAL_REQUEST        constant cst_tie_api_type_pkg.t_mti default '1644'; -- Retrieval request, retrieval request response

TC_PURCHASE                   constant cst_tie_api_type_pkg.t_tran_type default '00'; -- Purchases
TC_REFUND                     constant cst_tie_api_type_pkg.t_tran_type default '20'; -- Refund purchases
TC_CASH                       constant cst_tie_api_type_pkg.t_tran_type default '01'; -- Cash advance
TC_DEPOSIT                    constant cst_tie_api_type_pkg.t_tran_type default '21'; -- Deposit

FILE_TYPE_CLEARING            constant com_api_type_pkg.t_dict_value:= 'FLTP5005';

--SEND_CMI                      constant com_api_type_pkg.t_name:= 'SEND_CMI';
--SETTL_CMI                     constant com_api_type_pkg.t_name:= 'SETTL_CMI';
--USE_AUTH_ACQ_BIN_AS_SEND_CMI  constant com_api_type_pkg.t_name:= 'USE_AUTH_ACQ_BIN_AS_SEND_CMI';
--CENTER_CODE                   constant com_api_type_pkg.t_name:= 'CENTER_CODE';

end cst_tie_api_const_pkg;
/
