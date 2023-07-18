import {
	Ed25519Keypair,
	JsonRpcProvider,
	RawSigner,
	TransactionBlock,
	DEFAULT_ED25519_DERIVATION_PATH, Connection,
} from "@mysten/sui.js";

let isReleasing = false
require("dotenv").config();

const MNEMONICS: string = process.env.MNEMONICS || "";
const provider = new JsonRpcProvider(new Connection({
	fullnode: 'https://explorer-rpc.mainnet.sui.io:443'
}));
const keypair_ed25519 = Ed25519Keypair.deriveKeypair(
	MNEMONICS,
	DEFAULT_ED25519_DERIVATION_PATH
);
const {setTimeout: wait} = require("timers/promises");
const signer = new RawSigner(keypair_ed25519, provider);
const fs = require('fs')

async function airdropGas() {
	const userList: string[] = [
		// "0x7b4d92b18d2ffb721a6ddcfae8908c79d13bad273ea3644bf554de14371fef57",
		// "0x7001cb8b1f9300f538bdc46384e5cbb3efa10b37ca6b63f17dd98ad6ea9764ae",
		// "0xa568be650373102b6eb16f6e8f238412bd7bad7ab11a6b69143ccc496879020e",
		// "0x7a020bbe1e06ad5f6e22dba320bcadae91dc7cd23d10917e90da677ce7092be5",
		// "0x4398beb1c6ea1932f8d8bad1a14f9499a3c4e29e79802509687e5e019033fc4d",
		// "0xdc096b41e5e793060ec4c4f8aacf3f8879041137ecd0dfb2f32bc3ab41736025",
		// "0x614209187af7cf6ecd477ac99070ecd528d9ecbc899ef864f93a08ef23d6eaf0","0x7984b0350d7f3a29735f435f7cdef925ddbadd41e93ffda585274258eaf19555","0xe9dc0df71b88e0eee687e74d32e58567c98fa2b4265dda9c7f1d4df70dfab5b1","0xaf480ea5131d22ce1675c059e50b3cb6ad085ab2b7bbc550dd0cf62f866b84b0","0x99df4359b8e7474a8c440f224f4a4589070d6b37ca48520575a7289648ad7c30","0x846007b7f0600b42463f1453ed608c82dfcc9724a2b008ed9288e0fec57565b4","0x692fa0192d8e8b3d1823bb45a805ebbc7a16d57b3da02b8c9a891aa6dc1a732e","0x86abfd95bc51a37c3acda2e3e7822c1c75d8c8862c9522c647160049e5442549","0x64a64863f1f6fc14261b247aef72921552d6be48c3060f07679c6fc907aef7e8","0xfd0762293f6840bc5be80d9c8d10957f507eec1c15b283f72d289c18747617b0","0x7b04a6f3481d0162d4d5162e545fb522f008070e2b80b99826a2a9d0c5ec8519","0x444877506faaa24dfff73fc884e57ebe68bb895efee64eec6a83a3d742ebf33c","0x944914c4c9182d9a6d90b168d02118da7a28fd24f14e2bcee24afe0b0551e0f6","0xa4ca1ec6a2e021b46d8145cc70645fb9a65e5fd9c63178fb48cbcb4b57f79df7","0xa35ff7d93eb6593c84bc2f01211b3a7fcf4c082e4a98f421e90d1fa58cb2c85b","0xd0651291191fd6180fb18c1c7d1be6d6bf6a525d6b77640c795b17f9cf362609","0x11e1f238ddd986ef056351eda7ffe060fd072a30680376c8bf56c794335cb19d","0x56bf5618c632c1966c511d8fae8a478c3103d2106d6d6ae72070171fc9f005e8","0xf71b4ac27bcf73003fa3ffd2809cd37ed78c03b1381993fead22511dfb31aac6","0x3cf45997e3dc43b30d4ac1bbe79e2408b0414f21a277fc90f04da79eae1e6a4c","0xd35377dab3a325a0e3e9a38245c61a1a8ebd26b9dd6ed682cd03edbd507507a7","0x0838a63f3e9eb7a016ffab1573721bea143e86b83df02f8304dcc287781d067b","0xcec796d3ddbb0ad489bf7b8c6271da7fd035b5352413c61add6cb025f2bf5dff","0x3febf2a946dd685cb5669270d712f223114eae6923d6054d2046113d6aced391","0xca04494b8151433d8eda242c2c3fa0c666af6ec32d86220bca66ea5276f51918",
		// "0x6f88153b99116cc46c006e7563e20a02ae628d2b0aae764e1f726fc7cd0c686f",
		// "0xbb9a2e84a50d671ae8655dab354c2e6072b0f58019194b52973003c280614608","0x9671b9911345cc10c6b86138d221934ca1ff0177b1132c71650417b03461854c","0xd921af03fb4666279ccac30a170a74335c6f7a2ed7ab664bfa6e5f392fb6ab29","0xce7f6577bc6648b1eaaffe6896e8f16aca8cb76865facee260eb54affc5e1576","0x0ade9351e435b5f2b9393106c635208b922fe7f6de5a6a3b40e155aabbf4d1af","0x885e4a3ddc073129273a00af3432668eaea39b644b29a61218aa5fef6c92f5b8","0xd9d20b6ed1361447977d2ffb662e9a8109ee5665f46c492ec67d6d0218309c07","0xbeba1908580ea08918c045a0d0357dd07e68b5d242c6f5d9e28ddfb8e6af4036","0x213badb8d59d2e56648e64fe84dd6db39948ce9e79e5145770321293810da528","0x0037b62ac70711a94c4ca6db838cbd3d37e9f12bbba92ba472136ff0879d18d4","0xd35377dab3a325a0e3e9a38245c61a1a8ebd26b9dd6ed682cd03edbd507507a7","0x72faaef37f777244dc2de376d5ba8b420884f633f4ba8f65998a9aed4de17c3e","0xb1bcdff7f20be1b7b7270bec208f50ba749fd0e63792514da982b03f3bb48d5d","0x04e6a0799ceaec3138651d2388b7b25dcd01d8f145264fceebae190a1ae14a97","0x272c2c8abdfd12579427500ba6127491713ecee34f896b1c42e2807447075725","0x8a605e5dcdd0c3056f8d0f7dcfe5560347b68e3bd3b57df18ce2033da3a6732b","0x2db545e6e0fb027c9bc3bc3ba52c4113b8d7ead01e57a7c0a20c7a9e990a9dda","0xf1d1a5ee28bcdc7f02a118a316b67cbdae14de17d8c5a3b88be4c4afa2ff578a","0x90bb619378c2e4cf9401284922dedd80259d1fdc1d3b62f0f1f1fb61388118bf","0xde62d31ea757cb8a995dadc7ce3e64ed8550744f812974dcd89fcc980d1e3849","0x5ae2bc3b711eeea5a1fe3db933f4757ec39ba130d5f0a647bb71239d0d62428f","0x255806dcb180d74626c16dfec94bdf2bc36f527d89636ee59dba34689d0ce780","0xf64569efffdeff399cd511df2546af441c6671b90957bf2c777bcd269f937365","0xbcacd6ecc47a54dd07544607e4e0addc7051c8c88b47f3b9dec03ed2d4606a33","0xb95bd04926626a40c022cc55ff2d4ae9970e918dc40f20c551f72dd598413d72","0x9e473ffc4de2a7a08601a3a5997289e1db203200046d57722eb6188d30ab7d40","0xdfb6eaa8ca852ae228d0b288b9ed7662965cd02f0f52a57c21476e662fa28d68","0x06910ee33e80180fb9777410364fe61e12c78577bce29e1f01c76400dab2cf53","0x82bdbb5114790fd336d070033a09e2a358ccb86546a1c2a68ef146f6f98ebf6b","0x10046b0035059c1fabac4cc5b6cd7e56ec5385467de027cdc5f0c7ab7ad4c244","0x464d861343787d7583fdad627d5bb5fd332b0111485bbbbc2e0c3059abb77e9f","0x5306164edf18ee67277c416b1191874a35b85e25ec9a78565c255a8f81bbb087","0x80f391eb95b7bf6b0c608f0bafdbf5f7258ad55d268e7c6f8f21a6e7e3898ec2","0x652b8f9e59be65a80637785b2ea36a57ec3cc5bd7cbaaddd3cf842aa55f7f808","0x0d9e9460382d801560af79e3fdfafe4d21e82f0cc4c50695b1fc83ca83a9bc8c","0x52507a40e42da4d6fd21716c2a6039f803d0f1619e6ffd8efd7115313d6b5a51","0xee34dd0bcd6c4743e3877f5ce76629f0f936e4a85a0d8c508648574fb4059117","0x2ff7beb93930e2ca584edb99ec99c3ef43894191d369da87b5a83519b256452f","0x602aa680484462587af6f554c719134cd0623fe68c5e5ce853e544695a8adb93","0x0eed6b619895ba31cf5e9009ce8ebf7ad47551287d7471542c1ac0e43a63d168","0x47349678e101ed77a43e28c119c5a4045145124748090d1003971ddb0e67681e","0x75a7256ef8313fdadcaad6010e3d82e7527bd8143a50259bd60a021a93683a74","0xe83a3b8cfc372b0d45bad07a7b278fd576b062489787d15ef719c65fa5214a99","0xdb222d1cc1a23c8466115b89a56d7d9357f6908fc212ea7387672775a37f646a","0xe5a54dd17cd8425b33fc17e7ae463bad6cfad44161e67af9b6392202fc732927","0xb078bb2540dcb7838e14d0034fb2b90de209ddbbbdf7ce6bec3df6a435e0a593","0x43a2a94f293cd5cb1eb0ebaf4a469ca3488712e91035cd25c1dfbbab1049b53b","0xf487621f7d561db4f4d97f27e7f5470435ccddb4a88d228348c2cc5b4257802f","0xf62e06cb07376aee9fd9dc324d584744d55da7739882d5eeaec0035dbb65c0a3","0xd12a19bed21040a12d45a170ddf2b2471ce2c66f7b94bb0dc7224646546670c5","0x8f2e9784e2f16a89007213d4dca1bfd5722f21ff96a4efff90d505f71bc2bd6a","0x241be7d1fdbf47659621c41d626c165f7cd8da20ca80ed7cf0c64d5339fd4a5d","0xacda1345d8cc7d84e24de29ac1ea0bed56f4db82ebc62c343ed6ba9b65e61c88","0x125fc6ea05bbccaab006a73f6b0f7ff55fb8863756198a15480bc6b6e9065864","0x9a98804283250a1442840b7797202f6f7c34c3693b38bad1dffb127f87a76a74","0x60b6471af83472dad706f628557d95cd18c55bd9796047498057bc94344f351e","0x70f88385b80770d0e92a54e5563a5529613a33410ee17d79ee11ec5d0c30970d","0x35e093e0a82bce25db91dd13456662eda748c8df8994c9be230dcd798caed62d","0x35e093e0a82bce25db91dd13456662eda748c8df8994c9be230dcd798caed62d","0x63aaab78a33d12d1280c05ccb57b859b290b7e38e237db817511bf51628f7a6f","0xb7175ce2cdee8ef4392b1cb3e28b03f9e5268465907ccec1512345fc8147171c","0x08223c5534439f59183ef0b56946ec03f00e2ab7700b6bcac7b382eca3a66a7f","0x8e0483cf1e9d68e8ddbe010cfbdbd4aefd26d6776fe92bf5abdb78c2b4c249d6","0xc099eff76922cf8cf16fdc101a378fec55dbdc8908b1fe4c576afd04748b487b","0x122a564a491bfb92f81c757e77021fd75aa61f61df40b47a4a9785bae4d3033a","0x48a494f4f858ec37c2659018bd5094eafe96dc10105b7c96c1281a5bff366621","0x163160da0f56bca8aa4d180f0b4e54166a2177b58edf97215b116136943cc1f1","0x88b1538cb66603bb782ce88321c6d33baa56eddd6341f9bd69b8e378a7ef6978","0xb071e5a316f0066570caef4e95ddb3e1c01d449595fc4a4e1647514c9552b1e1","0xf68e604c7bc6ef1f3ab58c0c60bd6ccfd78e2a47b8d69d5e1111e5777706613d","0x0004edc277768c676187b664acec63d44634f4c8fb1ac205ca8e046cfc16e98b","0x5a1b93cd5d4bc50a3e833b0760828a0dfe8b45a8d323bd7ee1bf3a60e643401b",
		// "0x590fcd185d5e21c57ea912f60dcf4e00c55995d81adc56d9bb39ea8c8ff7b81e","0xb2e7c1af26250b7839bb4b81dc415e877ba2d6c95e17a1a8c93a81ee1319689c","0xc3b21fe6364aae105759819729f8899e4e9f724bb952f9cba83a4746e50133fc","0xecdbf7ea282045454882a5c79ed6f7204f44ccda9aeaf6aa25011418032a9b92","0x1b29855ab88a79bc8f1b0f85471eb664926c55c66d7234764114ea80751bf570","0xa05d3fc8bb77557aca66aedb6833b4c91e45ac4fc59ce3cbd16358878c94be91","0xcba36f474cadd13aa9bc970650b1b47b9796ae6b12744cca38aec6794209420c","0x02095d29d988c6a9656eaec9be6d325ef0a50e709b96b528565c2f637db6886f","0x906b875eaeacffe261823efea672ffa183dc4bbcae1d2d6e8856627264a5ded5","0xeda79e3206dee97a8b3c4cd41ecdd66e6e4ed57fc5106c0a97756b398ed1c198","0x3e65cfe83333959aa61347bbd2aedcf1dc492fc00ef1a66a22d458a7144ee4ce","0x999f893f03611bbdcc2e7c586aa69c88210a60a9d80cdc9f6cf292c7127c4bbd","0x272f6b790c0cd21beb9886531b4dd2a26545df2ec84f8b16301febc1acfd3f7d","0xa00fc061cda5bab65d43261d2adabe07fb462fddf2c3df1d07ae22024ff0a27a","0xc831b83bb8623bef94e993b53ba20487d61d8bd6d21340ccbf68a82b529cd9a0","0xf2e3c74848ace7115de0c112cffe6d47609022d3ae11ad5c050cd18f44d1853f","0x2321bb5c77cbb15bf4293af3b014f6b38f67e45fba26d346527df6b000a8860a","0x10e9992d98c9f98e0f35ad7ec58d1154be7ab49d00e2005fd6085eaee0dae61a","0xd4bd7a86a6383170e5d0bb3b134f9ada90e5abc6e83c7bb566711f30ea075269","0xbeba1908580ea08918c045a0d0357dd07e68b5d242c6f5d9e28ddfb8e6af4036","0x3dd9a47e7343ac5a1dc600d8ccc3c13ea99b977a555dce6c3e9ee902363def14",
		// "0x7793e2bfef9bdd8d6a02cb3b4fd0939ef21a8e5ff5f02f6b709bf7582457eb68","0xabfd0564a80fd1e3d9df84b7694d18d8a1d5bbeea585cfc4dbe589c4ce3afb60","0x64100663c984a50e9c2ef8de3180c76f7e465609b5776551a41983b0891075e9","0x495df61577f69bbfabb9cfa7cfa72e0917d5c8c9c884995b2b3d69e98f2d203d","0xee022c0350daf384bd966b419a20b9f1352ccf75155b49b326156e344c732619","0x6924b9b62585368d7645ca7e710c63a5df4607e6c1b4ba5eb631907c80197125","0x3fef594f693c317296b907d7c451fa95b7be4611f2223034ebad99f4397c5886","0xd0fdf88171b8a364c8332fab363b7bc6dc6f2b9f2e8beec6e7ce8663ce4f08ca","0xa94c8871d1c93ab832205830ffab8c5a20f944b4acaa350cd655b68fcfee5a5c","0xd48aa38b378bff3751e9b3360e14cfa5a967cb97d3dac7648866f65ae68e01bb",
		// "0x7a44d5ca45b79813109e66da3903ca586cbaa38bdb8eaaa2190e826607f8faf9","0x06c293f50d8682a5253833302bbb0100d02caabf49e63f28d5a8c3c9235ae164","0x634f4c29457c95c01a8fafc28da9b9e11e62a4086482e9cd8e8403a810cbc31b","0x06d4b7ed061ea4804ec8c461ef6cfccf07948828f8be0612ce850b246255df48","0x992f7b771a60d9880d5654c39501b5f9223cbb096361b8ba2406a52f6a6faac9","0x368aeb1c1e1c1b3fab0bca718ca365f8e356a93effcf983a76c189ec266a164f",
	]

	const airdropSuiCoin = 0.1 * 10 ** 9
	try {
		for (let receiverAddress of userList) {
			// transfer gas cost: 0.00199588
			// const receiverAddress = publicKey.toSuiAddress()
			const tx = new TransactionBlock();
			const [coin] = tx.splitCoins(tx.gas, [tx.pure(airdropSuiCoin)]);
			tx.transferObjects([coin], tx.pure(receiverAddress, 'string'));
			const result = await signer.signAndExecuteTransactionBlock({
				transactionBlock: tx,
			});
			console.log('airdrop success', receiverAddress, {result});
			await wait(5000)
		}
	} catch (err) {
		console.log(err);
		return null;
	}
}

async function queryCouponLog(nextCursor?: any) {
	const provider = new JsonRpcProvider(new Connection({
		fullnode: 'https://explorer-rpc.mainnet.sui.io:443'
	}));

	const data: any = await provider.queryEvents({
		query: {
			MoveEventType: '0xc133bfc300c20a8b123c3b27b0da96aa1649b0800b639dce3b067c7e68c5c3d7::box_nft::ClaimCouponEvent'
		},
		cursor: nextCursor,
		limit: 50,
		order: "descending"
	})

	let list = []

	for (let item of data.data) {
		const txBlock: any = await provider.getTransactionBlock({
			digest: item.id.txDigest,
			options: {
				showInput: true,
				showEffects: true,
				showEvents: true,
				showObjectChanges: true,
			}
		})

		if (txBlock && !txBlock.objectChanges) {
			continue
		}

		const tableSource: any = await txBlock.objectChanges.find((item: any) => item.type === 'created' && item.objectType === '0x2::dynamic_field::Field<address, u64>')

		const {data: tableData} = await provider.getObject({
			id: tableSource.objectId,
			options: {showType: true, showContent: true, showDisplay: true},
		})

		const content: any = tableData
		list.push({
			sender: item.sender,
			value: content.content.fields.value
		})
	}

	return {
		list,
		cursor: data.nextCursor,
		hasNext: data.hasNextPage
	}
}

async function fetchAllRecord() {
	let nextCursor: any = null, hasNext = true
	let list: any[] = []
	do {
		const {list: _list, cursor, hasNext: _hasNext} = await queryCouponLog(nextCursor)

		hasNext = _hasNext

		list = list.concat(_list)
		nextCursor = cursor
	} while (nextCursor && hasNext)

	fs.writeFileSync('./totalClaim.json', JSON.stringify(list, null, 2))

	return list
}

async function releaseReward() {
	if (isReleasing) return
	isReleasing = true
	const list = await fetchAllRecord()

	// const userList: string[] = ["0x21716a61a3eeb0a61b505d73c2cc16225b071daffedf8d96bdf59d1ad10e4354"]
	const fundedUsers = require('../funded.json')
	const fundedLog = require('../fundedLog.json')
	try {
		for (let {
			sender: receiverAddress,
			value: amount,
		} of list) {
			if (fundedUsers.includes(receiverAddress)) {
				console.log('already funded', receiverAddress)
				continue
			}

			// const tx = new TransactionBlock();
			// const [coin] = tx.splitCoins(tx.gas, [tx.pure(amount * 10**9)]);
			// tx.transferObjects([coin], tx.pure(receiverAddress));
			// const result = await signer.signAndExecuteTransactionBlock({
			// 	transactionBlock: tx,
			// });
			//
			// fundedLog.push(result)
			// fundedUsers.push(receiverAddress)

			// fs.writeFileSync('./funded.json', JSON.stringify(fundedUsers, null, 2))
			// fs.writeFileSync('./fundedLog.json', JSON.stringify(fundedLog, null, 2))
			// console.log('airdrop success', receiverAddress, amount, {result});
			await wait(5000)
		}
	} catch (err) {
		console.log(err);
		return null;
	}

	isReleasing = false
}

async function main() {
	// await airdropGas()
	setInterval(async function() {
		try {
			await releaseReward()
		} catch(err) {
			console.log(err)
		}
	}, 1000 * 60 * 10)
	// await releaseReward()
}

main()
	.then(() => {
	})
	.catch((error) => {
		console.error(`error: ${error.stack}`);
		process.exit(1);
	});
