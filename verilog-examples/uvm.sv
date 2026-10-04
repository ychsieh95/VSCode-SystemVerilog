




virtual interface my_if;

    clocking mon_cb();

    endclocking
endinterface: my_if

virtual my_if vif = main_if.sub_if;

my_struct s = a;
