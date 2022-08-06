module tutorial::simple_warrior {
    use sui::object::{Self, Info};
    use std::option::{Self, Option};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};


    struct Sword has key, store {
        info: Info,
        strength: u8,
    }

    struct Shield has key, store {
        info: Info,
        armor: u8,
    }

    struct SimpleWarrior has key {
        info: Info,
        sword: Option<Sword>,
        shield: Option<Shield>,
    }

    public entry fun create_warrior(ctx: &mut TxContext) {
        let warrior = SimpleWarrior {
            info: object::new(ctx),
            sword: option::none(),
            shield: option::none(),
        };
        transfer::transfer(warrior, tx_context::sender(ctx));
    }

    public entry fun equip_sword(warrior: &mut SimpleWarrior, sword: Sword, ctx: &mut TxContext) {
        if (option::is_some(&warrior.sword)) {
            let old_sword = option::extract(&mut warrior.sword);
            transfer::transfer(old_sword, tx_context::sender(ctx));
        };
        option::fill(&mut warrior.sword, sword);
    }

    public entry fun equip_shield(warrior: &mut SimpleWarrior, shield: Shield, ctx: &mut TxContext) {
        if (option::is_some(&warrior.shield)) {
            let old_shield = option::extract(&mut warrior.shield);
            transfer::transfer(old_shield, tx_context::sender(ctx));
        };
        option::fill(&mut warrior.shield, shield);
    }




}