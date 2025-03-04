module UART_RX_parity_check #(
        parameter COUNTER_WIDTH = 3'd4,
        parameter DATA_WIDTH = 4'd8
    ) (
        input   wire                        CLK,                    // UART RX Clock Signal
        input   wire                        RST,                    // Synchronized reset signal
        input   wire                        valid_sampled_bit,      // sampled_bit is valid when this signal is high
        input   wire                        sampled_bit,            // bit sampled from data_sampling module
        input   wire                        parity_check_enable,    // Enable parity_check
        input   wire                        PAR_TYP,                // Parity Type
        input   wire    [DATA_WIDTH-1:0]    P_DATA,                 // Frame Data Byte
        input   wire    [COUNTER_WIDTH-1:0] bit_counter,            // Number of bit in the frame
        output  reg                         PAR_ERR                 // Error if parity bit is wrong
    );

    // Internal Wire
    wire    parity_bit;
    assign parity_bit = ^P_DATA;

    always @(posedge CLK or negedge RST) begin
        
        if(!RST) begin
            
            // Clear PAR_ERR
            PAR_ERR <= 'b0;
        end
        else if(parity_check_enable) begin
            
            // Clear PAR_ERR
            PAR_ERR <= 'b0;
        end
        else if(valid_sampled_bit) begin
            
            if(bit_counter == 4'b1001) begin
                if(PAR_TYP) begin
                    
                    if(sampled_bit == !parity_bit) begin
                        
                        // Correct Parity therefore clear PAR_ERR
                        PAR_ERR <= 'b0;
                    end
                    else begin
                        
                        // Wrong Parity therefore set PAR_ERR
                        PAR_ERR <= 'b1;
                    end
                end
                else begin
                    
                    if(sampled_bit == parity_bit) begin
                        
                        // Correct Parity therefore clear PAR_ERR
                        PAR_ERR <= 'b0;
                    end
                    else begin
                        
                        // Wrong Parity therefore set PAR_ERR
                        PAR_ERR <= 'b1;
                    end
                end
            end
        end
    end

endmodule
