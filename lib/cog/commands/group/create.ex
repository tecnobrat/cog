defmodule Cog.Commands.Group.Create do
  require Cog.Commands.Helpers, as: Helpers
  alias Cog.Commands.Group
  alias Cog.Repository.Groups

  Helpers.usage """
  Creates new user groups.

  USAGE
    group create [FLAGS] <group_name>

  ARGS
    group_name    The name of the user group to create

  FLAGS
    -h, --help    Display this usage info
  """

  @spec create_group(%Cog.Command.Request{}, List.t) :: {:ok, String.t, Map.t} | {:error, any()}
  def create_group(req, arg_list) do
    if Helpers.flag?(req.options, "help") do
      show_usage
    else
      case Helpers.get_args(arg_list, 1) do
        {:ok, [group_name]} ->
          case Groups.new(%{name: group_name}) do
            {:ok, group} ->
              {:ok, "user-group-create", Group.json(group)}
            {:error, changeset} ->
              {:error, {:db_errors, changeset.errors}}
          end
        {:error, {:not_enough_args, _}} ->
          show_usage("Missing required argument: group_name")
        {:error, {:too_many_args, _}} ->
          show_usage("Too many arguments. You can only create one user group at a time.")
        error ->
          error
      end
    end
  end
end
