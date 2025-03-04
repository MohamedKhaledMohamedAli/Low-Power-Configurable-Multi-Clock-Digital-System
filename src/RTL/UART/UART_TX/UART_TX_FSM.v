module UART_TX_FSM (
        input   wire         CLK, RST,
        input   wire         PAR_EN, DATA_VALID, Serial_done,
        output  reg          Busy, Serial_EN, Parity_EN,
        output  reg  [1:0]   MUX_sel
    );

    // States of FSM
    localparam [2:0]    IDLE              = 3'b000,
                        START_BIT         = 3'b001,
                        DATA_TRANSMISSION = 3'b011,
                        PARITY_BIT        = 3'b111,
                        STOP_BIT          = 3'b110;

    reg [2 : 0] curr_state, next_state;

    always @(posedge CLK or negedge RST) begin
        if(!RST) begin
            curr_state <= IDLE;
        end
        else begin
            curr_state <= next_state;
        end
    end

    always @(*) begin

        // default values
        Serial_EN = 1'b0;
        Parity_EN = 1'b0;
        Busy = 1'b0;
        MUX_sel = 2'b00;
        
        case (curr_state)
            IDLE: begin

                // next state
                if(DATA_VALID) begin
                    next_state = START_BIT;
                end
                else begin
                    next_state = IDLE;
                end

                // Outputs
                Busy = 1'b0;
                MUX_sel = 2'b00;

                if(DATA_VALID) begin
                    Serial_EN = 1'b1;
                    Parity_EN = 1'b1;
                end
                else begin
                    Serial_EN = 1'b0;
                    Parity_EN = 1'b0;
                end

            end
            START_BIT: begin

                // next state
                next_state = DATA_TRANSMISSION;

                // Outputs                
                Serial_EN = 1'b0;
                Parity_EN = 1'b0;
                Busy = 1'b1;
                MUX_sel = 2'b01;
    
            end
            DATA_TRANSMISSION: begin
                
                // next state
                if(Serial_done && PAR_EN) begin
                    next_state = PARITY_BIT;
                end
                else if (Serial_done && !PAR_EN) begin
                    next_state = STOP_BIT;
                end
                else begin
                    next_state = DATA_TRANSMISSION;
                end

                // Outputs
                Serial_EN = 1'b0;
                Parity_EN = 1'b0;
                Busy = 1'b1;
                MUX_sel = 2'b10;

            end
            PARITY_BIT: begin

                // next state
                next_state = STOP_BIT;

                // Outputs                
                Serial_EN = 1'b0;
                Parity_EN = 1'b0;
                Busy = 1'b1;
                MUX_sel = 2'b11;

            end
            STOP_BIT: begin
                
                // next state
                if(DATA_VALID) begin
                    next_state = START_BIT;
                end
                else begin
                    next_state = IDLE;
                end

                // Outputs
                Busy = 1'b0;
                MUX_sel = 2'b00;

                if(DATA_VALID) begin
                    Serial_EN = 1'b1;
                    Parity_EN = 1'b1;
                end
                else begin
                    Serial_EN = 1'b0;
                    Parity_EN = 1'b0;
                end

            end
            default: begin
                
                // next state
                next_state = IDLE;

                // Outputs                
                Serial_EN = 1'b0;
                Parity_EN = 1'b0;
                Busy = 1'b0;
                MUX_sel = 2'b00;

            end


        endcase
        
    end
    
endmodule
