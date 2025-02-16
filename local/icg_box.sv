module icg_box (
  input        E,
  input        CLK, 
  input        TE,
  output logic GCLK
);

`ifdef presyn

	// ICG model for RTL sims (presyn). Zero delay on clock path
	logic latch_e;  
	logic latch_g;
	logic latch_q;

	assign latch_e = E || TE;
	assign latch_g = !CLK;
	assign GCLK = latch_q && CLK;

	always @ (*)
	  if(latch_g)
	     latch_q = latch_e;
`else

	//  ICG cell to be added in synthesis - Behavioral Model in Std Cell Lib. Adds physical delay of 0.02ns, so can't be used in RTL (presyn) sims
	LSGCPHDX0 u_icg (.E (E), .CLK (CLK), .SE (TE), .GCLK (GCLK));

`endif

endmodule
