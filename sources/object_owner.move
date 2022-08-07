module tutorial::object_owner {
    use sui::object::{Self, Info};
    use std::option::{Self, Option};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;

    struct Parent has key {
        info: Info,
        child: Option<Info>,
    }

    struct Child has key {
        info: Info,
    }

    struct AnotherParent has key {
        info: Info,
        child: UID,
    }

    public entry fun create_child(ctx: &mut TxContext) {
        transfer::transfer(
            Child { info: object::new(ctx) },
            tx_context::sender(ctx),
        )
    }

    public entry fun create_parent(ctx: &mut TxContext) {
        let parent = Parent {
            info: object::new(ctx),
            child: option::none(),
        };
        transfer::transfer(parent, tx_context::sender(ctx));
    }

    public entry fun add_child(parent: &mut Parent, child: Child) {
        let child_id = object::info(&child);
        transfer::transfer_to_object(child, parent);
        option::fill(&mut parent.child, child_id);
    }

    public entry fun create_another_parent(child: Child, ctx: &mut TxContext) {
        let info = object::new(ctx);
        let child_id = *object::id(&child);
        transfer::transfer_to_object_id(child, &info);
        let parent = AnotherParent {
            info,
            child: child_id,
        };
        transfer::transfer(parent, tx_context::sender(ctx));
    }

    

}