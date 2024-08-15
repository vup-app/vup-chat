use flutter_rust_bridge::frb;
use openmls::prelude::tls_codec::{Deserialize, Serialize};
pub use openmls::prelude::*;
pub use openmls_basic_credential::SignatureKeyPair;
use openmls_memory_storage::MemoryStorage;
use openmls_rust_crypto::RustCrypto;
pub use std::borrow::Borrow;
use std::io::Cursor;
pub use std::sync::RwLock;

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
}

// TODO Replace unwrap() with expect() everywhere

#[frb(opaque)]
pub struct MLSCredential {
    pub credential_with_key: CredentialWithKey,
    pub signer: SignatureKeyPair,
}

#[frb(opaque)]
pub struct OpenMLSConfig {
    pub ciphersuite: Ciphersuite,
    pub backend: MyOpenMlsRustCrypto,
    pub credential_type: CredentialType,
    pub signature_algorithm: SignatureScheme,
    pub mls_group_create_config: MlsGroupCreateConfig,
}

pub fn openmls_init_config(keystore_dump: Vec<u8>) -> OpenMLSConfig {
    // TODO Maybe use MLS_128_DHKEMX25519_CHACHA20POLY1305_SHA256_Ed25519
    let ciphersuite = Ciphersuite::MLS_128_DHKEMX25519_AES128GCM_SHA256_Ed25519;

    // TODO Tweak these settings
    let mls_group_create_config = MlsGroupCreateConfig::builder()
        // .padding_size(100)
        .sender_ratchet_configuration(SenderRatchetConfiguration::new(
            50,   // out_of_order_tolerance
            1000, // maximum_forward_distance
        ))
        .use_ratchet_tree_extension(true)
        .max_past_epochs(5)
        // TODO wire_format_policy
        .build();

    /*     let mls_group_create_config = MlsGroupCreateConfig::builder()
    // .padding_size(100)
    .sender_ratchet_configuration(SenderRatchetConfiguration::new(
        50,   // out_of_order_tolerance
        1000, // maximum_forward_distance
    ))
    .use_ratchet_tree_extension(true)
    .max_past_epochs(5)
    .build(); */

    let backend = if !keystore_dump.is_empty() {
        println!("[keystore] load existing");
        let mut cursor = Cursor::new(keystore_dump);
        MyOpenMlsRustCrypto {
            crypto: RustCrypto::default(),
            key_store: MemoryStorage::deserialize(&mut cursor).unwrap(),
        }
    } else {
        println!("[keystore] init empty");
        MyOpenMlsRustCrypto::default()
    };

    OpenMLSConfig {
        ciphersuite: ciphersuite,
        backend: backend,
        credential_type: CredentialType::Basic,
        signature_algorithm: ciphersuite.signature_algorithm(),
        mls_group_create_config: mls_group_create_config,
    }
}

#[derive(Default)]
#[frb(opaque)]
pub struct MyOpenMlsRustCrypto {
    crypto: RustCrypto,
    key_store: MemoryStorage,
}

#[frb(opaque)]
impl OpenMlsProvider for MyOpenMlsRustCrypto {
    type CryptoProvider = RustCrypto;
    type RandProvider = RustCrypto;
    type StorageProvider = MemoryStorage;

    fn storage(&self) -> &Self::StorageProvider {
        &self.key_store
    }

    fn crypto(&self) -> &Self::CryptoProvider {
        &self.crypto
    }

    fn rand(&self) -> &Self::RandProvider {
        &self.crypto
    }
}

pub fn openmls_keystore_dump(config: &OpenMLSConfig) -> Vec<u8> {
    let mut bytes = vec![];
    config.backend.storage().serialize(&mut bytes);
    bytes
}

pub fn openmls_generate_credential_with_key(
    identity: Vec<u8>,
    config: &OpenMLSConfig,
) -> MLSCredential {
    let credential = Credential::new(config.credential_type, identity);
    let signature_keys = SignatureKeyPair::new(config.signature_algorithm)
        .expect("Error generating a signature key pair.");

    // Store the signature key into the key store so OpenMLS has access
    // to it.
    signature_keys
        .store(config.backend.storage())
        .expect("Error storing signature keys in key store.");

    MLSCredential {
        credential_with_key: CredentialWithKey {
            credential,
            signature_key: signature_keys.public().into(),
        },
        signer: signature_keys,
    }
}

pub fn openmls_signer_get_public_key(signer: &SignatureKeyPair) -> Vec<u8> {
    signer.to_public_vec()
}

pub fn openmls_recover_credential_with_key(
    identity: Vec<u8>,
    public_key: Vec<u8>,
    config: &OpenMLSConfig,
) -> MLSCredential {
    let credential = Credential::new(config.credential_type, identity);

    let signature_keys = SignatureKeyPair::read(
        config.backend.storage(),
        &public_key,
        config.signature_algorithm,
    )
    .expect("Error generating a signature key pair.");

    MLSCredential {
        credential_with_key: CredentialWithKey {
            credential,
            signature_key: signature_keys.public().into(),
        },
        signer: signature_keys,
    }
}

// A helper to create key package bundles.
pub fn openmls_generate_key_package(
    signer: &SignatureKeyPair,
    credential_with_key: &CredentialWithKey,
    config: &OpenMLSConfig,
) -> Vec<u8> {
    // Create the key package
    let key_package = KeyPackage::builder()
        .build(
            config.ciphersuite,
            &config.backend,
            &*signer,
            (*credential_with_key).clone(),
        )
        .unwrap();

    key_package
        .key_package()
        .tls_serialize_detached()
        .expect("Error serializing key_package")
}

pub fn openmls_group_create(
    signer: &SignatureKeyPair,
    credential_with_key: &CredentialWithKey,
    config: &OpenMLSConfig,
) -> RwLock<MlsGroup> {
    let group = MlsGroup::new(
        &config.backend,
        &*signer,
        &config.mls_group_create_config,
        (*credential_with_key).clone(),
    )
    .expect("An unexpected error occurred.");
    RwLock::new(group)
}

pub struct MLSGroupAddMembersResponse {
    pub mls_message_out: Vec<u8>,
    pub welcome_out: Vec<u8>,
    // pub ratchet_tree: Vec<u8>,
}

pub fn openmls_group_add_member(
    group: &RwLock<MlsGroup>,
    signer: &SignatureKeyPair,
    key_package: Vec<u8>,
    config: &OpenMLSConfig,
) -> MLSGroupAddMembersResponse {
    let mut group_rw = match group.write() {
        Ok(guard) => guard,
        Err(poisoned) => poisoned.into_inner(),
    };

    let kp = KeyPackageIn::tls_deserialize_exact(&mut key_package.as_slice())
        .expect("Could not deserialize KeyPackage")
        .validate(config.backend.crypto(), ProtocolVersion::Mls10)
        .expect("Invalid KeyPackage");

    let (mls_message_out, welcome_out, _) = group_rw
        .add_members(&config.backend, &*signer, &[kp])
        .expect("Could not add members.");

    group_rw
        .merge_pending_commit(&config.backend)
        .expect("error merging pending commit");

    let serialized_mls_message = mls_message_out
        .tls_serialize_detached()
        .expect("Error serializing mls_message");

    let serialized_welcome = welcome_out
        .tls_serialize_detached()
        .expect("Error serializing welcome");

    MLSGroupAddMembersResponse {
        mls_message_out: serialized_mls_message,
        welcome_out: serialized_welcome,
        /*  ratchet_tree: group_rw
        .export_ratchet_tree()
        .tls_serialize_detached()
        .expect("Error serializing ratchet_tree"), */
    }
}

pub fn openmls_group_create_message(
    group: &RwLock<MlsGroup>,
    signer: &SignatureKeyPair,
    message: Vec<u8>,
    config: &OpenMLSConfig,
) -> Vec<u8> {
    let mut group_rw = match group.write() {
        Ok(guard) => guard,
        Err(poisoned) => poisoned.into_inner(),
    };

    let mls_message_out = group_rw
        .create_message(&config.backend, &*signer, &message)
        .expect("Error creating application message.");

    mls_message_out
        .tls_serialize_detached()
        .expect("Error serializing welcome")
}

pub fn openmls_group_join(
    welcome_in: Vec<u8>,
    // ratchet_tree: Vec<u8>,
    config: &OpenMLSConfig,
) -> RwLock<MlsGroup> {
    // de-serialize the message as an [`MlsMessageIn`] ...
    let mls_message_in = MlsMessageIn::tls_deserialize_exact(&mut welcome_in.as_slice())
        .expect("An unexpected error occurred.");

    // inspect the message.
    let welcome = match mls_message_in.extract() {
        MlsMessageBodyIn::Welcome(welcome) => welcome,
        // We know it's a welcome message, so we ignore all other cases.
        _ => unreachable!("Unexpected message type."),
    };

    let group = StagedWelcome::new_from_welcome(
        &config.backend,
        &config.mls_group_create_config.join_config(),
        welcome,
        None,
    )
    .expect("Failed to create staged join")
    .into_group(&config.backend)
    .expect("Failed to create MlsGroup");

    /*   // join the group.
    let group = MlsGroup::new_from_welcome(
        &config.backend,
        &config.mls_group_create_config.join_config(),
        welcome,
        // The public tree is usually needed and transferred out of band.
        // But we are currently using the [`RatchetTreeExtension`], so not needed
        None,
        //Some(group.export_ratchet_tree().into()),
    )
    .expect("Error joining group from Welcome"); */
    RwLock::new(group)
}

pub struct ProcessIncomingMessageResponse {
    pub is_application_message: bool,
    pub application_message: Vec<u8>,
    pub identity: Vec<u8>,
    pub sender: Vec<u8>,
    pub epoch: u64,
}

pub fn openmls_group_process_incoming_message(
    group: &RwLock<MlsGroup>,
    mls_message_in: Vec<u8>,
    config: &OpenMLSConfig,
) -> ProcessIncomingMessageResponse {
    let message_in = MlsMessageIn::tls_deserialize_exact(&mut mls_message_in.as_slice())
        .expect("Could not deserialize message.");

    let mut group_rw = match group.write() {
        Ok(guard) => guard,
        Err(poisoned) => poisoned.into_inner(),
    };

    let protocol_message: ProtocolMessage = match message_in.extract() {
        MlsMessageBodyIn::PrivateMessage(m) => m.into(),
        MlsMessageBodyIn::PublicMessage(m) => m.into(),
        _ => panic!("This is not an MLS message."),
    };
    let processed_message = group_rw
        .process_message(&config.backend, protocol_message)
        .expect("Could not process unverified message.");
    let processed_message_credential: Credential = processed_message.credential().clone();
    let processed_message_sender = processed_message
        .sender()
        .tls_serialize_detached()
        .expect("failed to serialize sender");
    let processed_message_epoch: u64 = processed_message.epoch().as_u64();


    match processed_message.into_content() {
        ProcessedMessageContent::ApplicationMessage(application_message) => {
            /*  let sender_name = match self.contacts.get(processed_message_credential.identity()) {
                Some(c) => c.username.clone(),
                None => {
                    // Contact list is not updated right now, get the identity from the
                    // mls_group member
                    let user_id = group_rw.members().find_map(|m| {
                        if m.credential.identity() == processed_message_credential.identity()
                            && (self
                                .identity
                                .borrow()
                                .credential_with_key
                                .signature_key
                                .as_slice()
                                != m.signature_key.as_slice())
                        {
                            // log::debug!("update::Processing ApplicationMessage read sender name from credential identity for group {} ", group.group_name);
                            Some(str::from_utf8(m.credential.identity()).unwrap().to_owned())
                        } else {
                            None
                        }
                    });
                    user_id.unwrap_or("".to_owned())
                }
            }; */
            return ProcessIncomingMessageResponse {
                is_application_message: true,
                application_message: application_message.into_bytes(),
                identity: processed_message_credential.serialized_content().to_vec(),
                sender: processed_message_sender,
                epoch: processed_message_epoch,
            };
            /*   if group_name.is_none() || group_name.clone().unwrap() == group.group_name {
                messages_out.push(conversation_message.clone());
            } */
        }
        ProcessedMessageContent::ProposalMessage(_proposal_ptr) => {
            // intentionally left blank.
        }
        ProcessedMessageContent::ExternalJoinProposalMessage(_external_proposal_ptr) => {
            // intentionally left blank.
        }
        ProcessedMessageContent::StagedCommitMessage(_) => {
          /* commit_ptr   let mut remove_proposal: bool = false;
            if commit_ptr.self_removed() {
                remove_proposal = true;
            }
            group_rw
                .merge_staged_commit(&config.backend, *commit_ptr)
                .expect("failed to merge_staged_commit");

            // TODO some things missing here */
        }
    }
    // TODO Only save when needed
    //if group_rw.state_changed() == InnerState::Changed {
    /*     group_rw
    .save(&config.backend)
    .expect("Error saving group state"); */
    // }
    return ProcessIncomingMessageResponse {
        is_application_message: false,
        application_message: vec![],
        identity: vec![],
        epoch: 0,
        sender: processed_message_sender,
    };
    /*  if let ProcessedMessageContent::ApplicationMessage(application_message) =
        processed_message.into_content()
    {
        return application_message.into_bytes();
    } else {
        panic!("Expected application message");
    } */
    //    processed_message.
}

/* #[derive(PartialEq)]
pub enum PostUpdateActions {
    None,
    Remove,
} */

pub fn openmls_group_save(group: &RwLock<MlsGroup>, config: &OpenMLSConfig) -> Vec<u8> {
    // let mut group_rw = group.write().unwrap();

    let mut group_rw = match group.write() {
        Ok(guard) => guard,
        Err(poisoned) => poisoned.into_inner(),
    };

    // TODO Save state!
    /*   group_rw
    .save(&config.backend)
    .expect("Error saving group state"); */

    group_rw.group_id().as_slice().to_vec()
}

pub fn openmls_group_load(id: Vec<u8>, config: &OpenMLSConfig) -> RwLock<MlsGroup> {
    let group = MlsGroup::load(config.backend.storage(), &GroupId::from_slice(&id))
        .unwrap()
        .unwrap();

    RwLock::new(group)
}

pub struct GroupMember {
    pub identity: Vec<u8>,
    pub index: u32,
    pub signature_key: Vec<u8>,
}

pub fn openmls_group_list_members(group: &RwLock<MlsGroup>) -> Vec<GroupMember> {
    let group_ro = match group.read() {
        Ok(guard) => guard,
        Err(poisoned) => poisoned.into_inner(),
    };

    let mut members = vec![];
    for member in group_ro.members() {
        members.push(GroupMember {
            identity: member.credential.serialized_content().to_vec(),
            index: member.index.u32(),
            signature_key: member.signature_key,
        });

        // identity: processed_message_credential.identity().to_vec(),
    }
    members
}

/* pub fn openmls_group_add_members(
    group: &RwLock<MlsGroup>,
    signer: RustOpaque<SignatureKeyPair>,
    key_packages: Vec<Vec<u8>>,
    config: &OpenMLSConfig,
) -> OpenMLSGroupAddMembersResponse {
    let mut group_rw = group.write().unwrap();

    let key_packages_native: Vec<KeyPackage> = key_packages
        .iter()
        .map(|kp| {
            KeyPackageIn::tls_deserialize(&mut kp.as_slice())
                .expect("Could not deserialize KeyPackage")
                .validate(config.backend.crypto(), ProtocolVersion::Mls10)
                .expect("Invalid KeyPackage")
        })
        .collect();

    let (mls_message_out, welcome_out, group_info) = group_rw
        .add_members(&config.backend, &*signer, &key_packages_native)
        .expect("Could not add members.");

    // Sasha merges the pending commit that adds Maxim.
    group_rw
        .merge_pending_commit(&config.backend)
        .expect("error merging pending commit");

    OpenMLSGroupAddMembersResponse {  }
} */

/* impl openmls_traits::Signer for RustOpaque<SignatureKeyPair> {
    type SignatureType = Signature; // Replace this with the correct type

    fn sign(&self, payload: &[u8]) -> Result<Self::SignatureType, SignatureError> {
        self.arc.sign(payload)
    }

    // Add other methods from the Signer trait and implement them similarly
} */


// Custom struct for the KeyStore to have more control over it (export/restore)
/*
#[derive(Clone)]

#[frb(opaque)]
pub struct MyMemoryKeyStore {
    pub values: Arc<RwLock<HashMap<Vec<u8>, Vec<u8>>>>,
}

impl OpenMlsKeyStore for MyMemoryKeyStore {
    /// The error type returned by the [`OpenMlsKeyStore`].
    type Error = MyMemoryKeyStoreError;

    /// Store a value `v` that implements the [`ToKeyStoreValue`] trait for
    /// serialization for ID `k`.
    ///
    /// Returns an error if storing fails.
    fn store<V: MlsEntity>(&self, k: &[u8], v: &V) -> Result<(), Self::Error> {
        let value = serde_json::to_vec(v).map_err(|_| MyMemoryKeyStoreError::SerializationError)?;
        // We unwrap here, because this is the only function claiming a write
        // lock on `credential_bundles`. It only holds the lock very briefly and
        // should not panic during that period.
        let mut values = self.values.write().unwrap();
        values.insert(k.to_vec(), value);
        Ok(())
    }

    /// Read and return a value stored for ID `k` that implements the
    /// [`FromKeyStoreValue`] trait for deserialization.
    ///
    /// Returns [`None`] if no value is stored for `k` or reading fails.
    fn read<V: MlsEntity>(&self, k: &[u8]) -> Option<V> {
        // We unwrap here, because the two functions claiming a write lock on
        // `init_key_package_bundles` (this one and `generate_key_package_bundle`) only
        // hold the lock very briefly and should not panic during that period.
        let values = self.values.read().unwrap();
        if let Some(value) = values.get(k) {
            serde_json::from_slice(value).ok()
        } else {
            None
        }
    }

    /// Delete a value stored for ID `k`.
    ///
    /// Returns an error if storing fails.
    fn delete<V: MlsEntity>(&self, k: &[u8]) -> Result<(), Self::Error> {
        // We just delete both ...
        let mut values = self.values.write().unwrap();
        values.remove(k);
        Ok(())
    }
}

/// Errors thrown by the key store.
#[derive(thiserror::Error, Debug, Copy, Clone, PartialEq, Eq)]
pub enum MyMemoryKeyStoreError {
    #[error("The key store does not allow storing serialized values.")]
    UnsupportedValueTypeBytes,
    #[error("Updating is not supported by this key store.")]
    UnsupportedMethod,
    #[error("Error serializing value.")]
    SerializationError,
}

#[frb(opaque)]
pub struct MyOpenMlsRustCrypto {
    crypto: RustCrypto,
    key_store: MyMemoryKeyStore,
}

impl OpenMlsCryptoProvider for MyOpenMlsRustCrypto {
    type CryptoProvider = RustCrypto;
    type RandProvider = RustCrypto;
    type KeyStoreProvider = MyMemoryKeyStore;

    fn crypto(&self) -> &Self::CryptoProvider {
        &self.crypto
    }

    fn rand(&self) -> &Self::RandProvider {
        &self.crypto
    }

    fn key_store(&self) -> &Self::KeyStoreProvider {
        &self.key_store
    }
}
 */
