create or replace package tie_api_const_pkg is

-- Purpose : KONTS Financial message constants

MTID_HEADER                   constant tie_api_type_pkg.t_mtid default '00';
MTID_PRESENTMENT              constant tie_api_type_pkg.t_mtid default '10'; -- Presentment transaction record
MTID_PRESENTMENT_CHIP         constant tie_api_type_pkg.t_mtid default '11'; -- Presentment transaction's  CHIP additional record, i.e. mtid='10'
MTID_DISPUTE                  constant tie_api_type_pkg.t_mtid default '12'; -- Reserved 1.chargeback, 2. Presentment, arbitration chargeback and reverse of all above
MTID_DISPUTE_CHIP             constant tie_api_type_pkg.t_mtid default '13'; -- Reserved for chargeback CHIP related data
MTID_FEE                      constant tie_api_type_pkg.t_mtid default '14'; -- Reserved fee collections and funds disbursements and reversals
MTID_ACQ_FEFERENCE_DATA       constant tie_api_type_pkg.t_mtid default '15'; -- Acquirer reference data of the transaction
MTID_DETAIL                   constant tie_api_type_pkg.t_mtid default '20'; -- Detail record of  the presentment record i.e. mtid='10'
MTID_AMEX_DETAIL              constant tie_api_type_pkg.t_mtid default '21'; -- AMEX detail record
MTID_RETRIEVAL_REQUEST        constant tie_api_type_pkg.t_mtid default '50'; -- Retrieval request, retrieval request response
MTID_TRAILER                  constant tie_api_type_pkg.t_mtid default '99'; -- Trailer

TC_PURCHASE                   constant tie_api_type_pkg.t_tran_type default '05'; -- Purchases
TC_REFUND                     constant tie_api_type_pkg.t_tran_type default '06'; -- Refund purchases
TC_CASH                       constant tie_api_type_pkg.t_tran_type default '07'; -- Cash advance
TC_DEPOSIT                    constant tie_api_type_pkg.t_tran_type default '08'; -- Deposit
TC_CASHBACK                   constant tie_api_type_pkg.t_tran_type default '09'; -- Cashback

TC_PURCHASE_REVERSAL          constant tie_api_type_pkg.t_tran_type default '25'; -- Purchases reversal
TC_REFUND_REVERSAL            constant tie_api_type_pkg.t_tran_type default '26'; -- Refund purchases reversal
TC_CASH_REVERSAL              constant tie_api_type_pkg.t_tran_type default '27'; -- Cash advance reversal
TC_DEPOSIT_REVERSAL           constant tie_api_type_pkg.t_tran_type default '28'; -- Deposit reversal
TC_CASHBACK_REVERSAL          constant tie_api_type_pkg.t_tran_type default '29'; -- Cashback reversal

FILE_TYPE_CLEARING            constant com_api_type_pkg.t_dict_value:= 'FLTPCTIE';

FILE_TYPE_L                   constant com_api_type_pkg.t_name:= 'L';
FILE_TYPE_W                   constant com_api_type_pkg.t_name:= 'W';
FILE_TYPE_N                   constant com_api_type_pkg.t_name:= 'N';
FILE_TYPE_D                   constant com_api_type_pkg.t_name:= 'D';
FILE_TYPE_B                   constant com_api_type_pkg.t_name:= 'B';

SEND_CMI                      constant com_api_type_pkg.t_name:= 'SEND_CMI';
SETTL_CMI                     constant com_api_type_pkg.t_name:= 'SETTL_CMI';
USE_AUTH_ACQ_BIN_AS_SEND_CMI  constant com_api_type_pkg.t_name:= 'USE_AUTH_ACQ_BIN_AS_SEND_CMI';
CENTER_CODE                   constant com_api_type_pkg.t_name:= 'CENTER_CODE';

end tie_api_const_pkg;
/
