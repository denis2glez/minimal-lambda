use lambda_runtime::{Context, Error};
use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize)]
struct Event {
    first_name: String,
    last_name: String,
}

#[derive(Serialize)]
struct Output {
    message: String,
    request_id: String,
}

async fn handler(event: Event, context: Context) -> Result<Output, Error> {
    let message = format!("Welcome {} {}!", event.first_name, event.last_name);

    Ok(Output {
        message,
        request_id: context.request_id,
    })
}

#[tokio::main]
async fn main() -> Result<(), Error> {
    let handler = lambda_runtime::handler_fn(handler);
    lambda_runtime::run(handler).await?;
    Ok(())
}
