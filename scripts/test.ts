import {
	Ed25519Keypair,
	JsonRpcProvider,
	devnetConnection,
	RawSigner,
	TransactionBlock,
	testnetConnection, DEFAULT_ED25519_DERIVATION_PATH,
} from "@mysten/sui.js";
import { bcs } from './bcsUtil'
import {BCS} from "@mysten/bcs";
require("dotenv").config();
const nftMetadataList: any = require("../consts/Metadata.json");

const MNEMONICS: string = process.env.MNEMONICS || "";
const provider = new JsonRpcProvider(testnetConnection);
const keypair_ed25519 = Ed25519Keypair.deriveKeypair(
  MNEMONICS,
  DEFAULT_ED25519_DERIVATION_PATH
);
const signer = new RawSigner(keypair_ed25519, provider);
const publicKey = keypair_ed25519.getPublicKey();
const defaultGasBudget = 0.01 * 10 ** 9

const packageId = process.env.PACKAGE_ID || "";
const contractId = process.env.CONTRACT_ID || "";
const phaseId = process.env.PHASE_ID || "";
const boxConfigId = process.env.BOX_CONFIG_ID || "";
const boxInfoId = process.env.BOX_INFO_ID || "";

const avatarMintCap = process.env.AVATAR_MINT_CAP || "";
const spaceMintCap = process.env.SPACE_MINT_CAP || "";
const couponMintCap = process.env.COUPON_MINT_CAP || "";
const mysteryBoxMintCap = process.env.MYSTERY_BOX_MINT_CAP || "";


async function test_mint() {
	const data = {
		"address": "0x633c214f58faf05c8b7e07093ae5c368b1d59e0cffe9de53b31a46fad00fc89b",
		"phase": 1,
		"nonce": 24,
		"signature": "04c25a9370a0061fe51229f4e44d7558d74585b17843b2055008802d55e54a094e691a85b90239d39c06b265bdea25b6b2c4d51afd6178275e7361049b954b09"
	}

	try {
		const tx = new TransactionBlock();
		const txn = await tx.moveCall({
			target: `${packageId}::box_nft::private_buy_box`,
			arguments: [
				tx.object(phaseId),
				tx.object(contractId),
				tx.object(boxConfigId),
				tx.object(boxInfoId),
				tx.object("0x6"),
				tx.pure(data.nonce),
				tx.pure(
					bcs.ser(['vector', BCS.U8],
						Buffer.from(data.signature, 'hex')).toBytes()
				),
			],
		});

		const executedTx = await signer.signAndExecuteTransactionBlock({
			transactionBlock: tx,
			options: {
				showInput: true,
				showEffects: true,
				showEvents: true,
				showObjectChanges: true,
			},
		});
		const { digest, transaction, effects, events, errors } = executedTx;
		console.log(digest, transaction, effects, events);
	} catch (err) {
		console.log(err);
		return null;
	}
}

async function test_openbox() {
	const data = {
		"boxId": "0x7947f614220dd56cc4fec8778ac5d8a8f00e2feb0ad26689e0dade988fd6a1ac",
		"collections": [
			"0x2fa39599a7cecf3b1c3063f7f5d12d31cf9b6c9f11674c974f33ea0e9be8750e",
			"0x12dc1d07c55669eedc34563c895d213eb83cd31bc867a79fa8b8b1b8a40577b4",
			"0xc0acc6c7419c40be23eeef8d90aee12b87637a4c5bd3c5158698025a48a2c4bd"
		],
		"signature": "8341d4775e92d78866a54a71855c8b7233d19b764e8b57300e60bbcd58399b650b06e3b986dc95b2154e11aad0e3b91df4383a635b9eea6d7e56065cf564bc03"
	}

	const mysteryBoxId = "0x7947f614220dd56cc4fec8778ac5d8a8f00e2feb0ad26689e0dade988fd6a1ac"
	try {
		const tx = new TransactionBlock();
		const txn = await tx.moveCall({
			target: `${packageId}::box_nft::open_box`,
			arguments: [
				tx.object(contractId),
				tx.object(boxConfigId),
				tx.object(mysteryBoxId),
				tx.object(boxInfoId),
				tx.object("0x6"),
				tx.object(data.collections[0]),
				tx.object(data.collections[1]),
				tx.object(data.collections[2]),
				tx.pure(
					bcs.ser(['vector', BCS.U8],
						Buffer.from(data.signature, 'hex')).toBytes()
				),
			],
		});

		const executedTx = await signer.signAndExecuteTransactionBlock({
			transactionBlock: tx,
			options: {
				showInput: true,
				showEffects: true,
				showEvents: true,
				showObjectChanges: true,
			},
		});
		const { digest, transaction, effects, events, errors } = executedTx;
		console.log(digest, transaction, effects, events);
	} catch (err) {
		console.log(err);
		return null;
	}
}

async function test_freemint() {
	try {

		// [{"name":"Blank","objectId":"0xca224357fb6042e2fe20e9563bc3492b145b3a8d93bbbdbf0c68c9de3bb9cce7","category":0,"rarity":"R"},
		// {"name":"500 SUI Voucher","objectId":"0x724d14562e3ef268fa74e7fc774b8fe1b5a17351c680b66fe5266aa1900dcefe","category":3,"rarity":"UR"},
		// {"name":"20 SUI Voucher","objectId":"0xee80ab8897f3186be51ab49b12af3346583d855b4523f5462864b0bc9f69f07e","category":3,"rarity":"SR"},
		// {"name":"Premium Cyber Space","objectId":"0x7ad18ef43fc885636c180e2ba745d4b551745896b3316bc94f0cc558bdbcd2ba","category":2,"rarity":"UR"},{"name":"Aqua World Space","objectId":"0x50303cc28b9e786dd487a7fa85ae768991a5462e5f0826ca407b642012a836c1","category":2,"rarity":"R"}]

		const templateId = '0x7ad18ef43fc885636c180e2ba745d4b551745896b3316bc94f0cc558bdbcd2ba'

		console.log({
			templateId, avatarMintCap, spaceMintCap, couponMintCap
		})
		const tx = new TransactionBlock();
		const txn = await tx.moveCall({
			target: `${packageId}::box_nft::freemint`,
			arguments: [
				tx.object(templateId),
				tx.object(avatarMintCap),
				tx.object(spaceMintCap),
				tx.object(couponMintCap),
			],
		});

		const executedTx = await signer.signAndExecuteTransactionBlock({
			transactionBlock: tx,
			options: {
				showInput: true,
				showEffects: true,
				showEvents: true,
				showObjectChanges: true,
			},
		});
		const { digest, transaction, effects, events, errors } = executedTx;
		console.log(digest, transaction, effects, events);
	} catch (err) {
		console.log(err);
		return null;
	}
}

async function test_claim() {
	try {
		const couponId = "0x169dd19ec5e649aab5ffcc5e0d201cfa58b995838ca29b0d433b8645ab47d818"
		const tx = new TransactionBlock();
		await tx.moveCall({
			// public entry fun claimCoupon(
			// 	phase: &Phase,
			// coupon: CouponNFT,
			// boxConfig: &mut BoxConfig,
			target: `${packageId}::box_nft::claimCoupon`,
			arguments: [
				tx.object(phaseId),
				tx.object(couponId),
				tx.object(boxConfigId),
			],
		});

		const executedTx = await signer.signAndExecuteTransactionBlock({
			transactionBlock: tx,
			options: {
				showInput: true,
				showEffects: true,
				showEvents: true,
				showObjectChanges: true,
			},
		});
		const { digest, transaction, effects, events, errors } = executedTx;
		console.log(digest, transaction, effects, events);
	} catch (err) {
		console.log(err);
		return null;
	}
}

async function test_transfer_object(objectId: string, receiver: string) {
	const tx = new TransactionBlock();
	tx.transferObjects(
		[
			tx.object(
				objectId,
			),
		],
		tx.pure(receiver),
	);
	const result = await signer.signAndExecuteTransactionBlock({
		transactionBlock: tx,
	});

	console.log(result)
}

async function main() {
	// await test_openbox()
	// await test_transfer_object('0x342c2049583e18276b80cba6d6f069e57e1ca37b26e67aaa8971b6bc890d25b2',
	// 	'0x17e20dae7cc09979265e6f6b6f86fd8e6c3dd53b96dc9b264cb68bda468aa50b')

	// await test_claim()
	await test_freemint()
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(`error: ${error.stack}`);
    process.exit(1);
  });
