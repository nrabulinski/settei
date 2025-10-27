use std::{
    convert::Infallible,
    env,
    net::{IpAddr, SocketAddr},
    result::Result as StdResult,
};

use axum::{
    Json, Router,
    extract::{ConnectInfo, FromRequestParts, State},
    routing::post,
};
use base64ct::{Base64Url, Encoding};
use color_eyre::eyre::Result;
use ddns::{UpdateRecord, state::Ddns};
use tap::Pipe;
use tokio::{fs, net::TcpListener};

struct RealIp(IpAddr);

fn ip_addr_from_parts(parts: &axum::http::request::Parts) -> IpAddr {
    parts
        .extensions
        .get::<ConnectInfo<SocketAddr>>()
        .expect("connect info should be present")
        .ip()
}

impl<S> FromRequestParts<S> for RealIp
where
    S: Send + Sync,
{
    type Rejection = Infallible;

    async fn from_request_parts(
        parts: &mut axum::http::request::Parts,
        _: &S,
    ) -> StdResult<Self, Infallible> {
        let ip = parts
            .headers
            .get("X-Real-Ip")
            .and_then(|header| header.to_str().ok())
            .and_then(|header| header.parse().ok())
            .unwrap_or_else(|| ip_addr_from_parts(parts));
        Ok(RealIp(ip))
    }
}

async fn update_record_cf(state: Ddns, domain: String, addr: IpAddr) {
    if let Err(e) = state.set_record(&domain, addr).await {
        eprintln!("Updating CF record for {domain:?} to {addr:?} failed: {e:?}");
    }
}

async fn update_record(
    State(state): State<Ddns>,
    RealIp(ip): RealIp,
    Json(body): Json<UpdateRecord>,
) -> &'static str {
    let secret = Base64Url::decode_vec(&body.secret).unwrap_or_default();
    if state.check_secret(&secret) {
        tokio::spawn(update_record_cf(state, body.domain, ip));
    }
    "ok"
}

#[tokio::main]
async fn main() -> Result<()> {
    color_eyre::install()?;
    let domain = env::var("DOMAIN")?;
    let secret = env::var("SECRET_PATH")?.pipe(fs::read).await?;
    let cf_key = env::var("CF_KEY_PATH")?.pipe(fs::read_to_string).await?;
    let cf_key = cf_key
        .lines()
        .find_map(|line| {
            line.trim_start()
                .strip_prefix("CF_DNS_API_TOKEN=")
                .map(str::trim)
        })
        .expect("CF_KEY_PATH should include DNS API token line");

    let port = env::var("PORT")?.parse()?;
    let listener = TcpListener::bind(("127.0.0.1", port)).await?;

    let router = Router::new()
        .route("/", post(update_record))
        .with_state(Ddns::new(secret, domain, cf_key.to_string()));

    axum::serve(
        listener,
        router.into_make_service_with_connect_info::<SocketAddr>(),
    )
    .await?;

    Ok(())
}
