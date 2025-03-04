module DATA_SYNC #(
        parameter BUS_WIDTH = 8,
        parameter NUM_STAGES = 2
    ) (
        input   wire                        CLK,
        input   wire                        RST,
        input   wire                        bus_enable,
        input   wire    [BUS_WIDTH-1:0]     unsync_bus,
        output  reg                         enable_pulse_d,
        output  reg     [BUS_WIDTH-1:0]     sync_bus
    );
    
    // Internal Registers
    reg [NUM_STAGES-1:0]    sync_reg;
    reg                     enable_flop;
    
    // Internal Wire
    wire mux_sel;
    
    // Assign internal wire
    assign mux_sel = (~enable_flop) & (sync_reg[NUM_STAGES - 'b1]);
    
    // Loop Variable
    integer i;
    
    always @(posedge CLK or negedge RST) begin
        
        if(!RST) begin
            
            // Clear Internal Register
            sync_reg <= 'b0;
            
            // Clear enable_flop
            enable_flop <= 'b0;
        end
        else begin
            
            // Like in bit synchronization but her it is only one bit so we don't need for loop
            sync_reg <= {sync_reg[NUM_STAGES - 'b10:0], bus_enable};
            
            // Assign enable_flop
            enable_flop <= sync_reg[NUM_STAGES - 'b1];
        end
    end
    
    // Assign enable signal
    always @(posedge CLK or negedge RST) begin
        
        if(!RST) begin
            
            // Clear enable signal
            enable_pulse_d <= 'b0;
            
            // Clear Output
            sync_bus <= 'b0;
        end
        else begin
            
            // Assign enable signal
            enable_pulse_d <= mux_sel;
            
            // Assign Output
            if(mux_sel) begin
                
                // take unsync bus
                sync_bus <= unsync_bus;
            end
            else begin
                
                // Store the same value (don't change it)
                sync_bus <= sync_bus;
            end
        end
    end
    
endmodule
