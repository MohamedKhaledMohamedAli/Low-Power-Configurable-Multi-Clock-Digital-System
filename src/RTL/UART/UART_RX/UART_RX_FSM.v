module UART_RX_FSM #(
        parameter COUNTER_WIDTH = 3'd4
    ) (
        input   wire                        CLK,                    // UART RX Clock Signal
        input   wire                        RST,                    // Synchronized reset signal
        input   wire                        PAR_EN,                 // Parity Enable
        input   wire                        RX_IN,                  // Serial Data IN
        input   wire                        start_glitch,           // Error if it was a glitch (not start bit)
        input   wire                        PAR_ERR,                // Error if parity bit is wrong
        input   wire                        STP_ERR,                // Error if there was no Stop bit
        input   wire    [COUNTER_WIDTH-1:0] bit_counter,            // Number of bit in the frame
        output  reg                         Data_valid,             // Data Byte Valid signal
        output  reg                         edge_conter_enable,     // Enable edge_counter
        output  reg                         data_sampling_enable,   // Enable data_sampling
        output  reg                         parity_check_enable,    // Enable parity_check
        output  reg                         start_bit_check_enable, // Enable start_bit_check
        output  reg                         stop_bit_check_enable,  // Enable stop_bit_check
        output  reg                         deserializer_enable     // Enable deserializer
    );
    
    /*
    States:
        1) IDLE: Waiting for start bit
        2) CHECK_START: Check if receiver received start bit or was it a glitch
        3) BUSY: Here the receiver deserializer the data received
        4) CHECK_IF_DATA_IS_VALID: checking that the frame is received correctly and not corrupted (PAR_ERR = 0 && STP_ERR = 0)
    */
    localparam  [1:0]   IDLE                   = 2'b00,
                        CHECK_START            = 2'b01,
                        BUSY                   = 2'b11,
                        CHECK_IF_DATA_IS_VALID = 2'b10;
    
    // Declare current state and next state registers
    reg [1:0]   curr_state, next_state;
    
    always @(posedge CLK or negedge RST) begin
        
        if(!RST) begin
            
            // Return to IDLE state
            curr_state <= IDLE;
        end
        else begin
            
            curr_state <= next_state;
        end
    end
    
    always @(*) begin
        
        // default values
        // clear signals
        Data_valid = 'b0;
        edge_conter_enable = 'b0;
        data_sampling_enable = 'b0;
        parity_check_enable = 'b0;
        start_bit_check_enable = 'b0;
        stop_bit_check_enable = 'b0;
        deserializer_enable = 'b0;
        
        case (curr_state)
            
            IDLE: begin
                
                // next state calculation
                if(!RX_IN) begin
                    
                    // Check if it's a glitch or start bit
                    next_state = CHECK_START;
                end
                else begin
                    
                    // Stay in the IDLE state
                    next_state = IDLE;
                end
                
                // signals calculation
                if(!RX_IN) begin
                    
                    // Enable start_bit_check
                    start_bit_check_enable = 1'b1;
                    
                    // Enable edge counter
                    edge_conter_enable = 1'b1;
                end
                else begin
                    
                    // Disable start_bit_check
                    start_bit_check_enable = 1'b0;
                    
                    // Disable edge counter
                    edge_conter_enable = 1'b0;
                end
            end
            CHECK_START: begin
                
                // next state calculation
                // check if it wasn't a glitch
                if(!start_glitch && (bit_counter == 'b1)) begin
                    
                    // Received start bit
                    // start receiving data
                    next_state = BUSY;
                end
                else if (start_glitch && (bit_counter == 'b1)) begin
                    
                    // It was a glitch
                    // Return to the IDLE state
                    next_state = IDLE;
                end
                else begin
                    
                    // Remain in the same state
                    next_state = CHECK_START;
                end
                
                // signals calculation
                // check if it wasn't a glitch
                if(!start_glitch && (bit_counter == 'b1)) begin
                    
                    // Enable deserializer
                    deserializer_enable = 1'b1;
                    
                    // Enable data_sampling
                    data_sampling_enable = 1'b1;
                end
                else begin
                    
                    // Disable deserializer
                    deserializer_enable = 1'b0;
                    
                    // Disable data_sampling
                    data_sampling_enable = 1'b0;
                end
            end
            BUSY: begin
                
                // next state calculation
                if((bit_counter == 4'b1000) && !PAR_EN) begin
                    
                    // Go and Check Stop bit
                    next_state = CHECK_IF_DATA_IS_VALID;
                end
                else if ((bit_counter == 4'b1001) && PAR_EN) begin
                    
                    if(!PAR_ERR) begin

                        // Go and check for Stop bit and Parity bit
                        next_state = CHECK_IF_DATA_IS_VALID;
                    end
                    else begin
                        
                        // Error in Parity therefore return to IDLE state
                        next_state = IDLE;
                    end
                end
                else begin
                    
                    // Stay in BUSY state
                    next_state = BUSY;
                end
                
                // signals calculation
                if((bit_counter == 4'b0111)) begin
                    
                    if(PAR_EN) begin
                        
                        // Enable parity bit check
                        parity_check_enable = 1'b1;
                        
                        // Disable Stop bit Check
                        stop_bit_check_enable = 1'b0;
                    end
                    else begin
                        
                        // Disable parity bit check
                        parity_check_enable = 1'b0;
                        
                        // Enable Stop bit Check
                        stop_bit_check_enable = 1'b1;
                    end
                end
                else if ((bit_counter == 4'b1000) && PAR_EN) begin
                    
                    // Disable parity bit check
                    parity_check_enable = 1'b0;
                    
                    // Enable Stop bit Check
                    stop_bit_check_enable = 1'b1;
                end
                else begin
                    
                    // Disable both Stop bit and Parity bit check
                    start_bit_check_enable = 1'b0;
                    parity_check_enable = 1'b0;
                end
            end
            CHECK_IF_DATA_IS_VALID: begin
                
                // next state calculation
                // Check if a consequent frame start bit or if it is a glitch
                if((((bit_counter == 4'b1001) && !PAR_EN) || (bit_counter == 4'b1010)) && (!RX_IN)) begin
                    
                    // Check if it's a glitch or start bit
                    next_state = CHECK_START;
                end
                else if((((bit_counter == 4'b1001) && !PAR_EN) || (bit_counter == 4'b1010)) && RX_IN) begin
                    
                    // Return to the IDLE state
                    next_state = IDLE;
                end
                else begin
                    
                    // Remain in the same state
                    next_state = CHECK_IF_DATA_IS_VALID;
                end                
                
                // signals calculation
                if(((!PAR_ERR && !STP_ERR && (bit_counter == 4'b1010)) || ((bit_counter == 4'b1001) && !STP_ERR && !PAR_EN))) begin
                    
                    // Set Data_valid since no Error has Occurred
                    Data_valid = 1'b1;
                end
                else begin
                    
                    // Clear Data_valid until the check is passed
                    Data_valid = 1'b0;
                end
                
                // signals calculation
                if((((bit_counter == 4'b1001) && !PAR_EN) || (bit_counter == 4'b1010)) && (!RX_IN)) begin
                    
                    // Enable start_bit_check
                    start_bit_check_enable = 1'b1;
                    
                    // Enable edge counter
                    edge_conter_enable = 1'b1;
                end
                else begin
                    
                    // Disable start_bit_check
                    start_bit_check_enable = 1'b0;
                    
                    // Disable edge counter
                    edge_conter_enable = 1'b0;
                end
            end
            default: begin
                
                // Return to IDLE state
                next_state = IDLE;
            end
        endcase
        
    end
    
endmodule
