create or replace package ecm_api_const_pkg is
/************************************************************
 * EMV constants <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 16.04.2013 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: ecm_api_const_pkg <br />
 * @headcom
 ************************************************************/
    
    DSEC_PROG_SERVICE_TYPE_ID    constant com_api_type_pkg.t_short_id := 10001717;

    DSEC_MESSAGE_STATUS          constant com_api_type_pkg.t_dict_value := '3DMS';
    DSEC_MES_STATUS_SUCCESS      constant com_api_type_pkg.t_dict_value := '3DMSY';
    DSEC_MES_STATUS_NOT_SUCCESS  constant com_api_type_pkg.t_dict_value := '3DMSN';
    DSEC_MES_STATUS_UNABLE       constant com_api_type_pkg.t_dict_value := '3DMSU';

    AAV_ALGORITHM_CVC2           constant com_api_type_pkg.t_dict_value := 'AAVACVC2';
    AAV_ALGORITHM_HMAC           constant com_api_type_pkg.t_dict_value := 'AAVAHMAC';

end;
/
