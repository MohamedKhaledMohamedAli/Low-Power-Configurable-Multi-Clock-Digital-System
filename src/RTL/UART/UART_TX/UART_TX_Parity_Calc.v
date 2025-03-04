module UART_TX_Parity_Calc #(
        parameter DATA_WIDTH = 4'd8
    ) (
        input   wire                        PAR_EN, Parity_EN, PAR_TYP, CLK, RST,
        input   wire    [DATA_WIDTH - 1:0]  P_DATA,
        output  reg                         parity_data
    );

    // Register to Store input data
    reg [DATA_WIDTH - 1 : 0]    parity_reg;

    always @(posedge CLK or negedge RST) begin
        if(!RST) begin
            parity_reg <= 'b0;
        end
        else if(PAR_EN && Parity_EN) begin
            parity_reg <= P_DATA;
        end
    end

    always @(*) begin
        
        if(PAR_TYP) begin
            parity_data = ~^parity_reg;
        end
        else begin
            parity_data = ^parity_reg;
        end
    end
    
endmodule
