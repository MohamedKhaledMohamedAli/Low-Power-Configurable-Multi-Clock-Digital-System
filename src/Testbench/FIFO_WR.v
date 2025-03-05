module FIFO_WR #(
        parameter   DATA_WIDTH = 8,
        parameter   ADDR_WIDTH = 3 // Note: we will add additional bit to W_ADDR, W_PTR and R_PTR_SUNC to be able to indicate if FIFO_memory is Full or Empty
    ) (
        input   wire                        W_CLK,      // Source domain clock
        input   wire                        W_RST,      // Source domain Async reset
        input   wire                        W_INC,      // Write operation enable
        input   wire    [ADDR_WIDTH:0]      R_PTR_SYNC, // Destination Domain Address (Read Address) Synchronized to Source Domain (Write Domain)
        output  wire                        W_FULL,     // To indicate if FIFO_memory is Full or not
        output  reg     [ADDR_WIDTH:0]      W_ADDR,     // Write operation Address
        output  reg     [ADDR_WIDTH:0]      W_PTR       // To Send Write Address to  Destination Domain (Read Domain) in Gray Encoding
    );
    
    
    // Always block to handle W_ADDR (Write Address)
    always @(posedge W_CLK or negedge W_RST) begin
        
        // If reset was Low we will reset and put W_ADDR with zero
        if(!W_RST) begin
            
            // We Will put W_ADDR with zero
            W_ADDR <= 'b0;
        end
        
        // Else if Write was enabled and FIFO_memory is not Full we will Write in the FIFO_memory
        // We will Increment the W_ADDR
        else if ((!W_FULL) && W_INC) begin
            
            // Increment W_ADDR
            W_ADDR <= W_ADDR + 'b1;
        end
    end
    
    // Combainational Always block to handle Gray Encoding
    always @(*) begin
        
        case (W_ADDR)
            4'b0000: W_PTR = 4'b0000 ;
            4'b0001: W_PTR = 4'b0001 ;
            4'b0010: W_PTR = 4'b0011 ;
            4'b0011: W_PTR = 4'b0010 ;
            4'b0100: W_PTR = 4'b0110 ;
            4'b0101: W_PTR = 4'b0111 ;
            4'b0110: W_PTR = 4'b0101 ;
            4'b0111: W_PTR = 4'b0100 ;
            4'b1000: W_PTR = 4'b1100 ;
            4'b1001: W_PTR = 4'b1101 ;
            4'b1010: W_PTR = 4'b1111 ;
            4'b1011: W_PTR = 4'b1110 ;
            4'b1100: W_PTR = 4'b1010 ;
            4'b1101: W_PTR = 4'b1011 ;
            4'b1110: W_PTR = 4'b1001 ;
            4'b1111: W_PTR = 4'b1000 ;
        endcase
    end
    
    // Always block to assign Full flag
    // Full flag condition from CDC Slides of Eltemsah Go there to Understand
    // Condition of FIFO_memory to be Full
    // Since condition is True therefore FIFO_memory is Full
    assign W_FULL = ((W_PTR[3] != R_PTR_SYNC[3]) && (W_PTR[2] != R_PTR_SYNC[2]) && (W_PTR[1:0] == R_PTR_SYNC[1:0]));
endmodule