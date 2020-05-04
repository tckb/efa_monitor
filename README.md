_THIS PROJECT IS NOT MAINTAINED HERE ANYMORE!_

# (EFA) Elektronische Fahrplanauskunft Monitor
An Elixir wrapper around the transportation services across Germany. This is an Elixir Umbrella application where the main "core" logic resides in [`dm_core`](apps/dm_core) application. 

## Production release

### Phoenix Web frontend
[Web frontend](apps/dm_web_front/) is added as a part of releases. 


Assemble the artifact:

```bash
$ MIX_ENV=prod SECRET_KEY_BASE=<super_secret_key> PORT=<port> mix release web_frontend 

Release created at _build/prod/rel/web_frontend!

    # To start your system
    _build/prod/rel/web_frontend/bin/web_frontend start

Once the release is running:

    # To connect to it remotely
    _build/prod/rel/web_frontend/bin/web_frontend remote

    # To stop it gracefully (you may also send SIGINT/SIGTERM)
    _build/prod/rel/web_frontend/bin/web_frontend stop

To list all commands:

    _build/prod/rel/web_frontend/bin/web_frontend
```

# Disclaimer 
 Unless specified otherwise, the [License](LICENSE) applies to all files in this repository.
