module ClkDiv #(
        parameter DIV_WIDTH = 8
    ) (
        input   wire                    I_ref_clk, I_rst_n, I_clk_en,
        input   wire  [DIV_WIDTH-1:0]   I_div_ratio,
        output  reg                     O_div_clk
    );

    // Internal register to count
    reg [DIV_WIDTH-1:0] count;

    // Internal register used to control at which half period I will change
    reg                 second_half_period;
    reg                 O_div_clk_reg;

    // Internal wires
    wire                       odd;             // Used to determine whether we will divide by an odd number or not
    wire    [DIV_WIDTH-1:0]    half;            // Used to determine the end of high signal in divided clock in even ratio
    wire    [DIV_WIDTH-1:0]    half_plus_one;   // Used to determine the end of high signal in divided clock in odd ratio

    // Determine whether we will divide by an odd number or not
    assign odd = I_div_ratio[0];

    /*  Determine the end of high signal in divided clock:
        by dividing divid ratio by 2 we can determine half of the cycle of desired divided clock */ 
    assign half = (I_div_ratio >> 1'b1) - 1'b1;

    assign half_plus_one = I_div_ratio >> 1'b1;
    
    always @(posedge I_ref_clk or negedge I_rst_n) begin
        if(!I_rst_n) begin

            // Reset count register
            count <= 1'b0;

            // Reset register to change first half period only
            second_half_period <= 1'b0;

            // Reset Output
            O_div_clk_reg <= 1'b0;
        end
        else if (I_clk_en && ( I_div_ratio != 1'b0) && ( I_div_ratio != 1'b1)) begin

            // Increment count register
            count <= count + 1'b1;
            
            // if Ratio is even
            if((count == half) && !odd) begin

                // Reset count register
                count <= 1'b0;

                // Toggle output clock
                O_div_clk_reg <= ~O_div_clk_reg;

            end

            // if we reached second half set the clock to zero is the ratio is even
            else if((((count == half) && second_half_period) || ((count == half_plus_one) && !second_half_period)) && odd) begin
                
                // Reset count register
                count <= 1'b0;

                // Toggle output
                O_div_clk_reg <= ~O_div_clk_reg;

                // Toggle register to change swap between half periods in each clock cycle
                second_half_period <= ~second_half_period;

            end

            else begin
                
                // Increment count register
                count <= count + 1'b1;

            end

        end
    end

    // Assign Output
    always @(*) begin
        if(( I_div_ratio == 1'b0) || ( I_div_ratio == 1'b1) || (!I_clk_en)) begin
            O_div_clk = I_ref_clk;
        end
        else begin
            O_div_clk = O_div_clk_reg;
        end
    end

endmodule
