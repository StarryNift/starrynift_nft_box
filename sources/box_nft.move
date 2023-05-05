module sui_nft_box::box_nft {
    use std::string::String;

    use sui::clock::Clock;
    use sui::coin::{Self, Coin};
    use sui::event;
    use sui::object::{Self, ID, UID, uid_as_inner, id};
    use sui::sui::SUI;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::url::Url;
    use sui_nft_box::admin::{Contract, get_receiver, assert_not_freeze, get_signer_public_key, assert_admin};
    use sui_nft_box::box_config::{BoxConfig, assert_box_same_phase, assert_can_open_box, get_box_name, get_box_description, get_box_img_url, get_box_price, assert_nonce_used, add_coupon_claim_record, remove_coupon_claim_record, get_user_claim_record};
    use sui_nft_box::ecdsa::{assert_mint_signature_valid, assert_open_box_signature_valid};
    use sui_nft_box::nft_config::{NFTConfig, mint_nft, get_nft_id, CouponNFT, burn_coupon, get_coupon_amount};
    use sui_nft_box::phase_config::{Phase, assert_phase_in_progress, get_current_phase, get_phase_config, assert_can_public_mint};
    use sui::transfer::public_transfer;
    use sui::package::receipt_cap;

    const EINSUFFIENT_PAID: u64 = 1;

    struct MysteryBox has key, store {
        id: UID,
        name: String,
        description: String,
        phase: u8,
        url: Url,
    }

    struct BoxInfo has key, store {
        id: UID,
        minted: u64,
        opened: u64,
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

    /// Init Box info
    fun init(ctx: &mut TxContext) {
        transfer::share_object(BoxInfo {
            id: object::new(ctx),
            minted: 0,
            opened: 0,
        });
    }

    public entry fun private_buy_box(
        phase: &mut Phase,
        contract: &mut Contract,
        box_config: &mut BoxConfig,
        box_info: &mut BoxInfo,
        clock: &Clock,
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
            url: get_box_img_url(box_config),
        };

        event::emit(
            BuyBoxNFTEvent {
                box_id: object::uid_to_inner(&box.id),
                phase: get_current_phase(phase),
                buyer: sender,
                box_price: get_box_price(box_config),
            }
        );
        transfer::transfer(box, sender);

        box_info.minted = box_info.minted + 1;
    }

    public entry fun buy_box(
        phase: &Phase,
        contract: &Contract,
        box_config: &BoxConfig,
        box_info: &mut BoxInfo,
        clock: &Clock,
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
        if (box_price > 0) {
            let paid_balance = coin::value(&paid);
            assert!(box_price == paid_balance, EINSUFFIENT_PAID);
            // Pay SUI to contract.receiver
            transfer::public_transfer(paid, get_receiver(contract));
        } else {
            transfer::public_transfer(paid, get_receiver(contract));
        };

        // Mint Box NFT to user
        let sender = tx_context::sender(ctx);

        let box = MysteryBox {
            id: object::new(ctx),
            name: get_box_name(box_config),
            description: get_box_description(box_config),
            phase: current_phase,
            url: get_box_img_url(box_config),
        };

        event::emit(
            BuyBoxNFTEvent {
                box_id: object::uid_to_inner(&box.id),
                phase: get_current_phase(phase),
                buyer: sender,
                box_price: get_box_price(box_config),
            }
        );

        transfer::transfer(box, sender);

        box_info.minted = box_info.minted + 1;
    }

    public entry fun open_box(
        contract: &Contract,
        box_config: &BoxConfig,
        mystery_box: MysteryBox,
        box_info: &mut BoxInfo,
        clock: &Clock,
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

        // Mint NFT by NFT combination list
        let MysteryBox { id, name: _, description: _, url: _, phase } = mystery_box;

        // Mint nft
        mint_nft(template1, ctx);
        mint_nft(template2, ctx);
        mint_nft(template3, ctx);

        event::emit(
            OpenBoxNFTEvent {
                box_id: object::uid_to_inner(&id),
                phase,
                user: tx_context::sender(ctx),
            }
        );

        // Burn user minted box
        object::delete(id);

        box_info.opened = box_info.opened + 1;
    }

    public entry fun claimCoupon(
        phase: &Phase,
        coupon: CouponNFT,
        boxConfig: &mut BoxConfig,
        ctx: &mut TxContext)
    {
        let sender = tx_context::sender(ctx);
        let amount = get_coupon_amount(&coupon);
        let phaseIndex = get_current_phase(phase);

        assert_box_same_phase(phaseIndex, boxConfig);

        // check role
        add_coupon_claim_record(
            boxConfig, amount, sender
        );
        burn_coupon(coupon);
    }

    public fun fundCoupon(
        phase: &Phase,
        contract: &Contract,
        boxConfig: &mut BoxConfig,
        paid: Coin<SUI>,
        reciever: address,
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);
        assert_admin(contract, ctx);

        let phaseIndex = get_current_phase(phase);

        assert_box_same_phase(phaseIndex, boxConfig);

        let amount = get_user_claim_record(boxConfig, reciever);

        assert!(amount == coin::value(&paid), EINSUFFIENT_PAID);

        // check role
        remove_coupon_claim_record(
            boxConfig, sender
        );
        transfer::public_transfer(paid, reciever);
    }
}
