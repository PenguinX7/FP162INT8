`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/11/18 16:00:59
// Design Name: 
// Module Name: FP162INT8_tb
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


module FP162INT8_tb(

    );
    reg [15:0]data_i;
    reg clk;
    reg rst;
    reg input_valid;
    wire [7:0]data_o;
    wire output_update;
    
    always #5 clk = ~clk;
    
    initial begin
        clk  = 0;
        rst = 1;
        input_valid = 1;
        data_i = 16'h47af;   //7.6836;
        #20 rst = 0;
        #10 data_i = 16'h5bf0; //254,overflow;
        #10 data_i = 16'hb680; //-0.40625,zero;
        #10 data_i = 16'h3801; //0.5+
        #10 input_valid = 0;
        #40 rst = 1;
    end
    
    FP162INT8 U1 (
    .data_i(data_i),
    .clk(clk),
    .rst(rst),
    .input_valid(input_valid),
    .data_o(data_o),
    .output_update(output_update)
    );
endmodule
