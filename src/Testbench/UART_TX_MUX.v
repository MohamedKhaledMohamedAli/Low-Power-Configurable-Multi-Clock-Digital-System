module UART_TX_MUX (
        input   wire   [1:0]   MUX_sel,
        input   wire           ser_data, parity_data,
        output  reg            MUX_OUT
    );

    localparam [1:0]    IDLE_BIT          = 2'b00,
                        START_BIT         = 2'b01,
                        DATA_TRANSMISSION = 2'b10,
                        PARITY_BIT        = 2'b11;
    
    always @(*) begin
        case (MUX_sel)
            IDLE_BIT: begin
                
                MUX_OUT = 1'b1;
            end
            START_BIT: begin
                
                MUX_OUT = 1'b0;
            end
            DATA_TRANSMISSION: begin
                
                MUX_OUT = ser_data;
            end
            PARITY_BIT: begin
                
                MUX_OUT = parity_data;
            end
            default: begin
                
                MUX_OUT = 1'b1;
            end
        endcase
    end

endmodule