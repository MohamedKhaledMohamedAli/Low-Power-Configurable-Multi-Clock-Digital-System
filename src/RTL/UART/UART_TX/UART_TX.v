module UART_TX #(
        parameter   DATA_WIDTH = 8
    ) (
        input   wire                        CLK, RST, PAR_TYP, PAR_EN, TX_DATA_VALID,
        input   wire    [DATA_WIDTH - 1:0]  TX_P_DATA,
        output  wire                        S_DATA, Busy
    );
    
    // Internal wires
    wire            Serial_done, Serial_EN, Parity_EN, ser_data, parity_data;
    wire    [1:0]   MUX_sel;
    
    ////////////////////// Instantiations //////////////////////
    // FSM Instantiation
    UART_TX_FSM FSM_U (
        .CLK(CLK),
        .RST(RST),
        .PAR_EN(PAR_EN),
        .DATA_VALID(TX_DATA_VALID),
        .Serial_done(Serial_done),
        .Busy(Busy),
        .Serial_EN(Serial_EN),
        .Parity_EN(Parity_EN),
        .MUX_sel(MUX_sel)
    );

    // MUX Instantiation
    UART_TX_MUX MUX_U (
        .MUX_sel(MUX_sel),
        .ser_data(ser_data),
        .parity_data(parity_data),
        .MUX_OUT(S_DATA)
    );

    // Parity_Calc Instantiation
    UART_TX_Parity_Calc #(.DATA_WIDTH(DATA_WIDTH)) Parity_Calc_U (
        .PAR_EN(PAR_EN),
        .Parity_EN(Parity_EN),
        .PAR_TYP(PAR_TYP),
        .CLK(CLK),
        .RST(RST),
        .P_DATA(TX_P_DATA),
        .parity_data(parity_data)
    );

    // Parity_Calc Instantiation
    UART_TX_Serializer #(.DATA_WIDTH(DATA_WIDTH)) Serializer_U (
        .CLK(CLK),
        .RST(RST),
        .P_DATA(TX_P_DATA),
        .Serial_EN(Serial_EN),
        .Serial_done(Serial_done),
        .ser_data(ser_data)
    );
    
endmodule
