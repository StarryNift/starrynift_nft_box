module starrynift_nft_box::nft_config {
    use std::option::{Self, Option};
    use std::string::{String, bytes};

    use starrynift_nft_box::admin::{Contract, assert_admin};
    use sui::event;
    use sui::object::{Self, UID, ID, uid_to_inner, uid_as_inner};
    use sui::transfer;
    use sui::tx_context::TxContext;
    use sui::url::{Self, Url};

    // =================== Struct =================

    /// Avatar attribute for config
    struct Avatar has copy, store, drop {
        asset_id: String,
    }

    /// Space attribute for config
    struct Space has copy, store, drop {
        scene_id: u8,
    }

    /// Coupon attribute for config
    struct Coupon has copy, store, drop {
        symbol: String,
        amount: u64,
    }

    /// Option attributes
    struct Attributes has copy, store, drop {
        avatar: Option<Avatar>,
        space: Option<Space>,
        coupon: Option<Coupon>,
    }

    /// NFT config
    struct NFTConfig has key, store {
        id: UID,
        name: String,
        description: String,
        img_url: Url,
        can_mint: bool,
        attributes: Attributes,
    }

    // =================== Event =================

    struct CreateNFTConfigEvent has copy, drop {
        id: ID,
        name: String,
        description: String,
        img_url: Url,
        attributes: Attributes,
    }

    // =================== Function =================

    public fun get_nft_id(nft_config: &NFTConfig): &ID {
        uid_as_inner(&nft_config.id)
    }

    public fun get_nft_name(nft_config: &NFTConfig): String {
        nft_config.name
    }

    public fun get_nft_description(nft_config: &NFTConfig): String {
        nft_config.description
    }

    public fun get_nft_img_url(nft_config: &NFTConfig): Url {
        nft_config.img_url
    }

    public fun get_nft_can_mint(nft_config: &NFTConfig): bool {
        nft_config.can_mint
    }

    public fun get_nft_avatar_attributes(nft_config: &NFTConfig): &Option<Avatar> {
        &nft_config.attributes.avatar
    }

    public fun get_nft_space_attributes(nft_config: &NFTConfig): &Option<Space> {
        &nft_config.attributes.space
    }

    public fun get_nft_coupon_attributes(nft_config: &NFTConfig): &Option<Coupon> {
        &nft_config.attributes.coupon
    }

    /// Create avatar NFT config
    public entry fun create_avatar_nft_config(
        contract: &Contract,
        name: String,
        description: String,
        img_url: String,
        can_mint: bool,
        asset_id: String,
        ctx: &mut TxContext,
    ) {
        assert_admin(contract, ctx);

        let img_url = url::new_unsafe_from_bytes(*bytes(&img_url));

        let id = object::new(ctx);
        event::emit(CreateNFTConfigEvent {
            id: uid_to_inner(&id),
            name,
            description,
            img_url,
            attributes: Attributes {
                avatar: option::some(Avatar {
                    asset_id
                }),
                space: option::none(),
                coupon: option::none(),
            },
        });

        let nft_config = NFTConfig {
            id,
            name,
            description,
            img_url,
            can_mint,
            attributes: Attributes {
                avatar: option::some(Avatar {
                    asset_id
                }),
                space: option::none(),
                coupon: option::none(),
            },
        };

        transfer::share_object(nft_config);
    }

    /// Create space NFT config
    public entry fun create_space_nft_config(
        contract: &Contract,
        name: String,
        description: String,
        img_url: String,
        can_mint: bool,
        scene_id: u8,
        ctx: &mut TxContext,
    ) {
        assert_admin(contract, ctx);

        let img_url = url::new_unsafe_from_bytes(*bytes(&img_url));

        let id = object::new(ctx);
        event::emit(CreateNFTConfigEvent {
            id: uid_to_inner(&id),
            name,
            description,
            img_url,
            attributes: Attributes {
                avatar: option::none(),
                space: option::some(Space {
                    scene_id
                }),
                coupon: option::none(),
            },
        });

        let nft_config = NFTConfig {
            id,
            name,
            description,
            img_url,
            can_mint,
            attributes: Attributes {
                avatar: option::none(),
                space: option::some(Space {
                    scene_id
                }),
                coupon: option::none(),
            },
        };

        transfer::share_object(nft_config);
    }

    /// Create coupon NFT config
    public entry fun create_coupon_nft_config(
        contract: &Contract,
        name: String,
        description: String,
        img_url: String,
        can_mint: bool,
        symbol: String,
        amount: u64,
        ctx: &mut TxContext,
    ) {
        assert_admin(contract, ctx);

        let img_url = url::new_unsafe_from_bytes(*bytes(&img_url));

        let id = object::new(ctx);
        event::emit(CreateNFTConfigEvent {
            id: uid_to_inner(&id),
            name,
            description,
            img_url,
            attributes: Attributes {
                avatar: option::none(),
                space: option::none(),
                coupon: option::some(Coupon {
                    symbol,
                    amount,
                }),
            },
        });

        let nft_config = NFTConfig {
            id,
            name,
            description,
            img_url,
            can_mint,
            attributes: Attributes {
                avatar: option::none(),
                space: option::none(),
                coupon: option::some(Coupon {
                    symbol,
                    amount,
                }),
            },
        };

        transfer::share_object(nft_config);
    }
}
