# Nauvisian

A library and CLI tool for the management of [Factorio](https://factorio.com) MODs and saves.

It eases downloading MODs, enabling/disabling locally installed MODs and synchroning MODs and settings with save files.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add nauvisian

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install nauvisian

## CLI Usage

- `nvsn mod disable MOD`
    Disable an installed MOD
- `nvsn mod download MOD` 🔐
    Download a MOD to the current directory
- `nvsn mod enable MOD`
    Enable an installed MOD
- `nvsn mod info MOD` 🖧
    Show info of MOD
- `nvsn mod installed`
    List installed MODs
- `nvsn mod latest MOD` 🖧
    Show the latest version of MOD
- `nvsn mod versions MOD` 🖧
    List available versions of MOD
- `nvsn mod settings dump`
    Dump MOD settings
- `nvsn save mod list SAVE`
    List MODs used in the given SAVE
- `nvsn save mod sync SAVE` 🔐
    Synchronize MODs and startup settings with the given SAVE

For options recognized by the commands above, try the command with `--help`.

- Commands with 🔐 requires the credenail information generally found in your `player-data.json`
- Commands with 🖧 accesses MOD portal's public API

## Development

After checking out the repo, run `bin/setup` to install dependencies.  It also copies currently installed MODs and saves into the workspace.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sakuro/nauvisian.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
