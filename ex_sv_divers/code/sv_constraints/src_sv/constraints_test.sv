class constraints_class;
    rand logic wr;
    rand logic rd;
    rand logic cs;
    rand logic[1:0] ptype;
    rand logic[7:0] address;
    rand logic[31:0] data;
    rand logic parity;

    // 1.
    constraint cs_address{
        (cs == 0) -> (address == 0);
    }

    // 2.
    constraint wr_rd{
        (wr == 1) -> (rd == 0);
    }

    // 3.
    constraint rd_wr{
        (rd == 1) -> (wr == 0);
    }

//    Correction 2 + 3 plus simple :
//    constraint wr_rd_exclusive{
//        wr != rd;
//    }

    // 4. 5. 6.
    constraint ptype_address{
        (ptype == 0) -> (address < 16);
        (ptype == 1) -> (address >= 16 && address < 128);
        (ptype == 2) -> (address >= 128);
    }

    // 7.
    constraint parity_data{
        int sum_data = 0;
        for (int i = 0; i < 32; i++) begin
            sum_data += data[i];
        end
        (parity == 0) -> (sum_data % 2 == 0);

//        Correction plus simple :
//        parity == ($countones(data) % 2);
    }

endclass : constraints_class


module constraints_test;

    task test_case1();
        automatic constraints_class obj = new();


        $display("Let's start test 1");

        for(int i=0;i<100;i++)
        begin
            void'(obj.randomize());
            $display("cs = %d, wr = %d, rd = %d, ptype = %d, address = %d, data = %d, parity = %d",
                obj.cs, obj.wr, obj.rd, obj.ptype, obj.address, obj.data, obj.parity);
        end
        $display("End of test 1");


    endtask


    // Programme lancé au démarrage de la simulation
    program TestSuite;
        initial begin
            test_case1();
            $display("done!");
            $stop;
        end
    endprogram

endmodule : constraints_test
