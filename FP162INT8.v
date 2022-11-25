`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/11/18 13:36:51
// Design Name: 
// Module Name: FP162INT8
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module FP162INT8(
    input data_i,
    input rst,
    input clk,
    input input_valid,
    output data_o,
    output output_update

    );
    
    wire [15:0]data_i;
    wire rst;
    wire clk;
    wire input_valid;
    reg [7:0]data_o;
    reg output_update;
    
    reg sign1;              //for step1:pre_opration
    reg [7:0]rmcache1;
    reg ifround;
    reg overflow1;
    reg zero1;
    reg pre_over;
    reg sign2;              //for step2:round to nearest even
    reg [7:0]rmcache2;
    reg overflow2;
    reg zero2;
    reg round_over;
    reg sign3;              //for step3:overflow and carry
    reg [7:0]rmcache3;
    reg overflow3;
    reg zero3;
    reg carry_over;
    
    always@(posedge clk or posedge rst) begin           //step1:pre_operation
        if(rst) begin
            pre_over <= 1'b0;
            sign1 <= 1'b0;
            rmcache1 <= 8'd0;
            ifround <= 1'b0;
            overflow1 <= 1'b0;
            zero1 <= 1'b0;
        end
        else if(input_valid)    begin
            pre_over <= 1'b1;
            sign1 <= data_i[15];
            case(data_i[14:10])
                5'd21 : begin
                    rmcache1 <= {1'b1,data_i[9:4]};
                    ifround <= data_i[3] & (data_i[4] | (|data_i[2:0]));
                    overflow1 <= 1'b0;
                    zero1 <= 1'b0;
                end
                5'd20 : begin
                    rmcache1 <= {2'd1,data_i[9:5]};
                    ifround <= data_i[4] & (data_i[5] | (|data_i[3:0]));
                    overflow1 <= 1'b0;
                    zero1 <= 1'b0;
                end
                5'd19 : begin
                    rmcache1 <= {3'd1,data_i[9:6]};
                    ifround <= data_i[5] & (data_i[6] | (|data_i[4:0]));
                    overflow1 <= 1'b0;
                    zero1 <= 1'b0;
                end
                5'd18 : begin
                    rmcache1 <= {4'd1,data_i[9:7]};
                    ifround <= data_i[6] & (data_i[7] | (|data_i[5:0]));
                    overflow1 <= 1'b0;
                    zero1 <= 1'b0;
                end
                5'd17 : begin
                    rmcache1 <= {5'd1,data_i[9:8]};
                    ifround <= data_i[7] & (data_i[8] | (|data_i[6:0]));
                    overflow1 <= 1'b0;
                    zero1 <= 1'b0;
                end
                5'd16 : begin
                    rmcache1 <= {6'd1,data_i[9]};
                    ifround <= data_i[8] & (data_i[9] | (|data_i[7:0]));
                    overflow1 <= 1'b0;
                    zero1 <= 1'b0;
                end
                5'd15 : begin
                    rmcache1 <= 7'd1;
                    ifround <= data_i[9];
                    overflow1 <= 1'b0;
                    zero1 <= 1'b0;
                end
                5'd14 : begin
                    rmcache1 <= 7'd0;
                    ifround <= (|data_i[9:0]);
                    overflow1 <= 1'b0;
                    zero1 <= 1'b0;
                end
                default : begin
                    rmcache1 <= rmcache1;
                    ifround <= ifround;
                    if(data_i[14:10] > 21)  begin
                        overflow1 <= 1'b1;
                        zero1 <= 1'b0;
                    end
                    else    begin
                        overflow1 <= 1'b0;
                        zero1 <= 1'b1;
                    end
                end
            endcase
        end
        else    begin
            pre_over <= 1'b0;
            rmcache1 <= rmcache1;
            ifround <= ifround;
            overflow1 <= overflow1;
            zero1 <= zero1;
        end
    end
    
    always@(posedge clk or posedge rst) begin           //step2:round to nearest even
        if(rst) begin
            round_over <= 1'b0;
            sign2 <= 1'b0;
            rmcache2 <= 8'd0;
            overflow2 <= 1'b0;
            zero2 <= 1'b0;
        end
        else if(pre_over)   begin
            round_over <= 1'b1;
            sign2 <= sign1;
            overflow2 <= overflow1;
            zero2 <= zero1;
            if(~(overflow1 || zero1))   begin
                rmcache2 <= ifround ? rmcache1 + 8'd1 : rmcache1;
            end
            else    begin
                rmcache2 <= rmcache2;
            end
        end
        else    begin
            round_over <= 1'b0;
            sign2 <= sign2;
            overflow2 <= overflow2;
            zero2 <= zero2;
            rmcache2 <= rmcache2;
        end
    end
    
    always@(posedge clk or posedge rst) begin           //step3:overflow and carry
        if(rst) begin
            carry_over <= 1'b0;
            sign3 <= 1'b0;
            rmcache3 <= 8'd0;
            overflow3 <= 1'b0;
            zero3 <= 1'b0;
        end
        else if(round_over) begin
            carry_over <= 1'b1;
            sign3 <= sign2;
            zero3 <= zero2;
            if(~(overflow2 | zero2))    begin
                if(rmcache2[8]) begin
                    overflow3 <= 1'b1;
                    rmcache3 <= rmcache3;
                end
                else    begin
                    overflow3 <= 1'b0;
                    rmcache3 <= rmcache2;
                end
            end
            else    begin
                overflow3 <= overflow2;
                rmcache3 <= rmcache3;
            end               
        end
        else    begin
            carry_over <= 1'b0;
            sign3 <= sign3;
            zero3 <= zero3;
            overflow3 <= overflow3;
            rmcache3 <= rmcache3;
        end
    end
    
    always@(posedge clk or posedge rst) begin           //step4:result
        if(rst) begin
            data_o <= 8'd0;
            output_update <= 1'b0;
        end
        else if(carry_over) begin
            output_update <= 1'b1;
            case({overflow3,zero3})
                2'b10 : data_o <= 8'b1111_1111;
                2'b01 : data_o <= 8'b0000_0000;
                2'b00 : data_o <= {sign3,rmcache3[6:0]};
                default : data_o <= 8'd0;
            endcase
        end
        else    begin
            output_update <= 1'b0;
            data_o <= data_o;
        end
    end
    
endmodule
