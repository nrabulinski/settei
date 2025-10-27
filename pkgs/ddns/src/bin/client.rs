use std::{
    env,
    net::{IpAddr, Ipv4Addr, Ipv6Addr},
};

use base64ct::{Base64Url, Encoding};
use color_eyre::Result;
use ddns::UpdateRecord;
use reqwest::Client;
use tap::Pipe;
use tokio::fs;

async fn send_req(client: &Client, url: &str, body: &UpdateRecord) -> Result<()> {
    client
        .post(url)
        .json(body)
        .send()
        .await?
        .error_for_status()?;
    Ok(())
}

#[tokio::main]
async fn main() -> Result<()> {
    color_eyre::install()?;
    let domain = env::var("DOMAIN")?;
    let secret = env::var("SECRET_PATH")?.pipe(fs::read).await?;
    let ddns = env::var("DDNS_URL")?;
    let which = match env::var("DDNS_MODE") {
        Ok(mut v) => {
            v.make_ascii_lowercase();
            v
        }
        Err(env::VarError::NotPresent) => "both".to_string(),
        Err(e) => return Err(e.into()),
    };

    let secret = Base64Url::encode_string(&secret);

    let both = which == "both";
    let do_v4 = both || which == "ipv4_only";
    let do_v6 = both || which == "ipv6_only";

    let body = UpdateRecord { secret, domain };

    if do_v4 {
        eprintln!("Updating IPv4 record");
        let client = Client::builder()
            .local_address(IpAddr::V4(Ipv4Addr::UNSPECIFIED))
            .build()?;
        send_req(&client, &ddns, &body).await?;
        eprintln!("Updated");
    }

    if do_v6 {
        eprintln!("Updating IPv6 record");
        let client = Client::builder()
            .local_address(IpAddr::V6(Ipv6Addr::UNSPECIFIED))
            .build()?;
        send_req(&client, &ddns, &body).await?;
        eprintln!("Updated");
    }

    Ok(())
}
