class fifo_env extends uvm_env;
    
    // Register with factory
    `uvm_component_utils(fifo_env)
    
    // Components
    fifo_agent agent;
    fifo_scoreboard scoreboard;
    fifo_coverage coverage;
    
    // Constructor
    function new(string name = "fifo_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    // Build phase - create agent
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        `uvm_info(get_type_name(), "Build phase", UVM_MEDIUM)
        
        // Create the agent
        agent = fifo_agent::type_id::create("agent", this);

        // Create the scoreboard
        scoreboard = fifo_scoreboard::type_id::create("scoareboard", this);

        // Create the coverage collector (subscriber)
        coverage = fifo_coverage::type_id::create("coverage", this);
    endfunction
    
    // Connect phase - nothing to connect yet (we'll add scoreboard later)
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        `uvm_info(get_type_name(), "Connect phase", UVM_MEDIUM)

        // Connect monitor to scoreboard
        agent.monitor.analysis_port.connect(scoreboard.analysis_export);

        // Connect monitor to coverage collector
        agent.monitor.analysis_port.connect(coverage.analysis_export);
        
        `uvm_info(get_type_name(), "Monitor connected to scoreboard and coverage", UVM_MEDIUM)
    endfunction
    
endclass