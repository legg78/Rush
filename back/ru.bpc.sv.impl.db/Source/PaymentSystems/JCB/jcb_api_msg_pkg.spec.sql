create or replace package jcb_api_msg_pkg is

    function format_de003 (
        i_de003_1           in jcb_api_type_pkg.t_de003
        , i_de003_2         in jcb_api_type_pkg.t_de003
        , i_de003_3         in jcb_api_type_pkg.t_de003
    ) return jcb_api_type_pkg.t_de003;
    
    function format_de022 (   
        i_de022_1           in jcb_api_type_pkg.t_de022s
        , i_de022_2         in jcb_api_type_pkg.t_de022s
        , i_de022_3         in jcb_api_type_pkg.t_de022s
        , i_de022_4         in jcb_api_type_pkg.t_de022s
        , i_de022_5         in jcb_api_type_pkg.t_de022s
        , i_de022_6         in jcb_api_type_pkg.t_de022s
        , i_de022_7         in jcb_api_type_pkg.t_de022s
        , i_de022_8         in jcb_api_type_pkg.t_de022s
        , i_de022_9         in jcb_api_type_pkg.t_de022s
        , i_de022_10        in jcb_api_type_pkg.t_de022s
        , i_de022_11        in jcb_api_type_pkg.t_de022s
        , i_de022_12        in jcb_api_type_pkg.t_de022s
    ) return jcb_api_type_pkg.t_de022;
       
    function format_de043 (   
        i_de043_1           in jcb_api_type_pkg.t_de043
        , i_de043_2         in jcb_api_type_pkg.t_de043
        , i_de043_3         in jcb_api_type_pkg.t_de043
        , i_de043_4         in jcb_api_type_pkg.t_de043
        , i_de043_5         in jcb_api_type_pkg.t_de043
        , i_de043_6         in jcb_api_type_pkg.t_de043
    ) return jcb_api_type_pkg.t_de043;

    function pack_message (
        i_pds_tab         in jcb_api_type_pkg.t_pds_tab
        , i_mti             in jcb_api_type_pkg.t_mti
        , i_de002           in jcb_api_type_pkg.t_de002 := null 
        , i_de003_1         in jcb_api_type_pkg.t_de003s := null 
        , i_de003_2         in jcb_api_type_pkg.t_de003s := null
        , i_de003_3         in jcb_api_type_pkg.t_de003s := null
        , i_de004           in jcb_api_type_pkg.t_de004 := null
        , i_de005           in jcb_api_type_pkg.t_de005 := null
        , i_de006           in jcb_api_type_pkg.t_de006 := null
        , i_de009           in jcb_api_type_pkg.t_de009 := null
        , i_de010           in jcb_api_type_pkg.t_de010 := null
        , i_de012           in jcb_api_type_pkg.t_de012 := null
        , i_de014           in jcb_api_type_pkg.t_de014 := null
        , i_de016           in jcb_api_type_pkg.t_de016 := null
        , i_de022           in jcb_api_type_pkg.t_de022 := null 
        , i_de022_1         in jcb_api_type_pkg.t_de022s := null
        , i_de022_2         in jcb_api_type_pkg.t_de022s := null
        , i_de022_3         in jcb_api_type_pkg.t_de022s := null
        , i_de022_4         in jcb_api_type_pkg.t_de022s := null
        , i_de022_5         in jcb_api_type_pkg.t_de022s := null
        , i_de022_6         in jcb_api_type_pkg.t_de022s := null
        , i_de022_7         in jcb_api_type_pkg.t_de022s := null
        , i_de022_8         in jcb_api_type_pkg.t_de022s := null
        , i_de022_9         in jcb_api_type_pkg.t_de022s := null
        , i_de022_10        in jcb_api_type_pkg.t_de022s := null
        , i_de022_11        in jcb_api_type_pkg.t_de022s := null
        , i_de022_12        in jcb_api_type_pkg.t_de022s := null
        , i_de023           in jcb_api_type_pkg.t_de023 := null
        , i_de024           in jcb_api_type_pkg.t_de024 := null
        , i_de025           in jcb_api_type_pkg.t_de025 := null
        , i_de026           in jcb_api_type_pkg.t_de026 := null
        , i_de030_1         in jcb_api_type_pkg.t_de030_1 := null
        , i_de030_2         in jcb_api_type_pkg.t_de030_2 := null
        , i_de031           in jcb_api_type_pkg.t_de031 := null
        , i_de032           in jcb_api_type_pkg.t_de032 := null
        , i_de033           in jcb_api_type_pkg.t_de033 := null
        , i_de037           in jcb_api_type_pkg.t_de037 := null
        , i_de038           in jcb_api_type_pkg.t_de038 := null
        , i_de040           in jcb_api_type_pkg.t_de040 := null
        , i_de041           in jcb_api_type_pkg.t_de041 := null
        , i_de042           in jcb_api_type_pkg.t_de042 := null
        , i_de043           in jcb_api_type_pkg.t_de043 := null 
        , i_de043_1         in jcb_api_type_pkg.t_de043 := null
        , i_de043_2         in jcb_api_type_pkg.t_de043 := null
        , i_de043_3         in jcb_api_type_pkg.t_de043 := null
        , i_de043_4         in jcb_api_type_pkg.t_de043 := null
        , i_de043_5         in jcb_api_type_pkg.t_de043 := null
        , i_de043_6         in jcb_api_type_pkg.t_de043 := null
        , i_de049           in jcb_api_type_pkg.t_de049 := null
        , i_de050           in jcb_api_type_pkg.t_de050 := null
        , i_de051           in jcb_api_type_pkg.t_de051 := null
        , i_de054           in jcb_api_type_pkg.t_de054 := null
        , i_de055           in jcb_api_type_pkg.t_de055 := null
        , i_de071           in jcb_api_type_pkg.t_de071 := null
        , i_de072           in jcb_api_type_pkg.t_de072 := null
        , i_de093           in jcb_api_type_pkg.t_de093 := null
        , i_de094           in jcb_api_type_pkg.t_de094 := null
        , i_de097           in jcb_api_type_pkg.t_de097 := null
        , i_de100           in jcb_api_type_pkg.t_de100 := null    
        , i_with_rdw        in com_api_type_pkg.t_boolean := null
    )return blob;

    procedure unpack_message (
        i_file              in blob
        , i_with_rdw        in com_api_type_pkg.t_boolean    default null
        , io_curr_pos       in out nocopy com_api_type_pkg.t_long_id
        , o_mti             out jcb_api_type_pkg.t_mti
        , o_de002           out jcb_api_type_pkg.t_de002  
        , o_de003_1         out jcb_api_type_pkg.t_de003s 
        , o_de003_2         out jcb_api_type_pkg.t_de003s
        , o_de003_3         out jcb_api_type_pkg.t_de003s
        , o_de004           out jcb_api_type_pkg.t_de004
        , o_de005           out jcb_api_type_pkg.t_de005
        , o_de006           out jcb_api_type_pkg.t_de006
        , o_de009           out jcb_api_type_pkg.t_de009
        , o_de010           out jcb_api_type_pkg.t_de010
        , o_de012           out jcb_api_type_pkg.t_de012
        , o_de014           out jcb_api_type_pkg.t_de014
        , o_de016           out jcb_api_type_pkg.t_de016
        , o_de022_1         out jcb_api_type_pkg.t_de022s
        , o_de022_2         out jcb_api_type_pkg.t_de022s
        , o_de022_3         out jcb_api_type_pkg.t_de022s
        , o_de022_4         out jcb_api_type_pkg.t_de022s
        , o_de022_5         out jcb_api_type_pkg.t_de022s
        , o_de022_6         out jcb_api_type_pkg.t_de022s
        , o_de022_7         out jcb_api_type_pkg.t_de022s
        , o_de022_8         out jcb_api_type_pkg.t_de022s
        , o_de022_9         out jcb_api_type_pkg.t_de022s
        , o_de022_10        out jcb_api_type_pkg.t_de022s
        , o_de022_11        out jcb_api_type_pkg.t_de022s
        , o_de022_12        out jcb_api_type_pkg.t_de022s
        , o_de023           out jcb_api_type_pkg.t_de023
        , o_de024           out jcb_api_type_pkg.t_de024
        , o_de025           out jcb_api_type_pkg.t_de025
        , o_de026           out jcb_api_type_pkg.t_de026
        , o_de030_1         out jcb_api_type_pkg.t_de030_1
        , o_de030_2         out jcb_api_type_pkg.t_de030_2
        , o_de031           out jcb_api_type_pkg.t_de031
        , o_de032           out jcb_api_type_pkg.t_de032
        , o_de033           out jcb_api_type_pkg.t_de033
        , o_de037           out jcb_api_type_pkg.t_de037
        , o_de038           out jcb_api_type_pkg.t_de038
        , o_de040           out jcb_api_type_pkg.t_de040
        , o_de041           out jcb_api_type_pkg.t_de041
        , o_de042           out jcb_api_type_pkg.t_de042
        , o_de043_1         out jcb_api_type_pkg.t_de043
        , o_de043_2         out jcb_api_type_pkg.t_de043
        , o_de043_3         out jcb_api_type_pkg.t_de043
        , o_de043_4         out jcb_api_type_pkg.t_de043
        , o_de043_5         out jcb_api_type_pkg.t_de043
        , o_de043_6         out jcb_api_type_pkg.t_de043
        , o_de048           out jcb_api_type_pkg.t_de048
        , o_de049           out jcb_api_type_pkg.t_de049
        , o_de050           out jcb_api_type_pkg.t_de050
        , o_de051           out jcb_api_type_pkg.t_de051
        , o_de054           out jcb_api_type_pkg.t_de054
        , o_de055           out jcb_api_type_pkg.t_de055
        , o_de062           out jcb_api_type_pkg.t_de062
        , o_de071           out jcb_api_type_pkg.t_de071
        , o_de072           out jcb_api_type_pkg.t_de072
        , o_de093           out jcb_api_type_pkg.t_de093
        , o_de094           out jcb_api_type_pkg.t_de094
        , o_de097           out jcb_api_type_pkg.t_de097
        , o_de100           out jcb_api_type_pkg.t_de100    
        , o_de123           out jcb_api_type_pkg.t_de123    
        , o_de124           out jcb_api_type_pkg.t_de124    
        , o_de125           out jcb_api_type_pkg.t_de125    
        , o_de126           out jcb_api_type_pkg.t_de126    
        --, i_charset         in com_api_type_pkg.t_oracle_name := null
    );

end;
/
 