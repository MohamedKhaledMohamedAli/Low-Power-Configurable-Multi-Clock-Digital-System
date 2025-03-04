module UART_RX_deserializer #(
        parameter DATA_WIDTH = 4'd8
    ) (
        input   wire                        CLK,                    // UART RX Clock Signal
        input   wire                        RST,                    // Synchronized reset signal
        input   wire                        valid_sampled_bit,      // sampled_bit is valid when this signal is high
        input   wire                        sampled_bit,            // bit sampled from data_sampling module
        input   wire                        deserializer_enable,    // Enable deserializer
        output  reg     [DATA_WIDTH-1:0]    P_DATA                  // Frame Data Byte
    );
    
    // Internal Counter
    reg [3:0]    count;
    
    always @(posedge CLK or negedge RST) begin
        
        if(!RST) begin
            
            // Clear Counter
            count <= 'b0;
            
            // Clear Output
            P_DATA <= 'b0;
        end
        else if(deserializer_enable) begin
            
            // Clear Counter
            count <= 'b0;
            
            // Clear Output
            P_DATA <= 'b0;
        end
        else if (valid_sampled_bit && (count != DATA_WIDTH)) begin
            
            // deserialize the data
            P_DATA <= P_DATA | (sampled_bit << count);
            
            // Increment the counter
            count <= count + 'b1;
        end
    end
    
endmodule