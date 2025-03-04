module SYS_TOP # (parameter DATA_WIDTH = 8,  RF_ADDR = 4)
    (
        input   wire                          RST_N,
        input   wire                          UART_CLK,
        input   wire                          REF_CLK,
        input   wire                          UART_RX_IN,
        output  wire                          UART_TX_O,
        output  wire                          parity_error,
        output  wire                          framing_error
    );
    
    // Synchronized deasserted Reset signal
    wire                                SYNC_UART_RST;
    wire                                SYNC_REF_RST;
    
    // UART_TX clock
    wire					               UART_TX_CLK;
    
    // UART_RX clock
    wire					               UART_RX_CLK;
    
    // wires of Register file
    wire      [DATA_WIDTH-1:0]             Operand_A;   // connected to ALU
    wire      [DATA_WIDTH-1:0]             Operand_B;   // connected to ALU
    wire      [DATA_WIDTH-1:0]             UART_Config; // connected to UART
    wire      [DATA_WIDTH-1:0]             DIV_RATIO;   // connected to clock divider for UART_TX
    
    // wire for clock divider of UART_RX
    wire      [DATA_WIDTH-1:0]             DIV_RATIO_RX;
    
    // Wires from UART_RX to SYS_CTRL 
    wire      [DATA_WIDTH-1:0]             UART_RX_OUT;
    wire         						   UART_RX_V_OUT;
    wire      [DATA_WIDTH-1:0]			   UART_RX_SYNC;
    wire                                   UART_RX_V_SYNC;
    
    // wires between SYS_CTRL and ASYNC FIFO
    wire      [DATA_WIDTH-1:0]             FIFO_WR_DATA;
    wire        						   W_INC;
    wire                                   FIFO_FULL ;
    
    // Wires between ASYNC FIFO and UART_TX
    wire      [DATA_WIDTH-1:0]             FIFO_RD_DATA;
    wire        						   FIFO_EMPTY;
    
    // Wire between PULSE_GEN and ASYNC FIFO
    wire                                   R_INC;
    
    // wires between PULSE_GEN and UART_TX
    wire                                   UART_TX_Busy;
    
    // wires between SYS_CTRL and register file
    wire                                   RF_WrEn;
    wire                                   RF_RdEn;
    wire      [RF_ADDR-1:0]                RF_Address;
    wire      [DATA_WIDTH-1:0]             RF_WrData;
    wire      [DATA_WIDTH-1:0]             RF_RdData;
    wire                                   RF_RdData_VLD;									   
    
    // Wires between SYS_CTRL and ALU and also between SYS_CTRL and clock gating 
    wire                                   CLKG_EN;
    wire                                   ALU_EN;
    wire      [3:0]                        ALU_FUN; 
    wire      [DATA_WIDTH*2-1:0]           ALU_OUT;
    wire                                   ALU_OUT_VLD; 
    
    // Wire between ALU and Clock gating
    wire                                   ALU_CLK;
    
    // Wire between SYS_CTRL and Clock Divider
    wire                                   CLKDIV_EN ;
    
    ///********************************************************///
    //////////////////// Reset synchronizers /////////////////////
    ///********************************************************///
    
    // Reset Synchronization for UART
    RST_SYNC #(.NUM_STAGES(2)) U0_RST_SYNC (
        .RST(RST_N),
        .CLK(UART_CLK),
        .SYNC_RST(SYNC_UART_RST)
    );
    
    // Reset Syncronization for system
    RST_SYNC #(.NUM_STAGES(2)) U1_RST_SYNC (
        .RST(RST_N),
        .CLK(REF_CLK),
        .SYNC_RST(SYNC_REF_RST)
    );
    
    ///********************************************************///
    ////////////////////// Data Synchronizer /////////////////////
    ///********************************************************///
    
    DATA_SYNC #(.NUM_STAGES(2) , .BUS_WIDTH(DATA_WIDTH)) U0_ref_sync (
        .CLK(REF_CLK),
        .RST(SYNC_REF_RST),
        .unsync_bus(UART_RX_OUT),
        .bus_enable(UART_RX_V_OUT),
        .sync_bus(UART_RX_SYNC),
        .enable_pulse_d(UART_RX_V_SYNC)
    );
    
    ///********************************************************///
    ///////////////////////// Async FIFO /////////////////////////
    ///********************************************************///
    
    ASYC_FIFO #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(3)) U0_UART_FIFO (
        .W_CLK(REF_CLK),
        .W_RST(SYNC_REF_RST),  
        .W_INC(W_INC),
        .WR_DATA(FIFO_WR_DATA),             
        .R_CLK(UART_TX_CLK),              
        .R_RST(SYNC_UART_RST),              
        .R_INC(R_INC),              
        .RD_DATA(FIFO_RD_DATA),             
        .FULL(FIFO_FULL),               
        .EMPTY(FIFO_EMPTY)               
    );
    
    ///********************************************************///
    //////////////////////// Pulse Generator /////////////////////
    ///********************************************************///
    
    PULSE_GEN U0_PULSE_GEN (
        .CLK(UART_TX_CLK),
        .RST(SYNC_UART_RST),
        .LVL_SIG(UART_TX_Busy),
        .PULSE_SIG(R_INC)
    );
    
    ///********************************************************///
    //////////// Clock Divider for UART_TX Clock /////////////////
    ///********************************************************///
    
    ClkDiv U0_ClkDiv (
    .I_ref_clk(UART_CLK),             
    .I_rst_n(SYNC_UART_RST),                 
    .I_clk_en(CLKDIV_EN),               
    .I_div_ratio(DIV_RATIO),           
    .O_div_clk(UART_TX_CLK)             
    );
    
    ///********************************************************///
    //////////// Custom Mux Clock /////////////////
    ///********************************************************///
    
    CLKDIV_MUX U0_CLKDIV_MUX (
    .IN(UART_Config[7:2]),
    .OUT(DIV_RATIO_RX)
    );
    
    ///********************************************************///
    //////////// Clock Divider for UART_RX Clock /////////////////
    ///********************************************************///
    
    ClkDiv U1_ClkDiv (
    .I_ref_clk(UART_CLK),             
    .I_rst_n(SYNC_UART_RST),                 
    .I_clk_en(CLKDIV_EN),               
    .I_div_ratio(DIV_RATIO_RX),           
    .O_div_clk(UART_RX_CLK)             
    );
    
    ///********************************************************///
    /////////////////////////// UART /////////////////////////////
    ///********************************************************///
    
    UART_TOP  U0_UART (
    .RST(SYNC_UART_RST),
    .TX_CLK(UART_TX_CLK),
    .RX_CLK(UART_RX_CLK),
    .PAR_EN(UART_Config[0]),
    .PAR_TYP(UART_Config[1]),
    .Prescale(UART_Config[7:2]),
    .RX_IN(UART_RX_IN),
    .RX_P_DATA(UART_RX_OUT),                      
    .RX_Data_valid(UART_RX_V_OUT),                      
    .TX_P_DATA(FIFO_RD_DATA), 
    .TX_DATA_VALID(!FIFO_EMPTY), 
    .S_DATA(UART_TX_O),
    .Busy(UART_TX_Busy),
    .PAR_ERR(parity_error),
    .STP_ERR(framing_error)                  
    );
    
    ///********************************************************///
    //////////////////// System Controller ///////////////////////
    ///********************************************************///
    
    SYS_CTRL U0_SYS_CTRL (
    .CLK(REF_CLK),
    .RST(SYNC_REF_RST),
    .RdData(RF_RdData),
    .RdData_Valid(RF_RdData_VLD),
    .WrEn(RF_WrEn),
    .RdEn(RF_RdEn),
    .Address(RF_Address),
    .WrData(RF_WrData),
    .EN(ALU_EN),
    .ALU_FUN(ALU_FUN), 
    .ALU_OUT(ALU_OUT),
    .OUT_Valid(ALU_OUT_VLD),  
    .CLK_EN(CLKG_EN), 
    .clk_div_en(CLKDIV_EN),   
    .FULL(FIFO_FULL),
    .RX_P_DATA(UART_RX_SYNC), 
    .RX_D_VLD(UART_RX_V_SYNC),
    .WR_DATA(FIFO_WR_DATA), 
    .W_INC(W_INC)
    );
    
    ///********************************************************///
    /////////////////////// Register File ////////////////////////
    ///********************************************************///
    
    Register_File U0_RegFile (
    .CLK(REF_CLK),
    .RST(SYNC_REF_RST),
    .WrEn(RF_WrEn),
    .RdEn(RF_RdEn),
    .Address(RF_Address),
    .WrData(RF_WrData),
    .RdData(RF_RdData),
    .RdData_Valid(RF_RdData_VLD),
    .REG0(Operand_A),
    .REG1(Operand_B),
    .REG2(UART_Config),
    .REG3(DIV_RATIO)
    );
    
    ///********************************************************///
    //////////////////////////// ALU /////////////////////////////
    ///********************************************************///
    
    ALU U0_ALU (
    .CLK(ALU_CLK),
    .RST(SYNC_REF_RST),  
    .A(Operand_A), 
    .B(Operand_B),
    .Enable(ALU_EN),
    .ALU_FUN(ALU_FUN),
    .ALU_OUT(ALU_OUT),
    .OUT_VALID(ALU_OUT_VLD)
    );
    
    ///********************************************************///
    ///////////////////////// Clock Gating ///////////////////////
    ///********************************************************///
    
    Clock_Gating U0_CLK_GATE (
    .CLK_EN(CLKG_EN),
    .CLK(REF_CLK),
    .GATED_CLK(ALU_CLK)
    );
endmodule