module UART_RX_stop_bit_check #(
        parameter COUNTER_WIDTH = 3'd4
    ) (
        input   wire                        CLK,                    // UART RX Clock Signal
        input   wire                        RST,                    // Synchronized reset signal
        input   wire                        valid_sampled_bit,      // sampled_bit is valid when this signal is high
        input   wire                        sampled_bit,            // bit sampled from data_sampling module
        input   wire                        stop_bit_check_enable,  // Enable stop_bit_check
        input   wire                        PAR_EN,                 // Parity Enable
        input   wire    [COUNTER_WIDTH-1:0] bit_counter,            // Number of bit in the frame
        output  reg                         STP_ERR                 // Error if there was no Stop bit
    );

    always @(posedge CLK or negedge RST) begin
        
        if(!RST) begin
            
            // Clear STP_ERR
            STP_ERR <= 'b0;
        end
        else if(stop_bit_check_enable) begin

            // Clear STP_ERR
            STP_ERR <= 'b0;
        end
        else if(valid_sampled_bit) begin
            
            if(((bit_counter == 4'b1001) && !PAR_EN) || ((bit_counter == 4'b1010) && PAR_EN)) begin
                if(sampled_bit) begin
                    
                    // Therefore received stop bit therefore clear STP_ERR
                    STP_ERR <= 'b0;
                end
                else begin
                    
                    // Therefore didn't received stop bit therefore set STP_ERR
                    STP_ERR <= 'b1;
                end
            end
        end
    end

endmodule