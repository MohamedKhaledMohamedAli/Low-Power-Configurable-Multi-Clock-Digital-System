
/* 
1- This code we separate the sequential and combinational logic in different always block
2- All Outputs are assigned values in the same always block
*/

module ALU #(
        parameter OP_WIDTH = 8,
        parameter FUN_WIDTH = 4,
        parameter OUT_WIDTH = OP_WIDTH + OP_WIDTH
    ) (
        input   wire    [OP_WIDTH-1:0]      A, B,
        input   wire                        CLK, RST, Enable,
        input   wire    [FUN_WIDTH-1:0]     ALU_FUN,
        output  reg                         OUT_VALID,
        output  reg     [OUT_WIDTH-1:0]     ALU_OUT
    );

    // internal wire
    reg [OUT_WIDTH-1:0] ALU_OUT_wire;
    reg                 OUT_VALID_wire;
    
    // Combinational always block
    always @(*) begin
        
        // If enable
        if (Enable) begin
            
            // Set Valid default value
            OUT_VALID_wire = 'b1;
            
            case (ALU_FUN)

                // Addition
                4'b0000: begin
                    ALU_OUT_wire = A + B;
                end

                // Subtraction
                4'b0001: begin
                    ALU_OUT_wire = A - B;
                end

                // Multiplication
                4'b0010: begin
                    ALU_OUT_wire = A * B;
                end
                
                // Division
                4'b0011: begin
                    ALU_OUT_wire = A / B;
                end
                
                // AND
                4'b0100: begin
                    ALU_OUT_wire = A & B;
                end
                
                // OR
                4'b0101: begin
                    ALU_OUT_wire = A | B;
                end

                // NAND
                4'b0110: begin
                    ALU_OUT_wire = ~(A & B);
                end

                // NOR
                4'b0111: begin
                    ALU_OUT_wire = ~(A | B);
                end

                // XOR
                4'b1000: begin
                    ALU_OUT_wire = A ^ B;
                end

                // XNOR
                4'b1001: begin
                    ALU_OUT_wire = A ~^ B;
                end

                // A Equal B
                4'b1010: begin
                    ALU_OUT_wire = (A == B);
                end

                // A Greater Than B
                4'b1011: begin
                    ALU_OUT_wire = (A > B)?'b10:'b0;
                end

                // A Less Than B
                4'b1100: begin
                    ALU_OUT_wire = (A < B)?'b11:'b0;
                end

                4'b1101: begin
                    ALU_OUT_wire = A >> 1;
                end

                4'b1110: begin
                    ALU_OUT_wire = A << 1;
                end
                
                default: begin
                    ALU_OUT_wire = 16'b0;
                    
                    // Clear Valid since undefined operation
                    OUT_VALID_wire = 'b0;
                end
            endcase
        end
        else begin
            
            ALU_OUT_wire = 16'b0;
            
            // Clear Valid since undefined operation
            OUT_VALID_wire = 'b0;
        end
    end

    // Sequential always block
    always @(posedge CLK or negedge RST) begin

        // Clear output if RST signal is Low
        if(!RST) begin
            
            // Clear Output
            ALU_OUT <= 'b0;
            
            // Clear Valid
            OUT_VALID <= 'b0;
        end
        else begin
            
            // Set Output
            ALU_OUT <= ALU_OUT_wire;
            
            // Set Valid
            OUT_VALID <= OUT_VALID_wire;
        end
    end
endmodule
