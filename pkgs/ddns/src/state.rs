use std::{borrow::Cow, collections::HashMap, net::IpAddr, sync::Arc};

use color_eyre::Result;
use subtle::ConstantTimeEq;
use tokio::sync::{OnceCell, RwLock};

use crate::cf::{
    create_record_for_domain, get_record_for_domain, get_zone_id_for_domain,
    overwrite_record_for_domain,
};

#[derive(Hash, PartialEq, Eq)]
struct EntryKey<'a> {
    domain: Cow<'a, str>,
    rec_type: &'static str,
}

impl EntryKey<'static> {
    fn owned(domain: &str, rec_type: &'static str) -> Self {
        EntryKey {
            domain: domain.to_string().into(),
            rec_type,
        }
    }
}

impl<'a> EntryKey<'a> {
    fn borrow(domain: &'a str, rec_type: &'static str) -> Self {
        EntryKey {
            domain: domain.into(),
            rec_type,
        }
    }
}

struct StateInner {
    secret: Vec<u8>,
    cf_key: String,
    domain: String,
    zone_id: OnceCell<String>,
    dns_entry_cache: RwLock<HashMap<EntryKey<'static>, String>>,
}

#[derive(Clone)]
pub struct Ddns(Arc<StateInner>);

impl Ddns {
    pub fn new(secret: Vec<u8>, domain: String, cf_key: String) -> Self {
        Ddns(Arc::new(StateInner {
            secret,
            cf_key,
            domain,
            zone_id: OnceCell::new(),
            dns_entry_cache: RwLock::default(),
        }))
    }

    pub fn check_secret(&self, secret: &[u8]) -> bool {
        self.0.secret.ct_eq(secret).into()
    }

    fn cf_key(&self) -> &str {
        &self.0.cf_key
    }

    async fn get_zone_id(&self) -> Result<&str> {
        self.0
            .zone_id
            .get_or_try_init(|| get_zone_id_for_domain(self.cf_key(), &self.0.domain))
            .await
            .map(String::as_str)
    }

    pub async fn set_record(&self, domain: &str, addr: IpAddr) -> Result<()> {
        let rec_type = match addr {
            IpAddr::V4(_) => "A",
            IpAddr::V6(_) => "AAAA",
        };
        let content = addr.to_string();
        let zone = self.get_zone_id().await?;
        if let Some(record) = self
            .0
            .dns_entry_cache
            .read()
            .await
            .get(&EntryKey::borrow(domain, rec_type))
        {
            overwrite_record_for_domain(self.cf_key(), zone, record, domain, rec_type, &content)
                .await?;
        } else {
            let record = if let Some(record) =
                get_record_for_domain(self.cf_key(), zone, domain, rec_type).await?
            {
                overwrite_record_for_domain(
                    self.cf_key(),
                    zone,
                    &record,
                    domain,
                    rec_type,
                    &content,
                )
                .await?;
                record
            } else {
                create_record_for_domain(self.cf_key(), zone, domain, rec_type, &content).await?
            };
            self.0
                .dns_entry_cache
                .write()
                .await
                .insert(EntryKey::owned(domain, rec_type), record);
        }
        Ok(())
    }
}
