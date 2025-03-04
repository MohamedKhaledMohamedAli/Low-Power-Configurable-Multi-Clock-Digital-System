module UART_TX_Serializer #(
        parameter DATA_WIDTH = 8
    ) (
        input   wire                        CLK, RST,
        input   wire    [DATA_WIDTH - 1:0]  P_DATA,
        input   wire                        Serial_EN,
        output  wire                        Serial_done,
        output  reg                         ser_data
    );

    // Register to Store input data
    reg [DATA_WIDTH - 1 : 0]    serial_reg;

    // internal register used for counting
    reg [3 : 0] counter;

    always @(posedge CLK or negedge RST) begin
        if(!RST) begin
            serial_reg <= 'b0;
            counter <= 'b0;
            ser_data <= 0;
        end
        else if(Serial_EN) begin
            serial_reg <= P_DATA;
            counter <= 'b0;
        end
        else begin

            if(counter != 'b1000) begin
                counter <= counter + 'b1;
            end

            ser_data <= serial_reg[0];

            serial_reg <= serial_reg >> 1'b1;
        end
    end

    assign Serial_done = (counter == 'b1000);
    
endmodule
