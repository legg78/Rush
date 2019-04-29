create or replace package rul_api_const_pkg is
/*********************************************************
 *  Constant for rules <br />
 *  Created by Khougaev A.(khougaev@bpcbt.com)  at 21.01.2010 <br />
 *  Module: RUL_API_CONST_PKG <br />
 *  @headcom
 **********************************************************/

BASE_VALUE_CONSTANT        constant com_api_type_pkg.t_dict_value := 'BVTPCNST';
BASE_VALUE_PARAMETER       constant com_api_type_pkg.t_dict_value := 'BVTPPRMT';
BASE_VALUE_INDEX           constant com_api_type_pkg.t_dict_value := 'BVTPINDX';
BASE_VALUE_ARRAY           constant com_api_type_pkg.t_dict_value := 'BVTPARRY';

PRODUCT_STATUS_ACTIVE      constant com_api_type_pkg.t_dict_value := 'PRDS0100';
PRODUCT_STATUS_INACTIVE    constant com_api_type_pkg.t_dict_value := 'PRDS0200';

TRANSFORMATION_NO          constant com_api_type_pkg.t_dict_value := 'TSFTNOTR';
TRANSFORMATION_ORACLE_SQL  constant com_api_type_pkg.t_dict_value := 'TSFTOSQL';

SCALE_TYPE_DICTIONARY      constant com_api_type_pkg.t_dict_value := 'SCTP';
SCALE_TYPE_RULES           constant com_api_type_pkg.t_dict_value := 'SCTPRULE';
SCALE_TYPE_PRODUCT         constant com_api_type_pkg.t_dict_value := 'SCTPPROD';
SCALE_TYPE_SCENARIO        constant com_api_type_pkg.t_dict_value := 'SCTPSCNR';
SCALE_TYPE_CHOISE_HSM      constant com_api_type_pkg.t_dict_value := 'SCTPCHSM';
SCALE_TYPE_SETTLEMENT      constant com_api_type_pkg.t_dict_value := 'SCTPSTTT';
SCALE_TYPE_EVENT           constant com_api_type_pkg.t_dict_value := 'SCTPEVNT';
SCALE_TYPE_NOTIFICATION    constant com_api_type_pkg.t_dict_value := 'SCTPNTFC';
SCALE_TYPE_APP_FLOW        constant com_api_type_pkg.t_dict_value := 'SCTPFLOW';
SCALE_TYPE_EMV_APPL        constant com_api_type_pkg.t_dict_value := 'SCTPEAPL';
SCALE_TYPE_PERSO_TEMPL     constant com_api_type_pkg.t_dict_value := 'SCTPPTPL';

PAD_TYPE_LEFT              constant com_api_type_pkg.t_dict_value := 'PADTLEFT';
PAD_TYPE_RIGHT             constant com_api_type_pkg.t_dict_value := 'PADTRGHT';

ENTITY_TYPE_GROUP_ATTR     constant com_api_type_pkg.t_dict_value := 'ENTTAGRP';

ALGORITHM_TYPE_SQNC        constant com_api_type_pkg.t_dict_value := 'IRAGSQNC';
ALGORITHM_TYPE_RNDM        constant com_api_type_pkg.t_dict_value := 'IRAGRNDM';
ALGORITHM_TYPE_RNGS        constant com_api_type_pkg.t_dict_value := 'IRAGRNGS';
ALGORITHM_TYPE_RNGR        constant com_api_type_pkg.t_dict_value := 'IRAGRNGR';

XML_HEADER                 constant com_api_type_pkg.t_original_data := com_api_const_pkg.XML_HEADER;

RULE_CATEGORY_ALGORITHM    constant com_api_type_pkg.t_dict_value := 'RLCGALGP';

CAPACITY_OF_MOD_STATIC_PKG constant com_api_type_pkg.t_count      := 100;

end;
/
