create or replace package rus_api_const_pkg is
/*********************************************************
 *  constants for RUS module <br />
 *  Created by Fomichev A.(fomichev@bpcbt.com)  at 15.02.2012 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: rus_api_const_pkg<br />
 *  @headcom
 **********************************************************/

------- PMO PARAMETERS
CBS_TRANSFER_BIC                constant  com_api_type_pkg.t_name := 'CBS_TRANSFER_BIC';
CBS_TRANSFER_BANK_NAME          constant  com_api_type_pkg.t_name := 'CBS_TRANSFER_BANK_NAME';
CBS_TRANSFER_BANK_BRANCH_NAME   constant  com_api_type_pkg.t_name := 'CBS_TRANSFER_BANK_BRANCH_NAME';
CBS_TRANSFER_RECIPIENT_ACCOUNT  constant  com_api_type_pkg.t_name := 'CBS_TRANSFER_RECIPIENT_ACCOUNT';
CBS_TRANSFER_RECIPIENT_TAX_ID   constant  com_api_type_pkg.t_name := 'CBS_TRANSFER_RECIPIENT_TAX_ID';
CBS_TRANSFER_RECIPIENT_NAME     constant  com_api_type_pkg.t_name := 'CBS_TRANSFER_RECIPIENT_NAME';
CBS_TRANSFER_PAYER_NAME         constant  com_api_type_pkg.t_name := 'CBS_TRANSFER_PAYER_NAME';
CBS_TRANSFER_PAYMENT_PURPOSE    constant  com_api_type_pkg.t_name := 'CBS_TRANSFER_PAYMENT_PURPOSE';
CBS_TRANSFER_BANK_CORR_ACC      constant  com_api_type_pkg.t_name := 'CBS_TRANSFER_BANK_CORR_ACC';
CBS_TRANSFER_BANK_CITY          constant  com_api_type_pkg.t_name := 'CBS_TRANSFER_BANK_CITY';

------- FIEXIBLE FIELDS

PRESENCE_ON_LOCATION            constant  com_api_type_pkg.t_name := 'PRESENCE_ON_LOCATION';
AUTHORIZED_CAPITAL              constant  com_api_type_pkg.t_name := 'AUTHORIZED_CAPITAL';
CORRESPONDENT_ACCOUNT           constant  com_api_type_pkg.t_name := 'CORRESPONDENT_ACCOUNT';
AUTHORIZED_CAPITAL_CURRENCY     constant  com_api_type_pkg.t_name := 'AUTHORIZED_CAPITAL_CURRENCY';
FLX_BANK_ID_CODE                constant  com_api_type_pkg.t_name := 'FLX_BANK_ID_CODE';
FLX_TAX_ID                      constant  com_api_type_pkg.t_name := 'FLX_TAX_ID';

CUSTOMER_CAT_NON_PERSONIF       constant  com_api_type_pkg.t_dict_value   := 'CCTG5001';
CUSTOMER_CAT_PERSONIFIED        constant  com_api_type_pkg.t_dict_value   := 'CCTG5002';
CUSTOMER_CAT_BANKING            constant  com_api_type_pkg.t_dict_value   := 'CCTG5003';

ACCOUNT_PREFIX_ELECTRONIC_FUND  constant  com_api_type_pkg.t_account_number := '40903';
ACCOUNT_PREFIX_CREDIT_ORGANIZ   constant  com_api_type_pkg.t_account_number := '302';

ACCOUNT_PREFIX_PERSONAL_ARRAY   constant com_api_type_pkg.t_short_id := 10000060;

OPER_INCREASE_AMOUNT_ARRAY      constant com_api_type_pkg.t_short_id := 10000061;
OPER_DECREASE_AMOUNT_ARRAY      constant com_api_type_pkg.t_short_id := 10000062;
OPER_CASH_OUT_ARRAY             constant com_api_type_pkg.t_short_id := 10000063;
OPER_MONEY_TRUNSFER_ARRAY       constant com_api_type_pkg.t_short_id := 10000064;
OPER_US_ON_THEM_ARRAY           constant com_api_type_pkg.t_short_id := 10000067;
OPER_THEM_ON_US_ARRAY           constant com_api_type_pkg.t_short_id := 10000068;

MACROS_TYPE_ARRAY               constant com_api_type_pkg.t_short_id := 10000065;
BALANCE_TYPE_ARRAY              constant com_api_type_pkg.t_short_id := 10000066;

COUNTRY_RUSSIA                  constant com_api_type_pkg.t_country_code := '643';

end;
/

