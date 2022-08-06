module tutorial::trusted_swap {
    use sui::object::{Self, Info};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use sui::sui::SUI;
    use sui::balance::{Self, Balance};
    use sui::coin::{Self, Coin};

    const MIN_FEE: u64 = 1000;

    struct Object has key, store {
        info: Info,
        scarcity: u8,
        style: u8,
    }

    struct ObjectWrapper has key {
        info: Info,
        original_owner: address,
        to_swap: Object,
        fee: Balance<SUI>,
    }

    public entry fun create_object(scarcity: u8, style: u8, ctx: &mut TxContext) {
        let object = Object {
            info: object::new(ctx),
            scarcity,
            style,
        };
        transfer::transfer(object, tx_context::sender(ctx));
    }

    public entry fun transfer_object(object: Object, recipient: address) {
        transfer::transfer(object, recipient);
    }

    public entry fun request_swap(object: Object, fee: Coin<SUI>, service_address: address, ctx: &mut TxContext) {
        assert!(coin::value(&fee) >= MIN_FEE, 0);
        let wrapper = ObjectWrapper {
            info: object::new(ctx),
            original_owner: tx_context::sender(ctx),
            to_swap: object,
            fee: coin::into_balance(fee),
        };
        transfer::transfer(wrapper, service_address);
    }

    public entry fun execute_swap(wrapper1: ObjectWrapper, wrapper2: ObjectWrapper, ctx: &mut TxContext) {
        assert!(wrapper1.to_swap.scarcity == wrapper2.to_swap.scarcity, 0);
        assert!(wrapper1.to_swap.style != wrapper2.to_swap.style, 0);

        let ObjectWrapper {
            info: id1,
            original_owner: original_owner1,
            to_swap: object1,
            fee: fee1,
        } = wrapper1;

        let ObjectWrapper {
            info: id2,
            original_owner: original_owner2,
            to_swap: object2,
            fee: fee2,
        } = wrapper2;

        transfer::transfer(object1, original_owner2);
        transfer::transfer(object2, original_owner1);

        let service_address = tx_context::sender(ctx);
        balance::join(&mut fee1, fee2);
        transfer::transfer(coin::from_balance(fee1, ctx), service_address);

        object::delete(id1);
        object::delete(id2);

    }
}