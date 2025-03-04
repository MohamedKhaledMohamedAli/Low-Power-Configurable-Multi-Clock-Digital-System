module UART_RX #(
        parameter DATA_WIDTH = 4'd8,
        parameter PRESCALE_WIDTH = 3'd6
    ) (
        input   wire                            CLK,            // UART RX Clock Signal
        input   wire                            RST,            // Synchronized reset signal
        input   wire                            PAR_TYP,        // Parity Type
        input   wire                            PAR_EN,         // Parity Enable
        input   wire                            RX_IN,          // Serial Data IN
        input   wire    [PRESCALE_WIDTH-1:0]    Prescale,       // Oversampling Prescale
        output  wire                            RX_Data_valid,  // Data Byte Valid signal
        output  wire    [DATA_WIDTH-1:0]        RX_P_DATA,      // Frame Data Byte
        output  wire                            PAR_ERR,        // Frame parity error
        output  wire                            STP_ERR         // Frame stop error 
    );
    
    // Parameters
    parameter COUNTER_WIDTH = 3'd4;
    
    // Internal wires
    wire    start_glitch, edge_conter_enable, data_sampling_enable, parity_check_enable, start_bit_check_enable, stop_bit_check_enable, deserializer_enable, sampled_bit, valid_sampled_bit;
    wire    [COUNTER_WIDTH-1:0]     bit_counter;
    wire    [PRESCALE_WIDTH-1:0]    sample_counter;
    
    ////////////////////// Instantiations //////////////////////
    
    // FSM Instantiation
    UART_RX_FSM #(.COUNTER_WIDTH(COUNTER_WIDTH)) U0_fsm (
        .CLK(CLK),                                          // UART RX Clock Signal
        .RST(RST),                                          // Synchronized reset signal
        .PAR_EN(PAR_EN),                                    // Parity Enable
        .RX_IN(RX_IN),                                      // Serial Data IN
        .start_glitch(start_glitch),                        // Error if it was a glitch (not start bit)
        .PAR_ERR(PAR_ERR),                                  // Error if parity bit is wrong
        .STP_ERR(STP_ERR),                                  // Error if there was no Stop bit
        .bit_counter(bit_counter),                          // Number of bit in the frame
        .Data_valid(RX_Data_valid),                         // Data Byte Valid signal
        .edge_conter_enable(edge_conter_enable),            // Enable edge_counter
        .data_sampling_enable(data_sampling_enable),        // Enable data_sampling
        .parity_check_enable(parity_check_enable),          // Enable parity_check
        .start_bit_check_enable(start_bit_check_enable),    // Enable start_bit_check
        .stop_bit_check_enable(stop_bit_check_enable),      // Enable stop_bit_check
        .deserializer_enable(deserializer_enable)           // Enable deserializer
    );
    
    // edge_counter Instantiation
    UART_RX_edge_counter #(.COUNTER_WIDTH(COUNTER_WIDTH), .PRESCALE_WIDTH(PRESCALE_WIDTH)) U0_edge_counter (
        .CLK(CLK),                                          // UART RX Clock Signal
        .RST(RST),                                          // Synchronized reset signal
        .bit_counter(bit_counter),                          // Number of bit in the frame
        .edge_conter_enable(edge_conter_enable),            // Enable edge_counter
        .Prescale(Prescale),                                // Oversampling Prescale
        .sample_counter(sample_counter)                     // Counts number of edges
    );
    
    // data_sampling Instantiation
    UART_RX_data_sampling #(.COUNTER_WIDTH(COUNTER_WIDTH), .PRESCALE_WIDTH(PRESCALE_WIDTH)) U0_data_sampling (
        .CLK(CLK),                                          // UART RX Clock Signal
        .RST(RST),                                          // Synchronized reset signal
        .RX_IN(RX_IN),                                      // Serial Data IN
        .data_sampling_enable(data_sampling_enable),        // Enable data_sampling
        .Prescale(Prescale),                                // Oversampling Prescale
        .bit_counter(bit_counter),                          // Number of bit in the frame
        .sample_counter(sample_counter),                    // Counts number of edges
        .sampled_bit(sampled_bit),                          // bit sampled from data_sampling module
        .valid_sampled_bit(valid_sampled_bit)               // sampled_bit is valid when this signal is high
    );
    
    // deserializer Instantiation
    UART_RX_deserializer #(.DATA_WIDTH(DATA_WIDTH)) U0_deserializer (
        .CLK(CLK),                                          // UART RX Clock Signal
        .RST(RST),                                          // Synchronized reset signal
        .valid_sampled_bit(valid_sampled_bit),              // sampled_bit is valid when this signal is high
        .sampled_bit(sampled_bit),                          // bit sampled from data_sampling module
        .deserializer_enable(deserializer_enable),          // Enable deserializer
        .P_DATA(RX_P_DATA)                                  // Frame Data Byte
    );
    
    // stop_bit_check Instantiation
    UART_RX_stop_bit_check #(.COUNTER_WIDTH(COUNTER_WIDTH)) U0_stop_bit_check (
        .CLK(CLK),                                          // UART RX Clock Signal
        .RST(RST),                                          // Synchronized reset signal
        .valid_sampled_bit(valid_sampled_bit),              // sampled_bit is valid when this signal is high
        .sampled_bit(sampled_bit),                          // bit sampled from data_sampling module
        .PAR_EN(PAR_EN),                                    // Parity Enable
        .STP_ERR(STP_ERR),                                  // Error if there was no Stop bit
        .bit_counter(bit_counter),                          // Number of bit in the frame
        .stop_bit_check_enable(stop_bit_check_enable)       // Enable stop_bit_check
    );
    
    // start_bit_check Instantiation
    UART_RX_start_bit_check #(.COUNTER_WIDTH(COUNTER_WIDTH)) U0_start_bit_check (
        .CLK(CLK),                                          // UART RX Clock Signal
        .RST(RST),                                          // Synchronized reset signal
        .valid_sampled_bit(valid_sampled_bit),              // sampled_bit is valid when this signal is high
        .sampled_bit(sampled_bit),                          // bit sampled from data_sampling module
        .start_glitch(start_glitch),                        // Error if it was a glitch (not start bit)
        .start_bit_check_enable(start_bit_check_enable),    // Enable start_bit_check
        .bit_counter(bit_counter)                           // Number of bit in the frame
    );
    
    // parity_check Instantiation
    UART_RX_parity_check #(.COUNTER_WIDTH(COUNTER_WIDTH), .DATA_WIDTH(DATA_WIDTH)) U0_parity_check (
        .CLK(CLK),                                          // UART RX Clock Signal
        .RST(RST),                                          // Synchronized reset signal
        .valid_sampled_bit(valid_sampled_bit),              // sampled_bit is valid when this signal is high
        .sampled_bit(sampled_bit),                          // bit sampled from data_sampling module
        .PAR_ERR(PAR_ERR),                                  // Error if parity bit is wrong
        .bit_counter(bit_counter),                          // Number of bit in the frame
        .parity_check_enable(parity_check_enable),          // Enable parity_check
        .PAR_TYP(PAR_TYP),                                  // Parity Type
        .P_DATA(RX_P_DATA)                                  // Frame Data Byte
    );
endmodule