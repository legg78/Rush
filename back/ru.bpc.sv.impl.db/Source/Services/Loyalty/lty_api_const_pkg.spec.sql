create or replace package lty_api_const_pkg is
/*********************************************************
 *  Constants for loyalty points <br />
 *  Created by Kopachev D.(kopachev@bpc.ru)  at 18.11.2009 <br />
 *  Module: LTY_API_CONST_PKG <br />
 *  @headcom
 **********************************************************/

BONUS_TRANSACTION_STATUS_KEY       com_api_type_pkg.t_dict_value := 'BNST';
BONUS_TRANSACTION_ACTIVE           com_api_type_pkg.t_dict_value := 'BNST0100';
BONUS_TRANSACTION_SPENT            com_api_type_pkg.t_dict_value := 'BNST0200';
BONUS_TRANSACTION_OUTDATED         com_api_type_pkg.t_dict_value := 'BNST0300';

LOYALTY_SERVICE_TYPE_ID            com_api_type_pkg.t_long_id    := 10000790;
LOYALTY_SERVICE_ACC_TYPE_ID        com_api_type_pkg.t_long_id    := 10003268;
LOYALTY_SERVICE_MRCH_TYPE_ID       com_api_type_pkg.t_long_id    := 10003241;
LOYALTY_SERVICE_CUST_TYPE_ID       com_api_type_pkg.t_long_id    := 10003422;

LOYALTY_ATTR_ACC_TYPE              com_api_type_pkg.t_name       := 'LTY_ACCOUNT_TYPE';
LOYALTY_ATTR_ACC_CURR              com_api_type_pkg.t_name       := 'LTY_ACCOUNT_CURRENCY';
LOYALTY_BONUS_START_DATE           com_api_type_pkg.t_name       := 'LTY_BONUS_START_DATE';
LOYALTY_BONUS_EXPIRE_DATE          com_api_type_pkg.t_name       := 'LTY_BONUS_EXPIRE_DATE';
LOYALTY_EXTERNAL_NUMBER            com_api_type_pkg.t_name       := 'LTY_EXTERNAL_NUMBER';
LOYALTY_ATTR_PROM_LEV_THRE_ACC     com_api_type_pkg.t_name       := 'LTY_PROMOTION_LEVEL_PRODUCT_ACCOUNT';
LOYALTY_ATTR_PROM_LEV_THRE_CAR     com_api_type_pkg.t_name       := 'LTY_PROMOTION_LEVEL_PRODUCT_CARD';
LOYALTY_ATTR_PROM_ALGORITH_ACC     com_api_type_pkg.t_name       := 'LTY_PROMOTION_ALGORITHM_ACCOUNT';
LOYALTY_ATTR_PROM_ALGORITH_CAR     com_api_type_pkg.t_name       := 'LTY_PROMOTION_ALGORITHM_CARD';

LOYALTY_FEE_TYPE                   com_api_type_pkg.t_name       := 'FETP1101';
LOYALTY_ACCOUNT_FEE_TYPE           com_api_type_pkg.t_name       := 'FETP0405';
LOYALTY_MERCHANT_FEE_TYPE          com_api_type_pkg.t_name       := 'FETP0220';
LOYALTY_BIRTHDAY_TRAN_FEE_TYPE     com_api_type_pkg.t_name       := 'FETP0149';
LOYALTY_REWARD_FEE_TYPE_CARD       com_api_type_pkg.t_name       := 'FETP0150';
LOYALTY_REWARD_FEE_TYPE_CUST       com_api_type_pkg.t_name       := 'FETP0908';
LOYALTY_REWARD_FEE_TYPE_ACCT       com_api_type_pkg.t_name       := 'FETP0413';
LOYALTY_REWARD_FEE_TYPE_MERCH      com_api_type_pkg.t_name       := 'FETP0224';

LOYALTY_CUSTOMER_FEE_TYPE          com_api_type_pkg.t_name       := 'FETP0905';
LOYALTY_REDEM_MIN_THR_FEE_TYPE     com_api_type_pkg.t_name       := 'FETP0223';
LOYALTY_ANNIV_BONUS_FEE_TYPE       com_api_type_pkg.t_name       := 'FETP0421';

LOYALTY_START_CYCLE_TYPE           com_api_type_pkg.t_name       := 'CYTP1102';
LOYALTY_ACC_START_CYCLE_TYPE       com_api_type_pkg.t_name       := 'CYTP0404';
LOYALTY_MRCH_START_CYCLE_TYPE      com_api_type_pkg.t_name       := 'CYTP0208';
LOYALTY_CUST_START_CYCLE_TYPE      com_api_type_pkg.t_name       := 'CYTP0907';
LOYALTY_EXPIRE_CYCLE_TYPE          com_api_type_pkg.t_name       := 'CYTP1103';
LOYALTY_ACC_EXPIRE_CYCLE_TYPE      com_api_type_pkg.t_name       := 'CYTP0405';
LOYALTY_MRCH_EXPIRE_CYCLE_TYPE     com_api_type_pkg.t_name       := 'CYTP0209';
LOYALTY_CUST_EXPIRE_CYCLE_TYPE     com_api_type_pkg.t_name       := 'CYTP0908';
LOYALTY_BIRTHDAY_CYCLE_TYPE        com_api_type_pkg.t_name       := 'CYTP1105';
LOYALTY_PROM_LEV_THRES_CYC_ACC     com_api_type_pkg.t_name       := 'CYTP0420';
LOYALTY_PROM_LEV_THRES_CYC_CAR     com_api_type_pkg.t_name       := 'CYTP0140';

LTY_MRCH_RWRD_RDMPT_CYC_TYPE       com_api_type_pkg.t_name       := 'CYTP0213';
LTY_MRCH_RWRD_RDMPT_FEE_TYPE       com_api_type_pkg.t_name       := 'FETP0230';

LOYALTY_ATTR_BONUS_RATE            com_api_type_pkg.t_name       := 'LTY_BONUS_RATE';
LOYALTY_ATTR_POINT_NAME            com_api_type_pkg.t_name       := 'LTY_POINT_NAME';

LOYALTY_OUTDATE_BUNCH_TYPE         com_api_type_pkg.t_name       := 'LTY_OUTDATE_BUNCH_TYPE';
LOYALTY_EXPORT_FILE_TYPE           com_api_type_pkg.t_dict_value := 'FLTPELTY';
LOYALTY_MANUAL_REDEMPTION          com_api_type_pkg.t_dict_value := 'OPTP1102';

LOYALTY_START_DATE_PARAM           com_api_type_pkg.t_dict_value := 'DTPR1101';
LOYALTY_EXPIRE_DATE_PARAM          com_api_type_pkg.t_dict_value := 'DTPR1101';

BONUS_CREATION_EVENT               com_api_type_pkg.t_dict_value := 'EVNT1103';
BONUS_SPEND_EVENT                  com_api_type_pkg.t_dict_value := 'EVNT1104';
BONUS_MOVE_EVENT                   com_api_type_pkg.t_dict_value := 'EVNT1112';
LOTTERY_TICKET_CREATION_EVENT      com_api_type_pkg.t_dict_value := 'EVNT1109';
ENTITY_TYPE_BONUS                  com_api_type_pkg.t_dict_value := 'ENTTLBNS';
ENTITY_TYPE_LOTTERY_TICKET         com_api_type_pkg.t_dict_value := 'ENTTLTTK';

LOYALTY_LIMIT_REWARD_CARD          com_api_type_pkg.t_dict_value := 'LMTP0142';
LOYALTY_LIMIT_REWARD_CUSTOMER      com_api_type_pkg.t_dict_value := 'LMTP0905';
LOYALTY_LIMIT_REWARD_ACCOUNT       com_api_type_pkg.t_dict_value := 'LMTP0410';
LOYALTY_LIMIT_REWARD_MERCHANT      com_api_type_pkg.t_dict_value := 'LMTP0204';

LOTTERY_TICKET_THRESHOLD           com_api_type_pkg.t_dict_value := 'LMTP0144';
LOTTERY_TICKET_THRESHOLD_CUST      com_api_type_pkg.t_dict_value := 'LMTP0904';

LOYALTY_PROM_LEV_THRES_LIM_ACC     com_api_type_pkg.t_dict_value := 'LMTP0424';
LOYALTY_PROM_LEV_THRES_LIM_CAR     com_api_type_pkg.t_dict_value := 'LMTP0145';

LOTTERY_TICKET_STATUS_KEY          com_api_type_pkg.t_dict_value := 'LTKS';
LOTTERY_TICKET_ACTIVE              com_api_type_pkg.t_dict_value := 'LTKSACTV';
LOTTERY_TICKET_CLOSED              com_api_type_pkg.t_dict_value := 'LTKSCLSD';

LTY_RWRD_ENROLL_MACROS_TYPE_ID     com_api_type_pkg.t_short_id   := 1027;

LTY_RWRD_STATUS_ACTIVE             com_api_type_pkg.t_dict_value := 'RLTS0100';
LTY_RWRD_STATUS_SPENT              com_api_type_pkg.t_dict_value := 'RLTS0200';

end lty_api_const_pkg;
/
