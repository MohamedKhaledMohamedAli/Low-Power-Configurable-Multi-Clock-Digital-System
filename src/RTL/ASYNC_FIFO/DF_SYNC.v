/*
    We have BUS_WIDTH since as we said before we can use this technique with sending counter values but must be grey encoding
*/
module DF_SYNC #(
        parameter BUS_WIDTH = 1,
        parameter NUM_STAGES = 2
    ) (
        input   wire                        CLK,
        input   wire                        RST,
        input   wire    [BUS_WIDTH-1:0]     ASYNC,
        output  reg     [BUS_WIDTH-1:0]     SYNC
    );
    
    // Internal registers
    reg [NUM_STAGES-1:0]    sync_reg   [BUS_WIDTH-1:0];
    
    // Loop Variable
    integer i;
    
    always @(posedge CLK or negedge RST) begin
        
        if(!RST) begin
            
            // Clear Internal Register
            for(i = 0; i < (BUS_WIDTH); i = i + 'b1) begin
                
                sync_reg[i] <= 'b0;
            end
        end
        else begin
            
            for(i = 0; i < (BUS_WIDTH); i = i + 'b1) begin
                
                /*
                    To understand it: assume BUS_WIDTH = 2, NUM_STAGES = 3
                    therefore:
                    syn_reg[0] = {syn_reg[0][1:0], ASYNC[0]} -----> means syn_reg[0] = bit 0 in syn_reg and {syn_reg[0][1:0], ASYNC[0]} 
                                                                    means bit zero from previous registers stages concatenated with 
                                                                    new value from other domain.
                                                                    (We shift the values according to no. of stages)
                    
                    Note: NUM_STAGES - 2 becauswe have ----> (-1) since MSB is NUM_STAGE - 1
                                                            and the other (-1) is because we overwrite on MSB
                    
                    therefore we loop according to bit number and we concatenate according to stages number
                */
                sync_reg[i] <= {sync_reg[i][NUM_STAGES-'b10:0], ASYNC[i]};
            end
        end
    end
    
    // Assign output
    always @(posedge CLK or negedge RST) begin
        
        if(!RST) begin
            
            // Clear Output
            SYNC <= 'b0;
        end
        else begin
            
            for(i = 0; i < (BUS_WIDTH); i = i + 'b1) begin
                
                //Here we give the output the MSB of sync_reg
                SYNC[i] <= sync_reg[i][NUM_STAGES-'b1];
            end
        end
    end
    
endmodule
