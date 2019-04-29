create or replace package aci_api_const_pkg is
/*********************************************************
 *  ACI Base24 API constants <br />
 *  Created by Kopachev D.(kopachev@bpcbt.com)  at 17.10.2013 <br />
 *  Last changed by $Author: nasybullina $ <br />
 *  $LastChangedDate:: 2013-11-01 11:47:02 +0400#$ <br />
 *  Revision: $LastChangedRevision: 36465 $ <br />
 *  Module: aci_api_const_pkg <br />
 *  @headcom
 **********************************************************/

    REC_TYPE_EXTRACT_POSITION           constant com_api_type_pkg.t_dict_value := '00';
    REC_TYPE_CUSTOMER_TRANSACTION       constant com_api_type_pkg.t_dict_value := '01';
    REC_TYPE_ADMIN_TRANSACTION          constant com_api_type_pkg.t_dict_value := '04';
    REC_TYPE_EXCEPTION_POSTED           constant com_api_type_pkg.t_dict_value := '20';
    REC_TYPE_EXCEPTION_NOTPOSTED        constant com_api_type_pkg.t_dict_value := '21';
    REC_TYPE_EXCEPTION_FUTURE           constant com_api_type_pkg.t_dict_value := '22';
    REC_TYPE_EXCEPTION_INVALIDDATA      constant com_api_type_pkg.t_dict_value := '23';
    
    FILE_TYPE_TLF                       constant com_api_type_pkg.t_dict_value := 'TLF';
    FILE_TYPE_PTLF                      constant com_api_type_pkg.t_dict_value := 'PTLF';

    MESSAGE_TYPE_AUTH_RESPONSE          constant com_api_type_pkg.t_dict_value := '0210';
    MESSAGE_TYPE_AUTH_ADVICE            constant com_api_type_pkg.t_dict_value := '0220';
    MESSAGE_TYPE_CHARGEBACK_RESP        constant com_api_type_pkg.t_dict_value := '0412';
    MESSAGE_TYPE_REVERSAL               constant com_api_type_pkg.t_dict_value := '0420';
    MESSAGE_TYPE_ADJUSTMENT             constant com_api_type_pkg.t_dict_value := '5400';
    MESSAGE_TYPE_INFORMATION            constant com_api_type_pkg.t_dict_value := '9980';
    MESSAGE_TYPE_LOG_REQUEST            constant com_api_type_pkg.t_dict_value := '9991';
    
    EXTRACT_TAPE_HEADER                 constant com_api_type_pkg.t_dict_value := 'TH';
    EXTRACT_TAPE_TRAILER                constant com_api_type_pkg.t_dict_value := 'TT';
    EXTRACT_FILE_HEADER                 constant com_api_type_pkg.t_dict_value := 'FH';
    EXTRACT_FILE_TRAILER                constant com_api_type_pkg.t_dict_value := 'FT';
    EXTRACT_DATA_RECORD                 constant com_api_type_pkg.t_dict_value := 'DR';
    
    BASE24_INST_ARRAY_TYPE              constant com_api_type_pkg.t_tiny_id := 1008;
    BASE24_NETWORK_ARRAY_TYPE           constant com_api_type_pkg.t_tiny_id := 1009;
    BASE24_CARD_TYPE_ARRAY_TYPE         constant com_api_type_pkg.t_tiny_id := 1010;
    BASE24_CARD_STATUS_ARRAY_TYPE       constant com_api_type_pkg.t_tiny_id := 1011;

    INTERFACE_BNET                      constant com_api_type_pkg.t_dict_value := 'BNET';
    INTERFACE_VISA                      constant com_api_type_pkg.t_dict_value := 'VISA';

    FILE_TYPE_CAF                       constant com_api_type_pkg.t_dict_value := 'FLTPCAF';
    FILE_TYPE_SEMF                      constant com_api_type_pkg.t_dict_value := 'FLTPSEMF';
    FILE_TYPE_MMF                       constant com_api_type_pkg.t_dict_value := 'FLTPMMF';

end;
/
