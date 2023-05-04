module starrynift_nft_box::collection {
    use std::string;

    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::display_info;
    use nft_protocol::mint_cap::{Self, MintCap};
    use ob_permissions::witness;

    use starrynift_nft_box::box_nft::{MysteryBox, AvatarNFT, SpaceNFT, CouponNFT};
    use sui::display;
    use sui::object;
    use sui::package;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    // =================== Struct =================
    /// One time witness is only instantiated in the init method
    struct COLLECTION has drop {}

    /// Used for authorization of other protected actions.
    ///
    /// `Witness` must not be freely exposed to any contract.
    struct Witness has drop {}

    // =================== Function =================

    /// Init collection
    fun init(otw: COLLECTION, ctx: &mut TxContext) {
        let sender = tx_context::sender(ctx);

        // Get the Delegated Witness
        let dw = witness::from_witness(Witness {});

        // Create Collection
        let collection: Collection<COLLECTION> = collection::create(dw, ctx);
        let collection_id = object::id(&collection);

        // Initialize per-type MintCaps
        let mint_cap_box: MintCap<MysteryBox> = mint_cap::new_unlimited(&otw, collection_id, ctx);
        let mint_cap_avatar: MintCap<AvatarNFT> = mint_cap::new_unlimited(&otw, collection_id, ctx);
        let mint_cap_space: MintCap<SpaceNFT> = mint_cap::new_unlimited(&otw, collection_id, ctx);
        let mint_cap_coupon: MintCap<CouponNFT> = mint_cap::new_unlimited(&otw, collection_id, ctx);

        // Init Publisher
        let publisher = package::claim(otw, ctx);

        collection::add_domain(
            dw,
            &mut collection,
            display_info::new(
                string::utf8(b"StarryNift"),
                string::utf8(b"StarryNift collection on Sui"),
            )
        );

        // Init Box Display
        let box_display = display::new<MysteryBox>(&publisher, ctx);
        display::add(&mut box_display, string::utf8(b"name"), string::utf8(b"{name}"));
        display::add(&mut box_display, string::utf8(b"description"), string::utf8(b"{description}"));
        display::add(&mut box_display, string::utf8(b"image_url"), string::utf8(b"{img_url}"));
        display::update_version(&mut box_display);
        transfer::public_transfer(box_display, tx_context::sender(ctx));

        // Init Avatar Display
        let avatar_display = display::new<AvatarNFT>(&publisher, ctx);
        display::add(&mut avatar_display, string::utf8(b"name"), string::utf8(b"{name}"));
        display::add(&mut avatar_display, string::utf8(b"description"), string::utf8(b"{description}"));
        display::add(&mut avatar_display, string::utf8(b"image_url"), string::utf8(b"{img_url}"));
        display::add(&mut avatar_display, string::utf8(b"attributes"), string::utf8(b"{attributes}"));
        display::update_version(&mut avatar_display);
        transfer::public_transfer(avatar_display, tx_context::sender(ctx));

        // Init Space Display
        let space_display = display::new<SpaceNFT>(&publisher, ctx);
        display::add(&mut space_display, string::utf8(b"name"), string::utf8(b"{name}"));
        display::add(&mut space_display, string::utf8(b"description"), string::utf8(b"{description}"));
        display::add(&mut space_display, string::utf8(b"image_url"), string::utf8(b"{img_url}"));
        display::add(&mut space_display, string::utf8(b"attributes"), string::utf8(b"{attributes}"));
        display::update_version(&mut space_display);
        transfer::public_transfer(space_display, tx_context::sender(ctx));

        // Init Coupon Display
        let coupon_display = display::new<CouponNFT>(&publisher, ctx);
        display::add(&mut coupon_display, string::utf8(b"name"), string::utf8(b"{name}"));
        display::add(&mut coupon_display, string::utf8(b"description"), string::utf8(b"{description}"));
        display::add(&mut coupon_display, string::utf8(b"image_url"), string::utf8(b"{img_url}"));
        display::add(&mut coupon_display, string::utf8(b"attributes"), string::utf8(b"{attributes}"));
        display::update_version(&mut coupon_display);
        transfer::public_transfer(coupon_display, tx_context::sender(ctx));

        transfer::public_transfer(mint_cap_box, sender);
        transfer::public_transfer(mint_cap_avatar, sender);
        transfer::public_transfer(mint_cap_space, sender);
        transfer::public_transfer(mint_cap_coupon, sender);
        transfer::public_transfer(publisher, sender);
        transfer::public_share_object(collection);
    }
}
