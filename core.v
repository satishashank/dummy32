module core (input clk,
             input rst_n,
             input [31:0] mem_read,
             output [31:0] mem_addr,
             input mem_busy);
    
    reg [31:0] registerFile [31:0];
    
    reg [31:0] pc;
    wire [31:0] pcplus4;
    assign pcplus4 = pc + 4;
    
    reg [31:0] instr;
    reg [31:0] rs1;
    reg [31:0] rs2;
    reg [31:0] rd;
    
    reg [1:0] state; // 4 states
    wire [2:0] funct3 = instr[14:12];
    wire [4:0] shift  = rs2[4:0];
    
    assign mem_addr      = (state == 0) ? pc : 0;
    wire [31:0] aluAdd   = rs1 + rs2;
    wire [32:0] aluMinus = rs1 - rs2;
    wire lt              = rs1[31]^rs2[31] ? rs1[31] : aluMinus[32];
    wire ltu             = aluMinus[32];
    wire eq              = (aluMinus == 0);
    wire [31:0] aluOut = 
    ((funct3 == 3'b000) ? instr[30] & instr[5] ? aluMinus[31:0] : aluAdd : 32'b0) |
    ((funct3 == 3'b001) ? rs1<<shift      : 32'b0) |
    ((funct3 == 3'b010) ? {31'b0, lt}     : 32'b0) |
    ((funct3 == 3'b011) ? {31'b0, ltu}    : 32'b0) |
    ((funct3 == 3'b100) ? rs1 ^ rs2 : 32'b0) |
    ((funct3 == 3'b101) ? rs2>>shift      : 32'b0) |
    ((funct3 == 3'b110) ? rs1 | rs2 : 32'b0) |
    ((funct3 == 3'b111) ? rs1 & rs2 : 32'b0) ;
    
    // FSM for handling states
    always @(posedge clk) begin
        if (!rst_n) begin
            state <= 0;
            pc    <= 0;
        end
        else begin
            case (state)
                2'b00: begin
                    if (!mem_busy) begin
                        instr <= mem_read; // Fetch instruction
                        state <= 2'b01;    // Move to the next state
                    end
                end
                2'b01: begin
                    rs1   <= registerFile[instr[19:15]]; // Decode rs1
                    rs2   <= registerFile[instr[24:20]]; // Decode rs2
                    state <= 2'b10; // Move to the execute state
                end
                2'b10: begin
                    rd    <= aluOut;
                    state <= 2'b11; // Move to write-back state
                end
                2'b11: begin
                    registerFile[instr[11:7]] <= rd; // Write back to destination register
                    pc                        <= pcplus4; // Increment PC
                    state                     <= 2'b00; // Go back to fetch state
                end
                default: state <= 2'b00; // Default to fetch state
            endcase
        end
    end
    initial begin
        $readmemh("data.txt",registerFile);
    end
    
endmodule
