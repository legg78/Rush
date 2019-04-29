create or replace package acq_api_const_pkg as
/*********************************************************
*  Acquier - list of constants <br />
*  Created by Filimonov A.(filimonov@bpc.ru)  at 03.09.2009 <br />
*  Module: acq_api_const_pkg <br />
*  @headcom
**********************************************************/

TERMINAL_TYPE_DICTIONARY        constant    com_api_type_pkg.t_dict_value   := 'TRMT';
TERMINAL_TYPE_IMPRINTER         constant    com_api_type_pkg.t_dict_value   := 'TRMT0001';
TERMINAL_TYPE_ATM               constant    com_api_type_pkg.t_dict_value   := 'TRMT0002';
TERMINAL_TYPE_POS               constant    com_api_type_pkg.t_dict_value   := 'TRMT0003';
TERMINAL_TYPE_EPOS              constant    com_api_type_pkg.t_dict_value   := 'TRMT0004';
TERMINAL_TYPE_MOBILE            constant    com_api_type_pkg.t_dict_value   := 'TRMT0005';
TERMINAL_TYPE_INTERNET          constant    com_api_type_pkg.t_dict_value   := 'TRMT0006';
TERMINAL_TYPE_MOBILE_POS        constant    com_api_type_pkg.t_dict_value   := 'TRMT0007';
TERMINAL_TYPE_INFO_KIOSK        constant    com_api_type_pkg.t_dict_value   := 'TRMT0008';
TERMINAL_TYPE_TRANSPONDER       constant    com_api_type_pkg.t_dict_value   := 'TRMT0009';
TERMINAL_TYPE_UNKNOWN           constant    com_api_type_pkg.t_dict_value   := 'TRMT0000';

DISPENSER_TYPE_CASSETTE         constant    com_api_type_pkg.t_dict_value   := 'DSTPCASS';
DISPENSER_TYPE_HOPPER           constant    com_api_type_pkg.t_dict_value   := 'DSTPHOPP';

TERMINAL_STATUS_ACTIVE          constant    com_api_type_pkg.t_dict_value   := 'TRMS0001';
TERMINAL_STATUS_INACTIVE        constant    com_api_type_pkg.t_dict_value   := 'TRMS0002';
TERMINAL_STATUS_CLOSED          constant    com_api_type_pkg.t_dict_value   := 'TRMS0009';

MERCHANT_TYPE_TERMINAL          constant    com_api_type_pkg.t_dict_value   := 'MRCTTRMN';
MERCHANT_TYPE_BANK              constant    com_api_type_pkg.t_dict_value   := 'MRCTBANK';

ENTITY_TYPE_ACQ_PRODUCT         constant    com_api_type_pkg.t_dict_value   := 'ENTTAPRD';
ENTITY_TYPE_ACQ_BIN             constant    com_api_type_pkg.t_dict_value   := 'ENTTABIN';
ENTITY_TYPE_MERCHANT            constant    com_api_type_pkg.t_dict_value   := 'ENTTMRCH';
ENTITY_TYPE_TERMINAL            constant    com_api_type_pkg.t_dict_value   := 'ENTTTRMN';

REIMB_BATCH_STATUS_AWATING      constant    com_api_type_pkg.t_dict_value   := 'REBSAWUP';
REIMB_BATCH_STATUS_UPLOADED     constant    com_api_type_pkg.t_dict_value   := 'REBSUPLD';
REIMB_BATCH_STATUS_UPLERR       constant    com_api_type_pkg.t_dict_value   := 'REBSUPER';

REIMB_AMOUNT_TYPE_GROSS         constant    com_api_type_pkg.t_dict_value   := 'REATGRSS';
REIMB_AMOUNT_TYPE_NET           constant    com_api_type_pkg.t_dict_value   := 'REATNETA';
REIMB_AMOUNT_TYPE_TAX           constant    com_api_type_pkg.t_dict_value   := 'REATTAXA';
REIMB_AMOUNT_TYPE_CHARGE        constant    com_api_type_pkg.t_dict_value   := 'REATSRVC';

MERCHANT_STATUS_ACTIVE          constant    com_api_type_pkg.t_dict_value   := 'MRCS0001';
MERCHANT_STATUS_SUSPENDED       constant    com_api_type_pkg.t_dict_value   := 'MRCS0003';
MERCHANT_STATUS_CLOSED          constant    com_api_type_pkg.t_dict_value   := 'MRCS0009';

EVENT_MERCHANT_CREATION         constant    com_api_type_pkg.t_dict_value   := 'EVNT0200';
EVENT_MERCHANT_CLOSE            constant    com_api_type_pkg.t_dict_value   := 'EVNT0220';
EVENT_MERCHANT_CHANGE           constant    com_api_type_pkg.t_dict_value   := 'EVNT0230';

EVENT_MERCHANT_ATTR_CHANGE      constant    com_api_type_pkg.t_dict_value   := 'EVNT0235';
EVENT_MERCHANT_ATTR_END_CHANGE  constant    com_api_type_pkg.t_dict_value   := 'EVNT0231';
EVENT_TERMINAL_ATTR_CHANGE      constant    com_api_type_pkg.t_dict_value   := 'EVNT0245';
EVENT_TERMINAL_ATTR_END_CHANGE  constant    com_api_type_pkg.t_dict_value   := 'EVNT0241';

EVENT_TERMINAL_CREATION         constant    com_api_type_pkg.t_dict_value   := 'EVNT0210';
EVENT_TERMINAL_CLOSE            constant    com_api_type_pkg.t_dict_value   := 'EVNT0240';
EVENT_TERMINAL_CHANGE           constant    com_api_type_pkg.t_dict_value   := 'EVNT0215';

STATUS_REASON_SYSTEM            constant    com_api_type_pkg.t_dict_value   := 'MRSRSYST';

ANY_MERCHANT                    constant    com_api_type_pkg.t_byte_char    := '%';
CURRENT_MERCHANT                constant    com_api_type_pkg.t_dict_value   := 'MRCTCURR';

CYCLE_TYPE_SUSPEND_MERCHANT     constant    com_api_type_pkg.t_dict_value   := 'CYTP0203';

POS_BATCH_METHOD_VALIDATION     constant    com_api_type_pkg.t_dict_value   := 'PSBMBTVM';
POS_BATCH_METHOD_COMPLETION     constant    com_api_type_pkg.t_dict_value   := 'PSBMBTCM';

EVENT_TERMINAL_COMMON           constant    com_api_type_pkg.t_dict_value   := 'EVNT0801';
EVENT_TERMINAL_DISP_LIMIT       constant    com_api_type_pkg.t_dict_value   := 'EVNT0802';
EVENT_TERMINAL_CARD_CAPTURED    constant    com_api_type_pkg.t_dict_value   := 'EVNT0803';
EVENT_TERMINAL_RCPT_LIMIT       constant    com_api_type_pkg.t_dict_value   := 'EVNT0804';
EVENT_TERMINAL_REJECT_LIMIT     constant    com_api_type_pkg.t_dict_value   := 'EVNT0805';
EVENT_TERMINAL_RCPT             constant    com_api_type_pkg.t_dict_value   := 'EVNT0806';
event_terminal_card_reader      constant    com_api_type_pkg.t_dict_value   := 'EVNT0807';
EVENT_TERMINAL_JRNL             constant    com_api_type_pkg.t_dict_value   := 'EVNT0808';
EVENT_TERMINAL_EJRNL            constant    com_api_type_pkg.t_dict_value   := 'EVNT0809';
EVENT_TERMINAL_STMT             constant    com_api_type_pkg.t_dict_value   := 'EVNT0810';
EVENT_TERMINAL_TOD_CLOCK        constant    com_api_type_pkg.t_dict_value   := 'EVNT0811';
EVENT_TERMINAL_DEPOSITORY       constant    com_api_type_pkg.t_dict_value   := 'EVNT0812';
EVENT_TERMINAL_NIGHT_SAFE       constant    com_api_type_pkg.t_dict_value   := 'EVNT0813';
EVENT_TERMINAL_ENCRYPTOR        constant    com_api_type_pkg.t_dict_value   := 'EVNT0814';
EVENT_TERMINAL_TSCREEN_KEYB     constant    com_api_type_pkg.t_dict_value   := 'EVNT0815';
EVENT_TERMINAL_VOICE_GUIDANCE   constant    com_api_type_pkg.t_dict_value   := 'EVNT0816';
EVENT_TERMINAL_CAMERA           constant    com_api_type_pkg.t_dict_value   := 'EVNT0817';
EVENT_TERMINAL_BUNCH_ACPT       constant    com_api_type_pkg.t_dict_value   := 'EVNT0818';
EVENT_TERMINAL_ENVELOPE_DISP    constant    com_api_type_pkg.t_dict_value   := 'EVNT0819';
EVENT_TERMINAL_CHEQUE_MODULE    constant    com_api_type_pkg.t_dict_value   := 'EVNT0820';
EVENT_TERMINAL_BARCODE_READER   constant    com_api_type_pkg.t_dict_value   := 'EVNT0821';
EVENT_TERMINAL_COIN_DISP        constant    com_api_type_pkg.t_dict_value   := 'EVNT0822';
EVENT_TERMINAL_DISPENSER        constant    com_api_type_pkg.t_dict_value   := 'EVNT0823';
EVENT_TERMINAL_CONNNECTION      constant    com_api_type_pkg.t_dict_value   := 'EVNT0827';

EVENT_TERMINAL_JAM_BANKNOTES    constant    com_api_type_pkg.t_dict_value   := 'EVNT0824';
EVENT_TERMINAL_RETRACT          constant    com_api_type_pkg.t_dict_value   := 'EVNT0825';
EVENT_TERMINAL_REJ_BANKNOTES    constant    com_api_type_pkg.t_dict_value   := 'EVNT0826';

FILE_TYPE_FEES                  constant    com_api_type_pkg.t_dict_value   := 'FLTPFEES';
FILE_TYPE_MERCHANTS             constant    com_api_type_pkg.t_dict_value   := 'FLTPMRCH';
FILE_TYPE_TERMINALS             constant    com_api_type_pkg.t_dict_value   := 'FLTPTRMN';

REVENUE_SHARING_SCALE_TYPE      constant    com_api_type_pkg.t_dict_value   := 'SCTPRVSH';

CONTRACT_TYPE_PAYMENT_TERMINAL  constant    com_api_type_pkg.t_dict_value   := 'CNTPPMTT';

MERCHANT_NUMBER_MAX_LENGTH      constant    com_api_type_pkg.t_count        := 15;

DICT_CARD_DATA_INPUT_CAP        constant    com_api_type_pkg.t_dict_value   := 'F221';
DICT_CARDHOLDER_AUTH_CAP        constant    com_api_type_pkg.t_dict_value   := 'F222';
DICT_CARD_CAPTURE_CAP           constant    com_api_type_pkg.t_dict_value   := 'F223';
DICT_TERMINAL_OPERATING_ENV     constant    com_api_type_pkg.t_dict_value   := 'F224';
DICT_CARDHOLDER_PRESENCE_DATA   constant    com_api_type_pkg.t_dict_value   := 'F225';
DICT_CARD_PRESENCE_DATA         constant    com_api_type_pkg.t_dict_value   := 'F226';
DICT_CARD_DATA_INPUT_MODE       constant    com_api_type_pkg.t_dict_value   := 'F227';
DICT_CARDHOLDER_AUTH_METHOD     constant    com_api_type_pkg.t_dict_value   := 'F228';
DICT_CARDHOLDER_AUTH_ENTITY     constant    com_api_type_pkg.t_dict_value   := 'F229';
DICT_CARD_DATA_OUTPUT_CAP       constant    com_api_type_pkg.t_dict_value   := 'F22A';
DICT_TERMINAL_DATA_OUTP_CAP     constant    com_api_type_pkg.t_dict_value   := 'F22B';
DICT_PIN_CAPTURE_CAP            constant    com_api_type_pkg.t_dict_value   := 'F22C';

REVENUE_SHAR_SERVICE_TYPE_ID    constant    com_api_type_pkg.t_short_id     := 10001122;
MERCHANT_MAINT_SRV_TYPE_ID      constant    com_api_type_pkg.t_short_id     := 10000905;
ACQ_ACC_MIN_AMOUNT_THRESHOLD    constant    com_api_type_pkg.t_name         := 'ACQ_ACC_MIN_AMNT';
ACQ_AWARD                       constant    com_api_type_pkg.t_name         := 'ACQ_AWARD';
ACQ_MERCHANT_SETTLEMENT_MODE    constant    com_api_type_pkg.t_name         := 'ACQ_MERCHANT_SETTLEMENT_MODE';
ACQ_MERCHANT_STTL_MACROS_TYPE   constant    com_api_type_pkg.t_name         := 'ACQ_MERCHANT_SETTLEMENT_MACROS_TYPE';

MERCHANT_SETTLEMENT_MODE_NET    constant    com_api_type_pkg.t_name         := 'SLMD0001';
MERCHANT_SETTLEMENT_MODE_GROSS  constant    com_api_type_pkg.t_name         := 'SLMD0002';

ACQUIRING_RATE_TYPE             constant    com_api_type_pkg.t_dict_value   := 'RTTPACQ';

ACQ_AWARD_FEE                   constant    com_api_type_pkg.t_dict_value   := 'FETP0231';

LOV_ID_TERMINAL_TYPES           constant    com_api_type_pkg.t_tiny_id      := 28;

end;
/
