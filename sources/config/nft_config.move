module sui_nft_box::nft_config {
    use std::option::{Self, Option};
    use std::string::{String, bytes};

    use sui::event;
    use sui::object::{Self, UID, ID, uid_to_inner, uid_as_inner};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::url::{Self, Url};
    use sui_nft_box::admin::{Contract, assert_admin};

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

    struct CreateNFTConfigEvent has copy, drop {
        id: ID,
        name: String,
        description: String,
        img_url: Url,
        attributes: Attributes,
    }

    // =================== Function =================

    public fun get_nft_name(nft_config: &NFTConfig): String {
        nft_config.name
    }

    public fun get_nft_description(nft_config: &NFTConfig): String {
        nft_config.description
    }

    public fun get_nft_id(nft_config: &NFTConfig): &ID {
        uid_as_inner(&nft_config.id)
    }

    public fun get_nft_img(nft_config: &NFTConfig): Url {
        nft_config.img_url
    }

    public fun get_coupon_amount(coupon: &CouponNFT): u64 {
        coupon.attributes.amount
    }

    // public fun burn_coupon(coupon: &CouponNFT) {
    //     object::delete(coupon.id);
    // }

    /// Mint NFT to user
    public fun mint_nft(nft_config: &NFTConfig, ctx: &mut TxContext) {
        if (option::is_some(&nft_config.attributes.avatar) && nft_config.can_mint) {
            let avatar = option::borrow(&nft_config.attributes.avatar);

            let avatar_nft = AvatarNFT {
                id: object::new(ctx),
                name: nft_config.name,
                description: nft_config.description,
                img_url: nft_config.img_url,
                attributes: *avatar
            };

            transfer::transfer(avatar_nft, tx_context::sender(ctx));
        } else if (option::is_some(&nft_config.attributes.space) && nft_config.can_mint) {
            let space = option::borrow(&nft_config.attributes.space);

            let space_nft = SpaceNFT {
                id: object::new(ctx),
                name: nft_config.name,
                description: nft_config.description,
                img_url: nft_config.img_url,
                attributes: *space
            };

            transfer::transfer(space_nft, tx_context::sender(ctx));
        } else if (option::is_some(&nft_config.attributes.coupon) && nft_config.can_mint) {
            let coupon = option::borrow(&nft_config.attributes.coupon);

            let coupon_nft = CouponNFT {
                id: object::new(ctx),
                name: nft_config.name,
                description: nft_config.description,
                img_url: nft_config.img_url,
                attributes: *coupon
            };

            transfer::transfer(coupon_nft, tx_context::sender(ctx));
        };
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
