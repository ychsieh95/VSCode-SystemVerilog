`ifndef DEFINE_MY_IF
`define DEFINE_MY_IF

interface my_if(input logic clk, input logic rst_n);

    reg [`DATA_WIDTH-1:0] data[5];
    reg                   valid;
    reg                   ready;

    clocking mon_cb (@posedge clk);
        input rst_n;
        input data;
        input valid;
        input ready;
    endclocking: mon_cb
endinterface: my_if

`endif // DEFINE_MY_IF


function void my_if_init(my_if if_inst);
    int i;
    for (i = 0; i < 5; i++) begin
        if_inst.data[i] = '0;
    end
    if_inst.valid = 1'b0;
    if_inst.ready = 1'b0;
endfunction: my_if_init

virtual my_if if_inst;
virtual `define_prefix(my_if) if_inst;


int index_q[$]
index_q = items[obj.get_index(.group(1), .port(1))].find_index(item) with (item.get_name() == "my_if");

obj.get_index(.group(1), .port(1));

virtual function void my_if_init(my_if if_inst);
    int i;
    for (i = 0; i < 5; i++) begin
        if_inst.data[i] = '0;
    end
    if_inst.valid = 1'b0;
    if_inst.ready = 1'b0;
endfunction: my_if_init

class my_class;
    virtual my_if if_inst;

    function new(virtual my_if if_inst);
        this.if_inst = if_inst;
    endfunction: new

    task run();
        // Example task that uses the interface
        @(posedge if_inst.clk);
        if_inst.valid <= 1'b1;
        if_inst.data[0] <= 8'hAA; // Example data
        @(posedge if_inst.clk);
        if_inst.valid <= 1'b0;
    endtask: run
endclass: my_class

my_class obj = new();

typedef enum int {
    IDLE,
    BUSY,
    DONE
} state_t;

typedef struct packed {
    bit       valid;
    bit [7:0] data;
} my_struct_t;

state_e     current_state;
my_struct_t my_data;
my_class    my_obj;
