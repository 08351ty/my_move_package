module tutorial::color_object {
    //object represents the object module, which allows us to call
    //functions in the module, such as the 'new' function, without fully
    //qualifying; sui::object::new
    use sui::object::{Self, Info};
    //tx_context::TxContext represents the TxContext struct in tx_context module
    use sui::tx_context::TxContext;
    use sui::transfer;

    struct ColorObject has key {
        info: Info,
        red: u8,
        green: u8,
        blue: u8,
    }

    fun new(red: u8, green: u8, blue: u8, ctx: &mut TxContext): ColorObject {
        ColorObject {
            info: object::new(ctx),
            red,
            green,
            blue,
        }
    }

    //entry function called directly by a transaction
    public entry fun create(red: u8, green: u8, blue: u8, ctx: &mut TxContext) {
        use sui::tx_context;
        let color_object = new(red, green, blue, ctx);
        transfer::transfer(color_object, tx_context::sender(ctx));
    }

    public fun get_color(self: &ColorObject): (u8, u8, u8) {
        (self.red, self.green, self.blue)
    }

}

#[test_only]
module tutorial::color_objectTests {
    use sui::test_scenario;
    use tutorial::color_object::{Self, ColorObject};

    #[test]
    fun test_create() {
        let owner = @0x1;
        //Create ColorObject and transfer it to @owner
        let scenario = &mut test_scenario::begin(&owner);
        {
            let ctx = test_scenario::ctx(scenario);
            color_object::create(255, 0, 255, ctx);
        };

        let not_owner = @0x2;
        test_scenario::next_tx(scenario, &not_owner);
        {
            assert!(!test_scenario::can_take_owned<ColorObject>(scenario), 0);
        };

        test_scenario::next_tx(scenario, &owner);
        {
            let object = test_scenario::take_owned<ColorObject>(scenario);
            let (red, green, blue) = color_object::get_color(&object);
            assert!(red == 255 && green == 0 && blue == 255, 0);
            test_scenario::return_owned(scenario, object);
        }
    }


}