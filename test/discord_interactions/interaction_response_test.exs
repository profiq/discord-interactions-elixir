defmodule DiscordInteractions.InteractionResponseTest do
  use ExUnit.Case
  doctest DiscordInteractions.InteractionResponse

  alias DiscordInteractions.InteractionResponse

  describe "pong/0" do
    test "creates a pong response" do
      assert %{type: 1, data: %{}} = InteractionResponse.pong()
    end
  end

  describe "channel_message_with_source/1" do
    test "creates a default message response with empty data" do
      assert %{type: 4, data: %{}} = InteractionResponse.channel_message_with_source()
    end

    test "creates a message response with provided data" do
      assert %{type: 4, data: %{content: "Hello"}} = InteractionResponse.channel_message_with_source(%{content: "Hello"})
    end
  end

  describe "deferred_channel_message_with_source/1" do
    test "creates a default deferred message response with empty data" do
      assert %{type: 5, data: %{}} = InteractionResponse.deferred_channel_message_with_source()
    end

    test "creates a deferred message response with provided data" do
      assert %{type: 5, data: %{content: "Loading"}} = InteractionResponse.deferred_channel_message_with_source(%{content: "Loading"})
    end
  end

  describe "deferred_update_message/1" do
    test "creates a default deferred update response with empty data" do
      assert %{type: 6, data: %{}} = InteractionResponse.deferred_update_message()
    end

    test "creates a deferred update response with provided data" do
      assert %{type: 6, data: %{content: "Updating"}} = InteractionResponse.deferred_update_message(%{content: "Updating"})
    end
  end

  describe "update_message/1" do
    test "creates a default update message response with empty data" do
      assert %{type: 7, data: %{}} = InteractionResponse.update_message()
    end

    test "creates an update message response with provided data" do
      assert %{type: 7, data: %{content: "Updated"}} = InteractionResponse.update_message(%{content: "Updated"})
    end
  end

  describe "application_command_autocomplete_result/1" do
    test "creates a default autocomplete response with empty choices" do
      assert %{type: 8, data: %{choices: []}} = InteractionResponse.application_command_autocomplete_result()
    end

    test "creates an autocomplete response with provided choices" do
      choices = [%{name: "Option 1", value: "opt1"}, %{name: "Option 2", value: "opt2"}]
      assert %{type: 8, data: %{choices: ^choices}} = InteractionResponse.application_command_autocomplete_result(%{choices: choices})
    end
  end

  describe "modal/1" do
    test "creates a modal response with provided data" do
      assert %{type: 9, data: %{title: "Form", custom_id: "form_id"}} = InteractionResponse.modal(%{title: "Form", custom_id: "form_id"})
    end
  end

  describe "premium_required/0" do
    test "creates a premium required response" do
      assert %{type: 10, data: %{}} = InteractionResponse.premium_required()
    end
  end

  describe "launch_activity/0" do
    test "creates a launch activity response" do
      assert %{type: 12, data: %{}} = InteractionResponse.launch_activity()
    end
  end

  describe "tts/1" do
    test "sets the tts flag" do
      response = InteractionResponse.channel_message_with_source()
      assert %{data: %{tts: true}} = InteractionResponse.tts(response)
    end
  end

  describe "content/2" do
    test "sets the content" do
      response = InteractionResponse.channel_message_with_source()
      assert %{data: %{content: "Hello"}} = InteractionResponse.content(response, "Hello")
    end
  end

  describe "embeds/2" do
    test "sets the embeds" do
      response = InteractionResponse.channel_message_with_source()
      embeds = [%{title: "Embed", description: "Description"}]
      assert %{data: %{embeds: ^embeds}} = InteractionResponse.embeds(response, embeds)
    end
  end

  describe "allowed_mentions/2" do
    test "sets default values with empty options" do
      response = InteractionResponse.channel_message_with_source()
      result = InteractionResponse.allowed_mentions(response, [])

      assert %{
        data: %{
          allowed_mentions: %{
            parse: [],
            roles: [],
            users: [],
            replied_user: false
          }
        }
      } = result
    end

    test "sets all provided options" do
      response = InteractionResponse.channel_message_with_source()
      roles = ["123", "456"]
      users = ["789"]

      result = InteractionResponse.allowed_mentions(response, [
        parse: [:users, :roles],
        roles: roles,
        users: users,
        replied_user: true
      ])

      assert %{
        data: %{
          allowed_mentions: %{
            parse: [:users, :roles],
            roles: ^roles,
            users: ^users,
            replied_user: true
          }
        }
      } = result
    end
  end

  describe "flags/2" do
    test "sets the flags" do
      response = InteractionResponse.channel_message_with_source()
      assert %{data: %{flags: 64}} = InteractionResponse.flags(response, 64)
    end
  end

  describe "components/2" do
    test "sets the components" do
      response = InteractionResponse.channel_message_with_source()
      components = [%{type: 1, components: [%{type: 2, label: "Button", custom_id: "btn1"}]}]
      assert %{data: %{components: ^components}} = InteractionResponse.components(response, components)
    end
  end

  describe "attachments/2" do
    test "sets the attachments" do
      response = InteractionResponse.channel_message_with_source()
      attachments = [%{id: 1, filename: "file.txt"}]
      assert %{data: %{attachments: ^attachments}} = InteractionResponse.attachments(response, attachments)
    end
  end

  describe "poll/2" do
    test "sets the poll" do
      response = InteractionResponse.channel_message_with_source()
      poll = %{question: "Question?", options: [%{text: "Option 1"}, %{text: "Option 2"}]}
      assert %{data: %{poll: ^poll}} = InteractionResponse.poll(response, poll)
    end
  end

  describe "suppress_embeds/1" do
    test "sets the suppress embeds flag on a response with no flags" do
      response = InteractionResponse.channel_message_with_source()
      assert %{data: %{flags: 2}} = InteractionResponse.suppress_embeds(response)
    end

    test "combines with existing flags" do
      response = InteractionResponse.channel_message_with_source(%{flags: 64})
      assert %{data: %{flags: 66}} = InteractionResponse.suppress_embeds(response)
    end
  end

  describe "ephemeral/1" do
    test "sets the ephemeral flag on a response with no flags" do
      response = InteractionResponse.channel_message_with_source()
      assert %{data: %{flags: 64}} = InteractionResponse.ephemeral(response)
    end

    test "combines with existing flags" do
      response = InteractionResponse.channel_message_with_source(%{flags: 2})
      assert %{data: %{flags: 66}} = InteractionResponse.ephemeral(response)
    end
  end

  describe "suppress_notifications/1" do
    test "sets the suppress notifications flag on a response with no flags" do
      response = InteractionResponse.channel_message_with_source()
      assert %{data: %{flags: 4096}} = InteractionResponse.suppress_notifications(response)
    end

    test "combines with existing flags" do
      response = InteractionResponse.channel_message_with_source(%{flags: 64})
      assert %{data: %{flags: 4160}} = InteractionResponse.suppress_notifications(response)
    end
  end

  describe "is_components_v2/1" do
    test "sets the components v2 flag on a response with no flags" do
      response = InteractionResponse.channel_message_with_source()
      assert %{data: %{flags: 32768}} = InteractionResponse.is_components_v2(response)
    end

    test "combines with existing flags" do
      response = InteractionResponse.channel_message_with_source(%{flags: 64})
      assert %{data: %{flags: 32832}} = InteractionResponse.is_components_v2(response)
    end
  end

  describe "title/2" do
    test "sets the modal title" do
      response = InteractionResponse.modal()
      assert %{data: %{title: "My Form"}} = InteractionResponse.title(response, "My Form")
    end
  end

  describe "custom_id/2" do
    test "sets the modal custom ID" do
      response = InteractionResponse.modal()
      assert %{data: %{custom_id: "form_id"}} = InteractionResponse.custom_id(response, "form_id")
    end
  end

  describe "function chaining for message responses" do
    test "can chain content and flag functions together" do
      response = InteractionResponse.channel_message_with_source()
                 |> InteractionResponse.content("Hello, world!")
                 |> InteractionResponse.ephemeral()
                 |> InteractionResponse.suppress_embeds()

      assert %{
        type: 4,
        data: %{
          content: "Hello, world!",
          flags: 66  # 64 (ephemeral) + 2 (suppress_embeds)
        }
      } = response
    end
  end

  describe "function chaining for modal responses" do
    test "can chain modal field setters together" do
      components = [%{type: 1, components: []}]

      response = InteractionResponse.modal()
                 |> InteractionResponse.title("My Form")
                 |> InteractionResponse.custom_id("form_id")
                 |> InteractionResponse.components(components)

      assert %{
        type: 9,
        data: %{
          title: "My Form",
          custom_id: "form_id",
          components: ^components
        }
      } = response
    end
  end
end
