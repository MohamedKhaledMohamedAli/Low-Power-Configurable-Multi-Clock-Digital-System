module ASYC_FIFO #(
        parameter   DATA_WIDTH = 8,
        parameter   ADDR_WIDTH = 3,
        parameter   MEM_DEPTH = 2**ADDR_WIDTH
    ) (
        input   wire                        W_CLK,      // Source domain clock
        input   wire                        W_RST,      // Source domain Async reset
        input   wire                        W_INC,      // Write operation enable
        input   wire                        R_CLK,      // Destination domain clock
        input   wire                        R_RST,      // Destination domain Async reset
        input   wire                        R_INC,      // Read operation enable
        input   wire    [DATA_WIDTH-1:0]    WR_DATA,    // Write Data Bus
        output  wire    [DATA_WIDTH-1:0]    RD_DATA,    // Read Data Bus
        output  wire                        FULL,       // FIFO Buffer full flag
        output  wire                        EMPTY       // FIFO Buffer empty flag
    );
    
    // Internal Wires
    wire                        W_CLK_EN;   // Source domain enable for FIFO_memory
    wire                        W_FULL;     // To indicate if FIFO_memory is Full or not
    wire    [ADDR_WIDTH:0]      W_ADDR;     // Write operation Address
    wire    [ADDR_WIDTH:0]      W_PTR;      // To Send Write Address to  Destination Domain (Read Domain) in Gray Encoding
    wire    [ADDR_WIDTH:0]      W_PTR_SYNC; // Source Domain Address (Write Address) Synchronized to Destination Domain (Read Domain)
    wire                        R_EMPTY;    // To indicate if FIFO_memory is Empty or not
    wire    [ADDR_WIDTH:0]      R_ADDR;     // Read operation Address
    wire    [ADDR_WIDTH:0]      R_PTR;       // To Send Read Address to  Source Domain (Write Domain) in Gray Encoding
    wire    [ADDR_WIDTH:0]      R_PTR_SYNC; // Destination Domain Address (Read Address) Synchronized to Source Domain (Write Domain)
    
    // Assign W_CLK_EN wire
    assign W_CLK_EN = W_INC & (!W_FULL);
    
    // Assign Full
    assign FULL = W_FULL;
    
    // Assign Empty
    assign EMPTY = R_EMPTY;
    
    ////////////////////////////////////////////////////////////////////
    ///////////////////////// Instantiations ///////////////////////////
    ////////////////////////////////////////////////////////////////////
    
    // Instantiate FIFO_MEM_CNTRL
    FIFO_MEM_CNTRL #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH), .MEM_DEPTH(MEM_DEPTH)) U0_FIFO_MEM_CNTRL (
        .W_CLK(W_CLK),                          // Source domain clock
        .W_RST(W_RST),                          // Source domain Async reset
        .W_CLK_EN(W_CLK_EN),                    // Source domain enable
        .W_ADDR(W_ADDR[ADDR_WIDTH-1:0]),        // Write operation Address
        .R_ADDR(R_ADDR[ADDR_WIDTH-1:0]),        // Read operation Address
        .W_DATA(WR_DATA),                       // Write Data Bus
        .R_DATA(RD_DATA)                        // Read Data Bus
    );
    
    // Instantiate DF_SYNC for Source Domain (Write Domain) 
    // i.e. From Read Domain to Write Domain
    DF_SYNC #(.BUS_WIDTH(ADDR_WIDTH + 'b1)) SYNC_R2W (
        .CLK(W_CLK),
        .RST(W_RST),
        .ASYNC(R_PTR),
        .SYNC(R_PTR_SYNC)
    );
    
    // Instantiate DF_SYNC for Destination Domain (Read Domain) 
    // i.e. From Write Domain to Read Domain
    DF_SYNC #(.BUS_WIDTH(ADDR_WIDTH + 'b1)) SYNC_W2R (
        .CLK(R_CLK),
        .RST(R_RST),
        .ASYNC(W_PTR),
        .SYNC(W_PTR_SYNC)
    );
    
    // Instantiate FIFO_WR
    FIFO_WR #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) U0_FIFO_WR (
        .W_CLK(W_CLK),              // Source domain clock
        .W_RST(W_RST),              // Source domain Async reset
        .W_INC(W_INC),              // Write operation enable
        .R_PTR_SYNC(R_PTR_SYNC),    // Destination Domain Address (Read Address) Synchronized to Source Domain (Write Domain)
        .W_FULL(W_FULL),            // To indicate if FIFO_memory is Full or not
        .W_ADDR(W_ADDR),            // Write operation Address
        .W_PTR(W_PTR)               // To Send Write Address to  Destination Domain (Read Domain) in Gray Encoding
    );
    
    // Instantiate FIFO_RD
    FIFO_RD #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) U0_FIFO_RD (
        .R_CLK(R_CLK),              // Destination domain clock
        .R_RST(R_RST),              // Destination domain Async reset
        .R_INC(R_INC),              // Read operation enable
        .W_PTR_SYNC(W_PTR_SYNC),    // Source Domain Address (Write Address) Synchronized to Destination Domain (Read Domain)
        .R_EMPTY(R_EMPTY),          // To indicate if FIFO_memory is Empty or not
        .R_ADDR(R_ADDR),            // Read operation Address
        .R_PTR(R_PTR)               // To Send Read Address to  Source Domain (Write Domain) in Gray Encoding
    );
endmodule