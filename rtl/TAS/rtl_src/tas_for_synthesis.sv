module tas (input  clk_50,               // 50Mhz input clock
    input  clk_2,                // 2Mhz input clock
    input  reset_n,              // reset async active low
    input  serial_data,          // serial input data
    input  data_ena,             // serial data enable
    output ram_wr_n,             // write strobe to ram (i.e., write enable), active low
    output [7:0] ram_data,       // ram data
    output [10:0] ram_addr       // ram address
);

//rx_present/next state enums
//This state machine controls concatenating bits into bytes
    enum logic [1:0]{
        RX_IDLE = 2'b00,
        RX_READ_BITS = 2'b01,
        RX_DONE = 2'b10,
        CHECK_BYTE = 2'b11
    } rx_present_state, rx_next_state;
//This state controls byte accumulation and throws flag for 2MHz FSM to catch when average is calculated
    enum logic [2:0]{
        STATE1 = 3'b000,
        STATE2 = 3'b001,
        STATE3 = 3'b010,
        STATE4 = 3'b011,
        STATE5 = 3'b100
    } byte_analysis_present_state, byte_analysis_next_state;

//2MHZ state/next state enums
//This state machine controls the
    enum logic [1:0]{
        CLK2_WAIT_FOR_AVG = 2'b00,
        CLK2_CLEANUP = 2'b01
    } clk2_present_state, clk2_next_state;

//declare internal variables
    //counters for number of bytes
    logic [2:0] p_byte_count, n_byte_count;
    logic [7:0] data_buff;
    
    //next and present ram registers
    logic [10:0] next_ram_addr;
    logic [10:0] present_ram_addr;
    logic [7:0] present_ram_data;

    //registers for receiving data from serial to bytes
    logic [2:0] p_bit_index, n_bit_index;
    logic [7:0] rx_serial_input_buffer;
    logic [7:0] rx_second_order_buffer;
    logic rx_buffer_bit;

    //variables for processing received bytes
    logic [10:0] p_accumulator, n_accumulator;

    //control signals for crossing clock domains
    logic average_ready_to_write;
    logic average_written_to_ram;
    logic successfully_written_to_ram;
    logic acc_done;
    logic ready_to_write_end_buff, ready_to_write_middle_buff;

    //vars containing average temp for a packet and the ram_wr_n signal
    logic [7:0] packet_avg_temp;
    logic avg_computed_n;

    logic [3:0] i;
    //assign outputs
    assign ram_addr = present_ram_addr;
    assign ram_data = present_ram_data;
    assign ram_wr_n = avg_computed_n;

/******************************************************************************
*This state machine takes in a serial stream of bits and concatenates them into bytes.
*When the byte is recived it increments the byte count which triggers the next state machine.
***********************CONVERTING SERIAL TO BYTES******************************/
    always_ff @(posedge clk_50, negedge reset_n)
    begin
        if (!reset_n)    
        begin
            //bring to RX_IDLE as beginning state
            rx_present_state <= RX_IDLE;
            p_byte_count <= 0;
        end
        else
        begin             
            //load next values into present values
            rx_present_state <= rx_next_state;
            p_bit_index <= n_bit_index;
            p_byte_count <= n_byte_count;
            //buffer register with shifting contents
            rx_second_order_buffer <= rx_serial_input_buffer;
            rx_buffer_bit <= serial_data;
        end
    end
    //This combinational block happens every posedge of 50Mhz clock 
    always_comb
    begin
        unique case (rx_present_state)
            RX_IDLE:
            begin
                //reset bit index
                n_bit_index = '0;
                //keep byte_count the same
                n_byte_count = p_byte_count;
                /********************************************************/
                //ONLY FOR SYNTHESIS
                rx_serial_input_buffer = 'x;
                data_buff = 'x;
                /********************************************************/
                //if data_ena is high then go to RX_READ_BITS state
                if(data_ena)
                begin
                    rx_next_state = RX_READ_BITS;
                end
                else
                    rx_next_state = RX_IDLE;
            end
            RX_READ_BITS:
            begin
                //keep byte_count the same
                n_byte_count = p_byte_count;
                //change value of bit in register with incoming serial data at correct index
                rx_serial_input_buffer[p_bit_index] = rx_buffer_bit;
                /********************************************************/
                //ONLY FOR SYNTHESIS
                data_buff = 'x;
                /*for(i=0;i<8;i=i+1)
                begin
                    if(i != p_bit_index)
                        rx_serial_input_buffer[i] = 1'bx;
                end*/
                /********************************************************/
                //if all 8 bits are in the buffer goto RX_DONE
                if(p_bit_index < 7)
                begin
                    //if bits are still coming increment bit_index and stay in state
                    n_bit_index = p_bit_index + 1;
                    rx_next_state = RX_READ_BITS;
                end
                else
                begin
                    //reset bit index
                    n_bit_index = '0;
                    rx_next_state = RX_DONE;
                end
            end
            RX_DONE:
            begin
                /********************************************************/
                // ONLY FOR SYNTHESIS
                n_bit_index = 'x;
                /********************************************************/
                //set data buffer with buffered value of serial input buffer;
                data_buff = rx_second_order_buffer;
                //if byte count is 5 set next to 1, else increment
                if(p_byte_count == 5)
                    n_byte_count = 2'h1;
                else
                    n_byte_count = p_byte_count + 1;
                //reset serial buffer
                rx_serial_input_buffer = '0;
                //if data_ena is high switch directly back to reading rather than RX_IDLE
                if(data_ena)
                    rx_next_state = RX_READ_BITS;  
                else              
                    rx_next_state = RX_IDLE;

            end
            default:
            begin
                rx_next_state = RX_IDLE;
                n_byte_count = p_byte_count;
                /********************************************************/
                // ONLY FOR SYNTHESIS
                rx_serial_input_buffer = 'x;
                n_bit_index = 'x;
                data_buff = 'x;
                /********************************************************/
            end
        endcase
    end
/**********************END OF CONVERTING SERIAL TO BYTES******************************
*This state machine processes bytes to determine whether there was a valid packet header
*If a valid header is found on the first of five bytes the next four bytes are added up and
*averaged, the FSM then sends a flag which triggers the clock domain logic on 2MHz FSM
*The byte analysis state machine runs on 50MHz to accomodate the communication logic
**********************ANALYZE BYTES**************************************************/


    always_ff @ (posedge clk_50, negedge reset_n)
    begin
        if(!reset_n)
        begin
            //STATE1 is IDLE STATE
            byte_analysis_present_state <= STATE1;
        end
        else
        begin
            //move shift flip flops
            byte_analysis_present_state <= byte_analysis_next_state;
            p_accumulator <= n_accumulator;
            successfully_written_to_ram <= average_written_to_ram;
            //final_acc <= n_accumulator;
        end
    end


    
    //assert accumulator done after the average is calculated
    assign acc_done = (byte_analysis_present_state != STATE5 && n_byte_count == 5) ? 1'b1 : 1'b0;
    //assign average_ready_to_write = (byte_analysis_present_state == STATE5 && n_byte_count == 5) ? 1'b1 : ((successfully_written_to_ram == 1) ? 1'b0 : 1'bx);

    always_comb
    begin
        //asserts average ready to write when the packet is finished being added up
        if(byte_analysis_present_state == STATE5 && n_byte_count == 5)
        begin
            average_ready_to_write = 1;
        end
        else
        begin
            //if the return signal from 2MHz clock is high (data has been written to ram)
            //set the ready to write signal low
            if(successfully_written_to_ram == 1)
            begin
                average_ready_to_write = 0;
            end
            /********************************************************/
            //PUT IN FOR SYNTHESIS BUT NOT FOR SIMULATION
            //this prevents latches from being synthesized and tells the synthesizer that
            //I don't care which value the ready to write signal has
            else
                average_ready_to_write = 'x;
            /********************************************************/
        end
    end
    //This combinational block does accumulates from STATE2 - STATE5
    //on STATE5 the average is sent into a register and acc_done is asserted
    always_comb
    begin
        unique case (byte_analysis_present_state)
            STATE1:
            begin
                //reset accumulator
                n_accumulator = '0;
                if(n_byte_count == 1)
                begin
                    //checks data buffer to see if first byte is valid header
                    if(data_buff == 8'hA5 || data_buff == 8'hC3)
                    begin
                        byte_analysis_next_state = STATE2;
                    end
                    else
                    begin
                        byte_analysis_next_state = STATE1;
                    end
                end
                else 
                begin
                    byte_analysis_next_state = byte_analysis_present_state;
                end
            end
            STATE2:
            begin
                if(n_byte_count == 2)
                begin
                    n_accumulator = p_accumulator + data_buff;
                    byte_analysis_next_state = STATE3; 
                end
                else
                begin
                    byte_analysis_next_state = byte_analysis_present_state;
                    n_accumulator = p_accumulator;
                end
            end
            STATE3:
            begin
                if(n_byte_count == 3)
                begin
                    n_accumulator = p_accumulator + data_buff;
                    byte_analysis_next_state = STATE4; 
                end
                else
                begin
                    byte_analysis_next_state = byte_analysis_present_state;
                    n_accumulator = p_accumulator;
                end
            end
            STATE4:
            begin
                if(n_byte_count == 4)
                begin
                    n_accumulator = p_accumulator + data_buff;
                    byte_analysis_next_state = STATE5; 
                end
                else
                begin
                    byte_analysis_next_state = byte_analysis_present_state;
                    n_accumulator = p_accumulator;
                end
            end
            STATE5:
            if(n_byte_count == 5)
            begin
                n_accumulator = p_accumulator + data_buff;
                //reset state
                byte_analysis_next_state = STATE1; 
            end
            else
            begin
                byte_analysis_next_state = byte_analysis_present_state;
                n_accumulator = p_accumulator;
            end
        endcase 
    end

    //This always divides the value by 4 by taking the last 8 MSBs from accumulator
    always_ff @ (posedge acc_done, negedge reset_n)
    begin
        if(!reset_n)
            packet_avg_temp <= '0;
        else
            packet_avg_temp <= n_accumulator[10:2];
    end

    /***************************2MHz FSM************************************
    *This state machine writes to ram and talks to the FSM controlling the ram_wr_signal
    /***********************************************************************/
    always_ff @ (posedge clk_2, negedge reset_n)
    begin
        if(!reset_n)
        begin
            //set init state and address
            clk2_present_state <= CLK2_WAIT_FOR_AVG;
            present_ram_addr <= 11'h7ff;
        end
        else
        begin
            clk2_present_state <= clk2_next_state;
            present_ram_addr <= next_ram_addr;
            //done signal from rx state machine
            //double buffer input from ~6Mhz (50/8) clock domain
            ready_to_write_middle_buff <= average_ready_to_write;
            ready_to_write_end_buff <= ready_to_write_middle_buff;

        end
    end
    always_comb
    begin
        unique case (clk2_present_state)
        CLK2_WAIT_FOR_AVG:
        begin
            //check to see if the average is computed
            if(ready_to_write_end_buff == 1)
            begin
                //assert active low ram_wr_n
                avg_computed_n = 0;
                //load value into ram data
                present_ram_data = packet_avg_temp;
                //sends signal to enable ram write process
                average_written_to_ram = 1;
                clk2_next_state = CLK2_CLEANUP;
                // if at the end of memory loop back to top
                if(present_ram_addr == '0)
                begin
                    next_ram_addr = 11'h7ff;
                end
                else
                begin
                    //else decrement
                    next_ram_addr = present_ram_addr - 1;
                end
            end
            else
            begin
                next_ram_addr = present_ram_addr;
                /********************************************************/
                //PUT THESE IN TO NOT SYNTHESIZE LATCHES BUT DONT USE IN SIM
                avg_computed_n = 'x;
                average_written_to_ram = 'x;
                present_ram_data = 'x;
                /********************************************************/
                clk2_next_state = CLK2_WAIT_FOR_AVG;
            end
        end
        CLK2_CLEANUP:
        begin
            //reset variables
            avg_computed_n = 1;
            average_written_to_ram = 0;
            next_ram_addr = present_ram_addr;
            clk2_next_state = CLK2_WAIT_FOR_AVG;
            /********************************************************/
            //FOR SYNTHESIS
            present_ram_data = 'x;
            /********************************************************/
        end
        endcase
    end
endmodule
