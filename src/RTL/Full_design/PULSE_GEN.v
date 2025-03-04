module PULSE_GEN (
        input   wire    CLK,        // Clock Signal
        input   wire    RST,        // Active Low Reset
        input   wire    LVL_SIG,    // Level signal
        output  wire    PULSE_SIG   // Pulse signal
    );
    
    // Internal Register
    reg     internal_reg;
    
    // Sequential Always Block
    always @(posedge CLK or negedge RST) begin
        
        // If reset signal is low clear internal register
        if(!RST) begin
            
            // Clear Internal register
            internal_reg <= 'b0;
        end
        
        // Else internal register equal to input
        else begin
            
            // Internal register equals the input
            internal_reg <= LVL_SIG;
        end
    end
    
    // Assign Output
    assign PULSE_SIG = LVL_SIG & (!internal_reg);
endmodule