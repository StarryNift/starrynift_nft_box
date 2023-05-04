module starrynift_nft_box::ecdsa {
    use std::vector;

    use sui::address;
    use sui::bcs;
    use sui::ed25519;
    use sui::object::{Self, ID};

    const EINVAILID_MINT_SIGNATURE: u64 = 0;
    const EINVAILID_OPEN_BOX_SIGNATURE: u64 = 1;

    // public fun keccak256(data: &vector<u8>): vector<u8> {
    //     hash::keccak256(data)
    // }

    public fun ed25519_verify(signature: &vector<u8>, public_key: &vector<u8>, msg: &vector<u8>): bool {
        ed25519::ed25519_verify(signature, public_key, msg)
    }

    // public fun ed25519_sign_mint_data(buyer: address, phase: u8, nonce: u64): vector<u8> {
    //     let signed_data = vector::empty<u8>();
    //     // let nonceu64 = bcs::peel_u64(&mut bcs::new(nonce));
    //     vector::append(&mut signed_data, address::to_bytes(buyer));
    //     vector::push_back(&mut signed_data, phase);
    //     vector::append(&mut signed_data, bcs::to_bytes(&nonce));
    //
    //     signed_data
    // }

    // public fun ed25519_designed_data(buyer: address, phase: u8, nonce: u64): u64 {
    //     let signed_data = vector::empty<u8>();
    //     vector::append(&mut signed_data, address::to_bytes(buyer));
    //     vector::push_back(&mut signed_data, phase);
    //     vector::append(&mut signed_data, bcs::to_bytes(&nonce));
    //
    //     nonce
    // }

    public fun verify_mint_data(
        buyer: address,
        phase: u8,
        nonce: u64,
        signature: vector<u8>,
        public_key: vector<u8>
    ): bool {
        let signed_data = vector::empty<u8>();

        vector::append(&mut signed_data, address::to_bytes(buyer));
        vector::push_back(&mut signed_data, phase);
        vector::append(&mut signed_data, bcs::to_bytes(&nonce));

        ed25519::ed25519_verify(&signature, &public_key, &signed_data)
    }

    public fun verify_open_box_data(
        mysteryBoxId: &ID,
        templateId1: &ID,
        templateId2: &ID,
        templateId3: &ID,
        signature: vector<u8>,
        public_key: vector<u8>
    ): bool {
        let signed_data = vector::empty<u8>();
        vector::append(&mut signed_data, object::id_to_bytes(mysteryBoxId));
        vector::append(&mut signed_data, object::id_to_bytes(templateId1));
        vector::append(&mut signed_data, object::id_to_bytes(templateId2));
        vector::append(&mut signed_data, object::id_to_bytes(templateId3));

        ed25519::ed25519_verify(&signature, &public_key, &signed_data)
    }

    // public fun secp256k1_ecrecover(signature: &vector<u8>, msg: &vector<u8>, hash: u8): vector<u8> {
    //     ecdsa_k1::secp256k1_ecrecover(signature, msg, hash)
    // }

    // public fun decompress_pubkey(pubkey: &vector<u8>): vector<u8> {
    //     ecdsa_k1::decompress_pubkey(pubkey)
    // }

    // public fun secp256k1_verify(signature: &vector<u8>, public_key: &vector<u8>, msg: &vector<u8>, hash: u8): bool {
    //     ecdsa_k1::secp256k1_verify(signature, public_key, msg, hash)
    // }

    public fun assert_mint_signature_valid(
        buyer: address,
        phase: u8,
        nonce: u64,
        signature: vector<u8>,
        public_key: vector<u8>
    ) {
        assert!(verify_mint_data(buyer, phase, nonce, signature, public_key), EINVAILID_MINT_SIGNATURE)
    }

    public fun assert_open_box_signature_valid(
        mysteryBoxId: &ID,
        templateId1: &ID,
        templateId2: &ID,
        templateId3: &ID,
        signature: vector<u8>,
        public_key: vector<u8>
    ) {
        assert!(verify_open_box_data(
            mysteryBoxId,
            templateId1,
            templateId2,
            templateId3,
            signature,
            public_key
        ), EINVAILID_MINT_SIGNATURE)
    }
}
