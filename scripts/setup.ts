import {
	Ed25519Keypair,
	JsonRpcProvider,
	devnetConnection,
	RawSigner,
	TransactionBlock,
	testnetConnection, DEFAULT_ED25519_DERIVATION_PATH,
} from "@mysten/sui.js";
import { bcs, serU82U8Vector } from './bcsUtil'
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

interface PackageInfo {
  packageId?: string;
  objectId?: string;
}

const packageId = process.env.PACKAGE_ID || "";
const contractId = process.env.CONTRACT_ID || "";
const phaseId = process.env.PHASE_ID || "";

/**
 * 设置合约新 Owner
 * @param contract
 * @param new_owner
 */
async function set_contract_owner(contract: string, new_owner: string) {
  try {
    const tx = new TransactionBlock();
    // const gasBudget = await provider.getReferenceGasPrice()
    // tx.setGasBudget(defaultGasBudget);
    const txn = await tx.moveCall({
      target: `${packageId}::admin::set_contract_owner`,
      arguments: [tx.object(contract), tx.pure(new_owner)],
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

/**
 * 创建盲盒配置
 */
async function create_box_config(boxId: number) {
  try {
    const tx = new TransactionBlock();
    tx.setGasBudget(defaultGasBudget);
    tx.moveCall({
      target: `${packageId}::box_config::create_box_config`,
      arguments: [
        // contract ID
        tx.object(contractId),
        // phase
        tx.pure(boxId, "u8"),
        // box_name
        tx.pure("AI ANIMO Mystery Box", "string"),
        // box_description
        tx.pure("The boxes come with varying rarity levels. By harnessing the unmatched scalability of the Sui Network for efficient transaction processing and storage. We have bundled three different assets - AI ANIMO characters, Starryverse 3D virtual spaces, and Sui token packages - into each box", "string"),
        // box_image
        tx.pure(
          "https://starrynift.s3.ap-southeast-1.amazonaws.com/web/img/sui-mysterybox.png",
          "string"
        ),
        // box_price
        tx.pure(0, "u64"),
        // open_time
        tx.pure(Math.ceil(new Date().getTime() / 1000 + 86400 * 120), "u64"),
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
    console.log("box config", digest, transaction);
    if (effects && effects.created && effects.created[0]) {
      return effects.created[0].reference?.objectId;
    }
    return null;
  } catch (err) {
    console.log(err);
    return null;
  }
}

/**
 *
 * create_avatar_nft_config(
 *   contract: &Contract,
 *   name: String,
 *   description: String,
 *   img_url: String,
 *   can_mint: bool,
 *   asset_id: String,
 *)
 * */
async function create_avatar_nft_config({
  name,
  description,
  image,
  canMint = true,
}: {
  name: string;
  description: string;
  image: string;
  canMint?: boolean;
}) {
  try {
    const tx = new TransactionBlock();
    tx.setGasBudget(defaultGasBudget);
    tx.moveCall({
      target: `${packageId}::nft_config::create_avatar_nft_config`,
      arguments: [
        // contract ID
        tx.object(contractId),
        // name
        tx.pure(name, "string"),
        // description
        tx.pure(description, "string"),
        // box_image
        tx.pure(image, "string"),
        // can_mint
        tx.pure(canMint, "bool"),
        // asset_id
        tx.pure("asset id", "string"),
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
    if (effects && effects.created && effects.created[0]) {
      return effects.created[0].reference?.objectId;
    }
    return null;
  } catch (err) {
    console.log(err);
    return null;
  }
}

async function create_space_nft_config({
  name,
  description,
  image,
  canMint = true,
}: {
  name: string;
  description: string;
  image: string;
  canMint?: boolean;
}) {
  try {
    const tx = new TransactionBlock();
    tx.setGasBudget(defaultGasBudget);
    tx.moveCall({
      target: `${packageId}::nft_config::create_space_nft_config`,
      arguments: [
        // contract ID
        tx.object(contractId),
        // name
        tx.pure(name, "string"),
        // description
        tx.pure(description, "string"),
        // box_image
        tx.pure(image, "string"),
        // can_mint
        tx.pure(canMint, "bool"),
        // scene_id TODO
        tx.pure(1, "u8"),
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
    if (effects && effects.created && effects.created[0]) {
      return effects.created[0].reference?.objectId;
    }
    return null;
  } catch (err) {
    console.log(err);
    return null;
  }
}

async function create_coupon_nft_config({
  name,
  description,
  image,
  amount,
  canMint = true,
}: {
  name: string;
  description: string;
  image: string;
  amount: number;
  canMint: boolean;
}) {
  try {
    const tx = new TransactionBlock();
    tx.setGasBudget(defaultGasBudget);
    tx.moveCall({
      target: `${packageId}::nft_config::create_coupon_nft_config`,
      arguments: [
        // contract ID
        tx.object(contractId),
        // name
        tx.pure(name, "string"),
        // description
        tx.pure(description, "string"),
        // box_image
        tx.pure(image, "string"),
        // can_mint
        tx.pure(canMint, "bool"),
        // TODO symbol
        tx.pure("SUI", "string"),
        // TODO amount
        tx.pure(amount, "u64"),
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
    if (effects && effects.created && effects.created[0]) {
      return effects.created[0].reference?.objectId;
    }
    return null;
  } catch (err) {
    console.log(err);
    return null;
  }
}

async function add_or_modify_phase_config() {
  try {
    const tx = new TransactionBlock();
    tx.setGasBudget(defaultGasBudget);
    tx.moveCall({
      target: `${packageId}::phase_config::add_or_modify_phase_config`,
      arguments: [
        // phase ID
        tx.object(phaseId),
        // contract ID
        tx.object(contractId),
        // phaseId
        tx.pure(1, "u8"),
        // allow_public_mint
        tx.pure(true, "bool"),
        // startTime
        tx.pure(0, "u64"),
        tx.pure(Math.ceil(new Date().getTime() / 1000 + 86400 * 30), "u64"),
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
    console.log("add_or_modify_phase_config", digest, transaction);
    if (effects && effects.created && effects.created[0]) {
      return effects.created[0].reference?.objectId;
    }
    return null;
  } catch (err) {
    console.log(err);
    return null;
  }
}

async function set_contract_signer_public_key() {
  try {
    const tx = new TransactionBlock();
    tx.setGasBudget(defaultGasBudget);
    tx.moveCall({
      target: `${packageId}::admin::set_contract_signer_public_key`,
      arguments: [
        // contract ID
        tx.object(contractId),
	      tx.pure(bcs.ser(['vector', BCS.U8], publicKey.toBytes()).toBytes())
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

    const { effects } = executedTx;
		const status = effects?.status
	  if (status?.status === 'failure') {
			console.log('set_contract_signer_public_key failed', status.error)
	  } else {
		  console.log('set_contract_signer_public_key success')
	  }
  } catch (err) {
    console.log(err);
    return null;
  }
}

async function set_current_phase(currentPhase: number) {
  try {
    const tx = new TransactionBlock();
    tx.setGasBudget(defaultGasBudget);
    tx.moveCall({
      target: `${packageId}::phase_config::set_current_phase`,
      arguments: [
        // phase ID
        tx.object(phaseId),
        // contract ID
        tx.object(contractId),
        //
        tx.pure(currentPhase, "u8"),
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
	  const status = effects?.status
	  if (status?.status === 'failure') {
		  console.log('set_current_phase failed', status.error)
	  } else {
		  console.log('set_current_phase success')
	  }
  } catch (err) {
    console.log(err);
    return null;
  }
}

async function add_nft_item() {
  if (nftMetadataList.length === 0) {
    return;
  }

	let metadataList = []

  for (let { name, category, description, amount, rarity, image } of nftMetadataList) {
    switch (category) {
      case 1: // avatar
        {
          const objectId = await create_avatar_nft_config({
            name,
            description,
            image,
          });
	        metadataList.push({ name, objectId, category, rarity });
					console.log(JSON.stringify(metadataList))
        }
        break;
      case 2: // space
        {
          const objectId = await create_space_nft_config({
            name,
            description,
            image,
          });
	        metadataList.push({ name, objectId, category, rarity });
					console.log(JSON.stringify(metadataList))
        }
        break;
      case 3:
        {
          const objectId = await create_coupon_nft_config({
            name,
            description,
            image,
            amount: amount || 0,
            canMint: true,
          });
	        metadataList.push({ name, objectId, category, rarity });
					console.log(JSON.stringify(metadataList))
        }
        break;
      default:
        {
          const objectId = await create_coupon_nft_config({
            name,
            description,
            image,
            amount: 0,
            canMint: false,
          });
	        metadataList.push({ name, objectId, category, rarity });
					console.log(JSON.stringify(metadataList))
        }
        break;
    }
  }

	return metadataList
}

async function fetchDeployInfo(digest: string) {
	const txBlock = await provider.getTransactionBlock({
		digest,
		options: {
			showInput: true,
			showEffects: true,
			showEvents: true,
			showObjectChanges: true,
		}
	})

	const objectChanges: any = txBlock?.objectChanges
	const packageId = objectChanges.find((item:any) => item.type === 'published').packageId
	const collectionId = objectChanges.find((item:any) => item.type === 'created' && item.objectType.includes('::Collection')).objectId
	const contractId = objectChanges.find((item:any) => item.type === 'created' && item.objectType.includes('::Contract')).objectId
	const upgradeCap = objectChanges.find((item:any) => item.type === 'created' && item.objectType.includes('::UpgradeCap')).objectId
	const phaseId = objectChanges.find((item:any) => item.type === 'created' && item.objectType.includes('::Phase')).objectId


console.log(`
PACKAGE_ID=${packageId}
COLLECTION_ID=${collectionId}
CONTRACT_ID=${contractId}
UPGRADE_CAP=${upgradeCap}
PHASE_ID=${phaseId}
`)
}

const queryPhaseConfig = async function () {
  const address = await signer.getAddress();
  const provider = new JsonRpcProvider(testnetConnection);

  const { data } = await provider.getObject({
    id: "0x0971c1164c43062441e0d128809d8dc2c33d50af1332e625200db3d159500370",
    options: { showType: true, showContent: true },
  });

  return data
};

async function main() {
	const new_owner = await signer.getAddress();

	await fetchDeployInfo('DQu9TSYdbVrxnCZVrQa5LAQmGf8tQYKXjNr1WF7G5pEu')

	// await set_contract_signer_public_key();
	// await add_or_modify_phase_config();
	// await set_current_phase(1);
	//

	// boxid2 digest 9jZ4XrfautyBMYMAJapodT9cQqQSCFm396uy5S3TLc2p
	// boxid2 boxid  0x3baadf5c7f760e18856019a5bd829cbc5ed40d17a43ecb1cb2e7fae9e2c74604
	// const boxConfigId = await create_box_config(1);
	// console.log({ boxConfigId });

	const metadataList = await add_nft_item();
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(`error: ${error.stack}`);
    process.exit(1);
  });
