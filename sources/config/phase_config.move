module sui_nft_box::phase_config {
    use sui::clock::{Self, Clock};
    use sui::event;
    use sui::object::{Self, UID, ID};
    use sui::object_table::{Self, ObjectTable};
    use sui::transfer;
    use sui::tx_context::TxContext;
    use sui_nft_box::admin::{assert_admin, Contract};

    // =================== Error =================

    const EWrongTime: u64 = 1;
    const EWrongPhaseKeyNotExists: u64 = 2;
    const EWrongPhaseNotStart: u64 = 3;
    const EWrongPhaseEnded: u64 = 4;
    const EWrongPublicMintNotAllowed: u64 = 5;

    // =================== Struct =================

    /// Phase config
    struct PhaseConfig has key, store {
        id: UID,
        allow_public_mint: bool,
        start_time: u64,
        end_time: u64,
    }

    /// Phase
    struct Phase has key, store {
        id: UID,
        current_phase: u8,
        config: ObjectTable<u8, PhaseConfig>
    }

    // =================== Event =================

    struct SetCurrentPhaseEvent has copy, drop {
        current_phase: u8,
    }

    struct AddPhaseConfigEvent has copy, drop {
        id: ID,
        add_phase_id: ID,
        add_phase_key: u8,
        allow_public_mint: bool,
        start_time: u64,
        end_time: u64,
    }

    struct ModifyPhaseConfigEvent has copy, drop {
        id: ID,
        modify_phase_id: ID,
        modify_phase_key: u8,
        allow_public_mint: bool,
        start_time: u64,
        end_time: u64,
    }

    // =================== Function =================

    fun init(ctx: &mut TxContext) {
        transfer::share_object(Phase {
            id: object::new(ctx),
            current_phase: 0,
            config: object_table::new<u8, PhaseConfig>(ctx),
        });
    }

    fun assert_phase_time(start_time: u64, end_time: u64) {
        assert!(start_time < end_time, EWrongTime);
    }

    fun assert_phase_key_exists(config: &ObjectTable<u8, PhaseConfig>, key: u8) {
        assert!(object_table::contains(config, key), EWrongPhaseKeyNotExists);
    }

    public fun assert_can_public_mint(phase_config: &PhaseConfig) {
        assert!(phase_config.allow_public_mint, EWrongPublicMintNotAllowed);
    }

    public fun assert_phase_in_progress(phase: &Phase, clock: &Clock) {
        let config = get_phase_config(phase);

        let now_timestamp = clock::timestamp_ms(clock) / 1000;

        assert!(now_timestamp >= config.start_time, EWrongPhaseNotStart);
        assert!(now_timestamp <= config.end_time, EWrongPhaseEnded);
    }

    /// Get current phase option
    public fun get_current_phase(phase: &Phase): u8 {
        phase.current_phase
    }

    /// Get phase config by key
    public fun get_phase_config_by_key(config: &ObjectTable<u8, PhaseConfig>, key: u8): &PhaseConfig {
        assert_phase_key_exists(config, key);
        object_table::borrow(config, key)
    }

    /// Get phase config by key
    public fun get_phase_config(phase: &Phase): &PhaseConfig {
        let current_phase = phase.current_phase;

        let config = &phase.config;

        get_phase_config_by_key(config, current_phase)
    }

    /// Set current phase
    public entry fun set_current_phase(
        phase: &mut Phase,
        contract: &Contract,
        current_phase: u8,
        ctx: &mut TxContext,
    ) {
        assert_admin(contract, ctx);

        assert_phase_key_exists(&phase.config, current_phase);

        phase.current_phase = current_phase;

        event::emit(SetCurrentPhaseEvent {
            current_phase
        });
    }

    /// Add or modify phase config
    public entry fun add_or_modify_phase_config(
        phase: &mut Phase,
        contract: &Contract,
        add_or_modify_phase_id: u8,
        allow_public_mint: bool,
        start_time: u64,
        end_time: u64,
        ctx: &mut TxContext
    ) {
        assert_admin(contract, ctx);

        assert_phase_time(start_time, end_time);

        let phase_has_exists = object_table::contains(&phase.config, add_or_modify_phase_id);

        if (phase_has_exists) {
            // modify phase config
            let mut_config = object_table::borrow_mut(&mut phase.config, add_or_modify_phase_id);

            mut_config.allow_public_mint = allow_public_mint;
            mut_config.start_time = start_time;
            mut_config.end_time = end_time;

            event::emit(ModifyPhaseConfigEvent {
                id: object::uid_to_inner(&phase.id),
                modify_phase_id: object::uid_to_inner(&mut_config.id),
                modify_phase_key: add_or_modify_phase_id,
                allow_public_mint,
                start_time,
                end_time,
            });
        } else {
            let id = object::new(ctx);

            event::emit(AddPhaseConfigEvent {
                id: object::uid_to_inner(&phase.id),
                add_phase_id: object::uid_to_inner(&id),
                add_phase_key: add_or_modify_phase_id,
                allow_public_mint,
                start_time,
                end_time,
            });

            // table add phase config, key: add_phase, value: PhaseConfig
            object_table::add(&mut phase.config, add_or_modify_phase_id, PhaseConfig {
                id,
                allow_public_mint,
                start_time,
                end_time,
            });
        }
    }
}
