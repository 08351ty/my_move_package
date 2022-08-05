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

    public entry fun copy_into(from_object: &ColorObject, into_object: &mut ColorObject) {
        into_object.red = from_object.red;
        into_object.green = from_object.green;
        into_object.blue = from_object.blue;
    }

    public entry fun delete(object: ColorObject) {
        let ColorObject { info, red: _, green: _, blue: _ } = object;
        object::delete(info);
    }

    public entry fun transfer(object: ColorObject, recipient: address) {
        transfer::transfer(object, recipient);
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

    #[test]
    fun test_copy_into() {
        use sui::test_scenario;
        use tutorial::color_object::{Self, ColorObject};
        use sui::object;
        use sui::tx_context;
        let owner = @0x1;
        let scenario = &mut test_scenario::begin(&owner);
        //Create two ColorObjects owned by 'owner', and obtain their IDs
        let (id1, id2) = {
            let ctx = test_scenario::ctx(scenario);
                color_object::create(255, 255, 255, ctx);
            let id1 = object::id_from_address(tx_context::last_created_object_id(ctx));
                color_object::create(0, 0, 0, ctx);
            let id2 = object::id_from_address(tx_context::last_created_object_id(ctx));
            (id1, id2)
        };
        test_scenario::next_tx(scenario, &owner);
        {
            let obj1 = test_scenario::take_owned_by_id<ColorObject>(scenario, id1);
            let obj2 = test_scenario::take_owned_by_id<ColorObject>(scenario, id2);
            let (red, green, blue) = color_object::get_color(&obj1);
            assert!(red == 255 && green == 255 && blue == 255, 0);

            color_object::copy_into(&obj2, &mut obj1);
            test_scenario::return_owned(scenario, obj1);
            test_scenario::return_owned(scenario, obj2);
        };
        test_scenario::next_tx(scenario, &owner);
        {
            let obj1 = test_scenario::take_owned_by_id<ColorObject>(scenario, id1);
            let (red, green, blue) = color_object::get_color(&obj1);
            assert!(red == 0 && green == 0 && blue == 0, 0);
            test_scenario::return_owned(scenario, obj1);
        };

    }
    #[test]
    fun test_delete() {
        let owner = @0x1;
        //Create a ColorObject and transfer it to @owner
        let scenario = &mut test_scenario::begin(&owner);
        {
            let ctx = test_scenario::ctx(scenario);
            color_object::create(255, 0, 255, ctx);
        };
        //Delete the ColorObject we just created
        test_scenario::next_tx(scenario, &owner);
        {
            let object = test_scenario::take_owned<ColorObject>(scenario);
            color_object::delete(object);
        };
        //Verify that the object was indeed deleted
        test_scenario::next_tx(scenario, &owner);
        {
            assert!(!test_scenario::can_take_owned<ColorObject>(scenario), 0);
        }
    }
    #[test]
    fun test_transfer() {
        let owner = @0x1;
        //Create a ColorObject and transfer it to @owner
        let scenario = &mut test_scenario::begin(&owner);
        {
            let ctx = test_scenario::ctx(scenario);
            color_object::create(255, 0, 255, ctx);
        };
        //transfer the object to recipient
        let recipient = @0x2;
        test_scenario::next_tx(scenario, &owner);
        {
            let object = test_scenario::take_owned<ColorObject>(scenario);
            color_object::transfer(object, recipient);
        };
        //check that owner no longer owns the object
        test_scenario::next_tx(scenario, &owner);
        {
            assert!(!test_scenario::can_take_owned<ColorObject>(scenario), 0);
        };
        //check that recipient now owns the object
        test_scenario::next_tx(scenario, &recipient);
        {
            assert!(test_scenario::can_take_owned<ColorObject>(scenario), 0);
        };
    }


}