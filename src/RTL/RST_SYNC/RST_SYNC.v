module RST_SYNC #(
        parameter NUM_STAGES = 2
    ) (
        input   wire    CLK,
        input   wire    RST,
        output  wire    SYNC_RST
    );
    
    // Internal registers
    reg [NUM_STAGES-1:0]    sync_reg;
    
    // Loop Variable
    integer i;
    
    always @(posedge CLK or negedge RST) begin
        
        if(!RST) begin
            
            // Clear Internal Register
            sync_reg <= 'b0;
        end
        else begin
            
            sync_reg <= {sync_reg[NUM_STAGES-'b10:0],1'b1} ;
        end
    end
    
    // Assign output
    assign  SYNC_RST = sync_reg[NUM_STAGES-'b1];
    
endmodule
