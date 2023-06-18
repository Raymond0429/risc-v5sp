/*
    做一个内存控制器, 控制4个8bit位宽的ram, 责任重大哟
    可用内存的总大小是2048, 映射到地址范围是0~2047
    外设总线寄存器的地址映射到
    pbus_addr - 65536, 可读可写
    pbus_wdata - 65540, 可读可写
    pbus_rdata - 65544, 只读
    对这些内存地址进行读写, 相当于在读写寄存器
    如果出现非法的地址, 即地址不在映射区域中, 则读取结果为0, 写入无效

    rstn 表示 rst 取非, 当 rstn == 0 或 clear_l3 == 1 时, 所有寄存器清零
*/


module DataRamCtrl (
    input  wire        clk,
    input  wire        rstn,
    input  wire        clear_l3,
    input  wire [31:0] alu_q_l2,      //访存地址
    input  wire [31:0] alu_b_l2,       //要写入内存的数据
    input  wire [31:0] pbus_rdata,    //从外设总线读取到的数据
    input  wire        ins_lb_l2,
    input  wire        ins_lh_l2,
    input  wire        ins_lw_l2,
    input  wire        ins_lbu_l2,
    input  wire        ins_lhu_l2,
    input  wire        ins_sb_l2,
    input  wire        ins_sh_l2,
    input  wire        ins_sw_l2,
    output reg  [31:0] ram_rdata_l3,
    output reg  [31:0] pbus_addr,     //外设总线地址, 尚不确定有多少外设, 位宽先按32处理
    output reg  [31:0] pbus_wdata     //要写入外设的数据

);

    parameter addr_width = 9;

    reg                     wea_0;
    reg                     wea_1;
    reg                     wea_2;
    reg                     wea_3;

    wire [addr_width - 1:0] addr_0;
    wire [addr_width - 1:0] addr_1;
    wire [addr_width - 1:0] addr_2;
    wire [addr_width - 1:0] addr_3;

    reg  [             7:0] din_0;
    reg  [             7:0] din_1;
    reg  [             7:0] din_2;
    reg  [             7:0] din_3;

    wire [             7:0] dout_0;
    wire [             7:0] dout_1;
    wire [             7:0] dout_2;
    wire [             7:0] dout_3;
	
	wire 					mem_en; //判断地址，只有在0-2047中才对mem进行读写操作
	
	assign mem_en = !(|alu_q_l2[31:11]); //对读写的mem地址进行判断，如果前21位中有1则地址大于2047，不在mem地址中，不对mem进行操作
	
	assign addr_0 = alu_q_l2[10:2];	//四字节对齐，每个ram存入地址相同
	assign addr_1 = alu_q_l2[10:2];
	assign addr_2 = alu_q_l2[10:2];
	assign addr_3 = alu_q_l2[10:2];
	
	always @(*) begin
		unique if (ins_sb_l2 & mem_en) begin	//sb指令存一个字节，用地址低两位判断存在哪个ram块中，其余块不写
			case(alu_q_l2[1:0])
				2'b00: begin
					{wea_3, wea_2, wea_1, wea_0} = 4'b0001;
					{din_3, din_2, din_1, din_0} = {24'd0, alu_b_l2[7:0]};
				end
				2'b01: begin
					{wea_3, wea_2, wea_1, wea_0} = 4'b0010;
					{din_3, din_2, din_1, din_0} = {16'd0, alu_b_l2[7:0],8'd0};
				end
				2'b10: begin
					{wea_3, wea_2, wea_1, wea_0} = 4'b0100;
					{din_3, din_2, din_1, din_0} = {8'd0, alu_b_l2[7:0],16'd0};
				end
				2'b11: begin
					{wea_3, wea_2, wea_1, wea_0} = 4'b1000;
					{din_3, din_2, din_1, din_0} = {alu_b_l2[7:0],24'd0};
				end
				default: begin
					{wea_3, wea_2, wea_1, wea_0} = 4'd0;
					{din_3, din_2, din_1, din_0} = 32'd0;
				end
			endcase
		end else if (ins_sh_l2 & mem_en) begin	//sh指令存一个半字，用地址低两位判断存在哪个ram块中，其余块不写
			case(alu_q_l2[1:0])
				2'b00: begin
					{wea_3, wea_2, wea_1, wea_0} = 4'b0011;
					{din_3, din_2, din_1, din_0} = {16'd0, alu_b_l2[15:0]};
				end
				2'b10: begin
					{wea_3, wea_2, wea_1, wea_0} = 4'b1100;
					{din_3, din_2, din_1, din_0} = {alu_b_l2[15:0], 16'd0};
				end
				default: begin
					{wea_3, wea_2, wea_1, wea_0} = 4'd0;
					{din_3, din_2, din_1, din_0} = 32'd0;
				end
			endcase
		end else if (ins_sw_l2 & mem_en) begin	//sw指令四个ram块都要写入
			{wea_3, wea_2, wea_1, wea_0} = 4'b1111;
			{din_3, din_2, din_1, din_0} = alu_b_l2;
		end else begin
			{wea_3, wea_2, wea_1, wea_0} = 4'd0;
			{din_3, din_2, din_1, din_0} = 32'd0;
		end
	end
	
	always @(*) begin
		unique if (ins_lhu_l2) begin
			unique if(mem_en) begin
				if (alu_q_l2[1:0] == 2'b00) begin //lhu指令，读取一个无符号的半字，用地址低两位判断取自的ram块，高16位补0
					ram_rdata_l3 = {16'd0, dout_1, dout_0};
				end else if (alu_q_l2[1:0] == 2'b10) begin
					ram_rdata_l3 = {16'd0, dout_3, dout_2};
				end else begin
					ram_rdata_l3 = 32'd0;
				end
			end
			else if(alu_q_l2 == 32'd65536) ram_rdata_l3 = {16'd0, pbus_addr[15:0]};
			else if(alu_q_l2 == 32'd65538) ram_rdata_l3 = {16'd0, pbus_addr[31:16]};
			else if(alu_q_l2 == 32'd65540) ram_rdata_l3 = {16'd0, pbus_wdata[15:0]};
			else if(alu_q_l2 == 32'd65542) ram_rdata_l3 = {16'd0, pbus_wdata[31:16]};
			else if(alu_q_l2 == 32'd65544) ram_rdata_l3 = {16'd0, pbus_rdata[15:0]};
			else if(alu_q_l2 == 32'd65546) ram_rdata_l3 = {16'd0, pbus_rdata[31:16]};
			else ram_rdata_l3 = 32'd0;

		end else if (ins_lbu_l2) begin								//lbu指令，读取一个无符号的字节，用地址低两位判断取自的ram块，高24位补0
			unique if(mem_en) begin
				unique if (alu_q_l2[1:0] == 2'b00) begin
			 		ram_rdata_l3 = {24'd0, dout_0};
			 	end else if (alu_q_l2[1:0] == 2'b01) begin
			 		ram_rdata_l3 = {24'd0, dout_1};
			 	end else if (alu_q_l2[1:0] == 2'b10) begin
			 		ram_rdata_l3 = {24'd0, dout_2};
			 	end else if (alu_q_l2[1:0] == 2'b11) begin
			 		ram_rdata_l3 = {24'd0, dout_3};
			 	end else begin
			 		ram_rdata_l3 = 32'd0;
			 	end
			end
			else if(alu_q_l2 == 32'd65536) ram_rdata_l3 = {24'd0, pbus_addr[7:0]};
			else if(alu_q_l2 == 32'd65537) ram_rdata_l3 = {24'd0, pbus_addr[15:8]};
			else if(alu_q_l2 == 32'd65538) ram_rdata_l3 = {24'd0, pbus_addr[23:16]};
			else if(alu_q_l2 == 32'd65539) ram_rdata_l3 = {24'd0, pbus_addr[31:24]};
			else if(alu_q_l2 == 32'd65540) ram_rdata_l3 = {24'd0, pbus_wdata[7:0]};
			else if(alu_q_l2 == 32'd65541) ram_rdata_l3 = {24'd0, pbus_wdata[15:8]};
			else if(alu_q_l2 == 32'd65542) ram_rdata_l3 = {24'd0, pbus_wdata[23:16]};
			else if(alu_q_l2 == 32'd65543) ram_rdata_l3 = {24'd0, pbus_wdata[31:24]};
			else if(alu_q_l2 == 32'd65544) ram_rdata_l3 = {24'd0, pbus_rdata[7:0]};
			else if(alu_q_l2 == 32'd65545) ram_rdata_l3 = {24'd0, pbus_rdata[15:8]};
			else if(alu_q_l2 == 32'd65546) ram_rdata_l3 = {24'd0, pbus_rdata[23:16]};
			else if(alu_q_l2 == 32'd65547) ram_rdata_l3 = {24'd0, pbus_rdata[31:24]};
			else ram_rdata_l3 = 32'd0;
		end else if (ins_lw_l2) begin								//lw指令，读取一个无符号的字
			unique if(mem_en) ram_rdata_l3 = {dout_3, dout_2, dout_1, dout_0};
			else if (alu_q_l2 == 32'd65536) ram_rdata_l3 = pbus_addr;
			else if (alu_q_l2 == 32'd65540) ram_rdata_l3 = pbus_wdata;
			else if (alu_q_l2 == 32'd65544) ram_rdata_l3 = pbus_rdata;
			else ram_rdata_l3 = 32'd0;
		end else if (ins_lh_l2) begin								//lh指令，读取一个有符号的半字，用地址低两位判断取自的ram块，高16位补符号位
			unique if (mem_en) begin
				if (alu_q_l2[1:0] == 2'b00) begin
					ram_rdata_l3 = {{16{dout_1[7]}}, dout_1, dout_0};
				end else if (alu_q_l2[1:0] == 2'b10) begin
					ram_rdata_l3 = {{16{dout_3[7]}}, dout_3, dout_2};
				end else begin
					ram_rdata_l3 = 32'd0;
				end
			end
			else if(alu_q_l2 == 32'd65536) ram_rdata_l3 = {{16{pbus_addr[15]}}, pbus_addr[15:0]};
			else if(alu_q_l2 == 32'd65538) ram_rdata_l3 = {{16{pbus_addr[31]}}, pbus_addr[31:16]};
			else if(alu_q_l2 == 32'd65540) ram_rdata_l3 = {{16{pbus_wdata[15]}}, pbus_wdata[15:0]};
			else if(alu_q_l2 == 32'd65542) ram_rdata_l3 = {{16{pbus_wdata[31]}}, pbus_wdata[31:16]};
			else if(alu_q_l2 == 32'd65544) ram_rdata_l3 = {{16{pbus_rdata[15]}}, pbus_rdata[15:0]};
			else if(alu_q_l2 == 32'd65546) ram_rdata_l3 = {{16{pbus_rdata[31]}}, pbus_rdata[31:16]};
			else ram_rdata_l3 = 32'd0;
		end else if (ins_lb_l2) begin								//lb指令，读取一个有符号的字节，用地址低两位判断取自的ram块，高24位补符号位
			unique if(mem_en) begin
				unique if (alu_q_l2[1:0] == 2'b00) begin
					ram_rdata_l3 = {{24{dout_0}}, dout_0};
				end else if (alu_q_l2[1:0] == 2'b01) begin
					ram_rdata_l3 = {{24{dout_1}}, dout_1};
				end else if (alu_q_l2[1:0] == 2'b10) begin
					ram_rdata_l3 = {{24{dout_2}}, dout_2};
				end else if (alu_q_l2[1:0] == 2'b11) begin
					ram_rdata_l3 = {{24{dout_3}}, dout_3};
				end else begin
					ram_rdata_l3 = 32'd0;
				end
			end
			else if(alu_q_l2 == 32'd65536) ram_rdata_l3 = {{24{pbus_addr[7 ]}}, pbus_addr[7:0]};
			else if(alu_q_l2 == 32'd65537) ram_rdata_l3 = {{24{pbus_addr[15]}}, pbus_addr[15:8]};
			else if(alu_q_l2 == 32'd65538) ram_rdata_l3 = {{24{pbus_addr[23]}}, pbus_addr[23:16]};
			else if(alu_q_l2 == 32'd65539) ram_rdata_l3 = {{24{pbus_addr[31]}}, pbus_addr[31:24]};
			else if(alu_q_l2 == 32'd65540) ram_rdata_l3 = {{24{pbus_wdata[7 ]}}, pbus_wdata[7:0]};
			else if(alu_q_l2 == 32'd65541) ram_rdata_l3 = {{24{pbus_wdata[15]}}, pbus_wdata[15:8]};
			else if(alu_q_l2 == 32'd65542) ram_rdata_l3 = {{24{pbus_wdata[23]}}, pbus_wdata[23:16]};
			else if(alu_q_l2 == 32'd65543) ram_rdata_l3 = {{24{pbus_wdata[31]}}, pbus_wdata[31:24]};
			else if(alu_q_l2 == 32'd65544) ram_rdata_l3 = {{24{pbus_rdata[7 ]}}, pbus_rdata[7:0]};
			else if(alu_q_l2 == 32'd65545) ram_rdata_l3 = {{24{pbus_rdata[15]}}, pbus_rdata[15:8]};
			else if(alu_q_l2 == 32'd65546) ram_rdata_l3 = {{24{pbus_rdata[23]}}, pbus_rdata[23:16]};
			else if(alu_q_l2 == 32'd65547) ram_rdata_l3 = {{24{pbus_rdata[31]}}, pbus_rdata[31:24]};
			else ram_rdata_l3 = 32'd0;
		end else ram_rdata_l3 = 32'd0;
	end

    //每个ram都是1字节为一个单元, 大小为512字节, 共4个ram, 这样一次访存刚好是32位
    //ram可以调用IP核, 不需要我们实现
    DataRam8Bit ram0 (
        clk,
        1'd1,
        wea_0,  //写使能
        addr_0,  //每个ram的大小是512字节, 故addr有9位
        din_0,  //要写入的数据
        dout_0  //读取出来的数据
    );
    DataRam8Bit ram1 (
        clk,
        1'd1,
        wea_1,
        addr_1,
        din_1,
        dout_1
    );
    DataRam8Bit ram2 (
        clk,
        1'd1,
        wea_2,
        addr_2,
        din_2,
        dout_2
    );
    DataRam8Bit ram3 (
        clk,
        1'd1,
        wea_3,
        addr_3,
        din_3,
        dout_3
    );


    // reg  [31:0] pbus_addr,     //外设总线地址, 尚不确定有多少外设, 位宽先按32处理
    // reg  [31:0] pbus_wdata     //要写入外设的数据
	// wire [31:0] pbus_rdata,    //从外设总线读取到的数据

	always_ff @( posedge clk ) begin
		if(!rstn || clear_l3) pbus_addr <= 32'd0;
		else if(ins_sw_l2 && alu_q_l2 == 32'd65536) pbus_addr <= alu_b_l2;
		else if(ins_sh_l2) begin
			if(alu_q_l2 == 32'd65536) pbus_addr[15:0] <= alu_b_l2[15:0];
			else if(alu_q_l2 == 32'd65538) pbus_addr[31:16] <= alu_b_l2[15:0];
		end else if(ins_sb_l2) begin
			if(alu_q_l2 == 32'd65536) pbus_addr[7:0] <= alu_b_l2[7:0];
			else if(alu_q_l2 == 32'd65537) pbus_addr[15:8] <= alu_b_l2[7:0];
			else if(alu_q_l2 == 32'd65538) pbus_addr[23:16] <= alu_b_l2[7:0];
			else if(alu_q_l2 == 32'd65539) pbus_addr[31:24] <= alu_b_l2[7:0];
		end
	end

	always_ff @( posedge clk ) begin
		if(!rstn || clear_l3) pbus_wdata <= 32'd0;
		else if(ins_sw_l2 && alu_q_l2 == 32'd65540) pbus_wdata <= alu_b_l2;
		else if(ins_sh_l2) begin
			if(alu_q_l2 == 32'd65540) pbus_wdata[15:0] <= alu_b_l2[15:0];
			else if(alu_q_l2 == 32'd65542) pbus_wdata[31:16] <= alu_b_l2[15:0];
		end else if(ins_sb_l2) begin
			if(alu_q_l2 == 32'd65540) pbus_wdata[7:0] <= alu_b_l2[7:0];
			else if(alu_q_l2 == 32'd65541) pbus_wdata[15:8] <= alu_b_l2[7:0];
			else if(alu_q_l2 == 32'd65542) pbus_wdata[23:16] <= alu_b_l2[7:0];
			else if(alu_q_l2 == 32'd65543) pbus_wdata[31:24] <= alu_b_l2[7:0];
		end
	end
	
endmodule
