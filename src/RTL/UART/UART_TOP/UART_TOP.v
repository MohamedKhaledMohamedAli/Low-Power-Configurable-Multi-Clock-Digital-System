module UART_TOP #(
        parameter DATA_WIDTH = 4'd8,
        parameter PRESCALE_WIDTH = 3'd6
    ) (
        input   wire                            RST,            // Synchronized reset signal
        
        ////////////////////////// UART ///////////////////////////
        input   wire                            RX_CLK,         // UART RX Clock Signal
        input   wire                            PAR_TYP,        // Parity Type
        input   wire                            PAR_EN,         // Parity Enable
        
        ///////////////////////// UART_RX /////////////////////////
        input   wire                            RX_IN,          // Serial Data IN
        input   wire    [PRESCALE_WIDTH-1:0]    Prescale,       // Oversampling Prescale
        output  wire                            RX_Data_valid,  // Data Byte Valid signal
        output  wire    [DATA_WIDTH-1:0]        RX_P_DATA,      // Frame Data Byte
        output  wire                            PAR_ERR,        // Frame parity error
        output  wire                            STP_ERR,        // Frame stop error
        
        ///////////////////////// UART_TX /////////////////////////
        input   wire                            TX_CLK,         // UART TX Clock Signal
        input   wire                            TX_DATA_VALID,
        input   wire    [DATA_WIDTH-1:0]        TX_P_DATA,      // Frame Data Byte
        output  wire                            S_DATA, Busy
    );
    
    ////////////////////// Instantiations //////////////////////
    
    // UART_RX Instantiation
    UART_RX #(.DATA_WIDTH(DATA_WIDTH), .PRESCALE_WIDTH(PRESCALE_WIDTH)) U0_uart_rx (
        .CLK(RX_CLK),                   // UART RX Clock Signal
        .RST(RST),                      // Synchronized reset signal
        .PAR_TYP(PAR_TYP),              // Parity Type
        .PAR_EN(PAR_EN),                // Parity Enable
        .RX_IN(RX_IN),                  // Serial Data IN
        .Prescale(Prescale),            // Oversampling Prescale
        .RX_Data_valid(RX_Data_valid),  // Data Byte Valid signal
        .RX_P_DATA(RX_P_DATA),          // Frame Data Byte
        .PAR_ERR(PAR_ERR),              // Frame parity error
        .STP_ERR(STP_ERR)               // Frame stop error 
    );
    
    // UART_TX Instantiation
    UART_TX #(.DATA_WIDTH(DATA_WIDTH)) U0_uart_tx (
        .CLK(TX_CLK),                   // UART TX Clock Signal
        .RST(RST),                      // Synchronized reset signal
        .PAR_TYP(PAR_TYP),              // Parity Type
        .PAR_EN(PAR_EN),                // Parity Enable
        .TX_DATA_VALID(TX_DATA_VALID),
        .TX_P_DATA(TX_P_DATA),
        .S_DATA(S_DATA),
        .Busy(Busy)
    );
endmodule
