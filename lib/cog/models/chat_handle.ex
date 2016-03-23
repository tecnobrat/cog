defmodule Cog.Models.ChatHandle do
  use Cog.Model
  use Cog.Models
  use Cog.Models.EctoJson

  schema "chat_handles" do
    field :handle, :string
    field :chat_provider_user_id, :string
    belongs_to :user, Cog.Models.User
    belongs_to :chat_provider, Cog.Models.ChatProvider, foreign_key: :provider_id, type: :integer

    timestamps
  end

  @required_fields ~w(handle user_id provider_id chat_provider_user_id)
  @optional_fields ~w()

  summary_fields [:id, :handle, :user_id, :provider_id, :chat_provider_user_id]
  detail_fields [:id, :handle, :user, :chat_provider, :chat_provider_user_id]

  def changeset(model, params \\ :empty) do
    params = coerce_chat_provider_user_id(params)

    model
    |> cast(params, @required_fields, @optional_fields)
  end

  defp coerce_chat_provider_user_id(%{"chat_provider_user_id" => chat_provider_user_id} = params),
    do: Map.put(params, "chat_provider_user_id", to_string(chat_provider_user_id))
  defp coerce_chat_provider_user_id(%{chat_provider_user_id: chat_provider_user_id} = params),
    do: Map.put(params, :chat_provider_user_id, to_string(chat_provider_user_id))
  defp coerce_chat_provider_user_id(params),
    do: params
end
