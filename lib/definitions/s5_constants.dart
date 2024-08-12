// ! CID types
// These bytes are carefully selected to make the base58 and base32 representations of different CID types
// easy to distinguish and not collide with anything on https://github.com/multiformats/multicodec
import 'dart:typed_data';

const cidTypeRaw = 0x26;
const cidTypeMetadataMedia = 0xc5;
// const cidTypeMetadataFile = 0xc6;
const cidTypeMetadataDirectory = 0x5d;

const cidTypeMetadataWebApp = 0x59;
const cidTypeResolver = 0x25;

const cidTypeUserIdentity = 0x77;

const cidTypeBridge = 0x3a;

// format for dynamic encrypted CID
// type algo key resolver_type mkey_ed255 pubkey
// in entry: encrypt(RAW CID or MEDIA or SOMETHING)

/// Used for immutable encrypted files and metadata formats, key can never be re-used
///
/// Used for file versions in Vup
const cidTypeEncryptedStatic = 0xae;

/// Used for encrypted files with update support
///
/// can point to resolver CID, Stream CID, Directory Metadata or Media Metadata object
const cidTypeEncryptedDynamic = 0xad;

const registryS5CIDByte = 0x5a;
const registryS5EncryptedByte = 0x5e;

// ! some multicodec bytes
// BLAKE3 with default output size of 256 bits
const mhashBlake3Default = 0x1f;

const mkeyEd25519 = 0xed;

const encryptionAlgorithmXChaCha20Poly1305 = 0xa6;
const encryptionAlgorithmXChaCha20Poly1305NonceSize = 24;
const encryptionAlgorithmXChaCha20Poly1305KeySize = 32;

final contentPackFileHeader = Uint8List.fromList(
  [0x5f, 0x26, 0x73, 0x35],
);

// ! metadata files

// used as the first byte of metadata files
const metadataMagicByte = 0x5f;

// types for metadata files
const metadataTypeMedia = 0x02;
const metadataTypeWebApp = 0x03;
const metadataTypeDirectory = 0x04;
const metadataTypeProofs = 0x05;
const metadataTypeUserIdentity = 0x07;

const parentLinkTypeUserIdentity = 1;
const parentLinkTypeBoard = 5;
const parentLinkTypeBridgeUser = 10;

const registryMaxDataSize = 64;

// ! user identity

const authPayloadVersion1 = 0x01;

const userIdentityLinkProfile = 0x00;
const userIdentityLinkPublicFileSystem = 0x01;
// const userIdentityLinkFollowingList = 0x02;

// ! p2p protocol message types

const protocolMethodHandshakeOpen = 1;
const protocolMethodHandshakeDone = 2;

const protocolMethodSignedMessage = 10;

const protocolMethodHashQuery = 4;
const protocolMethodAnnouncePeers = 8;
const protocolMethodRegistryQuery = 13; // 0x0d

const recordTypeStorageLocation = 0x05; // cache until TTL
const recordTypeRegistryEntry = 0x07; // permanent
const recordTypeStreamMessage = 0x08; // temporary?
const protocolMethodMessageQuery = 0x49; // 0x0e

// ! Some optional metadata extensions (same for files, media files and directories)

// List<String>, license identifier from https://spdx.org/licenses/
const metadataExtensionLicenses = 11;

// List<Uint8List>, multicoded pubkey that references a registry entry that contains donation links and addresses
const metadataExtensionDonationKeys = 12;

// map string->map, external ids of this object by their wikidata property id.
const metadataExtensionWikidataClaims = 13;

// List<String>, for example [en, de, de-DE]
const metadataExtensionLanguages = 14;

// List<String>,
const metadataExtensionSourceUris = 15;

// Resolver CID, can be used to update this post. can also be used to "delete" a post.
const metadataExtensionUpdateCID = 16;

// List<CID>, lists previous versions of this post
const metadataExtensionPreviousVersions = 17;

// unix timestamp in milliseconds
const metadataExtensionTimestamp = 18;

const metadataExtensionTags = 19;
const metadataExtensionCategories = 20;

// video, podcast, book, audio, music, ...
const metadataExtensionViewTypes = 21;

const metadataExtensionBasicMediaMetadata = 22;

const metadataExtensionBridge = 23;

const metadataExtensionOriginalTimestamp = 24;

// List<Uint8List>
const metadataExtensionRoutingHints = 25;

// TODO comment to / reply to (use parents)
// TODO mentions (use new extension field)
// TODO Reposts (just link the original item)

// ! media details
const metadataMediaDetailsDuration = 10;
const metadataMediaDetailsIsLive = 11;
const metadataMediaDetailsWasLive = 12;

// ! metadata proofs
const metadataProofTypeSignature = 1;
const metadataProofTypeTimestamp = 2;

// ! storage locations
const storageLocationTypeArchive = 0;
const storageLocationTypeFile = 3;
const storageLocationTypeFull = 5;
const storageLocationTypeBridge = 7;
