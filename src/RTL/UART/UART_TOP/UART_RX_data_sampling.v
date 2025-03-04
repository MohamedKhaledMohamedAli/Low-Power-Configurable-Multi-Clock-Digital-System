module UART_RX_data_sampling #(
        parameter COUNTER_WIDTH = 3'd4,
        parameter PRESCALE_WIDTH = 3'd5
    ) (
        input   wire                            CLK,                    // UART RX Clock Signal
        input   wire                            RST,                    // Synchronized reset signal
        input   wire                            RX_IN,                  // Serial Data IN
        input   wire                            data_sampling_enable,   // Enable data_sampling
        input   wire    [PRESCALE_WIDTH-1:0]    Prescale,               // Oversampling Prescale
        input   wire    [COUNTER_WIDTH-1:0]     bit_counter,            // Number of bit in the frame
        input   wire    [PRESCALE_WIDTH-1:0]    sample_counter,         // Counts number of edges
        output  reg                             valid_sampled_bit,      // sampled_bit is valid when this signal is high
        output  reg                             sampled_bit             // bit sampled from data_sampling module
    );
    
    // No. of Samples
    localparam NO_OF_SAMPLES = 2'd3;
    
    // Internal Register
    reg [NO_OF_SAMPLES-1:0] sampled_value_reg;
    
    always @(posedge CLK or negedge RST) begin
        
        if (!RST) begin
            
            // Reset Valid signak
            valid_sampled_bit <= 'b0;
            
            // Clear sampled_value_reg
            sampled_value_reg <= 'b0;
            
            // Clear sampled_bit
            sampled_bit <= 'b0;
        end
        else if(data_sampling_enable) begin
            
            // Reset Valid signak
            valid_sampled_bit <= 'b0;
            
            // Clear sampled_value_reg
            sampled_value_reg <= 'b0;
            
            // Clear sampled_bit
            sampled_bit <= 'b0;
        end
        else if (sample_counter == (Prescale>>1) - 'b1) begin
            
            // set first point
            sampled_value_reg[0] <= RX_IN;
            
            // Reset Valid signak
            valid_sampled_bit <= 'b0;
            
            // Clear sampled_bit
            sampled_bit <= 'b0;
        end
        else if (sample_counter == (Prescale>>1)) begin
            
            // set second point
            sampled_value_reg[1] <= RX_IN;
            
            // Reset Valid signak
            valid_sampled_bit <= 'b0;
            
            // Clear sampled_bit
            sampled_bit <= 'b0;
        end
        else if (sample_counter == (Prescale>>1) + 'b1) begin
            
            // set third point
            sampled_value_reg[2] <= RX_IN;
            
            // Reset Valid signak
            valid_sampled_bit <= 'b0;
            
            // Clear sampled_bit
            sampled_bit <= 'b0;
        end
        else if (sample_counter == Prescale - 'b10) begin
            
            // Set Valid signal
            valid_sampled_bit <= 'b1;
            
            if ((sampled_value_reg == 'b111) || (sampled_value_reg == 'b110) || (sampled_value_reg == 'b011) || (sampled_value_reg == 'b101)) begin
                
                // Set sampled_bit
                sampled_bit <= 'b1;
            end
        end
        else begin
            
            // Clear Valid signal
            valid_sampled_bit <= 'b0;
        end
    end
    
endmodule