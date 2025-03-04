module UART_RX_edge_counter #(
        parameter COUNTER_WIDTH = 3'd4,
        parameter PRESCALE_WIDTH = 3'd5
    ) (
        input   wire                            CLK,                    // UART RX Clock Signal
        input   wire                            RST,                    // Synchronized reset signal
        input   wire                            edge_conter_enable,     // Enable edge_counter
        input   wire    [PRESCALE_WIDTH-1:0]    Prescale,               // Oversampling Prescale
        output  reg     [COUNTER_WIDTH-1:0]     bit_counter,            // Number of bit in the frame
        output  reg     [PRESCALE_WIDTH-1:0]    sample_counter          // Counts number of edges
    );

    always @(posedge CLK or negedge RST) begin

        if(!RST) begin
            
            // Clear sample_counter
            sample_counter <= 'b0;

            // Clear bit_counter
            bit_counter <= 'b0;
        end
        else if(edge_conter_enable) begin
            
            // Clear sample_counter
            sample_counter <= 'b0;
            
            // Clear bit_counter
            bit_counter <= 'b0;
        end
        else begin
            
            // Increment sample_counter
            sample_counter <= sample_counter + 'b1;
            
            if(sample_counter == (Prescale - 'b1)) begin
                
                // Increment bit_counter
                bit_counter <= bit_counter + 'b1;
                
                // Clear sample_counter
                sample_counter <= 'b0;
            end
        end
    end

endmodule