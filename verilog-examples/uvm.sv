`timescale 1ns/1ps

package uvm_syntax_examples_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    // Enumerations and aggregate data types
    typedef enum logic [1:0] { IDLE, BUSY, DONE, ERROR } state_e;

    typedef struct {
        int           id;
        string        name;
        byte unsigned payload[];
    } unpacked_item_t;

    typedef struct packed {
        bit          valid;
        bit  [2:0]   opcode;
        logic [15:0] data;
    } packed_item_t;

    typedef union packed {
        logic [31:0] word;
        struct packed {
            logic [15:0] upper;
            logic [15:0] lower;
        } halves;
        struct packed {
            logic [7:0] byte_3;
            logic [7:0] byte_2;
            logic [7:0] byte_1;
            logic [7:0] byte_0;
        } bytes;
    } packed_word_t;

    // Transaction, constraints, and UVM field macros
    class bus_item extends uvm_sequence_item;
        rand bit          write;
        rand logic [15:0] address;
        rand logic [31:0] data;
        rand int unsigned delay;

        constraint aligned_address_c { address[1:0] == 2'b00; }
        constraint short_delay_c { delay inside {[0:10]}; }

        `uvm_object_utils_begin(bus_item)
            `uvm_field_int(write,   UVM_DEFAULT)
            `uvm_field_int(address, UVM_HEX)
            `uvm_field_int(data,    UVM_HEX)
            `uvm_field_int(delay,   UVM_DEC)
        `uvm_object_utils_end

        function new(string name = "bus_item");
            super.new(name);
        endfunction
    endclass

    // Parameterized classes and inline constraints
    class bus_sequence extends uvm_sequence #(bus_item);
        `uvm_object_utils(bus_sequence)

        function new(string name = "bus_sequence");
            super.new(name);
        endfunction

        virtual task body();
            repeat (4) begin
                req = bus_item::type_id::create("req");
                start_item(req);
                assert(req.randomize() with {
                    write == 1'b1;
                    address inside {[16'h1000:16'h10ff]};
                });
                finish_item(req);
            end
        endtask
    endclass

    class bus_sequencer extends uvm_sequencer #(bus_item);
        `uvm_component_utils(bus_sequencer)

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction
    endclass

    class bus_driver extends uvm_driver #(bus_item);
        `uvm_component_utils(bus_driver)
        virtual bus_if vif;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if (!uvm_config_db #(virtual bus_if)::get(this, "", "vif", vif))
                `uvm_fatal("NO_VIF", "bus_if was not configured")
        endfunction

        virtual task run_phase(uvm_phase phase);
            forever begin
                seq_item_port.get_next_item(req);
                repeat (req.delay) @(posedge vif.clk);
                vif.drive(req.write, req.address, req.data);
                seq_item_port.item_done();
            end
        endtask
    endclass

    class bus_monitor extends uvm_monitor;
        `uvm_component_utils(bus_monitor)
        virtual bus_if vif;
        uvm_analysis_port #(bus_item) item_port;

        function new(string name, uvm_component parent);
            super.new(name, parent);
            item_port = new("item_port", this);
        endfunction

        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            void'(uvm_config_db #(virtual bus_if)::get(this, "", "vif", vif));
        endfunction

        virtual task run_phase(uvm_phase phase);
            bus_item observed;
            forever begin
                @(vif.mon_cb);
                if (vif.mon_cb.valid && vif.mon_cb.ready) begin
                    observed = bus_item::type_id::create("observed");
                    observed.write   = vif.mon_cb.write;
                    observed.address = vif.mon_cb.address;
                    observed.data    = vif.mon_cb.data;
                    item_port.write(observed);
                end
            end
        endtask
    endclass

    class bus_agent extends uvm_agent;
        `uvm_component_utils(bus_agent)
        bus_sequencer sequencer;
        bus_driver    driver;
        bus_monitor   monitor;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            monitor = bus_monitor::type_id::create("monitor", this);
            if (get_is_active() == UVM_ACTIVE) begin
                sequencer = bus_sequencer::type_id::create("sequencer", this);
                driver    = bus_driver::type_id::create("driver", this);
            end
        endfunction

        virtual function void connect_phase(uvm_phase phase);
            if (get_is_active() == UVM_ACTIVE)
                driver.seq_item_port.connect(sequencer.seq_item_export);
        endfunction
    endclass

    class bus_env extends uvm_env;
        `uvm_component_utils(bus_env)
        bus_agent agent;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            agent = bus_agent::type_id::create("agent", this);
        endfunction
    endclass

    class bus_test extends uvm_test;
        `uvm_component_utils(bus_test)
        bus_env env;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            env = bus_env::type_id::create("env", this);
        endfunction

        virtual task run_phase(uvm_phase phase);
            bus_sequence sequence_h;
            phase.raise_objection(this);
            sequence_h = bus_sequence::type_id::create("sequence_h");
            sequence_h.start(env.agent.sequencer);
            phase.drop_objection(this);
        endtask
    endclass
endpackage

// Interface, clocking blocks, modports, assertion, and coverage
interface bus_if(input logic clk, input logic rst_n);
    logic        valid;
    logic        ready;
    logic        write;
    logic [15:0] address;
    logic [31:0] data;

    clocking drv_cb @(posedge clk);
        output valid, write, address, data;
        input ready;
    endclocking

    clocking mon_cb @(posedge clk);
        input valid, ready, write, address, data;
    endclocking

    modport DRIVER  (clocking drv_cb, input clk, rst_n);
    modport MONITOR (clocking mon_cb, input clk, rst_n);

    task automatic drive(
        input bit write_value,
        input logic [15:0] address_value,
        input logic [31:0] data_value
    );
        drv_cb.valid   <= 1'b1;
        drv_cb.write   <= write_value;
        drv_cb.address <= address_value;
        drv_cb.data    <= data_value;
        do @(drv_cb); while (!drv_cb.ready);
        drv_cb.valid <= 1'b0;
    endtask

    property valid_until_ready_p;
        @(posedge clk) disable iff (!rst_n)
        valid && !ready |=> valid;
    endproperty

    valid_until_ready_a: assert property (valid_until_ready_p);

    covergroup bus_cg @(posedge clk);
        write_cp: coverpoint write;
        address_cp: coverpoint address {
            bins low  = {[16'h0000:16'h0fff]};
            bins high = {[16'hf000:16'hffff]};
        }
        command_cross: cross write_cp, address_cp;
    endgroup
endinterface

module uvm_syntax_example_top;
    import uvm_pkg::*;
    import uvm_syntax_examples_pkg::*;

    logic clk = 1'b0;
    logic rst_n = 1'b0;
    bus_if bus_vif(clk, rst_n);

    always #5ns clk = ~clk;

    initial begin
        repeat (2) @(posedge clk);
        rst_n = 1'b1;
    end

    initial begin
        uvm_config_db #(virtual bus_if)::set(null, "uvm_test_top.env.agent.*", "vif", bus_vif);
        run_test("bus_test");
    end
endmodule
