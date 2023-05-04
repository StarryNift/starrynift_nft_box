module sui_nft_box::collection {
    use sui::event;
    use sui::object::{Self, UID, ID};
    use sui::transfer;
    use sui::tx_context::TxContext;

    // =================== Struct =================

    /// NFT collection which registered here.
    struct Collection has key, store {
        /// `Collection` ID
        id: UID,
    }

    // =================== Event =================

    struct CollectionEvent has copy, drop {
        collection_id: ID,
    }

    // =================== Function =================

    fun init(ctx: &mut TxContext) {
        let id = object::new(ctx);

        event::emit(CollectionEvent {
            collection_id: object::uid_to_inner(&id),
        });

        let collection = Collection {
            id,
        };

        transfer::share_object(collection);
    }
}
