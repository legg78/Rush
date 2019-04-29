create or replace package emv_api_const_pkg is
/************************************************************
 * EMV constants <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 15.06.2010 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: emv_api_const_pkg <br />
 * @headcom
 ************************************************************/

    DATA_TYPE_KEY              constant com_api_type_pkg.t_dict_value := 'EMVT';
    DATA_TYPE_ALPHA_NUMERIC    constant com_api_type_pkg.t_dict_value := 'EMVT0100';
    DATA_TYPE_TEXT             constant com_api_type_pkg.t_dict_value := 'EMVT0200';
    DATA_TYPE_COMP_NUMERIC     constant com_api_type_pkg.t_dict_value := 'EMVT0300';
    DATA_TYPE_DATE_ALPHA_NUM   constant com_api_type_pkg.t_dict_value := 'EMVT0400';
    DATA_TYPE_DATE_NUMERIC     constant com_api_type_pkg.t_dict_value := 'EMVT0500';
    DATA_TYPE_BYTE_HEXADEC     constant com_api_type_pkg.t_dict_value := 'EMVT0600';
    DATA_TYPE_DECIMAL          constant com_api_type_pkg.t_dict_value := 'EMVT0700';
    DATA_TYPE_NUMERIC          constant com_api_type_pkg.t_dict_value := 'EMVT0800';
    
    TAG_TYPE_KEY               constant com_api_type_pkg.t_dict_value := 'EMVP';
    DATA_TYPE_STATIC           constant com_api_type_pkg.t_dict_value := 'EMVP0100';
    DATA_TYPE_DYNAMIC          constant com_api_type_pkg.t_dict_value := 'EMVP0200';
    
    FORMAT_LOWERCASE           constant com_api_type_pkg.t_dict_value := 'LOWER';
    FORMAT_RANGE_INDICATOR     constant com_api_type_pkg.t_dict_value := '..';

    SCRIPT_TYPE_BLOCK_CARD     constant com_api_type_pkg.t_dict_value := 'SRTP0010';
    SCRIPT_TYPE_BLOCK_APPL     constant com_api_type_pkg.t_dict_value := 'SRTP0030';
    SCRIPT_TYPE_UNBLOCK_APPL   constant com_api_type_pkg.t_dict_value := 'SRTP0040';
    SCRIPT_TYPE_PIN_UNBLOCK    constant com_api_type_pkg.t_dict_value := 'SRTP0050';
    SCRIPT_TYPE_PIN_CHANGE     constant com_api_type_pkg.t_dict_value := 'SRTP0060';
    SCRIPT_TYPE_LWR_CNT_LIMIT  constant com_api_type_pkg.t_dict_value := 'SRTP0070';
    SCRIPT_TYPE_UPR_CNT_LIMIT  constant com_api_type_pkg.t_dict_value := 'SRTP0080';
    SCRIPT_TYPE_LWR_AMNT_LIMIT constant com_api_type_pkg.t_dict_value := 'SRTP0090';
    SCRIPT_TYPE_UPR_AMNT_LIMIT constant com_api_type_pkg.t_dict_value := 'SRTP0100';
    
    SCRIPT_STATUS_WAITING      constant com_api_type_pkg.t_dict_value := 'SRST0010';
    SCRIPT_STATUS_PROCESSING   constant com_api_type_pkg.t_dict_value := 'SRST0020';
    SCRIPT_STATUS_PROCESSED    constant com_api_type_pkg.t_dict_value := 'SRST0030';
    SCRIPT_STATUS_FAILED       constant com_api_type_pkg.t_dict_value := 'SRST0040';
    SCRIPT_STATUS_OVERLOADED   constant com_api_type_pkg.t_dict_value := 'SRST0050';

    ENTITY_TYPE_EMV_SCHEME     constant com_api_type_pkg.t_dict_value := 'ENTTESCH';
    ENTITY_TYPE_EMV_BLOCK      constant com_api_type_pkg.t_dict_value := 'ENTTEBLK';
    ENTITY_TYPE_EMV_VAR        constant com_api_type_pkg.t_dict_value := 'ENTTEVAR';

    PROFILE                    constant com_api_type_pkg.t_dict_value := 'EPFL';
    PROFILE_CONTACT            constant com_api_type_pkg.t_dict_value := 'EPFL0100';
    PROFILE_PAYPASS            constant com_api_type_pkg.t_dict_value := 'EPFL0200';
    PROFILE_PAYWAVE_QVSDC      constant com_api_type_pkg.t_dict_value := 'EPFL0300';
    PROFILE_PAYWAVE_MSD        constant com_api_type_pkg.t_dict_value := 'EPFL0400';

    VAR_TYPE_TKEY              constant com_api_type_pkg.t_dict_value := 'EVTP0100';
    VAR_TYPE_ALGORITHM         constant com_api_type_pkg.t_dict_value := 'EVTP0200';
    VAR_TYPE_METADATA          constant com_api_type_pkg.t_dict_value := 'EVTP0300';
    VAR_TYPE_APPL_NAME         constant com_api_type_pkg.t_dict_value := 'EVTP0400';
    
    EMV_SCHEME_VISA            constant com_api_type_pkg.t_dict_value := 'EMVS0010';
    EMV_SCHEME_MC              constant com_api_type_pkg.t_dict_value := 'EMVS0020';
    EMV_SCHEME_MUP             constant com_api_type_pkg.t_dict_value := 'EMVS0040';
    
    EMV_TAG_AID                constant com_api_type_pkg.t_name       := '4F';
    EMV_TAG_PAN_SEQ_NUMBER     constant com_api_type_pkg.t_name       := '5F34';

end;
/
