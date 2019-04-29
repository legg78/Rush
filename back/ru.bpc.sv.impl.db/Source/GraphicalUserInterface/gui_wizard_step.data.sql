insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1001, 1, 1, 1, 'MbCardDetailsStep')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1002, 1, 1, 2, 'MbChangeCardStatusDataStep')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1003, 1, 1, 3, 'MbChangeCardStatusResultStep')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1004, 1, 2, 1, 'MbCardDetailsStep')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1005, 1, 2, 2, 'MbResetPinCounterDataStep')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1006, 1, 2, 3, 'MbResetPinCounterResultStep')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1010, 1, 1002, 1, 'MbCardDetailsStep')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1011, 1, 1002, 2, 'MbChangeLimitAmountDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1012, 1, 1002, 3, 'MbChangeLimitAmountRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1014, 1, 1003, 1, 'MbCardDetailsStep')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1015, 1, 1003, 2, 'MbManualFeeDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1016, 1, 1003, 3, 'MbManualFeeRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1017, 1, 1005, 1, 'MbAccDetailsStep')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1018, 1, 1005, 2, 'MbAccChngLimitAmtDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1019, 1, 1005, 3, 'MbChangeLimitAmountRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1020, 1, 1006, 1, 'MbAccDetailsStep')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1021, 1, 1006, 2, 'MbAccManualFeeDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1022, 1, 1006, 3, 'MbManualFeeRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1029, 1, 1011, 1, 'MbCardDetailsStep')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1030, 1, 1011, 2, 'MbSrvSelectionStep')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1031, 1, 1011, 3, 'MbSmsAttachRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1032, 1, 1012, 1, 'MbCardDetailsStep')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1033, 1, 1012, 2, 'MbDetachServiceDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1034, 1, 1012, 3, 'MbDetachServiceRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1035, 1, 1013, 1, 'MbCardDetailsStep')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1036, 1, 1013, 2, 'MbUnholdOprDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1037, 1, 1013, 3, 'MbUnholdOprRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1038, 1, 1014, 1, 'MbAccDetailsStep')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1039, 1, 1014, 2, 'MbBalanceCorrectionDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1040, 1, 1014, 3, 'MbBalanceCorrectionRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1025, 1, 1009, 1, 'MbCardDetailsStep')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1026, 1, 1009, 2, 'MbBalanceRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1027, 1, 1010, 1, 'MbAccDetailsStep')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1028, 1, 1010, 2, 'MbBalanceRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1044, 1, 1016, 10, 'MbCardDetailsStep')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1045, 1, 1016, 20, 'MbReverseOprDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1046, 1, 1016, 30, 'MbReverseOprRS')
/
delete gui_wizard_step where id = 1038
/
delete gui_wizard_step where id = 1041
/
delete gui_wizard_step where id = 1013
/
delete gui_wizard_step where id = 1017
/
delete gui_wizard_step where id = 1020
/
delete gui_wizard_step where id = 1027
/
delete gui_wizard_step where id = 1001
/
delete gui_wizard_step where id = 1004
/
delete gui_wizard_step where id = 1010
/
delete gui_wizard_step where id = 1014
/
delete gui_wizard_step where id = 1025
/
delete gui_wizard_step where id = 1029
/
delete gui_wizard_step where id = 1032
/
delete gui_wizard_step where id = 1035
/
delete gui_wizard_step where id = 1044
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1047, 1, 1017, 1, 'MbPurchaseStep')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1048, 1, 1017, 2, 'MbPurchaseResultStep')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1049, 1, 1018, 10, 'MbPreAuthDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1050, 1, 1018, 20, 'MbPurchaseResultStep')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1051, 1, 1019, 10, 'MbCompletionDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1052, 1, 1019, 20, 'MbPurchaseResultStep')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1053, 1, 1020, 10, 'MbCreditDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1054, 1, 1020, 20, 'MbPurchaseResultStep')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1055, 1, 1021, 10, 'MbCasheDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1056, 1, 1021, 20, 'MbPurchaseResultStep')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1057, 1, 1022, 10, 'MbReverseOprDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1058, 1, 1022, 20, 'MbReverseOprRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1059, 1, 1023, 10, 'MbReversalDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1060, 1, 1023, 20, 'MbPurchaseResultStep')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1061, 1, 1024, 10, 'MbAccountOperationDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1062, 1, 1024, 20, 'MbAccountOperationRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1063, 1, 1025, 20, 'MbChangeBatchCardsStatusDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1064, 1, 1025, 30, 'MbChangeBatchCardsStatusRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1066, 1, 1026, 30, 'MbChangeStatusRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1065, 1, 1026, 20, 'MbChangeStatusDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1067, 1, 1027, 20, 'MbAccountBalanceDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1068, 1, 1027, 30, 'MbAccountOperationRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1069, 1, 1028, 20, 'MbProvideCreditLimitDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1070, 1, 1028, 30, 'MbAccountOperationRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1073, 1, 1030, 20, 'MbChangeStatusOperationDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1074, 1, 1030, 30, 'MbChangeStatusOperationRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1075, 1, 1031, 10, 'MbMatchOperationDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1076, 1, 1031, 20, 'MbMatchOperationRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1077, 1, 1032, 10, 'MbChangeOperationsStatusDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1078, 1, 1032, 20, 'MbChangeOperationsStatusRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1079, 1, 1033, 10, 'MbMatchReverseOperationDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1080, 1, 1033, 20, 'MbMatchReverseOperationRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1081, 1, 1034, 10, 'MbChangeStatusCommonDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1082, 1, 1034, 20, 'MbChangeStatusCommonRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1083, 1, 1035, 20, 'MbCardOperationDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1084, 1, 1035, 30, 'MbCardOperationRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1085, 1, 1036, 10, 'MbAccountOperationWOProcessingDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1086, 1, 1036, 20, 'MbAccountOperationRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1088, 1, 1037, 30, 'MbFeeCollectionRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1087, 1, 1037, 20, 'MbFeeCollectionDS')
/
delete from gui_wizard_step where id=1045
/
delete from gui_wizard_step where id=1046
/
delete from gui_wizard_step where id=1057
/
delete from gui_wizard_step where id=1058
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1091, 1, 1039, 10, 'MbAccountFundsTransferDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1092, 1, 1039, 20, 'MbAccountFundsTransferRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1093, 1, 1040, 10, 'MbStopListTypeSelectionStep')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1094, 1, 1040, 20, 'MbStopListDataStepDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1095, 1, 1041, 10, 'MbFundsTranferBetweenAccountsDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1096, 1, 1041, 20, 'MbFundsTranferBetweenAccountsRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1097, 1, 1042, 10, 'MbFundsTranferBetweenAccountsDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1098, 1, 1042, 20, 'MbFundsTranferBetweenAccountsRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1099, 1, 1043, 10, 'MbAccountOperationDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1100, 1, 1043, 20, 'MbAccountOperationRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1101, 1, 1044, 10, 'MbAccountFundsTransferDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1102, 1, 1044, 20, 'MbAccountFundsTransferRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1103, 1, 1045, 10, 'MbProductAppInitializeDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1104, 1, 1045, 20, 'MbProductAppServiceTermsDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1105, 1, 1045, 30, 'MbProductAppCardTypesDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1106, 1, 1045, 40, 'MbProductAppAccountTypesDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1107, 1, 1045, 50, 'MbProductAppInfoRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1108, 1, 1046, 10, 'MbChangeFraudOperStatusDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1109, 1, 1046, 20, 'MbChangeFraudOperStatusRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1110, 1, 1047, 2, 'MbManualSendSmsDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1111, 1, 1047, 3, 'MbManualSendSmsRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1116, 1, 1050, 10, 'MbRewardsLoyaltyMerchantCardDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1117, 1, 1050, 20, 'MbRewardsLoyaltyOperationsDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1120, 1, 1052, 10, 'MbRepaymentDebtOperationDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1121, 1, 1052, 20, 'MbRepaymentDebtOperationRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1125, 1, 1055, 10, 'MbRestructureDebtInputDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1126, 1, 1055, 20, 'MbRestructureDebtCheckDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1127, 1, 1055, 30, 'MbRestructureDebtRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1128, 1, 1040, 15, 'MbStopListEventTypeSelectionStep')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1129, 1, 1056, 2, 'MbManualFeeAccDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1130, 1, 1056, 3, 'MbManualFeeAccRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1131, 1, 1057, 2, 'MbAccManualFeeAccDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1132, 1, 1057, 3, 'MbAccManualFeeAccRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1133, 1, 1058, 2, 'MbManualFeeAccRetDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1134, 1, 1058, 3, 'MbManualFeeAccRetRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1135, 1, 1059, 2, 'MbAccManualFeeAccRetDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1136, 1, 1059, 3, 'MbAccManualFeeAccRetRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1139, 1, 1063, 10, 'MbDualChangeCardStatusDataStep')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1140, 1, 1063, 20, 'MbChangeCardStatusResultStep')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1141, 1, 1064, 10, 'MbDualChangeLimitAmountDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1142, 1, 1064, 20, 'MbChangeLimitAmountRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1143, 1, 1065, 10, 'MbDualManualFeeDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1144, 1, 1065, 20, 'MbManualFeeRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1145, 1, 1066, 10, 'MbDualAccChngLimitAmtDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1146, 1, 1066, 20, 'MbChangeLimitAmountRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1147, 1, 1067, 10, 'MbDualAccManualFeeDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1148, 1, 1067, 20, 'MbManualFeeRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1149, 1, 1068, 10, 'MbDualSrvSelectionStep')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1150, 1, 1068, 20, 'MbSmsAttachRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1151, 1, 1069, 10, 'MbDualDetachServiceDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1152, 1, 1069, 20, 'MbDetachServiceRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1153, 1, 1070, 10, 'MbDualUnholdOprDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1154, 1, 1070, 20, 'MbUnholdOprRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1155, 1, 1071, 10, 'MbDualBalanceCorrectionDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1156, 1, 1071, 20, 'MbBalanceCorrectionRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1157, 1, 1072, 10, 'MbDualAccountOperationIssDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1158, 1, 1072, 20, 'MbAccountOperationRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1159, 1, 1073, 10, 'MbDualChangeStatusDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1160, 1, 1073, 20, 'MbChangeStatusRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1161, 1, 1074, 10, 'MbDualAccountBalanceDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1162, 1, 1074, 20, 'MbAccountOperationRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1163, 1, 1075, 10, 'MbDualProvideCreditLimitDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1164, 1, 1075, 20, 'MbAccountOperationRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1165, 1, 1076, 10, 'MbDualChangeStatusOperationDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1166, 1, 1076, 20, 'MbChangeStatusOperationRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1167, 1, 1077, 10, 'MbDualMatchOperationDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1168, 1, 1077, 20, 'MbMatchOperationRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1169, 1, 1078, 10, 'MbDualChangeOperationsStatusDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1170, 1, 1078, 20, 'MbChangeOperationsStatusRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1171, 1, 1079, 10, 'MbDualMatchReverseOperationDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1172, 1, 1079, 20, 'MbMatchReverseOperationRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1173, 1, 1080, 10, 'MbDualAccountOperationWOProcessingDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1174, 1, 1080, 20, 'MbAccountOperationRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1175, 1, 1081, 10, 'MbDualAccountFundsTransferDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1176, 1, 1081, 20, 'MbAccountFundsTransferRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1177, 1, 1082, 10, 'MbDualFundsTranferBetweenAccountsDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1178, 1, 1082, 20, 'MbFundsTranferBetweenAccountsRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1179, 1, 1083, 10, 'MbDualAccountOperationAcqDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1180, 1, 1083, 20, 'MbAccountOperationRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1181, 1, 1084, 10, 'MbDualChangeFraudOperStatusDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1182, 1, 1084, 20, 'MbChangeFraudOperStatusRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1183, 1, 1085, 10, 'MbDualBalanceTransferFromPrepaidCardDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1184, 1, 1085, 20, 'MbBalanceTransferFromPrepaidCardRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1185, 1, 1086, 10, 'MbRewardsLoyaltyMerchantCardDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1186, 1, 1086, 20, 'MbDualRewardsLoyaltyOperationsDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1187, 1, 1087, 10, 'MbDualCardOperationDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1188, 1, 1087, 20, 'MbCardOperationRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1189, 1, 1088, 10, 'MbDualCreditBalanceTransferDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1190, 1, 1088, 20, 'MbDualCreditBalanceTransferRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1191, 1, 1089, 10, 'MbDualRollbackCreditBalanceTransferDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1192, 1, 1089, 20, 'MbDualRollbackCreditBalanceTransferRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1195, 1, 1091, 10, 'MbReissueCardDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1196, 1, 1091, 20, 'MbApplicationIdRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1197, 1, 1092, 10, 'MbChangeCardProductDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1198, 1, 1092, 20, 'MbApplicationIdRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1199, 1, 1093, 10, 'MbChangeCardholderPhotoDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1200, 1, 1094, 10, 'MbDualCreateOperForNotRcnMsgDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1201, 1, 1094, 20, 'MbDualCreateOperForNotRcnMsgRS')
/
