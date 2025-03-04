module FIFO_RD #(
        parameter   DATA_WIDTH = 8,
        parameter   ADDR_WIDTH = 3 // Note: we will add additional bit to R_ADDR, R_PTR and R_PTR_SUNC to be able to indicate if FIFO_memory is Full or Empty
    ) (
        input   wire                        R_CLK,      // Destination domain clock
        input   wire                        R_RST,      // Destination domain Async reset
        input   wire                        R_INC,      // Read operation enable
        input   wire    [ADDR_WIDTH:0]      W_PTR_SYNC, // Source Domain Address (Write Address) Synchronized to Destination Domain (Read Domain)
        output  wire                        R_EMPTY,    // To indicate if FIFO_memory is Empty or not
        output  reg     [ADDR_WIDTH:0]      R_ADDR,     // Read operation Address
        output  reg     [ADDR_WIDTH:0]      R_PTR       // To Send Read Address to  Source Domain (Write Domain) in Gray Encoding
    );
    
    
    // Always block to handle R_ADDR (Read Address)
    always @(posedge R_CLK or negedge R_RST) begin
        
        // If reset was Low we will reset and put R_ADDR with zero
        if(!R_RST) begin
            
            // We Will put R_ADDR with zero
            R_ADDR <= 'b0;
        end
        
        // Else if Read was enabled and FIFO_memory is not Empty we will Read from the FIFO_memory
        // We will Increment the R_ADDR
        else if ((!R_EMPTY) && R_INC) begin
            
            // Increment R_ADDR
            R_ADDR <= R_ADDR + 'b1;
        end
    end
    
    // Combainational Always block to handle Gray Encoding
    always @(*) begin
        
        case (R_ADDR)
            4'b0000: R_PTR = 4'b0000 ;
            4'b0001: R_PTR = 4'b0001 ;
            4'b0010: R_PTR = 4'b0011 ;
            4'b0011: R_PTR = 4'b0010 ;
            4'b0100: R_PTR = 4'b0110 ;
            4'b0101: R_PTR = 4'b0111 ;
            4'b0110: R_PTR = 4'b0101 ;
            4'b0111: R_PTR = 4'b0100 ;
            4'b1000: R_PTR = 4'b1100 ;
            4'b1001: R_PTR = 4'b1101 ;
            4'b1010: R_PTR = 4'b1111 ;
            4'b1011: R_PTR = 4'b1110 ;
            4'b1100: R_PTR = 4'b1010 ;
            4'b1101: R_PTR = 4'b1011 ;
            4'b1110: R_PTR = 4'b1001 ;
            4'b1111: R_PTR = 4'b1000 ;
        endcase
    end
    
    // Always block to assign Empty flag
    // Empty flag condition from CDC Slides of Eltemsah Go there to Understand
    // Condition of FIFO_memory to be Empty
    // Since condition is True therefore FIFO_memory is Empty
    assign R_EMPTY = (R_PTR == W_PTR_SYNC);
endmodule