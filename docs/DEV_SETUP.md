# Dev setup (macOS)

## Docker
```bash
docker compose build
AWS_PROFILE=default docker compose run --rm dev make deploy
```

## Host tools
```bash
brew bundle
make setup
```

## Daily
```bash
git pull
source .venv/bin/activate
```
