# Hospital Alerting (Ward Alert MVP)

Uploads to S3 under a ward prefix trigger a Lambda that sends an SMS `ALERT: Bed X` to a shared ward phone.

## Quickstart (Docker)
```bash
docker compose build
docker compose run --rm dev
# inside the container:
make deploy
touch sample.MOV && make test
```
> The container uses your host AWS creds via ~/.aws mount.

## Quickstart (host)
```bash
brew bundle
make setup
make deploy
touch sample.MOV && make test
```

- Ensure `BUCKET` and `ARTIFACTS` in the Makefile are **unique**.
- iPhone videos are .MOV; default suffix filter is `.MOV`. Adjust if needed.
- The test uploads to `s3://$BUCKET/ward-A3/bed-4/videos/test.MOV` which should trigger `ALERT: Bed 4`.
