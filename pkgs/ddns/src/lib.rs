use serde::{Deserialize, Serialize};

pub mod cf;
pub mod state;

#[derive(Deserialize, Serialize)]
pub struct UpdateRecord {
    pub secret: String,
    pub domain: String,
}
