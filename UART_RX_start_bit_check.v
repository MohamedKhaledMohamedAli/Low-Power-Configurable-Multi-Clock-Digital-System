module UART_RX_start_bit_check #(
        parameter COUNTER_WIDTH = 3'd4
    ) (
        input   wire                        CLK,                    // UART RX Clock Signal
        input   wire                        RST,                    // Synchronized reset signal
        input   wire                        valid_sampled_bit,      // sampled_bit is valid when this signal is high
        input   wire                        sampled_bit,            // bit sampled from data_sampling module
        input   wire                        start_bit_check_enable, // Enable start_bit_check
        input   wire    [COUNTER_WIDTH-1:0] bit_counter,            // Number of bit in the frame
        output  reg                         start_glitch            // Error if it was a glitch (not start bit)
    );

    always @(posedge CLK or negedge RST) begin
        
        if(!RST) begin
            
            // Clear start_glitch
            start_glitch <= 'b0;
        end
        else if(start_bit_check_enable) begin

            // Clear start_glitch
            start_glitch <= 'b0;
        end
        else if(valid_sampled_bit) begin
            
            if(bit_counter == 'b1) begin
                if(!sampled_bit) begin
                    
                    // Therefore we received start bit therefore clear start_glitch
                    start_glitch <= 'b0;
                end
                else begin
                    
                    // Therefore a glitch has occurred therefore set start_glitch
                    start_glitch <= 'b1;
                end
            end
        end
    end

endmodule