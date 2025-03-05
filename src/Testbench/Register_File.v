module Register_File # (
        parameter ADDR_WIDTH = 4,
        parameter NO_OF_REGISTER = 2**ADDR_WIDTH,
        parameter REGISTER_DATA_WIDTH = 8
    )(
        input  wire                             CLK,            // Clock Signal
        input  wire                             RST,            // Active Low Reset
        input  wire  [ADDR_WIDTH-1:0]           Address,        // Address bus
        input  wire                             WrEn,           // Write Enable
        input  wire                             RdEn,           // Read Enable
        input  wire  [REGISTER_DATA_WIDTH-1:0]  WrData,         // Write Data Bus 
        output reg   [REGISTER_DATA_WIDTH-1:0]  RdData,         // Read Data Bus
        output reg                              RdData_Valid,   // Read Data Valid
        output wire  [REGISTER_DATA_WIDTH-1:0]  REG0,           // Register at Address 0x0
        output wire  [REGISTER_DATA_WIDTH-1:0]  REG1,           // Register at Address 0x1
        output wire  [REGISTER_DATA_WIDTH-1:0]  REG2,           // Register at Address 0x2
        output wire  [REGISTER_DATA_WIDTH-1:0]  REG3            // Register at Address 0x3
    );
    
    // Register File
    reg [REGISTER_DATA_WIDTH-1:0] memory [0:NO_OF_REGISTER-1];
    
    // Loop Variable
    integer i;
    
    // Sequential Block
    always @(posedge CLK or negedge RST) begin
        if (!RST) begin
            
            // For Loop to Clear Register File
            for (i = 0;i < NO_OF_REGISTER;i = i + 1) begin
                
                // if i=2 ---> we will set default Prescale = 32 for UART and enable parity bit since this is default
                if(i == 2) begin
                    
                    // Set default Prescale = 32 and enable parity since this is default
                    memory[i] <= 'b100000_01;
                end
                
                // Else if i=3 ----> we will set default Division Ratio which is 32
                else if (i == 3) begin
                    
                    // Set default Divide Ratio to 32
                    memory[i] <= 'b0010_0000;
                end
                else begin
                    
                    // Clear Register File
                    memory[i] <= 'b0;
                end
            end
            
            // Clear Read data
            RdData <= 0;
            
            // Clear Read Valid
            RdData_Valid <= 'b0;
        end
        else begin
            
            // Clear Read Valid
            RdData_Valid <= 'b0;
            
            case ({WrEn, RdEn})
                
                // Read Operation
                2'b01: begin
                    RdData <= memory[Address];
                    
                    // Set Read Valid
                    RdData_Valid <= 'b1;
                end
                
                // Write Operation
                2'b10: begin
                    memory[Address] <= WrData;
                    RdData <= 'b0;
                end
                
                default: begin
                    RdData <= 'b0;
                    memory[Address] <= memory[Address];
                end
            endcase
        end
    end
    
    // Assign Address 0x0 to REG0
    assign REG0 = memory[0];
    
    // Assign Address 0x1 to REG1
    assign REG1 = memory[1];
    
    // Assign Address 0x2 to REG2
    assign REG2 = memory[2];
    
    // Assign Address 0x3 to REG3
    assign REG3 = memory[3];
endmodule