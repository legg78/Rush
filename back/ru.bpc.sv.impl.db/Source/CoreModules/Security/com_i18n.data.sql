------- COM_DICTIONARY
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000004794, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10000517, 'Security question')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000004795, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10000518, 'Any security word')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000016639, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10001246, 'What was your childhood nickname? ')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000016640, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10001247, 'In what city or town did your mother and father meet? ')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000016641, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10001248, 'What was the name of your elementary / primary school?')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000016642, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10001249, 'What is the name of the company of your first job?')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000013271, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10000818, 'Security DES key type')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000014701, 'LANGENG', NULL, 'COM_DICTIONARY', 'DESCRIPTION', 10001040, 'CVK is used for genearating and validating of card verification information, i.e. CVV.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000014700, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10001040, 'Card Verification Key')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000014703, 'LANGENG', NULL, 'COM_DICTIONARY', 'DESCRIPTION', 10001041, 'CVK2 is used for genearating and validating of card and cardholder verification information, i.e. CVV2.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000014702, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10001041, 'Card Verification Key 2')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000014715, 'LANGENG', NULL, 'COM_DICTIONARY', 'DESCRIPTION', 10001047, 'IMKac is used to verify EMV data while transaction is processed. It is used to verify APQC (cryptogram that was generated at terminal side) and to generate ARPC (host cryptogram). The key is generated in card generating process. ')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000014714, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10001047, 'Issuer Master Key for Application Cryptograms')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000014692, 'LANGENG', NULL, 'COM_DICTIONARY', 'DESCRIPTION', 10001033, 'PVK is used to generate and verify PIN verification data (PVV, PIN-offset) and thus verify the authenticity of a PIN. PVK usage may vary in accordance with different PIN verification methods. For VISA methods it is possible to have up to 7 PVK. For IBM3624 method PVK is used with decimalization table.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000014691, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10001033, 'PIN Verification Key')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000014713, 'LANGENG', NULL, 'COM_DICTIONARY', 'DESCRIPTION', 10001046, 'TAK is used to generate Message Authentication Code (MAC)  for message that is transmitted from terminal to host or vise versa. TAK is also used to verify MAC. TAK must be known at both sides of interaction.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000014712, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10001046, 'Terminal MAC Session Key')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000014709, 'LANGENG', NULL, 'COM_DICTIONARY', 'DESCRIPTION', 10001044, 'TMK is terminal key that is used to transfer another terminal keys (TPK, TAK) between terminal and host in case of key change procedure. TMK is stored at both sides of interaction. TMK for TAK is used if terminal supports separate master keys for encription of different key types. In this case TMK for TAK is used instead of regular TMK to transfer TAK keys.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000014708, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10001044, 'Terminal MAC Master Key')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000014707, 'LANGENG', NULL, 'COM_DICTIONARY', 'DESCRIPTION', 10001043, 'TMK is terminal key that is used to transfer another terminal keys (TPK, TAK) between terminal and host in case of key change procedure. TMK is stored at both sides of interaction. TMK for TPK is used if terminal supports separate master keys for encription of different key types. In this case TMK for TPK is used instead of regular TMK to transfer TPK keys.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000014706, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10001043, 'Terminal PIN Master Key')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000014711, 'LANGENG', NULL, 'COM_DICTIONARY', 'DESCRIPTION', 10001045, 'TPK is used to encript PIN in PIN Block while transferring it between terminal and host system. TPK must be known at both sides of interaction.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000014710, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10001045, 'Terminal PIN Session Key')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000014690, 'LANGENG', NULL, 'COM_DICTIONARY', 'DESCRIPTION', 10001032, 'ZPK is used in different ways. The main idea is to encrypt PINs for transfer between communicating parties. So ZPK is always associated with external systems. ZPK can be local if it is used as key to encrypt newly generated PIN (only for Safenet HSM hardware).')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000014689, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10001032, 'Zone PIN Key')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000017103, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10001309, 'Key Mailer')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000017210, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10001344, 'Issuer Master Key for Data Authentication Code')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000017211, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10001345, 'Issuer Master Key for ICC Dynamic Number')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000017212, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10001346, 'Issuer Master Key for Secure Messaging Confidentiality')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000017213, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10001347, 'Issuer Master Key for Secure Messaging Integrity')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000017222, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10001350, 'Key Encrypting Key')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000015555, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10001091, 'Encryption key length')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000015556, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10001092, 'Single')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000015557, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10001093, 'Double')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000015558, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10001094, 'Triple')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000120535, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10001933, 'Terminal Master Key')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000120536, 'LANGENG', NULL, 'COM_DICTIONARY', 'DESCRIPTION', 10001933, 'A Terminal Master Key (TMK) is used to distribute data-encrypting keys, within a local (non-shared) network, to an ATM or POS terminal or similar.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000120537, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10001934, 'Zone Master Key')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000120538, 'LANGENG', NULL, 'COM_DICTIONARY', 'DESCRIPTION', 10001934, 'A Zone Master Key (ZMK) is a key-encrypting key which is distributed manually between two (or more) communicating sites, within a shared network, in order that further keys can be exchanged automatically (without the need for manual intervention).')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000120541, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10001936, 'Issuing Zone PIN Key')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000120542, 'LANGENG', NULL, 'COM_DICTIONARY', 'DESCRIPTION', 10001936, 'Issuing Pin Exchange Key for Hosts')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000120543, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10001940, 'Acquiring Zone PIN Key')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000120544, 'LANGENG', NULL, 'COM_DICTIONARY', 'DESCRIPTION', 10001940, 'Acquiring Pin Exchange Key for Hosts')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000120545, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10001941, 'Cryptographic Algorithms')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000120546, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10001942, 'DES algorithm')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000120547, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10001943, 'RSA algorithm')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000121840, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10002131, 'Encryption Key Prefix')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000121845, 'LANGENG', '', 'COM_DICTIONARY', 'DESCRIPTION', 10002135, 'Thales Keyblock Method - for single, double or triple length keys')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000121844, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10002135, 'Single, double or triple length keys')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000121846, 'LANGENG', '', 'COM_DICTIONARY', 'DESCRIPTION', 10002134, 'Thales Variant Method - for triple length keys')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000121843, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10002134, 'Triple length keys')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000121847, 'LANGENG', '', 'COM_DICTIONARY', 'DESCRIPTION', 10002133, 'Thales Variant Method - for double length keys')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000121842, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10002133, 'Double length keys')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000121848, 'LANGENG', '', 'COM_DICTIONARY', 'DESCRIPTION', 10002132, 'Thales Variant Method - for single length keys')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000121841, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10002132, 'Single length keys')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000122133, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10002220, 'X Encryption of a double length key using ANSI X9.17')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000122134, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10002221, 'Y Encryption of a triple length key using ANSI X9.17')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000122231, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10002229, 'Certificate authority type')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000122232, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10002230, 'MasterCard')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000122233, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10002231, 'Visa')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000123881, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10002398, 'NCR')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000123879, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10002397, 'System')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000122248, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10002232, 'Issuer RSA Key Set')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000122569, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10002281, 'Authority RSA Key set')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000122698, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10002317, 'Visa Self-certified Issuer Public Key')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000122404, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10002256, 'MasterCard Self-certified Issuer Public Key')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000122405, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10002257, 'Hash-code calculated on a Payment System Public Key')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000122520, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10002277, 'Issuer Public Key Certificate')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000122521, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10002278, 'Self-certified Payment System Public Key')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000122522, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10002279, 'Hash-code calculated on a self-certified Issuer Public Key')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000122464, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10002265, 'Signature algorithm')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000122465, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10002266, 'RSA')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000122466, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10002267, 'RSA with exponent 65535')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000122477, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10002269, 'Hash algorithm')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000122479, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10002271, 'MD5')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000122480, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10002272, 'ISO 10118-2')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000122481, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10002273, 'SHA-224')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000122482, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10002274, 'SHA-256')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000122483, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10002275, 'SHA-384')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000122484, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10002276, 'SHA-512')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000122478, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10002270, 'SHA-1')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000122773, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10002319, 'Encryption key state')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000122774, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10002320, 'Init')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000122775, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10002321, 'Active')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000123181, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10002378, 'Issuer Master Key CVC3')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000124008, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10002434, 'Authority centers')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000132901, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10002533, 'Encryption mode')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000132908, 'LANGENG', '', 'COM_DICTIONARY', 'DESCRIPTION', 10002534, 'Electronic codebook')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000132902, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10002534, 'ECB')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000132906, 'LANGENG', '', 'COM_DICTIONARY', 'DESCRIPTION', 10002535, 'Cipher-block chaining')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000132905, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10002535, 'CBC')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000017991, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10002975, 'Local Master Key')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000021722, 'LANGENG', null, 'COM_DICTIONARY', 'DESCRIPTION', 10003236, 'The key is used in message encryption session key generating procedure as master key.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000021721, 'LANGENG', null, 'COM_DICTIONARY', 'NAME', 10003236, 'Zone authentification key for message encription')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000023831, 'LANGENG', null, 'COM_DICTIONARY', 'NAME', 10003830, 'Private key for use in a Keyed-Hash Message Authentication Code (HMAC)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000023832, 'LANGENG', null, 'COM_DICTIONARY', 'DESCRIPTION', 10003830, 'The HMAC Key may only be used as input to HMAC functions; it is not available for use with any other HSM functions')
/


------- COM_LOV
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000014310, 'LANGENG', NULL, 'COM_LOV', 'NAME', 57, 'DES crypto key length')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000015689, 'LANGENG', NULL, 'COM_LOV', 'NAME', 66, 'Encryption key types')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000017108, 'LANGENG', NULL, 'COM_LOV', 'NAME', 86, 'Formats key mailer')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000121849, 'LANGENG', NULL, 'COM_LOV', 'NAME', 1023, 'Key prefix')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000122249, 'LANGENG', NULL, 'COM_LOV', 'NAME', 140, 'RSA key types')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000018073, 'LANGENG', NULL, 'COM_LOV', 'NAME', 217, 'Signature algorithm')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000018620, 'LANGENG', NULL, 'COM_LOV', 'NAME', 237, 'Certificate authority type')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000018646, 'LANGENG', NULL, 'COM_LOV', 'NAME', 238, 'DES key types')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000018661, 'LANGENG', NULL, 'COM_LOV', 'NAME', 241, 'Key entities')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000135279, 'LANGENG', NULL, 'COM_LOV', 'NAME', 281, 'Certificate authority centers')
/

------- ACM_PRIVILEGE
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000015685, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 1349, 'View DES crypto keys')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000015686, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 1350, 'Adding DES crypto key')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000015687, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 1351, 'Modifying DES crypto key')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000015688, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 1352, 'Removing DES crypto key')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000015699, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 1353, 'Generate DES crypto key')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000015700, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 1354, 'Translate DES crypto key')
/

insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000018074, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 1949, 'View RSA crypto keys')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000018075, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 1950, 'Add RSA crypto key')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000018076, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 1951, 'Modify RSA crypto key')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000018077, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 1952, 'Remove RSA crypto key')
/

insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000018078, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 1953, 'View RSA certificates')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000021889, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 2013, 'Adding RSA certificate')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000021874, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 2014, 'Modifying RSA certificate')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000021875, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 2015, 'Removing certificate')
/

insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000018612, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 1968, 'View certificate authority centers')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000018613, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 1969, 'Adding certificate authority center')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000018614, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 1970, 'Modifying certificate authority center')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000018615, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 1971, 'Removing certificate authority center')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000022136, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 2018, 'Verification of a secure word')
/


------- COM_LABEL
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000122110, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10008963, 'Can''t translate key [#1]. HSM response code [#2]')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000116955, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10005972, 'Can''t generate key [#1]. HSM response code [#2]')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000116956, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10005973, 'Key check value validation failed for key [#1]. HSM response code [#2]')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000116957, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10005974, 'Can''t generate key check value for key [#1]. HSM response code [#2]')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000118992, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10008559, 'Translate DES key')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000118993, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10001869, 'Check value')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000118994, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10001874, 'DES key has been saved.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000118996, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10008563, 'Key encryption key')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000118997, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10001868, 'Key length')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000118998, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10001872, 'Edit DES key')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000118999, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10008566, 'Print clear components')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000119000, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10008567, 'Translate')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000119001, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10008568, 'DES key')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000119002, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10001871, 'Create new DES key')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000119003, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10001866, 'Key type')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000119004, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10008571, 'Key cryptogram')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000119005, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10008572, 'Generate')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000119006, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10008573, 'Generate DES key')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000119007, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10008574, 'Format')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000119008, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10001873, 'DES key {0} has been deleted.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000119009, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10008576, 'Key component number')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000119010, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10001867, 'Key prefix')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000119011, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10008578, 'Encrypted key')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000119012, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10008579, 'Key index')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000119013, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10001870, 'Key')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000120518, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10008774, 'Check word')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000120519, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10008775, 'Check security word')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000120520, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10008776, 'Question')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000120521, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10008777, 'Answer')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000120522, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10008778, 'Validation')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000120523, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10008779, 'Incorrect word!')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000120524, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10008780, 'Correct!')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000121819, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10008941, 'Key [#1] with key index [#2] already exists')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000121837, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10008943, 'Such key is already exists.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000121838, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10008945, 'Do you want to overwrite existing key?')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000121829, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10008942, 'Key [#3] with key index [#4] for [#1] [#2] not found')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000121839, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10008944, 'Key check value [#1] for [#2] not valid')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000122121, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10008965, 'New key prefix')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000122453, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10009166, 'Error genereate issuer RSA key set [#1]. HSM response code [#2]')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000122454, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10009167, 'Certificate request number is not defined')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000122455, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10009168, 'Identifies specific Visa Service is not defined')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000122456, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10009169, 'Certificate serial number assigned by certificate authority is not defined')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000122457, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10009170, 'Unknown certification authority [#1].')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000133138, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10009906, 'Authority not found')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000133139, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10009907, 'MasterCard public key algorithm indicator mismatch')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000133140, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10009908, 'Visa public key certificate file header mismatch')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000133141, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10009909, 'Certificate authority center public key index mismatch')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000133142, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10009910, 'Certificate expiration date mismatch')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000133143, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10009911, 'Certificate files is empty')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000133144, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10009912, 'Certificate subject id mismatch')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000133145, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10009913, 'Certification authority mismatch')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000133146, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10009914, 'Can''t validate a certification authority self-signed certificate [#1]. HSM response code [#2]')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000133147, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10009915, 'Can''t validate a issuer public key certificate[#1]. HSM response code [#2]')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000133148, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10009916, 'Issuer public exponent length mismatch')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000133149, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10009917, 'Issuer public key certificate file header mismatch')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000133150, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10009918, 'RSA key certificate not found')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000133151, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10009919, 'RSA certificate not found')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000133152, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10009920, 'RSA crypto key not found')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000133153, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10009921, 'Files not found')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000133154, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10009922, 'Unknown authority type by issuer public key certificate file')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000133155, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10009923, 'Visa service identifier mismatch')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000018640, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10003303, 'Certificate authority center')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000018641, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10003304, 'Type')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000018642, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10003305, 'RID')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000018643, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10003306, 'Name')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000018644, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10003307, 'New certificate authority center')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000018645, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10003308, 'Edit certificate authority center')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000020163, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10003460, 'RSA key pair already used')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000135251, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10003902, 'Standard key type')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000021891, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10003934, 'Authority ID')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000021892, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10003935, 'RSA Certificates')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000021893, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10003936, 'Expiration date')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000021894, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10003937, 'Subject ID')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000021895, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10003938, 'Certificated key ID')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000021896, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10003939, 'Authority key ID')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000021897, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10003940, 'Serial number')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000021898, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10003941, 'VISA service ID')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000021899, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10003942, 'Certificate')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000021900, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10003943, 'Reminder')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000021901, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10003944, 'Hash')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000021902, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10003945, 'Tracking number')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000021903, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10003946, 'State')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000021927, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10003950, 'Description')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000021928, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10003951, 'Module length')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000021929, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10003952, 'LMK ID')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000021930, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10003953, 'HSM Device ID')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000021931, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10003954, 'Algorithm')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000021932, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10003955, 'Exponent')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000021933, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10003956, 'Edit RSA key')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000021934, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10003957, 'New RSA key')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000021935, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10003958, 'View RSA key')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000021936, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10003959, 'RSA keys')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000022192, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10003996, '{0} is not hexadecimal value')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000022193, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10003997, 'Fill only one field')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000022194, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10003998, 'Public key MAC')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000022195, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10003999, 'Public key')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000022196, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10004000, 'Private key')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000022197, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10004001, 'Certificates')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000022198, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10004002, 'Set CA index')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000022199, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10004003, 'Authority key index')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000022200, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10004004, 'BIN')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136117, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10004811, 'Object description')
/
------- RUL_NAME_FORMAT
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000122406, 'LANGENG', NULL, 'RUL_NAME_FORMAT', 'LABEL', 1267, 'Self-certified Issuer Public Key (MasterCard)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000122407, 'LANGENG', NULL, 'RUL_NAME_FORMAT', 'LABEL', 1268, 'Hash-code calculated on a self-certified Issuer Public Key (MasterCard)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000122408, 'LANGENG', NULL, 'RUL_NAME_FORMAT', 'LABEL', 1269, 'Self-certified Issuer Public Key (Visa)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000018572, 'LANGENG', NULL, 'RUL_NAME_FORMAT', 'LABEL', 1273, 'Issuer Public Key Certificate (MasterCard)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000018573, 'LANGENG', NULL, 'RUL_NAME_FORMAT', 'LABEL', 1274, 'Issuer Public Key Certificate (Visa)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000018574, 'LANGENG', NULL, 'RUL_NAME_FORMAT', 'LABEL', 1275, 'Self-certified Payment System Public Key (MasterCard)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000018575, 'LANGENG', NULL, 'RUL_NAME_FORMAT', 'LABEL', 1276, 'Self-certified Payment System Public Key (Visa)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000018576, 'LANGENG', NULL, 'RUL_NAME_FORMAT', 'LABEL', 1277, 'Hash-code calculated on a Payment System Public Key (MasterCard)')
/

------- PRC_PROCESS
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000018577, 'LANGENG', NULL, 'PRC_PROCESS', 'NAME', 10000004, 'Make certificate request')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000018578, 'LANGENG', NULL, 'PRC_PROCESS', 'NAME', 10000005, 'Read certificate response')
/

------- PRC_FILE
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000018579, 'LANGENG', '', 'PRC_FILE', 'NAME', 1304, 'Self-certified Issuer Public Key (Visa)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000018580, 'LANGENG', '', 'PRC_FILE', 'NAME', 1305, 'Self-certified Issuer Public Key (MasterCard)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000018581, 'LANGENG', '', 'PRC_FILE', 'NAME', 1306, 'Hash-code calculated on a self-certified Issuer Public Key (MasterCard)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000018582, 'LANGENG', '', 'PRC_FILE', 'NAME', 1307, 'Issuer Public Key Certificate')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000018584, 'LANGENG', '', 'PRC_FILE', 'NAME', 1309, 'Self-certified Payment System Public Key')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000018586, 'LANGENG', '', 'PRC_FILE', 'NAME', 1311, 'Hash-code calculated on a Payment System Public Key')
/

------- SEC_AUTHORITY
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000021767, 'LANGENG', NULL, 'SEC_AUTHORITY', 'NAME', 1001, 'MasterCard')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000021768, 'LANGENG', NULL, 'SEC_AUTHORITY', 'NAME', 1002, 'Visa')
/

update com_i18n set text = 'HSM' where id = 100000021930
/
delete from com_i18n where id in (100000133151, 100000020163)
/

insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000026501, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000015, 'View HMAC keys')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000026502, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000016, 'Adding HMAC key')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000026503, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000017, 'Removing HMAC key')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000027056, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10004943, 'HMAC key already exists')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000027233, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10003956, 'IPS root sertificate')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (600000000021, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 60000005, 'Digits only')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (600000000022, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 60000006, 'Alphanumeric')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (600000000019, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 60000003, 'Password type')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000027260, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10004978, 'HMAC keys')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000027262, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10004980, 'Key value')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000027264, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10004982, 'Generate date')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000027266, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10004984, 'Generate user name')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000027269, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10004987, 'New HMAC key')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000027271, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10004989, 'HMAC key')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000027273, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10004991, 'Generate HMAC key')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000027277, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10004994, 'DES keys')
/
delete com_i18n where id in (600000000021,600000000022,600000000019)
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000027289, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10003970, 'Password algorithm type')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000027290, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10003971, 'Digits only')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000027291, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10003972, 'Alphanumeric')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000027292, 'LANGENG', NULL, 'COM_LOV', 'NAME', 340, 'Algoritm of generation passwords')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000027328, 'LANGENG', NULL, 'PRC_PROCESS', 'NAME', 10000016, 'Load IPS root certificate')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000027329, 'LANGRUS', NULL, 'PRC_FILE', 'NAME', 1327, 'IPS root certificate')
/
update com_i18n set text = 'IPS root certificate' where id = 100000027233
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000028203, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004025, 'ACS certificate')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000028204, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004026, 'Intermediate certificate')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000028205, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004027, 'ACS key set')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000028741, 'LANGENG', NULL, 'PRC_PROCESS', 'NAME', 10000021, 'Load intermediate certificate')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000028743, 'LANGENG', NULL, 'PRC_PROCESS', 'NAME', 10000022, 'Load ACS certificate')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000028742, 'LANGENG', NULL, 'PRC_FILE', 'NAME', 1332, 'Intermediate certificate')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000028747, 'LANGENG', NULL, 'PRC_FILE', 'NAME', 1333, 'ACS certificate')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000029271, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004212, 'OTP request in ATM')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000029323, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004213, 'PIN protection key')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000029324, 'LANGENG', NULL, 'COM_DICTIONARY', 'DESCRIPTION', 10004213, 'PPK is used in PVV-Calc')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000029481, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004224, 'ECB single length')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000029482, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004225, 'ECB double length')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000029483, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004226, 'ECB triple length')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000029484, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004227, 'CBC double length')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000029485, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004228, 'CBC triple length')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000030875, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000107, 'Check DES key')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000030876, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000108, 'View key type')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000030877, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000109, 'Check security word')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000030878, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000110, 'View security word')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000030879, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000111, 'Link authority key index with certified key index')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000032099, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10005473, 'Private key mac')
/
update com_i18n set text = 'Error while generating issuer RSA key set. HSM response code [#2].' where id = 100000122453
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000032445, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10005526, 'RSA key with index [#1] already exists')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000032589, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10005552, 'Public key is not found for the BIN with the type ''''{0}''''')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000032794, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10005588, 'Certificate authority already exists.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000032796, 'LANGENG', NULL, 'COM_LOV', 'NAME', 427, 'Certificate authority RIDs')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000044030, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000018, 'Generate HMAC key')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000044549, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005163, 'IBM pin offset key')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000046215, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000335, 'View DES crypto keys on the tab')
/
update com_i18n set text = 'IPS root certificate loading' where table_name = 'PRC_PROCESS' and column_name = 'NAME' and object_id = 10000016 and lang = 'LANGENG'
/
update com_i18n set text = 'Intermediate certificate loading' where table_name = 'PRC_PROCESS' and column_name = 'NAME' and object_id = 10000021 and lang = 'LANGENG'
/
update com_i18n set text = 'ACS certificate loading' where table_name = 'PRC_PROCESS' and column_name = 'NAME' and object_id = 10000022 and lang = 'LANGENG'
/
delete com_i18n where id = 100000046390
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000046390, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10009471, 'Unknown PIN block format [#1]')
/
update com_i18n set text = 'Can''t generate key of type [#2] with HSM device [#1]. Response message is [#3]' where id = 100000116955
/
update com_i18n set text = 'Can''t generate translate key of type [#2] with HSM device [#1]. Response message is [#3]' where id = 100000122110
/
update com_i18n set text = 'Error on generating issuer''s RSA key set with HSM device [#1]. Certificate authority type [#2], response message is [#3].' where id = 100000122453
/
update com_i18n set text = 'Can''t validate a certification authority self-signed certificate [#2] with HSM device [#1]. Response message [#3].' where id = 100000133146
/
update com_i18n set text = 'Can''t validate a issuer public key certificate [#2] with HSM device [#1]. Response message [#3].' where id = 100000133147
/
update com_i18n set text = 'Can''t generate key check value for key type [#2] with HSM device [#1]. Response message is [#3]' where id = 100000116957
/
update com_i18n set text = 'Key check value validation failed for key type [#2] with HSM device [#1]. Response message is [#3]' where id = 100000116956
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050098, 'LANGENG', NULL, 'RUL_NAME_BASE_PARAM', 'DESCRIPTION', 10000224, 'Key Type')
/
update com_i18n set text = 'Encryption key types by entities' where id = 100000015689
/
update com_i18n set text = 'IPS root certificate downloading' where id = 100000027328
/
update com_i18n set text = 'Intermediate certificate downloading' where id = 100000028741
/
update com_i18n set text = 'ACS certificate downloading' where id = 100000028743
/
update com_i18n set text = 'Load IPS root certificate' where id = 100000027328
/
update com_i18n set text = 'Load intermediate certificate' where id = 100000028741
/
update com_i18n set text = 'Load ACS certificate' where id = 100000028743
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000056730, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007596, 'Web authentication scheme')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000056732, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007597, 'Password')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000056733, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007598, 'Certificate')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000056734, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007599, 'Certificate and password')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000056738, 'LANGENG', NULL, 'COM_LOV', 'NAME', 581, 'Web authentication scheme')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000056740, 'LANGENG', NULL, 'SET_PARAMETER', 'CAPTION', 10003467, 'Authentication')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000056741, 'LANGENG', NULL, 'SET_PARAMETER', 'CAPTION', 10003468, 'Authentication scheme')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000056742, 'LANGENG', NULL, 'SET_PARAMETER', 'CAPTION', 10003469, 'Pattern to extract username from certificate Subject DN')
/
update com_i18n set object_id=10003590 where id=100000056741
/
update com_i18n set lang = 'LANGENG' where id = 100000027329
/
