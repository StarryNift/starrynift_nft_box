module starrynift_nft_box::box_nft {
    use std::option;
    use std::string::{Self, String};

    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::display_info;
    use nft_protocol::mint_cap::{Self, MintCap};
    use nft_protocol::mint_event;
    use ob_permissions::witness;

    use starrynift_nft_box::admin::{Contract, get_receiver, assert_not_freeze, get_signer_public_key};
    use starrynift_nft_box::box_config::{BoxConfig, assert_box_same_phase, assert_can_open_box, get_box_name, get_box_description, get_box_img_url, get_box_price, assert_nonce_used, add_coupon_claim_record};
    use starrynift_nft_box::ecdsa::{assert_mint_signature_valid, assert_open_box_signature_valid};
    use starrynift_nft_box::nft_config::{NFTConfig, get_nft_id, Avatar, Space, Coupon, get_nft_avatar_attributes, get_nft_can_mint, get_nft_name, get_nft_description, get_nft_img_url, get_nft_space_attributes, get_nft_coupon_attributes, get_nft_coupon_amount};
    use starrynift_nft_box::phase_config::{Phase, assert_phase_in_progress, get_current_phase, get_phase_config, assert_can_public_mint};
    use sui::clock::Clock;
    use sui::coin::{Self, Coin};
    use sui::display;
    use sui::event;
    use sui::object::{Self, ID, UID, uid_as_inner};
    use sui::package;
    use sui::sui::SUI;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::url::Url;

    const COLLECTION_NAME: vector<u8> = b"AI ANIMO";
    const COLLECTION_DESCRIPTION: vector<u8> = b"AI ANIMO is an experimental project launched by StarryNift on Sui Mainnet that aims to push the boundaries of NFTs by combining the latest AIGC and Composable 3D technologies.";

    // =================== Error =================

    const EINSUFFIENT_PAID: u64 = 1;

    // =================== Struct =================

    /// One time witness is only instantiated in the init method
    struct BOX_NFT has drop {}

    /// Used for authorization of other protected actions.
    ///
    /// `Witness` must not be freely exposed to any contract.
    struct Witness has drop {}

    struct MysteryBox has key, store {
        id: UID,
        name: String,
        description: String,
        phase: u8,
        img_url: Url,
    }

    struct BoxInfo has key, store {
        id: UID,
        minted: u64,
        opened: u64,
    }

    /// Avatar NFT for mint
    struct AvatarNFT has key, store {
        id: UID,
        name: String,
        description: String,
        img_url: Url,
        attributes: Avatar,
    }

    /// Space NFT for mint
    struct SpaceNFT has key, store {
        id: UID,
        name: String,
        description: String,
        img_url: Url,
        attributes: Space,
    }

    /// Coupon NFT for mint
    struct CouponNFT has key {
        id: UID,
        name: String,
        description: String,
        img_url: Url,
        attributes: Coupon,
    }

    // =================== Event =================

    struct BuyBoxNFTEvent has copy, drop {
        box_id: ID,
        phase: u8,
        buyer: address,
        box_price: u64,
    }

    struct OpenBoxNFTEvent has copy, drop {
        box_id: ID,
        phase: u8,
        user: address,
    }

    // =================== Function =================

    fun init(otw: BOX_NFT, ctx: &mut TxContext) {
        // Get the Delegated Witness
        let dw = witness::from_witness(Witness {});

        // Create Collection
        let collection: Collection<BOX_NFT> = collection::create(dw, ctx);
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
                string::utf8(COLLECTION_NAME),
                string::utf8(COLLECTION_DESCRIPTION),
            )
        );

        // Init Box Display
        let box_display = display::new<MysteryBox>(&publisher, ctx);
        display::add(&mut box_display, string::utf8(b"name"), string::utf8(b"{name}"));
        display::add(&mut box_display, string::utf8(b"description"), string::utf8(b"{description}"));
        display::add(&mut box_display, string::utf8(b"image_url"), string::utf8(b"{img_url}"));
        display::update_version(&mut box_display);
        transfer::public_share_object(box_display);

        // Init Avatar Display
        let avatar_display = display::new<AvatarNFT>(&publisher, ctx);
        display::add(&mut avatar_display, string::utf8(b"name"), string::utf8(b"{name}"));
        display::add(&mut avatar_display, string::utf8(b"description"), string::utf8(b"{description}"));
        display::add(&mut avatar_display, string::utf8(b"image_url"), string::utf8(b"{img_url}"));
        display::add(&mut avatar_display, string::utf8(b"attributes"), string::utf8(b"{attributes}"));
        display::update_version(&mut avatar_display);
        transfer::public_share_object(avatar_display);

        // Init Space Display
        let space_display = display::new<SpaceNFT>(&publisher, ctx);
        display::add(&mut space_display, string::utf8(b"name"), string::utf8(b"{name}"));
        display::add(&mut space_display, string::utf8(b"description"), string::utf8(b"{description}"));
        display::add(&mut space_display, string::utf8(b"image_url"), string::utf8(b"{img_url}"));
        display::add(&mut space_display, string::utf8(b"attributes"), string::utf8(b"{attributes}"));
        display::update_version(&mut space_display);
        transfer::public_share_object(space_display);

        // Init Coupon Display
        let coupon_display = display::new<CouponNFT>(&publisher, ctx);
        display::add(&mut coupon_display, string::utf8(b"name"), string::utf8(b"{name}"));
        display::add(&mut coupon_display, string::utf8(b"description"), string::utf8(b"{description}"));
        display::add(&mut coupon_display, string::utf8(b"image_url"), string::utf8(b"{img_url}"));
        display::add(&mut coupon_display, string::utf8(b"attributes"), string::utf8(b"{attributes}"));
        display::update_version(&mut coupon_display);
        transfer::public_share_object(coupon_display);

        transfer::public_share_object(mint_cap_box);
        transfer::public_share_object(mint_cap_avatar);
        transfer::public_share_object(mint_cap_space);
        transfer::public_share_object(mint_cap_coupon);
        transfer::public_share_object(publisher);
        transfer::public_share_object(collection);

        transfer::share_object(BoxInfo {
            id: object::new(ctx),
            minted: 0,
            opened: 0,
        });
    }

    /// Mint NFT to user
    fun mint_nft(
        nft_config: &NFTConfig,
        mint_cap_avatar: &mut MintCap<AvatarNFT>,
        mint_cap_space: &mut MintCap<SpaceNFT>,
        mint_cap_coupon: &mut MintCap<CouponNFT>,
        ctx: &mut TxContext
    ) {
        if (option::is_some(get_nft_avatar_attributes(nft_config)) && get_nft_can_mint(nft_config)) {
            let avatar = option::borrow(get_nft_avatar_attributes(nft_config));

            let avatar_nft = AvatarNFT {
                id: object::new(ctx),
                name: get_nft_name(nft_config),
                description: get_nft_description(nft_config),
                img_url: get_nft_img_url(nft_config),
                attributes: *avatar
            };

            mint_event::emit_mint(
                witness::from_witness(Witness {}),
                mint_cap::collection_id(mint_cap_avatar),
                &avatar_nft
            );

            mint_cap::increment_supply(mint_cap_avatar, 1);

            transfer::transfer(avatar_nft, tx_context::sender(ctx));
        } else if (option::is_some(get_nft_space_attributes(nft_config)) && get_nft_can_mint(nft_config)) {
            let space = option::borrow(get_nft_space_attributes(nft_config));

            let space_nft = SpaceNFT {
                id: object::new(ctx),
                name: get_nft_name(nft_config),
                description: get_nft_description(nft_config),
                img_url: get_nft_img_url(nft_config),
                attributes: *space
            };

            mint_event::emit_mint(
                witness::from_witness(Witness {}),
                mint_cap::collection_id(mint_cap_space),
                &space_nft
            );

            mint_cap::increment_supply(mint_cap_space, 1);

            transfer::transfer(space_nft, tx_context::sender(ctx));
        } else if (option::is_some(get_nft_coupon_attributes(nft_config)) && get_nft_can_mint(nft_config)) {
            let coupon = option::borrow(get_nft_coupon_attributes(nft_config));

            let coupon_nft = CouponNFT {
                id: object::new(ctx),
                name: get_nft_name(nft_config),
                description: get_nft_description(nft_config),
                img_url: get_nft_img_url(nft_config),
                attributes: *coupon
            };

            mint_event::emit_mint(
                witness::from_witness(Witness {}),
                mint_cap::collection_id(mint_cap_coupon),
                &coupon_nft
            );

            mint_cap::increment_supply(mint_cap_coupon, 1);

            transfer::transfer(coupon_nft, tx_context::sender(ctx));
        };
    }

    fun burn_coupon(coupon: CouponNFT, mint_cap_coupon: &MintCap<CouponNFT>) {
        let burn_guard = mint_event::start_burn(
            witness::from_witness(Witness {}),
            &coupon
        );

        let CouponNFT { id, name: _, description: _, img_url: _, attributes: _ } = coupon;

        // Burn user minted box
        mint_event::emit_burn(
            burn_guard,
            mint_cap::collection_id(mint_cap_coupon),
            id
        );
    }

    public entry fun private_buy_box(
        phase: &Phase,
        contract: &Contract,
        box_config: &mut BoxConfig,
        box_info: &mut BoxInfo,
        clock: &Clock,
        mint_cap_box: &mut MintCap<MysteryBox>,
        nonce: u64,
        signature: vector<u8>,
        ctx: &mut TxContext
    ) {
        assert_not_freeze(contract);
        assert_phase_in_progress(phase, clock);

        let current_phase = get_current_phase(phase);
        assert_box_same_phase(current_phase, box_config);

        // Mint Box NFT to user
        let sender = tx_context::sender(ctx);

        assert_mint_signature_valid(
            sender,
            current_phase,
            nonce,
            signature,
            get_signer_public_key(contract)
        );

        assert_nonce_used(box_config, nonce);

        let box = MysteryBox {
            id: object::new(ctx),
            name: get_box_name(box_config),
            description: get_box_description(box_config),
            phase: current_phase,
            img_url: get_box_img_url(box_config),
        };

        event::emit(
            BuyBoxNFTEvent {
                box_id: object::uid_to_inner(&box.id),
                phase: get_current_phase(phase),
                buyer: sender,
                box_price: get_box_price(box_config),
            }
        );

        mint_event::emit_mint(
            witness::from_witness(Witness {}),
            mint_cap::collection_id(mint_cap_box),
            &box
        );

        mint_cap::increment_supply(mint_cap_box, 1);
        box_info.minted = box_info.minted + 1;

        transfer::transfer(box, sender);
    }

    public entry fun buy_box(
        phase: &Phase,
        contract: &Contract,
        box_config: &BoxConfig,
        box_info: &mut BoxInfo,
        clock: &Clock,
        mint_cap_box: &mut MintCap<MysteryBox>,
        paid: Coin<SUI>,
        ctx: &mut TxContext
    ) {
        assert_not_freeze(contract);
        assert_phase_in_progress(phase, clock);

        let current_phase = get_current_phase(phase);
        assert_box_same_phase(current_phase, box_config);

        let phase_config = get_phase_config(phase);
        assert_can_public_mint(phase_config);

        let box_price = get_box_price(box_config);
        let paid_balance = coin::value(&paid);
        assert!(box_price == paid_balance, EINSUFFIENT_PAID);
        // Pay SUI to contract.receiver
        transfer::public_transfer(paid, get_receiver(contract));

        // Mint Box NFT to user
        let sender = tx_context::sender(ctx);

        let box = MysteryBox {
            id: object::new(ctx),
            name: get_box_name(box_config),
            description: get_box_description(box_config),
            phase: current_phase,
            img_url: get_box_img_url(box_config),
        };

        event::emit(
            BuyBoxNFTEvent {
                box_id: object::uid_to_inner(&box.id),
                phase: get_current_phase(phase),
                buyer: sender,
                box_price: get_box_price(box_config),
            }
        );

        mint_event::emit_mint(
            witness::from_witness(Witness {}),
            mint_cap::collection_id(mint_cap_box),
            &box
        );

        mint_cap::increment_supply(mint_cap_box, 1);
        box_info.minted = box_info.minted + 1;

        transfer::transfer(box, sender);
    }

    public entry fun open_box(
        contract: &Contract,
        box_config: &BoxConfig,
        mystery_box: MysteryBox,
        box_info: &mut BoxInfo,
        clock: &Clock,
        mint_cap_box: &MintCap<MysteryBox>,
        mint_cap_avatar: &mut MintCap<AvatarNFT>,
        mint_cap_space: &mut MintCap<SpaceNFT>,
        mint_cap_coupon: &mut MintCap<CouponNFT>,
        template1: &NFTConfig,
        template2: &NFTConfig,
        template3: &NFTConfig,
        signature: vector<u8>,
        ctx: &mut TxContext
    ) {
        assert_not_freeze(contract);
        assert_can_open_box(box_config, clock);

        // Verify signature (contract.signer + nft_config.id)
        assert_open_box_signature_valid(
            uid_as_inner(&mystery_box.id),
            get_nft_id(template1),
            get_nft_id(template2),
            get_nft_id(template3),
            signature,
            get_signer_public_key(contract));

        // Mint nft
        mint_nft(
            template1,
            mint_cap_avatar,
            mint_cap_space,
            mint_cap_coupon,
            ctx
        );
        mint_nft(
            template2,
            mint_cap_avatar,
            mint_cap_space,
            mint_cap_coupon,
            ctx
        );
        mint_nft(
            template3,
            mint_cap_avatar,
            mint_cap_space,
            mint_cap_coupon,
            ctx
        );

        event::emit(
            OpenBoxNFTEvent {
                box_id: object::uid_to_inner(&mystery_box.id),
                phase: mystery_box.phase,
                user: tx_context::sender(ctx),
            }
        );

        let burn_guard = mint_event::start_burn(
            witness::from_witness(Witness {}),
            &mystery_box
        );

        let MysteryBox { id, name: _, description: _, img_url: _, phase: _ } = mystery_box;

        // Burn user minted box
        mint_event::emit_burn(
            burn_guard,
            mint_cap::collection_id(mint_cap_box),
            id
        );

        box_info.opened = box_info.opened + 1;
    }

    public entry fun claim_coupon(
        coupon: CouponNFT,
        box_config: &mut BoxConfig,
        mint_cap_coupon: &MintCap<CouponNFT>,
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);
        let amount = get_nft_coupon_amount(&coupon.attributes);

        add_coupon_claim_record(
            box_config, amount, sender
        );
        burn_coupon(coupon, mint_cap_coupon);
    }
}
