create or replace package cst_smn_api_const_pkg as
/**********************************************************
 * Constants for use in saman custom <br />
 * Created by Gogolev I.(i.gogolev@bpcbt.com) at 16.03.2018 <br />
 * <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: CST_SMN_API_CONST_PKG
 * @headcom
 **********************************************************/
FILE_TYPE_ACQ_FIN_SHETAB        constant    com_api_type_pkg.t_dict_value   := 'FLTP5911';
FILE_TYPE_ISS_FIN_SHETAB        constant    com_api_type_pkg.t_dict_value   := 'FLTP5912';
FILE_TYPE_ISS_SCS_FIN_SHETAB    constant    com_api_type_pkg.t_dict_value   := 'FLTP5913';
FILE_TYPE_DAILY_FIN_SHETAB      constant    com_api_type_pkg.t_dict_value   := 'FLTP5921';

ARRAY_TYPE_OPTP_CODE_SHETAB     constant    com_api_type_pkg.t_tiny_id      := -5018;
ARRAY_TYPE_TRMT_CODE_SHETAB     constant    com_api_type_pkg.t_tiny_id      := -5019;
ARRAY_TYPE_PRTY_CODE_SHETAB     constant    com_api_type_pkg.t_tiny_id      := -5020;
ARRAY_TYPE_FNOT_CODE_SHETAB     constant    com_api_type_pkg.t_tiny_id      := -5022;

ARRAY_LIST_OPTP_CODE_SHETAB     constant    com_api_type_pkg.t_medium_id    := -50000044;
ARRAY_LIST_TRMT_CODE_SHETAB     constant    com_api_type_pkg.t_medium_id    := -50000045;
ARRAY_OPER_PRTY_921_SHETAB      constant    com_api_type_pkg.t_medium_id    := -50000046;
ARRAY_LIST_PRTY_CODE_SHETAB     constant    com_api_type_pkg.t_medium_id    := -50000047;
ARRAY_LIST_FNOT_CODE_SHETAB     constant    com_api_type_pkg.t_medium_id    := -50000049;
ARRAY_OPER_TYPE_911_SHETAB      constant    com_api_type_pkg.t_medium_id    := -50000050;
ARRAY_OPER_TYPE_912_SHETAB      constant    com_api_type_pkg.t_medium_id    := -50000051;
ARRAY_OPER_TYPE_913_SHETAB      constant    com_api_type_pkg.t_medium_id    := -50000052;
ARRAY_OPER_TYPE_921_SHETAB      constant    com_api_type_pkg.t_medium_id    := -50000053;
ARRAY_LIST_TRMT_DG_CODE_SHETAB  constant    com_api_type_pkg.t_medium_id    := -50000054;

SHETAB_FUNC_OPTP_CODE_TTA       constant    com_api_type_pkg.t_dict_value   := 'TTA';  -- Account transfer transaction
SHETAB_FUNC_OPTP_CODE_TFA       constant    com_api_type_pkg.t_dict_value   := 'TFA';  -- Transaction for transfer from card for deposit to account
SHETAB_FUNC_OPTP_CODE_FIN       constant    com_api_type_pkg.t_dict_value   := 'FIN';  -- Inquiry for financial operation
SHETAB_FUNC_OPTP_CODE_SSP       constant    com_api_type_pkg.t_dict_value   := 'SSP';  -- Specific shetab purchase
SHETAB_FUNC_OPTP_CODE_RFC       constant    com_api_type_pkg.t_dict_value   := 'RFC';  -- Purchase return transaction-full
SHETAB_FUNC_OPTP_CODE_RFP       constant    com_api_type_pkg.t_dict_value   := 'RFP';  -- Purchase return transaction- partial

SHETAB_OPTP_CODE_TF             constant    com_api_type_pkg.t_byte_char    := 'TF';   -- Transfer (debit from)
SHETAB_OPTP_CODE_TT             constant    com_api_type_pkg.t_byte_char    := 'TT';   -- Transfer (deposit to)
SHETAB_OPTP_CODE_PU             constant    com_api_type_pkg.t_byte_char    := 'PU';   -- Purchase
SHETAB_OPTP_CODE_WD             constant    com_api_type_pkg.t_byte_char    := 'WD';   -- Withdrawal
SHETAB_OPTP_CODE_BI             constant    com_api_type_pkg.t_byte_char    := 'BI';   -- Inquiry for balance
SHETAB_OPTP_CODE_RF             constant    com_api_type_pkg.t_byte_char    := 'RF';   -- Back purchase transaction

SHETAB_STMT_CODE_WD_ATM         constant    com_api_type_pkg.t_dict_value   := 141;
SHETAB_STMT_CODE_WD_OTHER       constant    com_api_type_pkg.t_dict_value   := 446;
SHETAB_STMT_CODE_PU_EPOS        constant    com_api_type_pkg.t_dict_value   := 448;
SHETAB_STMT_CODE_PU_OTHER       constant    com_api_type_pkg.t_dict_value   := 444;
SHETAB_STMT_CODE_BI             constant    com_api_type_pkg.t_dict_value   := 458;
SHETAB_STMT_CODE_RF             constant    com_api_type_pkg.t_dict_value   := 090;
SHETAB_STMT_CODE_TT             constant    com_api_type_pkg.t_dict_value   := 252;
SHETAB_STMT_CODE_TF             constant    com_api_type_pkg.t_dict_value   := 253;

SHETAB_TRMN_TYPE_ATM            constant    com_api_type_pkg.t_dict_value   := 'ATM';
SHETAB_TRMN_TYPE_IPOS           constant    com_api_type_pkg.t_dict_value   := 'INT';

end cst_smn_api_const_pkg;
/
