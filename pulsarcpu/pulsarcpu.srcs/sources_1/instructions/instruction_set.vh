//INSTRUCTION PART DEFINITIONS
`define OPCODE 6:0
`define RD 11:7
`define FUNC3 14:12
`define RS1 19:15
`define RS2 24:20
`define FUNC7 31:25
`define SUBTYPE 30

localparam [31:0] NOP = 32'h00000013;

//OPCODE PATTERNS
localparam [6:0] ALI = 7'b0010011,
                 ALR = 7'b0110011,
                 STORE = 7'b0100011, 
                 LOAD = 7'b0000011,
                 BRANCH = 7'b1100011, 
                 JMPR = 7'b1100111, 
                 JMP = 7'b1101111,
                 LUI = 7'b0110111;

// FUNC3 PATTERNS FOR B-TYPES, INST[14:12], INST[6:0] = 7'b1100011
localparam  [ 2: 0] BEQ     = 3'b000,
                    BNE     = 3'b001,
                    BLT     = 3'b100,
                    BGE     = 3'b101,
                    BLTU    = 3'b110,
                    BGEU    = 3'b111;

// FUNC3 PATTERNS FOR S-TYPES(LOAD), INST[14:12], INST[6:0] = 7'b0000011
localparam  [ 2: 0] LB      = 3'b000,
                    LH      = 3'b001,
                    LW      = 3'b010,
                    LBU     = 3'b100,
                    LHU     = 3'b101;

// FUNC3 PATTERNS FOR S-TYPES(STORE), INST[14:12], INST[6:0] = 7'b0100011
localparam  [ 2: 0] SB      = 3'b000,
                    SH      = 3'b001,
                    SW      = 3'b010;
                    
// FUNC3 PATTERNS FOR I-TYPES AND R-TYPES, INST[14:12], INST[6:0] = 7'b0110011, 7'b0010011
localparam  [ 2: 0] ADD     = 3'b000,    // inst[30] == 0: ADD, inst[31] == 1: SUB
                    SLL     = 3'b001,
                    SLT     = 3'b010,
                    SLTU    = 3'b011,
                    XOR     = 3'b100,
                    SR      = 3'b101,    // inst[30] == 0: SRL, inst[31] == 1: SRA
                    OR      = 3'b110,
                    AND     = 3'b111;
                    
                    
//---------------------------RV32M-----------------------------//
//RV32M EXTENSION PACK FUNC7 PREFIX
localparam[6:0]     RV32M   = 7'b0000001;
//FUNC3 PATTERNS FOR R-TYPED MULTIPLICATION/DIVISION INSTRUCTIONS
localparam [2:0]    MUL     = 3'b000,
                    MULH    = 3'b001,
                    MULHSU  = 3'b010,
                    MULHU   = 3'b011,
                    DIV     = 3'b100,
                    DIVU    = 3'b101,
                    REM     = 3'b110,
                    REMU    = 3'b111;
//---------------------------------------------------------------//

