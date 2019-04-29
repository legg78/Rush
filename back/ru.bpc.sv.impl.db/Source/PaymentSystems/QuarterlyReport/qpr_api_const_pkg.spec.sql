create or replace package qpr_api_const_pkg
is 

    ARRAY_ID_STTL_ISS        constant         com_api_type_pkg.t_medium_id  := 10000013;
    ARRAY_ID_STTL_ACQ        constant         com_api_type_pkg.t_medium_id  := 10000012;
    ARRAY_ID_OPER_TYPE       constant         com_api_type_pkg.t_medium_id  := 10000014;
    ARRAY_ID_OPER_STATUS     constant         com_api_type_pkg.t_medium_id  := 10000020;
    ARRAY_CONV_ID_MC_CARDS   constant         com_api_type_pkg.t_medium_id  := 1012;
    ARRAY_CONV_ID_VISA_CARDS constant         com_api_type_pkg.t_medium_id  := 1013;
    
    VISA_CRYPTOGRAM          constant         com_api_type_pkg.t_dict_value := 'F227000C'; 
    VISA_ELECTRON            constant         com_api_type_pkg.t_byte_char  := 'L';

end qpr_api_const_pkg;
/ 
