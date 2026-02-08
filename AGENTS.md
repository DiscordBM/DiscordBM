## Procedure For Updating This Library With Discord Docs Changes

- Make a plan and ask for confirmation before proceeding with the changes.
- List all related commits from the Discord docs repo @ https://github.com/discord/discord-api-docs.
- The changes that will need to be made are very similar to this commit: https://github.com/DiscordBM/DiscordBM/commit/c860b84a25aca6b64701dc5ac326426beabd17a6.
- Only run non-integration tests, to confirm your changes are functional: `swift test --skip IntegrationTests`.
- When writing integration tests, be strict and accurate to ensure correctness.
- Only update the integration tests, for example when a new endpoint is added.
- For new endpoints, add their entry to Plugins/GenerateAPIEndpointsExec/Resources/openapi.yml.
  - Then run the plugin to generate code from that openapi file: `swift package --allow-writing-to-package-directory generate-api-endpoints`.
- Always update all required files that with all copies of a certain type. For example there are copies of a `Guild` in different files, sometimes called `PartialGuild`.
- Formatting is done via `swift format format --parallel --in-place --recursive .`.
  - Other than that, simply try to follow the existing formatting conventions and avoid making up rules.
- When referring to commits, always use their GitHub link, alongside the commit title and any more useful info.
- Always tolerate network connection issues. Never continue without fetching full required context.
- Always process the commit one by one in order of the oldest.
- Don't commit to git directly. I'll commit after I'm done verifying the changes.
- Update this file when necessary with info that will help AI agents to work better.
- ACCURACY IS OF UTMOST IMPORTANCE. TIME IS MEANINGLESS. MISTAKES ARE NOT TOLERATED.
