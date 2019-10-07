//  Class: master
//
//  Interface: mif
//
import uvm_pkg::*;
`include "uvm_macros.svh"


interface handshake_int ();
    logic ARVALID;
    logic ARREADY;
    logic ARADDR; 
    //logic ARDATA;   
endinterface: handshake_int

//  Class: master
//
class master extends uvm_component;//
    `uvm_component_utils(master);


    //  Constructor: new
    function new(string name = "", uvm_component parent);
        super.new(name, parent);
    endfunction: new

    virtual handshake_int mif;

    function void build_phase(uvm_phase phase);
        if(!(uvm_config_db #(virtual handshake_int)::get(null,"*","handshake_int",mif)))
        `uvm_error("", "uvm_config_db::get - Failed at interface")
    endfunction: build_phase

    virtual task run_phase(uvm_phase phase);
        mif.ARVALID = 1;
        `uvm_info("ID1","ARVALID is HIGH", UVM_HIGH)

        wait(mif.ARREADY == 1);
        if(mif.ARREADY == 1)
        begin
            `uvm_info("ID1","Received ARREADY from Slave", UVM_MEDIUM)
        end
        //`uvm_info(get_name(), "message", UVM_MEDIUM)
        
        
       // $display("Data = %b",slv.ARDATA);
                        
    endtask : run_phase   
    
    
endclass: master


//  Class: slave
//
class slave extends uvm_component;
    `uvm_component_utils(slave);
    
    //logic temp;
    
    virtual handshake_int sif;

    function new(string name = "", uvm_component parent);
        super.new(name,parent);
    endfunction: new

    function void build_phase (uvm_phase phase);
        if(!(uvm_config_db#(virtual handshake_int)::get(null,"*","handshake_int",sif)))
        `uvm_error("", "uvm_config_db::get - Failed at interface")
    endfunction: build_phase

    task run_phase(uvm_phase phase);
        wait(sif.ARVALID==1);
        if(sif.ARVALID == 1)
        begin
            sif.ARREADY = 1;
            `uvm_info("ID1", "Received ARVALID from Master", UVM_MEDIUM)
           
        end
    
           
        
    endtask: run_phase
    
endclass: slave

//  Class: env
//
class handshake_env extends uvm_env;
    `uvm_component_utils(handshake_env)
    
    
    function new(string name = "handshake_env", uvm_component parent);
        super.new(name,parent);
    endfunction: new

    master mst;
    slave slv;

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mst = master::type_id::create("mst",this);
        slv = slave::type_id::create("slv",this);
    endfunction: build_phase
    

endclass: handshake_env 


//  Class: handshake_test
//
class handshake_test extends uvm_test;
    `uvm_component_utils(handshake_test)
    

    handshake_env env;

    function new(string name = "handshake_test", uvm_component parent);
        super.new(name, parent);
    endfunction: new
    
    function void build_phase(uvm_phase phase);
        
        super.build_phase(phase);
        env = handshake_env::type_id::create("env", this);
        
    endfunction: build_phase
    
    
    
    function void report_phase(uvm_phase phase);
        uvm_report_server server;
        
        super.report_phase(phase);
        server = uvm_report_server::get_server();

        if( server.get_severity_count(UVM_ERROR)>0)
        begin
            $display("............Test is Failed............");
        end
        else
        begin
            $display("............Test is Passed............");
        end
    endfunction: report_phase

    

endclass: handshake_test

//  Module: top
//
module top;
    `include "uvm_macros.svh"
    import uvm_pkg::*;

   // master mst;
   // slave slv;

    handshake_int itf();

    initial begin
        
        uvm_config_db #(virtual handshake_int)::set(null, "*", "handshake_int", itf);
        
        
    end   


    initial begin
        uvm_top.set_report_verbosity_level(UVM_HIGH);
        run_test("handshake_test");
    end
    
endmodule: top

