module starrynift_nft_box::ecdsa {
    use std::vector;

    use sui::address;
    use sui::bcs;
    use sui::ed25519;
    use sui::object::{Self, ID};

    const EINVAILID_MINT_SIGNATURE: u64 = 0;
    const EINVAILID_OPEN_BOX_SIGNATURE: u64 = 1;


    public fun ed25519_verify(signature: &vector<u8>, public_key: &vector<u8>, msg: &vector<u8>): bool {
        ed25519::ed25519_verify(signature, public_key, msg)
    }

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
        ), EINVAILID_OPEN_BOX_SIGNATURE)
    }
}
