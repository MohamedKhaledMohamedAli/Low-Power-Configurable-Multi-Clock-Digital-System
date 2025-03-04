module SYS_CTRL #(
        parameter ADDRESS_WIDTH = 4,
        parameter DATA_WIDTH = 8,
        parameter ALU_OUT_WIDTH = DATA_WIDTH + DATA_WIDTH,
        parameter FUN_WIDTH = 4
    ) (
        input   wire                            CLK,            // Clock Signal
        input   wire                            RST,            // Active Low Reset
        
        ////////////////////////// ALU //////////////////////////
        input   wire                            OUT_Valid,      // ALU Result Valid
        input   wire    [ALU_OUT_WIDTH-1:0]     ALU_OUT,        // ALU Result
        output  reg                             EN,             // ALU Enable signal
        output  reg     [FUN_WIDTH-1:0]         ALU_FUN,        // ALU Function signal
        
        //////////////////////// CLK_GATE ///////////////////////
        output  reg                             CLK_EN,         // Clock gate enable
        
        //////////////////////// RegFile ////////////////////////
        input   wire                            RdData_Valid,   // Read Data Valid
        input   wire    [DATA_WIDTH-1:0]        RdData,         // Read Data Bus
        output  reg                             WrEn,           // Write Enable
        output  reg                             RdEn,           // Read Enable
        output  reg     [DATA_WIDTH-1:0]        WrData,         // Write Data Bus
        output  reg     [ADDRESS_WIDTH-1:0]     Address,        // Address bus
        
        //////////////////////// UART_RX ////////////////////////
        input   wire                            RX_D_VLD,       // RX Data Valid
        input   wire    [DATA_WIDTH-1:0]        RX_P_DATA,      // UART_RX Data
        
        ////////////////////// ASYNC FIFO ///////////////////////
        input   wire                            FULL,           // FIFO Buffer full flag
        output  reg                             W_INC,          // Write operation enable
        output  reg     [DATA_WIDTH-1:0]        WR_DATA,        // Write Data Bus
        
        //////////////////////// CLKDiv /////////////////////////
        output  reg                             clk_div_en      // Clock divider enable 
    );
    /* Commands */
    localparam  [DATA_WIDTH-1:0]    RF_WR_CMD = 'hAA;           // Register File Write command
    localparam  [DATA_WIDTH-1:0]    RF_RD_CMD = 'hBB;           // Register File Read command
    localparam  [DATA_WIDTH-1:0]    ALU_OPER_W_OP_CMD = 'hCC;   // ALU Operation command with operand
    localparam  [DATA_WIDTH-1:0]    ALU_OPER_W_NOP_CMD = 'hDD;  // ALU Operation command with No operand
    
    /* Commands to be stored in command register */
    localparam [1:0]    COMMAND_WRITE = 'b00;               // Write command
    localparam [1:0]    COMMAND_READ = 'b01;                // Read command
    localparam [1:0]    COMMAND_ALU_W_OPERAND = 'b10;       // ALU command with operand
    localparam [1:0]    COMMAND_ALU_NO_OPERAND = 'b11;      // Read command without operand
    
    /*
        States:
            1) IDEAL: Wait for Valid Signal of UART_RX
            2) FIRST: Wait for first frame either read address(in case Read Command) or write address(in case Write Command) or data(in case ALU Command with operands(1st operand)) or ALU function(in case ALU no operand Command) from UART_RX
            3) SECOND: Wait for second frame either data(in case ALU Command with operands(2nd operand)) or write data(in case Write Command) from UART_RX
            4) THIRD: Wait for third frame ALU function (in case ALU Command with or without operands(get function of ALU)) from UART_RX
            5) WAIT: Wait for ALU to finish it's operation (in case of ALU with or without operands)
            6) SEND: Here we send least significant byte of ALU result first then we send most significant byte in DONE state
            7) DONE: Send final data to output 
    */
    localparam  [2:0]   IDEAL  = 'b000,
                        FIRST  = 'b001,
                        SECOND = 'b011,
                        THIRD  = 'b010,
                        WAIT   = 'b110,
                        SEND   = 'b111,
                        DONE   = 'b101;
    
    // Internal Register to store Address of Write
    reg [DATA_WIDTH-1:0]    temp_address_reg;   // Register to store the value from sequential always block during "Write command"
    reg [DATA_WIDTH-1:0]    temp_address_en;    // Wire that enables temp_address_reg register to store the address
    
    // Internal Register to store the which command we are in
    reg [1:0]   command;
    reg         command_en; // To enable when command register changes it's value
    
    // current state register and next state 
    reg [2:0]   curr_state, next_state;
    
    // Sequential Always for curr_state register
    always @(posedge CLK or negedge RST) begin
        
        // If Reset is Low make curr_state at IDEAL state
        if(!RST) begin
            
            // Make curr_state = IDEAL STATE
            // To Start from a known state
            curr_state <= IDEAL;
        end
        else begin // Else curr_state will be equal to next_state at clock edge
            
            // Make curr_state = next_state
            curr_state <= next_state;
        end
    end
    
    // Combinational Always block
    always @(*) begin
        
        /////////////////// Set default Values ///////////////////
        
        /* ALU */
        EN = 'b0;
        ALU_FUN = 'b0;
        
        /* Regfile */
        WrEn = 'b0;
        RdEn = 'b0;
        WrData = 'b0;
        Address = 'b0;
        temp_address_en = 'b0; // Internal wire for Regfile
        
        /* Clock Gating */
        CLK_EN = 'b0;
        
        /* ASYNC FIFO */
        W_INC = 'b0;
        WR_DATA = 'b0;
        
        /* Clock Divider */
        clk_div_en = 'b1;
        
        /* To control when command register changes it's value to store at which command we are in */
        command_en = 'b0;
        
        ///////////////////// Case Statement /////////////////////
        case (curr_state)
            
            IDEAL: begin
                
                /********************** next state logic **********************/
                /*
                    if valid signal of UART_RX is high go to next state (We have 2 next states):
                        1) FIRST state: if we are "Write command" or "Read command" or "ALU Operation command with operand"
                        2) THIRD state: if we are "ALU Operation command with No operand"
                */
                if(RX_D_VLD && ((RX_P_DATA == RF_WR_CMD) || (RX_P_DATA == RF_RD_CMD) || (RX_P_DATA == ALU_OPER_W_OP_CMD))) begin
                    
                    // Go to next state ---> FIRST state: during "Write command" or "Read command" or "ALU Operation command with operand"
                    next_state = FIRST;
                end
                else if(RX_D_VLD && (RX_P_DATA == ALU_OPER_W_NOP_CMD)) begin
                    
                    // Go to next state ---> THIRD state: during "ALU Operation command with No operand"
                    next_state = THIRD;
                end
                else begin // else stay in the same state
                    
                    // Remain in the same state
                    next_state = IDEAL; 
                end
                
                /************************ output logic ************************/
                // Make command register changes it's value to store current command
                command_en = 'b1;
                
                // If we are "ALU Operation command with No operand" we will need to enable clock gating of ALU
                if(RX_D_VLD && (RX_P_DATA == ALU_OPER_W_NOP_CMD)) begin
                    
                    // Enable Clock gating
                    CLK_EN = 'b1;
                end
                else begin // else don't enable clock gating
                    
                    // Don't enable Clock gating
                    CLK_EN = 'b0;
                end
            end
            FIRST: begin
                
                /********************** next state logic **********************/
                /*
                    if valid signal of UART_RX is high go to next state (We have 2 next states):
                        1) SECOND state: if we are "Write command" or "ALU Operation command with operand"
                        2) DONE state: if we are "Read command"
                */
                if(RX_D_VLD && ((command == COMMAND_WRITE) || (command == COMMAND_ALU_W_OPERAND))) begin
                    
                    // Go to next state ---> SECOND state: during "Write command" or "ALU Operation command with operand"
                    next_state = SECOND;
                end
                else if(RX_D_VLD && (command == COMMAND_READ)) begin
                    
                    // Go to next state ---> DONE state: during "Read command"
                    next_state = DONE;
                end
                else begin // else stay in the same state
                    
                    // Remain in the same state
                    next_state = FIRST; 
                end
                
                /************************ output logic ************************/
                // If data is valid
                if(RX_D_VLD) begin
                    
                    case (command)
                        COMMAND_WRITE: begin // if "Write command" store the write address
                            
                            // Enable register to store write address
                            temp_address_en = 'b1;
                        end
                        COMMAND_READ: begin // if we are "Read command" send address to register file and read from register file
                            
                            // Enable Read from register file
                            RdEn = 'b1;
                            
                            // Send address to register file
                            Address = RX_P_DATA;
                        end
                        COMMAND_ALU_W_OPERAND: begin // if we are "ALU Operation command with operand" Store First operand of ALU in Address 0x0
                            
                            // Enable Write in Register file
                            WrEn = 'b1;
                            
                            // Send address to Register file
                            Address = 'b0;
                            
                            // Send data
                            WrData = RX_P_DATA;
                        end
                        default: begin // Don't enable any thing
                            
                            // Disable write and read in Register file
                            WrEn = 'b0;
                            RdEn = 'b0;
                        end
                    endcase
                end
                else begin // clear all signals that may change inside case statement to avoid latches
                    
                    // Disable write and read in Register file
                    WrEn = 'b0;
                    RdEn = 'b0;
                    
                    // Clear Address
                    Address = 'b0;
                    
                    // Clear Data
                    WrData = 'b0;
                    
                    // Disable register to store write address
                    temp_address_en = 'b0;
                end
            end
            SECOND: begin
                
                /********************** next state logic **********************/
                /*
                    if valid signal of UART_RX is high go to next state (We have 2 next states):
                        1) THIRD state: if we are "ALU Operation command with operand"
                        2) IDEAL state: if we are "Write command"
                */
                if(RX_D_VLD && (command == COMMAND_ALU_W_OPERAND)) begin
                    
                    // Go to next state ---> THIRD state: during "ALU Operation command with operand"
                    next_state = THIRD;
                end
                else if(RX_D_VLD && ((command == COMMAND_WRITE))) begin
                    
                    // Go to next state ---> IDEAL state: during "Write command"
                    next_state = IDEAL;
                end
                else begin // else stay in the same state
                    
                    // Remain in the same state
                    next_state = SECOND; 
                end
                
                /************************ output logic ************************/
                // If data is valid
                if(RX_D_VLD) begin
                    
                    case (command)
                        COMMAND_WRITE: begin // if "Write command" store the data now in the register file
                            
                            // Enable Write in Register file
                            WrEn = 'b1;
                            
                            // Send address to Register file
                            Address = temp_address_reg;
                            
                            // Send data
                            WrData = RX_P_DATA;
                        end
                        COMMAND_ALU_W_OPERAND: begin // if we are "ALU Operation command with operand" we will enable clock gating and will store Second operand of ALU in Address 0x1
                            
                            // Enable Clock gating
                            CLK_EN = 'b1;
                            
                            // Enable Write in Register file
                            WrEn = 'b1;
                            
                            // Send address to Register file
                            Address = 'b1;
                            
                            // Send data
                            WrData = RX_P_DATA;
                        end
                        default: begin // Don't enable any thing
                            
                            // Disable write in Register file
                            WrEn = 'b0;
                        end
                    endcase
                end
                else begin // clear all signals that may change inside case statement to avoid latches
                    
                    // Disable write in Register file
                    WrEn = 'b0;
                    
                    // Clear Address
                    Address = 'b0;
                    
                    // Clear data
                    WrData = 'b0;
                    
                    // Disable Clock gating
                    CLK_EN = 'b0;
                end
            end
            THIRD: begin
                
                /********************** next state logic **********************/
                // if valid signal of UART_RX is high go to next state
                if(RX_D_VLD) begin
                    
                    // Go to next state ---> WAIT state
                    next_state = WAIT;
                end
                else begin // else stay in the same state
                    
                    // Remain in the same state
                    next_state = THIRD; 
                end
                
                /************************ output logic ************************/
                // Leave Clock gating enabled
                CLK_EN = 'b1;
                
                // If data is valid we will send ALU_FUN (Function that the ALU will perform) to the ALU
                if(RX_D_VLD) begin
                    
                    // Enable ALU
                    EN = 'b1;
                    
                    // Send ALU function
                    ALU_FUN = RX_P_DATA;
                end
                else begin // clear all signals that may change inside case statement to avoid latches
                    
                    // Disable ALU
                    EN = 'b0;
                    
                    // Send Zeros to ALU_FUN
                    ALU_FUN = 'b0;
                end
            end
            WAIT: begin
                
                /********************** next state logic **********************/
                // if valid signal of ALU is high go to next state
                if(OUT_Valid) begin
                    
                    // Go to next state ---> SEND state
                    next_state = SEND;
                end
                else begin // else stay in the same state
                    
                    // Remain in the same state
                    next_state = WAIT; 
                end
                
                /************************ output logic ************************/
                // Leave Clock gating enabled
                CLK_EN = 'b1;
                
                // Leave Send ALU function
                ALU_FUN = RX_P_DATA;
                
                // Leave ALU enabled
                EN = 'b1;
            end
            SEND: begin
                
                /********************** next state logic **********************/
                // if FIFO is not Full go to next state
                if(!FULL) begin
                    
                    // Go to next state ---> DONE state
                    next_state = DONE;
                end
                else begin // else stay in the same state
                    
                    // Remain in the same state
                    next_state = SEND;
                end
                
                /************************ output logic ************************/
                // if FIFO is not Full send least significant byte to FIFO
                if(!FULL) begin
                    
                    // Send least significant byte of ALU output to FIFO
                    WR_DATA = ALU_OUT[DATA_WIDTH-1:0];
                    
                    // enable write in FIFO
                    W_INC = 'b1;
                end
                else begin // else Clear all outputs
                    
                    // disable write in FIFO
                    W_INC = 'b0;
                    
                    // Send zeros to FIFO
                    WR_DATA = 'b0;
                end
            end
            DONE: begin
                
                /********************** next state logic **********************/
                // if FIFO is not Full go to next state
                if(!FULL) begin
                    
                    // Go to next state ---> IDEAL state
                    next_state = IDEAL;
                end
                else begin // else stay in the same state
                    
                    // Remain in the same state
                    next_state = DONE;
                end
                
                /************************ output logic ************************/
                // if FIFO is not Full and we are "Read command" and valid of register file is high we will send data to FIFO
                if(!FULL && (command == COMMAND_READ) && RdData_Valid) begin
                    
                    // Send Read data from register file to FIFO
                    WR_DATA = RdData;
                    
                    // enable write in FIFO
                    W_INC = 'b1;
                end
                else if(!FULL && ((command == COMMAND_ALU_W_OPERAND) || (command == COMMAND_ALU_NO_OPERAND))) begin // else if FIFO is not Full and we are in ALU operation we will send most significant byte
                    
                    // Send most significant byte of ALU output to FIFO
                    WR_DATA = ALU_OUT[ALU_OUT_WIDTH-1:DATA_WIDTH];
                    
                    // enable write in FIFO
                    W_INC = 'b1;
                end
                else begin // else Clear all outputs
                    
                    // disable write in FIFO
                    W_INC = 'b0;
                    
                    // Send zeros to FIFO
                    WR_DATA = 'b0;
                end
            end
            default: begin
                
                // Return to IDEAL state (Known state)
                next_state = IDEAL;
            end
        endcase
    end
    
    // Sequential Always block for temp_address_register that stores the address of "Write command" or "Read command" till data is received to write in register file
    always @(posedge CLK or negedge RST) begin
        
        // if reset is low clear the register
        if(!RST) begin
            
            // Reset temp_address_reg register
            temp_address_reg <= 'b0;
        end
        else if(temp_address_en) begin // else if enable was high store the address of write operation in register
            
            // Store Value of Address when enable is high 
            temp_address_reg <= RX_P_DATA;
        end
    end
    
    // Sequential Always block to store which command we are in
    always @(posedge CLK or negedge RST) begin
        
        // if reset is low clear the register
        if(!RST) begin
            
            // Make register store value of "Write command" as default
            command <= 'b00;
        end
        else if (command_en && RX_D_VLD) begin
            
            /*
                Commands to store:
                    1- COMMAND_WRITE ('b00) ---> "Write command"
                    2- COMMAND_READ ('b01) ---> "Read command"
                    3- COMMAND_ALU_W_OPERAND ('b10) ---> "ALU Operation command with operand"
                    4- COMMAND_ALU_NO_OPERAND ('b11) ---> "ALU Operation command with No operand"
            */
            case (RX_P_DATA)
                RF_WR_CMD: begin
                    
                    // "Write command" therefore will store COMMAND_WRITE ('b00)
                    command <= COMMAND_WRITE;
                end
                RF_RD_CMD: begin
                    
                    // "Read Command" therefore will store COMMAND_READ ('b01)
                    command <= COMMAND_READ;
                end
                ALU_OPER_W_OP_CMD: begin
                    
                    // "ALU Operation command with operand" therefore will store COMMAND_ALU_W_OPERAND ('b10)
                    command <= COMMAND_ALU_W_OPERAND;
                end
                ALU_OPER_W_NOP_CMD: begin
                    
                    // "ALU Operation command with No operand" therefore will store COMMAND_ALU_NO_OPERAND ('b11)
                    command <= COMMAND_ALU_NO_OPERAND;
                end
            endcase
        end
    end
endmodule
