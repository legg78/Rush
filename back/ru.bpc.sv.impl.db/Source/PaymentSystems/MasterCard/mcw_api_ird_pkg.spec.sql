create or replace package mcw_api_ird_pkg is

----
--20
    function interregional_20 (
        i_brand              in com_api_type_pkg.t_dict_value
        , i_product_id       in com_api_type_pkg.t_dict_value
        , i_acquiring_region in com_api_type_pkg.t_dict_value
        , i_issuer_region    in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean;

----
--21
    function interregional_21 (
        i_brand              in com_api_type_pkg.t_dict_value
        , i_product_id       in com_api_type_pkg.t_dict_value
        , i_acquiring_region in com_api_type_pkg.t_dict_value
        , i_issuer_region    in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean;

----
--24
    function interregional_24 (
        i_brand              in com_api_type_pkg.t_dict_value
        , i_product_id       in com_api_type_pkg.t_dict_value
        , i_acquiring_region in com_api_type_pkg.t_dict_value
        , i_issuer_region    in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean;

----
--2A
    function interregional_2A (
        i_brand              in com_api_type_pkg.t_dict_value
        , i_product_id       in com_api_type_pkg.t_dict_value
        , i_acquiring_region in com_api_type_pkg.t_dict_value
        , i_issuer_region    in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean;

----
--51-52
    function interregional_51_52(
        i_brand              in com_api_type_pkg.t_dict_value
      , i_product_id         in com_api_type_pkg.t_dict_value
      , i_acquiring_region   in com_api_type_pkg.t_dict_value
      , i_issuer_region      in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean;

----
--A1, A3, A5; A2, A4, A6
    function interregional_ax_tier(
        i_brand              in com_api_type_pkg.t_dict_value
      , i_product_id         in com_api_type_pkg.t_dict_value
      , i_acquiring_region   in com_api_type_pkg.t_dict_value
      , i_issuer_region      in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean;

----
--AS
    function interregional_as(
        i_brand              in com_api_type_pkg.t_dict_value
      , i_product_id         in com_api_type_pkg.t_dict_value
      , i_acquiring_region   in com_api_type_pkg.t_dict_value
      , i_issuer_region      in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean;

----
--47
    function interregional_47 (
        i_brand              in com_api_type_pkg.t_dict_value
        , i_product_id       in com_api_type_pkg.t_dict_value
        , i_acquiring_region in com_api_type_pkg.t_dict_value
        , i_issuer_region    in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean;

----
--57 Commercial
    function interregional_57_com (
        i_brand              in com_api_type_pkg.t_dict_value
        , i_product_id       in com_api_type_pkg.t_dict_value
        , i_acquiring_region in com_api_type_pkg.t_dict_value
        , i_issuer_region    in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean;

----
--57 Consumer
    function interregional_57_con (
        i_brand              in com_api_type_pkg.t_dict_value
        , i_product_id       in com_api_type_pkg.t_dict_value
        , i_acquiring_region in com_api_type_pkg.t_dict_value
        , i_issuer_region    in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean;

----
--61
    function interregional_61 (
        i_brand              in com_api_type_pkg.t_dict_value
        , i_product_id       in com_api_type_pkg.t_dict_value
        , i_acquiring_region in com_api_type_pkg.t_dict_value
        , i_issuer_region    in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean;

----
--62
    function interregional_62 (
        i_brand              in com_api_type_pkg.t_dict_value
        , i_product_id       in com_api_type_pkg.t_dict_value
        , i_acquiring_region in com_api_type_pkg.t_dict_value
        , i_issuer_region    in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean;

----
--63
    function interregional_63 (
        i_brand              in com_api_type_pkg.t_dict_value
        , i_product_id       in com_api_type_pkg.t_dict_value
        , i_acquiring_region in com_api_type_pkg.t_dict_value
        , i_issuer_region    in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean;

----
--67
    function interregional_67 (
        i_brand              in com_api_type_pkg.t_dict_value
        , i_product_id       in com_api_type_pkg.t_dict_value
        , i_acquiring_region in com_api_type_pkg.t_dict_value
        , i_issuer_region    in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean;

----
--73
    function interregional_73 (
        i_brand              in com_api_type_pkg.t_dict_value
        , i_product_id       in com_api_type_pkg.t_dict_value
        , i_acquiring_region in com_api_type_pkg.t_dict_value
        , i_issuer_region    in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean;

----
--79
    function interregional_79 (
        i_brand              in com_api_type_pkg.t_dict_value
        , i_product_id       in com_api_type_pkg.t_dict_value
        , i_acquiring_region in com_api_type_pkg.t_dict_value
        , i_issuer_region    in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean;

----
--EA
    function interregional_ea (
        i_brand              in com_api_type_pkg.t_dict_value
        , i_product_id       in com_api_type_pkg.t_dict_value
        , i_acquiring_region in com_api_type_pkg.t_dict_value
        , i_issuer_region    in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean;

----
--EE
    function interregional_ee (
        i_brand              in com_api_type_pkg.t_dict_value
        , i_product_id       in com_api_type_pkg.t_dict_value
        , i_acquiring_region in com_api_type_pkg.t_dict_value
        , i_issuer_region    in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean;

----
--EF
    function interregional_ef (
        i_brand              in com_api_type_pkg.t_dict_value
        , i_product_id       in com_api_type_pkg.t_dict_value
        , i_acquiring_region in com_api_type_pkg.t_dict_value
        , i_issuer_region    in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean;

----
--EI
    function interregional_ei (
        i_brand              in com_api_type_pkg.t_dict_value
        , i_product_id       in com_api_type_pkg.t_dict_value
        , i_acquiring_region in com_api_type_pkg.t_dict_value
        , i_issuer_region    in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean;

----
--EM
    function interregional_em (
        i_brand              in com_api_type_pkg.t_dict_value
        , i_product_id       in com_api_type_pkg.t_dict_value
        , i_acquiring_region in com_api_type_pkg.t_dict_value
        , i_issuer_region    in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean;

----
--ES
    function interregional_es (
        i_brand              in com_api_type_pkg.t_dict_value
        , i_product_id       in com_api_type_pkg.t_dict_value
        , i_acquiring_region in com_api_type_pkg.t_dict_value
        , i_issuer_region    in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean;

----
--EZ
    function interregional_ez (
        i_brand              in com_api_type_pkg.t_dict_value
        , i_product_id       in com_api_type_pkg.t_dict_value
        , i_acquiring_region in com_api_type_pkg.t_dict_value
        , i_issuer_region    in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean;

----
--FF
    function interregional_ff (
        i_brand            in     com_api_type_pkg.t_dict_value
      , i_product_id       in     com_api_type_pkg.t_dict_value
      , i_acquiring_region in     com_api_type_pkg.t_dict_value
      , i_issuer_region    in     com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean;

----
--PA
    function interregional_pa (
        i_brand              in com_api_type_pkg.t_dict_value
        , i_product_id       in com_api_type_pkg.t_dict_value
        , i_acquiring_region in com_api_type_pkg.t_dict_value
        , i_issuer_region    in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean;

----
--PE
    function interregional_pe (
        i_brand              in com_api_type_pkg.t_dict_value
        , i_product_id       in com_api_type_pkg.t_dict_value
        , i_acquiring_region in com_api_type_pkg.t_dict_value
        , i_issuer_region    in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean;

----
--PF
    function interregional_pf (
        i_brand              in com_api_type_pkg.t_dict_value
        , i_product_id       in com_api_type_pkg.t_dict_value
        , i_acquiring_region in com_api_type_pkg.t_dict_value
        , i_issuer_region    in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean;

----
--PI
    function interregional_pi (
        i_brand              in com_api_type_pkg.t_dict_value
        , i_product_id       in com_api_type_pkg.t_dict_value
        , i_acquiring_region in com_api_type_pkg.t_dict_value
        , i_issuer_region    in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean;

----
--PM
    function interregional_pm (
        i_brand              in com_api_type_pkg.t_dict_value
        , i_product_id       in com_api_type_pkg.t_dict_value
        , i_acquiring_region in com_api_type_pkg.t_dict_value
        , i_issuer_region    in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean;

----
--PS    
    function interregional_ps (
        i_brand              in com_api_type_pkg.t_dict_value
        , i_product_id       in com_api_type_pkg.t_dict_value
        , i_acquiring_region in com_api_type_pkg.t_dict_value
        , i_issuer_region    in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean;
    
----
--IP    
    function interregional_ip (
        i_brand              in com_api_type_pkg.t_dict_value
        , i_product_id       in com_api_type_pkg.t_dict_value
        , i_acquiring_region in com_api_type_pkg.t_dict_value
        , i_issuer_region    in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean;

    function interregional_74 (
        i_brand              in com_api_type_pkg.t_dict_value
        , i_product_id       in com_api_type_pkg.t_dict_value
        , i_acquiring_region in com_api_type_pkg.t_dict_value
        , i_issuer_region    in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean;
    
---
--MS
    function interregional_ms (
        i_brand              in com_api_type_pkg.t_dict_value
        , i_product_id       in com_api_type_pkg.t_dict_value
        , i_acquiring_region in com_api_type_pkg.t_dict_value
        , i_issuer_region    in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean;

----
--ZX
    function interregional_zx(
        i_brand              in com_api_type_pkg.t_dict_value
      , i_product_id         in com_api_type_pkg.t_dict_value
      , i_acquiring_region   in com_api_type_pkg.t_dict_value
      , i_issuer_region      in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean;

---
--QR    
    function interregional_qr (
        i_brand            in     com_api_type_pkg.t_dict_value
      , i_product_id       in     com_api_type_pkg.t_dict_value
      , i_acquiring_region in     com_api_type_pkg.t_dict_value
      , i_issuer_region    in     com_api_type_pkg.t_dict_value
      , i_de_003_1         in     com_api_type_pkg.t_dict_value
      , i_standard_version in     com_api_type_pkg.t_tiny_id
    ) return com_api_type_pkg.t_boolean;
    
----
--Get Amount
    function get_amount (
        i_de_004             in mcw_api_type_pkg.t_de004
        , i_curr_code        in com_api_type_pkg.t_curr_code
    ) return mcw_api_type_pkg.t_de004;

end;
/
