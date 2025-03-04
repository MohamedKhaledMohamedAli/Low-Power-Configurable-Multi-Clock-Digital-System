module FIFO_MEM_CNTRL #(
        parameter   DATA_WIDTH = 8,
        parameter   ADDR_WIDTH = 3,
        parameter   MEM_DEPTH = 2**ADDR_WIDTH
    ) (
        input   wire                        W_CLK,      // Source domain clock
        input   wire                        W_RST,      // Source domain Async reset
        input   wire                        W_CLK_EN,   // Source domain enable for FIFO_memory
        input   wire    [ADDR_WIDTH-1:0]    W_ADDR,     // Write operation Address
        input   wire    [ADDR_WIDTH-1:0]    R_ADDR,     // Read operation Address
        input   wire    [DATA_WIDTH-1:0]    W_DATA,     // Write Data Bus
        output  wire    [DATA_WIDTH-1:0]    R_DATA      // Read Data Bus
    );
    
    // The memory of the FIFO
    reg     [DATA_WIDTH-1:0]    FIFO_memory     [0:MEM_DEPTH-1];
    
    // Loop Variable
    integer i;
    
    // Always block to handle Source Domain (Write Domain)
    always @(posedge W_CLK or negedge W_RST) begin
        
        // If W_RST signal is low clear the FIFO_memory
        if(!W_RST) begin
            
            // Clear the whole FIFO_memory
            for(i = 0;i < MEM_DEPTH;i = i + 1) begin
                
                // Clear FIFO_memory
                FIFO_memory[i] <= 'b0;
            end
        end
        
        // Else If the Enable was High
        else if(W_CLK_EN) begin
            
            // Write in the FIFO memory if write operation was enable
            FIFO_memory[W_ADDR] <= W_DATA;
        end
    end
    
    // Read Data to Destination Domain
    assign R_DATA = FIFO_memory[R_ADDR];
    
endmodule