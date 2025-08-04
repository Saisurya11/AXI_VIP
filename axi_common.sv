`define addr_width 32
`define data_width 32
typedef enum bit[1:0]{
	FIXED,
	INCR,
	WRAP,
	RSVD_burst
	} burst_type_t;
typedef enum bit[2:0]{
	BURST_SIZE_1_BYTE,
	BURST_SIZE_2_BYTE,
	BURST_SIZE_4_BYTE,
	BURST_SIZE_8_BYTE,
	BURST_SIZE_16_BYTE,
	BURST_SIZE_32_BYTE,
	BURST_SIZE_64_BYTE,
	BURST_SIZE_128_BYTE
	} burst_size_t;

typedef enum bit[1:0]{
	OKAY,
	EXOKAY,
	SLVERR,
	DECERR
	} resp_t;

typedef enum bit [1:0]{
	NORMAL,
	EXCLUSIVE,
	LOCKED,
	RSVD_lock
	}lock_t;

typedef enum bit{
	READ,
	WRITE
	}wr_rd_t;

`define NEW_COMP \
function new(string name="",uvm_component parent); \
	super.new(name,parent); \
endfunction

`define NEW_OBJ \
function new(string name=""); \
	super.new(name); \
endfunction

class axi_common;
  static int num_of_tx=1;
endclass
