module CLKDIV_MUX #(
        parameter CONFIG_WIDTH = 6,
        parameter DATA_WIDTH = 8
    ) (
        input   wire    [CONFIG_WIDTH-1:0]  IN,
        output  reg     [DATA_WIDTH-1:0]    OUT
    );
    
    // Combinational Always block
    always @(*) begin
        
        case (IN)
            'd32: begin // Since UART_CLK is 32 times of UART_TX so we will not change anything if configuration was 32
                
                // We will do nothing
                OUT = 'd1;
            end
            'd16: begin // if configuration is 16 times we will divide the clock by 2
                
                // We will divide by 2
                OUT = 'd2;
            end
            'd8: begin  // if configuration is 8 times we will divide the clock by 4
                
                // We will divide by 4
                OUT = 'd4;
            end
            'd4: begin  // if configuration is 4 times we will divide the clock by 8
                
                // We will divide by 8
                OUT = 'd8;
            end
            default: begin
                
                // unkown Configuration therefore do nothing
                OUT = 'd1;
            end
        endcase
    end
endmodule