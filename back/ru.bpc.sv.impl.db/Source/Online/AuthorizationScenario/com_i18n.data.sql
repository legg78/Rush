-- COM_DICTIONARY(ASTP)
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000004813, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10000524, 'Authorization scenario state type')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000004815, 'LANGENG', '', 'COM_DICTIONARY', 'DESCRIPTION', 10000525, 'State A is intended to call authorization procedure plugin and perform authorization actions provided by this plugin.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000004814, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10000525, 'Execution of predefined authorization procedure')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000004817, 'LANGENG', '', 'COM_DICTIONARY', 'DESCRIPTION', 10000526, 'State B is intended to send message to external system in order to obtain additional data or to perfom additional authorization or just to inform external system about operation.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000004816, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10000526, 'Sending request to external system')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000004819, 'LANGENG', '', 'COM_DICTIONARY', 'DESCRIPTION', 10000527, 'State C is intended to send SMS or e-mail to message delivery system in order to inform cardholder, customer, operator, etc. about authorization of operation.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000004818, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10000527, 'Stakeholders notification')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000004821, 'LANGENG', '', 'COM_DICTIONARY', 'DESCRIPTION', 10000528, 'State D is intended to send operation into BackOffice system for further batch processing of operations.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000004820, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10000528, 'Sending operation to BackOffice')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000004823, 'LANGENG', '', 'COM_DICTIONARY', 'DESCRIPTION', 10000529, 'State E is intended to send operation result to operation originator, i.e. module of origin or device of origin that communicates with one of the system modules.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000004822, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10000529, 'Sending response to operation originator')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000004825, 'LANGENG', '', 'COM_DICTIONARY', 'DESCRIPTION', 10000530, 'State F is intended to create new operation based on current operation data, to conduct new operation and to estimate its result.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000004824, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10000530, 'Creation of additional subordinate operation')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000004827, 'LANGENG', '', 'COM_DICTIONARY', 'DESCRIPTION', 10000531, 'State G is intended to describe scenario execution alternatives depending on value of operation parameters.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000004826, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10000531, 'Conditional jump')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000004829, 'LANGENG', '', 'COM_DICTIONARY', 'DESCRIPTION', 10000532, 'State H is intended to stop operation execution during specified period of time.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000004828, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10000532, 'Hold up operation')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000004831, 'LANGENG', '', 'COM_DICTIONARY', 'DESCRIPTION', 10000533, 'State I is intended to authorize operation by means of external card issuing system (IPN, processing centres, CBS).')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000004830, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10000533, 'Sending request to card issuer')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000004833, 'LANGENG', '', 'COM_DICTIONARY', 'DESCRIPTION', 10000534, 'State J is intended to call custom user-defined stored procedure which can be customized by customer itself.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000004832, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10000534, 'Execution of custom authorization procedure')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000005064, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10000565, 'End scenario processing')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000005065, 'LANGENG', '', 'COM_DICTIONARY', 'DESCRIPTION', 10000565, 'State Z is intended to mark endpoint of authorization scenario.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000014229, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10000969, 'Mark as complete')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000014230, 'LANGENG', '', 'COM_DICTIONARY', 'DESCRIPTION', 10000969, 'State K is intended to set authorization completion flag. Authorization can be considered as complete after successful processing of such state.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000132355, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10002450, 'Fraud monitoring')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000132356, 'LANGENG', '', 'COM_DICTIONARY', 'DESCRIPTION', 10002450, 'State L is used to call fraud prevention checks for card, account, terminal and/or merchant.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000017949, 'LANGENG', '', 'COM_DICTIONARY', 'DESCRIPTION', 10002964, 'State M is used to interact with payment aggregators in order to provide generic payment functionality')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000017948, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10002964, 'Send data to payment aggregator')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000018363, 'LANGENG', '', 'COM_DICTIONARY', 'DESCRIPTION', 10003001, 'State S is used to call all procedures linked to specified processing stage')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000018362, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10003001, 'Processing stage execution')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000023748, 'LANGENG', null, 'COM_DICTIONARY', 'NAME', 10003614, 'Set Payment Order Status')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000023749, 'LANGENG', null, 'COM_DICTIONARY', 'DESCRIPTION', 10003614, 'Plugin sets Payment Order Status when Authorization state M returns by timeout error')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000135992, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10003801, 'Payment service list selection')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000135993, 'LANGENG', NULL, 'COM_DICTIONARY', 'DESCRIPTION', 10003801, 'Plugin is used to select list of services that can be payed using specified authorization environment (terminal type, customer type, etc.)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000135994, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10003802, 'Payment provider list selection')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000135995, 'LANGENG', NULL, 'COM_DICTIONARY', 'DESCRIPTION', 10003802, 'Plugin is used to select list of payment providers for specified service with respect to authorization environment (terminal type, customer type, etc.)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000135996, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10003803, 'Payment parameters data selection')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000135997, 'LANGENG', NULL, 'COM_DICTIONARY', 'DESCRIPTION', 10003803, 'Plugin is used to select list of payment parameters for specified service and service provider.')
/


-- COM_DICTIONARY(ENTT)
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000005013, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10000555, 'Authorization scenario')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000005014, 'LANGENG', '', 'COM_DICTIONARY', 'DESCRIPTION', 10000555, 'Online authorization scenario, i.e. algorithm of routing and online authorization checks application.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000005015, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10000556, 'Authorization scenario state')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000005016, 'LANGENG', '', 'COM_DICTIONARY', 'DESCRIPTION', 10000556, 'Online authorization scenario state, i.e. specification of operation that should be performed on particular scenario step, for instance, routing to issuer, call to authorization procedure and so on.')
/


-- COM_DICTIONARY(ATHP)
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000015760, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10001105, 'Authorization procedure plugin')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000119587, 'LANGENG', '', 'COM_DICTIONARY', 'DESCRIPTION', 10001679, 'Plugin is used to select list of available card accounts of specified type, that is suitable for specified operation type')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000119586, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10001679, 'Accounts list selection plugin')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000119677, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10001701, 'Statement processing')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000119678, 'LANGENG', '', 'COM_DICTIONARY', 'DESCRIPTION', 10001701, 'Plugin is used to obtain history of operation done by specified card')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000119842, 'LANGENG', '', 'COM_DICTIONARY', 'DESCRIPTION', 10001710, 'Plugin is used to communicate with HSM in order to ensure PIN correctness')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000119841, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10001710, 'PIN checking plugin')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000119845, 'LANGENG', '', 'COM_DICTIONARY', 'DESCRIPTION', 10001711, 'Plugin is used to perform CVV, CVV2, AVV, CAVV checks.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000119844, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10001711, 'Security checks plugin')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000121151, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10002022, 'Authorization generate plugin')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000122593, 'LANGENG', '', 'COM_DICTIONARY', 'DESCRIPTION', 10002288, 'Plugin is used to create virtual card with specified type, limits, currency and expiration date.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000122592, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10002288, 'Create virtual card')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000122591, 'LANGENG', '', 'COM_DICTIONARY', 'DESCRIPTION', 10002287, 'Plugin is used to obtain available virtual card types.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000122590, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10002287, 'Get virtual card types')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000122908, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10002339, 'Authorization notification type and direction')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000122912, 'LANGENG', '', 'COM_DICTIONARY', 'DESCRIPTION', 10002341, 'Notify merchants or other authorization originators')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000122911, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10002341, 'Acquirer-related notification')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000122914, 'LANGENG', '', 'COM_DICTIONARY', 'DESCRIPTION', 10002342, 'Notify customer, cardholder, merchant, etc.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000122913, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10002342, 'Notification of acquirer and issuer parties')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000122910, 'LANGENG', '', 'COM_DICTIONARY', 'DESCRIPTION', 10002340, 'Notification of customer, cardholder, etc.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000122909, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10002340, 'Issuer-related notification')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000020362, 'LANGENG', null, 'COM_DICTIONARY', 'NAME', 10003179, 'Schedule registration')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000020363, 'LANGENG', null, 'COM_DICTIONARY', 'DESCRIPTION', 10003179, 'Plugin is used by schedule registering authorizations in order to set up schedule for future authorization.')
/




-- COM_DICTIONARY(SPLP)
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000123122, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10002363, 'Authorization splitting plugin')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000123126, 'LANGENG', '', 'COM_DICTIONARY', 'DESCRIPTION', 10002365, 'Plugin is used to create P2P credit operation data from P2P debit operation data.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000123125, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10002365, 'P2P credit authorization creation')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000123124, 'LANGENG', '', 'COM_DICTIONARY', 'DESCRIPTION', 10002364, 'Plugin is used to create P2P debit operation data from original P2P operation data.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000123123, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10002364, 'P2P debit authorization creation')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000018146, 'LANGENG', '', 'COM_DICTIONARY', 'DESCRIPTION', 10002985, 'Plugin is used to generate authorization for credit part of funds transfer. Plugin is useful for any P2P transfers.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000018145, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10002985, 'Funds transfer credit authorization creation')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000135821, 'LANGENG', null, 'COM_DICTIONARY', 'DESCRIPTION', 10003798, 'Plugin is used to create credit account authorization for funds transfers between account which is identified directly by account number.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000135820, 'LANGENG', null, 'COM_DICTIONARY', 'NAME', 10003798, 'Funds transfer credit account authorization creation')
/





-- ASC_PARAMETER
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text) values (100000004874, 'LANGENG', null, 'ASC_PARAMETER', 'DESCRIPTION', 1, 'Name of predefined authorization procedure plugin')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text) values (100000004944, 'LANGENG', null, 'ASC_PARAMETER', 'DESCRIPTION', 19, 'Next state code in case of rejection for current state execution')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text) values (100000004880, 'LANGENG', null, 'ASC_PARAMETER', 'DESCRIPTION', 2, 'Name of PL/SQL procedure that performs custom authorization functions')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text) values (100000004882, 'LANGENG', null, 'ASC_PARAMETER', 'DESCRIPTION', 3, 'Next state number in case of successful execution of current state')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text) values (100000004884, 'LANGENG', null, 'ASC_PARAMETER', 'DESCRIPTION', 4, 'Next state number in case of unsuccessful execution of current state')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text) values (100000004886, 'LANGENG', null, 'ASC_PARAMETER', 'DESCRIPTION', 5, 'Next state number in case of unsuccessful execution of current state but if retry is possible')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text) values (100000004888, 'LANGENG', null, 'ASC_PARAMETER', 'DESCRIPTION', 6, 'Next state number if execution of current state cannot be done')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text) values (100000004894, 'LANGENG', null, 'ASC_PARAMETER', 'DESCRIPTION', 7, 'Next state number if result of current state execution is unknown')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text) values (100000004904, 'LANGENG', null, 'ASC_PARAMETER', 'DESCRIPTION', 8, 'Name of plugin that generates additional authorization')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text) values (100000004906, 'LANGENG', null, 'ASC_PARAMETER', 'DESCRIPTION', 9, 'Value of timeout in seconds to hold up authorization')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text) values (100000004910, 'LANGENG', null, 'ASC_PARAMETER', 'DESCRIPTION', 11, 'Tag number for first operand of condition jump check')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text) values (100000004912, 'LANGENG', null, 'ASC_PARAMETER', 'DESCRIPTION', 12, 'Tag number for second operand of condition jump check')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text) values (100000004914, 'LANGENG', null, 'ASC_PARAMETER', 'DESCRIPTION', 13, 'Constant value for second operand of condition jump check')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text) values (100000004916, 'LANGENG', null, 'ASC_PARAMETER', 'DESCRIPTION', 14, 'Money amount for second operand of condition jump check')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text) values (100000004918, 'LANGENG', null, 'ASC_PARAMETER', 'DESCRIPTION', 15, 'Currency for second operand of condition jump check')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text) values (100000004920, 'LANGENG', null, 'ASC_PARAMETER', 'DESCRIPTION', 16, 'Operation of condition jump check')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text) values (100000004928, 'LANGENG', null, 'ASC_PARAMETER', 'DESCRIPTION', 17, 'Plugin name that is used to route operation to external system')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text) values (100000013847, 'LANGENG', null, 'ASC_PARAMETER', 'DESCRIPTION', 20, 'Next state code in case of external refuse during state execution')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text) values (100000014154, 'LANGENG', null, 'ASC_PARAMETER', 'DESCRIPTION', 21, 'Second operand value in case of short values comparison')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text) values (100000014155, 'LANGENG', null, 'ASC_PARAMETER', 'DESCRIPTION', 22, 'Second operand value in case of long values comparison')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text) values (100000014156, 'LANGENG', null, 'ASC_PARAMETER', 'DESCRIPTION', 23, 'Second operand value in case of integer values comparison')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text) values (100000014157, 'LANGENG', null, 'ASC_PARAMETER', 'DESCRIPTION', 24, 'Second operand value in case of float values comparison')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text) values (100000014300, 'LANGENG', null, 'ASC_PARAMETER', 'DESCRIPTION', 25, 'Value of second operand in comparison if dates are compared')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text) values (100000014301, 'LANGENG', null, 'ASC_PARAMETER', 'DESCRIPTION', 26, 'Dates comparison template')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text) values (100000119591, 'LANGENG', null, 'ASC_PARAMETER', 'DESCRIPTION', 27, 'Next state code if next request was received from initiator')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text) values (100000122916, 'LANGENG', null, 'ASC_PARAMETER', 'DESCRIPTION', 28, 'Authorization notification type')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text) values (100000123129, 'LANGENG', null, 'ASC_PARAMETER', 'DESCRIPTION', 29, 'Flag shows the existence of dependency of parent operation on subordinate operation result')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text) values (100000132346, 'LANGENG', null, 'ASC_PARAMETER', 'DESCRIPTION', 30, 'Card data registering requirement flag')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text) values (100000132347, 'LANGENG', null, 'ASC_PARAMETER', 'DESCRIPTION', 31, 'Account data registering requirement flag')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text) values (100000132348, 'LANGENG', null, 'ASC_PARAMETER', 'DESCRIPTION', 32, 'Terminal data registering requirement flag')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text) values (100000132349, 'LANGENG', null, 'ASC_PARAMETER', 'DESCRIPTION', 33, 'Merchant data registering requirement flag')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text) values (100000132350, 'LANGENG', null, 'ASC_PARAMETER', 'DESCRIPTION', 34, 'Card monitoring suite number')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text) values (100000132351, 'LANGENG', null, 'ASC_PARAMETER', 'DESCRIPTION', 35, 'Account monitoring suite number')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text) values (100000132352, 'LANGENG', null, 'ASC_PARAMETER', 'DESCRIPTION', 36, 'Terminal monitoring suite number')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text) values (100000132353, 'LANGENG', null, 'ASC_PARAMETER', 'DESCRIPTION', 37, 'Merchant monitoring suite number')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text) values (100000134844, 'LANGENG', null, 'ASC_PARAMETER', 'DESCRIPTION', 38, 'Flag allowing sending of reversal due to timeout')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text) values (100000017947, 'LANGENG', null, 'ASC_PARAMETER', 'DESCRIPTION', 39, 'Message function')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text) values (100000018361, 'LANGENG', null, 'ASC_PARAMETER', 'DESCRIPTION', 40, 'Authorization stage')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text) values (100000023602, 'LANGENG', null, 'ASC_PARAMETER', 'DESCRIPTION', 41, 'Flag shows if the reversal is required if originator rejects the response')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text) values (100000023777, 'LANGENG', null, 'ASC_PARAMETER', 'DESCRIPTION', 42, 'Flag shows if the revrsal is required if the destination is unavailable')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text) values (100000023773, 'LANGENG', null, 'ASC_PARAMETER', 'DESCRIPTION', 44, 'Payment aggregator host selection mode')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text) values (100000023774, 'LANGENG', null, 'ASC_PARAMETER', 'DESCRIPTION', 45, 'Payment aggregator host selection algorithm')
/



-- ASC_STATE_PARAMETER
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000005078, 'LANGENG', NULL, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 15, 'Next state number if reply was not delivered to operation initiator')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000005079, 'LANGENG', NULL, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 16, 'Next state number if operation initiator rejects reply')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000005080, 'LANGENG', NULL, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 17, 'Next state number if operation delivery result is unknown')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000005081, 'LANGENG', NULL, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 18, 'Name of plugin that is responsible for subordinate authorization generation')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000005082, 'LANGENG', NULL, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 19, 'Next state number if subordinate operation is successful')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000005083, 'LANGENG', NULL, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 20, 'Next state number if subordinate operation is unsuccessful')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000005084, 'LANGENG', NULL, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 21, 'Next state number if subordinate operation cannot be generated')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000005085, 'LANGENG', NULL, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 22, 'Next state number if subordinate operation is unknown')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000005086, 'LANGENG', NULL, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 23, 'Type of performed condition check')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000005087, 'LANGENG', NULL, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 24, 'Operand 1 of check: tag number')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000005088, 'LANGENG', NULL, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 25, 'Operand 2 of check: tag number')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000005089, 'LANGENG', NULL, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 26, 'Operand 2 of check: constant')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000005090, 'LANGENG', NULL, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 27, 'Operand 2 of check: money amount')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000005091, 'LANGENG', NULL, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 28, 'Operand 2 of check: money currency')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000005092, 'LANGENG', NULL, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 29, 'Check condition(check operation)')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000005093, 'LANGENG', NULL, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 30, 'Next state number if check was successful')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000005094, 'LANGENG', NULL, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 31, 'Next state number if check failed')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000005095, 'LANGENG', NULL, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 32, 'Next state number if check cannot be performed')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000005096, 'LANGENG', NULL, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 33, 'Value of timeout in seconds to hold up operation')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000005097, 'LANGENG', NULL, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 34, 'Next state number after timer expiration ')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000005098, 'LANGENG', NULL, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 35, 'Next state number if issuer returns authorization approval')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000005099, 'LANGENG', NULL, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 36, 'Next state number if issuer returns authorization decline')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000005100, 'LANGENG', NULL, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 37, 'Next state number if issuer is unavailable')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000005101, 'LANGENG', NULL, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 38, 'Next state number if request result is unknown')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000005102, 'LANGENG', NULL, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 39, 'Name of PL/SQL procedure that executes required authorization action')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000005103, 'LANGENG', NULL, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 40, 'Next state code if procedure returns success')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000005104, 'LANGENG', NULL, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 41, 'Next state code if procedure returns failure')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000005105, 'LANGENG', NULL, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 42, 'Next state code if procedure returns failure but repeated call can be performed')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000005106, 'LANGENG', NULL, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 43, 'Next state code if procedure is unavailable in database')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000013848, 'LANGENG', NULL, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 44, 'Next state number in case of external refusal from card issuer')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000014160, 'LANGENG', null, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 47, 'Second operand value if integer values are compared')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000014158, 'LANGENG', null, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 45, 'Second operand value if short values are compared')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000014159, 'LANGENG', null, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 46, 'Second operand value if long values are compared')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000014161, 'LANGENG', null, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 48, 'Second operand value if float values are compared')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000014231, 'LANGENG', null, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 49, 'Next state code in case of successful execution')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000014304, 'LANGENG', null, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 50, 'Value of second operand of comparison if dates are compared')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000014306, 'LANGENG', null, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 51, 'Dates comparison template')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000119592, 'LANGENG', null, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 52, 'Next state number if new request was issued by initiator')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000121391, 'LANGENG', null, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 53, 'Next state number if external system refuses to approve operation')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000122917, 'LANGENG', null, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 54, 'Authorization notification direction type')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000123130, 'LANGENG', null, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 55, 'Parent on subordinate dependency existence flag')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000132363, 'LANGENG', null, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 61, 'Account monitoring suite')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000132358, 'LANGENG', null, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 56, 'Card data registering requirement flag')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000132359, 'LANGENG', null, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 57, 'Account data registering requirement flag')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000132360, 'LANGENG', null, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 58, 'Terminal data registering requirement flag')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000132361, 'LANGENG', null, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 59, 'Merchant data registering requirement flag')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000132362, 'LANGENG', null, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 60, 'Card monitoring suite')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000132364, 'LANGENG', null, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 62, 'Terminal monitoring suite')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000132365, 'LANGENG', null, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 63, 'Merchant monitoring suite')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000132477, 'LANGENG', null, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 64, 'Next state code for successful check')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000132478, 'LANGENG', null, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 65, 'Next state code for failure check')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000132479, 'LANGENG', null, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 66, 'Next state code if monitoring cannot be performed')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000134865, 'LANGENG', NULL, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 67, 'Send a reversal to the issuer due to timeout of authorization')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000017950, 'LANGENG', null, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 68, 'Message function shows if request is parameters check, payment completion, etc.')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000017951, 'LANGENG', null, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 69, 'Next state number if payment aggregator returns authorization approval')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000017952, 'LANGENG', null, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 70, 'Next state number if payment aggregator returns authorization decline')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000017953, 'LANGENG', null, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 71, 'Next state number if payment aggregator is unavailable')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000017954, 'LANGENG', null, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 72, 'Next state number if request result is unknown')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000017955, 'LANGENG', null, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 73, 'Next state number in case of external refusal from payment aggregator')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000018364, 'LANGENG', null, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 88, 'Processing stage')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000018366, 'LANGENG', null, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 89, 'Next state number in case of success')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000018367, 'LANGENG', null, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 90, 'Next state number in case of failure')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000018368, 'LANGENG', null, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 91, 'Next state number in case of failure, retry is possible')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000018369, 'LANGENG', null, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 92, 'Next state number if stage cannot be called')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000023604, 'LANGENG', null, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 93, 'Flag shows if it is required to perform reversal if originator rejects operation response')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000023775, 'LANGENG', null, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 133, 'Aggregator host selection mode')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000023776, 'LANGENG', null, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 134, 'Aggregator host selection algorithm')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000023779, 'LANGENG', null, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 154, 'Flag shows if reversal must be generated if originator is not available')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000023780, 'LANGENG', null, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 155, 'Flag shows if reversal must be generated on delivery timeout')
/





-- ASC_SCENARIO
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000121968, 'LANGENG', NULL, 'ASC_SCENARIO', 'NAME', 0, 'ERROR DEFAULT SCENARIO')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000014278, 'LANGENG', null, 'ASC_SCENARIO', 'DESCRIPTION', 0, 'Default scenario to be used in case of errors in scenario execution initialization')
/

-- ASC_STATE
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000014279, 'LANGENG', null, 'ASC_STATE', 'DESCRIPTION', 1, 'Response with bad response code')
/
insert into com_i18n ( id, lang, entity_type, table_name, column_name, object_id, text ) values (100000014280, 'LANGENG', null, 'ASC_STATE', 'DESCRIPTION', 2, 'Finish scenario')
/

-- ACM_PRIVILEGE
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000015647, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 1329, 'Adding authorization scenario')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000015648, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 1330, 'Modifying authorization scenario')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000015649, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 1331, 'Removing authorization scenario')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000015650, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 1332, 'Removing authorization scenario state')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000015651, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 1333, 'Adding authorization scenario state')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000015652, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 1334, 'Modifying authorization scenario state')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000015653, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 1335, 'View authorization scenario states')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000015654, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 1336, 'View authorization scenarios')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000116515, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 1560, 'View authorization state parameters')
/


-- COM_LABEL
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000133211, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10009952, 'Unable to define authorization scenario')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000017544, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10003156, 'Authorization scenario with modifier [#1] already exists')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000117524, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10001528, 'Scenario has been saved.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000117525, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10001530, 'Scenario {0} has been deleted.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000117526, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10001532, 'State has been saved.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000117527, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10001524, 'Edit authorization scenario')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000117528, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10001523, 'Add authorization scenario')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000117529, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10001540, 'Scenario')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000117530, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10001550, 'Parameter has been saved.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000117531, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10001538, 'Authorizations states')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000117532, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10001542, 'Edit authorization state')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000117533, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10001534, 'State {0} has been deleted.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000117534, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10001548, 'New authorization scenario')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000117535, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10001516, 'Authorization scenarios')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000117536, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10001543, 'New authorization state')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000117537, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10001521, 'States')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000120505, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10008772, 'Data type [#1] is unknown')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000132425, 'LANGENG', null, 'COM_LABEL', 'NAME', 10009792, 'Process operation [#1] using authorization scenario [#2].')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000132426, 'LANGENG', null, 'COM_LABEL', 'NAME', 10009793, 'Authorization scenario is finished. Operation response code is [#1]. Operation completion status is [#2].')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000018483, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10003208, 'State of scenario already exists.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000022219, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10004019, 'Selection')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000022221, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10004022, 'New scenario selection')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000022223, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10004024, 'Scenario selection deleted')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000022225, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10004026, 'Scenario selection saved')
/

-- COM_LOV
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000121148, 'LANGENG', NULL, 'COM_LOV', 'NAME', 117, 'Authorization procedure plugin')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000121149, 'LANGENG', NULL, 'COM_LOV', 'NAME', 118, 'Authorization generate plugin')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000121150, 'LANGENG', NULL, 'COM_LOV', 'NAME', 119, 'Application plugins')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000121154, 'LANGENG', NULL, 'COM_LOV', 'NAME', 120, 'Conditions')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000121155, 'LANGENG', NULL, 'COM_LOV', 'NAME', 121, 'Scenario states')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000121156, 'LANGENG', NULL, 'COM_LOV', 'NAME', 122, 'Tags for authorization message')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000121157, 'LANGENG', NULL, 'COM_LOV', 'NAME', 123, 'Date format')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000122915, 'LANGENG', null, 'COM_LOV', 'NAME', 152, 'Authorization notification type')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000023772, 'LANGENG', null, 'COM_LOV', 'NAME', 308, 'Authorization payment aggregator selection modes')
/



-- COM_DICTIONARY(APAM)
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000023763, 'LANGENG', null, 'COM_DICTIONARY', 'NAME', 10003616, 'Authorization payment aggregator selection mode')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000023765, 'LANGENG', null, 'COM_DICTIONARY', 'DESCRIPTION', 10003617, 'Select aggregator host using selection algorithm and save it into authorization. Real request to aggregator is not implied.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000023764, 'LANGENG', null, 'COM_DICTIONARY', 'NAME', 10003617, 'Select host only')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000023767, 'LANGENG', null, 'COM_DICTIONARY', 'DESCRIPTION', 10003618, 'Get host from authorization data and send request to aggregator.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000023766, 'LANGENG', null, 'COM_DICTIONARY', 'NAME', 10003618, 'Send to aggreagtor only')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000023769, 'LANGENG', null, 'COM_DICTIONARY', 'DESCRIPTION', 10003619, 'Select aggregator host using selection algorithm and save it into authorization. Send request to selected aggregator.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000023768, 'LANGENG', null, 'COM_DICTIONARY', 'NAME', 10003619, 'Select host and send to aggregator')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000023771, 'LANGENG', null, 'COM_DICTIONARY', 'DESCRIPTION', 10003620, 'Select aggregator host using selection algorithm and save it into authorization. Send request to selected aggregator. If aggregator is not available try to choose reserve hosts and send requests to them.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000023770, 'LANGENG', null, 'COM_DICTIONARY', 'NAME', 10003620, 'Iterate aggregators')
/

insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136126, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10003824, 'PIN check and change')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136127, 'LANGENG', NULL, 'COM_DICTIONARY', 'DESCRIPTION', 10003824, 'Plugin is used to validate old PIN, generate and store new PIN offset. If reversal is processed than plugin can be used to reverse latest PIN change effect by setting old PIN as active.')
/
delete com_i18n where id in (  100000005086, 100000121149 )
/
update com_i18n set text = 'Payment templates data selection' where id = 100000135996
/
update com_i18n set text = 'Plugin is used to select list of customer templates for specified service and service provider.' where id = 100000135997
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000023948, 'LANGENG', NULL, 'ASC_PARAMETER', 'DESCRIPTION', 46, 'Second operand value in case of boolean values comparison')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000023949, 'LANGENG', NULL, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 156, 'Second operand value in case of bool values comparison')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000026298, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10003849, 'Get list of virtual cards')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000026299, 'LANGENG', NULL, 'COM_DICTIONARY', 'DESCRIPTION', 10003849, 'Plugin is used to obtain list of virtual cards attached to customer.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000026629, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10003913, 'Generate generic reversal')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000026630, 'LANGENG', NULL, 'COM_DICTIONARY', 'DESCRIPTION', 10003913, 'Plugin is used to generate generic reversal on current operation during authorization scenario execution.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000027053, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10003932, 'PIN check and result registration plugin')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000027054, 'LANGENG', NULL, 'COM_DICTIONARY', 'DESCRIPTION', 10003932, 'Plugin is used to ensure PIN correctness and to call special processing stages to register the result of check. ')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000027364, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10003978, 'Entries obtaining')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000027365, 'LANGENG', NULL, 'COM_DICTIONARY', 'DESCRIPTION', 10003978, 'Plugin is used to obtain account entries considered in authorization.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000027805, 'LANGENG', NULL, 'ASC_PARAMETER', 'DESCRIPTION', 47, 'Flag used to force response setup suppressing')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000027807, 'LANGENG', NULL, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 157, 'Flag used to force response setup suppressing')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000027901, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10003985, 'Split account adjustment')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000027902, 'LANGENG', NULL, 'COM_DICTIONARY', 'DESCRIPTION', 10003985, 'Plugin is used to create subordinate debit or credit adjustments at contragent side.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000028143, 'LANGENG', NULL, 'ASC_PARAMETER', 'DESCRIPTION', 48, 'Completion astatus of authorization')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000028146, 'LANGENG', NULL, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 158, 'Completion status of operation')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000029247, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004208, 'One-time password check')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000029248, 'LANGENG', NULL, 'COM_DICTIONARY', 'DESCRIPTION', 10004208, 'Plugin is used to generate and check one-time passwords for service attachment operation.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000030871, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000103, 'Set authorization state parameter')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000030872, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000104, 'View scenario selection')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000030873, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000105, 'Add scenario selection')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000030874, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000106, 'Remove scenario selection')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000031143, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004661, 'Authorization scenario parameter value')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000031145, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004662, 'Authorization scenario selection rule')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136553, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005083, 'External fraud monitoring')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136554, 'LANGENG', NULL, 'COM_DICTIONARY', 'DESCRIPTION', 10005083, 'State LL is used to call fraud prevention checks for card, account, terminal and/or merchant')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136557, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005084, 'ISO8583POS with CBS')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136558, 'LANGENG', NULL, 'COM_DICTIONARY', 'DESCRIPTION', 10005084, 'Plugin for usage ISO8583 POS protocol with fraud monitoring system')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000044900, 'LANGENG', NULL, 'COM_LOV', 'NAME', 155, 'Authorization splitting plugin')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000046095, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005710, 'Authorization parameter setting')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000046096, 'LANGENG', NULL, 'COM_DICTIONARY', 'DESCRIPTION', 10005710, 'State O is intended to set value for a single authorization parameter')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000046103, 'LANGENG', NULL, 'ASC_PARAMETER', 'DESCRIPTION', 10002705, 'Authorization parameter number')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000046105, 'LANGENG', NULL, 'ASC_PARAMETER', 'DESCRIPTION', 10002706, 'Authorization parameter value')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000046111, 'LANGENG', NULL, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 1033, 'Next state in case of successful setting of value for authorization parameter')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000046113, 'LANGENG', NULL, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 1034, 'Next state in case of unsuccessful setting of value for authorization parameter')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000046115, 'LANGENG', NULL, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 1035, 'Authorization parameter number')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000046117, 'LANGENG', NULL, 'ASC_STATE_PARAMETER', 'DESCRIPTION', 1036, 'Authorization parameter value')
/
update com_i18n set text = 'Completion status of authorization' where id = 100000028143
/

