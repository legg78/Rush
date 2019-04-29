create or replace package sec_api_const_pkg is
/**********************************************************
 * Security constants
 * Created by Kopachev D.(kopachev@bpcbt.com) at 21.05.2010
 * Last changed by $Author: krukov $ <br />
 * $LastChangedDate:: 2011-03-01 14:46:54 +0300#$ <br />
 * Revision: $LastChangedRevision: 8281 $ <br /> 
 * Module: sec_api_const_pkg
 * @headcom
 **********************************************************/    

    -- Security key type
    SECURITY_KEY_TYPE           constant com_api_type_pkg.t_dict_value := 'ENKT';

    -- DES keys
    SECURITY_DES_KEY_ZPK            constant com_api_type_pkg.t_dict_value := 'ENKTZPK';
    SECURITY_DES_KEY_PPK            constant com_api_type_pkg.t_dict_value := 'ENKTPPK';
    SECURITY_DES_KEY_PEKT           constant com_api_type_pkg.t_dict_value := 'ENKTZPK';
    SECURITY_DES_KEY_PVK            constant com_api_type_pkg.t_dict_value := 'ENKTPVK';
    SECURITY_DES_KEY_PIBK           constant com_api_type_pkg.t_dict_value := 'ENKTPIBK';
    SECURITY_DES_KEY_CVK            constant com_api_type_pkg.t_dict_value := 'ENKTCVK';
    SECURITY_DES_KEY_CVK2           constant com_api_type_pkg.t_dict_value := 'ENKTCVK2';
    SECURITY_DES_KEY_IMK_AC         constant com_api_type_pkg.t_dict_value := 'ENKTIMKA';
    SECURITY_DES_KEY_IMK_DAC        constant com_api_type_pkg.t_dict_value := 'ENKTIMKD';
    SECURITY_DES_KEY_IMK_IDN        constant com_api_type_pkg.t_dict_value := 'ENKTIMKN';
    SECURITY_DES_KEY_IMK_SMC        constant com_api_type_pkg.t_dict_value := 'ENKTIMKC';
    SECURITY_DES_KEY_IMK_SMI        constant com_api_type_pkg.t_dict_value := 'ENKTIMKI';
    SECURITY_DES_KEY_IMK_CVC3       constant com_api_type_pkg.t_dict_value := 'ENKTIMK3';
    SECURITY_DES_KEY_KEK            constant com_api_type_pkg.t_dict_value := 'ENKTKEK';
    SECURITY_DES_KEY_TPK            constant com_api_type_pkg.t_dict_value := 'ENKTTPK';
    SECURITY_DES_KEY_TMKP           constant com_api_type_pkg.t_dict_value := 'ENKTTMKP';
    SECURITY_DES_KEY_TMKA           constant com_api_type_pkg.t_dict_value := 'ENKTTMKA';
    SECURITY_DES_KEY_TAK            constant com_api_type_pkg.t_dict_value := 'ENKTTAK';
    SECURITY_DES_KEY_ZPKI           constant com_api_type_pkg.t_dict_value := 'ENKTZPKI';
    SECURITY_DES_KEY_ZPKA           constant com_api_type_pkg.t_dict_value := 'ENKTZPKA';
    SECURITY_DES_KEY_TMK            constant com_api_type_pkg.t_dict_value := 'ENKTTMK';
    SECURITY_DES_KEY_ZMK            constant com_api_type_pkg.t_dict_value := 'ENKTZMK';
    SECURITY_DES_KEY_LMK            constant com_api_type_pkg.t_dict_value := 'ENKTLMK';

    SECURITY_DES_KEY_HMAC           constant com_api_type_pkg.t_dict_value := 'ENKTHMAC';

    -- RSA Key Set
    SECURITY_RSA_ISS_KEYSET         constant com_api_type_pkg.t_dict_value := 'ENKTIRKS';
    SECURITY_RSA_CA_KEYSET          constant com_api_type_pkg.t_dict_value := 'ENKTARKS';
    SECURITY_RSA_ACS_KEYSET         constant com_api_type_pkg.t_dict_value := 'ENKTACSR';

    -- RSA Key State
    RSA_KEY_STATE_INIT              constant com_api_type_pkg.t_dict_value := 'ENKS0100';
    RSA_KEY_STATE_ACTIVE            constant com_api_type_pkg.t_dict_value := 'ENKS0200';

    -- Naming component for key mailer
    PARAM_COMPONENT_KEY             constant com_api_type_pkg.t_name := 'COMPONENT_KEY';
    PARAM_COMPONENT_NUM             constant com_api_type_pkg.t_name := 'COMPONENT_NUM';
    PARAM_OBJECT_NUMBER             constant com_api_type_pkg.t_name := 'OBJECT_NUMBER';
    PARAM_KEY_TYPE                  constant com_api_type_pkg.t_name := 'KEY_TYPE';

    -- Certificate authority type
    AUTHORITY_TYPE_MASTERCARD       constant com_api_type_pkg.t_dict_value := 'AUTT0010';
    AUTHORITY_TYPE_VISA             constant com_api_type_pkg.t_dict_value := 'AUTT0020';
    AUTHORITY_TYPE_NCR              constant com_api_type_pkg.t_dict_value := 'AUTT0030';
    AUTHORITY_TYPE_SYSTEM           constant com_api_type_pkg.t_dict_value := 'AUTT0040';

    -- Hash Algorithm
    HASH_ALGORITHM_SHA1             constant com_api_type_pkg.t_dict_value := 'HASHSHA1';
    HASH_ALGORITHM_MD5              constant com_api_type_pkg.t_dict_value := 'HASHMD5';
    HASH_ALGORITHM_ISO_110118_2     constant com_api_type_pkg.t_dict_value := 'HASHISO1';
    HASH_ALGORITHM_SHA_224          constant com_api_type_pkg.t_dict_value := 'HASHS224';
    HASH_ALGORITHM_SHA_256          constant com_api_type_pkg.t_dict_value := 'HASHS256';
    HASH_ALGORITHM_SHA_384          constant com_api_type_pkg.t_dict_value := 'HASHS384';
    HASH_ALGORITHM_SHA_512          constant com_api_type_pkg.t_dict_value := 'HASHS512';
    
    -- Signature algorithm
    SIGNATURE_ALGORITHM             constant com_api_type_pkg.t_dict_value := 'SGNA';
    SIGNATURE_ALGORITHM_01          constant com_api_type_pkg.t_dict_value := 'SGNA01';
    SIGNATURE_ALGORITHM_03          constant com_api_type_pkg.t_dict_value := 'SGNA03';

    -- Encryption mode
    ENCRYPTION_METHOD_ECB           constant com_api_type_pkg.t_dict_value := 'ENMD0010';
    ENCRYPTION_METHOD_CBC           constant com_api_type_pkg.t_dict_value := 'ENMD0020';

    -- Type files that contain keys, certificates and hash-codes
    FILE_TYPE_ISS_PUBLIC_KEY_MC     constant com_api_type_pkg.t_dict_value := 'FLTPSIP';
    FILE_TYPE_ISS_PUBLIC_KEY_VISA   constant com_api_type_pkg.t_dict_value := 'FLTPINP';
    FILE_TYPE_HASH_ISS_PUBLIC_KEY   constant com_api_type_pkg.t_dict_value := 'FLTPHIP';
    FILE_TYPE_CA_PUBLIC_KEY         constant com_api_type_pkg.t_dict_value := 'FLTPSEP';
    FILE_TYPE_HASH_CA_PUBLIC_KEY    constant com_api_type_pkg.t_dict_value := 'FLTPHEP';
    FILE_TYPE_ISS_PUB_KEY_CERT      constant com_api_type_pkg.t_dict_value := 'FLTPCERT';

    KEY_PREFIX_DOUBLE_LENGTH        constant com_api_type_pkg.t_dict_value := 'ENKPU';
    
    ENTITY_TYPE_AUTHORITY           constant com_api_type_pkg.t_dict_value := 'ENTTATHR';
    
    SECURITY_RSA_IPS_ROOT_CERT      constant com_api_type_pkg.t_dict_value := 'ENKTIPCR';
    SECURITY_RSA_INTERMED_CERT      constant com_api_type_pkg.t_dict_value := 'ENKTIMTC';
    SECURITY_RSA_ACS_CERT           constant com_api_type_pkg.t_dict_value := 'ENKTACSC';
    
    PASSWORD_TYPE_DIGITS            constant com_api_type_pkg.t_dict_value := 'PWTPNMBR';
    PASSWORD_TYPE_ALPHANUM          constant com_api_type_pkg.t_dict_value := 'PWTPNMCH';
    
    DEFAULT_SECURITY_QUESTION       constant com_api_type_pkg.t_dict_value := 'SEQUWORD';

end;
/
