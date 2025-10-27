use color_eyre::eyre::{Result, eyre};
use serde::{Deserialize, Serialize};

#[derive(Deserialize)]
struct CfError {
    code: u32,
    #[serde(default)]
    message: String,
}

#[derive(Deserialize)]
struct CfResult<T> {
    #[serde(default)]
    errors: Vec<CfError>,
    success: bool,
    #[serde(default = "Option::default")]
    result: Option<T>,
}

impl<T> CfResult<T> {
    fn into_result(self) -> Result<T> {
        if self.success {
            Ok(self
                .result
                .expect("result should be present if success is true"))
        } else {
            let lines: Vec<_> = self
                .errors
                .into_iter()
                .map(|err| format!("\tError {}: {}", err.code, err.message))
                .collect();
            Err(eyre!("Cloudflare returned errors:\n{}", lines.join("\n")))
        }
    }
}

#[derive(Deserialize)]
struct IdOnly {
    id: String,
    // No need for the rest of the props
}

pub async fn get_zone_id_for_domain(key: &str, domain: &str) -> Result<String> {
    let mut zones = reqwest::Client::new()
        .get("https://api.cloudflare.com/client/v4/zones")
        .query(&[("name", domain)])
        .bearer_auth(key)
        .send()
        .await?
        .json::<CfResult<Vec<IdOnly>>>()
        .await?
        .into_result()?;

    match zones.len() {
        0 => Err(eyre!("No matching zones")),
        1 => Ok(zones.pop().unwrap().id),
        _ => Err(eyre!("More than one matching zone!?")),
    }
}

#[derive(Serialize)]
struct RecordBody<'a> {
    name: &'a str,
    #[serde(rename = "type")]
    rec_type: &'a str,
    ttl: i32,
    content: &'a str,
    proxied: bool,
}

pub async fn get_record_for_domain(
    key: &str,
    zone: &str,
    domain: &str,
    rec_type: &str,
) -> Result<Option<String>> {
    let mut records = reqwest::Client::new()
        .get(format!(
            "https://api.cloudflare.com/client/v4/zones/{zone}/dns_records"
        ))
        .query(&[("name.exact", domain), ("type", rec_type)])
        .bearer_auth(key)
        .send()
        .await?
        .json::<CfResult<Vec<IdOnly>>>()
        .await?
        .into_result()?;

    if records.len() > 1 {
        Err(eyre!("More than one record found for {domain:?}"))
    } else {
        Ok(records.pop().map(|body| body.id))
    }
}

pub async fn overwrite_record_for_domain(
    key: &str,
    zone: &str,
    id: &str,
    domain: &str,
    rec_type: &str,
    content: &str,
) -> Result<()> {
    let url = format!("https://api.cloudflare.com/client/v4/zones/{zone}/dns_records/{id}");
    reqwest::Client::new()
        .put(url)
        .bearer_auth(key)
        .json(&RecordBody {
            name: domain,
            rec_type,
            ttl: 1,
            content,
            proxied: false,
        })
        .send()
        .await?
        .json::<CfResult<IdOnly>>()
        .await?
        .into_result()?;
    Ok(())
}

pub async fn create_record_for_domain(
    key: &str,
    zone: &str,
    domain: &str,
    rec_type: &str,
    content: &str,
) -> Result<String> {
    let url = format!("https://api.cloudflare.com/client/v4/zones/{zone}/dns_records");
    reqwest::Client::new()
        .post(url)
        .bearer_auth(key)
        .json(&RecordBody {
            name: domain,
            rec_type,
            ttl: 1,
            content,
            proxied: false,
        })
        .send()
        .await?
        .json::<CfResult<IdOnly>>()
        .await?
        .into_result()
        .map(|body| body.id)
}
