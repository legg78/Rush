create or replace package mup_api_pds_pkg is

    procedure extract_pds
    (   de048                   in mup_api_type_pkg.t_de048
        , de062                 in mup_api_type_pkg.t_de062
        , de123                 in mup_api_type_pkg.t_de123
        , de124                 in mup_api_type_pkg.t_de124
        , de125                 in mup_api_type_pkg.t_de125
        , pds_tab               in out nocopy mup_api_type_pkg.t_pds_tab
    );
    
    procedure format_pds
    (   pds_tab                 in mup_api_type_pkg.t_pds_tab
        , de048                 out mup_api_type_pkg.t_de048
        , de062                 out mup_api_type_pkg.t_de062
        , de123                 out mup_api_type_pkg.t_de123
        , de124                 out mup_api_type_pkg.t_de124
        , de125                 out mup_api_type_pkg.t_de125
    );
    
    function get_pds_body (
        i_pds_tab               in mup_api_type_pkg.t_pds_tab
        , i_pds_tag             in mup_api_type_pkg.t_pds_tag
    ) return mup_api_type_pkg.t_pds_body;
    
    procedure set_pds_body (
        io_pds_tab              in out nocopy mup_api_type_pkg.t_pds_tab
        , i_pds_tag             in mup_api_type_pkg.t_pds_tag
        , i_pds_body            in mup_api_type_pkg.t_pds_body
    );
    
    procedure read_pds (
        i_msg_id                in com_api_type_pkg.t_long_id
        , o_pds_tab             in out nocopy mup_api_type_pkg.t_pds_tab
    );             

    procedure save_pds (
        i_msg_id                in com_api_type_pkg.t_long_id
        , i_pds_tab             in out nocopy mup_api_type_pkg.t_pds_tab
        , i_clear               in com_api_type_pkg.t_boolean := com_api_type_pkg.TRUE
    );
    
    function format_p0025
    (   i_p0025_1               in mup_api_type_pkg.t_p0025_1
        , i_p0025_2             in mup_api_type_pkg.t_p0025_2
    ) return mup_api_type_pkg.t_pds_body;
                 
    function format_p0268 (   
        i_p0268_1               in mup_api_type_pkg.t_p0268_1
        , i_p0268_2             in mup_api_type_pkg.t_p0268_2
    ) return mup_api_type_pkg.t_pds_body;
    
    function format_p0149 (   
        i_p0149_1               in mup_api_type_pkg.t_p0149_1
        , i_p0149_2             in mup_api_type_pkg.t_p0149_2
    ) return mup_api_type_pkg.t_pds_body;

    function format_p2158 (   
        i_p2158_1               in mup_api_type_pkg.t_p2158_1
        , i_p2158_2             in mup_api_type_pkg.t_p2158_2
        , i_p2158_3             in mup_api_type_pkg.t_p2158_3
        , i_p2158_4             in mup_api_type_pkg.t_p2158_4
        , i_p2158_5             in mup_api_type_pkg.t_p2158_5
        , i_p2158_6             in mup_api_type_pkg.t_p2158_6
    ) return mup_api_type_pkg.t_pds_body;

    function format_p2072
    (   i_p2072_1               in mup_api_type_pkg.t_p2072_1
        , i_p2072_2             in mup_api_type_pkg.t_p2072_2
    ) return mup_api_type_pkg.t_pds_body;

    function format_p2097(
        i_p2097_1               in  mup_api_type_pkg.t_p2097_1
      , i_p2097_2               in  mup_api_type_pkg.t_p2097_2
      , i_standard_version_id   in  com_api_type_pkg.t_tiny_id   := null
    ) return mup_api_type_pkg.t_pds_body;

    function format_p2175(
        i_p2175_1               in  mup_api_type_pkg.t_p2175_1
      , i_p2175_2               in  mup_api_type_pkg.t_p2175_2
      , i_standard_version_id   in  com_api_type_pkg.t_tiny_id   := null
    ) return mup_api_type_pkg.t_pds_body;

/*    function format_p0200 (   
        i_p0200_1               in mup_api_type_pkg.t_p0200_1
        , i_p0200_2             in mup_api_type_pkg.t_p0200_2         
    ) return mup_api_type_pkg.t_pds_body;

    function format_p0210 (   
        i_p0210_1               in mup_api_type_pkg.t_p0210_1
        , i_p0210_2             in mup_api_type_pkg.t_p0210_2
    ) return mup_api_type_pkg.t_pds_body;    
*/
    procedure parse_p0005 (
        i_p0005                  in mup_api_type_pkg.t_pds_body
        , o_reject_code_tab      out nocopy mup_api_type_pkg.t_reject_code_tab
    );
    
    procedure parse_p0025 (
        i_p0025                 in mup_api_type_pkg.t_pds_body
        , o_p0025_1             out mup_api_type_pkg.t_p0025_1
        , o_p0025_2             out mup_api_type_pkg.t_p0025_2
    );
    
    procedure parse_p0105 (   
        i_p0105                 in mup_api_type_pkg.t_pds_body
        , o_file_type           out mup_api_type_pkg.t_pds_body
        , o_file_date           out date
        , o_cmid                out com_api_type_pkg.t_cmid
    );

    procedure parse_p0146(
        i_pds_body              in  mup_api_type_pkg.t_pds_body
        , o_p0146               out mup_api_type_pkg.t_p0146
        , o_p0146_net           out mup_api_type_pkg.t_p0146_net
      --  , i_is_p0147            in  com_api_type_pkg.t_boolean
    );

    procedure parse_p0149 (
        i_p0149                 in mup_api_type_pkg.t_pds_body
        , o_p0149_1             out mup_api_type_pkg.t_p0149_1
        , o_p0149_2             out mup_api_type_pkg.t_p0149_1
    );
    
    procedure parse_p2158 (
        i_p2158                in mup_api_type_pkg.t_pds_body
        , o_p2158_1            out mup_api_type_pkg.t_p2158_1
        , o_p2158_2            out mup_api_type_pkg.t_p2158_2
        , o_p2158_3            out mup_api_type_pkg.t_p2158_3
        , o_p2158_4            out mup_api_type_pkg.t_p2158_4
        , o_p2158_5            out mup_api_type_pkg.t_p2158_5
        , o_p2158_6            out mup_api_type_pkg.t_p2158_6
    );
    
    procedure parse_p2159 (
        i_p2159                in mup_api_type_pkg.t_pds_body
        , o_p2159_1            out mup_api_type_pkg.t_p2159_1
        , o_p2159_2            out mup_api_type_pkg.t_p2159_2
        , o_p2159_3            out mup_api_type_pkg.t_p2159_3
        , o_p2159_4            out mup_api_type_pkg.t_p2159_4
        , o_p2159_5            out mup_api_type_pkg.t_p2159_5
        , o_p2159_6            out mup_api_type_pkg.t_p2159_6
    );
    
    procedure parse_p0268 (
        i_p0268                in mup_api_type_pkg.t_pds_body
        , o_p0268_1            out mup_api_type_pkg.t_p0268_1
        , o_p0268_2            out mup_api_type_pkg.t_p0268_2
    );
    
    procedure parse_p0370 (
        i_p0370                 in mup_api_type_pkg.t_pds_body
        , o_p0370_1             out mup_api_type_pkg.t_p0370_1
        , o_p0370_2             out mup_api_type_pkg.t_p0370_2
    );

    procedure parse_p0372 (
        i_p0372                 in mup_api_type_pkg.t_pds_body
        , o_p0372_1             out mup_api_type_pkg.t_p0372_1
        , o_p0372_2             out mup_api_type_pkg.t_p0372_2
    );

    procedure parse_p0380 (
        i_pds_body              in mup_api_type_pkg.t_pds_body
        , i_pds_name            in mup_api_type_pkg.t_pds_body
        , o_p0380_1             out mup_api_type_pkg.t_p0380_1
        , o_p0380_2             out mup_api_type_pkg.t_p0380_2
    );

    procedure parse_p2072 (
        i_p2072                 in mup_api_type_pkg.t_pds_body
        , o_p2072_1             out mup_api_type_pkg.t_p2072_1
        , o_p2072_2             out mup_api_type_pkg.t_p2072_2
    );

    procedure parse_p2097(
        i_p2097                 in      mup_api_type_pkg.t_pds_body
      , o_p2097_1                  out  mup_api_type_pkg.t_p2097_1
      , o_p2097_2                  out  mup_api_type_pkg.t_p2097_2
      , i_standard_version_id   in      com_api_type_pkg.t_tiny_id  := null
    );

    procedure parse_p2175(
        i_p2175                 in      mup_api_type_pkg.t_pds_body
      , o_p2175_1                  out  mup_api_type_pkg.t_p2175_1
      , o_p2175_2                  out  mup_api_type_pkg.t_p2175_2
      , i_standard_version_id   in      com_api_type_pkg.t_tiny_id  := null
    );

    procedure parse_p2001 (
        i_p2001                 in      mup_api_type_pkg.t_pds_body
      , o_p2001_1                  out  mup_api_type_pkg.t_p2001_1
      , o_p2001_2                  out  mup_api_type_pkg.t_p2001_2
      , o_p2001_3                  out  mup_api_type_pkg.t_p2001_3
      , o_p2001_4                  out  mup_api_type_pkg.t_p2001_4
      , o_p2001_5                  out  mup_api_type_pkg.t_p2001_5
      , o_p2001_6                  out  mup_api_type_pkg.t_p2001_6
      , o_p2001_7                  out  mup_api_type_pkg.t_p2001_7
    );
    
end;
/
