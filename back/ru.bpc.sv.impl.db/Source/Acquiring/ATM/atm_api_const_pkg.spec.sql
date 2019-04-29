create or replace package atm_api_const_pkg is
/*******************************************************************
*  API constants for ATM module<br />
*  Created by Fomichev A.(fomichev@bpc.ru)  at 03.12.2010 <br />
*  Last changed by $Author: fomichev $ <br />
*  $LastChangedDate:: 2010-12-20 12:59:00 +0400#$ <br />
*  Revision: $LastChangedRevision: 7178 $ <br />
*  Module: atm_api_const_pkg <br />
*  @headcom
******************************************************************/

ATM_PART_TYPE_TOD_CLOCK        constant com_api_type_pkg.t_dict_value := 'HCDT0001'; -- Time-of-Day Clock (A)
ATM_PART_TYPE_CARD_READER      constant com_api_type_pkg.t_dict_value := 'HCDT0004';
ATM_PART_TYPE_ENV_DEPOSITORY   constant com_api_type_pkg.t_dict_value := 'HCDT0006'; -- Envelope Depository (F)
ATM_PART_TYPE_RECEIPT_PRINTER  constant com_api_type_pkg.t_dict_value := 'HCDT0007';
ATM_PART_TYPE_JOURNAL_PRINTER  constant com_api_type_pkg.t_dict_value := 'HCDT0008';
ATM_PART_TYPE_NIGHT_SAFE_DPST  constant com_api_type_pkg.t_dict_value := 'HCDT0011'; -- Night Safe Depository (K)
ATM_PART_TYPE_ENCRYPTOR        constant com_api_type_pkg.t_dict_value := 'HCDT0012';
ATM_PART_TYPE_SECURITY_CAMERA  constant com_api_type_pkg.t_dict_value := 'HCDT0013';
ATM_PART_TYPE_CARDHLDR_DISPLAY constant com_api_type_pkg.t_dict_value := 'HCDT0019'; -- Cardholder Display (S)
ATM_PART_TYPE_STMT_PRINTER     constant com_api_type_pkg.t_dict_value := 'HCDT0022';
ATM_PART_TYPE_COIN_DISPENSER   constant com_api_type_pkg.t_dict_value := 'HCDT0025';
ATM_PART_TYPE_ENV_DISPENSER    constant com_api_type_pkg.t_dict_value := 'HCDT0028'; -- Envelope Dispenser (\)
ATM_PART_TYPE_BARCODE_READER   constant com_api_type_pkg.t_dict_value := 'HCDT0031'; -- Barcode Reader (f)
ATM_PART_TYPE_CHK_PROCESS_MOD  constant com_api_type_pkg.t_dict_value := 'HCDT0032'; -- Cheque Processing Module (CPM)
ATM_PART_TYPE_NOTE_ACCEPTOR    constant com_api_type_pkg.t_dict_value := 'HCDT0033'; -- Bunch Note Acceptor (BNA) (w)
ATM_PART_TYPE_ELECTRON_JOURNAL constant com_api_type_pkg.t_dict_value := 'HCDT0034';
ATM_PART_TYPE_VOICE_GUIDANCE   constant com_api_type_pkg.t_dict_value := 'HCDT0035';
ATM_PART_TYPE_DISPENSER        constant com_api_type_pkg.t_dict_value := 'HCDT0036';
   
--CARD_READER_STATUS_DICT        constant com_api_type_pkg.t_dict_value := 'CARS';
CARD_READER_STATUS_OK          constant com_api_type_pkg.t_dict_value := 'CARSCROK';
CARD_READER_STATUS_OVERFILL    constant com_api_type_pkg.t_dict_value := 'CARSCROF';
CARD_READER_STATUS_ERROR       constant com_api_type_pkg.t_dict_value := 'CARSCRER';
   
PRINTER_STATUS_DICT            constant com_api_type_pkg.t_dict_value := 'PRST'; -- Receipt
PRINTER_STATUS_OK              constant com_api_type_pkg.t_dict_value := 'PRSTPROK';
PRINTER_STATUS_NOT_CONFIGURED  constant com_api_type_pkg.t_dict_value := 'PRSTPRNC';
PRINTER_STATUS_SUPPLY_WARNING  constant com_api_type_pkg.t_dict_value := 'PRSTPRSW';
PRINTER_STATUS_SUPPLY_ERROR    constant com_api_type_pkg.t_dict_value := 'PRSTPRSE';
PRINTER_STATUS_ERROR           constant com_api_type_pkg.t_dict_value := 'PRSTPRER';
   
JRNL_STATUS_DICT               constant com_api_type_pkg.t_dict_value := 'JRNL';
JRNL_STATUS_OK                 constant com_api_type_pkg.t_dict_value := 'JRNLPROK';
JRNL_STATUS_NOT_CONFIGURED     constant com_api_type_pkg.t_dict_value := 'JRNLPRNC';
JRNL_STATUS_SUPPLY_WARNING     constant com_api_type_pkg.t_dict_value := 'JRNLPRSW';
JRNL_STATUS_SUPPLY_ERROR       constant com_api_type_pkg.t_dict_value := 'JRNLPRSE';
JRNL_STATUS_ERROR              constant com_api_type_pkg.t_dict_value := 'JRNLPRER';
   
EJRN_STATUS_DICT               constant com_api_type_pkg.t_dict_value := 'EJRN';
EJRN_STATUS_OK                 constant com_api_type_pkg.t_dict_value := 'EJRNPROK';
EJRN_STATUS_NOT_CONFIGURED     constant com_api_type_pkg.t_dict_value := 'EJRNPRNC';
EJRN_STATUS_SUPPLY_WARNING     constant com_api_type_pkg.t_dict_value := 'EJRNPRSW';
EJRN_STATUS_SUPPLY_ERROR       constant com_api_type_pkg.t_dict_value := 'EJRNPRSE';
EJRN_STATUS_ERROR              constant com_api_type_pkg.t_dict_value := 'EJRNPRER';

STPR_STATUS_DICT               constant com_api_type_pkg.t_dict_value := 'STPR';
STPR_STATUS_OK                 constant com_api_type_pkg.t_dict_value := 'STPRPROK';
STPR_STATUS_NOT_CONFIGURED     constant com_api_type_pkg.t_dict_value := 'STPRPRNC';
STPR_STATUS_SUPPLY_WARNING     constant com_api_type_pkg.t_dict_value := 'STPRPRSW';
STPR_STATUS_SUPPLY_ERROR       constant com_api_type_pkg.t_dict_value := 'STPRPRSE';
STPR_STATUS_ERROR              constant com_api_type_pkg.t_dict_value := 'STPRPRER';

PAPER_STATUS_DICT              constant com_api_type_pkg.t_dict_value := 'PPST';
PAPER_STATUS_OK                constant com_api_type_pkg.t_dict_value := 'PPSTPPOK';
PAPER_STATUS_LOW               constant com_api_type_pkg.t_dict_value := 'PPSTPLOW';
PAPER_STATUS_EXHAUSTED         constant com_api_type_pkg.t_dict_value := 'PPSTPPEX';
   
RIBBON_STATUS_DICT             constant com_api_type_pkg.t_dict_value := 'RBST';
RIBBON_STATUS_OK               constant com_api_type_pkg.t_dict_value := 'RBSTRBOK';
RIBBON_STATUS_OPTIONAL         constant com_api_type_pkg.t_dict_value := 'RBSTRBOR';
RIBBON_STATUS_MANDATORY        constant com_api_type_pkg.t_dict_value := 'RBSTRBMR';
   
HEAD_STATUS_DICT               constant com_api_type_pkg.t_dict_value := 'HDST';
HEAD_STATUS_OK                 constant com_api_type_pkg.t_dict_value := 'HDSTHDOK';
HEAD_STATUS_OPTIONAL           constant com_api_type_pkg.t_dict_value := 'HDSTHDOR';
HEAD_STATUS_MANDATORY          constant com_api_type_pkg.t_dict_value := 'HDSTHDMR';
   
KNIFE_STATUS_DICT              constant com_api_type_pkg.t_dict_value := 'KNST';
KNIFE_STATUS_OK                constant com_api_type_pkg.t_dict_value := 'KNSTKNOK';
KNIFE_STATUS_OPTIONAL          constant com_api_type_pkg.t_dict_value := 'KNSTKNOR';
KNIFE_STATUS_MANDATORY         constant com_api_type_pkg.t_dict_value := 'KNSTKNMR';
      
STMT_CAPT_BIN_STATUS_DICT      constant com_api_type_pkg.t_dict_value := 'SCBS';
STMT_CAPT_BIN_STATUS_OK        constant com_api_type_pkg.t_dict_value := 'SCBSSTOK';
STMT_CAPT_BIN_STATUS_OVERFILL  constant com_api_type_pkg.t_dict_value := 'SCBSOVER';

--TOD_CLOCK_STATUS_DICT          constant com_api_type_pkg.t_dict_value := 'TDST';
TOD_CLOCK_STATUS_OK            constant com_api_type_pkg.t_dict_value := 'TDSTSTOK';
TOD_CLOCK_STATUS_RESET         constant com_api_type_pkg.t_dict_value := 'TDSTCRBR';
TOD_CLOCK_STATUS_STOP          constant com_api_type_pkg.t_dict_value := 'TDSTSTOP';
   
--DEPOSITORY_STATUS_DICT         constant com_api_type_pkg.t_dict_value := 'DSST';
DEPOSITORY_STATUS_OK           constant com_api_type_pkg.t_dict_value := 'DSSTSTOK';
DEPOSITORY_STATUS_ERROR        constant com_api_type_pkg.t_dict_value := 'DSSTDSER';
DEPOSITORY_STATUS_OVERFILL     constant com_api_type_pkg.t_dict_value := 'DSSTOVER';
DEPOSITORY_STATUS_NOT_PRESENT  constant com_api_type_pkg.t_dict_value := 'DSSTNOPR';
            
--NIGHT_SAFE_STATUS_DICT         constant com_api_type_pkg.t_dict_value := 'NDST';
NIGHT_SAFE_STATUS_OK           constant com_api_type_pkg.t_dict_value := 'NDSTSTOK';
NIGHT_SAFE_STATUS_OVERFILL     constant com_api_type_pkg.t_dict_value := 'NDSTOVER';
NIGHT_SAFE_STATUS_NOT_PRESENT  constant com_api_type_pkg.t_dict_value := 'NDSTNOPR';

--ENCRYPTOR_STATUS_DICT          constant com_api_type_pkg.t_dict_value := 'ENST';
ENCRYPTOR_STATUS_OK            constant com_api_type_pkg.t_dict_value := 'ENSTSTOK';
ENCRYPTOR_STATUS_ERROR         constant com_api_type_pkg.t_dict_value := 'ENSTENER';
ENCRYPTOR_STATUS_NOT_CONF      constant com_api_type_pkg.t_dict_value := 'ENSTSTOK';
   
--TSCREEN_KEYB_STATUS_DICT       constant com_api_type_pkg.t_dict_value := 'TKST';
TSCREEN_KEYB_STATUS_OK         constant com_api_type_pkg.t_dict_value := 'TKSTSTOK';
TSCREEN_KEYB_STATUS_ERROR      constant com_api_type_pkg.t_dict_value := 'TKSTTKER';
TSCREEN_KEYB_STATUS_NOT_PR     constant com_api_type_pkg.t_dict_value := 'TKSTNOPR';

--VOICE_GUIDANCE_STATUS_DICT     constant com_api_type_pkg.t_dict_value := 'VGST';
VOICE_GUIDANCE_STATUS_OK       constant com_api_type_pkg.t_dict_value := 'VGSTSTOK';
VOICE_GUIDANCE_STATUS_ERROR    constant com_api_type_pkg.t_dict_value := 'VGSTVGER';
VOICE_GUIDANCE_STATUS_NOTPR    constant com_api_type_pkg.t_dict_value := 'VGSTNOPR';
   
--CAMERA_STATUS_DICT             constant com_api_type_pkg.t_dict_value := 'CAMS';
CAMERA_STATUS_OK               constant com_api_type_pkg.t_dict_value := 'CAMSSTOK';
CAMERA_STATUS_SUPPLY_WARNING   constant com_api_type_pkg.t_dict_value := 'CAMSSWRN';
CAMERA_STATUS_SUPPLY_ERROR     constant com_api_type_pkg.t_dict_value := 'CAMSSERR';
CAMERA_STATUS_ERROR            constant com_api_type_pkg.t_dict_value := 'CAMSSTER';
   
--BUNCH_ACPT_STATUS_DICT         constant com_api_type_pkg.t_dict_value := 'BAST';
BUNCH_ACPT_STATUS_OK           constant com_api_type_pkg.t_dict_value := 'BASTSTOK';
BUNCH_ACPT_STATUS_NOPR         constant com_api_type_pkg.t_dict_value := 'BASTNOPR';
   
--ENVELOPE_DISP_STATUS_DICT      constant com_api_type_pkg.t_dict_value := 'EDST';
ENVELOPE_DISP_STATUS_OK        constant com_api_type_pkg.t_dict_value := 'EDSTSTOK';
ENVELOPE_DISP_STATUS_ERROR     constant com_api_type_pkg.t_dict_value := 'EDSTSERR';
ENVELOPE_DISP_STATUS_LOW       constant com_api_type_pkg.t_dict_value := 'EDSTSLOW';
ENVELOPE_DISP_STATUS_EX        constant com_api_type_pkg.t_dict_value := 'EDSTEDEX';
ENVELOPE_DISP_STATUS_NOPR      constant com_api_type_pkg.t_dict_value := 'EDSTNOPR';
   
--CHEQUE_MODULE_STATUS_DICT      constant com_api_type_pkg.t_dict_value := 'CPST';
CHEQUE_MODULE_STATUS_OK        constant com_api_type_pkg.t_dict_value := 'CPSTSTOK';
CHEQUE_MODULE_STATUS_NOPR      constant com_api_type_pkg.t_dict_value := 'CPSTNOPR';
  
--BARCODE_READER_STATUS_DICT     constant com_api_type_pkg.t_dict_value := 'BRST';
BARCODE_READER_STATUS_OK       constant com_api_type_pkg.t_dict_value := 'BRSTSTOK';
BARCODE_READER_STATUS_ERROR    constant com_api_type_pkg.t_dict_value := 'BRSTSERR';
BARCODE_READER_STATUS_NOPR     constant com_api_type_pkg.t_dict_value := 'BRSTNOPR';

--COIN_DISP_STATUS_DICT          constant com_api_type_pkg.t_dict_value := 'CDST';
COIN_DISP_STATUS_OK            constant com_api_type_pkg.t_dict_value := 'CDSTSTOK';
COIN_DISP_STATUS_ERROR         constant com_api_type_pkg.t_dict_value := 'CDSTSERR';
COIN_DISP_STATUS_NOPR          constant com_api_type_pkg.t_dict_value := 'CDSTNOPR';

--DISPENSER_STATUS_DICT          constant com_api_type_pkg.t_dict_value := 'DIST';
DISPENSER_STATUS_OK            constant com_api_type_pkg.t_dict_value := 'DISTSTOK';
DISPENSER_STATUS_ERROR         constant com_api_type_pkg.t_dict_value := 'DISTSERR';
DISPENSER_STATUS_RBOF          constant com_api_type_pkg.t_dict_value := 'DISTRBOF';
DISPENSER_STATUS_NOPR          constant com_api_type_pkg.t_dict_value := 'DISTNOPR';
   
WORKFLOW_STATUS_DICT           constant com_api_type_pkg.t_dict_value := 'AWST';
WORKFLOW_STATUS_UNDEFINED      constant com_api_type_pkg.t_dict_value := 'AWSTUNDF';
WORKFLOW_STATUS_IDLE           constant com_api_type_pkg.t_dict_value := 'AWSTIDLE';
WORKFLOW_STATUS_PROCEDURE      constant com_api_type_pkg.t_dict_value := 'AWSTPROC';
WORKFLOW_STATUS_OPERATION      constant com_api_type_pkg.t_dict_value := 'AWSTOPER';

SERVICE_STATUS_DICT            constant com_api_type_pkg.t_dict_value := 'ASST';
SERVICE_STATUS_UNDEFINED       constant com_api_type_pkg.t_dict_value := 'ASSTUNDF';
SERVICE_STATUS_IN_SERVICE      constant com_api_type_pkg.t_dict_value := 'ASSTISRV';
SERVICE_STATUS_OUT_OF_S        constant com_api_type_pkg.t_dict_value := 'ASSTOSRV';
   
DISPENSER_TYPE_CASSETTE        constant com_api_type_pkg.t_dict_value := 'DSTPCASS';
DISPENSER_TYPE_HOPPER          constant com_api_type_pkg.t_dict_value := 'DSTPHOPP';

CASSETTE_STATUS_DISABLED       constant com_api_type_pkg.t_dict_value := 'CSSTDSBL';
CASSETTE_STATUS_ACTIVE         constant com_api_type_pkg.t_dict_value := 'CSSTACTV';
CASSETTE_STATUS_NOTES_LOW      constant com_api_type_pkg.t_dict_value := 'CSSTNLOW';
CASSETTE_STATUS_OUT_OF_NOTES   constant com_api_type_pkg.t_dict_value := 'CSSTOUTN';
CASSETTE_STATUS_ERROR          constant com_api_type_pkg.t_dict_value := 'CSSTSERR';

SYNC_NOT_PERMITTED             constant com_api_type_pkg.t_dict_value := 'ATMS0001';
SYNC_PERMITTED                 constant com_api_type_pkg.t_dict_value := 'ATMS0002';
SYNC_ONLY_VERIFICATION         constant com_api_type_pkg.t_dict_value := 'ATMS0003';

COMMON_TECH_STATUS_NA          constant com_api_type_pkg.t_dict_value := 'ATCS0000';
COMMON_TECH_STATUS_OK          constant com_api_type_pkg.t_dict_value := 'ATCS0001';
COMMON_TECH_STATUS_WARNING     constant com_api_type_pkg.t_dict_value := 'ATCS0002';
COMMON_TECH_STATUS_PROBLEM     constant com_api_type_pkg.t_dict_value := 'ATCS0003';
   
COMMON_FIN_STATUS_NA           constant com_api_type_pkg.t_dict_value := 'AFCS0000';
COMMON_FIN_STATUS_OK           constant com_api_type_pkg.t_dict_value := 'AFCS0001';
COMMON_FIN_STATUS_WARNING      constant com_api_type_pkg.t_dict_value := 'AFCS0002';
COMMON_FIN_STATUS_PROBLEM      constant com_api_type_pkg.t_dict_value := 'AFCS0003';
   
COMMON_EXPEND_STATUS_NA        constant com_api_type_pkg.t_dict_value := 'AECS0000';
COMMON_EXPEND_STATUS_OK        constant com_api_type_pkg.t_dict_value := 'AECS0001';
COMMON_EXPEND_STATUS_WARNING   constant com_api_type_pkg.t_dict_value := 'AECS0002';
COMMON_EXPEND_STATUS_PROBLEM   constant com_api_type_pkg.t_dict_value := 'AECS0003';
   
ATM_SERVICE_STATUS_CHANGE      constant com_api_type_pkg.t_dict_value := 'ATMMCHNG';
ATM_SERVICE_STATUS_NOT_CHANGE  constant com_api_type_pkg.t_dict_value := 'ATMMNOCH';

CONECTION_STATUS_DICT          constant com_api_type_pkg.t_dict_value := 'CNST';
CONECTION_STATUS_OPEN          constant com_api_type_pkg.t_dict_value := 'CNST0010';
CONECTION_STATUS_CLOSE         constant com_api_type_pkg.t_dict_value := 'CNST0020';
    
AGGREGATED_STATUS_KEY          constant com_api_type_pkg.t_dict_value := 'AGRS';
AGGR_STATUS_ABSENCE_COMM       constant com_api_type_pkg.t_dict_value := 'AGRS0010';
AGGR_STATUS_CLOSED_FATAL_ERROR constant com_api_type_pkg.t_dict_value := 'AGRS0020';
AGGR_STATUS_CLOSED             constant com_api_type_pkg.t_dict_value := 'AGRS0030';
AGGR_STATUS_CLOSED_AUTO_PROC   constant com_api_type_pkg.t_dict_value := 'AGRS0040';
AGGR_STATUS_OPEN_DISP_NOT_WORK constant com_api_type_pkg.t_dict_value := 'AGRS0050';
AGGR_STATUS_OPEN_OUT_OF_NOTES  constant com_api_type_pkg.t_dict_value := 'AGRS0060';
AGGR_STATUS_OPEN_CASSETTEEMPTY constant com_api_type_pkg.t_dict_value := 'AGRS0070';
AGGR_STATUS_OPEN_NOTES_LOW     constant com_api_type_pkg.t_dict_value := 'AGRS0080';
AGGR_STATUS_OPEN               constant com_api_type_pkg.t_dict_value := 'AGRS0090';
    
end;
/
