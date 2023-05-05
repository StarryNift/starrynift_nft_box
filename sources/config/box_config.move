module sui_nft_box::box_config {
    use std::string::{String, bytes};

    use sui::clock::{Self, Clock};
    use sui::event;
    use sui::object::{Self, UID, ID};
    use sui::transfer;
    use sui::tx_context::TxContext;
    use sui::url::{Self, Url};
    use sui::vec_set::{Self, VecSet};
    use sui_nft_box::admin::{Contract, assert_admin};
    use sui::table::Table;
    use sui::table;

    // =================== Error =================

    const EWrongNotSamePhase: u64 = 1;
    const EWrongBoxOpenNotStart: u64 = 2;
    const EWrongNonceUsed: u64 = 3;

    // =================== Struct =================
    /// Box config
    struct BoxConfig has key, store {
        id: UID,
        phase: u8,
        name: String,
        description: String,
        img_url: Url,
        box_price: u64,
        open_time: u64,
        nonce_used: VecSet<u64>,
        claimed_coupon: Table<address, u64>,
    }

    // =================== Event =================

    struct CreateBoxConfigEvent has copy, drop {
        box_config_id: ID,
        phase: u8,
        name: String,
        description: String,
        img_url: Url,
        box_price: u64,
        open_time: u64,
    }

    struct ModifyBoxConfigEvent has copy, drop {
        box_config_id: ID,
        phase: u8,
        name: String,
        description: String,
        img_url: Url,
        box_price: u64,
        open_time: u64,
    }

    // =================== Function =================

    public fun get_box_name(box: &BoxConfig): String {
        box.name
    }

    public fun get_box_description(box: &BoxConfig): String {
        box.description
    }

    public fun get_box_img_url(box: &BoxConfig): Url {
        box.img_url
    }

    public fun get_box_price(box: &BoxConfig): u64 {
        box.box_price
    }

    /// Check phase config and box config has the same phase
    public fun assert_box_same_phase(phase: u8, box_config: &BoxConfig) {
        assert!(phase == box_config.phase, EWrongNotSamePhase);
    }

    /// Check box nft and box config has the same phase
    public fun assert_nft_same_phase(phase: u8, box_config: &BoxConfig) {
        assert!(phase == box_config.phase, EWrongNotSamePhase);
    }

    /// Check can open box: now timestamp >= open time
    public fun assert_can_open_box(box_config: &BoxConfig, clock: &Clock) {
        let now_timestamp = clock::timestamp_ms(clock) / 1000;
        assert!(now_timestamp >= box_config.open_time, EWrongBoxOpenNotStart);
    }

    public fun assert_nonce_used(box_config: &mut BoxConfig, nonce: u64) {
        assert!(!vec_set::contains(&box_config.nonce_used, &nonce), EWrongNonceUsed);

        vec_set::insert(&mut box_config.nonce_used, nonce);
    }

    /// Create Box config
    public entry fun create_box_config(
        contract: &Contract,
        phase: u8,
        name: String,
        description: String,
        img_url: String,
        box_price: u64,
        open_time: u64,
        ctx: &mut TxContext
    ) {
        assert_admin(contract, ctx);

        let img_url = url::new_unsafe_from_bytes(*bytes(&img_url));

        let id = object::new(ctx);
        event::emit(CreateBoxConfigEvent {
            box_config_id: object::uid_to_inner(&id),
            phase,
            name,
            description,
            img_url,
            box_price,
            open_time,
        });

        transfer::share_object(BoxConfig {
            id,
            phase,
            name,
            description,
            img_url,
            box_price,
            open_time,
            nonce_used: vec_set::empty(),
            claimed_coupon: table::new(ctx),
        });
    }

    /// Modify Box NFT config
    public entry fun modify_box_config(
        box_config: &mut BoxConfig,
        contract: &Contract,
        phase: u8,
        name: String,
        description: String,
        img_url: String,
        box_price: u64,
        open_time: u64,
        ctx: &mut TxContext
    ) {
        assert_admin(contract, ctx);

        let img_url = url::new_unsafe_from_bytes(*bytes(&img_url));

        box_config.phase = phase;
        box_config.name = name;
        box_config.description = description;
        box_config.img_url = img_url;
        box_config.box_price = box_price;
        box_config.open_time = open_time;

        let id = &box_config.id;
        event::emit(ModifyBoxConfigEvent {
            box_config_id: object::uid_to_inner(id),
            phase,
            name,
            description,
            img_url,
            box_price,
            open_time,
        });
    }

    public fun get_user_claim_record(box_config: &BoxConfig, address: address): u64 {
        *table::borrow(&box_config.claimed_coupon, address)
    }

    public entry fun add_coupon_claim_record(box_config: &mut BoxConfig, amount: u64, address: address) {
        table::add(&mut box_config.claimed_coupon, address, amount);
    }

    public entry fun remove_coupon_claim_record(box_config: &mut BoxConfig, address: address) {
        table::remove(&mut box_config.claimed_coupon, address);
    }
}
