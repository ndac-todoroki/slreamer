FROM elixir:latest as builder

ARG app_name
ARG build_env
ARG release_name

ENV MIX_ENV=${build_env} TERM=xterm

WORKDIR /app

# Install dependencies

RUN apt update -y \
    && mix local.rebar --force \
    && mix local.hex --force

COPY . .

# Initial setup
RUN mix do deps.get --only prod, compile

# Create release
RUN mix release --overwrite ${release_name}

# ----

FROM gcr.io/google.com/cloudsdktool/cloud-sdk:latest

ARG service_account_filename
ARG bucket_url

WORKDIR /app

# copy the release artifacts from the previous step
COPY --from=builder /app/_build/prod/*.tar.gz .

# copy the service account and startup script
COPY  ${service_account_filename} /credentials/service-account.json
COPY instance-startup.sh .

# set env variables
ENV GOOGLE_APPLICATION_CREDENTIALS=/credentials/service-account.json
ENV CLOUDSDK_CONFIG=/credentials

# activate the service account to be able to use google cloud sdk
RUN gcloud auth activate-service-account --key-file=/credentials/service-account.json

# upload the releaser on cloud storage with gsutil
RUN gsutil -m cp -r . ${bucket_url}

CMD ["sh"]