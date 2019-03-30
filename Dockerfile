FROM elixir:1.8-alpine

# Working directory
WORKDIR /opt/app

# Environment variables
ENV MIX_ENV prod

# Install basic tools
RUN mix local.hex --force
RUN mix local.rebar --force

# Install dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only prod
RUN mix deps.compile

# Copy source code
COPY lib lib
COPY config config

# Compile
RUN mix deps.get --only prod
RUN mix compile

# Start
CMD ["elixir", "-S", "mix", "run", "--no-halt"]
