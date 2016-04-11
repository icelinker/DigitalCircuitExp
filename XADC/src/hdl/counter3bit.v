//每次时钟上升沿到来时，Q加一，实现从000到111的不断变化。

module counter3bit (
    input clk,
    input rst,
    output reg [2:0] Q
    );
 
always @ (posedge(clk))   // When will Always Block Be Triggered
begin
    if (rst == 3'b111)
        // How Output reacts when Reset Is Asserted
        Q <= 3'b0;
    else
        // How Output reacts when Rising Edge of Clock Arrives?
        Q <= Q + 1'b1;
end
 
endmodule
