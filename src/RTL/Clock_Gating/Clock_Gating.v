module Clock_Gating (
        input      CLK_EN,      // Clock Enable
        input      CLK,         // Clock Signal
        output     GATED_CLK    // Gated Clock signal
    );
    
    //internal connections since I'm implementing Latch-based Clock Gating
    reg     Latch_Out;
    
    //latch (Level Sensitive Device)
    always @(*) begin
    
    // active low
    // This is a latch since there is no else
    if(!CLK) begin
            
            // Output of Latch is CLK_EN
            Latch_Out <= CLK_EN ;
        end
    end
    
    // ANDING
    assign  GATED_CLK = CLK & Latch_Out;
endmodule
