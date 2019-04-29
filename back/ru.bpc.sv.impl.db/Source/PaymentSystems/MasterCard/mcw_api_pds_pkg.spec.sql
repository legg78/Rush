create or replace package mcw_api_pds_pkg is

    procedure extract_pds(
        de048                   in            mcw_api_type_pkg.t_de048
      , de062                   in            mcw_api_type_pkg.t_de062
      , de123                   in            mcw_api_type_pkg.t_de123
      , de124                   in            mcw_api_type_pkg.t_de124
      , de125                   in            mcw_api_type_pkg.t_de125
      , pds_tab                 in out nocopy mcw_api_type_pkg.t_pds_tab
    );
    
    procedure format_pds(
        i_pds_tab               in            mcw_api_type_pkg.t_pds_tab
      , o_de048                    out        mcw_api_type_pkg.t_de048
      , o_de062                    out        mcw_api_type_pkg.t_de062
      , o_de123                    out        mcw_api_type_pkg.t_de123
      , o_de124                    out        mcw_api_type_pkg.t_de124
      , o_de125                    out        mcw_api_type_pkg.t_de125
    );
    
    function get_pds_body (
        i_pds_tab               in mcw_api_type_pkg.t_pds_tab
        , i_pds_tag             in mcw_api_type_pkg.t_pds_tag
    ) return mcw_api_type_pkg.t_pds_body;
    
    procedure set_pds_body (
        io_pds_tab              in out nocopy mcw_api_type_pkg.t_pds_tab
        , i_pds_tag             in mcw_api_type_pkg.t_pds_tag
        , i_pds_body            in mcw_api_type_pkg.t_pds_body
    );
    
    procedure read_pds (
        i_msg_id                in com_api_type_pkg.t_long_id
        , o_pds_tab             in out nocopy mcw_api_type_pkg.t_pds_tab
    );             

    procedure save_pds (
        i_msg_id                in com_api_type_pkg.t_long_id
        , i_pds_tab             in out nocopy mcw_api_type_pkg.t_pds_tab
        , i_clear               in com_api_type_pkg.t_boolean := com_api_type_pkg.TRUE
    );
    
    function format_p0004 (
        i_p0004_1               in mcw_api_type_pkg.t_p0004_1
        , i_p0004_2             in mcw_api_type_pkg.t_p0004_2
    ) return mcw_api_type_pkg.t_pds_body;
                 
    function format_p0025 (
        i_p0025_1               in mcw_api_type_pkg.t_p0025_1
        , i_p0025_2             in mcw_api_type_pkg.t_p0025_2
    ) return mcw_api_type_pkg.t_pds_body;
                 
    function format_p0268 (   
        i_p0268_1               in mcw_api_type_pkg.t_p0268_1
        , i_p0268_2             in mcw_api_type_pkg.t_p0268_2
    ) return mcw_api_type_pkg.t_pds_body;
    
    function format_p0149 (   
        i_p0149_1               in mcw_api_type_pkg.t_p0149_1
        , i_p0149_2             in mcw_api_type_pkg.t_p0149_2
    ) return mcw_api_type_pkg.t_pds_body;

    function format_p0158 (   
        i_p0158_1               in mcw_api_type_pkg.t_p0158_1
        , i_p0158_2             in mcw_api_type_pkg.t_p0158_2
        , i_p0158_3             in mcw_api_type_pkg.t_p0158_3
        , i_p0158_4             in mcw_api_type_pkg.t_p0158_4
        , i_p0158_5             in mcw_api_type_pkg.t_p0158_5
        , i_p0158_6             in mcw_api_type_pkg.t_p0158_6
        , i_p0158_7             in mcw_api_type_pkg.t_p0158_7
        , i_p0158_8             in mcw_api_type_pkg.t_p0158_8
        , i_p0158_9             in mcw_api_type_pkg.t_p0158_9
        , i_p0158_10            in mcw_api_type_pkg.t_p0158_10
        , i_p0158_11            in mcw_api_type_pkg.t_p0158_11
        , i_p0158_12            in mcw_api_type_pkg.t_p0158_12
        , i_p0158_13            in mcw_api_type_pkg.t_p0158_13        
        , i_p0158_14            in mcw_api_type_pkg.t_p0158_14         
    ) return mcw_api_type_pkg.t_pds_body;

    function format_p0181(
        i_host_id               in     com_api_type_pkg.t_tiny_id
      , i_installment_data_1    in     com_api_type_pkg.t_param_value
      , i_installment_data_2    in     com_api_type_pkg.t_param_value
    ) return com_api_type_pkg.t_name;

    function format_p0200 (   
        i_p0200_1               in mcw_api_type_pkg.t_p0200_1
        , i_p0200_2             in mcw_api_type_pkg.t_p0200_2         
    ) return mcw_api_type_pkg.t_pds_body;

    function format_p0208 (   
        i_p0208_1               in mcw_api_type_pkg.t_p0208_1
        , i_p0208_2             in mcw_api_type_pkg.t_p0208_2
    ) return mcw_api_type_pkg.t_pds_body;    

    function format_p0210 (   
        i_p0210_1               in mcw_api_type_pkg.t_p0210_1
        , i_p0210_2             in mcw_api_type_pkg.t_p0210_2
    ) return mcw_api_type_pkg.t_pds_body;    

    procedure parse_p0001 (
        i_p0001                in mcw_api_type_pkg.t_pds_body
        , o_p0001_1            out mcw_api_type_pkg.t_p0001_1
        , o_p0001_2            out mcw_api_type_pkg.t_p0001_2
    );

    procedure parse_p0004 (
        i_p0004                in mcw_api_type_pkg.t_pds_body
        , o_p0004_1            out mcw_api_type_pkg.t_p0004_1
        , o_p0004_2            out mcw_api_type_pkg.t_p0004_2
    );

    procedure parse_p0005 (
        i_p0005                  in mcw_api_type_pkg.t_pds_body
        , o_reject_code_tab      out nocopy mcw_api_type_pkg.t_reject_code_tab
    );
    
    procedure parse_p0025 (
        i_p0025                 in mcw_api_type_pkg.t_pds_body
        , o_p0025_1             out mcw_api_type_pkg.t_p0025_1
        , o_p0025_2             out mcw_api_type_pkg.t_p0025_2
    );
    
    procedure parse_p0105 (   
        i_p0105                 in mcw_api_type_pkg.t_pds_body
        , o_file_type           out mcw_api_type_pkg.t_pds_body
        , o_file_date           out date
        , o_cmid                out com_api_type_pkg.t_cmid
    );

    procedure parse_p0146(
        i_pds_body              in  mcw_api_type_pkg.t_pds_body
        , o_p0146               out mcw_api_type_pkg.t_p0146
        , o_p0146_net           out mcw_api_type_pkg.t_p0146_net
        , i_is_p0147            in  com_api_type_pkg.t_boolean
    );

    procedure parse_p0149 (
        i_p0149                 in mcw_api_type_pkg.t_pds_body
        , o_p0149_1             out mcw_api_type_pkg.t_p0149_1
        , o_p0149_2             out mcw_api_type_pkg.t_p0149_1
    );
    
    procedure parse_p0158 (
        i_p0158                in mcw_api_type_pkg.t_pds_body
        , o_p0158_1            out mcw_api_type_pkg.t_p0158_1
        , o_p0158_2            out mcw_api_type_pkg.t_p0158_2
        , o_p0158_3            out mcw_api_type_pkg.t_p0158_3
        , o_p0158_4            out mcw_api_type_pkg.t_p0158_4
        , o_p0158_5            out mcw_api_type_pkg.t_p0158_5
        , o_p0158_6            out mcw_api_type_pkg.t_p0158_6
        , o_p0158_7            out mcw_api_type_pkg.t_p0158_7
        , o_p0158_8            out mcw_api_type_pkg.t_p0158_8
        , o_p0158_9            out mcw_api_type_pkg.t_p0158_9
        , o_p0158_10           out mcw_api_type_pkg.t_p0158_10
        , o_p0158_11           out mcw_api_type_pkg.t_p0158_11
        , o_p0158_12           out mcw_api_type_pkg.t_p0158_12
        , o_p0158_13           out mcw_api_type_pkg.t_p0158_13        
        , o_p0158_14           out mcw_api_type_pkg.t_p0158_14                        
    );
    
    procedure parse_p0159 (
        i_p0159                in mcw_api_type_pkg.t_pds_body
        , o_p0159_1            out mcw_api_type_pkg.t_p0159_1
        , o_p0159_2            out mcw_api_type_pkg.t_p0159_2
        , o_p0159_3            out mcw_api_type_pkg.t_p0159_3
        , o_p0159_4            out mcw_api_type_pkg.t_p0159_4
        , o_p0159_5            out mcw_api_type_pkg.t_p0159_5
        , o_p0159_6            out mcw_api_type_pkg.t_p0159_6
        , o_p0159_7            out mcw_api_type_pkg.t_p0159_7
        , o_p0159_8            out mcw_api_type_pkg.t_p0159_8
        , o_p0159_9            out mcw_api_type_pkg.t_p0159_9
    );
    
    procedure parse_p0164
    (   i_p0164                 in mcw_api_type_pkg.t_pds_body
        , i_de050               in mcw_api_type_pkg.t_de050
        , o_cur_rate_tab        out mcw_api_type_pkg.t_cur_rate_tab
    );

    procedure parse_p0200 (
        i_p0200                in mcw_api_type_pkg.t_pds_body
        , o_p0200_1            out mcw_api_type_pkg.t_p0200_1
        , o_p0200_2            out mcw_api_type_pkg.t_p0200_2
    );
    
    procedure parse_p0208 (
        i_p0208                in mcw_api_type_pkg.t_pds_body
        , o_p0208_1            out mcw_api_type_pkg.t_p0208_1
        , o_p0208_2            out mcw_api_type_pkg.t_p0208_2
    );    
    
    procedure parse_p0210 (
        i_p0210                in mcw_api_type_pkg.t_pds_body
        , o_p0210_1            out mcw_api_type_pkg.t_p0210_1
        , o_p0210_2            out mcw_api_type_pkg.t_p0210_2
    );    
    
    procedure parse_p0268 (
        i_p0268                in mcw_api_type_pkg.t_pds_body
        , o_p0268_1            out mcw_api_type_pkg.t_p0268_1
        , o_p0268_2            out mcw_api_type_pkg.t_p0268_2
    );
    
    procedure parse_p0370 (
        i_p0370                 in mcw_api_type_pkg.t_pds_body
        , o_p0370_1             out mcw_api_type_pkg.t_p0370_1
        , o_p0370_2             out mcw_api_type_pkg.t_p0370_2
    );

    procedure parse_p0372 (
        i_p0372                 in mcw_api_type_pkg.t_pds_body
        , o_p0372_1             out mcw_api_type_pkg.t_p0372_1
        , o_p0372_2             out mcw_api_type_pkg.t_p0372_2
    );

    procedure parse_p0380 (
        i_pds_body              in mcw_api_type_pkg.t_pds_body
        , i_pds_name            in mcw_api_type_pkg.t_pds_body
        , o_p0380_1             out mcw_api_type_pkg.t_p0380_1
        , o_p0380_2             out mcw_api_type_pkg.t_p0380_2
    );

    procedure parse_p0399 (
        i_pds_body           in     mcw_api_type_pkg.t_pds_body
      , i_pds_name           in     mcw_api_type_pkg.t_pds_body
      , o_p0399_1               out mcw_api_type_pkg.t_p0399_1
      , o_p0399_2               out mcw_api_type_pkg.t_p0399_2
    );

    procedure parse_p0501 (
        i_p0501              in     mcw_api_type_pkg.t_pds_body
      , o_p0501_1               out mcw_api_type_pkg.t_p0501_1
      , o_p0501_2               out mcw_api_type_pkg.t_p0501_2
      , o_p0501_3               out mcw_api_type_pkg.t_p0501_3
      , o_p0501_4               out mcw_api_type_pkg.t_p0501_4
    );

    procedure parse_p0715(
        i_p0715              in     mcw_api_type_pkg.t_pds_body
      , o_p0715                 out mcw_api_type_pkg.t_p0715
    );

    procedure parse_p0181(
        i_p0181                 in      com_api_type_pkg.t_name
      , o_installment_data_1       out  com_api_type_pkg.t_param_value
      , o_installment_data_2       out  com_api_type_pkg.t_param_value
    );

end;
/
